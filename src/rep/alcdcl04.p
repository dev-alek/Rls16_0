block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: alcdcl04.p $
$Archive: rep/alcdcl04.p $

Декларация об объемах розничной продажи алкогольной продукции (Псков)

Автор: Хныкин Павел Андреевич
Дата создания: 09/18/07
Author: Pavel Khnykin
Creation date: 09/18/07

В 1901 году решением 3-й Генеральной конференции по мерам и весам литр был определён как объём 1 кг чистой воды
при нормальном атмосферном давлении (760 мм рт. ст.) и температуpe наибольшей плотности воды (4 °С).
Таким образом, объём 1 литра был принят за 1,000028 дм3.
В 1964 году 12-я Генеральная конференция по мерам и весам отменила это определение и приняла, что 1 л = 1 дм3 (точно).

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: alcdcl04.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/alcdcl04.p $":U .
define variable vss-description as character no-undo init "Декларация об объемах розничной продажи алкогольной продукции (Псков)".
{ cmp/vssrevis.i   }
{ cmp/str-glbl.i   }
{ cmp/library.i    }
{ cmp/r-pril.i new }
{ cmp/r-page1.i    }
{ gbl/waitfram.i   }
{ gbl/prn-lib.i    }
{ rep/r-sym.i      }
{ trg/factord.i    }
{ rep/ost-line.i   }
{ str/clcprtsl.i   }
{ rep/lkp-font.i   }
{ rep/fmtcli.i     }
{ gbl/paramls.i    }
define variable g#report-num  as integer    no-undo .
{ rep/alc04xl.i    }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get " " my-handle }
{ gbl/getsect.i def }


define stream out-stream.

define temp-table tt-gds no-undo like ub.goods
  field alc-type-inner-code like ub.alc-type.alc-type-inner-code
  field create-user-db-num  like ub.alc-type.create-user-db-num
  field alc-type-code       like ub.alc-type.alc-type-code
  field alc-type-name       like ub.alc-type.alc-type-name
index pi is primary unique
  gds-code
index alc-type
  alc-type-inner-code
  create-user-db-num
index alc-type-code
  alc-type-code
.

define temp-table tt-report no-undo
/*  field alc-type-inner-code like alc-type.alc-type-inner-code*/
/*  field create-user-db-num  like alc-type.create-user-db-num*/
  field alc-type-code       like ub.alc-type.alc-type-code
  field alc-type-name       like ub.alc-type.alc-type-name
  field ost-begin           as decimal
  field purchase            as decimal
  field sell                as decimal
  field ret                 as decimal
  field other               as decimal
  field ras-total           as decimal
  field ost-end             as decimal
index pi is primary unique
  alc-type-code
.

define variable v-par-val                 as character  no-undo .
define variable v-par-type                as character  no-undo .
define variable v-line                    as character  no-undo .
define variable v-begin-date              as date       no-undo .
define variable v-end-date                as date       no-undo .
define variable v-alc-type-num            as character  no-undo .
define variable v-host-code               like ub.clients.host-code  no-undo .
define variable v-host-code-2             like ub.clients.host-code  no-undo .

/* 198 */
&scop f-w-line 197

&scop col-fmt-2 56

&scop col-fmtl-1 "X(4)"
&scop col-fmtl-2 "X({&col-fmt-2})"
&scop col-fmtl-3 "X(7)"
&scop col-fmtl-4 "->>>,>>>,>>9.9999"
&scop col-fmtl-5 "->>>,>>>,>>9.9999"
&scop col-fmtl-6 "->>>,>>>,>>9.9999"
&scop col-fmtl-7 "->>>,>>>,>>9.9999"
&scop col-fmtl-8 "->>>,>>>,>>9.9999"
&scop col-fmtl-9 "->>>,>>>,>>9.9999"
&scop col-fmtl-10 "->>>,>>>,>>9.9999"

