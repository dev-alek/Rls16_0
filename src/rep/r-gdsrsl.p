block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-gdsrsl.p $
$Archive: rep/r-gdsrsl.p $

Товарный отчет (реестр документов) по поставщикам в продажных ценах

Автор: Булгаков Андрей Николаевич
Дата создания: 07/24/06
Author: Andrew Bulgakoff
Creation date: 07/24/06

*/

define input parameter p-parent-proc as widget-handle no-undo .
define input parameter p-obj-type    as character     no-undo .
define input parameter p-obj-code    as integer       no-undo .
define input parameter p-tog-suppl   as logical       no-undo .
define input parameter p-trn-doc-num as integer       no-undo .
define input parameter p-all-suppl   as logical       no-undo .

&scop f-l             Sparse,Centering,ShiftRight
&scop total-supp-type "---"
&scop total-supp-code -1
&scop total-orig-mask '&1#&2-&3&4'
&scop text-length     123

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-gdsrsl.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-gdsrsl.p $":U .
define variable vss-description as character no-undo initial "Товарный отчет (реестр документов) по поставщикам в продажных ценах":U .

{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/r-page1.i         }
{ str/trdcalib.i        }
{ cmp/r-pril.i          }
{ gbl/waitfram.i        }
{ trg/factord.i         }
{ str/clcprtsl.i        }
{ gbl/cur-time.i        }
{ gbl/std-func.i {&f-l} }

define variable ParParentproc as widget-handle no-undo .

assign
  ParParentproc = p-parent-proc
.

{ gbl/getcntxt.i   def  }

define variable l-proceed       as logical   no-undo .
define variable l-holding       as logical   no-undo .
define variable v-supp-type     as character no-undo .
define variable j-supp-code     as integer   no-undo .
define variable j-order         as integer   no-undo .
define variable dtotal-sale     as decimal   no-undo .
define variable jorder-from     as integer   no-undo .
define variable j-supp-vat-ord  as integer   no-undo .
define variable v-type          as character no-undo .
define variable varr-b          as character no-undo .
define variable d_start-rest    as decimal   no-undo .
define variable d_final-rest    as decimal   no-undo .
define variable d_temp-rest     as decimal   no-undo .
define variable d_start-qnty    as decimal   no-undo .
define variable d_final-qnty    as decimal   no-undo .
define variable d_temp-qnty     as decimal   no-undo .
define variable fact-order-from as decimal   no-undo .
define variable fact-order-till as decimal   no-undo .
define variable was-docs-exists as logical   no-undo .
define variable t_today         as date      no-undo .
define variable j_time          as integer   no-undo .
define variable j-npp           as integer   no-undo .
define variable Under_Line      as character no-undo .
define variable Header-Line1    as character no-undo .
define variable Header-Line2    as character no-undo .
define variable Header-Line3    as character no-undo .
define variable Header-Line4    as character no-undo .
define variable Header-Line5    as character no-undo .
define variable Header-Line6    as character no-undo .
define variable Header-Line7    as character no-undo .
define variable Header-Line8    as character no-undo .
define variable Label-Line1     as character no-undo .
define variable Label-Line2     as character no-undo .
define variable Label-Line3     as character no-undo .
define variable Format-Line1    as character no-undo .
define variable Format-Line2    as character no-undo .
define variable v-tmp-string    as character no-undo .
define variable j-add-length    as integer   no-undo .
define variable Discount_Total  as decimal   no-undo .
define variable Document_Total  as decimal   no-undo .
define variable jj              as integer   no-undo .
define variable v-original-code as character no-undo .
define variable XL-delim        as character no-undo .
define variable v_data-type     as character no-undo .
define variable v_temp-param    as character no-undo .
/* define variable XLS-page-num    as integer   no-undo initial 0 . */
define variable v-del-0         as character no-undo .
define variable v-del-1         as character no-undo .
define variable v-del-2         as character no-undo .
define variable v-short-date    as character no-undo .
define variable v-ext-doc-name  as character no-undo .
define variable first_time      as logical   no-undo .
define variable d_doc-sum-sale  as decimal   no-undo .

define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo initial yes .
define variable g#host-code   as integer no-undo .

define shared temp-table g#supplier no-undo
  field supp-type like ub.clients.obj-type
  field supp-code like ub.clients.obj-code
  field supp-name like ub.clients.obj-name

  index pi        is   unique primary supp-type supp-code
.

define temp-table tt-suppl no-undo
  field order        as   integer
  field supp-type    like ub.clients.obj-type
  field supp-code    like ub.clients.obj-code
  field cli-name     like ub.clients.obj-name
  field ext-doc-type like ub.trn-doc.ext-doc-type
  field ext-doc-ord  as   integer
  field ext-doc-grp  as   integer
  field orig-code    like ub.trn-doc.doc-code
  field doc-code     like ub.trn-doc.doc-code
  field fact-date    like ub.trn-doc.fact-date
  field sum-sale     like ub.trn-doc.tot-rubl
  field is-total     as   logical
  field is-hold-doc  as   logical

  index pi           is   primary unique order
  index i1           is           unique supp-type supp-code   orig-code
  index i2                               is-total  ext-doc-grp ext-doc-ord doc-code    cli-name
  index i3                               is-total  supp-type   supp-code   ext-doc-grp ext-doc-ord
.

define temp-table tt-supp-vat no-undo
  field order   as integer
  field vat-pc  as decimal
  field sum-doc as decimal
  field is-tot  as logical
  field vat-ord as integer

  index pi      is primary unique order  vat-pc  descending
  index i1                        is-tot vat-pc  descending
  index i2                        order  vat-ord
  index i3                        is-tot vat-ord
.

define temp-table tt-vat-total no-undo
  field vat-pc  as decimal
  field vat-ord as integer
  field vat-sum as decimal

  index pi      is primary unique vat-pc  descending
  index i1      is         unique vat-ord descending
.

define buffer bf_trn-doc  for ub.trn-doc  .
define buffer bf_doc-line for ub.doc-line .
define buffer bf_parts    for ub.parts    .
define buffer bf_clients  for ub.clients  .
define buffer bf_objects  for ub.clients  .

define buffer bf_stk-tot    for ub.stk-tot    .
define buffer bf_price-doc  for ub.price-doc  .
define buffer bf_price-list for ub.price-list .

define buffer bf_suppl     for tt-suppl     .
define buffer bf_supp-vat  for tt-supp-vat  .
define buffer bf_vat-total for tt-vat-total .

define stream text_out .

{ gbl/prn-lib.i " " text_out }

form header
  Centering( Sparse( "Товарный отчет (реестр документов) по поставщикам" ), {&text-length} ) format "x({&A4_CW0})":U at 1 skip( 0 )
  Centering( Sparse( "в продажных ценах"                                 ), {&text-length} ) format "x({&A4_CW0})":U at 1 skip( 0 )
  Centering( Sparse( substitute( "за период с &1 по &2."
                               , string( x-date-start, "99.99.9999":U )
                               , string( x-date-end,   "99.99.9999":U )
                               )                                         ), {&text-length} ) format "x({&A4_CW0})":U at 1 skip( 1 )
  ShiftRight( substitute( "Дата печати: &1, время: &2.   Страница: &3."
                        , string( t_today,                 "99.99.9999":U )
                        , string( j_time,                  "HH:MM:SS":U   )
                        , string( page-number( text_out ), ">>9":U        )
                        )                                                , {&text-length} ) format "x({&A4_CW0})":U at 1 skip( 0 )
with frame Top_Page width {&A4_CW0} page-top no-labels no-box use-text stream-io no-underline .

form header                                 skip( 1 )
  Under_Line format "x({&A4_CW0})":U  at  1 skip
  "Продолжение на следующей странице" at 30 skip
with frame Bottom_Page width {&A4_CW0} page-bottom no-labels no-box use-text stream-io no-underline .

