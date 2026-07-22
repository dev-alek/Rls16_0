block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-obgrpw.p $
$Archive: rep/r-obgrpw.p $

Отчет по оборотка по группам для суздальского

Автор: Демин Алексей Сергеевич
Дата создания: 09/14/05
Author: Alexey Demin
Creation date: 09/14/05

*/

define input  parameter   p-call-handle as handle no-undo .
define input  parameter   p-host-code as integer   no-undo .
define input  parameter   p-period-type      as character   no-undo .
define input  parameter   p-date1     as date      no-undo .
define input  parameter   p-date2     as date      no-undo .
define input  parameter   p-dir   as character no-undo .
/*в случае задания p-date1 = ? or p-date2 = ? вычисляет сам по периоду*/
define input parameter    p-rep-code as character no-undo .


/*define variable  p-host-code as integer   no-undo .*/
/*define variable  p-date1      as date      no-undo .*/
/*define variable  p-date2      as date      no-undo .*/
/*define variable  p-period-type    as character   no-undo .*/
/*assign*/
/*  p-host-code = 1*/
/*  p-date1      = 1/1/2005*/
/*  p-date2      = 1/15/2005*/
/*  p-character    = 0*/
/*.*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-obgrpw.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-obgrpw.p $":U .
define variable vss-description as character no-undo init "Отчет оборот по группам".

define variable v-delim as character no-undo .
define variable v-del-1 as character no-undo .
define variable v-sdate as character no-undo .
define variable v-shortdate as character no-undo .
run gbl/getlocal.p ( output v-delim  , output v-del-1, output v-sdate, output v-shortdate ) no-error .
if error-status :error then do:
  message error-status :error error-status :get-message(1) v-delim v-del-1.
  v-delim = ','  .
end.
define variable g#report-num as integer   no-undo .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ rep/f-fdec.i   }
{ gbl/paramls.i  }
{ rep/mcrexcel.i }
{ trg/factord.i  }
{ ref/grplibfn.i }
{ gbl/cur-time.i }

do
on error undo, return error
:
  define Stream macr_excel.

  define var    v-fact-order-start     as decimal   no-undo .
  define var    v-fact-order-end       as decimal   no-undo .

  define buffer buf_goods    for ub.goods.
  define buffer buf_gds-obj  for ub.gds-obj.
  define buffer buf_gds-grp  for ub.gds-grp.
  define buffer buf_stk-line for ub.stk-line.
  define buffer buf_shop     for ub.shop.

  define variable jj as integer   no-undo .
  define variable v-date-from    as date         no-undo.
  define variable v-date-to      as date         no-undo.
  define variable v-can-print    as logical      no-undo.
  define variable v-archive-ok   as logical      no-undo.
  define variable v-comment      as character    no-undo.
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .
  define variable v-file-prefix as character no-undo .
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
  if p-dir = ?
  or p-dir = ''
  then do:
    p-dir = session:temp-directory.
  end.
  assign
  v-file-prefix  =  string(p-dir) +
                                       substitute("&1_&2&3&4_&5"
                                                 , p-period-type
                                                 , string(year(p-date1), "9999")
                                                 , string(month(p-date1), "99")
                                                 , string(day(p-date1), "99")
                                                 , p-rep-code
                                                 )

  .

  assign
    v-date-from = p-date1
    v-date-to   = p-date2
  .
  run day-begin-fact-order in this-procedure ( input p-date1, output v-fact-order-start ). /*Поиск нач fact-order*/
  run day-begin-fact-order in this-procedure ( input p-date2,   output v-fact-order-end ). /*Поиск посл fact-order*/

  define temp-table temp-mag no-undo  /* для списка магазинов */
    field obj-code  like ub.clients.obj-code
    field obj-type  like ub.clients.obj-type
    field obj-name  like ub.clients.obj-name
  INDEX pi  IS PRIMARY unique obj-type obj-code
      .
  for each temp-mag:
    delete temp-mag.
    end.
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
  for each temp-mag no-lock:
        run rep/chk-ahz.p (
        input        temp-mag.obj-type
      , input        temp-mag.obj-code
          , input        yes                      /*p-verify-detail */
          , input        yes /*p-verify-arh*/
          , input        no  /*p-verify-ahsp*/
          , input        no  /*p-verify-aht*/
          , input        no                       /* p-check-act         */
          , input        0                        /* p-check-act-db-num  */
          , input        "":U                     /* p-check-act-user-id */
          , input-output v-date-from
          , input-output v-date-to
          , output       v-archive-ok
          , output       v-comment
          , output       v-can-print
        ) no-error .
        if error-status :error then do:
          undo, return error substitute( "Ошибка при вызове программы chk-ahz.p. &1. &2. &3"
            , return-value, trim(error-status :get-message(1)), trim(error-status :get-message(2))
          ) .
        end. /*if error-status:error then do:*/
      end.


  define temp-table temp-tov no-undo  /* для списка товаров */
    field prod-code  like ub.goods.prod-code
    field prod-type  like ub.goods.prod-type
    field artic      like ub.goods.artic
    field grp-code  like ub.goods.grp-code
    INDEX pi  IS PRIMARY artic prod-type prod-code
    INDEX pi1 grp-code
  .

  define temp-table gds-prop no-undo  /* для списка групп */
    field   grp-code           like ub.goods.grp-code
    field   grp-name           like ub.goods.grp-name
    field   sgrp-name          like ub.goods.grp-name
    field   StartWay-Qnty      as  decimal
    field   StartWay-CostSum   as  decimal
    field   EndWay-Qnty        as  decimal
    field   EndWay-CostSum     as  decimal
    /* обороты */
    field   InExt-Qnty         as  decimal
    field   InExt-CostSum      as  decimal
    field   RetPost-Qnty       as  decimal
    field   RetPost-CostSum    as  decimal
    field   OutExt-Qnty        as  decimal
    field   OutExt-CostSum     as  decimal
    field   OutExtKass-Qnty    as  decimal
    field   OutExtKass-CostSum as  decimal
    field   OutExtKass-SaleSum as  decimal
    field   Spi-Qnty           as  decimal
    field   Spi-CostSum        as  decimal
    field   InProiz-Qnty       as  decimal
    field   InProiz-CostSum    as  decimal
    field   OutProiz-Qnty      as  decimal
    field   OutProiz-CostSum   as  decimal
    field   num-tov            as integer

    INDEX pi  IS PRIMARY grp-name
    INDEX pi1            grp-code
  .

  define temp-table gds-gr no-undo like gds-prop . /* для списка групп */


  define variable  Counter1    as integer   no-undo .
  define variable  ii          as integer   no-undo .
  define variable  CurrGrpName as character no-undo .
  define variable  str-find    as character no-undo .
  define variable  str-find1   as character no-undo .
  define variable  str-find2   as character no-undo .

  define variable v-row       as integer   no-undo .
  define variable v-col       as integer   no-undo .
  define variable v-ind       as integer   no-undo initial 1 .

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

  assign Counter1 = 0 .

  for each temp-mag :
    for each buf_gds-obj no-lock
      where buf_gds-obj.obj-type  = temp-mag.obj-type
        and buf_gds-obj.obj-code  = temp-mag.obj-code
      :
      if buf_gds-obj.last-doc < p-date1 and buf_gds-obj.fact-qnty = 0 and buf_gds-obj.avrg-qnty = 0 and buf_gds-obj.fact-sale =0 and buf_gds-obj.fact-base = 0 then next .

      assign Counter1 = Counter1 + 1.
      { rep/repfrm.i disp Counter1 }

      find first buf_goods no-lock where buf_goods.gds-code = buf_gds-obj.gds-code .
      find first gds-prop where gds-prop.grp-name = buf_gds-obj.grp-name no-error .
      if not available gds-prop then do:
        create gds-prop .
        assign
          gds-prop.grp-code = buf_goods.grp-code
          gds-prop.grp-name = buf_goods.grp-name
        .
      end.

      /* ОСТАТКИ */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-cost}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.EndWay-Qnty    = gds-prop.EndWay-Qnty  +  buf_stk-line.fact-qnty
          gds-prop.EndWay-CostSum = gds-prop.EndWay-CostSum + buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = {&arh-cost}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.StartWay-Qnty  = gds-prop.StartWay-Qnty + buf_stk-line.fact-qnty
          gds-prop.StartWay-CostSum = gds-prop.StartWay-CostSum + buf_stk-line.sum-rubl
        .
      end.
      /* обороты */
      if buf_goods.gds-type = {&gds-office} then do:
        assign
          str-find  = {&arh-csdt-service}
          str-find1 = {&arh-sadt-service}
          str-find2 = {&arh-cgdt-service}
        .
      end.
      else do:
        assign
          str-find  = {&arh-csdt}
          str-find1 = {&arh-sadt}
          str-find2 = {&arh-cgdt}
        .
      end.
      /* ПРИХОД внешний */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Pri_Vnesh}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.InExt-Qnty    = gds-prop.InExt-Qnty + buf_stk-line.fact-qnty
          gds-prop.InExt-CostSum = gds-prop.InExt-CostSum + buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Pri_Vnesh}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.InExt-Qnty = gds-prop.InExt-Qnty - buf_stk-line.fact-qnty
          gds-prop.InExt-CostSum = gds-prop.InExt-CostSum - buf_stk-line.sum-rubl
        .
      end.

      /* ***************************************************************************************** */
      /* нужны обороты ВОЗВРАТОВ ПОСТАВ. */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Ras_Vnesh_VP}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.RetPost-Qnty = gds-prop.RetPost-Qnty - buf_stk-line.fact-qnty
          gds-prop.RetPost-CostSum = gds-prop.RetPost-CostSum - buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Ras_Vnesh_VP}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.RetPost-Qnty = gds-prop.RetPost-Qnty + buf_stk-line.fact-qnty
          gds-prop.RetPost-CostSum = gds-prop.RetPost-CostSum + buf_stk-line.sum-rubl
        .
      end.

      /* ***************************************************************************************** */
      /* нужны обороты ВНЕШ. РАСХОД */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Ras_Vnesh}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.OutExt-CostSum = gds-prop.OutExt-CostSum - buf_stk-line.sum-rubl
          gds-prop.OutExt-Qnty    = gds-prop.OutExt-Qnty    - buf_stk-line.fact-qnty
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Ras_Vnesh}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.OutExt-CostSum = gds-prop.OutExt-CostSum + buf_stk-line.sum-rubl
          gds-prop.OutExt-Qnty    = gds-prop.OutExt-Qnty    + buf_stk-line.fact-qnty
        .
      end.
    /* ***************************************************************************************** */
    /* нужны обороты ВНЕШ. ВОЗВРАТ */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Vozvrat_Vnesh}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.OutExt-CostSum = gds-prop.OutExt-CostSum - buf_stk-line.sum-rubl
          gds-prop.OutExt-Qnty    = gds-prop.OutExt-Qnty    - buf_stk-line.fact-qnty
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Vozvrat_Vnesh}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.OutExt-CostSum = gds-prop.OutExt-CostSum + buf_stk-line.sum-rubl
          gds-prop.OutExt-Qnty    = gds-prop.OutExt-Qnty + buf_stk-line.fact-qnty
        .
      end.

      /* ***************************************************************************************** */
      /* нужны обороты ВНЕШ. РАСХОД КАССА  */
      assign ii = 0 .
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Ras_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          ii = buf_stk-line.fact-qnty
          gds-prop.OutExtKass-Qnty = gds-prop.OutExtKass-Qnty - buf_stk-line.fact-qnty
          gds-prop.OutExtKass-CostSum = gds-prop.OutExtKass-CostSum - buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Ras_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          ii = ii - buf_stk-line.fact-qnty
          gds-prop.OutExtKass-Qnty = gds-prop.OutExtKass-Qnty + buf_stk-line.fact-qnty
          gds-prop.OutExtKass-CostSum = gds-prop.OutExtKass-CostSum + buf_stk-line.sum-rubl
        .
      end.

      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Ras_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign gds-prop.OutExtKass-SaleSum   = gds-prop.OutExtKass-SaleSum - buf_stk-line.sum-rubl .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Ras_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign gds-prop.OutExtKass-SaleSum   = gds-prop.OutExtKass-SaleSum   + buf_stk-line.sum-rubl .
      end.
      if ii <> 0 then run FindTov in this-procedure .
      /* ***************************************************************************************** */
      /* нужны обороты ВНЕШ. ВОЗВРАТ КАССА  */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Vozvrat_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.OutExtKass-Qnty = gds-prop.OutExtKass-Qnty - buf_stk-line.fact-qnty
          gds-prop.OutExtKass-CostSum = gds-prop.OutExtKass-CostSum - buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Vozvrat_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.OutExtKass-Qnty = gds-prop.OutExtKass-Qnty + buf_stk-line.fact-qnty
          gds-prop.OutExtKass-CostSum = gds-prop.OutExtKass-CostSum + buf_stk-line.sum-rubl
        .
      end.

      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Vozvrat_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign gds-prop.OutExtKass-SaleSum   = gds-prop.OutExtKass-SaleSum   - buf_stk-line.sum-rubl .
      end.

      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find2 + {&TDEDT_Vozvrat_Vnesh_Kass}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign gds-prop.OutExtKass-SaleSum   = gds-prop.OutExtKass-SaleSum   + buf_stk-line.sum-rubl .
      end.

      /* ***************************************************************************************** */
      /* нужны обороты СПИСАНИЕ. */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Spi_Vnesh}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.Spi-Qnty = gds-prop.Spi-Qnty - buf_stk-line.fact-qnty
          gds-prop.Spi-CostSum = gds-prop.Spi-CostSum - buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Spi_Vnesh}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          gds-prop.Spi-Qnty = gds-prop.Spi-Qnty + buf_stk-line.fact-qnty
          gds-prop.Spi-CostSum = gds-prop.Spi-CostSum + buf_stk-line.sum-rubl
        .
    end.

      /* ***************************************************************************************** */
      /* нужны обороты ПРОИЗ-ВО ПРИХОД */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Pri_Prvo}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.InProiz-Qnty = gds-prop.InProiz-Qnty + buf_stk-line.fact-qnty
          gds-prop.InProiz-CostSum = gds-prop.InProiz-CostSum + buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Pri_Prvo}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.InProiz-Qnty = gds-prop.InProiz-Qnty - buf_stk-line.fact-qnty
          gds-prop.InProiz-CostSum = gds-prop.InProiz-CostSum - buf_stk-line.sum-rubl
        .
      end.

      /* ***************************************************************************************** */
      /* нужны обороты ПРОИЗ-ВО РАСХОД */
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Spi_Prvo}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order < v-fact-order-end
        use-index category no-error .
      if available buf_stk-line then do:
        assign
          gds-prop.OutProiz-Qnty = gds-prop.OutProiz-Qnty - buf_stk-line.fact-qnty
          gds-prop.OutProiz-CostSum = gds-prop.OutProiz-CostSum - buf_stk-line.sum-rubl
        .
      end.
      find last buf_stk-line no-lock
        where buf_stk-line.obj-type  = buf_gds-obj.obj-type
          and buf_stk-line.obj-code  = buf_gds-obj.obj-code
          and buf_stk-line.artic     = buf_gds-obj.artic
          and buf_stk-line.prod-type = buf_gds-obj.prod-type
          and buf_stk-line.prod-code = buf_gds-obj.prod-code
          and buf_stk-line.sum-type  = str-find + {&TDEDT_Spi_Prvo}
          and buf_stk-line.cat-id    = '##,##'
          and buf_stk-line.fact-order <= v-fact-order-start
        use-index category no-error .

      if available buf_stk-line then do:
        assign
          gds-prop.OutProiz-Qnty = gds-prop.OutProiz-Qnty + buf_stk-line.fact-qnty
          gds-prop.OutProiz-CostSum = gds-prop.OutProiz-CostSum + buf_stk-line.sum-rubl
        .
      end.
    end.
  end.

  for each temp-tov break by temp-tov.grp-code :
    if first-of(temp-tov.grp-code) then do:
      find first gds-prop where gds-prop.grp-code = temp-tov.grp-code .
    end.
    assign gds-prop.num-tov = gds-prop.num-tov + 1 .
  end.

  for each gds-prop: /* теперь создаем и считаем нетерминальные группы */
    if  gds-prop.StartWay-Qnty      = 0 and
        gds-prop.StartWay-CostSum   = 0 and
        gds-prop.EndWay-Qnty        = 0 and
        gds-prop.EndWay-CostSum     = 0 and
        gds-prop.InExt-Qnty         = 0 and
        gds-prop.InExt-CostSum      = 0 and
        gds-prop.RetPost-Qnty       = 0 and
        gds-prop.RetPost-CostSum    = 0 and
        gds-prop.OutExt-Qnty        = 0 and
        gds-prop.OutExt-CostSum     = 0 and
        gds-prop.OutExtKass-Qnty    = 0 and
        gds-prop.OutExtKass-CostSum = 0 and
        gds-prop.OutExtKass-SaleSum = 0 and
        gds-prop.Spi-Qnty           = 0 and
        gds-prop.Spi-CostSum        = 0 and
        gds-prop.InProiz-Qnty       = 0 and
        gds-prop.InProiz-CostSum    = 0 and
        gds-prop.OutProiz-Qnty      = 0 and
        gds-prop.OutProiz-CostSum   = 0 and
        gds-prop.num-tov            = 0 then next .
    create gds-gr .
    buffer-copy gds-prop to gds-gr .
    find first buf_gds-grp no-lock where buf_gds-grp.node-code = gds-prop.grp-code .
    do while buf_gds-grp.upper-code > 0 :
      assign  gds-gr.sgrp-name = buf_gds-grp.node-name .
      find first gds-gr where gds-gr.grp-code = buf_gds-grp.upper-code no-error .

      if not available gds-gr then do:
        create gds-gr .
        assign gds-gr.grp-code  = buf_gds-grp.upper-code .
        run grplib-get-full-name (input gds-gr.grp-code, output gds-gr.grp-name) .
      end.
      assign
        gds-gr.StartWay-Qnty      = gds-gr.StartWay-Qnty      + gds-prop.StartWay-Qnty
        gds-gr.StartWay-CostSum   = gds-gr.StartWay-CostSum   + gds-prop.StartWay-CostSum
        gds-gr.EndWay-Qnty        = gds-gr.EndWay-Qnty        + gds-prop.EndWay-Qnty
        gds-gr.EndWay-CostSum     = gds-gr.EndWay-CostSum     + gds-prop.EndWay-CostSum
        gds-gr.InExt-Qnty         = gds-gr.InExt-Qnty         + gds-prop.InExt-Qnty
        gds-gr.InExt-CostSum      = gds-gr.InExt-CostSum      + gds-prop.InExt-CostSum
        gds-gr.RetPost-Qnty       = gds-gr.RetPost-Qnty       + gds-prop.RetPost-Qnty
        gds-gr.RetPost-CostSum    = gds-gr.RetPost-CostSum    + gds-prop.RetPost-CostSum
        gds-gr.OutExt-Qnty        = gds-gr.OutExt-Qnty        + gds-prop.OutExt-Qnty
        gds-gr.OutExt-CostSum     = gds-gr.OutExt-CostSum     + gds-prop.OutExt-CostSum
        gds-gr.OutExtKass-Qnty    = gds-gr.OutExtKass-Qnty    + gds-prop.OutExtKass-Qnty
        gds-gr.OutExtKass-CostSum = gds-gr.OutExtKass-CostSum + gds-prop.OutExtKass-CostSum
        gds-gr.OutExtKass-SaleSum = gds-gr.OutExtKass-SaleSum + gds-prop.OutExtKass-SaleSum
        gds-gr.Spi-Qnty           = gds-gr.Spi-Qnty           + gds-prop.Spi-Qnty
        gds-gr.Spi-CostSum        = gds-gr.Spi-CostSum        + gds-prop.Spi-CostSum
        gds-gr.InProiz-Qnty       = gds-gr.InProiz-Qnty       + gds-prop.InProiz-Qnty
        gds-gr.InProiz-CostSum    = gds-gr.InProiz-CostSum    + gds-prop.InProiz-CostSum
        gds-gr.OutProiz-Qnty      = gds-gr.OutProiz-Qnty      + gds-prop.OutProiz-Qnty
        gds-gr.OutProiz-CostSum   = gds-gr.OutProiz-CostSum   + gds-prop.OutProiz-CostSum
        gds-gr.num-tov            = gds-gr.num-tov            + gds-prop.num-tov
      .
      find first buf_gds-grp no-lock where buf_gds-grp.node-code = gds-gr.grp-code .
    end.
  end.


  /* macr_excel - для экселя */
  assign
  v-file-name = v-file-prefix + ".txt"
  .

  output stream macr_excel to value(v-file-name) .
  assign v-ind = v-ind + 1 .

  { gbl/working.i }

  run PutColumnTitulExcel in this-procedure .

  for each gds-gr:
    if gds-gr.grp-name = "" then next .
    assign v-col = 1 .
    run macr_excel_char ( string(gds-gr.grp-code)  , v-row, v-col) .    assign v-col = v-col + 1 .
    case num-entries( right-trim(gds-gr.grp-name, {&delim-grp}), {&delim-grp} ) :
      when 1 then assign v-col = 2 .
      when 2 then assign v-col = 3 .
      otherwise   assign v-col = 4 .
    end.
    run macr_excel_char ( gds-gr.sgrp-name          , v-row, v-col) .
    assign v-col = 5 .
