block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-act-kg.p $
$Archive: rep/r-act-kg.p $

Печать акта и протокола переоценки топлива в кг (весовой учет топлива)

Автор: Булгаков Андрей Николаевич
Дата создания: 05/25/05
Author: Andrew Bulgakoff
Creation date: 05/25/05

*/

&scop f-l Word-Sum,Total-Word,RedLine,Roubles,Copecks
&scop def def "'r-act-kg.log'"

define input parameter parparentproc     as widget-handle no-undo.
define input parameter p-rec_id          as recid         no-undo.
define input parameter p-doc-type        as character     no-undo. /* act - акт, ord - приказ */
define input parameter p-price-celection as integer       no-undo.
define input parameter p-print-null-qnty as logical       no-undo.
define input parameter p-sort-by-group   as logical       no-undo.

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      as character no-undo initial "$Author: expertek $":U.
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: r-act-kg.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/r-act-kg.p $":U.
define variable vss-description as character no-undo initial "Печать акта и протокола переоценки топлива в кг (весовой учет топлива)":U.

{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ gbl/cur-time.i        }
{ cmp/r-pril.i     new  }
{ cmp/croslist.i        }
{ str/hvrdtax.i         }
{ gbl/tax-name.i        }
{ gbl/dtm.i             }
{ str/writelog.i {&def} }
{ gbl/waitfram.i        }
{ str/lib-trn.i         }
{ gbl/std-func.i {&f-l} }
{ gbl/getcntxt.i def    }
{ gbl/getcntxt.i get    }
{ str/getctxtp.i def    }
{ str/getctxtp.i get    }

define variable g#report-num  as integer   no-undo.
define variable g#quest-print as logical   no-undo.
define variable g#log         as logical   no-undo.
define variable base-code     as integer   no-undo.
define variable base-type     as character no-undo.
define variable base-part     as character no-undo.
define variable v-cntxt-host-name-obj as character no-undo .

define buffer buf_clients    for ub.clients.
define buffer buf_price-list for ub.price-list.

define variable v-old-sum                    as   decimal                   no-undo.
define variable v-new-sum                    as   decimal                   no-undo.
define variable v-del-sum                    as   decimal                   no-undo.
define variable v-up-fact                    as   decimal                   no-undo.
define variable propis                       as   character                 no-undo.
define variable abbr                         as   character                 no-undo.
define variable v-single-line                as   character                 no-undo.
define variable v-b-code                     as   character                 no-undo.
define variable v-line-counter               as   integer                   no-undo.
define variable v-good-line-counter          as   integer                   no-undo.
define variable Log-Res1                     as   logical                   no-undo.
define variable v-print-cost-price           as   logical                   no-undo.
define variable v-shift-down                 as   logical                   no-undo initial yes.
define variable v-print-group                as   logical                   no-undo initial yes.
define variable v-price-doc_doc-num          like ub.price-doc.doc-num      no-undo.
define variable v-price-doc_doc-date         like ub.price-doc.doc-date     no-undo.
define variable v-trn-doc_doc-code           like ub.trn-doc.doc-code       no-undo.
define variable v-main-price-sale            like ub.price-list.price-sale  no-undo.
define variable v-rb-is-base                 as   logical                   no-undo.
define variable sym1                         as   character format "x(1)":U no-undo initial ":" column-label ":!:".
define variable sym2                         as   character format "x(1)":U no-undo initial ":" column-label ":!:".
define variable sym3                         as   character format "x(1)":U no-undo initial ":" column-label ":!:".
define variable sym4                         as   character format "x(1)":U no-undo initial ":" column-label ":!:".
define variable sym5                         as   character format "x(1)":U no-undo initial ":" column-label ":!:".
define variable sym6                         as   character format "x(1)":U no-undo initial ":" column-label ":!:".
define variable is-petrol                    as   logical                   no-undo.
define variable is-pieces                    as   logical                   no-undo.
define variable v-have-petrolium             as   logical                   no-undo.
define variable v-price-list_doc-qnty        like ub.price-list.doc-qnty    no-undo.
define variable v-price-list_doc-num         like ub.price-list.doc-num     no-undo.
define variable v-price-list_road-tax        like ub.price-list.road-tax    no-undo.
define variable v-price-list_excise          like ub.price-list.excise      no-undo.
define variable v-price-list_price-sale_old  like ub.price-list.price-sale  no-undo.
define variable v-price-list_price-sale_new  like ub.price-list.price-sale  no-undo.
define variable v-price-list_b-code          like ub.bar-code.b-code        no-undo.
define variable v-gds-obj_last-price         like ub.gds-obj.last-rubl      no-undo.
define variable v-gds-prt-node_code          like ub.gds-prt.node-code      no-undo.
define variable v-gds-prt-node_name          like ub.gds-prt.node-name      no-undo.
define variable v-code-is-main               as   logical                   no-undo.
define variable v-not-main-unit-cli          like ub.bar-code.unit-cli      no-undo.
define variable v-not-main-cli-base-rate     like ub.bar-code.cli-base-rate no-undo.
define variable v-not-main-b-code            like ub.bar-code.cli-base-rate no-undo.
define variable v-taxname                    as   character                 no-undo.
define variable v-tax                        as   decimal                   no-undo initial 0.
define variable v-tax-sum                    as   decimal                   no-undo initial 0.
define variable v-tax-parts-qnty             as   decimal                   no-undo initial 0.
define variable v-cli-base-rate              as   decimal                   no-undo initial 0.
define variable j-counter                    as   integer                   no-undo initial 0.
define variable v-print-rubl                 as   logical                   no-undo.
define variable v-price-list-recid           as   recid                     no-undo.
define variable v-total_doc-qnty             like ub.price-list.doc-qnty    no-undo initial 0.
define variable v-total_price-sale_old       like ub.price-list.price-sale  no-undo initial 0.
define variable v-total_price-sale_new       like ub.price-list.price-sale  no-undo initial 0.
define variable v-total_last-price-sale      like ub.gds-obj.last-rubl      no-undo initial 0.
define variable v-total_price-sale_diff      like ub.price-list.price-sale  no-undo initial 0.
define variable v-price-list_price-sale_diff like ub.price-list.price-sale  no-undo.
define variable v-parts_road-tax-rubl        like ub.price-list.price-sale  no-undo.

