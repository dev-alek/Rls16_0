block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-daycas.p $
$Archive: rep/r-daycas.p $

Отчет по выручке для суздальского

Автор: Демин Алексей Сергеевич
Дата создания: 09/13/05
Author: Alexey Demin
Creation date: 09/13/05

*/

define input parameter p-call-handle as handle no-undo .
define input parameter p-host-code as integer   no-undo .
define input parameter p-period-type as character no-undo .
define input parameter p-date1     as date      no-undo .
define input parameter p-date2     as date      no-undo .
define input parameter p-dir-name as character no-undo .
define input parameter p-rep-code as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-daycas.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-daycas.p $":U .
define variable vss-description as character no-undo init "Отчет по выручке".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-delim as character no-undo .
define variable v-del-1 as character no-undo .
define variable v-sdate as character no-undo .
define variable v-file-prefix as character no-undo .
define variable v-shortdate as character no-undo .
run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
if error-status :error then do:
  message error-status :error error-status :get-message(1) v-delim v-del-1.
  v-delim = ','  .
end.
define variable g#report-num as integer   no-undo .

{ cmp/library.i  }
{ cmp/r-pril.i   }
{ rep/f-fdec.i   }
{ gbl/paramls.i  }
{ rep/mcrexcel.i }
{ str/clcprtsl.i }
{ gbl/cur-time.i }

do
on error undo, return error
:

 define stream macr_excel .
/* define variable v-file-name as character no-undo .*/

  define temp-table temp-mag no-undo  /* для списка товаров */
    field obj-code  like ub.clients.obj-code
    field obj-type  like ub.clients.obj-type
    field obj-name  like ub.clients.obj-name
    field sum-viruch   as decimal
    field sum-kredit   as decimal
    field sum-real     as decimal
    field nazen        as decimal
    field num-chk      as integer
    field num-tov      as integer
    INDEX pi  IS unique PRIMARY obj-type obj-code
  .
  define temp-table temp-tov no-undo  /* для списка товаров */
    field prod-code  like ub.clients.obj-code
    field prod-type  like ub.clients.obj-type
    field artic      as character
    INDEX pi  IS PRIMARY unique artic prod-code prod-type
  .

  for each temp-mag:
    delete temp-mag.
  end.
  define buffer buf_inkas for ub.inkas .
  define buffer buf_cash-pay for ub.cash-pay.
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf1_trn-doc for ub.trn-doc .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_inkas-pay for ub.inkas-pay .
  define buffer buf_shop     for ub.shop.

  define variable  Counter1    as integer   no-undo .
  define variable  ii          as integer   no-undo .

  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .
  if valid-handle(p-call-handle)
  and lookup( "cb_get-shops", p-call-handle:internal-entries ) > 0
  then do:
    run cb_get-shops in p-call-handle ( input this-procedure:handle).
  end.
  if not can-find(first temp-mag) then do:
    for each buf_shop no-lock where
      p-host-code = 0
    or buf_shop.host-code = p-host-code :
      run cb_set-shops in this-procedure ( input buf_shop.obj-code).
    end.
  end.
  assign  Counter1 = 0 .
  if p-date1 = ?
  or p-date2 = ? then do:
    run cur-time in this-procedure ( output v-today, output v-time).
    case p-period-type:
      when {&period-type-yesterday} then do:
    assign
        p-date1 = v-today - 1
        p-date2 = v-today.
      end.
      when {&period-type-week-last} then do:
      assign
      p-date1 = (v-today - ((weekday(today) + 5) modulo 7) - 7)
      p-date2   = (v-today - ((weekday(today) + 5) modulo 7))
    .
  end.
      when {&period-type-month-last} then do:
        assign
        p-date1 = if month(v-today) = 1
                      then  date( 12, 1, year(v-today) - 1 )
                      else  date( month(v-today) - 1, 1, year(v-today) )
        p-date2 = date( month(v-today), 1, year(v-today))
        .
      end.
      otherwise do:
        undo, return error substitute("Не заданы ни даты ни тип периода").
      end.
    end case.
  end.
  if p-dir-name = ?
  or p-dir-name = ''
  then do:
    p-dir-name = session:temp-directory.
  end.
  assign
  v-file-prefix =  p-dir-name + substitute("ov_&1_&2&3&4_&5"
              , p-period-type
              , string(year(p-date1), "9999")
              , string(month(p-date1), "99")
              , string(day(p-date1), "99")
              , p-rep-code
              )
  .

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */
  for each temp-mag :
    for each temp-tov : delete  temp-tov. end.
    for each buf_inkas no-lock
      where buf_inkas.obj-code  = temp-mag.obj-code
        and buf_inkas.obj-type  = temp-mag.obj-type
        and buf_inkas.status_   = {&fact}
        and buf_inkas.doc-date >= p-date1
        and buf_inkas.doc-date < p-date2
    :
      assign
        temp-mag.num-chk    = temp-mag.num-chk    + buf_inkas.num-chk
      .
      find first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_inkas.inkas-code no-error .
      if available buf_trn-doc then do:
        assign temp-mag.sum-real = temp-mag.sum-real + buf_trn-doc.fact-rubl .
        for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :
          find first temp-tov no-lock
            where temp-tov.artic     = buf_doc-line.artic
              and temp-tov.prod-code = buf_doc-line.prod-code
              and temp-tov.prod-type = buf_doc-line.prod-type
          no-error .
          if not available temp-tov then do:
            create temp-tov .
            assign
              temp-tov.artic     = buf_doc-line.artic
              temp-tov.prod-code = buf_doc-line.prod-code
              temp-tov.prod-type = buf_doc-line.prod-type
              temp-mag.num-tov   = temp-mag.num-tov + 1
            .
          end.