/*    run macr_excel_char ( gds-gr.grp-name          , v-row, v-col) .    assign v-col = v-col + 1 .*/
    run macr_excel_sum1  ( gds-gr.num-tov           , v-row, v-col, 0) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.StartWay-CostSum  , v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.InExt-CostSum     , v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.OutExt-CostSum    , v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.RetPost-CostSum   , v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.OutExtKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 .

    put stream macr_excel unformatted substitute('select("r&1c&2")', v-row , v-col ) + {&new-line} .
    put stream macr_excel unformatted 'format.number("#,##0.00")' + {&new-line} .
    put stream macr_excel unformatted substitute('formula("=(r&1c10 - r&1c11)","r&1c&2")', v-row , v-col ) skip  .
    assign v-col = v-col + 1 .
    put stream macr_excel unformatted substitute('select("r&1c&2")', v-row , v-col ) + {&new-line} .
    put stream macr_excel unformatted 'format.number("0.00%")' + {&new-line} .
    put stream macr_excel unformatted substitute('formula("=(r&1c10 - r&1c11)/r&1c11","r&1c&2")', v-row , v-col ) skip  .
    assign v-col = v-col + 1 .
    put stream macr_excel unformatted substitute('select("r&1c&2")', v-row , v-col ) + {&new-line} .
    put stream macr_excel unformatted 'format.number("0.00%")' + {&new-line} .
    put stream macr_excel unformatted substitute('formula("=(r&1c10 - r&1c11)/r&1c10","r&1c&2")', v-row , v-col ) skip  .
    assign v-col = v-col + 1 .