define frame f-decl
    sym1                        no-label format "X(1)"                          space(0)
    v-alc-type-num              no-label format {&col-fmtl-1}                   space(0)
    sym2                        no-label format "X(1)"                          space(0)
    tt-report.alc-type-name     no-label format {&col-fmtl-2}                   space(0)
    sym3                        no-label format "X(1)"                          space(0)
    tt-report.alc-type-code     no-label format {&col-fmtl-3}                   space(0)
    sym4                        no-label format "X(1)"                          space(0)
    tt-report.ost-begin         no-label format {&col-fmtl-4}                   space(0)
    sym5                        no-label format "X(1)"                          space(0)
    tt-report.purchase          no-label format {&col-fmtl-5}                   space(0)
    sym6                        no-label format "X(1)"                          space(0)
    tt-report.sell              no-label format {&col-fmtl-6}                   space(0)
    sym7                        no-label format "X(1)"                          space(0)
    tt-report.ret               no-label format {&col-fmtl-7}                   space(0)
    sym8                        no-label format "X(1)"                          space(0)
    tt-report.other             no-label format {&col-fmtl-8}                   space(0)
    sym9                        no-label format "X(1)"                          space(0)
    tt-report.ras-total         no-label format {&col-fmtl-9}                   space(0)
    sym10                       no-label format "X(1)"                          space(0)
    tt-report.ost-end           no-label format {&col-fmtl-10}                  space(0)
    sym11                       no-label format "X(1)"                          space(0)
header
  ":----:--------------------------------------------------------:-------:-----------------:-----------------:-----------------:-----------------:-----------------:-----------------:-----------------:":U skip
  ":  1 :                              2                         :   3   :         4       :         5       :         6       :         7       :        8        :        9        :        10       :":U skip
with width {&A4_LS} down stream-io no-label no-box.

form header
        v-line format "X({&f-w-line})" at 1 SKIP
        "Продолжение - на следующей странице" at 1 SKIP
with frame BottomFrame width {&A4_LS} PAGE-BOTTOM NO-LABELS NO-BOX .

form header
        "Стр. " + string(PAGE-NUMBER(out-stream),">>9" ) at 185
with frame topFrame width {&A4_LS} PAGE-TOP NO-LABELS NO-BOX .


do on error undo, return error return-value
:
  { gbl/working.i }