do
on error undo, return error return-value
:
  run WaitFram-Show   in this-procedure
    ( input {&MyWaitMess}
    ) .
  {&SetCursorWait}
  run get-report-num  in p-parent-proc
    (
      output g#report-num
    ) .
  {&SetCursorWait}
  run get-quest-print in p-parent-proc
    (
      output g#quest-print
    ) .
  {&SetCursorWait}
  { gbl/curr-r-b.i
    varr-b
    no-error
  }
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
  run rep/get-fo.p
    (  input p-obj-type
    ,  input p-obj-code
    ,  input x-date-start
    ,  input x-date-end
    , output fact-order-from
    , output fact-order-till
    , output was-docs-exists
    ) no-error .
  if error-status :error
  then do:
    run WaitFram-Hide in this-procedure .
    {&SetCursorNo}
    undo, return error "Ошибка определения диапазона для архива (fact-order)." .
  end.
  {&SetCursorWait}
  if was-docs-exists <> yes
  then do:
    run WaitFram-Hide in this-procedure .
    {&SetCursorNo}
    message vss-workfile skip( 0 ) vss-date skip( 0 ) vss-revision skip( 1 ) vss-description skip( 1 )
            "Нет документов за заданный период или не рассчитан архив." skip( 1 )
    view-as alert-box information .
    return .
  end.

  for each bf_trn-doc no-lock where
           bf_trn-doc.obj-type   = p-obj-type   and
           bf_trn-doc.obj-code   = p-obj-code   and
           bf_trn-doc.status_    = {&fact}      and
           bf_trn-doc.fact-date >= x-date-start and
           bf_trn-doc.fact-date <= x-date-end
  :
    { gbl/hold-doc.i
        bf_trn-doc.doc-code
        l-holding
        no-error
    }
    if error-status :error
    then do:
      run WaitFram-Hide in this-procedure .
      {&SetCursorNo}
      undo, return error substitute( 'Ошибка определения межфирменного перемещения по документу "&1"'
                                   , bf_trn-doc.doc-code
                                   ) .
    end.

    case bf_trn-doc.ext-doc-type :
      when {&TDEDT_Pri_Vnesh}
      then do:
        assign
          l-proceed = ( if l-holding = yes then use-column[  3 ] else use-column[  1 ] )
        .
      end.
      when {&TDEDT_Ras_Vnesh_VP}
      then do:
        assign
          l-proceed = ( if l-holding = yes then use-column[  4 ] else use-column[  2 ] )
        .
      end.
      when {&TDEDT_Pri_Perem}
      then do:
        assign
          l-proceed = use-column[  5 ]
        .
      end.
      when {&TDEDT_Vozvrat_Perem}
      then do:
        assign
          l-proceed = use-column[  6 ]
        .
      end.
      when {&TDEDT_Spi_Vnesh}
      then do:
        assign
          l-proceed = use-column[  7 ]
        .
      end.
      when {&TDEDT_Spi_Prvo}
      then do:
        assign
          l-proceed = use-column[  8 ]
        .
      end.
      when {&TDEDT_Ras_Vnesh}
      then do:
        assign
          l-proceed = ( if l-holding = yes then use-column[  9 ] else use-column[ 15 ] )
        .
      end.
      when {&TDEDT_Vozvrat_Vnesh}
      then do:
        assign
          l-proceed = ( if l-holding = yes then use-column[ 10 ] else use-column[ 16 ] )
        .
      end.
      when {&TDEDT_Ras_Perem}
      then do:
        assign
          l-proceed = use-column[ 11 ]
        .
      end.
      when {&TDEDT_Inv}
      then do:
        assign
          l-proceed = use-column[ 12 ]
        .
      end.
      when {&TDEDT_Peresort}
      then do:
        assign
          l-proceed = use-column[ 13 ]
        .
      end.
      when {&TDEDT_Overturn}
      then do:
        assign
          l-proceed = use-column[ 14 ]
        .
      end.
      when {&TDEDT_Ras_Vnesh_Kass}
      then do:
        assign
          l-proceed = use-column[ 17 ]
        .
      end.
      when {&TDEDT_Vozvrat_Vnesh_Kass}
      then do:
        assign
          l-proceed = use-column[ 18 ]
        .
      end.
      otherwise do:
        assign
          l-proceed = no
        .
      end.
    end case. /* bf_trn-doc.ext-doc-type */
    if l-proceed <> yes
    then do:
      next .
    end.

    for each bf_doc-line no-lock where
             bf_doc-line.doc-code = bf_trn-doc.doc-code
    :
      for each bf_parts no-lock where
               bf_parts.obj-type  = bf_doc-line.obj-type  and
               bf_parts.obj-code  = bf_doc-line.obj-code  and
               bf_parts.artic     = bf_doc-line.artic     and
               bf_parts.prod-type = bf_doc-line.prod-type and
               bf_parts.prod-code = bf_doc-line.prod-code and
               bf_parts.out-code  = bf_doc-line.doc-code
      :
        /*
        run get-suppl in this-procedure
          (  input bf_parts.in-code
          ,  input bf_parts.artic
          ,  input bf_parts.prod-type
          ,  input bf_parts.prod-code
          ,  input bf_parts.part-code
          , output v-supp-type
          , output j-supp-code
          ) no-error .
        if error-status :error
        then do:
          run WaitFram-Hide in this-procedure .
          {&SetCursorNo}
          undo, return error substitute( 'Ошибка определения поставщика "&1" &2 &3 &4.'
                                       , bf_doc-line.doc-code
                                       , bf_doc-line.artic
                                       , bf_doc-line.prod-type
                                       , bf_doc-line.prod-code
                                       ) .
        end.
        {&SetCursorWait}
        if v-supp-type = "":U and
           j-supp-code = 0
        then do:
        */
          assign
            v-supp-type = bf_parts.supp-type
            j-supp-code = bf_parts.supp-code
          .
        /* end. */
        if p-all-suppl = yes
        then do:
          find first g#supplier no-lock where
                     g#supplier.supp-type = v-supp-type and
                     g#supplier.supp-code = j-supp-code no-error .
          if not available g#supplier
          then do:
            find first bf_clients no-lock where
                       bf_clients.obj-type = v-supp-type and
                       bf_clients.obj-code = j-supp-code no-error .
            if available bf_clients
            then do:
              create g#supplier .
              assign
                g#supplier.supp-type = bf_clients.obj-type
                g#supplier.supp-code = bf_clients.obj-code
                g#supplier.supp-name = bf_clients.obj-name
              .
            end. /* if available bf_clients */
          end. /* if not available g#supplier */
        end. /* if p-all-suppl = yes */
        find first g#supplier no-lock where
                   g#supplier.supp-type = v-supp-type and
                   g#supplier.supp-code = j-supp-code no-error .
        if available g#supplier
        then do:
          run cr-tt-suppl in this-procedure
            ( input recid( bf_parts )
            , input g#supplier.supp-type
            , input g#supplier.supp-code
            ) no-error .
          if error-status :error
          then do:
            run WaitFram-Hide in this-procedure .
            {&SetCursorNo}
            undo, return error substitute( 'Ошибка формирования временной таблицы "&1" &2 &3 &4.'
                                         , bf_doc-line.doc-code
                                         , bf_doc-line.artic
                                         , bf_doc-line.prod-type
                                         , bf_doc-line.prod-code
                                         ) .
          end.
          {&SetCursorWait}
          next .
        end.

        if l-holding = yes
        then do:
          if p-all-suppl = yes
          then do:
            find first g#supplier no-lock where
                       g#supplier.supp-type = v-supp-type and
                       g#supplier.supp-code = j-supp-code no-error .
            if not available g#supplier
            then do:
              find first bf_clients no-lock where
                         bf_clients.obj-type = v-supp-type and
                         bf_clients.obj-code = j-supp-code no-error .
              if available bf_clients
              then do:
                create g#supplier .
                assign
                  g#supplier.supp-type = bf_clients.obj-type
                  g#supplier.supp-code = bf_clients.obj-code
                  g#supplier.supp-name = bf_clients.obj-name
                .
              end. /* if available bf_clients */
            end. /* if not available g#supplier */
          end. /* if p-all-suppl = yes */
          find first g#supplier no-lock where
                     g#supplier.supp-type = v-supp-type and
                     g#supplier.supp-code = j-supp-code no-error .
          if available g#supplier
          then do:
            run cr-tt-suppl in this-procedure
              ( input recid( bf_parts )
              , input g#supplier.supp-type
              , input g#supplier.supp-code
              ) no-error .
            if error-status :error
            then do:
              run WaitFram-Hide in this-procedure .
              {&SetCursorNo}
              undo, return error substitute( 'Ошибка формирования временной таблицы "&1" &2 &3 &4.'
                                           , bf_trn-doc.doc-code
                                           , bf_doc-line.artic
                                           , bf_doc-line.prod-type
                                           , bf_doc-line.prod-code
                                           ) .
            end.
            {&SetCursorWait}
            next .
          end. /* if available g#supplier */
        end. /* if l-holding = yes */
      end. /* for each bf_parts */
    end. /* for each bf_doc-line */
  end. /* for each bf_trn-doc */

  if use-column[ 14 ] = yes
  then do:
    for each bf_price-doc no-lock where
             bf_price-doc.obj-type   = p-obj-type       and
             bf_price-doc.obj-code   = p-obj-code       and
             bf_price-doc.status_    = {&act-overvalue} and
             bf_price-doc.fact-date >= x-date-start     and
             bf_price-doc.fact-date <= x-date-end
    :
      for each bf_price-list no-lock where
               bf_price-list.doc-num = bf_price-doc.doc-num
      :
        for each bf_parts no-lock where
                 bf_parts.obj-type  = bf_price-list.obj-type  and
                 bf_parts.obj-code  = bf_price-list.obj-code  and
                 bf_parts.artic     = bf_price-list.artic     and
                 bf_parts.prod-type = bf_price-list.prod-type and
                 bf_parts.prod-code = bf_price-list.prod-code and
                 bf_parts.out-code  = bf_price-list.doc-num
        :
          /*
          run get-suppl in this-procedure
            (  input bf_parts.in-code
            ,  input bf_parts.artic
            ,  input bf_parts.prod-type
            ,  input bf_parts.prod-code
            ,  input bf_parts.part-code
            , output v-supp-type
            , output j-supp-code
            ) no-error .
          if error-status :error
          then do:
            run WaitFram-Hide in this-procedure .
            {&SetCursorNo}
            undo, return error substitute( 'Ошибка определения поставщика "&1" &2 &3 &4.'
                                         , bf_price-doc.doc-num
                                         , bf_price-list.artic
                                         , bf_price-list.prod-type
                                         , bf_price-list.prod-code
                                         ) .
          end.
          {&SetCursorWait}
          if v-supp-type = "":U and
             j-supp-code = 0
          then do:
          */
            assign
              v-supp-type = bf_parts.supp-type
              j-supp-code = bf_parts.supp-code
            .
          /* end. */
          if p-all-suppl = yes
          then do:
            find first g#supplier no-lock where
                       g#supplier.supp-type = v-supp-type and
                       g#supplier.supp-code = j-supp-code no-error .
            if not available g#supplier
            then do:
              find first bf_clients no-lock where
                         bf_clients.obj-type = v-supp-type and
                         bf_clients.obj-code = j-supp-code no-error .
              if available bf_clients
              then do:
                create g#supplier .
                assign
                  g#supplier.supp-type = bf_clients.obj-type
                  g#supplier.supp-code = bf_clients.obj-code
                  g#supplier.supp-name = bf_clients.obj-name
                .
              end. /* if available bf_clients */
            end. /* if not available g#supplier */
          end. /* if p-all-suppl = yes */
          find first g#supplier no-lock where
                     g#supplier.supp-type = v-supp-type and
                     g#supplier.supp-code = j-supp-code no-error .
          if available g#supplier
          then do:
            run cr-tt-suppl-prc in this-procedure
              ( input recid( bf_parts )
              , input g#supplier.supp-type
              , input g#supplier.supp-code
              ) no-error .
            if error-status :error
            then do:
              run WaitFram-Hide in this-procedure .
              {&SetCursorNo}
              undo, return error substitute( 'Ошибка формирования временной таблицы "&1" &2 &3 &4.'
                                           , bf_price-doc.doc-num
                                           , bf_price-list.artic
                                           , bf_price-list.prod-type
                                           , bf_price-list.prod-code
                                           ) .
            end.
            {&SetCursorWait}
            next .
          end. /* if available g#supplier */
        end. /* for each bf_parts */
      end. /* for each bf_price-list */
    end. /* for each bf_price-doc */
  end. /* переоценки */

  /* итоги */
  assign
    v-tmp-string = "":U
  .
  for each tt-suppl no-lock
  break by tt-suppl.supp-type
        by tt-suppl.supp-code
        by tt-suppl.ext-doc-grp
        by tt-suppl.ext-doc-ord
  :
    if first-of( tt-suppl.ext-doc-ord )
    then do:
      assign
        dtotal-sale  = 0.00
        v-tmp-string = "":U
      .
    end. /* if first-of( tt-suppl.ext-doc-ord ) */
    assign
      dtotal-sale  = dtotal-sale  + tt-suppl.sum-sale
      v-tmp-string = v-tmp-string + ( if v-tmp-string = "":U then "":U else {&comma-char} )
                                  + trim( string( tt-suppl.order, ">>>>>>>>>9":U ) )
    .
    if last-of( tt-suppl.ext-doc-ord )
    then do:
      assign
        j-order = j-order + 10
      .
      create bf_suppl .
      assign
        bf_suppl.order        = j-order + 1
        bf_suppl.supp-type    = tt-suppl.supp-type
        bf_suppl.supp-code    = tt-suppl.supp-code
        bf_suppl.cli-name     = "":U
        bf_suppl.ext-doc-type = tt-suppl.ext-doc-type
        bf_suppl.ext-doc-ord  = tt-suppl.ext-doc-ord
        bf_suppl.ext-doc-grp  = tt-suppl.ext-doc-grp
        v-original-code       = substitute( {&total-orig-mask}
                                          , bf_suppl.supp-type
                                          , bf_suppl.supp-code
                                          , bf_suppl.ext-doc-type
                                          , trim( string( tt-suppl.is-hold-doc = yes, "_hold/":U ) )
                                          )
        bf_suppl.orig-code    = v-original-code
        bf_suppl.doc-code     = "Итого:"
        bf_suppl.fact-date    = x-date-end
        bf_suppl.sum-sale     = dtotal-sale
        bf_suppl.is-total     = yes
        bf_suppl.is-hold-doc  = ?
      .
      assign
        j-supp-vat-ord = 0
      .
      do jj = 1 to num-entries( v-tmp-string )
      :
        assign
          jorder-from = integer( entry( jj, v-tmp-string ) )
        .
        for each tt-supp-vat no-lock where
                 tt-supp-vat.order = jorder-from
              by tt-supp-vat.vat-pc descending
        :
          find first bf_supp-vat where
                     bf_supp-vat.order  = bf_suppl.order     and
                     bf_supp-vat.vat-pc = tt-supp-vat.vat-pc no-error .
          if not available bf_supp-vat
          then do:
            assign
              j-supp-vat-ord = j-supp-vat-ord + 1
            .
            create bf_supp-vat .
            assign
              bf_supp-vat.order   = bf_suppl.order
              bf_supp-vat.vat-pc  = tt-supp-vat.vat-pc
              bf_supp-vat.is-tot  = yes
              bf_supp-vat.vat-ord = j-supp-vat-ord
            .
          end. /* if not available bf_supp-vat */
          assign
            bf_supp-vat.sum-doc = bf_supp-vat.sum-doc + tt-supp-vat.sum-doc
          .
        end. /* for each tt-supp-vat */
        for each tt-supp-vat where
                 tt-supp-vat.order = jorder-from
              by tt-supp-vat.vat-pc descending
        :
          find first bf_supp-vat no-lock where
                     bf_supp-vat.order  = bf_suppl.order     and
                     bf_supp-vat.vat-pc = tt-supp-vat.vat-pc no-error .
          assign
            tt-supp-vat.vat-ord = bf_supp-vat.vat-ord
          .
        end. /* for each tt-supp-vat */
      end. /* do jj */
      assign
        v-tmp-string = "":U
        jj           = 0
      .
    end. /* if last-of( tt-suppl.ext-doc-ord ) */
  end. /* for each tt-suppl */

  if p-tog-suppl = no
  then do:
    assign
      v-tmp-string = "":U
    .
    for each tt-suppl no-lock where
             tt-suppl.is-total = yes
    break by tt-suppl.ext-doc-grp
          by tt-suppl.ext-doc-ord
    :
      if first-of( tt-suppl.ext-doc-ord )
      then do:
        assign
          dtotal-sale  = 0.00
          v-tmp-string = "":U
        .
      end. /* if first-of( tt-suppl.ext-doc-ord ) */
      assign
        dtotal-sale  = dtotal-sale  + tt-suppl.sum-sale
        v-tmp-string = v-tmp-string + ( if v-tmp-string = "":U then "":U else {&comma-char} )
                                    + trim( string( tt-suppl.order, ">>>>>>>>>9":U ) )
      .
      if last-of( tt-suppl.ext-doc-ord )
      then do:
        assign
          j-order = j-order + 10
        .
        assign
          v-original-code = tt-suppl.orig-code
        .
        entry( 1, v-original-code, "-" ) = substitute( '&1#&2'
                                                     , {&total-supp-type}
                                                     , {&total-supp-code}
                                                     ) .
        create bf_suppl .
        assign
          bf_suppl.order        = j-order + 2
          bf_suppl.supp-type    = {&total-supp-type}
          bf_suppl.supp-code    = {&total-supp-code}
          bf_suppl.cli-name     = tt-suppl.cli-name
          bf_suppl.ext-doc-type = tt-suppl.ext-doc-type
          bf_suppl.ext-doc-ord  = tt-suppl.ext-doc-ord
          bf_suppl.ext-doc-grp  = tt-suppl.ext-doc-grp
          bf_suppl.orig-code    = v-original-code
          bf_suppl.doc-code     = tt-suppl.doc-code
          bf_suppl.fact-date    = x-date-end
          bf_suppl.sum-sale     = dtotal-sale
          bf_suppl.is-total     = yes
          bf_suppl.is-hold-doc  = tt-suppl.is-hold-doc
        .
        assign
          dtotal-sale    = 0.00
          j-supp-vat-ord = 0
        .
        do jj = 1 to num-entries( v-tmp-string )
        :
          assign
            jorder-from = integer( entry( jj, v-tmp-string ) )
          .
          for each tt-supp-vat no-lock where
                   tt-supp-vat.order  = jorder-from and
                   tt-supp-vat.is-tot = yes
          :
            find first bf_supp-vat where
                       bf_supp-vat.order  = bf_suppl.order     and
                       bf_supp-vat.vat-pc = tt-supp-vat.vat-pc no-error .
            if not available bf_supp-vat
            then do:
              assign
                j-supp-vat-ord = j-supp-vat-ord + 1
              .
              create bf_supp-vat .
              assign
                bf_supp-vat.order   = bf_suppl.order
                bf_supp-vat.vat-pc  = tt-supp-vat.vat-pc
                bf_supp-vat.is-tot  = yes
                bf_supp-vat.vat-ord = j-supp-vat-ord
              .
            end. /* if not available bf_supp-vat */
            assign
              bf_supp-vat.sum-doc = bf_supp-vat.sum-doc + tt-supp-vat.sum-doc
            .
          end. /* for each tt-supp-vat */
        end. /* do jj ... */
        assign
          v-tmp-string = "":U
          jj           = 0
        .
      end. /* if last-of( tt-suppl.ext-doc-ord ) */
    end. /* for each tt-suppl */
    for each tt-suppl no-lock where
             tt-suppl.is-total = no
    break by tt-suppl.ext-doc-grp
          by tt-suppl.ext-doc-ord
    :
      assign
        v-original-code = substitute( {&total-orig-mask}
                                    , {&total-supp-type}
                                    , {&total-supp-code}
                                    , tt-suppl.ext-doc-type
                                    , trim( string( tt-suppl.is-hold-doc = yes, "_hold/":U ) )
                                    )
      .
      find first bf_suppl no-lock where
                 bf_suppl.supp-type = {&total-supp-type} and
                 bf_suppl.supp-code = {&total-supp-code} and
                 bf_suppl.orig-code =   v-original-code  no-error .
      if available bf_suppl
      then do:
        for each tt-supp-vat where
                 tt-supp-vat.order = tt-suppl.order
              by tt-supp-vat.vat-pc descending
        :
          find first bf_supp-vat no-lock where
                     bf_supp-vat.order  = bf_suppl.order     and
                     bf_supp-vat.vat-pc = tt-supp-vat.vat-pc no-error .
          if available bf_supp-vat
          then do:
            assign
              tt-supp-vat.vat-ord = bf_supp-vat.vat-ord
            .
          end. /* if available bf_supp-vat */
        end. /* for each tt-supp-vat */
      end. /* if available bf_suppl */
    end. /* for each tt-suppl */
  end. /* if p-tog-suppl = no */

  /* печать */
  run cur-time in this-procedure
    ( output t_today
    , output j_time
    ) .
  {&SetCursorWait}
  assign
    Under_Line = fill( '-', {&text-length} )
  .

  run prn-lib-open-stream in this-procedure
    ( input p-parent-proc
    , input {&CS_PS}
    , input yes
    , input no
    ) .

  view stream text_out frame    Top_Page .
  view stream text_out frame Bottom_Page .

  assign
    ReportName   = "Товарный отчет в продажных ценах по поставщикам" + {&new-line}
                 + substitute( "за период с &1 по &2."
                             , string( x-date-start, "99.99.9999":U )
                             , string( x-date-end,   "99.99.9999":U )
                             )
    ReportHeader = substitute( "Дата печати: &1, время: &2"
                             , string( t_today, "99.99.9999":U )
                             , string( j_time,  "HH:MM:SS":U   )
                             )
  .

  if p-tog-suppl = yes
  then do:
    /* раздельно по поставщикам */
    for  each tt-suppl   no-lock where
              tt-suppl.is-total    = no use-index i3
      , first bf_clients no-lock where
              bf_clients.obj-type  = tt-suppl.supp-type and
              bf_clients.obj-code  = tt-suppl.supp-code
     break by tt-suppl.supp-type
           by tt-suppl.supp-code
           by tt-suppl.ext-doc-grp
           by tt-suppl.ext-doc-ord
    :
      if first-of( tt-suppl.supp-code )
      then do:
        {&SetCursorWait}
        run get-supp-rest in this-procedure
          (  input tt-suppl.supp-type
          ,  input tt-suppl.supp-code
          ,  input "start":U
          ,  input fact-order-from
          , output d_start-rest
          , output d_start-qnty
          ) no-error .
        if error-status :error or
           d_start-rest = ?
        then do:
          assign
            d_start-rest = 0.00
          .
        end.
        put stream text_out unformatted
          string( substitute( 'Поставщик: &1'
                            , bf_clients.obj-name
                            ), "x(80)":U ) skip
          string( substitute( 'Остаток на начало: &1'
                            , trim( string( d_start-rest, "->,>>>,>>>,>>>,>>9.99":U ) )
                            ), "x(80)":U ) skip
        .
        assign
          str3 = substitute( 'Поставщик: &1'
                           , bf_clients.obj-name
                           )
          str4 = substitute( 'Остаток на начало: &1'
                           , trim( string( d_start-rest, "->,>>>,>>>,>>>,>>9.99":U ) )
                           )
        .
        assign
          first_time = ?
        .
        if tt-suppl.ext-doc-ord > 1
        then do:
          assign
            first_time = yes
          .
          do jj = 1 to tt-suppl.ext-doc-ord - 1
          :
            if use-column[ jj ] = yes
            then do:
              if first_time = yes
              then do:
                assign
                  first_time = no
                .
                put stream text_out unformatted
                  skip( 1 )
                .
              end.
              run get-xtype-name in this-procedure
                (  input jj
                , output v-ext-doc-name
                ) .
              put stream text_out unformatted
                v-ext-doc-name ':' skip
              .
            end.
          end.
          if first_time = no
          then do:
            put stream text_out unformatted
              skip( 1 )
            .
          end.
        end. /* if tt-suppl.ext-doc-ord > 1 */
      end. /* if first-of( tt-suppl.supp-code ) */

      if first-of( tt-suppl.ext-doc-ord )
      then do:
        assign
          j-npp = 0
        .

        run get-xtype-name in this-procedure
          (  input tt-suppl.ext-doc-ord
          , output v-ext-doc-name
          ) .

        case tt-suppl.ext-doc-grp :
          when 1
          then do:
            if line-counter( text_out ) + 9 > page-size( text_out )
            then do:
              page stream text_out .
            end.
            /* :   7   :                   40                   :   11      :       15      :        21           : 100  */
            put stream text_out unformatted
              v-ext-doc-name                                                                                     ':' skip
              '----------------------------------------------------------------------------------------------------' skip
              ': № п/п :              Наименование              :    Дата   :  № документа  :     Стоимость в     :' skip
              ':       :               контрагента              : документа :               :      продажных      :' skip
              ':       :                                        :           :               :        ценах        :' skip
              ':-------:----------------------------------------:-----------:---------------:---------------------:' skip
              ':   1   :                    2                   :     3     :       4       :          5          :' skip
              ':-------:----------------------------------------:-----------:---------------:---------------------:' skip
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
              SheetF.Excel-Column-Lable = "№ п/п"                       + {&comma-char} +
                                          "Наименование контрагента"    + {&comma-char} +
                                          "Дата документа"              + {&comma-char} +
                                          "№ документа"                 + {&comma-char} +
                                          "Стоимость в продажных ценах"
              SheetF.ColFormat          = "1=" + "0"           + ";"  +
                                          "2=" + "@"           + ";"  +
                                          "3=" + "@"           + ";"  +
                                          "4=" + "@"           + ";"  +
                                          "5=" + "#" + v-del-1 + "##" +
                                                 "0" + v-delim + "00" +
                                          "":U
                                        + {&delim-par}
                                        + {&delim-par}
                                        + tt-suppl.supp-type + " ":U
                                        + trim( string( tt-suppl.supp-code, "->>>>>>>>>9":U ) )
                                        + ". " + v-ext-doc-name
              SheetF.Sizes              = "7,40,10,15,21"
            .
            if XLS-page-num > 1
            then do:
              {&PageExcel}
            end.
            run rep/extitle.p
              ( input XLS-page-num
              ) no-error .
            */
          end.
          when 2
          then do:
            if line-counter( text_out ) + 9 > page-size( text_out )
            then do:
              page stream text_out .
            end.
            /* :   7   :                   40                   :   11      :       15      :        21           : 100  */
            put stream text_out unformatted
              v-ext-doc-name                                                                                     ':' skip
              '----------------------------------------------------------------------------------------------------' skip
              ': № п/п :              Наименование              :    Дата   :  № документа  :      Разница в      :' skip
              ':       :               контрагента              : документа :               :      продажных      :' skip
              ':       :                                        :           :               :        ценах        :' skip
              ':-------:----------------------------------------:-----------:---------------:---------------------:' skip
              ':   1   :                    2                   :     3     :       4       :          5          :' skip
              ':-------:----------------------------------------:-----------:---------------:---------------------:' skip
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
              SheetF.Excel-Column-Lable = "№ п/п"                     + {&comma-char} +
                                          "Наименование контрагента"  + {&comma-char} +
                                          "Дата документа"            + {&comma-char} +
                                          "№ документа"               + {&comma-char} +
                                          "Разница в продажных ценах"
              SheetF.ColFormat          = "1=" + "0"           + ";"  +
                                          "2=" + "@"           + ";"  +
                                          "3=" + "@"           + ";"  +
                                          "4=" + "@"           + ";"  +
                                          "5=" + "#" + v-del-1 + "##" +
                                                 "0" + v-delim + "00" +
                                          "":U
                                        + {&delim-par}
                                        + {&delim-par}
                                        + tt-suppl.supp-type + " ":U
                                        + trim( string( tt-suppl.supp-code, "->>>>>>>>>9":U ) )
                                        + ". " + v-ext-doc-name
              SheetF.Sizes              = "7,40,10,15,21"
            .
            if XLS-page-num > 1
            then do:
              {&PageExcel}
            end.
            run rep/extitle.p
              ( input XLS-page-num
              ) no-error .
            */
          end.
          when 3
          then do:
            assign
              j-supp-vat-ord = 0
              j-add-length   = 0
              Header-Line1   = "":U
              Header-Line2   = "":U
              Header-Line3   = "":U
              Header-Line4   = "":U
              Header-Line5   = "":U
              Header-Line6   = "":U
              Header-Line7   = "":U
              Header-Line8   = "":U
              Label-Line1    = "":U
              Label-Line2    = "":U
              Label-Line3    = "":U
              Format-Line1   = "":U
              Format-Line2   = "":U
            .
            for each tt-vat-total
            :
              delete tt-vat-total .
            end.
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
              SheetF.Excel-Column-Lable = "":U
              SheetF.ColFormat          = "":U
              Label-Line1               = "№ п/п"                               + {&comma-char} +
                                          "Наименование контрагента"            + {&comma-char} +
                                          "Дата документа"                      + {&comma-char} +
                                          "№ документа"                         + {&comma-char} +
                                          "Стоимость (сумма в ценах документа)" + {&comma-char}
              Label-Line2               = "":U                                  + {&comma-char} +
                                          "":U                                  + {&comma-char} +
                                          "":U                                  + {&comma-char} +
                                          "":U                                  + {&comma-char}
              Format-Line1              = "1=" + "0"          + ";" +
                                          "2=" + "@"          + ";" +
                                          "3=" + "@"          + ";" +
                                          "4=" + "@"          + ";"
              Format-Line2              = "":U + {&delim-par} +
                                          "":U + {&delim-par}
                                               + tt-suppl.supp-type + " ":U
                                               + trim( string( tt-suppl.supp-code, "->>>>>>>>>9":U ) )
                                               + ". " + v-ext-doc-name
              SheetF.Sizes              = "7,40,10,15"
            .
            */
            assign
              v-original-code = substitute( {&total-orig-mask}
                                          , tt-suppl.supp-type
                                          , tt-suppl.supp-code
                                          , tt-suppl.ext-doc-type
                                          , trim( string( tt-suppl.is-hold-doc = yes, "_hold/":U ) )
                                          )
            .
            find first bf_suppl no-lock where
                       bf_suppl.is-total    = yes                  and
                       bf_suppl.supp-type   = tt-suppl.supp-type   and
                       bf_suppl.supp-code   = tt-suppl.supp-code   and
                       bf_suppl.ext-doc-grp = tt-suppl.ext-doc-grp and
                       bf_suppl.ext-doc-ord = tt-suppl.ext-doc-ord and
                       bf_suppl.orig-code   = v-original-code      no-error .
            if available bf_suppl
            then do:
              for each tt-supp-vat no-lock where
                       tt-supp-vat.order  = bf_suppl.order
              break by tt-supp-vat.vat-pc descending
              :
                assign
                  j-supp-vat-ord = j-supp-vat-ord +  1
                  j-add-length   = j-add-length   + 13
                  v-tmp-string   = Centering( string( tt-supp-vat.vat-pc, ">>9.<<":U ) + "% НДС", 13 )
                  v-tmp-string   = replace( v-tmp-string, ".%", "%" )
                  Header-Line1   = Header-Line1 + "--------------"
                  Header-Line4   = Header-Line4 + "--------------"
                  Header-Line5   = Header-Line5 + v-tmp-string + fill( " ":U, 13 - length( v-tmp-string ) ) + ":"
                  Header-Line6   = Header-Line6 + "-------------:"
                  Header-Line7   = Header-Line7 + substring( Centering( string( j-supp-vat-ord + 4 ), 13 ) + fill( " ":U, 13 ), 1, 13 ) + ":"
                  Header-Line8   = Header-Line8 + "-------------:"
                .
                create tt-vat-total .
                assign
                  tt-vat-total.vat-ord = tt-supp-vat.vat-ord
                  tt-vat-total.vat-pc  = tt-supp-vat.vat-pc
                  tt-vat-total.vat-sum = ?
                .
                /*
                assign
                  Label-Line1  = Label-Line1                         + {&comma-char}
                  Label-Line2  = Label-Line2  + trim( v-tmp-string ) + {&comma-char}
                  Format-Line1 = Format-Line1 + string( j-supp-vat-ord + 4 ) + "=" +
                                                "#" + v-del-1 + "##" +
                                                "0" + v-delim + "00" + ";"
                  SheetF.Sizes = SheetF.Sizes + ",13"
                .
                */
              end. /* for each tt-supp-vat */
            end. /* if available bf_suppl */
            assign
              j-supp-vat-ord = j-supp-vat-ord +  1
              j-add-length   = j-add-length   + 13
              v-tmp-string   = Centering( string( j-supp-vat-ord + 4 ), 13 )
              Header-Line1   = Header-Line1 + "-------------"
              Header-Line2   = Centering(         "Стоимость",         j-add-length + j-supp-vat-ord - 1 )
              Header-Line3   = Centering( "(сумма в ценах документа)", j-add-length + j-supp-vat-ord - 1 )
              Header-Line4   = Header-Line4 + "-------------"
              Header-Line5   = Header-Line5 + "    Итого    "
              Header-Line6   = Header-Line6 + "-------------"
              Header-Line7   = Header-Line7 + v-tmp-string + fill( " ":U, 13 - length( v-tmp-string ) ) + ":"
              Header-Line8   = Header-Line8 + "-------------"
              /*
              Format-Line1   = Format-Line1 + string( j-supp-vat-ord + 4 ) + "=" +
                                              "#" + v-del-1 + "##" +
                                              "0" + v-delim + "00" + ";"
                                            + string( j-supp-vat-ord + 5 ) + "=" +
                                              "#" + v-del-1 + "##" +
                                              "0" + v-delim + "00" + ";"
                                            + string( j-supp-vat-ord + 6 ) + "=" +
                                              "#" + v-del-1 + "##" +
                                              "0" + v-delim + "00"
              */
            .
            /*
            assign
              SheetF.MergeCellsH        = SheetF.MergeCellsH           +
                                          ( if SheetF.MergeCellsH = "":U then "":U else {&comma-char} ) +
                                          "5:"                         +
                                          string( j-supp-vat-ord + 4 )
              SheetF.MergeCellsV        = "1=1:2/2=1:2/3=1:2/4=1:2/"   +
                                          string( j-supp-vat-ord + 5 ) + "=1:2/" +
                                          string( j-supp-vat-ord + 6 ) + "=1:2"
              SheetF.Excel-Column-Lable = Label-Line1                  +
                                          "Сумма скидки"               + {&comma-char} +
                                          "Сумма в ценах прайс-листа"  + {&new-line}   +
                                          Label-Line2                  +
                                          "Итого"                      + {&comma-char} +
                                          "":U                         + {&comma-char}
              SheetF.ColFormat          = Format-Line1                 + Format-Line2
              SheetF.Sizes              = SheetF.Sizes                 + ",13,21,21"
            .
            */
            if line-counter( text_out ) + 10 > page-size( text_out )
            then do:
              page stream text_out .
            end.
            /* : 3 :           24           :   10     :      13     : =55 */
            /* :     13      :     13      : =28  83 + 56 */
            put stream text_out unformatted
              v-ext-doc-name              ':' skip
              '-------------------------------------------------------' + Header-Line1 +
              '-----------------------------' skip
              ': № :      Наименование      :   Дата   : № документа :' + Header-Line2 +
              ':    Сумма    :Сумма в ценах:' skip
              ':п/п:       контрагента      : документа:             :' + Header-Line3 +
              ':    скидки   : прайс-листа :' skip
              ':   :                        :          :             :' + Header-Line4 +
              ':             :             :' skip
              ':   :                        :          :             :' + Header-Line5 +
              ':             :             :' skip
              ':---:------------------------:----------:-------------:' + Header-Line6 +
              ':-------------:-------------:' skip
              ': 1 :            2           :     3    :      4      :' + Header-Line7 +
              substring( Centering( string( j-supp-vat-ord + 5 ), 13 ) + fill( " ":U, 13 ), 1, 13 ) + ":" +
              substring( Centering( string( j-supp-vat-ord + 6 ), 13 ) + fill( " ":U, 13 ), 1, 13 ) + ":" skip
              ':---:------------------------:----------:-------------:' + Header-Line8 +
              ':-------------:-------------:' skip
            .
            /*
            if XLS-page-num > 1
            then do:
              {&PageExcel}
            end.
            run rep/extitle.p
              ( input XLS-page-num
              ) no-error .
            */
          end.
        end case. /* tt-suppl.ext-doc-grp */
      end. /* if first-of( tt-suppl.ext-doc-ord ) */

      assign
        j-npp = j-npp + 1
      .
      case tt-suppl.ext-doc-grp :
        when 1
        then do:
          put stream text_out unformatted
             ": " + string( string( j-npp,              ">>>>9":U                 ), "x(5)":U )  +
            " :"  + string(         tt-suppl.cli-name,  "x(40)":U                 )              +
             ": " + string( string( tt-suppl.fact-date, "99/99/9999":U            ), "x(10)":U ) +
             ":"  + string(         tt-suppl.doc-code,  "x(15)":U                 )              +
             ":"  + string( string( tt-suppl.sum-sale,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) + ":" skip
          .
          /*
          {&PutExcel}
            string( j-npp,              ">>>>>>>>9":U         ) {&tabulation}
                    tt-suppl.cli-name                           {&tabulation}
            string( tt-suppl.fact-date, "99/99/9999":U        ) {&tabulation}
                    tt-suppl.doc-code                           {&tabulation}
            string( tt-suppl.sum-sale,  "->>>>>>>>>>>>9.99":U ) {&tabulation} skip
          .
          */
        end.
        when 2
        then do:
          put stream text_out unformatted
             ": " + string( string( j-npp,              ">>>>9":U                 ), "x(5)":U )  +
            " :"  + string(         tt-suppl.cli-name,  "x(40)":U                 )              +
             ": " + string( string( tt-suppl.fact-date, "99/99/9999":U            ), "x(10)":U ) +
             ":"  + string(         tt-suppl.doc-code,  "x(15)":U                 )              +
             ":"  + string( string( tt-suppl.sum-sale,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) + ":" skip
          .
          /*
          {&PutExcel}
            string( j-npp,              ">>>>>>>>9":U         ) {&tabulation}
                    tt-suppl.cli-name                           {&tabulation}
            string( tt-suppl.fact-date, "99/99/9999":U        ) {&tabulation}
                    tt-suppl.doc-code                           {&tabulation}
            string( tt-suppl.sum-sale,  "->>>>>>>>>>>>9.99":U ) {&tabulation} skip
          .
          */
        end.
        when 3
        then do:
          put stream text_out unformatted
             ":" + string( string( j-npp,              ">>9":U                   ), "x(3)":U )  +
             ":" + string(         tt-suppl.cli-name,  "x(24)":U                 )              +
             ":" + string( string( tt-suppl.fact-date, "99/99/9999":U            ), "x(10)":U ) +
             ":" + string(         tt-suppl.doc-code,  "x(13)":U                 )
          .
          /*
          {&PutExcel}
            string( j-npp,              ">>>>>>>>9":U  ) {&tabulation}
                    tt-suppl.cli-name                    {&tabulation}
            string( tt-suppl.fact-date, "99/99/9999":U ) {&tabulation}
                    tt-suppl.doc-code                    {&tabulation}
          .
          */
          for each tt-supp-vat no-lock where
                   tt-supp-vat.order  = tt-suppl.order
          break by tt-supp-vat.vat-pc descending
          :
            find first tt-vat-total no-lock where
                       tt-vat-total.vat-pc = tt-supp-vat.vat-pc no-error .
            if not available tt-vat-total
            then do:
              create tt-vat-total .
              assign
                tt-vat-total.vat-pc  = tt-supp-vat.vat-pc
                tt-vat-total.vat-ord = tt-supp-vat.vat-ord
                tt-vat-total.vat-sum = 0.00
              .
            end.
            else do:
              if tt-vat-total.vat-sum = ?
              then do:
                assign
                  tt-vat-total.vat-sum = 0.00
                .
              end.
            end.
            assign
              tt-vat-total.vat-sum = tt-vat-total.vat-sum + tt-supp-vat.sum-doc
            .
          end. /* for each tt-supp-vat */
          assign
            Document_Total = 0.00
            Discount_Total = 0.00
          .
          for each tt-vat-total no-lock
          break by tt-vat-total.vat-pc descending

          :
            if tt-vat-total.vat-sum = ?
            then do:
              put stream text_out unformatted
                ":             ":U
              .
              /*
              {&PutExcel}
                {&tabulation}
              .
              */
            end.
            else do:
              find first tt-supp-vat no-lock where
                         tt-supp-vat.order  = tt-suppl.order      and
                         tt-supp-vat.vat-pc = tt-vat-total.vat-pc no-error .
              if available tt-supp-vat
              then do:
                assign
                  Document_Total = Document_Total + tt-supp-vat.sum-doc
                .
                put stream text_out unformatted
                  ":" + string( string( tt-supp-vat.sum-doc, "->,>>>,>>9.99":U ), "x(13)":U )
                .
                /*
                {&PutExcel}
                  string( tt-supp-vat.sum-doc, "->>>>>>>>9.99":U ) {&tabulation}
                .
                */
              end. /* if available tt-supp-vat */
              else do: /* if not available tt-supp-vat */
                put stream text_out unformatted
                  ":             ":U
                .
                /*
                {&PutExcel}
                  {&tabulation}
                .
                */
              end. /* if not available tt-supp-vat */
            end.
          end. /* for each tt-vat-total */
          assign
            jj = 0
          .
          assign
            Discount_Total = tt-suppl.sum-sale - Document_Total
          .
          put stream text_out unformatted
             ":" string( string( Document_Total,    "->,>>>,>>9.99":U ), "x(13)":U )
             ":" string( string( Discount_Total,    "->,>>>,>>9.99":U ), "x(13)":U )
             ":" string( string( tt-suppl.sum-sale, "->,>>>,>>9.99":U ), "x(13)":U ) ":" skip
          .
          /*
          {&PutExcel}
            string( Document_Total,    "->>>>>>>>>>>>9.99":U ) {&tabulation}
            string( Discount_Total,    "->>>>>>>>>>>>9.99":U ) {&tabulation}
            string( tt-suppl.sum-sale, "->>>>>>>>>>>>9.99":U ) skip
          .
          */
        end.
      end case. /* tt-suppl.ext-doc-grp */

      if last-of( tt-suppl.ext-doc-ord )
      then do:
        assign
          v-original-code = substitute( {&total-orig-mask}
                                      , tt-suppl.supp-type
                                      , tt-suppl.supp-code
                                      , tt-suppl.ext-doc-type
                                      , trim( string( tt-suppl.is-hold-doc = yes, "_hold/":U ) )
                                      )
        .
        find first bf_suppl no-lock where
                   bf_suppl.is-total    = yes                  and
                   bf_suppl.supp-type   = tt-suppl.supp-type   and
                   bf_suppl.supp-code   = tt-suppl.supp-code   and
                   bf_suppl.ext-doc-grp = tt-suppl.ext-doc-grp and
                   bf_suppl.ext-doc-ord = tt-suppl.ext-doc-ord and
                   bf_suppl.orig-code   = v-original-code      no-error .
        if available bf_suppl
        then do:
          case tt-suppl.ext-doc-grp :
            when 1
            then do:
              put stream text_out unformatted
                ':-------:----------------------------------------:-----------:---------------:---------------------:' skip( 0 )
                ':       :                                        :           : Итого:        :'
                string( string( bf_suppl.sum-sale, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )                        ':' skip( 0 )
                '----------------------------------------------------------------------------------------------------' skip( 0 )
              .
              /*
              {&PutExcel}                                          {&tabulation}
                                                                   {&tabulation}
                                                                   {&tabulation}
                "Итого:"                                           {&tabulation}
                string( bf_suppl.sum-sale, "->>>>>>>>>>>>9.99":U ) skip
              .
              */
            end.
            when 2
            then do:
              put stream text_out unformatted
                ':-------:----------------------------------------:-----------:---------------:---------------------:' skip( 0 )
                ':       :                                        :           : Итого:        :'
                string( string( bf_suppl.sum-sale, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )                        ':' skip( 0 )
                '----------------------------------------------------------------------------------------------------' skip( 0 )
              .
              /*
              {&PutExcel}                                          {&tabulation}
                                                                   {&tabulation}
                                                                   {&tabulation}
                "Итого:"                                           {&tabulation}
                string( bf_suppl.sum-sale, "->>>>>>>>>>>>9.99":U ) skip
              .
              */
            end.
            when 3
            then do:
              assign
                Document_Total = 0.00
                Discount_Total = 0.00
              .
              put stream text_out unformatted
                ':---:------------------------:----------:-------------:'
                fill( '-------------:', j-supp-vat-ord ) '-------------:-------------:' skip( 0 )
                ':   :                        :          : Итого:      :'
              .
              /*
              {&PutExcel} {&tabulation}
                          {&tabulation}
                          {&tabulation}
                "Итого:"  {&tabulation}
              .
              */
              for each bf_supp-vat no-lock where
                       bf_supp-vat.order  = bf_suppl.order and
                       bf_supp-vat.is-tot = yes
              break by bf_supp-vat.vat-pc descending
              :
                assign
                  Document_Total = Document_Total + bf_supp-vat.sum-doc
                .
                put stream text_out unformatted
                  string( string( bf_supp-vat.sum-doc, "->,>>>,>>9.99":U ), "x(13)":U ) ':'
                .
                /*
                {&PutExcel}
                  string( bf_supp-vat.sum-doc, "->>>>>>>>>>>>9.99":U ) {&tabulation}
                .
                */
              end. /* for each bf_supp-vat */
              assign
                Discount_Total = bf_suppl.sum-sale - Document_Total
              .
              put stream text_out unformatted
                string( string( Document_Total,    "->,>>>,>>9.99":U ), "x(13)":U ) ':'
                string( string( Discount_Total,    "->,>>>,>>9.99":U ), "x(13)":U ) ':'
                string( string( bf_suppl.sum-sale, "->,>>>,>>9.99":U ), "x(13)":U ) ':' skip( 0 )
                '-------------------------------------------------------'
                fill( '--------------', j-supp-vat-ord ) '----------------------------' skip( 0 )
              .
              /*
              {&PutExcel}
                string( Document_Total,    "->>>>>>>>>>>>9.99":U ) {&tabulation}
                string( Discount_Total,    "->>>>>>>>>>>>9.99":U ) {&tabulation}
                string( bf_suppl.sum-sale, "->>>>>>>>>>>>9.99":U ) skip
              .
              */
              for each tt-vat-total
              :
                delete tt-vat-total .
              end.
            end.
          end case. /* tt-suppl.ext-doc-grp */
        end. /* if available bf_suppl */

        assign
          first_time = ?
        .
        find first bf_suppl no-lock where
                   bf_suppl.is-total    = no                   and
                   bf_suppl.supp-type   = tt-suppl.supp-type   and
                   bf_suppl.supp-code   = tt-suppl.supp-code   and
                   bf_suppl.ext-doc-ord > tt-suppl.ext-doc-ord no-error .
        if available bf_suppl
        then do:
          assign
            first_time = yes
          .
          do jj = tt-suppl.ext-doc-ord + 1 to bf_suppl.ext-doc-ord - 1
          :
            if use-column[ jj ] = yes
            then do:
              if first_time = yes
              then do:
                assign
                  first_time = no
                .
                put stream text_out unformatted
                  skip( 1 )
                .
              end.
              run get-xtype-name in this-procedure
                (  input jj
                , output v-ext-doc-name
                ) .
              put stream text_out unformatted
                v-ext-doc-name ':' skip
              .
            end.
          end.
          if first_time = no
          then do:
            put stream text_out unformatted
              skip( 1 )
            .
          end.
        end. /* if available bf_suppl */
      end. /* if last-of( tt-suppl.ext-doc-ord ) */

      if last-of( tt-suppl.supp-code )
      then do:
        assign
          first_time = ?
        .
        if tt-suppl.ext-doc-ord < 18
        then do:
          assign
            first_time = yes
          .
          do jj = tt-suppl.ext-doc-ord + 1 to 18
          :
            if use-column[ jj ] = yes
            then do:
              if first_time = yes
              then do:
                assign
                  first_time = no
                .
                put stream text_out unformatted
                  skip( 1 )
                .
              end.
              run get-xtype-name in this-procedure
                (  input jj
                , output v-ext-doc-name
                ) .
              put stream text_out unformatted
                v-ext-doc-name ':' skip
              .
            end.
          end.
          if first_time = no
          then do:
            put stream text_out unformatted
              skip( 1 )
            .
          end.
        end. /* if tt-suppl.ext-doc-ord < 18 */
        {&SetCursorWait}
        run get-supp-rest in this-procedure
          (  input tt-suppl.supp-type
          ,  input tt-suppl.supp-code
          ,  input "final":U
          ,  input fact-order-till
          , output d_final-rest
          , output d_final-qnty
          ) no-error .
        if error-status :error or
           d_final-rest = ?
        then do:
          assign
            d_final-rest = 0.00
          .
        end.
        put stream text_out unformatted
          string( substitute( 'Остаток на конец: &1'
                            , trim( string( d_final-rest, "->,>>>,>>>,>>>,>>9.99":U ) )
                            ), "x(80)":U ) skip( 1 )
        .
        {&PutExcel}
          substitute( 'Остаток на конец: &1'
                    , trim( string( d_final-rest, "->,>>>,>>>,>>>,>>9.99":U ) )
                    ) skip
        .
      end. /* if last-of( tt-suppl.supp-code ) */
      if last( tt-suppl.supp-code )
      then do:
        hide stream text_out frame Bottom_Page no-pause .
      end. /* if last( tt-suppl.supp-code ) */
    end. /* for each tt-suppl */
  end.
  else do:
    /* суммарно по поставщикам */
    if p-all-suppl = yes
    then do:
      find last bf_stk-tot no-lock where
                bf_stk-tot.obj-type    = p-obj-type      and
                bf_stk-tot.obj-code    = p-obj-code      and
                bf_stk-tot.fact-order <= fact-order-from and
             /* bf_stk-tot.sum-type    = {&arh-cgdt}     and */
                bf_stk-tot.sum-type    = {&arh-crsa}     and
                bf_stk-tot.cat-id      = {&root-cat-id}  no-error .
      if available bf_stk-tot
      then do:
        assign
          d_start-rest = ( if varr-b = "rubl" then bf_stk-tot.sum-rubl else bf_stk-tot.sum-base )
          d_start-qnty = bf_stk-tot.fact-qnty
        .
      end. /* if available bf_stk-supp-tot */
      else do: /* if not available bf_stk-supp-tot */
        assign
          d_start-rest = 0.00
          d_start-qnty = 0.00
        .
      end. /* if not available bf_stk-supp-tot */
    end. /* if p-all-suppl = yes */
    else do: /* if p-all-suppl = no */
      for each g#supplier no-lock
      :
        run get-supp-rest in this-procedure
          (  input g#supplier.supp-type
          ,  input g#supplier.supp-code
          ,  input "start":U
          ,  input fact-order-from
          , output d_temp-rest
          , output d_temp-qnty
          ) no-error .
        if error-status :error or
           d_temp-rest = ?
        then do:
          assign
            d_temp-rest = 0.00
          .
        end.
        assign
          d_start-rest = d_start-rest + d_temp-rest
          d_temp-rest  = 0.00
        .
      end. /* for each g#supplier */
    end. /* if p-all-suppl = no */

    put stream text_out unformatted
      string( substitute( 'Остаток на начало: &1'
                        , trim( string( d_start-rest, "->,>>>,>>>,>>>,>>9.99":U ) )
                        ), "x(80)":U ) skip
    .
    assign
      str4 = substitute( 'Остаток на начало: &1'
                        , trim( string( d_start-rest, "->,>>>,>>>,>>>,>>9.99":U ) )
                        )
    .
    for each tt-suppl   no-lock where
             tt-suppl.is-total    = no use-index i2
    break by tt-suppl.ext-doc-grp
          by tt-suppl.ext-doc-ord
          by tt-suppl.doc-code
          by tt-suppl.cli-name
    :
      if first( tt-suppl.ext-doc-ord )
      then do:
        assign
          first_time = ?

        .
        if tt-suppl.ext-doc-ord > 1

        then do:
          assign
            first_time = yes
          .
          do jj = 1 to tt-suppl.ext-doc-ord - 1
          :
            if use-column[ jj ] = yes
            then do:
              if first_time = yes
              then do:
                assign
                  first_time = no
                .
                put stream text_out unformatted
                  skip( 1 )
                .
              end.
              run get-xtype-name in this-procedure
                (  input jj
                , output v-ext-doc-name
                ) .
              put stream text_out unformatted
                v-ext-doc-name ':' skip
              .
            end.
          end.
          if first_time = no
          then do:
            put stream text_out unformatted
              skip( 1 )
            .
          end.
        end. /* if tt-suppl.ext-doc-ord > 1 */
      end. /* first( tt-suppl.ext-doc-ord ) */

      if first-of( tt-suppl.ext-doc-ord )
      then do:
        assign
          j-npp = 0
        .

        run get-xtype-name in this-procedure
          (  input tt-suppl.ext-doc-ord
          , output v-ext-doc-name
          ) .
        case tt-suppl.ext-doc-grp :
          when 1
          then do:
            if line-counter( text_out ) + 9 > page-size( text_out )
            then do:
              page stream text_out .
            end.
            /* :   7   :                   40                   :   11      :       15      :        21           : 100  */
            put stream text_out unformatted
              v-ext-doc-name                                                                                     ':' skip
              '----------------------------------------------------------------------------------------------------' skip
              ': № п/п :              Наименование              :    Дата   :  № документа  :     Стоимость в     :' skip
              ':       :               контрагента              : документа :               :      продажных      :' skip
              ':       :                                        :           :               :        ценах        :' skip
              ':-------:----------------------------------------:-----------:---------------:---------------------:' skip
              ':   1   :                    2                   :     3     :       4       :          5          :' skip
              ':-------:----------------------------------------:-----------:---------------:---------------------:' skip
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
              SheetF.Excel-Column-Lable = "№ п/п"                       + {&comma-char} +
                                          "Наименование контрагента"    + {&comma-char} +
                                          "Дата документа"              + {&comma-char} +
                                          "№ документа"                 + {&comma-char} +
                                          "Стоимость в продажных ценах"
              SheetF.ColFormat          = "1=" + "0"           + ";"  +
                                          "2=" + "@"           + ";"  +
                                          "3=" + "@"           + ";"  +
                                          "4=" + "@"           + ";"  +
                                          "5=" + "#" + v-del-1 + "##" +
                                                 "0" + v-delim + "00" +
                                          "":U
                                        + {&delim-par}
                                        + {&delim-par}
                                        + v-ext-doc-name
              SheetF.Sizes              = "7,40,10,15,21"
            .
            if XLS-page-num > 1
            then do:
              {&PageExcel}
            end.
            run rep/extitle.p
              ( input XLS-page-num
              ) no-error .
            */
          end.
          when 2
          then do:
            if line-counter( text_out ) + 9 > page-size( text_out )
            then do:
              page stream text_out .
            end.
            /* :   7   :                   40                   :   11      :       15      :        21           : 100  */
            put stream text_out unformatted
              v-ext-doc-name                                                                                     ':' skip
              '----------------------------------------------------------------------------------------------------' skip
              ': № п/п :              Наименование              :    Дата   :  № документа  :      Разница в      :' skip
              ':       :               контрагента              : документа :               :      продажных      :' skip
              ':       :                                        :           :               :        ценах        :' skip
              ':-------:----------------------------------------:-----------:---------------:---------------------:' skip
              ':   1   :                    2                   :     3     :       4       :          5          :' skip
              ':-------:----------------------------------------:-----------:---------------:---------------------:' skip
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
              SheetF.Excel-Column-Lable = "№ п/п"                     + {&comma-char} +
                                          "Наименование контрагента"  + {&comma-char} +
                                          "Дата документа"            + {&comma-char} +
                                          "№ документа"               + {&comma-char} +
                                          "Разница в продажных ценах"
              SheetF.ColFormat          = "1=" + "0"           + ";"  +
                                          "2=" + "@"           + ";"  +
                                          "3=" + "@"           + ";"  +
                                          "4=" + "@"           + ";"  +
                                          "5=" + "#" + v-del-1 + "##" +
                                                 "0" + v-delim + "00" +
                                          "":U
                                        + {&delim-par}
                                        + {&delim-par}
                                        + v-ext-doc-name
              SheetF.Sizes              = "7,40,10,15,21"
            .
            if XLS-page-num > 1
            then do:
              {&PageExcel}
            end.
            run rep/extitle.p
              ( input XLS-page-num
              ) no-error .
            */
          end.
          when 3
          then do:
            assign
              j-supp-vat-ord = 0
              j-add-length   = 0
              Header-Line1   = "":U
              Header-Line2   = "":U
              Header-Line3   = "":U
              Header-Line4   = "":U
              Header-Line5   = "":U
              Header-Line6   = "":U
              Header-Line7   = "":U
              Header-Line8   = "":U
              Label-Line1    = "":U
              Label-Line2    = "":U
              Label-Line3    = "":U
              Format-Line1   = "":U
              Format-Line2   = "":U
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
              SheetF.Excel-Column-Lable = "":U
              SheetF.ColFormat          = "":U
              Label-Line1               = "№ п/п"                               + {&comma-char} +
                                          "Наименование контрагента"            + {&comma-char} +
                                          "Дата документа"                      + {&comma-char} +
                                          "№ документа"                         + {&comma-char} +
                                          "Стоимость (сумма в ценах документа)" + {&comma-char}
              Label-Line2               = "":U                                  + {&comma-char} +
                                          "":U                                  + {&comma-char} +
                                          "":U                                  + {&comma-char} +
                                          "":U                                  + {&comma-char}
              Format-Line1              = "1=" + "0"          + ";" +
                                          "2=" + "@"          + ";" +
                                          "3=" + "@"          + ";" +
                                          "4=" + "@"          + ";"
              Format-Line2              = "":U + {&delim-par} +
                                          "":U + {&delim-par}
                                               + v-ext-doc-name
              SheetF.Sizes              = "7,40,10,15"
            .
            */
            assign
              v-original-code = substitute( {&total-orig-mask}
                                          , {&total-supp-type}
                                          , {&total-supp-code}
                                          , tt-suppl.ext-doc-type
                                          , trim( string( tt-suppl.is-hold-doc = yes, "_hold/":U ) )
                                          )
            .
            find first bf_suppl no-lock where
                       bf_suppl.is-total    = yes                  and
                       bf_suppl.supp-type   = {&total-supp-type}   and
                       bf_suppl.supp-code   = {&total-supp-code}   and
                       bf_suppl.ext-doc-grp = tt-suppl.ext-doc-grp and
                       bf_suppl.ext-doc-ord = tt-suppl.ext-doc-ord and
                       bf_suppl.orig-code   = v-original-code      no-error .
            if available bf_suppl
            then do:
              for each tt-supp-vat no-lock where
                       tt-supp-vat.order  = tt-suppl.order
              break by tt-supp-vat.vat-pc descending
              :
                assign
                  j-supp-vat-ord = j-supp-vat-ord +  1
                  j-add-length   = j-add-length   + 13
                  v-tmp-string   = Centering( string( tt-supp-vat.vat-pc, ">>9.<<":U ) + "% НДС", 13 )
                  v-tmp-string   = replace( v-tmp-string, ".%", "%" )
                  Header-Line1   = Header-Line1 + "--------------"
                  Header-Line4   = Header-Line4 + "--------------"
                  Header-Line5   = Header-Line5 + v-tmp-string + fill( " ":U, 13 - length( v-tmp-string ) ) + ":"
                  Header-Line6   = Header-Line6 + "-------------:"
                  Header-Line7   = Header-Line7 + substring( Centering( string( j-supp-vat-ord + 4 ), 13 ) + fill( " ":U, 13 ), 1, 13 ) + ":"
                  Header-Line8   = Header-Line8 + "-------------:"
                .
                /*
                assign
                  Label-Line1  = Label-Line1                         + {&comma-char}
                  Label-Line2  = Label-Line2  + trim( v-tmp-string ) + {&comma-char}
                  Format-Line1 = Format-Line1 + string( j-supp-vat-ord + 4 ) + "=" +
                                                "#" + v-del-1 + "##" +
                                                "0" + v-delim + "00" + ";"
                  SheetF.Sizes = SheetF.Sizes + ",13"
                .
                */
              end. /* for each tt-supp-vat */
            end. /* if available bf_suppl */
            assign
              j-supp-vat-ord = j-supp-vat-ord +  1
              j-add-length   = j-add-length   + 13
              v-tmp-string   = Centering( string( j-supp-vat-ord + 4 ), 13 )
              Header-Line1   = Header-Line1 + "-------------"
              Header-Line2   = Centering(         "Стоимость",         j-add-length + j-supp-vat-ord - 1 )
              Header-Line3   = Centering( "(сумма в ценах документа)", j-add-length + j-supp-vat-ord - 1 )
              Header-Line4   = Header-Line4 + "-------------"
              Header-Line5   = Header-Line5 + "    Итого    "
              Header-Line6   = Header-Line6 + "-------------"
              Header-Line7   = Header-Line7 + v-tmp-string + fill( " ":U, 13 - length( v-tmp-string ) ) + ":"
              Header-Line8   = Header-Line8 + "-------------"
              /*
              Format-Line1   = Format-Line1 + string( j-supp-vat-ord + 4 ) + "=" +
                                              "#" + v-del-1 + "##" +
                                              "0" + v-delim + "00" + ";"
                                            + string( j-supp-vat-ord + 5 ) + "=" +
                                              "#" + v-del-1 + "##" +
                                              "0" + v-delim + "00" + ";"
                                            + string( j-supp-vat-ord + 6 ) + "=" +
                                              "#" + v-del-1 + "##" +
                                              "0" + v-delim + "00"
              */
            .
            /*
            assign
              SheetF.MergeCellsH        = SheetF.MergeCellsH           +
                                          ( if SheetF.MergeCellsH = "":U then "":U else {&comma-char} ) +
                                          "5:"                         +
                                          string( j-supp-vat-ord + 4 )
              SheetF.MergeCellsV        = "1=1:2/2=1:2/3=1:2/4=1:2/"   +
                                          string( j-supp-vat-ord + 5 ) + "=1:2/" +
                                          string( j-supp-vat-ord + 6 ) + "=1:2"
              SheetF.Excel-Column-Lable = Label-Line1                  +
                                          "Сумма скидки"               + {&comma-char} +
                                          "Сумма в ценах прайс-листа"  + {&new-line}   +
                                          Label-Line2                  +
                                          "Итого"                      + {&comma-char} +
                                          "":U                         + {&comma-char}
              SheetF.ColFormat          = Format-Line1                 + Format-Line2
              SheetF.Sizes              = SheetF.Sizes                 + ",13,21,21"
            .
            */
            if line-counter( text_out ) + 10 > page-size( text_out )
            then do:
              page stream text_out .
            end.
            /* : 3 :           24           :    10    :      13     : =55 */
            /* :     13      :      13     : =28  83 + 56 */
            put stream text_out unformatted
              v-ext-doc-name              ':' skip
              '-------------------------------------------------------' + Header-Line1 +
              '-----------------------------' skip
              ': № :      Наименование      :   Дата   : № документа :' + Header-Line2 +
              ':    Сумма    :Сумма в ценах:' skip
              ':п/п:       контрагента      : документа:             :' + Header-Line3 +
              ':    скидки   : прайс-листа :' skip
              ':   :                        :          :             :' + Header-Line4 +
              ':             :             :' skip
              ':   :                        :          :             :' + Header-Line5 +
              ':             :             :' skip
              ':---:------------------------:----------:-------------:' + Header-Line6 +
              ':-------------:-------------:' skip
              ': 1 :            2           :     3    :      4      :' + Header-Line7 +
              substring( Centering( string( j-supp-vat-ord + 5 ), 13 ) + fill( " ":U, 13 ), 1, 13 ) + ":" +
              substring( Centering( string( j-supp-vat-ord + 6 ), 13 ) + fill( " ":U, 13 ), 1, 13 ) + ":" skip
              ':---:------------------------:----------:-------------:' + Header-Line8 +
              ':-------------:-------------:' skip
            .
            /*
            if XLS-page-num > 1
            then do:
              {&PageExcel}
            end.
            run rep/extitle.p
              ( input XLS-page-num
              ) no-error .
            */
          end.
        end case. /* tt-suppl.ext-doc-grp */
      end. /* if first-of( tt-suppl.ext-doc-ord ) */

      if first-of( tt-suppl.doc-code )
      then do:
        case tt-suppl.ext-doc-grp :
          when 3
          then do:
            for each tt-vat-total
            :
              delete tt-vat-total .
            end.
            assign
              v-original-code = substitute( {&total-orig-mask}
                                          , {&total-supp-type}
                                          , {&total-supp-code}
                                          , tt-suppl.ext-doc-type
                                          , trim( string( tt-suppl.is-hold-doc = yes, "_hold/":U ) )
                                          )
            .
            find first bf_suppl no-lock where
                       bf_suppl.is-total    = yes                  and
                       bf_suppl.supp-type   = {&total-supp-type}   and
                       bf_suppl.supp-code   = {&total-supp-code}   and
                       bf_suppl.ext-doc-grp = tt-suppl.ext-doc-grp and
                       bf_suppl.ext-doc-ord = tt-suppl.ext-doc-ord and
                       bf_suppl.orig-code   = v-original-code      no-error .
            if available bf_suppl
            then do:
              for each tt-supp-vat no-lock where
                       tt-supp-vat.order  = bf_suppl.order and
                       tt-supp-vat.is-tot = yes
              break by tt-supp-vat.vat-pc descending
              :
                create tt-vat-total .
                assign
                  tt-vat-total.vat-ord = tt-supp-vat.vat-ord
                  tt-vat-total.vat-pc  = tt-supp-vat.vat-pc
                  tt-vat-total.vat-sum = ?
                .
              end. /* for each tt-supp-vat */
            end. /* if available bf_suppl */
          end.
        end case. /* tt-suppl.ext-doc-grp */
      end. /* if first-of( tt-suppl.doc-code ) */

      case tt-suppl.ext-doc-grp :
        when 1
        then do:
          assign
            d_doc-sum-sale = d_doc-sum-sale + tt-suppl.sum-sale
          .
          if last-of( tt-suppl.doc-code )
          then do:
            assign
              j-npp = j-npp + 1
            .
            put stream text_out unformatted
               ": " + string( string( j-npp,              ">>>>9":U                 ), "x(5)":U )  +
              " :"  + string(         tt-suppl.cli-name,  "x(40)":U                 )              +
               ": " + string( string( tt-suppl.fact-date, "99/99/9999":U            ), "x(10)":U ) +
               ":"  + string(         tt-suppl.doc-code,  "x(15)":U                 )              +
               ":"  + string( string( d_doc-sum-sale,     "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) + ":" skip
            .
            /*
            {&PutExcel}
              string( j-npp,              ">>>>>>>>9":U         ) {&tabulation}
                      tt-suppl.cli-name                           {&tabulation}
              string( tt-suppl.fact-date, "99/99/9999":U        ) {&tabulation}
                      tt-suppl.doc-code                           {&tabulation}
              string( d_doc-sum-sale,     "->>>>>>>>>>>>9.99":U ) {&tabulation} skip
            .
            */
            assign
              d_doc-sum-sale = 0.00
            .
          end. /* if last-of( tt-suppl.doc-code ) */
        end. /* when 1 */
        when 2
        then do:
          assign
            d_doc-sum-sale = d_doc-sum-sale + tt-suppl.sum-sale
          .
          if last-of( tt-suppl.doc-code ) or
             last-of( tt-suppl.cli-name ) and
             tt-suppl.ext-doc-ord = 14
          then do:
            assign
              j-npp = j-npp + 1
            .
            put stream text_out unformatted
               ": " + string( string( j-npp,              ">>>>9":U                 ), "x(5)":U  ) +
              " :"  + string(         tt-suppl.cli-name,  "x(40)":U                 )              +
               ": " + string( string( tt-suppl.fact-date, "99/99/9999":U            ), "x(10)":U ) +
               ":"  + string(         tt-suppl.doc-code,  "x(15)":U                 )              +
               ":"  + string( string( d_doc-sum-sale,     "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U ) + ":" skip
            .
            /*
            {&PutExcel}
              string( j-npp,              ">>>>>>>>9":U         ) {&tabulation}
                      tt-suppl.cli-name                           {&tabulation}
              string( tt-suppl.fact-date, "99/99/9999":U        ) {&tabulation}
                      tt-suppl.doc-code                           {&tabulation}
              string( d_doc-sum-sale,     "->>>>>>>>>>>>9.99":U ) {&tabulation} skip
            .
            */
            assign
              d_doc-sum-sale = 0.00
            .
          end. /* if last-of( tt-suppl.doc-code ) */
        end. /* when 2 */
        when 3
        then do:
          assign
            d_doc-sum-sale = d_doc-sum-sale + tt-suppl.sum-sale
          .
          if last-of( tt-suppl.doc-code )
          then do:
            assign
              j-npp = j-npp + 1
            .
            put stream text_out unformatted
               ":" + string( string( j-npp,              ">>9":U                   ), "x(3)":U  ) +
               ":" + string(         tt-suppl.cli-name,  "x(24)":U                 )              +
               ":" + string( string( tt-suppl.fact-date, "99/99/9999":U            ), "x(10)":U ) +
               ":" + string(         tt-suppl.doc-code,  "x(13)":U                 )
            .
            /*
            {&PutExcel}
              string( j-npp,              ">>>>>>>>9":U  ) {&tabulation}
                      tt-suppl.cli-name                    {&tabulation}
              string( tt-suppl.fact-date, "99/99/9999":U ) {&tabulation}
                      tt-suppl.doc-code                    {&tabulation}
            .
            */
          end. /* if last-of( tt-suppl.doc-code ) */
          assign
            jj = j-supp-vat-ord - 1
          .
          for each tt-supp-vat no-lock where
                   tt-supp-vat.order  = tt-suppl.order
          break by tt-supp-vat.vat-pc descending
          :
            find first tt-vat-total no-lock where
                       tt-vat-total.vat-pc = tt-supp-vat.vat-pc no-error .
            if not available tt-vat-total
            then do:
              create tt-vat-total .
              assign
                tt-vat-total.vat-pc  = tt-supp-vat.vat-pc
                tt-vat-total.vat-ord = tt-supp-vat.vat-ord
                tt-vat-total.vat-sum = 0.00
              .
            end.
            else do:
              if tt-vat-total.vat-sum = ?
              then do:
                assign
                  tt-vat-total.vat-sum = 0.00
                .
              end.
            end.
            assign
              tt-vat-total.vat-sum = tt-vat-total.vat-sum + tt-supp-vat.sum-doc
            .
          end. /* for each tt-supp-vat */
          if last-of( tt-suppl.doc-code )
          then do:
            assign
              Document_Total = 0.00
              Discount_Total = 0.00
            .
            for each tt-vat-total no-lock
            break by tt-vat-total.vat-pc descending
            :
              if tt-vat-total.vat-sum = ?
              then do:
                put stream text_out unformatted
                  ":             ":U
                .
                /*
                {&PutExcel}
                  {&tabulation}
                .
                */
              end.
              else do:
                assign
                  Document_Total = Document_Total + tt-vat-total.vat-sum
                .
                put stream text_out unformatted
                  ":" + string( string( tt-vat-total.vat-sum, "->,>>>,>>9.99":U ), "x(13)":U )
                .
                /*
                {&PutExcel}
                  string( tt-vat-total.vat-sum, "->>>>>>>>9.99":U ) {&tabulation}
                .
                */
              end.
            end. /* for each tt-vat-total */
            assign
              jj = 0
            .
            assign
              Discount_Total = d_doc-sum-sale - Document_Total
            .
            put stream text_out unformatted
               ":" string( string( Document_Total, "->,>>>,>>9.99":U ), "x(13)":U )
               ":" string( string( Discount_Total, "->,>>>,>>9.99":U ), "x(13)":U )
               ":" string( string( d_doc-sum-sale, "->,>>>,>>9.99":U ), "x(13)":U ) ":" skip
            .
            /*
            {&PutExcel}
              string( Document_Total, "->>>>>>>>>>>>9.99":U ) {&tabulation}
              string( Discount_Total, "->>>>>>>>>>>>9.99":U ) {&tabulation}
              string( d_doc-sum-sale, "->>>>>>>>>>>>9.99":U ) skip
            .
            */
            assign
              d_doc-sum-sale = 0.00
            .
            for each tt-vat-total
            :
              delete tt-vat-total .
            end.
          end. /* if last-of( tt-suppl.doc-code ) */
        end. /* when 3 */
      end case. /* tt-suppl.ext-doc-grp */

      if last-of( tt-suppl.ext-doc-ord )
      then do:
        assign
          v-original-code = substitute( {&total-orig-mask}
                                      , {&total-supp-type}
                                      , {&total-supp-code}
                                      , tt-suppl.ext-doc-type
                                      , trim( string( tt-suppl.is-hold-doc = yes, "_hold/":U ) )
                                      )
        .
        find first bf_suppl no-lock where
                   bf_suppl.is-total    = yes                  and
                   bf_suppl.supp-type   = {&total-supp-type}   and
                   bf_suppl.supp-code   = {&total-supp-code}   and
                   bf_suppl.ext-doc-grp = tt-suppl.ext-doc-grp and
                   bf_suppl.ext-doc-ord = tt-suppl.ext-doc-ord and
                   bf_suppl.orig-code   = v-original-code      no-error .
        if available bf_suppl
        then do:
          case tt-suppl.ext-doc-grp :
            when 1
            then do:
              put stream text_out unformatted
                ':-------:----------------------------------------:-----------:---------------:---------------------:' skip( 0 )
                ':       :                                        :           : Итого:        :'
                string( string( bf_suppl.sum-sale, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )                        ':' skip( 0 )
                '----------------------------------------------------------------------------------------------------' skip( 0 )
              .
              /*
              {&PutExcel}                                          {&tabulation}
                                                                   {&tabulation}
                                                                   {&tabulation}
                "Итого:"                                           {&tabulation}
                string( bf_suppl.sum-sale, "->>>>>>>>>>>>9.99":U ) skip
              .
              */
            end.
            when 2
            then do:
              put stream text_out unformatted
                ':-------:----------------------------------------:-----------:---------------:---------------------:' skip( 0 )
                ':       :                                        :           : Итого:        :'
                string( string( bf_suppl.sum-sale, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )                        ':' skip( 0 )
                '----------------------------------------------------------------------------------------------------' skip( 0 )
              .
              /*
              {&PutExcel}                                          {&tabulation}
                                                                   {&tabulation}
                                                                   {&tabulation}
                "Итого:"                                           {&tabulation}
                string( bf_suppl.sum-sale, "->>>>>>>>>>>>9.99":U ) skip
              .
              */
            end.
            when 3
            then do:
              assign
                Document_Total = 0.00
                Discount_Total = 0.00
              .
              put stream text_out unformatted
                ':---:------------------------:----------:-------------:'
                fill( '-------------:', j-supp-vat-ord ) '-------------:-------------:' skip( 0 )
                ':   :                        :          : Итого:      :'
              .
              /*
              {&PutExcel} {&tabulation}
                          {&tabulation}
                          {&tabulation}
                "Итого:"  {&tabulation}
              .
              */
              for each bf_supp-vat no-lock where
                       bf_supp-vat.order  = bf_suppl.order and
                       bf_supp-vat.is-tot = yes
              break by bf_supp-vat.vat-pc descending
              :
                assign
                  Document_Total = Document_Total + bf_supp-vat.sum-doc
                .
                put stream text_out unformatted
                  string( string( bf_supp-vat.sum-doc, "->,>>>,>>9.99":U ), "x(13)":U ) ':'
                .
                /*
                {&PutExcel}
                  string( bf_supp-vat.sum-doc, "->>>>>>>>>>>>9.99":U ) {&tabulation}
                .
                */
              end. /* for each bf_supp-vat */
              assign
                Discount_Total = bf_suppl.sum-sale - Document_Total
              .
              put stream text_out unformatted
                string( string( Document_Total,    "->,>>>,>>9.99":U ), "x(13)":U ) ':'
                string( string( Discount_Total,    "->,>>>,>>9.99":U ), "x(13)":U ) ':'
                string( string( bf_suppl.sum-sale, "->,>>>,>>9.99":U ), "x(13)":U ) ':' skip( 0 )
                '-------------------------------------------------------'
                fill( '--------------', j-supp-vat-ord ) '----------------------------' skip( 0 )
              .
              /*
              {&PutExcel}
                string( Document_Total,    "->>>>>>>>>>>>9.99":U ) {&tabulation}
                string( Discount_Total,    "->>>>>>>>>>>>9.99":U ) {&tabulation}
                string( bf_suppl.sum-sale, "->>>>>>>>>>>>9.99":U ) skip
              .
              */
            end.
          end case. /* tt-suppl.ext-doc-grp */
        end. /* if available bf_suppl */

        assign
          first_time = ?
        .
        find first bf_suppl no-lock where
                   bf_suppl.is-total    = no                   and
                   bf_suppl.ext-doc-ord > tt-suppl.ext-doc-ord no-error .
        if available bf_suppl
        then do:
          assign
            first_time = yes
          .
          do jj = tt-suppl.ext-doc-ord + 1 to bf_suppl.ext-doc-ord - 1
          :
            if use-column[ jj ] = yes
            then do:
              if first_time = yes
              then do:
                assign
                  first_time = no
                .
                put stream text_out unformatted
                  skip( 1 )
                .
              end.
              run get-xtype-name in this-procedure
                (  input jj
                , output v-ext-doc-name
                ) .
              put stream text_out unformatted
                v-ext-doc-name ':' skip
              .
            end.
          end.
          if first_time = no
          then do:
            put stream text_out unformatted
              skip( 1 )
            .
          end.
        end. /* if available bf_suppl */
      end. /* if last-of( tt-suppl.ext-doc-ord ) */

      if last( tt-suppl.ext-doc-ord )
      then do:
        assign
          first_time = ?
        .
        if tt-suppl.ext-doc-ord < 18
        then do:
          assign
            first_time = yes
          .
          do jj = tt-suppl.ext-doc-ord + 1 to 18
          :
            if use-column[ jj ] = yes
            then do:
              if first_time = yes
              then do:
                assign
                  first_time = no
                .
                put stream text_out unformatted
                  skip( 1 )
                .
              end.
              run get-xtype-name in this-procedure
                (  input jj
                , output v-ext-doc-name
                ) .
              put stream text_out unformatted
                v-ext-doc-name ':' skip
              .
            end.
          end.
          if first_time = no
          then do:
            put stream text_out unformatted
              skip( 1 )
            .
          end.
        end. /* if tt-suppl.ext-doc-ord < 18 */

        hide stream text_out frame Bottom_Page no-pause .
      end. /* if last( tt-suppl.ext-doc-ord ) */
    end. /* for each tt-suppl */

    if p-all-suppl = yes
    then do:
      find first bf_stk-tot no-lock where
                 bf_stk-tot.obj-type    = p-obj-type      and
                 bf_stk-tot.obj-code    = p-obj-code      and
                 bf_stk-tot.fact-order >= fact-order-till and
              /* bf_stk-tot.sum-type    = {&arh-cgdt}     and */
                 bf_stk-tot.sum-type    = {&arh-crsa}     and
                 bf_stk-tot.cat-id      = {&root-cat-id}  no-error .
      if available bf_stk-tot
      then do:
        assign
          d_final-rest = ( if varr-b = "rubl" then bf_stk-tot.sum-rubl else bf_stk-tot.sum-base )
          d_final-qnty = bf_stk-tot.fact-qnty
        .
      end. /* if available bf_stk-supp-tot */
      else do: /* if not available bf_stk-supp-tot */
        assign
          d_final-rest = 0.00
          d_final-qnty = 0.00
        .
      end. /* if not available bf_stk-supp-tot */
    end. /* if p-all-suppl = yes */
    else do: /* if p-all-suppl = no */
      for each g#supplier no-lock
      :
        run get-supp-rest in this-procedure
          (  input g#supplier.supp-type
          ,  input g#supplier.supp-code
          ,  input "final":U
          ,  input fact-order-till
          , output d_temp-rest
          , output d_temp-qnty
          ) no-error .
        if error-status :error or
           d_temp-rest = ?
        then do:
          assign
            d_temp-rest = 0.00
          .
        end.
        assign
          d_final-rest = d_final-rest + d_temp-rest
          d_temp-rest  = 0.00
        .
      end. /* for each g#supplier */
    end. /* if p-all-suppl = no */

    put stream text_out unformatted
      string( substitute( 'Остаток на конец: &1'
                        , trim( string( d_final-rest, "->,>>>,>>>,>>>,>>9.99":U ) )
                        ), "x(80)":U ) skip( 1 )
    .
    /*
    {&PutExcel}
      substitute( 'Остаток на конец: &1'
                , trim( string( d_final-rest, "->,>>>,>>>,>>>,>>9.99":U ) )
                ) skip
    .
    */
  end.

  output stream text_out close .
  /* {&CloseExcel} */

  run WaitFram-Hide in this-procedure .
  {&SetCursorNo}
  run prn-lib-prn-file in this-procedure
    ( input p-parent-proc
    , input 0
    ) .
end. /* on error */

procedure get-suppl :
  define  input parameter p-in-code   like ub.parts-supp.in-code   no-undo .
  define  input parameter p-artic     like ub.parts-supp.artic     no-undo .
  define  input parameter p-prod-type like ub.parts-supp.prod-type no-undo .
  define  input parameter p-prod-code like ub.parts-supp.prod-code no-undo .
  define  input parameter p-part-code like ub.parts-supp.part-code no-undo .
  define output parameter p-supp-type like ub.parts-supp.supp-type no-undo initial "":U .
  define output parameter p-supp-code like ub.parts-supp.supp-code no-undo initial 0 .

  define buffer bf_parts-supp for ub.parts-supp .

  do
  on error undo, return error return-value
  :
    repeat
    :
      find first bf_parts-supp no-lock where
                 bf_parts-supp.in-code   = p-in-code   and
                 bf_parts-supp.artic     = p-artic     and
                 bf_parts-supp.prod-type = p-prod-type and
                 bf_parts-supp.prod-code = p-prod-code and
                 bf_parts-supp.part-code = p-part-code no-error .
      if not available bf_parts-supp
      then do:
        leave .
      end.
      assign
        p-in-code   = bf_parts-supp.orig-in-code
        p-part-code = bf_parts-supp.orig-part-code
        p-supp-type = bf_parts-supp.supp-type
        p-supp-code = bf_parts-supp.supp-code
      .
    end.
  end. /* on error */
end procedure. /* get-suppl */

procedure cr-tt-suppl :
  define input parameter p-parts     as recid     no-undo .
  define input parameter p-supp-type as character no-undo .
  define input parameter p-supp-code as integer   no-undo .

  define variable varcur-fact-qnty    like ub.gds-dtl.fact-qnty     no-undo .
  define variable varcur-base         like ub.gds-dtl.price-base    no-undo .
  define variable varcur-road-tax     like ub.doc-line.road-tax     no-undo .
  define variable varcur-excise       like ub.doc-line.excise       no-undo .
  define variable varcur-vat-pc       like ub.doc-line.vat-pc       no-undo .
  define variable varcur-cons-vat-pc  like ub.doc-line.cons-vat-pc  no-undo .
  define variable varcur-slt-pc       like ub.doc-line.slt-pc       no-undo .
  define variable varprice-sale       like ub.price-list.price-sale no-undo .
  define variable vardoc-num          like ub.price-doc.doc-num     no-undo .
  define variable varb-code           like ub.bar-code.b-code       no-undo .
  define variable varroad-tax         like ub.price-list.road-tax   no-undo .
  define variable varexcise           like ub.price-list.excise     no-undo .
  define variable varlastcur-base     like ub.gds-dtl.price-base    no-undo .
  define variable varlastcur-road-tax like ub.gds-dtl.price-base    no-undo .
  define variable varlastcur-excise   like ub.gds-dtl.price-base    no-undo .

  define buffer buf_parts    for ub.parts    .
  define buffer buf_trn-doc  for ub.trn-doc  .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_goods    for ub.goods    .
  define buffer buf_sysconf  for ub.sysconf  .
  define buffer buf_gds-dtl  for ub.gds-dtl  .
  define buffer buf_suppl    for tt-suppl    .
  define buffer buf_supp-vat for tt-supp-vat .
  define buffer buf_clients  for ub.clients  .

  do
  on error undo, return error return-value
  :
    find first buf_parts no-lock where
        recid( buf_parts ) = p-parts no-error .
    if not available buf_parts
    then do:
      run WaitFram-Hide in this-procedure .
      {&SetCursorNo}
      undo, return error "Партия не найдена" .
    end. /* if not available buf_parts */
    find first g#supplier no-lock where
               g#supplier.supp-type = p-supp-type and
               g#supplier.supp-code = p-supp-code no-error .
    if not available g#supplier
    then do:
      if p-all-suppl = yes
      then do:
        find first bf_clients no-lock where
                   bf_clients.obj-type = buf_parts.supp-type and
                   bf_clients.obj-code = buf_parts.supp-code no-error .
        if available bf_clients
        then do:
          create g#supplier .
          assign
            g#supplier.supp-type = bf_clients.obj-type
            g#supplier.supp-code = bf_clients.obj-code
            g#supplier.supp-name = bf_clients.obj-name
          .
        end. /* if available bf_clients */
      end. /* if p-all-suppl = yes */
      else do:
        run WaitFram-Hide in this-procedure .
        {&SetCursorNo}
        undo, return error substitute( 'Не найден поставщик &1 &2.'
                                     , p-supp-type
                                     , p-supp-code
                                     ) .
      end. /* if p-all-suppl <> yes */
    end. /* if not available g#supplier */
    find first buf_trn-doc no-lock where
               buf_trn-doc.doc-code = buf_parts.out-code no-error .
    if not available buf_trn-doc
    then do:
      run WaitFram-Hide in this-procedure .
      {&SetCursorNo}
      undo, return error substitute( 'Не найден документ "&1" по партии.'
                                   , buf_parts.out-code
                                   ) .
    end. /* if not available buf_trn-doc */
    find first buf_clients no-lock where
               buf_clients.obj-type = buf_trn-doc.cli-type and
               buf_clients.obj-code = buf_trn-doc.cli-code no-error .
    if not available buf_clients
    then do:
      run WaitFram-Hide in this-procedure .
      {&SetCursorNo}
      undo, return error substitute( 'Не найден контрагент &1 &2 из документа "&3".'
                                   , buf_trn-doc.cli-type
                                   , buf_trn-doc.cli-code
                                   , buf_trn-doc.doc-code
                                   ) .
    end. /* if not available buf_trn-doc */
    find first buf_doc-line no-lock where
               buf_doc-line.doc-code  = buf_trn-doc.doc-code and
               buf_doc-line.artic     = buf_parts.artic      and
               buf_doc-line.prod-type = buf_parts.prod-type  and
               buf_doc-line.prod-code = buf_parts.prod-code  no-error .
    if not available buf_doc-line
    then do:
      run WaitFram-Hide in this-procedure .
      {&SetCursorNo}
      undo, return error substitute( 'Не найдена строка документа "&1" по партии (&2 &3 &4).'
                                   , buf_trn-doc.doc-code
                                   , buf_parts.artic
                                   , buf_parts.prod-type
                                   , buf_parts.prod-code
                                   ) .
    end. /* if not available buf_trn-doc */
    find first buf_goods no-lock where
               buf_goods.artic     = buf_doc-line.artic     and
               buf_goods.prod-type = buf_doc-line.prod-type and
               buf_goods.prod-code = buf_doc-line.prod-code .
    if varcur-vat-pc = ?
    then do:
      { gbl/pftxvalg.i
          buf_goods.gds-code
          {&vat-tax-code}
          buf_trn-doc.fact-date
          buf_trn-doc.host-code
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          varcur-vat-pc
      }
    end.
    if varcur-slt-pc = ?
    then do:
      { gbl/pftxvalg.i
          buf_goods.gds-code
          {&slt-tax-code}
          buf_trn-doc.fact-date
          buf_trn-doc.host-code
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          varcur-slt-pc
      }
    end.
    if varcur-vat-pc = ?
    then do:
      run WaitFram-Hide in this-procedure .
      {&SetCursorNo}
      undo, return error substitute( 'Нет текущего продажного НДС по товару &1 &2 &3'
                                   , buf_goods.artic
                                   , buf_goods.prod-type
                                   , buf_goods.prod-code
                                   ) .
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute( 'Нет текущего продажного НП по товару &1 &2 &3'
                             , buf_goods.artic
                             , buf_goods.prod-type
                             , buf_goods.prod-code
                             ) .
    end.
    find first buf_sysconf no-lock where
               buf_sysconf.host-code = buf_trn-doc.host-code .
    assign
      varcur-cons-vat-pc = buf_sysconf.cons-vat-pc
    .
    if varcur-cons-vat-pc = ?
    then do:
      return error substitute( 'Нет текущего продажного консигнационного НДС по фирме &1'
                             , buf_trn-doc.host-code
                             ) .
    end.
    for each buf_gds-dtl no-lock where
             buf_gds-dtl.doc-code  = buf_doc-line.doc-code  and
             buf_gds-dtl.artic     = buf_doc-line.artic     and
             buf_gds-dtl.prod-type = buf_doc-line.prod-type and
             buf_gds-dtl.prod-code = buf_doc-line.prod-code
    on error undo, return error return-value
    :
      { gbl/gdsbcode.i
          buf_goods.gds-code
          buf_gds-dtl.prt-code
          varb-code
          no-error
      }
      { gbl/bcodeprc.i
          buf_trn-doc.obj-type
          buf_trn-doc.obj-code
          varb-code
          0
          buf_trn-doc.fact-order
          vardoc-num
          varprice-sale
          varroad-tax
          varexcise
      }
      if varprice-sale = ?
      then do:
        assign
          varprice-sale = 0.00
          varroad-tax   = 0.00
          varexcise     = 0.00
        .
      end.
      assign
        varlastcur-base     = varprice-sale
        varlastcur-road-tax = varroad-tax
        varlastcur-excise   = varexcise
        varcur-base         = varcur-base      + varprice-sale * buf_gds-dtl.fact-qnty
        varcur-road-tax     = varcur-road-tax  + varroad-tax   * buf_gds-dtl.fact-qnty
        varcur-excise       = varcur-excise    + varexcise     * buf_gds-dtl.fact-qnty
        varcur-fact-qnty    = varcur-fact-qnty +                 buf_gds-dtl.fact-qnty
      .
    end. /* for each buf_gds-dtl */
    if varcur-fact-qnty = 0.00
    then do:
      assign
        varcur-base      = varlastcur-base
        varcur-road-tax  = varlastcur-road-tax
        varcur-excise    = varlastcur-excise
      .
    end.
    else do:
      assign
        varcur-base      = varcur-base     / varcur-fact-qnty
        varcur-road-tax  = varcur-road-tax / varcur-fact-qnty
        varcur-excise    = varcur-excise   / varcur-fact-qnty
      .
    end.
    { gbl/gdsbcode.i
        buf_goods.gds-code
        ?
        varb-code
    }
    { gbl/bcprcex.i
        buf_trn-doc.obj-type
        buf_trn-doc.obj-code
        varb-code
        0
        buf_trn-doc.fact-order
        vardoc-num
        varprice-sale
        varroad-tax
        varexcise
        varcur-vat-pc
        varcur-slt-pc
    }
    if varprice-sale = ?
    then do:
      assign
        varcur-vat-pc = 0.00
        varcur-slt-pc = 0.00
      .
    end.

    create tt-clcparts .
    buffer-copy buf_parts to tt-clcparts no-error .
    if error-status :error
    then do:
      run WaitFram-Hide in this-procedure .
      {&SetCursorNo}
      undo, return error "Ошибка расчета сумм по партиям" .
    end.
    run clcprtsl_calc-parts in this-procedure
      ( input recid( tt-clcparts )
      , input yes
      , input yes
      , input buf_doc-line.road-tax
      , input buf_doc-line.excise
      , input buf_doc-line.vat-pc
      , input buf_doc-line.cons-vat-pc
      , input buf_doc-line.slt-pc
      , input buf_trn-doc.base-rate
      , input buf_trn-doc.base-scale
      , input varr-b
      , input varcur-base
      , input varcur-road-tax
      , input varcur-excise
      , input varcur-vat-pc
      , input varcur-cons-vat-pc
      , input varcur-slt-pc
      ) no-error .
    if error-status :error
    then do:
      run WaitFram-Hide in this-procedure .
      {&SetCursorNo}
      undo, return error "Ошибка расчета сумм по партиям" .
    end.
    {&SetCursorWait}
    find first tt-allsum where
               tt-allsum.sum-type = {&sum-general} .

    find first buf_suppl no-lock where
               buf_suppl.supp-type = p-supp-type          and
               buf_suppl.supp-code = p-supp-code          and
               buf_suppl.orig-code = buf_trn-doc.doc-code no-error .
    if not available buf_suppl
    then do:
      assign
        j-order = j-order + 10
      .
      create buf_suppl .
      assign
        buf_suppl.order        = j-order
        buf_suppl.supp-type    = p-supp-type
        buf_suppl.supp-code    = p-supp-code
        buf_suppl.cli-name     = ( if available buf_clients
                                   then buf_clients.obj-name
                                   else substitute( '&1 &2'
                                                  , buf_trn-doc.doc-type
                                                  , buf_trn-doc.doc-code
                                                  )
                                 )
        buf_suppl.ext-doc-type = buf_trn-doc.ext-doc-type
        buf_suppl.fact-date    = buf_trn-doc.fact-date
        buf_suppl.orig-code    = buf_trn-doc.doc-code
        buf_suppl.is-total     = no
      .
      case p-trn-doc-num :
        when 1
        then do:
          { str/tdat-val.i
              buf_trn-doc.doc-code
              {&trdcattr-nids}
              buf_suppl.doc-code
              v-type
              no-error
          }
          {&SetCursorWait}
          if error-status :error      or
             buf_suppl.doc-code = "":U or
             buf_suppl.doc-code = ?
          then do:
            assign
              buf_suppl.doc-code = '@' + buf_trn-doc.doc-code
            .
          end.
        end.
        otherwise do:
          assign
            buf_suppl.doc-code = buf_trn-doc.doc-code
          .
        end.
      end case. /* p-trn-doc-num */
      { gbl/hold-doc.i
          buf_trn-doc.doc-code
          buf_suppl.is-hold-doc
          no-error
      }
      if error-status :error       or
         buf_suppl.is-hold-doc = ?
      then do:
        run WaitFram-Hide in this-procedure .
        {&SetCursorNo}
        undo, return error substitute( 'Ошибка определения межфирменного перемещения по документу "&1"'
                                     , buf_trn-doc.doc-code
                                     ) .
      end.
      run get-xtype-order in this-procedure
        (  input buf_suppl.ext-doc-type
        ,  input buf_suppl.is-hold-doc
        , output buf_suppl.ext-doc-ord
        , output buf_suppl.ext-doc-grp
        ) .
    end. /* if not available buf_suppl */
    case buf_trn-doc.ext-doc-type :
      when {&TDEDT_Pri_Vnesh}
      then do:
        assign
          buf_suppl.sum-sale = buf_suppl.sum-sale +
                               ( if varr-b = "rubl" then tt-allsum.sum-dsc-rubl-cur else tt-allsum.sum-dsc-base-cur )
        .
      end.
      otherwise do:
        assign
          buf_suppl.sum-sale = buf_suppl.sum-sale +
                               ( if varr-b = "rubl" then tt-allsum.sum-dsc-rubl-doc else tt-allsum.sum-dsc-base-doc )
        .
      end.
    end case. /* buf_trn-doc.ext-doc-type */

    if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}     or
       buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass} or
       buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh}          and buf_suppl.is-hold-doc <> yes or
       buf_trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh}      and buf_suppl.is-hold-doc <> yes
    then do:
      if buf_parts.purch-code = {&bef-consignation-code}
      then do:
        find first buf_supp-vat where
                   buf_supp-vat.order  = buf_suppl.order          and
                   buf_supp-vat.vat-pc = buf_doc-line.cons-vat-pc no-error .
        if not available buf_supp-vat
        then do:
          create buf_supp-vat .
          assign
            buf_supp-vat.order   = buf_suppl.order
            buf_supp-vat.vat-pc  = buf_doc-line.cons-vat-pc
            buf_supp-vat.sum-doc = 0.00
            buf_supp-vat.is-tot  = no
          .
        end.
      end. /* if buf_parts.purch-code = {&bef-consignation-code} */
      else do:
        find first buf_supp-vat where
                   buf_supp-vat.order  = buf_suppl.order     and
                   buf_supp-vat.vat-pc = buf_doc-line.vat-pc no-error .
        if not available buf_supp-vat
        then do:
          create buf_supp-vat .
          assign
            buf_supp-vat.order   = buf_suppl.order
            buf_supp-vat.vat-pc  = buf_doc-line.vat-pc
            buf_supp-vat.sum-doc = 0.00
            buf_supp-vat.is-tot  = no
          .
        end.
      end. /* if buf_parts.purch-code <> {&bef-consignation-code} */
      case buf_trn-doc.ext-doc-type :
        when {&TDEDT_Pri_Vnesh}
        then do:
          assign
            buf_supp-vat.sum-doc = buf_supp-vat.sum-doc +
                                   ( if varr-b = "rubl" then tt-allsum.sum-dsc-rubl-cur else tt-allsum.sum-dsc-base-cur )
          .
        end.
        otherwise do:
          assign
            buf_supp-vat.sum-doc = buf_supp-vat.sum-doc +
                                   ( if varr-b = "rubl" then tt-allsum.sum-dsc-rubl-doc else tt-allsum.sum-dsc-base-doc )
          .
        end.
      end case. /* buf_trn-doc.ext-doc-type */
    end. /* касса */
  end. /* on error */
end procedure. /* cr-tt-suppl */

procedure cr-tt-suppl-prc :
  define input parameter p-parts     as recid     no-undo .
  define input parameter p-supp-type as character no-undo .
  define input parameter p-supp-code as integer   no-undo .

  define variable varcur-fact-qnty    like ub.gds-dtl.fact-qnty     no-undo .
  define variable varcur-base         like ub.gds-dtl.price-base    no-undo .
  define variable varcur-road-tax     like ub.doc-line.road-tax     no-undo .
  define variable varcur-excise       like ub.doc-line.excise       no-undo .
  define variable varcur-vat-pc       like ub.doc-line.vat-pc       no-undo .
  define variable varcur-cons-vat-pc  like ub.doc-line.cons-vat-pc  no-undo .
  define variable varcur-slt-pc       like ub.doc-line.slt-pc       no-undo .
  define variable varprice-sale       like ub.price-list.price-sale no-undo .
  define variable vardoc-num          like ub.price-doc.doc-num     no-undo .
  define variable varb-code           like ub.bar-code.b-code       no-undo .
  define variable varroad-tax         like ub.price-list.road-tax   no-undo .
  define variable varexcise           like ub.price-list.excise     no-undo .
  define variable varlastcur-base     like ub.gds-dtl.price-base    no-undo .
  define variable varlastcur-road-tax like ub.gds-dtl.price-base    no-undo .
  define variable varlastcur-excise   like ub.gds-dtl.price-base    no-undo .
  define variable v-trn-doc-code      like ub.trn-doc.doc-code      no-undo .

  define buffer buf_parts      for ub.parts      .
  define buffer buf_price-doc  for ub.price-doc  .
  define buffer buf_price-list for ub.price-list .
  define buffer buf_price-prev for ub.price-list .
  define buffer buf_goods      for ub.goods      .
  define buffer buf_sysconf    for ub.sysconf    .
  define buffer buf_gds-dtl    for ub.gds-dtl    .
  define buffer buf_suppl      for tt-suppl      .
  define buffer buf_supp-vat   for tt-supp-vat   .
  define buffer buf_clients    for ub.clients    .

  do
  on error undo, return error return-value
  :
    find first buf_parts no-lock where
        recid( buf_parts ) = p-parts no-error .
    if not available buf_parts
    then do:
      run WaitFram-Hide in this-procedure .
      {&SetCursorNo}
      undo, return error "Партия не найдена" .
    end. /* if not available buf_parts */
    find first g#supplier no-lock where
               g#supplier.supp-type = p-supp-type and
               g#supplier.supp-code = p-supp-code no-error .
    if not available g#supplier
    then do:
      if p-all-suppl = yes
      then do:
        find first bf_clients no-lock where
                   bf_clients.obj-type = buf_parts.supp-type and
                   bf_clients.obj-code = buf_parts.supp-code no-error .
        if available bf_clients
        then do:
          create g#supplier .
          assign
            g#supplier.supp-type = bf_clients.obj-type
            g#supplier.supp-code = bf_clients.obj-code
            g#supplier.supp-name = bf_clients.obj-name
          .
        end. /* if available bf_clients */
      end. /* if p-all-suppl = yes */
      else do:
        run WaitFram-Hide in this-procedure .
        {&SetCursorNo}
        undo, return error substitute( 'Не найден поставщик &1 &2.'
                                     , p-supp-type
                                     , p-supp-code
                                     ) .
      end. /* if p-all-suppl <> yes */
    end. /* if not available g#supplier */
    find first buf_price-doc no-lock where
               buf_price-doc.doc-num = buf_parts.out-code no-error .
    if not available buf_price-doc
    then do:
      run WaitFram-Hide in this-procedure .
      {&SetCursorNo}
      undo, return error substitute( 'Не найден документ переоценки "&1" по партии.'
                                   , buf_parts.out-code
                                   ) .
    end. /* if not available buf_price-doc */
    find first buf_price-list no-lock where
               buf_price-list.doc-num    = buf_parts.out-code  and
               buf_price-list.main-price = yes                 and
               buf_price-list.artic      = buf_parts.artic     and
               buf_price-list.prod-type  = buf_parts.prod-type and
               buf_price-list.prod-code  = buf_parts.prod-code no-error .
    if not available buf_price-list
    then do:
      run WaitFram-Hide in this-procedure .
      {&SetCursorNo}
      undo, return error substitute( 'Не найдена строка переоценки "&1" по партии (&2 &3 &4).'
                                   , buf_parts.out-code
                                   , buf_parts.artic
                                   , buf_parts.prod-type
                                   , buf_parts.prod-code
                                   ) .
    end. /* if not available buf_price-doc */
    find first buf_clients no-lock where
               buf_clients.obj-type = buf_price-doc.obj-type and
               buf_clients.obj-code = buf_price-doc.obj-code no-error .
    if not available buf_clients
    then do:
      run WaitFram-Hide in this-procedure .
      {&SetCursorNo}
      undo, return error substitute( 'Не найден контрагент &1 &2 из партии переоценки "&3".'
                                   , buf_price-doc.obj-type
                                   , buf_price-doc.obj-code
                                   , buf_price-doc.doc-num
                                   ) .
    end. /* if not available buf_trn-doc */
    find first buf_suppl no-lock where
               buf_suppl.supp-type = p-supp-type          and
               buf_suppl.supp-code = p-supp-code          and
               buf_suppl.orig-code = buf_price-doc.doc-num no-error .
    if not available buf_suppl
    then do:
      assign
        j-order = j-order + 10
      .
      run get-supp-cli-name in this-procedure
        (
           input p-parts
        , output v-trn-doc-code
        ) no-error .
      if error-status :error   or
         v-trn-doc-code = "":U or
         v-trn-doc-code = ?
      then do:
        assign
          v-trn-doc-code = replace( buf_price-doc.PS, {&new-line}, " ":U )
        .
      end.
      else do:
        assign
          v-trn-doc-code = v-trn-doc-code + " ":U + g#supplier.supp-name
        .
      end.
      create buf_suppl .
      assign
        buf_suppl.order        = j-order
        buf_suppl.supp-type    = p-supp-type
        buf_suppl.supp-code    = p-supp-code
     /* buf_suppl.cli-name     = buf_parts.in-code + " ":U + g#supplier.supp-name */
     /* buf_suppl.cli-name     = v-trn-doc-code */
        buf_suppl.cli-name     = replace( buf_price-doc.PS, {&new-line}, " ":U )
     /* buf_suppl.cli-name     = ( if available buf_clients
                                   then buf_clients.obj-name
                                   else substitute( '&1 &2'
                                                  , buf_price-doc.obj-type
                                                  , buf_price-doc.obj-code
                                                  )
                                 ) */
        buf_suppl.ext-doc-type = {&TDEDT_Overturn}
        buf_suppl.fact-date    = buf_price-doc.fact-date
        buf_suppl.doc-code     = buf_price-doc.doc-num
        buf_suppl.orig-code    = buf_price-doc.doc-num
        buf_suppl.is-total     = no
      .
      run get-xtype-order in this-procedure
        (  input buf_suppl.ext-doc-type
        ,  input buf_suppl.is-hold-doc
        , output buf_suppl.ext-doc-ord
        , output buf_suppl.ext-doc-grp
        ) .
    end. /* if not available buf_suppl */
    find last buf_price-prev no-lock where
              buf_price-prev.obj-type   = buf_price-list.obj-type   and
              buf_price-prev.obj-code   = buf_price-list.obj-code   and
              buf_price-prev.b-code     = buf_price-list.b-code     and
              buf_price-prev.fact-order < buf_price-list.fact-order no-error .
    if available buf_price-prev
    then do:
      assign
        buf_suppl.sum-sale = buf_suppl.sum-sale +
                           ( buf_price-list.price-sale - buf_price-prev.price-sale ) * buf_parts.fact-qnty
      .
    end. /* if available buf_price-prev */
    else do:
      assign
        buf_suppl.sum-sale = buf_suppl.sum-sale + buf_price-list.price-sale * buf_parts.fact-qnty
      .
    end.
  end. /* on error */
end procedure. /* cr-tt-suppl-prc */

procedure get-xtype-order :
  define  input parameter p-xtype as character no-undo .
  define  input parameter p-hold  as logical   no-undo .
  define output parameter p-index as integer   no-undo initial 0 .
  define output parameter p-group as integer   no-undo initial 0 .

  do
  on error undo, return error return-value
  :
    case p-xtype :
      when {&TDEDT_Pri_Vnesh}
      then do:
        assign
          p-index = ( if p-hold = yes then 3 else 1 )
          p-group = 1
        .
      end.
      when {&TDEDT_Ras_Vnesh_VP}
      then do:
        assign
          p-index = ( if p-hold = yes then 4 else 2 )
          p-group = 1
        .
      end.
      when {&TDEDT_Pri_Perem}
      then do:
        assign
          p-index = 5
          p-group = 1
        .
      end.
      when {&TDEDT_Vozvrat_Perem}
      then do:
        assign
          p-index = 6
          p-group = 1
        .
      end.
      when {&TDEDT_Spi_Vnesh}
      then do:
        assign
          p-index = 7
          p-group = 1
        .
      end.
      when {&TDEDT_Spi_Prvo}
      then do:
        assign
          p-index = 8
          p-group = 1
        .
      end.
      when {&TDEDT_Ras_Vnesh}
      then do:
        assign
          p-index = ( if p-hold = yes then 9 else 15 )
          p-group = ( if p-hold = yes then 1 else  3 )
        .
      end.
      when {&TDEDT_Vozvrat_Vnesh}
      then do:
        assign
          p-index = ( if p-hold = yes then 10 else 16 )
          p-group = ( if p-hold = yes then  1 else  3 )
        .
      end.
      when {&TDEDT_Ras_Perem}
      then do:
        assign
          p-index = 11
          p-group =  1
        .
      end.
      when {&TDEDT_Inv}
      then do:
        assign
          p-index = 12
          p-group =  2
        .
      end.
      when {&TDEDT_Peresort}
      then do:
        assign
          p-index = 13
          p-group =  2
        .
      end.
      when {&TDEDT_Overturn}
      then do:
        assign
          p-index = 14
          p-group =  2
        .
      end.
      when {&TDEDT_Ras_Vnesh_Kass}
      then do:
        assign
          p-index = 17
          p-group =  3
        .
      end.
      when {&TDEDT_Vozvrat_Vnesh_Kass}
      then do:
        assign
          p-index = 18
          p-group =  3
        .
      end.
    end case. /* p-xtype */
  end. /* on error */
end procedure. /* get-xtype-order */

procedure get-xtype-name :
  define  input parameter p-num  as integer   no-undo .
  define output parameter p-name as character no-undo initial "":U .

  define variable v-list as character no-undo .

  do
  on error undo, return error return-value
  :
    assign
      v-list = 'Приход внешний,Возврат поставщику,Приход межфирменный,Возврат поставщику между фирмами,':U      +
               'Приход внутренний,Возврат внутренний,Списание,Списание в производство,Расход межфирменный,':U   +
               'Возврат от покупателя между фирмами,Расход внутренний,Инвентаризация,Пересортица,Переоценка,':U +
               'Расход внешний,Возврат от покупателя,Расход через ККМ,Возврат от покупателя через ККМ':U
    .
    if p-num >=  1 and
       p-num <= 18
    then do:
      assign
        p-name = trim( string( p-num, ">9":U ) ) + ". ":U + entry( p-num, v-list )
      .
    end.
  end. /* on error */
end procedure. /* get-xtype-name */

procedure get-supp-rest :
  define  input parameter p-supp-type  as character no-undo .
  define  input parameter p-supp-code  as integer   no-undo .
  define  input parameter p-rest-type  as character no-undo .
  define  input parameter p-fact-order as decimal   no-undo .
  define output parameter p-rest-sum   as decimal   no-undo .
  define output parameter p-rest-qnty  as decimal   no-undo .

  define variable j_bar-code      as integer   no-undo .
  define variable j_root-bar-code as integer   no-undo .
  define variable v_doc-num-price as character no-undo .
  define variable d_price-sale    as decimal   no-undo .
  define variable d_road-tax      as decimal   no-undo .
  define variable d_excise        as decimal   no-undo .

  define buffer bf_prt-obj       for ub.prt-obj       .
  define buffer bf_bar-code      for ub.bar-code      .
  define buffer bf_goods         for ub.goods         .
  define buffer bf_stk-supp-line for ub.stk-supp-line .

  do
  on error undo, return error return-value
  :
    case p-rest-type :
      when "start":U
      then do:
        for each bf_prt-obj no-lock where
                 bf_prt-obj.obj-type = p-obj-type and
                 bf_prt-obj.obj-code = p-obj-code
        break by bf_prt-obj.prod-type
              by bf_prt-obj.prod-code
              by bf_prt-obj.artic
              by bf_prt-obj.prt-code
        :
          find last bf_stk-supp-line no-lock where
                    bf_stk-supp-line.obj-type    = bf_prt-obj.obj-type  and
                    bf_stk-supp-line.obj-code    = bf_prt-obj.obj-code  and
                    bf_stk-supp-line.cli-type    = p-supp-type          and
                    bf_stk-supp-line.cli-code    = p-supp-code          and
                    bf_stk-supp-line.artic       = bf_prt-obj.artic     and
                    bf_stk-supp-line.prod-type   = bf_prt-obj.prod-type and
                    bf_stk-supp-line.prod-code   = bf_prt-obj.prod-code and
                    bf_stk-supp-line.sum-type    = {&arh-cost}          and
                    bf_stk-supp-line.cat-id      = {&single-cat-id}     and
                    bf_stk-supp-line.fact-order <= p-fact-order         use-index category
          no-error .
          if not available bf_stk-supp-line
          then do:
            next .
          end. /* if not available bf_stk-supp-line */
          find first bf_goods no-lock where
                     bf_goods.artic     = bf_stk-supp-line.artic     and
                     bf_goods.prod-type = bf_stk-supp-line.prod-type and
                     bf_goods.prod-code = bf_stk-supp-line.prod-code no-error .
          if not available bf_goods
          then do:
            next .
          end. /* if not available bf_goods */
          { gbl/gdsbcode.i
              bf_goods.gds-code
              ?
              j_root-bar-code
              no-error
          }
          if error-status :error
          then do:
            next .
          end.
          {&SetCursorWait}
          { gbl/gdsbcode.i
              bf_goods.gds-code
              bf_prt-obj.prt-code
              j_bar-code
              no-error
          }
          if error-status :error
          then do:
            next .
          end.
          {&SetCursorWait}
          { gbl/bcodeprc.i
              bf_stk-supp-line.obj-type
              bf_stk-supp-line.obj-code
              j_bar-code
              j_root-bar-code
              p-fact-order
              v_doc-num-price
              d_price-sale
              d_road-tax
              d_excise
              no-error
          }
          if error-status :error
          then do:
            next .
          end.
          {&SetCursorWait}
          assign
            p-rest-sum  = p-rest-sum  + bf_stk-supp-line.fact-qnty * d_price-sale
            p-rest-qnty = p-rest-qnty + bf_stk-supp-line.fact-qnty
          .
        end. /* for each bf_prt-obj */
      end. /* when "start":U */
      when "final":U
      then do:
        for each bf_prt-obj no-lock where
                 bf_prt-obj.obj-type = p-obj-type and
                 bf_prt-obj.obj-code = p-obj-code
        break by bf_prt-obj.artic
              by bf_prt-obj.prod-type
              by bf_prt-obj.prod-code
        :
          find last bf_stk-supp-line no-lock where
                    bf_stk-supp-line.obj-type    = bf_prt-obj.obj-type  and
                    bf_stk-supp-line.obj-code    = bf_prt-obj.obj-code  and
                    bf_stk-supp-line.cli-type    = p-supp-type          and
                    bf_stk-supp-line.cli-code    = p-supp-code          and
                    bf_stk-supp-line.artic       = bf_prt-obj.artic     and
                    bf_stk-supp-line.prod-type   = bf_prt-obj.prod-type and
                    bf_stk-supp-line.prod-code   = bf_prt-obj.prod-code and
                    bf_stk-supp-line.sum-type    = {&arh-cost}          and
                    bf_stk-supp-line.cat-id      = {&single-cat-id}     and
                    bf_stk-supp-line.fact-order <= p-fact-order         use-index category
          no-error .
          if not available bf_stk-supp-line
          then do:
            next .
          end. /* if not available bf_stk-supp-line */
          find first bf_goods no-lock where
                     bf_goods.artic     = bf_stk-supp-line.artic     and
                     bf_goods.prod-type = bf_stk-supp-line.prod-type and
                     bf_goods.prod-code = bf_stk-supp-line.prod-code no-error .
          if not available bf_goods
          then do:
            next .
          end. /* if not available bf_goods */
          { gbl/gdsbcode.i
              bf_goods.gds-code
              ?
              j_root-bar-code
              no-error
          }
          if error-status :error
          then do:
            next .
          end.
          {&SetCursorWait}
          { gbl/gdsbcode.i
              bf_goods.gds-code
              bf_prt-obj.prt-code
              j_bar-code
              no-error
          }
          if error-status :error
          then do:
            next .
          end.
          {&SetCursorWait}
          { gbl/bcodeprc.i
              bf_stk-supp-line.obj-type
              bf_stk-supp-line.obj-code
              j_bar-code
              j_root-bar-code
              p-fact-order
              v_doc-num-price
              d_price-sale
              d_road-tax
              d_excise
              no-error
          }
          if error-status :error
          then do:
            next .
          end.
          {&SetCursorWait}
          assign
            p-rest-sum  = p-rest-sum  + bf_stk-supp-line.fact-qnty * d_price-sale
            p-rest-qnty = p-rest-qnty + bf_stk-supp-line.fact-qnty
          .
        end. /* for each bf_prt-obj */
      end. /* when "final":U */
    end case. /* p-rest-type */
  end. /* on error */
end procedure. /* get-supp-rest */

procedure get-supp-cli-name :
  define  input parameter p-parts-rec as recid     no-undo .
  define output parameter p-doc-code  as character no-undo .

  define variable v-in-code   like ub.parts-supp.in-code   no-undo .
  define variable v-artic     like ub.parts-supp.artic     no-undo .
  define variable v-prod-type like ub.parts-supp.prod-type no-undo .
  define variable v-prod-code like ub.parts-supp.prod-code no-undo .
  define variable v-part-code like ub.parts-supp.part-code no-undo .
  define variable v-supp-type like ub.parts-supp.supp-type no-undo .
  define variable v-supp-code like ub.parts-supp.supp-code no-undo .

  define buffer buf_parts     for ub.parts      .
  define buffer bf_parts-supp for ub.parts-supp .
  define buffer buf_trn-doc   for ub.trn-doc    .

  do
  on error undo, return error return-value
  :
    find first buf_parts no-lock where
        recid( buf_parts ) = p-parts-rec no-error .
    if available buf_parts
    then do:
      assign
        v-in-code   = bf_parts.in-code
        v-artic     = bf_parts.artic
        v-prod-type = bf_parts.prod-type
        v-prod-code = bf_parts.prod-code
        v-part-code = bf_parts.part-code
        v-supp-type = bf_parts.supp-type
        v-supp-code = bf_parts.supp-code
      .
      repeat
      :
        find first bf_parts-supp no-lock where
                   bf_parts-supp.in-code   = v-in-code   and
                   bf_parts-supp.artic     = v-artic     and
                   bf_parts-supp.prod-type = v-prod-type and
                   bf_parts-supp.prod-code = v-prod-code and
                   bf_parts-supp.part-code = v-part-code no-error .
        if not available bf_parts-supp
        then do:
          leave .
        end.
        assign
          v-in-code   = bf_parts-supp.orig-in-code
          v-artic     = bf_parts-supp.artic
          v-prod-type = bf_parts-supp.prod-type
          v-prod-code = bf_parts-supp.prod-code
          v-part-code = bf_parts-supp.orig-part-code
          v-supp-type = bf_parts-supp.supp-type
          v-supp-code = bf_parts-supp.supp-code
        .
      end. /* repeat */
      find first buf_trn-doc no-lock where
                 buf_trn-doc.doc-code = v-in-code no-error .
      if available buf_trn-doc
      then do:
        case p-trn-doc-num :
          when 1
          then do:
            { str/tdat-val.i
               buf_trn-doc.doc-code
               {&trdcattr-nids}
               p-doc-code
               v-type
               no-error
               }
            {&SetCursorWait}
            if error-status :error or
               p-doc-code = "":U   or
               p-doc-code = ?
            then do:
              assign
                p-doc-code = '@' + buf_trn-doc.doc-code
              .
            end.
          end.
          otherwise do:
            assign
              p-doc-code = buf_trn-doc.doc-code
            .
          end.
        end case. /* p-trn-doc-num */
      end. /* if available buf_trn-doc */
    end. /* if available buf_parts */
  end. /* on error */
end procedure. /* get-supp-cli-name */