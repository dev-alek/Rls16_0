block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trg-12po.p $
$Archive: rep/trg-12po.p $

Печатные формы. Торг-12 для возврата поставщику

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

*/

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter is_rem               as character        no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: trg-12po.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/trg-12po.p $":U .
define variable vss-description as character no-undo initial "Печатные формы. Торг-12 для внешнего прихода, расхода и возврата поставщику":U .

{ cmp/vssrevis.i    }
{ cmp/str-glbl.i    }
{ cmp/library.i     }
{ cmp/r-pril.i      }
{ cmp/breakstr.i    }
{ gbl/cur-time.i    }
{ gbl/dtm.i         }
{ str/trdcalib.i    }
{ rep/fmtcli.i      }
{ gbl/clntattr.i    }
{ rep/torgconf.i    }
{ str/clcprtsl.i    }

do
on error undo, return error
:

  DEFINE temp-table gds-prop no-undo
    field   artic            as  char
    field   prod-type        as  char
    field   prod-code        as  integer
    field   part-code        like parts.part-code
    field   in-code          like parts.in-code
    field   gds-code         as  integer
    field   gds-name         as  char
    field   grp-name         as  char
    field   unit-base        as  char
    field   b-code           as  integer
    field   qnty             as  decimal
    field   price-noNDS      as  decimal
    field   stoim-noNDS      as  decimal
    field   VAT-pc           as  decimal
    field   VAT-sum          as  decimal
    field   stoim            as  decimal
    field   sum              as  decimal
    INDEX pi  IS PRIMARY   artic  prod-type prod-code
    INDEX pi1              gds-name
    INDEX pi2              grp-name
 .


  define buffer t-doc             for trn-doc.
  define buffer buf_goods         for goods.
  define buffer buf_parts         for parts .

  define stream out-stream .

