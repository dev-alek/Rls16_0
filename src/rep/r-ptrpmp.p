block-level on error undo, throw.
/*

$Revision: 899f5f3721f3, 1951, rls $
$Author: ASMorozov $
$Date: Fri Jul 26 11:39:33 2019 +0300 $
$Workfile: r-ptrpmp.p $
$Archive: rep/r-ptrpmp.p $

АКТ учета нефтепродуктов при выполнении работ по проверке погрешности ТРК

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/22/05
Author: Dmitry Ukhanov
Creation date: 11/22/05

*/

/* ***************************  Definitions  ************************** */
/* ********************  Preprocessor Definitions  ******************** */
&scop cli-length  40
&scop right-just  97
&scop f-l         MonthNameRusGen

/* VSS Variable Definitions */
define variable vss-revision    as character no-undo initial "$Revision: 899f5f3721f3, 1951, rls $":U.
define variable vss-author      as character no-undo initial "$Author: ASMorozov $":U.
define variable vss-date        as character no-undo initial "$Date: Fri Jul 26 11:39:33 2019 +0300 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: r-ptrpmp.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/r-ptrpmp.p $":U.
define variable vss-description as character no-undo initial "АКТ учета нефтепродуктов при выполнении работ по проверке погрешности ТРК":U.

/* Common Definitions */
{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ str/lib-trn.i         }
{ gbl/prn-lib.i         }
{ cmp/r-page1.i         }
{ cmp/r-pril.i          }
{ gbl/cur-time.i        }
{ gbl/waitfram.i        }
{ gbl/std-func.i {&f-l} }
{ str/trdcalib.i        }

/* Temp Table Definitions */
define temp-table tt_tsf no-undo
  field obj-type  as character
  field obj-code  as integer
  field gds-code  as integer
  field gds-name  as character
  field pump-code as integer
  field chk-date  as date
  field chk-time  as integer
  field doc-qnty  as decimal
  field ps        as character
  index ttpi      is primary   obj-type obj-code gds-code pump-code chk-date chk-time.

/* Local Variable Definitions */
define variable Line        as character no-undo.
define variable j_time      as integer   no-undo.
define variable v_today     as character no-undo.
define variable j-host-code as integer   no-undo.
define variable v-host-name as character no-undo.
define variable v-host-nmhd as character no-undo.
define variable v-obj-name  as character no-undo.
define variable j-max-objid as integer   no-undo.
define variable j-min-objid as integer   no-undo.
define variable j_order     as integer   no-undo.
define variable v-value     as character no-undo.
define variable v-type      as character no-undo.
define buffer bf_inkas       for ub.inkas.
define buffer bf-spi_trn-doc for ub.trn-doc.


/* ************************  Frame Definitions  *********************** */
form header
  Line format "x({&A4_CW0})":U          at  1 skip
  "Продолжение - на следующей странице" at 30 skip
with frame BottomFrame width {&DOS_CW_2} page-bottom no-labels no-box.

/* ***************************  Main Block  *************************** */
run WaitFram-Show in this-procedure ( input "Идет сбор данных для отчета, ждите..." ).
assign Line    = fill( "-", {&A4_CW0} )
       v_today = '" ' + trim( string( day( x-date-alone ), ">9":U   ) ) + ' "  ' +
                 MonthNameRusGen( month(   x-date-alone ) )             + " ":U  +
                 trim( string(      year(  x-date-alone ), "9999":U ) ) + "г.".
for each Sheetf where Sheetf.Sheet-Num > 1 :
  process events.
  delete Sheetf.
end.
find first Sheetf where Sheetf.Sheet-Num = 1 no-error.
if not available Sheetf then do:
  create Sheetf.
  assign Sheetf.Sheet-num = 1.
end.
assign Sheetf.Excel-Column-Lable = "Наименование нефтепродукта" + {&comma-char} +
                                   "№ ТРК"                      + {&comma-char} +
                                   "Дата Время       час мин."  + {&comma-char} +
                                   "Объем (л)"                  + {&comma-char} +
                                   "Примечание"
       Sheetf.Sizes              = "{&cli-length},5,15,11,127".
assign str1 = "":U
       str2 = "":U
       str3 = "":U
       str4 = "":U.

run spill-fuel          in this-procedure.
run prn-lib-open-stream in this-procedure ( input my-handle,
                                             input {&CS_PS},
                                             input yes,       /* p-is-stream */
                                             input no         /* p-append    */ ).
view stream PrnLibStream frame BottomFrame.

run WaitFram-Show in this-procedure ( input "Идет формирование отчета, ждите..." ).
{&SetCursorWait}

assign j_order = 0.
for each obj-list no-lock
   where obj-list.obj-id   > 0           and
         obj-list.obj-id   > j-min-objid and
         obj-list.obj-id   < j-max-objid