/*    run macr_excel_sum1  ( gds-gr.OutExtKass-SaleSum - gds-gr.OutExtKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 .*/
/*    run macr_excel_sum1  ( (gds-gr.OutExtKass-SaleSum - gds-gr.OutExtKass-CostSum) / gds-gr.OutExtKass-CostSum, v-row, v-col, 2) . assign v-col = v-col + 1 .*/
/*    run macr_excel_sum1  ( (gds-gr.OutExtKass-SaleSum - gds-gr.OutExtKass-CostSum) / gds-gr.OutExtKass-SaleSum, v-row, v-col, 2) . assign v-col = v-col + 1 .*/
    run macr_excel_sum1  ( gds-gr.Spi-CostSum       , v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.InProiz-CostSum   , v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.OutProiz-CostSum  , v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.EndWay-CostSum    , v-row, v-col, 2) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.StartWay-Qnty     , v-row, v-col, 3) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.InExt-Qnty        , v-row, v-col, 3) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.OutExt-Qnty       , v-row, v-col, 3) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.RetPost-Qnty      , v-row, v-col, 3) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.OutExtKass-Qnty   , v-row, v-col, 3) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.Spi-Qnty          , v-row, v-col, 3) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.InProiz-Qnty      , v-row, v-col, 3) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.OutProiz-Qnty     , v-row, v-col, 3) . assign v-col = v-col + 1 .
    run macr_excel_sum1  ( gds-gr.EndWay-Qnty       , v-row, v-col, 3) .
    assign v-row = v-row + 1 .
  end.

  put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 7 , 1 , v-row - 1 , v-col ) skip .
