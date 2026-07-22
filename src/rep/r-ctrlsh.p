block-level on error undo, throw.
/*

$Revision: 837068ab241e, 1750, rls $
$Author: SMMolotkov $
$Date: Thu Feb 07 16:49:47 2019 +0300 $
$Workfile: r-ctrlsh.p $
$Archive: rep/r-ctrlsh.p $

Отчет 'Контрольная ведомость движения НП'

Автор: Уханов Дмитрий Юрьевич
Дата создания: 11/13/10
Author: Dmitry Ukhanov
Creation date: 11/13/10

*/
define input  parameter parparentproc as handle    no-undo .
define input  parameter p-log-handle  as handle    no-undo .


define variable vss-revision    as character no-undo init "$Revision: 837068ab241e, 1750, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Feb 07 16:49:47 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-ctrlsh.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-ctrlsh.p $":U .
define variable vss-description as character no-undo init "Отчет 'Контрольная ведомость движения НП'".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ gbl/prn-lib.i "new shared" }
{ rep/r-sym.i    }
{ rep/r-gl.i     }
{ gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }
{ gbl/clntattr.i }

&global-define bottom-height 2
&global-define page-height   43

  define variable v-line      as character no-undo .
  define variable v-cnt-obj   as integer   no-undo .
  define variable v-count     as integer   no-undo .
  define variable v-str       as character no-undo .
  define variable v-sign      as decimal   no-undo .
  define variable v-shftrep2  as character no-undo .
  define variable v-attr-type as character no-undo .

  define buffer buf_shift-obj          for ub.shift-obj .
  define buffer previous_shift-obj     for ub.shift-obj .
  define buffer buf_rvs-doc            for ub.rvs-doc .
  define buffer buf_rvs-line           for ub.rvs-line .
  define buffer buf_rvs-line-pump      for ub.rvs-line-pump .
  define buffer previous_rvs-doc       for ub.rvs-doc .
  define buffer previous_rvs-line      for ub.rvs-line .
  define buffer previous_rvs-line-pump for ub.rvs-line-pump .
  define buffer control_rvs-doc        for ub.rvs-doc       .
  define buffer control_rvs-line-pump  for ub.rvs-line-pump .
  define buffer buf_trn-doc            for ub.trn-doc .
  define buffer buf_doc-pl             for ub.doc-pl .

  define variable pol1  as date      no-undo .
  define variable pol2  as character no-undo .
  define variable pol3  as decimal   no-undo .
  define variable pol4  as decimal   no-undo .
  define variable pol5  as decimal   no-undo .
  define variable pol6  as decimal   no-undo .
  define variable pol7  as decimal   no-undo .
  define variable pol8  as decimal   no-undo .
  define variable pol9  as decimal   no-undo .
  define variable pol10 as decimal   no-undo .
  define variable pol11 as decimal   no-undo .
  define variable pol12 as decimal   no-undo .
  define variable pol13 as decimal   no-undo .
  define variable pol14 as decimal   no-undo .
  define variable pol15 as decimal   no-undo .
  define variable pol16 as decimal   no-undo .

  define variable tot-pol3  as decimal   no-undo .
  define variable tot-pol4  as decimal   no-undo .
  define variable tot-pol5  as decimal   no-undo .
  define variable tot-pol6  as decimal   no-undo .
  define variable tot-pol7  as decimal   no-undo .
  define variable tot-pol8  as decimal   no-undo .
  define variable tot-pol9  as decimal   no-undo .
  define variable tot-pol10 as decimal   no-undo .
  define variable tot-pol11 as decimal   no-undo .
  define variable tot-pol12 as decimal   no-undo .
  define variable tot-pol13 as decimal   no-undo .
  define variable tot-pol14 as decimal   no-undo .
  define variable tot-pol15 as decimal   no-undo .
  define variable tot-pol16 as decimal   no-undo .

  &scop All-sym sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 sym9 sym10 sym11 sym12 sym13 sym14 sym15 sym16 sym17

  &scop sym-l column-label ":" format "x(1)":U space( 0 )

  DEFINE FRAME FRAME-1
    sym1  {&sym-l}
    pol1  column-label "1":C8   format "99/99/99":U       space( 0 )
    sym2  {&sym-l}
    pol2  column-label "2":C3   format  "X(3)":U          space( 0 )
    sym3  {&sym-l}
    pol3  column-label "3":C12  format ">>>>>>>9.999":U   space( 0 )
    sym4  {&sym-l}
    pol4  column-label "4":C12  format ">>>>>>>9.999":U   space( 0 )
    sym5  {&sym-l}
    pol5  column-label "5":C12  format ">>>>>>>9.999":U   space( 0 )
    sym6  {&sym-l}
    pol6  column-label "6":C12  format ">>>>>>>9.999":U   space( 0 )
    sym7  {&sym-l}
    pol7  column-label "7":C12  format "->>>>>>>9.999":U   space( 0 )
    sym8  {&sym-l}
    pol8  column-label "8":C9   format ">>>>9.999":U      space( 0 )
    sym9  {&sym-l}
    pol9  column-label "9":C12  format ">>>>>>>9.999":U   space( 0 )
    sym10 {&sym-l}
    pol10 column-label "10":C12 format ">>>>>>>9.999":U   space( 0 )
    sym11 {&sym-l}
    pol11 column-label "11":C13 format ">>>>>>>>9.999":U  space( 0 )
    sym12 {&sym-l}
    pol12 column-label "12":C13 format ">>>>>>>>9.999":U  space( 0 )
    sym13 {&sym-l}
    pol13 column-label "13":C13 format "->>>>>>>9.999":U  space( 0 )
    sym14 {&sym-l}
    pol14 column-label "14":C13 format "->>>>>>>9.999":U  space( 0 )
    sym15 {&sym-l}
    pol15 column-label "15":C12 format "->>>>>>9.999":U   space( 0 )
    sym16 {&sym-l}
    pol16 column-label "16":C12 format "->>>>>>9.999":U   space( 0 )
    sym17 {&sym-l}
  with width {&DOS_CW_2} down stream-io use-text NO-BOX.


