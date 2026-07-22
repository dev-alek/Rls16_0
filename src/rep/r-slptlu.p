block-level on error undo, throw.
/*

$Revision: 099a383cf864, 290, rls $
$Author: PGridchina $
$Date: Tue Dec 01 19:11:24 2015 +0300 $
$Workfile: r-slptlu.p $
$Archive: rep/r-slptlu.p $

отчет по розничной реализации нефтепродуктов на АЗК (Украина)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/22/07
Author: Dmitry Ukhanov
Creation date: 08/22/07

Author1: Dmitry Ukhanov
Creation date1: 05/05/06

*/

define variable vss-revision    as character no-undo initial "$Revision: 099a383cf864, 290, rls $":U .
define variable vss-author      as character no-undo initial "$Author: PGridchina $":U .
define variable vss-date        as character no-undo initial "$Date: Tue Dec 01 19:11:24 2015 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-slptlu.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-slptlu.p $":U .
define variable vss-description as character no-undo initial "отчет по приходу нефтепродуктов на АЗК (Украина)":U .

/* Parameters Definitions ---                                           */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ str/lib-trn.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ gbl/waitfram.i }
{ trg/factord.i  }
{ str/clcprtsl.i }
{ gbl/cur-time.i }
{ ref/gds-attr.i }


{ rep/real-2df.i "new shared" treal-2 }
{ rep/real-3df.i "new shared" treal-3 }
{ rep/real-4df.i "new shared" treal-4 }
{ rep/icm-2df.i  "new shared"         }
{ rep/icm-3df.i  "new shared"         }

define variable Header-Name      as character no-undo .
define variable Header-Line0     as character no-undo .
define variable Header-Line1     as character no-undo .
define variable Header-Line2     as character no-undo .
define variable Header-Line3     as character no-undo .
define variable Header-Line4     as character no-undo .
define variable Header-Line5     as character no-undo .
define variable Header-add-Line0 as character no-undo .
define variable Header-add-Line1 as character no-undo .
define variable Header-add-Line2 as character no-undo .
define variable Header-add-Line3 as character no-undo .
define variable Header-add-Line4 as character no-undo .
define variable Header-add-Line5 as character no-undo .
define variable Under-Line       as character no-undo .
define variable temp-line        as character no-undo .
define variable XLS-page-num     as integer   no-undo initial 0 .
define variable fact-order_from  as decimal   no-undo initial 0.00 .
define variable fact-order_till  as decimal   no-undo initial 0.00 .
define variable j_columns-total  as integer   no-undo .
define variable j_total-rows     as integer   no-undo .
define variable j_length         as integer   no-undo .
define variable j_line-order     as integer   no-undo .
define variable j_start-order    as integer   no-undo .
define variable j_line-counter   as integer   no-undo .
define variable jj               as integer   no-undo .
define variable j1               as integer   no-undo .
define variable goods-found      as logical   no-undo initial no .
define variable gds-gas-found    as logical   no-undo initial no .
define variable gds-ptr-found    as logical   no-undo initial no .
define variable d_summa          as decimal   no-undo .
define variable ext-column-label as character no-undo .
define variable d_all-qnty       as decimal   no-undo .
define variable d_all-sum        as decimal   no-undo .
define variable XL-delim         as character no-undo .
define variable v_data-type      as character no-undo .
define variable v_temp-param     as character no-undo .
define variable t_today          as date      no-undo .
define variable j_time           as integer   no-undo .
define variable j_excel-row      as integer   no-undo .
define variable j_excel-col      as integer   no-undo .
define variable j_excel-pay      as integer   no-undo .
define variable vcurr-sheet-name as character no-undo .
define variable v-green-row      as character no-undo .
define variable d_total-qnty     as decimal   no-undo .
define variable d_total-sum      as decimal   no-undo .
define variable d_gas-price      as decimal   no-undo .
define variable v-column-label-1 as character no-undo initial "":U .
define variable v-column-label-2 as character no-undo initial "":U .
define variable v-column-label-3 as character no-undo initial "":U .
define variable v-column-label-4 as character no-undo initial "":U .
define variable v-merge-cells-h1 as character no-undo initial "":U .
define variable v-merge-cells-h2 as character no-undo initial "":U .
define variable v-merge-cells-h3 as character no-undo initial "":U .
define variable v-params-adding  as character no-undo .
define variable num-monthes      as integer   no-undo .

define variable g#host-code      as integer   no-undo .
define variable g#report-num     as integer   no-undo .
define variable g#quest-print    as logical   no-undo initial yes .

define buffer bf_trn-doc       for ub.trn-doc       .
define buffer bf_doc-line      for ub.doc-line      .
define buffer bf_doc-line-attr for ub.doc-line-attr .
define buffer bf_clients       for ub.clients       .
define buffer bf_shift-obj     for ub.shift-obj     .

&scop f-l Centering,ShiftRight,CalcMonthes,MonthNameRus,NextMonth-MY
&scop total-label "И Т О Г О"

{ gbl/getcntxt.i   def  }
{ gbl/std-func.i {&f-l} }

function Centre returns character ( input i-string as character
                                  , input i-length as integer
                                  ) :
  define variable v-str as character no-undo .

  assign
    v-str = Centering( trim( i-string ), i-length )
  .
  if length( v-str ) < i-length
  then do:
    assign
      v-str = v-str + fill( " ":U, i-length - length( v-str ) )
    .
  end.
  else
  if length( v-str ) > i-length
  then do:
    assign
      v-str = substring( v-str, 1, i-length )
    .
  end.
  return ( v-str  ) .
end function. /* Centre */

function OutDec returns character ( input p-sum as decimal ) :
  define variable v-sum as character no-undo .

  run get-dec-string in this-procedure
    (  input p-sum
    , output v-sum
    ) no-error .
  return ( if error-status :error then fill( " ":U, 12 ) else v-sum ) .
end function. /* OutDec */

function RusMonth returns character ( input i-num as integer ) :
  define variable j-month as integer no-undo .
  define variable j-calc  as integer no-undo .

  assign
    j-month = month( x-Date-Start )
  .
  if i-num > 1
  then do:
    do j-calc = 1 to i-num - 1 :
      assign
        j-month = NextMonth-MY( j-month )
      .
    end.
  end.

  return ( MonthNameRus( j-month ) ) .
end function. /* RusMonth */

define temp-table gds-ptrl no-undo
  field obj-type  like ub.clients.obj-type
  field obj-code  like ub.clients.obj-code
  field artic     like ub.gds-obj.artic
  field prod-type like ub.gds-obj.prod-type
  field prod-code like ub.gds-obj.prod-code
  field gds-code  like ub.gds-obj.gds-code
  field gds-name  like ub.goods.gds-name
  field is-gas    as   logical
  field gds-order as   integer

  index artic     is   unique primary obj-type obj-code is-gas artic     prod-type prod-code
  index gds-code  is   unique         obj-type obj-code is-gas gds-code
  index gds-name                      obj-type obj-code is-gas gds-name
  index gds-order is   unique         obj-type obj-code is-gas gds-order
.

define temp-table gds-line no-undo
  field line-order as   integer
  field shift-date like ub.shift-obj.shift-date
  field shift-num  like ub.shift-obj.shift-num
  field shift-name like ub.shift-obj.shift-name
  field pay-code   as   integer            format "->>>>>>>>>9":U
  field out-name   like ub.clients.obj-name
  field pay-name   like ub.clients.obj-name
  field is-cash    as   logical
  field is-gas     as   logical
  field all-qnty   as   decimal decimals 2 format "->>>>>>>9.99":U
  field all-sum    as   decimal decimals 2 format "->>>>>>>9.99":U
  field row-count  as   integer
  field col-count  as   integer

  index pi         is   unique  primary  line-order
  index i0         is   unique           line-order is-cash    shift-date shift-num  pay-code   is-gas
  index i1         is   unique           pay-code   shift-date shift-num  is-gas
  index i2         is   unique           line-order shift-date shift-num  pay-code
  index i3         is   unique           shift-date shift-num  line-order
  index i4         is   unique           is-gas     shift-date shift-num  line-order
  index i5         is   unique           is-gas     pay-code   is-cash    shift-date shift-num  line-order
.

define temp-table gds-cell no-undo
  field line-order as   integer
  field shift-date like ub.shift-obj.shift-date
  field shift-num  like ub.shift-obj.shift-num
  field pay-code   as   integer            format "->>>>>>>>>9":U
  field is-cash    as   logical
  field is-gas     as   logical
  field gds-order  as   integer
  field gds-code   like ub.gds-obj.gds-code
  field gds-qnty   as   decimal decimals 2 format "->>>>>>>9.99":U
  field gds-price  as   decimal decimals 2 format "->>>>>>>9.99":U
  field gds-sum    as   decimal decimals 2 format "->>>>>>>9.99":U
  field row-count  as   integer
  field col-count  as   integer

  index pi         is   unique  primary  line-order gds-order
  index i0         is   unique           line-order shift-date shift-num is-cash  gds-code   pay-code
  index i1         is   unique           shift-date shift-num  pay-code  gds-code
  index i2         is   unique           line-order shift-date shift-num gds-code pay-code   is-cash
  index i3         is   unique           is-gas     pay-code   gds-order is-cash  shift-date shift-num gds-code
  index i4         is   unique           line-order is-gas     gds-order
.

define temp-table tt_object no-undo
  field obj-type  like ub.clients.obj-type
  field obj-code  like ub.clients.obj-code
  field obj-name  like ub.clients.obj-name
  field obj-id    as   integer
  field db-num    as   integer
  field gds-found as   logical
  field gas-found as   logical
  field was-found as   logical

  index pi        is   unique  primary obj-id
  index ie1       is   unique          obj-type obj-code
  index ie2                            obj-name
.

define temp-table tt_obj-pay no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field pay-name like ub.clients.obj-name
  field pay-num  as   integer
  field xls-col  as   integer

  index pi       is   unique primary obj-type obj-code pay-name
  index i1       is   unique         xls-col           pay-name
.

define buffer bf_gds-ptrl for gds-ptrl   .
define buffer bf_object   for tt_object  .
define buffer bf_gds-line for gds-line   .
define buffer bf_gds-cell for gds-cell   .
define buffer bf_obj-pay  for tt_obj-pay .

define stream text_out .

{ gbl/prn-lib.i " " text_out }

