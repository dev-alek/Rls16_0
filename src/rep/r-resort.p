block-level on error undo, throw.
/*

$Revision: 503102c480fa, 3492, rls $
$Author: EShklyar $
$Date: 2023/10/16 15:13:36 $
$Workfile: r-resort.p $
$Archive: rep/r-resort.p $

Печать документа пересортицы

Автор: Булгаков Андрей Николаевич
Дата создания: 05/23/06
Author: Andrew Bulgakoff
Creation date: 05/23/06

*/

define input parameter p-parent-proc as widget-handle no-undo .
define input parameter p-rec-trn-doc as recid         no-undo .

define variable vss-revision    as character no-undo initial "$Revision: 503102c480fa, 3492, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/10/16 15:13:36 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-resort.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-resort.p $":U .
define variable vss-description as character no-undo initial "Печать документа пересортицы":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/r-pril.i   }
{ gbl/waitfram.i }
{ cmp/breakstr.i }

define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo initial yes .
define variable g#log         as logical no-undo .

{ gbl/paramls.i  }
{ rep/r-resort.i }

define variable v-host-name    as character no-undo .
define variable p-host-code    as integer   no-undo .
define variable v-doc-num      as character no-undo .
define variable price-sale-in  as decimal   no-undo .
define variable price-sale-out as decimal   no-undo .
define variable d-road-tax     as decimal   no-undo .
define variable d-excise       as decimal   no-undo .
define variable sum-sale-in    as decimal   no-undo .
define variable sum-sale-out   as decimal   no-undo .
define variable sum-sale-total as decimal   no-undo .
define variable sum-cost-in    as decimal   no-undo .
define variable sum-cost-out   as decimal   no-undo .
define variable sum-cost-total as decimal   no-undo .
define variable itog-sum-sale-in  as decimal   no-undo .
define variable itog-sum-sale-out as decimal   no-undo .
define variable itog-sum-cost-in  as decimal   no-undo .
define variable itog-sum-cost-out as decimal   no-undo .
define variable fact-qnty-in   as decimal   no-undo .
define variable fact-qnty-out  as decimal   no-undo .
define variable t_inv-date     as date     no-undo .
define variable j_LineCount    as integer   no-undo .
define variable word-sum-total as character no-undo .
define variable word-sum-temp1 as character no-undo .
define variable word-sum-temp2 as character no-undo .
define variable word-sum-buf-1 as character no-undo .
define variable word-sum-buf-2 as character no-undo .
define variable word-sum-buf-3 as character no-undo .
define variable v-stroka       as integer   no-undo .
define variable v-stroka-out   as integer   no-undo .
define variable v-sum-sale-in  as decimal   no-undo .
define variable v-doc-date     as character no-undo .
define variable v-inv-date     as character no-undo .  
define buffer bf_trn-doc    for ub.trn-doc    .
define buffer bf_doc-line   for ub.doc-line   .
define buffer bf_goods-in   for ub.goods      .
define buffer bf_goods-out  for ub.goods      .
define buffer bf_object     for ub.clients    .
define buffer bf_parts-root for ub.parts-root .
define buffer bf_parts-in   for ub.parts      .
define buffer bf_parts-out  for ub.parts      .

define temp-table tt-resort-out no-undo
  field j_LineCount as integer
  field stroka      as integer
  field artic       like ub.goods.artic
  field gds-name    like ub.goods.gds-name
  field gds-code    like ub.goods.gds-code
  field unit-base   like ub.goods.unit-base
  field fact-qnty   as decimal
  field price-sale  as decimal
  field sum-sale    as decimal
  field d-per-cent  as decimal
  field sum-cost    as decimal
.
define temp-table tt-resort-in no-undo
  field j_LineCount as integer
  field artic       like ub.goods.artic
  field gds-name    like ub.goods.gds-name
  field gds-code    like ub.goods.gds-code
  field unit-base   like ub.goods.unit-base
  field fact-qnty   as decimal
  field price-sale  as decimal
  field sum-sale    as decimal
  field sum-cost    as decimal