do
on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( 1 ) )
on stop   undo, return error substitute( "&1. stop", vss-workfile )
on endkey undo, return error substitute( "&1. endkey", vss-workfile )
:

  run waitfram-show in this-procedure ({&MyWaitMess} ).

    v-cnt-obj = 0.
    for each obj-list :
      v-cnt-obj = v-cnt-obj + 1 .
  end.

  for each sheetf
    where sheetf.sheet-num > 1
  :
    delete sheetf.
  end.
  find first sheetf
    where sheetf.sheet-num = 1
    no-error.
  assign
    sheetf.sizes = ""
  .

  { gbl/getcntxt.i get }

  v-line = fill("-", 230) .

  run prn-lib-open-stream  in this-procedure
    ( input parParentProc
    , input {&page-height}
    , input yes /*p-is-stream*/
    , input no /*p-append*/
    ).

  form header
      v-line format "x(198)":u                at  1
      skip substitute( "стр. &1", page-number(PrnLibStream) ) at 5 "Продолжение - на следующей странице" at 35
      skip
      with frame bottomframe width {&dos_cw_2} page-bottom no-labels no-box .
  view stream PrnLibStream frame bottomframe .

  page stream PrnLibStream .

/*  if x-TOG-Shift = true then do:*/
    assign
      str1 = substitute( "За период с: &1 (порядок смены &2) по: &3 (порядок смены &4)"
                          ,string( x-date-start, "99/99/9999" )
                          ,x-shift-start
                          ,string( x-date-end, "99/99/9999" )
                          ,x-shift-end
                        )
    .
