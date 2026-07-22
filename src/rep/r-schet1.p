block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-schet1.p $
$Archive: rep/r-schet1.p $

Печать счета

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/
define input parameter parParentProc     AS WIDGET-HANDLE NO-UNDO.
define input parameter rec_id   as recid          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-schet1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-schet1.p $":U .
define variable vss-description as character no-undo init "Печать счета".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ cmp/r-pril.i   }
{ rep/fmtcli.i   }
{ gbl/clntattr.i }
{ str/trdcalib.i }
{ rep/torgconf.i }
{ str/clcprtsl.i }
{ rep/tmp-tab.i  }
{ str/getctxtp.i def }
{ str/getctxtp.i get }
{ str/get-pr.i def }

do
on error undo, return error
:

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define variable g#quest-print as logical   no-undo .
  run get-quest-print in parParentProc ( output g#quest-print ).

  define variable g#gds-engl as logical   no-undo .
  run get-gds-engl  in parParentProc ( output g#gds-engl ).


  DEFINE VARIABLE base-type    AS CHARACTER NO-UNDO.
  define variable g#log as logical   no-undo .

    define shared variable CostPrice    as logical          no-undo .
  define shared variable PrintScale   as logical          no-undo.
  define shared variable sort-gr      as logical          no-undo.
  define shared variable sort-name    as logical          no-undo.

  define buffer t-doc         for ub.trn-doc.
  define buffer buf_firm      for ub.firm .
  define buffer buf_sysconf   for ub.sysconf .
  define buffer cli-pbank     for ub.clients .
  define buffer cli-obj       for ub.clients .
  define buffer Our_Object    for ub.clients.
  define buffer Our_Host      for ub.clients.
  define buffer buf_clients   for ub.clients.
  define buffer buf_goods     for ub.goods.
  define buffer buf_doc-line  for ub.doc-line.
  define buffer buf_gds-dtl   for ub.gds-dtl.
  define buffer buf_gds-prt   for ub.gds-prt.
  define buffer buf_pay-type  for ub.pay-type.

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
  define variable gds_name     like ub.goods.gds-name .
  define variable Price        as  decimal     no-undo.
  define variable qnty         as  decimal     no-undo.
  define variable stoim        as  decimal     no-undo.
  define variable SLT-sum      as  decimal     no-undo.
  define variable VAT-sum      as  decimal     no-undo.

  define variable all-qnty         as  decimal     no-undo.
  define variable all-stoim        as  decimal     no-undo.
  define variable all-SLT-sum      as  decimal     no-undo.
  define variable all-VAT-sum      as  decimal     no-undo.

  define variable v-vat-pc     like ub.doc-line.vat-pc         no-undo .
  define variable v-slt-pc     like ub.doc-line.slt-pc         no-undo .

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

  define variable p-form-name         as character init "schet"    no-undo.
  define variable v-host-code         as integer              no-undo.
  define variable vv-exch-rate  as decimal   no-undo .
  define variable vv-exch-scale as decimal   no-undo .

  { gbl/hostcode.i t-doc.obj-type  t-doc.obj-code  v-host-code  }
  { gbl/exchrate.i base-code today vv-exch-rate vv-exch-scale base-type }

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
/*  run torgconf-get-cli-param in this-procedure ( input t-doc.host-code, input t-doc.cli-type, input t-doc.cli-code, input v-curr-code) no-error.*/
/*  if error-status :error then do:*/
/*    message*/
/*      vss-workfile vss-revision vss-description  skip "Ошибка чтения параметров объекта клиента документа." skip return-value*/
/*      skip trim(error-status :get-message(1))    trim(error-status :get-message(2))   trim(error-status :get-message(3))*/
/*    view-as alert-box warning.*/
/*  end.*/


  find first our_object  where our_object.obj-type   = t-doc.obj-type and our_object.obj-code  = t-doc.obj-code  no-lock.
  find first our_host    where our_host.obj-type     = {&cmp}         and our_host.obj-code    = t-doc.host-code no-lock.
  find first buf_firm    where buf_firm.firm-code    = our_host.obj-code no-lock.
  find first buf_sysconf where buf_sysconf.host-code = buf_firm.firm-code  no-lock.

  if v-torgconf-self-schet-exists then do:
    PUT STREAM Out_Stream
      space(9)  string ( "Поставщик: {&abbr_inn_allshift} " + v-torgconf-self-host-inn + " , {&abbr_kpp_allshift} " + v-torgconf-self-host-kpp + " " + v-torgconf-self-host-name ) format "X(130)" SKIP
      space(9)  string ( "Адрес: " + v-torgconf-self-host-addres ) format "X(130)" SKIP
      space(9)  string ( "Телефон, факс: " + v-torgconf-self-host-phone ) format "X(130)" SKIP
      space(9)  string ( "Реквизиты банка: " + v-torgconf-self-bank-name + " " + v-torgconf-self-bank-addres ) format "X(130)" SKIP
      space(26) string ( "р/c " + v-torgconf-self-bank-r-schet ) format "X(130)" SKIP
      space(26) string ( "БИК " + v-torgconf-self-bank-bik ) format "X(130)" SKIP
      space(26) string ( "к/c " + v-torgconf-self-bank-c-schet ) format "X(130)" SKIP
    .
  end.
  else do:
    PUT STREAM Out_Stream
      space(9)  string ( "Поставщик: {&abbr_inn_allshift} " + v-torgconf-self-host-inn + " , {&abbr_kpp_allshift} " + v-torgconf-self-host-kpp + " " + v-torgconf-self-host-name ) format "X(130)" SKIP
      space(9)  string ( "Адрес: " + v-torgconf-self-host-addres ) format "X(130)" SKIP
      space(9)  string ( "Телефон, факс: " + v-torgconf-self-host-phone ) format "X(130)" SKIP
      space(9)  string ( "Реквизиты банка: "  ) format "X(130)" SKIP
    .
  end.

  PUT STREAM Out_Stream " " SKIP .

  FIND cli-obj WHERE cli-obj.obj-type = t-doc.cli-type AND cli-obj.obj-code = t-doc.cli-code NO-LOCK .
  PUT STREAM Out_Stream   ( /*if  t-doc.status_ = {&inquiry} and v-sys-key <> "PeacHom" then " З А П Р О С   N " else*/ "С Ч Е Т       N " ) AT 32
                       format "X(17)"  t-doc.doc-code format "X(14)" "  от  " t-doc.doc-date format "99.99.9999" SKIP .

  PUT STREAM Out_Stream " " SKIP .

  PUT STREAM Out_Stream SPACE(9) "Плательщик   : " + cli-obj.obj-name + "(" + string(cli-obj.obj-code) + ")" format "X(102)" SKIP .

  /* печать вида платежа и примечания */
  Find buf_pay-type Where buf_pay-type.Obj-code = T-doc.Pay-code No-lock No-error.
/*    Put Stream Out_Stream String( {&type-pay} + ( If Available Pay-type Then Pay-type.Obj-name Else "?" ) ) At 10 Format "X(60)" Skip .*/
  Put Stream Out_Stream String( "вид оплаты : " + ( If Available buf_pay-type Then buf_pay-type.Obj-name Else "?" ) ) At 10 Format "X(60)" Skip .
  If V-torgconf-outprim = No Then Do:
    Put Stream Out_Stream  String( "примечание : " + ( If ( Not Can-do( {&fact}, T-doc.Status_ ) Or Logres ) And Not ( T-doc.Ps Begins "@" ) Then  T-doc.Ps Else " " ) ) At 10 Format "X(100)" Skip .
/*      Put Stream Out_Stream  String( {&note2} + ( If ( Not Can-do( {&fact}, T-doc.Status_ ) Or Logres ) And Not ( T-doc.Ps Begins "@" ) Then  T-doc.Ps Else " " ) ) At 10 Format "X(100)" Skip .*/
  End.

  PUT STREAM Out_Stream SPACE(9) string("Срок оплаты счета: " + ( if v-cntxp-rsrv-time = 0 then "2" else string(v-cntxp-rsrv-time, ">>9") ) + " дней.") format "X(102)" SKIP .


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


  if prn_NP then do: /* с НП */
    if not PrintRubl then form with frame val .
    else                  form with frame rubl .
    form header
      Line format "X(134)" at 1 skip
      "Продолжение - на следующей странице" at 30 skip
      with frame BottomframeNp width {&DOS_CW_2} page-bottom no-labels no-box .
      view stream Out_stream frame BottomframeNp .
  end.
  else do:
    if not PrintRubl then form with frame val1 .
    else                  form with frame rubl1 .
    form header
      Line format "X(119)" at 1 skip
      "Продолжение - на следующей странице" at 30 skip
      with frame Bottomframe width {&DOS_CW_2} page-bottom no-labels no-box .
      view stream Out_stream frame Bottomframe .
  end.

  if can-do( {&wayb} , t-doc.status_ ) and ( not t-doc.flag_ ) then
    put stream Out_stream "----------   Т Е С Т О В А Я   П Е Ч А Т Ь   ----------"  at 31 format "X(60)" skip(1) .

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

  if can-do( {&fact} , t-doc.status_ ) or
     ( can-do( {&expense} , t-doc.doc-type ) and can-do( {&wayb_inquiry} , t-doc.status_ ) and
     ( not t-doc.internal ) )
  then do:
    if not PrintRubl then run rep/wp.p (     input ParParentProc, input all-stoim, output s1, output s2 ) .
    else                  run rep/wp-rub.p ( input all-stoim, output s1, output s2 ) .
    if can-do( {&return} , t-doc.doc-type ) then put stream Out_stream space(5) "Итого " format "x(6)" .
    else                                         put stream Out_stream space(5) "Всего на сумму: " format "x(17)" .

    put stream Out_stream  all-stoim format "->>>,>>>,>>>,>>9.99" space(1) trim(s2) format "x(4)".
    put stream Out_stream skip space(5)  caps(s1) format "x(126)" skip .

    if not t-doc.internal and not CostPrice then do:
      put stream Out_stream space(5)  "в том числе: " format "x(13)" .

      if v-torgconf-outdisc = no then do:    /* скидку - показать ! */
        put stream Out_stream space(1) "Скидка " format "x(8)"
          ( if t-doc.tot-calc <> 0 and t-doc.discnt-pc = 0  then " " else string( string( t-doc.discnt-pc, "->>9.9" ) + "%" ) )
          space(2) "на сумму" format "x(10)"
          space(2) ( if not PrintRubl then t-doc.tot-calc else t-doc.discnt-rubl )  format "->>>,>>>,>>>,>>9.99"
          space(2) ( if not PrintRubl then base-type else "{&abbr_rub_allshift}" )  format "x(4)" skip .
      end.
      else put stream Out_stream " " skip .
      if PrintRubl then do:
        if all-VAT-sum <> ? and all-VAT-sum > 0 then
          put stream Out_stream string( "НДС: " + string( all-VAT-sum , "->>>,>>>,>>9.99" ) + "{&abbr_rub_allshift}" ) at 20 format "x(50)" skip .
        if prn_NP and all-slt-sum <> ? and all-slt-sum > 0  then /* с НП */
          put stream Out_stream string( "налог с продаж: " + string( all-SLT-sum, "->>>,>>>,>>9.99" ) + "{&abbr_rub_allshift}") at 20 format "x(50)" skip .

      end.
      else do:
        if all-vat-sum <> ? and all-vat-sum > 0 then
          put stream Out_stream string( "НДС: " + string( all-VAT-sum , "->>>,>>>,>>9.99" ) + base-type) at 20 format "x(50)" skip .
        if prn_NP and all-slt-sum <> ? and all-slt-sum > 0  then  /* с НП */
          put stream Out_stream string( "налог с продаж: " + string( all-SLT-sum, "->>>,>>>,>>9.99" ) + base-type) at 20 format "x(50)" skip .

      end.
    end.
  end.

  if can-do( {&expense} , t-doc.doc-type ) and ( not t-doc.internal ) and ( ( can-do( {&inquiry} , t-doc.status_ )
          or ( can-do( {&wayb} , t-doc.status_ ) and t-doc.flag_ ) ) ) or t-doc.status_ = {&fact}
  then do:
    put stream Out_stream  skip(2) space(10)
      "Руководитель предприятия: ___________________ / " buf_firm.director      format "X(20)"
      " /   Главный бухгалтер: __________________ /"     buf_sysconf.snr-accnt  format "X(20)"  " /" skip(1) .
  end.
  else do:
                put stream Out_stream
                    space(30) "--- Н Е   П О Д П И С Ы В А Т Ь ! ---" format "X(75)" skip(1) .
  end.

  hide stream Out_stream frame Bottomframe .

  output stream Out_stream close.

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
    if prn_NP then do: /* с НП */
      if PrintRubl then do:    { rep/r-outrt1.i rubl "r-schet1" }    end.
      else do:                 { rep/r-outrt1.i val "r-schet1" }     end.
    end.
    else do:
      if PrintRubl then do:   { rep/r-outrt1.i rubl1 "r-schet1" }     end.
      else do:                { rep/r-outrt1.i val1 "r-schet1" }      end.
    end.
  end.
end procedure. /* print-line */