block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-corpr1.p $
$Archive: rep/r-corpr1.p $

Печатные формы. Торг-12 для возврата поставщику

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

define input parameter ParParentProc as widget-handle no-undo.
define input parameter p-cli-type as character no-undo .
define input parameter p-cli-code as integer   no-undo .
define input parameter tdoc-code  as character no-undo .
define input parameter sort-name  as integer   no-undo .
define input parameter sort-gr    as logical   no-undo .
define input parameter is_rem     as logical   no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-corpr1.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-corpr1.p $":U .
define variable vss-description as character no-undo initial "Печатные формы. Торг-12 для внешнего прихода, расхода и возврата поставщику":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ rep/r-sym.i    }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ cmp/breakstr.i }

{ rep/r-cliprp.i def }

{ str/trdcalib.i }
{ rep/fmtcli.i   }
{ gbl/clntattr.i }
{ rep/torgconf.i }
{ trg/factord.i  }

{ str/clcprtsl.i }
{ rep/rep-bt.i   }
{ gbl/prn-lib.i  }

do
on error undo, return error
:
  define variable v-tax-name          as char                             no-undo.
  define variable v-tax-sum           like doc-line.road-tax      init 0  no-undo.
  define variable v-tot-discnt            as decimal   no-undo .

  { rep/r-corpr.i }

  define variable v-doc-date-string   as character                        no-undo.

  define variable v-line-counter      as integer                          no-undo.
  define variable v-doc-line-counter  as integer                          no-undo.
  define variable txt-LC              as char                             no-undo.
  define variable s1                  as char                             no-undo.
  define variable s2                  as char                             no-undo.

  define variable all-tqnty           like doc-line.doc-qnty      init 0  no-undo.
  define variable all-VAT-gds         like ot-line.VAT-base       init 0  no-undo.
  define variable all-SLT-gds         like ot-line.SLT-base       init 0  no-undo.
  define variable all-sum-no-VAT      like doc-line.price-base    init 0  no-undo.
  define variable all-stoim           like doc-line.price-base    init 0  no-undo.
  define variable all-sum             like doc-line.price-base    init 0  no-undo.
  define variable Pg-tqnty            like doc-line.doc-qnty      init 0  no-undo.
  define variable Pg-VAT-gds          like ot-line.VAT-base       init 0  no-undo.
  define variable Pg-SLT-gds          like ot-line.SLT-base       init 0  no-undo.
  define variable Pg-sum-no-VAT      like doc-line.price-base    init 0  no-undo.
  define variable Pg-stoim            like doc-line.price-base    init 0  no-undo.
  define variable PrevPage            as int     init 0   no-undo.

  define variable OKEI                as char                             no-undo.
  define variable tb-code             as char                             no-undo.
  define variable pack-type           as char                             no-undo.
  define variable qnty-opl            like doc-line.doc-qnty              no-undo.
  define variable qnty-pl             like doc-line.doc-qnty              no-undo.
  define variable mass                as decimal     decimals 10          no-undo.

  define variable v-single-line       as char              no-undo.
  define variable v-underline         as char              no-undo.
  define variable v-char-counter      as int               no-undo.

  define variable gds-str             as char              no-undo.
  define variable gds-str1            as char              no-undo.
  define variable gds-str2            as char              no-undo.
  define variable val-str             as char              no-undo.
  define variable v-print-doc                 as character                no-undo.
  define variable v-par-type                  as character                no-undo.
  define variable v-curr-code         as integer      no-undo.

  define variable tmp-var  as character no-undo .
  define variable FullGdsName        as logical   no-undo .

    { gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-prt-firm} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'factur01' then v-print-doc =  string(thbjattr_thbj-attr.property-value-logical) .
    end.
    if v-print-doc <> 'yes'  then assign v-print-doc = "no"  .

    { gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-prt-obj} }
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then tmp-var =  string(thbjattr_thbj-attr.property-value-logical) .
    end.
    assign
      FullGdsName = ( tmp-var = "yes" )
      .

  &scop gds-len-m 52

  define frame f-doc-m
        sym1 column-label ":!:!:!:!:" format "X(1)" space(0)
        v-doc-line-counter COLUMN-LABEL "N!п/п! ! ! " format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        gds-prop.artic COLUMN-LABEL "Артикул! ! ! ! " format "X(17)" space(0)
        sym19 column-label ":!:!:!:!:" format "X(1)" space(0)
        gds-prop.gds-name COLUMN-LABEL "Наименование товара! ! ! ! " format "X({&gds-len-m})" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        tb-code COLUMN-LABEL "Код товара! ! ! ! " format "X(13)" space(0)
        sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        gds-prop.unit-base COLUMN-LABEL "Наим!ед.!изм.! ! " format "X(4)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        OKEI COLUMN-LABEL "Код!ед.!изм.!по!ОКЕИ" format "X(4)" space(0)
        sym6 column-label ":!:!:!:!:" format "X(1)" space(0)
        pack-type COLUMN-LABEL "Вид!уп.! ! ! " format "X(3)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-opl COLUMN-LABEL "Кол-!во в!одном!месте! " format ">>9.<" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        qnty-pl COLUMN-LABEL "Кол-!во!мест! ! " format ">>9.<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        mass COLUMN-LABEL "Масса!брут-!то! ! " format ">>9.<" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        gds-prop.qnty COLUMN-LABEL "Количество ! ! ! ! " format "->>>>>9.<<<" space(0)
        sym11 column-label ":!:!:!:!:" format "X(1)" space(0)
        gds-prop.price-no-VAT COLUMN-LABEL "Цена без!НДС и НП! ! ! " format "->>>>>9.99" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        gds-prop.sum-no-VAT COLUMN-LABEL "Сумма без!НДС и НП! ! ! " format "->>,>>>,>>9.99" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
        gds-prop.VAT-pc column-label "Став-!ка!НДС!%! " format ">9.9<" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        gds-prop.VAT column-label "Сумма!НДС! ! ! " format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:!:!:" format "X(1)" space(0)
        gds-prop.stoim column-label "Сумма!с учетом!НДС (без НП)! ! " format "->>>,>>>,>>9.99" space(0)
        sym16 column-label ":!:!:!:!:" format "X(1)" space(0)
    header
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + tdoc-code + " от " + v-doc-date-string ) at 40 format "X(50)"
        /*" "  at 100 format "X(30)" */ string( "Страница " + string( PAGE-NUMBER( PrnLibStream ), ">>9" ) ) at 180 format "X(13)" SKIP
        v-single-line format "X(198)" at 1
  with width {&DOS_CW} down stream-io.


  assign
    v-single-line = fill("-", 230)
    v-underline = fill("_", 230)
    v-line-counter = 1
    v-doc-line-counter = 1
  .
    if x-SET_val_TYPE = 1 then assign v-curr-code = 0 .
    else assign v-curr-code = base-code .

    run torgconf-read in this-procedure (
          input "torg12"
        , input v-cntxt-host-code-obj
        , input v-obj-type
        , input v-obj-code
    ) no-error.
    if error-status :error
    then do:
        message
        vss-workfile vss-revision vss-description
        skip "Ошибка чтения параметров печати формы."
        skip "Форма будет напечатана с параметрами по умолчанию."
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
        view-as alert-box error.
    end.

  if v-torgconf-outdate = yes then  assign v-doc-date-string =  "          " .
  else  assign v-doc-date-string = string( x-date-end, "99/99/9999" ) .

  { gbl/working.i }
  run prn-lib-open-stream  in this-procedure (input my-handle,input {&LS_PS_A4},input yes,input no).

  form header
    v-single-line format "X(198)" at 1 SKIP
    "Продолжение - на следующей странице" at 30 SKIP
    with frame BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  view stream PrnLibStream frame BottomFrame .

  assign  val-str =  if x-SET_val_TYPE = 1 then "{&abbr_rublyah}" else base-type .

