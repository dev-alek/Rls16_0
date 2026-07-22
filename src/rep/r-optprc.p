block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-optprc.p $
$Archive: rep/r-optprc.p $

Оптовый прайс-лист

Автор: Хныкин Павел Андреевич
Дата создания: 11/21/08
Author: Pavel Khnykin
Creation date: 11/21/08

*/
define input  parameter p-show-without-price-doc as logical   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-optprc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-optprc.p $":U .
define variable vss-description as character no-undo init "".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i      }
{ cmp/r-pril.i       }
{ rep/r-sym.i        }
{ gbl/waitfram.i     }
{ rep/lkp-font.i     }
{ ref/grplibfn.i     }
{ rep/fmtcli.i       }
{ rep/prg-bar.i run  }
{ gbl/paramls.i      }
{ gbl/cur-time.i     }


define variable parparentproc  as handle  no-undo .
define variable g#report-num   as integer no-undo .
assign
  parparentproc = my-handle
.
run get-report-num in my-handle (output g#report-num).
{ rep/optprcxl.i     }

define stream out-stream.

define temp-table tt-goods no-undo like ub.goods.

define temp-table tt-optprc no-undo
  field gds-code like ub.goods.gds-code
  field artic    like ub.goods.artic
  field b-code   like ub.bar-code.b-code
  field b-code-str  as character
  field gds-name as character
  field grp-code as integer
  field grp-name as character
  field prod-type as character
  field prod-code as integer
  field prod-name as character
  field unit-name as character

  /* цена за единицу */
  field price     as decimal
  field price-str as character
  /* кол-во в упаковке */
  field unit-qnty as decimal
  field unit-qnty-str as character
  /* Цена за упаковку */
  field unit-price as decimal
  field unit-price-str as character
  field is-root-code   as logical
index pi is primary unique
  gds-code
  b-code
index grp
  grp-name
  artic
  is-root-code descending
  unit-qnty
.

define buffer buf_currency for ub.currency .

define variable v-base-code              as integer   no-undo .
define variable v-curr-abbr              as character no-undo .
define variable v-print-rubl             as logical   no-undo .
define variable v-host-code              as integer   no-undo .
define variable v-line                   as character no-undo .

&scop frame-width 131
&scop col-fmtl-1 "X(16)":U
&scop col-fmtl-2 "X(10)":U
&scop col-fmtl-3 "X(30)":U
&scop col-fmtl-4 "X(20)":U
&scop col-fmtl-5 "X(4)":U
&scop col-fmtl-6 "X(14)":U
&scop col-fmtl-7 "X(14)":U
&scop col-fmtl-8 "X(14)":U
&scop col-fmtlw-1 16
&scop col-fmtlw-2 10
&scop col-fmtlw-3 30
&scop col-fmtlw-4 20
&scop col-fmtlw-5 4
&scop col-fmtlw-6 14
&scop col-fmtlw-7 14
&scop col-fmtlw-8 14

&scop fmt-b-code "999999999":U
&scop fmt-price ">>>,>>>,>>9.99":U
&scop fmt-unit-qnty-dcml ">>>,>>>,>>9.99":U
&scop fmt-unit-qnty-int ">,>>>,>>>,>>>9":U
&scop fmt-unit-price ">>>,>>>,>>9.99":U

define frame optprc
  sym1                            no-label format "X(1)"                          space(0)
  tt-optprc.artic                 no-label format {&col-fmtl-1}                   space(0)
  sym2                            no-label format "X(1)"                          space(0)
  tt-optprc.b-code-str            no-label format {&col-fmtl-2}                   space(0)
  sym3                            no-label format "X(1)"                          space(0)
  tt-optprc.gds-name              no-label format {&col-fmtl-3}                   space(0)
  sym4                            no-label format "X(1)"                          space(0)
  tt-optprc.prod-name             no-label format {&col-fmtl-4}                   space(0)
  sym5                            no-label format "X(1)"                          space(0)
  tt-optprc.unit-name             no-label format {&col-fmtl-5}                   space(0)
  sym6                            no-label format "X(1)"                          space(0)
  tt-optprc.price-str             no-label format {&col-fmtl-6}                   space(0)
  sym7                            no-label format "X(1)"                          space(0)
  tt-optprc.unit-qnty-str         no-label format {&col-fmtl-7}                   space(0)
  sym8                            no-label format "X(1)"                          space(0)
  tt-optprc.unit-price-str        no-label format {&col-fmtl-8}                   space(0)
  sym9                            no-label format "X(1)"                          space(0)
with width {&frame-width} down stream-io no-label no-box.

form header
      ":----------------:----------:------------------------------:--------------------:----:--------------:--------------:--------------:":U skip
      ":       1        :    2     :               3              :           4        : 5  :      6       :      7       :      8       :":U skip
      ":----------------:----------:------------------------------:--------------------:----:--------------:--------------:--------------:":U
with frame HeaderFrame width {&A4_LS} PAGE-TOP NO-LABELS NO-BOX .

form header
        v-line format "X(131)" at 1 SKIP
        "Продолжение - на следующей странице" at 1 SKIP
with frame BottomFrame width {&A4_LS} PAGE-BOTTOM NO-LABELS NO-BOX .

function get-unit-qnty-str returns character (p-unit-qnty as decimal) forward.

do
on error undo, return error return-value
:
  { gbl/working.i }
  run clear-tt in this-procedure .
  assign
    v-line = fill( "-" , 300 )
  .
  find first obj-list no-error .
  if not available obj-list then do:
    message
      "Не указан объект для формирования отчета!"
    view-as alert-box error.
    undo, return error.
  end.
  { gbl/hostcode.i obj-list.obj-type obj-list.obj-code v-host-code }

  { gbl/basecode.i
    v-host-code
    v-base-code
  }

  find buf_currency no-lock
    where buf_currency.curr-code = v-base-code
  no-error .
  if not available buf_currency
  then do:
    message
      substitute( "Не найдена базовая валюта для фирмы &1" , v-host-code )
    view-as alert-box information.
    undo, return error.
  end.

  assign
    v-curr-abbr =  buf_currency.curr-abbr
  .

  { cmp/open-out.i stream out-stream " " }
  run optprcxl-init in this-procedure .

  run prg-bar_init-cb-handle in this-procedure (v-d-report-handle) .

  run fill-tt in this-procedure .
  run print-report in this-procedure .
  output stream out-stream close.
  run optprcxl-close in this-procedure .
  run clear-tt in this-procedure .

  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure ( input ReportPageHeight
                                 , input ReportPageWidth
                                 , output v-orient-page
                                 ) .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                 else DisabledOptions = 0 .
  run gbl/prnfilen.w
      ( input  ""
      , input  DisabledOptions
      , input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      , input  ReportFontNum
      , output v-user-action
      , output v-printed
      ) .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .


end.

/* ========================================================================================== */
procedure fill-tt-goods :
  define buffer buf_goods     for ub.goods.
  define buffer buf_tt-goods  for tt-goods.

do
on error undo, return error return-value
:
  define variable v-curr-grp-name as character no-undo .

  run waitfram-show in this-procedure (input "Построение списка товаров":U ) .

  case x-SelectGood :
    when {&g-all} then do: /* все товары */
      for each buf_goods no-lock
        where buf_goods.stts = 0
      :
        create buf_tt-goods.
        buffer-copy buf_goods to buf_tt-goods.
      end.
    end.
    when {&g-grp} then do: /* товары по группам  */
      for each tmp#grp no-lock
      :
        run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .
        for each buf_goods no-lock
              where buf_goods.grp-name begins v-curr-grp-name
        :
          find first buf_tt-goods no-lock
            where buf_tt-goods.gds-code = buf_goods.gds-code
          no-error .
          if not available buf_tt-goods
          then do:
            create buf_tt-goods.
            buffer-copy buf_goods to buf_tt-goods.
          end. /* if not available but_tt-goods */
        end.
      end.
    end.
    when {&g-prod} then do: /* товары по производителю */
      for each g#cli no-lock,
          each buf_goods no-lock
            where buf_goods.prod-type = g#cli.obj-type
              and buf_goods.prod-code = g#cli.obj-code
              and buf_goods.stts      = 0
      :
        find first buf_tt-goods
          where buf_tt-goods.gds-code = buf_goods.gds-code
        no-error .
        if not available buf_tt-goods
        then do:
          create buf_tt-goods .
          buffer-copy buf_goods to buf_tt-goods.
        end.
      end.
    end.
    when {&g-choice} then do: /* товары выборочно */
      for each gds-list
      :
        find first buf_tt-goods
          where buf_tt-goods.gds-code = gds-list.gds-code
        no-error .
        if not available buf_tt-goods
        then do:
          create buf_tt-goods .
          buffer-copy gds-list
            except
              qnty
              to-del
              order-num
              to-sel
            to buf_tt-goods
          .
        end.
      end.
    end.
    when {&g-one} then do: /* один товар */
      for each gds-list
      :
        find first buf_tt-goods
          where buf_tt-goods.gds-code = gds-list.gds-code
        no-error .
        if not available buf_tt-goods
        then do:
          create buf_tt-goods .
          buffer-copy gds-list
            except
              qnty
              to-del
              order-num
              to-sel
            to buf_tt-goods
          .
        end.
      end.
    end.
    when {&g-grp-prod} then do: /* группа и производитель */
      for each gds-list
      :
        find first buf_tt-goods
          where buf_tt-goods.gds-code = gds-list.gds-code
        no-error .
        if not available buf_tt-goods
        then do:
          create buf_tt-goods .
          buffer-copy gds-list
            except
              qnty
              to-del
              order-num
              to-sel
            to buf_tt-goods
          .
        end.
      end.
    end.
  end case.
  run waitfram-hide in this-procedure .
end.

end procedure. /* fill-tt-goods */

/* ========================================================================================== */
procedure clear-tt :
  define buffer buf_tt-optprc for tt-optprc.
do  for buf_tt-optprc
on error undo, return error return-value
:
  empty temp-table buf_tt-optprc.
end.

end procedure. /* clear-tt */

/* ========================================================================================== */
procedure fill-tt :

  define buffer buf_gds-obj   for ub.gds-obj.
  define buffer buf_goods     for ub.goods.
  define buffer base-bar-code for ub.bar-code.
  define buffer buf_bar-code  for ub.bar-code.
  define buffer buf_clients   for ub.clients.
  define buffer buf_units     for ub.units.
  define buffer buf_price-list  for ub.price-list .

  define buffer buf_tt-goods  for tt-goods.
  define buffer buf_tt-optprc for tt-optprc.
do
on error undo, return error return-value
:

  define variable v-bar-code    like ub.bar-code.b-code  no-undo .
  define variable v-tot-gds-obj as integer            no-undo .
  define variable v-str         as character          no-undo .
  define variable v-prod-name   as character          no-undo .
  define variable v-artic       as character          no-undo .
  define variable v-doc-num     as character          no-undo .
  define variable v-price-sale  as decimal            no-undo .
  define variable v-road-tax    as decimal            no-undo .
  define variable v-excise      as decimal            no-undo .

  run fill-tt-goods in this-procedure .

  find first obj-list no-error .

  for each buf_gds-obj no-lock
    where buf_gds-obj.obj-type = obj-list.obj-type
      and buf_gds-obj.obj-code = obj-list.obj-code
  , first buf_tt-goods no-lock
      where buf_tt-goods.artic     = buf_gds-obj.artic
        and buf_tt-goods.prod-type = buf_gds-obj.prod-type
        and buf_tt-goods.prod-code = buf_gds-obj.prod-code
  :
    assign
      v-tot-gds-obj = v-tot-gds-obj + 1
    .
  end.
  run prg-bar_new in this-procedure ( 1, v-tot-gds-obj).
  run prg-bar_title in this-procedure ( input "Обработка товаров...":U).
  run prg-bar_show in this-procedure .

  goods-cycle:
  for each buf_gds-obj no-lock
    where buf_gds-obj.obj-type = obj-list.obj-type
      and buf_gds-obj.obj-code = obj-list.obj-code
  , first buf_tt-goods no-lock
      where buf_tt-goods.artic     = buf_gds-obj.artic
        and buf_tt-goods.prod-type = buf_gds-obj.prod-type
        and buf_tt-goods.prod-code = buf_gds-obj.prod-code
  :
    run prg-bar_increment in this-procedure .

    { gbl/gdsbcode.i
      buf_tt-goods.gds-code
      ?
      v-bar-code
      no-error
    }
    if error-status :error
    then do:
      next goods-cycle.
    end.

    find base-bar-code no-lock
      where base-bar-code.b-code = v-bar-code
    no-error .
    if not available base-bar-code then do:
      next goods-cycle.
    end.

    find first buf_clients no-lock
      where buf_clients.obj-type = buf_tt-goods.prod-type
        and buf_clients.obj-code = buf_tt-goods.prod-code
    no-error .
    assign
      v-prod-name = if available buf_clients then buf_clients.obj-name else "?":U
    .
    /* определяем цену для основного бар-кода */
    { gbl/bcodeprc.i
      buf_gds-obj.obj-type
      buf_gds-obj.obj-code
      base-bar-code.b-code
      0
      0
      v-doc-num
      v-price-sale
      v-road-tax
      v-excise
    }

    if v-price-sale = ?
    then do:
      next goods-cycle.
    end.

    find first buf_tt-optprc
      where buf_tt-optprc.gds-code = buf_tt-goods.gds-code
        and buf_tt-optprc.b-code   = base-bar-code.b-code
    no-error.
    if not available buf_tt-optprc
    then do:
      create buf_tt-optprc.
      assign
        buf_tt-optprc.gds-code       = buf_tt-goods.gds-code
        buf_tt-optprc.artic          = buf_tt-goods.artic
        buf_tt-optprc.b-code         = base-bar-code.b-code
        buf_tt-optprc.is-root-code   = true
        buf_tt-optprc.b-code-str     = string(base-bar-code.b-code, {&fmt-b-code})
        buf_tt-optprc.gds-name       = buf_tt-goods.gds-name
        buf_tt-optprc.grp-code       = buf_tt-goods.grp-code
        buf_tt-optprc.grp-name       = buf_tt-goods.grp-name
        buf_tt-optprc.prod-type      = buf_tt-goods.prod-type
        buf_tt-optprc.prod-code      = buf_tt-goods.prod-code
        buf_tt-optprc.prod-name      = v-prod-name
        buf_tt-optprc.unit-name      = base-bar-code.unit-cli
        buf_tt-optprc.price          = v-price-sale
        buf_tt-optprc.price-str      = string(v-price-sale, {&fmt-price})
        buf_tt-optprc.unit-qnty      = base-bar-code.cli-base-rate
        buf_tt-optprc.unit-price     = v-price-sale
        buf_tt-optprc.unit-price-str = string(v-price-sale, {&fmt-unit-price})
      .
      assign
        buf_tt-optprc.unit-qnty-str  = get-unit-qnty-str(buf_tt-optprc.unit-qnty)
      .
    end.

    bc-cycle:
    for each buf_bar-code no-lock
      where buf_bar-code.gds-code  = base-bar-code.gds-code
        and buf_bar-code.node-code = base-bar-code.node-code
        and buf_bar-code.part-code = base-bar-code.part-code
        and buf_bar-code.in-code   = base-bar-code.in-code
    :
      find first buf_tt-optprc
        where buf_tt-optprc.gds-code = buf_tt-goods.gds-code
          and buf_tt-optprc.b-code   = buf_bar-code.b-code
      no-error.
      if not available buf_tt-optprc
      then do:
        { gbl/bcodeprc.i
          buf_gds-obj.obj-type
          buf_gds-obj.obj-code
          buf_bar-code.b-code
          0
          0
          v-doc-num
          v-price-sale
          v-road-tax
          v-excise
        }
        if v-price-sale = ? or v-doc-num = ?
        then do:
          next bc-cycle.
        end.

        find first buf_price-list no-lock
          where buf_price-list.doc-num    = v-doc-num
            and buf_price-list.b-code     = buf_bar-code.b-code
            and buf_price-list.price-type = ""
          no-error.
        if not available buf_price-list and not p-show-without-price-doc
        then do:
          next bc-cycle.
        end.

        create buf_tt-optprc.
        assign
          buf_tt-optprc.gds-code       = buf_tt-goods.gds-code
          buf_tt-optprc.artic          = buf_tt-goods.artic
          buf_tt-optprc.b-code         = buf_bar-code.b-code
          buf_tt-optprc.is-root-code   = false
          buf_tt-optprc.b-code-str     = string(buf_bar-code.b-code, {&fmt-b-code})
          buf_tt-optprc.gds-name       = buf_tt-goods.gds-name
          buf_tt-optprc.grp-code       = buf_tt-goods.grp-code
          buf_tt-optprc.grp-name       = buf_tt-goods.grp-name
          buf_tt-optprc.prod-type      = buf_tt-goods.prod-type
          buf_tt-optprc.prod-code      = buf_tt-goods.prod-code
          buf_tt-optprc.prod-name      = v-prod-name
          buf_tt-optprc.unit-name      = buf_bar-code.unit-cli
          buf_tt-optprc.price          = v-price-sale / buf_bar-code.cli-base-rate
          buf_tt-optprc.price-str      = string(buf_tt-optprc.price, {&fmt-price})
          buf_tt-optprc.unit-qnty      = buf_bar-code.cli-base-rate
          buf_tt-optprc.unit-price     = v-price-sale
          buf_tt-optprc.unit-price-str = string(buf_tt-optprc.unit-price, {&fmt-unit-price})
        .
        assign
          buf_tt-optprc.unit-qnty-str  = get-unit-qnty-str(buf_tt-optprc.unit-qnty)
        .
      end.
    end. /* bc-cycle: */
  end. /* for each buf_gds-obj no-lock  */
  run prg-bar_delete in this-procedure .
end.

end procedure. /* fill-tt */

/* ========================================================================================== */
procedure print-report :
  define buffer buf_tt-optprc for tt-optprc.

do
on error undo, return error return-value
:
  define variable v-gds-name-lines  as decimal   no-undo .
  define variable v-prod-name-lines as decimal   no-undo .
  define variable v-grp-name-lines  as decimal   no-undo .
  define variable v-tot-lines       as integer   no-undo .
  define variable v-i               as integer   no-undo .
  define variable v-gds-name        as character no-undo .
  define variable v-prod-name       as character no-undo .
  define variable v-grp-name        as character no-undo .
  define variable v-grp-name-str    as character no-undo .

  run waitfram-show in this-procedure (input "Печать отчета":U ) .
  run print-header in this-procedure .

  view stream out-stream frame BottomFrame .
  view stream out-stream frame HeaderFrame .

  for each tt-optprc
    break by tt-optprc.grp-name
          by tt-optprc.artic
          by tt-optprc.is-root-code descending
          by tt-optprc.unit-qnty
  :
    if first-of(tt-optprc.grp-name)
    then do:
      assign
        v-grp-name = trim( tt-optprc.grp-name , "/":U )
      .

      if line-counter( out-stream ) + 3 > page-size( out-stream ) then do:
        page stream out-stream .
      end.
      if not first(tt-optprc.grp-name) and line-counter( out-stream ) > 3
      then do:
        put stream out-stream unformatted substitute( ":&1:" , fill('-',129)) skip .
      end.

      assign
        v-grp-name-lines = length(v-grp-name) / 129
      .

      if v-grp-name-lines > 1
      then do:
        assign
          v-tot-lines = round( v-grp-name-lines + 0.5 , 0 )
        .
      end.
      else do:
        assign
          v-tot-lines = 1
        .
      end.

      do v-i = 1 to v-tot-lines
      :
        assign
          v-grp-name-str  = substring(v-grp-name, 127 * (v-i - 1) + 1, 127)
        .
        put stream out-stream unformatted ": " v-grp-name-str format "X(127)" " :" skip .
      end.

      put stream out-stream unformatted substitute( ":&1:" , fill('-',129)) skip .

      run optprcxl-sheet1-write-line-data in this-procedure ( input v-grp-name
                                                            , input "":U
                                                            , input "":U
                                                            , input "":U
                                                            , input "":U
                                                            , input "":U
                                                            , input 0
                                                            , input "":U
                                                            ).
      run optprcxl-sheet1-write-line-format in this-procedure ( "GroupName" ).
    end.

    run optprcxl-sheet1-write-line-data in this-procedure ( input (if tt-optprc.is-root-code then tt-optprc.artic else "":U)
                                                          , input (if not tt-optprc.is-root-code then tt-optprc.b-code-str else "":U)
                                                          , input tt-optprc.gds-name
                                                          , input tt-optprc.prod-name
                                                          , input tt-optprc.unit-name
                                                          , input tt-optprc.price
                                                          , input (if not tt-optprc.is-root-code then trim(tt-optprc.unit-qnty-str) else "":U)
                                                          , input (if not tt-optprc.is-root-code then trim(tt-optprc.unit-price-str) else "":U)
                                                          ).

    assign
      v-gds-name-lines  = length(tt-optprc.gds-name)  / {&col-fmtlw-3}
      v-prod-name-lines = length(tt-optprc.prod-name) / {&col-fmtlw-4}
    .
    if (v-gds-name-lines > 1) or (v-prod-name-lines > 1)
    then do:
      assign
        v-tot-lines  = round( (if v-gds-name-lines > v-prod-name-lines then v-gds-name-lines else v-prod-name-lines) + 0.5 , 0)
      .
      do v-i = 1 to v-tot-lines
      :
        assign
          v-gds-name  = substring(tt-optprc.gds-name, {&col-fmtlw-3} * (v-i - 1) + 1, {&col-fmtlw-3})
          v-prod-name = substring(tt-optprc.prod-name, {&col-fmtlw-4} * (v-i - 1) + 1, {&col-fmtlw-4})
        .
        display stream out-stream
          sym1
          tt-optprc.artic when tt-optprc.is-root-code and v-i = 1
          sym2
          tt-optprc.b-code-str when not tt-optprc.is-root-code and v-i = 1
          sym3
          v-gds-name @ tt-optprc.gds-name
          sym4
          v-prod-name @ tt-optprc.prod-name
          sym5
          tt-optprc.unit-name when v-i = 1
          sym6
          tt-optprc.price-str when v-i = 1
          sym7
          tt-optprc.unit-qnty-str when not tt-optprc.is-root-code and v-i = 1
          sym8
          tt-optprc.unit-price-str when not tt-optprc.is-root-code and v-i = 1
          sym9
        with frame optprc .
        down stream out-stream with frame optprc.
      end.

    end.
    else do:
      display stream out-stream
        sym1
        tt-optprc.artic when tt-optprc.is-root-code
        sym2
        tt-optprc.b-code-str when not tt-optprc.is-root-code
        sym3
        tt-optprc.gds-name
        sym4
        tt-optprc.prod-name
        sym5
        tt-optprc.unit-name
        sym6
        tt-optprc.price-str
        sym7
        tt-optprc.unit-qnty-str when not tt-optprc.is-root-code
        sym8
        tt-optprc.unit-price-str when not tt-optprc.is-root-code
        sym9
      with frame optprc .
    end.
    down stream out-stream with frame optprc.
  end. /* for each tt-optprc */

  put stream out-stream unformatted v-line format "X(131)" skip.

  run print-footer in this-procedure .
  hide stream out-stream frame BottomFrame .
  run waitfram-hide in this-procedure .
end.

end procedure. /* print-report */

/* ========================================================================================== */
procedure print-header :

do
on error undo, return error return-value
:
  define variable v-org-str as character no-undo .
  define variable v-curr-time-str as character no-undo .

  run fmtcli-get-client in this-procedure
            ( input  {&cmp}
            , input  v-host-code
            ) .

  assign
    v-curr-time-str = cur-time-string()
  .
  assign
    v-org-str = substitute("&1 &2", v-fmtcli-name , obj-list.obj-name )
  .
  put stream out-stream unformatted
    "ПРАЙС-ЛИСТ":U skip
     v-curr-time-str skip
    v-org-str skip
    "Валюта: " v-curr-abbr skip(1)
  .

  put stream out-stream unformatted
    "-----------------------------------------------------------------------------------------------------------------------------------":U skip
    ":    Артикул     : Артикул  :        Наименование          :    Производитель   : Ед.: Цена за ед.  :   Кол-во в   :  Стоимость   :":U skip
    ":    основной    :неосновной:                              :                    :изм.:              :   упаковке   :  упаковки    :":U skip
    ":----------------:----------:------------------------------:--------------------:----:--------------:--------------:--------------:":U skip
    ":       1        :    2     :               3              :           4        :  5 :      6       :      7       :      8       :":U skip
    ":----------------:----------:------------------------------:--------------------:----:--------------:--------------:--------------:":U skip
 .

  run optprcxl-write-cell-data in this-procedure ( input {&optprcxl-h_org}
                                                 , input v-org-str
                                                 ).
  run optprcxl-write-cell-data in this-procedure ( input {&optprcxl-h_time}
                                                 , input v-curr-time-str
                                                 ).
  run optprcxl-write-cell-data in this-procedure ( input {&optprcxl-h_currency}
                                                 , input substitute("Валюта : &1" , v-curr-abbr)
                                                 ).


end.

end procedure. /* print-header */

/* ========================================================================================== */
procedure print-footer :

do
on error undo, return error return-value
:

end.

end procedure. /* print-footer */

/* ========================================================================================== */
function get-unit-qnty-str returns character (p-unit-qnty as decimal):
  define variable v-qnty-int  as integer   no-undo .
  define variable v-str       as character no-undo .

  if( p-unit-qnty <> 0)
  then do:
    assign
      v-qnty-int = truncate( p-unit-qnty, 0 )
    .

    if( p-unit-qnty = v-qnty-int )
    then do:
        assign
          v-str = string(v-qnty-int , {&fmt-unit-qnty-int})
        .
    end.
    else do:
        assign
          v-str = string(p-unit-qnty , {&fmt-unit-qnty-dcml})
        .
    end.
  end.
  else do:
    assign
      v-str = string(p-unit-qnty , {&fmt-unit-qnty-int})
    .
  end.

  return v-str.
end.