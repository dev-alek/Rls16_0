block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-wth-dc.p $
$Archive: rep/r-wth-dc.p $

Отчет о движении материальных ценностей

Автор: Гридчина Полина Дмитриевна
Дата создания: 09/04/06
Author: Polina Gridchina
Creation date: 09/04/06

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-tog-object  as logical       no-undo .
define input parameter p-tog-total   as logical       no-undo .

&scop f-l            Sparse,Centering,ShiftRight
&scop total-obj-type "---"
&scop total-obj-code -1
&scop text-length    113
                  /*            23                     21                    21                    21                     21          = 113 (107 + 6) */
&scop single-line   Under_Line
&scop total-line    "-----------------------------------------------------------------------------------------------------------------" skip( 0 )
&scop subtotal-line "|-----------------------:---------------------:---------------------:---------------------:---------------------|" skip( 0 )
&scop report-header {&total-line}                                                                                                       skip( 0 ) ~
                 /* "|                       :  Остаток на начало  :   Выручка за смену  : Инкассировано в банк:   Остаток на конец  |" skip( 0 ) */ ~
                 /* "|     № и дата смены    :   периода (на АЗК)  : (в наличных рублях) :      (за смену)     :   периода (на АЗК)  |" skip( 0 ) */ ~
                    "|                       :  Остаток на начало  :                     : Инкассировано в банк:   Остаток на конец  |" skip( 0 ) ~
                    "|     № и дата смены    :   периода (на АЗК)  :   Выручка за смену  :      (за смену)     :   периода (на АЗК)  |" skip( 0 ) ~
                    {&subtotal-line}                                                                                                    skip( 0 )

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-wth-dc.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-wth-dc.p $":U .
define variable vss-description as character no-undo initial "Отчет о движении материальных ценностей":U .

{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i         }
{ str/lib-trn.i         }
{ str/wth-lib.i         }
{ cmp/r-page1.i         }
{ cmp/r-pril.i          }
{ gbl/waitfram.i        }
{ gbl/cur-time.i        }
{ gbl/std-func.i {&f-l} }
{ gbl/getcntxt.i   def  }

define buffer bf_wth-doc  for ub.wth-doc  .
define buffer bf_wth-line for ub.wth-line .
define buffer bf_clients  for ub.clients  .
define buffer bf_object   for ub.clients  .
define buffer bf_sysconf  for ub.sysconf  .

define variable v-own-name as character no-undo .
define variable v-obj-name as character no-undo .
define variable v-temp     as character no-undo .
define variable Under_Line as character no-undo .
define variable t_today    as date      no-undo .
define variable j_time     as integer   no-undo .
define variable j_order    as integer   no-undo initial 0 .
define variable v-del-0    as character no-undo .
define variable v-del-1    as character no-undo .
define variable v-del-2    as character no-undo .
define variable r-rec-line as recid     no-undo .

define variable v-firm-name      as character no-undo .
define variable v-object-name    as character no-undo .
define variable v-object-type    as character no-undo .
define variable v-object-code    as integer   no-undo .
define variable fact-order_from  as decimal   no-undo .
define variable fact-order_till  as decimal   no-undo .
define variable j_line-counter   as integer   no-undo .
define variable j_order-max      as integer   no-undo .
define variable v-short-date     as character no-undo .
define variable XLS-page-num     as integer   no-undo .
define variable v-temp-string    as character no-undo .
define variable v_temp-param     as character no-undo .
define variable v_data-type      as character no-undo .
define variable XL-delim         as character no-undo .
define variable v-report-name    as character no-undo .
define variable v-report-subname as character no-undo .
define variable v-stored-name    as character no-undo .

define variable d_rest-from  like ub.wth-line.income no-undo .
define variable d_rest-till  like ub.wth-line.income no-undo .
define variable d_cash-sum   like ub.wth-line.income no-undo .
define variable d_incass-sum like ub.wth-line.incass no-undo .

define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo initial yes .
define variable g#host-code   as integer no-undo .