/*  put  stream macr_excel unformatted 'row.height(10,,,) '  skip .*/
  put  stream macr_excel unformatted 'BORDER( 0 , 7 , 7 , 7 , 7 , ,0,0,0,0,0) '  skip .
  put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 7 , 2 , v-row - 1 , 2 ) skip .
  put  stream macr_excel unformatted 'BORDER( 0, 7, 0, 7, 7, ,0,0,0,0,0) '  skip .
  put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 7 , 3 , v-row - 1 , 3 ) skip .
  put  stream macr_excel unformatted 'BORDER( 0, 0, 0, 7, 7, ,0,0,0,0,0) '  skip .
  put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 7 , 4 , v-row - 1 , 4 ) skip .
  put  stream macr_excel unformatted 'BORDER( 0, 0, 7, 7, 7, ,0,0,0,0,0) '  skip .
  put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , 7 , 18 , v-row - 1 , 18 ) skip .
  put  stream macr_excel unformatted 'BORDER( 0, 7, 1, 7, 7, ,0,0,0,0,0) '  skip .

/*  find first gds-gr where gds-gr.grp-name = "" .  /* итого */*/
/*  if available gds-gr then do:*/

/*    run macr_cell_bordur ( v-row, 1, v-row, v-col) .*/
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 1 , v-row , v-col ) skip .
    put  stream macr_excel unformatted 'ALIGNMENT( 4, , 2, ,)'   skip  .
    put  stream macr_excel unformatted 'BORDER( 0, 1, 1, 1, 1, ,0,0,0,0,0) '  skip .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 2 , v-row , 2 ) skip .
    put  stream macr_excel unformatted 'row.height(10,,,) '  skip .
    put  stream macr_excel unformatted 'BORDER( 0, 1, 0, 1, 1, ,0,0,0,0,0) '  skip .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 3 , v-row , 3 ) skip .
    put  stream macr_excel unformatted 'BORDER( 0, 0, 0, 1, 1, ,0,0,0,0,0) '  skip .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 4 , v-row , 4 ) skip .
    put  stream macr_excel unformatted 'BORDER( 0, 0, 1, 1, 1, ,0,0,0,0,0) '  skip .


    assign v-col = 1 .
    run macr_excel_char (  "итого"   , v-row, v-col) .
    assign v-col = 5 .
    run macr_excel_sum2  ( v-row , v-col, 0) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    put stream macr_excel unformatted substitute('select("r&1c&2")', v-row , v-col ) + {&new-line} .
    put stream macr_excel unformatted 'format.number("#,##0.00")' + {&new-line} .
    put stream macr_excel unformatted substitute('formula("=(r&1c10 - r&1c11)","r&1c&2")', v-row , v-col ) skip  .
    assign v-col = v-col + 1 .
    put stream macr_excel unformatted substitute('select("r&1c&2")', v-row , v-col ) + {&new-line} .
    put stream macr_excel unformatted 'format.number("0.00%")' + {&new-line} .
    put stream macr_excel unformatted substitute('formula("=(r&1c10 - r&1c11)/r&1c11","r&1c&2")', v-row , v-col ) skip  .
    assign v-col = v-col + 1 .
    put stream macr_excel unformatted substitute('select("r&1c&2")', v-row , v-col ) + {&new-line} .
    put stream macr_excel unformatted 'format.number("0.00%")' + {&new-line} .
    put stream macr_excel unformatted substitute('formula("=(r&1c10 - r&1c11)/r&1c10","r&1c&2")', v-row , v-col ) skip  .
    assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 2) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .  assign v-col = v-col + 1 .
    run macr_excel_sum2  ( v-row , v-col, 3) .

    run macr_cell_format1 ( 'Tahoma',8, yes, no, ?, 2, 1, 6, v-col) .
    run macr_cell_format1 ( 'Tahoma',8, no, no, ?, 7, 1, v-row - 1, v-col) .
    run macr_cell_format1 ( 'Tahoma',8, yes, no, ?, v-row, 1, v-row, v-col) .
    put  stream macr_excel unformatted substitute('select("r1c4:r&1c&2 ")' , v-row, v-col)  skip .
    put  stream macr_excel unformatted 'COLUMN.WIDTH(,,,3,) '  skip .
    put  stream macr_excel unformatted substitute('select("r7c1:r&1c&2 ")' , v-row, v-col)  skip .
    put  stream macr_excel unformatted 'row.height(,,3,) '  skip .
    put  stream macr_excel unformatted substitute('select("r1c1:r5c&2 ")' , v-row, v-col)  skip .
    put  stream macr_excel unformatted 'row.height(,,3,) '  skip .

  output stream macr_excel close .
  run paramls-write in this-procedure (input "file",input string(v-ind),input v-file-name) .

  run end-proc1 .

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  { gbl/stopwork.i }

  run rep/runexlmk.p (v-file-name, "Первичный отчет по группам").
