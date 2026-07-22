block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-inpzum.p $
$Archive: rep/r-inpzum.p $

Документ прихода (старый)

Автор: Демин Алексей Сергеевич
Дата создания: 04/12/06
Author: Alexey Demin
Creation date: 04/12/06

Input:

Output:

*/

do
on error undo, return error
:
  define input parameter p-mainmenu-handle  as handle           no-undo.
  define input parameter rec_id             as recid            no-undo.

  define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
  define variable vss-author      as character no-undo initial "$Author: expertek $":U .
  define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
  define variable vss-workfile    as character no-undo initial "$Workfile: r-inpzum.p $":U .
  define variable vss-archive     as character no-undo initial "$Archive: rep/r-inpzum.p $":U .
  define variable vss-description as character no-undo initial "Документ прихода (старый)":U .

  { cmp/vssrevis.i    }
  { cmp/str-glbl.i    }
  { cmp/library.i     }
  { cmp/r-pril.i      }
  { cmp/breakstr.i    }
  { rep/fmtcli.i      }
  { gbl/clntattr.i    }
  { str/trdcalib.i    }
  { rep/torgconf.i    }
  { rep/r-cost.i      }
  { rep/r-sale.i      }
  { gbl/getcntxt.i def }

define variable type-par1 as character no-undo .
define variable tmp-var1  as character no-undo .
define variable in-cur-rate as logical no-undo .
define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable g#gds-engl      as logical      no-undo.
define variable g#inp-jewel     as logical      no-undo.
define variable v-base-code     as integer      no-undo.
define variable store-type      as character    no-undo.
define variable store-code      as integer      no-undo.
define variable varr-b as character no-undo.

{ gbl/curr-r-b.i varr-b }

{ gbl/getcntxt.i get " " p-mainmenu-handle }
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).
run get-gds-engl in p-mainmenu-handle (
    output g#gds-engl
).
run get-inp-jewel in p-mainmenu-handle (
    output g#inp-jewel
).
assign
    store-type = v-cntxt-obj-type
    store-code = v-cntxt-obj-code
.
{ gbl/basecode.i
    v-cntxt-host-code-obj
    v-base-code
}