/*          run clcprtsl_calc-line in this-procedure (input recid (buf_doc-line)).*/
/*          find first tt-allsum-line where tt-allsum-line.sum-type = {&sum-general} no-error .*/
/*          assign temp-mag.sum-real = temp-mag.sum-real + tt-allsum-line.sum-dsc-rubl-acc .*/
        end. /*for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :*/
        find first buf1_trn-doc no-lock where buf1_trn-doc.doc-code = buf_trn-doc.out-code no-error .
        if available buf1_trn-doc then do:
          assign temp-mag.sum-real = temp-mag.sum-real - buf1_trn-doc.fact-rubl .
          for each buf_doc-line no-lock where buf_doc-line.doc-code = buf1_trn-doc.doc-code :
            find first temp-tov no-lock
              where temp-tov.artic     = buf_doc-line.artic
                and temp-tov.prod-code = buf_doc-line.prod-code
                and temp-tov.prod-type = buf_doc-line.prod-type
            no-error .
            if not available temp-tov then do:
              create temp-tov .
              assign
                temp-tov.artic     = buf_doc-line.artic
                temp-tov.prod-code = buf_doc-line.prod-code
                temp-tov.prod-type = buf_doc-line.prod-type
                temp-mag.num-tov   = temp-mag.num-tov + 1
              .
            end.