/*  define shared var PrintScale   as logical                          no-undo. */
/*  define shared var CostPrice    as logical                          no-undo. */
  define shared var sort-name    as logical                          no-undo.
  define shared var sort-gr      as logical                          no-undo.

  define variable v-rootnode-code     as integer                          no-undo.

  define variable v-line-counter      as integer                          no-undo.
  define variable v-doc-line-counter  as integer                          no-undo.
  define variable txt-LC              as char                             no-undo.
  define variable s1                  as char                             no-undo.
  define variable s2                  as char                             no-undo.

  define variable all-tqnty            like doc-line.doc-qnty      init 0  no-undo.
  define variable all-VAT-gds          like ot-line.VAT-base       init 0  no-undo.
  define variable all-SLT-gds          like ot-line.SLT-base       init 0  no-undo.
  define variable all-stoim-noNDS      like doc-line.price-base    init 0  no-undo.
  define variable all-stoim            like doc-line.price-base    init 0  no-undo.
  define variable all-sum              like doc-line.price-base    init 0  no-undo.
  define variable Pg-tqnty            like doc-line.doc-qnty      init 0  no-undo.
  define variable Pg-VAT-gds          like ot-line.VAT-base       init 0  no-undo.
  define variable Pg-SLT-gds          like ot-line.SLT-base       init 0  no-undo.
  define variable Pg-stoim-noNDS      like doc-line.price-base    init 0  no-undo.
  define variable Pg-stoim            like doc-line.price-base    init 0  no-undo.
  define variable PrevPage            as int     init 0   no-undo.

  define variable OKEI                as char                             no-undo.
  define variable tb-code             as char                             no-undo.
  define variable pack-type           as char                             no-undo.
  define variable qnty-opl            like doc-line.doc-qnty              no-undo.
  define variable qnty-pl             like doc-line.doc-qnty              no-undo.
  define variable mass                as decimal     decimals 10          no-undo.

  define variable v-tax-name          as char                             no-undo.
  define variable v-tax-sum           like doc-line.road-tax      init 0  no-undo.

  define variable sym1                as char     init ":" no-undo.
  define variable sym2                as char     init ":" no-undo.
  define variable sym3                as char     init ":" no-undo.
  define variable sym4                as char     init ":" no-undo.
  define variable sym5                as char     init ":" no-undo.
  define variable sym6                as char     init ":" no-undo.
  define variable sym7                as char     init ":" no-undo.
  define variable sym8                as char     init ":" no-undo.
  define variable sym9                as char     init ":" no-undo.
  define variable sym10               as char     init ":" no-undo.
  define variable sym11               as char     init ":" no-undo.
  define variable sym12               as char     init ":" no-undo.
  define variable sym13               as char     init ":" no-undo.
  define variable sym14               as char     init ":" no-undo.
  define variable sym15               as char     init ":" no-undo.
  define variable sym16               as char     init ":" no-undo.
  define variable sym17               as char     init ":" no-undo.
  define variable sym18               as char     init ":" no-undo.
  define variable sym19               as char     init ":" no-undo.

  define variable v-single-line       as char              no-undo.
  define variable v-underline         as char              no-undo.
  define variable v-char-counter      as int               no-undo.

  define variable gds-str             as char              no-undo.
  define variable gds-str1            as char              no-undo.
  define variable gds-str2            as char              no-undo.
  define variable val-str             as char              no-undo.
  define variable v-print-doc       as character                no-undo.
  define variable v-par-type        as character                no-undo.
  define variable v-host-code       as integer                  no-undo.
  define variable v-curr-code       as integer                  no-undo.

  define variable g#report-num    as integer      no-undo.
  define variable g#quest-print   as logical      no-undo.
  define variable g#log           as logical      no-undo.

  run get-report-num in p-mainmenu-handle (
      output g#report-num
  ).
  run get-quest-print in p-mainmenu-handle (
      output g#quest-print
  ).

  find first t-doc no-lock where recid( t-doc ) = rec_id .
  { gbl/hostcode.i
    t-doc.obj-type
    t-doc.obj-code
    v-host-code
  }
    if printRubl = yes
    then do:
        assign
            v-curr-code = 0
        .
    end.
    else do:
        { gbl/basecode.i
            v-host-code
            v-curr-code
        }
    end.
  run torgconf-read in this-procedure (
      input "torg12"
    , input v-host-code
    , input t-doc.obj-type
    , input t-doc.obj-code
  ) no-error.
  if error-status :error then do:
      message   vss-workfile vss-revision vss-description
      skip "Ошибка чтения параметров печати формы."  skip "Форма будет напечатана с параметрами по умолчанию."
      skip return-value skip trim(error-status :get-message(1))  trim(error-status :get-message(2)) trim(error-status :get-message(3))
      view-as alert-box error.
  end.
  run torgconf-get-self-param in this-procedure (
      input t-doc.obj-type
      , input t-doc.obj-code
      , input v-curr-code
  ) no-error.
  if error-status :error
  then do:
      message
      vss-workfile vss-revision vss-description
      skip "Ошибка чтения параметров объекта документа."
      skip return-value
      skip trim(error-status :get-message(1))
          trim(error-status :get-message(2))
          trim(error-status :get-message(3))
      view-as alert-box warning.
  end.
  run torgconf-get-cli-param in this-procedure (
      input t-doc.host-code
      , input t-doc.cli-type
      , input t-doc.cli-code
      , input v-curr-code
  ) no-error.
  if error-status :error
  then do:
      message
      vss-workfile vss-revision vss-description
      skip "Ошибка чтения параметров объекта клиента документа."
      skip return-value
      skip trim(error-status :get-message(1))
          trim(error-status :get-message(2))
          trim(error-status :get-message(3))
      view-as alert-box warning.
  end.
  for each parts-root no-lock where parts-root.doc-code = t-doc.doc-code :
    create gds-prop .
    if is_rem = "yes" then do:
      find first buf_goods where buf_goods.gds-code = parts-root.orig-gds-code no-lock .
      find first buf_parts no-lock
           where buf_parts.artic     = buf_goods.artic
             and buf_parts.prod-code = buf_goods.prod-code
             and buf_parts.prod-type = buf_goods.prod-type
             and buf_parts.part-code = parts-root.orig-part-code
             and buf_parts.in-code   = parts-root.orig-in-code
             and buf_parts.out-code  = t-doc.doc-code
             and buf_parts.obj-code  = t-doc.obj-code
             and buf_parts.obj-type  = t-doc.obj-type
        no-error .
    end.
    else do:
      find first buf_goods where buf_goods.gds-code = parts-root.gds-code no-lock .
      find first buf_parts no-lock
           where buf_parts.artic     = buf_goods.artic
             and buf_parts.prod-code = buf_goods.prod-code
             and buf_parts.prod-type = buf_goods.prod-type
             and buf_parts.part-code = parts-root.part-code
             and buf_parts.in-code   = parts-root.in-code
             and buf_parts.out-code  = t-doc.doc-code
             and buf_parts.obj-code  = t-doc.obj-code
             and buf_parts.obj-type  = t-doc.obj-type
        no-error .
     end.

    { gbl/gdsbcode.i  buf_goods.gds-code  ?  gds-prop.b-code  no-error }
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip  "Код товара" buf_goods.gds-code skip
      view-as alert-box error .
    end.

    for each tt-clcparts : delete tt-clcparts . end.
    create tt-clcparts.
    buffer-copy buf_parts to tt-clcparts.
    run clcprtsl_calc-parts (input recid (tt-clcparts), input no, input no,0,0,0,0,0,0,0,0,0,0,0,0,0,0 ) .
    find first tt-allsum where tt-allsum.sum-type = {&sum-general}.

    assign
      gds-prop.artic     = buf_goods.artic
      gds-prop.prod-type = buf_goods.prod-type
      gds-prop.prod-code = buf_goods.prod-code
      gds-prop.gds-code  = buf_goods.gds-code
      gds-prop.gds-name  = buf_goods.gds-name
      gds-prop.grp-name  = buf_goods.grp-name
      gds-prop.unit-base = buf_goods.unit-base
      gds-prop.part-code = parts-root.part-code
      gds-prop.in-code   = parts-root.in-code
      gds-prop.qnty      = ABSOLUTE(buf_parts.fact-qnty)
      gds-prop.VAT-pc    = buf_parts.VAT-pc
    .

    if PrintRubl then
      assign
        gds-prop.price-noNDS = ABSOLUTE(tt-allsum.sum-dsc-rubl-acc - tt-allsum.slt-rubl-acc - tt-allsum.vat-rubl-acc) / gds-prop.qnty
        gds-prop.stoim-noNDS = ABSOLUTE(tt-allsum.sum-dsc-rubl-acc - tt-allsum.slt-rubl-acc - tt-allsum.vat-rubl-acc)
        gds-prop.VAT-sum     = ABSOLUTE(tt-allsum.vat-rubl-acc)
        gds-prop.stoim       = ABSOLUTE(tt-allsum.sum-dsc-rubl-acc - tt-allsum.slt-rubl-acc)
        gds-prop.sum         = ABSOLUTE(tt-allsum.sum-dsc-rubl-acc)
        v-tax-sum            = v-tax-sum + ABSOLUTE(tt-allsum.road-tax-rubl-acc)
      .
    else
      assign
        gds-prop.price-noNDS = ABSOLUTE(tt-allsum.sum-dsc-base-acc - tt-allsum.slt-base-acc - tt-allsum.vat-base-acc) / gds-prop.qnty
        gds-prop.stoim-noNDS = ABSOLUTE(tt-allsum.sum-dsc-base-acc - tt-allsum.slt-base-acc - tt-allsum.vat-base-acc)
        gds-prop.VAT-sum     = ABSOLUTE(tt-allsum.vat-base-acc)
        gds-prop.stoim       = ABSOLUTE(tt-allsum.sum-dsc-base-acc - tt-allsum.slt-base-acc)
        gds-prop.sum         = ABSOLUTE(tt-allsum.sum-dsc-base-acc)
        v-tax-sum            = v-tax-sum + ABSOLUTE(tt-allsum.road-tax-base-acc)
      .
  end.