break by obj-list.obj-type
      by obj-list.obj-code :
  process events.
  {&SetCursorWait}
  view stream PrnLibStream frame BottomFrame.

  find first tt_tsf no-lock where
             tt_tsf.obj-type = obj-list.obj-type and
             tt_tsf.obj-code = obj-list.obj-code no-error.
  if not available tt_tsf then do: next. end.
  { gbl/hostname.i obj-list.obj-type obj-list.obj-code j-host-code v-host-name no-error }
  {&SetCursorWait}
  if error-status :error then do: next. end.

  assign v-obj-name  = trim( obj-list.obj-name ) + fill( "_", {&cli-length} )
         v-host-nmhd = trim( v-host-name       ) + fill( "_", {&cli-length} ).
  assign ReportHeader =
    fill( " ":U, {&right-just} ) + string( v-host-nmhd, "x({&cli-length})":U )             + {&new-line} +
    fill( " ":U, {&right-just} ) + string( v-obj-name,  "x({&cli-length})":U )             + {&new-line} +
                                                                                             {&new-line} +
                                                                                             {&new-line} +
    fill( " ":U, 64            ) + "А К Т"                                                 + {&new-line} +
    fill( " ":U, 54            ) + "прокачки топлива через ТРК"                            + {&new-line} +
                                                                                             {&new-line} +
                                                                                             {&new-line} +
    fill( " ":U, 56            ) + string( v_today,     "x(24)":U            )             + {&new-line} +
                                                                                             {&new-line} +
                                                                                             {&new-line} +
    '           Мы, нижеподписавшиеся, представители "' + v-host-name + '" составили'      + {&new-line} +
    "настоящий Акт о том, что при проведении технических работ, проверке точности отпуска дозы (ненужное зачеркнуть) " + {&new-line} +
    "через ТРК было прокачено в мерник и слито (возвращено) в резервуар в соответствии с видом топлива:"  + {&new-line} +
                                                                                                            {&new-line} .
  assign j_order = j_order + 1.
  find first Sheetf where Sheetf.Sheet-Num = j_order no-error.
  if not available Sheetf then do:
    create Sheetf.
    assign Sheetf.Sheet-num = j_order.
  end.
  assign Sheetf.Excel-Column-Lable = "Наименование нефтепродукта" + {&comma-char} +
                                     "№ ТРК"                      + {&comma-char} +
                                     "Дата Время       час мин."  + {&comma-char} +
                                     "Объем (л)"                  + {&comma-char} +
                                     "Примечание"
         Sheetf.Sizes              = "{&cli-length},5,15,11,127".
  run rep/extitle.p ( input j_order ) no-error.
  {&SetCursorWait}
  run print-header in this-procedure.
  {&SetCursorWait}
  put stream PrnLibStream unformatted
    "----------------------------------------------------------------------------------------------------------------------------------------" skip
    ":              Наименование              : № :  Дата, Время, : Объем (л) : Примечание                                                  :" skip
    ":              нефтепродукта             :ТРК:   час,  мин.  :           :                                                             :" skip
    "----------------------------------------------------------------------------------------------------------------------------------------" skip.

  for each tt_tsf no-lock where
           tt_tsf.obj-type  = obj-list.obj-type and
           tt_tsf.obj-code  = obj-list.obj-code use-index ttpi
  break by tt_tsf.obj-type
        by tt_tsf.obj-code
        by tt_tsf.gds-code
        by tt_tsf.pump-code
        by tt_tsf.chk-date
        by tt_tsf.chk-time  :
    process events.
    {&SetCursorWait}
    put stream PrnLibStream unformatted ":".
    if first-of( tt_tsf.gds-code ) then do:
      put stream PrnLibStream unformatted string( tt_tsf.gds-name, "x(40)":U ).
    end.
    else do:
      put stream PrnLibStream unformatted string( "           ":U, "x(40)":U ).
    end.
    put stream PrnLibStream unformatted
      ":" + ( if tt_tsf.pump-code < 10 then
            ( " ":U + string( tt_tsf.pump-code, "9":U     ) ) + " ":U
                                         else
            ( " ":U + string( tt_tsf.pump-code, ">9":U  ) ) ) +
      ":" + string( tt_tsf.chk-date,  "99/99/99":U          ) + ", ":U +
            string( tt_tsf.chk-time,  "HH:MM":U             ) +
      ":" + string( tt_tsf.doc-qnty,  "zzzzzzz9.99":U       ) +
      ":" + string( tt_tsf.ps,        "x(61)"               ) + ":"    skip.
    if last-of( tt_tsf.gds-code ) then do:
        if not last( tt_tsf.gds-code ) then do:
      put stream PrnLibStream unformatted
        ":----------------------------------------:-------------------:-----------:-------------------------------------------------------------:" skip.
        end.
    end.
    else do:
      put stream PrnLibStream unformatted
        ":                                        :-------------------:-----------:-------------------------------------------------------------:" skip.
    end.
    if first-of( tt_tsf.gds-code ) then do:
      {&PutExcel} string( tt_tsf.gds-name, "x(40)":U ) {&tabulation}.
    end.
    else do:
      {&PutExcel} string( "           ":U, "x(40)":U ) {&tabulation}.
    end.
    {&PutExcel} string( tt_tsf.pump-code, "z9":U          ) {&tabulation}
                string( tt_tsf.chk-date,  "99/99/99":U    ) + ", ":U +
                string( tt_tsf.chk-time,  "HH:MM":U       ) {&tabulation}
                string( tt_tsf.doc-qnty,  "zzzzzzz9.99":U ) {&tabulation}
                string( tt_tsf.ps,        "x(61)"         ) {&new-line}.
  end. /* for each tt_tsf */

  find first tt_tsf no-lock no-error.
  if available tt_tsf then do:
    put stream PrnLibStream unformatted
      "----------------------------------------------------------------------------------------------------------------------------------------" skip( 1 ).
  end.
  {&SetCursorWait}
  run print-footer in this-procedure.
  if not last( obj-list.obj-type ) then do:
    hide stream PrnLibStream frame BottomFrame.
    page stream PrnLibStream.
    {&PageExcel}
  end.
