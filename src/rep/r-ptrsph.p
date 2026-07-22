block-level on error undo, throw.
/*

$Revision: c7170b2137c1, 2069, rls $
$Author: EShklyar $
$Date: Fri Oct 18 13:05:47 2019 +0300 $
$Workfile: r-ptrsph.p $
$Archive: rep/r-ptrsph.p $

Почасовая статистика продаж ТРК с детализацией по пистолетам

Автор: Уханов Дмитрий Юрьевич
Дата создания: 08/08/06
Author: Dmitry Ukhanov
Creation date: 08/08/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-obj-type    as character     no-undo .
define input parameter p-obj-code    as integer       no-undo .

define variable vss-revision    as character no-undo initial "$Revision: c7170b2137c1, 2069, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Fri Oct 18 13:05:47 2019 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-ptrsph.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-ptrsph.p $":U .
define variable vss-description as character no-undo initial "Почасовая статистика продаж ТРК с детализацией по пистолетам":U .


{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ gbl/waitfram.i }
{ trg/factord.i  }
{ gbl/cur-time.i }
{ str/findtank.i }
{ rep/real3tmp.i bge pump-nozzle }
{ rep/real-2df.i "NEW SHARED" treal-2 bge pump-nozzle }
{ rep/real-4df.i "NEW SHARED" treal-4 bge }
{ rep/real-8df.i "NEW SHARED" treal-8 }
{ rep/realg3df.i "NEW SHARED" treal-3 bge }
{ rep/real-2cr.i treal-2 bge pump-nozzle }
{ rep/r-paychk.i def }
define buffer g-treal-3 for treal-3.
{ rep/realg3cr.i treal-3 bge }
{ rep/realg3cr.i g-treal-3 bge }
{ rep/real-4cr.i treal-4 bge }

{ gbl/cur-time.i }
{ cus/real-vat.i "NEW SHARED" treal-vat }
{ rep/icm-3df.i  "NEW SHARED"         }
{ str/valddnst.i def }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/getctxtp.i def }
{ str/getctxtp.i get }
{ rep/cpapcep.i }
{ rep/r-paychk.i defvar bge }
define variable v-host-code as integer no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .


&scop f-l Sparse,Centering,ShiftRight


define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo initial yes .
define variable g#host-code   as integer no-undo .

define variable fact-order-from as decimal   no-undo .
define variable fact-order-till as decimal   no-undo .
define variable is-petrol       as logical   no-undo .
define variable is-pieces       as logical   no-undo .
define variable j_pl-code       as integer   no-undo .
define variable j_pump-code     as integer   no-undo .
define variable j_nozzle-code   as integer   no-undo .
define variable j_order         as integer   no-undo .
define variable j_chk-count     as integer   no-undo .
define variable j_hour-from     as integer   no-undo .
define variable j_hour-till     as integer   no-undo .
define variable j_tmp-hour-from as integer   no-undo .
define variable j_tmp-hour-till as integer   no-undo .
define variable t_tmp-date      as date      no-undo .
define variable v_chk-code-list as character no-undo .
define variable t_today         as date      no-undo .
define variable j_time          as integer   no-undo .
define variable r_temp-rec-id   as recid     no-undo .
define variable Under_Line      as character no-undo .
define variable j_text-length   as integer   no-undo .
define variable j_column-no     as integer   no-undo .
define variable j_total-length  as integer   no-undo .
define variable v_label-line1   as character no-undo .
define variable v_label-line2   as character no-undo .
define variable v_label-line3   as character no-undo .
define variable v_label-line4   as character no-undo .
define variable v_label-line5   as character no-undo .
define variable v_print-line    as character no-undo .
define variable v_excel-line    as character no-undo .
define variable d_sum-sale      as decimal   no-undo .
define variable d_base-qnty     as decimal   no-undo .
define variable j_indent        as integer   no-undo .
define variable v_text-indent   as character no-undo .
define variable v_excel-indent  as character no-undo .
define variable XL-delim        as character no-undo .
define variable v-del-0         as character no-undo .
define variable v-del-1         as character no-undo .
define variable v-del-2         as character no-undo .
define variable v-short-date    as character no-undo .
define variable XLS-page-num    as integer   no-undo initial 0 .
define variable v_temp-param    as character no-undo .
define variable v_param-type    as character no-undo .
define variable j_row-counter   as integer   no-undo .
define variable v_total-lines   as character no-undo .
define variable j_total-lines   as integer   no-undo .
define variable v-column-list   as character no-undo .
define variable varpump-code    as integer   no-undo.
define variable varnozzle-code  as integer   no-undo.
define variable pay-sum as decimal no-undo. /*сумма неразбросанного*/
define variable v-density as decimal no-undo.
define variable v-curr-r-b as character no-undo .
define variable v-line-num as integer no-undo .
define variable v-rv as integer no-undo .
define variable vari as integer no-undo.
define variable v-user-action as character no-undo .
define variable v-printed as logical   no-undo .
define variable p-by-pay-card-prefix as logical no-undo init no.


define buffer buf_inkas for ub.inkas.
assign
x-SelectGood  = {&g-all}
pychk_SHEET2  = yes
.


define temp-table tt_line no-undo
  field artic       like ub.goods.artic         /*  1) артикул                  */
  field prod-type   like ub.goods.prod-type     /*  2) тип производителя        */
  field prod-code   like ub.goods.prod-code     /*  3) код производителя        */
  field gds-code    like ub.goods.gds-code      /*  4) код товара               */
  field gds-name    like ub.goods.gds-name      /*  5) наименование товара      */
  field pump-code   like ub.pump.pump-code      /*  8) код ТРК                  */
  field nozzle-code like ub.nozzle.nozzle-code  /*  9) код пистолета            */
  field chk-count   as   integer                /* 10) количество чеков         */
  field base-qnty   like ub.doc-line.fact-qnty  /* 11) количество в литрах      */
  field cli-qnty    like ub.doc-line.fact-qnty  /* 12) количество в килограммах */
  field sum-sale    like ub.trn-doc.tot-calc    /* 13) сумма                    */
  field pay-code    like ub.cash-pay.cdpay-code /* 14) код оплаты               */
  field pay-name    like ub.cash-pay.obj-name   /* 15) вид оплаты               */
  field curr-code   like ub.cash-pay.curr-code  /* 16) вид оплаты               */
  field order       as   integer                /* 17) номер п/п                */
  field chk-date    like ub.chk-doc.chk-date    /* 18) дата чека                */
  field chk-time    like ub.chk-doc.chk-time    /* 19) время чека               */
  field chk-code    like ub.chk-doc.doc-code    /* 20) уникальный номер чека    */
  field chk-num     as character                /* 21) Номер чека на кассе:номер z-отчета */
  field pass-gds    as character                /* 22) Сухой чек                */
  field doc-num2    like ub.chk-doc.doc-num2    /* 23) № заказа                 */

  index upi         is   unique primary order
  index ui1         is   unique gds-code pump-code nozzle-code pay-code curr-code chk-date chk-time
  index uic         chk-code gds-code    pay-code curr-code
  index i1          chk-date chk-time
