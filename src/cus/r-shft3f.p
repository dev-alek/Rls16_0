block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-shft3f.p $
$Archive: cus/r-shft3f.p $

Расшифровка реализации к сменному отчету

Автор: Уханов Дмитрий Юрьевич
Дата создания: 01/28/09
Author: Dmitry Ukhanov
Creation date: 01/28/09

Author1: Michael Kochetkov
Creation date1: 10/10/07

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-shft3f.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-shft3f.p $":U .
define variable vss-description as character no-undo init "Расшифровка реализации к сменному отчету".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ gbl/getsect.i def }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get " " my-handle }
{ str/lib-trn.i  }
{ gbl/thbjattr.i }

define variable parparentproc     as widget-handle no-undo.
assign parparentproc =  my-handle .
define variable g#report-num as integer no-undo .
run get-report-num  in parparentproc (output  g#report-num).

{ gbl/paramls.i    }
{ cus/shift3xl.i   }
{ ref/cp-attr.i interface parparentproc  }
{ rep/r-pychk0.i defalgo }

DEFINE stream out-stream .


FUNCTION get-grp-name RETURNS integer
  ( INPUT p-cdpay-code AS integer, INPUT p-curr-code AS INTEGER ) :

   DEFINE VARIABLE v-dopi  as integer   no-undo .
   DEFINE VARIABLE v-value AS character NO-UNDO.
   DEFINE VARIABLE v-type  AS character NO-UNDO.
     RUN cp-attr-value  IN THIS-PROCEDURE(
       input p-cdpay-code
       ,input p-curr-code
       ,input 0 /*p-host-code    */
       ,input '':U /*p-obj-type     */
       ,input 0 /* p-obj-code     */
       ,INPUT {&cp-attr-grp-code}
       ,output v-value
       ,OUTPUT v-type) NO-ERROR.

  IF NOT ERROR-STATUS:ERROR THEN DO:
    ASSIGN
      v-dopi = INTEGER(entry(2, v-value, {&delim-par}))
/*      p-grp-name = entry(1, v-value, {&delim-par} )*/
    NO-ERROR.
  END.
  RETURN v-dopi.
END FUNCTION.



/*define temp-table temp-shift-obj no-undo*/
/*  FIELD v-shift-num      as integer*/
/*  FIELD v-shift-date     as date*/
/*  FIELD v-shift-name     as character*/
/*  FIELD v-shift-name-num as character*/
/*  FIELD v-count          as integer*/
/*  FIELD v-sum            as decimal*/
/*  FIELD v-sum-ret        as decimal*/
/*  INDEX ii IS UNIQUE v-count*/
/*  INDEX ii1 IS UNIQUE  v-shift-num v-shift-date*/
/*.*/

define temp-table temp-gds no-undo
  FIELD artic     as character
  FIELD prod-type as character
  FIELD prod-code as integer
  FIELD gds-code  as integer
  FIELD b-code    as integer
  FIELD num       as integer
  INDEX ii IS UNIQUE num
  INDEX ii1 IS UNIQUE  artic   prod-type  prod-code
  INDEX ii2 b-code
  INDEX ii3 gds-code
.

define temp-table temp-sale no-undo
  FIELD val1     as decimal
  FIELD sum1     as decimal
  FIELD val2     as decimal
  FIELD sum2     as decimal
  FIELD val3     as decimal
  FIELD sum3     as decimal
  FIELD val4     as decimal
  FIELD sum4     as decimal
  FIELD val5     as decimal
  FIELD sum5     as decimal
  FIELD val6     as decimal
  FIELD sum6     as decimal
  FIELD val-all  as decimal
  FIELD sum-all  as decimal
  FIELD name     as character
  FIELD code     as integer
  FIELD grp      as integer
  FIELD is-nal   as logical
  INDEX ii IS UNIQUE code
  INDEX ii1  grp
.

define temp-table temp-grp no-undo
  FIELD val1     as decimal
  FIELD sum1     as decimal
  FIELD val2     as decimal
  FIELD sum2     as decimal
  FIELD val3     as decimal
  FIELD sum3     as decimal
  FIELD val4     as decimal
  FIELD sum4     as decimal
  FIELD val5     as decimal
  FIELD sum5     as decimal
  FIELD val6     as decimal
  FIELD sum6     as decimal
  FIELD val-all  as decimal
  FIELD sum-all  as decimal
  FIELD name     as character
  FIELD code     as integer
  FIELD num      as integer
  INDEX ii IS UNIQUE num
  INDEX ii1  code
  INDEX ii2  name
.

define variable v-itog-bn   as decimal extent 14 no-undo .
define variable v-itog-sale as decimal extent 14 no-undo .
define variable v-teh       as decimal extent 14 no-undo .
define variable v-counter   as decimal extent 14 no-undo .
define variable v-b-code    as integer no-undo .

  define variable Counter1    as integer   no-undo .

  define variable v-ind      as integer   no-undo .
  define variable v-str      as character no-undo .
  define variable v-is-petrol as logical   no-undo .
  define variable v-is-pieces as logical   no-undo .

  define buffer buf_prod-bc  for ub.prod-bc .
  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_goods    for ub.goods .
  define buffer buf1_shift-obj for ub.shift-obj .
  define buffer buf2_shift-obj for ub.shift-obj .

  assign  Counter1 = 0 .
  { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 1 } /* Показать окно информации о текущем процессе */

  find first obj-list .

  find first buf1_shift-obj no-lock
    where buf1_shift-obj.obj-type    = obj-list.obj-type
      and buf1_shift-obj.obj-code    = obj-list.obj-code
      and buf1_shift-obj.shift-date  = x-Date-Start
      and buf1_shift-obj.shift-num   = x-Shift-Start
  no-error .
  if not available buf1_shift-obj then do:
    message "Не найдена смена начала отчета." skip "Дата:" string( x-Date-Start, "99/99/9999":U ) skip  "Порядок:" x-Shift-Start view-as alert-box error .
    return  .
  end.
  find first buf2_shift-obj no-lock
    where buf2_shift-obj.obj-type    = obj-list.obj-type
      and buf2_shift-obj.obj-code    = obj-list.obj-code
      and buf2_shift-obj.shift-date  = x-Date-End
      and buf2_shift-obj.shift-num   = x-Shift-End
  no-error .
  if not available buf2_shift-obj then do:
    message "Не найдена смена окончания отчета." skip "Дата:" string( x-Date-End, "99/99/9999":U ) skip  "Порядок:" x-Shift-End view-as alert-box error .
    return .
  end.

  define variable v-sort-list as character no-undo .
{ gbl/getsect.i run '' 0 {&attr-report-glob} no-error}
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'rep-sort'  then v-sort-list  = thbjattr_thbj-attr.property-value-character .
  end.
if error-status:error or v-sort-list = "":U then do:
  define variable v-tooltip as character no-undo .
  define variable v-label as character no-undo .
  define variable v-tooltip-code as character no-undo .
  run thbjattr_tooltip in this-procedure (
                                            input  {&attr-report-glob}
                                           ,input  {&attr-report-glob_rep-sort}
                                           ,output v-tooltip
                                           ,output v-label
                                           ,output v-tooltip-code ) no-error.
  if error-status:error then do:
    assign
    v-tooltip-code = {&attr-report-glob_rep-sort}
    v-tooltip = {&attr-report-glob}
    .
  end.
  message
  substitute("Не найден или незаполнен параметр <&1>&2Секция <&3>"
            , v-tooltip-code
            , {&new-line}
            ,v-tooltip)
  view-as alert-box error .
  return .
end.
  _sort-cycle:
  do v-ind = 1 to NUM-ENTRIES(v-sort-list) :  /* формируем список товаров для отчета */
    assign v-str = entry( v-ind, v-sort-list ) .

    _gds-cycle:
    for each buf_goods no-lock
    where buf_goods.gds-code = integer(v-str)
    :
      { str/is-petrl.i
              buf_goods.artic
              buf_goods.prod-type
              buf_goods.prod-code
              v-is-petrol
              v-is-pieces
      }
      if v-is-petrol  = yes
      and v-is-pieces = no
      then do:
        /* для топлива по идее код один */
      { gbl/gdsbcode.i buf_goods.gds-code ? v-b-code }
        find first temp-gds where temp-gds.gds-code = buf_goods.gds-code no-error .
        if not available temp-gds then do:
          create temp-gds .
          assign
            temp-gds.artic     = buf_goods.artic
            temp-gds.prod-type = buf_goods.prod-type
            temp-gds.prod-code = buf_goods.prod-code
            temp-gds.gds-code  = buf_goods.gds-code
          temp-gds.b-code    = v-b-code
            temp-gds.num       = v-ind
          .
          next _gds-cycle.
        end.
      end.
    end.
  end.

  find first temp-gds no-error .
  if not available temp-gds then do:
    message "Нет товаров для отчета." view-as alert-box error .
    return .
  end.

define variable cpgrpnam as character no-undo .
define variable v-dops as character no-undo.
define variable v-dopi as integer no-undo.
define variable ii as integer no-undo.
define variable nn as integer   no-undo .

  /*найдем настройку*/
{ gbl/getsect.i run '' 0 {&attr-cashpays} no-error }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = {&attr-cashpays_cpgrpnam}  then cpgrpnam  = thbjattr_thbj-attr.property-value-character .
  end.


  assign  nn = 1 .
  DO ii = 1 TO NUM-ENTRIES(cpgrpnam) by 2:
    ASSIGN
      v-dops = ENTRY(ii, cpgrpnam)
      v-dopi = integer(ENTRY(ii + 1, cpgrpnam))
    NO-ERROR.
    IF ERROR-STATUS:ERROR or v-dopi = 0 or v-dopi >= 10000 THEN DO:
      run thbjattr_tooltip in this-procedure (
                                               input {&attr-cashpays}
                                              ,input  {&attr-cashpays_cpgrpnam}
                                              ,output v-tooltip
                                              ,output v-label
                                              ,output v-tooltip-code ) no-error.
      if error-status:error then do:
        assign
        v-tooltip-code = {&attr-cashpays_cpgrpnam}
        v-tooltip = {&attr-cashpays}
        .
      end.
      MESSAGE
      substitute("Неверное значение параметра <&1>&2Секция <&3>&2" +
                 "четные элементы списка должны быть положительными целыми числами < 10000"
                , v-tooltip-code
                , {&new-line}
                ,v-tooltip)
      VIEW-AS ALERT-BOX ERROR.
      RETURN .
    END.
    create temp-grp .
    ASSIGN
      temp-grp.name = v-dops
      temp-grp.code = v-dopi
      temp-grp.num  = nn
      nn            = nn + 1
    .
  END.

  define buffer buf_chk-gds-pay for ub.chk-gds-pay .
  define buffer buf_cash-pay for ub.cash-pay .
  /*НАДО УБЕДИТЬСЯ ЧТО ВСЕ РАЗМАЗАНО!!*/
  run rep/rpychk0.p ( input "r-shft3f"
                     ,input obj-list.obj-type
                     ,input obj-list.obj-code
                     ,input ? /*p-date-from*/
                     ,input ? /*p-date-to*/
                     ,input X-date-start /*p-shift-date-from*/
                     ,input X-date-end /*p-shift-date-to*/
                     ,input X-shift-start /*X-shift-start*/
                     ,input X-shift-end /*X-shift-end*/
                     ,input ? /*p-inkas-code*/
                     ).
  for each temp-gds :
    for each buf_chk-gds-pay no-lock
      where buf_chk-gds-pay.b-code      = temp-gds.b-code
        and buf_chk-gds-pay.obj-type    = obj-list.obj-type
        and buf_chk-gds-pay.obj-code    = obj-list.obj-code
        and buf_chk-gds-pay.shift-date >= X-date-start
        and buf_chk-gds-pay.shift-date <= X-date-end
    :
      if buf_chk-gds-pay.algo-num <> {&current-algo-1} then next.
      if buf_chk-gds-pay.shift-date = X-date-start  and buf_chk-gds-pay.shift-num < X-Shift-Start  then next .
      if buf_chk-gds-pay.shift-date = X-date-end and buf_chk-gds-pay.shift-num > X-Shift-end then next .
      find first temp-sale where temp-sale.code = buf_chk-gds-pay.pay-code no-error .
      if not available temp-sale then do:
        find first buf_cash-pay no-lock where buf_cash-pay.cdpay-code = buf_chk-gds-pay.pay-code and buf_cash-pay.curr-code = buf_chk-gds-pay.curr-code .
        create temp-sale .
        assign
          temp-sale.name   = buf_cash-pay.obj-name
          temp-sale.code   = buf_cash-pay.cdpay-code
          temp-sale.is-nal = buf_cash-pay.is-cash
        .
        temp-sale.grp  = get-grp-name(input buf_cash-pay.cdpay-code, buf_cash-pay.curr-code) .
      end.
      case temp-gds.num :
        when 1 then do:
          assign
            temp-sale.val1 = temp-sale.val1 + buf_chk-gds-pay.eff-doc-qnty
            temp-sale.sum1 = temp-sale.sum1 + buf_chk-gds-pay.tot-r-b
          .
        end.
        when 2 then do:
          assign
            temp-sale.val2 = temp-sale.val2 + buf_chk-gds-pay.eff-doc-qnty
            temp-sale.sum2 = temp-sale.sum2 + buf_chk-gds-pay.tot-r-b
          .
        end.
        when 3 then do:
          assign
            temp-sale.val3 = temp-sale.val3 + buf_chk-gds-pay.eff-doc-qnty
            temp-sale.sum3 = temp-sale.sum3 + buf_chk-gds-pay.tot-r-b
          .
        end.
        when 4 then do:
          assign
            temp-sale.val4 = temp-sale.val4 + buf_chk-gds-pay.eff-doc-qnty
            temp-sale.sum4 = temp-sale.sum4 + buf_chk-gds-pay.tot-r-b
          .
        end.
        when 5 then do:
          assign
            temp-sale.val5 = temp-sale.val5 + buf_chk-gds-pay.eff-doc-qnty
            temp-sale.sum5 = temp-sale.sum5 + buf_chk-gds-pay.tot-r-b
          .
        end.
        when 6 then do:
          assign
            temp-sale.val6 = temp-sale.val6 + buf_chk-gds-pay.eff-doc-qnty
            temp-sale.sum6 = temp-sale.sum6 + buf_chk-gds-pay.tot-r-b
          .
        end.
      end.
      assign
        temp-sale.val-all = temp-sale.val5 + buf_chk-gds-pay.eff-doc-qnty
        temp-sale.sum-all = temp-sale.sum5 + buf_chk-gds-pay.tot-r-b
      .
    end.
  end.

  { cmp/open-out.i stream out-stream " " {&CS_PS} }

  run shift3xl-init in this-procedure.

  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-h_Obj}, input "Объект: " + obj-list.obj-name ).

  define variable p-str as character no-undo .
  if x-Date-Start = x-Date-End and x-Shift-Start = x-Shift-End then do:  /* одна смена */
    assign
      p-str =   "Смена:" + string (buf1_shift-obj.shift-name) + " от "
              + string( buf1_shift-obj.open-date , "99/99/9999" ) + ' '
              + string( buf1_shift-obj.open-time , "hh:mm" ) + ' '
              + "смена закрыта: " + string( buf1_shift-obj.close-date , "99/99/9999" )
              + " " +  string( buf1_shift-obj.close-time , "hh:mm" )
    .
  end.
  else do:
    assign
      p-str =   "Смены с: " + string(buf1_shift-obj.shift-name)
              + " от " + string( buf1_shift-obj.open-date , "99/99/9999" ) + ' '
              + string ( buf1_shift-obj.open-time , "hh:mm" )
    .
    assign
      p-str =   p-str + ' '
              + "по: " + string(buf2_shift-obj.shift-name)
              + " от " + string( buf2_shift-obj.open-date , "99/99/9999" ) + ' '
              + string( buf2_shift-obj.open-time , "hh:mm" )
              + " закрыта " + string( buf2_shift-obj.close-date,"99/99/9999") + " "
              + string(buf2_shift-obj.close-time,"hh:mm")
    .
  end.
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-h_Date}, input p-str ).

  for each temp-grp :
    run shift3xl-sheet1-write-line-data ( temp-grp.name,
                                          "",    "",
                                          "",    "",
                                          "",    "",
                                          "",    "",
                                          "",    "",
                                          "",    "",
                                          "",    "").
