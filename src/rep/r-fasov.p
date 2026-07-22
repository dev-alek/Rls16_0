block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-fasov.p $
$Archive: rep/r-fasov.p $

Лист журнала фасовочных работ

Автор: Кочетков Михаил Юрьевич
Дата создания: 07/18/07
Author: Michael Kochetkov
Creation date: 07/18/07

*/

define input parameter p-mainmenu-handle  as handle           no-undo.
define input parameter p-trn-doc-recid as recid no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-fasov.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-fasov.p $":U .
define variable vss-description as character no-undo init "Лист журнала фасовочных работ.".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/r-pril.i   }
{ rep/p-fmt.i    }
{ str/trdcalib.i }
{ ref/gds-attr.i }
{ cmp/library.i  }
{ gbl/paramls.i  }
define variable g#report-num    as integer      no-undo.
{ rep/r-fasxl.i  }

define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.

{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get " " p-mainmenu-handle }
run get-report-num in p-mainmenu-handle (
    output g#report-num
).
run get-quest-print in p-mainmenu-handle (
    output g#quest-print
).

&scoped-define left-margin 1
&scoped-define right-margin 195
&scoped-define max-width 195
&scoped-define tab-stop1 22
&scoped-define bottom-page-line-size 2
&scoped-define group-line-size 2
&scoped-define page-result-line-size 2

&scop max-width-from-tab1 86
&scop tab-stop2 60
&scop max-width-from-tab2 70
&scop tab-stop3 80
&scop tab-stop4 100
&scop note-line-size 12

/*----S----- Таблица --------------------------------*/
&GLOB P-S 1
&GLOB P-X 195        /*длина линии*/
&GLOB P-X0 193       /*длина внутренней линии = длина линии - 2*/
&GLOB P-X1 184       /*длина внутренней линии */

&GLOB P-C2-S    {&P-S} + 11
&GLOB P-C3-S    {&P-S} + 20
&GLOB P-C4-S    {&P-S} + 28
&GLOB P-C5-S    {&P-S} + 63
&GLOB P-C6-S    {&P-S} + 67
&GLOB P-C7-S    {&P-S} + 78
&GLOB P-C8-S    {&P-S} + 89
&GLOB P-C9-S    {&P-S} + 104
&GLOB P-C10-S   {&P-S} + 139
&GLOB P-C11-S   {&P-S} + 143
&GLOB P-C12-S   {&P-S} + 154
&GLOB P-C13-S   {&P-S} + 169
&GLOB P-C14-S   {&P-S} + 186
/*&GLOB P-C15-S   {&P-S} + 125*/
&GLOB P-E       {&P-S} + 195
/*----E----- Таблица --------------------------------*/

    define shared variable sort-name    as logical          no-undo.
    define shared variable sort-gr      as logical          no-undo.

    define stream out-stream .

    define variable v-line-counter  as integer      no-undo.
    define variable v-single-line   as character    no-undo.

    define variable v-cli-name      as character    no-undo.
    define variable v-obj-name      as character    no-undo.

    define variable v-first-line    as logical      no-undo.

    define variable tot-sum as decimal   no-undo .
    define variable tot-qnty as decimal   no-undo .
    define variable b-code as integer   no-undo .

    define buffer buf_trn-doc   for trn-doc.
    define buffer buf_goods     for goods.
    define buffer buf_parts     for parts.
    define buffer buf_clients   for clients.
    define buffer buf_doc-line  for doc-line.
    define buffer buf_gds-dtl   for gds-dtl.

    define variable v-sort-prod         as character         no-undo.
    define variable v-par-type          as character         no-undo.
    run gbl/conf-rd.p ( input "sort-prd", input "", input "", input 0, input "", input "", input "", input no, output v-sort-prod, output v-par-type) no-error.
    if error-status :error then  assign  v-sort-prod = "no" .