end. /* for each obj-list */

{&CloseExcel}
hide stream PrnLibStream frame BottomFrame.
output stream PrnLibStream close.
run waitfram-hide in this-procedure.
{&SetCursorNo}

find first tt_tsf no-lock no-error.
if not available tt_tsf then do:
  message "За" x-date-alone "по выбранным объектам не было тех.проливов." view-as alert-box information.
  return.
end.
else do:
  run prn-lib-prn-file in this-procedure ( input my-handle, input 0 ).
end.

/* **********************  Internal Procedures  *********************** */
procedure print-header :
  put stream PrnLibStream unformatted                                                        skip( 1 )
    string( v-host-nmhd, "x({&cli-length})":U ) format "x({&cli-length})":U at {&right-just} skip
    string( v-obj-name,  "x({&cli-length})":U ) format "x({&cli-length})":U at {&right-just} skip( 2 )
              "А К Т"                                                       at 65            skip
    "прокачки топлива через ТРК"                                            at 55            skip( 1 )
    string( v_today,     "x(24)":U            ) format "x(24)":U            at 57            skip( 1 )
    '           Мы, нижеподписавшиеся, представители "' + v-host-name + '" составили'        skip
    "настоящий Акт о том, что при проведении технических работ, проверке точности отпуска дозы (ненужное зачеркнуть) через "   skip
    "ТРК было прокачено в мерник и слито (возвращено) в резервуар в соответствии с видом топлива:" skip( 1 ).
end procedure. /* print-header */

