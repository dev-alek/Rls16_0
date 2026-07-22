block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-torg2.p $
$Archive: rep/r-torg2.p $

Печатные формы. Торг-2 для возврата поставщику

Автор: Демин Алексей Сергеевич
Дата создания: 04/13/06
Author: Alexey Demin
Creation date: 04/13/06

*/

define input parameter parParentProc     AS WIDGET-HANDLE NO-UNDO.
define input parameter rec_id       as recid      no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-torg2.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-torg2.p $":U .
define variable vss-description as character no-undo initial "Печатные формы. Торг-2 для возврата поставщику":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/r-pril.i   }
{ gbl/cur-time.i }
{ rep/fmtcli.i   }
{ gbl/clntattr.i }
{ str/trdcalib.i }
{ rep/torgconf.i }
{ gbl/paramls.i  }

do
on error undo, return error
:
define buffer t-doc             for trn-doc.
define buffer buf_gds-dtl      for gds-dtl.
define buffer buf_goods         for goods.
define buffer buf_clients       for clients .
define buffer buf_firm          for firm.
define buffer buf_sysconf       for sysconf.
define buffer buf_currency      for currency .

define stream out-stream .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define variable g#quest-print as logical   no-undo .
  run get-quest-print in parParentProc ( output g#quest-print ).

  define variable g#log as logical   no-undo .

define shared var sort-name    as logical                          no-undo.
define shared var sort-gr      as logical                          no-undo.

define variable v-par-type                  as character                no-undo.
define variable v-curr-code                 as integer                  no-undo.
/*define variable v-osnov      as character no-undo .*/
/*define variable v-chet-fact  as character no-undo .*/
/*define variable v-contract   as character no-undo .*/
/*define variable v-attr-value as character no-undo .*/
/*define variable v-attr-type  as character no-undo .*/
define variable all-qnty as decimal   no-undo .
define variable all-sum as decimal   no-undo .

define variable v-propis       as char              no-undo.
define variable v-propis-cop       as char              no-undo.
define variable v-itog as decimal no-undo .
define variable v-num as integer   no-undo .

define variable v-single-line       as char              no-undo.
define variable v-underline         as char              no-undo.
assign
  v-single-line = fill("-", 230)
  v-underline = fill("_", 230)
.

  find first t-doc no-lock where recid( t-doc ) = rec_id .

  find first buf_currency no-lock where buf_currency.curr-code = t-doc.exch-code no-error .
  if not available buf_currency then do:
    undo, return error substitute("Не найдена валюта &1", t-doc.exch-code) .
  end.
  define variable str-curr as character no-undo .
  assign str-curr = string(buf_currency.curr-abbr,"x(8)") .

  define variable v-sort-prod             as character            no-undo.
  { gbl/getsect.i run "''" 0 {&attr-prt-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'sort-prd' then v-sort-prod = string( thbjattr_thbj-attr.property-value-logical) .
  end.


  run torgconf-read in this-procedure ( input "torg2", input t-doc.host-code, input t-doc.obj-type, input t-doc.obj-code) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description    skip "Ошибка чтения параметров печати формы."
      skip "Форма будет напечатана с параметрами по умолчанию."    skip return-value
      skip trim(error-status :get-message(1))    trim(error-status :get-message(2))    trim(error-status :get-message(3))
    view-as alert-box error.
  end.
  run torgconf-get-self-param in this-procedure ( input t-doc.obj-type, input t-doc.obj-code, input v-curr-code) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description    skip "Ошибка чтения параметров объекта документа."
      skip return-value    skip trim(error-status :get-message(1))
      trim(error-status :get-message(2))     trim(error-status :get-message(3))
    view-as alert-box warning.
  end.
  run torgconf-get-cli-param in this-procedure ( input t-doc.host-code, input t-doc.cli-type, input t-doc.cli-code, input v-curr-code) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description    skip "Ошибка чтения параметров объекта клиента документа."
      skip return-value    skip trim(error-status :get-message(1))    trim(error-status :get-message(2))  trim(error-status :get-message(3))
    view-as alert-box warning.
  end.
  run torgconf-get-form-header in this-procedure (
          input no
        , input t-doc.doc-code
        , input "no"
        , input t-doc.doc-date
        , input t-doc.fact-date
        , input t-doc.doc-type
        , input t-doc.status_
        , input no
        , input no
    ).

  if v-torgconf-outappr = yes  then do:
    put stream out-stream  "Утверждена постановлением Госкомстата России от 25.12.98 N 132" at 87 .
  end.

  { gbl/working.i }
  { cmp/open-out.i stream out-stream " "  }

  define variable v-operation-type    as character    no-undo.
  assign  v-operation-type = " " .

  put stream out-stream
        space(5) v-single-line          format  "X(19)"     at 110 skip
        space(5) "| "  at 110    {&g___code}  at 118   "|"  at 128 skip
        space(5) "Форма по ОКУД"   format "X(14)"  at 95 "| " at 110  "0330202"  "|"   at 128 skip
        string(v-torgconf-self-host-name  + ", " + v-torgconf-self-host-post-addres)    format "X(96)" "по ОКПО" format "X(7)" at 102  "| " at 110  v-torgconf-okpo  format "X(16)" "|" at 128 skip
        string( caps( v-torgconf-self-obj-name)  + " (" + string(v-torgconf-self-obj-code) + ")") format "X(104)" "| "  at 110  "|"  at 128 skip
        space(5) "Вид деятельности по ОКДП" format "X(25)"  at 84   "| "  at 110  "|"  at 128 skip
        space(5) string( "Основание для составления акта ______________приказ, распоряжение________ " ) format "X(75)"
                        "номер" format "X(5)" at 104 "| " at 110 v-torgconf-doc-code format "X(16)" "|" at 128 skip
        space(5) "дата" format "X(4)" at 105 "| " at 110 v-torgconf-doc-date format "X(10)" "|" at 128 skip
        space(5) "Вид операции"   format "X(12)"    at 97  "| "  at 110  v-operation-type format "X(16)"  "|" at 128 skip
        space(5) v-single-line format  "X(19)" at 110 skip
    .

/*  { str/tdat-val.i t-doc.doc-code {&trdcattr-nids} v-attr-value v-attr-type }*/
/*  if v-attr-value > "" then assign v-osnov = "накладная " + v-attr-value .*/
/*  { str/tdat-val.i t-doc.doc-code {&trdcattr-dids} v-attr-value v-attr-type }*/
/*  if v-attr-value > "" then assign v-osnov = v-osnov + " от " + v-attr-value .*/
/*  { str/tdat-val.i t-doc.doc-code {&trdcattr-nsf}  v-attr-value v-attr-type }*/
/*  assign v-chet-fact = v-attr-value .*/
/*  { str/tdat-val.i t-doc.doc-code {&trdcattr-dsf}  v-attr-value v-attr-type }*/
/*  assign v-chet-fact = v-chet-fact + " от " + v-attr-value .*/
/*  { str/tdat-val.i t-doc.doc-code {&trdcattr-ndog} v-attr-value v-attr-type }*/
/*  assign v-contract = v-attr-value .*/
/*  { str/tdat-val.i t-doc.doc-code {&trdcattr-ddog} v-attr-value v-attr-type }*/
/*  assign v-contract = v-contract + " от " + v-attr-value .*/

  put stream out-stream
          "УТВЕРЖДАЮ Руководитель" format "X(23)" at 105 skip
        space(50) v-single-line format "X(33)"  space(10)  v-underline format "X(33)" skip
        space(44) string( "А К Т | " + string( v-torgconf-doc-code, "X(16)") + "| "
                                     + string( v-torgconf-doc-date, "X(12)")
                                     + "| " + (if t-doc.status_ <> {&fact} then string( "(" + CAPS(t-doc.status_) + ")" ) else "")
                                    ) format "X(50)"  skip
        space(50) v-single-line format "X(33)"  space(10)  v-underline format "X(15)" space(3)  v-underline format "X(15)"  skip
        space(35) "ОБ УСТАНОВЛЕННОМ РАСХОЖДЕНИИ ПО КОЛИЧЕСТВУ"   skip
        space(25) "И КАЧЕСТВУ ПРИ ПРИЕМКЕ ТОВАРНО-МАТЕРИАЛЬНЫХ ЦЕННОСТЕЙ"   space(15) '"____"'  space(3)  v-underline format "X(15)"  space(3)  v-underline format "X(5)" "г."  skip(2)
        "Поставщик товара " format "X(18)"  v-torgconf-cli-name format "X(110)" skip
        'Настоящий акт составлен комиссией, которая установила, что ниже перечисленный товар имеет '  skip
        'ненадлежащее качество ( ________________________ ), вследствие чего его следует возвратить:'  skip
  .


  put stream out-stream
        v-single-line          format  "X(130)"    skip
               "|  №  |                   Наименование товара                 |Един|  Количество  |      Цена      |       Сумма        |Причина | "     format  "X(130)"    skip
        string("| п/п |                                                       |изм.|   (Масса)    |       " + str-curr + " |        " + str-curr + "    |возврата|")     format  "X(130)"    skip
        v-single-line          format  "X(130)"    skip
  .

  run for-each in this-procedure  .

  if line-counter( out-stream ) + 7 > page-size( out-stream ) then page stream out-stream.

  put stream out-stream
        "    Заключение комиссии: Вернуть некачественный товар поставщику"       format  "X(130)"    skip
        "    ПРИЛОЖЕНИЕ: возвратная, приходная накладная № ____________ от <_____> ______________ 20____ г."       format  "X(130)"    skip
        "                возвратная, приходная накладная № ____________ от <_____> ______________ 20____ г."       format  "X(130)"    skip
        "                возвратная, приходная накладная № ____________ от <_____> ______________ 20____ г."       format  "X(130)"    skip
        "                возвратная, приходная накладная № ____________ от <_____> ______________ 20____ г."       format  "X(130)"    skip
        "                возвратная, приходная накладная № ____________ от <_____> ______________ 20____ г."       format  "X(130)"    skip
        "    Члены комиссии предупреждены об ответственности за подписание акта, содержащего данные, не соответствующие действительности."       format  "X(130)"    skip
  .
  if line-counter( out-stream ) + 4 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
        "Председатель комиссии         ___________________________    _____________   _________________________"       format  "X(130)"    skip
        "Члены комиссии                ___________________________    _____________   _________________________"       format  "X(130)"    skip
        "                              ___________________________    _____________   _________________________"       format  "X(130)"    skip
        "                              ___________________________    _____________   _________________________"       format  "X(130)"    skip
  .
  if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
  put stream out-stream
        "Представитель поставщика      ___________________________    _____________   _________________________"       format  "X(130)"    skip
        "Решение руководителя: Вернуть некачественный товар поставщику "       format  "X(130)"    skip
  .

  { gbl/stopwork.i }
  output stream out-stream close.

  { rep/q-print.i 0}

end.



procedure for-each :
  do on error undo, return error return-value :
    if v-sort-prod = "yes" then do:
      if sort-gr = yes then do:
        if sort-name = yes then do:
          for each buf_gds-dtl no-lock
            where buf_gds-dtl.doc-code = t-doc.doc-code
            , first buf_goods no-lock
              where buf_goods.artic      = buf_gds-dtl.artic
                and buf_goods.prod-type  = buf_gds-dtl.prod-type
                and buf_goods.prod-code  = buf_gds-dtl.prod-code
            break by buf_gds-dtl.prod-type by buf_gds-dtl.prod-code by buf_goods.grp-name  by buf_goods.gds-name
          :
            if  first-of( buf_gds-dtl.prod-code) then do:
              run print-prod in this-procedure .
            end.
            if  first-of( buf_goods.grp-name) then do:
              run print-grp in this-procedure .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name = yes */
        else do:
          for each buf_gds-dtl
            where buf_gds-dtl.doc-code = t-doc.doc-code
            , first buf_goods no-lock
              where buf_goods.artic      = buf_gds-dtl.artic
                and buf_goods.prod-type  = buf_gds-dtl.prod-type
                and buf_goods.prod-code  = buf_gds-dtl.prod-code
            break by buf_gds-dtl.prod-type by buf_gds-dtl.prod-code by buf_goods.grp-name  by buf_gds-dtl.artic
          :
            if  first-of( buf_gds-dtl.prod-code) then do:
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
          for each buf_gds-dtl no-lock
            where buf_gds-dtl.doc-code = t-doc.doc-code
            , first buf_goods no-lock
            where buf_goods.artic      = buf_gds-dtl.artic
              and buf_goods.prod-type  = buf_gds-dtl.prod-type
              and buf_goods.prod-code  = buf_gds-dtl.prod-code
            break by buf_gds-dtl.prod-type by buf_gds-dtl.prod-code by buf_goods.gds-name
          :
            if  first-of( buf_gds-dtl.prod-code) then do:
              run print-prod in this-procedure .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name = yes */
        else do:
          for each buf_gds-dtl
            where buf_gds-dtl.doc-code = t-doc.doc-code
            , first buf_goods no-lock
            where buf_goods.artic      = buf_gds-dtl.artic
                and buf_goods.prod-type  = buf_gds-dtl.prod-type
                and buf_goods.prod-code  = buf_gds-dtl.prod-code
            break by buf_gds-dtl.prod-type by buf_gds-dtl.prod-code by buf_gds-dtl.artic
          :
            if  first-of( buf_gds-dtl.prod-code) then do:
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
          for each buf_gds-dtl no-lock
            where buf_gds-dtl.doc-code = t-doc.doc-code
            , first buf_goods no-lock
              where buf_goods.artic      = buf_gds-dtl.artic
                and buf_goods.prod-type  = buf_gds-dtl.prod-type
                and buf_goods.prod-code  = buf_gds-dtl.prod-code
            break by buf_goods.grp-name  by buf_goods.gds-name
          :
            if  first-of( buf_goods.grp-name) then do:
              run print-grp in this-procedure .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name = yes */
        else do:
          for each buf_gds-dtl
            where buf_gds-dtl.doc-code = t-doc.doc-code
            , first buf_goods no-lock
              where buf_goods.artic      = buf_gds-dtl.artic
                and buf_goods.prod-type  = buf_gds-dtl.prod-type
                and buf_goods.prod-code  = buf_gds-dtl.prod-code
            break by buf_goods.grp-name  by buf_gds-dtl.artic
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
          for each buf_gds-dtl no-lock
            where buf_gds-dtl.doc-code = t-doc.doc-code
            , first buf_goods no-lock
            where buf_goods.artic      = buf_gds-dtl.artic
              and buf_goods.prod-type  = buf_gds-dtl.prod-type
              and buf_goods.prod-code  = buf_gds-dtl.prod-code
            break by buf_goods.gds-name
          :
            run print-line in this-procedure .
          end.
        end.        /* sort-name = yes */
        else do:
          for each buf_gds-dtl
            where buf_gds-dtl.doc-code = t-doc.doc-code
            , first buf_goods no-lock
            where buf_goods.artic      = buf_gds-dtl.artic
                and buf_goods.prod-type  = buf_gds-dtl.prod-type
                and buf_goods.prod-code  = buf_gds-dtl.prod-code
            break by buf_gds-dtl.artic
          :
            run print-line in this-procedure .
          end.
        end.        /* sort-name <> yes */
      end.        /* sort-gr <> yes */
    end.        /* sort-prod = yes */
    put stream out-stream   v-single-line  format  "X(130)"    skip
      "|  ИТОГО "                   format  "X(67)"
      "|"  all-qnty   format ">>>>>,>>>,>>9.<<<"
      "|"
      "|" at 100 all-sum  format ">,>>>,>>>,>>>,>>9.99"
      "|" "|" at 130
    skip
    v-single-line  format  "X(130)"
    skip .
  end.
end procedure. /* for-each */



procedure Print-prod :
  do on error undo, return error return-value :
    if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
    find first buf_clients where buf_clients.obj-type = buf_goods.prod-type and buf_clients.obj-code = buf_goods.prod-code no-lock .
    put stream out-stream "| Производитель - " format "X(18)"  buf_clients.obj-name   format  "X(110)"  "|" at 130 skip .
  end.
end procedure. /* Print-prod */



procedure print-grp :
  do on error undo, return error return-value :
    if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.
    put stream out-stream "| Группа - " format "X(11)"  buf_goods.grp-name   format  "X(118)"  "|" at 130 skip .
  end.
end procedure. /* print-grp */



procedure print-line :
  do on error undo, return error return-value :
    if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.

    assign
      v-num = v-num + 1
      all-qnty  = all-qnty + buf_gds-dtl.fact-qnty
      all-sum   = all-sum  + if t-doc.exch-code = 0 then buf_gds-dtl.price-rubl * buf_gds-dtl.fact-qnty else buf_gds-dtl.price-base * buf_gds-dtl.fact-qnty
    .
    put stream out-stream
      "|"  v-num                    format ">>>>9"
      "|"  buf_goods.gds-name       format  "X(55)"
      "|"  buf_goods.unit-base      format  "X(4)"
      "|"  buf_gds-dtl.fact-qnty   format ">>>>>,>>>,>>9.<<<"
      "|"  if t-doc.exch-code = 0 then buf_gds-dtl.price-rubl else buf_gds-dtl.price-base  format ">,>>>,>>>,>>9.99"
      "|"  if t-doc.exch-code = 0 then buf_gds-dtl.price-rubl * buf_gds-dtl.fact-qnty else buf_gds-dtl.price-base * buf_gds-dtl.fact-qnty  format ">,>>>,>>>,>>>,>>9.99"
      "|" "|" at 130
    skip .
  end.
end procedure. /* print-line */