end.

/* ******************************************************* */





procedure FindTov :
  do
  on error undo, return error return-value
  :
      find first temp-tov
        where temp-tov.artic     = buf_gds-obj.artic
          and temp-tov.prod-type = buf_gds-obj.prod-type
          and temp-tov.prod-code = buf_gds-obj.prod-code
      no-error .
      if not available temp-tov then do:
        create temp-tov .
        assign
          temp-tov.artic     = buf_gds-obj.artic
          temp-tov.prod-type = buf_gds-obj.prod-type
          temp-tov.prod-code = buf_gds-obj.prod-code
          temp-tov.grp-code  = buf_goods.grp-code
        .
      end.
  end.
end procedure. /* FindTov */


procedure PutColumnTitulExcel : /* заголовки для колонок экселя */
  do
  on error undo, return error return-value
  :
    assign
      v-row = 1
      v-col = 1
    .

    put  stream macr_excel unformatted substitute('select("r1c1:r1c1 ")' )  skip .
    put  stream macr_excel unformatted 'row.height(15,,,) '  skip .
    put  stream macr_excel unformatted substitute('select("r2c1:r5c1 ")' )  skip .
    put  stream macr_excel unformatted 'row.height(10.5,,,) '  skip .
    put  stream macr_excel unformatted substitute('select("r6c1:r6c1 ")' )  skip .
    put  stream macr_excel unformatted 'row.height(33,,,) '  skip .

    /*run macr_excel_char ("Приложение 2", v-row,  v-col) .*/
    run macr_cell_format1 ( 'Tahoma', 12, yes, no, ?, 1, 1, 1, 1) .
    assign  v-row = v-row + 1 .
    run macr_excel_char ("Оборотная ведомость по группам товаров", v-row,  v-col) .
    assign  v-row = v-row + 1 .
    run macr_excel_char ("Период: с " + string(p-date1,"99.99.9999") + " по " + string(p-date2 - 1,"99.99.9999"), v-row,  v-col) .
    assign  v-row = v-row + 1 .
    assign CurrGrpName = "Список объектов: " .
    for each temp-mag:
      if length(CurrGrpName) + 1 + length(temp-mag.obj-name) > 255 then do:
        run macr_excel_char (CurrGrpName, v-row, v-col) .
        assign  v-row = v-row + 1 .
        CurrGrpName = "".
    end.
      assign
      CurrGrpName = CurrGrpName + (if CurrGrpName = "Список объектов: "
                                    or CurrGrpName = ""
                                    then ''
                                    else  "; ") + temp-mag.obj-name .
    end.
    if CurrGrpName  <> '' then do:
    run macr_excel_char (CurrGrpName, v-row, v-col) .
    end.
    assign  v-row = v-row + 2 .

    run macr_excel_char("код группы", v-row, v-col) .                        assign  v-col = v-col + 1 .
    run macr_excel_char("название группы", v-row, 2) .
    assign  v-col = 5.
    run macr_excel_char("ассортимент, кол-во наименований", v-row, v-col) .  assign  v-col = v-col + 1 .
    run macr_excel_char("остаток на начало, уч.цена", v-row, v-col) .        assign  v-col = v-col + 1 .
    run macr_excel_char("приход внешний, уч.цена", v-row, v-col) .           assign  v-col = v-col + 1 .
    run macr_excel_char("расход внешний, уч.цена", v-row, v-col) .           assign  v-col = v-col + 1 .
    run macr_excel_char("возврат пост-ку, уч.цена", v-row, v-col) .          assign  v-col = v-col + 1 .
    run macr_excel_char("реализация розничная, прод.цена", v-row, v-col) .   assign  v-col = v-col + 1 .
    run macr_excel_char("реализация розничная, уч.цена", v-row, v-col) .     assign  v-col = v-col + 1 .
    run macr_excel_char("прибыль розничная", v-row, v-col) .                 assign  v-col = v-col + 1 .
    run macr_excel_char("торговая наценка розничная", v-row, v-col) .        assign  v-col = v-col + 1 .
    run macr_excel_char("маржа розничная", v-row, v-col) .                   assign  v-col = v-col + 1 .
    run macr_excel_char("списано, уч.цена", v-row, v-col) .                  assign  v-col = v-col + 1 .
    run macr_excel_char("приход про-во, уч.цена", v-row, v-col) .            assign  v-col = v-col + 1 .
    run macr_excel_char("расход про-во, уч.цена", v-row, v-col) .            assign  v-col = v-col + 1 .
    run macr_excel_char("остаток на конец, уч.цена", v-row, v-col) .         assign  v-col = v-col + 1 .
    run macr_excel_char("остаток на начало, кол-во", v-row, v-col) .         assign  v-col = v-col + 1 .
    run macr_excel_char("приход внешний, кол-во", v-row, v-col) .            assign  v-col = v-col + 1 .
    run macr_excel_char("расход внешний, кол-во", v-row, v-col) .            assign  v-col = v-col + 1 .
    run macr_excel_char("возврат пост-ку, кол-во", v-row, v-col) .           assign  v-col = v-col + 1 .
    run macr_excel_char("реализация розничная, кол-во", v-row, v-col) .      assign  v-col = v-col + 1 .
    run macr_excel_char("списано, кол-во", v-row, v-col) .                   assign  v-col = v-col + 1 .
    run macr_excel_char("приход про-во, кол-во", v-row, v-col) .             assign  v-col = v-col + 1 .
    run macr_excel_char("расход про-во, кол-во", v-row, v-col) .             assign  v-col = v-col + 1 .
    run macr_excel_char("остаток на конец, кол-во", v-row, v-col) .