/*  find first pay-type no-lock  where pay-type.obj-code = t-doc.pay-code no-error .*/

  /* реквизиты нашей фирмы  */
  find first clients no-lock  where clients.obj-type = {&cmp}   and clients.obj-code = v-cntxt-host-code-obj .
  { rep/r-cliprp.i }

  if v-torgconf-outappr = yes then  put stream PrnLibStream  "Утверждена постановлением Госкомстата России от 25.12.98 N 132" at 137 .

  put stream PrnLibStream
    space(5) v-single-line format  "X(19)" at 180 skip
    space(5) "| " at 180 {&g___code} at 188 "|" at 198 skip
    space(5) "Форма по ОКУД" format "X(14)" at 166 "| " at 180 "0330212" "|" at 198 skip
    space(5) string( "{&abbr_inn_allshift} " + t-inn + " " + CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")" + t-addres + t-phone) format "X(160)"
                   "по ОКПО" format "X(7)" at 172 "| " at 180 t-okpo format "X(16)" "|" at 198 skip
    space(5) ( if is_rem then string( CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")" ) else  " " ) format "X(160)" "| " at 180  "|" at 198 skip
    space(5) "Вид деятельности по ОКДП" format "X(25)" at 155 "| " at 180 "|" at 198 skip
  .

  if is_rem = yes then find first clients no-lock where clients.obj-type = {&cmp}     and clients.obj-code = v-cntxt-host-code-obj  .
  else                 find first clients no-lock where clients.obj-type = p-cli-type and clients.obj-code = p-cli-code .

  { rep/r-cliprp.i }
  put stream PrnLibStream
    space(5) string( "Грузоотправитель: " + "{&abbr_inn_allshift} " + t-inn + " " + CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ") "
                + t-addres + " " + t-phone)  format "X(160)"  "по ОКПО" format "X(7)"  at 172  "| " at 180  t-okpo format "X(16)"  "|" at 198 skip
  .

  if is_rem = yes then find first clients no-lock where clients.obj-type = {&cmp}     and clients.obj-code = v-cntxt-host-code-obj .
  else                 find first clients no-lock where clients.obj-type = p-cli-type and clients.obj-code = p-cli-code .


    run fmtcli-get-bank in this-procedure (
          input v-cntxt-host-code-obj
        , input clients.obj-type
        , input clients.obj-type
        , input v-curr-code
    ).
  put stream PrnLibStream
    space(5) string( "Поставщик: " + clients.obj-name
                    + ( if v-fmtcli-schet-exists
                        then substitute( ", р/с &1 к/с &2", v-fmtcli-bank-r-schet, v-fmtcli-bank-c-schet )
                            + ( if v-fmtcli-bank-exists
                                then substitute( " БИК &1 в &2 &3", v-fmtcli-bank-bik, v-fmtcli-bank-name, v-fmtcli-bank-addres  )
                                else ""
                              )
                        else "" )
                      ) format "X(160)"
              "по ОКПО" format "X(7)"       at 172
              "| "                          at 180
              t-okpo    format "X(16)"
              "|"                           at 198 skip
  .

  if is_rem = yes then find first clients no-lock where clients.obj-type = p-cli-type and clients.obj-code = p-cli-code .
  else                 find first clients no-lock where clients.obj-type = {&cmp}     and clients.obj-code = v-cntxt-host-code-obj .

    run fmtcli-get-bank in this-procedure (
          input v-cntxt-host-code-obj
        , input clients.obj-type
        , input clients.obj-type
        , input v-curr-code
    ).
  define variable v-attr-value  as character no-undo .
  define variable v-attr-type   as character no-undo .
  define variable v-osnov       as character initial "" no-undo .

  put stream PrnLibStream
    space(5) string( "Плательщик: " + clients.obj-name
                    + ( if v-fmtcli-schet-exists
                        then substitute( ", р/с &1 к/с &2", v-fmtcli-bank-r-schet, v-fmtcli-bank-c-schet )
                            + ( if v-fmtcli-bank-exists
                                then substitute( " БИК &1 в &2 &3", v-fmtcli-bank-bik, v-fmtcli-bank-name, v-fmtcli-bank-addres  )
                                else ""
                              )
                        else "" )
                      ) format "X(160)"
             "по ОКПО"          format "X(7)"       at 172
             "| "                                   at 180
             t-okpo             format "X(16)"
             "|"                                    at 198 skip
             space(5) string( "Основание: " + v-osnov ) format "X(160)" "номер" format "X(5)" at 174 "| " at 180  "|" at 198 skip
  .

  if v-torgconf-outprim = no then  put stream PrnLibStream space(5) string( "Примечание: " ) format "X(160)" .

  put stream PrnLibStream  "дата" format "X(4)" at 175 "| " at 180 "|" at 198 skip
    space(5) string( "Вид оплаты: " /*+ ( if available pay-type then pay-type.obj-name else "?" ) */) format "X(130)"
    string( "Транспортная накладная " ) format "X(23)" at 147 "номер" format "X(5)" at 174 "| " at 180 tdoc-code format "X(16)" "|" at 198 skip
    space(5) "дата" format "X(4)" at 175 "| " at 180 v-doc-date-string format "X(10)" "|" at 198 skip
    space(5) "Вид операции" format "X(12)" at 167 "| " at 180  (if is_rem = yes then "возврат пост-ку" else "приход")  format "X(16)" "|" at 198 skip
    space(5) v-single-line format  "X(19)" at 180 skip    space(64) v-single-line format "X(33)" skip
    space(45) string( "ТОВАРНАЯ НАКЛАДНАЯ | " + string( tdoc-code, "X(16)") + " | " + v-doc-date-string + " | " ) format "X(100)" skip
    space(64) v-single-line format "X(33)"
  .

  if is_rem = yes then put stream PrnLibStream skip space(10) "Возврат товара поставщику" format "X(120)" .

  form with frame f-doc-m .
  if sort-gr = yes then down stream PrnLibStream 1 with frame f-doc-m .


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


  if line-counter( PrnLibStream ) + 20 > page-size( PrnLibStream ) then do:
    put stream PrnLibStream v-single-line format "x(198)" skip.
    display stream PrnLibStream
      "Итого"         @ gds-prop.gds-name
       Pg-tqnty       @ gds-prop.qnty
       Pg-sum-no-VAT @ gds-prop.sum-no-VAT
       Pg-VAT-gds     @ gds-prop.VAT
       Pg-stoim       @ gds-prop.stoim
    with frame f-doc-m .
    down stream PrnLibStream 1 with frame f-doc-m .
    page stream PrnLibStream .
    if page-number( PrnLibStream ) > prevpage then  assign  Pg-tqnty = 0  Pg-VAT-gds = 0   Pg-sum-no-VAT = 0  Pg-stoim = 0   .
  end.
  hide stream PrnLibStream frame BottomFrame .

  put stream PrnLibStream v-single-line format "x(198)" skip.
  display stream PrnLibStream
    "Итого"           @ gds-prop.gds-name
     Pg-tqnty         @ gds-prop.qnty
     Pg-sum-no-VAT   @ gds-prop.sum-no-VAT
     Pg-VAT-gds       @ gds-prop.VAT
     Pg-stoim         @ gds-prop.stoim
  with frame f-doc-m .
  down stream PrnLibStream 1 with frame f-doc-m .
  display stream PrnLibStream
        "Всего по накладной"               @ gds-prop.gds-name
        all-tqnty          @ gds-prop.qnty
        all-sum-no-VAT    @ gds-prop.sum-no-VAT
        all-VAT-gds        @ gds-prop.VAT
        all-stoim          @ gds-prop.stoim
  with frame f-doc-m .
  down stream PrnLibStream 2 with frame f-doc-m .

  if x-SET_val_TYPE = 1 then  run rep/wp-rub.p ( all-sum , output s1, output s2 ) .
  else               run rep/wp.p ( ParParentProc, all-sum , output s1, output s2 ) .

  run rep/wp-qnty.p ( input ( v-doc-line-counter - 1 ), output txt-LC).
  put stream PrnLibStream
    space(10) "  Всего на сумму:        "
    trim( string( all-sum , "->>>,>>>,>>>,>>>,>>9.99") ) format "X(25)"
    " (" trim( (  if x-SET_val_TYPE = 1 then "{&abbr_rub_allshift}" else base-type ) ) format "X(6)" ")"
  .

  put stream PrnLibStream skip space(15) string( "В том числе: " ) format "X(160)" skip .
  if v-tax-sum <> 0 then do:
    put stream PrnLibStream space(21) v-tax-name + ":" + fill(" ", 1) + trim(string(v-tax-sum, "->>>,>>>,>>>,>>>,>>9.99"))
                       + " (" + trim( ( if x-SET_val_TYPE = 1 then "{&abbr_rub_allshift}" else base-type ) ) + ")" format "X(160)"  .
  end.

    define variable v-doc-places    as character    no-undo.
    { str/tdat-val.i
        tdoc-code
        {&trdcattr-qntyplace}
        v-doc-places
        v-attr-type
    }
    if v-doc-places = "":U
    then do:
        assign
            v-doc-places = v-underline
        .
    end.
  put stream PrnLibStream  skip
    space(30) string( "НДС: " + trim( string( all-VAT-gds, "->>>,>>>,>>>,>>>,>>9.99") ) +
                                " (" + trim( ( if x-SET_val_TYPE = 1 then "{&abbr_rub_allshift}" else base-type ) ) + ")" ) format "X(160)" skip(2)