/*  end.*/
/*  else do:*/
/*    assign*/
/*      p-str = substitute( "За период с: &1 по: &2"*/
/*                          ,string( x-date-start, "99/99/9999" )*/
/*                          ,string( x-date-end, "99/99/9999" )*/
/*                        )*/
/*    .*/
/*  end.*/

  assign
    str2 = "":U
    str3 = "":U
    str4 = "":U
  .

  if v-cnt-obj = 1 then do:
    find first obj-list .
    assign
      str2 = substitute( "Объект: &2&1", {&new-line}, obj-list.obj-name )
    .
    put stream prnlibstream unformatted
      "Контрольная ведомость движения НП" at 17 skip
      str1                                at 17 skip
      str2                                at 17 skip
      skip
    .
  end.
  else do:
    put stream prnlibstream unformatted
      "Контрольная ведомость движения НП" at 17 skip
      str1                                at 17 skip
      skip
    .
  end.

  put stream PrnLibStream unformatted
    "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------" skip
    ":  Дата  : С :    Факт. остаток на     :  Поступление за смену   : Реализация :   Тех.  :     Расход - возврат    :      Факт. остаток на     :      Расч. остаток на     :        Разница          :" skip
    ":        : м :      начало смены       :                         :     по     :  пролив :         (касса)         :        конец смены        :        конец смены        :                         :" skip
    ":        :   :-------------------------:-------------------------: счетчикам  : по док. :-------------------------:---------------------------:---------------------------:-------------------------:" skip
    ":        :   :      л     :     кг     :      л     :     кг     :     л      :    л    :     л      :     кг     :      л      :     кг      :      л      :     кг      :     л      :      кг    :" skip
    "-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
  .

  assign
    Sheetf.MergeCellsH = "3:4,5:6,9:10,11:12,13:14,15:16"
    Sheetf.MergeCellsV = "1=1:2/2=1:2"
    Sheetf.Sizes       = "10,3,12,12,10,10,10,10,10,10,12,12,12,12,10,10"
  .
  assign
    Sheetf.Excel-Column-Lable = "Дата"                                + {&comma-char} +
                                "Смена"                               + {&comma-char} +
                                "ФАКТИЧЕСКИЙ ОСТАТОК на начало смены" + {&comma-char} +
                                                                        {&comma-char} +
                                "Поступление за смену"                + {&comma-char} +
                                                                        {&comma-char} +
                                "Реализация по счетчикам"             + {&comma-char} +
                                "Тех. пролив по док."                 + {&comma-char} +
                                "Расход - возврат (касса)"            + {&comma-char} +
                                                                        {&comma-char} +
                                "ФАКТИЧЕСКИЙ ОСТАТОК на конец смены"  + {&comma-char} +
                                                                        {&comma-char} +
                                "РАСЧЕТНЫЙ ОСТАТОК на конец смены"    + {&comma-char} +
                                                                        {&comma-char} +
                                "Разница"                             + {&comma-char} +
                                                                        {&comma-char} +
                            {&new-line}   +
                                                                        {&comma-char} +
                                                                        {&comma-char} +
                                "л"                                   + {&comma-char} +
                                "кг"                                  + {&comma-char} +
                                "л"                                   + {&comma-char} +
                                "кг"                                  + {&comma-char} +
                                "л"                                   + {&comma-char} +
                                "л"                                   + {&comma-char} +
                                "л"                                   + {&comma-char} +
                                "кг"                                  + {&comma-char} +
                                "л"                                   + {&comma-char} +
                                "кг"                                  + {&comma-char} +
                                "л"                                   + {&comma-char} +
                                "кг"                                  + {&comma-char} +
                                "л"                                   + {&comma-char} +
                                "кг"                                  + {&comma-char} +
                            {&new-line} +
                                '="1"'                                + {&comma-char} +
                                '="2"'                                + {&comma-char} +
                                '="3"'                                + {&comma-char} +
                                '="4"'                                + {&comma-char} +
                                '="5"'                                + {&comma-char} +
                                '="6"'                                + {&comma-char} +
                                '="7"'                                + {&comma-char} +
                                '="8"'                                + {&comma-char} +
                                '="9"'                                + {&comma-char} +
                                '="10"'                               + {&comma-char} +
                                '="11"'                               + {&comma-char} +
                                '="12"'                               + {&comma-char} +
                                '="13"'                               + {&comma-char} +
                                '="14"'                               + {&comma-char} +
                                '="15"'                               + {&comma-char} +
                                '="16"'                               + {&comma-char}
    .


  run rep/extitle.p
    ( input 1
    ) no-error.

  view frame frame-1 .

  for each obj-list
  :
    for each gds-list
      break by gds-list.artic
    :
      if v-cnt-obj = 1 then do:
        assign
          v-str = substitute( "Наименование НП: &1", gds-list.gds-name )
        .
      end.
      else do:
        assign
          v-str = substitute( "Объект: &2&1Наименование НП: &3", {&new-line}, obj-list.obj-name, gds-list.gds-name )
        .
      end.
      assign
        v-count = 2
      .
      for each buf_shift-obj  no-lock
        where buf_shift-obj.obj-code   =  obj-list.obj-code
          and buf_shift-obj.obj-type   =  obj-list.obj-type
          and buf_shift-obj.shift-date >= X-date-Start
          and buf_shift-obj.shift-date <= X-date-End
      :
        if x-TOG-Shift = true
          and ( ( buf_shift-obj.shift-date = X-date-Start
                  and buf_shift-obj.shift-num < X-Shift-Start
                )
                or ( buf_shift-obj.shift-date = X-date-End
                    and buf_shift-obj.shift-num > X-Shift-End
                  )
              )
        then do:
          next .
        end.
        assign
          v-count = v-count + 1
        .

      end.

      if page-number( PrnLibstream ) > 1
        and v-count < page-size( PrnLibstream )
                   - {&bottom-height}
                   - 2
                   - (if v-cnt-obj = 1 then 1 else 2)
      then do:
        run on-same-page in this-procedure ({&bottom-height} + v-count ) .
      end.

      display stream PrnLibstream
        with frame frame-1
        .
      put stream PrnLibStream unformatted
        skip
        v-str
        skip
        .
      {&PutExcel}
        {&new-line}
        v-str
        {&new-line}
      .
      if first-of( gds-list.artic ) then do:
        assign
          tot-pol3  = 0.0
          tot-pol4  = 0.0
          tot-pol5  = 0.0
          tot-pol6  = 0.0
          tot-pol7  = 0.0
          tot-pol8  = 0.0
          tot-pol9  = 0.0
          tot-pol10 = 0.0
          tot-pol11 = 0.0
          tot-pol12 = 0.0
          tot-pol13 = 0.0
          tot-pol14 = 0.0
          tot-pol15 = 0.0
          tot-pol16 = 0.0
        .
      end.

      for each buf_shift-obj  no-lock
        where buf_shift-obj.obj-code   =  obj-list.obj-code
          and buf_shift-obj.obj-type   =  obj-list.obj-type
          and buf_shift-obj.shift-date >= X-date-Start
          and buf_shift-obj.shift-date <= X-date-End
        break by buf_shift-obj.shift-date by buf_shift-obj.shift-num
      :
        if x-TOG-Shift = true
          and ( ( buf_shift-obj.shift-date = X-date-Start
                  and buf_shift-obj.shift-num < X-Shift-Start
                )
                or ( buf_shift-obj.shift-date = X-date-End
                    and buf_shift-obj.shift-num > X-Shift-End
                  )
              )
        then do:
          next .
        end.

        assign
          pol1 = (if first-of( buf_shift-obj.shift-date ) then buf_shift-obj.shift-date else ? )
          pol2 = buf_shift-obj.shift-name
          pol3 = 0
          pol4 = 0
        .

        find last previous_shift-obj
          where previous_shift-obj.obj-type = buf_shift-obj.obj-type
            and previous_shift-obj.obj-code = buf_shift-obj.obj-code
            and (( previous_shift-obj.shift-date = buf_shift-obj.shift-date
                  and previous_shift-obj.shift-num < buf_shift-obj.shift-num
                )
                or previous_shift-obj.shift-date < buf_shift-obj.shift-date
                )
            use-index pi no-error.
        if available previous_shift-obj then do:
          find first previous_rvs-doc no-lock
            where previous_rvs-doc.obj-type   = previous_shift-obj.obj-type
              and previous_rvs-doc.obj-code   = previous_shift-obj.obj-code
              and previous_rvs-doc.shift-date = previous_shift-obj.shift-date
              and previous_rvs-doc.shift-num  = previous_shift-obj.shift-num
              and previous_rvs-doc.status_    = {&fact}
              and previous_rvs-doc.rvs-type   = {&rvs-shift}
            no-error .
          if available previous_rvs-doc then do:
            for each previous_rvs-line no-lock
              where previous_rvs-line.gds-code  = gds-list.gds-code
                and previous_rvs-line.rvs-code  = previous_rvs-doc.rvs-code
                and previous_rvs-line.obj-type  = previous_rvs-doc.obj-type
                and previous_rvs-line.obj-code  = previous_rvs-doc.obj-code
            :
              assign
                pol3 = pol3 + previous_rvs-line.state-measure-qnty + previous_rvs-line.state-add-qnty
                pol4 = pol4 + previous_rvs-line.state-measure-cli-qnty + previous_rvs-line.state-add-qnty * previous_rvs-line.state-density
              .
            end.
          end.
        end.

        assign
          pol7  = 0.0
          pol11 = 0.0
          pol12 = 0.0
        .
        for each buf_rvs-doc no-lock
          where buf_rvs-doc.obj-type   = buf_shift-obj.obj-type
            and buf_rvs-doc.obj-code   = buf_shift-obj.obj-code
            and buf_rvs-doc.shift-date = buf_shift-obj.shift-date
            and buf_rvs-doc.shift-num  = buf_shift-obj.shift-num
            and buf_rvs-doc.status_    = {&fact}
            and buf_rvs-doc.rvs-type   = {&rvs-shift}
        :
          for each buf_rvs-line no-lock
            where buf_rvs-line.gds-code  = gds-list.gds-code
              and buf_rvs-line.rvs-code  = buf_rvs-doc.rvs-code
              and buf_rvs-line.obj-type  = buf_rvs-doc.obj-type
              and buf_rvs-line.obj-code  = buf_rvs-doc.obj-code
          :
            assign
              pol11 = pol11 + buf_rvs-line.state-measure-qnty + buf_rvs-line.state-add-qnty
              pol12 = pol12 + buf_rvs-line.state-measure-cli-qnty + buf_rvs-line.state-add-qnty * buf_rvs-line.state-density
            .
          end.

          for each buf_rvs-line-pump no-lock
            where buf_rvs-line-pump.rvs-code = buf_rvs-doc.rvs-code
              and buf_rvs-line-pump.obj-type = buf_shift-obj.obj-type
              and buf_rvs-line-pump.obj-code = buf_shift-obj.obj-code
               /* and для всех buf_rvs-line-pump.pl-code */
              and buf_rvs-line-pump.gds-code = gds-list.gds-code
            break by buf_rvs-line-pump.pump-code
                  by buf_rvs-line-pump.nozzle-code
          :
            /*по одной ТРК надо собрать по всем пистолетам*/
            /* 28/XI-2018  не по "по одной ТРК", а по одному топливу собрать по всем пистолетам всех ТРК */
              assign
                pol7 = pol7 + buf_rvs-line-pump.state-mh-cnt
              .
              /*найдем показания счетного механизма по пистолету в сменной сверке за пред. смену*/
              if available previous_rvs-doc then do:
                find first previous_rvs-line-pump  no-lock
                  where previous_rvs-line-pump.rvs-code    = previous_rvs-doc.rvs-code
                    and previous_rvs-line-pump.obj-code    = buf_shift-obj.obj-code
                    and previous_rvs-line-pump.obj-type    = buf_shift-obj.obj-type
                    and previous_rvs-line-pump.pump-code   = buf_rvs-line-pump.pump-code
                    and previous_rvs-line-pump.nozzle-code = buf_rvs-line-pump.nozzle-code
                  no-error.
                if available previous_rvs-line-pump then do:
                  assign
                    pol7 = pol7 - previous_rvs-line-pump.state-mh-cnt
                  .
                end.
              end.
              if not available previous_rvs-doc
                or not available previous_rvs-line-pump
              then do:
                /*должны найти первую контрольную сверку по текущей смене,  в которой есть эта ТРК, бензин, и пистолет и взять оттуда*/
                for each control_rvs-doc no-lock
                  where control_rvs-doc.obj-type   = buf_shift-obj.obj-type
                    and control_rvs-doc.obj-code   = buf_shift-obj.obj-code
                    and control_rvs-doc.shift-date = buf_shift-obj.shift-date
                    and control_rvs-doc.shift-num  = buf_shift-obj.shift-num
                    and control_rvs-doc.status_    = {&fact}
                    and control_rvs-doc.rvs-type   = {&rvs-control}
                  ,first control_rvs-line-pump no-lock
                  where control_rvs-line-pump.rvs-code    = control_rvs-doc.rvs-code
                    and control_rvs-line-pump.gds-code    = gds-list.gds-code
                    and control_rvs-line-pump.obj-code    = control_rvs-doc.obj-code
                    and control_rvs-line-pump.obj-type    = control_rvs-doc.obj-type
                    and control_rvs-line-pump.pump-code   = buf_rvs-line-pump.pump-code
                    and control_rvs-line-pump.nozzle-code = buf_rvs-line-pump.nozzle-code
                  by control_rvs-doc.fact-order
                :
                  if control_rvs-line-pump.state-mh-cnt <> ? then do:
                    assign
                      pol7 = pol7 - control_rvs-line-pump.state-mh-cnt
                    .
                  end.
                  leave.
                end.
              end.
          end.
        end. /* for each buf_rvs-doc no-lock */

        assign
          pol5  = 0.0
          pol6  = 0.0
          pol8  = 0.0
          pol9  = 0.0
          pol10 = 0.0
          pol13 = pol3
          pol14 = pol4
        .

        for each buf_trn-doc no-lock
          where buf_trn-doc.obj-type   = buf_shift-obj.obj-type
            and buf_trn-doc.obj-code   = buf_shift-obj.obj-code
            and buf_trn-doc.shift-date = buf_shift-obj.shift-date
            and buf_trn-doc.shift-num  = buf_shift-obj.shift-num
            and buf_trn-doc.status_    = {&fact}
        on error undo, return error return-value
        :
          run clntattr-value in this-procedure
            ( input buf_trn-doc.cli-type
            , input buf_trn-doc.cli-code
            , input {&attr-shftrep2}
            , output v-shftrep2
            , output v-attr-type
            ).

