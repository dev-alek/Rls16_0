block-level on error undo, throw.
/*

$Revision: 099a383cf864, 290, rls $
$Author: PGridchina $
$Date: Tue Dec 01 19:11:24 2015 +0300 $
$Workfile: r-inptlu.p $
$Archive: rep/r-inptlu.p $

Отчет по приходу нефтепродуктов на АЗК (Украина)

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/10/06
Author: Dmitry Ukhanov
Creation date: 10/10/06

create: Булгаков Андрей Николаевич
Дата создания: 05/05/06

*/

define variable vss-revision    as character no-undo initial "$Revision: 099a383cf864, 290, rls $":U .
define variable vss-author      as character no-undo initial "$Author: PGridchina $":U .
define variable vss-date        as character no-undo initial "$Date: Tue Dec 01 19:11:24 2015 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-inptlu.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-inptlu.p $":U .
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

define variable Header-Name      as character no-undo .
define variable Header-Line0     as character no-undo .
define variable Header-Line1     as character no-undo .
define variable Header-Line2     as character no-undo .
define variable Header-Line3     as character no-undo .
define variable Header-Line4     as character no-undo .
define variable Header-add-Line0 as character no-undo .
define variable Header-add-Line1 as character no-undo .
define variable Header-add-Line2 as character no-undo .
define variable Header-add-Line3 as character no-undo .
define variable Header-add-Line4 as character no-undo .
define variable Under-Line       as character no-undo .
define variable temp-line        as character no-undo .
define variable XLS-page-num     as integer   no-undo initial 0 .
define variable fact-order_from  as decimal   no-undo initial 0.00 .
define variable fact-order_till  as decimal   no-undo initial 0.00 .
define variable j_columns-total  as integer   no-undo .
define variable j_length         as integer   no-undo .
define variable j_gds-order      as integer   no-undo .
define variable d_total-doc-qnty as decimal   no-undo .
define variable jj               as integer   no-undo .
define variable goods-found      as logical   no-undo initial no .
define variable gds-gas-found    as logical   no-undo initial no .
define variable gds-ptr-found    as logical   no-undo initial no .
define variable d_summa          as decimal   no-undo .
define variable ext-column-label as character no-undo .
define variable d_total-qnty     as decimal   no-undo .
define variable d_total-sum      as decimal   no-undo .
define variable XL-delim         as character no-undo .
define variable v_data-type      as character no-undo .
define variable v_temp-param     as character no-undo .
define variable t_today          as date      no-undo .
define variable j_time           as integer   no-undo .
define variable j_excel-row      as integer   no-undo .
define variable j_excel-col      as integer   no-undo .
define variable vcurr-sheet-name as character no-undo .

define variable v-autoent-obj-code  like doc-attr.attr-value no-undo.
define variable v-autoent-obj-type  like doc-attr.attr-value no-undo.
define variable v-car-num           like doc-attr.attr-value no-undo.
define variable v-car-vol           like doc-attr.attr-value no-undo.
define variable v-item-pour         like doc-attr.attr-value no-undo.
define variable v-tank-density      like doc-attr.attr-value no-undo.
define variable v-tank-temp         like doc-attr.attr-value no-undo.
define variable v-tank-vol          like doc-attr.attr-value no-undo.
define variable v-tank-water        like doc-attr.attr-value no-undo.
define variable v-tank-weight       like doc-attr.attr-value no-undo.
define variable v-time-pour         like doc-attr.attr-value no-undo.
define variable v-time-income       like doc-attr.attr-value no-undo.
define variable v-time-start        like doc-attr.attr-value no-undo.
define variable v-time-end          like doc-attr.attr-value no-undo.
define variable v-type-inp-vat      like doc-attr.attr-value no-undo.
define variable v-fio               like doc-attr.attr-value no-undo.
define variable v-autoent-obj-code-dec  as integer no-undo.
define buffer buf_doc-attr for ub.doc-attr.
{ rep/akt-topl.i init-attr }

define variable g#host-code      as integer   no-undo .
define variable g#report-num     as integer   no-undo .
define variable g#quest-print    as logical   no-undo initial yes .

define buffer bf_trn-doc       for ub.trn-doc       .
define buffer bf_doc-line      for ub.doc-line      .
define buffer bf_doc-line-attr for ub.doc-line-attr .
define buffer bf_clients       for ub.clients       .

&scop f-l Centering,ShiftRight

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

function OutQty returns character ( input p-qty as decimal ) :
  define variable v-qty as character no-undo .

  run get-dec-string in this-procedure
    (  input p-qty
    ,  input 3
    , output v-qty
    ) no-error .
  return ( if error-status :error then fill( " ":U, 12 ) else v-qty ) .
end function. /* OutQty */

function OutSum returns character ( input p-sum as decimal ) :
  define variable v-sum as character no-undo .

  run get-dec-string in this-procedure
    (  input p-sum
    ,  input 2
    , output v-sum
    ) no-error .
  return ( if error-status :error then fill( " ":U, 12 ) else v-sum ) .
end function. /* OutSum */

define temp-table gds-ptrl no-undo
  field obj-type  like ub.gds-obj.obj-type
  field obj-code  like ub.gds-obj.obj-code
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