do
on error undo, return error return-value
:
  run WaitFram-Show in this-procedure
    ( input {&MyWaitMess}
    ) .
  {&SetCursorWait}
  run get-report-num  in my-handle
    (
      output g#report-num
    ) .
  run get-quest-print in my-handle
    (
      output g#quest-print
    ) .
  { gbl/getcntxt.i
      get
      " "
      my-handle
  }

  assign
    g#host-code = v-cntxt-host-code-obj
  .

  run cur-time      in this-procedure
    ( output t_today
    , output j_time
    ) .
  { gbl/getsect.i  def }
  { gbl/getsect.i run v-cntxt-obj-type  v-cntxt-obj-code {&attr-report-firm} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'XL-delim'  then v_temp-param   = thbjattr_thbj-attr.property-value-character.
  end.
  IF v_temp-param = "" then XL-delim = ";".
  else XL-delim = v_temp-param.

  for each SheetF where
           SheetF.Sheet-Num > 1
  :
    delete SheetF .
  end.
  for each obj-list no-lock
  :
    create tt_object .
    assign
      tt_object.obj-type  = obj-list.obj-type
      tt_object.obj-code  = obj-list.obj-code
      tt_object.obj-name  = obj-list.obj-name
      tt_object.obj-id    = obj-list.obj-id
      tt_object.db-num    = obj-list.db-num
      tt_object.gds-found = no
      tt_object.gas-found = no
    .
  end. /* for each obj-list */

  run prn-lib-open-stream in this-procedure
    ( input my-handle
    , input {&LS_PS_A4}
    , input yes
    , input no
    ) .

  for each tt_object no-lock
  :
    for each gds-line
    :
      delete gds-line .
    end. /* for each gds-line */
    for each gds-cell
    :
      delete gds-cell .
    end. /* for each gds-line */
    assign
      v-green-row = "":U
    .

    assign
      ReportName       = "":U
      ReportHeader     = "":U
      str1             = "":U
      str2             = "":U
      str3             = "":U
      str4             = "":U
      /*                  :    10    :        17       :     12     :     12     : */
      Header-Line0     = "--------------------------------------------------------"
      Header-Line1     = ":          :                 :          Итого          :"
      Header-Line2     = ":   Дата   :    Покупатель   :------------:------------:"
      Header-Line3     = ":          :                 :   Кол-во   :  сумма нал :"
      Header-Line4     = ":          :                 :     (л)    :   (грн.)   :"
      Header-Line5     = ":----------:-----------------:------------:------------:"
      Header-add-Line0 = "":U
      Header-add-Line1 = "":U
      Header-add-Line2 = "":U
      Header-add-Line3 = "":U
      Header-add-Line4 = "":U
      Header-add-Line5 = "":U
    .
    assign
      j_excel-row = 0
      j_excel-col = 0
    .
    run get-fo-range in this-procedure
      (  input tt_object.obj-type
      ,  input tt_object.obj-code
      ,  input x-Date-Start
      ,  input x-Date-End
      ,  input x-Shift-Start
      ,  input x-Shift-End
      ,  input x-TOG-Shift
      , output fact-order_from
      , output fact-order_till
      ) no-error .
    if error-status :error
    then do:
      message return-value view-as alert-box .
      return error .
    end.

    assign
      j_columns-total = 0
      j_line-order    = 0
    .
    assign
      XLS-page-num = XLS-page-num + 1
    .
    find first SheetF where
               SheetF.Sheet-Num = XLS-page-num no-error .
    if not available SheetF
    then do:
      create SheetF .
      assign
        SheetF.Sheet-Num = XLS-page-num
      .
    end.
    assign
      SheetF.MergeCellsH        = "3:4"
      SheetF.MergeCellsV        = "1=1:2/2=1:2"
      SheetF.Excel-Column-Lable = "Дата"              + {&comma-char} +
                                  "Покупатель"        + {&comma-char} +
                                  "Итого"             + {&comma-char} +
                                  "":U
      SheetF.ColFormat          = "3=" + "0" + v-delim + "00" + ";" +
                                  "4=" + "0" + v-delim + "00"
      SheetF.Sizes              = "10,17,12,12"
      ext-column-label          = "":U             + {&comma-char} +
                                  "":U             + {&comma-char} +
                                  "Кол-во (л)"     + {&comma-char} +
                                  "Сумма нал(грн)"
    .
    run cr-gds-list in this-procedure
      ( input tt_object.obj-type
      , input tt_object.obj-code
      ) no-error .
    if error-status :error
    then do:
      message return-value view-as alert-box .
      return error .
    end.
    find first bf_gds-ptrl no-lock where
               bf_gds-ptrl.obj-type = tt_object.obj-type and
               bf_gds-ptrl.obj-code = tt_object.obj-code no-error .
    if not available bf_gds-ptrl
    then do:
      assign
        SheetF.MergeCellsH        = "":U
        SheetF.MergeCellsV        = "":U
        SheetF.Excel-Column-Lable = "":U
        SheetF.ColFormat          = "":U
        SheetF.Sizes              = "":U
        ext-column-label          = "":U
        XLS-page-num              = XLS-page-num - 1
      .
      next .
    end.

    assign
      goods-found   = no
      gds-ptr-found = no
      gds-gas-found = no
    .
    for each gds-ptrl no-lock where
             gds-ptrl.obj-type = tt_object.obj-type and
             gds-ptrl.obj-code = tt_object.obj-code
    :
      find first bf_object exclusive-lock where
          recid( bf_object ) = recid( tt_object ) .
      if gds-ptrl.is-gas = no
      then do:
        assign
          bf_object.gds-found = yes
        .
        assign
          gds-ptr-found = yes
        .
      end.
      if gds-ptrl.is-gas = yes
      then do:
        assign
          bf_object.gas-found = yes
        .
        assign
          gds-gas-found = yes
        .
      end.
      if bf_object.gas-found = yes or
         bf_object.gds-found = yes
      then do:
        assign
          bf_object.was-found = yes
        .
      end.
      find first bf_object        no-lock where
          recid( bf_object ) = recid( tt_object ) .
    end. /* for each gds-ptrl */

    assign
      j_columns-total = 0
    .
    for each gds-ptrl no-lock where
             gds-ptrl.obj-type = tt_object.obj-type and
             gds-ptrl.obj-code = tt_object.obj-code and
             gds-ptrl.is-gas   = no
          by gds-ptrl.gds-order
    :
      assign
        gds-ptr-found    = yes
        j_columns-total  = j_columns-total  + 1
        Header-add-Line0 = Header-add-Line0 + "---------------------------------------"
        Header-add-Line1 = Header-add-Line1 + Centre( gds-ptrl.gds-name, 38 )     + ":"
        Header-add-Line2 = Header-add-Line2 + "------------:------------:------------:"
        Header-add-Line3 = Header-add-Line3 + "   Кол-во   :    Цена    :    Сумма   :"
        Header-add-Line4 = Header-add-Line4 + "     (л)    :   реализ   :   реализ   :"
        Header-add-Line5 = Header-add-Line5 + "------------:------------:------------:"
      .
      assign
        SheetF.Excel-Column-Lable = SheetF.Excel-Column-Lable + {&comma-char} +
                                    replace( gds-ptrl.gds-name, {&comma-char}, {&space-char} )
                                                              + {&comma-char}
                                                              + {&comma-char}
        ext-column-label          = ext-column-label          + {&comma-char} +
                                    "Кол-во (л)"              + {&comma-char} +
                                    "Цена реализ"             + {&comma-char} +
                                    "Сумма реализ"
        SheetF.ColFormat          = SheetF.ColFormat                                               + ";" +
                                    string( j_columns-total * 3 + 2 ) + "=" + "0" + v-delim + "00" + ";" +
                                    string( j_columns-total * 3 + 3 ) + "=" + "0" + v-delim + "00" + ";" +
                                    string( j_columns-total * 3 + 4 ) + "=" + "0" + v-delim + "00"
        SheetF.Sizes              = SheetF.Sizes + {&comma-char} + "12" +
                                                   {&comma-char} + "12" +
                                                   {&comma-char} + "12"
        SheetF.MergeCellsH        = SheetF.MergeCellsH                + {&comma-char} +
                                    string( j_columns-total * 3 + 2 ) + ":"           +
                                    string( j_columns-total * 3 + 4 )
      .
    end. /* for each gds-ptrl */
    assign
      SheetF.Excel-Column-Lable = SheetF.Excel-Column-Lable + {&new-line} + ext-column-label
    .

    if tt_object.gds-found = yes
    then do:
      assign
        ReportName   = substitute( 'Отчет по розничной реализации нефтепродуктов на &1'
                                 , tt_object.obj-name
                                 )
        j_length     = 56 + 39 * j_columns-total
        Under-Line   = fill( "-", j_length )
        str1         = substitute( "за период с &1 по &2"
                                 , string( x-Date-Start, "99/99/9999":U )
                                 , string( x-Date-End,   "99/99/9999":U )
                                 )
        ReportHeader = substitute( "Дата печати: &1, время: &2"
                                 , string( t_today, "99.99.9999":U )
                                 , string( j_time,  "HH:MM:SS":U   )
                                 )
        Header-Name  = Centering(  caps( ReportName ), j_length ) +
                       {&new-line}                                +
                       Centering(        str1,         j_length ) +
                       {&new-line}                                +
                       {&new-line}                                +
                       {&new-line}                                +
                       ShiftRight(       ReportHeader, j_length )
      .
      assign
        j_line-order = 0
      .
      for each bf_shift-obj no-lock where
               bf_shift-obj.obj-type    = tt_object.obj-type and
               bf_shift-obj.obj-code    = tt_object.obj-code and
               bf_shift-obj.status_     = {&sht-closed}      and
               bf_shift-obj.fact-order >= fact-order_from    and
               bf_shift-obj.fact-order <= fact-order_till
      break by bf_shift-obj.shift-date
            by bf_shift-obj.shift-num
      :
        if first-of( bf_shift-obj.shift-num )
        then do:
          for each treal-2
          :
            delete treal-2 .
          end.
          run rep/r-shftch.p
            ( input bf_shift-obj.obj-type
            , input bf_shift-obj.obj-code
            , input bf_shift-obj.shift-date
            , input bf_shift-obj.shift-num
            , input bf_shift-obj.shift-date
            , input bf_shift-obj.shift-num
            , input 1110
            , input yes
            , input yes
            , input yes
            , input no /*sheet8**/
            , input no
            , input no
            ) no-error .
          if error-status :error
          then do:
            message return-value view-as alert-box .
            return error .
          end.
        end. /* if first-of( bf_shift-obj.shift-num ) */
        assign
          j_excel-row   = 0
          j_start-order = j_line-order
        .
        for each treal-2 no-lock where
                 treal-2.is-pay    <> ? and
                 treal-2.curr-code >= 0
        :
          find first gds-ptrl no-lock where
                     gds-ptrl.obj-type = tt_object.obj-type and
                     gds-ptrl.obj-code = tt_object.obj-code and
                     gds-ptrl.is-gas   = no                 and
                     gds-ptrl.gds-code = treal-2.gds-code   no-error .
          if not available gds-ptrl
          then do:
            next .
          end.
          assign
            j_excel-row = j_excel-row + 1
          .
          find first gds-line where
                     gds-line.pay-code   = treal-2.cpay-code       and
                     gds-line.shift-date = bf_shift-obj.shift-date and
                     gds-line.shift-num  = bf_shift-obj.shift-num  and
                     gds-line.is-gas     = gds-ptrl.is-gas         no-error .
          if not available gds-line
          then do:
            assign
              j_line-order = j_line-order + 10
            .
            find first ub.cash-pay no-lock where
                       ub.cash-pay.cdpay-code = treal-2.cpay-code and
                       ub.cash-pay.curr-code  = treal-2.curr-code no-error .
            create gds-line .
            assign
              gds-line.line-order = j_line-order
              gds-line.shift-date = bf_shift-obj.shift-date
              gds-line.shift-num  = bf_shift-obj.shift-num
              gds-line.shift-name = bf_shift-obj.shift-name
              gds-line.pay-code   = treal-2.cpay-code
              gds-line.out-name   = treal-2.out-name
              gds-line.pay-name   = ( if available ub.cash-pay then ub.cash-pay.obj-name else treal-2.out-name )
              gds-line.is-cash    = ( if available ub.cash-pay then ub.cash-pay.is-cash  else no )
              gds-line.is-gas     = gds-ptrl.is-gas
              gds-line.col-count  = j_columns-total
            .
            if gds-line.is-cash = no and
               ( available ub.cash-pay )
            then do:
              find first tt_obj-pay no-lock where
                         tt_obj-pay.obj-type = bf_shift-obj.obj-type and
                         tt_obj-pay.obj-code = bf_shift-obj.obj-code and
                         tt_obj-pay.pay-name = gds-line.pay-name     no-error .
              if not available tt_obj-pay
              then do:
                create tt_obj-pay .
                assign
                  tt_obj-pay.obj-type = bf_shift-obj.obj-type
                  tt_obj-pay.obj-code = bf_shift-obj.obj-code
                  tt_obj-pay.pay-name = gds-line.pay-name
                  tt_obj-pay.pay-num  = 0
                  tt_obj-pay.xls-col  = 0
                .
              end. /* if not available tt_obj-pay */
            end. /* if gds-line.is-cash = no */
          end. /* if not available gds-line */
          assign
            gds-line.all-qnty = gds-line.all-qnty + treal-2.qnty1
            gds-line.all-sum  = gds-line.all-sum  + ( if gds-line.is-cash = yes then treal-2.netto else 0.00 )
          .

          find first gds-cell where
                     gds-cell.shift-date = bf_shift-obj.shift-date and
                     gds-cell.shift-num  = bf_shift-obj.shift-num  and
                     gds-cell.pay-code   = treal-2.cpay-code       and
                     gds-cell.gds-code   = treal-2.gds-code        no-error .
          if not available gds-cell
          then do:
            create gds-cell .
            assign
              gds-cell.line-order = gds-line.line-order
              gds-cell.shift-date = gds-line.shift-date
              gds-cell.shift-num  = gds-line.shift-num
              gds-cell.pay-code   = gds-line.pay-code
              gds-cell.is-cash    = gds-line.is-cash
              gds-cell.is-gas     = gds-ptrl.is-gas
              gds-cell.gds-order  = gds-ptrl.gds-order
              gds-cell.gds-code   = gds-ptrl.gds-code
              gds-cell.col-count  = gds-line.col-count
            .
          end. /* if not available gds-cell */
          assign
            gds-cell.gds-qnty  = gds-cell.gds-qnty  + treal-2.qnty1
            gds-cell.gds-sum   = gds-cell.gds-sum   + ( if treal-2.is-pay = yes then treal-2.netto                 else 0.00 )
            gds-cell.gds-price = gds-cell.gds-price + ( if treal-2.is-pay = yes then treal-2.netto / treal-2.qnty1 else 0.00 )
          .
        end. /* for each treal-2 */
        for each gds-line where
                 gds-line.line-order > j_start-order
        :
          for each gds-cell where
                   gds-cell.line-order = gds-line.line-order
          :
            assign
              gds-cell.row-count = j_excel-row
            .
          end. /* for each gds-cell */
          assign
            gds-line.row-count = j_excel-row
          .
        end. /* for each gds-line */

        /* итоги (б/н) */
        assign
          d_all-qnty = 0.00
          d_all-sum  = 0.00
        .
        for each gds-line no-lock
           where gds-line.line-order > j_start-order
             and gds-line.is-cash    = no
             and gds-line.shift-date = bf_shift-obj.shift-date
             and gds-line.shift-num  = bf_shift-obj.shift-num
        :
          assign
            d_all-qnty = d_all-qnty + gds-line.all-qnty
          .
        end. /* for each gds-line */
        assign
          j_line-order = j_line-order + 10
        .
        create gds-line .
        assign
          gds-line.line-order = j_line-order
          gds-line.shift-date = bf_shift-obj.shift-date
          gds-line.shift-num  = bf_shift-obj.shift-num
          gds-line.shift-name = bf_shift-obj.shift-name
          gds-line.pay-code   = 1000000001
          gds-line.out-name   = "Всего б/н"
          gds-line.pay-name   = "Всего б/н"
          gds-line.is-cash    = no
          gds-line.is-gas     = no
          gds-line.col-count  = j_columns-total
          gds-line.row-count  = j_excel-row
          gds-line.all-qnty   = d_all-qnty
          gds-line.all-sum    = 0.00
        .
        assign
          d_all-qnty = 0.00
        .
        for each bf_gds-cell no-lock where
                 bf_gds-cell.line-order > j_start-order       and
                 bf_gds-cell.shift-date = gds-line.shift-date and
                 bf_gds-cell.shift-num  = gds-line.shift-num  and
                 bf_gds-cell.is-cash    = gds-line.is-cash
        break by bf_gds-cell.gds-code
              by bf_gds-cell.pay-code
        :
          if first-of( bf_gds-cell.gds-code )
          then do:
            assign
              d_all-qnty = 0.00
            .
          end. /* if first-of( bf_gds-cell.pay-code ) */
          assign
            d_all-qnty = d_all-qnty + bf_gds-cell.gds-qnty
          .
          if last-of( bf_gds-cell.gds-code )
          then do:
            create gds-cell .
            assign
              gds-cell.line-order = j_line-order
              gds-cell.shift-date = gds-line.shift-date
              gds-cell.shift-num  = gds-line.shift-num
              gds-cell.pay-code   = gds-line.pay-code
              gds-cell.is-cash    = gds-line.is-cash
              gds-cell.is-gas     = bf_gds-cell.is-gas
              gds-cell.gds-order  = bf_gds-cell.gds-order
              gds-cell.gds-code   = bf_gds-cell.gds-code
              gds-cell.col-count  = gds-line.col-count
              gds-cell.gds-qnty   = d_all-qnty
              gds-cell.gds-sum    = 0.00
              gds-cell.gds-price  = 0.00
            .
          end. /* if last-of( bf_gds-cell.pay-code ) */
        end. /* for each bf_gds-cell */

        /* итоги (нал) */
        assign
          d_all-qnty = 0.00
          d_all-sum  = 0.00
        .
        for each gds-line no-lock
           where gds-line.line-order > j_start-order
             and gds-line.is-cash    = yes
             and gds-line.shift-date = bf_shift-obj.shift-date
             and gds-line.shift-num  = bf_shift-obj.shift-num
        on error undo, return error return-value
        :
          assign
            d_all-qnty = d_all-qnty + gds-line.all-qnty
            d_all-sum  = d_all-sum  + gds-line.all-sum
          .
        end. /* for each gds-line */
        assign
          j_line-order = j_line-order + 10
        .
        create gds-line .
        assign
          gds-line.line-order = j_line-order
          gds-line.shift-date = bf_shift-obj.shift-date
          gds-line.shift-num  = bf_shift-obj.shift-num
          gds-line.shift-name = bf_shift-obj.shift-name
          gds-line.pay-code   = 1000000002
          gds-line.out-name   = "Всего нал"
          gds-line.pay-name   = "Всего нал"
          gds-line.is-cash    = yes
          gds-line.is-gas     = no
          gds-line.col-count  = j_columns-total
          gds-line.row-count  = j_excel-row
          gds-line.all-qnty   = d_all-qnty
          gds-line.all-sum    = d_all-sum
        .
        assign
          d_all-qnty = 0.00
          d_all-sum  = 0.00
        .
        for each bf_gds-cell no-lock where
                 bf_gds-cell.line-order > j_start-order       and
                 bf_gds-cell.shift-date = gds-line.shift-date and
                 bf_gds-cell.shift-num  = gds-line.shift-num  and
                 bf_gds-cell.is-cash    = gds-line.is-cash
        break by bf_gds-cell.gds-code
              by bf_gds-cell.pay-code
        :
          if first-of( bf_gds-cell.gds-code )
          then do:
            assign
              d_all-qnty = 0.00
              d_all-sum  = 0.00
            .
          end. /* if first-of( bf_gds-cell.pay-code ) */
          assign
            d_all-qnty = d_all-qnty + bf_gds-cell.gds-qnty
            d_all-sum  = d_all-sum  + bf_gds-cell.gds-sum
          .
          if last-of( bf_gds-cell.gds-code )
          then do:
            create gds-cell .
            assign
              gds-cell.line-order = j_line-order
              gds-cell.shift-date = gds-line.shift-date
              gds-cell.shift-num  = gds-line.shift-num
              gds-cell.pay-code   = gds-line.pay-code
              gds-cell.is-cash    = gds-line.is-cash
              gds-cell.is-gas     = bf_gds-cell.is-gas
              gds-cell.gds-order  = bf_gds-cell.gds-order
              gds-cell.gds-code   = bf_gds-cell.gds-code
              gds-cell.col-count  = gds-line.col-count
              gds-cell.gds-qnty   = d_all-qnty
              gds-cell.gds-sum    = d_all-sum
              gds-cell.gds-price  = 0.00
            .
          end. /* if last-of( bf_gds-cell.pay-code ) */
        end. /* for each bf_gds-cell */

        /* итоги (нал+б/н) */
        assign
          d_all-qnty = 0.00
          d_all-sum  = 0.00
        .
        for each gds-line no-lock where
                 gds-line.line-order > j_start-order           and
                 gds-line.shift-date = bf_shift-obj.shift-date and
                 gds-line.shift-num  = bf_shift-obj.shift-num  and
               ( gds-line.pay-code   = 1000000001 or
                 gds-line.pay-code   = 1000000002 )
        :
          assign
            d_all-qnty = d_all-qnty + gds-line.all-qnty
            d_all-sum  = d_all-sum  + gds-line.all-sum
          .
        end. /* for each gds-line */
        assign
          j_line-order = j_line-order + 10
        .
        create gds-line .
        assign
          gds-line.line-order = j_line-order
          gds-line.shift-date = bf_shift-obj.shift-date
          gds-line.shift-num  = bf_shift-obj.shift-num
          gds-line.shift-name = bf_shift-obj.shift-name
          gds-line.pay-code   = 1000000003
          gds-line.out-name   = "Всего (нал+б/н)"
          gds-line.pay-name   = "Всего (нал+б/н)"
          gds-line.is-cash    = ?
          gds-line.is-gas     = no
          gds-line.col-count  = j_columns-total
          gds-line.row-count  = j_excel-row
          gds-line.all-qnty   = d_all-qnty
          gds-line.all-sum    = d_all-sum
        .
        assign
          d_all-qnty = 0.00
          d_all-sum  = 0.00
        .
        for each bf_gds-cell no-lock
           where bf_gds-cell.line-order > j_start-order
             and bf_gds-cell.shift-date = gds-line.shift-date
             and bf_gds-cell.shift-num  = gds-line.shift-num
             and ( bf_gds-cell.pay-code   = 1000000001
                  or bf_gds-cell.pay-code = 1000000002 )

        break by bf_gds-cell.gds-code
              by bf_gds-cell.pay-code
        :
          if first-of( bf_gds-cell.gds-code )
          then do:
            assign
              d_all-qnty = 0.00
              d_all-sum  = 0.00
            .
          end. /* if first-of( bf_gds-cell.pay-code ) */
          assign
            d_all-qnty = d_all-qnty + bf_gds-cell.gds-qnty
            d_all-sum  = d_all-sum  + bf_gds-cell.gds-sum
          .
          if last-of( bf_gds-cell.gds-code )
          then do:
            create gds-cell .
            assign
              gds-cell.line-order = j_line-order
              gds-cell.shift-date = gds-line.shift-date
              gds-cell.shift-num  = gds-line.shift-num
              gds-cell.pay-code   = gds-line.pay-code
              gds-cell.is-cash    = gds-line.is-cash
              gds-cell.is-gas     = bf_gds-cell.is-gas
              gds-cell.gds-order  = bf_gds-cell.gds-order
              gds-cell.gds-code   = bf_gds-cell.gds-code
              gds-cell.col-count  = gds-line.col-count
              gds-cell.gds-qnty   = d_all-qnty
              gds-cell.gds-sum    = d_all-sum
              gds-cell.gds-price  = 0.00
            .
          end. /* if last-of( bf_gds-cell.pay-code ) */
        end. /* for each bf_gds-cell */
        assign
          d_all-qnty = 0.00
          d_all-sum  = 0.00
        .
      end. /* for each bf_shift-obj */

      /* итого */
      assign
        j_start-order = j_line-order
      .
      for each bf_gds-line no-lock
         where bf_gds-line.is-gas     = no
           and bf_gds-line.line-order <= j_start-order
      break by bf_gds-line.pay-code
            by bf_gds-line.is-cash
            by bf_gds-line.shift-date
            by bf_gds-line.shift-num
            by bf_gds-line.line-order
      :
        if first-of( bf_gds-line.pay-code )
        then do:
          assign
            j_line-order = j_line-order + 10
          .
          create gds-line .
          assign
            gds-line.line-order = j_line-order
            gds-line.shift-date = today + 396
            gds-line.shift-num  = 99
            gds-line.shift-name = {&total-label}
            gds-line.pay-code   = bf_gds-line.pay-code
            gds-line.out-name   = bf_gds-line.out-name
            gds-line.pay-name   = bf_gds-line.pay-name
            gds-line.is-cash    = bf_gds-line.is-cash
            gds-line.is-gas     = bf_gds-line.is-gas
            gds-line.col-count  = bf_gds-line.col-count
            gds-line.row-count  = 0
            gds-line.all-qnty   = 0.00
            gds-line.all-sum    = 0.00
          .
        end. /* if first-of( bf_gds-line.pay-code ) */
        assign
          gds-line.all-qnty  = gds-line.all-qnty  + bf_gds-line.all-qnty
          gds-line.row-count = gds-line.row-count + 1
        .

        if gds-line.is-cash <> no
        then do:
          assign
            gds-line.all-sum = gds-line.all-sum + bf_gds-line.all-sum
          .
        end.
        if last-of( bf_gds-line.pay-code )
        then do:
          for each bf_gds-cell no-lock
             where bf_gds-cell.is-gas   = bf_gds-line.is-gas
               and bf_gds-cell.pay-code = bf_gds-line.pay-code
               and bf_gds-cell.line-order <= j_start-order
          break by bf_gds-cell.gds-order
                by bf_gds-cell.is-cash
                by bf_gds-cell.shift-date
                by bf_gds-cell.shift-num
                by bf_gds-cell.gds-code
          :
            if first-of( bf_gds-cell.gds-order )
            then do:
              create gds-cell .
              assign
                gds-cell.line-order = gds-line.line-order
                gds-cell.shift-date = gds-line.shift-date
                gds-cell.shift-num  = gds-line.shift-num
                gds-cell.pay-code   = gds-line.pay-code
                gds-cell.is-cash    = gds-line.is-cash
                gds-cell.is-gas     = bf_gds-cell.is-gas
                gds-cell.gds-order  = bf_gds-cell.gds-order
                gds-cell.gds-code   = bf_gds-cell.gds-code
                gds-cell.col-count  = gds-line.col-count
                gds-cell.row-count  = gds-line.row-count
                gds-cell.gds-qnty   = 0.00
                gds-cell.gds-price  = 0.00
                gds-cell.gds-sum    = 0.00
              .
            end. /* first-of( bf_gds-cell.gds-order ) */
            assign
              gds-cell.gds-qnty = gds-cell.gds-qnty + bf_gds-cell.gds-qnty
            .
            if gds-cell.is-cash <> no
            then do:
              assign
                gds-cell.gds-sum = gds-cell.gds-sum + bf_gds-cell.gds-sum
              .
            end.
          end. /* for each bf_gds-cell */
        end. /* if last-of( bf_gds-line.pay-code ) */
      end. /* for each bf_gds-line */

      assign
        j_total-rows   = 0
        j_line-counter = 0
      .
      for each gds-line no-lock
      break by gds-line.shift-date
            by gds-line.shift-num
            by gds-line.line-order
      :
        if first-of( gds-line.shift-num )
        then do:
          assign
            j_line-counter = 0
          .
        end. /* if first-of( gds-line.shift-num ) */
        if gds-line.pay-code = 1000000002
        then do:
          next .
        end.
        if gds-line.all-qnty = 0.00
        then do:
          next .
        end.
        assign
          j_line-counter = j_line-counter + 1
        .
        if last-of( gds-line.shift-num )
        then do:
          assign
            j_total-rows = j_total-rows + j_line-counter
            v-green-row  = v-green-row  +
                           ( if v-green-row = "":U then "":U else {&comma-char} ) +
                           string( j_total-rows + 6 )
          .
          for each bf_gds-line where
                   bf_gds-line.shift-date = gds-line.shift-date and
                   bf_gds-line.shift-num  = gds-line.shift-num
          :
            for each bf_gds-cell where
                     bf_gds-cell.line-order = bf_gds-line.line-order
            :
              assign
                bf_gds-cell.row-count = j_line-counter
              .
            end. /* for each bf_gds-cell */
            assign
              bf_gds-line.row-count = j_line-counter
            .
          end. /* for each bf_gds-line */
        end. /* if last-of( gds-line.shift-num ) */
      end. /* for each gds-line */
      if not can-find( first bf_gds-line no-lock )
      then do:
        assign
          SheetF.MergeCellsH        = "":U
          SheetF.MergeCellsV        = "":U
          SheetF.Excel-Column-Lable = "":U
          SheetF.ColFormat          = "":U
          SheetF.Sizes              = "":U
          ext-column-label          = "":U
          XLS-page-num              = XLS-page-num - 1
        .
        next .
      end.

      put stream text_out unformatted
        Header-Name                     skip
        Header-Line0 + Header-add-Line0 skip
        Header-Line1 + Header-add-Line1 skip
        Header-Line2 + Header-add-Line2 skip
        Header-Line3 + Header-add-Line3 skip
        Header-Line4 + Header-add-Line4 skip
        Header-Line5 + Header-add-Line5 skip
      .
      assign
        /* vcurr-sheet-name = string( XLS-page-num ) + ". " + tt_object.obj-name */
        vcurr-sheet-name = tt_object.obj-name
      .
      assign
        Sheetf.Bas-File      = "slptrluk.bas"
        Sheetf.Bas-Param-Add = yes
        Sheetf.Bas-Params    = "Petrol"                               + {&delim-par} +
                               string(              j_total-rows    ) + {&delim-par} +
                               string(              j_columns-total ) + {&delim-par} +
                                                                        {&delim-par} +
                               string( num-entries( v-green-row   ) ) + {&delim-par} +
                               v-green-row
        SheetF.ColFormat     = SheetF.ColFormat                       + {&delim-par} +
                                                                        {&delim-par} +
                               vcurr-sheet-name
      .
      run rep/extitle.p
        ( input XLS-page-num
        ) no-error .
      assign
        j_line-counter = 0
      .
      for each gds-line no-lock where
               gds-line.is-gas = no
      break by gds-line.shift-date
            by gds-line.shift-num
            by gds-line.line-order
      :
        if first-of( gds-line.shift-num )
        then do:
          assign
            j_line-counter = 0
          .
        end. /* if first-of( gds-line.shift-num ) */
        if gds-line.pay-code = 1000000002
        then do:
          next .
        end.
        if gds-line.all-qnty = 0.00
        then do:
          next .
        end.
        assign
          j_line-counter = j_line-counter + 1
        .
        case j_line-counter :
          when 1
          then do:
            if gds-line.shift-name = {&total-label}
            then do:
              put stream text_out unformatted
                ":" + fill( " ":U, 10 )
              .
              {&PutExcel}
                string( gds-line.shift-name, "x(10)":U      ) {&tabulation}
              .
            end.
            else do:
              put stream text_out unformatted
                ":" + string( gds-line.shift-date, "99.99.9999":U )
              .
              {&PutExcel}
                string( gds-line.shift-date, "99.99.9999":U ) + " ":U +
                string( gds-line.shift-name, "x(10)":U      ) {&tabulation}
              .
            end.
          end.
          when 2
          then do:
            put stream text_out unformatted
              ":" + Centre( gds-line.shift-name, 10 )
            .
            {&PutExcel}
              {&tabulation}
            .
          end.
          otherwise
          do:
            put stream text_out unformatted
              ":" + fill( " ":U, 10 )
            .
            {&PutExcel}
              {&tabulation}
            .
          end.
        end case. /* j_line-counter */
        put stream text_out unformatted
          ":" + string(         gds-line.pay-name,   "x(17)":U ) +
          ":" + string( OutDec( gds-line.all-qnty ), "x(12)":U )
        .
        {&PutExcel}
          string(         gds-line.pay-name,   "x(17)":U ) {&tabulation}
          string( OutDec( gds-line.all-qnty ), "x(12)":U ) {&tabulation}
        .
        if gds-line.is-cash = no
        then do:
          put stream text_out unformatted
            ":" + fill( " ":U, 12 )
          .
          {&PutExcel}
            {&tabulation}
          .
        end.
        else do:
          put stream text_out unformatted
            ":" + string( OutDec( gds-line.all-sum ), "x(12)":U )
          .
          {&PutExcel}
            string( OutDec( gds-line.all-sum ), "x(12)":U ) {&tabulation}
          .
        end.

        do jj = 1 to gds-line.col-count
        :
          find first gds-cell no-lock where
                     gds-cell.line-order = gds-line.line-order and
                     gds-cell.gds-order  = jj                  no-error .
          if available gds-cell
          then do:
            put stream text_out unformatted
              ":" + string( OutDec( gds-cell.gds-qnty  ), "x(12)":U )
            .
            {&PutExcel}
              string( OutDec( gds-cell.gds-qnty  ), "x(12)":U ) {&tabulation}
            .
            if gds-cell.is-cash = no
            then do:
              put stream text_out unformatted
                ":" + fill( " ":U, 12 ) +
                ":" + fill( " ":U, 12 )
              .
              {&PutExcel}
                {&tabulation}
                {&tabulation}
              .
            end.
            else do:
              if gds-line.is-cash =  yes
              then do:
                put stream text_out unformatted
                  ":" + string( OutDec( gds-cell.gds-price ), "x(12)":U )
                .
                {&PutExcel}
                  string( OutDec( gds-cell.gds-price ), "x(12)":U ) {&tabulation}
                .
              end.
              else do:
                put stream text_out unformatted
                  ":" + fill( " ":U, 12 )
                .
                {&PutExcel}
                  {&tabulation}
                .
              end.
              put stream text_out unformatted
                ":" + string( OutDec( gds-cell.gds-sum ), "x(12)":U )
              .
              {&PutExcel}
                string( OutDec( gds-cell.gds-sum ), "x(12)":U ) {&tabulation}
              .
            end.
          end. /* if available gds-cell */
          else do: /* if not available gds-cell */
            put stream text_out unformatted
              ":" + fill( " ":U, 12 ) +
              ":" + fill( " ":U, 12 ) +
              ":" + fill( " ":U, 12 )
            .
            {&PutExcel}
              {&tabulation}
              {&tabulation}
              {&tabulation}
            .
          end. /* if not available gds-cell */
        end. /* do jj ... */

        put stream text_out unformatted
          ":" skip
        .
        {&PutExcel}
          skip
        .
        if last-of( gds-line.shift-num )
        then do:
          put stream text_out unformatted
            Under-Line skip
          .
        end. /* if last-of( gds-line.shift-num ) */
      end. /* for each gds-line */
    end. /* if tt_object.gds-found = yes */
    for each gds-ptrl no-lock where
             gds-ptrl.obj-type  = tt_object.obj-type and
             gds-ptrl.obj-code  = tt_object.obj-code and
             gds-ptrl.is-gas    = no
    break by gds-ptrl.artic
          by gds-ptrl.prod-type
          by gds-ptrl.prod-code
    :
      assign
        j_excel-col = j_excel-col + 1
      .
    end. /* for each gds-ptrl */
    if tt_object.gds-found = yes
    then do:
      page stream text_out .
      {&PageExcel}
    end.
    else do:
      if XLS-page-num > 0
      then do:
        if not available SheetF
        then do:
          find first SheetF where
                     SheetF.Sheet-Num = XLS-page-num no-error .
        end.
        if available SheetF
        then do:
          delete SheetF .
        end.
        assign
          XLS-page-num = XLS-page-num - 1
        .
      end.
    end.
  end. /* for each tt_object */

  /* газ */
  assign
    gds-gas-found = no
  .
  for each tt_object no-lock
  :
    if tt_object.gas-found <> yes
    then do:
      next .
    end.
    assign
      gds-gas-found = yes
    .
    leave .
  end. /* for each tt_object */

  if gds-gas-found = yes
  then do:
    assign
      j_columns-total = 0
      j_line-order    = 0
    .
    for each tt_object no-lock
    :
      for each gds-line
      :
        delete gds-line .
      end. /* for each gds-line */
      for each gds-cell
      :
        delete gds-cell .
      end. /* for each gds-line */
      assign
        v-green-row = "":U
      .

      if tt_object.gas-found <> yes
      then do:
        next .
      end.
      if tt_object.gas-found = yes
      then do:
        assign
          ReportName       = "":U
          ReportHeader     = "":U
          str1             = "":U
          str2             = "":U
          str3             = "":U
          str4             = "":U
          /*                  :    10    :        17       :     12     :     12     :     12     :     12     : */
          Header-Line0     = "----------------------------------------------------------------------------------"
          Header-Line1     = ":          :                 :            :" + centre( tt_object.obj-name, 38 ) + ":"
          Header-Line2     = ":          :                 :            :------------:------------:------------:"
          Header-Line3     = ":   Дата   :    Покупатель   :   Итого:   :   Кол-во   :    Цена    :    Сумма   :"
          Header-Line4     = ":          :                 :            :     (л)    :   реализ   :   реализ   :"
          Header-Line5     = ":----------:-----------------:------------:------------:------------:------------:"
          Header-add-Line0 = "":U
          Header-add-Line1 = "":U
          Header-add-Line2 = "":U
          Header-add-Line3 = "":U
          Header-add-Line4 = "":U
          Header-add-Line5 = "":U
        .
        assign
          j_excel-row = 0
          j_excel-col = 0
        .
        assign
          ReportName   = substitute( 'Отчет по розничной реализации нефтепродуктов (газ) на &1'
                                   , tt_object.obj-name
                                   )
          j_length     = 82
          Under-Line   = fill( "-", j_length )
          str1         = substitute( "за период с &1 по &2"
                                   , string( x-Date-Start, "99/99/9999":U )
                                   , string( x-Date-End,   "99/99/9999":U )
                                   )
          ReportHeader = substitute( "Дата печати: &1, время: &2"
                                   , string( t_today, "99.99.9999":U )
                                   , string( j_time,  "HH:MM:SS":U   )
                                   )
          Header-Name  = Centering(  caps( ReportName ), j_length ) +
                         {&new-line}                                +
                         Centering(        str1,         j_length ) +
                         {&new-line}                                +
                         {&new-line}                                +
                         {&new-line}                                +
                         ShiftRight(       ReportHeader, j_length )
        .
        assign
          j_line-order = j_line-order + 100
        .
        for each bf_shift-obj no-lock where
                 bf_shift-obj.obj-type    = tt_object.obj-type and
                 bf_shift-obj.obj-code    = tt_object.obj-code and
                 bf_shift-obj.status_     = {&sht-closed}      and
                 bf_shift-obj.fact-order >= fact-order_from    and
                 bf_shift-obj.fact-order <= fact-order_till
        break by bf_shift-obj.shift-date
              by bf_shift-obj.shift-num
        :
          if first-of( bf_shift-obj.shift-num )
          then do:
            for each treal-2
            :
              delete treal-2 .
            end.
            run rep/r-shftch.p
              ( input bf_shift-obj.obj-type
              , input bf_shift-obj.obj-code
              , input bf_shift-obj.shift-date
              , input bf_shift-obj.shift-num
              , input bf_shift-obj.shift-date
              , input bf_shift-obj.shift-num
              , input 1110
              , input yes
              , input yes
              , input yes
              , input no /*sheet8*/
              , input no
              , input no
              ) no-error .
            if error-status :error
            then do:
              message return-value view-as alert-box .
              return error .
            end.
          end. /* if first-of( bf_shift-obj.shift-num ) */
          assign
            j_excel-row   = 0
            j_start-order = j_line-order
          .
          for each treal-2 no-lock where
                   treal-2.is-pay    <> ? and
                   treal-2.curr-code >= 0
          :
            find first gds-ptrl no-lock where
                       gds-ptrl.obj-type = tt_object.obj-type and
                       gds-ptrl.obj-code = tt_object.obj-code and
                       gds-ptrl.is-gas   = yes                and
                       gds-ptrl.gds-code = treal-2.gds-code   no-error .
            if not available gds-ptrl
            then do:
              next .
            end.
            assign
              j_excel-row = j_excel-row + 1
            .
            find first gds-line where
                       gds-line.pay-code   = treal-2.cpay-code       and
                       gds-line.shift-date = bf_shift-obj.shift-date and
                       gds-line.shift-num  = bf_shift-obj.shift-num  and
                       gds-line.is-gas     = gds-ptrl.is-gas         no-error .
            if not available gds-line
            then do:
              assign
                j_line-order = j_line-order + 10
              .
              find first ub.cash-pay no-lock where
                         ub.cash-pay.cdpay-code = treal-2.cpay-code and
                         ub.cash-pay.curr-code  = treal-2.curr-code no-error .
              create gds-line .
              assign
                gds-line.line-order = j_line-order
                gds-line.shift-date = bf_shift-obj.shift-date
                gds-line.shift-num  = bf_shift-obj.shift-num
                gds-line.shift-name = bf_shift-obj.shift-name
                gds-line.pay-code   = treal-2.cpay-code
                gds-line.out-name   = treal-2.out-name
                gds-line.pay-name   = ( if available ub.cash-pay then ub.cash-pay.obj-name else treal-2.out-name )
                gds-line.is-cash    = ( if available ub.cash-pay then ub.cash-pay.is-cash  else no )
                gds-line.is-gas     = gds-ptrl.is-gas
                gds-line.col-count  = j_columns-total
              .
              if gds-line.is-cash = no and
                 ( available ub.cash-pay )
              then do:
                find first tt_obj-pay no-lock where
                           tt_obj-pay.obj-type = bf_shift-obj.obj-type and
                           tt_obj-pay.obj-code = bf_shift-obj.obj-code and
                           tt_obj-pay.pay-name = gds-line.pay-name     no-error .
                if not available tt_obj-pay
                then do:
                  create tt_obj-pay .
                  assign
                    tt_obj-pay.obj-type = bf_shift-obj.obj-type
                    tt_obj-pay.obj-code = bf_shift-obj.obj-code
                    tt_obj-pay.pay-name = gds-line.pay-name
                    tt_obj-pay.pay-num  = 0
                    tt_obj-pay.xls-col  = 0
                  .
                end. /* if not available tt_obj-pay */
              end. /* if gds-line.is-cash = no */
            end. /* if not available gds-line */
            assign
              gds-line.all-qnty = gds-line.all-qnty + treal-2.qnty1
              gds-line.all-sum  = gds-line.all-sum  + ( if gds-line.is-cash = yes then treal-2.netto else 0.00 )
            .

            find first gds-cell where
                       gds-cell.shift-date = bf_shift-obj.shift-date and
                       gds-cell.shift-num  = bf_shift-obj.shift-num  and
                       gds-cell.pay-code   = treal-2.cpay-code       and
                       gds-cell.gds-code   = treal-2.gds-code        no-error .
            if not available gds-cell
            then do:
              create gds-cell .
              assign
                gds-cell.line-order = gds-line.line-order
                gds-cell.shift-date = gds-line.shift-date
                gds-cell.shift-num  = gds-line.shift-num
                gds-cell.pay-code   = gds-line.pay-code
                gds-cell.is-cash    = gds-line.is-cash
                gds-cell.is-gas     = gds-ptrl.is-gas
                gds-cell.gds-order  = gds-ptrl.gds-order
                gds-cell.gds-code   = gds-ptrl.gds-code
                gds-cell.col-count  = gds-line.col-count
              .
            end. /* if not available gds-cell */
            assign
              gds-cell.gds-qnty  = gds-cell.gds-qnty  + treal-2.qnty1
              gds-cell.gds-sum   = gds-cell.gds-sum   + ( if treal-2.is-pay = yes then treal-2.netto                 else 0.00 )
              gds-cell.gds-price = gds-cell.gds-price + ( if treal-2.is-pay = yes then treal-2.netto / treal-2.qnty1 else 0.00 )
            .
          end. /* for each treal-2 */
          for each gds-line where
                   gds-line.line-order > j_start-order
          :
            for each gds-cell where
                     gds-cell.line-order = gds-line.line-order
            :
              assign
                gds-cell.row-count = j_excel-row
              .
            end. /* for each gds-cell */
            assign
              gds-line.row-count = j_excel-row
            .
          end. /* for each gds-line */

          /* итоги (б/н) */
          assign
            d_all-qnty = 0.00
            d_all-sum  = 0.00
          .
          for each gds-line no-lock where
                   gds-line.line-order > j_start-order           and
                   gds-line.is-cash    = no                      and
                   gds-line.shift-date = bf_shift-obj.shift-date and
                   gds-line.shift-num  = bf_shift-obj.shift-num
          :
            assign
              d_all-qnty = d_all-qnty + gds-line.all-qnty
            .
          end. /* for each gds-line */
          assign
            j_line-order = j_line-order + 10
          .
          create gds-line .
          assign
            gds-line.line-order = j_line-order
            gds-line.shift-date = bf_shift-obj.shift-date
            gds-line.shift-num  = bf_shift-obj.shift-num
            gds-line.shift-name = bf_shift-obj.shift-name
            gds-line.pay-code   = 1000000001
            gds-line.out-name   = "Всего б/н"
            gds-line.pay-name   = "Всего б/н"
            gds-line.is-cash    = no
            gds-line.is-gas     = yes
            gds-line.col-count  = j_columns-total
            gds-line.row-count  = j_excel-row
            gds-line.all-qnty   = d_all-qnty
            gds-line.all-sum    = 0.00
          .
          assign
            d_all-qnty = 0.00
          .
          for each bf_gds-cell no-lock where
                   bf_gds-cell.line-order > j_start-order       and
                   bf_gds-cell.shift-date = gds-line.shift-date and
                   bf_gds-cell.shift-num  = gds-line.shift-num  and
                   bf_gds-cell.is-cash    = gds-line.is-cash
          break by bf_gds-cell.gds-code
                by bf_gds-cell.pay-code
          :
            if first-of( bf_gds-cell.gds-code )
            then do:
              assign
                d_all-qnty = 0.00
              .
            end. /* if first-of( bf_gds-cell.pay-code ) */
            assign
              d_all-qnty = d_all-qnty + bf_gds-cell.gds-qnty
            .
            if last-of( bf_gds-cell.gds-code )
            then do:
              create gds-cell .
              assign
                gds-cell.line-order = j_line-order
                gds-cell.shift-date = gds-line.shift-date
                gds-cell.shift-num  = gds-line.shift-num
                gds-cell.pay-code   = gds-line.pay-code
                gds-cell.is-cash    = gds-line.is-cash
                gds-cell.is-gas     = bf_gds-cell.is-gas
                gds-cell.gds-order  = bf_gds-cell.gds-order
                gds-cell.gds-code   = bf_gds-cell.gds-code
                gds-cell.col-count  = gds-line.col-count
                gds-cell.gds-qnty   = d_all-qnty
                gds-cell.gds-sum    = 0.00
                gds-cell.gds-price  = 0.00
              .
            end. /* if last-of( bf_gds-cell.pay-code ) */
          end. /* for each bf_gds-cell */

          /* итоги (нал) */
          assign
            d_all-qnty = 0.00
            d_all-sum  = 0.00
          .
          for each gds-line no-lock where
                   gds-line.line-order > j_start-order           and
                   gds-line.is-cash    = yes                     and
                   gds-line.shift-date = bf_shift-obj.shift-date and
                   gds-line.shift-num  = bf_shift-obj.shift-num
          :
            assign
              d_all-qnty = d_all-qnty + gds-line.all-qnty
              d_all-sum  = d_all-sum  + gds-line.all-sum
            .
          end. /* for each gds-line */
          assign
            j_line-order = j_line-order + 10
          .
          create gds-line .
          assign
            gds-line.line-order = j_line-order
            gds-line.shift-date = bf_shift-obj.shift-date
            gds-line.shift-num  = bf_shift-obj.shift-num
            gds-line.shift-name = bf_shift-obj.shift-name
            gds-line.pay-code   = 1000000002
            gds-line.out-name   = "Всего нал"
            gds-line.pay-name   = "Всего нал"
            gds-line.is-cash    = yes
            gds-line.is-gas     = yes
            gds-line.col-count  = j_columns-total
            gds-line.row-count  = j_excel-row
            gds-line.all-qnty   = d_all-qnty
            gds-line.all-sum    = d_all-sum
          .
          assign
            d_all-qnty = 0.00
            d_all-sum  = 0.00
          .
          for each bf_gds-cell no-lock where
                   bf_gds-cell.line-order > j_start-order       and
                   bf_gds-cell.shift-date = gds-line.shift-date and
                   bf_gds-cell.shift-num  = gds-line.shift-num  and
                   bf_gds-cell.is-cash    = gds-line.is-cash
          break by bf_gds-cell.gds-code
                by bf_gds-cell.pay-code
          :
            if first-of( bf_gds-cell.gds-code )
            then do:
              assign
                d_all-qnty = 0.00
                d_all-sum  = 0.00
              .
            end. /* if first-of( bf_gds-cell.pay-code ) */
            assign
              d_all-qnty = d_all-qnty + bf_gds-cell.gds-qnty
              d_all-sum  = d_all-sum  + bf_gds-cell.gds-sum
            .
            if last-of( bf_gds-cell.gds-code )
            then do:
              create gds-cell .
              assign
                gds-cell.line-order = j_line-order
                gds-cell.shift-date = gds-line.shift-date
                gds-cell.shift-num  = gds-line.shift-num
                gds-cell.pay-code   = gds-line.pay-code
                gds-cell.is-cash    = gds-line.is-cash
                gds-cell.is-gas     = bf_gds-cell.is-gas
                gds-cell.gds-order  = bf_gds-cell.gds-order
                gds-cell.gds-code   = bf_gds-cell.gds-code
                gds-cell.col-count  = gds-line.col-count
                gds-cell.gds-qnty   = d_all-qnty
                gds-cell.gds-sum    = d_all-sum
                gds-cell.gds-price  = 0.00
              .
            end. /* if last-of( bf_gds-cell.pay-code ) */
          end. /* for each bf_gds-cell */

          /* итоги (нал+б/н) */
          assign
            d_all-qnty = 0.00
            d_all-sum  = 0.00
          .
          for each gds-line no-lock where
                   gds-line.line-order > j_start-order           and
                   gds-line.shift-date = bf_shift-obj.shift-date and
                   gds-line.shift-num  = bf_shift-obj.shift-num  and
                 ( gds-line.pay-code   = 1000000001 or
                   gds-line.pay-code   = 1000000002 )
          :
            assign
              d_all-qnty = d_all-qnty + gds-line.all-qnty
              d_all-sum  = d_all-sum  + gds-line.all-sum
            .
          end. /* for each gds-line */
          assign
            j_line-order = j_line-order + 10
          .
          create gds-line .
          assign
            gds-line.line-order = j_line-order
            gds-line.shift-date = bf_shift-obj.shift-date
            gds-line.shift-num  = bf_shift-obj.shift-num
            gds-line.shift-name = bf_shift-obj.shift-name
            gds-line.pay-code   = 1000000003
            gds-line.out-name   = "Всего (нал+б/н)"
            gds-line.pay-name   = "Всего (нал+б/н)"
            gds-line.is-cash    = ?
            gds-line.is-gas     = yes
            gds-line.col-count  = j_columns-total
            gds-line.row-count  = j_excel-row
            gds-line.all-qnty   = d_all-qnty
            gds-line.all-sum    = d_all-sum
          .
          assign
            d_all-qnty = 0.00
            d_all-sum  = 0.00
          .
          for each bf_gds-cell no-lock where
                   bf_gds-cell.line-order > j_start-order       and
                   bf_gds-cell.shift-date = gds-line.shift-date and
                   bf_gds-cell.shift-num  = gds-line.shift-num  and
                 ( bf_gds-cell.pay-code   = 1000000001          or
                   bf_gds-cell.pay-code   = 1000000002 )
          break by bf_gds-cell.gds-code
                by bf_gds-cell.pay-code
          :
            if first-of( bf_gds-cell.gds-code )
            then do:
              assign
                d_all-qnty = 0.00
                d_all-sum  = 0.00
              .
            end. /* if first-of( bf_gds-cell.pay-code ) */
            assign
              d_all-qnty = d_all-qnty + bf_gds-cell.gds-qnty
              d_all-sum  = d_all-sum  + bf_gds-cell.gds-sum
            .
            if last-of( bf_gds-cell.gds-code )
            then do:
              create gds-cell .
              assign
                gds-cell.line-order = j_line-order
                gds-cell.shift-date = gds-line.shift-date
                gds-cell.shift-num  = gds-line.shift-num
                gds-cell.pay-code   = gds-line.pay-code
                gds-cell.is-cash    = gds-line.is-cash
                gds-cell.is-gas     = bf_gds-cell.is-gas
                gds-cell.gds-order  = bf_gds-cell.gds-order
                gds-cell.gds-code   = bf_gds-cell.gds-code
                gds-cell.col-count  = gds-line.col-count
                gds-cell.gds-qnty   = d_all-qnty
                gds-cell.gds-sum    = d_all-sum
                gds-cell.gds-price  = 0.00
              .
            end. /* if last-of( bf_gds-cell.pay-code ) */
          end. /* for each bf_gds-cell */
          assign
            d_all-qnty = 0.00
            d_all-sum  = 0.00
          .
        end. /* for each bf_shift-obj */

        /* итого */
        assign
          j_start-order = j_line-order
        .
        for each bf_gds-line no-lock where
                 bf_gds-line.is-gas      = yes           and
                 bf_gds-line.line-order <= j_start-order
        break by bf_gds-line.pay-code
              by bf_gds-line.is-cash
              by bf_gds-line.shift-date
              by bf_gds-line.shift-num
              by bf_gds-line.line-order
        :
          if first-of( bf_gds-line.pay-code )
          then do:
            assign
              j_line-order = j_line-order + 10
            .
            create gds-line .
            assign
              gds-line.line-order = j_line-order
              gds-line.shift-date = today + 396
              gds-line.shift-num  = 99
              gds-line.shift-name = {&total-label}
              gds-line.pay-code   = bf_gds-line.pay-code
              gds-line.out-name   = bf_gds-line.out-name
              gds-line.pay-name   = bf_gds-line.pay-name
              gds-line.is-cash    = bf_gds-line.is-cash
              gds-line.is-gas     = bf_gds-line.is-gas
              gds-line.col-count  = bf_gds-line.col-count
              gds-line.row-count  = 0
              gds-line.all-qnty   = 0.00
              gds-line.all-sum    = 0.00
            .
          end. /* if first-of( bf_gds-line.pay-code ) */
          assign
            gds-line.all-qnty  = gds-line.all-qnty  + bf_gds-line.all-qnty
            gds-line.row-count = gds-line.row-count + 1
          .
          if gds-line.is-cash <> no
          then do:
            assign
              gds-line.all-sum = gds-line.all-sum + bf_gds-line.all-sum
            .
          end.
          if last-of( bf_gds-line.pay-code )
          then do:
            for each bf_gds-cell no-lock
               where bf_gds-cell.is-gas   = bf_gds-line.is-gas
                 and bf_gds-cell.pay-code = bf_gds-line.pay-code
                 and bf_gds-cell.line-order <= j_start-order
            break by bf_gds-cell.gds-order
                  by bf_gds-cell.is-cash
                  by bf_gds-cell.shift-date
                  by bf_gds-cell.shift-num
                  by bf_gds-cell.gds-code
            :
              if first-of( bf_gds-cell.gds-order )
              then do:
                create gds-cell .
                assign
                  gds-cell.line-order = gds-line.line-order
                  gds-cell.shift-date = gds-line.shift-date
                  gds-cell.shift-num  = gds-line.shift-num
                  gds-cell.pay-code   = gds-line.pay-code
                  gds-cell.is-cash    = gds-line.is-cash
                  gds-cell.is-gas     = bf_gds-cell.is-gas
                  gds-cell.gds-order  = bf_gds-cell.gds-order
                  gds-cell.gds-code   = bf_gds-cell.gds-code
                  gds-cell.col-count  = gds-line.col-count
                  gds-cell.row-count  = gds-line.row-count
                  gds-cell.gds-qnty   = 0.00
                  gds-cell.gds-price  = 0.00
                  gds-cell.gds-sum    = 0.00
                .
              end. /* first-of( bf_gds-cell.gds-order ) */
              assign
                gds-cell.gds-qnty = gds-cell.gds-qnty + bf_gds-cell.gds-qnty
              .
              if gds-cell.is-cash <> no
              then do:
                assign
                  gds-cell.gds-sum = gds-cell.gds-sum + bf_gds-cell.gds-sum
                .
              end.
            end. /* for each bf_gds-cell */
          end. /* if last-of( bf_gds-line.pay-code ) */
        end. /* for each bf_gds-line */

        assign
          j_total-rows   = 0
          j_line-counter = 0
        .
        for each gds-line no-lock
        break by gds-line.shift-date
              by gds-line.shift-num
              by gds-line.line-order
        :
          if first-of( gds-line.shift-num )
          then do:
            assign
              j_line-counter = 0
            .
          end. /* if first-of( gds-line.shift-num ) */
          if gds-line.pay-code = 1000000002
          then do:
            next .
          end.
          if gds-line.all-qnty = 0.00
          then do:
            next .
          end.
          assign
            j_line-counter = j_line-counter + 1
          .
          if last-of( gds-line.shift-num )
          then do:
            assign
              j_total-rows = j_total-rows + j_line-counter
              v-green-row  = v-green-row  +
                             ( if v-green-row = "":U then "":U else {&comma-char} ) +
                             string( j_total-rows + 6 )
            .
            for each bf_gds-line where
                     bf_gds-line.shift-date = gds-line.shift-date and
                     bf_gds-line.shift-num  = gds-line.shift-num
            :
              for each bf_gds-cell where
                       bf_gds-cell.line-order = bf_gds-line.line-order
              :
                assign
                  bf_gds-cell.row-count = j_line-counter
                .
              end. /* for each bf_gds-cell */
              assign
                bf_gds-line.row-count = j_line-counter
              .
            end. /* for each bf_gds-line */
          end. /* if last-of( gds-line.shift-num ) */
        end. /* for each gds-line */

        assign
          XLS-page-num = XLS-page-num + 1
        .
        find first SheetF where
                   SheetF.Sheet-Num = XLS-page-num no-error .
        if not available SheetF
        then do:
          create SheetF .
          assign
            SheetF.Sheet-Num = XLS-page-num
          .
        end.
        assign
          SheetF.MergeCellsH        = "5:7"
          SheetF.MergeCellsV        = "1=1:2/2=1:2/3=1:2"
          SheetF.Excel-Column-Lable = "Дата"              + {&comma-char} +
                                      "Покупатель"        + {&comma-char} +
                                      "ИТОГО:"            + {&comma-char} +
                                                            {&comma-char} +
                             replace( tt_object.obj-name,   {&comma-char} , {&space-char} )
                                                          + {&comma-char}
                                                          + {&comma-char}
                                                          + {&comma-char} + {&new-line}
                                                          + {&comma-char}
                                                          + {&comma-char}
                                                          + {&comma-char}
                                                          + {&comma-char} +
                                      "Кол-во (л)"        + {&comma-char} +
                                      "Цена реал."        + {&comma-char} +
                                      "Сумма грн."        + {&comma-char}
          SheetF.ColFormat          = "3=" + "0" + v-delim + "00" + ";" +
                                      "5=" + "0" + v-delim + "00" + ";" +
                                      "6=" + "0" + v-delim + "00" + ";" +
                                      "7=" + "0" + v-delim + "00"
          SheetF.Sizes              = "10,17,12,2,12,12,12,2"
        .
        for each gds-ptrl no-lock where
                 gds-ptrl.obj-type  = tt_object.obj-type and
                 gds-ptrl.obj-code  = tt_object.obj-code and
                 gds-ptrl.is-gas    = yes
        break by gds-ptrl.artic
              by gds-ptrl.prod-type
              by gds-ptrl.prod-code
        :
          assign
            j_excel-row = j_excel-row + 1
          .
        end. /* for each gds-ptrl */
        assign
          /* vcurr-sheet-name = string( XLS-page-num ) + ". " + tt_object.obj-name + " - ГАЗ" */
          vcurr-sheet-name = tt_object.obj-name + " - ГАЗ"
          j_columns-total  = 7
        .
        if j_total-rows = 0 or
           v-green-row  = "":U
        then do:
          assign
            SheetF.MergeCellsH        = "":U
            SheetF.MergeCellsV        = "":U
            SheetF.Excel-Column-Lable = "":U
            SheetF.ColFormat          = "":U
            SheetF.Sizes              = "":U
            ext-column-label          = "":U
            XLS-page-num              = XLS-page-num - 1
          .
          next .
        end.

        put stream text_out unformatted
          Header-Name  skip
          Header-Line0 skip
          Header-Line1 skip
          Header-Line2 skip
          Header-Line3 skip
          Header-Line4 skip
          Header-Line5 skip
        .
        assign
          Sheetf.Bas-File      = "slptrluk.bas"
          Sheetf.Bas-Param-Add = yes
          Sheetf.Bas-Params    = "Gas"                                  + {&delim-par} +
                                 string(              j_total-rows    ) + {&delim-par} +
                                 string(              j_columns-total ) + {&delim-par} +
                                                                          {&delim-par} +
                                 string( num-entries( v-green-row   ) ) + {&delim-par} +
                                 v-green-row
          SheetF.ColFormat     = SheetF.ColFormat                       + {&delim-par} +
                                                                          {&delim-par} +
                                 vcurr-sheet-name
        .
        run rep/extitle.p
          ( input XLS-page-num
          ) no-error .

        for each gds-line no-lock where
                 gds-line.is-gas = yes
        break by gds-line.shift-date
              by gds-line.shift-num
              by gds-line.line-order
        :
          if first-of( gds-line.shift-num )
          then do:
            assign
              j_line-counter = 0
            .
          end. /* if first-of( gds-line.shift-num ) */
          if gds-line.pay-code = 1000000002
          then do:
            next .
          end.
          if gds-line.all-qnty = 0.00
          then do:
            next .
          end.
          assign
            j_line-counter = j_line-counter + 1
          .
          case j_line-counter :
            when 1
            then do:
              if gds-line.shift-name = {&total-label}
              then do:
                put stream text_out unformatted
                  ":" + fill( " ":U, 10 )
                .
                {&PutExcel}
                  string( gds-line.shift-name, "x(10)":U      ) {&tabulation}
                .
              end.
              else do:
                put stream text_out unformatted
                  ":" + string( gds-line.shift-date, "99.99.9999":U )
                .
                {&PutExcel}
                  string( gds-line.shift-date, "99.99.9999":U ) + " ":U +
                  string( gds-line.shift-name, "x(10)":U      ) {&tabulation}
                .
              end.
            end.
            when 2
            then do:
              put stream text_out unformatted
                ":" + Centre( gds-line.shift-name, 10 )
              .
              {&PutExcel}
                {&tabulation}
              .
            end.
            otherwise
            do:
              put stream text_out unformatted
                ":" + fill( " ":U, 10 )
              .
              {&PutExcel}
                {&tabulation}
              .
            end.
          end case. /* j_line-counter */
          put stream text_out unformatted
            ":" + string(         gds-line.pay-name,   "x(17)":U ) +
            ":" + string( OutDec( gds-line.all-qnty ), "x(12)":U )
          .
          {&PutExcel}
            string(         gds-line.pay-name,   "x(17)":U ) {&tabulation}
            string( OutDec( gds-line.all-qnty ), "x(12)":U ) {&tabulation}
                                                             {&tabulation}
          .
          assign
            d_total-qnty = 0.00
            d_total-sum  = 0.00
          .
          for each gds-cell no-lock where
                   gds-cell.line-order = gds-line.line-order and
                   gds-cell.is-gas     = yes
          :
            assign
              d_total-qnty = d_total-qnty + gds-cell.gds-qnty
            .
            if gds-cell.is-cash <> no
            then do:
              assign
                d_total-sum = d_total-sum + gds-cell.gds-sum
              .
            end.
          end. /* for each gds-cell */

          put stream text_out unformatted
            ":" + string( OutDec( d_total-qnty ), "x(12)":U )
          .
          {&PutExcel}
            string( OutDec( d_total-qnty ), "x(12)":U ) {&tabulation}
          .
          if gds-line.is-cash <> no
          then do:
            if gds-line.is-cash = yes
            then do:
              assign
                d_gas-price = ( if d_total-qnty <> 0.00 and d_total-qnty <> ? then d_total-sum / d_total-qnty else 0.00 )
              .
              put stream text_out unformatted
                ":" + string( OutDec( d_gas-price ), "x(12)":U )
              .
              {&PutExcel}
                string( OutDec( d_gas-price ), "x(12)":U ) {&tabulation}
              .
            end.
            else do:
              put stream text_out unformatted
                ":" + fill( " ":U, 12 )
              .
              {&PutExcel}
                {&tabulation}
              .
            end.
            put stream text_out unformatted
              ":" + string( OutDec( d_total-sum ), "x(12)":U )
            .
            {&PutExcel}
              string( OutDec( d_total-sum ), "x(12)":U ) {&tabulation}
            .
          end.
          else do:
            put stream text_out unformatted
              ":" + fill( " ":U, 12 ) +
              ":" + fill( " ":U, 12 )
            .
            {&PutExcel}
              {&tabulation}
              {&tabulation}
            .
          end.

          put stream text_out unformatted
            ":" skip
          .
          {&PutExcel}
            {&tabulation}
            skip
          .
          if last-of( gds-line.shift-num )
          then do:
            put stream text_out unformatted
              Under-Line skip
            .
          end. /* if last-of( gds-line.shift-num ) */
        end. /* for each gds-line */
        /* put stream text_out unformatted */
        /*   Under-Line skip */
        /* . */
        page stream text_out .

        {&PageExcel}
      end. /* if tt_object.gas-found = yes */
      if tt_object.gas-found <> yes
      then do:
        if XLS-page-num > 0
        then do:
          if not available SheetF
          then do:
            find first SheetF where
                       SheetF.Sheet-Num = XLS-page-num no-error .
          end.
          if available SheetF
          then do:
            delete SheetF .
          end.
          assign
            XLS-page-num = XLS-page-num - 1
          .
        end.
      end.
    end. /* for each tt_object */
  end. /* газ */

  /* справочно: цены */
  assign
    ReportName   = "Справочно."
    ReportHeader = "":U
    str1         = "Цены. Расход. Рынок. Месяц."
    str2         = "":U
    str3         = "":U
    str4         = "":U
    j_excel-row  = 0
    j_excel-col  = 0
  .
  assign
    XLS-page-num = XLS-page-num + 1
  .
  find first SheetF where
             SheetF.Sheet-Num = XLS-page-num no-error .
  if not available SheetF
  then do:
    create SheetF .
    assign
      SheetF.Sheet-Num = XLS-page-num
    .
  end.
  assign
    SheetF.MergeCellsH = "":U
    SheetF.MergeCellsV = "1=1:4/2=1:4"
    SheetF.ColFormat   = "":U
    SheetF.Sizes       = "9,20"
    v-column-label-1   = "На ........ Месяца" + {&comma-char} +
                         "Вид н.п."
    v-column-label-2   = "":U                 + {&comma-char} +
                         "":U
    v-column-label-3   = "":U                 + {&comma-char} +
                         "":U
    v-column-label-4   = "":U                 + {&comma-char} +
                         "":U
    v-merge-cells-h1   = "":U
    v-merge-cells-h2   = "":U
    v-merge-cells-h3   = "":U
  .
  for each tt_object no-lock
  :
    assign
      v-column-label-1 = v-column-label-1                                            + {&comma-char} +
                         replace( tt_object.obj-name, {&comma-char}, {&space-char} ) + {&comma-char}
                                                                                     + {&comma-char}
                                                                                     + {&comma-char}
                                                                                     + {&comma-char}
                                                                                     + {&comma-char}
                                                                                     + {&comma-char}
      v-column-label-2 = v-column-label-2 + {&comma-char} +
                         "Приход"         + {&comma-char} +
                         "Расход"         + {&comma-char}
                                          + {&comma-char}
                                          + {&comma-char}
                                          + {&comma-char}
                                          + {&comma-char}
      v-column-label-3 = v-column-label-3 + {&comma-char} +
                         "":U             + {&comma-char} +
                         "нал"            + {&comma-char} +
                         "грн."           + {&comma-char}
                                          + {&comma-char}
                                          + {&comma-char}
                                          + {&comma-char}
      v-column-label-4 = v-column-label-4 + {&comma-char} +
                         "":U             + {&comma-char} +
                         "":U
    .
    assign
      j_excel-pay = 0
      j_excel-col = j_excel-col + 1
    .
    for each tt_obj-pay no-lock where
             tt_obj-pay.obj-type = tt_object.obj-type and
             tt_obj-pay.obj-code = tt_object.obj-code
    break by tt_obj-pay.obj-type
          by tt_obj-pay.obj-code
          by tt_obj-pay.pay-name
    :
      if first-of( tt_obj-pay.obj-code )
      then do:
        assign
          j_excel-pay = 0
        .
      end. /* if first-of( tt_obj-pay.obj-code ) */
      assign
        v-column-label-4 = v-column-label-4    + {&comma-char} +
                           tt_obj-pay.pay-name
        j_excel-pay      = j_excel-pay         + 1
      .
      if last-of( tt_obj-pay.obj-code )
      then do:
        for each bf_obj-pay exclusive-lock where
                 bf_obj-pay.obj-type = tt_obj-pay.obj-type and
                 bf_obj-pay.obj-code = tt_obj-pay.obj-code
        :
          assign
            bf_obj-pay.pay-num = j_excel-pay
            bf_obj-pay.xls-col = j_excel-col
          .
        end. /* for each bf_obj-pay */
        assign
          j_excel-pay = 0
        .
      end. /* if last-of( tt_obj-pay.obj-code ) */
    end. /* for each tt_obj-pay */
    find first tt_obj-pay where
               tt_obj-pay.obj-type = tt_object.obj-type and
               tt_obj-pay.obj-code = tt_object.obj-code no-error .
    if not available tt_obj-pay
    then do:
      create tt_obj-pay .
      assign
        tt_obj-pay.obj-type = tt_object.obj-type
        tt_obj-pay.obj-code = tt_object.obj-code
        tt_obj-pay.pay-name = fill( " ":U, 12 )
        tt_obj-pay.pay-num  = 1
        tt_obj-pay.xls-col  = j_excel-col
      .
      assign
        v-column-label-4 = v-column-label-4    + {&comma-char} +
                           tt_obj-pay.pay-name
      .
    end.
  end. /* for each tt_object */
  assign
    j_excel-row = 0
    j_excel-pay = 0
  .
  for each gds-list
  :
    delete gds-list .
  end. /* for each gds-list */
  for each gds-ptrl no-lock
  :
    find first gds-list no-lock where
               gds-list.gds-code = gds-ptrl.gds-code no-error .
    if available gds-list
    then do:
      next .
    end.
    find first gds-list no-lock where
               gds-list.artic     = gds-ptrl.artic     and
               gds-list.prod-type = gds-ptrl.prod-type and
               gds-list.prod-code = gds-ptrl.prod-code no-error .
    if available gds-list
    then do:
      next .
    end.
    assign
      j_excel-row = j_excel-row + 1
    .
    create gds-list .
    assign
      gds-list.artic     = gds-ptrl.artic
      gds-list.prod-type = gds-ptrl.prod-type
      gds-list.prod-code = gds-ptrl.prod-code
      gds-list.gds-code  = gds-ptrl.gds-code
      gds-list.gds-name  = gds-ptrl.gds-name
      gds-list.order-num = j_excel-row
    .
  end. /* for each gds-ptrl */
  assign
    j_excel-pay     = 2
    v-params-adding = "":U
  .
  do jj = 1 to j_excel-col :
    find first tt_obj-pay no-lock where
               tt_obj-pay.xls-col = jj no-error .
    if not available tt_obj-pay
    then do:
      message "Ошибка определения карт и талонов." view-as alert-box error .
      return .
    end.
    assign
      SheetF.MergeCellsV = SheetF.MergeCellsV + "/"           + string( j_excel-pay + 1 ) + "=" + "2:4"
                                              + "/"           + string( j_excel-pay + 2 ) + "=" + "3:4"
      SheetF.Sizes       = SheetF.Sizes       + {&comma-char} + "12"
                                              + {&comma-char} + "12"
                                              + fill( {&comma-char} + "12", tt_obj-pay.pay-num )
      SheetF.ColFormat   = SheetF.ColFormat   + ";"           + string( j_excel-pay + 1 ) + "=" + "0" + v-delim + "00"
                                              + ";"           + string( j_excel-pay + 2 ) + "=" + "0" + v-delim + "00"
      v-merge-cells-h1   = v-merge-cells-h1   + {&comma-char} + string( j_excel-pay + 1 ) + ":"
                                                              + string( j_excel-pay + tt_obj-pay.pay-num + 2 )
      v-merge-cells-h2   = v-merge-cells-h2   + {&comma-char} + string( j_excel-pay + 2 ) + ":"
                                                              + string( j_excel-pay + tt_obj-pay.pay-num + 2 )
      v-merge-cells-h3   = v-merge-cells-h3   + {&comma-char} + string( j_excel-pay + 3 ) + ":"
                                                              + string( j_excel-pay + tt_obj-pay.pay-num + 2 )
    .
    do j1 = 1 to tt_obj-pay.pay-num :
      assign
        SheetF.ColFormat = SheetF.ColFormat + ";" + string( j_excel-pay + j1 + 2 ) + "=" + "0" + v-delim + "00"
      .
    end.
    assign
      j_excel-pay     = j_excel-pay     + tt_obj-pay.pay-num + 2
      v-params-adding = v-params-adding
                      + ( if v-params-adding = "":U then "":U else {&comma-char} )
                      + string( j_excel-pay )
    .
  end.
  assign
    num-monthes     = CalcMonthes( x-Date-Start, x-Date-End )
    v-params-adding = v-params-adding       + {&delim-par} +
                      string( num-monthes ) + {&delim-par} +
                      "9"
  .
  do jj = 1 to num-monthes - 1 :
    assign
      v-params-adding = v-params-adding + {&comma-char} + string( j_excel-row * jj + 9 )
    .
  end.
  assign
    SheetF.Excel-Column-Lable = v-column-label-1 + {&new-line} +
                                v-column-label-2 + {&new-line} +
                                v-column-label-3 + {&new-line} +
                                v-column-label-4
    SheetF.MergeCellsH        = substring( v-merge-cells-h1, 2 ) + "/" +
                                substring( v-merge-cells-h2, 2 ) + "/" +
                                substring( v-merge-cells-h3, 2 )
    Sheetf.Bas-File           = "slptrluk.bas"
    Sheetf.Bas-Param-Add      = yes
    Sheetf.Bas-Params         = "Info"                + {&delim-par} +
                                string( j_excel-row ) + {&delim-par} +
                                string( j_excel-col ) + {&delim-par} +
                                v-params-adding
    SheetF.ColFormat          = SheetF.ColFormat      + {&delim-par} +
                                                        {&delim-par} +
                             /* string( XLS-page-num ) + ". Справочно Цены" */
                               "Справочно Цены"
  .
  run rep/extitle.p
    ( input XLS-page-num
    ) no-error .
  do jj = 1 to num-monthes :
    {&PutExcel}
      RusMonth( jj )
    .
    for each gds-list no-lock
    :
      {&PutExcel}
                          {&tabulation}
        gds-list.gds-name {&tabulation}
        fill( {&tabulation}, j_excel-col )
        skip
      .
    end. /* for each gds-list */
  end.

  output stream text_out close .
  {&CloseExcel}

  run waitfram-hide in this-procedure .
  {&SetCursorNo}
  run prn-lib-prn-file in this-procedure
    ( input my-handle
    , input 8
    ) .
end. /* on error */

procedure get-fo-range :
  define  input parameter p-obj-type   as character no-undo .
  define  input parameter p-obj-code   as integer   no-undo .
  define  input parameter p-date-from  as date      no-undo .
  define  input parameter p-date-till  as date      no-undo .
  define  input parameter p-shift-from as integer   no-undo .
  define  input parameter p-shift-till as integer   no-undo .
  define  input parameter p-is-shift   as logical   no-undo .
  define output parameter p-fo-from    as decimal   no-undo initial 0.00 .
  define output parameter p-fo-till    as decimal   no-undo initial 0.00 .

  define variable v-shift-end-fact-order as decimal no-undo .
  define variable v-day-end-fact-order   as decimal no-undo .
  define variable v-fact-order           as decimal no-undo .

  do
  on error undo, return error return-value
  :
    if p-is-shift = yes
    then do:
      run factord in this-procedure
        (  input p-date-from            /* p-fact-date            */
        ,  input 1                      /* p-fact-time            */
        ,  input 1                      /* p-fact-num             */
        ,  input p-date-from            /* p-shift-date           */
        ,  input p-shift-from           /* p-shift-num            */
        ,  input p-is-shift             /* p-shift-on             */
        , output p-fo-from              /* p-fact-order           */
        , output v-shift-end-fact-order /* p-shift-end-fact-order */
        , output v-day-end-fact-order   /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error
      then do:
        message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                "Ошибка при вызове процедуры factord" skip( 0 )
                error-status :get-message( 1 ) skip( 0 )
                return-value skip( 1 )
        view-as alert-box error .
        undo, return error return-value .
      end.
      run factord in this-procedure
        (  input p-date-till            /* p-fact-date            */
        ,  input 1                      /* p-fact-time            */
        ,  input 1                      /* p-fact-num             */
        ,  input p-date-till            /* p-shift-date           */
        ,  input p-shift-till           /* p-shift-num            */
        ,  input p-is-shift             /* p-shift-on             */
        , output v-fact-order           /* p-fact-order           */
        , output p-fo-till              /* p-shift-end-fact-order */
        , output v-day-end-fact-order   /* p-day-end-fact-order   */
        ) no-error .
      if error-status :error
      then do:
        message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
                "Ошибка при вызове процедуры factord" skip( 0 )
                error-status :get-message( 1 ) skip( 0 )
                return-value skip( 1 )
        view-as alert-box error .
        undo, return error return-value .
      end.
    end. /* if p-is-shift = yes */
    else do: /* if p-is-shift <> yes */
      run day-begin-fact-order in this-procedure
        (  input p-date-from
        , output p-fo-from
        ) no-error .
      if error-status :error or
         p-fo-from = ?
      then do:
        assign
          p-fo-from = 0.00
        .
      end.
      run factord-end-day in this-procedure
        (  input p-date-till
        , output p-fo-till
        ) no-error .
      if error-status :error or
         p-fo-till = ?
      then do:
        assign
          p-fo-till = truncate( p-fo-from, 0 ) + 0.99
        .
      end.
    end. /* if p-is-shift <> yes */
    if p-fo-till < p-fo-from
    then do:
      assign
        p-fo-till = p-fo-from
      .
    end.
  end. /* on error */
end procedure. /* get-fo-range */

procedure cr-gds-list :
  define input parameter p-obj-type as character no-undo .
  define input parameter p-obj-code as integer   no-undo .

  define variable is-petrol as logical no-undo .
  define variable is-pieces as logical no-undo .

  define variable v_gds-attr-value as character no-undo .
  define variable v_gds-attr-type  as character no-undo .
  define variable j_gds-order      as integer   no-undo initial 0 .
  define variable j_gas-order      as integer   no-undo initial 0 .
  define variable l_is-gds-gas     as logical   no-undo .

  define variable doc-line_qnty    as decimal   no-undo initial 0.00 .

  define buffer bf_gds-obj  for ub.gds-obj .
  define buffer bf_goods    for ub.goods   .
  define buffer bf_gds-ptrl for gds-ptrl   .

  do
  on error undo, return error return-value
  :
    for each gds-ptrl no-lock where
             gds-ptrl.obj-type = p-obj-type and
             gds-ptrl.obj-code = p-obj-code
    :
      find first bf_gds-ptrl exclusive-lock where
          recid( bf_gds-ptrl ) = recid( gds-ptrl ) .
      delete bf_gds-ptrl .
    end. /* for each gds-ptrl */
    for each  bf_gds-obj no-lock where
              bf_gds-obj.obj-type = p-obj-type and
              bf_gds-obj.obj-code = p-obj-code
      , first bf_goods   no-lock where
              bf_goods.gds-code   = bf_gds-obj.gds-code
    :
      find first gds-ptrl no-lock where
                 gds-ptrl.obj-type = bf_gds-obj.obj-type and
                 gds-ptrl.obj-code = bf_gds-obj.obj-code and
                 gds-ptrl.gds-code = bf_gds-obj.gds-code no-error .
      if available gds-ptrl
      then do:
        next .
      end.
      { str/is-petrl.i
          bf_gds-obj.artic
          bf_gds-obj.prod-type
          bf_gds-obj.prod-code
          is-petrol
          is-pieces
          no-error
      }
      if error-status :error or
         is-petrol <> yes    or
         is-pieces <> no
      then do:
        next .
      end.
      run gds-attr-value in this-procedure
        (  input bf_goods.gds-code
        ,  input {&attr-fuel-type}
        , output v_gds-attr-value
        , output v_gds-attr-type
        ) no-error .
      if not error-status :error and
         v_gds-attr-value = 'metan':U
      then do:
        assign
          l_is-gds-gas = yes
        .
      end.
      else do:
        assign
          l_is-gds-gas = no
        .
      end.
      find first bf_doc-line no-lock where
                 bf_doc-line.obj-type      = bf_gds-obj.obj-type     and
                 bf_doc-line.obj-code      = bf_gds-obj.obj-code     and
                 bf_doc-line.prod-type     = bf_gds-obj.prod-type    and
                 bf_doc-line.prod-code     = bf_gds-obj.prod-code    and
                 bf_doc-line.artic         = bf_gds-obj.artic        and
                 bf_doc-line.ext-doc-type  = {&TDEDT_Ras_Vnesh_Kass} and
                 bf_doc-line.status_       = {&fact}                 and
                 bf_doc-line.fact-order   >= fact-order_from         and
                 bf_doc-line.fact-order   <= fact-order_till         no-error .
      if not available bf_doc-line
      then do:
        next .
      end.
      assign
        doc-line_qnty = 0.00
      .
      for each bf_doc-line no-lock where
               bf_doc-line.obj-type      = bf_gds-obj.obj-type     and
               bf_doc-line.obj-code      = bf_gds-obj.obj-code     and
               bf_doc-line.prod-type     = bf_gds-obj.prod-type    and
               bf_doc-line.prod-code     = bf_gds-obj.prod-code    and
               bf_doc-line.artic         = bf_gds-obj.artic        and
               bf_doc-line.ext-doc-type  = {&TDEDT_Ras_Vnesh_Kass} and
               bf_doc-line.status_       = {&fact}                 and
               bf_doc-line.fact-order   >= fact-order_from         and
               bf_doc-line.fact-order   <= fact-order_till
      :
        assign
          doc-line_qnty = doc-line_qnty + bf_doc-line.fact-qnty
        .
      end. /* for each bf_doc-line */
      if doc-line_qnty = 0.00
      then do:
        next .
      end.
      if l_is-gds-gas = yes
      then do:
        assign
          j_gas-order = j_gas-order + 1
        .
      end.
      else do:
        assign
          j_gds-order = j_gds-order + 1
        .
      end.
      create gds-ptrl .
      assign
        gds-ptrl.obj-type  = bf_gds-obj.obj-type
        gds-ptrl.obj-code  = bf_gds-obj.obj-code
        gds-ptrl.artic     = bf_gds-obj.artic
        gds-ptrl.prod-type = bf_gds-obj.prod-type
        gds-ptrl.prod-code = bf_gds-obj.prod-code
        gds-ptrl.gds-code  = bf_gds-obj.gds-code
        gds-ptrl.gds-name  = bf_goods.gds-name
        gds-ptrl.is-gas    = l_is-gds-gas
        gds-ptrl.gds-order = ( if l_is-gds-gas = yes then j_gas-order else j_gds-order )
      .
    end. /* for each bf_gds-obj, first bf_goods */
  end. /* on error */
end procedure. /* cr-gds-list */

procedure get-dec-string :
  define  input parameter p-dec  as decimal   no-undo .
  define output parameter p-char as character no-undo .

  define variable j-len as integer no-undo initial 12 .

  do
  on error undo, return error return-value
  :
    if p-dec = ? or
       p-dec = 0.00
    then do:
      assign
        p-char = fill( " ":U, j-len )
      .
    end.
    else do:
      assign
        p-char = trim( string( p-dec, "->>>>>>>9.99":U ) )
        p-char = fill( " ":U, j-len - length( trim( p-char ) ) ) + trim( p-char )
      .
    end.
  end. /* on error */
end procedure. /* get-dec-string */