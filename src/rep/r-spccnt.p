block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-spccnt.p $
$Archive: rep/r-spccnt.p $

Акт отклонения цен накладной от цен спецификации к договору с поставщиком

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/

define input parameter parParentProc     AS WIDGET-HANDLE NO-UNDO.
define input parameter p-trn-doc-recid as recid no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-spccnt.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-spccnt.p $":U .
define variable vss-description as character no-undo init "Акт отклонения цен накладной от цен спецификации к договору с поставщиком.".
{ cmp/vssrevis.i        }
{ cmp/str-glbl.i        }
{ cmp/library.i        }
{ cmp/r-pril.i          }
{ rep/p-fmt.i           }
{ str/clcprtsl.i        }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/getsect.i  def }
{ str/cont-ms-def.i }


  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  define variable g#quest-print as logical   no-undo .
  run get-quest-print in parParentProc ( output g#quest-print ).

&scoped-define left-margin 1
&scoped-define right-margin 140
&scoped-define max-width 138
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
&GLOB P-X 135        /*длина линии*/
&GLOB P-X0 133       /*длина внутренней линии = длина линии - 2*/
&GLOB P-C3-X  13     /*ширина колонки производителя (3+1+9)*/
&GLOB P-C4-X  35     /*ширина колонки названия товара*/

&GLOB P-C2-S  {&P-S} + 11
&GLOB P-C3-S  {&P-S} + 28
&GLOB P-C4-S  {&P-S} + 42
&GLOB P-C5-S  {&P-S} + 81
&GLOB P-C6-S  {&P-S} + 93
&GLOB P-C7-S  {&P-S} + 105
&GLOB P-C8-S  {&P-S} + 115
&GLOB P-C9-S  {&P-S} + 125
&GLOB P-E     {&P-S} + 135
/*----E----- Таблица --------------------------------*/

    define shared variable sort-name    as logical          no-undo.
    define shared variable sort-gr      as logical          no-undo.

    define stream out-stream .

    define variable v-line-counter  as integer      no-undo.
    define variable v-single-line   as character    no-undo.

    define variable v-cli-name      as character    no-undo.
    define variable v-obj-name      as character    no-undo.

    define variable v-host-code     as integer      no-undo.

    define variable v-first-line    as logical      no-undo.

    define buffer buf_trn-doc   for trn-doc.
    define buffer buf_goods     for goods.
    define buffer buf_clients   for clients.
    define buffer buf_doc-line  for doc-line.
    define buffer buf_contract  for contract.
    define buffer buf_contract-specif  for contract-specif.

    define variable g#log as logical   no-undo .

    define variable v-sort-prod         as character         no-undo.
  { gbl/getsect.i run "''" 0 {&attr-prt-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'sort-prd' then v-sort-prod = string( thbjattr_thbj-attr.property-value-logical) .
  end.

/*do*/
/*for buf_trn-doc*/
/*  , buf_goods*/
/*  , buf_clients*/
/*  , buf_doc-line*/
/*on error undo, return error*/
/*:*/
    find first buf_trn-doc no-lock where recid( buf_trn-doc ) = p-trn-doc-recid .
    { gbl/hostcode.i  buf_trn-doc.obj-type  buf_trn-doc.obj-code  v-host-code }

    find first buf_contract no-lock
         where buf_contract.contract-code = buf_trn-doc.contract-code
           and buf_contract.host-code     = v-host-code
    no-error .
    if not available buf_contract then do:
      message  "Накладная не привязана к договору!"  view-as alert-box ERROR .
      return error .
    end.
/*
    find first buf_contract-specif no-lock
         where buf_contract-specif.contract-num = buf_trn-doc.contract-code
           and buf_contract-specif.host-code     = v-host-code
    no-error .
*/
   {str/cont-slave-inc.i
        &FIND_FIRST = YES
        &BUFFER_SPECIF  = buf_contract-specif
        &P_HOST_CODE    = v-host-code
        &P_CONTRACT_NUM = buf_trn-doc.contract-code
        &NO_LOCK=YES
        &NO_ERROR=YES
   }
    if not available buf_contract-specif then do:
      message  "Нет спецификации к договору!" view-as alert-box ERROR .
      return error .
    end.

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
    assign
        v-single-line       = fill( "-", {&right-margin} )
        v-line-counter      = 0
    .

    { cmp/open-out.i stream out-stream " " {&CS_PS} }

    form header
        space({&P-S}) v-single-line format "X({&P-X})" skip
        'Продолжение - на следующей странице' at 90 skip
        with frame BottomFrame width {&A4_CW0} page-bottom no-labels no-box .
    view stream out-stream frame BottomFrame .

    find first buf_clients no-lock where buf_clients.obj-type = {&cmp} and buf_clients.obj-code = v-host-code .

    { gbl/working.i }

    put stream out-stream
            buf_clients.obj-name format "X(60)" at {&P-S} + ( ( {&P-E} - {&P-S}) / 2 ) - ( length( buf_clients.obj-name ) / 2 )
        skip (1) space( {&tab-stop1} )
            "Акт отклонения цен накладной от цен спецификации к договору с поставщиком"
        skip space( {&tab-stop1} )
            "   Номер накладной: "   buf_trn-doc.doc-code           format "X(14)"
            "   Дата: "    string(buf_trn-doc.doc-date)             format "X(10)"
            ( if buf_trn-doc.status_ <> {&fact} then "   Статус: " + caps(buf_trn-doc.status_) else " " )  format "X(25)"
        skip space( {&tab-stop1} )
            "   Номер договора:  "   buf_contract.contract-prn-code    format "X(14)"
            "   Дата: "    string(buf_contract.contract-date)         format "X(10)"
        skip space( {&tab-stop1} ) "Поставщик (отправитель): "     v-cli-name   format "X(60)"
        skip space( {&tab-stop1} ) "Покупатель (получатель): "     v-obj-name   format "X(60)"
        skip
    .
    run print-header in this-procedure .

    if v-sort-prod = "yes" then do:
      if sort-gr = yes then do:  /* группировка по группам */
        if sort-name = yes then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code  = buf_trn-doc.doc-code
            , first buf_goods no-lock
              where buf_goods.artic        = buf_doc-line.artic
                and buf_goods.prod-type    = buf_doc-line.prod-type
                and buf_goods.prod-code    = buf_doc-line.prod-code
              break by buf_doc-line.prod-type by buf_doc-line.prod-code by  buf_goods.grp-name by buf_goods.gds-name
          :
            if  first-of( buf_doc-line.prod-code) then do:
              run print-prod in this-procedure .
            end.
            if first-of(buf_goods.grp-name) then do:
              run print-group-line in this-procedure ( input buf_goods.gds-code ).
            end.
            if last( buf_goods.gds-name ) and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure ( input buf_trn-doc.doc-code, input buf_doc-line.artic, input buf_doc-line.prod-type, input buf_doc-line.prod-code ).
          end.
        end.        /* sort-name = yes */
        else do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code  = buf_trn-doc.doc-code
            , first buf_goods no-lock
               where buf_goods.artic        = buf_doc-line.artic
                 and buf_goods.prod-type    = buf_doc-line.prod-type
                 and buf_goods.prod-code    = buf_doc-line.prod-code
              break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_goods.grp-name by buf_doc-line.line-num
          :
            if  first-of( buf_doc-line.prod-code) then do:
              run print-prod in this-procedure .
            end.
            if first-of( buf_goods.grp-name ) then do:
              run print-group-line in this-procedure (input buf_goods.gds-code).
            end.
            if last( buf_doc-line.line-num ) and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure (input buf_trn-doc.doc-code, input buf_doc-line.artic, input buf_doc-line.prod-type, input buf_doc-line.prod-code).
          end.
        end.        /* sort-name <> yes */
      end.        /* sort-gr = yes */
      else do:
        if sort-name = yes then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code  = buf_trn-doc.doc-code
            , first buf_goods no-lock
            where buf_goods.artic        = buf_doc-line.artic
              and buf_goods.prod-type    = buf_doc-line.prod-type
              and buf_goods.prod-code    = buf_doc-line.prod-code
            break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_goods.gds-name
          :
            if  first-of( buf_doc-line.prod-code) then do:
              run print-prod in this-procedure .
            end.
            if last( buf_goods.gds-name ) and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure (input buf_trn-doc.doc-code, input buf_doc-line.artic, input buf_doc-line.prod-type, input buf_doc-line.prod-code).
          end.
        end.        /* sort-name = yes */
        else do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code  = buf_trn-doc.doc-code
            , first buf_goods no-lock where buf_goods.artic        = buf_doc-line.artic and buf_goods.prod-type    = buf_doc-line.prod-type and buf_goods.prod-code    = buf_doc-line.prod-code
            break by buf_doc-line.prod-type by buf_doc-line.prod-code by buf_doc-line.line-num
          :
            if  first-of( buf_doc-line.prod-code) then do:
              run print-prod in this-procedure .
            end.
            if last( buf_doc-line.line-num ) and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure (input buf_trn-doc.doc-code, input buf_doc-line.artic, input buf_doc-line.prod-type, input buf_doc-line.prod-code).
          end.
        end.        /* sort-name <> yes */
      end.        /* sort-gr <> yes */
    end.
    else do:
      if sort-gr = yes then do:  /* группировка по группам */
        if sort-name = yes then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code  = buf_trn-doc.doc-code
            , first buf_goods no-lock
              where buf_goods.artic        = buf_doc-line.artic
                and buf_goods.prod-type    = buf_doc-line.prod-type
                and buf_goods.prod-code    = buf_doc-line.prod-code
              break by buf_goods.grp-name
                    by buf_goods.gds-name
          :
            if first-of(buf_goods.grp-name) then do:
              run print-group-line in this-procedure ( input buf_goods.gds-code ).
            end.
            if last( buf_goods.gds-name ) and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure ( input buf_trn-doc.doc-code, input buf_doc-line.artic, input buf_doc-line.prod-type, input buf_doc-line.prod-code ).
          end.
        end.        /* sort-name = yes */
        else do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code  = buf_trn-doc.doc-code
            , first buf_goods no-lock
               where buf_goods.artic        = buf_doc-line.artic
                 and buf_goods.prod-type    = buf_doc-line.prod-type
                 and buf_goods.prod-code    = buf_doc-line.prod-code
              break by buf_goods.grp-name
                    by buf_doc-line.line-num
          :
            if first-of( buf_goods.grp-name ) then do:
              run print-group-line in this-procedure (input buf_goods.gds-code).
            end.
            if last( buf_doc-line.line-num ) and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure (input buf_trn-doc.doc-code, input buf_doc-line.artic, input buf_doc-line.prod-type, input buf_doc-line.prod-code).
          end.
        end.        /* sort-name <> yes */
      end.        /* sort-gr = yes */
      else do:
        if sort-name = yes then do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code  = buf_trn-doc.doc-code
            , first buf_goods no-lock
            where buf_goods.artic        = buf_doc-line.artic
              and buf_goods.prod-type    = buf_doc-line.prod-type
              and buf_goods.prod-code    = buf_doc-line.prod-code
            break by buf_goods.gds-name
          :
            if last( buf_goods.gds-name ) and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure (input buf_trn-doc.doc-code, input buf_doc-line.artic, input buf_doc-line.prod-type, input buf_doc-line.prod-code).
          end.
        end.        /* sort-name = yes */
        else do:
          for each buf_doc-line no-lock
            where buf_doc-line.doc-code  = buf_trn-doc.doc-code
            , first buf_goods no-lock where buf_goods.artic        = buf_doc-line.artic and buf_goods.prod-type    = buf_doc-line.prod-type and buf_goods.prod-code    = buf_doc-line.prod-code
            break by buf_doc-line.line-num
          :
            if last( buf_doc-line.line-num ) and line-counter( Out-Stream ) + {&note-line-size} + 1 > page-size( Out-Stream ) then do:
              run PrintTitul .
            end.
            run print-line in this-procedure (input buf_trn-doc.doc-code, input buf_doc-line.artic, input buf_doc-line.prod-type, input buf_doc-line.prod-code).
          end.
        end.        /* sort-name <> yes */
      end.        /* sort-gr <> yes */
    end.

    run print-total-result in this-procedure .

    hide stream Out-Stream frame BottomFrame .

    run print-note in this-procedure .

    { gbl/stopwork.i }

    output stream out-stream close.

    { rep/q-print.i 4 }

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
        "Код"                   at center-field({&P-S} + 1, {&P-C2-S}, 3)
        "|"                     at {&P-C2-S}
        "Артикул"               at center-field({&P-C2-S}, {&P-C3-S}, 7)
        "|"                     at {&P-C3-S}
        "Производитель"         at center-field({&P-C3-S}, {&P-C4-S}, 13)
        "|"                     at {&P-C4-S}
        "Наименование товара"   at {&P-C4-S} + 2
        "|"                     at {&P-C5-S}
        "Цена "                 at center-field({&P-C5-S}, {&P-C6-S}, 10)
        "|"                     at {&P-C6-S}
        "Цена"                  at center-field({&P-C6-S}, {&P-C7-S}, 10)
        "|"                     at {&P-C7-S}
        "Допуст."               at center-field({&P-C7-S}, {&P-C8-S}, 8)
        "|"                     at {&P-C8-S}
        "Реальный"              at center-field({&P-C8-S}, {&P-C9-S}, 8)
        "|"                     at {&P-C9-S}
        "Отклон."               at center-field({&P-C9-S}, {&P-E}, 8)
        "|"                     at {&P-E}
    skip space({&P-S})  "|"
        "|"                     at {&P-C2-S}
        "|"                     at {&P-C3-S}
        "|"                     at {&P-C4-S}
        "|"                     at {&P-C5-S}
        "накладной"             at center-field({&P-C5-S}, {&P-C6-S}, 10)
        "|"                     at {&P-C6-S}
        "специф."               at center-field({&P-C6-S}, {&P-C7-S}, 10)
        "|"                     at {&P-C7-S}
        "% откл."               at center-field({&P-C7-S}, {&P-C8-S}, 8)
        "|"                     at {&P-C8-S}
        "% откл."               at center-field({&P-C8-S}, {&P-C9-S}, 8)
        "|"                     at {&P-C9-S}
        "|"                     at {&P-E}
    skip space({&P-S})
        "|" v-single-line format "X({&P-X0})" "|"
    .
  end.
end procedure. /* print-header */









/*==========================================================================*/
procedure print-line :

  define input parameter p-doc-code   as character        no-undo.
  define input parameter p-artic      as character        no-undo.
  define input parameter p-prod-type  as character        no-undo.
  define input parameter p-prod-code  as integer          no-undo.

  define variable v-last-date     as date         no-undo.
  define variable v-same-date     as logical      no-undo.
  define variable v-first-parts   as logical      no-undo.
  define variable v-qnty          as decimal      no-undo.
  define variable v-price         as decimal      no-undo.
  define variable v-sum-price     as decimal      no-undo.
  define variable v-prc           as decimal      no-undo.

  define buffer buf_parts     for parts.
  define buffer buf_contract-specif-attr for ub.contract-specif-attr .

    for each buf_parts no-lock
       where buf_parts.out-code   = buf_doc-line.doc-code
         and buf_parts.obj-type   = buf_doc-line.obj-type
         and buf_parts.obj-code   = buf_doc-line.obj-code
         and buf_parts.prod-type  = buf_doc-line.prod-type
         and buf_parts.prod-code  = buf_doc-line.prod-code
         and buf_parts.artic      = buf_doc-line.artic
    :
      find first buf_contract-specif no-lock
        where buf_contract-specif.contract-num = buf_trn-doc.contract-code
          and buf_contract-specif.host-code    = v-host-code
          and buf_contract-specif.gds-code     = buf_goods.gds-code
      no-error .
      find first  buf_contract-specif-attr no-lock
        where buf_contract-specif-attr.contract-num = buf_trn-doc.contract-code
          and buf_contract-specif-attr.host-code    = v-host-code
          and buf_contract-specif-attr.gds-code     = buf_goods.gds-code
          and buf_contract-specif-attr.attr-code    = {&contract-specif-prc-min}
      no-error .
         if (buf_parts.price-cli - ( if avail buf_contract-specif then buf_contract-specif.price-cli else 0 ) ) < 0 then do:
           if available buf_contract-specif-attr then v-prc = - decimal(buf_contract-specif-attr.attr-value) .
         end.
         else do:
           if available buf_contract-specif then v-prc = buf_contract-specif.prc .
         end.

      {str/cont-slave-inc.i
           &FIND_FIRST = YES
           &BUFFER_SPECIF  = buf_contract-specif
           &P_HOST_CODE    = v-host-code
           &P_CONTRACT_NUM = buf_trn-doc.contract-code
           &P_GDS_CODE     = buf_goods.gds-code
           &NO_LOCK=YES
           &NO_ERROR=YES
      }

      if available buf_contract-specif then do:
        put stream out-stream
            skip space({&P-S})  "|"
                string( buf_goods.gds-code, "999999999" )       format "X(9)"
                "|"   at {&P-C2-S}
                string( buf_goods.artic )                       format "X(16)"
                "|"   at {&P-C3-S}
                substitute( "&1 &2", buf_goods.prod-type, buf_goods.prod-code )  format "X({&P-C3-X})"
                "|"   at {&P-C4-S}
                buf_goods.gds-name                              format "X({&P-C4-X})"
                "|"   at {&P-C5-S}
                buf_parts.price-cli                             format "->>>>>>9.99"
                "|"   at {&P-C6-S}
                buf_contract-specif.price-cli                   format "->>>>>>9.99"
                "|"   at {&P-C7-S}
                v-prc                                           format "->>>>9.99"
                "|"   at {&P-C8-S}
                (buf_parts.price-cli - buf_contract-specif.price-cli) * 100 / buf_contract-specif.price-cli    format "->>>>9.99"
                "|"   at {&P-C9-S}
                (buf_parts.price-cli - buf_contract-specif.price-cli)    format "->>>>9.99"
                "|"   at {&P-E}
        .
      end.
      else do:
        put stream out-stream
            skip space({&P-S})  "|"
                string( buf_goods.gds-code, "999999999" )       format "X(9)"
                "|"   at {&P-C2-S}
                string( buf_goods.artic )                       format "X(16)"
                "|"   at {&P-C3-S}
                substitute( "&1 &2", buf_goods.prod-type, buf_goods.prod-code )  format "X({&P-C3-X})"
                "|"   at {&P-C4-S}
                buf_goods.gds-name                              format "X({&P-C4-X})"
                "|"   at {&P-C5-S}
                buf_parts.price-cli                             format "->>>>>>9.99"
                "|"   at {&P-C6-S}
                "|"   at {&P-C7-S}
                "|"   at {&P-C8-S}
                "|"   at {&P-C9-S}
                "|"   at {&P-E}
        .
      end.
      assign v-line-counter      = v-line-counter    + 1  .
      if line-counter( Out-Stream ) + {&bottom-page-line-size} + {&page-result-line-size} > page-size( Out-Stream ) then do:
        page stream Out-Stream .
        run print-header in this-procedure .
      end.
  end.
end procedure. /* print-line */







/*==========================================================================*/
procedure print-group-line :
  define input parameter p-gds-code   as integer          no-undo.
  define buffer buf_goods     for goods.

  do for buf_goods on error undo, return error :
    find first buf_goods no-lock where buf_goods.gds-code = p-gds-code .
    if line-counter( Out-Stream ) + {&bottom-page-line-size} + {&group-line-size} + 1 > page-size( Out-Stream ) then do:
        page stream out-stream.
        run print-header in this-procedure .
    end.
    if v-first-line <> yes then do:
      put stream out-stream  skip space({&P-S}) "|" v-single-line format "X({&P-X0})" "|" .
    end.        /* p-print-type <> "no-line" */
    put stream out-stream  skip space({&P-S}) "|   ***  Группа:  "  + buf_goods.grp-name format "X(110)" "|" at {&P-E} .
end.
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
    find first buf_clients no-lock where buf_clients.obj-type = buf_doc-line.prod-type and buf_clients.obj-code = buf_doc-line.prod-code  .
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