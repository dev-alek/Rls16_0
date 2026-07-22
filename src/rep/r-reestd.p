block-level on error undo, throw.
/*

$Revision: 504acad51c75, 1685, rls $
$Author: EShklyar $
$Date: Tue Dec 11 10:07:22 2018 +0300 $
$Workfile: r-reestd.p $
$Archive: rep/r-reestd.p $

Реестр документов (Кедр-М)


Автор: Демин Алексей Сергеевич
Дата создания: 12/18/08
Author: Alexey Demin
Creation date: 12/18/08

Input:

Output:

*/

define variable vss-revision    as character no-undo init "$Revision: 504acad51c75, 1685, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 11 10:07:22 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-reestd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-reestd.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/r-page1.i      }
{ cmp/r-pril.i       }
{ rep/r-sym.i        }
{ gbl/waitfram.i     }
{ rep/p-fmt.i        }
{ gbl/paramls.i      }
{ rep/repfrm.i def   }
{ gbl/cur-time.i     }

{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/trdcalib.i }
{ trg/factord.i  }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/clcprtsl.i }

define variable factorder1    like stk-tot.Fact-order no-undo.
define variable p-fact-order  like stk-tot.Fact-order no-undo.
define variable factorder2    like stk-tot.Fact-order no-undo.
define variable v-clients               as character  no-undo.
define variable v-single-line           as character    no-undo.
define variable v-attr-doc-code         as character    no-undo.
define variable v-attr-type             as character    no-undo.
define variable varr-b                  as character    no-undo .
define variable v-type                  as character    no-undo.
define variable p-shift-end-fact-order  as decimal      no-undo.
define variable p-day-end-fact-order    as decimal      no-undo.
define variable v-ind                   as INTEGER      no-undo.
define variable v-stoim                 as decimal      no-undo.
define variable SLT-sum                 as decimal      no-undo.
define variable vat-acc                 as decimal      no-undo.
define variable vat-acc-ten             as decimal      no-undo.
define variable vat-acc-eighteen        as decimal      no-undo.
define variable excise-cli-acc          as decimal      no-undo.
define variable vat-cli-acc             as decimal      no-undo.
define variable sum-dsc-cli-acc         as decimal      no-undo.
define variable sum-cli-novat           as decimal      no-undo.
define variable sum-pr-list             as decimal      no-undo.
define variable itog-v-ind              as INTEGER      no-undo.
define variable itog-vat-acc            as decimal      no-undo.
define variable itog-sum-dsc-cli-acc    as decimal      no-undo.
define variable itog-sum-cli-novat      as decimal      no-undo.
define variable itog-vat-acc-eighteen   as decimal      no-undo.
define variable itog-vat-acc-ten        as decimal      no-undo.
define variable itog-sum-pr-list        as decimal      no-undo.
define variable v-test                  as decimal      no-undo.
define variable v-qnty                  as decimal      no-undo.
define variable v-sum-pl                as decimal      no-undo.
define variable itog-v-sum-pl           as decimal      no-undo.
define variable old-price               as decimal      no-undo.
define variable v-old                   as decimal      no-undo.

define variable varcur-fact-qnty    like ub.gds-dtl.fact-qnty     no-undo .
define variable varcur-base         like ub.gds-dtl.price-base    no-undo .
define variable varcur-road-tax     like ub.doc-line.road-tax     no-undo .
define variable varcur-excise       like ub.doc-line.excise       no-undo .
define variable varcur-vat-pc       like ub.doc-line.vat-pc       no-undo .
define variable varcur-cons-vat-pc  like ub.doc-line.cons-vat-pc  no-undo .
define variable varcur-slt-pc       like ub.doc-line.slt-pc       no-undo .
define variable varprice-sale       like ub.price-list.price-sale no-undo .
define variable vardoc-num          like ub.price-doc.doc-num     no-undo .
define variable varb-code           like ub.bar-code.b-code       no-undo .
define variable varroad-tax         like ub.price-list.road-tax   no-undo .
define variable varexcise           like ub.price-list.excise     no-undo .
define variable varlastcur-base     like ub.gds-dtl.price-base    no-undo .
define variable varlastcur-road-tax like ub.gds-dtl.price-base    no-undo .
define variable varlastcur-excise   like ub.gds-dtl.price-base    no-undo .

define variable v-shift-obj-on as logical      no-undo.
define variable is-petrolium   as logical      no-undo.
define variable is-pieces      as logical      no-undo.
define variable v-print-rubl   as logical      no-undo.
define variable v-flag         as logical      no-undo init "false".
define variable v-linenm       as integer      no-undo.

define buffer buf_trn-doc   for trn-doc .
define buffer buf_doc-line  for doc-line .
define buffer buf_clients   for clients .
define buffer buf_parts     for parts .
define buffer buf_doc-attr  for doc-attr .
define buffer buf_goods     for goods .
define buffer buf_sysconf   for sysconf .
define buffer buf_gds-dtl   for gds-dtl .
define buffer buf_price-doc for price-doc .
define buffer buf_sys-ctrl  for sys-ctrl .
&scop sum-fmt ">>>>>>>>>>>>>>>9.<<<":U


do
on error undo, return error
:
/*---------------------------------*/
define stream out-stream.
define variable parparentproc  as handle  no-undo .
define variable g#report-num   as integer no-undo .
assign
  parparentproc = my-handle