define stream AktStr.

define frame Prik
  sym1 v-good-line-counter         column-label "N!п/п"             format ">>>9":U
  sym2 v-b-code                    column-label "Код! "             format "x({&BarCode_Length})":U
  sym3 ub.price-list.artic         column-label "Артикул! "         format "x(16)":U
  sym4 ub.goods.gds-name           column-label "Название товара! " format "x(33)":U
  sym5 ub.price-list.doc-qnty      column-label "Количество  ! "    format "->>>>>>>9.<<":U
       v-price-list_price-sale_old column-label "Старая прод.!цена" format "->>>,>>>,>>9.99":U
       ub.price-list.price-sale    column-label "Новая прод.!цена"  format "->>>,>>>,>>9.99":U
       v-up-fact                   column-label "Процент!разницы"   format "->>>>>>>9.9%":U         sym6
header cur-time-print( ) at 5 format "x(35)":U string( "Приказ на переоценку " ) at 47 format "x(25)":U
       v-price-doc_doc-num format "x(10)":U " от " v-price-doc_doc-date format "99/99/9999":U
       string( "Страница " + string( PAGE-NUMBER( AktStr ), ">>9":U ) ) at 120 format "x(13)":U skip
       v-single-line at 1 format "x({&A4_CW0})":U
with width {&A4_CW} down stream-io use-text.

define frame Prik-Cost
  sym1 v-b-code                 column-label "Код! "                format "x({&BarCode_Length})":U
       ub.price-list.artic      column-label "Артикул! "            format "x(16)":U
  sym4 ub.goods.gds-name        column-label "Название товара! "    format "x(42)":U
  sym5 ub.price-list.doc-qnty   column-label "Количество  ! "       format "->>>>>>>9.<<":U
       v-gds-obj_last-price     column-label "Последняя учет.!цена" format "->>>,>>>,>>9.99":U
       ub.price-list.price-sale column-label "Новая прод.!цена"     format "->>>,>>>,>>9.99":U
       v-up-fact                column-label "Процент!разницы"      format "->>>>>>>9.9%":U         sym6
header cur-time-print( ) at 5 format "x(35)":U
       string( "Приказ на переоценку " ) at 47 format "x(25)":U v-price-doc_doc-num format "x(10)":U " от " v-price-doc_doc-date format "99/99/9999":U
       string( "Страница " + string( PAGE-NUMBER( AktStr ), ">>9":U ) ) at 120 format "x(13)":U skip
       v-single-line format "x({&A4_CW0})":U at 1
with width {&A4_CW} down stream-io use-text.

