block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: eff-move.p $
$Archive: rep/eff-move.p $

Печать акта формирования продажной цены

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

do
on error undo, return error
:

define input parameter parParentProc     AS WIDGET-HANDLE NO-UNDO.
define input parameter rec_id as recid no-undo .

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: eff-move.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/eff-move.p $":U .
define variable vss-description as character no-undo initial "Печать акта формирования продажной цены":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/library.i  }
{ rep/r-cost.i   }
{ rep/r-sale.i   }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/getsect.i  def }

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define variable g#quest-print as logical   no-undo .
  run get-quest-print in parParentProc ( output g#quest-print ).

  define variable g#log as logical   no-undo .

  define stream Out_stream .

  define shared variable sort-gr      as logical          no-undo.
  define shared variable sort-name    as logical          no-undo.

  define buffer buf_trn-doc  for trn-doc.
  define buffer buf_doc-line for doc-line .
  define buffer buf_goods    for goods .
  define buffer buf_clients  for clients .

  define variable sum-no-vat              as decimal     no-undo.
  define variable doc-sum                 as decimal     no-undo.
  define variable doc-price               as decimal     no-undo.
  define variable sum                     as decimal     no-undo.
  define variable price                   as decimal     no-undo.
  define variable nazen                   as decimal     no-undo.
  define variable eff                     as decimal     no-undo.
  define variable num                     as integer   no-undo .

  define variable sum1              as decimal     no-undo.
  define variable sum2              as decimal     no-undo.
  define variable sum3              as decimal     no-undo.
  define variable sum4              as decimal     no-undo.
  define variable sum5              as decimal     no-undo.

  define variable VAT-sum                 as decimal     no-undo.
  define variable b-code as integer   no-undo .
  define variable t-dec as decimal   no-undo .
  define variable v-sum-base    as decimal   no-undo .
  define variable v-sum-rubl    as decimal   no-undo .
  define variable v-vat-base    as decimal   no-undo .
  define variable v-vat-rubl    as decimal   no-undo .
  define variable v-sum-base1   as decimal   no-undo .
  define variable v-sum-rubl1   as decimal   no-undo .
  define variable v-vat-base1   as decimal   no-undo .
  define variable v-vat-rubl1   as decimal   no-undo .
  define variable v-vat-pc     like ub.doc-line.vat-pc         no-undo .

  define variable Line            as character        no-undo.

  define variable sym1  as character initial ":"   no-undo.
  define variable sym2  as character initial ":"   no-undo.
  define variable sym3  as character initial ":"   no-undo.
  define variable sym4  as character initial ":"   no-undo.
  define variable sym5  as character initial ":"   no-undo.
  define variable sym6  as character initial ":"   no-undo.
  define variable sym7  as character initial ":"   no-undo.
  define variable sym8  as character initial ":"   no-undo.
  define variable sym9  as character initial ":"   no-undo.
  define variable sym10 as character initial ":"   no-undo.
  define variable sym11 as character initial ":"   no-undo.
  define variable sym12 as character initial ":"   no-undo.
  define variable sym13 as character initial ":"   no-undo.
  define variable sym14 as character initial ":"   no-undo.
  define variable sym15 as character initial ":"   no-undo.
  define variable tb-code    as character             no-undo.

  define variable tdoc-date  like    trn-doc.doc-date no-undo.
  define variable tdoc-code  like trn-doc.doc-code    no-undo.

/*  define variable v-curr-r-b as character         no-undo.*/
/*  { gbl/curr-r-b.i v-curr-r-b }*/

  def buffer Our_Host for clients.

  define variable v-sort-prod             as character            no-undo.
  { gbl/getsect.i run "''" 0 {&attr-prt-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'sort-prd' then v-sort-prod = string( thbjattr_thbj-attr.property-value-logical) .
  end.

  DEFINE FRAME Akt
        sym1           column-label ":!:" format "X(1)" space(0)
        tb-code        column-label "Код! " format "x({&BarCode_Length})"
        sym2           column-label ":!:" format "X(1)" space(0)
        buf_goods.artic    column-label "Артикул! " format "X(16)"
        sym3           column-label ":!:" format "X(1)" space(0)
        buf_goods.gds-name column-label "Название товара! " format "X(36)"
        sym4           column-label ":!:" format "X(1)" space(0)
        buf_doc-line.fact-qnty           column-label "Количество ! " format ">>>>>>9.<<<"
        sym5           column-label ":!:" format "X(1)" space(0)
        price          column-label "Учет. цена!с НДС" format ">>>>>>9.99"
        sym6           column-label ":!:" format "X(1)" space(0)
        sum            column-label "Сумма в учет.!ценах с НДС" format ">>,>>>,>>9.99"
        sym7           column-label ":!:" format "X(1)" space(0)
        sum-no-vat     column-label "Сумма в учет.!ценах без НДС" format ">>,>>>,>>9.99"
        sym8           column-label ":!:" format "X(1)" space(0)
        doc-price      column-label "Цена по!докум." format ">>>>>>9.99"
        sym9           column-label ":!:" format "X(1)" space(0)
        doc-sum        column-label "Сумма по!докум." format ">>,>>>,>>9.99"
        sym10          column-label ":!:" format "X(1)" space(0)
        nazen          column-label "Торговая!наценка" format "->>>>9.<<%"
        sym11          column-label ":!:" format "X(1)" space(0)
        eff            column-label "Эффекти-!вность" format "->>>>>>>>9.99"
        sym12          column-label ":!:" format "X(1)" space(0)
        buf_doc-line.vat-pc column-label "Ставка!НДС" format ">>9.<<%"
        sym13          column-label ":!:" format "X(1)" space(0)
        VAT-sum        column-label "Сумма НДС от!цен док-та" format "->>>>>>>>9.99" space(0)
        sym14          column-label ":!:" format "X(1)" space(0)
    HEADER
            cur-time-print() AT 5 format "X(35)"
            string( "Эффективность движения товара по документу N " + tdoc-code + " от " + string( tdoc-date,"99/99/9999" ) ) AT 40 format "X(80)"
            ( if PrintRubl then "Цены и суммы указаны в {&abbr_rublyah}" else "Цены и суммы указаны в б.вал." ) format "X(30)"
            string( "Страница " + string( PAGE-NUMBER(Out_stream), ">>9") ) AT 164 format "X(15)" SKIP
        Line format "X(198)" AT 1
    with width {&DOS_CW} down stream-io.

  Line = fill("-", 200).
  FIND buf_trn-doc WHERE recid(buf_trn-doc) = rec_id  NO-LOCK.
  assign
    tdoc-date = buf_trn-doc.doc-date
    tdoc-code    = buf_trn-doc.doc-code
  .
  FIND Our_Host WHERE Our_Host.obj-type = {&cmp} AND Our_Host.obj-code = buf_trn-doc.host-code NO-LOCK.

/*  { cmp/open-out.i " " " " " " {&LS_PS_A4} }*/
  { cmp/open-out.i stream Out_stream  " " {&LS_PS_A4} }

  PUT stream Out_stream SPACE(90) Our_Host.obj-name format "x(40)" SKIP(2)
        SPACE(20) "Эффективность движения товара  по документу  N " format "x(50)"
        buf_trn-doc.doc-code format "X(10)" "  от  " buf_trn-doc.doc-date format "99.99.9999" SKIP(1).

  PUT stream Out_stream SPACE(20) string( "ПОКУПАТЕЛЬ : " + buf_trn-doc.cli-name ) format "x(90)" SKIP(1) .

  FORM HEADER
    Line format "X(198)" AT 1 SKIP  "Продолжение - на следующей странице" AT 30 SKIP
    with FRAME BottomFrame width {&DOS_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream Out_stream FRAME BottomFrame .

  form with frame Akt .

  assign num = 1 .
  /* печать строк */
  if v-sort-prod = "yes" then do:
    if sort-gr = yes then do:
      if sort-name = yes then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
          , first buf_goods no-lock
            where buf_goods.artic      = buf_doc-line.artic
              and buf_goods.prod-type  = buf_doc-line.prod-type
              and buf_goods.prod-code  = buf_doc-line.prod-code
          break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_goods.grp-name  by buf_goods.gds-name
        :
          if  first-of( buf_doc-line.prod-code) then do:
            run print-prod in this-procedure .
          end.
          if  first-of( buf_goods.grp-name) then do:
            run print-grp in this-procedure .
          end.
          run print-line in this-procedure .
        end.
      end.        /* sort-name = yes */
      else do:
        for each buf_doc-line
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
          , first buf_goods no-lock
            where buf_goods.artic      = buf_doc-line.artic
              and buf_goods.prod-type  = buf_doc-line.prod-type
              and buf_goods.prod-code  = buf_doc-line.prod-code
          break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_goods.grp-name  by buf_doc-line.num-place
        :
          if  first-of( buf_doc-line.prod-code) then do:
            run print-prod in this-procedure .
          end.
          if  first-of( buf_goods.grp-name) then do:
            run print-grp in this-procedure .
          end.
          run print-line in this-procedure .
        end.
      end.        /* sort-name <> yes */
    end.        /* sort-gr = yes */
    else do:
      if sort-name = yes then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
          , first buf_goods no-lock
          where buf_goods.artic      = buf_doc-line.artic
            and buf_goods.prod-type  = buf_doc-line.prod-type
            and buf_goods.prod-code  = buf_doc-line.prod-code
          break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_goods.gds-name
        :
          if  first-of( buf_doc-line.prod-code) then do:
            run print-prod in this-procedure .
          end.
          run print-line in this-procedure .
        end.
      end.        /* sort-name = yes */
      else do:
        for each buf_doc-line
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
          , first buf_goods no-lock
          where buf_goods.artic      = buf_doc-line.artic
              and buf_goods.prod-type  = buf_doc-line.prod-type
              and buf_goods.prod-code  = buf_doc-line.prod-code
          break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_doc-line.num-place
        :
          if  first-of( buf_doc-line.prod-code) then do:
            run print-prod in this-procedure .
          end.
          run print-line in this-procedure .
        end.
      end.        /* sort-name <> yes */
    end.        /* sort-gr <> yes */
  end.        /* sort-prod = yes */
  else do:
    if sort-gr = yes then do:
      if sort-name = yes then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
          , first buf_goods no-lock
            where buf_goods.artic      = buf_doc-line.artic
              and buf_goods.prod-type  = buf_doc-line.prod-type
              and buf_goods.prod-code  = buf_doc-line.prod-code
          break by buf_goods.grp-name  by buf_goods.gds-name
        :
          if  first-of( buf_goods.grp-name) then do:
            run print-grp in this-procedure .
          end.
          run print-line in this-procedure .
        end.
      end.        /* sort-name = yes */
      else do:
        for each buf_doc-line
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
          , first buf_goods no-lock
            where buf_goods.artic      = buf_doc-line.artic
              and buf_goods.prod-type  = buf_doc-line.prod-type
              and buf_goods.prod-code  = buf_doc-line.prod-code
          break by buf_goods.grp-name  by buf_doc-line.num-place
        :
          if  first-of( buf_goods.grp-name) then do:
            run print-grp in this-procedure .
          end.
          run print-line in this-procedure .
        end.
      end.        /* sort-name <> yes */
    end.        /* sort-gr = yes */
    else do:
      if sort-name = yes then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
          , first buf_goods no-lock
          where buf_goods.artic      = buf_doc-line.artic
            and buf_goods.prod-type  = buf_doc-line.prod-type
            and buf_goods.prod-code  = buf_doc-line.prod-code
          break by buf_goods.gds-name
        :
          run print-line in this-procedure .
        end.
      end.        /* sort-name = yes */
      else do:
        for each buf_doc-line
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
          , first buf_goods no-lock
          where buf_goods.artic      = buf_doc-line.artic
              and buf_goods.prod-type  = buf_doc-line.prod-type
              and buf_goods.prod-code  = buf_doc-line.prod-code
          break by buf_doc-line.num-place
        :
          run print-line in this-procedure .
        end.
      end.        /* sort-name <> yes */
    end.        /* sort-gr <> yes */
  end.        /* sort-prod = yes */

  PUT stream Out_stream  Line format "X(198)"   SKIP  .
    display stream out_stream            sym1   sym2  sym3
      "ИТОГО" @ buf_goods.gds-name       sym4
      sum1 @ buf_doc-line.fact-qnty      sym5   sym6
      sum2 @ sum                         sym7
      sum3 @  sum-no-vat                 sym8   sym9
      sum4 @ doc-sum                     sym10
      ((sum4 - sum2) * 100 / sum2)  @ nazen     sym11
      (sum4 - sum2) @ eff                sym12  sym13
      sum5 @ VAT-sum                     sym14
    with frame Akt.
    down stream out_stream with frame Akt .
  PUT stream Out_stream  Line format "X(198)"   SKIP(1)  .

  PUT stream Out_stream  SPACE(10) "Всего  " string(num,">>>>9")  " наименований." format "X(15)"  SKIP(1)  .
  PUT stream Out_stream  SPACE(20) "Зав. складом/Зав. секцией : " format "X(30)" .

  HIDE stream Out_stream  FRAME BottomFrame .
  output stream Out_stream close .

  { rep/q-print.i 8}
end.



procedure Print-prod :
  do on error undo, return error return-value :
    find first buf_clients where buf_clients.obj-type = buf_goods.prod-type and buf_clients.obj-code = buf_goods.prod-code no-lock .

    display stream out_stream sym1 "Производитель -" @ buf_goods.artic buf_clients.obj-name @ buf_goods.gds-name sym14 with frame Akt .
    down stream out_stream with frame Akt .
  end.
end procedure. /* Print-prod */



procedure print-grp :
  do on error undo, return error return-value :
    display stream out_stream sym1 "Группа -" @ buf_goods.artic buf_goods.grp-name @ buf_goods.gds-name sym14 with frame Akt .
    down stream out_stream with frame Akt .
  end.
end procedure. /* print-grp */



procedure print-line :
  do on error undo, return error return-value :

    { gbl/gdsbcode.i  buf_goods.gds-code  ?  b-code  no-error }
    if error-status :error then do:
      message vss-workfile vss-revision vss-description skip "Ошибка при определении бар-кода товара" skip  "Код товара" buf_goods.gds-code skip
      view-as alert-box error .
    end.
/*    if g#gds-engl then assign gds_name = buf_goods.engl-name.*/
/*    else               assign gds_name = buf_goods.gds-name.*/
    assign
      num = num + 1
      tb-code = string(b-code)
    .

    run r-cost in this-procedure ( input buf_doc-line.doc-code  ,input buf_doc-line.artic ,input buf_doc-line.prod-type
              ,input buf_doc-line.prod-code  ,output t-dec       ,output v-vat-pc   ,output t-dec
              ,output v-sum-base             ,output v-sum-rubl  ,output v-vat-base ,output v-vat-rubl
              ,output t-dec                  ,output t-dec       ,output t-dec      ,output t-dec
              ,output t-dec   ,output t-dec  ,output t-dec       ,output t-dec      ,output t-dec   ,output t-dec ) no-error .
    run r-sale in this-procedure ( input buf_doc-line.doc-code  ,input buf_doc-line.artic ,input buf_doc-line.prod-type
              ,input buf_doc-line.prod-code  ,output t-dec       ,output v-vat-pc   ,output t-dec
              ,output v-sum-base1            ,output v-sum-rubl1 ,output v-vat-base1 ,output v-vat-rubl1
              ,output t-dec                  ,output t-dec  ,output t-dec      ,output t-dec
              ,output t-dec   ,output t-dec  ,output t-dec       ,output t-dec      ,output t-dec   ,output t-dec ) no-error .


    if PrintRubl then
      assign
        price      = - v-sum-rubl / buf_doc-line.fact-qnty
        sum        = - v-sum-rubl
        sum-no-vat = - (v-sum-rubl - v-vat-rubl)
        doc-price  = - v-sum-rubl1 / buf_doc-line.fact-qnty
        doc-sum    = - v-sum-rubl1
        VAT-sum    = - v-vat-rubl1
      .
    else
      assign
        price      = - v-sum-base / buf_doc-line.fact-qnty
        sum        = - v-sum-base
        sum-no-vat = - (v-sum-base - v-vat-base)
        doc-price  = - v-sum-base1 / buf_doc-line.fact-qnty
        doc-sum    = - v-sum-base1
        VAT-sum    = - v-vat-base1
      .
    assign
      eff   = doc-sum - sum
      nazen = eff * 100 / sum
      sum1 = sum1 + buf_doc-line.fact-qnty
      sum2 = sum2 + sum
      sum3 = sum3 + sum-no-vat
      sum4 = sum4 + doc-sum
      sum5 = sum5 + VAT-sum
    .

    display stream out_stream
      sym1 tb-code  sym2 buf_goods.artic sym3 buf_goods.gds-name sym4 buf_doc-line.fact-qnty sym5
       price        sym6
       sum          sym7
       sum-no-vat   sym8
       doc-price    sym9
       doc-sum      sym10
       nazen        sym11
       eff          sym12
       buf_doc-line.vat-pc sym13
       VAT-sum      sym14
    with frame Akt.
    down stream out_stream with frame Akt .
  end.
end procedure. /* print-line */