/*  if ub.trn-doc.out-code <> '':U*/
/*  and LOOKUP(ub.trn-doc.ext-doc-type, {&sale-add-ext-doc-types}) > 0 then do:*/
/*    find first buf_sale-doc no-lock  where*/
/*             buf_sale-doc.doc-code = ub.trn-doc.doc-code*/
/*         and buf_sale-doc.inkas-code = ub.trn-doc.out-code no-error .*/
/*    if available buf_sale-doc*/
/*    and buf_sale-doc.order > 0 then do:*/
/*      v-sale-auto = yes.*/
/*    end.*/
/*  end.*/

          for each buf_doc-pl no-lock
            where buf_doc-pl.gds-code = gds-list.gds-code
              and buf_doc-pl.obj-code = buf_trn-doc.obj-code
              and buf_doc-pl.obj-type = buf_trn-doc.obj-type
              and buf_doc-pl.out-code = buf_trn-doc.doc-code
          on error undo, return error return-value
          :
            if lookup( buf_trn-doc.ext-doc-type, {&TDEDT_out_list} ) > 0 then do:
              assign
                v-sign = -1.0
              .
            end.
            else do:
              assign
                v-sign = 1.0
              .
              if lookup( buf_trn-doc.ext-doc-type, {&TDEDT_in_list} ) = 0 then do:
                message
                  vss-workfile vss-revision vss-description skip
                  substitute( '&1. Тип "&2" не внесен в списки документов уменьшающих(увеличивающих) остатки!', vss-workfile, buf_trn-doc.ext-doc-type) skip
                  view-as alert-box error .
              end.
            end.

            assign
              pol13 = pol13 + buf_doc-pl.fact-qnty * v-sign
              pol14 = pol14 + buf_doc-pl.cli-fact-qnty * v-sign
            .

            if buf_trn-doc.doc-type = {&income} then do:
              assign
                pol5 = pol5 + buf_doc-pl.fact-qnty
                pol6 = pol6 + buf_doc-pl.cli-fact-qnty
              .
            end.
            else do:
              if v-shftrep2 = "yes" then do:
                assign
                  pol8 = pol8 + buf_doc-pl.fact-qnty
                .
              end.

              if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
                or buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
              then do:
                assign
                  pol9  = pol9  + buf_doc-pl.fact-qnty * v-sign * -1
                  pol10 = pol10 + buf_doc-pl.cli-fact-qnty * v-sign * -1
                .
              end.
            end.
          end.
        end. /* for each ub.trn-doc */

        assign
          pol15 = pol11 - pol13
          pol16 = pol12 - pol14
        .

        display stream PrnLibstream
          {&All-sym}
          pol1  when pol1 <> ?
          pol2
          pol3
          pol4
          pol5  when pol5 <> 0
          pol6  when pol6 <> 0
          pol7  when pol7 <> 0
          pol8  when pol8 <> 0
          pol9  when pol9 <> 0
          pol10 when pol10 <> 0
          pol11
          pol12
          pol13
          pol14
          pol15 when pol15 <> 0
          pol16 when pol16 <> 0
          with frame frame-1
        .
        down stream PrnLibstream
          with frame frame-1.

        {&PutExcel}
          (if pol1 <> ? then string( pol1, "99.99.9999" ) else "":U)  {&tabulation}
          pol2  {&tabulation}
          pol3  {&tabulation}
          pol4  {&tabulation}
          (if pol5  <> 0 then substitute( "&1", pol5  ) else "":U)  {&tabulation}
          (if pol6  <> 0 then substitute( "&1", pol6  ) else "":U)  {&tabulation}
          (if pol7  <> 0 then substitute( "&1", pol7  ) else "":U)  {&tabulation}
          (if pol8  <> 0 then substitute( "&1", pol8  ) else "":U)  {&tabulation}
          (if pol9  <> 0 then substitute( "&1", pol9  ) else "":U)  {&tabulation}
          (if pol10 <> 0 then substitute( "&1", pol10 ) else "":U)  {&tabulation}
          pol11 {&tabulation}
          pol12 {&tabulation}
          pol13 {&tabulation}
          pol14 {&tabulation}
          (if pol15 <> 0 then substitute( "&1", pol15 ) else "":U)  {&tabulation}
          (if pol16 <> 0 then substitute( "&1", pol16 ) else "":U)
          {&new-line}
        .
        assign
          tot-pol5  = tot-pol5  + pol5
          tot-pol6  = tot-pol6  + pol6
          tot-pol7  = tot-pol7  + pol7
          tot-pol8  = tot-pol8  + pol8
          tot-pol9  = tot-pol9  + pol9
          tot-pol10 = tot-pol10 + pol10
          tot-pol15 = tot-pol15 + pol15
          tot-pol16 = tot-pol16 + pol16
        .
      end.
      if last-of( gds-list.artic ) then do:
        display stream PrnLibstream
          {&All-sym}
          "итого"   @ pol1
          tot-pol5  @ pol5
          tot-pol6  @ pol6
          tot-pol7  @ pol7
          tot-pol8  @ pol8
          tot-pol9  @ pol9
          tot-pol10 @ pol10
          tot-pol15 @ pol15
          tot-pol16 @ pol16
          with frame frame-1
        .