/*            run clcprtsl_calc-line in this-procedure (input recid (buf_doc-line)).*/
/*            find first tt-allsum-line where tt-allsum-line.sum-type = {&sum-general} no-error .*/
/*            assign temp-mag.sum-real = temp-mag.sum-real - tt-allsum-line.sum-dsc-rubl-acc .*/
          end.  /*for each buf_doc-line no-lock where buf_doc-line.doc-code = buf1_trn-doc.doc-code :*/
        end. /*if available buf1_trn-doc then do:*/
      end. /*if available buf_trn-doc then do:*/
      for each buf_inkas-pay no-lock
        where buf_inkas-pay.inkas-code = buf_inkas.inkas-code ,
        first buf_cash-pay no-lock where
              buf_cash-pay.cdpay-code = buf_inkas-pay.pay-code
          and buf_cash-pay.curr-code = buf_inkas-pay.curr-code:
        assign
        temp-mag.sum-viruch = temp-mag.sum-viruch + buf_inkas-pay.tot-rubl
        .
        if (buf_cash-pay.atr16
           or buf_cash-pay.is-card-swap
           or buf_cash-pay.is-credit-card
           or buf_cash-pay.is-debet-card)
             then do:
           assign
           temp-mag.sum-kredit = temp-mag.sum-kredit + buf_inkas-pay.tot-rubl
           .
        end. /*if (buf_cash-pay.atr16*/
      end. /*      for each buf_inkas-pay no-lock*/
    end. /*    for each buf_inkas no-lock*/
  end. /*  for each temp-mag :*/


  /* macr_excel - для экселя */
  assign
  v-file-name = v-file-prefix + ".txt"
  .
  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .


  { gbl/working.i }

  run PutColumnTitulExcel in this-procedure .

  run macr_excel_char("1. Выручка всего, {&abbr_rub}" , v-row, 1) .
  run macr_cell_format1 ( 'Arial Cyr',9, yes, yes, ?, v-row, 1, v-row, 1) .
  assign v-col = 2 .
  for each temp-mag :
    run macr_excel_sum1  ( Temp-mag.sum-viruch, v-row, v-col,  2) .
    assign v-col = v-col + 1 .
  end.
  run macr_cell_format1 ( 'Arial Cyr',10, no, no, ?, v-row, 2, v-row + 6, v-col - 1) .
  run macr_cell_BORDER  (v-row, 1, v-row + 5, v-col - 1) .
  assign v-row = v-row + 1 .

  run macr_excel_char1("   в т.ч. кредитные карты, {&abbr_rub}" , v-row, 1) .
  run macr_cell_format1 ( 'Arial Cyr',9, no, yes, ?, v-row, 1, v-row, 1) .
  assign v-col = 2 .
  for each temp-mag :
    run macr_excel_sum1  ( Temp-mag.sum-kredit, v-row, v-col,  2) .
    assign v-col = v-col + 1 .
  end.
  assign v-row = v-row + 1 .

  run macr_excel_char("2. Реализация (розница), {&abbr_rub}" , v-row, 1) .
  run macr_cell_format1 ( 'Arial Cyr',9, yes, yes, ?, v-row, 1, v-row, 1) .
  assign v-col = 2 .
  for each temp-mag :
    run macr_excel_sum1  ( Temp-mag.sum-viruch, v-row, v-col,  2) .
    assign v-col = v-col + 1 .
  end.
  assign v-row = v-row + 1 .

  run macr_excel_char1("   Наценка (розница), {&abbr_rub}" , v-row, 1) .
  run macr_cell_format1 ( 'Arial Cyr',9, no, yes, ?, v-row, 1, v-row, 1) .
  assign v-col = 2 .
  for each temp-mag :
    assign temp-mag.nazen = temp-mag.sum-viruch - Temp-mag.sum-real .   /* *********** */
    run macr_excel_sum1  ( Temp-mag.nazen, v-row, v-col,  2) .
    assign v-col = v-col + 1 .
  end.
  assign v-row = v-row + 1 .

  run macr_excel_char1("'   Кол-во чеков всего, шт'" , v-row, 1) .
  run macr_cell_format1 ( 'Arial Cyr',9, no, yes, ?, v-row, 1, v-row, 1) .
  assign v-col = 2 .
  for each temp-mag :
    run macr_excel_sum1  ( Temp-mag.num-chk, v-row, v-col,  0) .
    assign v-col = v-col + 1 .
  end.
  assign v-row = v-row + 1 .

  run macr_excel_char1("   Ассортимент, кол-во наименований" , v-row, 1) .
  run macr_cell_format1 ( 'Arial Cyr',9, no, yes, ?, v-row, 1, v-row, 1) .
  assign v-col = 2 .
  for each temp-mag :
    run macr_excel_sum1  ( Temp-mag.num-tov, v-row, v-col,  0) .
    assign v-col = v-col + 1 .
  end.
  assign v-row = v-row + 2 .

  run macr_excel_char("Главный кассир" , v-row, 1) .
  run macr_cell_format1 ( 'Arial Cyr',9, no, no, ?, v-row, 1, v-row, 1) .

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .
  run end-proc1 .

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  { gbl/stopwork.i }

  run rep/runexlmk.p (v-file-name, "Отчет по выручке" ).