{ gbl/getsect.i run "''" 0 {&attr-report-glob} }
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'ardecldt' then v-par-val =  string(thbjattr_thbj-attr.property-value-date,"99/99/9999") .
end.

  find first obj-list no-lock .
  if not available obj-list then do:
    message
      "Нет ни одного объекта для формирования отчета!"
    view-as alert-box error.
    return error return-value.
  end.
  { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code }
  for each obj-list :
    { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code-2 }
    if v-host-code <> v-host-code-2 then do:
      message
        "Отчет формируется только по объектам одной фирмы."
      view-as alert-box error.
      return error return-value.
    end.
  end.


  run clear-all in this-procedure .
  assign
    v-line        = fill( "-" , 300 )
    v-begin-date  = date(v-par-val)
    v-end-date    = x-Date-Alone
  .
  run get-report-num in my-handle (output g#report-num).
  { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }
  run alc04xl-init in this-procedure.
  run waitfram-show in this-procedure ( "Формирование данных об организации..." ) .
  run find-alc-goods in this-procedure .
  run fill-tt-report in this-procedure .
  view stream out-stream frame BottomFrame .
  view stream out-stream frame topFrame .
  run print-header in this-procedure .
  run print-report in this-procedure .
  run print-footer in this-procedure .
  run alc04xl-close in this-procedure .
  hide stream out-stream frame BottomFrame.
  output stream out-stream close.
  {&CloseExcel}
  run clear-all in this-procedure .
  run waitfram-hide in this-procedure .
  { gbl/stopwork.i }
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .

  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  run gbl/prnfilen.w
      (input  ""
      ,input  8
      ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      ,input  ReportFontNum
      ,output v-user-action
      ,output v-printed
      ) .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
end.


/* ===================================================================================================== */
procedure clear-all :

do
on error undo, return error return-value
:
  empty temp-table tt-gds.
  empty temp-table tt-report.
end.

end procedure. /* clear-all */

/* ===================================================================================================== */
procedure find-alc-goods :

do
on error undo, return error return-value
:

  define buffer buf_alc-type      for ub.alc-type.
  define buffer buf_alc-type-gds  for ub.alc-type-gds.
  define buffer buf_goods         for ub.goods.

  /* заполняем список алкогольных товаров */
  empty temp-table tt-gds.
  for each buf_alc-type no-lock
        where buf_alc-type.alc-type-status = 0
  :
    for each buf_alc-type-gds no-lock
          where buf_alc-type-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
            AND buf_alc-type-gds.create-user-db-num  = buf_alc-type.create-user-db-num
      , first buf_goods no-lock
          where buf_goods.gds-code = buf_alc-type-gds.gds-code
    :
      find first tt-gds no-lock where tt-gds.gds-code = buf_goods.gds-code no-error .
      if not available tt-gds then do:
        create tt-gds.
        buffer-copy buf_goods to tt-gds
        assign
          tt-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
          tt-gds.create-user-db-num  = buf_alc-type.create-user-db-num
          tt-gds.alc-type-code       = buf_alc-type.alc-type-code
          tt-gds.alc-type-name       = buf_alc-type.alc-type-name
        .
      end.
    end.
  end.

end.

end procedure. /* find-alc-goods */

/* ===================================================================================================== */
procedure fill-tt-report :

  define buffer buf_alc-type    for ub.alc-type.
  define buffer buf_trn-doc     for ub.trn-doc.
  define buffer t-doc           for ub.trn-doc.
  define buffer buf_doc-line    for ub.doc-line.
  define buffer buf_parts       for ub.parts.
  define buffer buf_tt-clcparts for tt-clcparts .
  define buffer buf_goods       for ub.goods.
  define buffer buf_ot-line     for ub.ot-line.
  define buffer buf_obj-list    for obj-list.

  define variable var-x-store-code    like ub.clients.obj-code    no-undo.
  define variable var-x-store-type    like ub.clients.obj-type    no-undo.
  define variable var-x-date-start    like ub.stk-tot.Fact-date   no-undo.
  define variable var-x-date-endt     like ub.stk-tot.Fact-date   no-undo.
  define variable var-x-sum-type      like ub.stk-tot.sum-type    no-undo.
  define variable var-x-ost-sum-type  like ub.stk-tot.sum-type    no-undo.
  define variable var-x-cat-id        like ub.stk-tot.cat-id      no-undo.
  define variable var-xTog-obj        as   logical             no-undo.

  define variable var-Quantity        like ub.stk-tot.fact-qnty   initial ? no-undo.
  define variable var-Coast_R         like ub.stk-tot.sum-rubl    no-undo.
  define variable var-Coast_V         like ub.stk-tot.sum-rubl    no-undo.
  define variable var-VAT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-VAT_V           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-Fact-order      like ub.stk-tot.Fact-order  no-undo.

  define variable var-x-artic         like ub.stk-line.artic        no-undo.
  define variable var-x-prod-code     like ub.stk-line.prod-code    no-undo.
  define variable var-x-prod-type     like ub.stk-line.prod-type    no-undo.

  define variable var-SLT_R           like ub.stk-tot.sum-rubl    no-undo.
  define variable var-SLT_V           like ub.stk-tot.sum-rubl    no-undo.

  define variable v-fact-order-1      like ub.ot-line.fact-order no-undo .
  define variable v-fact-order-2      like ub.ot-line.fact-order no-undo .
  define variable v-shift-end-fact-order          as decimal    no-undo .
  define variable v-day-end-fact-order            as decimal    no-undo .

  define variable v-part-qnty                     as decimal   no-undo .
  define variable v-ot-line-qnty                  as decimal   no-undo .

  define variable v-ost-begin-qnty  as decimal   no-undo .
  define variable v-purchase-qnty   as decimal   no-undo .
  define variable v-sell-qnty       as decimal   no-undo .
  define variable v-ret-qnty        as decimal   no-undo .
  define variable v-other-qnty      as decimal   no-undo .
  define variable v-ost-end-qnty    as decimal   no-undo .

  define variable v-income-doc-code like ub.trn-doc.doc-code no-undo .

do
on error undo, return error return-value
:
  run factord in this-procedure
    ( input  v-begin-date            /* p-fact-date            */
    , input  1                       /* p-fact-time            */
    , input  1                       /* p-fact-num             */
    , input  ?                       /* p-shift-date           */
    , input  0                       /* p-shift-num            */
    , input  false                   /* p-shift-on             */
    , output v-fact-order-1          /* p-fact-order           */
    , output v-shift-end-fact-order  /* p-shift-end-fact-order */
    , output v-day-end-fact-order    /* p-day-end-fact-order   */
    ) no-error .
  if error-status:error then do:
    message error-status :get-message(1) view-as alert-box error .
    return error.
  end.
  run factord in this-procedure
    ( input  v-end-date + 1          /* p-fact-date            */
    , input  1                       /* p-fact-time            */
    , input  1                       /* p-fact-num             */
    , input  ?                       /* p-shift-date           */
    , input  0                       /* p-shift-num            */
    , input  false                   /* p-shift-on             */
    , output v-fact-order-2          /* p-fact-order           */
    , output v-shift-end-fact-order  /* p-shift-end-fact-order */
    , output v-day-end-fact-order    /* p-day-end-fact-order   */
    ) no-error .
  if error-status:error then do:
    message error-status :get-message(1) view-as alert-box error .
    return error.
  end.
  assign
    var-x-sum-type      = {&arh-cost}
    var-x-ost-sum-type  = {&arh-cost}
  .
  run waitfram-show in this-procedure ( "Расчет остатков на начало" ).
  for each buf_alc-type no-lock
        where buf_alc-type.alc-type-status = 0
  break by buf_alc-type.alc-type-code
  :
    /* остаток на начало */
    for each obj-list no-lock ,
        each tt-gds no-lock
          where tt-gds.alc-type-code = buf_alc-type.alc-type-code
    :
        assign
          var-x-store-code  = obj-list.obj-code
          var-x-store-type  = obj-list.obj-type
          var-x-artic       = tt-gds.artic
          var-x-prod-code   = tt-gds.prod-code
          var-x-prod-type   = tt-gds.prod-type
          var-x-cat-id      = {&root-cat-id}
          var-xTog-obj      = yes
        .
        RUN ost-line  (
            input   var-x-store-code,
            input   var-x-store-type,
            INPUT   var-x-artic     ,
            INPUT   var-x-prod-code ,
            INPUT   var-x-prod-type ,
            input   no              ,
            input   v-fact-order-1  ,
            input   var-x-ost-sum-type  ,
            input   var-x-cat-id    ,
            input   var-xTog-obj    ,
            output  var-Quantity    ,
            output  var-Coast_R     ,
            output  var-Coast_V     ,
            output  var-VAT_R       ,
            output  var-VAT_V       ,
            output  var-SLT_R       ,
            output  var-SLT_V       ).
        assign
          v-ost-begin-qnty = v-ost-begin-qnty + (var-Quantity * tt-gds.ms-base / 10 )
        .
        RUN ost-line  (
            input   var-x-store-code,
            input   var-x-store-type,
            INPUT   var-x-artic     ,
            INPUT   var-x-prod-code ,
            INPUT   var-x-prod-type ,
            input   no              ,
            input   v-fact-order-2  ,
            input   var-x-ost-sum-type  ,
            input   var-x-cat-id    ,
            input   var-xTog-obj    ,
            output  var-Quantity    ,
            output  var-Coast_R     ,
            output  var-Coast_V     ,
            output  var-VAT_R       ,
            output  var-VAT_V       ,
            output  var-SLT_R       ,
            output  var-SLT_V       ).
        assign
          v-ost-end-qnty = v-ost-end-qnty + + (var-Quantity * tt-gds.ms-base / 10 )
        .
    end. /* for each obj-list no-lock , each tt-gds no-lock */

    /* собираем приходы, расходы */
    for each obj-list no-lock ,
        each tt-gds no-lock
          where tt-gds.alc-type-inner-code = buf_alc-type.alc-type-inner-code
            and tt-gds.create-user-db-num  = buf_alc-type.create-user-db-num ,
          each buf_ot-line no-lock
            where   buf_ot-line.artic        = tt-gds.artic
              and   buf_ot-line.prod-code    = tt-gds.prod-code
              and   buf_ot-line.prod-type    = tt-gds.prod-type
              and   buf_ot-line.fact-order   <= v-fact-order-2  /* fact-order конца периода */
              and   buf_ot-line.fact-order   >= v-fact-order-1  /* fact-order начала периода */
              and   buf_ot-line.obj-code     = obj-list.obj-code
              and   buf_ot-line.obj-type     = obj-list.obj-type
              and   buf_ot-line.sum-type     = var-x-sum-type
    :
      run waitfram-show in this-procedure (input substitute("Расчет оборота по объекту: &1" , obj-list.obj-name ) ).
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = buf_ot-line.doc-code
      no-error .
      if not available buf_trn-doc then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Не найден складской документ &1.&2Документ не будет учтен в отчете." , buf_ot-line.doc-code , {&new-line} )
        view-as alert-box error .
        next.
      end.
        assign
          v-ot-line-qnty  = abs(buf_ot-line.fact-qnty * tt-gds.ms-base / 10)
        .

      case buf_ot-line.ext-doc-type:
        /* это приход */
        when {&TDEDT_PRI_VNESH}  then do :
          assign
            v-purchase-qnty = v-purchase-qnty + v-ot-line-qnty
          .
        end.
        when {&TDEDT_PRI_PEREM} then do :
          assign
            v-other-qnty = v-other-qnty - v-ot-line-qnty
          .
        end.
        /* расход */
        when {&TDEDT_RAS_VNESH}  then do :
          assign
            v-sell-qnty = v-sell-qnty + v-ot-line-qnty
          .
        end.
        when {&TDEDT_RAS_VNESH_KASS}  then do :
          assign
            v-sell-qnty = v-sell-qnty + v-ot-line-qnty
          .
        end.
        when {&TDEDT_VOZVRAT_VNESH}  then do :
          assign
            v-ret-qnty = v-ret-qnty + v-ot-line-qnty
          .
        end.
        when {&TDEDT_VOZVRAT_VNESH_KASS}  then do :
          assign
            v-ret-qnty = v-ret-qnty - v-ot-line-qnty
          .
        end.
        /* списание и возврат поставщику */
        when {&TDEDT_RAS_VNESH_VP} then do :
          assign
            v-ret-qnty = v-ret-qnty + v-ot-line-qnty
          .
        end.
        when {&TDEDT_SPI_VNESH}  then do :
          assign
            v-other-qnty = v-other-qnty + v-ot-line-qnty
          .
        end.
        when {&TDEDT_RAS_PEREM} then do :
          assign
            v-other-qnty = v-other-qnty + v-ot-line-qnty
          .
        end.
        when {&TDEDT_VOZVRAT_PEREM} then do :
          assign
            v-other-qnty = v-other-qnty - v-ot-line-qnty
          .
        end.
        when {&tdedt_inv} or when {&tdedt_peresort} or when {&tdedt_pri_prvo} then do:
          assign
            v-other-qnty = v-other-qnty - v-ot-line-qnty
          .

        end.
        otherwise do:
          assign
            v-other-qnty = v-other-qnty + v-ot-line-qnty
          .
        end.
      end case.
    end.
    if last-of( buf_alc-type.alc-type-code ) then do:
      find first tt-report
        where tt-report.alc-type-code = buf_alc-type.alc-type-code
      no-error .
      if not available tt-report then do:
        create tt-report.
      end.
      assign
        tt-report.alc-type-code = buf_alc-type.alc-type-code
        tt-report.alc-type-name = buf_alc-type.alc-type-name + ( if buf_alc-type.alc-type-code = "460" then " *" else "" )
        tt-report.ost-begin     = v-ost-begin-qnty
        tt-report.purchase      = v-purchase-qnty
        tt-report.sell          = v-sell-qnty
        tt-report.ret           = v-ret-qnty
        tt-report.other         = v-other-qnty
        tt-report.ras-total     = v-sell-qnty + v-ret-qnty + v-other-qnty
        tt-report.ost-end       = v-ost-end-qnty /*v-ost-begin-qnty + v-purchase-qnty - tt-report.ras-total*/
        v-ost-begin-qnty        = 0
        v-purchase-qnty         = 0
        v-sell-qnty             = 0
        v-ret-qnty              = 0
        v-other-qnty            = 0
        v-ost-end-qnty          = 0
      .
    end.
  end. /* for each buf_alc-type no-lock */
end.

end procedure. /* fill-tt-report */

/* ===================================================================================================== */
procedure find-income-doc-code :
  define input  parameter p-in-code         like ub.parts.in-code    no-undo .
  define input  parameter p-gds-code        like ub.goods.gds-code   no-undo .
  define input  parameter p-part-code       like ub.parts.part-code  no-undo .
  define output parameter p-income-doc-code like ub.parts.in-code    no-undo .

define buffer buf_parts-attr        for ub.parts-attr .
define buffer buf_income_parts-attr for ub.parts-attr .


do on error undo, return error return-value :
  assign
    p-income-doc-code = ?
  .
  find first buf_parts-attr no-lock
    where buf_parts-attr.in-code   = p-in-code
      and buf_parts-attr.gds-code  = p-gds-code
      and buf_parts-attr.part-code = p-part-code
  no-error .
  if available buf_parts-attr then do:
    find first buf_income_parts-attr no-lock
      where buf_income_parts-attr.in-code   = buf_parts-attr.income-in-code
        and buf_income_parts-attr.gds-code  = buf_parts-attr.income-gds-code
        and buf_income_parts-attr.part-code = buf_parts-attr.income-part-code
      no-error .
    if available buf_income_parts-attr then do:
      assign
        p-income-doc-code = buf_parts-attr.income-in-code
      .
    end.
    else do:
      assign
        p-income-doc-code = ?
      .
    end.
  end.
  else do:
    assign
      p-income-doc-code = ?
    .
  end.
end. /* do */

end procedure. /* find-income-doc-code */

/* ===================================================================================================== */
procedure print-report :

  define variable v-alc-type-code-int       as integer   no-undo .
  define variable v-alc-type-code-int-prev  as integer   no-undo .
  define variable v-section                 as integer   no-undo .
  define variable v-subsection              as integer   no-undo .
  define variable v-ost-begin-tot-qnty      as decimal   no-undo .
  define variable v-purchase-tot-qnty       as decimal   no-undo .
  define variable v-sell-tot-qnty           as decimal   no-undo .
  define variable v-ret-tot-qnty            as decimal   no-undo .
  define variable v-other-tot-qnty          as decimal   no-undo .
  define variable v-ras-tot-qnty            as decimal   no-undo .
  define variable v-ost-end-tot-qnty        as decimal   no-undo .
  define variable v-row-counter             as integer   no-undo .
  define variable v-offset                  as integer   no-undo .
  define variable v-i                       as integer   no-undo .
  define variable v-alc-type-name           as character no-undo .
do
on error undo, return error return-value
:
  assign
    v-section                = 1
    v-subsection             = 1
    v-alc-type-num           = substitute( "&1.&2" , v-section , v-subsection )
    v-alc-type-code-int-prev = 0
  .
  for each tt-report
    break by tt-report.alc-type-code
  :
    if first-of(tt-report.alc-type-code) then do:

      assign
        v-alc-type-code-int-prev  = v-alc-type-code-int
        v-alc-type-code-int       = integer(tt-report.alc-type-code)
      no-error .
      if error-status :error then do:
        assign
          v-alc-type-code-int = 0
        .
      end.
      if v-alc-type-code-int-prev < 200 and v-alc-type-code-int >= 200 then do:
        assign
          v-alc-type-name = "Спиртные напитки, в том числе:"
        .
        display stream out-stream
          "1"  @ v-alc-type-num
          v-alc-type-name @ tt-report.alc-type-name
          "x" @ tt-report.alc-type-code
          sym1
          sym2
          sym3
          sym4
          sym5
          sym6
          sym7
          sym8
          sym9
          sym10
          sym11
        with frame f-decl.
        down stream out-stream with frame f-decl.
        run alc04xl-sheet1-write-line-data in this-procedure
              ( input "1"
              , input v-alc-type-name
              , input "x"
              , input " "
              , input " "
              , input " "
              , input " "
              , input " "
              , input " "
              , input " "
              ).
      end.
      if v-alc-type-code-int-prev < 400 and v-alc-type-code-int >= 400 then do:
          assign
            v-section = v-section + 1
            v-subsection    = 1
            v-alc-type-num  = substitute( "&1.&2" , v-section , v-subsection )
            v-alc-type-name = "Вина, в том числе:"
          .
          display stream out-stream
            "2"  @ v-alc-type-num
            v-alc-type-name @ tt-report.alc-type-name
            "x" @ tt-report.alc-type-code
            sym1
            sym2
            sym3
            sym4
            sym5
            sym6
            sym7
            sym8
            sym9
            sym10
            sym11
          with frame f-decl.
          down stream out-stream with frame f-decl.
          run alc04xl-sheet1-write-line-data in this-procedure
                ( input "2"
                , input v-alc-type-name
                , input "x"
                , input " "
                , input " "
                , input " "
                , input " "
                , input " "
                , input " "
                , input " "
                ).
      end.
    end.
    assign
      v-row-counter = integer( truncate( ( length(tt-report.alc-type-name) / {&col-fmt-2} ) , 0) + 1 )
    .
    if line-counter(out-stream) + v-row-counter - 1 > page-size(out-stream) then do:
      page stream out-stream.
    end.
    do v-i = 1 to v-row-counter :
      display stream out-stream
        v-alc-type-num          when v-i = 1
        substring( tt-report.alc-type-name , (v-i - 1) * {&col-fmt-2} + 1 , {&col-fmt-2} ) @ tt-report.alc-type-name
        tt-report.alc-type-code when v-i = 1
        tt-report.ost-begin     when v-i = 1
        tt-report.purchase      when v-i = 1
        tt-report.sell          when v-i = 1
        tt-report.ret           when v-i = 1
        tt-report.other         when v-i = 1
        tt-report.ras-total     when v-i = 1
        tt-report.ost-end       when v-i = 1
        sym1
        sym2
        sym3
        sym4
        sym5
        sym6
        sym7
        sym8
        sym9
        sym10
        sym11
      with frame f-decl.
      down stream out-stream with frame f-decl.
    end.
    run alc04xl-sheet1-write-line-data in this-procedure
          ( input v-alc-type-num
          , input tt-report.alc-type-name
          , input tt-report.alc-type-code
          , input string( tt-report.ost-begin )
          , input string( tt-report.purchase  )
          , input string( tt-report.sell      )
          , input string( tt-report.ret       )
          , input string( tt-report.other     )
          , input string( tt-report.ras-total )
          , input string( tt-report.ost-end   )
          ).
/*define input parameter p-alc-type-num  as character no-undo .*/
/*define input parameter p-alc-type-name as character no-undo .*/
/*define input parameter p-alc-type-code as character no-undo .*/
/*define input parameter p-ost-begin     as decimal   no-undo .*/
/*define input parameter p-purchase      as decimal   no-undo .*/
/*define input parameter p-sell          as decimal   no-undo .*/
/*define input parameter p-ret           as decimal   no-undo .*/
/*define input parameter p-other         as decimal   no-undo .*/
/*define input parameter p-ras-total     as decimal   no-undo .*/
/*define input parameter p-ost-end       as decimal   no-undo .*/


    assign
      v-ost-begin-tot-qnty = v-ost-begin-tot-qnty + tt-report.ost-begin
      v-purchase-tot-qnty  = v-purchase-tot-qnty  + tt-report.purchase
      v-sell-tot-qnty      = v-sell-tot-qnty      + tt-report.sell
      v-ret-tot-qnty       = v-ret-tot-qnty       + tt-report.ret
      v-other-tot-qnty     = v-other-tot-qnty     + tt-report.other
      v-ras-tot-qnty       = v-ras-tot-qnty       + tt-report.ras-total
      v-ost-end-tot-qnty   = v-ost-end-tot-qnty   + tt-report.ost-end
      v-subsection    = v-subsection + 1
      v-alc-type-num  = substitute( "&1.&2" , v-section , v-subsection )
    .

  end. /* for each tt-report */
  if line-counter(out-stream) + 2 > page-size(out-stream) then do:
    page stream out-stream.
  end.
  put stream out-stream v-line format "X({&f-w-line})" skip.
  display stream out-stream
      "ИТОГО по видам"      @ tt-report.alc-type-name
      v-ost-begin-tot-qnty  @ tt-report.ost-begin
      v-purchase-tot-qnty   @ tt-report.purchase
      v-sell-tot-qnty       @ tt-report.sell
      v-ret-tot-qnty        @ tt-report.ret
      v-other-tot-qnty      @ tt-report.other
      v-ras-tot-qnty        @ tt-report.ras-total
      v-ost-end-tot-qnty    @ tt-report.ost-end
      sym1
      sym2
      sym3
      sym4
      sym5
      sym6
      sym7
      sym8
      sym9
      sym10
      sym11
  with frame f-decl.
  put stream out-stream v-line format "X({&f-w-line})" skip.
  run alc04xl-write-cell-data in this-procedure ( input {&alc04xl-sheet1-it-ostbegin}, input v-ost-begin-tot-qnty ).
  run alc04xl-write-cell-data in this-procedure ( input {&alc04xl-sheet1-it-purchase}, input v-purchase-tot-qnty  ).
  run alc04xl-write-cell-data in this-procedure ( input {&alc04xl-sheet1-it-sell    }, input v-sell-tot-qnty      ).
  run alc04xl-write-cell-data in this-procedure ( input {&alc04xl-sheet1-it-ret     }, input v-ret-tot-qnty       ).
  run alc04xl-write-cell-data in this-procedure ( input {&alc04xl-sheet1-it-other   }, input v-other-tot-qnty     ).
  run alc04xl-write-cell-data in this-procedure ( input {&alc04xl-sheet1-it-rastotal}, input v-ras-tot-qnty       ).
  run alc04xl-write-cell-data in this-procedure ( input {&alc04xl-sheet1-it-ostend  }, input v-ost-end-tot-qnty   ).
end.

end procedure. /* print-report */

/* ===================================================================================================== */
procedure print-header :

do
on error undo, return error return-value
:
  run fmtcli-get-client in this-procedure
            ( input  {&cmp}
            , input  v-host-code
            ) .
  put stream out-stream
      v-fmtcli-name skip
      "{&abbr_inn_allshift} " v-fmtcli-inn skip
      "{&abbr_kpp_allshift} " v-fmtcli-kpp skip
      "Декларация" at 93 skip
      "о розничной продаже алкогольной продукции" at 80 skip
      "дал." at 190 skip
  "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------":U skip
  ": №  :  Наименование вида продукции                           : Код   : Остаток на на-  : Объем закупки   :                                  Расход                               : Остаток на конец:":U skip
  ": п/п:                                                        : вида  : чало отчетного  :                 :-----------------------------------------------------------------------: отчетного пери- :":U skip
  ":    :                                                        :продук-: периода         :                 :    Розничная    :     Возврат     :     Прочий      :      Всего      : ода             :":U skip
  ":    :                                                        :ции    :                 :                 :     продажа     :    продукции    :     расход      :                 :                 :":U skip
  .
  run alc04xl-write-cell-data in this-procedure ( input {&alc04xl-h_firmname}, input v-fmtcli-name ).
  run alc04xl-write-cell-data in this-procedure ( input {&alc04xl-h_inn}, input v-fmtcli-inn ).
  run alc04xl-write-cell-data in this-procedure ( input {&alc04xl-h_kpp}, input v-fmtcli-kpp ).
end.

end procedure. /* print-header */

/* ===================================================================================================== */
procedure print-footer :

do
on error undo, return error return-value
:

  put stream out-stream
  "* - вермуты, плодово-виноградные вина, фруктово-виноградные вина, сидры, медовые вина и др.":U at 3 skip(2)
  "Руководитель" at 3 "____________________" at 40 "____________________" at 70 skip
  "(подпись)" at 45 "(ф.и.о.)" at 78  skip(1)
  "Главный бухгалтер" at 3 "____________________" at 40 "____________________" at 70  skip
  "(подпись)" at 45 "(ф.и.о.)" at 78  skip(1)
  "Уполномоченный" at 3 skip
  "представитель" at 3 "____________________" at 40 "____________________" at 70 skip
  "(подпись)" at 45 "(ф.и.о.)" at 78  skip(1)
  "Исполнитель" at 3 "________________________________________" at 40 skip(1)
  "Телефон" at 3 "________________________________________" at 40 skip(1)
  "Дата" at 3 "________________________________________" at 40 skip(1)
  .

end.

end procedure. /* print-footer */