{ gbl/getsect.i run t-doc.obj-type t-doc.obj-code {&attr-prt-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'factur01' then v-print-doc =  string(thbjattr_thbj-attr.property-value-logical) .
end.
if v-print-doc <> 'yes'  then assign v-print-doc = "no"  .
define variable  FullGdsName as logical   no-undo .
{ gbl/getsect.i run t-doc.obj-type t-doc.obj-code {&attr-prt-obj} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'FGdsNinD' then FullGdsName =  thbjattr_thbj-attr.property-value-logical .
end.

    run torgconf-get-form-header in this-procedure (
          input ( is_rem = "yes" )
        , input t-doc.doc-code
        , input ( v-print-doc = "yes" )
        , input t-doc.doc-date
        , input t-doc.fact-date
        , input t-doc.doc-type
        , input t-doc.status_
        , input no
        , input no
    ).

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
        gds-prop.price-noNDS COLUMN-LABEL "Цена без!НДС и НП! ! ! " format "->>>>>9.99" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        gds-prop.stoim-noNDS COLUMN-LABEL "Сумма без!НДС и НП! ! ! " format "->>,>>>,>>9.99" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
        gds-prop.VAT-pc column-label "Став-!ка!НДС!%! " format ">9.9<" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        gds-prop.VAT-sum column-label "Сумма!НДС! ! ! " format "->>,>>>,>>9.99" space(0)
        sym15 column-label ":!:!:!:!:" format "X(1)" space(0)
        gds-prop.stoim column-label "Сумма!с учетом!НДС (без НП)! ! " format "->>>,>>>,>>9.99" space(0)
        sym16 column-label ":!:!:!:!:" format "X(1)" space(0)
    header
        string( "Цены и суммы указаны в " + trim( val-str ) ) format "X(30)"
        string( "Документ N: " + v-torgconf-doc-code + " от " + v-torgconf-doc-date ) at 40 format "X(50)"
            ( if t-doc.status_ <> {&fact} then string( "Статус документа: " + t-doc.status_ + " " + string( t-doc.flag_, "+/-" ) )
              else  " " ) at 100 format "X(30)"
            string( "Страница " + string( PAGE-NUMBER( out-stream ), ">>9" ) ) at 180 format "X(13)" SKIP
        v-single-line format "X(198)" at 1
    with width {&DOS_CW} down stream-io.

  assign
    v-single-line = fill("-", 230)
    v-underline = fill("_", 230)
    v-line-counter = 1
    v-doc-line-counter = 1
  .

  { gbl/working.i }
  { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }

  form header
    v-single-line format "X(198)" at 1 SKIP
    "Продолжение - на следующей странице" at 30 SKIP
    with frame BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  view stream out-stream frame BottomFrame .

  assign  val-str =  if PrintRubl then "{&abbr_rublyah}" else "баз.вал" .

  find first pay-type no-lock  where pay-type.obj-code = t-doc.pay-code no-error .

  /* реквизиты нашей фирмы  */
  if v-torgconf-outappr = yes then  put stream out-stream  "Утверждена постановлением Госкомстата России от 25.12.98 N 132" at 137 .

  put stream out-stream
    space(5) v-single-line format  "X(19)" at 180 skip
    space(5) "| " at 180 {&g___code} at 188 "|" at 198 skip
    space(5) "Форма по ОКУД"            format "X(14)"      at 166
             "| "                                           at 180
             "0330212"
             "|"                                            at 198 skip
    space(5) v-torgconf-organization    format "X(160)"
                   "по ОКПО"            format "X(7)"       at 172
                   "| "                                     at 180
                   v-torgconf-okpo      format "X(16)"
                   "|"                                      at 198 skip
    space(5) v-torgconf-client-from     format "X(160)"
             "| "                                           at 180
             "|"                                            at 198 skip
    space(5) "Вид деятельности по ОКДП" format "X(25)"      at 155
             "| "                                           at 180
             "|"                                            at 198 skip
  .
    put stream out-stream
        space(5) v-torgconf-torg12-cargo-string     format "X(160)"
                 "по ОКПО"                          format "X(7)"       at 172
                 "| "                                               at 180
                 v-torgconf-torg12-cargo-okpo       format "X(16)"
                 "|"                                                at 198 skip
    .
    put stream out-stream
        space(5) string( "Поставщик: " + v-torgconf-suppi )      format "X(160)"
                 "по ОКПО"                                          format "X(7)"   at 172
                 "| "                                                               at 180
                 v-torgconf-supplier-okpo                           format "X(16)"
                 "|"                                                                at 198 skip
    .

    define variable v-attr-value  as character no-undo .
    define variable v-attr-type   as character no-undo .
    define variable v-osnov       as character initial "" no-undo .
    if t-doc.doc-type = {&income} then  do:
        { str/tdat-val.i t-doc.doc-code {&trdcattr-nids} v-attr-value v-attr-type }
        assign v-osnov = v-attr-value .
        { str/tdat-val.i t-doc.doc-code {&trdcattr-dids} v-attr-value v-attr-type }
        assign v-osnov = v-osnov + " от " + v-attr-value .
    end.
    put stream out-stream
        space(5) string( "Плательщик: " + v-torgconf-saler )                         format "X(160)"
                        "по ОКПО" format "X(7)" at 172 "| " at 180 v-torgconf-saler-okpo   format "X(16)" "|" at 198 skip
        space(5) string( "Основание: " + v-osnov ) format "X(160)"
                        "номер" format "X(5)" at 174 "| " at 180  "|" at 198 skip
    .

  if v-torgconf-outprim = no then  put stream out-stream space(5) string( "Примечание: " + (if not( t-doc.PS begins "@" ) then t-doc.PS else "" ) ) format "X(160)" .

  put stream out-stream  "дата" format "X(4)" at 175 "| " at 180 "|" at 198 skip
    space(5) string( "Вид оплаты: " + ( if available pay-type then pay-type.obj-name else "?" ) ) format "X(130)"
                    string( "Транспортная накладная " ) format "X(23)" at 147
                    "номер" format "X(5)" at 174 "| " at 180 v-torgconf-doc-code format "X(16)" "|" at 198 skip
    space(5) "дата" format "X(4)" at 175 "| " at 180 v-torgconf-doc-date format "X(10)" "|" at 198 skip
    space(5) "Вид операции" format "X(12)" at 167 "| " at 180  (if is_rem = "yes" then "возврат пост-ку" else "приход")  format "X(16)" "|" at 198 skip
    space(5) v-single-line format  "X(19)" at 180 skip    space(64) v-single-line format "X(33)" skip
    space(45) string( "ТОВАРНАЯ НАКЛАДНАЯ | " + string( v-torgconf-doc-code, "X(16)") + " | " + v-torgconf-doc-date + " | " +
                      (if t-doc.status_ <> {&fact} then string( "(" + CAPS(t-doc.status_) + ")" ) else "") ) format "X(100)" skip
    space(64) v-single-line format "X(33)"
  .

  if is_rem = "yes" then put stream out-stream skip space(10) "Возврат товара поставщику" format "X(120)" .

  form with frame f-doc-m .
  if sort-gr = yes then down stream out-stream 1 with frame f-doc-m .


  if sort-name = yes then do:    /*Включена сортировка по имени*/
    if sort-gr = yes then do:
      for each gds-prop break by gds-prop.grp-name by gds-prop.gds-name :
        if first-of (gds-prop.grp-name) then put stream out-stream  skip  ":" space(5)  "Группа:" space(2)  gds-prop.grp-name .
        run print-line in this-procedure .
      end.
    end.
    else do:
      for each gds-prop break by gds-prop.gds-name :
        run print-line in this-procedure .
      end.
    end.
  end.                           /*Включена сортировка по имени*/
  else do:                       /*Сортировка по имени выключена*/
    if sort-gr = yes then do:
      for each gds-prop break by gds-prop.grp-name by gds-prop.artic  :
        if first-of (gds-prop.grp-name) then put stream out-stream  skip  ":" space(5)  "Группа:" space(2)  gds-prop.grp-name .
        run print-line in this-procedure .
      end.
    end.
    else do:
      for each gds-prop break by gds-prop.artic  :
        run print-line in this-procedure .
      end.
    end.
  end.                           /*Сортировка по имени выключена*/

  if line-counter( out-stream ) + 20 > page-size( out-stream ) then do:
    put stream out-stream v-single-line format "x(198)" skip.
    display stream out-stream
      "Итого"         @ gds-prop.gds-name
       Pg-tqnty       @ gds-prop.qnty
       Pg-stoim-noNDS @ gds-prop.stoim-noNDS
       Pg-VAT-gds     @ gds-prop.VAT-sum
       Pg-stoim       @ gds-prop.stoim
    with frame f-doc-m .
    down stream out-stream 1 with frame f-doc-m .
    page stream out-stream .
    if page-number( out-stream ) > prevpage then  assign  Pg-tqnty = 0  Pg-VAT-gds = 0   Pg-stoim-noNDS = 0  Pg-stoim = 0   .
  end.
  hide stream out-stream frame BottomFrame .

  put stream out-stream v-single-line format "x(198)" skip.
  display stream out-stream
    "Итого"           @ gds-prop.gds-name
     Pg-tqnty         @ gds-prop.qnty
     Pg-stoim-noNDS   @ gds-prop.stoim-noNDS
     Pg-VAT-gds       @ gds-prop.VAT-sum
     Pg-stoim         @ gds-prop.stoim
  with frame f-doc-m .
  down stream out-stream 1 with frame f-doc-m .
  display stream out-stream
        "Всего по накладной"               @ gds-prop.gds-name
        all-tqnty          @ gds-prop.qnty
        all-stoim-noNDS    @ gds-prop.stoim-noNDS
        all-VAT-gds        @ gds-prop.VAT-sum
        all-stoim          @ gds-prop.stoim
  with frame f-doc-m .
  down stream out-stream 2 with frame f-doc-m .

  if PrintRubl then  run rep/wp-rub.p ( all-sum , output s1, output s2 ) .
  else               run rep/wp.p ( input p-mainmenu-handle, all-sum , output s1, output s2 ) .

  run rep/wp-qnty.p ( input ( v-doc-line-counter - 1 ), output txt-LC).
  put stream out-stream
    space(10) "  Всего на сумму:        "
    trim( string( all-sum , "->>>,>>>,>>>,>>>,>>9.99") ) format "X(25)"
    " (" trim( (  if PrintRubl then "{&abbr_rub}" else "баз.вал" ) ) format "X(6)" ")"
  .

  put stream out-stream skip space(15) string( "В том числе: " ) format "X(160)" skip .
  if v-tax-sum <> 0 then do:
    put stream out-stream space(21) v-tax-name + ":" + fill(" ", 1) + trim(string(v-tax-sum, "->>>,>>>,>>>,>>>,>>9.99"))
                       + " (" + trim( ( if PrintRubl then "{&abbr_rub}" else "баз.вал" ) ) + ")" format "X(160)"  .
  end.

    define variable v-doc-places    as character    no-undo.
    { str/tdat-val.i
        t-doc.doc-code
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
  put stream out-stream  skip
    space(30) string( "НДС: " + trim( string( all-VAT-gds, "->>>,>>>,>>>,>>>,>>9.99") ) +
                                " (" + trim( ( if PrintRubl then "{&abbr_rub}" else "баз.вал" ) ) + ")" ) format "X(160)" skip(2)
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

    put stream out-stream
        string( "Отпуск разрешил " + v-underline ) format "X(95)" "|" at 97
        skip "|" at 97 string( "Груз принял " + v-underline ) format "X(100)" at 99
        skip v-underline format "X(95)" "|" at 97 string( "Груз получил грузополучатель " + v-underline ) format "X(100)" at 99
        skip "М.П." at 15  "|" at 97 "М.П." at 99
    .

  { gbl/stopwork.i }

  output stream out-stream close.

  { rep/q-print.i 8}

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
      if line-counter( out-stream ) + v-char-counter > page-size( out-stream )  then do:
        put stream out-stream v-single-line format "x(198)" skip.
        display stream out-stream
          "Итого"           @ gds-prop.gds-name
           Pg-tqnty         @ gds-prop.qnty
           Pg-stoim-noNDS   @ gds-prop.stoim-noNDS
           Pg-VAT-gds       @ gds-prop.VAT-sum
           Pg-stoim         @ gds-prop.stoim
        with frame f-doc-m .
        down stream out-stream 1 with frame f-doc-m .
        PAGE stream out-stream.
        if page-number( out-stream ) > prevpage then  assign  Pg-tqnty = 0  Pg-VAT-gds = 0   Pg-stoim-noNDS = 0  Pg-stoim = 0   .
      end.
      assign
        gds-str1 = breakstr(gds-prop.gds-name, {&gds-len-m}, input-output gds-str1, input-output gds-str2)
      .
    end.
    else  assign gds-str1 = gds-prop.gds-name  .

    /*---E--------- Определили наименование товара -------------------*/

    display stream out-stream
      v-doc-line-counter
      gds-prop.artic
      gds-str1          @ gds-prop.gds-name
      string( gds-prop.b-code )   @ tb-code
      gds-prop.unit-base
      gds-prop.qnty
      gds-prop.price-noNDS
      gds-prop.stoim-noNDS
      gds-prop.VAT-pc
      gds-prop.VAT-sum
      gds-prop.stoim
      sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym19
    with frame f-doc-m.
    down stream out-stream 1 with frame f-doc-m.

    if FullGdsName then do:
      do while gds-str2 <> "" :
        assign
          gds-str = gds-str2
          gds-str1 = breakstr(gds-str, {&gds-len-m}, input-output gds-str1, input-output gds-str2)
        .
        display stream out-stream
          gds-str1 @ gds-prop.gds-name sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym19
        with frame f-doc-m .
        down stream out-stream 1 with frame f-doc-m .
      end. /* do while ... */
    end.

    assign
      v-line-counter     = v-line-counter + 1
      v-doc-line-counter = v-doc-line-counter + 1
      PrevPage = page-number( Out-Stream )
      Pg-tqnty       = Pg-tqnty       + gds-prop.qnty
      Pg-VAT-gds     = Pg-VAT-gds     + gds-prop.VAT-sum
      Pg-stoim-noNDS = Pg-stoim-noNDS + gds-prop.stoim-noNDS
      Pg-stoim       = Pg-stoim       + gds-prop.stoim
      all-tqnty       = all-tqnty       + gds-prop.qnty
      all-stoim-noNDS = all-stoim-noNDS + gds-prop.stoim-noNDS
      all-VAT-gds     = all-VAT-gds     + gds-prop.VAT-sum
      all-stoim       = all-stoim       + gds-prop.stoim
      all-sum         = all-sum         + gds-prop.sum
    .
    if line-counter( Out-Stream ) + 1 > page-size( Out-Stream ) then do:
      put stream out-stream v-single-line format "x(198)" skip.
      display stream out-stream
        "Итого"   @ gds-prop.gds-name
         Pg-tqnty @ gds-prop.qnty
         Pg-stoim-noNDS @ gds-prop.stoim-noNDS
         Pg-VAT-gds  @ gds-prop.VAT-sum
         Pg-stoim @ gds-prop.stoim
      with frame f-doc-m .
      down stream out-stream 1 with frame f-doc-m .
      if page-number( out-stream ) > prevpage then  assign  Pg-tqnty = 0  Pg-VAT-gds = 0   Pg-stoim-noNDS = 0  Pg-stoim = 0   .
    end.

  end.
end procedure. /* print-line */
/*---E-------- Печать линии в документе -----------------*/