DEFINE temp-table temp-gds no-undo
    field   artic            as char
    field   prod-type        as char
    field   prod-code        as integer
    field   part-code        like parts.part-code
    field   in-code          like parts.in-code
    field   gds-code         as integer
    field   gds-name         as char
    field   gds-name1        as char
    field   grp-name         as char
    field   upak             as decimal
    field   qnty             as decimal
    field   price            as decimal
    field   qnty1            as decimal
    field   price1           as decimal
    field   sum              as decimal
    field   num-ser          as character
    field   seria            as character
    field   line-num         like doc-line.line-num
    field   data             as date
    field   last-date        as date
    index pi  is primary   artic  prod-type prod-code
    index pi1              gds-name
    index pi2              grp-name
    index pi3              line-num
.

/*do*/
/*for buf_trn-doc*/
/*  , buf_goods*/
/*  , buf_clients*/
/*  , buf_doc-line*/
/*on error undo, return error*/
/*:*/
    find first buf_trn-doc no-lock where recid( buf_trn-doc ) = p-trn-doc-recid .

    find first buf_clients no-lock
         where buf_clients.obj-type = buf_trn-doc.obj-type
           and buf_clients.obj-code = buf_trn-doc.obj-code
    .
    assign  v-obj-name = string( buf_clients.obj-name )  .
    find first buf_clients no-lock
         where buf_clients.obj-type = buf_trn-doc.cli-type
           and buf_clients.obj-code = buf_trn-doc.cli-code
    .
    if available buf_clients then  assign  v-cli-name = string( buf_clients.obj-name ) .
    else                           assign  v-cli-name = "" .

    define variable v-attr-value  as character no-undo .
    define variable v-attr-type   as character no-undo .
    define variable v-osnov       as character initial "" no-undo .
    define variable v-ser_on_pack   as character.
    { str/tdat-val.i    buf_trn-doc.doc-code     {&trdcattr-ser_on_pack}   v-ser_on_pack   v-attr-type  }
    { str/tdat-val.i    buf_trn-doc.doc-code     {&trdcattr-nids}   v-attr-value   v-attr-type  }
    assign v-osnov = v-attr-value .
    { str/tdat-val.i    buf_trn-doc.doc-code     {&trdcattr-dids}   v-attr-value   v-attr-type  }
    if v-attr-value <> ? and trim(v-attr-value) <> "" then assign v-osnov = v-osnov + " от " + v-attr-value .

    assign
        v-single-line       = fill( "-", {&right-margin} )
        v-line-counter      = 0
    .

    { cmp/open-out.i stream out-stream " " {&LS_PS_A4} }
    run r-fasxl-init in this-procedure .

    form header
        space({&P-S}) v-single-line format "X({&P-X})" skip    'Продолжение - на следующей странице' at 90 skip
        with frame BottomFrame width {&A4_LS} page-bottom no-labels no-box .
    view stream out-stream frame BottomFrame .

    { gbl/working.i }

    put stream out-stream
        space(1 )  v-obj-name  format "X(60)"
        skip space( {&tab-stop2} ) "Лист журнала фасовочных работ № "   buf_trn-doc.doc-code   format "X(14)"
        " от " ( if buf_trn-doc.status_ <> {&fact} then string(buf_trn-doc.doc-date) + "   Статус: " + caps(buf_trn-doc.status_) else string(buf_trn-doc.fact-date) )  format "X(50)"
        skip space( 1 ) string( "Поставщик (отправитель): " + v-cli-name + v-osnov )  format "X(160)"
        skip
    .
    run r-fasxl-write-cell-data in this-procedure ( input {&r-fasxl-h_docName}, input string( buf_trn-doc.doc-code + " от " + ( if buf_trn-doc.status_ <> {&fact} then string(buf_trn-doc.doc-date) + "   Статус: " + caps(buf_trn-doc.status_) else string(buf_trn-doc.fact-date) ))) .
    run r-fasxl-write-cell-data in this-procedure ( input {&r-fasxl-h_Obj}, input v-obj-name) .
    run r-fasxl-write-cell-data in this-procedure ( input {&r-fasxl-h_cliFrom}, input string( "Поставщик (отправитель): " + v-cli-name + v-osnov )) .

    run print-header in this-procedure .

    /* заполняем tt */
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code :
      find first  buf_goods no-lock where buf_goods.artic = buf_doc-line.artic and buf_goods.prod-type = buf_doc-line.prod-type and buf_goods.prod-code = buf_doc-line.prod-code .
      run gds-attr-value in this-procedure (
           input  buf_goods.gds-code,
           input  {&attr-fasovka},
           output v-attr-value,
           output v-attr-type )
           .
      if lookup(v-attr-value, 'true,yes':u) = 0 then next .
      for each buf_parts no-lock
        where buf_parts.out-code   = buf_doc-line.doc-code
          and buf_parts.obj-type   = buf_doc-line.obj-type
          and buf_parts.obj-code   = buf_doc-line.obj-code
          and buf_parts.artic      = buf_doc-line.artic
          and buf_parts.prod-type  = buf_doc-line.prod-type
          and buf_parts.prod-code  = buf_doc-line.prod-code
        :
        create temp-gds .
        assign
          temp-gds.artic       = buf_doc-line.artic
          temp-gds.prod-type   = buf_doc-line.prod-type
          temp-gds.prod-code   = buf_doc-line.prod-code
          temp-gds.part-code   = buf_parts.part-code
          temp-gds.in-code     = buf_parts.in-code
          temp-gds.gds-code    = buf_goods.gds-code
          temp-gds.gds-name1   = buf_goods.gds-name
          temp-gds.gds-name    = buf_goods.engl-name
          temp-gds.grp-name    = buf_goods.grp-name
          temp-gds.upak        = if buf_goods.qnty-cart = 0 then 1 else buf_goods.qnty-cart
          temp-gds.qnty        = buf_parts.fact-qnty
          temp-gds.qnty1       = buf_parts.fact-qnty / temp-gds.upak
          temp-gds.line-num    = buf_doc-line.line-num
          temp-gds.data        = if buf_trn-doc.status_ <> {&fact} then buf_trn-doc.doc-date else buf_trn-doc.fact-date
          temp-gds.last-date   = buf_parts.last-date
          temp-gds.num-ser     = entry(1,buf_parts.part-code,' ')
        .
        if num-entries(buf_parts.part-code,' ') > 1 then do:
          assign temp-gds.seria = entry(2,buf_parts.part-code,' ') .
          if num-entries(buf_parts.part-code,' ') > 2 then assign temp-gds.seria = temp-gds.seria + entry(3,buf_parts.part-code,' ') .
        end.

        if trim(temp-gds.gds-name) = "" then  assign temp-gds.gds-name = temp-gds.gds-name1 .
        if temp-gds.num-ser = ? then assign temp-gds.num-ser = ""  .
        if temp-gds.seria = ?   then assign temp-gds.seria = ""  .
        if buf_trn-doc.status_ = {&fact} then do:
          assign
            tot-sum  = 0
            tot-qnty = 0
          .
          FOR EACH buf_gds-dtl NO-LOCK
            WHERE buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
              and buf_gds-dtl.artic     = buf_doc-line.artic
              and buf_gds-dtl.prod-type = buf_doc-line.prod-type
              and buf_gds-dtl.prod-code = buf_doc-line.prod-code
            :
            assign
              tot-sum  = tot-sum  + buf_gds-dtl.doc-qnty * buf_gds-dtl.cur-base
              tot-qnty = tot-qnty + buf_gds-dtl.doc-qnty
            .
          end.
          if tot-qnty <> 0 then assign temp-gds.price = tot-sum / tot-qnty  .
        END.
        else do:
          { gbl/gdsbcode.i  temp-gds.gds-code  ?  b-code  no-error }
          if not error-status :error then do:
            find last price-list no-lock
              where price-list.obj-type  = buf_doc-line.obj-type
                and price-list.obj-code  = buf_doc-line.obj-code
                and price-list.b-code    = b-code
            use-index fact-close no-error .
            if available price-list then assign temp-gds.price = price-list.price-sale .
          end .
        end .
        assign
          temp-gds.price1      = temp-gds.price * temp-gds.upak
          temp-gds.sum         = temp-gds.qnty * temp-gds.price
        .
      end.
    end.

    if v-sort-prod = "yes" then do:
      if sort-gr = yes then do:  /* группировка по группам */
        if sort-name = yes then do:
          for each temp-gds break by temp-gds.prod-type by temp-gds.prod-code by  temp-gds.grp-name by temp-gds.gds-name :
            if  first-of( temp-gds.prod-code) then do:
              run print-prod in this-procedure .
            end.
            if first-of(temp-gds.grp-name) then do:
              run print-group-line in this-procedure ( input temp-gds.grp-name ).
            end.
            if last( temp-gds.gds-name ) and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name = yes */
        else do:
          for each temp-gds break by temp-gds.prod-type by temp-gds.prod-code by temp-gds.grp-name by temp-gds.line-num :
            if  first-of( temp-gds.prod-code) then do:
              run print-prod in this-procedure .
            end.
            if first-of( temp-gds.grp-name ) then do:
              run print-group-line in this-procedure ( input temp-gds.grp-name ).
            end.
            if last( temp-gds.line-num ) and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name <> yes */
      end.        /* sort-gr = yes */
      else do:
        if sort-name = yes then do:
          for each temp-gds break by temp-gds.prod-type by temp-gds.prod-code by temp-gds.gds-name :
            if  first-of( temp-gds.prod-code) then do:
              run print-prod in this-procedure .
            end.
            if last( temp-gds.gds-name ) and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name = yes */
        else do:
          for each temp-gds break by temp-gds.prod-type by temp-gds.prod-code by temp-gds.line-num :
            if  first-of( temp-gds.prod-code) then do:
              run print-prod in this-procedure .
            end.
            if last( temp-gds.line-num ) and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name <> yes */
      end.        /* sort-gr <> yes */
    end.
    else do:
      if sort-gr = yes then do:  /* группировка по группам */
        if sort-name = yes then do:
          for each temp-gds break by temp-gds.grp-name  by temp-gds.gds-name :
            if first-of(temp-gds.grp-name) then do:
              run print-group-line in this-procedure ( input temp-gds.grp-name ).
            end.
            if last( temp-gds.gds-name ) and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name = yes */
        else do:
          for each temp-gds break by temp-gds.grp-name by temp-gds.line-num :
            if first-of( temp-gds.grp-name ) then do:
              run print-group-line in this-procedure ( input temp-gds.grp-name ).
            end.
            if last( temp-gds.line-num ) and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name <> yes */
      end.        /* sort-gr = yes */
      else do:
        if sort-name = yes then do:
          for each temp-gds break by temp-gds.gds-name  :
            if last( temp-gds.gds-name ) and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name = yes */
        else do:
          for each temp-gds break by temp-gds.line-num    :
            if last( temp-gds.line-num ) and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure .
          end.
        end.        /* sort-name <> yes */
      end.        /* sort-gr <> yes */
    end.

    run print-total-result in this-procedure .
       put stream out-stream
       skip
        space(20 )   "Сдал___________________                                                                                Принял__________________________ "   format "X(140)" skip.

    run r-fasxl-close in this-procedure .
    hide stream Out-Stream frame BottomFrame .
    output stream out-stream close.
    { gbl/stopwork.i }

    { rep/q-print.i 8 }

