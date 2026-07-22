block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-ptrcnt.p $
$Archive: rep/r-ptrcnt.p $

Отчет по электронным значениям счетчиков ТРК

Автор: Хныкин Павел Андреевич
Дата создания: 02/26/07
Author: Pavel Khnykin
Creation date: 02/26/07

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ptrcnt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ptrcnt.p $":U .
define variable vss-description as character no-undo init "Отчет по электронным значениям счетчиков ТРК".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ gbl/waitfram.i }
{ trg/factord.i  }
{ gbl/cur-time.i }
{ rep/lkp-font.i }

&scop meas-el-cnt-fmt @
&scop meas-mh-qnty-fmt @
&scop meas-mh-qnty-total-fmt @
&scop meas-el-cnt-width-fmt 20
&scop meas-mh-qnty-width-fmt 20
&scop meas-mh-qnty-total-width-fmt 20


define stream out-stream.

define buffer buf_shift-obj_from  for ub.shift-obj.
define buffer buf_shift-obj_till  for ub.shift-obj.
define buffer buf_shift-obj       for ub.shift-obj.
define buffer buf_rvs-doc         for ub.rvs-doc.
define buffer buf_rvs-line-pump   for ub.rvs-line-pump.
define buffer buf_goods           for ub.goods.

define variable g#report-num      as integer   no-undo .
define variable v-obj-counter     as integer   no-undo .

define variable v-i               as integer   no-undo .
define variable v-j               as integer   no-undo .
define variable v-column-count    as integer   no-undo .
define variable v-start-gds-count as integer   no-undo .
define variable v-line-1          as character no-undo .
define variable v-line-2          as character no-undo .
define variable v-line-v          as character no-undo .
define variable v-clmn-label-1    as character no-undo .
define variable v-clmn-label-2    as character no-undo .
define variable v-clmn-label-3    as character no-undo .
define variable v-clmn-label-4    as character no-undo .
define variable v-clmn-format     as character no-undo .
define variable v-clmn-sizes      as character no-undo .

define temp-table tt-ptrl-goods no-undo like ub.goods
  field obj-type      like ub.shift-obj.obj-type
  field obj-code      like ub.shift-obj.obj-code
index pi is primary unique
  obj-type
  obj-code
  gds-code
.

define temp-table tt-rep-line no-undo
  field obj-type      like ub.rvs-line-pump.obj-type
  field obj-code      like ub.rvs-line-pump.obj-code
  field rvs-code      like ub.rvs-line-pump.rvs-code
  field pump-code     like ub.rvs-line-pump.pump-code
  field gds-code      like ub.rvs-line-pump.gds-code
  field meas-el-cnt   like ub.rvs-line-pump.meas-el-cnt
  field meas-mh-qnty  like ub.rvs-line-pump.meas-mh-qnty
  field shift-date    like ub.shift-obj.shift-date
  field shift-num     like ub.shift-obj.shift-num
  /*
      buf_rvs-line-pump
        meas-el-cnt   - измерения электронного счетчика
        meas-mh-qnty  - измеренный оборот
  */
index pi is unique primary
  obj-type
  obj-code
  rvs-code
  gds-code
  pump-code
index print
  shift-date
  shift-num
  rvs-code
  gds-code
  pump-code
.

define temp-table tt-rep-head no-undo
  field obj-type      like ub.shift-obj.obj-type
  field obj-code      like ub.shift-obj.obj-code
  field gds-code      like ub.goods.gds-code
  field pump-code     like ub.pump.pump-code
  field ptrl-name     like ub.goods.gds-name
  field pump-name     as character
index pi is primary unique
  obj-type
  obj-code
  gds-code
  pump-code
.

function str-format returns character ( val as decimal ) forward.