define temp-table tt_line no-undo
  field order      as integer
  field obj-type   as character
  field obj-code   as integer
  field obj-name   as character
  field own-type   as character
  field own-code   as integer
  field own-name   as character
  field shift-date as date
  field shift-num  as integer
  field shift-name as character
  field shift-out  as character                                             /* 1-я колонка */
  field rest-from  as decimal   decimals 2 format "->,>>>,>>>,>>>,>>9.99":U /* 2-я колонка */
  field rest-till  as decimal   decimals 2 format "->,>>>,>>>,>>>,>>9.99":U /* 5-я колонка */
  field cash-sum   as decimal   decimals 2 format "->,>>>,>>>,>>>,>>9.99":U /* 3-я колонка */
  field incass-sum as decimal   decimals 2 format "->,>>>,>>>,>>>,>>9.99":U /* 4-я колонка */
  field is-total   as logical

  index tt-pui     is primary   unique order
  index tt-ui1     is           unique obj-type   obj-code   shift-date shift-num
  index tt-ui2     is           unique shift-date shift-num  obj-type   obj-code
  index i1                             is-total   obj-type   obj-code   shift-date shift-num order
  index i2                             is-total   shift-date shift-num  obj-type   obj-code  order
.

define buffer bf_line for tt_line .

define stream text_out .

{ gbl/prn-lib.i " " text_out }

form header
  v-report-name                                                             format "x({&A4_CW0})":U at 1
  v-report-subname                                                          format "x({&A4_CW0})":U at 1
  v-firm-name                                                               format "x({&A4_CW0})":U at 1 skip( 0 )
  substitute( '&1 &2 "&3".'
            , v-object-type
            , v-object-code
            , v-object-name
            )                                                              format "x({&A4_CW0})":U at 1 skip( 1 )
  ShiftRight( substitute( "Дата печати: &1, время: &2.   Страница: &3."
                        , string( t_today,                 "99.99.9999":U )
                        , string( j_time,                  "HH:MM:SS":U   )
                        , string( page-number( text_out ), ">>9":U        )
                        )                                , {&text-length} ) format "x({&A4_CW0})":U at 1 skip( 0 )
  {&report-header}
with frame Top_Page width {&A4_CW0} page-top no-labels no-box use-text stream-io no-underline .

form header                                    skip( 1 )
  {&single-line} format "x({&A4_CW0})":U at  1 skip( 0 )
  "Продолжение на следующей странице"    at 30 skip( 0 )
with frame Bottom_Page width {&A4_CW0} page-bottom no-labels no-box use-text stream-io no-underline .

