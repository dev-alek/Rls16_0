block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-schflr.p $
$Archive: rep/r-schflr.p $

Печать счета Топ-аукцион

Автор: Чернова Светлана Александровна
Дата создания: 10/24/05
Author: Svetlana Chernova
Creation date: 10/24/05

*/
define input parameter parparentproc as handle    no-undo.
define input parameter rec_id        as recid          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-schflr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-schflr.p $":U .
define variable vss-description as character no-undo init "Печать счета Топ-аукцион".
{ cmp/vssrevis.i }
{ cmp/showinf.i  }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ rep/fmtcli.i   }
{ gbl/clntattr.i }
{ str/trdcalib.i }
{ rep/torgconf.i }
{ str/clcprtsl.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

do
on error undo, return error
:

define variable base-type as character no-undo .
define variable base-code as integer   no-undo .
define variable g#gds-engl as logical   no-undo .
define variable g#report-num as integer   no-undo .
define variable g#rsrv-time as integer   no-undo .
define variable g#quest-print as logical   no-undo .
define variable g#log as logical   no-undo .


define variable v-cntxt-host-name-obj as character no-undo .

define buffer buf_rep_currency for ub.currency.
{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
{ gbl/basecode.i v-cntxt-host-code-obj base-code }


find first buf_rep_currency no-lock
  where buf_rep_currency.curr-code = base-code
  no-error .
  if available buf_rep_currency then base-type = buf_rep_currency.curr-abbr .
               else base-type = "б.в." .

run get-report-num  in parparentproc ( output g#report-num ).
run get-gds-engl   in parparentproc ( output g#gds-engl ) .
run get-quest-print in parparentproc ( output g#quest-print ) .


  DEFINE temp-table temp-nalog no-undo
    field   slt-prc          as  decimal
    field   vat-prc          as  decimal
    field   sum              as  decimal
    field   slt-sum          as  decimal
    field   vat-sum          as  decimal
    INDEX pi  IS PRIMARY   vat-prc slt-prc
  .

  define shared variable CostPrice    as logical          no-undo .
  define shared variable PrintScale   as logical          no-undo.
  define shared variable sort-gr      as logical          no-undo.
  define shared variable sort-name    as logical          no-undo.
  CostPrice   = false .
  PrintScale  = false .
  sort-gr     = false .
  sort-name   = false .
  define buffer t-doc       for ub.trn-doc.
  define buffer buf_firm    for ub.firm .
  define buffer buf_sysconf for ub.sysconf .
  define buffer cli-pbank   for ub.clients .
  define buffer cli-obj     for ub.clients .
  define buffer Our_Object  for ub.clients.
  define buffer Our_Host    for ub.clients.

  define buffer buf_clients for ub.clients.
  define buffer buf_goods   for ub.goods.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_gds-dtl for ub.gds-dtl.

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
  define variable gds_name     like ub.goods.gds-name no-undo .
  define variable Price        as  decimal     no-undo.
  define variable qnty         as  decimal     no-undo.
  define variable stoim        as  decimal     no-undo.
  define variable stoim-d        as  decimal     no-undo.
  define variable SLT-sum      as  decimal     no-undo.
  define variable VAT-sum      as  decimal     no-undo.

  define variable all-qnty         as  decimal     no-undo.
  define variable all-stoim        as  decimal     no-undo.
  define variable all-SLT-sum      as  decimal     no-undo.
  define variable all-VAT-sum      as  decimal     no-undo.

  define variable v-vat-pc     like ub.doc-line.vat-pc         no-undo .
  define variable v-slt-pc     like ub.doc-line.slt-pc         no-undo .

  define variable v-kol-n as integer   no-undo .


  DEFINE STREAM Out_Stream .

  define frame val
        sym1 column-label ":!:" format "X(1)" space(0)
        Lines_Counter column-label "N!п/п":C5 format ">>>>9" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
        tb-code column-label "Код! ":C10 format "x(10)" space(0)
        sym3 column-label ":!:" format "X(1)" space(0)
        buf_goods.artic column-label "Артикул! ":C16 format "X(16)" space(0)
        sym4 column-label ":!:" format "X(1)" space(0)
        gds_name column-label "Наименование! ":C34 format "X(34)" space(0)
        sym5 column-label ":!:" format "X(1)" space(0)
        buf_goods.unit-base column-label "Ед.!изм" format "X(3)" space(0)
        sym6 column-label ":!:" format "X(1)" space(0)
        Price column-label "Цена за ед.!(Б.вал.) " format ">>>>>>>>>>9.99" space(0)
        sym7 column-label ":!:" format "X(1)" space(0)
        qnty column-label "Количество ! " format "->>>>>9.<<<" space(0)
        sym8 column-label ":!:" format "X(1)" space(0)
        stoim column-label "Стоимость!(Б.вал.) " format "->>>>>>>>>>>>9.99" space(0)
        sym9 column-label ":!:" format "X(1)" space(0)
        SLT-sum column-label "Сумма налога с!продаж(Б.вал.)" format "->>>>>>>>>9.99" space(0)
        sym10 column-label ":!:" format "X(1)" space(0)
    header
        string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) at 5 format "X(35)"
        v-doc-code at 70 format "X(14)" " от " v-doc-date-string format "X(10)"
        string( "Страница " + string( PAGE-NUMBER( Out_stream ), ">>9" ) ) at 110 format "X(13)" skip
        Line format "X(134)" at 1
  with width {&DOS_CW_2} down stream-io.

  define frame rubl
        sym1 column-label ":!:" format "X(1)" space(0)
        Lines_Counter column-label "N!п/п" format ">>>9" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
        tb-code column-label "Код! ":C10 format "x(10)" space(0)
        sym3 column-label ":!:" format "X(1)" space(0)
        buf_goods.artic column-label "Артикул! ":C16 format "X(16)" space(0)
        sym4 column-label ":!:" format "X(1)" space(0)
        gds_name column-label "Наименование! ":C32 format "X(32)" space(0)
        sym5 column-label ":!:" format "X(1)" space(0)
        buf_goods.unit-base column-label "Ед.!изм" format "X(3)" space(0)
        sym6 column-label ":!:" format "X(1)" space(0)
        Price column-label "Цена за ед.!({&abbr_rub_allshift}) " format ">>>>,>>>,>>9.99" space(0)
        sym7 column-label ":!:" format "X(1)" space(0)
        qnty column-label "Количество ! " format ">>>>>>9.<<<" space(0)
        sym8 column-label ":!:" format "X(1)" space(0)
        stoim column-label "Стоимость!({&abbr_rub_allshift}) " format "->>>,>>>,>>>,>>9.99" space(0)
        sym9 column-label ":!:" format "X(1)" space(0)
        SLT-sum column-label "Сумма налога!с продаж ({&abbr_rub_allshift})" format "->>>>>>>>>9.99" space(0)
        sym10 column-label ":!:" format "X(1)" space(0)
    header
        string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) at 5 format "X(35)"
        v-doc-code at 70 format "X(14)" " от " v-doc-date-string format "X(10)"
        string( "Страница " + string( PAGE-NUMBER( Out_stream ), ">>9" ) ) at 110 format "X(13)" skip
        Line format "X(134)" at 1
  with width {&DOS_CW_2} down stream-io.

  define frame val1
        sym1 column-label ":!:" format "X(1)" space(0)
        Lines_Counter column-label "N!п/п":C5 format ">>>>9" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
        tb-code column-label "Код! ":C10 format "x(10)" space(0)
        sym3 column-label ":!:" format "X(1)" space(0)
        buf_goods.artic column-label "Артикул! ":C16 format "X(16)" space(0)
        sym4 column-label ":!:" format "X(1)" space(0)
        gds_name column-label "Наименование! ":C34 format "X(34)" space(0)
        sym5 column-label ":!:" format "X(1)" space(0)
        buf_goods.unit-base column-label "Ед.!изм" format "X(3)" space(0)
        sym6 column-label ":!:" format "X(1)" space(0)
        Price column-label "Цена за ед.!(Б.вал.) " format ">>>>>>>>>>9.99" space(0)
        sym7 column-label ":!:" format "X(1)" space(0)
        qnty column-label "Количество ! " format "->>>>>9.<<<" space(0)
        sym8 column-label ":!:" format "X(1)" space(0)
        stoim column-label "Стоимость!(Б.вал.) " format "->>>>>>>>>>>>9.99" space(0)
        sym10 column-label ":!:" format "X(1)" space(0)
    header
        string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) at 5 format "X(35)"
        v-doc-code at 60 format "X(14)" " от " v-doc-date-string format "X(10)"
        string( "Страница " + string( PAGE-NUMBER( Out_stream ), ">>9" ) ) at 100 format "X(13)" skip
        Line format "X(119)" at 1
  with width {&DOS_CW_2} down stream-io.

  define frame rubl1
        sym1 column-label ":!:" format "X(1)" space(0)
        Lines_Counter column-label "N!п/п" format ">>>9" space(0)
        sym2 column-label ":!:" format "X(1)" space(0)
        tb-code column-label "Код! ":C10 format "x(10)" space(0)
        sym3 column-label ":!:" format "X(1)" space(0)
        buf_goods.artic column-label "Артикул! ":C16 format "X(16)" space(0)
        sym4 column-label ":!:" format "X(1)" space(0)
        gds_name column-label "Наименование! ":C32 format "X(32)" space(0)
        sym5 column-label ":!:" format "X(1)" space(0)
        buf_goods.unit-base column-label "Ед.!изм" format "X(3)" space(0)
        sym6 column-label ":!:" format "X(1)" space(0)
        Price column-label "Цена за ед.!({&abbr_rub_allshift}) " format ">>>>,>>>,>>9.99" space(0)
        sym7 column-label ":!:" format "X(1)" space(0)
        qnty column-label "Количество ! " format ">>>>>>9.<<<" space(0)
        sym8 column-label ":!:" format "X(1)" space(0)
        stoim column-label "Стоимость!({&abbr_rub_allshift}) " format "->>>,>>>,>>>,>>9.99" space(0)
        sym10 column-label ":!:" format "X(1)" space(0)
    header
        string( "Дата печати : " + string(TODAY,"99.99.9999") +  " , " + string(TIME, "HH:MM") ) at 5 format "X(35)"
        v-doc-code at 60 format "X(14)" " от " v-doc-date-string format "X(10)"
        string( "Страница " + string( PAGE-NUMBER( Out_stream ), ">>9" ) ) at 100 format "X(13)" skip
        Line format "X(119)" at 1
  with width {&DOS_CW_2} down stream-io.


  { cmp/open-out.i STREAM Out_Stream " "}

  find first t-doc where recid(t-doc)   = rec_id  no-lock no-error.

  define variable v-sort-prod         as character         no-undo.
  define variable v-sys-key as character no-undo .

  { gbl/currsysk.i
    v-sys-key
    no-error
  }

  { gbl/getsect.i run "''" 0 {&attr-prt-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'sort-prd' then v-sort-prod = string( thbjattr_thbj-attr.property-value-logical) .
  end.

    if t-doc.obj-type = {&shop} then do:
      find first ub.shop no-lock where ub.shop.obj-code = t-doc.obj-code no-error .
      if available ub.shop then
        g#rsrv-time = ub.shop.rsrv-time
      .
    end.
    else do:
      find first ub.store no-lock where ub.store.obj-code = t-doc.obj-code no-error .
        if available ub.store then
          g#rsrv-time = ub.store.rsrv-time
        .
    end.

  define variable p-form-name         as character init "schet"    no-undo.

  define variable v-host-code         as integer              no-undo.
  { gbl/hostcode.i    t-doc.obj-type  t-doc.obj-code  v-host-code  }

  run torgconf-read in this-procedure (input p-form-name, input v-host-code, input t-doc.obj-type, input t-doc.obj-code) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip "Ошибка чтения параметров печати формы." skip "Форма будет напечатана с параметрами по умолчанию."
        skip return-value   skip trim(error-status :get-message(1))  trim(error-status :get-message(2)) trim(error-status :get-message(3))
    view-as alert-box error.
  end.

  define variable v-curr-code as integer   no-undo .
  if printRubl = yes then assign v-curr-code = 0 .
  else do:
    { gbl/basecode.i v-host-code v-curr-code }
  end.

  run torgconf-get-self-param in this-procedure ( input t-doc.obj-type, input t-doc.obj-code, input v-curr-code) no-error.
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description   skip "Ошибка чтения параметров объекта документа."  skip return-value
      skip trim(error-status :get-message(1))   trim(error-status :get-message(2))  trim(error-status :get-message(3))
    view-as alert-box warning.
  end.


  find first our_object  where our_object.obj-type   = t-doc.obj-type and our_object.obj-code  = t-doc.obj-code  no-lock.
  find first our_host    where our_host.obj-type     = {&cmp}         and our_host.obj-code    = t-doc.host-code no-lock.
  find first buf_firm    where buf_firm.firm-code    = our_host.obj-code no-lock.
  find first buf_sysconf where buf_sysconf.host-code = buf_firm.firm-code  no-lock.

  if v-torgconf-self-schet-exists then do:
    PUT STREAM Out_Stream
      space(9)  string ( "Поставщик: {&abbr_inn_allshift} " + v-torgconf-self-host-inn + " , {&abbr_kpp_allshift} " + v-torgconf-self-host-kpp + " " + v-torgconf-self-host-name ) format "X(100)" SKIP
      space(9)  string ( "Адрес: " + v-torgconf-self-host-addres ) format "X(100)" SKIP
      space(9)  string ( "Телефон, факс: " + v-torgconf-self-host-phone ) format "X(100)" SKIP
      space(9)  string ( "Реквизиты банка: " + v-torgconf-self-bank-name  ) format "X(100)" SKIP
      space(26) string ( "р/c " + v-torgconf-self-bank-r-schet ) format "X(100)" SKIP
      space(26) string ( "БИК " + v-torgconf-self-bank-bik ) format "X(100)" SKIP
      space(26) string ( "к/c " + v-torgconf-self-bank-c-schet ) format "X(100)" SKIP
    .
  end.
  else do:
    PUT STREAM Out_Stream
      space(9)  string ( "Поставщик: {&abbr_inn_allshift} " + v-torgconf-self-host-inn + " , {&abbr_kpp_allshift} " + v-torgconf-self-host-kpp + " " + v-torgconf-self-host-name ) format "X(100)" SKIP
      space(9)  string ( "Адрес: " + v-torgconf-self-host-addres ) format "X(100)" SKIP
      space(9)  string ( "Телефон, факс: " + v-torgconf-self-host-phone ) format "X(100)" SKIP
      space(9)  string ( "Реквизиты банка: "  ) format "X(100)" SKIP
    .
  end.

  PUT STREAM Out_Stream " " SKIP .

  FIND cli-obj WHERE cli-obj.obj-type = t-doc.cli-type AND cli-obj.obj-code = t-doc.cli-code NO-LOCK .

  PUT STREAM Out_Stream   (  "С Ч Е Т       N " ) AT 32
                       format "X(17)"  t-doc.doc-code format "X(10)" "  от  " t-doc.doc-date format "99.99.9999" SKIP .

  PUT STREAM Out_Stream " " SKIP .

  PUT STREAM Out_Stream SPACE(9) "Плательщик   : " + cli-obj.obj-name + "(" + string(cli-obj.obj-code) + ")" format "X(102)" SKIP .

  /* печать вида платежа и примечания */
  Find ub.pay-type Where ub.pay-type.Obj-code = T-doc.Pay-code No-lock No-error.
/*    Put Stream Out_Stream String( {&type-pay} + ( If Available ub.pay-type Then ub.pay-type.Obj-name Else "?" ) ) At 10 Format "X(60)" Skip .*/
  Put Stream Out_Stream String( "вид оплаты : " + ( If Available ub.pay-type Then ub.pay-type.Obj-name Else "?" ) ) At 10 Format "X(60)" Skip .
  If V-torgconf-outprim = No Then Do:
    Put Stream Out_Stream  String( "примечание : " + ( If ( Not Can-do( {&fact}, T-doc.Status_ ) Or Logres ) And Not ( T-doc.Ps Begins "@" ) Then  T-doc.Ps Else " " ) ) At 10 Format "X(100)" Skip .
/*      Put Stream Out_Stream  String( {&note2} + ( If ( Not Can-do( {&fact}, T-doc.Status_ ) Or Logres ) And Not ( T-doc.Ps Begins "@" ) Then  T-doc.Ps Else " " ) ) At 10 Format "X(100)" Skip .*/
  End.

  PUT STREAM Out_Stream SPACE(9) string("Срок оплаты счета: " + ( if g#rsrv-time = 0 then "2" else string(g#rsrv-time, ">>9") ) + " дней.") format "X(102)" SKIP .


  if session:set-wait-state("compiler") then.

  assign
    Line = fill( "-", {&DOS_CW_2} )
    Lines_Counter = 0
  .
  if v-torgconf-outnum = yes then assign  v-doc-code = fill( " ", 10 )  .
  else                            assign  v-doc-code = t-doc.doc-code .

  if v-torgconf-outdate = yes then assign v-doc-date-string = fill( " ", 10 ) .
  else                             assign v-doc-date-string = string( t-doc.doc-date, "99/99/9999" )  .

  define variable prn_NP as logical initial no no-undo .
  if buf_sysconf.cash-pay = t-doc.pay-code then assign prn_NP = yes . /* с НП */

    if not PrintRubl then form with frame val1 .
    else                  form with frame rubl1 .
    form header
      Line format "X(119)" at 1 skip
      "Продолжение - на следующей странице" at 30 skip
      with frame Bottomframe width {&DOS_CW_2} page-bottom no-labels no-box .

  view stream Out_stream frame Bottomframe .

  /* печать строк */
  if v-sort-prod = "yes" then do:
    if sort-gr = yes then do:
      if sort-name = yes then do:
        for each buf_doc-line no-lock
          where buf_doc-line.doc-code = t-doc.doc-code
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
          where buf_doc-line.doc-code = t-doc.doc-code
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
          where buf_doc-line.doc-code = t-doc.doc-code
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
          where buf_doc-line.doc-code = t-doc.doc-code
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
          where buf_doc-line.doc-code = t-doc.doc-code
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
          where buf_doc-line.doc-code = t-doc.doc-code
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
          where buf_doc-line.doc-code = t-doc.doc-code
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
          where buf_doc-line.doc-code = t-doc.doc-code
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

  if prn_NP then do: /* с НП */
    put stream out_stream Line format "X(134)" skip .
    if PrintRubl then do:
      display stream out_stream
        sym1 sym2 sym3 sym4 "ИТОГО: " @ gds_name sym5 sym6 sym7 all-qnty @ qnty sym8 all-stoim @ stoim sym9 all-SLT-sum @ SLT-sum sym10
      with frame rubl.
      down stream out_stream with frame rubl .
    end.
    else do:
      display stream out_stream
        sym1 sym2 sym3 sym4 "ИТОГО: " @ gds_name sym5 sym6 sym7 all-qnty @ qnty sym8 all-stoim @ stoim sym9 all-SLT-sum @ SLT-sum sym10
      with frame val.
      down stream out_stream with frame val .
    end.
    put stream out_stream Line format "X(134)" skip .
  end.
  else do:
    put stream out_stream Line format "X(119)" skip .
    if PrintRubl then do:
      display stream out_stream
        sym1 sym2 sym3 sym4 "ИТОГО: " @ gds_name sym5 sym6 sym7 all-qnty @ qnty sym8 all-stoim @ stoim sym10
      with frame rubl1.
      down stream out_stream with frame rubl1 .
    end.
    else do:
      display stream out_stream
        sym1 sym2 sym3 sym4 "ИТОГО: " @ gds_name sym5 sym6 sym7 all-qnty @ qnty sym8 all-stoim @ stoim sym10
      with frame val1.
      down stream out_stream with frame val1 .
    end.
    put stream out_stream Line format "X(119)" skip .
  end.

  if line-counter( Out_stream ) + 8 > page-size( Out_stream ) then page stream Out_stream .


    put stream Out_stream
          space(5) "Всего " + trim(string(v-kol-n)) + " наименований на сумму: " format "x(30)"
          space(2) all-stoim  format "->>>,>>>,>>>,>>9.99"
          space(2) ( if not PrintRubl then base-type else "{&abbr_rub_allshift}" )  format "x(4)" skip .

    /* для внешних */
    if not t-doc.internal  then do:
        put stream Out_stream
          space(5) "Скидка " +  string( string( t-doc.discnt-pc, "->>9.99" ) + "%" ) +
          " на сумму :" format "x(30)"
          space(2) ( if not PrintRubl then t-doc.tot-calc else t-doc.discnt-rubl )  format "->>>,>>>,>>>,>>9.99"
          space(2) ( if not PrintRubl then base-type      else "{&abbr_rub_allshift}" )  format "x(4)" skip .

        all-stoim = all-stoim - ( if not PrintRubl then t-doc.tot-calc else t-doc.discnt-rubl ) .

     end.

    put stream Out_stream
      space(5) "Итого к оплате :" format "x(30)"
      space(2) all-stoim  format "->>>,>>>,>>>,>>9.99"
      space(2) ( if not PrintRubl then base-type else "{&abbr_rub_allshift}" )  format "x(4)" skip .


    if not PrintRubl
    then do:
       run rep/wp.p
         (input parparentproc
         ,input all-stoim
         ,output s1
         ,output s2
         ) .
    end.
    else do:
       run rep/wp-rub.p
         (input all-stoim
         ,output s1
         ,output s2
         ) .
    end.


    put stream Out_stream skip space(5)  caps(s1) format "x(126)" skip .

    put stream Out_stream space(5)  "В том числе: " skip .

      if PrintRubl then do:
        for each temp-nalog :
          put stream Out_stream space(15) string( "НДС " + string(temp-nalog.vat-prc) + "% : " + string( temp-nalog.vat-sum , "->>>,>>>,>>9.99" ) + " " + "{&abbr_rub_allshift}" ) format "x(35)"
                             "от суммы "  string( temp-nalog.sum , "->>>,>>>,>>9.99" ) + " " + "{&abbr_rub_allshift}"   format "x(20)"   skip .
        end.
      end.
      else do:
       for each temp-nalog :
          put stream Out_stream space(15) string( "НДС " + string(temp-nalog.vat-prc) + "% : "  + string( temp-nalog.vat-sum , "->>>,>>>,>>9.99" ) + " " + base-type) format "x(35)"
                            "от суммы "  (string( temp-nalog.sum , "->>>,>>>,>>9.99" ) + " " + base-type )  format "x(20)" skip .
       end.
      end.



    put stream Out_stream  skip(2)
      "Руководитель предприятия: ___________________ / " buf_firm.director      format "X(20)"  " /"   skip(1)
      "Главный бухгалтер:        __________________ /"   buf_sysconf.snr-accnt  format "X(20)"  " /" skip .

  hide stream Out_stream frame Bottomframe .

  output stream Out_stream close.
  if session:set-wait-state("") then.
  { rep/q-print.i 4 }
end.



procedure Print-prod :
  do on error undo, return error return-value :
    find first buf_clients where buf_clients.obj-type = buf_goods.prod-type and buf_clients.obj-code = buf_goods.prod-code no-lock .

    if prn_NP then do: /* с НП */
      if not printrubl then do:
        display stream out_stream sym1 "Производитель -" @ buf_goods.artic buf_clients.obj-name @ gds_name sym10 with frame val .
        down stream out_stream 1 with frame val .
        underline stream out_stream buf_goods.artic gds_name with frame val .
      end.
      else do:
        display stream out_stream sym1 "Производитель -" @ buf_goods.artic buf_clients.obj-name @ gds_name sym10 with frame rubl .
        down stream out_stream 1 with frame rubl .
        underline stream out_stream buf_goods.artic gds_name with frame rubl .
      end.
    end.
    else do:
      if not printrubl then do:
        display stream out_stream sym1 "Производитель -" @ buf_goods.artic buf_clients.obj-name @ gds_name sym10 with frame val1 .
        down stream out_stream 1 with frame val1 .
        underline stream out_stream buf_goods.artic gds_name with frame val1 .
      end.
      else do:
        display stream out_stream sym1 "Производитель -" @ buf_goods.artic buf_clients.obj-name @ gds_name sym10 with frame rubl1 .
        down stream out_stream 1 with frame rubl1 .
        underline stream out_stream buf_goods.artic gds_name with frame rubl1 .
      end.
    end.

  end.
end procedure. /* Print-prod */



procedure print-grp :
  do on error undo, return error return-value :
    if prn_NP then do: /* с НП */
      if not printrubl then do:
        display stream out_stream sym1 "Группа -" @ buf_goods.artic buf_goods.grp-name @ gds_name sym10 with frame val .
        down stream out_stream 1 with frame val .
        underline stream out_stream buf_goods.artic gds_name with frame val .
      end.
      else do:
        display stream out_stream sym1 "Группа -" @ buf_goods.artic buf_goods.grp-name @ gds_name sym10 with frame rubl .
        down stream out_stream 1 with frame rubl .
        underline stream out_stream buf_goods.artic gds_name with frame rubl .
      end.
    end.
    else do:
      if not printrubl then do:
        display stream out_stream sym1 "Группа -" @ buf_goods.artic buf_goods.grp-name @ gds_name sym10 with frame val1 .
        down stream out_stream 1 with frame val1 .
        underline stream out_stream buf_goods.artic gds_name with frame val1 .
      end.
      else do:
        display stream out_stream sym1 "Группа -" @ buf_goods.artic buf_goods.grp-name @ gds_name sym10 with frame rubl1 .
        down stream out_stream 1 with frame rubl1 .
        underline stream out_stream buf_goods.artic gds_name with frame rubl1 .
      end.
    end.
  end.
end procedure. /* print-grp */



procedure print-line :
  do on error undo, return error return-value :
  v-kol-n = v-kol-n + 1 .

    if prn_NP then do: /* с НП */
      if PrintRubl then do:    { rep/r-sflr.i rubl }    end.
      else do:                 { rep/r-sflr.i val }     end.
    end.
    else do:
      if PrintRubl then do:   { rep/r-sflr.i rubl1 }     end.
      else do:                { rep/r-sflr.i val1 }      end.
    end.
  end.
end procedure. /* print-line */