/*    run macr_cell_bordur ( v-row, 1, v-row, v-col) .*/
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 1 , v-row , v-col ) skip .
    put  stream macr_excel unformatted 'BORDER( 0 , 1 , 1 , 1 , 1 , ,0,0,0,0,0) '  skip .
    put  stream macr_excel unformatted 'ALIGNMENT( 2, true, 2, ,)'   skip  .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 2 , v-row , 2 ) skip .
    put  stream macr_excel unformatted 'ALIGNMENT( 2, false, 2, ,)'   skip  .
    run macr_cell_size ( 6,?, v-row,  1, ?    , ?).
    run macr_cell_size ( 2,?, v-row,  2, ?    , 3).
    run macr_cell_size (29,?, v-row,  4, ?    , ?).
    run macr_cell_size (13,?, v-row,  5, v-row, 5) .
    run macr_cell_size (29,?, v-row,  4, ?    , ?).
    run macr_cell_size (13,?, v-row,  5, v-row, 5) .
    run macr_cell_size (10,?, v-row,  6, v-row, 6) .
    run macr_cell_size ( 8,?, v-row,  7, v-row, 9) .
    run macr_cell_size (13,?, v-row, 10, v-row, 12) .
    run macr_cell_size (11,?, v-row, 13, v-row, 13) .
    run macr_cell_size (10,?, v-row, 14, v-row, 14) .
    run macr_cell_size ( 8,?, v-row, 15, v-row, 18) .
    run macr_cell_size (10,?, v-row, 19, v-row, 19) .
    run macr_cell_size ( 8,?, v-row, 20, v-row, 22) .
    run macr_cell_size (10,?, v-row, 23, v-row, 24) .
    run macr_cell_size ( 8,?, v-row, 25, v-row, 26) .
    run macr_cell_size (9,?, v-row, 27, v-row, 27) .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 2 , v-row , 2 ) skip .
    put  stream macr_excel unformatted 'BORDER( 0, 7, 0, 1, 1, ,0,0,0,0,0) '  skip .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 3 , v-row , 3 ) skip .
    put  stream macr_excel unformatted 'BORDER( 0, 0, 0, 1, 1, ,0,0,0,0,0) '  skip .
    put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , v-row , 4 , v-row , 4 ) skip .
    put  stream macr_excel unformatted 'BORDER( 0, 0, 7, 1, 1, ,0,0,0,0,0) '  skip .
    assign  v-row = v-row + 1 .
  end.