do
on error undo, return error return-value
:
  run WaitFram-Show   in this-procedure
    ( input {&MyWaitMess}
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
  assign
    g#host-code = v-cntxt-host-code-obj
  .
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
  /*
  for each SheetF where
           SheetF.Sheet-Num > 1
  :
    delete SheetF .
  end.
  */

  case x-radio-task :
    when 1
    then do:
      assign
        v-temp = "период с " + string( x-date-start ) + " по " + string( x-date-end )
      .
    end.
    when 2
    then do:
      assign
        v-temp = "сменные сутки c " + string( x-date-start ) + " по " + string( x-date-end )
      .
    end.
    when 3
    then do:
      assign
        v-temp = "сменные сутки и порядок смен с "
                + string( x-shift-start ) + " ":U + string( x-date-start ) + " по "
                + string( x-shift-end   ) + " ":U + string( x-date-end   )
      .
    end.
    when 4
    then do:
      assign
        v-temp = "смену " + string( x-shift-alone ) + " с "
                          + string( x-date-start  ) + " по " + string( x-date-end )
      .
    end.
  end case. /* x-radio-task */

  run cur-time in this-procedure
    ( output t_today
    , output j_time
    ) .
  {&SetCursorWait}
  assign
    {&single-line} = fill( '-', {&text-length} )
  .
  for each obj-list no-lock
  :
    find first bf_object no-lock where
               bf_object.obj-type = obj-list.obj-type and
               bf_object.obj-code = obj-list.obj-code .
    find first bf_clients no-lock where
               bf_clients.obj-type = {&cmp}              and
               bf_clients.obj-code = bf_object.host-code .
    find first bf_sysconf no-lock where
               bf_sysconf.host-code = bf_clients.obj-code .

    if lookup( bf_object.obj-name, v-obj-name, {&comma-char} ) = 0
    then do:
      assign
        v-obj-name = v-obj-name
                   + ( if v-obj-name = "":U then "":U else {&comma-char} )
                   + bf_object.obj-name
      .
    end. /* v-obj-name */
    if lookup( bf_clients.obj-name, v-own-name, {&comma-char} ) = 0
    then do:
      assign
        v-own-name = v-own-name
                   + ( if v-own-name = "":U then "":U else {&comma-char} )
                   + bf_clients.obj-name
      .
    end. /* v-own-name */

    case x-radio-task :
      when 1
      then do:
        for each bf_wth-doc no-lock where
                 bf_wth-doc.obj-type   = obj-list.obj-type and
                 bf_wth-doc.obj-code   = obj-list.obj-code and
                 bf_wth-doc.fact-date >= x-date-start      and
                 bf_wth-doc.fact-date <= x-date-end        and
                 bf_wth-doc.status_    = {&fact}           and
                 bf_wth-doc.borned     = no
          , each bf_wth-line no-lock where
                 bf_wth-line.doc-code  = bf_wth-doc.doc-code
        break by bf_wth-doc.shift-date
              by bf_wth-doc.shift-num
              by bf_wth-line.wth-code
        :
          { rep/r-wth-dc.i 1 }
        end. /* for each bf_wth-doc */
      end. /* 1 */
      when 2
      then do:
        for each bf_wth-doc no-lock where
                 bf_wth-doc.obj-type    = obj-list.obj-type and
                 bf_wth-doc.obj-code    = obj-list.obj-code and
                 bf_wth-doc.shift-date >= x-date-start      and
                 bf_wth-doc.shift-date <= x-date-end        and
                 bf_wth-doc.status_     = {&fact}           and
                 bf_wth-doc.borned      = no
          , each bf_wth-line no-lock where
                 bf_wth-line.doc-code   = bf_wth-doc.doc-code
        break by bf_wth-doc.shift-date
              by bf_wth-doc.shift-num
              by bf_wth-line.wth-code
        :
          { rep/r-wth-dc.i 2 }
        end. /* for each bf_wth-doc */
      end. /* 2 */
      when 3
      then do:
        for each bf_wth-doc no-lock where
                 bf_wth-doc.obj-type    = obj-list.obj-type and
                 bf_wth-doc.obj-code    = obj-list.obj-code and
               ( bf_wth-doc.shift-date >  x-date-start      or
               ( bf_wth-doc.shift-date  = x-date-start      and
                 bf_wth-doc.shift-num  >= x-shift-start ) ) and
               ( bf_wth-doc.shift-date <  x-date-end        or
               ( bf_wth-doc.shift-date  = x-date-end        and
                 bf_wth-doc.shift-num  <= x-shift-end   ) ) and
                 bf_wth-doc.status_     = {&fact}           and
                 bf_wth-doc.borned      = no
          , each bf_wth-line no-lock where
                 bf_wth-line.doc-code   = bf_wth-doc.doc-code
        break by bf_wth-doc.shift-date
              by bf_wth-doc.shift-num
              by bf_wth-line.wth-code
        :
          { rep/r-wth-dc.i 3 }
        end. /* for each bf_wth-doc */
      end. /* 3 */
      when 4
      then do:
        for each bf_wth-doc no-lock where
                 bf_wth-doc.obj-type    = obj-list.obj-type and
                 bf_wth-doc.obj-code    = obj-list.obj-code and
                 bf_wth-doc.shift-date >= x-date-start      and
                 bf_wth-doc.shift-date <= x-date-end        and
                 bf_wth-doc.shift-num   = x-shift-alone     and
                 bf_wth-doc.status_     = {&fact}           and
                 bf_wth-doc.borned      = no
          , each bf_wth-line no-lock where
                 bf_wth-line.doc-code   = bf_wth-doc.doc-code
        break by bf_wth-doc.shift-date
              by bf_wth-doc.shift-num
              by bf_wth-line.wth-code
        :
          { rep/r-wth-dc.i 4 }
        end. /* for each bf_wth-doc */
      end. /* 4 */
    end case. /* x-radio-task */
  end. /* for each obj-list */

  for each tt_line
  :
    assign
      tt_line.incass-sum = tt_line.incass-sum - tt_line.cash-sum
    .
  end. /* for each tt_line */

  assign
    d_rest-from  = 0.00
    d_rest-till  = 0.00
    d_cash-sum   = 0.00
    d_incass-sum = 0.00
  .
  for each bf_line no-lock where
           bf_line.is-total = no
  break by bf_line.obj-type
        by bf_line.obj-code
  :
    if first-of( bf_line.obj-code )
    then do:
      assign
        d_rest-from  = bf_line.rest-from
        d_rest-till  = 0.00
        d_cash-sum   = 0.00
        d_incass-sum = 0.00
      .
    end. /* if first-of( bf_line.obj-code ) */
    assign
      d_cash-sum   = d_cash-sum   + bf_line.cash-sum
      d_incass-sum = d_incass-sum + bf_line.incass-sum
    .
    if last-of( bf_line.obj-code )
    then do:
      assign
        j_order = j_order + 10
      .
      create tt_line .
      assign
        tt_line.order      = j_order + 2      /* раздельно по объектам */
        tt_line.obj-type   = bf_line.obj-type
        tt_line.obj-code   = bf_line.obj-code
        tt_line.obj-name   = bf_line.obj-name
        tt_line.own-type   = bf_line.own-type
        tt_line.own-code   = bf_line.own-code
        tt_line.own-name   = bf_line.own-name
        tt_line.shift-date = t_today
        tt_line.shift-num  = j_time
        tt_line.shift-name = "":U
        tt_line.shift-out  = "":U
        tt_line.rest-from  = d_rest-from
        tt_line.rest-till  = bf_line.rest-till
        tt_line.cash-sum   = d_cash-sum
        tt_line.incass-sum = d_incass-sum
        tt_line.is-total   = yes
      .
      assign
        tt_line.shift-out  = Centering( "Итого по объекту:" , 23 )
      .
    end. /* if last-of( bf_line.obj-code ) */
  end. /* for each bf_line */

  for each bf_line no-lock where
           bf_line.is-total = no
  break by bf_line.shift-date
        by bf_line.shift-num
  :
    if first-of( bf_line.shift-num )
    then do:
      assign
        d_rest-from  = bf_line.rest-from
        d_rest-till  = 0.00
        d_cash-sum   = 0.00
        d_incass-sum = 0.00
      .
    end. /* if first-of( bf_line.obj-code ) */
    assign
      d_cash-sum   = d_cash-sum   + bf_line.cash-sum
      d_incass-sum = d_incass-sum + bf_line.incass-sum
    .
    if last-of( bf_line.shift-num )
    then do:
      assign
        j_order = j_order + 10
      .
      create tt_line .
      assign
        tt_line.order      = j_order + 4        /* только итоги, все объекты в кучу */
        tt_line.obj-type   = {&total-obj-type}
        tt_line.obj-code   = {&total-obj-code}
        tt_line.obj-name   = v-obj-name
        tt_line.own-type   = "":U
        tt_line.own-code   = 0
        tt_line.own-name   = v-own-name
        tt_line.shift-date = bf_line.shift-date
        tt_line.shift-num  = bf_line.shift-num
        tt_line.shift-name = bf_line.shift-name
        tt_line.shift-out  = "":U
        tt_line.rest-from  = d_rest-from
        tt_line.rest-till  = bf_line.rest-till
        tt_line.cash-sum   = d_cash-sum
        tt_line.incass-sum = d_incass-sum
        tt_line.is-total   = yes
      .
      assign
        tt_line.shift-out  = Centering( "Итого за смену:" , 23 )
      .
    end. /* if last-of( bf_line.obj-code ) */
  end. /* for each bf_line */

  assign
    d_rest-from  = 0.00
    d_rest-till  = 0.00
    d_cash-sum   = 0.00
    d_incass-sum = 0.00
  .
  for each bf_line no-lock where
           bf_line.is-total = yes
  :
    if bf_line.obj-type   = {&total-obj-type} or
       bf_line.obj-code   = {&total-obj-code} or
       bf_line.shift-date = ?                 or
       bf_line.shift-num  = 0
    then do:
      next .
    end.
    assign
      d_rest-from  = d_rest-from  + bf_line.rest-from
      d_rest-till  = d_rest-till  + bf_line.rest-till
      d_cash-sum   = d_cash-sum   + bf_line.cash-sum
      d_incass-sum = d_incass-sum + bf_line.incass-sum
    .
  end. /* for each bf_line */
  assign
    j_order = j_order + 10
  .
  create tt_line .
  assign
    tt_line.order      = j_order + 8
    tt_line.obj-type   = {&total-obj-type}
    tt_line.obj-code   = {&total-obj-code}
    tt_line.obj-name   = v-obj-name
    tt_line.own-type   = "":U
    tt_line.own-code   = 0
    tt_line.own-name   = v-own-name
    tt_line.shift-date = ?
    tt_line.shift-num  = 0
    tt_line.shift-name = "":U
    tt_line.shift-out  = "":U
    tt_line.rest-from  = d_rest-from
    tt_line.rest-till  = d_rest-till
    tt_line.cash-sum   = d_cash-sum
    tt_line.incass-sum = d_incass-sum
    tt_line.is-total   = yes
  .
  assign
    tt_line.shift-out  = Centering( "Итого:" , 23 )
  .
  assign
    d_rest-from  = 0.00
    d_rest-till  = 0.00
    d_cash-sum   = 0.00
    d_incass-sum = 0.00
  .
  assign
    j_order-max = tt_line.order
  .

  run prn-lib-open-stream in this-procedure
    ( input parparentproc
    , input {&CS_PS}
    , input yes
    , input no
    ) .

  assign
    v-report-name    = Centering( Sparse( "Отчет о движении материальных ценностей" ), {&text-length} )
    v-report-subname = Centering( Sparse( "за " + v-temp                            ), {&text-length} )
                     + {&new-line}
                     + {&new-line}
  .
  /*
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
    SheetF.MergeCellsH        = "":U
    SheetF.MergeCellsV        = "":U
    SheetF.Excel-Column-Lable = "№ и дата смены"                       + {&comma-char} +
                                "Остаток на начало периода (на АЗК)"   + {&comma-char} +
                                "Выручка за смену (в наличных р у б л ях)" + {&comma-char} +
                                "Инкассировано в банк (за смену)"      + {&comma-char} +
                                "Остаток на конец периода (на АЗК)"
    SheetF.ColFormat          = "1=" + "@"                  + ";" +
                                "2=" + "#" + v-del-1 + "##" +
                                       "0" + v-delim + "00" + ";" +
                                "3=" + "#" + v-del-1 + "##" +
                                       "0" + v-delim + "00" + ";" +
                                "4=" + "#" + v-del-1 + "##" +
                                       "0" + v-delim + "00" + ";" +
                                "5=" + "#" + v-del-1 + "##" +
                                       "0" + v-delim + "00"
                              + {&delim-par}
                              + {&delim-par}
    SheetF.Sizes              = "23,21,21,21,21"
  .
  */

  if p-tog-object = yes
  then do:
    assign
      j_line-counter = 0
    .
    for each tt_line no-lock where
             tt_line.is-total = p-tog-total
    break by tt_line.obj-type
          by tt_line.obj-code
          by tt_line.shift-date
          by tt_line.shift-num
    :
      if p-tog-total        =  yes               and
         tt_line.obj-type   =  {&total-obj-type} and
         tt_line.obj-code   =  {&total-obj-code} and
         tt_line.shift-date <> t_today           and
         tt_line.shift-num  <> j_time
      then do:
        next .
      end.
      if first-of( tt_line.obj-code )
      then do:
        assign
          v-firm-name   = tt_line.own-name
          v-object-type = tt_line.obj-type
          v-object-code = tt_line.obj-code
          v-object-name = tt_line.obj-name
        .
        if v-firm-name = v-stored-name
        then do:
          assign
            v-firm-name = "":U
          .
        end.
        view stream text_out frame    Top_Page .
        view stream text_out frame Bottom_Page .

        if not first( tt_line.obj-code )
        then do:
          assign
            v-report-name    = "":U
            v-report-subname = "":U
          .
          if page-size( text_out ) > line-counter( text_out ) + 6 and
             j_line-counter        > 0
          then do:
            put stream text_out unformatted
              v-firm-name               format "x({&A4_CW0})":U at 1                                                              skip( 0 )
              substitute( '&1 &2 "&3".'
                        , v-object-type
                        , v-object-code
                        , v-object-name
                        )               format "x({&A4_CW0})":U at 1                                                              skip( 0 )
              {&report-header}
            .
          end.
          else do:
            page stream text_out .
          end.
        end. /* if not first( tt_line.obj-code ) */
        assign
          v-firm-name   = tt_line.own-name
          v-stored-name = tt_line.own-name
        .
        /*
        assign
          SheetF.ColFormat = SheetF.ColFormat + substitute( '&1 &2'
                                                          , tt_line.obj-type
                                                          , tt_line.obj-code
                                                          )
        .
        if XLS-page-num > 1
        then do:
          {&PageExcel}
        end.
        assign
          ReportName   = "Отчет о движении материальных ценностей" + {&new-line}
                       + "за " + v-temp
          ReportHeader = v-firm-name + {&new-line}
                       + substitute( '&1 &2 "&3".'
                                   , v-object-type
                                   , v-object-code
                                   , v-object-name
                                   )
                       + substitute( "Дата печати: &1, время: &2."
                                   , string( t_today, "99.99.9999":U )
                                   , string( j_time,  "HH:MM:SS":U   )
                                   )
        .
        run rep/extitle.p
          ( input XLS-page-num
          ) no-error .
        */
      end. /* if first-of( tt_line.obj-code ) */
      put stream text_out unformatted
        "|" string(         tt_line.shift-out                              , "x(23)":U )
        ":" string( string( tt_line.rest-from,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
        ":" string( string( tt_line.cash-sum,   "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
        ":" string( string( tt_line.incass-sum, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
        ":" string( string( tt_line.rest-till,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
        "|" skip
      .
      /*
      {&PutExcel}
        string(         tt_line.shift-out                              , "x(23)":U ) {&tabulation}
        string( string( tt_line.rest-from,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) {&tabulation}
        string( string( tt_line.cash-sum,   "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) {&tabulation}
        string( string( tt_line.incass-sum, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) {&tabulation}
        string( string( tt_line.rest-till,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) {&tabulation} skip
      .
      */
      if last-of( tt_line.obj-code )
      then do:
        if p-tog-total = no
        then do:
          find first bf_line no-lock where
                     bf_line.is-total = yes              and
                     bf_line.obj-type = tt_line.obj-type and
                     bf_line.obj-code = tt_line.obj-code .
          put stream text_out unformatted
            {&subtotal-line}
          .
          put stream text_out unformatted
            "|" string(         bf_line.shift-out                              , "x(23)":U )
            ":" string( string( bf_line.rest-from,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
            ":" string( string( bf_line.cash-sum,   "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
            ":" string( string( bf_line.incass-sum, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
            ":" string( string( bf_line.rest-till,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
            "|" skip
          .
          /*
          {&PutExcel}
            string(         bf_line.shift-out                              , "x(23)":U ) {&tabulation}
            string( string( bf_line.rest-from,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) {&tabulation}
            string( string( bf_line.cash-sum,   "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) {&tabulation}
            string( string( bf_line.incass-sum, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) {&tabulation}
            string( string( bf_line.rest-till,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) {&tabulation} skip
          .
          */
        end. /* if p-tog-total = no */
        if last( tt_line.obj-code )
        then do:
          put stream text_out unformatted
            string( {&single-line}, "x({&text-length})":U ) skip( 0 )
          .
          hide stream text_out frame Bottom_Page .
        end. /* if last( tt_line.obj-code ) */
        else do: /* if not last( tt_line.obj-code ) */
          put stream text_out unformatted
            string( {&single-line}, "x({&text-length})":U ) skip( 1 )
          .
        end. /* if not last( tt_line.obj-code ) */
      end. /* if last-of( tt_line.obj-code ) */
      if last( tt_line.obj-code )
      then do:
        hide stream text_out frame Bottom_Page .
      end. /* if last( tt_line.obj-code ) */
      assign
        j_line-counter = j_line-counter + 1
      .
    end. /* for each tt_line */
  end. /* if p-tog-object = yes */
  else do: /* if p-tog-object = no */
    assign
      v-firm-name   = v-own-name
      v-object-type = "":U
      v-object-code = num-entries( v-obj-name )
      v-object-name = v-obj-name
    .
    view stream text_out frame    Top_Page .
    view stream text_out frame Bottom_Page .

    /*
    assign
      SheetF.ColFormat = SheetF.ColFormat + substitute( 'Лист &1'
                                                      , XLS-page-num
                                                      )
    .
    if XLS-page-num > 1
    then do:
      {&PageExcel}
    end.
    assign
      ReportName   = "Отчет о движении материальных ценностей" + {&new-line}
                   + "за " + v-temp
      ReportHeader = v-firm-name + {&new-line}
                   + substitute( '&1 &2 "&3".'
                               , v-object-type
                               , v-object-code
                               , v-object-name
                               )
                   + substitute( "Дата печати: &1, время: &2."
                               , string( t_today, "99.99.9999":U )
                               , string( j_time,  "HH:MM:SS":U   )
                               )
    .
    run rep/extitle.p
      ( input XLS-page-num
      ) no-error .
    */

    assign
      v-report-name    = "":U
      v-report-subname = "":U
    .
    if p-tog-total = yes
    then do:
      assign
        j_line-counter = 1
      .
    end. /* if p-tog-total = yes */
    else do: /* if p-tog-total = no */
      assign
        j_line-counter = 0
      .
      for each tt_line no-lock where
               tt_line.is-total = p-tog-total
      break by tt_line.shift-date
            by tt_line.shift-num
            by tt_line.obj-type
            by tt_line.obj-code
      :
        if p-tog-total        =  yes               and
           tt_line.obj-type   <> {&total-obj-type} and
           tt_line.obj-code   <> {&total-obj-code} and
           tt_line.shift-date =  t_today           and
           tt_line.shift-num  =  j_time
        then do:
          next .
        end.
        if tt_line.order      = j_order-max or
           tt_line.shift-date = ?           or
           tt_line.shift-num  = 0
        then do:
          next .
        end.

        if p-tog-total = yes
        then do:
          assign
            v-temp-string = ShiftRight( substitute( '№ &1&3 от &2'
                                      , tt_line.shift-name
                                      , string( tt_line.shift-date, "99/99/9999":U )
                                      , ( if tt_line.shift-name = string( tt_line.shift-num ) then "":U else
                                        ( substitute( '(&1)'
                                                    , tt_line.shift-num
                                                    )
                                        )
                                        )
                                      )
                                      , 22 ) + " ":U
          .
          put stream text_out unformatted
            "|" string( v-temp-string, "x(23)":U )
          .
          /*
          {&PutExcel}
            string( v-temp-string, "x(23)":U ) {&tabulation}
          .
          */
        end.
        else do:
          put stream text_out unformatted
            "|" string(         tt_line.shift-out                              , "x(23)":U )
          .
          /*
          {&PutExcel}
            string(         tt_line.shift-out                              , "x(23)":U ) {&tabulation}
          .
          */
        end.
        put stream text_out unformatted
          ":" string( string( tt_line.rest-from,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
          ":" string( string( tt_line.cash-sum,   "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
          ":" string( string( tt_line.incass-sum, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
          ":" string( string( tt_line.rest-till,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
          "|" skip
        .
        /*
        {&PutExcel}
          string( string( tt_line.rest-from,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) {&tabulation}
          string( string( tt_line.cash-sum,   "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) {&tabulation}
          string( string( tt_line.incass-sum, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) {&tabulation}
          string( string( tt_line.rest-till,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) skip
        .
        */
        if last( tt_line.shift-num )
        then do:
          hide stream text_out frame Bottom_Page .
        end. /* if last( tt_line.shift-num ) */
        assign
          j_line-counter = j_line-counter + 1
        .
      end. /* for each tt_line */
      put stream text_out unformatted
        string( {&single-line}, "x({&text-length})":U ) skip
      .
    end. /* if p-tog-total = no */
  end. /* if p-tog-object = no */
  if j_line-counter > 0
  then do:
    find first bf_line no-lock where
               bf_line.order = j_order-max .
    put stream text_out unformatted
      "|" string(         bf_line.shift-out                              , "x(23)":U )
      ":" string( string( bf_line.rest-from,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
      ":" string( string( bf_line.cash-sum,   "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
      ":" string( string( bf_line.incass-sum, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
      ":" string( string( bf_line.rest-till,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
      "|" skip
    .
    put stream text_out unformatted
      string( {&single-line}, "x({&text-length})":U ) skip
    .
    /*
    {&PutExcel}
      string(         bf_line.shift-out                              , "x(23)":U ) {&tabulation}
      string( string( bf_line.rest-from,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) {&tabulation}
      string( string( bf_line.cash-sum,   "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) {&tabulation}
      string( string( bf_line.incass-sum, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) {&tabulation}
      string( string( bf_line.rest-till,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) {&tabulation} skip
    .
    */
  end.

  hide stream text_out frame    Top_Page .
  hide stream text_out frame Bottom_Page .

  output stream text_out close .
  /* {&CloseExcel} */

  run WaitFram-Hide in this-procedure .
  {&SetCursorNo}
  run prn-lib-prn-file in this-procedure
    ( input parparentproc
    , input 0
    ) .
end. /* on error */

procedure wealth-rest :
  define  input parameter p-obj-type    as character no-undo .
  define  input parameter p-obj-code    as integer   no-undo .
  define  input parameter p-shift-date  as date      no-undo .
  define  input parameter p-shift-num   as integer   no-undo .
  define output parameter p-rest-from   as decimal   no-undo initial 0.00 .
  define output parameter p-rest-till   as decimal   no-undo initial 0.00 .
  define output parameter p-incass-bank as decimal   no-undo initial 0.00 .

  define variable d_stock-start  like ub.wth-line.income       no-undo .
  define variable d_stock-end    like ub.wth-line.income       no-undo .
  define variable d_income       like ub.wth-line.income       no-undo .
  define variable d_income-cassa like ub.wth-line.income-cassa no-undo .
  define variable d_income-other like ub.wth-line.income-other no-undo .
  define variable d_incass       like ub.wth-line.incass       no-undo .
  define variable d_incass-bank  like ub.wth-line.incass-bank  no-undo .
  define variable d_incass-other like ub.wth-line.incass-other no-undo .
  define variable d_incass-cassa like ub.wth-line.incass-cassa no-undo .

  define buffer bf_wth-obj for ub.wth-obj .

  do
  on error undo, return error return-value
  :
    for each bf_wth-obj no-lock where
             bf_wth-obj.obj-type = p-obj-type and
             bf_wth-obj.obj-code = p-obj-code
          by bf_wth-obj.wth-code
    :
      run wth-lib_full-inf-shift in this-procedure
        (  input p-obj-type
        ,  input p-obj-code
        ,  input bf_wth-obj.wth-code
        ,  input p-shift-date
        ,  input p-shift-num
        , output d_stock-start
        , output d_stock-end
        , output d_income
        , output d_income-cassa
        , output d_income-other
        , output d_incass
        , output d_incass-bank
        , output d_incass-other
        , output d_incass-cassa
        ) no-error .
      if error-status :error
      then do:
        undo, return error return-value .
      end.
      assign
        p-rest-from   = p-rest-from   + d_stock-start
        p-rest-till   = p-rest-till   + d_stock-end
        p-incass-bank = p-incass-bank + d_income      - d_incass
      .
    end. /* for each bf_wth-obj */
  end. /* on error */
end procedure. /* wealth-rest */

procedure create-tt_line :
  define  input parameter p-obj-type   as character no-undo .
  define  input parameter p-obj-code   as integer   no-undo .
  define  input parameter p-obj-name   as character no-undo .
  define  input parameter p-cli-type   as character no-undo .
  define  input parameter p-cli-code   as integer   no-undo .
  define  input parameter p-cli-name   as character no-undo .
  define  input parameter p-shift-date as date      no-undo .
  define  input parameter p-shift-num  as integer   no-undo .
  define output parameter p-rec-id     as recid     no-undo .

  define variable v-shift-name     as character no-undo .
  define variable v-shift-name-num as character no-undo .

  do
  on error undo, return error return-value
  :
    find first tt_line where
               tt_line.obj-type   = p-obj-type   and
               tt_line.obj-code   = p-obj-code   and
               tt_line.shift-date = p-shift-date and
               tt_line.shift-num  = p-shift-num  no-error .
    if not available tt_line
    then do:
      assign
        j_order = j_order + 10
      .
      { str/shiftnam.i
          p-obj-type
          p-obj-code
          p-shift-date
          p-shift-num
          v-shift-name
          v-shift-name-num
          no-error
      }
      if error-status :error
      then do:
        undo, return error return-value .
      end.
      create tt_line .
      assign
        tt_line.order      = j_order
        tt_line.obj-type   = p-obj-type
        tt_line.obj-code   = p-obj-code
        tt_line.obj-name   = p-obj-name
        tt_line.own-type   = p-cli-type
        tt_line.own-code   = p-cli-code
        tt_line.own-name   = p-cli-name
        tt_line.shift-date = p-shift-date
        tt_line.shift-num  = p-shift-num
        tt_line.shift-name = v-shift-name
        tt_line.shift-out  = "":U
        tt_line.rest-from  = 0.00
        tt_line.rest-till  = 0.00
        tt_line.cash-sum   = 0.00
        tt_line.incass-sum = 0.00
        tt_line.is-total   = no
      .
      assign
        tt_line.shift-out  = ShiftRight( substitute( '№ &1 от &2'
                                                   , v-shift-name-num
                                                   , string( p-shift-date, "99/99/9999":U )
                                                   )
                                                   , 22 ) + " ":U
      .
      run wealth-rest in this-procedure
        (  input p-obj-type
        ,  input p-obj-code
        ,  input p-shift-date
        ,  input p-shift-num
        , output tt_line.rest-from
        , output tt_line.rest-till
        , output tt_line.incass-sum
        ) no-error .
      if error-status :error
      then do:
        undo, return error return-value .
      end.
    end. /* if not available tt_line */
    assign
      p-rec-id = recid( tt_line )
    .
  end. /* on error */
end procedure. /* create-tt_line */