/*    space(19) string( "налог с продаж: " + trim( string( (accum total SLT-gds), "->>>,>>>,>>>,>>>,>>9.99") ) +*/
/*                                " (" + trim( ( if x-SET_val_TYPE = 1 then "{&abbr_rub_allshift}" else base-type ) ) + ")" ) format "X(160)" skip(2)*/
    space(10) string( "Товарная накладная имеет приложение на " + v-underline ) format "X(125)" skip
    space(10) string( "и содержит " + CAPS( txt-LC ) + " порядковый(ых) номер(ов) записей") format "X(180)" skip
    v-underline format "X(29)" at 151 skip
    string( "Масса груза (нетто) " + v-underline ) format "X(85)" at 60 string( "|" + v-underline ) format "X(30)" at 150 "|" skip
    space(10) string( "Всего мест " + v-doc-places ) format "X(45)" string( "Масса груза (брутто) " + v-underline ) format "X(85)" at 60
            string( "|" + v-underline ) format "X(30)" at 150 "|" skip(1)
    string( "Приложение (паспорта, сертификаты, и т.д.) на " + string( v-underline, "X(42)" ) + " листах" ) format "X(95)" "|" at 97
        string( "По доверенности N " + string( v-underline, "X(39)" ) + " от " + v-underline ) format "X(100)" at 99 skip
    "Всего отпущено на сумму " format "X(95)" "|" at 97 string( "выданной " + v-underline ) format "X(100)" at 99 skip
    space(2) CAPS(s1) format "X(93)" "|" at 97 skip
  .

    put stream PrnLibStream
        string( "Отпуск разрешил " + v-underline ) format "X(95)" "|" at 97
        skip "|" at 97 string( "Груз принял " + v-underline ) format "X(100)" at 99
        skip v-underline format "X(95)" "|" at 97 string( "Груз получил грузополучатель " + v-underline ) format "X(100)" at 99
        skip "М.П." at 15  "|" at 97 "М.П." at 99
    .

  { gbl/stopwork.i }

  output stream PrnLibStream close.

  run prn-lib-prn-file in this-procedure (input my-handle,input 8).