end.


procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
    assign
      v-row = 1
      v-col = 1
    .
    /*run macr_excel_char ("Приложение 1", v-row, 1) .*/
    run macr_cell_format1 ( 'Tahoma', 12, yes, no, ?, 1, 1, 1, 1) .
    run macr_excel_char ("Y1", v-row, 2) . run macr_cell_ALIGN ( v-row, 2) .
    run macr_excel_char ("Y2", v-row, 3) . run macr_cell_ALIGN ( v-row, 3) .
    run macr_excel_char ("Y3", v-row, 4) . run macr_cell_ALIGN ( v-row, 4) .
    run macr_excel_char ("Y4", v-row, 5) . run macr_cell_ALIGN ( v-row, 5) .

    run macr_cell_format1 ( 'Tahoma',8, yes, no, ?, v-row, 2, v-row, 5) .
    assign  v-row = v-row + 2 .
    run macr_excel_char ("Отчет по выручке по сети магазинов", v-row, 1) .
    if p-period-type = {&period-type-yesterday} then do:
      run macr_excel_date (string(p-date1 - 01/01/1900  + 2 ), v-row, 3) .
    end.
    else do:
      run macr_excel_char ( substitute("&1-&2", string(p-date1, "99/99/9999"),string(p-date2, "99/99/9999")) , v-row, 3) .
    end.
    run macr_cell_ALIGN ( v-row, 3) .
    run macr_cell_format1 ('Arial Cyr',10, yes, no, ?, v-row, 1, v-row, 3) .      assign  v-row = v-row + 2 .

    run macr_excel_char("Магазины", v-row, 1) .
    run macr_cell_ALIGN ( v-row, 1) .
    run macr_cell_size (37,?, v-row, 1,?,?).
    assign v-col = v-col + 1 .
    for each temp-mag :
      run macr_excel_char(temp-mag.obj-name , v-row, v-col ) .
      run macr_cell_ALIGN ( v-row, v-col) .
      assign v-col = v-col + 1 .
    end.
    run macr_cell_BORDER  (v-row, 1, v-row + 6, v-col - 1) .
/*    run macr_cell_bordur ( v-row, 1, v-row + 6 , v-col - 1) .*/
    run macr_cell_format1 ( 'Arial Cyr',10, yes, no, ?, v-row, 1, v-row, v-col - 1) . /*?-35*/
/*  run macr_cell_size   (14,?, 6, 3, 6, v-col) .*/
    run macr_cell_size   (20,?, v-row, 2, v-row, v-col - 1) .
    assign  v-row = v-row + 1 .
  end.
end procedure. /* PutColumnTitulExcel */


procedure end-proc1 :
 do
 on error undo, return error return-value
 :
  v-file-name = v-file-prefix + ".t-t".
  OUTPUT to VALUE (v-file-name) .
  for each temp-param :
    export  temp-param  .
  end.

 end. /* do */
end procedure. /* end-proc */

procedure macr_cell_format1 :
 do
 on error undo, return error return-value
 :
 define input parameter  p-name   as character no-undo .
 define input parameter  p-size   as integer   no-undo .
 define input parameter  p-bold   as logical   no-undo .
 define input parameter  p-italic as logical   no-undo .
 define input parameter  p-color  as integer   no-undo .
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .

  if p-size = ? then p-size = 10 .
  if p-bold = ? then p-bold = false .
  if p-italic = ? then p-italic = false .
  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .

  if p-color <> ? then do:
     put  stream macr_excel unformatted
       substitute('patterns(1,,&1,true)', p-color )  skip  .
  end.
  put  stream macr_excel unformatted
       substitute('format.font("&1",&2,&3,&4)', p-name, p-size,
                                        string ( p-bold  , "true/false" ) ,
                                        string ( p-italic , "true/false" )
                                        ) skip .
 end. /* do */