/*end.*/



procedure PrintTitul :
  do on error undo, return error return-value :
    if line-counter( Out-Stream ) + {&bottom-page-line-size} < page-size( Out-Stream ) then do:
      put stream out-stream skip space({&P-S}) "|" v-single-line format "X({&P-X0})" "|" .
    end.
    page stream Out-Stream .
    run print-header in this-procedure .
  end.
end procedure. /* PrintTitul */


/*==========================================================================*/
procedure print-header :
  do on error undo, return error:
    assign  v-first-line = yes .

    put stream out-stream
    skip
    space({&P-S})       v-single-line   format "X({&P-X})"
    skip space({&P-S})  "|"
        "Выдано в работу"       at center-field({&P-S} + 1, {&P-C9-S}, 15)
        "|"                     at {&P-C9-S}
        "Расфасовано и сдано"   at center-field({&P-C9-S}, {&P-C14-S}, 19)
        "|"                     at {&P-C14-S}
        "Срок"                  at center-field({&P-C14-S}, {&P-E}, 4)
        "|"                     at {&P-E}
    skip
    space({&P-S})   "|"     v-single-line   format "X({&P-X1})"   "|"
        "|"                     at {&P-E}
    skip space({&P-S})  "|"
        "№ ф/с"                 at center-field({&P-S} + 1, {&P-C2-S}, 7)
        "|"                     at {&P-C2-S}
        "дата"                  at center-field({&P-C2-S}, {&P-C3-S}, 4)
        "|"                     at {&P-C3-S}
        "номенкл"               at center-field({&P-C3-S}, {&P-C4-S}, 7)
        "|"                     at {&P-C4-S}
        "Наименование товара (сырья)"   at {&P-C4-S} + 2
        "|"                     at {&P-C5-S}
        "Ед."                   at center-field({&P-C5-S}, {&P-C6-S}, 3)
        "|"                     at {&P-C6-S}
        "Серия"                 at center-field({&P-C6-S}, {&P-C7-S}, 5)
        "|"                     at {&P-C7-S}
        "Кол-во"                at center-field({&P-C7-S}, {&P-C8-S}, 6)
        "|"                     at {&P-C8-S}
        "Цена розн."            at center-field({&P-C8-S}, {&P-C9-S}, 10)
        "|"                     at {&P-C9-S}
        "Наименование готовой продукции"   at {&P-C9-S} + 2
        "|"                     at {&P-C10-S}
        "Ед."                   at center-field({&P-C10-S}, {&P-C11-S}, 3)
        "|"                     at {&P-C11-S}
        "Кол-во"                at center-field({&P-C11-S}, {&P-C12-S}, 6)
        "|"                     at {&P-C12-S}
        "Цена розн."            at center-field({&P-C12-S}, {&P-C13-S}, 10)
        "|"                     at {&P-C13-S}
        "Сумма розн."           at center-field({&P-C13-S}, {&P-C14-S}, 11)
        "|"                     at {&P-C14-S}
        "годности"              at center-field({&P-C14-S}, {&P-E}, 8)
        "|"                     at {&P-E}
    skip space({&P-S})  "|"
        "|"                     at {&P-C2-S}
        "|"                     at {&P-C3-S}
        "номер"                 at center-field({&P-C3-S}, {&P-C4-S}, 5)
        "|"                     at {&P-C4-S}
        "|"                     at {&P-C5-S}
        "изм"                   at center-field({&P-C5-S}, {&P-C6-S}, 3)
        "|"                     at {&P-C6-S}
        "|"                     at {&P-C7-S}
        "|"                     at {&P-C8-S}
        "|"                     at {&P-C9-S}
        "|"                     at {&P-C10-S}
        "изм"                   at center-field({&P-C10-S}, {&P-C11-S}, 3)
        "|"                     at {&P-C11-S}
        "|"                     at {&P-C12-S}
        "|"                     at {&P-C13-S}
        "|"                     at {&P-C14-S}
        "|"                     at {&P-E}
    skip space({&P-S})
        "|" v-single-line format "X({&P-X0})" "|"
    .
  end.