define temp-table gds-cell no-undo
  field obj-type   like ub.gds-obj.obj-type
  field obj-code   like ub.gds-obj.obj-code
  field gds-code   like ub.gds-obj.gds-code
  field doc-code   like ub.trn-doc.doc-code
  field doc-date   like ub.trn-doc.fact-date
  field supp-type  like ub.clients.obj-type
  field supp-code  like ub.clients.obj-code
  field supp-name  like ub.clients.obj-name
  field auto-type  like ub.clients.obj-type
  field auto-code  like ub.clients.obj-code
  field auto-name  like ub.clients.obj-name
  field price      like ub.doc-line.price-rubl
  field qnty       like ub.doc-line.fact-qnty
  field total-qnty like ub.doc-line.fact-qnty
  field gds-order  as   integer

  index pi         is   unique primary obj-type obj-code doc-code gds-code
  index pii        is   unique         obj-type obj-code gds-code doc-code
  index piii       is   unique         obj-type obj-code doc-code gds-order
  index piiii      is   unique         obj-type obj-code doc-code gds-order gds-code
.

define temp-table gds-total no-undo
  field obj-type      like ub.gds-obj.obj-type
  field obj-code      like ub.gds-obj.obj-code
  field gds-code      like ub.gds-obj.gds-code
  field gds-order     as   integer
  field total-qnty    like ub.doc-line.fact-qnty
  field total-sum     like ub.doc-line.other-rubl
  field total-overall like ub.doc-line.other-rubl

  index pi            is   unique primary obj-type obj-code gds-code  gds-order
  index pii           is   unique         obj-type obj-code gds-order gds-code
.

define temp-table tt_object no-undo
  field obj-type  like ub.clients.obj-type
  field obj-code  like ub.clients.obj-code
  field obj-name  like ub.clients.obj-name
  field obj-id    as   integer
  field db-num    as   integer
  field was-found as   logical
  field gds-found as   logical
  field gas-found as   logical

  index pi       is   primary unique obj-id
  index ie1      is           unique obj-type obj-code
  index ie2                          obj-name
.