define frame Akt
  sym1 v-b-code                    column-label "Код! "                  format "x({&BarCode_Length})":U
       ub.price-list.artic         column-label "Артикул! "              format "x(16)":U
       ub.goods.gds-name           column-label "Название товара! "      format "x(21)":U
       ub.price-list.doc-qnty      column-label "Количество! "           format "->>>>>9.<<":U
       v-price-list_price-sale_old column-label "Старая прод.!цена"      format "->>>>>>>9.99":U
       v-old-sum                   column-label "Старая сумма!прод. цен" format "->>>>>>>>>>>9.99":U
       ub.price-list.price-sale    column-label "Новая прод.!цена"       format "->>>>>>>9.99":U
       v-new-sum                   column-label "Новая сумма!прод. цен"  format "->>>>>>>>>>9.99":U
       v-up-fact                   column-label "Процент!разницы"        format "->>>>>>>9.9%":U         sym6
header cur-time-print( ) at 5 format "x(35)":U
       string( "Акт переоценки " ) at 50 format "x(20)":U v-price-doc_doc-num format "x(10)":U " от " v-price-doc_doc-date format "99/99/9999":U
       string( "Страница " + string( PAGE-NUMBER( AktStr ), ">>9":U ) ) at 120 format "x(13)":U skip
       v-single-line format "x({&A4_CW0})":U at 1
with width {&A4_CW} down stream-io use-text.

define frame Akt-Cost
  sym1 v-b-code                 column-label "Код! "               format "x({&BarCode_Length})":U
       ub.price-list.artic      column-label "Артикул! "           format "x(16)":U
       ub.goods.gds-name        column-label "Название товара! "   format "x(22)":U
       ub.price-list.doc-qnty   column-label "Количество! "        format "->>>>>9.<<":U
       v-gds-obj_last-price     column-label "Последняя уч.!цена"  format "->>>>>>>>9.99":U
       v-old-sum                column-label "Сумма учет.!цен"     format "->>>>>>>>>9.99":U
       ub.price-list.price-sale column-label "Новая прод.!цена"    format "->>>>>>>>9.99":U
       v-new-sum                column-label "Новая сумма!пр. цен" format "->>>>>>>>>9.99":U
       v-up-fact                column-label "Процент!разницы"     format "->>>>>>>9.9%":U         sym6
header cur-time-print( ) at 5 format "x(35)":U
       string( "Акт переоценки " ) at 50 format "x(20)":U v-price-doc_doc-num format "x(10)":U " от " v-price-doc_doc-date format "99/99/9999":U
       string( "Страница " + string( PAGE-NUMBER( AktStr ), ">>9":U ) ) at 120 format "x(13)":U skip
       v-single-line format "x({&A4_CW0})":U at 1
with width {&A4_CW} down stream-io use-text.

do on error undo, return error :
  { gbl/working.i }

define buffer buf_rep_currency for ub.currency.
{ gbl/hostname.i v-cntxt-obj-type v-cntxt-obj-code v-cntxt-host-code-obj v-cntxt-host-name-obj }
{ gbl/basecode.i v-cntxt-host-code-obj base-code }

find first buf_rep_currency no-lock where
           buf_rep_currency.curr-code = base-code
           no-error .
  if available buf_rep_currency
    then do:
      assign
        base-type = buf_rep_currency.curr-abbr
        base-part = buf_rep_currency.part-abbr
      .
    end.
    else do:
      assign
        base-type = "б.в."
        base-part = ""
      .
    end.