end procedure. /* print-header */









/*==========================================================================*/
procedure print-line :
    put stream out-stream
            skip space({&P-S})  "|"
                v-ser_on_pack                format "X(9)"
                "|"   at {&P-C2-S}
                temp-gds.data                format "99/99/99"
                "|"   at {&P-C3-S}
                "|"   at {&P-C4-S}
                temp-gds.gds-name            format "X(34)"
                "|"   at {&P-C5-S}
                "|"   at {&P-C6-S}
                temp-gds.num-ser             format "X(10)"
                "|"   at {&P-C7-S}
                temp-gds.qnty1                format "->>>>>9.99"
                "|"   at {&P-C8-S}
                temp-gds.price1              format "->>>>>>>>>9.99"
                "|"   at {&P-C9-S}
                temp-gds.gds-name1           format "X(34)"
                "|"   at {&P-C10-S}
                "|"   at {&P-C11-S}
                temp-gds.qnty                format "->>>>>9.99"
                "|"   at {&P-C12-S}
                temp-gds.price              format "->>>>>>>>>9.99"
                "|"   at {&P-C13-S}
                temp-gds.sum                 format "->>>>>>>>>>>9.99"
                "|"   at {&P-C14-S}
                temp-gds.last-date           format "99/99/99"
                "|"   at {&P-E}
        .
      run r-fasxl-write-line-data in this-procedure (
                  input v-ser_on_pack
                , input string(temp-gds.data, "99/99/99")
                , input temp-gds.gds-name
                , input temp-gds.num-ser
                , input temp-gds.qnty1
                , input temp-gds.price1
                , input temp-gds.gds-name1
                , input temp-gds.qnty
                , input temp-gds.price
                , input temp-gds.sum
                , input if string(temp-gds.last-date) = ? then "" else string(temp-gds.last-date, "99/99/9999" )
      ).


      assign v-line-counter      = v-line-counter    + 1  .
      if line-counter( Out-Stream ) + {&bottom-page-line-size} + {&page-result-line-size} > page-size( Out-Stream ) then do:
        page stream Out-Stream .
        run print-header in this-procedure .
      end.