end procedure. /* macr_pattern */


procedure macr_cell_ALIGN :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .

  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row , p-col ) skip .

  put  stream macr_excel unformatted
       'ALIGNMENT( 3, , 2, ,)'   skip
       .
/*       'ALIGNMENT(3 , , 4 , 4 ,)'   skip*/
 end. /* do */
end procedure. /* macr_pattern */


procedure macr_cell_BORDER :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .
 define input parameter  p-row-2  as integer   no-undo .
 define input parameter  p-col-2  as integer   no-undo .

  if p-row-2 = ? then p-row-2 = p-row .
  if p-col-2 = ? then p-col-2 = p-col .
  put  stream macr_excel unformatted
   substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .

  put  stream macr_excel unformatted
       'BORDER( 1 , 1 , 1 , 1 , 1 , ,0,0,0,0,0) '  skip
       .
 end. /* do */
end procedure. /* macr_cell_bordur */


procedure macr_excel_char1 :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .

      put  stream macr_excel unformatted
        substitute('formula("&3","r&1c&2")', p-row , p-col , p-val ) skip  .

 end. /* do */
end procedure. /* macr_exel_char */


procedure macr_excel_sum1 :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as decimal   no-undo .
 define input parameter  p-row as integer   no-undo .
 define input parameter  p-col as integer   no-undo .
 define input parameter  p-typ as integer   no-undo .

 if p-val = ? then assign p-val = 0 .
 define variable ss as character no-undo .
 if p-typ = 0 then assign ss = string( Round( p-val, 0), ">>>,>>>,>>>,>>>,>>>,>>>,>>>" ) .
 else              assign ss = string( Round( p-val, 2), ">>>,>>>,>>>,>>>,>>>,>>>,>>>.99" ) .

  define variable iPos as integer   no-undo .
  DO ii = 1 TO NUM-ENTRIES(TRIM(ss), ",") - 1  :
    assign iPos = INDEX( ss, ",") .
    IF iPos > 0 THEN SUBSTRing( ss, iPos, 1 ) = ' '.
  END.
  put stream macr_excel unformatted substitute('select("r&1c&2")', p-row , p-col ) + {&new-line} .
  if p-typ = 0 then put stream macr_excel unformatted 'format.number("#,##0")' + {&new-line} .
  else              put stream macr_excel unformatted 'format.number("#,##0.00")' + {&new-line} .
  put stream macr_excel unformatted substitute('formula(" &3","r&1c&2")', p-row , p-col , ss ) skip  .
 end. /* do */
END procedure.

procedure cb_set-shops :
define input parameter p-shop-code as integer no-undo .
define buffer buf_clients for ub.clients.
do
on error undo, return error
:
  find first buf_clients no-lock where
            buf_clients.obj-type = {&shop}
        and buf_clients.obj-code = p-shop-code no-error.
  if available buf_clients
  and buf_clients.stts <> integer({&current-status-int}) then next.
  find first temp-mag where
            temp-mag.obj-type = {&shop}
          and temp-mag.obj-code = p-shop-code no-error .
  if not available temp-mag then do:
    create temp-mag .
    assign
    temp-mag.obj-code   = p-shop-code
    temp-mag.obj-type   = {&shop}
    temp-mag.obj-name   = (if available buf_clients
                            then buf_clients.obj-name
                            else ({&shop} + string(p-shop-code)))
    temp-mag.sum-viruch = 0
    temp-mag.sum-kredit = 0
    temp-mag.sum-real   = 0
    temp-mag.nazen      = 0
    temp-mag.num-chk    = 0
    temp-mag.num-tov    = 0
    .
    release temp-mag.
   end.
end.

end procedure. /* cb_set-shops */