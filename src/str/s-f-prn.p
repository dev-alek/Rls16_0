block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: s-f-prn.p $
$Archive: str/s-f-prn.p $

Печать счета-фактуры поставщика

Автор: Кочетков Михаил Юрьевич
Дата создания: 10/19/05
Author: Michael Kochetkov
Creation date: 10/19/05

*/
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id           as recid                no-undo.
define input parameter p-mode           as character            no-undo.

&scoped-define gds-len 59
&scoped-define footer-tab-stop1 40

do
on error undo, return error
:

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: s-f-prn.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/s-f-prn.p $":U .
define variable vss-description as character no-undo init "Печать счета-фактуры".
{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ cmp/r-pril.i  NEW     }
{ cmp/breakstr.i     }
/*{ rep/fmtcli.i       }*/
{ gbl/clntattr.i     }
{ str/trdcalib.i     }
/*{ rep/torgconf.i     }*/
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
{ gbl/paramls.i      }
{ rep/facturxl.i     }
{ gbl/getsect.i def  }
{ str/getctxtp.i def }
{ str/getctxtp.i get p-mainmenu-handle }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get " " p-mainmenu-handle }

run get-report-num in p-mainmenu-handle ( output g#report-num ).
run get-quest-print in p-mainmenu-handle ( output g#quest-print ).

define variable v-torgconf-doc-code             as character    no-undo.
define variable v-torgconf-doc-date             as character    no-undo.

define stream Out-stream .

    output to value( string( session:temp-directory + "$" + string( g#report-num ) ) + ".txl" ) .
    output close.
    output to value( string( session:temp-directory + {&DF_Name} + string( g#report-num ) ) + ".txl" ) .
    output close.


define variable str                     as character            no-undo.
define variable gds-str                 as character            no-undo.
define variable gds-str1                as character            no-undo.
define variable gds-str2                as character            no-undo.

define variable v-lines-counter         as integer              no-undo.

define variable v-tot-sum               as decimal              no-undo.
define variable v-tot-VAT               as decimal              no-undo.
define variable v-tot-sum-no-VAT        as decimal              no-undo.

define variable sym1 as char init ":" no-undo.
define variable sym2 as char init ":" no-undo.
define variable sym3 as char init ":" no-undo.
define variable sym4 as char init ":" no-undo.
define variable sym5 as char init ":" no-undo.
define variable sym6 as char init ":" no-undo.
define variable sym7 as char init ":" no-undo.
define variable sym8 as char init ":" no-undo.
define variable sym9 as char init ":" no-undo.
define variable sym10 as char init ":" no-undo.
define variable sym11 as char init ":" no-undo.
define variable sym12 as char init ":" no-undo.
define variable sym13 as char init ":" no-undo.

define variable v-single-line    as character            no-undo.
define variable v-propis         as character            no-undo.
define variable v-propis-cop     as character            no-undo.

define buffer buf_schet-fact-doc        for schet-fact-doc .
define buffer buf_schet-fact-line       for schet-fact-line .

      define frame factur
        sym1 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.gds-name    column-label "Наименование товара! ":C59 format "X(59)" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.unit-base   column-label "Ед.!изм." format "X(4)" space(0)
        sym3 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.fact-qnty   column-label "Количество ! " format ">>>>>>9.<<<" space(0)
        sym4 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.price-rubl  column-label "Цена!за ед.изм.":C12 format "->>>>>>>9.99" space(0)
        sym5 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.sum-rubl column-label "Стоимость товаров!всего без налога":C17 format "->>>>>>>>>>>>9.99" space(0)
        sym6 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.excise column-label "в т.ч.!акциз":C9 format ">>>>>9.99" space(0)
        sym7 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.Vat-pc column-label "Ставка!налога":C6 format ">9.9<%" space(0)
        sym8 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.VAT-rubl column-label "Сумма!налога":C12 format "->>>>>>>9.99" space(0)
        sym9 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.sum-rubl-VAT column-label "Ст-ть товаров!с учетом налога":c15 format "->>>>>>>>>>9.99" space(0)
        sym11 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.country column-label "Страна!происхождения":C15 format "X(15)" space(0)
        sym12 column-label ":!:" format "X(1)" space(0)
        buf_schet-fact-line.gtd column-label "Номер грузовой таможенной!декларации":C26 format "X(26)" space(0)
        sym13 column-label ":!:" format "X(1)" space(0)
     header
        ( if PAGE-NUMBER( Out-stream ) > 1
          then string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date )
          else "":U )                                                       at 40 format "X(50)"
        string( "Страница " + string( PAGE-NUMBER( Out-stream ), ">>9" ) )  at 180 format "X(13)" skip
        v-single-line format "X(198)" at 1
     with width {&DOS_CW} down stream-io.

   { gbl/working.i }

  find first buf_schet-fact-doc no-lock where recid( buf_schet-fact-doc ) = rec_id .
  assign
    v-torgconf-doc-code = buf_schet-fact-doc.doc-code
    v-torgconf-doc-date = string(buf_schet-fact-doc.doc-date,"99/99/9999")
  .

  assign
    v-single-line   = fill("-", 198)
    v-lines-counter = 1
  .

  { cmp/open-out.i stream Out-stream " " {&LS_PS_A4} }

  run facturxl-init in this-procedure .

  run print-header in this-procedure .

  form header
    v-single-line format "X(198)" at 1 skip  "Продолжение - на следующей странице" at 30 skip
    with frame Bottomframe width {&DOS_CW} page-bottom no-labels no-box .
  view stream Out-stream frame Bottomframe .

  form with frame factur .

  /*---S---------------- По строке документа -----------------------*/
  for each buf_schet-fact-line no-lock  where buf_schet-fact-line.doc-code = buf_schet-fact-doc.doc-code
  break by buf_schet-fact-line.line-num
  :
    run print-line in this-procedure .
  end.        /*for  each doc-line ...*/
  /*---E---------------- По строке документа -----------------------*/

  put stream Out-stream  v-single-line format "X(198)"  /* skip */ .

  if line-counter( Out-stream ) + 7 > page-size( Out-stream ) then  page stream Out-stream.

  run facturxl-write-cell-data in this-procedure ( input {&facturxl-it_SumNoVAT} , input string( v-tot-sum-no-VAT ) ).
  run facturxl-write-cell-data in this-procedure ( input {&facturxl-it_VATsum}   , input string( v-tot-VAT ) ).
  run facturxl-write-cell-data in this-procedure ( input {&facturxl-it_sum}      , input string( v-tot-sum ) ).

  run rep/wp-rub.p ( input v-tot-sum , output v-propis, output v-propis-cop ).
/*  display stream Out-stream*/
/*    sym1  "Всего к оплате"    @ buf_schet-fact-line.gds-name*/
/*/*    sym2   v-tot-sum-no-VAT  @ buf_schet-fact-line.sum-rubl*/*/
/*    sym8   v-tot-VAT         @ buf_schet-fact-line.VAT-rubl*/
/*    sym9   v-tot-sum         @ buf_schet-fact-line.sum-rubl-VAT*/
/*    sym11 sym12 sym13*/
/*  with frame factur .*/
  down stream Out-stream with frame factur .
  put stream Out-stream  skip  ": Всего к оплате  " v-propis format "X(107)"
    ":"   v-tot-VAT format ">>>>>>>>9.99"
    ":"   v-tot-sum format ">>>>>>>>>>>9.99"
    ":               :                          :"
  .
  put stream Out-stream v-single-line format "X(198)" at 1 .

/*  if v-torgconf-outsubs = no then do:*/
/*    run facturxl-write-cell-data in this-procedure ( input {&facturxl-f_bossName}, input v-torgconf-main-boss ).*/
/*    run facturxl-write-cell-data in this-procedure ( input {&facturxl-f_buhName} , input v-torgconf-main-buh  ).*/
/*    put stream Out-stream*/
/*        skip space(5) "Руководитель предприятия" format "X(30)" "/ " v-torgconf-main-boss format "X(36)" " /"*/
/*        "    Гл. бухгалтер" format "X(30)" "/ " v-torgconf-main-buh format "X(36)" " /"*/
/*    .*/
/*  end.        /* v-torgconf-outsubs = no */*/
/*  else do:*/
    put stream Out-stream
        skip
        space(5) "Руководитель предприятия" format "X(50)" "/ " fill( "_", 36 ) format "X(36)" " /"
        "     Гл. бухгалтер" format "X(50)" "/ " fill( "_", 36 ) format "X(36)" " /"
    .
/*  end.        /* NOT ( v-torgconf-outsubs = no ) */*/
  put stream Out-stream
        skip  space(10) "М.П." format "X(5)"
        skip  space(5) "Выдал" format "X(50)" skip
  .

  run facturxl-close in this-procedure .

  hide stream Out-stream frame Bottomframe .
  output stream Out-stream close.

  { gbl/stopwork.i }

  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" ) .
  os-rename
      value(  string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
      value(  string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .
  run gbl/prnfilen.w
    (input  ""
    ,input  8
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input  7
    ,output v-user-action
    ,output v-printed
    ) .
  os-delete value( string( session:temp-directory ) +  "$" + string( g#report-num ) + ".txl" ) .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" ) .

end.

/*===============================================================================================*/
procedure print-more:
  do on error undo, return error :
    def var v-start-string as character no-undo.
    def var v-add-string as character no-undo.
    assign v-start-string = gds-str2 .

    do while trim(v-start-string) <> "" :
      assign gds-str = v-start-string.
      v-add-string = breakstr(gds-str, {&gds-len}, input-output v-add-string, input-output v-start-string).
      display stream Out-stream
        sym1 fill(" ",17) + v-add-string @ buf_schet-fact-line.gds-name sym2 sym3 sym4 sym5 sym6 sym7 sym8  sym9 /*sym10*/ sym11 sym12 sym13
      with frame factur .
      down stream Out-stream 1 with frame factur .
    end. /* DO WHILE ... */
  end.
end procedure.

/*==========================================================================*/
procedure print-line :
  do on error undo, return error :
/*    assign*/
/*      gds-str  = ''*/
/*      gds-str1 = ''*/
/*      gds-str2 = ''*/
/*    .*/

    display stream Out-stream
      sym1  buf_schet-fact-line.gds-name
      sym2  buf_schet-fact-line.unit-base
      sym3  buf_schet-fact-line.fact-qnty
      sym4  buf_schet-fact-line.price-rubl
      sym5  buf_schet-fact-line.sum-rubl
      sym6  buf_schet-fact-line.excise
      sym7  buf_schet-fact-line.Vat-pc
      sym8  buf_schet-fact-line.VAT-rubl
      sym9  buf_schet-fact-line.sum-rubl-VAT
      sym11 buf_schet-fact-line.country
      sym12 buf_schet-fact-line.GTD
      sym13
    with frame factur .
    down stream Out-stream 1 with frame factur .
    run facturxl-write-line-data in this-procedure (
        input buf_schet-fact-line.gds-name      /*  p-Name     */
      , input buf_schet-fact-line.unit-base     /*  p-EI       */
      , input buf_schet-fact-line.fact-qnty     /*  p-qnty     */
      , input buf_schet-fact-line.price-rubl    /*  p-price    */
      , input buf_schet-fact-line.sum-rubl      /*  p-SumNoVAT */
      , input buf_schet-fact-line.excise        /*  p-SumActciz*/
      , input buf_schet-fact-line.Vat-pc        /*  p-VATpc    */
      , input buf_schet-fact-line.VAT-rubl      /*  p-VATsum   */
      , input buf_schet-fact-line.sum-rubl-VAT  /*  p-sum      */
      , input buf_schet-fact-line.country                                               /*  p-country  */
      , input buf_schet-fact-line.GTD                                                   /*  p-GTD      */
    ).
    assign
      v-tot-sum-no-VAT  = v-tot-sum-no-VAT + buf_schet-fact-line.sum-rubl
      v-tot-VAT         = v-tot-VAT        + buf_schet-fact-line.VAT-rubl
      v-tot-sum         = v-tot-sum        + buf_schet-fact-line.sum-rubl-VAT
      v-lines-counter   = v-lines-counter + 1
    .

  end.
end procedure. /* print-line */


/*==========================================================================*/
procedure print-header :
  define variable v-print-doc      as character           no-undo.
  define variable v-par-type       as character           no-undo.
  define variable t-num            as character           no-undo.
  define variable v-plat-rasch-doc as character    no-undo.
  define variable v-rubl-name      as character    no-undo.

define buffer buf_currency for ub.currency.
assign v-plat-rasch-doc    = "":U  .

 do on error undo, return error :

    { gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-prt-firm} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'factur01' then v-print-doc =  string(thbjattr_thbj-attr.property-value-logical) .
    end.

    if v-print-doc <> 'yes'  then assign v-print-doc = "no"  .

    assign  t-num = substitute( "&1         от &2 &3" , v-torgconf-doc-code , v-torgconf-doc-date
           , ( if buf_schet-fact-doc.status_ <> {&fact} then string( "(" + caps( buf_schet-fact-doc.status_ ) + ")" ) else "":U ) )
    .
    assign v-plat-rasch-doc = buf_schet-fact-doc.in-doc-code + " от " + string(buf_schet-fact-doc.in-doc-date, "99/99/9999") .
find first buf_currency no-lock
         where buf_currency.curr-code = 0
    .
    assign
        v-rubl-name = buf_currency.curr-name
    .    

put stream Out-stream
                space(25) string( "СЧЕТ-ФАКТУРА N " +  t-num ) format "X(190)"
        skip(1) space(5) string( "Продавец " + fill( " ", 31 ) + buf_schet-fact-doc.cli-name ) format "X(190)"
        skip    space(5) string( "Адрес "    + fill( " ", 34 ) + buf_schet-fact-doc.cli-address ) format "X(190)"
        skip    space(5) string( "Идентификационный номер продавца ({&abbr_inn_allshift}/{&abbr_kpp_allshift}) " + buf_schet-fact-doc.cli-inn + "/" + buf_schet-fact-doc.cli-kpp ) format "X(190)"
        skip    space(5) string( "Грузоотправитель и его адрес " + fill( " ", 10 ) + buf_schet-fact-doc.Gruz-otprav ) format "X(190)"
        skip    space(5) string( "Грузополучатель и его адрес" + fill( " ", 12 ) + buf_schet-fact-doc.Gruz-poluch )   format "X(190)"
        skip    space(5) string( "К платежно-расчетному документу        " + v-plat-rasch-doc ) format "X(190)"
        skip(1) space(5) string( "Покупатель" + fill( " ", 29 ) + buf_schet-fact-doc.own-name ) format "X(190)"
        skip    space(5) string( "Адрес" + fill( " ", 34 ) + buf_schet-fact-doc.own-address ) format "X(190)"
        skip    space(5) string( "Идентификационный номер покупателя ({&abbr_inn_allshift}/{&abbr_kpp_allshift})" + buf_schet-fact-doc.own-inn + "/" + buf_schet-fact-doc.own-kpp ) format "X(190)"
        skip    space(5) string( "Валюта : " + v-rubl-name ) format "X(190)"
        skip
    .
    run facturxl-write-cell-data in this-procedure ( input {&facturxl-h_docCode} , input v-torgconf-doc-code ).
    run facturxl-write-cell-data in this-procedure ( input {&facturxl-h_docDate} , input v-torgconf-doc-date ).
    run facturxl-write-cell-data in this-procedure ( input {&facturxl-h_supplier} , input buf_schet-fact-doc.cli-name ).
    run facturxl-write-cell-data in this-procedure ( input {&facturxl-h_supplierAddr} , input buf_schet-fact-doc.cli-address ).
    run facturxl-write-cell-data in this-procedure ( input {&facturxl-h_supplierINN} , input buf_schet-fact-doc.cli-inn + "/" + buf_schet-fact-doc.cli-kpp ).
    run facturxl-write-cell-data in this-procedure ( input {&facturxl-h_cargoFrom} , input buf_schet-fact-doc.Gruz-otprav ).
    run facturxl-write-cell-data in this-procedure ( input {&facturxl-h_cargoTo} , input buf_schet-fact-doc.Gruz-poluch ).
    run facturxl-write-cell-data in this-procedure ( input {&facturxl-h_platDoc} , input v-plat-rasch-doc ).
    run facturxl-write-cell-data in this-procedure ( input {&facturxl-h_saler}   , input buf_schet-fact-doc.own-name ).
    run facturxl-write-cell-data in this-procedure ( input {&facturxl-h_salerAddr} , input buf_schet-fact-doc.own-address ).
    run facturxl-write-cell-data in this-procedure ( input {&facturxl-h_salerINN} , input buf_schet-fact-doc.own-inn + "/" + buf_schet-fact-doc.own-kpp ).
    run facturxl-write-cell-data in this-procedure ( input {&facturxl-h_currency} , input v-rubl-name ).
end.
end procedure. /* print-header */