end.




/*====================================================================*/
/*---S---------------- Печать линии в документе ----------------------*/
procedure print-line :
  do on error undo, return error :

    /*---S--------- Определили наименование товара -------------------*/
    if FullGdsName then do:
      gds-str1 = breakstr(gds-prop.gds-name, {&gds-len-m}, input-output gds-str1, input-output gds-str2).
      assign v-char-counter = 0.
      do while gds-str2 <> "" :
        assign
          gds-str = gds-str2
          gds-str1 = breakstr(gds-str, {&gds-len-m}, input-output gds-str1, input-output gds-str2)
          v-char-counter = v-char-counter + 1
        .
      end. /* do while ... */
      if line-counter( PrnLibStream ) + v-char-counter > page-size( PrnLibStream )  then do:
        put stream PrnLibStream v-single-line format "x(198)" skip.
        display stream PrnLibStream
          "Итого"           @ gds-prop.gds-name
           Pg-tqnty         @ gds-prop.qnty
           Pg-sum-no-VAT   @ gds-prop.sum-no-VAT
           Pg-VAT-gds       @ gds-prop.VAT
           Pg-stoim         @ gds-prop.stoim
        with frame f-doc-m .
        down stream PrnLibStream 1 with frame f-doc-m .
        PAGE stream PrnLibStream.
        if page-number( PrnLibStream ) > prevpage then  assign  Pg-tqnty = 0  Pg-VAT-gds = 0   Pg-sum-no-VAT = 0  Pg-stoim = 0   .
      end.
      assign
        gds-str1 = breakstr(gds-prop.gds-name, {&gds-len-m}, input-output gds-str1, input-output gds-str2)
      .
    end.
    else  assign gds-str1 = gds-prop.gds-name  .

    /*---E--------- Определили наименование товара -------------------*/

    display stream PrnLibStream
      v-doc-line-counter
      gds-prop.artic
      gds-str1          @ gds-prop.gds-name
      string( gds-prop.b-code )   @ tb-code
      gds-prop.unit-base
      gds-prop.qnty
      gds-prop.price-no-VAT
      gds-prop.sum-no-VAT
      gds-prop.VAT-pc
      gds-prop.VAT
      gds-prop.stoim
      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym19
    with frame f-doc-m.
    down stream PrnLibStream 1 with frame f-doc-m.

    if FullGdsName then do:
      do while gds-str2 <> "" :
        assign
          gds-str = gds-str2
          gds-str1 = breakstr(gds-str, {&gds-len-m}, input-output gds-str1, input-output gds-str2)
        .
        display stream PrnLibStream
          gds-str1 @ gds-prop.gds-name sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym19
        with frame f-doc-m .
        down stream PrnLibStream 1 with frame f-doc-m .
      end. /* do while ... */
    end.

    assign
      v-line-counter     = v-line-counter + 1
      v-doc-line-counter = v-doc-line-counter + 1
      PrevPage = page-number( PrnLibStream )
      Pg-tqnty       = Pg-tqnty       + gds-prop.qnty
      Pg-VAT-gds     = Pg-VAT-gds     + gds-prop.VAT
      Pg-sum-no-VAT = Pg-sum-no-VAT + gds-prop.sum-no-VAT
      Pg-stoim       = Pg-stoim       + gds-prop.stoim
      all-tqnty       = all-tqnty       + gds-prop.qnty
      all-sum-no-VAT = all-sum-no-VAT + gds-prop.sum-no-VAT
      all-VAT-gds     = all-VAT-gds     + gds-prop.VAT
      all-stoim       = all-stoim       + gds-prop.stoim
      all-sum         = all-sum         + gds-prop.sum
    .
    if line-counter( PrnLibStream ) + 1 > page-size( PrnLibStream ) then do:
      put stream PrnLibStream v-single-line format "x(198)" skip.
      display stream PrnLibStream
        "Итого"   @ gds-prop.gds-name
         Pg-tqnty @ gds-prop.qnty
         Pg-sum-no-VAT @ gds-prop.sum-no-VAT
         Pg-VAT-gds  @ gds-prop.VAT
         Pg-stoim @ gds-prop.stoim
      with frame f-doc-m .
      down stream PrnLibStream 1 with frame f-doc-m .
      if page-number( PrnLibStream ) > prevpage then  assign  Pg-tqnty = 0  Pg-VAT-gds = 0   Pg-sum-no-VAT = 0  Pg-stoim = 0   .
    end.

  end.
end procedure. /* print-line */
/*---E-------- Печать линии в документе -----------------*/