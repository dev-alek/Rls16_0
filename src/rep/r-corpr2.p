block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-corpr2.p $
$Archive: rep/r-corpr2.p $

Печать счета-фактуры

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer   no-undo .
define input parameter v-doc-code as character no-undo .
define input parameter sort-name  as integer   no-undo .
define input parameter sort-gr    as logical   no-undo .
define input parameter is_rem     as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-corpr2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-corpr2.p $":U .
define variable vss-description as character no-undo init "Печать счета-фактуры".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ cmp/breakstr.i }
{ gbl/tax-name.i }
{ str/clcprtsl.i }
{ trg/factord.i  }
{ rep/r-sym.i    }
{ cmp/r-page1.i  }
{ rep/rep-bt.i   }
{ gbl/prn-lib.i  }
{ gbl/getsect.i def }

&scoped-define gds-len 59
&scoped-define footer-tab-stop1 40

do
on error undo, return error
:

  define variable v-tax-name          as char                             no-undo.
  define variable v-tax-sum           like doc-line.road-tax      init 0  no-undo.
  define variable v-tot-discnt            as decimal   no-undo .

  { rep/r-corpr.i }

  define variable PrevPage                as integer     init 0   no-undo.

define variable str                     as character            no-undo.
define variable gds-str                 as character            no-undo.
define variable gds-str1                as character            no-undo.
define variable gds-str2                as character            no-undo.

define variable v-lines-counter         as integer              no-undo.
define variable v-single-line           as character no-undo .

define variable v-tot-sum               as decimal              no-undo.
define variable v-tot-VAT               as decimal              no-undo.
define variable v-tot-SLT               as decimal              no-undo.
define variable v-tot-sum-no-VAT        as decimal              no-undo.
define variable v-tot-tax               as decimal   no-undo .


/*define variable v-doc-code       like trn-doc.doc-code   no-undo.*/
define variable v-doc-date       like trn-doc.doc-date   no-undo.

define variable t-addres         as character            no-undo.
define variable t-phone          as character            no-undo.
define variable t-inn            as character            no-undo.
define variable t-num            as character            no-undo.
define variable v-print-doc      as character            no-undo.
define variable v-par-type       as character            no-undo.
define variable v-no-print-discnt as character            no-undo.


define variable v-main-boss     as character            no-undo.
define variable v-main-buh      as character            no-undo.

define buffer buf_our_clients           for clients.
define buffer buf_clients               for clients.
define buffer buf_firm                  for firm.
define buffer buf_sysconf               for sysconf.

define frame factur
        sym1 column-label ":!:" format "X(1)" space(0)
        gds-prop.gds-name column-label "Наименование товара! ":C59 format "X(59)" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
        gds-prop.unit-base column-label "Ед.!изм." format "X(4)" space(0)
        sym3 column-label ":!:" format "X(1)" space(0)
        gds-prop.qnty column-label "Количество ! " format ">>>>>>9.<<<" space(0)
        sym4 column-label ":!:" format "X(1)" space(0)
        gds-prop.price-no-VAT column-label "Цена!за ед.изм.":C12 format "->>>>>>>9.99" space(0)
        sym5 column-label ":!:" format "X(1)" space(0)
        gds-prop.sum-no-VAT column-label "Стоимость товаров!всего без налога":C17 format "->>>>>>>>>>>>9.99" space(0)
        sym6 column-label ":!:" format "X(1)" space(0)
        gds-prop.sum-actciz column-label "в т.ч.!акциз":C9 format ">>>>>9.99" space(0)
        sym7 column-label ":!:" format "X(1)" space(0)
        gds-prop.Vat-pc column-label "Ставка!налога":C6 format ">9.9<%" space(0)
        sym8 column-label ":!:" format "X(1)" space(0)
        gds-prop.VAT column-label "Сумма!налога":C12 format "->>>>>>>9.99" space(0)
        sym9 column-label ":!:" format "X(1)" space(0)
        gds-prop.sum column-label "Ст-ть товаров!с учетом налога":c15 format "->>>>>>>>>>9.99" space(0)
        sym11 column-label ":!:" format "X(1)" space(0)
        gds-prop.country column-label "Страна!происхождения":C15 format "X(15)" space(0)
        sym12 column-label ":!:" format "X(1)" space(0)
        gds-prop.GTD column-label "Номер грузовой таможенной!декларации":C26 format "X(26)" space(0)
        sym13 column-label ":!:" format "X(1)" space(0)