end procedure. /* print-line */







/*==========================================================================*/
procedure print-group-line :
  define input parameter p-grp-name   as character no-undo .

  if line-counter( Out-Stream ) + {&bottom-page-line-size} + {&group-line-size} + 1 > page-size( Out-Stream ) then do:
    page stream out-stream.
    run print-header in this-procedure .
  end.
  if v-first-line <> yes then do:
    put stream out-stream  skip space({&P-S}) "|" v-single-line format "X({&P-X0})" "|" .
  end.        /* p-print-type <> "no-line" */
  put stream out-stream  skip space({&P-S}) "|   ***  Группа:  "  + p-grp-name format "X(110)" "|" at {&P-E} .
end procedure. /* print-group-line */


/*==========================================================================*/
procedure print-prod :
  do on error undo, return error :
    if line-counter( Out-Stream ) + {&bottom-page-line-size} + {&group-line-size} + 1 > page-size( Out-Stream ) then do:
        page stream out-stream.
        run print-header in this-procedure .
    end.
    if v-first-line <> yes then do:
      put stream out-stream  skip space({&P-S}) "|" v-single-line format "X({&P-X0})" "|" .
    end.        /* p-print-type <> "no-line" */
    find first buf_clients no-lock where buf_clients.obj-type = temp-gds.prod-type and buf_clients.obj-code = temp-gds.prod-code  .
    put stream out-stream  skip space({&P-S}) "| *** Производитель: "  + buf_clients.obj-name format "X(110)" "|" at {&P-E} .
  end.
end procedure. /* print-group-line */





/*==========================================================================*/
procedure print-total-result :
  do on error undo, return error :
    put stream out-stream  skip space({&P-S})  v-single-line format "X({&P-X})" .
  end.
end procedure. /* print-total-result */



/*==========================================================================*/
procedure print-note :
  do on error undo, return error :
    put stream out-stream  skip(1) space({&tab-stop1})  "Всего строк: "  v-line-counter  format ">>>>>9"  .
  end.
end procedure. /* print-total-result */