/*    for each temp-sale where temp-sale.grp = temp-grp.code :*/
    for each temp-sale where temp-sale.grp = temp-grp.code :
      run shift3xl-sheet1-write-line-data ( "Итого " + temp-grp.name,
                                            string(temp-sale.val1),    string(temp-sale.sum1),
                                            string(temp-sale.val2),    string(temp-sale.sum2),
                                            string(temp-sale.val3),    string(temp-sale.sum3),
                                            string(temp-sale.val4),    string(temp-sale.sum4),
                                            string(temp-sale.val5),    string(temp-sale.sum5),
                                            string(temp-sale.val6),    string(temp-sale.sum6),
                                            string(temp-sale.val-all), string(temp-sale.sum-all)).
      assign
        temp-grp.val1    = temp-grp.val1    + temp-sale.val1
        temp-grp.val2    = temp-grp.val2    + temp-sale.val2
        temp-grp.val3    = temp-grp.val3    + temp-sale.val3
        temp-grp.val4    = temp-grp.val4    + temp-sale.val4
        temp-grp.val5    = temp-grp.val5    + temp-sale.val5
        temp-grp.val6    = temp-grp.val6    + temp-sale.val6
        temp-grp.val-all = temp-grp.val-all + temp-sale.val-all
        temp-grp.sum1    = temp-grp.sum1    + temp-sale.sum1
        temp-grp.sum2    = temp-grp.sum2    + temp-sale.sum2
        temp-grp.sum3    = temp-grp.sum3    + temp-sale.sum3
        temp-grp.sum4    = temp-grp.sum4    + temp-sale.sum4
        temp-grp.sum5    = temp-grp.sum5    + temp-sale.sum5
        temp-grp.sum6    = temp-grp.sum6    + temp-sale.sum6
        temp-grp.sum-all = temp-grp.sum-all + temp-sale.sum-all
      .
      if temp-sale.is-nal = no then do:
        assign
          v-itog-bn [1]  = v-itog-bn [1]  + temp-sale.val1
          v-itog-bn [2]  = v-itog-bn [2]  + temp-sale.sum1
          v-itog-bn [3]  = v-itog-bn [3]  + temp-sale.val2
          v-itog-bn [4]  = v-itog-bn [4]  + temp-sale.sum2
          v-itog-bn [5]  = v-itog-bn [5]  + temp-sale.val3
          v-itog-bn [6]  = v-itog-bn [6]  + temp-sale.sum3
          v-itog-bn [7]  = v-itog-bn [7]  + temp-sale.val4
          v-itog-bn [8]  = v-itog-bn [8]  + temp-sale.sum4
          v-itog-bn [9]  = v-itog-bn [9]  + temp-sale.val5
          v-itog-bn [10] = v-itog-bn [10] + temp-sale.sum5
          v-itog-bn [11] = v-itog-bn [11] + temp-sale.val6
          v-itog-bn [12] = v-itog-bn [12] + temp-sale.sum6
          v-itog-bn [13] = v-itog-bn [13] + temp-sale.val-all
          v-itog-bn [14] = v-itog-bn [14] + temp-sale.sum-all
        .
      end.
    end.
    run shift3xl-sheet1-write-line-data ( "Итого " + temp-grp.name,
                                          string(temp-grp.val1),    string(temp-grp.sum1),
                                          string(temp-grp.val2),    string(temp-grp.sum2),
                                          string(temp-grp.val3),    string(temp-grp.sum3),
                                          string(temp-grp.val4),    string(temp-grp.sum4),
                                          string(temp-grp.val5),    string(temp-grp.sum5),
                                          string(temp-grp.val6),    string(temp-grp.sum6),
                                          string(temp-grp.val-all), string(temp-grp.sum-all)).
    assign
      v-itog-sale [1]  = v-itog-sale [1]  + temp-grp.val1
      v-itog-sale [2]  = v-itog-sale [2]  + temp-grp.sum1
      v-itog-sale [3]  = v-itog-sale [3]  + temp-grp.val2
      v-itog-sale [4]  = v-itog-sale [4]  + temp-grp.sum2
      v-itog-sale [5]  = v-itog-sale [5]  + temp-grp.val3
      v-itog-sale [6]  = v-itog-sale [6]  + temp-grp.sum3
      v-itog-sale [7]  = v-itog-sale [7]  + temp-grp.val4
      v-itog-sale [8]  = v-itog-sale [8]  + temp-grp.sum4
      v-itog-sale [9]  = v-itog-sale [9]  + temp-grp.val5
      v-itog-sale [10] = v-itog-sale [10] + temp-grp.sum5
      v-itog-sale [11] = v-itog-sale [11] + temp-grp.val6
      v-itog-sale [12] = v-itog-sale [12] + temp-grp.sum6
      v-itog-sale [13] = v-itog-sale [13] + temp-grp.val-all
      v-itog-sale [14] = v-itog-sale [14] + temp-grp.sum-all
    .
  end.
  run shift3xl-sheet1-write-line-data ( "Итого безнал:" ,
                                          string(v-itog-bn [1] ),
                                          string(v-itog-bn [2] ),
                                          string(v-itog-bn [3] ),
                                          string(v-itog-bn [4] ),
                                          string(v-itog-bn [5] ),
                                          string(v-itog-bn [6] ),
                                          string(v-itog-bn [7] ),
                                          string(v-itog-bn [8] ),
                                          string(v-itog-bn [9] ),
                                          string(v-itog-bn [10]),
                                          string(v-itog-bn [11]),
                                          string(v-itog-bn [12]),
                                          string(v-itog-bn [13]),
                                          string(v-itog-bn [14])
                                          ).
  run shift3xl-sheet1-write-line-data ( "Итого реализация:" ,
                                          string(v-itog-sale [1] ),
                                          string(v-itog-sale [2] ),
                                          string(v-itog-sale [3] ),
                                          string(v-itog-sale [4] ),
                                          string(v-itog-sale [5] ),
                                          string(v-itog-sale [6] ),
                                          string(v-itog-sale [7] ),
                                          string(v-itog-sale [8] ),
                                          string(v-itog-sale [9] ),
                                          string(v-itog-sale [10]),
                                          string(v-itog-sale [11]),
                                          string(v-itog-sale [12]),
                                          string(v-itog-sale [13]),
                                          string(v-itog-sale [14])
                                          ).


  run Calc-Itog-Teh in this-procedure .
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_teh1}, input string( v-teh [ 1 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_teh2}, input string( v-teh [ 2 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_teh3}, input string( v-teh [ 3 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_teh4}, input string( v-teh [ 4 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_teh5}, input string( v-teh [ 5 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_teh6}, input string( v-teh [ 6 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_teh7}, input string( v-teh [ 1 ] +  v-teh [ 2 ] + v-teh [ 3 ] + v-teh [ 4 ] + v-teh [ 5 ] + v-teh [ 6 ]) ).

  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_fteh1}, input string( v-itog-sale [1] + v-teh [ 1 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_fteh2}, input string( v-itog-sale [3] + v-teh [ 2 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_fteh3}, input string( v-itog-sale [5] + v-teh [ 3 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_fteh4}, input string( v-itog-sale [7] + v-teh [ 4 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_fteh5}, input string( v-itog-sale [9] + v-teh [ 5 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_fteh6}, input string( v-itog-sale [11] + v-teh [ 6 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_fteh7}, input string( v-itog-sale [13] + v-teh [ 1 ] +  v-teh [ 2 ] + v-teh [ 3 ] + v-teh [ 4 ] + v-teh [ 5 ] + v-teh [ 6 ]) ).

  run Calc-Itog-Counter in this-procedure .
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_count1}, input string( v-counter [ 1 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_count2}, input string( v-counter [ 2 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_count3}, input string( v-counter [ 3 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_count4}, input string( v-counter [ 4 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_count5}, input string( v-counter [ 5 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_count6}, input string( v-counter [ 6 ] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_count7}, input string( v-counter [ 1 ] +  v-counter [ 2 ] + v-counter [ 3 ] + v-counter [ 4 ] + v-counter [ 5 ] + v-counter [ 6 ]) ).

  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_itog1}, input string( v-itog-sale [1] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_itog2}, input string( v-itog-sale [3] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_itog3}, input string( v-itog-sale [5] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_itog4}, input string( v-itog-sale [7] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_itog5}, input string( v-itog-sale [9] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_itog6}, input string( v-itog-sale [11] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_itog7}, input string( v-itog-sale [13] ) ).

  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_delta1}, input string( v-counter [ 1 ] - v-itog-sale [1] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_delta2}, input string( v-counter [ 2 ] - v-itog-sale [3] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_delta3}, input string( v-counter [ 3 ] - v-itog-sale [5] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_delta4}, input string( v-counter [ 4 ] - v-itog-sale [7] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_delta5}, input string( v-counter [ 5 ] - v-itog-sale [9] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_delta6}, input string( v-counter [ 6 ] - v-itog-sale [11] ) ).
  run shift3xl-write-cell-data in this-procedure ( input {&shift3xl-f_delta7}, input string( v-counter [ 1 ]  +  v-counter [ 2 ] + v-counter [ 3 ] + v-counter [ 4 ] + v-counter [ 5 ] + v-counter [ 6 ] - v-itog-sale [13] ) ).

  put STREAM out-stream   "ИТОГО" .
  output stream out-stream close.

  run shift3xl-close in this-procedure .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
  os-rename
    value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
    value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
  .
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .

  run gbl/prnfilen.w
      (input  ""
      ,input  20
      ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      ,input  ReportFontNum
      ,output v-user-action
      ,output v-printed
      ) .
  os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .



/* *********************************************************************************** */

/* *********************************************************************************** */
define temp-table temp-rvs-line no-undo like ub.rvs-line
  FIELD gds-name as character
  FIELD place_loc1 as character
  FIELD shift-date like ub.rvs-doc.shift-date
  FIELD shift-num  like ub.rvs-doc.shift-num
  FIELD v-bar-code like ub.bar-code.b-code
  FIELD artic      like ub.goods.artic
  FIELD prod-type  like ub.goods.prod-type
  FIELD prod-code  like ub.goods.prod-code
.

procedure Calc-Itog-Counter :
  do on error undo, return error return-value :

/*define variable v-count    as integer   no-undo .*/
/*define variable v-count2   as integer   no-undo .*/
/*define variable v-tot-cnt  as integer   no-undo .*/

  define buffer buf_rvs-line-pump for ub.rvs-line-pump .
  define buffer buf_temp-rvs-line for temp-rvs-line .

define buffer previous-rvs-doc for ub.rvs-doc.
define buffer previous-rvs-line for ub.rvs-line.
define buffer previous-rvs-line-pump for ub.rvs-line-pump.
define buffer last-rvs-doc for ub.rvs-doc.
define buffer last-rvs-line for ub.rvs-line.
define buffer last-rvs-line-pump for ub.rvs-line-pump.
define buffer previous-shift-obj for ub.shift-obj.
define buffer control-rvs-doc for ub.rvs-doc.
define buffer control-rvs-line-pump for ub.rvs-line-pump.

define variable pol5 as decimal   no-undo .
define variable pol6 as decimal   no-undo .

/* сверка данной смены*/
FIND FIRST last-rvs-doc No-LOCK WHERE
           last-rvs-doc.obj-type   = obj-list.obj-type AND
           last-rvs-doc.obj-code   = obj-list.obj-code AND
           last-rvs-doc.shift-date = x-date-End AND
           last-rvs-doc.shift-num  = x-shift-end AND
           last-rvs-doc.status_    = {&fact} AND
           last-rvs-doc.rvs-type   = {&rvs-shift} NO-ERROR.
if not avail last-rvs-doc then do:
  message vss-workfile vss-revision vss-description skip
          "Не найдена сверка типа СМН "
          "объект" obj-list.obj-type obj-list.obj-code
          "смена" x-date-End x-shift-end
  view-as alert-box ERROR.
  return error.
END.
/*нам надо еще знать сверку за предыдущую смену*/
/*предыдущая смена по объекту найдена в r-shftfo.i previous-shift-obj*/
find last previous-shift-obj no-lock where
          previous-shift-obj.obj-type   = obj-list.obj-type  and
          previous-shift-obj.obj-code   = obj-list.obj-code  and
      ( ( previous-shift-obj.shift-date = x-date-Start   and
          previous-shift-obj.shift-num  < x-shift-Start  ) or
          previous-shift-obj.shift-date < x-date-Start ) use-index pi no-error .
if available previous-shift-obj then do:
  FIND FIRST previous-rvs-doc No-LOCK WHERE
            previous-rvs-doc.obj-type   = obj-list.obj-type AND
            previous-rvs-doc.obj-code   = obj-list.obj-code AND
            previous-rvs-doc.shift-date = previous-shift-obj.shift-date AND
            previous-rvs-doc.shift-num  = previous-shift-obj.shift-num AND
            previous-rvs-doc.status_    = {&fact} AND
            previous-rvs-doc.rvs-type   = {&rvs-shift} NO-ERROR.
end.


  for each ub.rvs-doc No-LOCK WHERE
           ub.rvs-doc.obj-type   = obj-list.obj-type AND
           ub.rvs-doc.obj-code   = obj-list.obj-code AND
           ub.rvs-doc.shift-date >= x-date-Start AND
           ub.rvs-doc.shift-date <= x-date-End AND
           ub.rvs-doc.status_    = {&fact} AND
           ub.rvs-doc.rvs-type   = {&rvs-shift} :
    if ub.rvs-doc.shift-date = x-date-Start and ub.rvs-doc.shift-num < x-Shift-Start then next .
    if ub.rvs-doc.shift-date = x-date-End   and ub.rvs-doc.shift-num > x-Shift-End then next .

    for each ub.rvs-line No-LOCK WHERE ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code :
      find first temp-gds where temp-gds.gds-code = ub.rvs-line.gds-code no-error .
      if not available temp-gds then next .

      find first temp-rvs-line where temp-rvs-line.pl-code  = ub.rvs-line.pl-code and temp-rvs-line.gds-code = ub.rvs-line.gds-code no-error .
      if not available temp-rvs-line then do:
        create temp-rvs-line .
        BUFFER-COPY ub.rvs-line to temp-rvs-line .
        assign
          temp-rvs-line.artic      = temp-gds.artic
          temp-rvs-line.prod-type  = temp-gds.prod-type
          temp-rvs-line.prod-code  = temp-gds.prod-code
          temp-rvs-line.shift-date = ub.rvs-doc.shift-date
          temp-rvs-line.shift-num  = ub.rvs-doc.shift-num
          temp-rvs-line.v-bar-code = temp-gds.b-code
        .
      end.
      else do:
        if temp-rvs-line.shift-date < ub.rvs-doc.shift-date or temp-rvs-line.shift-date = ub.rvs-doc.shift-date and temp-rvs-line.shift-num  < ub.rvs-doc.shift-num then
          BUFFER-COPY ub.rvs-line to temp-rvs-line .
      end.
    end.
  end.

  for each temp-rvs-line  break by temp-rvs-line.gds-code by temp-rvs-line.pl-code on error undo, return error return-value :
    if first-of(temp-rvs-line.gds-code) then do:
      assign
        pol5 = 0
        pol6 = 0
      .
    end.

    if avail previous-rvs-doc then
      Find first previous-rvs-line  No-LOCK WHERE
              previous-rvs-line.rvs-code = previous-rvs-doc.rvs-code and
              previous-rvs-line.gds-code = temp-rvs-line.gds-code  and
              previous-rvs-line.obj-code = temp-rvs-line.obj-code  and
              previous-rvs-line.obj-type = temp-rvs-line.obj-type  and
              previous-rvs-line.pl-code  = temp-rvs-line.pl-code
              no-error .

    FOR EACH buf_rvs-line-pump No-LOCK WHERE
       buf_rvs-line-pump.rvs-code = temp-rvs-line.rvs-code  and
       buf_rvs-line-pump.gds-code = temp-rvs-line.gds-code  and
       buf_rvs-line-pump.obj-code = temp-rvs-line.obj-code  and
       buf_rvs-line-pump.obj-type = temp-rvs-line.obj-type  and
       buf_rvs-line-pump.pl-code  = temp-rvs-line.pl-code
      BREAK BY buf_rvs-line-pump.pump-code BY buf_rvs-line-pump.nozzle-code:
      /*по одной ТРК надо собрать по всем пистолетам*/
      assign
        pol5 = pol5 + buf_rvs-line-pump.state-mh-cnt
      .
      /*найдем показания счетного механизма по пистолету в сменной сверке за пред. смену*/
      if avail previous-rvs-doc then do:
        Find FIRST previous-rvs-line-pump  No-LOCK WHERE
            previous-rvs-line-pump.rvs-code = previous-rvs-doc.rvs-code AND
            previous-rvs-line-pump.gds-code = temp-rvs-line.gds-code  and
            previous-rvs-line-pump.obj-code = temp-rvs-line.obj-code  and
            previous-rvs-line-pump.obj-type = temp-rvs-line.obj-type  and
            previous-rvs-line-pump.pl-code  = temp-rvs-line.pl-code AND
            previous-rvs-line-pump.pump-code = buf_rvs-line-pump.pump-code AND
            previous-rvs-line-pump.nozzle-code = buf_rvs-line-pump.nozzle-code No-ERROR.
        IF AVAIL previous-rvs-line-pump then do:
          assign pol6 = pol6 + previous-rvs-line-pump.state-mh-cnt .
        end.
      end.
      if not avail previous-rvs-doc or not avail previous-rvs-line-pump then do:
        /*должны найти первую контрольную сверку по текущей смене,  в которой есть эта ТРК, бензин, и пистолет и взять оттуда*/
        FOR EACH control-rvs-doc NO-LOCK WHERE
            control-rvs-doc.obj-type   = obj-list.obj-type AND
            control-rvs-doc.obj-code   = obj-list.obj-code AND
            control-rvs-doc.shift-date = x-date-Start AND
            control-rvs-doc.shift-num  = x-shift-Start AND
            control-rvs-doc.status_    = {&fact} AND
            control-rvs-doc.rvs-type   = {&rvs-control},
        FIRST control-rvs-line-pump No-LOCK WHERE
          control-rvs-line-pump.rvs-code = control-rvs-doc.rvs-code AND
          control-rvs-line-pump.gds-code = temp-rvs-line.gds-code  and
          control-rvs-line-pump.obj-code = temp-rvs-line.obj-code  and
          control-rvs-line-pump.obj-type = temp-rvs-line.obj-type  and
          control-rvs-line-pump.pl-code  = temp-rvs-line.pl-code AND
          control-rvs-line-pump.pump-code = buf_rvs-line-pump.pump-code AND
          control-rvs-line-pump.nozzle-code = buf_rvs-line-pump.nozzle-code
        BY control-rvs-doc.fact-order:
          assign pol6 = pol6 + control-rvs-line-pump.state-mh-cnt .
          LEAVE.
        END. /* FOR EACH control-rvs-doc NO-LOCK WHERE */
      end.
    END. /* FOR EACH buf_rvs-line-pump*/

    /* Всего по товару ------------------------------------------------------------------------------------------------------*/
    if last-of( temp-rvs-line.gds-code ) then do:
      find first temp-gds where temp-gds.gds-code = temp-rvs-line.gds-code no-error .
      if available temp-gds then assign v-counter [ temp-gds.num ] = pol5 - pol6 .
    End. /* last-of(temp-rvs-line.gds-code)  */
  End. /* FOR EACH temp-rvs-line No-LOCK WHERE  */

  end.
end procedure. /* Calc-Itog-Counter */



procedure Calc-Itog-Teh :
  do on error undo, return error return-value :

    define buffer buf_clients      for ub.clients .
    define buffer buf_clients-attr for ub.clients-attr .
    define buffer buf_trn-doc      for ub.trn-doc .
    define buffer buf_doc-line     for ub.doc-line .

    /* соберем данные по спецклиентам */
    FOR EACH buf_clients-attr WHERE buf_clients-attr.attr-code  = {&attr-shftrep2} AND buf_clients-attr.attr-value = "yes":U :
      FIND FIRST buf_clients NO-LOCK WHERE buf_clients.obj-type = buf_clients-attr.obj-type AND buf_clients.obj-code = buf_clients-attr.obj-code NO-ERROR.
      IF not AVAILABLE buf_clients THEN next .
      for each buf_trn-doc no-lock
        where buf_trn-doc.obj-type   = obj-list.obj-type
          and buf_trn-doc.obj-code   = obj-list.obj-code
          and buf_trn-doc.status_    = {&fact}
          and buf_trn-doc.cli-type   = buf_clients.obj-type
          and buf_trn-doc.cli-code   = buf_clients.obj-code
          and buf_trn-doc.shift-date >= x-Date-Start
          and buf_trn-doc.shift-date <= x-Date-End
      :
        if buf_trn-doc.shift-date = x-Date-Start and buf_trn-doc.shift-num < x-Shift-Start then next .
        if buf_trn-doc.shift-date = x-Date-End   and buf_trn-doc.shift-num > x-Shift-End   then next .
        IF buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} then next .

        for each buf_doc-line no-lock where buf_doc-line.doc-code  = buf_trn-doc.doc-code :
          find first temp-gds
            where temp-gds.artic     = buf_doc-line.artic
              and temp-gds.prod-type = buf_doc-line.prod-type
              and temp-gds.prod-code = buf_doc-line.prod-code
          no-error .
          if not available temp-gds then next .
          IF buf_doc-line.ext-doc-type = {&TDEDT_Inv} or buf_doc-line.ext-doc-type = {&TDEDT_Peresort} THEN DO:
            assign v-teh [ temp-gds.num ] = v-teh  [ temp-gds.num ] + ( IF buf_doc-line.cli-qnty = ? THEN 0 ELSE buf_doc-line.cli-qnty ).
          end.
          else do:
            assign v-teh [ temp-gds.num ] = v-teh  [ temp-gds.num ] + buf_doc-line.fact-qnty .
          end.
        END. /* IF NOT ERROR-STATUS :ERROR */
      END. /* IF AVAILABLE ub.clients */
    END. /* FOR EACH ub.clients-attr */



  end.
end procedure. /* Calc-Itog-Teh */