header
        string( "Документ N: " + v-doc-code + " от " + string(v-doc-date, "99/99/9999") ) at 40 format "X(50)"
        string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) at 180 format "X(13)" skip
        v-single-line format "X(198)" at 1
with width {&DOS_CW} down stream-io.

assign
    v-single-line   = fill("-", 198)
    v-lines-counter = 1
.

{ gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-prt-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'factur01' then v-print-doc =  string(thbjattr_thbj-attr.property-value-logical) .
end.
if v-print-doc <> 'yes'  then assign v-print-doc = "no"  .



/* !!! НЕТ В ПАРАМЕТРАХ */
run gbl/conf-rd.p ("factur02", "", "", 0, "", "", "", no, output v-no-print-discnt, output v-par-type) no-error.
if error-status :error then  assign v-no-print-discnt = "no"  .

assign v-doc-date =   x-date-end .

{ gbl/working.i }

  run prn-lib-open-stream  in this-procedure (input my-handle,input {&LS_PS_A4},input yes,input no).

  form header
    v-single-line format "X(198)" at 1 skip "Продолжение - на следующей странице" at 30 skip
    with frame Bottomframe width {&DOS_CW} page-bottom no-labels no-box .
  view stream PrnLibStream frame Bottomframe .

  assign  t-num = v-doc-code + "         от " + string( v-doc-date, "99/99/9999") .

  find first clients no-lock where clients.obj-type = p-cli-type and clients.obj-code = p-cli-code .
  if clients.obj-type = {&cmp} then do:
    find first firm no-lock where firm.firm-code = clients.obj-code .
    assign
      t-addres = ( ( if firm.ind <> 0 then string( firm.ind ) else "" ) + " " + firm.city + " " + trim( firm.addres1 ) + " " + trim( firm.addres2 ) )
      t-phone = firm.phone
      t-inn = firm.inn
    .
  end.
  else do:
    find first person no-lock where person.psn-code = clients.obj-code no-error.
    if available person then do:
      assign
        t-addres = ( ( if person.ind <> 0 then string( person.ind ) else "" ) + " " + person.city + " " + trim( person.address ) )
        t-phone = person.phone1
        t-inn = ""
      .
    end.
    else assign t-addres    = ""   t-phone     = ""    t-inn       = "" .
  end.

  put stream PrnLibStream
    space(25) string( "СЧЕТ-ФАКТУРА  N  " + t-num ) format "X(100)" skip(1)
    space(5) string( "Продавец   " + clients.obj-name ) format "X(100)" skip
    space(5) string( "Адрес   " + t-addres ) format "X(90)" skip
    space(5) string( "Идентификационный номер продавца ({&abbr_inn_allshift})   " + t-inn ) format "X(100)" skip
    space(5) string( "Грузоотправитель и его адрес   " + trim( clients.obj-name ) ) format "X(100)" skip
  .

  find first clients no-lock where clients.obj-type = {&cmp} and clients.obj-code = v-cntxt-host-code-obj .
  find first firm no-lock    where firm.firm-code = v-cntxt-host-code-obj .
  assign
    t-addres = ( ( if firm.ind <> 0 then string( firm.ind ) else "" ) + " " + firm.city + " " + trim( firm.addres1 ) + " " + trim( firm.addres2 ) )
    t-phone = firm.phone
    t-inn = firm.inn
  .

  put stream PrnLibStream
    space(5) string( "Грузополучатель  и его адрес   " + trim( clients.obj-name ) + ", " + t-addres )    format "X(130)" skip
    space(5) string( "К платежно-расчетному документу" +  " N " + t-num ) format "X(100)" skip(1)
    space(5) string( "Покупатель   " + clients.obj-name + "(" + string(clients.obj-code) + ")" ) format "X(100)" skip
    space(5) string( "Адрес   " + t-addres ) format "X(90)" skip
    space(5) string( "Идентификационный номер покупателя ({&abbr_inn_allshift})   " + t-inn ) format "X(100)" skip
    space(5) "Дополнение (условия оплаты по договору (контракту), способ отправления и т.п." format "X(130)" skip
    space(5) string( fill( "_", 130 ) ) format "X(130)" skip
  .

  put stream PrnLibStream
    space(10) string( "Цены и суммы указаны в " + trim( ( if x-SET_val_TYPE = 1 then "{&abbr_rublyah}" else base-type ) ) + "." ) format "X(120)"
    skip(1) .

  form with frame factur .

  /*---S---------------- По строке документа -----------------------*/
  if sort-gr = yes then do:
    case sort-name :
      when 1 then do:
        for each gds-prop break by gds-prop.grp-name by gds-prop.gds-name :
          if first-of (gds-prop.grp-name) then put stream PrnLibStream  skip  ":" space(5)  "Группа:" space(2)  gds-prop.grp-name .
          run print-line in this-procedure .
        end.
      end.
      when 2 then do:
        for each gds-prop break by gds-prop.grp-name by gds-prop.b-code :
          if first-of (gds-prop.grp-name) then put stream PrnLibStream  skip  ":" space(5)  "Группа:" space(2)  gds-prop.grp-name .
          run print-line in this-procedure .
        end.
      end.
      when 3 then do:
        for each gds-prop break by gds-prop.grp-name by gds-prop.artic :
          if first-of (gds-prop.grp-name) then put stream PrnLibStream  skip  ":" space(5)  "Группа:" space(2)  gds-prop.grp-name .
          run print-line in this-procedure .
        end.
      end.
    end.
  end.
  else do:
    case sort-name :
      when 1 then do:
        for each gds-prop break by gds-prop.gds-name :      run print-line in this-procedure .      end.
      end.
      when 2 then do:
        for each gds-prop break by gds-prop.b-code :        run print-line in this-procedure .      end.
      end.
      when 3 then do:
        for each gds-prop break by gds-prop.artic :         run print-line in this-procedure .      end.
      end.
    end.
  end.
  /*---E---------------- По строке документа -----------------------*/

  put stream PrnLibStream  v-single-line format "X(198)" .
  if line-counter( PrnLibStream ) + 7 > page-size( PrnLibStream ) then page stream PrnLibStream.

  display stream PrnLibStream  "Всего" @ gds-prop.gds-name   v-tot-sum-no-VAT @ gds-prop.sum-no-VAT  v-tot-VAT @ gds-prop.VAT v-tot-sum  @ gds-prop.sum with frame factur .
  down stream PrnLibStream 2 with frame factur .

  if abs( v-tot-SLT ) >= 0.005 or ( v-tot-discnt >= 0.005 ) then do:
    put stream PrnLibStream
        space(5) "Итого по документу: " trim( string( v-tot-sum, "->,>>>,>>>,>>>,>>>,>>9.99" ) )  + " ("
        + trim( ( if x-SET_val_TYPE = 1 then "{&abbr_rub_allshift}" else base-type ) ) + ")"  format "X(120)"     at {&footer-tab-stop1}
    .
    if v-tot-SLT <> 0 then do:
      put stream PrnLibStream  skip space(10) "Налог с продаж: " trim( string( v-tot-SLT, "->>>,>>9.99" ) )
        + " (" + trim( ( if x-SET_val_TYPE = 1 then "{&abbr_rub_allshift}" else base-type ) ) + ")" format "X(150)"     at {&footer-tab-stop1}
      .
    end.
    if v-tot-discnt <> 0 and v-no-print-discnt = "no" then do:
      put stream PrnLibStream
        skip space(14) "Скидка:" trim( string( v-tot-discnt, "->>>,>>>,>>>,>>9.99" ) )
                    + " (" + trim( ( if x-SET_val_TYPE = 1 then "{&abbr_rub_allshift}" else base-type ) ) + ")" format "X(150)" at {&footer-tab-stop1}
      .
    end.
  end.
  if v-tax-sum <> 0 then do:
    put stream PrnLibStream
      skip space(10)  v-tax-name + ": " format "X(20)"  trim( string( v-tax-sum, "->>>,>>>,>>>,>>9.99" ) )
      + " ("  + trim( if x-SET_val_TYPE = 1 then "{&abbr_rub_allshift}" else base-type  )   + ")"
      format "X(150)"     at {&footer-tab-stop1}
    .
  end.
  put stream PrnLibStream
    skip space(5) "Итого к оплате: " string( trim( string( v-tot-sum + v-tot-SLT, "->,>>>,>>>,>>>,>>>,>>9.99" ) )
     + " (" + trim( if x-SET_val_TYPE = 1 then "{&abbr_rub_allshift}" else base-type ) + ")" )
    format "X(150)"     at {&footer-tab-stop1} skip(1)
  .

  find first buf_clients no-lock  where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = v-cntxt-host-code-obj .
  find first buf_firm no-lock where buf_firm.firm-code = buf_clients.obj-code .
  assign
    v-main-boss = buf_firm.director
    v-main-buh  = buf_firm.gen-acct
  .
  find first buf_sysconf no-lock where buf_sysconf.host-code = v-cntxt-host-code-obj .
  assign v-main-buh  = buf_sysconf.snr-accnt .
  put stream PrnLibStream  space(10) "Руководитель предприятия" format "X(50)" "/ " v-main-boss format "X(36)" " /"
    "          Гл. бухгалтер" format "X(50)" "/ " v-main-buh format "X(36)" " /"  skip (1) space(80) "М.П." format "X(5)"
    space(25) "Выдал" format "X(50)" skip
  .

  hide stream PrnLibStream frame Bottomframe .
  output stream PrnLibStream close.

  { gbl/stopwork.i }

  run prn-lib-prn-file in this-procedure (input my-handle,input 8).
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
      display stream PrnLibStream  sym1 fill(" ",17) + v-add-string @ gds-prop.gds-name
            sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 /*sym10*/ sym11 sym12 sym13
      with frame factur .
      down stream PrnLibStream 1 with frame factur .
    end. /* DO WHILE ... */
  end.
end procedure.




/*==========================================================================*/
procedure print-line :
  do on error undo, return error  :
/*    define variable v-print-parts     as logical    init no       no-undo.*/
    assign
      gds-str  = ''
      gds-str1 = ''
      gds-str2 = ''
      Gds-str1 = breakstr(gds-prop.gds-name, {&gds-len}, input-output gds-str1, input-output gds-str2)
    .
    do while trim(gds-str2) <> "" :
      assign
        gds-str = gds-str2
        gds-str1 = breakstr(gds-str, {&gds-len}, input-output gds-str1, input-output gds-str2)
     .
    end.
    assign gds-str1 = breakstr(gds-prop.gds-name, {&gds-len}, input-output gds-str1, input-output gds-str2).

    if gds-prop.gds-type = {&gds-office} then do: /*---S------------- Услуга ---------------------*/
      display stream PrnLibStream
        sym1  gds-str1 @ gds-prop.gds-name
        sym2  gds-prop.unit-base
        sym3  gds-prop.qnty
        sym4  gds-prop.price-no-VAT
        sym5  gds-prop.sum-no-VAT
        sym6  "   ---" format "x(6)" @ gds-prop.sum-actciz
        sym7  gds-prop.Vat-pc
        sym8  gds-prop.VAT
        sym9  gds-prop.sum
        sym11 gds-prop.country
        sym12
        sym13
      with frame factur .
      down stream PrnLibStream 1 with frame factur .
      run print-more in this-procedure.
      assign v-lines-counter = v-lines-counter + 1.
      /*---E------------- Услуга ---------------------*/
    end.
    else do: /*---S------------- Не услуга ---------------------*/
      display stream PrnLibStream
        sym1  gds-str1      @ gds-prop.gds-name
        sym2  gds-prop.unit-base
        sym3  gds-prop.qnty
        sym4  gds-prop.price-no-VAT
        sym5  gds-prop.sum-no-VAT
        sym6  "   ---" format "x(6)"   @ gds-prop.sum-actciz
        sym7  gds-prop.Vat-pc
        sym8  gds-prop.VAT
        sym9  gds-prop.sum
        sym11 gds-prop.country
        sym12 gds-prop.GTD
        sym13
      with frame factur .
      down stream PrnLibStream 1 with frame factur .
      run print-more in this-procedure.
/*                { rep/r-factur.i tax prt-}*/
      assign v-lines-counter = v-lines-counter + 1.
    /*---E------------- Не услуга ---------------------*/
    end.
        /*---E------------- Пустая шкала или от поставщика ---------------------*/
    assign
      v-tot-sum-no-VAT    = v-tot-sum-no-VAT  + gds-prop.sum-no-VAT
      v-tot-VAT           = v-tot-VAT         + gds-prop.VAT
      v-tot-sum           = v-tot-sum         + gds-prop.sum
    .
  end.
end procedure. /* print-line */