run get-report-num  in parparentproc ( output g#report-num ).
run get-quest-print in parparentproc ( output g#quest-print ) .

  { gbl/rbisbase.i v-rb-is-base }
  assign v-print-rubl = ( v-rb-is-base = no ).
  find first ub.price-doc no-lock where recid( ub.price-doc ) = p-rec_id no-error.
  if not available ub.price-doc then do:
    message 'Порушена табличка "price-doc" (r-act-kg.p).' view-as alert-box error.
    return error.
  end.
  assign v-have-petrolium = no.
  for each ub.price-list no-lock where ub.price-list.doc-num = ub.price-doc.doc-num :
    { str/is-petrl.i ub.price-list.artic
                 ub.price-list.prod-type
                 ub.price-list.prod-code
                 is-petrol
                 is-pieces               no-error }
    if error-status :error or is-petrol <> yes or is-pieces <> no then do: next. end.
    assign v-have-petrolium = yes.
    leave.
  end. /* for each ub.price-list */
  if v-have-petrolium <> yes then do:
    message "Нет топливных товаров (r-act-kg.p)." view-as alert-box error.
    return.
  end.
  assign v-price-doc_doc-num  = ub.price-doc.doc-num
         v-price-doc_doc-date = ub.price-doc.doc-date.
  find ub.clients no-lock where
       ub.clients.obj-code = ub.price-doc.obj-code and
       ub.clients.obj-type = ub.price-doc.obj-type.
  if not available ub.clients then do:
    message 'Порушена табличка "ub.clients" (r-act-kg.p).' view-as alert-box error.
    return error.
  end.

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_overvalue-cast_print':U
    {&cntxt-firm}
    v-cntxt-host-code-obj
    '':U
    0
    0
    0
    0
    false
    Log-Res1
  }

  if ( price-doc.status_ = {&act-overvalue} ) or Log-Res1 = yes then do:
    assign v-print-cost-price = ( if p-price-celection = 2 then yes else no ).
  end.
  find ub.trn-doc no-lock where ub.trn-doc.doc-code = ub.price-doc.doc-num no-error.
  assign v-single-line = fill( "-", {&A4_CW0} ).

  { cmp/open-out.i stream AktStr }

  find buf_clients no-lock where
       buf_clients.obj-type = {&cmp} and
       buf_clients.obj-code = ub.price-doc.host-code.
  put stream AktStr space( 50 ) buf_clients.obj-name format "x(70)":U skip( 2 ).

  os-delete log-file-name.
  run writelog in this-procedure ( input log-file-name, input 0, input "&Line" ).

  if ub.price-doc.status_ = {&act-overvalue} then do:
    put stream AktStr space( 25 ) string( "А К Т  переоценки  по  остаткам  " +
      ( if available ub.trn-doc then string( "документу N " + ub.trn-doc.doc-code + "  по  " )
                                else " " ) + ub.clients.obj-name ) format "x(90)":U skip( 1 ).
    run writelog in this-procedure ( input log-file-name, input 1, input "Печать акта № " + string( ub.price-doc.doc-num )
                                   + " по док-ту № " + "  от  " + string( ub.price-doc.doc-date, "99.99.9999":U )
                                   + "  по  " + ub.clients.obj-name ).
  end.
  else do:
    put stream AktStr space( 20 ) string( "П Р И К А З   о  переоценке  товаров  " +
      ( if available ub.trn-doc then string( "по документу N " + ub.trn-doc.doc-code )
                                else " " ) + "  в  " + ub.clients.obj-name ) format "x(110)":U skip( 1 ).
    run writelog in this-procedure ( input log-file-name, input 1, input "Печать приказа № " + string( ub.price-doc.doc-num )
                                   + " по док-ту № " + "  от  " + string( ub.price-doc.doc-date, "99.99.9999":U )
                                   + "  в  " + ub.clients.obj-name ).
  end.
  put stream AktStr "Номер " ub.price-doc.doc-num "  от  " ub.price-doc.doc-date format "99.99.9999":U skip( 1 ).

  form header v-single-line format "x({&A4_CW0})":U at  1 skip
              "Продолжение - на следующей странице" at 30 skip
  with frame Bottomframe width {&A4_CW} page-bottom no-labels no-box.
  view stream AktStr frame bottomframe.

  if ub.price-doc.status_ = {&act-overvalue} then do:
    run writelog in this-procedure ( input log-file-name, input 1, input "Документ закрыт до факта" ).
    if v-print-cost-price = yes then do: form with frame Akt-Cost. end.
                                else do: form with frame Akt.      end.
    if p-sort-by-group = yes then do:
      run writelog in this-procedure ( input log-file-name, input 1, input "Включена сортировка по группам" ).
      for each ub.price-list no-lock where ub.price-list.doc-num = ub.price-doc.doc-num
        , each ub.goods      no-lock where ub.goods.artic        = ub.price-list.artic             and
                                           ub.goods.prod-type    = ub.price-list.prod-type         and
                                           ub.goods.prod-code    = ub.price-list.prod-code
      break by ub.goods.grp-name
            by ub.goods.artic    descending
      :
        { str/is-petrl.i ub.goods.artic
                     ub.goods.prod-type
                     ub.goods.prod-code
                     is-petrol
                     is-pieces          no-error }
        if error-status :error or is-petrol <> yes or is-pieces <> no then do: next. end.

        assign v-print-group = ( if first-of( ub.goods.grp-name ) then yes else no ).
        { rep/r-act-kg.i calc act }
        if v-code-is-main = yes then do:
          run writelog in this-procedure ( input log-file-name, input 2, input "Основной код. Собираем количества и суммы" ).
          assign v-price-list_price-sale_diff = v-price-list_price-sale_new - v-price-list_price-sale_old.
          assign v-total_doc-qnty        = v-total_doc-qnty        + v-price-list_doc-qnty
                 v-total_price-sale_old  = v-total_price-sale_old  + v-price-list_doc-qnty * v-price-list_price-sale_old
                 v-total_price-sale_new  = v-total_price-sale_new  + v-price-list_doc-qnty * v-price-list_price-sale_new
                 v-total_last-price-sale = v-total_last-price-sale + v-price-list_doc-qnty * v-gds-obj_last-price
                 v-total_price-sale_diff = v-total_price-sale_diff + v-price-list_doc-qnty * v-price-list_price-sale_diff.
          run print-line-fact in this-procedure.
          if last-of( ub.goods.grp-name ) and not last( ub.goods.grp-name ) then do:
            put stream AktStr v-single-line format "x({&A4_CW0})":U at 1.
          end.
        end. /* if v-code-is-main */
      end. /* for each ub.price-list */
    end. /* if p-sort-by-group = yes */
    else do:
      run writelog in this-procedure ( input log-file-name, input 1, input "Сортировка по группам выключена" ).
      for each ub.price-list no-lock where ub.price-list.doc-num = ub.price-doc.doc-num
        , each ub.goods      no-lock where ub.goods.artic        = ub.price-list.artic     and
                                           ub.goods.prod-type    = ub.price-list.prod-type and
                                           ub.goods.prod-code    = ub.price-list.prod-code
      break by ub.goods.artic descending
      :
        { rep/r-act-kg.i calc act }
        if v-code-is-main = yes then do:
          run writelog in this-procedure ( input log-file-name, input 2, input "Основной код. Собираем количества и суммы" ).
          assign v-price-list_price-sale_diff = v-price-list_price-sale_new - v-price-list_price-sale_old.
          assign v-total_doc-qnty        = v-total_doc-qnty        + v-price-list_doc-qnty
                 v-total_price-sale_old  = v-total_price-sale_old  + v-price-list_doc-qnty * v-price-list_price-sale_old
                 v-total_price-sale_new  = v-total_price-sale_new  + v-price-list_doc-qnty * v-price-list_price-sale_new
                 v-total_last-price-sale = v-total_last-price-sale + v-price-list_doc-qnty * v-gds-obj_last-price
                 v-total_price-sale_diff = v-total_price-sale_diff + v-price-list_doc-qnty * v-price-list_price-sale_diff.
          run print-line-fact in this-procedure.
        end. /* if v-code-is-main */
      end. /* for each ub.price-list */
    end.

    put stream AktStr v-single-line format "x({&A4_CW0})":U skip.
    if v-print-cost-price = yes then do:
      display stream AktStr "Итого" format "x(8)":U @ ub.goods.gds-name
                            v-total_doc-qnty        @ ub.price-list.doc-qnty
                            v-total_last-price-sale @ v-old-sum
                            v-total_price-sale_new  @ v-new-sum
                  ( 100 * ( v-total_price-sale_new  / v-total_last-price-sale - 1 ) ) when round( v-total_last-price-sale, 2 ) <> 0
                                                    @ v-up-fact
      with frame Akt-Cost.
      underline stream AktStr ub.price-list.doc-qnty
                              v-old-sum
                              v-new-sum
                              v-up-fact
      with frame Akt-Cost.
    end.
    else do:
      display stream AktStr "Итого" format "x(8)":U @ ub.goods.gds-name
                            v-total_doc-qnty        @ ub.price-list.doc-qnty
                            v-total_price-sale_old  @ v-old-sum
                            v-total_price-sale_new  @ v-new-sum
                  ( 100 * ( v-total_price-sale_new  / v-total_price-sale_old - 1 ) ) when round( v-total_price-sale_old, 2 ) <> 0
                                                    @ v-up-fact
      with frame Akt.
      underline stream AktStr ub.price-list.doc-qnty
                              v-old-sum
                              v-new-sum
                              v-up-fact
      with frame Akt.
    end.

    hide stream AktStr frame Bottomframe.

    if v-print-cost-price <> yes then do:
      if v-rb-is-base = yes then do:
        assign propis = Total-Word(          absolute( v-total_price-sale_diff ), base-type, base-part )
               abbr   = base-type.
      end.                  else do:
        assign propis = Total-Word(          absolute( v-total_price-sale_diff ),
                                    Roubles( absolute( v-total_price-sale_diff ) ),
                                    Copecks( absolute( v-total_price-sale_diff ) ) )
               abbr   = " {&abbr_rub}.".
      end.

      if line-counter( AktStr ) + 9 > page-size( AktStr ) then do: page stream AktStr. end.
      put stream AktStr skip space( 10 ) "Cумма переоценки: " format "x(18)":U
        v-total_price-sale_diff format "->>>>>>>>9.99":U
        space( 1 ) ( if v-rb-is-base = yes then "баз.вал" else "{&abbr_rub}" ) format "x(3)":U " (" format "x(2)":U.
      if v-total_price-sale_diff < 0 then do: put stream AktStr "Минус " format "x(6)":U. end.
      put stream AktStr
        ( if trim( propis ) begins abbr then string( "0 " + propis + ")" ) else string( propis + ")" ) ) format "x(95)":U.
    end.
    put stream AktStr skip( 2 ) space( 10 ) "Зав. складом : " format "x(25)":U skip.
  end. /* if ub.price-doc.status_ = {&act-overvalue} */
  else do: /* if ub.price-doc.status_ <> {&act-overvalue} */
    run writelog in this-procedure ( input log-file-name, input 1, input "Документ не закрыт до акта" ).
    if v-print-cost-price = yes then do: form with frame Prik-Cost. end.
                                else do: form with frame Prik.      end.
    if p-sort-by-group = yes then do:
      for each ub.price-list no-lock where ub.price-list.doc-num = ub.price-doc.doc-num
        , each ub.goods      no-lock where ub.goods.artic        = ub.price-list.artic     and
                                           ub.goods.prod-type    = ub.price-list.prod-type and
                                           ub.goods.prod-code    = ub.price-list.prod-code
      break by ub.goods.grp-name
            by ub.goods.artic    descending
            by ub.goods.gds-code descending
      :
        { rep/r-act-kg.i calc ord }
        if v-code-is-main = yes then do: run print-line-no-fact in this-procedure. end.
      end. /* for each ub.price-list */
    end.
    else do:
      for each ub.price-list no-lock where ub.price-list.doc-num = ub.price-doc.doc-num
        , each ub.goods      no-lock where ub.goods.artic        = ub.price-list.artic     and
                                           ub.goods.prod-type    = ub.price-list.prod-type and
                                           ub.goods.prod-code    = ub.price-list.prod-code
      break by ub.goods.artic    descending
            by ub.goods.gds-code descending
      :
        { rep/r-act-kg.i calc ord }
        if v-code-is-main = yes then do: run print-line-no-fact in this-procedure. end.
      end. /* for each ub.price-list */
    end.

    hide stream AktStr frame Bottomframe.

    if line-counter( AktStr ) + 6 > page-size( AktStr ) then do: page stream AktStr. end.
    put stream AktStr v-single-line format "x({&A4_CW0})":U skip( 2 )
      space( 10 ) "Всего  " v-good-line-counter format ">>>>9":U " наименований." format "x(15)":U skip( 2 )
      space( 10 ) "Директор :  " format "x(60)":U "Главный бухгалтер :  " format "x(70)":U skip.
  end. /* if ub.price-doc.status_ <> {&act-overvalue} */

  output stream AktStr close.
  { gbl/stopwork.i   }
  { rep/q-print.i  4 }
end. /* on error */

procedure print-line-fact :
  define variable v-out-log-string as character no-undo.

  do on error undo, return error :
    run writelog in this-procedure ( input log-file-name, input 1, input "Вызов программы печати строки АКТА" ).
    if not can-find( first ub.gds-prt where ub.gds-prt.upper-code = v-gds-prt-node_code ) then do: /* пустая шкала */
      run writelog in this-procedure ( input log-file-name, input 2, "Пустая шкала" ).
      if ( ub.price-list.doc-qnty <> 0 ) or ( p-print-null-qnty = yes ) then do:
        assign v-out-log-string = "Количество по документу > 0 ( = " + string( ub.price-list.doc-qnty ) + " ) " +
                                  "или включена печать нулевого количества ( " + string( p-print-null-qnty ) + " )".
        run writelog in this-procedure ( input log-file-name, input 3, input v-out-log-string ).
        if v-print-cost-price = yes then do:
          run writelog in this-procedure ( input log-file-name, input 4, input "Включена печать по учетным ценам" ).
          if p-sort-by-group = yes then do:
            { rep/r-act-kg.i group cost }
          end.
          display stream AktStr
                  sym1  trim( string( ub.bar-code.b-code ) )                                 @ v-b-code
                          ub.price-list.artic
                          v-gds-prt-node_name                                                @ ub.goods.gds-name
                          v-price-list_doc-qnty       when v-price-list_doc-qnty <> ?        @ ub.price-list.doc-qnty
                          v-price-list_price-sale_new                                        @ ub.price-list.price-sale
                        ( v-price-list_doc-qnty       * v-price-list_price-sale_new )        @ v-new-sum
                          v-gds-obj_last-price
                        ( v-price-list_doc-qnty       * v-gds-obj_last-price        )        @ v-old-sum
                  100 * ( v-price-list_price-sale_new / v-gds-obj_last-price - 1    )
                                                      when v-gds-obj_last-price <> 0         @ v-up-fact sym6
          with frame Akt-Cost.
          down stream AktStr 1 with frame Akt-Cost.
          { rep/r-act-kg.i third-tax fact cost }
        end.
        else do:
          run writelog in this-procedure ( input log-file-name, input 4, input "Печать по учетным ценам выключена" ).
          if p-sort-by-group = yes then do:
            { rep/r-act-kg.i group }
          end.
          display stream AktStr
                  sym1  trim( string( ub.bar-code.b-code ) )                                 @ v-b-code
                          ub.price-list.artic
                          v-gds-prt-node_name                                                @ ub.goods.gds-name
                          v-price-list_doc-qnty       when v-price-list_doc-qnty <> ?        @ ub.price-list.doc-qnty
                          v-price-list_price-sale_old
                        ( v-price-list_doc-qnty   * v-price-list_price-sale_old      )       @ v-old-sum
                          v-price-list_price-sale_new                                        @ ub.price-list.price-sale
                        ( v-price-list_doc-qnty   * v-price-list_price-sale_new      )       @ v-new-sum
                  100 * ( v-price-list_price-sale_diff / v-price-list_price-sale_old )
                                                      when v-price-list_price-sale_old <> 0  @ v-up-fact sym6
          with frame Akt.
          down stream AktStr 1 with frame Akt.
          { rep/r-act-kg.i third-tax fact sale }
        end.
      end.
    end. /* пустая шкала */
    else do:  /* Не пустая шкала */
      run writelog in this-procedure ( input log-file-name, input 2, input "Не пустая шкала" ).
      if ( price-list.doc-qnty <> 0 ) or ( p-print-null-qnty ) then do:
        assign v-out-log-string = "Количество по документу > 0 ( = " + string( ub.price-list.doc-qnty ) + " ) " +
                                  "или включена печать нулевого количества ( " + string( p-print-null-qnty ) + " )".
        run writelog in this-procedure ( input log-file-name, input 3, input v-out-log-string ).
        if v-print-cost-price = yes then do:
          run writelog in this-procedure ( input log-file-name, input 4, input "Включена печать по учетным ценам" ).
          display stream AktStr
                  sym1  trim( string( ub.bar-code.b-code ) )                                 @ v-b-code
                          ub.price-list.artic
                          v-gds-prt-node_name                                                @ ub.goods.gds-name
                          v-price-list_doc-qnty       when v-price-list_doc-qnty <> ?        @ ub.price-list.doc-qnty
                          v-gds-obj_last-price
                        ( v-price-list_doc-qnty       * v-gds-obj_last-price        )        @ v-old-sum
                          v-price-list_price-sale_new                                        @ ub.price-list.price-sale
                        ( v-price-list_doc-qnty       * v-price-list_price-sale_new )        @ v-new-sum
                  100 * ( v-price-list_price-sale_new / v-gds-obj_last-price - 1    )
                                                      when v-gds-obj_last-price <> 0         @ v-up-fact sym6
          with frame Akt-Cost.
          down stream AktStr 1 with frame Akt-Cost.
          { rep/r-act-kg.i third-tax fact cost }
        end.
        else do:
          run writelog in this-procedure ( input log-file-name, input 4, input "Печать по учетным ценам выключена" ).
          display stream AktStr
                  sym1  trim( string( ub.bar-code.b-code ) )                                 @ v-b-code
                          ub.price-list.artic
                          v-gds-prt-node_name                                                @ ub.goods.gds-name
                          v-price-list_doc-qnty       when v-price-list_doc-qnty <> ?        @ ub.price-list.doc-qnty
                          v-price-list_price-sale_old
                        ( v-price-list_doc-qnty        * v-price-list_price-sale_old )       @ v-old-sum
                          v-price-list_price-sale_new                                        @ ub.price-list.price-sale
                        ( v-price-list_doc-qnty        * v-price-list_price-sale_new )       @ v-new-sum
                  100 * ( v-price-list_price-sale_diff / v-price-list_price-sale_old )
                                                      when v-price-list_price-sale_old <> 0  @ v-up-fact sym6
          with frame Akt.
          down stream AktStr 1 with frame Akt.
          { rep/r-act-kg.i third-tax fact sale }
        end.
      end.
    end. /* Не пустая шкала */
  end. /* on error */
end procedure. /* print-line-fact */

procedure print-line-no-fact :
  do on error undo, return error :
    run writelog in this-procedure ( input log-file-name, input 1, input "Вызов программы печати строки НЕ АКТА" ).
    if not can-find( first ub.gds-prt where ub.gds-prt.upper-code = v-gds-prt-node_code ) then do: /* Пустая шкала */
      if v-print-cost-price = yes then do:
        if p-sort-by-group = yes then do:
          { rep/r-act-kg.i group cost }
        end.
        assign v-line-counter      = v-line-counter      + 1
               v-good-line-counter = v-good-line-counter + 1.
        display stream AktStr
                sym1 trim( string( ub.bar-code.b-code ) )                                 @ v-b-code
                     ub.price-list.artic
                sym4 v-gds-prt-node_name                                                  @ ub.goods.gds-name
                sym5 v-price-list_doc-qnty       when v-price-list_doc-qnty <> ?          @ ub.price-list.doc-qnty
                     v-gds-obj_last-price
                     v-price-list_price-sale_new                                          @ ub.price-list.price-sale
                     ( 100 * ( v-price-list_price-sale_new / v-gds-obj_last-price - 1 ) )
                                                 when v-gds-obj_last-price <> 0           @ v-up-fact sym6
        with frame Prik-Cost.
        down stream AktStr 1 with frame Prik-Cost.
        { rep/r-act-kg.i third-tax no-fact cost }
      end.
      else do:
        if p-sort-by-group = yes then do:
          { rep/r-act-kg.i group }
        end.
        assign v-line-counter      = v-line-counter      + 1
               v-good-line-counter = v-good-line-counter + 1.
        display stream AktStr
                sym1    v-good-line-counter
                sym2    trim( string( ub.bar-code.b-code ) )                                 @ v-b-code
                sym3    ub.price-list.artic
                sym4    v-gds-prt-node_name                                                  @ ub.goods.gds-name
                sym5    v-price-list_doc-qnty       when v-price-list_doc-qnty <> ?          @ ub.price-list.doc-qnty
                        v-price-list_price-sale_old
                        v-price-list_price-sale_new                                          @ ub.price-list.price-sale
                100 * ( v-price-list_price-sale_new / v-price-list_price-sale_old - 1 )
                                                    when v-price-list_price-sale_old <> 0    @ v-up-fact sym6
        with frame Prik.
        down stream AktStr 1 with frame Prik.
        { rep/r-act-kg.i third-tax no-fact sale }
      end.
    end.
    else do: /* Не пустая шкала */
      if v-print-cost-price = yes then do:
        if p-sort-by-group = yes then do:
          { rep/r-act-kg.i group cost }
        end.
        assign v-line-counter      = v-line-counter      + 1
               v-good-line-counter = v-good-line-counter + 1.
        display stream AktStr
                sym1    trim( string( ub.bar-code.b-code ) )                                 @ v-b-code
                        ub.price-list.artic
                sym4    v-gds-prt-node_name                                                  @ ub.goods.gds-name
                sym5    v-price-list_doc-qnty       when v-price-list_doc-qnty <> ?          @ ub.price-list.doc-qnty
                        v-gds-obj_last-price
                        v-price-list_price-sale_new                                          @ ub.price-list.price-sale
                100 * ( v-price-list_price-sale_new / v-gds-obj_last-price - 1 )
                                                    when v-gds-obj_last-price <> 0           @ v-up-fact sym6
        with frame Prik-Cost.
        down stream AktStr 1 with frame Prik-Cost.
        { rep/r-act-kg.i third-tax no-fact cost }
      end.
      else do:
        if p-sort-by-group = yes then do:
          { rep/r-act-kg.i group }
        end.
        assign v-line-counter      = v-line-counter      + 1
               v-good-line-counter = v-good-line-counter + 1.
        display stream AktStr
                sym1    v-good-line-counter
                sym2    trim( string( ub.bar-code.b-code ) )                                 @ v-b-code
                sym3    ub.price-list.artic
                sym4    v-gds-prt-node_name                                                  @ ub.goods.gds-name
                sym5    v-price-list_doc-qnty       when v-price-list_doc-qnty <> ?          @ ub.price-list.doc-qnty
                        v-price-list_price-sale_old
                        v-price-list_price-sale_new                                          @ ub.price-list.price-sale
                100 * ( v-price-list_price-sale_new / v-price-list_price-sale_old - 1 )
                                                    when v-price-list_price-sale_old <> 0    @ v-up-fact sym6
        with frame Prik.
        down stream AktStr 1 with frame Prik.
        { rep/r-act-kg.i third-tax no-fact sale }
      end.
    end. /* Не пустая шкала */
  end. /* on error */
end procedure. /* print-line-no-fact */