end procedure. /* PutColumnTitulExcel */



procedure end-proc1 :
 do
 on error undo, return error return-value
 :
  assign
  v-file-name = v-file-prefix + ".t-t"
  .

  OUTPUT to VALUE (v-file-name) .
  for each temp-param :   export  temp-param  .  end.

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

  put  stream macr_excel unformatted substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .
  if p-color <> ? then do:
    put  stream macr_excel unformatted substitute('patterns(1,,&1,true)', p-color )  skip  .
  end.
  put  stream macr_excel unformatted
    substitute('format.font("&1",&2,&3,&4,)', p-name, p-size, string ( p-bold  , "true/false" ) , string ( p-italic , "true/false" )) skip .
 end. /* do */
end procedure. /* macr_pattern */


procedure macr_cell_ALIGN :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row    as integer   no-undo .
 define input parameter  p-col    as integer   no-undo .

  put  stream macr_excel unformatted substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row , p-col ) skip .
  put  stream macr_excel unformatted 'ALIGNMENT( 3, , 2, ,)'   skip  .
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

  put  stream macr_excel unformatted  substitute('select("r&1c&2:r&3c&4 ")' , p-row , p-col , p-row-2 , p-col-2 ) skip .
  put  stream macr_excel unformatted 'BORDER( 0 , 7 , 7 , 7 , 7 , ,0,0,0,0,0) '  skip .
 end. /* do */