.

define buffer bf_shift-obj_from for ub.shift-obj      .
define buffer bf_shift-obj_till for ub.shift-obj      .
define buffer bf_shift-obj      for ub.shift-obj      .
define buffer bf_chk-gds        for ub.chk-gds        .
define buffer bf_chk-pay        for ub.chk-pay        .
define buffer bf_bar-code       for ub.bar-code       .
define buffer bf_goods          for ub.goods          .
define buffer bf_pl-gds-pump    for ub.pl-gds-pump    .
define buffer bf_pl-pump-nozzle for ub.pl-pump-nozzle .
define buffer bf_place          for ub.place          .
define buffer bf_cash-pay       for ub.cash-pay       .
define buffer bf_line           for tt_line           .
define buffer buf_bar-code      for ub.bar-code       .
define buffer buf_cash-pay      for ub.cash-pay       .


define stream text_out .

FUNCTION Centering RETURNS CHARACTER ( INPUT i-string AS CHARACTER, INPUT i-length AS INTEGER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.
  RUN get-centre-string IN THIS-PROCEDURE ( INPUT i-string, INPUT i-length, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-string ELSE v-outstring ).
END FUNCTION. /* Centering */

PROCEDURE get-centre-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-length    AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.

  DEFINE VARIABLE j-format AS INTEGER NO-UNDO.
  DEFINE VARIABLE j-left   AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-instring = TRIM(   p-instring )
           j-format   = LENGTH( p-instring ).
    IF           j-format > p-length THEN DO:
      ASSIGN p-outstring = SUBSTRING( p-instring, 1, p-length ).
    END. ELSE IF j-format < p-length THEN DO:
      ASSIGN j-left      = INTEGER( ( p-length - ( j-format + 1 ) ) * 0.5 )
             p-outstring = FILL( " ":U, j-left ) + p-instring + FILL( " ":U, p-length - ( j-left + j-format ) ).
    END.                             ELSE DO:
      ASSIGN p-outstring = p-instring.
    END.
  END.
END PROCEDURE. /* get-centre-string */
FUNCTION ShiftRight RETURNS CHARACTER ( INPUT i-string AS CHARACTER, INPUT i-length AS INTEGER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.

  RUN get-right-string IN THIS-PROCEDURE ( INPUT i-string, INPUT i-length, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-string ELSE v-outstring ).
END FUNCTION. /* ShiftRight */

PROCEDURE get-right-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-length    AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.

  DEFINE VARIABLE j-format AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-instring = TRIM(   p-instring )
           j-format   = LENGTH( p-instring ).
    IF           j-format > p-length THEN DO:
      ASSIGN p-outstring = SUBSTRING( p-instring, 1, p-length ).
    END. ELSE IF j-format < p-length THEN DO:
      ASSIGN p-outstring = FILL( " ":U, p-length - j-format ) + p-instring.
    END.                             ELSE DO:
      ASSIGN p-outstring = p-instring.
    END.
  END.
END PROCEDURE. /* get-right-string */
FUNCTION Sparse RETURNS CHARACTER ( INPUT p-instring AS CHARACTER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.

  RUN get-sparsed-string IN THIS-PROCEDURE ( INPUT p-instring, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN p-instring ELSE v-outstring ).
END FUNCTION. /* Sparse */

PROCEDURE get-sparsed-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.

  DEFINE VARIABLE jj AS INTEGER NO-UNDO.

  DO ON ERROR UNDO, RETURN ERROR :
    DO jj = 1 TO LENGTH( p-instring ) :
      ASSIGN p-outstring = p-outstring + ( IF p-outstring = "":U THEN "":U ELSE " ":U ) + SUBSTRING( p-instring, jj, 1 ).
    END.
    ASSIGN p-outstring = CAPS( TRIM( p-outstring ) ).
  END.
END PROCEDURE. /* get-sparsed-string */

form header
  Centering( Sparse( "Почасовая статистика продаж ТРК с детализацией по пистолетам" )
                          , j_total-length ) format "x({&A4_LS})":U at 1 skip( 1 )
  ShiftRight( substitute( "Дата печати: &1, время: &2.   Страница: &3."
                        , string( t_today,                 "99.99.9999":U )
                        , string( j_time,                  "HH:MM:SS":U   )
                        , string( page-number( text_out ), ">>>9":U        )
                        ) , j_total-length ) format "x({&A4_LS})":U at 1 skip( 0 )
  v_label-line1                              format "x({&A4_LS})":U at 1 skip( 0 )
  v_label-line2                              format "x({&A4_LS})":U at 1 skip( 0 )
  v_label-line3                              format "x({&A4_LS})":U at 1 skip( 0 )
  v_label-line4                              format "x({&A4_LS})":U at 1 skip( 0 )
  v_label-line5                              format "x({&A4_LS})":U at 1 skip( 0 )
with frame Top_Page width {&A4_LS} page-top no-labels no-box use-text stream-io no-underline .

form header                                 skip( 1 )
  Under_Line format "x({&A4_LS})":U   at  1 skip( 0 )
  "Продолжение на следующей странице" at 30 skip( 0 )
with frame Bottom_Page width {&A4_LS} page-bottom no-labels no-box use-text stream-io no-underline .

do
on error undo, return error return-value
:
  run WaitFram-Show   in this-procedure
    (
      input {&MyWaitMess}
    ) .
  {&SetCursorWait}
  run get-report-num  in parparentproc
    (
      output g#report-num
    ) .
  {&SetCursorWait}
  run get-quest-print in parparentproc
    (
      output g#quest-print
    ) .
  {&SetCursorWait}
  { gbl/getcntxt.i get }
  {&SetCursorWait}
  { gbl/getsect.i  def }
  { gbl/getsect.i run v-cntxt-obj-type  v-cntxt-obj-code {&attr-report-firm} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'XL-delim'  then v_temp-param   = thbjattr_thbj-attr.property-value-character.
  end.
  IF v_temp-param = "" then XL-delim = ";".
  else XL-delim = v_temp-param.

  run gbl/getlocal.p
    ( output v-del-0
    , output v-del-1
    , output v-del-2
    , output v-short-date
    ) no-error .
  if error-status :error
  then do:
    assign
      v-del-1 = " ":U
    .
  end.
  {&SetCursorWait}
  assign
    XLS-page-num = XLS-page-num + 1
  .
  for each SheetF where
           SheetF.Sheet-Num > XLS-page-num
  :
    delete SheetF .
  end.
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
    SheetF.MergeCellsH        = "":U
    SheetF.MergeCellsV        = "":U
    SheetF.Excel-Column-Lable = "":U
    SheetF.ColFormat          = "":U
    SheetF.Sizes              = "":U
    Sheetf.Bas-File           = "ptrlhour.bas"
    Sheetf.Bas-Param-Add      = yes
  .
  run get-fo-range in this-procedure
    (
       input p-obj-type
    ,  input p-obj-code
    ,  input x-Date-Start
    ,  input x-Date-End
    ,  input x-Shift-Start
    ,  input x-Shift-End
    ,  input x-TOG-Shift
    , output fact-order-from
    , output fact-order-till
    ) no-error .
  if error-status :error
  then do:
    message return-value skip( 0 )
            error-status :get-message( 1 ) skip( 0 )
            error-status :get-message( 2 ) skip( 0 )
    view-as alert-box error .
    return error .
  end.

  if x-TOG-Shift = yes
  then do:
    find first bf_shift-obj_from no-lock where
               bf_shift-obj_from.obj-type    = p-obj-type     and
               bf_shift-obj_from.obj-code    = p-obj-code     and
             ( bf_shift-obj_from.shift-date  = x-Date-Start   and
               bf_shift-obj_from.shift-num  >= x-Shift-Start  or
               bf_shift-obj_from.shift-date >  x-Date-Start ) no-error .
    if not available bf_shift-obj_from
    then do:
      message "Не найдена смена начала отчета." skip( 0 )
              "Дата:"    string( x-Date-Start, "99/99/9999":U ) skip( 0 )
              "Порядок:" x-Shift-Start skip( 1 )
      view-as alert-box error .
      return error .
    end. /* if not available bf_shift-obj_from */
    find last bf_shift-obj_till no-lock where
              bf_shift-obj_till.obj-type    = p-obj-type   and
              bf_shift-obj_till.obj-code    = p-obj-code   and
            ( bf_shift-obj_till.shift-date  = x-Date-End   and
              bf_shift-obj_till.shift-num  <= x-Shift-End  or
              bf_shift-obj_till.shift-date <  x-Date-End ) no-error .
    if not available bf_shift-obj_from
    then do:
      message "Не найдена смена окончания отчета." skip( 0 )
              "Дата:"    string( x-Date-End, "99/99/9999":U ) skip( 0 )
              "Порядок:" x-Shift-Start skip( 1 )
      view-as alert-box error .
      return error .
    end. /* if not available bf_shift-obj_from */
  end.
  else do:
    find first bf_shift-obj_from no-lock where
               bf_shift-obj_from.obj-type    = p-obj-type   and
               bf_shift-obj_from.obj-code    = p-obj-code   and
               bf_shift-obj_from.shift-date >= x-Date-Start no-error .
    if not available bf_shift-obj_from
    then do:
      message "Не найдена смена начала отчета." skip( 0 )
              "Дата:" string( x-Date-Start, "99/99/9999":U ) skip( 1 )
      view-as alert-box error .
      return error .
    end. /* if not available bf_shift-obj_from */
    find last bf_shift-obj_till no-lock where
              bf_shift-obj_till.obj-type    = p-obj-type and
              bf_shift-obj_till.obj-code    = p-obj-code and
              bf_shift-obj_till.shift-date <= x-Date-End no-error .
    if not available bf_shift-obj_from
    then do:
      message "Не найдена смена окончания отчета." skip( 0 )
              "Дата:" string( x-Date-End, "99/99/9999":U ) skip( 1 )
      view-as alert-box error .
      return error .
    end. /* if not available bf_shift-obj_from */
  end.
  { gbl/curr-r-b.i v-curr-r-b }
  { gbl/hostcode.i p-obj-type p-obj-code v-host-code }
  { gbl/basecode.i v-host-code v-base-code }
  if v-curr-r-b = {&r-b-base} or
  v-base-code = 0 then pychk_NO-exch = yes.
  else pychk_No-exch = no.
  if v-curr-r-b = {&r-b-rubl} or
  v-base-code = 0 then pychk_NO-exch-rubl = yes.
  else pychk_No-exch-rubl = no.
  for each bf_shift-obj no-lock where
           bf_shift-obj.obj-type    = p-obj-type                   and
           bf_shift-obj.obj-code    = p-obj-code                   and
           bf_shift-obj.shift-date >= bf_shift-obj_from.shift-date and
           bf_shift-obj.shift-date <= bf_shift-obj_till.shift-date
  :
    if bf_shift-obj.shift-date = bf_shift-obj_from.shift-date and
       bf_shift-obj.shift-num  < bf_shift-obj_from.shift-num  or
       bf_shift-obj.shift-date = bf_shift-obj_till.shift-date and
       bf_shift-obj.shift-num  > bf_shift-obj_till.shift-num
    then do:
      next .
    end.

    _chk-doc:
    for each chk-doc no-lock where
             chk-doc.obj-type    = bf_shift-obj.obj-type   and
             chk-doc.obj-code    = bf_shift-obj.obj-code   and
             chk-doc.shift-date  = bf_shift-obj.shift-date and
             chk-doc.shift-num   = bf_shift-obj.shift-num  and
             chk-doc.out-code   <> ? :
      find first buf_inkas where buf_inkas.inkas-code = chk-doc.out-code no-lock no-error.
      if not available buf_inkas then do:
        next.
      end.
      if lookup( string( chk-doc.chk-type ), {&no-docum-receipt-codes} ) > 0
      then do:
        next _chk-doc .
      end.
      for each treal-2 :
        delete treal-2.
      end.
      for each treal-vat :
        delete treal-vat.
      end.
      for each chk-pay no-lock where
               chk-pay.doc-code = chk-doc.doc-code
        BREAK
        BY CHK-pay.DOC-CODE
        BY CHK-pay.LINE-NUM:
        { rep/r-paychk.i bge pump-nozzle }
      end.
      for each treal-2 :
        /* товар */
        find first bf_goods no-lock where
                   bf_goods.gds-code = treal-2.gds-code .
        /* топливо */
        { str/is-petrl.i
            bf_goods.artic
            bf_goods.prod-type
            bf_goods.prod-code
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

        assign
          j_pump-code = treal-2.pump
        no-error .
        if j_pump-code  = ?    or
           j_pump-code  = 0
        then do:
          message substitute( 'r-ptrsph.p: не удалось найти ТРК (из чека &4), '
                            + 'из которого продано топливо &1 &2&3 (&5) смена за &6.'
                            , bf_goods.artic
                            , bf_goods.prod-type
                            , bf_goods.prod-code
                            , chk-doc.doc-code
                            , treal-2.pump
                            , string(chk-doc.shift-date, "99/99/9999")
                            )
          view-as alert-box error .
          return error .
        end.
        assign
        varnozzle-code = treal-2.nozzle-code
        no-error .
        if varnozzle-code = 0
        or varnozzle-code = ?
        then do:
          varnozzle-code = 0.
          run find-nzl-without-pl in this-procedure (
                                           input  chk-doc.obj-type
                                          ,input  chk-doc.obj-code
                                          ,input  j_pump-code
                                          ,input  bf_goods.gds-code
                                          ,output varnozzle-code    ) no-error .
          if error-status :error or
            varnozzle-code  = ?    or
            varnozzle-code  = 0
          then do:
            message substitute( 'r-ptrsph.p (find-nzl): не удалось найти пистолет (из чека &4), '
                              + 'из которого продано топливо &1 &2&3 (&5) смена за &6.'
                              , bf_goods.artic
                              , bf_goods.prod-type
                              , bf_goods.prod-code
                              , chk-doc.doc-code
                              , treal-2.pump
                              , string(chk-doc.shift-date, "99/99/9999")
                              )
            view-as alert-box error .
            return error .
          end.
        end. /*if varnozzle-code = 0*/
        find first tt_line where
                    tt_line.pump-code   = j_pump-code
                and tt_line.nozzle-code = varnozzle-code
                and tt_line.pay-code    = treal-2.cpay-code
                and tt_line.curr-code   = treal-2.curr-code
                and tt_line.chk-date    = chk-doc.chk-date
                and tt_line.chk-time    = chk-doc.chk-time
                and tt_line.gds-code    = treal-2.gds-code
                no-error .
        if not available tt_line
        then do:
          find first bf_cash-pay no-lock where
                      bf_cash-pay.cdpay-code = treal-2.cpay-code and
                      bf_cash-pay.curr-code  = treal-2.curr-code .
          assign
            j_order = j_order + 1
          .
          for first ub.bar-code no-lock where ub.bar-code.gds-code = treal-2.gds-code,
          first ub.chk-gds no-lock where ub.chk-gds.b-code = ub.bar-code.b-code
          and ub.chk-gds.doc-code = chk-doc.doc-code:
            
          create tt_line .
          assign
            tt_line.artic       = bf_goods.artic
            tt_line.prod-type   = bf_goods.prod-type
            tt_line.prod-code   = bf_goods.prod-code
            tt_line.gds-code    = bf_goods.gds-code
            tt_line.gds-name    = bf_goods.gds-name
            tt_line.pump-code   = j_pump-code
            tt_line.nozzle-code = varnozzle-code
            tt_line.chk-count   = 0
            tt_line.base-qnty   = 0.00
            tt_line.cli-qnty    = 0.00
            tt_line.sum-sale    = 0.00
            tt_line.pay-code    = bf_cash-pay.cdpay-code
            tt_line.pay-name    = bf_cash-pay.obj-name
            tt_line.curr-code   = bf_cash-pay.curr-code
            tt_line.order       = j_order
            tt_line.chk-date    = chk-doc.chk-date
            tt_line.chk-time    = chk-doc.chk-time
            tt_line.chk-code    = chk-doc.doc-code
            tt_line.chk-num     = chk-doc.doc-num + ":" + STRING (chk-doc.z-number)
            tt_line.pass-gds    = if chk-gds.pass-gds = 1 then "+" else "-"
            tt_line.doc-num2    = chk-doc.doc-num2
          .
          end. 
        end. /* if not available tt_line */
        assign
        tt_line.sum-sale = tt_line.sum-sale   + treal-2.netto-rubl
        tt_line.base-qnty = tt_line.base-qnty + treal-2.qnty1
        .
      end. /* for each treal-2 */
    end. /* for each chk-doc */
  end. /* for each bf_shift-obj */

  /* итоги */
  assign
    j_chk-count     = 0
    j_row-counter   = 0
    j_total-lines   = 0
    v_total-lines   = "":U
    v_chk-code-list = "":U
  .
  for each tt_line no-lock
  break by tt_line.chk-date
        by tt_line.chk-time
  :
    if first-of( tt_line.chk-date )
    then do:
      assign
        t_tmp-date      = tt_line.chk-date
        v_chk-code-list = "":U
      .

      run get-hour-range in this-procedure
        (
           input tt_line.chk-time
        , output j_hour-from
        , output j_hour-till
        ) .

      do vari = 0 to 23 :
        assign
          j_chk-count = 0.
        for each bf_line where
                 bf_line.chk-date  = t_tmp-date  and
                 bf_line.chk-time >= vari * 3600 and
                 bf_line.chk-time <= vari * 3600 + 3599
        by bf_line.chk-date by bf_line.chk-time
        :
          assign
            j_chk-count = j_chk-count + 1
          .
          assign
          bf_line.chk-count = j_chk-count.
        end. /* for each bf_line */
      end.

      if not first( tt_line.chk-date )
      then do:
        assign
          j_row-counter = j_row-counter + 1
          j_total-lines = j_total-lines + 1
          v_total-lines = v_total-lines
                        + ( if v_total-lines = "":U then "":U else {&comma-char} )
                        + string( j_row-counter )
        .
      end.
    end. /* if first-of( tt_line.chk-date ) */
    run get-hour-range in this-procedure
      (
         input tt_line.chk-time
      , output j_tmp-hour-from
      , output j_tmp-hour-till
      ) .
    if j_tmp-hour-from = j_hour-from and
       j_tmp-hour-till = j_hour-till and
       t_tmp-date      = tt_line.chk-date
    then do:
      if lookup( tt_line.chk-code, v_chk-code-list ) = 0
      then do:
        assign
          v_chk-code-list = v_chk-code-list + ( if v_chk-code-list = "":U then "":U else {&comma-char} )
                                            + tt_line.chk-code
        .
      end.
    end.
    else do: /* last-of range */
      assign
        j_hour-from     = j_tmp-hour-from
        j_hour-till     = j_tmp-hour-till
        t_tmp-date      = tt_line.chk-date
        v_chk-code-list = tt_line.chk-code
      .
      assign
        j_row-counter = j_row-counter + 1
        j_total-lines = j_total-lines + 1
        v_total-lines = v_total-lines
                      + ( if v_total-lines = "":U then "":U else {&comma-char} )
                      + string( j_row-counter )
      .
    end. /* last-of range */
    assign
      j_row-counter = j_row-counter + 1
    .
  end. /* for each tt_line */
  assign
    j_row-counter = j_row-counter + 1
    j_total-lines = j_total-lines + 1
    v_total-lines = v_total-lines
                  + ( if v_total-lines = "":U then "":U else {&comma-char} )
                  + string( j_row-counter )
  .
  assign
    t_tmp-date      = ?
    j_hour-from     = 0
    j_hour-till     = 0
    v_chk-code-list = "":U
  .

  run get-label-lines in this-procedure
    (
      output v_label-line1
    , output v_label-line2
    , output v_label-line3
    , output v_label-line4
    , output v_label-line5
    , output j_text-length
    , output j_column-no
    , output j_total-length
    ) no-error .
  if error-status :error
  then do:
    message return-value skip( 0 )
            error-status :get-message( 1 ) skip( 1 )
    view-as alert-box.
    return error .
  end.
  find first SheetF where
             SheetF.Sheet-Num = XLS-page-num .
  assign
    Sheetf.Bas-Params = string( j_row-counter ) + {&delim-par}
                      + string( j_column-no   ) + {&delim-par}
                      + string( j_total-lines ) + "#"
                      +         v_total-lines   + {&delim-par}
                      +         v-column-list
  .
  assign
    Under_Line = fill( '-', j_total-length )
  .
  run cur-time in this-procedure
    ( output t_today
    , output j_time
    ) .

  /* печать */
  if j_total-length > {&A4_CW0 }
  then do:
    { cmp/open-out.i stream text_out " " {&LS_PS_A4} }
  end.
  else do:
    { cmp/open-out.i stream text_out " " {&CS_PS}    }
  end.
  if XLS-page-num > 1
  then do:
    {&PageExcel}
  end.
  assign
    ReportName   = "Почасовая статистика продаж ТРК с детализацией по пистолетам"
    ReportHeader = substitute( "Дата печати: &1, время: &2."
                             , string( t_today, "99.99.9999":U )
                             , string( j_time,  "hh:mm:ss":U   )
                             )
  .
  run rep/extitle.p
    ( input XLS-page-num
    ) no-error .

  view stream text_out frame    Top_Page .
  view stream text_out frame Bottom_Page .

  assign
    t_tmp-date  = ?
    d_sum-sale  = 0.00
    d_base-qnty = 0.00
  .
  for each tt_line no-lock
  break by tt_line.chk-date
        by tt_line.chk-time
  :
    if first-of( tt_line.chk-date )
    then do:
      assign
        t_tmp-date = tt_line.chk-date
      .
      run get-hour-range in this-procedure
        (
           input tt_line.chk-time
        , output j_hour-from
        , output j_hour-till
        ) .
    end. /* if first-of( tt_line.chk-date ) */
    run get-hour-range in this-procedure
      (
         input tt_line.chk-time
      , output j_tmp-hour-from
      , output j_tmp-hour-till
      ) .
    if j_tmp-hour-from = j_hour-from and
       j_tmp-hour-till = j_hour-till and
       t_tmp-date      = tt_line.chk-date
    then do:
      if use-column[  9 ] = yes
      then do:
        assign
          d_base-qnty = d_base-qnty + tt_line.base-qnty
        .
      end.
      if use-column[ 10 ] = yes
      then do:
        assign
          d_sum-sale  = d_sum-sale  + tt_line.sum-sale
        .
      end.
    end.
    else do: /* last-of range */
      if use-column[  9 ] = yes or
         use-column[ 10 ] = yes
      then do:
        if use-column[  9 ] = yes
        then do:
          run get-indent in this-procedure
            (
               input 9
            , output j_indent
            , output v_text-indent
            , output v_excel-indent
            ) .
          put stream text_out unformatted
            v_text-indent
            fill( "-", 13 )
          .
        end.
        if use-column[ 10 ] = yes
        then do:
          if use-column[  9 ] <> yes
          then do:
            run get-indent in this-procedure
              (
                 input 10
              , output j_indent
              , output v_text-indent
              , output v_excel-indent
              ) .
            put stream text_out unformatted
              v_text-indent
            .
          end.
          else do:
            put stream text_out unformatted
              " ":U
            .
          end.
          put stream text_out unformatted
            fill( "-", 21 )
          .
        end.
        put stream text_out unformatted
          skip
        .
      end.
      if use-column[  9 ] = yes or
         use-column[ 10 ] = yes
      then do:
        if use-column[  9 ] = yes
        then do:
          run get-indent in this-procedure
            (
               input 9
            , output j_indent
            , output v_text-indent
            , output v_excel-indent
            ) .
          put stream text_out unformatted
            v_text-indent
            string( d_base-qnty, "->>>>,>>9.999":U )
          .
          {&PutExcel}
            v_excel-indent
            string( d_base-qnty, "->>>>>>>9.999":U )
          .
        end.
        if use-column[ 10 ] = yes
        then do:
          if use-column[  9 ] <> yes
          then do:
            run get-indent in this-procedure
              (
                 input 10
              , output j_indent
              , output v_text-indent
              , output v_excel-indent
              ) .
            put stream text_out unformatted
              v_text-indent
            .
            {&PutExcel}
              v_excel-indent
            .
          end.
          else do:
            put stream text_out unformatted
              " ":U
            .
          end.
          put stream text_out unformatted
            string( d_sum-sale, "->,>>>,>>>,>>>,>>9.99":U )
          .
          {&PutExcel}
            {&tabulation}
            string( d_sum-sale, "->>>>>>>>>>>>>>>>9.99":U )
          .
        end.
        put stream text_out unformatted
          skip Under_Line skip
        .
        {&PutExcel}
          skip
        .
      end.
      assign
        j_hour-from = j_tmp-hour-from
        j_hour-till = j_tmp-hour-till
        t_tmp-date  = tt_line.chk-date
        d_sum-sale  = tt_line.sum-sale
        d_base-qnty = tt_line.base-qnty
      .
    end. /* last-of range */
    run get-print-line in this-procedure
      (
         input recid( tt_line )
      , output v_print-line
      , output v_excel-line
      ) no-error .
    if error-status :error or
       v_print-line = ?    or
       v_print-line = "":U
    then do:
      return error substitute( 'Ошибка печати строки отчета.&1 ТРК &2, Пистолет &3, &4.&1'
                             + 'Чек &5, Оплата &6, Код валюты &7.'
                             , {&new-line}
                             , tt_line.pump-code
                             , tt_line.nozzle-code
                             , substitute( 'Топливо &1 &2&3 "&4"'
                                         , tt_line.artic
                                         , tt_line.prod-type
                                         , tt_line.prod-code
                                         , tt_line.gds-code
                                         )
                             , tt_line.chk-code
                             , tt_line.pay-code
                             , tt_line.curr-code
                             ) .
    end.
    put stream text_out unformatted
      v_print-line skip
    .
    {&PutExcel}
      v_excel-line skip
    .
    if last-of( tt_line.chk-date )
    then do:
      if use-column[  9 ] = yes or
         use-column[ 10 ] = yes
      then do:
        if use-column[  9 ] = yes
        then do:
          run get-indent in this-procedure
            (
               input 9
            , output j_indent
            , output v_text-indent
            , output v_excel-indent
            ) .
          put stream text_out unformatted
            v_text-indent
            fill( "-", 13 )
          .
        end.
        if use-column[ 10 ] = yes
        then do:
          if use-column[  9 ] <> yes
          then do:
            run get-indent in this-procedure
              (
                 input 10
              , output j_indent
              , output v_text-indent
              , output v_excel-indent
              ) .
            put stream text_out unformatted
              v_text-indent
            .
          end.
          else do:
            put stream text_out unformatted
              " ":U
            .
          end.
          put stream text_out unformatted
            fill( "-", 21 )
          .
        end.
        put stream text_out unformatted
          skip
        .
      end.
      if use-column[  9 ] = yes or
         use-column[ 10 ] = yes
      then do:
        if use-column[  9 ] = yes
        then do:
          run get-indent in this-procedure
            (
               input 9
            , output j_indent
            , output v_text-indent
            , output v_excel-indent
            ) .
          put stream text_out unformatted
            v_text-indent
            string( d_base-qnty, "->>>>,>>9.999":U )
          .
          {&PutExcel}
            v_excel-indent
            string( d_base-qnty, "->>>>>>>9.999":U )
          .
        end.
        if use-column[ 10 ] = yes
        then do:
          if use-column[  9 ] <> yes
          then do:
            run get-indent in this-procedure
              (
                 input 10
              , output j_indent
              , output v_text-indent
              , output v_excel-indent
              ) .
            put stream text_out unformatted
              v_text-indent
            .
            {&PutExcel}
              v_excel-indent
            .
          end.
          else do:
            put stream text_out unformatted
              " ":U
            .
          end.
          put stream text_out unformatted
            string( d_sum-sale, "->,>>>,>>>,>>>,>>9.99":U )
          .
          {&PutExcel}
            {&tabulation}
            string( d_sum-sale, "->>>>>>>>>>>>>>>>9.99":U )
          .
        end.
        put stream text_out unformatted
          skip Under_Line skip
        .
        {&PutExcel}
          skip
        .
      end.
      assign
        d_sum-sale  = 0.00
        d_base-qnty = 0.00
      .
      if last-of( tt_line.chk-date )
      then do:
        hide stream text_out frame Bottom_Page no-pause .
      end. /* if last( tt_line.chk-date ) */
    end. /* if last-of( tt_line.chk-date ) */
  end. /* for each tt_line */
  hide stream text_out frame Bottom_Page no-pause .

  output stream text_out close .
  {&CloseExcel}

  run WaitFram-Hide in this-procedure .
  {&SetCursorNo}
  if j_total-length > {&A4_CW0 }
  then do:
    run gbl/prnfilen.w
      (
          input  ""
         ,input  8
         ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
         ,input  7
         ,output v-user-action
         ,output v-printed
      ) .
  end.
  else do:
    run gbl/prnfilen.w
      (
          input  ""
         ,input  0
         ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
         ,input  7
         ,output v-user-action
         ,output v-printed
      ) .
  end.
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
        (
           input p-date-from            /* p-fact-date            */
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
        (
           input p-date-till            /* p-fact-date            */
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
        (
           input p-date-from
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
        (
           input p-date-till
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

procedure get-hour-range :
  define  input parameter p-time as integer no-undo .
  define output parameter p-from as integer no-undo .
  define output parameter p-till as integer no-undo .

  define variable j-hour as integer no-undo .

  do
  on error undo, return error return-value
  :
    assign
      j-hour = integer( substring( string( p-time, "hh:mm:ss":U ), 1, 2 ) )
      p-from = j-hour * 3600
      p-till = p-from + 3599
    .
  end. /* on error */
end procedure. /* get-hour-range */

procedure get-label-lines :
  define output parameter p-label-line-1 as character no-undo initial "":U .
  define output parameter p-label-line-2 as character no-undo initial "":U .
  define output parameter p-label-line-3 as character no-undo initial "":U .
  define output parameter p-label-line-4 as character no-undo initial "":U .
  define output parameter p-label-line-5 as character no-undo initial "":U .
  define output parameter p-text-length  as integer   no-undo initial 0    .
  define output parameter p-columns-no   as integer   no-undo initial 0    .
  define output parameter p-total-length as integer   no-undo initial 0    .

  define variable v_list-length as character no-undo initial "":U .
  define variable v_list-label  as character no-undo initial "":U .
  define variable v_list-types  as character no-undo initial "":U .
  define variable jj            as integer   no-undo initial 0    .
  define variable j_length      as integer   no-undo initial 0    .
  define variable v_length      as character no-undo initial "":U .
  define variable v_label       as character no-undo initial "":U .
  define variable v_data-type   as character no-undo initial "":U .

  do
  on error undo, return error return-value
  :
    assign
      p-label-line-1 = "-":U
      p-label-line-2 = ":":U
      p-label-line-3 = ":":U
      p-label-line-4 = ":":U
      p-label-line-5 = ":":U
      p-text-length  = 0
      p-columns-no   = 0
    .
    run get-lbl-data in this-procedure
      (
        output v_list-label
      , output v_list-length
      , output v_list-types
      ) .
    find first SheetF where
               SheetF.Sheet-Num = XLS-page-num .
    do jj = 1 to num-entries( v_list-label )
    :
      if use-column[ jj ] <> yes
      then do:
        next .
      end.
      assign
        v_label     = trim( entry( jj, v_list-label  ) )
        v_length    = trim( entry( jj, v_list-length ) )
        v_data-type = trim( entry( jj, v_list-types  ) )
      .
      assign
        j_length = integer( v_length )
      no-error .
      assign
        p-text-length  = p-text-length  + j_length
        p-columns-no   = p-columns-no   + 1
        p-label-line-1 = p-label-line-1 + fill( "-", j_length ) + "-"
        p-label-line-2 = p-label-line-2 + substring( Centering( v_label, j_length ) + fill( " ":U, j_length )
                                                   , 1
                                                   , j_length
                                                   ) + ":"
        p-label-line-3 = p-label-line-3 + fill( "-", j_length ) + ":"
        p-label-line-4 = p-label-line-4 + substring( Centering( string( p-columns-no ), j_length ) +
                                                     fill( " ":U, j_length )
                                                   , 1
                                                   , j_length
                                                   ) + ":"
        p-label-line-5 = p-label-line-5 + fill( "-", j_length ) + ":"
      .
      assign
        SheetF.Excel-Column-Lable = SheetF.Excel-Column-Lable
                                  + ( if SheetF.Excel-Column-Lable = "":U then "":U else {&comma-char} )
                                  + v_label
        SheetF.Sizes              = SheetF.Sizes
                                  + ( if SheetF.Sizes = "":U then "":U else {&comma-char} )
                                  + v_length
      .
      case v_data-type :
        when "D":U
        then do:
          assign
            SheetF.ColFormat = SheetF.ColFormat
                             + ( if SheetF.ColFormat = "":U then "":U else ";":U )
                             + string( p-columns-no ) + "=":U + "@":U
          .
          assign
            v-column-list = v-column-list
                          + ( if v-column-list = "":U then "":U else ";" )
                          + "@":U
          .
        end.
        when "T":U
        then do:
          assign
            SheetF.ColFormat = SheetF.ColFormat
                             + ( if SheetF.ColFormat = "":U then "":U else ";":U )
                             + string( p-columns-no ) + "=":U + "@":U
          .
          assign
            v-column-list = v-column-list
                          + ( if v-column-list = "":U then "":U else ";" )
                          + "@":U
          .
        end.
        when "Z":U
        then do:
          assign
            SheetF.ColFormat = SheetF.ColFormat
                             + ( if SheetF.ColFormat = "":U then "":U else ";":U )
                             + string( p-columns-no ) + "=":U + "#":U + v-del-1 + "##":U + "0":U
          .
          assign
            v-column-list = v-column-list
                          + ( if v-column-list = "":U then "":U else ";" )
                          + "#":U + v-del-1 + "##":U + "0":U
          .
        end.
        when "C":U
        then do:
          assign
            SheetF.ColFormat = SheetF.ColFormat
                             + ( if SheetF.ColFormat = "":U then "":U else ";":U )
                             + string( p-columns-no ) + "=":U + "@":U
          .
          assign
            v-column-list = v-column-list
                          + ( if v-column-list = "":U then "":U else ";" )
                          + "@":U
          .
        end.
        when "I":U
        then do:
          assign
            SheetF.ColFormat = SheetF.ColFormat
                             + ( if SheetF.ColFormat = "":U then "":U else ";":U )
                             + string( p-columns-no ) + "=":U + "0":U
          .
          assign
            v-column-list = v-column-list
                          + ( if v-column-list = "":U then "":U else ";" )
                          + "0":U
          .
        end.
        when "Q":U
        then do:
          assign
            SheetF.ColFormat = SheetF.ColFormat
                             + ( if SheetF.ColFormat = "":U then "":U else ";":U )
                             + string( p-columns-no ) + "=":U + "#":U + v-del-1 + "##":U + "0":U + v-delim + "000":U
          .
          assign
            v-column-list = v-column-list
                          + ( if v-column-list = "":U then "":U else ";" )
                          + "#":U + v-del-1 + "##":U + "0":U + v-delim + "000":U
          .
        end.
        when "S":U
        then do:
          assign
            SheetF.ColFormat = SheetF.ColFormat
                             + ( if SheetF.ColFormat = "":U then "":U else ";":U )
                             + string( p-columns-no ) + "=":U + "#":U + v-del-1 + "##":U + "0":U + v-delim + "00":U
          .
          assign
            v-column-list = v-column-list
                          + ( if v-column-list = "":U then "":U else ";" )
                          + "#":U + v-del-1 + "##":U + "0":U + v-delim + "00":U
          .
        end.
      end case. /* v_data-type */
    end.
    assign
      SheetF.ColFormat = SheetF.ColFormat
                       + {&delim-par}
                       + {&delim-par}
                       + trim( string( XLS-page-num, ">>>>>>>>>9":U ) ) + "-й Лист"
    .
    assign
      p-total-length = p-text-length + p-columns-no + 1
    .
  end. /* on error */
end procedure. /* get-label-lines */

procedure get-print-line :
  define  input parameter p-temp-rec-id as recid     no-undo .
  define output parameter p-print-line  as character no-undo initial "":U .
  define output parameter p-excel-line  as character no-undo initial "":U .

  define variable v_list-label  as character no-undo initial "":U .
  define variable v_list-types  as character no-undo initial "":U .
  define variable v_list-length as character no-undo initial "":U .
  define variable v_data-type   as character no-undo initial "":U .
  define variable v_length      as character no-undo initial "":U .
  define variable j_length      as integer   no-undo initial 0    .
  define variable jj            as integer   no-undo initial 0    .
  define variable j_time-top    as integer   no-undo .
  define variable j_time-bottom as integer   no-undo .

  define buffer bf_print-line for tt_line .

  do
  on error undo, return error return-value
  :
    find first bf_print-line no-lock where
        recid( bf_print-line ) = p-temp-rec-id .
    run get-lbl-data in this-procedure
      (
        output v_list-label
      , output v_list-length
      , output v_list-types
      ) .
    assign
      p-print-line = ":":U
      p-excel-line = "":U
    .
    do jj = 1 to num-entries( v_list-length )
    :
      if use-column[ jj ] <> yes
      then do:
        next .
      end.
      assign
        v_length    = trim( entry( jj, v_list-length ) )
        v_data-type = trim( entry( jj, v_list-types  ) )
      .
      assign
        j_length = integer( v_length )
      no-error .
      case v_data-type :
        when "D":U
        then do:
          assign
            p-print-line = p-print-line + string( bf_print-line.chk-date, "99/99/9999":U ) + ":":U
            p-excel-line = p-excel-line + string( bf_print-line.chk-date, "99/99/9999":U ) + {&tabulation}
          .
        end.
        when "T":U
        then do:
          assign
            p-print-line = p-print-line + string( bf_print-line.chk-time, "hh:mm:ss":U ) + ":":U
            p-excel-line = p-excel-line + string( bf_print-line.chk-time, "hh:mm:ss":U ) + {&tabulation}
          .
        end.
        when "Z":U
        then do:
          case j_length :
            when 10
            then do:
              assign
                p-print-line = p-print-line + " ":U + string( bf_print-line.gds-code, "999999999":U ) + ":":U
                p-excel-line = p-excel-line         + string( bf_print-line.gds-code, "999999999":U ) + {&tabulation}
              .
            end.
          end case. /* j_length */
        end.
        when "C":U
        then do:
          case j_length :
            when 10
            then do:
              assign
                p-print-line = p-print-line + string( bf_print-line.artic, "x(10)":U ) + ":":U
                p-excel-line = p-excel-line + string( bf_print-line.artic, "x(10)":U ) + {&tabulation}
              .
            end.
            when 15
            then 
              do:
                case jj :
                  when 12
                  then 
                    do:
                      assign
                        p-print-line = p-print-line + string( bf_print-line.chk-num, "x(15)":U ) + ":":U
                        p-excel-line = p-excel-line + string( bf_print-line.chk-num, "x(15)":U ) + {&tabulation}
                        .
                    end.
                  when 13
                  then 
                    do:
                      assign
                        p-print-line = p-print-line + string( bf_print-line.pass-gds, "x(15)":U ) + ":":U
                        p-excel-line = p-excel-line + string( bf_print-line.pass-gds, "x(15)":U ) + {&tabulation}
                        .
                    end.
                  when 14
                  then 
                    do:
                      assign
                        p-print-line = p-print-line + "  ":U + string( bf_print-line.doc-num2, "x(12)":U ) + " ":U + ":":U
                        p-excel-line = p-excel-line          + string( bf_print-line.doc-num2, "x(12)":U ) + {&tabulation}
                        .
                    end.
                end case.     
              end.       
            when 17
            then do:
              case jj :
                when 2
                then do:
                  run get-hour-range in this-procedure
                    (
                       input bf_print-line.chk-time
                    , output j_time-top
                    , output j_time-bottom
                    ) .
                  assign
                    p-print-line = p-print-line + string( j_time-top,    "hh:mm:ss":U ) + "-":U
                                                + string( j_time-bottom, "hh:mm:ss":U ) + ":":U
                    p-excel-line = p-excel-line + string( j_time-top,    "hh:mm:ss":U ) + "-":U
                                                + string( j_time-bottom, "hh:mm:ss":U ) + {&tabulation}
                  .
                end.
              end case. /* jj */
            end.
            when 24
            then do:
              case jj :
                when 5
                then do:
                  assign
                    p-print-line = p-print-line + string( bf_print-line.gds-name, "x(24)":U ) + ":":U
                    p-excel-line = p-excel-line + string( bf_print-line.gds-name, "x(24)":U ) + {&tabulation}
                  .
                end.
                when 11
                then do:
                  assign
                    p-print-line = p-print-line + string( bf_print-line.pay-name, "x(24)":U ) + ":":U
                    p-excel-line = p-excel-line + string( bf_print-line.pay-name, "x(24)":U ) + {&tabulation}
                  .
                end.
              end case. /* jj */
            end.
          end case. /* j_length */
        end.
        when "I":U
        then do:
          case jj :
            when 6
            then do:
              assign
                p-print-line = p-print-line + "  ":U + string( bf_print-line.pump-code, ">9":U ) + " ":U + ":":U
                p-excel-line = p-excel-line          + string( bf_print-line.pump-code, ">9":U ) + {&tabulation}
              .
            end.
            when 7
            then do:
              assign
                p-print-line = p-print-line + "   ":U + string( bf_print-line.nozzle-code, ">9":U ) + "   ":U + ":":U
                p-excel-line = p-excel-line           + string( bf_print-line.nozzle-code, ">9":U ) + {&tabulation}
              .
            end.
            when 8
            then do:
              assign
                p-print-line = p-print-line + string( bf_print-line.chk-count, ">>>>9":U ) + ":":U
                p-excel-line = p-excel-line + string( bf_print-line.chk-count, ">>>>9":U ) + {&tabulation}
              .
            end.
          end case. /* jj */
        end.
        when "Q":U
        then do:
          assign
            p-print-line = p-print-line + string( bf_print-line.base-qnty, "->>>>,>>9.999":U ) + ":":U
            p-excel-line = p-excel-line + string( bf_print-line.base-qnty, "->>>>>>>9.999":U ) + {&tabulation}
          .
        end.
        when "S":U
        then do:
          assign
            p-print-line = p-print-line + string( bf_print-line.sum-sale, "->,>>>,>>>,>>>,>>9.99":U ) + ":":U
            p-excel-line = p-excel-line + string( bf_print-line.sum-sale, "->>>>>>>>>>>>>>>>9.99":U ) + {&tabulation}
          .
        end.
      end case. /* v_data-type */
    end. /* do jj = 1 to num-entries( v_list-length ) */
  end. /* on error */
end procedure. /* get-print-line */

procedure get-lbl-data :
  define output parameter p-list-label  as character no-undo .
  define output parameter p-list-length as character no-undo .
  define output parameter p-list-types  as character no-undo .

  /* ********************************************************** *\
   *                                                            *
   * Типы данных:                                               *
   *  I - целый с подавлением лидирующих нулей;                 *
   *  J - как I, но с разбивкой по разрядам (тройкам);          *
   *  Z - целый без подавления лидирующих нулей;                *
   *  D - дата длинная (4 цифры года);                          *
   *  Y - дата короткая (2 цифры года);                         *
   *  T - время;                                                *
   *  H - время без секунд;                                     *
   *  Q - десятичный с 3 позициями после запятой (количество);  *
   *  S - десятичный с 2 позициями после запятой (сумма);       *
   *  R - десятичный без разбивки по разрядам (2 позиции);      *
   *  C - символьный (строка);                                  *
   *                                                            *
  \* ********************************************************** */
  do
  on error undo, return error return-value
  :
    assign
      p-list-length = "10,8,10,10,24,5,8,5,13,21,24,15,15,15":U
      p-list-label  = "Дата,Время,Код товара,Артикул,Наименование товара,№ ТРК,Пистолет,Чеков,Количество,":U +
                      "Сумма продаж,Вид оплаты,Номер чека,Сухой чек,№ заказа":U
      p-list-types  = "D,T,Z,C,C,I,I,I,Q,S,C,C,C,C":U
    .
    if num-entries( p-list-length ) <> num-entries( p-list-label ) or
       num-entries( p-list-length ) <> num-entries( p-list-types )
    then do:
      message "Заголовки:"   p-list-label  num-entries( p-list-label  ) skip( 0 )
              "Длины полей:" p-list-length num-entries( p-list-length ) skip( 0 )
              "Типы данных:" p-list-types  num-entries( p-list-types  ) skip( 1 )
      view-as alert-box .
      undo, return error "Размерности массивов: заголовков, длин полей и типов данных  НЕ СОВПАДАЮТ." .
    end.
  end. /* on error */
end procedure. /* get-lbl-data */

procedure get-indent :
  define  input parameter p-for-column-no as integer   no-undo .
  define output parameter p-indent-length as integer   no-undo initial 0 .
  define output parameter p-text-indent   as character no-undo initial "":U .
  define output parameter p-excel-indent  as character no-undo initial "":U .

  define variable v_list-label  as character no-undo initial "":U .
  define variable v_list-types  as character no-undo initial "":U .
  define variable v_list-length as character no-undo initial "":U .
  define variable v_length      as character no-undo initial "":U .
  define variable j_length      as integer   no-undo initial 0    .
  define variable jj            as integer   no-undo initial 0    .

  do
  on error undo, return error return-value
  :
    run get-lbl-data in this-procedure
      (
        output v_list-label
      , output v_list-length
      , output v_list-types
      ) .
    do jj = 1 to min( num-entries( v_list-length ), p-for-column-no - 1 )
    :
      if use-column[ jj ] <> yes
      then do:
        next .
      end.
      assign
        v_length = trim( entry( jj, v_list-length ) )
      .
      assign
        j_length = integer( v_length )
      no-error .
      assign
        p-indent-length = p-indent-length + j_length + 1
        p-excel-indent  = p-excel-indent  + {&tabulation}
      .
    end.
    assign
      p-indent-length = p-indent-length + 1
    .
    assign
      p-text-indent = fill( " ":U, p-indent-length )
    .
  end. /* on error */
end procedure. /* get-indent */

{ rep/real-2cr.i b2-treal-2 bge pump-nozzle }
{ rep/realg3cr.i b2-treal-3 bge }
{ rep/real-4cr.i b2-treal-4 bge }