procedure spill-fuel :
  define variable j-host-code as integer   no-undo.
  define variable v-host-name as character no-undo.
  define variable v-obj-name  as character no-undo.
  define variable is-petrol   as logical   no-undo.
  define variable is-pieces   as logical   no-undo.
  define variable was-found   as logical   no-undo.

  define buffer bf_chk-doc  for ub.chk-doc.
  define buffer bf_chk-gds  for ub.chk-gds.
  define buffer bf_goods    for ub.goods.
  define buffer bf_bar-code for ub.bar-code.
  define buffer bf_obj-list for obj-list.

  find first obj-list no-lock use-index pi no-error.
  assign j-min-objid = ( if available obj-list then obj-list.obj-id else 0 ) - 1.

  find last  obj-list no-lock use-index pi no-error.
  assign j-max-objid = ( if available obj-list then obj-list.obj-id else 0 ) + 1.

  for each obj-list no-lock where
           obj-list.obj-id > j-min-objid and
           obj-list.obj-id < j-max-objid :
    process events.
    assign was-found = no.

    for each bf_chk-doc no-lock where
             bf_chk-doc.obj-type = obj-list.obj-type and
             bf_chk-doc.obj-code = obj-list.obj-code and
             bf_chk-doc.chk-date = x-date-alone      use-index obj-date :
      process events.
      /*Берем только чеки, привязанные к продажам*/
      find first bf_inkas where bf_inkas.inkas-code = bf_chk-doc.out-code no-lock no-error.
      if not available bf_inkas then do:
        next.
      end.
      if bf_chk-doc.chk-type <> integer( {&rcpt-tech-refuell} ) then do: next. end.

      for each bf_chk-gds no-lock where
               bf_chk-gds.doc-code = bf_chk-doc.doc-code :
        process events.

        if bf_chk-gds.pump = 0 then do: next. end.
        find first bf_bar-code no-lock where bf_bar-code.b-code = bf_chk-gds.b-code    no-error.
        if not available bf_bar-code then do: next. end.
        find first bf_goods    no-lock where bf_goods.gds-code  = bf_bar-code.gds-code no-error.
        if not available bf_goods then do: next. end.
        { str/is-petrl.i bf_goods.artic
                     bf_goods.prod-type
                     bf_goods.prod-code
                     is-petrol
                     is-pieces          no-error }
        if error-status :error then do: next. end.

        /* остался только техпролив топлива */
        def var v-value as character no-undo.
        def var v-type  as character no-undo.
        def var v-tech-pass as logical no-undo.
        { str/tdat-val.i                                    
          bf-spi_trn-doc.doc-code
          {&trdcattr-techpass}
          v-value 
          v-type 
          no-error
        }
        assign
          v-tech-pass = yes when v-value = "yes".
        create tt_tsf.
        assign tt_tsf.obj-type  = bf_chk-doc.obj-type
               tt_tsf.obj-code  = bf_chk-doc.obj-code
               tt_tsf.gds-code  = bf_goods.gds-code
               tt_tsf.gds-name  = bf_goods.gds-name
               tt_tsf.pump-code = bf_chk-gds.pump
               tt_tsf.chk-date  = bf_chk-doc.chk-date
               tt_tsf.chk-time  = bf_chk-doc.chk-time
               tt_tsf.doc-qnty  = bf_chk-gds.doc-qnty.
        define buffer buf_sale-doc for ub.sale-doc.
        find first buf_sale-doc no-lock where
                  buf_Sale-doc.inkas-code = bf_inkas.inkas-code
             and  buf_Sale-doc.doc-kind = {&sale-add-tech-refuell} no-error.
        if available buf_sale-doc or v-tech-pass then do:
          find first bf-spi_trn-doc where bf-spi_trn-doc.doc-code = v-value no-lock no-error.
          if available bf-spi_trn-doc and
            substring(bf-spi_trn-doc.ps, 1, 1) <> "@" then do:
            assign
              tt_tsf.ps = substring(replace(replace(bf-spi_trn-doc.ps, {&carriage-return}, "":u), {&new-line}, "":u), 1, 61).
          end.
        end.
        assign was-found        = yes.
      end. /* for each bf_chk-gds */
    end. /* for each bf_chk-doc */

    find bf_obj-list exclusive-lock where recid( bf_obj-list ) = recid( obj-list ).
    if was-found <> yes then do:
      assign bf_obj-list.obj-id = - ( abs( bf_obj-list.obj-id ) + abs( j-min-objid ) ).
      /* delete obj-list. */
    end.
    else do:
      assign bf_obj-list.obj-id =   ( abs( bf_obj-list.obj-id ) + abs( j-max-objid ) ).
    end.
    find bf_obj-list        no-lock where recid( bf_obj-list ) = recid( obj-list ).
  end. /* for each obj-list */

  find first obj-list no-lock where
             obj-list.obj-id > 0 use-index pi no-error.
  assign j-min-objid = ( if available obj-list then obj-list.obj-id else 0 ) - 1.

  find last  obj-list no-lock    use-index pi no-error.
  assign j-max-objid = ( if available obj-list then obj-list.obj-id else 0 ) + 1.
end procedure. /* spill-fuel */

procedure print-footer :
  put stream PrnLibStream unformatted                                                          skip( 1 )
    "Председатель комиссии:"                                                                   skip
    "________________________    (                                                         )" at 50 skip( 2 )
    "Члены комиссии:"                                                                          skip
    "________________________    (                                                         )" at 50 skip( 1 )
    "________________________    (                                                         )" at 50 skip( 1 )
    "________________________    (                                                         )" at 50 skip( 1 )
    "________________________    (                                                         )" at 50 skip( 1 ).
  {&PutExcel}                                                                                     {&new-line}
                                                                                                  {&new-line}
              "Председатель комиссии:"                                                            {&new-line}
              fill( " ":U, 49 ) +
              "_______________________    (                                                    )" {&new-line}
                                                                                                  {&new-line}
                                                                                                  {&new-line}
              "Члены комиссии:"                                                                   {&new-line}
              fill( " ":U, 50 ) +
              "_______________________    (                                                    )" {&new-line}
                                                                                                  {&new-line}
              fill( " ":U, 50 ) +
              "_______________________    (                                                    )" {&new-line}
                                                                                                  {&new-line}
              fill( " ":U, 50 ) +
              "_______________________    (                                                    )" {&new-line}
                                                                                                  {&new-line}
              fill( " ":U, 50 ) +
              "_______________________    (                                                    )" {&new-line}
                                                                                                  {&new-line}.
end procedure. /* print-footer */