/* MAIN */
do on error undo, return error return-value :
  run waitfram-show in this-procedure ( "Формирование отчета..." ) .
  empty temp-table tt-rep-head.
  empty temp-table tt-rep-line.
  empty temp-table tt-ptrl-goods.

  /* открываем поток текстового вывода */
  run get-report-num in my-handle (output g#report-num).
  { cmp/open-out.i stream out-stream " " {&CS_PS} }

  run fill-tt-rep-line in this-procedure .
  assign
    v-obj-counter     = 0
    v-start-gds-count = 3
    v-column-count    = v-start-gds-count - 1
  .
  /* формируем шапку отчета */
  for each tt-rep-head no-lock
    break by tt-rep-head.gds-code
          by tt-rep-head.pump-code
  :
      assign
        v-column-count    = v-column-count + 1
        v-start-gds-count = if first-of( tt-rep-head.gds-code ) then v-column-count else v-start-gds-count
        v-line-2          = v-line-2 + substitute(",&1:&2" , v-column-count, v-column-count + 1 )
        v-clmn-format     = v-clmn-format + substitute("&1={&meas-el-cnt-fmt};&2={&meas-mh-qnty-fmt};", v-column-count, v-column-count + 1)
        v-column-count    = v-column-count + 1
        v-clmn-label-1    = v-clmn-label-1 + if first-of( tt-rep-head.gds-code ) then tt-rep-head.ptrl-name + {&comma-char} + {&comma-char} else {&comma-char} + {&comma-char}
        v-clmn-label-2    = v-clmn-label-2 + substitute( "ТРК &1" , tt-rep-head.pump-code ) + {&comma-char} + {&comma-char}
        v-clmn-label-3    = v-clmn-label-3 + "Измеряемые счетчики" + {&comma-char} + "Измеряемые обороты" + {&comma-char}
        v-clmn-sizes      = v-clmn-sizes + "{&meas-el-cnt-width-fmt}"  + {&comma-char} + "{&meas-mh-qnty-width-fmt}"  + {&comma-char}
      .

    if last-of( tt-rep-head.gds-code ) then do :
      assign
        v-column-count    = v-column-count + 1
        v-line-1          = v-line-1 + substitute(",&1:&2", v-start-gds-count ,  v-column-count )
        v-clmn-format     = v-clmn-format + substitute("&1={&meas-mh-qnty-total-fmt};", v-column-count )
        v-start-gds-count = v-column-count
        v-line-v          = v-line-v + substitute("&1=2:3/" , v-column-count )
        v-clmn-label-1    = v-clmn-label-1 + {&comma-char}
        v-clmn-label-2    = v-clmn-label-2 + "Сумма измеряемых оборотов" + {&comma-char}
        v-clmn-label-3    = v-clmn-label-3 + {&comma-char}
        v-clmn-sizes      = v-clmn-sizes + "{&meas-mh-qnty-total-width-fmt}"  + {&comma-char}
      .

    end.

  end.

  if v-column-count = 2 then do:
    message
      "В выбраном диапазоне нет ни одной сверки."
    view-as alert-box information.
    run clear-all in this-procedure .
    return .
  end.

  do v-i = 1 to v-column-count :
    assign
      v-clmn-label-4 = v-clmn-label-4 + string(v-i) + {&comma-char}
    .
  end.

  assign
    v-line-1      = trim( v-line-1 , {&comma-char} )
    v-line-2      = trim( v-line-2 , {&comma-char} )
    v-line-v      = trim( v-line-v , "/" )
    v-clmn-sizes  = trim( v-clmn-sizes , {&comma-char} )
    v-clmn-format = trim( v-clmn-format , ";" )
  .
  assign
    sheetf.sheet-num          = 1
    sheetf.MergeCellsH        = v-line-1 + '/' + v-line-2 + '/'
    sheetf.MergeCellsV        = "1=1:3/2=1:3/" + v-line-v
    sheetf.Excel-Column-Lable = "Смена / Дата"  + {&comma-char} + "Номер документа сверки" + {&comma-char} + v-clmn-label-1
                                + {&new-line}
                                                + {&comma-char}                            + {&comma-char} + v-clmn-label-2
                                + {&new-line}
                                                + {&comma-char}                            + {&comma-char} + v-clmn-label-3
                                + {&new-line}
                                                                                                           + v-clmn-label-4
    sheetf.colformat          = "1=@;2=@" + {&delim-par} + v-clmn-format + {&delim-par} + "Отчет"
    sheetf.Sizes              = "20" + {&comma-char} + "20" + {&comma-char} + v-clmn-sizes

  .
  put stream out-stream unformatted 1 skip 1 skip 1 skip.
  run rep/extitle.p (1).

  for each tt-rep-line no-lock
    break by tt-rep-line.shift-date
          by tt-rep-line.shift-num
          by tt-rep-line.rvs-code
          by tt-rep-line.gds-code
          by tt-rep-line.pump-code
  :
    if first-of(tt-rep-line.rvs-code) then do :
      {&PutExcel}
        substitute("№&1 &2" , tt-rep-line.shift-num , string( tt-rep-line.shift-date , "99.99.99" ) )  {&tabulation}
        tt-rep-line.rvs-code {&tabulation}
      .
    end.
    {&PutExcel}
       tt-rep-line.meas-el-cnt   {&tabulation}
       tt-rep-line.meas-mh-qnty  {&tabulation}
    .
    /* собираем сумму измеряемых оборотов */
    accumulate tt-rep-line.meas-mh-qnty ( TOTAL by tt-rep-line.gds-code ) .
    if last-of(tt-rep-line.gds-code) then do:
      {&PutExcel} accum total by tt-rep-line.gds-code tt-rep-line.meas-mh-qnty.
      if not last-of(tt-rep-line.rvs-code) then {&PutExcel} {&tabulation}.
    end.

    if last-of(tt-rep-line.rvs-code) then do:
        {&PutExcel} skip.
    end.
  end.
  run clear-all in this-procedure .
  /* печатаем */
  define variable v-user-action   as character no-undo .
  define variable v-printed       as logical   no-undo .
  define variable DisabledOptions as integer   no-undo .
  define variable v-orient-page as character no-undo .
  run How-name in this-procedure (
      input ReportPageHeight,
      input ReportPageWidth,
      output v-orient-page )
      .
  if v-orient-page = "A4-lans":U then DisabledOptions = 8 .
                                else DisabledOptions = 0 .

  run gbl/prnfilen.w
      (input  ""
      ,input  DisabledOptions
      ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
      ,input  ReportFontNum
      ,output v-user-action
      ,output v-printed
      ) .

end. /* MAIN */


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
        return error return-value .
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
        return error return-value .
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


procedure fill-petrl-goods-on-object :
/*
Определение топливных товаров с разбивкой по объектам
*/
define buffer buf_goods         for ub.goods.
define buffer buf_units         for ub.units.
define buffer buf_gds-obj       for ub.gds-obj.
define buffer buf_tt-ptrl-goods for tt-ptrl-goods.

define variable v-fact-order-from as decimal   no-undo .
define variable v-fact-order-till as decimal   no-undo .
define variable v-is-petrol as logical   no-undo .
define variable v-is-pieces as logical   no-undo .

do
on error undo, return error return-value
:

  for each obj-list no-lock ,
      each buf_gds-obj no-lock
        where buf_gds-obj.obj-type = obj-list.obj-type
          and buf_gds-obj.obj-code = obj-list.obj-code ,
      each buf_goods no-lock
        where buf_goods.artic     = buf_gds-obj.artic
          and buf_goods.prod-type = buf_gds-obj.prod-type
          and buf_goods.prod-code = buf_gds-obj.prod-code
  :
      { str/is-petrl.i
          buf_goods.artic
          buf_goods.prod-type
          buf_goods.prod-code
          v-is-petrol
          v-is-pieces
          no-error
      }
      if error-status :error or
          v-is-petrol <> yes   or
          v-is-pieces <> no
      then do:
        next .
      end.
      buffer-copy buf_goods to buf_tt-ptrl-goods
        assign
          buf_tt-ptrl-goods.obj-type = obj-list.obj-type
          buf_tt-ptrl-goods.obj-code = obj-list.obj-code
      .
  end.
end.

end procedure. /* fill-petrl-goods-on-object */


procedure fill-tt-rep-line :

define buffer buf_goods       for ub.goods.
define buffer buf_tt-rep-line for tt-rep-line.
define buffer cur_tt-rep-line for tt-rep-line.

define variable v-is-petrol as logical   no-undo .
define variable v-is-pieces as logical   no-undo .

do
on error undo, return error return-value
:

for each obj-list no-lock :
  /* находим первую и последнюю смену по отчету */
  find first buf_shift-obj_from no-lock
    where buf_shift-obj_from.obj-type    = obj-list.obj-type
      and buf_shift-obj_from.obj-code    = obj-list.obj-code
      and buf_shift-obj_from.shift-date  = x-Date-Start
      and buf_shift-obj_from.shift-num   = x-Shift-Start
  no-error .
  if not available buf_shift-obj_from then do:
      message "Не найдена смена начала отчета." skip
              "Дата:" string( x-Date-Start, "99/99/9999":U ) skip
              "Порядок:" x-Shift-Start
      view-as alert-box error .
      return error .
  end.
  find first buf_shift-obj_till no-lock
    where buf_shift-obj_till.obj-type    = obj-list.obj-type
      and buf_shift-obj_till.obj-code    = obj-list.obj-code
      and buf_shift-obj_till.shift-date  = x-Date-End
      and buf_shift-obj_till.shift-num   = x-Shift-End
  no-error .
  if not available buf_shift-obj_till then do:
      message "Не найдена смена окончания отчета." skip
              "Дата:" string( x-Date-End, "99/99/9999":U ) skip
              "Порядок:" x-Shift-End
      view-as alert-box error .
      return error .
  end.

  for each buf_rvs-doc no-lock
      where buf_rvs-doc.obj-type    = obj-list.obj-type
        and buf_rvs-doc.obj-code    = obj-list.obj-code
        and buf_rvs-doc.shift-date >= x-Date-Start
        and buf_rvs-doc.shift-date <= x-Date-End
        and buf_rvs-doc.status_     = {&fact} ,
      each buf_rvs-line-pump no-lock
      where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
  :
    if buf_rvs-doc.shift-date = x-Date-Start and buf_rvs-doc.shift-num  < x-Shift-Start then next .
    if buf_rvs-doc.shift-date = x-Date-End   and buf_rvs-doc.shift-num  > x-Shift-End   then next .

    find first buf_goods no-lock
      where buf_goods.gds-code = buf_rvs-line-pump.gds-code
    no-error .
    if not available buf_goods then do:
      message
        "Не найден товар с кодом " buf_rvs-line-pump.gds-code
      view-as alert-box error.
      return error return-value.
    end.
    { str/is-petrl.i
        buf_goods.artic
        buf_goods.prod-type
        buf_goods.prod-code
        v-is-petrol
        v-is-pieces
        no-error
    }
    if error-status :error or
        v-is-petrol <> yes   or
        v-is-pieces <> no
    then do:
      next .
    end.
    find first buf_shift-obj no-lock
      where buf_shift-obj.obj-type     = obj-list.obj-type
        and buf_shift-obj.obj-code     = obj-list.obj-code
        and buf_shift-obj.shift-date   = buf_rvs-doc.shift-date
        and buf_shift-obj.shift-num    = buf_rvs-doc.shift-num
    no-error .
    if not available buf_shift-obj then do :
      message
        "Не найдена смена для документа " buf_rvs-line-pump.rvs-code
      view-as alert-box error.
      return error return-value.
    end.
    /* сливаем строки по разным резервуарам и пистолетам в одну ТРК */
    find first tt-rep-line no-lock
      where tt-rep-line.obj-type    = obj-list.obj-type
        and tt-rep-line.obj-code    = obj-list.obj-code
        and tt-rep-line.rvs-code    = buf_rvs-line-pump.rvs-code
        and tt-rep-line.gds-code    = buf_rvs-line-pump.gds-code
        and tt-rep-line.pump-code   = buf_rvs-line-pump.pump-code
    no-error .
    if not available tt-rep-line then do:
      create tt-rep-line.
      assign
        tt-rep-line.obj-type      = obj-list.obj-type
        tt-rep-line.obj-code      = obj-list.obj-code
        tt-rep-line.rvs-code      = buf_rvs-line-pump.rvs-code
        tt-rep-line.gds-code      = buf_rvs-line-pump.gds-code
        tt-rep-line.pump-code     = buf_rvs-line-pump.pump-code

        tt-rep-line.shift-date    = buf_shift-obj.shift-date
        tt-rep-line.shift-num     = buf_shift-obj.shift-num

        tt-rep-line.meas-el-cnt   = if buf_rvs-line-pump.meas-el-cnt = ? then 0 else buf_rvs-line-pump.meas-el-cnt
        tt-rep-line.meas-mh-qnty  = if buf_rvs-line-pump.meas-mh-qnty = ? then 0 else buf_rvs-line-pump.meas-mh-qnty
      .
      find first tt-rep-head no-lock
        where tt-rep-head.obj-type  = obj-list.obj-type
          and tt-rep-head.obj-code  = obj-list.obj-code
          and tt-rep-head.gds-code  = buf_goods.gds-code
          and tt-rep-head.pump-code = buf_rvs-line-pump.pump-code
      no-error.
      if not available tt-rep-head then do :
        create tt-rep-head.
        assign
          tt-rep-head.obj-type  = obj-list.obj-type
          tt-rep-head.obj-code  = obj-list.obj-code
          tt-rep-head.gds-code  = buf_goods.gds-code
          tt-rep-head.pump-code = buf_rvs-line-pump.pump-code
          tt-rep-head.ptrl-name = replace( buf_goods.gds-name , {&comma-char} , " " ) /* в шапке не должно быть запятых */
        .
      end.
    end. /* if not available tt-rep-line */
    else do :
      assign
        tt-rep-line.meas-el-cnt   = tt-rep-line.meas-el-cnt +
                                    if buf_rvs-line-pump.meas-el-cnt = ? then 0 else buf_rvs-line-pump.meas-el-cnt
        tt-rep-line.meas-mh-qnty  = tt-rep-line.meas-mh-qnty +
                                    if buf_rvs-line-pump.meas-mh-qnty = ? then 0 else buf_rvs-line-pump.meas-mh-qnty
      .
    end.
  end.
  /* дополняем нулевыми значениями по всем бензинам все строки документа */
  for each buf_rvs-doc no-lock
      where buf_rvs-doc.obj-type    = obj-list.obj-type
        and buf_rvs-doc.obj-code    = obj-list.obj-code
        and buf_rvs-doc.shift-date >= x-Date-Start
        and buf_rvs-doc.shift-date <= x-Date-End
        and buf_rvs-doc.status_     = {&fact} ,
      first buf_rvs-line-pump no-lock /* в документе должны быть значения счетчиков */
      where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
  :
    if buf_rvs-doc.shift-date = x-Date-Start and buf_rvs-doc.shift-num  < x-Shift-Start then next .
    if buf_rvs-doc.shift-date = x-Date-End   and buf_rvs-doc.shift-num  > x-Shift-End   then next .
    for each tt-rep-head no-lock
      where tt-rep-head.obj-type = obj-list.obj-type
        and tt-rep-head.obj-code = obj-list.obj-code
    :
      find first tt-rep-line no-lock
        where tt-rep-line.obj-type      = obj-list.obj-type
          and tt-rep-line.obj-code      = obj-list.obj-code
          and tt-rep-line.rvs-code      = buf_rvs-doc.rvs-code
          and tt-rep-line.gds-code      = tt-rep-head.gds-code
          and tt-rep-line.pump-code     = tt-rep-head.pump-code
      no-error .
      if not available tt-rep-line then do:
        find first cur_tt-rep-line no-lock
          where cur_tt-rep-line.obj-type      = obj-list.obj-type
            and cur_tt-rep-line.obj-code      = obj-list.obj-code
            and cur_tt-rep-line.rvs-code      = buf_rvs-doc.rvs-code
        no-error .
        if not available cur_tt-rep-line then do:
          message
            "Ошибка при формировании отчета. Не найден документ " buf_rvs-doc.rvs-code
          view-as alert-box error.
          run clear-all in this-procedure .
          return error.
        end.

        create buf_tt-rep-line.
        assign
          buf_tt-rep-line.obj-type      = obj-list.obj-type
          buf_tt-rep-line.obj-code      = obj-list.obj-code
          buf_tt-rep-line.rvs-code      = buf_rvs-doc.rvs-code
          buf_tt-rep-line.gds-code      = tt-rep-head.gds-code
          buf_tt-rep-line.pump-code     = tt-rep-head.pump-code
          buf_tt-rep-line.shift-date    = cur_tt-rep-line.shift-date
          buf_tt-rep-line.shift-num     = cur_tt-rep-line.shift-num
          buf_tt-rep-line.meas-el-cnt   = 0
          buf_tt-rep-line.meas-mh-qnty  = 0
        .
      end.
    end.
  end.

end.
end.
end procedure. /* fill-tt-rep-line */


procedure clear-all :

do
on error undo, return error return-value
:
  empty temp-table tt-rep-head.
  empty temp-table tt-rep-line.
  empty temp-table tt-ptrl-goods.
  output stream out-stream close.
  {&CloseExcel}
  run waitfram-hide in this-procedure .
end.

end procedure. /* clear-all */

function str-format returns character (val as decimal):
  return trim( replace( string( val , ">>>>>>>>9.99" ) , "." , "," ) ) .
end function.