define buffer bf_gds-ptrl for gds-ptrl  .
define buffer bf_gds-cell for gds-cell  .
define buffer bf_object   for tt_object .

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
  /* run paramls-clear in this-procedure no-error . */
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
  run cr-gds-list in this-procedure no-error .

  run prn-lib-open-stream in this-procedure
    ( input my-handle
    , input {&LS_PS_A4}
    , input yes
    , input no
    ) .

  for each tt_object no-lock
  :
    assign
      ReportName       = "":U
      ReportHeader     = "":U
      str1             = "":U
      str2             = "":U
      str3             = "":U
      str4             = "":U
      /*                  :    10    :      14      :              30              :              30              :     12     :     12     : */
      Header-Line0     = "-------------------------------------------------------------------------------------------------------------------"
      Header-Line1     = ":          :              :                              :                       Перевозчик                       :"
      Header-Line2     = ":   Дата   :   № док-та   :           Источник           :------------------------------:------------:------------:"
      Header-Line3     = ":          :              :                              :              ООО             : Сумма, грн : Кол-во (л) :"
      Header-Line4     = ":----------:--------------:------------------------------:------------------------------:-------------------------:"
      Header-add-Line0 = "":U
      Header-add-Line1 = "":U
      Header-add-Line2 = "":U
      Header-add-Line3 = "":U
      Header-add-Line4 = "":U
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
      j_gds-order     = 0
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
      SheetF.MergeCellsH        = "4:6"
      SheetF.MergeCellsV        = "1=1:2/2=1:2/3=1:2"
      SheetF.Excel-Column-Lable = "Дата"              + {&comma-char} +
                                  "№ док-та"          + {&comma-char} +
                                  "Источник"          + {&comma-char} +
                                  "Перевозчик"        + {&comma-char} +
                                  "":U                + {&comma-char} +
                                  "":U
      SheetF.ColFormat          = "5=" + "0" + v-delim + "00"  + ";" +
                                  "6=" + "0" + v-delim + "000"
      SheetF.Sizes              = "10,14,30,30,12,12"
      ext-column-label          = "":U                + {&comma-char} +
                                  "":U                + {&comma-char} +
                                  "":U                + {&comma-char} +
                                  "ООО"               + {&comma-char} +
                                  "Сумма грн."        + {&comma-char} +
                                  "Кол-во (л)"
    .
    if gds-ptr-found <> yes
    then do:
      assign
        gds-ptr-found = no
      .
    end.
    if gds-gas-found <> yes
    then do:
      assign
        gds-gas-found = no
      .
    end.
    assign
      goods-found = no
    .
    for each gds-ptrl no-lock where
             gds-ptrl.obj-type = tt_object.obj-type and
             gds-ptrl.obj-code = tt_object.obj-code
          by gds-ptrl.is-gas
          by gds-ptrl.gds-order
          by gds-ptrl.artic
          by gds-ptrl.prod-type
          by gds-ptrl.prod-code
    :
      assign
        goods-found = no
      .
      for each bf_doc-line no-lock where
               bf_doc-line.obj-type      = gds-ptrl.obj-type  and
               bf_doc-line.obj-code      = gds-ptrl.obj-code  and
               bf_doc-line.prod-type     = gds-ptrl.prod-type and
               bf_doc-line.prod-code     = gds-ptrl.prod-code and
               bf_doc-line.artic         = gds-ptrl.artic     and
               bf_doc-line.ext-doc-type  = {&TDEDT_Pri_Vnesh} and
               bf_doc-line.status_       = {&fact}            and
               bf_doc-line.fact-order   >= fact-order_from    and
               bf_doc-line.fact-order   <= fact-order_till    use-index dt-fo
            by bf_doc-line.fact-order
      :
        assign
          goods-found = yes
        .
        find first bf_trn-doc no-lock where
                   bf_trn-doc.doc-code = bf_doc-line.doc-code .
        find first gds-cell no-lock where
                   gds-cell.obj-type = bf_doc-line.obj-type and
                   gds-cell.obj-code = bf_doc-line.obj-code and
                   gds-cell.gds-code = gds-ptrl.gds-code    and
                   gds-cell.doc-code = bf_doc-line.doc-code no-error .
        if available gds-cell
        then do:
          next .
        end.
        create gds-cell .
        assign
          gds-cell.obj-type  = bf_doc-line.obj-type
          gds-cell.obj-code  = bf_doc-line.obj-code
          gds-cell.gds-code  = gds-ptrl.gds-code
          gds-cell.gds-order = gds-ptrl.gds-order
          gds-cell.doc-code  = bf_doc-line.doc-code
          gds-cell.doc-date  = ( if bf_trn-doc.status_ = {&fact} then bf_trn-doc.fact-date else bf_trn-doc.doc-date )
          gds-cell.supp-type = bf_trn-doc.cli-type
          gds-cell.supp-code = bf_trn-doc.cli-code
          gds-cell.supp-name = bf_trn-doc.cli-name
          gds-cell.qnty      = bf_doc-line.fact-qnty
        .
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
        for each tt-allsum-line
        :
          delete tt-allsum-line .
        end.
        run clcprtsl_calc-line in this-procedure
          ( input recid( bf_doc-line )
          ) no-error .
        if error-status :error
        then do:
          message
            substitute( 'Ошибка &1 &2 при вызове процедуры clcprtsl_calc-line для строки документа "&3" по товару &4 &5 &6.'
                      , return-value
                      , error-status :get-message( 1 )
                      , bf_doc-line.doc-code
                      , bf_doc-line.artic
                      , bf_doc-line.prod-type
                      , bf_doc-line.prod-code
                      )
          view-as alert-box error .
          return error return-value .
        end.
        find first tt-allsum-line where
                   tt-allsum-line.sum-type = {&sum-general} no-error .
        if not available tt-allsum-line
        then do:
          message
            substitute( 'Не найдена запись с типом суммы &1 после запуска clcprtsl_calc-line.'
                      , {&sum-general}
                      )
          view-as alert-box error .
          return error return-value .
        end.
        assign
          gds-cell.price = ( tt-allsum-line.sum-dsc-rubl-acc - tt-allsum-line.transport-rubl-acc ) / bf_doc-line.fact-qnty
        .
        
        for each buf_doc-attr no-lock where
                 buf_doc-attr.doc-code = bf_doc-line.doc-code:
          case buf_doc-attr.attr-code :
            { rep/act-ptrl.i when-doc-attr trdcattr-autoent }
          end case. /* buf_doc-attr.attr-code */
        end. /* for each buf_doc-attr */
        { rep/act-ptrl.i dec autoent-obj-code }
        assign
            gds-cell.auto-type = v-autoent-obj-type
          .
        assign
          gds-cell.auto-code = v-autoent-obj-code-dec
        .

        find first bf_clients no-lock where
                   bf_clients.obj-type = gds-cell.auto-type and
                   bf_clients.obj-code = gds-cell.auto-code no-error .
        if available bf_clients
        then do:
          assign
            gds-cell.auto-name = bf_clients.obj-name
          .
        end.
      end. /* for each bf_doc-line */
      if goods-found = yes
      then do:
        if gds-ptrl.is-gas = no
        then do:
          assign
            j_columns-total  = j_columns-total  + 1
            j_gds-order      = j_gds-order      + 1
            Header-add-Line0 = Header-add-Line0 + "--------------------------"
            Header-add-Line1 = Header-add-Line1 + Centre( gds-ptrl.gds-name, 25 ) + ":"
            Header-add-Line2 = Header-add-Line2 + "------------:------------:"
            Header-add-Line3 = Header-add-Line3 + "  Кол-во,л  : Цена прих. :"
            Header-add-Line4 = Header-add-Line4 + "------------:------------:"
          .
          assign
            SheetF.Excel-Column-Lable = SheetF.Excel-Column-Lable + {&comma-char} +
                                        replace( gds-ptrl.gds-name, {&comma-char}, {&space-char} )
                                                                  + {&comma-char}
            ext-column-label          = ext-column-label          + {&comma-char} +
                                        "Кол-во (л)"              + {&comma-char} +
                                        "Цена прих."
            SheetF.ColFormat          = SheetF.ColFormat                                                + ";" +
                                        string( j_columns-total * 2 + 5 ) + "=" + "0" + v-delim + "000" + ";" +
                                        string( j_columns-total * 2 + 6 ) + "=" + "0" + v-delim + "00"
            SheetF.Sizes              = SheetF.Sizes                      + {&comma-char} + "12" +
                                                                            {&comma-char} + "12"
            SheetF.MergeCellsH        = SheetF.MergeCellsH                + {&comma-char} +
                                        string( j_columns-total * 2 + 5 ) + ":" +
                                        string( j_columns-total * 2 + 6 )
          .
          if gds-ptrl.gds-order <> j_gds-order
          then do:
            find first bf_gds-ptrl exclusive-lock where
                       bf_gds-ptrl.obj-type  = gds-ptrl.obj-type  and
                       bf_gds-ptrl.obj-code  = gds-ptrl.obj-code  and
                       bf_gds-ptrl.is-gas    = gds-ptrl.is-gas    and
                       bf_gds-ptrl.artic     = gds-ptrl.artic     and
                       bf_gds-ptrl.prod-type = gds-ptrl.prod-type and
                       bf_gds-ptrl.prod-code = gds-ptrl.prod-code .
            for each gds-cell no-lock where
                     gds-cell.obj-type = gds-ptrl.obj-type and
                     gds-cell.obj-code = gds-ptrl.obj-code and
                     gds-cell.gds-code = gds-ptrl.gds-code
            :
              if gds-cell.gds-order <> j_gds-order
              then do:
                find first bf_gds-cell exclusive-lock where
                    recid( bf_gds-cell ) = recid( gds-cell ) .
                assign
                  bf_gds-cell.gds-order = j_gds-order
                .
              end.
            end. /* for each gds-cell */
            assign
              bf_gds-ptrl.gds-order = j_gds-order
            .
          end.
        end.
      end.
      else do:
        find first bf_gds-ptrl exclusive-lock where
                   bf_gds-ptrl.obj-type  = gds-ptrl.obj-type  and
                   bf_gds-ptrl.obj-code  = gds-ptrl.obj-code  and
                   bf_gds-ptrl.is-gas    = gds-ptrl.is-gas    and
                   bf_gds-ptrl.artic     = gds-ptrl.artic     and
                   bf_gds-ptrl.prod-type = gds-ptrl.prod-type and
                   bf_gds-ptrl.prod-code = gds-ptrl.prod-code .
        delete bf_gds-ptrl .
        next .
      end.
    end. /* for each gds-ptrl */

    assign
      jj = j_columns-total * 2 + 6
    .
    for each gds-ptrl no-lock where
             gds-ptrl.obj-type = tt_object.obj-type and
             gds-ptrl.obj-code = tt_object.obj-code and
             gds-ptrl.is-gas   = no
          by gds-ptrl.gds-order
          by gds-ptrl.artic
          by gds-ptrl.prod-type
          by gds-ptrl.prod-code
    :
      assign
        Header-add-Line0 = Header-add-Line0 + "-------------"
        Header-add-Line2 = Header-add-Line2 + "------------:"
        Header-add-Line3 = Header-add-Line3 + Centre( gds-ptrl.gds-name, 12 ) + ":"
        Header-add-Line4 = Header-add-Line4 + "------------:"
      .
      assign
        jj               = jj + 1
        ext-column-label = ext-column-label + {&comma-char} + replace( gds-ptrl.gds-name, {&comma-char}, {&space-char} )
        SheetF.ColFormat = SheetF.ColFormat + ";" +
                           string( jj )     + "=" + "0" + v-delim + "00"
        SheetF.Sizes     = SheetF.Sizes     + {&comma-char} + "12"
      .
    end. /* for each gds-ptrl */
    assign
      SheetF.Excel-Column-Lable = SheetF.Excel-Column-Lable         + {&comma-char} +
                                  "Cумма грн."                      + {&new-line}   +
                                  ext-column-label
      SheetF.MergeCellsH        = SheetF.MergeCellsH                + {&comma-char} +
                                  string( j_columns-total * 2 + 7 ) + ":" +
                                  string( j_columns-total * 3 + 6 )
    .
    assign
      d_total-doc-qnty = 0.00
    .
    for each gds-ptrl no-lock where
             gds-ptrl.obj-type = tt_object.obj-type and
             gds-ptrl.obj-code = tt_object.obj-code and
             gds-ptrl.is-gas   = no
      , each gds-cell no-lock where
             gds-cell.obj-type = gds-ptrl.obj-type and
             gds-cell.obj-code = gds-ptrl.obj-code and
             gds-cell.gds-code = gds-ptrl.gds-code
    break by gds-cell.doc-code
          by gds-cell.gds-code
    :
      assign
        d_total-doc-qnty = d_total-doc-qnty + gds-cell.qnty
      .
      find first gds-total where
                 gds-total.obj-type = gds-cell.obj-type and
                 gds-total.obj-code = gds-cell.obj-code and
                 gds-total.gds-code = gds-cell.gds-code no-error .
      if not available gds-total
      then do:
        create gds-total .
        assign
          gds-total.obj-type      = gds-cell.obj-type
          gds-total.obj-code      = gds-cell.obj-code
          gds-total.gds-code      = gds-cell.gds-code
          gds-total.gds-order     = gds-cell.gds-order
          gds-total.total-qnty    = 0.000
          gds-total.total-sum     = 0.00
          gds-total.total-overall = 0.000
        .
      end.
      assign
        gds-total.total-qnty = gds-total.total-qnty + gds-cell.qnty
        gds-total.total-sum  = gds-total.total-sum  + gds-cell.qnty * gds-cell.price
      .
      if last-of( gds-cell.doc-code )
      then do:
        for each bf_gds-cell exclusive-lock where
                 bf_gds-cell.obj-type = gds-cell.obj-type and
                 bf_gds-cell.obj-code = gds-cell.obj-code and
                 bf_gds-cell.doc-code = gds-cell.doc-code
        :
          assign
            bf_gds-cell.total-qnty = d_total-doc-qnty
          .
        end. /* for each bf_gds-cell */
        assign
          gds-total.total-overall = gds-total.total-overall + d_total-doc-qnty
        .
        assign
          d_total-doc-qnty = 0.00
        .
      end.
    end. /* for each gds-cell */
    if tt_object.gds-found = yes
    then do:
      assign
        j_length         = 12 * j_columns-total
        temp-line        = Centering( "Сумма, грн.", j_length + j_columns-total - 1 )
        Header-add-Line1 = Header-add-Line1 + temp-line + fill( " ":U, j_length - length( temp-line ) ) + ":"
      .
      assign
        ReportName   = substitute( 'Отчет по приходу нефтепродуктов на &1'
                                 , tt_object.obj-name
                                 )
        j_length     = 115 + 39 * j_columns-total
        Under-Line   = fill( "-", j_length )
        Header-Name  = Centering(  caps( ReportName ), j_length ) +
                       {&new-line} +
                       {&new-line} +
                       ShiftRight( "Примечание: Цена прих. - цена прихода без доставки"
                                 , 165
                                 /* , j_length - ( 13 * j_columns-total + 1 ) */
                                 ) +
                       {&new-line} +
                       substitute( "за период с &1 по &2"
                                 , string( x-Date-Start, "99/99/9999":U )
                                 , string( x-Date-End,   "99/99/9999":U )
                                 ) +
                       ShiftRight( substitute( "Дата печати: &1, время: &2"
                                             , string( t_today, "99.99.9999":U )
                                             , string( j_time,  "HH:MM:SS":U   )
                                             )
                                 , j_length - 36 )
      .
      assign
        ReportHeader = substitute( "за период с &1 по &2"
                                 , string( x-Date-Start, "99/99/9999":U )
                                 , string( x-Date-End,   "99/99/9999":U )
                                 ) +
                       ShiftRight( substitute( "Дата печати: &1, время: &2"
                                             , string( t_today, "99.99.9999":U )
                                             , string( j_time,  "HH:MM:SS":U   )
                                             )
                                 , j_length - 36 )
        str3         = "Примечание: Цена прих. - цена прихода без доставки"
      .
      for each gds-ptrl no-lock where
               gds-ptrl.obj-type = tt_object.obj-type and
               gds-ptrl.obj-code = tt_object.obj-code and
               gds-ptrl.is-gas   = no
        , each gds-cell no-lock where
               gds-cell.obj-type = gds-ptrl.obj-type and
               gds-cell.obj-code = gds-ptrl.obj-code and
               gds-cell.gds-code = gds-ptrl.gds-code
      break by gds-cell.doc-code
            by gds-ptrl.artic
            by gds-ptrl.prod-type
            by gds-ptrl.prod-code
      :
        if first-of( gds-cell.doc-code )
        then do:
          assign
            j_excel-row = j_excel-row + 1
          .
        end. /* if first-of( gds-cell.doc-code ) */
      end. /* for each gds-ptrl, gds-cell */

      put stream text_out unformatted
        Header-Name                     skip
        Header-Line0 + Header-add-Line0 skip
        Header-Line1 + Header-add-Line1 skip
        Header-Line2 + Header-add-Line2 skip
        Header-Line3 + Header-add-Line3 skip
        Header-Line4 + Header-add-Line4 skip
      .
      assign
        vcurr-sheet-name = tt_object.obj-name
      .
      assign
        Sheetf.Bas-File      = "inptlug1.bas"
        Sheetf.Bas-Param-Add = yes
        Sheetf.Bas-Params    = "Petrol"                  + {&delim-par} +
                               string( j_excel-row     ) + {&delim-par} +
                               string( j_columns-total ) /* + {&delim-par} +
                               string( XLS-page-num    ) + {&delim-par} +
                               vcurr-sheet-name */
          SheetF.ColFormat   = SheetF.ColFormat          + {&delim-par} +
                                                           {&delim-par} +
                               vcurr-sheet-name
      .
      run rep/extitle.p
        ( input XLS-page-num
        ) no-error .
    end.

    for each gds-cell no-lock
       where gds-cell.obj-type = gds-ptrl.obj-type
         and gds-cell.obj-code = gds-ptrl.obj-code
      , each gds-ptrl no-lock
       where gds-ptrl.obj-type = tt_object.obj-type
         and gds-ptrl.obj-code = tt_object.obj-code
         and gds-ptrl.gds-code = gds-cell.gds-code
         and gds-ptrl.is-gas   = no
    break by gds-cell.doc-code
          by gds-cell.gds-order
          by gds-cell.gds-code
          by gds-ptrl.artic
          by gds-ptrl.prod-type
          by gds-ptrl.prod-code
    :
      if first-of( gds-cell.doc-code )
      then do:
        put stream text_out unformatted
          ":" + string(         gds-cell.doc-date,     "99.99.9999":U ) +
          ":" + string(         gds-cell.doc-code,     "x(14)":U      ) +
          ":" + string(         gds-cell.supp-name,    "x(30)":U      ) +
          ":" + string(         gds-cell.auto-name,    "x(30)":U      ) +
          ":" + fill(           " ":U,                    12          ) +
          ":" + string( OutQty( gds-cell.total-qnty ), "x(12)":U      )
        .
        {&PutExcel}
          string(         gds-cell.doc-date,     "99.99.9999":U ) {&tabulation}
          string(         gds-cell.doc-code,     "x(14)":U      ) {&tabulation}
          string(         gds-cell.supp-name,    "x(30)":U      ) {&tabulation}
          string(         gds-cell.auto-name,    "x(30)":U      ) {&tabulation}
          fill(           " ":U,                    12          ) {&tabulation}
          string( OutQty( gds-cell.total-qnty ), "x(12)":U      ) {&tabulation}
        .
        do jj = 1 to j_columns-total :
          assign
            j_excel-col = jj * 2 + 5
          .
          find first bf_gds-cell no-lock
            where bf_gds-cell.obj-type  = gds-cell.obj-type
              and bf_gds-cell.obj-code  = gds-cell.obj-code
              and bf_gds-cell.doc-code  = gds-cell.doc-code
              and bf_gds-cell.gds-order = jj
            no-error .
          if available bf_gds-cell then do:
            put stream text_out unformatted
              ":" + string( OutQty( bf_gds-cell.qnty  ), "x(12)":U ) +
              ":" + string( OutSum( bf_gds-cell.price ), "x(12)":U )
            .
            {&PutExcel}
              string( OutQty( bf_gds-cell.qnty  ), "x(12)":U ) {&tabulation}
              string( OutSum( bf_gds-cell.price ), "x(12)":U ) {&tabulation}
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
        end. /* do jj ... */
      end. /* if first-of( gds-cell.doc-code ) */
      if last-of( gds-cell.doc-code ) then do:
        do jj = 1 to j_columns-total :
          assign
            j_excel-col = j_excel-col + 1
          .
          find first bf_gds-cell no-lock
            where bf_gds-cell.obj-type  = gds-cell.obj-type
              and bf_gds-cell.obj-code  = gds-cell.obj-code
              and bf_gds-cell.doc-code  = gds-cell.doc-code
              and bf_gds-cell.gds-order = jj
            no-error .
          if available bf_gds-cell then do:
            assign
              d_summa = bf_gds-cell.price * bf_gds-cell.qnty
            .
            put stream text_out unformatted
              ":" + string( OutSum( d_summa ), "x(12)":U )
            .
            {&PutExcel}
              string( OutSum( d_summa ), "x(12)":U ) {&tabulation}
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
        end. /* do jj ... */

        put stream text_out unformatted
          ":" skip
        .
        {&PutExcel}
          skip
        .
      end. /* if last-of( gds-cell.doc-code ) */

    end. /* for each gds-ptrl, gds-cell */

    if tt_object.gds-found = yes
    then do:
      put stream text_out unformatted
        Under-Line skip
      .
      assign
        d_total-doc-qnty = 0.00
      .
      for each gds-total where
               gds-total.obj-type = tt_object.obj-type and
               gds-total.obj-code = tt_object.obj-code
      break by gds-total.obj-type
            by gds-total.obj-code
            by gds-total.gds-order
            by gds-total.gds-code
      :
        assign
          d_total-doc-qnty = d_total-doc-qnty + gds-total.total-overall
        .
      end. /* for each gds-total */
      put stream text_out unformatted
        ":" + string( "Итого:    ":U,             "x(10)":U ) +
        ":" + string( "":U,                       "x(14)":U ) +
        ":" + string( "":U,                       "x(30)":U ) +
        ":" + string( "":U,                       "x(30)":U ) +
        ":" + string( "":U,                       "x(12)":U ) +
        ":" + string( OutQty( d_total-doc-qnty ), "x(12)":U )
      .
      {&PutExcel}
        string( "Итого:    ":U,             "x(10)":U ) {&tabulation}
        string( "":U,                       "x(14)":U ) {&tabulation}
        string( "":U,                       "x(30)":U ) {&tabulation}
        string( "":U,                       "x(30)":U ) {&tabulation}
        string( "":U,                       "x(12)":U ) {&tabulation}
        string( OutQty( d_total-doc-qnty ), "x(12)":U ) {&tabulation}
      .
      assign
        d_total-doc-qnty = 0.00
      .
      for each gds-total where
               gds-total.obj-type = tt_object.obj-type and
               gds-total.obj-code = tt_object.obj-code
      break by gds-total.obj-type
            by gds-total.obj-code
            by gds-total.gds-order
            by gds-total.gds-code
      :
        do jj = 1 to j_columns-total :
          if gds-total.gds-order = jj
          then do:
            put stream text_out unformatted
              ":" + string( OutQty( gds-total.total-qnty ), "x(12)":U ) +
              ":" + string( "":U,                           "x(12)":U )
            .
            {&PutExcel}
              string( OutQty( gds-total.total-qnty ), "x(12)":U ) {&tabulation}
              string( "":U,                           "x(12)":U ) {&tabulation}
            .
          end.
          /*
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
          */
        end. /* do jj ... */
      end. /* for each gds-total */
      for each gds-total where
               gds-total.obj-type = tt_object.obj-type and
               gds-total.obj-code = tt_object.obj-code
      break by gds-total.obj-type
            by gds-total.obj-code
            by gds-total.gds-order
            by gds-total.gds-code
      :
        do jj = 1 to j_columns-total :
          if gds-total.gds-order = jj
          then do:
            put stream text_out unformatted
              ":" + string( OutSum( gds-total.total-sum  ), "x(12)":U )
            .
            {&PutExcel}
              string( OutSum( gds-total.total-sum  ), "x(12)":U ) {&tabulation}
            .
          end.
          /*
          else do:
            put stream text_out unformatted
              ":" + fill( " ":U, 12 )
            .
            {&PutExcel}
              {&tabulation}
            .
          end.
          */
        end.
      end. /* for each gds-total */
      put stream text_out unformatted
        ":" skip
            Under-Line
            skip
      .
      page stream text_out .
      {&PutExcel}
        skip
      .
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
  if gds-gas-found = yes
  then do:
    for each tt_object no-lock
    :
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
          /*                  :    10    :      14     :              30              :     12     :     12     :     12     : */
          Header-Line0     = "-------------------------------------------------------------------------------------------------"
          Header-Line1     = ":          :              :                              :" + Centering( tt_object.obj-name, 38 ) + ":"
          Header-Line2     = ":   Дата   :   № док-та   :         Постачальник         :------------:------------:------------:"
          Header-Line3     = ":          :              :                              : Кол-во, л. : Цена прих. : Сумма,грн. :"
          Header-Line4     = ":----------:--------------:------------------------------:------------:------------:------------:"
          Header-add-Line0 = "":U
          Header-add-Line1 = "":U
          Header-add-Line2 = "":U
          Header-add-Line3 = "":U
          Header-add-Line4 = "":U
        .
        assign
          j_excel-row = 0
          j_excel-col = 0
        .
        assign
          ReportName  = substitute( 'Отчет по приходу нефтепродуктов на &1. Газ'
                                  , tt_object.obj-name
                                  )
          j_length    = 97
          Under-Line  = fill( "-", j_length )
          Header-Name = Centering(  caps( ReportName ), j_length ) +
                        {&new-line} +
                        {&new-line} +
                        substitute( "за период с &1 по &2"
                                  , string( x-Date-Start, "99/99/9999":U )
                                  , string( x-Date-End,   "99/99/9999":U )
                                  ) +
                        ShiftRight( substitute( "Дата печати: &1, время: &2"
                                              , string( t_today, "99.99.9999":U )
                                              , string( j_time,  "HH:MM:SS":U   )
                                              )
                                  , j_length - 36 )
          ReportHeader = substitute( "за период с &1 по &2"
                                   , string( x-Date-Start, "99/99/9999":U )
                                   , string( x-Date-End,   "99/99/9999":U )
                                   ) +
                         ShiftRight( substitute( "Дата печати: &1, время: &2"
                                               , string( t_today, "99.99.9999":U )
                                               , string( j_time,  "HH:MM:SS":U   )
                                               )
                                   , j_length - 44 )
        .
        put stream text_out unformatted
          Header-Name  skip
          Header-Line0 skip
          Header-Line1 skip
          Header-Line2 skip
          Header-Line3 skip
          Header-Line4 skip
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
          SheetF.MergeCellsH        = "4:6"
          SheetF.MergeCellsV        = "1=1:2/2=1:2/3=1:2"
          SheetF.Excel-Column-Lable = "Дата"              + {&comma-char} +
                                      "№ док-та"          + {&comma-char} +
                                      "Постачальник"      + {&comma-char} +
                             replace( tt_object.obj-name,   {&comma-char} , {&space-char} )
                                                          + {&comma-char}
                                                          + {&comma-char} + {&new-line}
                                                          + {&comma-char}
                                                          + {&comma-char}
                                                          + {&comma-char} +
                                      "Кол-во (л)"        + {&comma-char} +
                                      "Цена прих."        + {&comma-char} +
                                      "Сумма грн."
          SheetF.ColFormat          = "4=" + "0" + v-delim + "000" + ";" +
                                      "5=" + "0" + v-delim + "00"  + ";" +
                                      "6=" + "0" + v-delim + "00"
          SheetF.Sizes              = "10,14,30,12,12,12"
        .
        for each gds-ptrl no-lock where
                 gds-ptrl.obj-type = tt_object.obj-type and
                 gds-ptrl.obj-code = tt_object.obj-code and
                 gds-ptrl.is-gas   = yes
          , each gds-cell no-lock where
                 gds-cell.obj-type = gds-ptrl.obj-type and
                 gds-cell.obj-code = gds-ptrl.obj-code and
                 gds-cell.gds-code = gds-ptrl.gds-code
        :
          assign
            j_excel-row = j_excel-row + 1
          .
        end. /* for each gds-ptrl, gds-cell */
        assign
          vcurr-sheet-name = tt_object.obj-name + ". ГАЗ"
        .
        assign
          Sheetf.Bas-File      = "inptlug1.bas"
          Sheetf.Bas-Param-Add = yes
          Sheetf.Bas-Params    = "Gas"                  + {&delim-par} +
                                 string( j_excel-row  ) + {&delim-par} +
                                 "1"                    /* + {&delim-par} +
                                 string( XLS-page-num ) + {&delim-par} +
                                 vcurr-sheet-name */
          SheetF.ColFormat     = SheetF.ColFormat       + {&delim-par} +
                                                          {&delim-par} +
                                 vcurr-sheet-name
        .
        run rep/extitle.p
          ( input XLS-page-num
          ) no-error .

        assign
          d_total-qnty = 0.00
          d_total-sum  = 0.00
        .
        for each gds-ptrl no-lock where
                 gds-ptrl.obj-type = tt_object.obj-type and
                 gds-ptrl.obj-code = tt_object.obj-code and
                 gds-ptrl.is-gas   = yes
          , each gds-cell no-lock where
                 gds-cell.obj-type = gds-ptrl.obj-type and
                 gds-cell.obj-code = gds-ptrl.obj-code and
                 gds-cell.gds-code = gds-ptrl.gds-code
        break by gds-cell.doc-code
              by gds-ptrl.artic
              by gds-ptrl.prod-type
              by gds-ptrl.prod-code
        :
          assign
            d_summa = gds-cell.price * gds-cell.qnty
          .
          put stream text_out unformatted
            ":" + string(         gds-cell.doc-date,  "99.99.9999":U ) +
            ":" + string(         gds-cell.doc-code,  "x(14)":U      ) +
            ":" + string(         gds-cell.supp-name, "x(30)":U      ) +
            ":" + string( OutQty( gds-cell.qnty  ),   "x(12)":U      ) +
            ":" + string( OutSum( gds-cell.price ),   "x(12)":U      ) +
            ":" + string( OutSum( d_summa ),          "x(12)":U      ) +
            ":"   skip
          .
          {&PutExcel}
            string(         gds-cell.doc-date,  "99.99.9999":U ) {&tabulation}
            string(         gds-cell.doc-code,  "x(14)":U      ) {&tabulation}
            string(         gds-cell.supp-name, "x(30)":U      ) {&tabulation}
            string( OutQty( gds-cell.qnty  ),   "x(12)":U      ) {&tabulation}
            string( OutSum( gds-cell.price ),   "x(12)":U      ) {&tabulation}
            string( OutSum( d_summa ),          "x(12)":U      )
            skip
          .
          assign
            d_total-qnty = d_total-qnty + gds-cell.qnty
            d_total-sum  = d_total-sum  + d_summa
          .
        end. /* for each gds-ptrl, gds-cell */
        put stream text_out unformatted
          Under-Line skip
        .
        put stream text_out unformatted
          ":" + string( "Итого:    ":U,         "x(10)":U ) +
          ":" + string( "":U,                   "x(14)":U ) +
          ":" + string( "":U,                   "x(30)":U ) +
          ":" + string( OutQty( d_total-qnty ), "x(12)":U ) +
          ":" + string( "":U,                   "x(12)":U ) +
          ":" + string( OutSum( d_total-sum  ), "x(12)":U ) +
          ":"   skip
                Under-Line
                skip
        .
        page stream text_out .

        {&PutExcel}
          string( "Итого:    ":U,         "x(10)":U ) {&tabulation}
          string( "":U,                   "x(14)":U ) {&tabulation}
          string( "":U,                   "x(30)":U ) {&tabulation}
          string( OutQty( d_total-qnty ), "x(12)":U ) {&tabulation}
          string( "":U,                   "x(12)":U ) {&tabulation}
          string( OutSum( d_total-sum  ), "x(12)":U )
          skip
        .
        {&PageExcel}
      end. /* if tt_object.gas-found = yes */
    end. /* for each tt_object */
  end. /* газ */

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
  define variable is-petrol as logical no-undo .
  define variable is-pieces as logical no-undo .

  define variable v_gds-attr-value as character no-undo .
  define variable v_gds-attr-type  as character no-undo .
  define variable j_gds-order      as integer   no-undo .
  define variable j_gas-order      as integer   no-undo .
  define variable l_is-gds-gas     as logical   no-undo .

  define buffer bf_gds-obj for ub.gds-obj .
  define buffer bf_goods   for ub.goods   .

  do
  on error undo, return error return-value
  :
    for each obj-list no-lock
    :
      create tt_object .
      assign
        tt_object.obj-type  = obj-list.obj-type
        tt_object.obj-code  = obj-list.obj-code
        tt_object.obj-name  = obj-list.obj-name
        tt_object.obj-id    = obj-list.obj-id
        tt_object.db-num    = obj-list.db-num
        tt_object.was-found = no
        tt_object.gds-found = no
        tt_object.gas-found = no
      .
    end. /* for each obj-list */
    for each tt_object no-lock
    break by tt_object.obj-type
          by tt_object.obj-code
    :
      if first-of( tt_object.obj-code )
      then do:
        assign
          j_gds-order = 0
          j_gas-order = 0
        .
      end.
      for each  bf_gds-obj no-lock where
                bf_gds-obj.obj-type = tt_object.obj-type and
                bf_gds-obj.obj-code = tt_object.obj-code
        , first bf_goods   no-lock where
                bf_goods.gds-code   = bf_gds-obj.gds-code
      :
        find first gds-ptrl no-lock where
                   gds-ptrl.obj-type  = bf_gds-obj.obj-type  and
                   gds-ptrl.obj-code  = bf_gds-obj.obj-code  and
                   gds-ptrl.artic     = bf_gds-obj.artic     and
                   gds-ptrl.prod-type = bf_gds-obj.prod-type and
                   gds-ptrl.prod-code = bf_gds-obj.prod-code no-error .
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
    end. /* for each tt_object */
  end. /* on error */
end procedure. /* cr-gds-list */

procedure get-dec-string :
  define  input parameter p-dec  as decimal   no-undo .
  define  input parameter p-len  as integer   no-undo .
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
    else
    if p-len = 3
    then do:
      assign
        p-char = trim( string( p-dec, "->>>>>>9.999":U ) )
      .
    end.
    else
    if p-len = 2
    then do:
      assign
        p-char = trim( string( p-dec, "->>>>>>>9.99":U ) )
      .
    end.
    assign
      p-char = fill( " ":U, j-len - length( trim( p-char ) ) ) + trim( p-char )
    .
  end. /* on error */
end procedure. /* get-dec-string */