end procedure. /* macr_cell_bordur */


procedure macr_excel_char1 :
 do
 on error undo, return error return-value
 :
 define input parameter  p-val as character no-undo .
 define input parameter  p-row as integer no-undo .
 define input parameter  p-col as integer no-undo .

    put  stream macr_excel unformatted substitute('formula("&3","r&1c&2")', p-row , p-col , p-val ) skip  .

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
 assign ss = string( Round( p-val, p-typ) ) .

  put stream macr_excel unformatted substitute('select("r&1c&2")', p-row , p-col ) + {&new-line} .
  case p-typ :
    when 0 then   put stream macr_excel unformatted 'format.number("#,##0")' + {&new-line} .
    when 2 then   put stream macr_excel unformatted 'format.number("#,##0.00")' + {&new-line} .
    otherwise     put stream macr_excel unformatted 'format.number("#,##0.000")' + {&new-line} .
  end.
  put stream macr_excel unformatted substitute('formula(" &3","r&1c&2")', p-row , p-col , ss ) skip  .
 end. /* do */
END procedure.

procedure macr_excel_sum2 :
 do
 on error undo, return error return-value
 :
 define input parameter  p-row as integer   no-undo .
 define input parameter  p-col as integer   no-undo .
 define input parameter  p-typ as integer   no-undo .

  put stream macr_excel unformatted substitute('select("r&1c&2")', p-row , p-col ) + {&new-line} .
  case p-typ :
    when 0 then   put stream macr_excel unformatted 'format.number("#,##0")' + {&new-line} .
    when 2 then   put stream macr_excel unformatted 'format.number("#,##0.00")' + {&new-line} .
    otherwise     put stream macr_excel unformatted 'format.number("#,##0.000")' + {&new-line} .
  end.
  put stream macr_excel unformatted substitute('formula("=SUMIF(r7c2:r&4c2,&3,r7c&2:r&4c&2)","r&1c&2")', p-row , p-col,'""<>""', p-row - 1 ) skip  .
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
          and temp-mag.obj-code = p-shop-code no-error.
    if not available temp-mag then do:
      create temp-mag .
      assign
      temp-mag.obj-code   = p-shop-code
      temp-mag.obj-type   = {&shop}
      temp-mag.obj-name   = (if available buf_clients
                              then buf_clients.obj-name
                              else ({&shop} + string(p-shop-code)))
      .
      release temp-mag.
    end.
end.

end procedure. /* cb_set-shops */