.

&scop ReportWidth 125
&scop f-l Sparse,Word-Sum,Total-Word,Roubles,Copecks

{ gbl/std-func.i {&f-l} }

   
function CenterLine returns character ( input p-in-string as character
                                      , input p-rep-width as integer ) :
  define variable v-out-string as character no-undo .

  run get-center-line in this-procedure
    (  input p-in-string
    ,  input p-rep-width
    , output v-out-string
    ) no-error .
  return ( if error-status :error then '':U else v-out-string ) .
end function. /* CenterLine */

define stream text_out .

do
on error undo, return error return-value
:
  run WaitFram-Show in this-procedure
    ( input 'Идет формирование отчета, ждите...'
    ) .
  {&SetCursorWait}
  run get-report-num  in p-parent-proc
    (
      output g#report-num
    ) .
  run get-quest-print in p-parent-proc
    (
      output g#quest-print
    ) .
  find first bf_trn-doc no-lock where
      recid( bf_trn-doc ) = p-rec-trn-doc no-error .
  if not available bf_trn-doc
  then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    message substitute( 'Не найден документ пересортицы с идентификатором &1.'
                      , p-rec-trn-doc
                      )
    view-as alert-box error .
    undo, return error .
  end.
  if bf_trn-doc.doc-type     <> {&inventory} or
     bf_trn-doc.ext-doc-type <> {&TDEDT_Peresort}
  then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    message
      'Данная форма только для печати документа пересортицы.'
    view-as alert-box error .
    undo, return error .
  end.
  find first bf_object no-lock where
             bf_object.obj-type = bf_trn-doc.obj-type and
             bf_object.obj-code = bf_trn-doc.obj-code .

  { gbl/hostname.i
      bf_trn-doc.obj-type
      bf_trn-doc.obj-code
      p-host-code
      v-host-name
      no-error
  }
  if error-status :error
  then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    message
      'Не могу определить текущую фирму.'
    view-as alert-box error .
    undo, return error .
  end.
  if bf_trn-doc.host-code <> p-host-code
  then do:
    {&SetCursorNo}
    run waitfram-hide in this-procedure .
    message
      'Ошибка определения текущей фирмы.'
    view-as alert-box error .
    undo, return error .
  end.
  assign
    t_inv-date = ( if bf_trn-doc.status_ = {&fact} then bf_trn-doc.fact-date else bf_trn-doc.doc-date )
  .

  { cmp/open-out.i stream text_out " " {&LS_PS_A4} }
  put stream text_out unformatted
    '-----------------------------------------------------------------------' skip
    '|     Предприятие, организация     |            Со склада             |' skip
    '-----------------------------------------------------------------------' skip
    '|' +
    substring( string( CenterLine( v-host-name,        34 ) + fill( ' ':U, 34 ), "x(34)":U ), 1, 34 )
        +                              '|' +
    substring( string( CenterLine( bf_object.obj-name, 34 ) + fill( ' ':U, 34 ), "x(34)":U ), 1, 34 )
                                                                        + '|' skip
    '-----------------------------------------------------------------------' skip( 4 )
    space( 59 ) '-----------------------------------' skip
    space( 59 ) '|Номер документа |Дата составления|' skip
    space( 59 ) '-----------------------------------' skip
    caps(
    substring( string( CenterLine( entry( lookup( bf_trn-doc.ext-doc-type, {&TDEDT_List} ), {&TDEDT_List-full} ), 59 )
                     + fill( ' ':U, 59 ), "x(59)":U )
                     , 1, 59 )
        ) +     '|' +
    substring( string( CenterLine(         bf_trn-doc.doc-code,                   16 ) + fill( ' ':U, 16 ), "x(34)":U ), 1, 16 )
                               + '|' +
    substring( string( CenterLine( string( bf_trn-doc.doc-date, "99/99/9999":U ), 16 ) + fill( ' ':U, 16 ), "x(34)":U ), 1, 16 )
                                                + '|' skip
    space( 59 ) '-----------------------------------' skip( 1 )
    'Примечание: ' substring( replace( bf_trn-doc.PS, {&new-line}, ' ':U ), 1, {&ReportWidth} ) skip
    'Дата проведения: ' string( t_inv-date, "99/99/9999":U ) skip
  .
  put stream text_out unformatted
    '-----------------------------------------------------------------------------------------------------------------------------------' skip
    '|  N | Номенклатурный |     Наименование, сорт,                        |Ед.|Количест-|  Цена   |   Сумма   |     %     |   Сумма   |' skip
    '| п/п|     номер      |        размер                                  |изм|   во    |Розничная| Розничная | Отклонения|  Учетная  |' skip
    /*'-----------------------------------------------------------------------------------------------------------------------------' skip */
  .

  run r-resort-init            in this-procedure .
  
      v-doc-date =     string( entry(2,string(bf_trn-doc.doc-date),"/") + "/" + 
    entry(1,string(bf_trn-doc.doc-date),"/") + "/" + 
    entry(3,string(bf_trn-doc.doc-date),"/"))
    . 
      v-inv-date =     string( entry(2,string(t_inv-date),"/") + "/" + 
    entry(1,string(t_inv-date),"/") + "/" + 
    entry(3,string(t_inv-date),"/"))
    . 
  run r-resort-write-cell-data in this-procedure
    ( input {&r-resort-h_OwnFirm}
    , input trim( v-host-name )
    ) .
  run r-resort-write-cell-data in this-procedure
    ( input {&r-resort-h_ObjName}
    , input trim( bf_object.obj-name )
    ) .
  run r-resort-write-cell-data in this-procedure
    ( input {&r-resort-h_DocType}
    , input caps( entry( lookup( bf_trn-doc.ext-doc-type, {&TDEDT_List} ), {&TDEDT_List-full} ) )
    ) .
  run r-resort-write-cell-data in this-procedure
    ( input {&r-resort-h_DocCode}
    , input bf_trn-doc.doc-code
    ) .
  run r-resort-write-cell-data in this-procedure
    ( input {&r-resort-h_DocDate}
    , input string( v-doc-date )
    ) .
  run r-resort-write-cell-data in this-procedure
    ( input {&r-resort-h_DocFact}
    , input string( v-inv-date )
    ) .
  run r-resort-write-cell-data in this-procedure
    ( input {&r-resort-h_PostScr}
    , input trim( replace( bf_trn-doc.PS, {&new-line}, ' ':U ) )
    ) .
  assign
    j_LineCount    = 0
    sum-sale-total = 0.00
    sum-cost-total = 0.00
  .
  for each  bf_parts-root no-lock where
            bf_parts-root.doc-code = bf_trn-doc.doc-code


    , first bf_goods-out  no-lock where
            bf_goods-out.gds-code  = bf_parts-root.orig-gds-code
    , first bf_goods-in   no-lock where
            bf_goods-in.gds-code   = bf_parts-root.gds-code
   break by bf_parts-root.doc-code
         by bf_parts-root.orig-gds-code
         by bf_parts-root.gds-code
  :
    if first-of (bf_parts-root.gds-code) then do:
      assign
        sum-sale-in    = 0.00
        sum-sale-out   = 0.00
        sum-cost-in    = 0.00
        sum-cost-out   = 0.00
        fact-qnty-in   = 0.00
        v-sum-sale-in  = 0.00
        fact-qnty-out  = 0.00.
    end.


    { gbl/bcodeprc.i
        bf_trn-doc.obj-type
        bf_trn-doc.obj-code
        bf_goods-in.gds-code
        0
        bf_trn-doc.fact-order
        v-doc-num
        price-sale-in
        d-road-tax
        d-excise
        no-error
    }
    if error-status :error
    then do:
      {&SetCursorNo}
      run waitfram-hide in this-procedure .
      message
        'Не могу определить текущие продажные цены для оприходованного товара.' skip
        bf_goods-in.artic bf_goods-in.prod-type bf_goods-in.prod-code '.'
      view-as alert-box error .
      undo, return error .
    end.
    { gbl/bcodeprc.i
        bf_trn-doc.obj-type
        bf_trn-doc.obj-code
        bf_goods-out.gds-code
        0
        bf_trn-doc.fact-order
        v-doc-num
        price-sale-out
        d-road-tax
        d-excise
        no-error
    }
    if error-status :error
    then do:
      {&SetCursorNo}
      run waitfram-hide in this-procedure .
      message
        'Не могу определить текущие продажные цены для оприходованного товара.' skip
        bf_goods-in.artic bf_goods-in.prod-type bf_goods-in.prod-code '.'
      view-as alert-box error .
      undo, return error .
    end.

     for each bf_parts-out no-lock where
        bf_parts-out.out-code  = bf_trn-doc.doc-code          and
        bf_parts-out.obj-type  = bf_trn-doc.obj-type          and
        bf_parts-out.obj-code  = bf_trn-doc.obj-code          and
        bf_parts-out.artic     = bf_goods-out.artic           and
        bf_parts-out.prod-type = bf_goods-out.prod-type       and
        bf_parts-out.prod-code = bf_goods-out.prod-code       and
        bf_parts-out.fact-qnty < 0 /*and
             bf_parts-out.in-code   = bf_parts-root.orig-in-code   and
             bf_parts-out.part-code = bf_parts-root.orig-part-code*/ on error undo, return error return-value :
        if bf_parts-out.part-code = bf_parts-root.orig-part-code then 
        do:                
           assign
              sum-sale-out  = sum-sale-out  + price-sale-out          * bf_parts-out.fact-qnty
              sum-cost-out  = sum-cost-out  + bf_parts-out.price-rubl * bf_parts-out.fact-qnty 
              fact-qnty-out = fact-qnty-out + bf_parts-out.fact-qnty
              .
        end.
        else 
        do:
           if bf_parts-out.out-code   = bf_parts-root.in-code then 
           do:
              assign
                 sum-sale-out  = sum-sale-out  + price-sale-out          * bf_parts-out.fact-qnty
                 sum-cost-out  = sum-cost-out  + bf_parts-out.price-rubl * bf_parts-out.fact-qnty 
                 fact-qnty-out = fact-qnty-out + bf_parts-out.fact-qnty
                 .            
           end.   
        end.   
     end. /* for each bf_parts-out */
     for each bf_parts-in   no-lock where
        bf_parts-in.out-code   = bf_trn-doc.doc-code         and
        bf_parts-in.obj-type   = bf_trn-doc.obj-type         and
        bf_parts-in.obj-code   = bf_trn-doc.obj-code         and
        bf_parts-in.artic      = bf_goods-in.artic           and
        bf_parts-in.prod-type  = bf_goods-in.prod-type       and
        bf_parts-in.prod-code  = bf_goods-in.prod-code       and
        bf_parts-in.fact-qnty > 0 /*and
             bf_parts-in.in-code    = bf_parts-root.in-code       and
             bf_parts-in.part-code  = bf_parts-root.part-code */    on error undo, return error return-value :
        if bf_parts-in.part-code  = bf_parts-root.part-code then 
        do:                
           assign
              sum-sale-in  = sum-sale-in  + price-sale-in          * bf_parts-in.fact-qnty
              sum-cost-in  = sum-cost-in  + bf_parts-in.price-rubl * bf_parts-in.fact-qnty
              fact-qnty-in = fact-qnty-in + bf_parts-in.fact-qnty
              .
        end.
        else 
        do:
           if bf_parts-in.in-code    = bf_parts-root.in-code then 
           do:
              assign
                 sum-sale-in  = sum-sale-in  + price-sale-in          * bf_parts-in.fact-qnty
                 sum-cost-in  = sum-cost-in  + bf_parts-in.price-rubl * bf_parts-in.fact-qnty
                 fact-qnty-in = fact-qnty-in + bf_parts-in.fact-qnty
                 .            
           end.   
        end.   
     end.
   /* end. */
    find first tt-resort-out where tt-resort-out.artic = bf_goods-out.artic no-error .
    if not available tt-resort-out then do :
        create tt-resort-out .
      assign
        j_LineCount    = j_LineCount + 1
          tt-resort-out.j_LineCount     = j_LineCount
          tt-resort-out.artic           = bf_goods-out.artic
          tt-resort-out.gds-name        = bf_goods-out.gds-name
          tt-resort-out.unit-base       = bf_goods-out.unit-base
          tt-resort-out.fact-qnty       = fact-qnty-out
          tt-resort-out.price-sale      = price-sale-out
          tt-resort-out.sum-sale        = sum-sale-out
          tt-resort-out.sum-cost        = sum-cost-out
          v-sum-sale-in                 = 0
      .
    end .
    find first tt-resort-in where tt-resort-in.artic = bf_goods-in.artic no-error .
    if not available tt-resort-in then do :
       create tt-resort-in .
       assign
          j_LineCount                = j_LineCount + 1
          tt-resort-in.j_LineCount   = j_LineCount
          tt-resort-in.artic         = bf_goods-in.artic
          tt-resort-in.gds-name      = bf_goods-in.gds-name
          tt-resort-in.unit-base     = bf_goods-in.unit-base
          tt-resort-in.fact-qnty     = fact-qnty-in
          tt-resort-in.price-sale    = price-sale-in
          tt-resort-in.sum-sale      = sum-sale-in
          tt-resort-in.sum-cost      = sum-cost-in
          v-sum-sale-in              = v-sum-sale-in + sum-sale-in
        .
    end .
    find first tt-resort-out where tt-resort-out.artic = bf_goods-out.artic no-error .
    if available tt-resort-out then do :
       assign tt-resort-out.d-per-cent = (( v-sum-sale-in + tt-resort-out.sum-sale) / v-sum-sale-in ) * 100.00 .
    end .
  end. /* for each bf_parts-root */

  do while v-stroka ne j_LineCount :
    v-stroka = v-stroka + 1 .
    find first tt-resort-out where tt-resort-out.j_LineCount = v-stroka no-error .
    if available tt-resort-out then do :
      assign
        itog-sum-cost-out = itog-sum-cost-out + tt-resort-out.sum-cost
        itog-sum-sale-out = itog-sum-sale-out + tt-resort-out.sum-sale
        v-stroka-out      = v-stroka-out      + 1
      .
      put stream text_out unformatted
        '|----|----------------|------------------------------------------------|---|---------|---------|-----------|-----------|-----------|' skip
      .
      put stream text_out unformatted                                                '|'      /* списание */
        string( string( v-stroka-out,                 ">>>9":U  ), "x(4)":U  )       '|'      /* 1 */
        string( tt-resort-out.artic,                  "x(16)":U  )                   '|'      /* 2 */
        string( tt-resort-out.gds-name,               "x(48)":U )                    '|'      /* 3 */
        string( tt-resort-out.unit-base,              "x(3)":U  )                    '|'      /* 4 */
        string( string( tt-resort-out.fact-qnty,      "->>>>9.<<":U ), "x(9)":U  )   '|'      /* 5 */
        string( string( tt-resort-out.price-sale,     ">>>>>9.99":U ), "x(9)":U  )   '|'      /* 6 */
        string( string( tt-resort-out.sum-sale,       "->>>>>>9.99":U ), "x(11)":U ) '|'      /* 7 */
        string( string( tt-resort-out.d-per-cent,     "->>>>>9.<<%":U ), "x(11)":U ) '|'      /* 8 */
        string( string( tt-resort-out.sum-cost,       "->>>>>>9.99":U ), "x(11)":U ) '|' skip /* 9 */
      .
      if length( tt-resort-out.gds-name ) > 48
      then do:
        put stream text_out unformatted
          '|    |                |'
          string( substring( tt-resort-out.gds-name, 49 ), "x(48)":U )
          '|   |         |         |           |           |           |' skip
        .
      end.
      run r-resort-write-line-data in this-procedure
        (                                                                     /* списание */
          input v-stroka-out                                                  /* 1 */
        , input "'" + tt-resort-out.artic                                           /* 2 */
        , input tt-resort-out.gds-name                                        /* 3 */
        , input tt-resort-out.unit-base                                       /* 4 */
        , input trim( string( tt-resort-out.fact-qnty,    "->>>>9.<<":U ) )   /* 5 */
        , input trim( string( tt-resort-out.price-sale,   ">>>>>9.99":U ) )   /* 6 */
        , input trim( string( tt-resort-out.sum-sale,     "->>>>>>9.99":U ) ) /* 7 */
        , input trim( string( tt-resort-out.d-per-cent,   "->>>>>>9.<<":U ) ) /* 8 */
        , input trim( string( tt-resort-out.sum-cost,     "->>>>>>9.99":U ) ) /* 9 */
        ) .
    end.
    find first tt-resort-in where tt-resort-in.j_LineCount = v-stroka no-error .
    if available tt-resort-in then do :
      assign
          itog-sum-cost-in = itog-sum-cost-in + tt-resort-in.sum-cost
          itog-sum-sale-in = itog-sum-sale-in + tt-resort-in.sum-sale
        .
      put stream text_out unformatted
        '|    |----------------|------------------------------------------------|---|---------|---------|-----------|-----------|-----------|' skip
      .
      put stream text_out unformatted                                            '|'      /* оприходование */
                                                                             '    |'      /* 1 */
        string( tt-resort-in.artic,               "x(16)":U  )                   '|'      /* 2 */
        string( tt-resort-in.gds-name,            "x(48)":U )                    '|'      /* 3 */
        string( tt-resort-in.unit-base,           "x(3)":U  )                    '|'      /* 4 */
        string( string ( tt-resort-in.fact-qnty,  "->>>>9.<<":U ), "x(9)":U  )   '|'      /* 5 */
        string( string ( tt-resort-in.price-sale, ">>>>>9.99":U ), "x(9)":U  )   '|'      /* 6 */
        string( string ( tt-resort-in.sum-sale,   "->>>>>>9.99":U ), "x(11)":U ) '|'      /* 7 */
                                                                      '           |'      /* 8 */
        string( string( tt-resort-in.sum-cost,    "->>>>>>9.99":U ), "x(11)":U ) '|' skip /* 9 */
      .
      if length( tt-resort-in.gds-name ) > 48
      then do:
        put stream text_out unformatted
          '|    |                |'
          string( substring( tt-resort-in.gds-name, 49 ), "x(48)":U )
          '|   |         |         |           |           |           |' skip
        .
      end.
    run r-resort-write-line-data in this-procedure
      (                                                                      /* оприходование */
        input ?                                                              /* 1 */
        , input tt-resort-in.artic                                           /* 2 */
        , input tt-resort-in.gds-name                                        /* 3 */
        , input tt-resort-in.unit-base                                       /* 4 */
        , input trim( string( tt-resort-in.fact-qnty,    "->>>>9.<<":U ) )   /* 5 */
        , input trim( string( tt-resort-in.price-sale,   ">>>>>9.99":U ) )   /* 6 */
        , input trim( string( tt-resort-in.sum-sale,     "->>>>>>9.99":U ) ) /* 7 */
      , input ?                                                              /* 8 */
        , input trim( string( tt-resort-in.sum-cost,     "->>>>>>9.99":U ) ) /* 9 */
      ) .
    end.
  end.
  assign
    sum-sale-total = sum-sale-total + itog-sum-sale-in + itog-sum-sale-out
    sum-cost-total = sum-cost-total + itog-sum-cost-in + itog-sum-cost-out
  .
  assign
    word-sum-total = Total-Word( sum-sale-total, Roubles( sum-sale-total ), Copecks( sum-sale-total ) )
    word-sum-buf-1 = '':U
    word-sum-buf-2 = '':U
    word-sum-buf-3 = '':U
  .
  if length( word-sum-total ) > 97
  then do:
    assign
      word-sum-temp1 = breakstr( word-sum-total, 97, input-output word-sum-buf-1, input-output word-sum-buf-2 )
      word-sum-temp2 = word-sum-buf-2
    .
    if length( word-sum-temp2 ) > 125
    then do:
      assign
        word-sum-temp1 = breakstr( word-sum-temp2, 125, input-output word-sum-buf-2, input-output word-sum-buf-3 )
      .
    end.
    else do:
      assign
        word-sum-buf-2 = word-sum-temp2
        word-sum-buf-3 = '':U
      .
    end.
  end.
  else do:
    assign
      word-sum-buf-1 = word-sum-total
      word-sum-buf-2 = '':U
      word-sum-buf-3 = '':U
    .
  end.
  put stream text_out unformatted
    '------------------------------------------------------------------------------------------------------------------------------------' skip
    '                                                              Итого:                           |'
    string( string( sum-sale-total, "->>>>>>9.99":U ), "x(11)":U )
                                                                                                        '|           |'
    string( string( sum-cost-total, "->>>>>>9.99":U ), "x(11)":U )
                                                                                                                                '|' skip
    '                                                                                               -------------------------------------' skip
    '    Разница сумм розничная: '
    string( word-sum-buf-1, "x(97)":U  ) skip
    string( word-sum-buf-2, "x(125)":U ) skip
    string( word-sum-buf-3, "x(125)":U ) skip
  .
  if word-sum-buf-2 <> '':U
  then do:
    put stream text_out unformatted
      skip
    .
    if word-sum-buf-3 <> '':U
    then do:
      put stream text_out unformatted
        skip
      .
    end.
  end.
  put stream text_out unformatted
    '    МОЛ:        _________________________     _________________________     _________________________'                         skip
    '                       должность                       подпись                 расшифровка подписи   '                         skip( 1 )
    '    Бухгалтер:  _________________________     _________________________'                                                       skip
    '                       подпись                    расшифровка подписи  '                                                       skip( 1 )
  .
  run r-resort-write-cell-data in this-procedure
    ( input {&r-resort-h_SaleTot}
    , input trim( string( sum-sale-total, "->>>>>>9.99":U ) )
    ) .
  run r-resort-write-cell-data in this-procedure
    ( input {&r-resort-h_CostTot}
    , input trim( string( sum-cost-total, "->>>>>>9.99":U ) )
    ) .
  run r-resort-write-cell-data in this-procedure
    ( input {&r-resort-h_WordTot}
    , input 'Разница сумма розничная: ' + word-sum-total
    ) .
  run waitfram-hide  in this-procedure .
  run r-resort-close in this-procedure .
  output stream text_out close .
  {&SetCursorNo}
  { rep/q-print.i 2 }
end. /* on error */

procedure get-center-line :
  define  input parameter p-in-string  as character no-undo .
  define  input parameter p-rep-width  as integer   no-undo .
  define output parameter p-out-string as character no-undo .

  do
  on error undo, return error return-value
  :
    if length( p-in-string ) < p-rep-width
    then do:
      assign
        p-out-string = fill( ' ':U, integer( ( p-rep-width - length( p-in-string ) ) * 0.5 ) ) + p-in-string
      .
    end.
    else do:
      assign
        p-out-string = p-in-string
      .
    end.
  end. /* on error */
end procedure. /* get-center-line */