{ gbl/getsect.i run v-cntxt-obj-type v-cntxt-obj-code {&attr-prt-firm} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'incurrat' then in-cur-rate =  thbjattr_thbj-attr.property-value-logical .
end.

define variable v-sort-prod             as character            no-undo.
{ gbl/getsect.i run "''"  0 {&attr-prt-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'sort-prd' then v-sort-prod = string( thbjattr_thbj-attr.property-value-logical) .
end.


  DEFINE temp-table temp-nalog no-undo
    field   slt-prc          as  decimal
    field   vat-prc          as  decimal
    field   slt-sum          as  decimal
    field   vat-sum          as  decimal
    INDEX pi  IS PRIMARY   vat-prc slt-prc
  .

  define stream Out_stream .

  define shared variable CostPrice    as logical          no-undo .
  define shared variable PrintScale   as logical          no-undo.
  define shared variable sort-gr      as logical          no-undo.
  define shared variable sort-name    as logical          no-undo.

  define variable goods_PS        as char    no-undo.
  define variable goods_PS1       as char    no-undo.
  define variable goods_PS2       as char    no-undo.

  define buffer buf_trn-doc  for trn-doc.
  define buffer buf_clients  for clients.
  define buffer Our_Object   for clients.
  define buffer Our_Host     for clients.
  define buffer buf_goods    for goods.
  define buffer buf_doc-line for doc-line.
  define buffer buf_gds-dtl  for gds-dtl.

  define variable LogRes              as logical   init no    no-undo.
  define variable s1                  as character            no-undo.
  define variable s2                  as character            no-undo.
  define variable v-doc-code          as character            no-undo.
  define variable v-doc-date-string   as character            no-undo.

  define variable v-root-node as integer   no-undo .
  define variable empty-scale as logical   no-undo .
  define variable b-code      as integer   no-undo .

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

  define variable Line     as  char      no-undo.

  define variable Lines_Counter as integer     no-undo.
  define variable tb-code      as  char        no-undo.
  define variable gds_name     like goods.gds-name .
  define variable Price        as  decimal     no-undo.
  define variable qnty         as  decimal     no-undo.
  define variable stoim        as  decimal     no-undo.
  define variable Up-fact      as  decimal     no-undo .
  define variable SLT-sum      as  decimal     no-undo.
  define variable VAT-sum      as  decimal     no-undo.

  define variable all-qnty         as  decimal     no-undo.
  define variable all-stoim        as  decimal     no-undo.

  define variable t-dec        as decimal   no-undo .
  define variable v-sum-base   as decimal   no-undo .
  define variable v-sum-rubl   as decimal   no-undo .
  define variable v-slt-base   as decimal   no-undo .
  define variable v-slt-rubl   as decimal   no-undo .
  define variable v-vat-base   as decimal   no-undo .
  define variable v-vat-rubl   as decimal   no-undo .
  define variable v-vat-pc     like ub.doc-line.vat-pc         no-undo .
  define variable v-slt-pc     like ub.doc-line.slt-pc         no-undo .
  define variable stemp as char init " "   no-undo.

  define variable Rubl_Coeff              as decimal              no-undo.
  define variable rate                    as decimal              no-undo.
  define variable Mngr_name       as char    no-undo.
  define variable Wrkr_name       as char    no-undo.
  define variable Isp_name        as char    no-undo.
  define variable Log-Res         as logical no-undo .
  define variable num-form        as integer   no-undo .
  define variable i as integer   no-undo .

&scop Size-form 134

  define frame AKT
    sym1 column-label ":!:" format "X(1)" space(0)
    Lines_Counter column-label "N!п/п" format ">>>>9" space(0)
    sym2 column-label ":!:" format "X(1)" space(0)
    tb-code column-label "Код! " format "x({&BarCode_Length})"
    sym3 column-label ":!:" format "X(1)" space(0)
    buf_goods.artic column-label "Артикул! " format "X(16)"
    sym4 column-label ":!:" format "X(1)" space(0)
    gds_name column-label "Название товара! " format "X(40)"
    sym5 column-label ":!:" format "X(1)"
    buf_goods.unit-base column-label "Един.!изм." format "X(5)"
    sym6 column-label ":!:" format "X(1)"
    Price column-label "Фактическое!    количество" format ">>,>>>,>>9.<<<"
    sym7 column-label ":!:" format "X(1)"
    qnty column-label "Колич-во по!контракту" format ">>>>>>9.<<<"
    sym8 column-label ":!:" format "X(1)"
    stoim column-label "Несоответствие!(в ед. измер.)" format "->>>,>>>,>>9.99"
    sym9 column-label ":!:" format "X(1)"
   header
      string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) at 5 format "X(35)"
      string( "Приходный акт " + " N " + v-doc-code + " от " +  v-doc-date-string ) at 50 format "X(65)"
      string( "Страница " + string( PAGE-NUMBER(Out_stream), ">>9") ) at 120 format "X(13)" skip   Line format "X(136)" at 1
  with width {&A4_CW} down stream-io.


  define frame rubl
    sym1 column-label ":!:" format "X(1)" space(0)
    Lines_Counter column-label "N!п/п" format ">>>>9" space(0)
    sym2 column-label ":!:" format "X(1)" space(0)
    tb-code column-label "Код! " format "x({&BarCode_Length})"
    sym3 column-label ":!:" format "X(1)" space(0)
    buf_goods.artic column-label "Артикул! " format "X(16)"
    sym4 column-label ":!:" format "X(1)" space(0)
    gds_name column-label "Название товара! " format "X(38)" space(0)
    sym5 column-label ":!:" format "X(1)" space(0)
    buf_goods.unit-base column-label "Един.!изм." format "X(5)" space(0)
    sym6 column-label ":!:" format "X(1)" space(0)
    Price column-label "Цена за ед.! ({&abbr_rub_allshift})" format ">>>,>>>,>>9.99"  space(0)
    sym7 column-label ":!:" format "X(1)" space(0)
    qnty   column-label "Количество ! " format ">>>>>>9.<<<" space(0)
    sym8 column-label ":!:" format "X(1)" space(0)
    stoim column-label "Стоимость! ({&abbr_rub_allshift})" format  ">>,>>>,>>>,>>9.99"  space(0)
    sym9 column-label ":!:" format "X(1)" space(0)
    Up-fact column-label "Наценка! (%) " format "->>>9.99" space(0)
    sym10 column-label ":!:" format "X(1)"
    header
        string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) at 5 format "X(35)"
        string( "Приходная накладная " + " N " + v-doc-code + " от " + v-doc-date-string ) at 45 format "X(70)"
        string( "Страница " + string( PAGE-NUMBER(Out_stream), ">>9") ) at 120 format "X(13)" skip
        Line format "X(136)" at 1
  with width {&A4_CW} down stream-io no-box.

    define frame Zum-rubl
        sym1 column-label ":!:" format "X(1)" space(0)
        Lines_Counter column-label "N!п/п" format ">>>>9" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
        buf_goods.artic column-label "Артикул! " format "X(16)"
        sym3 column-label ":!:" format "X(1)" space(0)
        gds_name column-label "Название товара! " format "X(40)"
        sym4 column-label ":!:" format "X(1)" space(0)
        buf_clients.obj-name column-label "Производитель! " format "X(18)"
        sym5 column-label ":!:" format "X(1)" space(0)
        buf_goods.unit-base column-label "Един.!изм." format "X(5)" space(0)
        sym6 column-label ":!:" format "X(1)" space(0)
        Price column-label "Цена за ед.! ({&abbr_rub_allshift})" format ">>>,>>>,>>9.99" space(0)
        sym7 column-label ":!:" format "X(1)" space(0)
        qnty column-label "Количество ! " format ">>>>>>9.<<<" space(0)
        sym8 column-label ":!:" format "X(1)" space(0)
        stoim column-label "Стоимость! ({&abbr_rub_allshift})" format  "->>>,>>>,>>9.99" space(0)
        sym9 column-label ":!:" format "X(1)"
    header
        string( "Приходная накладная " + " N " + v-doc-code  + " от " + v-doc-date-string ) at 45 format "X(70)"
        string( "Страница " + string( PAGE-NUMBER(Out_stream), ">>9") ) at 120 format "X(13)" skip  Line format "X(136)" at 1
    with width {&A4_CW} down stream-io no-box.

define frame Zum-jew
        sym1  column-label ":!:" format "X(1)" space(0)
        Lines_Counter column-label "N!п/п" format ">>>>9" space(0)
        sym2  column-label ":!:" format "X(1)" space(0)
        buf_goods.artic column-label "Артикул! " format "X(16)"
        sym3  column-label ":!:" format "X(1)" space(0)
        gds_name column-label "Название товара! " format "X(40)"
        sym4  column-label ":!:" format "X(1)"
        buf_goods.unit-base column-label "Един.!изм." format "X(5)"
        sym5  column-label ":!:" format "X(1)"
        Price column-label "Цена за ед.! ({&abbr_rub_allshift})" format ">>>,>>>,>>9.99"
        sym6  column-label ":!:" format "X(1)"
        qnty  column-label "Количество ! " format ">>>>>>9.<<<"
        sym7  column-label ":!:" format "X(1)" space(0)
        stemp column-label "    шт! " format "x({&BarCode_Length})" space(0)
        sym8  column-label ":!:" format "X(1)"
        stoim column-label "Стоимость! ({&abbr_rub_allshift})" format  ">,>>>,>>>,>>9.99"
        sym9  column-label ":!:" format "X(1)"
    header
        string( "Приходная накладная " + " N " + v-doc-code + " от " + v-doc-date-string ) at 45 format "X(70)"
        string( "Страница " + string( PAGE-NUMBER(Out_stream), ">>9") ) at 120 format "X(13)" skip Line format "X(136)" at 1
    with width {&A4_CW} down stream-io no-box.


  find first buf_trn-doc no-lock where recid( buf_trn-doc ) = rec_id  .



  define variable v-host-code             as integer              no-undo.
  { gbl/hostcode.i buf_trn-doc.obj-type buf_trn-doc.obj-code v-host-code }
  run torgconf-read in this-procedure ( input "oldinp", input v-host-code, input buf_trn-doc.obj-type, input buf_trn-doc.obj-code) no-error.
  if error-status :error
  then do:
    message   vss-workfile vss-revision vss-description  skip "Ошибка чтения параметров печати формы." skip "Форма будет напечатана с параметрами по умолчанию."
      skip return-value  skip trim(error-status :get-message(1)) trim(error-status :get-message(2)) trim(error-status :get-message(3))
    view-as alert-box error.
  end.
  if v-torgconf-outnum = yes then  assign v-doc-code = fill( " ", 10 )  .
  else                             assign v-doc-code = buf_trn-doc.doc-code .

  if v-torgconf-outdate = yes then assign v-doc-date-string = fill( " ", 10 )  .
  else                             assign v-doc-date-string = string( buf_trn-doc.doc-date, "99.99.9999" )  .

  if session:set-wait-state("compiler") then.

  Line = fill("-", 200) .
  Lines_Counter = 0 .

  if in-cur-rate
  then do:
    find last curr-accnt no-lock where curr-accnt.curr-code = v-base-code and curr-accnt.exch-date <= today no-error .
    find last curr-shop no-lock
      where curr-shop.curr-code = v-base-code
        and curr-shop.obj-code  = store-code
        and curr-shop.obj-type  = store-type
      use-index pi  no-error .
    if store-type = {&shop}
    then do:
      if available curr-shop  then assign rate = curr-shop.exch-rate / curr-shop.exch-scale .
    end.
    else do:
      if available curr-accnt then assign rate = curr-accnt.exch-rate / curr-accnt.exch-scale .
    end.
    assign Rubl_Coeff = rate.
  end.
  else assign Rubl_Coeff = buf_trn-doc.base-rate / buf_trn-doc.base-scale.

  find Our_Object  where Our_Object.obj-type  = buf_trn-doc.obj-type and Our_Object.obj-code  = buf_trn-doc.obj-code  no-lock.
  find Our_Host    where Our_Host.obj-type    = {&cmp}               and Our_Host.obj-code    = buf_trn-doc.host-code no-lock.
  find buf_clients where buf_clients.obj-type = buf_trn-doc.cli-type and buf_clients.obj-code = buf_trn-doc.cli-code  no-lock .

  if can-do({&fact}, buf_trn-doc.status_ )
  or ( can-do({&wayb}, buf_trn-doc.status_) and buf_trn-doc.flag_ )
  then do:
    if buf_trn-doc.internal then assign num-form = 2 .   /* внутреннее перемещение */
    else do:
      if g#inp-jewel then assign num-form = 4 .
      else                assign num-form = 3 .
    end.
  end.
  else  assign num-form = 1 .

  { cmp/open-out.i stream Out_stream }

  run print-titul in this-procedure .

  /* печать строк */
  if v-sort-prod = "yes"
  then do:
    if sort-gr = yes
    then do:
      if sort-name = yes
      then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
          , first buf_goods no-lock
            where buf_goods.artic      = buf_doc-line.artic
              and buf_goods.prod-type  = buf_doc-line.prod-type
              and buf_goods.prod-code  = buf_doc-line.prod-code
          break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_goods.grp-name  by buf_goods.gds-name
        :
          if  first-of( buf_doc-line.prod-code)
          then do:
            run print-prod in this-procedure .
          end.
          if  first-of( buf_goods.grp-name)
          then do:
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
          if  first-of( buf_doc-line.prod-code)
          then do:
            run print-prod in this-procedure .
          end.
          if  first-of( buf_goods.grp-name)
          then do:
            run print-grp in this-procedure .
          end.
          run print-line in this-procedure .
        end.
      end.        /* sort-name <> yes */
    end.        /* sort-gr = yes */
    else do:
      if sort-name = yes
      then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
          , first buf_goods no-lock
          where buf_goods.artic      = buf_doc-line.artic
            and buf_goods.prod-type  = buf_doc-line.prod-type
            and buf_goods.prod-code  = buf_doc-line.prod-code
          break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_goods.gds-name
        :
          if  first-of( buf_doc-line.prod-code)
          then do:
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
          if  first-of( buf_doc-line.prod-code)
          then do:
            run print-prod in this-procedure .
          end.
          run print-line in this-procedure .
        end.
      end.        /* sort-name <> yes */
    end.        /* sort-gr <> yes */
  end.        /* sort-prod = yes */
  else do:
    if sort-gr = yes
    then do:
      if sort-name = yes
      then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = buf_trn-doc.doc-code
          , first buf_goods no-lock
            where buf_goods.artic      = buf_doc-line.artic
              and buf_goods.prod-type  = buf_doc-line.prod-type
              and buf_goods.prod-code  = buf_doc-line.prod-code
          break by buf_goods.grp-name  by buf_goods.gds-name
        :
          if  first-of( buf_goods.grp-name)
          then do:
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
          if  first-of( buf_goods.grp-name)
          then do:
            run print-grp in this-procedure .
          end.
          run print-line in this-procedure .
        end.
      end.        /* sort-name <> yes */
    end.        /* sort-gr = yes */
    else do:
      if sort-name = yes
      then do:
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

  run print-itog in this-procedure .

  if num-form > 1
  then do:
    if line-counter + 12 > page-size then page .

    put stream Out_stream space(5) "Всего  "   all-qnty     format ">,>>>,>>9.<<<" " единицы  "
                                              Lines_Counter format ">>>>9" " наименований. " format "X(15)" skip(1) .
    run itog in this-procedure .
    hide stream Out_stream frame Bottomframe .
  end.
  else do:
    put stream Out_stream skip space(20) "Главный бухгалтер ____________" format "X(45)"
                                         "Начальник склада__________" format "X(35)" skip.
    hide stream Out_stream frame Akt-Bottomframe .
  end.

  output stream Out_stream close .

  run print.
end.
/*---------------------      local procedures -------------------*/


procedure print-titul :
  do on error undo, return error return-value :
    if num-form > 1
    then do:
      if buf_trn-doc.internal then put stream Out_stream  "В Н У Т Р Е Н Н Е Е  ПЕРЕМЕЩЕНИЕ - П Р И Х О Д   N " at 22 format "X(55)"
                 v-doc-code format "X(10)" "  от  " v-doc-date-string format "X(10)" skip(1) .
      else put stream Out_stream "П Р И Х О Д Н А Я   Н А К Л А Д Н А Я   N  " at 32 format "X(45)" v-doc-code format "X(10)" "  от  " v-doc-date-string format "X(10)" skip(1) .

      put stream Out_stream string( "Отправитель  : " + buf_clients.obj-name + " (" + buf_clients.obj-type + " " + string(buf_clients.obj-code) + ")" ) at 10 format "X(120)" skip
              string( "Получатель   : " + Our_Host.obj-name + ",  " + Our_Object.obj-name ) at 10 format "X(125)" skip(1) .

      find pay-type where pay-type.obj-code = buf_trn-doc.pay-code no-lock no-error .
      if buf_trn-doc.internal
      then do:
        put stream Out_stream "Вид оплаты   : " at 10 format  "x(15)" ( if available pay-type then pay-type.obj-name else "?" ) format "X(60)" skip .
      end.
      else do:
        put stream Out_stream "Основание    : " at 10 format  "x(15)" ( if buf_trn-doc.ord-num <> "" then  "заказ N" + trim(buf_trn-doc.ord-num)
            else fill( " ", 10) ) format "X(110)" skip "Инвойс       : " at 10 format "x(15)"
            ( if buf_trn-doc.inv-num <> "" then fill(" ", 10 - length(trim(string( buf_trn-doc.inv-num)))) +
            trim(string( buf_trn-doc.inv-num, "x(8)") ) else fill( " ", 8) ) format "X(10)" skip.
        &if "{&sys-key}" <> "Tati" &then
          if Rubl_Coeff <> 1 then put stream Out_stream "Таможня      : " at 10 format "x(15)" buf_trn-doc.exch-date format "99.99.9999" skip.
        &endif
        put stream Out_stream "Вид оплаты   : " at 10 format "X(15)" ( if available pay-type then pay-type.obj-name else "?" ) format "X(30)" skip.
        &if "{&sys-key}" <> "Tati" &then
          if Rubl_Coeff <> 1 then put stream Out_stream "Курс         : " at 10 format "x(15)" Rubl_Coeff format ">>>,>>9.9999" skip .
          if buf_trn-doc.discnt-pc <> 0 then put stream Out_stream "Тамож. налог : " at 10 format "X(15)" buf_trn-doc.discnt-pc skip .
        &endif
      end.

      if v-torgconf-outprim = no
      then do:
        put stream Out_stream "Примечание   : "  at 10  format "X(15)" (if not( buf_trn-doc.PS BEGinS "@" ) then buf_trn-doc.PS else "" )  format "X(100)" skip(1) .
      end.

      case num-form :
        when 2 then form with frame Zum-rubl .
        when 3 then form with frame Nakl-rubl .
        when 4 then form with frame Zum-jew .
      end.

      form header
        Line format "X(136)" at 1 skip  "Продолжение - на следующей странице" at 30 skip
        with frame Bottomframe width {&DOS_CW_2} page-bottom no-labels no-box.
      view stream Out_stream frame Bottomframe .
    end.
    else do:
      put stream Out_stream "Приходный  акт  N  " at 40 format "X(20)" v-doc-code format "X(8)"
              "  от  " v-doc-date-string format "X(10)" skip(1) "на осмотр и приемку товаров, поступивших " at 30 format "X(45)"
              (if buf_trn-doc.obj-type = {&stock} then "на склад" else "в магазин") format "X(10)" Our_Object.obj-name format "X(40)" skip
              Our_Host.obj-name at 30 format "X(45)" " от поставщика " format "X(15)" skip  "согласно ________________" at 30 format "X(25)"
              " N ____________" format "X(15)" " от " '"____"_____________' format "X(20)"
              string( string( year( buf_trn-doc.doc-date ) ) + " г." )  format "X(20)" skip(1) .

      if not buf_trn-doc.internal then
        put stream Out_stream  &if "{&sys-key}" <> "zum" &then "Заказ        : "  &else "Накл. пост. N: " &endif
            at 40 format  "x(15)"  ( if buf_trn-doc.ord-num <> "" then fill(" ", 10 - length(trim(string( buf_trn-doc.ord-num)))) +
            trim(string( buf_trn-doc.ord-num, "x(10)") ) else fill( " ", 10) ) format "X(10)"
            "Таможня : " at 75 format "x(12)" space(3) buf_trn-doc.exch-date format "99.99.9999" skip
            "Инвойс       : " at 40 format "x(15)" ( if buf_trn-doc.inv-num = "" then "   " else buf_trn-doc.inv-num ) format "x(20)"
            "Курс    : " format "x(12)" space(3) Rubl_Coeff format ">>>,>>9.9999" skip(1) .
      form with frame AKT .
      form header
           Line format "X(136)" at 1 skip "Продолжение - на следующей странице" at 30 skip
           with frame Akt-Bottomframe width {&A4_CW} page-bottom no-labels no-box.
      view stream Out_stream frame Akt-Bottomframe .
    end.
  end.
end procedure. /* print-titul */



procedure Print-prod :
  do on error undo, return error return-value :
    find first buf_clients where buf_clients.obj-type = buf_goods.prod-type and buf_clients.obj-code = buf_goods.prod-code no-lock .
    case num-form :
      when 1
      then do:
        display stream out_stream sym1 "Производитель -" @ buf_goods.artic buf_clients.obj-name @ gds_name sym9 with frame akt .
        down stream out_stream 1 with frame akt .
      end.
      when 2
      then do:
        display stream out_stream sym1 "Производитель -" @ buf_goods.artic buf_clients.obj-name @ gds_name sym9 with frame Zum-rubl .
        down stream out_stream 1 with frame Zum-rubl .
      end.
      when 3
      then do:
        display stream out_stream sym1 "Производитель -" @ buf_goods.artic buf_clients.obj-name @ gds_name sym10 with frame rubl .
        down stream out_stream 1 with frame rubl .
      end.
      when 4
      then do:
        display stream out_stream sym1 "Производитель -" @ buf_goods.artic buf_clients.obj-name @ gds_name sym9 with frame Zum-jew .
        down stream out_stream 1 with frame Zum-jew .
      end.
    end.
  end.
end procedure. /* Print-prod */



procedure print-grp :
  do on error undo, return error return-value :
    case num-form :
      when 1
      then do:
        display stream out_stream sym1 "Группа -" @ buf_goods.artic buf_goods.grp-name @ gds_name sym9 with frame akt .
        down stream out_stream 1 with frame akt .
      end.
      when 2
      then do:
        display stream out_stream sym1 "Группа -" @ buf_goods.artic buf_goods.grp-name @ gds_name sym9 with frame Zum-rubl .
        down stream out_stream 1 with frame Zum-rubl .
      end.
      when 3
      then do:
        display stream out_stream sym1 "Группа -" @ buf_goods.artic buf_goods.grp-name @ gds_name sym10 with frame rubl .
        down stream out_stream 1 with frame rubl .
      end.
      when 4
      then do:
        display stream out_stream sym1 "Группа -" @ buf_goods.artic buf_goods.grp-name @ gds_name sym9 with frame Zum-jew .
        down stream out_stream 1 with frame Zum-jew .
      end.
    end.
  end.
end procedure. /* print-grp */



procedure print-line :
  do on error undo, return error return-value :
    case num-form :
      when 1
      then do:
        { rep/r-inpz1.i akt      }
      end.
      when 2
      then do:
        { rep/r-inpz1.i Zum-rubl }
      end.
      when 3
      then do:
        { rep/r-inpz1.i rubl     }
      end.
      when 4
      then do:
        { rep/r-inpz1.i Zum-jew  }
      end.
    end.
  end.
end procedure. /* print-line */



procedure print-itog :
  do on error undo, return error return-value :

    case num-form :
      when 1
      then do:
        put stream out_stream Line format "X(136)" skip .
        display stream out_stream sym1 sym2 sym3 sym4 "ИТОГО: " @ gds_name sym5 sym6
          all-qnty @ Price sym7 all-stoim @ qnty sym8 (all-qnty - all-stoim) @ stoim sym9 with frame AKT.
        down stream out_stream with frame AKT .
        put stream out_stream Line format "X(136)" skip .
      end.
      when 2
      then do:
        put stream out_stream Line format "X(136)" skip .
        display stream out_stream sym1 sym2 sym3 sym4 "ИТОГО: " @ gds_name sym5 sym6 sym7 all-qnty @ qnty sym8 all-stoim @ stoim sym9 with frame Zum-rubl.
        down stream out_stream with frame Zum-rubl .
        put stream out_stream Line format "X(136)" skip .
      end.
      when 3
      then do:
        put stream out_stream Line format "X(136)" skip .
        display stream out_stream sym1 sym2 sym3 sym4 "ИТОГО: " @ gds_name sym5 sym6 sym7 all-qnty @ qnty sym8 all-stoim @ stoim sym9 sym10 with frame rubl.
        down stream out_stream with frame rubl .
        put stream out_stream Line format "X(136)" skip .
      end.
      when 4
      then do:
        put stream out_stream Line format "X(136)" skip .
        display stream out_stream sym1 sym2 sym3 sym4 "ИТОГО: " @ gds_name sym5 sym6 sym7 all-qnty @ qnty sym8 all-stoim @ stoim sym9  with frame Zum-jew.
        down stream out_stream with frame Zum-jew .
        put stream out_stream Line format "X(136)" skip .
      end.
    end.
  end.
end procedure. /* print-itog */


procedure itog:
  if not PrintRubl then run rep/wp.p (     input p-mainmenu-handle, input all-stoim, output s1, output s2 ) .
  else                  run rep/wp-rub.p (                          input all-stoim, output s1, output s2 ) .
  if buf_trn-doc.internal
  then do:
    PUT STREAM Out_Stream SPACE(5) "Итого к оплате " all-stoim format ">,>>>,>>>,>>9.99" SPACE(2) trim(s2) format "X(4)" .
  end.
  else do:
    PUT STREAM Out_Stream SPACE(5) "Итого " all-stoim format ">>,>>>,>>>,>>9.99" SPACE(2) trim(s2) format "X(4)" .
    put stream Out_stream ", в том числе: " format "x(25)" skip(1).
    put stream Out_stream string( ": Сумма  налога :   Сумма НДС   :" ) at 60 format "X(40)" skip.
    for each temp-nalog break by temp-nalog.slt-prc by temp-nalog.vat-prc:
      accumulate
        temp-nalog.slt-sum (total)
        temp-nalog.vat-sum (total)
      .
      put stream Out_stream
        string( "Налог с продаж" + string( temp-nalog.slt-prc, ">>9.<<%")
        + string( ", НДС" + string( temp-nalog.vat-prc, ">>9.<<%") ) ) at 20 format "X(40)"
        string( ":"  + string( temp-nalog.SLT-sum , "->>>,>>>,>>9.99" )
        + ":"  + string( temp-nalog.VAT-sum , "->>>,>>>,>>9.99" ) + ":" ) at 60 format "X(40)"  skip
      .
    end.
    put stream Out_stream
      line at 20 format "X(73)" skip string( "Итого" ) at 20 format "X(40)"
      string( ":" + string( accum total temp-nalog.SLT-sum, "->>>,>>>,>>9.99" ) + ":"
      + string( accum total temp-nalog.VAT-sum, "->>>,>>>,>>9.99" )  + ":" ) at 60 format "X(40)" skip
    .
    put stream Out_stream skip(1) space(10) caps(s1) format "x(126)" skip(2) .
  end.

  if buf_trn-doc.status_ = {&fact}
  then do:
    run rep/get-psn.p ( input buf_trn-doc.boss, output Mngr_name ) .
    run rep/get-psn.p ( input buf_trn-doc.wrkr, output Wrkr_name) .
    run rep/get-psn.p ( input buf_trn-doc.agnt, output Isp_name ) .

    define variable v-user-name as character no-undo .

    { gbl/usrfulnm.i
      buf_trn-doc.creid
      v-user-name
    }

    if not( "{&sys-key}" = "ia" and CostPrice = no ) then
      &if "{&sys-key}" = "smk" &then
         put stream Out_stream skip(1) space(10) "Товар сдал   :" format "X(75)" skip(1)
         space(10) "Товар принял :" format "X(75)" skip(1)
         space(10) "Разрешаю     :" format "X(75)" "М.П." format "X(10)" skip
         space(10) "Генеральный директор " + Our_Host.obj-name format "X(120)" skip(1)
       .
      &else
         put stream Out_stream "Торговый представитель : " at 9 format "X(30)"  Mngr_name   format "X(30)" skip
                               "Исполнитель            : " at 9 format "X(30)"  Isp_name    format "X(30)" skip
                               "Документ оформил       : " at 9 format "X(30)"  v-user-name format "X(60)" skip
                               "Кладовщик              : " at 9 format "X(30)"  Wrkr_name   format "X(30)" skip(1)
        .
      &endif
    put stream Out_stream space(65) ( if v-torgconf-outdate = no then string( buf_trn-doc.fact-date, "99/99/9999" ) else "" )  format "X(10)"  skip .
  end.
  else do:
    put stream Out_stream  space(30) "--- Н Е   П О Д П И С Ы В А Т Ь ! ---" format "X(75)" skip(1) .
  end.
end procedure.

procedure print:
    { gbl/chk-actg.i
        v-cntxt-db-num
        v-cntxt-userid
        {&action-head-code-main}
        'actn_waybills-to-file_print':U
        {&cntxt-firm}
        v-cntxt-host-code-obj
        '':U
        0
        0
        0
        0
        no
        Log-Res
    }
    if Log-Res
    then do:
      { rep/q-print.i 4 }
    end.
    else do:
      { rep/q-print.i 4 }
    end.
end procedure.