.
run get-report-num in my-handle (output g#report-num).
{ gbl/getcntxt.i def }
{ rep/reestdxl.i     }

/*---------------------------------------*/

/*print*/

/*-------------------------------*/
 /* выбираем валюту */
  case x-SET_val_TYPE :
    when {&v-rubl} then do:
      assign
        v-print-rubl = yes
      .
    end.
    when {&v-base} then do:
      assign
        v-print-rubl = no
      .
    end.
    end.
  find first buf_sys-ctrl no-lock.
  v-single-line = fill("-", 198).
 { cmp/open-out.i stream out-stream " " 42}
  FORM HEADER
    string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 160 format "X(13)" skip
    with FRAME TopFrame width {&DOS_CW} PAGE-TOP use-text stream-io NO-LABELS no-box.
  VIEW stream out-stream FRAME TopFrame .

  FORM HEADER
  "Продолжение - на следующей странице" AT 10 SKIP
  with FRAME CliBottomFrame width {&DOS_CW} PAGE-BOTTOM use-text stream-io NO-LABELS no-box.
  VIEW stream out-stream FRAME CliBottomFrame .

  run reestdxl-init in this-procedure .

  run pr-Header in this-procedure.

  run incom in this-procedure(
  input {&TDEDT_Pri_Vnesh}
  ).
  run incom in this-procedure(
  input {&TDEDT_Ras_Vnesh_VP}
  ).
  run price in this-procedure
  .
  run incom in this-procedure(
  input {&TDEDT_Pri_Perem}
  ).
  run incom in this-procedure(
  input {&TDEDT_Ras_Perem}
  ).
  run incom in this-procedure(
  input {&TDEDT_Spi_Vnesh}
  ).
  run footer in this-procedure.
  hide stream out-stream FRAME TopFrame .
  hide stream out-stream frame CliBottomFrame.
  run reestdxl-close in this-procedure .
  output stream out-stream close.
  {&CloseExcel}

  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
    run gbl/prnfilen.w
      ( input  ""
      , input  8 /*DisabledOptions*/
      , input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      , input  ReportFontNum
      , output v-user-action
      , output v-printed
      ) .

  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .

      define frame Pri_Vnesh
        sym1                  column-label ":!:"  format "X(1)" space(0)
        v-ind                 column-label "№! п/п "  format "->>,>>9" space(0)
        sym2                  column-label ":!:" format "X(1)" space(0)
        v-clients             column-label "Наименование контрагента! ":C40 format "X(40)" space(0)
        sym3                  column-label ":!:"  format "X(1)" space(0)
        buf_trn-doc.fact-date column-label "Дата прихода!документа"  format "99/99/99" space(0)
        sym4                  column-label ":!:" format "X(1)" space(0)
        v-attr-doc-code       column-label "№ документа!по контрагенту" format "X(14)" space(0)
        sym5                  column-label ":!:" format "X(1)" space(0)
        buf_trn-doc.doc-code  column-label "№ документа!в системе" format "X(14)" space(0)
        sym6                  column-label ":!:" format "X(1)" space(0)
        sum-cli-novat         column-label "Сумма по поставщику!без НДС":C20 format "->>,>>>,>>9.99" space(0)
        sym7                  column-label ":!:" format "X(1)" space(0)
        vat-acc-ten           column-label "Сумма НДС!10%":C10 format "->>,>>>,>>9.99" space(0)
        sym8                  column-label ":!:" format "X(1)" space(0)
        vat-acc-eighteen      column-label "Сумма НДС!18/20%:":C10 format "->>,>>>,>>9.99" space(0)
        sym9                  column-label ":!:" format "X(1)" space(0)
        vat-acc               column-label "Сумма НДС! ":C10 format "->>,>>>,>>9.99" space(0)
        sym10                 column-label ":!:" format "X(1)" space(0)
        sum-dsc-cli-acc       column-label "Сумма по поставщику!с НДС":c20 format "->>,>>>,>>9.99" space(0)
        sym11                 column-label ":!:" format "X(1)" space(0)
        sum-pr-list           column-label "Сумма в продажных!ценах":C18 format "->>,>>>,>>9.99" space(0)
        sym12                 column-label ":!:" format "X(1)" space(0)
        header "1. Приход внешний"
        cur-time-print() at 5 format "X(35)" skip
        v-single-line format "X(198)" at 1

        with width {&DOS_CW} down stream-io use-text .
      define frame Ras_Vnesh_VP
        sym1                  column-label ":!:"  format "X(1)" space(0)
        v-ind                 column-label "№! п/п "  format "->>,>>9" space(0)
        sym2                  column-label ":!:" format "X(1)" space(0)
        v-clients             column-label "Наименование контрагента! ":C40 format "X(40)" space(0)
        sym3                  column-label ":!:"  format "X(1)" space(0)
        buf_trn-doc.fact-date column-label "Дата !возврата"  format "99/99/99" space(0)
        sym4                  column-label ":!:" format "X(1)" space(0)
        buf_trn-doc.doc-code  column-label "№ документа!в системе" format "X(14)" space(0)
        sym5                  column-label ":!:" format "X(1)" space(0)
        buf_trn-doc.fact-qnty column-label "Количество!по накладной" format "->>,>>>,>>9.<<<" space(0)
        sym6                  column-label ":!:" format "X(1)" space(0)
        sum-cli-novat         column-label "Сумма по поставщику!без НДС":C20 format "->>,>>>,>>9.99" space(0)
        sym7                  column-label ":!:" format "X(1)" space(0)
        vat-acc-ten           column-label "Сумма НДС!10%":C10 format "->>,>>>,>>9.99" space(0)
        sym8                  column-label ":!:" format "X(1)" space(0)
        vat-acc-eighteen      column-label "Сумма НДС!18/20%:":C10 format "->>,>>>,>>9.99" space(0)
        sym9                  column-label ":!:" format "X(1)" space(0)
        vat-acc               column-label "Сумма НДС! ":C10 format "->>,>>>,>>9.99" space(0)
        sym10                 column-label ":!:" format "X(1)" space(0)
        sum-dsc-cli-acc       column-label "Сумма по поставщику!с НДС":c20 format "->>,>>>,>>9.99" space(0)
        sym11                 column-label ":!:" format "X(1)" space(0)
        sum-pr-list           column-label "Сумма в продажных!ценах":C18 format "->>,>>>,>>9.99" space(0)
        sym12                 column-label ":!:" format "X(1)" space(0)
        header "2. Возврат поставщику"
        v-single-line format "X(192)" at 1
        with width {&DOS_CW} down stream-io use-text .
      define frame Pri_Perem
        sym1                  column-label ":!:"  format "X(1)" space(0)
        v-ind                 column-label "№! п/п "  format "->>,>>9" space(0)
        sym2                  column-label ":!:" format "X(1)" space(0)
        v-clients             column-label "Наименование контрагента! ":C40 format "X(40)" space(0)
        sym3                  column-label ":!:"  format "X(1)" space(0)
        buf_trn-doc.fact-date column-label "Дата прихода! "  format "99/99/99" space(0)
        sym5                  column-label ":!:" format "X(1)" space(0)
        buf_trn-doc.doc-code  column-label "№ документа!в системе":C14 format "X(14)" space(0)
        sym6                  column-label ":!:" format "X(1)" space(0)
        buf_trn-doc.fact-qnty column-label "Количество!по накладной":C13 format "->>,>>>,>>9.<<<" space(0)
        sym7                  column-label ":!:" format "X(1)" space(0)
        sum-dsc-cli-acc       column-label "Сумма по поставщику!с НДС":c20 format "->>,>>>,>>9.99" space(0)
        sym12                 column-label ":!:" format "X(1)" space(0)
        sum-cli-novat      column-label "Сумма по поставщику!без НДС":c20 format "->>,>>>,>>9.99" space(0)
        sym14                 column-label ":!:" format "X(1)" space(0)
        sum-pr-list           column-label "Сумма в продажных!ценах":C18 format "->>,>>>,>>9.99" space(0)
        sym13                 column-label ":!:" format "X(1)" space(0)
        header "4. Приход внутренний"
        v-single-line format "X(160)" at 1
        with width {&DOS_CW} down stream-io use-text .
      define frame Ras_Perem
        sym1                  column-label ":!:"  format "X(1)" space(0)
        v-ind                 column-label "№! п/п "  format "->>,>>9" space(0)
        sym2                  column-label ":!:" format "X(1)" space(0)
        v-clients             column-label "Наименование!контрагента " format "X(40)" space(0)
        sym3                  column-label ":!:"  format "X(1)" space(0)
        buf_trn-doc.fact-date column-label "Дата расхода! "  format "99/99/99" space(0)
        sym5                  column-label ":!:" format "X(1)" space(0)
        buf_trn-doc.doc-code  column-label "№ документа!в системе":C13 format "X(14)" space(0)
        sym6                  column-label ":!:" format "X(1)" space(0)
        buf_trn-doc.fact-qnty column-label "Количество!по накладной":C13 format "->>,>>>,>>9.<<<" space(0)
        sym7                  column-label ":!:" format "X(1)" space(0)
        sum-dsc-cli-acc       column-label "Сумма по поставщику!с НДС":c20 format "->>,>>>,>>9.99" space(0)
        sym12                 column-label ":!:" format "X(1)" space(0)
        sum-cli-novat      column-label "Сумма по поставщику!без НДС":c22 format "->>,>>>,>>9.99" space(0)
        sym14                 column-label ":!:" format "X(1)" space(0)
        sum-pr-list           column-label "Сумма в продажных!ценах":C18 format "->>,>>>,>>9.99" space(0)
        sym13                 column-label ":!:" format "X(1)" space(0)
        header "5. Расход внутренний"
        v-single-line format "X(160)" at 1
        with width {&DOS_CW} down stream-io use-text .
      define frame Spi_Vnesh
        sym1                  column-label ":!:"  format "X(1)" space(0)
        v-ind                 column-label "№! п/п "  format "->>,>>9" space(0)
        sym3                  column-label ":!:"  format "X(1)" space(0)
        buf_trn-doc.fact-date column-label "Дата ! ":C4  format "99/99/99" space(0)
        sym5                  column-label ":!:" format "X(1)" space(0)
        buf_trn-doc.doc-code  column-label "№ документа!в системе" format "X(14)" space(0)
        sym6                  column-label ":!:" format "X(1)" space(0)
        buf_trn-doc.fact-qnty column-label "Количество!по накладной":C13 format "->>,>>>,>>9.<<<" space(0)
        sym7                  column-label ":!:" format "X(1)" space(0)
        sum-dsc-cli-acc       column-label "Сумма по поставщику!с НДС":c22 format "->>,>>>,>>9.99" space(0)
        sym12                 column-label ":!:" format "X(1)" space(0)
        sum-pr-list           column-label "Сумма в продажных!ценах":C18 format "->>,>>>,>>9.<<<" space(0)
        sym13                 column-label ":!:" format "X(1)" space(0)
        header "6. Списание"
        v-single-line format "X(87)" at 1
        with width {&DOS_CW} down stream-io use-text .
      define frame bef-h-ov
        sym1                    column-label ":!:"  format "X(1)" space(0)
        v-ind                   column-label "№! п/п "  format "->>,>>9" space(0)
        sym3                    column-label ":!:"  format "X(1)" space(0)
        buf_price-doc.fact-date column-label "Дата! "  format "99/99/99" space(0)
        sym5                    column-label ":!:" format "X(1)" space(0)
        buf_price-doc.doc-num   column-label "№ документа!в системе" format "X(14)" space(0)
        sym6                    column-label ":!:" format "X(1)" space(0)
        v-qnty                  column-label "Количество!по документу":C13 format "->>,>>>,>>9.<<<" space(0)
        sym7                    column-label ":!:" format "X(1)" space(0)
        v-sum-pl                column-label "Сумма переоценки !в продажных ценах":C17 format "->>,>>>,>>9.<<<" space(0)
        sym12                   column-label ":!:" format "X(1)" space(0)
        header "3. Переоценка"
        v-single-line format "X(64)" at 1
        with width {&DOS_CW} down stream-io use-text .

/*==========================================================================*/
procedure pr-Header :  /*Шапка документа*/
do
on error undo, return error
:
find first obj-list no-lock
no-error.
put stream  out-stream
space (70) "РЕЕСТР ДОКУМЕНТОВ" SKIP
space (65) "ЗА ПЕРИОД с " string(x-Date-Start,"99/99/99") " по " string(x-Date-End,"99/99/99") SKIP
space (65) obj-list.obj-name            skip.
if v-flag = true
then do:
put stream  out-stream
space (65) "Порядок смен - без смен " skip.
run reestdxl-write-cell-data in this-procedure ( input {&reestdxl-h_num}   , input "Порядок смен - без смен " ).
end.
else do:
put stream  out-stream
space (65) "Порядок смен с "X-Shift-Start " по " X-Shift-End skip.
run reestdxl-write-cell-data in this-procedure ( input {&reestdxl-h_num}   , input substitute("Порядок смен с &1  по  &2", X-Shift-Start, X-Shift-End  ) ).
end.
run reestdxl-write-cell-data in this-procedure ( input {&reestdxl-h_date}  , input substitute("ЗА ПЕРИОД с  &1  по &2", string(x-Date-Start, "99/99/99"), string(x-Date-End, "99/99/99"))).
run reestdxl-write-cell-data in this-procedure ( input {&reestdxl-h_obj}   , input substitute("&1", obj-list.obj-name  ) ).

end. /* do on error */
end procedure. /* Header */
/*==========================================================================*/
procedure footer :

do
on error undo, return error
:
put stream out-stream
skip  (2)
space (20) "Администратор торгового зала _________________            Ст. продавец _________________            Бухгалтер _________________".

run reestdxl-write-cell-data in this-procedure ( input {&reestdxl-f_sign}  , input "Администратор торгового зала _________________            Ст. продавец _________________            Бухгалтер _________________").
run reestdxl-write-cell-data in this-procedure ( input {&reestdxl-f_sign2} , input "Администратор торгового зала _________________            Ст. продавец _________________            Бухгалтер _________________").
run reestdxl-write-cell-data in this-procedure ( input {&reestdxl-f_sign3} , input "Администратор торгового зала _________________            Ст. продавец _________________            Бухгалтер _________________").
run reestdxl-write-cell-data in this-procedure ( input {&reestdxl-f_sign4} , input "Администратор торгового зала _________________            Ст. продавец _________________            Бухгалтер _________________").
run reestdxl-write-cell-data in this-procedure ( input {&reestdxl-f_sign5} , input "Администратор торгового зала _________________            Ст. продавец _________________            Бухгалтер _________________").
run reestdxl-write-cell-data in this-procedure ( input {&reestdxl-f_sign6} , input "Администратор торгового зала _________________            Ст. продавец _________________            Бухгалтер _________________").
end. /* do on error */
end procedure. /* footer */
/*==========================================================================*/
procedure incom :
/*Приход внешний*/
define input parameter p-type as character no-undo.
do
on error undo, return error
:

   assign
   itog-v-ind            = 0
   itog-vat-acc          = 0
   itog-sum-dsc-cli-acc  = 0
   itog-sum-cli-novat    = 0
   itog-vat-acc-eighteen = 0
   itog-vat-acc-ten      = 0
   itog-sum-pr-list      = 0

   is-petrolium = false
   v-ind                 = 1
   v-clients             = "":U
   v-attr-doc-code       = "":U
   varcur-vat-pc         = 0
   varcur-cons-vat-pc    = 0
   varb-code             = 0

   varlastcur-base       = 0
   varlastcur-road-tax   = 0
   varlastcur-excise     = 0
   varcur-fact-qnty      = 0
   varcur-base           = 0
   varcur-road-tax       = 0
   varcur-excise         = 0
   vardoc-num            = "":U
   varprice-sale         = 0
   varroad-tax           = 0
   varexcise             = 0
   varcur-slt-pc         = 0
   .


   for each obj-list  no-lock:
     run D-factord in this-procedure no-error .
     if error-status :error
     then do:
      undo, return error.
     end.

     _trn-doc-petrl:
     for each buf_trn-doc     no-lock
      where    buf_trn-doc.obj-type      =  obj-list.obj-type
      and      buf_trn-doc.obj-code      =  obj-list.obj-code
      and      buf_trn-doc.status_       = {&fact}
      and      buf_trn-doc.fact-order    >  factorder1
      and      buf_trn-doc.fact-order   <=  factorder2
      and      buf_trn-doc.ext-doc-type =   p-type

   :
      assign
      vat-acc          = 0  /* Сумма НДС */
      vat-cli-acc      = 0
      sum-dsc-cli-acc  = 0  /*Сумма по поставщику с НДС* sum-dsc-base-acc sum-dsc-rubl-acc*/
      sum-cli-novat    = 0  /* Сумма по поставщику без НДС*/
      vat-acc-eighteen = 0
      vat-acc-ten      = 0
      sum-pr-list      = 0 /*Сумма в продажных ценах*/
      v-linenm         = 0
   .
   _goods-petrl:
   for each     buf_doc-line no-lock
   where    buf_doc-line.doc-code     = buf_trn-doc.doc-code
   :

    { str/is-petrl.i
    buf_doc-line.artic
    buf_doc-line.prod-type
    buf_doc-line.prod-code
    is-petrolium
    is-pieces
    no-error
    }
   if error-status :error
   then do:
    return error return-value .
   end.
    if is-petrolium = true
    then do:
    next _goods-petrl.
    end.
    assign
      v-linenm = v-linenm + 1.


    find first buf_clients no-lock
    where  buf_clients.obj-code = buf_trn-doc.cli-code
    and    buf_clients.obj-type = buf_trn-doc.cli-type
    no-error.
    if available buf_clients
    then do:
      assign v-clients = buf_clients.obj-name.
    end.
  /*------------------------------------------------------------------------------*/
    find first buf_goods no-lock where
               buf_goods.artic     = buf_doc-line.artic     and
               buf_goods.prod-type = buf_doc-line.prod-type and
               buf_goods.prod-code = buf_doc-line.prod-code .
    if varcur-vat-pc = ?
    then do:
      { gbl/pftxvalg.i
          buf_goods.gds-code
          {&vat-tax-code}
          buf_trn-doc.fact-date
          buf_trn-doc.host-code
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          varcur-vat-pc
      }
    end.
    if varcur-slt-pc = ?
    then do:
      { gbl/pftxvalg.i
          buf_goods.gds-code
          {&slt-tax-code}
          buf_trn-doc.fact-date
          buf_trn-doc.host-code
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          varcur-slt-pc
      }
    end.
    if varcur-vat-pc = ?
    then do:
      run WaitFram-Hide in this-procedure .
      {&SetCursorNo}
      undo, return error substitute( 'Нет текущего продажного НДС по товару &1 &2 &3'
                                   , buf_goods.artic
                                   , buf_goods.prod-type
                                   , buf_goods.prod-code
                                   ) .
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute( 'Нет текущего продажного НП по товару &1 &2 &3'
                             , buf_goods.artic
                             , buf_goods.prod-type
                             , buf_goods.prod-code
                             ) .
    end.
    find first buf_sysconf no-lock where
               buf_sysconf.host-code = buf_trn-doc.host-code .
    assign
      varcur-cons-vat-pc = buf_sysconf.cons-vat-pc
    .
    if varcur-cons-vat-pc = ?
    then do:
      return error substitute( 'Нет текущего продажного консигнационного НДС по фирме &1'
                             , buf_trn-doc.host-code
                             ) .
    end.
    assign
       varprice-sale       = 0.00
       varroad-tax         = 0.00
       varexcise           = 0.00
       varlastcur-base     = 0.00
       varlastcur-road-tax = 0.00
       varlastcur-excise   = 0.00
       varcur-base         = 0.00
       varcur-fact-qnty    = 0.00
    .


    for each buf_gds-dtl no-lock where
             buf_gds-dtl.doc-code  = buf_doc-line.doc-code  and
             buf_gds-dtl.artic     = buf_doc-line.artic     and
             buf_gds-dtl.prod-type = buf_doc-line.prod-type and
             buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error return-value
    :

      { gbl/gdsbcode.i
          buf_goods.gds-code
          buf_gds-dtl.prt-code
          varb-code
          no-error
      }
      { gbl/bcodeprc.i
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          varb-code
          0
          buf_trn-doc.fact-order
          vardoc-num
          varprice-sale
          varroad-tax
          varexcise
      }
      if varprice-sale = ?
      then do:
        assign
          varprice-sale = 0.00
          varroad-tax   = 0.00
          varexcise     = 0.00
        .
      end.
      assign
        varlastcur-base     = varprice-sale
        varlastcur-road-tax = varroad-tax
        varlastcur-excise   = varexcise
        varcur-base         = varcur-base      + buf_gds-dtl.cur-base * buf_gds-dtl.fact-qnty
        varcur-fact-qnty    = varcur-fact-qnty + buf_gds-dtl.fact-qnty
      .
    end. /* for each buf_gds-dtl */
    if varcur-fact-qnty = 0.00
    then do:
      assign
        varcur-base      = varlastcur-base
        varcur-road-tax  = varlastcur-road-tax
        varcur-excise    = varlastcur-excise
      .
    end.
    else do:
      assign
        varcur-base      = varcur-base     / varcur-fact-qnty
        varcur-road-tax  = varcur-road-tax / varcur-fact-qnty
        varcur-excise    = varcur-excise   / varcur-fact-qnty
      .
    end.
    { gbl/gdsbcode.i
        buf_goods.gds-code
        ?
        varb-code
    }
    { gbl/bcprcex.i
        buf_trn-doc.obj-type
        buf_trn-doc.obj-code
        varb-code
        0
        buf_trn-doc.fact-order
        vardoc-num
        varprice-sale
        varroad-tax
        varexcise
        varcur-vat-pc
        varcur-slt-pc
    }
    if varprice-sale = ?
    then do:
      assign
        varcur-vat-pc = 0.00
        varcur-slt-pc = 0.00
      .
    end.

    /*------------------------------------------------------------------------------*/
    for each buf_parts no-lock
    where    buf_parts.artic     = buf_doc-line.artic
    and      buf_parts.prod-code = buf_doc-line.prod-code
    and      buf_parts.prod-type = buf_doc-line.prod-type
    and      buf_parts.out-code  = buf_doc-line.doc-code
    and      buf_parts.obj-code  = buf_doc-line.obj-code
    and      buf_parts.obj-type  = buf_doc-line.obj-type
    :
     create tt-clcparts.
     buffer-copy buf_parts to tt-clcparts.

     run clcprtsl_calc-parts (
           input recid( tt-clcparts )
         , input yes
         , input yes
         , input buf_doc-line.road-tax
         , input buf_doc-line.excise
         , input buf_doc-line.vat-pc
         , input buf_doc-line.cons-vat-pc
         , input buf_doc-line.slt-pc
         , input buf_trn-doc.base-rate
         , input buf_trn-doc.base-scale
         , input /*varr-b*/ buf_sys-ctrl.r-b
         , input varcur-base
         , input varcur-road-tax
         , input varcur-excise
         , input varcur-vat-pc
         , input varcur-cons-vat-pc
         , input varcur-slt-pc
     ) .

     find first tt-allsum
     where tt-allsum.sum-type = {&sum-general}
     .
     if v-print-rubl = true
      then do:
         assign
            vat-acc          = vat-acc         + tt-allsum.vat-rubl-acc
            vat-cli-acc      = vat-cli-acc     + tt-allsum.vat-cli-acc
            sum-pr-list      = sum-pr-list     + tt-allsum.sum-dsc-rubl-cur
            sum-dsc-cli-acc  = sum-dsc-cli-acc + tt-allsum.sum-dsc-rubl-acc
            sum-cli-novat    = sum-cli-novat   + (tt-allsum.sum-dsc-rubl-acc - tt-allsum.vat-rubl-acc)
      .

         .
         if buf_parts.vat-pc = 10
         then do:
            assign
               vat-acc-ten      = vat-acc-ten + tt-allsum.vat-rubl-acc
            .
         end.
         if buf_parts.vat-pc = 20 or buf_parts.vat-pc = 18
         then do:
             assign
               vat-acc-eighteen      = vat-acc-eighteen + tt-allsum.vat-rubl-acc
             .
         end.
      end.
      else do:
         assign
            vat-acc      = vat-acc      + tt-allsum.vat-base-acc
            vat-cli-acc  = vat-cli-acc  + tt-allsum.vat-cli-acc
            sum-pr-list  = sum-pr-list  + tt-allsum.sum-dsc-base-cur
            sum-dsc-cli-acc  = sum-dsc-cli-acc + tt-allsum.sum-dsc-base-acc
            sum-cli-novat    = sum-cli-novat   + (tt-allsum.sum-dsc-base-acc - tt-allsum.vat-base-acc)

         .
         if buf_parts.vat-pc = 10
         then do:
            assign
               vat-acc-ten  = vat-acc-ten + tt-allsum.vat-base-acc
            .
         end.
         if buf_parts.vat-pc = 20 or buf_parts.vat-pc = 18
         then do:
             assign
               vat-acc-eighteen  = vat-acc-eighteen + tt-allsum.vat-base-acc
             .
         end.

      end.
    end. /* for each buf_parts*/
    end. /* for each buf_doc-line*/

    if v-linenm = 0 then next _trn-doc-petrl.
   /*Итого*/
   assign
         itog-sum-dsc-cli-acc  = itog-sum-dsc-cli-acc  + sum-dsc-cli-acc
         itog-sum-cli-novat    = itog-sum-cli-novat    + sum-cli-novat
         itog-sum-pr-list      = itog-sum-pr-list      + sum-pr-list
         itog-vat-acc          = itog-vat-acc          + vat-acc
         itog-vat-acc-eighteen = itog-vat-acc-eighteen + vat-acc-eighteen
         itog-vat-acc-ten      = itog-vat-acc-ten      + vat-acc-ten
   .
   if p-type = {&TDEDT_Pri_Vnesh}
   then do:
      run gbl/trdcat-v.p (
         input buf_trn-doc.doc-code
      , input {&trdcattr-nids}
      , output v-attr-doc-code
      , output v-attr-type
      ).
      display stream out-stream
      sym1  v-ind sym2 v-clients sym3 buf_trn-doc.fact-date sym4 v-attr-doc-code sym5 buf_trn-doc.doc-code  sym6
      sum-cli-novat  sym7 vat-acc-ten sym8 vat-acc-eighteen  sym9  vat-acc sym10  sum-dsc-cli-acc  sym11
      sum-pr-list  sym12 with frame Pri_Vnesh .
      DOWN STREAM out-stream 1 WITH FRAME Pri_Vnesh.

      run reestdxl-sheet1-write-line-data ( input   v-ind
                                          , input   v-clients
                                          , input   string(buf_trn-doc.fact-date, "99.99.9999")
                                          , input   v-attr-doc-code
                                          , input   buf_trn-doc.doc-code
                                          , input   string(sum-cli-novat, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(vat-acc-ten, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(vat-acc-eighteen, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(vat-acc, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(sum-dsc-cli-acc, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(sum-pr-list, "->>>>>>>>>>>>>>>9.99")
                                          ) .

   end.
   if p-type = {&TDEDT_Ras_Vnesh_VP}
   then do:
      display stream out-stream
      sym1  v-ind sym2 v-clients sym3 buf_trn-doc.fact-date sym4 buf_trn-doc.doc-code sym5 buf_trn-doc.fact-qnty sym6
      sum-cli-novat  sym7 vat-acc-ten sym8 vat-acc-eighteen  sym9  vat-acc sym10  sum-dsc-cli-acc  sym11
      sum-pr-list  sym12 with frame Ras_Vnesh_VP .
      DOWN STREAM out-stream 1 WITH FRAME Ras_Vnesh_VP.

      run reestdxl-sheet2-write-line-data ( input   v-ind
                                          , input   v-clients
                                          , input   string(buf_trn-doc.fact-date, "99.99.9999")
                                          , input   buf_trn-doc.doc-code
                                          , input   buf_trn-doc.fact-qnty
                                          , input   string(sum-cli-novat, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(vat-acc-ten, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(vat-acc-eighteen, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(vat-acc, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(sum-dsc-cli-acc, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(sum-pr-list, "->>>>>>>>>>>>>>>9.99")
                                          ) .


   end.
   if p-type = {&TDEDT_Pri_Perem}
   then do:
       display stream out-stream
       sym1  sym2  sym3  sym5 sym6 sym7 sym12 sym13
       v-ind
       v-clients
       buf_trn-doc.fact-date
       buf_trn-doc.doc-code
       buf_trn-doc.fact-qnty
       sum-dsc-cli-acc
       sum-cli-novat
       sum-pr-list with frame Pri_Perem .
       DOWN STREAM out-stream 1 WITH FRAME Pri_Perem.

      run reestdxl-sheet4-write-line-data ( input   v-ind
                                          , input   v-clients
                                          , input   string(buf_trn-doc.fact-date, "99.99.9999")
                                          , input   buf_trn-doc.doc-code
                                          , input   buf_trn-doc.fact-qnty
                                          , input   string(sum-dsc-cli-acc, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(sum-cli-novat, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(sum-pr-list, "->>>>>>>>>>>>>>>9.99")
                                          ) .


   end.
   if p-type = {&TDEDT_Ras_Perem}
   then do:
       display stream out-stream
       sym1  sym2  sym3  sym5 sym6 sym7 sym12 sym13
       v-ind
       v-clients
       buf_trn-doc.fact-date
       buf_trn-doc.doc-code
       buf_trn-doc.fact-qnty
       sum-dsc-cli-acc
       sum-cli-novat
       sum-pr-list with frame Ras_Perem.
       DOWN STREAM out-stream 1 WITH FRAME Ras_Perem.

      run reestdxl-sheet5-write-line-data ( input   v-ind
                                          , input   v-clients
                                          , input   string(buf_trn-doc.fact-date, "99.99.9999")
                                          , input   buf_trn-doc.doc-code
                                          , input   buf_trn-doc.fact-qnty
                                          , input   string(sum-dsc-cli-acc, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(sum-cli-novat, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(sum-pr-list, "->>>>>>>>>>>>>>>9.99")
                                          ) .



   end.
   if p-type = {&TDEDT_Spi_Vnesh}
   then do:
       display stream out-stream
       sym1 sym3 sym5 sym6 sym7 sym12 sym13
       v-ind buf_trn-doc.fact-date buf_trn-doc.doc-code
       buf_trn-doc.fact-qnty sum-dsc-cli-acc sum-pr-list
       with frame Spi_Vnesh .
       DOWN STREAM out-stream 1 WITH FRAME Spi_Vnesh.

      run reestdxl-sheet6-write-line-data ( input   v-ind
                                          , input   string(buf_trn-doc.fact-date, "99.99.9999")
                                          , input   buf_trn-doc.doc-code
                                          , input   buf_trn-doc.fact-qnty
                                          , input   string(sum-dsc-cli-acc, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(sum-pr-list, "->>>>>>>>>>>>>>>9.99")
                                          ) .
   end.
   assign v-ind = v-ind + 1.
   end. /*each buf_trn-doc*/
   end. /*for each obj-list*/

    if p-type = {&TDEDT_Pri_Vnesh}
   then do:
      display stream out-stream
      sym6 sym7 sym8 sym9  sym10 sym11 sym12
      itog-sum-cli-novat @ sum-cli-novat
      itog-vat-acc-ten @ vat-acc-ten
      itog-vat-acc-eighteen @ vat-acc-eighteen
      itog-vat-acc @ vat-acc
      itog-sum-dsc-cli-acc @ sum-dsc-cli-acc
      itog-sum-pr-list @ sum-pr-list
      "Итого" @ buf_trn-doc.doc-code with frame Pri_Vnesh .
      DOWN STREAM out-stream 1 WITH FRAME Pri_Vnesh.
      run reestdxl-sheet1-write-line-data ( input   "":U
                                          , input   "":U
                                          , input   "":U
                                          , input   "":U
                                          , input   "Итого"
                                          , input   string(itog-sum-cli-novat, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(itog-vat-acc-ten, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(itog-vat-acc-eighteen, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(itog-vat-acc, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(itog-sum-dsc-cli-acc, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(itog-sum-pr-list, "->>>>>>>>>>>>>>>9.99")
                                          ) .


   end.
   if p-type = {&TDEDT_Ras_Vnesh_VP}
   then do:
      display stream out-stream
      sym6 sym7 sym8 sym9  sym10 sym11 sym12
      itog-sum-cli-novat @ sum-cli-novat
      itog-vat-acc-ten @ vat-acc-ten
      itog-vat-acc-eighteen @ vat-acc-eighteen
      itog-vat-acc @ vat-acc
      itog-sum-dsc-cli-acc @ sum-dsc-cli-acc
      itog-sum-pr-list @ sum-pr-list
      "Итого" @ buf_trn-doc.fact-qnty with frame Ras_Vnesh_VP .
      DOWN STREAM out-stream 1 WITH FRAME Ras_Vnesh_VP.
      run reestdxl-sheet2-write-line-data ( input   "":U
                                          , input   "":U
                                          , input   "":U
                                          , input   "":U
                                          , input   "Итого"
                                          , input   string(itog-sum-cli-novat, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(itog-vat-acc-ten, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(itog-vat-acc-eighteen, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(itog-vat-acc, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(itog-sum-dsc-cli-acc, "->>>>>>>>>>>>>>>9.99")
                                          , input   string(itog-sum-pr-list, "->>>>>>>>>>>>>>>9.99")
                                          ) .

   end.
   if p-type = {&TDEDT_Pri_Perem}
   then do:
       display stream out-stream
       sym7 sym12 sym13
       "Итого" @ buf_trn-doc.fact-qnty
       itog-sum-dsc-cli-acc @ sum-dsc-cli-acc
       itog-sum-cli-novat @ sum-cli-novat
       itog-sum-pr-list @ sum-pr-list  with frame Pri_Perem .
       DOWN STREAM out-stream 1 WITH FRAME Pri_Perem.
       run reestdxl-sheet4-write-line-data ( input   "":U
                                           , input   "":U
                                           , input   "":U
                                           , input   "":U
                                           , input   "Итого"
                                           , input   string(itog-sum-dsc-cli-acc , "->>>>>>>>>>>>>>>9.99")
                                           , input   string(itog-sum-cli-novat , "->>>>>>>>>>>>>>>9.99")
                                           , input   string(itog-sum-pr-list, "->>>>>>>>>>>>>>>9.99")
                                           ) .

   end.
   if p-type = {&TDEDT_Ras_Perem}
   then do:
       display stream out-stream
       sym7 sym12 sym13
       "Итого" @ buf_trn-doc.fact-qnty
       itog-sum-dsc-cli-acc @ sum-dsc-cli-acc
       itog-sum-cli-novat @ sum-cli-novat
       itog-sum-pr-list @ sum-pr-list  with frame Ras_Perem .
       DOWN STREAM out-stream 1 WITH FRAME Ras_Perem.
      run reestdxl-sheet5-write-line-data ( input   "":U
                                          , input   "":U
                                          , input   "":U
                                          , input   "":U
                                          , input   "Итого"
                                          , input   string(itog-sum-dsc-cli-acc , "->>>>>>>>>>>>>>>9.99")
                                          , input   string(itog-sum-cli-novat , "->>>>>>>>>>>>>>>9.99")
                                          , input   string(itog-sum-pr-list, "->>>>>>>>>>>>>>>9.99")
                                          ) .

   end.
   if p-type = {&TDEDT_Spi_Vnesh}
   then do:
       display stream out-stream
       sym7 sym12 sym13
      "Итого" @ buf_trn-doc.fact-qnty
       itog-sum-dsc-cli-acc @ sum-dsc-cli-acc
       itog-sum-pr-list @  sum-pr-list
       with frame Spi_Vnesh .
       DOWN STREAM out-stream 1 WITH FRAME Spi_Vnesh.
      run reestdxl-sheet6-write-line-data ( input    "":U
                                          , input    "":U
                                          , input    "":U
                                          , input    "Итого"
                                          , input    string(itog-sum-dsc-cli-acc , "->>>>>>>>>>>>>>>9.99")
                                          , input    string(itog-sum-pr-list, "->>>>>>>>>>>>>>>9.99")
                                          ) .

   end.

end. /* do on error */
end procedure. /* incom */
 /* Цена Прошлой переоценки СТАРАЯ */
   function fnc-old-price return decimal (buffer local-price-list for price-list).
   define variable cur-pr like price-list.price-sale no-undo.
   define variable cur-rt like price-list.road-tax   no-undo.
   define variable cur-ex like price-list.excise     no-undo.
   define variable cur-dn like price-list.doc-num    no-undo.
   { gbl/bcodeprc.i
      local-price-list.obj-type
      local-price-list.obj-code
      local-price-list.b-code
      0
      local-price-list.fact-order
      cur-dn
      cur-pr
      cur-rt
      cur-ex
      no-error }
   old-price = cur-pr.
   return (old-price).
   end function.

/*==========================================================================*/
procedure price :

define buffer buf_price-list     for price-list .
do
on error undo, return error
:
/*put stream out-stream
"3. Переоценка".*/
   assign
   itog-v-sum-pl = 0
   is-petrolium  = false
   v-ind         = 0
   .

   for each obj-list  no-lock :
     run D-factord in this-procedure no-error .
     if error-status :error
     then do:
      undo, return error.
     end.
   _trn-doc-petrl2:
   for each buf_price-doc       no-lock
      where buf_price-doc.obj-type    =  obj-list.obj-type
      and   buf_price-doc.obj-code    =  obj-list.obj-code
      and   buf_price-doc.status_     = {&act-overvalue}
      and   buf_price-doc.fact-order >   factorder1
      and   buf_price-doc.fact-order <=  factorder2
   :

   assign
     v-qnty   = 0
     v-sum-pl = 0
     v-linenm = 0.
   .
  _goods-petrl2:
   for each     buf_price-list no-lock
   where    buf_price-list.doc-num     = buf_price-doc.doc-num
   and      buf_price-list.main-price  = true
   :
    { str/is-petrl.i
    buf_price-list.artic
    buf_price-list.prod-type
    buf_price-list.prod-code
    is-petrolium
    is-pieces
    no-error
    }
   if error-status :error
   then do:
    return error return-value .
   end.
    if is-petrolium = true
    then do:
    next _goods-petrl2.
    end.
    assign
      v-linenm = v-linenm + 1.
    v-old = fnc-old-price(buffer buf_price-list).
    if v-old = ?
    then do:
      v-old = 0.
    end.
     assign
      v-qnty   = v-qnty + buf_price-list.doc-qnty
      v-sum-pl = v-sum-pl + (buf_price-list.doc-qnty) * (buf_price-list.price-sale - v-old)
    .
    end. /* buf_price-list*/
    if v-linenm = 0 then next _trn-doc-petrl2.
    assign
      itog-v-sum-pl = itog-v-sum-pl + v-sum-pl
      v-ind         =  v-ind + 1
    .

   display stream out-stream
      sym1 sym3 sym5 sym6 sym7 sym12
      v-ind
      buf_price-doc.fact-date
      buf_price-doc.doc-num
      v-qnty
      v-sum-pl
   with frame bef-h-ov .
   DOWN STREAM out-stream 1 WITH FRAME bef-h-ov.
  run reestdxl-sheet3-write-line-data ( input   v-ind
                                      , input   string(buf_price-doc.fact-date, "99.99.9999")
                                      , input   buf_price-doc.doc-num
                                      , input   string(v-qnty, "->>>>>>>>>>>>>>>9.<<<")
                                      , input   string(v-sum-pl, "->>>>>>>>>>>>>>>9.99")
                                      ) .


    end. /* buf_price-doc*/
   end. /*obj-list*/
   display stream out-stream
   sym7 sym12
      "Итого" @ v-qnty
      itog-v-sum-pl @ v-sum-pl
   with frame bef-h-ov .
   DOWN STREAM out-stream 1 WITH FRAME bef-h-ov.
  run reestdxl-sheet3-write-line-data ( input   "":U
                                      , input   "":U
                                      , input   "":U
                                      , input   "Итого"
                                      , input   string(itog-v-sum-pl, "->>>>>>>>>>>>>>>9.99")
                                      ) .


end. /* do on error */
end procedure. /* price */
/*==========================================================================*/
procedure D-factord :

do
on error undo, return error
:
      define buffer bff_shift-obj for ub.shift-obj.
      define buffer bff_trn-doc   for ub.trn-doc.

  /* сменный или нет*/
  { gbl/objat.i
        obj-list.obj-type
        obj-list.obj-code
        "'shift-on=request'"
        v-shift-obj-on
        no-error
  }
  if v-shift-obj-on = false
  or (     X-Shift-Start = 0
       and X-Shift-End   = 0)
   then do:
   /*начало*/
   run day-begin-fact-order in this-procedure (
   input x-Date-Start ,
   output factorder1 ).
   /*конец*/
   run factord-end-day in this-procedure (
   input x-Date-End,
   output factorder2).
   assign
      v-flag = true
   .
   end.
   /*смены*/
   else do:
         run factord in this-procedure
         (input  x-Date-Start             /* p-fact-date            */
         ,input  0                        /* p-fact-time            */
         ,input  1                        /* p-fact-num             */
         ,input  x-Date-Start             /* p-shift-date           */
         ,input  X-Shift-Start            /* p-shift-num            */
         ,input  yes                      /* p-shift-on             */
         ,output factorder1               /* p-fact-order           */
         ,output p-shift-end-fact-order   /* p-shift-end-fact-order */
         ,output p-day-end-fact-order     /* p-day-end-fact-order   */
         )
         no-error.
      find first bff_shift-obj where bff_shift-obj.obj-type = obj-list.obj-type and
                                     bff_shift-obj.obj-code = obj-list.obj-code and
                                     bff_shift-obj.shift-date = x-Date-End and
                                     bff_shift-obj.shift-num = X-Shift-End no-lock no-error .

      if not available bff_shift-obj
      then do:
        message
          substitute( "Не найдена смена по объекту &1 &2 дата &3 порядок &4&5Отчет не может быть сформирован.":U
                    , obj-list.obj-type
                    , obj-list.obj-code
                    , x-Date-End
                    , X-Shift-End
                    , {&new-line}
                    )
        view-as alert-box error.
        undo, return error.
      end.
      find first bff_trn-doc where bff_trn-doc.obj-type   = bff_shift-obj.obj-type    and
                                   bff_trn-doc.obj-code   = bff_shift-obj.obj-code    and
                                   bff_trn-doc.shift-date = bff_shift-obj.shift-date  and
                                   bff_trn-doc.shift-num  <= bff_shift-obj.shift-num  and
                                   bff_trn-doc.status_     = {&fact}                  or
                                   bff_trn-doc.obj-type   = bff_shift-obj.obj-type    and
                                   bff_trn-doc.obj-code   = bff_shift-obj.obj-code    and
                                   bff_trn-doc.shift-date < bff_shift-obj.shift-date
                                   use-index shift no-lock no-error.
      if available bff_trn-doc then do:
        assign
          factorder2 = bff_trn-doc.fact-order.
     end.
   end.

end. /* do on error */
end procedure. /* factord */

end. /*DO*/