/*        underline stream PrnLibstream*/
/*          {&All-sym}*/
/*          {&All-Pol}*/
/*          with frame frame-1.*/
        down stream PrnLibstream
          with frame frame-1.
        {&PutExcel}
          "итого"  {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          substitute( "&1", tot-pol5  ) {&tabulation}
          substitute( "&1", tot-pol6  ) {&tabulation}
          substitute( "&1", tot-pol7  ) {&tabulation}
          substitute( "&1", tot-pol8  ) {&tabulation}
          substitute( "&1", tot-pol9  ) {&tabulation}
          substitute( "&1", tot-pol10 ) {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          {&tabulation}
          substitute( "&1", tot-pol15 ) {&tabulation}
          substitute( "&1", tot-pol16 )
          {&new-line}
        .
      end.
    end.
  end.

  hide frame frame-1 .

  {&closeExcel}

  HIDE STREAM PrnLibStream FRAME BottomFrame .

  Output stream PrnLibStream close.
  run waitfram-hide in this-procedure .

  run prn-lib-prn-file in this-procedure
    ( input parParentProc
    , input 8
    ).

end.

/* позволяет перейти к следующей странице (если это необходимо) */
/* необходимо применять, перед выводом блок из нескольких строк, который должен быть размещен в предлах одной страницы */
procedure on-same-page :
  define input parameter p-line-number as integer no-undo .

  /* запрошенное количество строк превышает размер страницы - не переходим на следующую страницу */
  if p-line-number > page-size( PrnLibstream )
  then do:
    return .
  end.
  if line-counter( PrnLibstream ) + p-line-number > page-size( PrnLibstream )
  then do:
    page stream PrnLibstream .
  end.
end procedure. /* on-same-page */