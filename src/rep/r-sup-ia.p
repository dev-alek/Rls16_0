block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-sup-ia.p $
$Archive: rep/r-sup-ia.p $

Отчет по поставщикам - расчет и печать

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/

define input parameter p-SelectGood as integer   no-undo .
define input parameter p_typ_val    as integer   no-undo .
define input parameter p_type-count as character no-undo .
define input parameter p_cli-list   as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-sup-ia.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-sup-ia.p $":U .
define variable vss-description as character no-undo init "Отчет по поставщикам - расчет и печать".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i  }
{ cmp/r-pril.i   }
{ rep/r-sym.i    }
{ cmp/r-page1.i  }


do
on error undo, return error
:

DEFINE VARIABLE parParentProc     AS WIDGET-HANDLE NO-UNDO.
ASSIGN parParentProc =  my-handle .

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  { str/getctxtp.i def }
  { str/getctxtp.i get }

define temp-table gds-cycl no-undo
  field artic        like goods.artic
  field prod-type    like goods.prod-type
  field prod-code    like goods.prod-code
  field gds-name     like goods.gds-name
  field pay-code     like trn-doc.pay-code
  field ext-doc-type like trn-doc.ext-doc-type
  field type         as integer      /* 0 - возврат поставщику, 1 - все остальное */
  field in-doc-date  like trn-doc.fact-date
  field in-doc-code  like doc-line.doc-code
  field in-cli-code  like trn-doc.cli-code
  field in-cli-type  like trn-doc.cli-type
  field in-cli-name  like trn-doc.cli-name
  field in-qnty      like doc-line.fact-qnty
  field in-sum       like doc-line.price-rubl
  field out-doc-date like trn-doc.fact-date
  field out-doc-code like doc-line.doc-code
  field out-doc-type like trn-doc.doc-type
  field out-cli-code like trn-doc.cli-code
  field out-cli-type like trn-doc.cli-type
  field out-cli-name like trn-doc.cli-name
  field out-qnty     like doc-line.fact-qnty
  field out-sum      like doc-line.price-rubl
  field out-sumc     like doc-line.price-rubl

  index gds artic prod-type prod-code out-doc-code in-cli-code in-cli-type
  index tp type
.

define Stream OutStream.
define buffer cli-obj     for clients.
define buffer cli-suppl   for clients.
define buffer b-trn-doc   for trn-doc.
define buffer b-doc-line  for doc-line.
define buffer buf_goods   for goods.
define buffer buf_parts   for parts.
define buffer buf_trn-doc for trn-doc.
define buffer buf_clients for clients.

define variable Counter as integer .


  FOR EACH gds-cycl :
    delete gds-cycl.
  END.

  { rep/repfrm.i def } /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 10 } /* Показать окно информации о текущем процессе */
  assign Counter = 0.

  for each obj-list no-lock :
    find cli-obj no-lock
      where cli-obj.obj-type = obj-list.obj-type
        and cli-obj.obj-code = obj-list.obj-code .

    if p-SelectGood = {&g-all} then  /* выбраны все товары */
    do:
      for each buf_goods no-lock :
        run suppl-cycl in this-procedure . /* заполняем temp-table gds-cycl */
      end.
    end.
    else do:
      for each gds-list no-lock ,
          each buf_goods no-lock
         where buf_goods.artic     = gds-list.artic
           and buf_goods.prod-type = gds-list.prod-type
           and buf_goods.prod-code = gds-list.prod-code :
        run suppl-cycl in this-procedure .  /* заполняем temp-table gds-cycl */
      end. /* for each gds-list....*/
    end.
  end. /* for each obj-list.....*/

  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  if not can-find( first gds-cycl no-lock ) then
  do:
    message "Нет данных по движению товара." view-as alert-box ERROR.
  end.
  else /* Сбор данных завершен. */
  do:
    run PrintProvOtchet in this-procedure . /* печатаем */
  end.

end.



PROCEDURE suppl-cycl :

  /* заполняем temp-table gds-cycl  */

  for each buf_parts no-lock
    where  buf_parts.obj-type  = obj-list.obj-type
       and buf_parts.obj-code  = obj-list.obj-code
       and buf_parts.artic     = buf_goods.artic
       and buf_parts.prod-type = buf_goods.prod-type
       and buf_parts.prod-code = buf_goods.prod-code
       and buf_parts.status_   = yes
       and (buf_parts.doc-type  = {&expense}  or
            buf_parts.doc-type  = {&return} )
       ,
      each buf_trn-doc no-lock
     where buf_trn-doc.obj-code   = obj-list.obj-code
       and buf_trn-doc.obj-type   = obj-list.obj-type
       and buf_trn-doc.fact-date >= x-date-start
       and buf_trn-doc.fact-date <= x-date-end
       and buf_trn-doc.doc-type   = buf_parts.doc-type
       and buf_trn-doc.status_    = {&fact}
       and buf_trn-doc.internal   = no
       and buf_trn-doc.office     = no
       and buf_trn-doc.doc-code   = buf_parts.out-code
    :

    assign Counter = Counter + 1.
    { rep/repfrm.i disp Counter }

    find cli-suppl no-lock
      where cli-suppl.obj-type = buf_parts.supp-type
        and cli-suppl.obj-code = buf_parts.supp-code  no-error.

    find buf_clients no-lock
      where buf_clients.obj-type = buf_trn-doc.cli-type
        and buf_clients.obj-code = buf_trn-doc.cli-code .

    case p_type-count :
      when "поставщик" then
      do:
        if available cli-suppl and not can-do( p_cli-list, string( recid( cli-suppl ) ) ) then next.
      end.
      when "покупатель" then
      do:
        if not can-do( p_cli-list, string( recid( buf_clients ) ) ) then next.
      end.
      otherwise
      do:
      end.
    end case.

    for each gds-dtl
       where gds-dtl.doc-code = buf_trn-doc.doc-code
         and gds-dtl.artic = buf_goods.artic
         and gds-dtl.prod-type = buf_goods.prod-type
         and gds-dtl.prod-code = buf_goods.prod-code
     no-lock :

      ACCUMULATE
        gds-dtl.fact-qnty (TOTAL)
        gds-dtl.fact-qnty * gds-dtl.price-rubl (TOTAL)
        gds-dtl.fact-qnty * gds-dtl.price-base (TOTAL)
        gds-dtl.fact-qnty * ( gds-dtl.price-rubl - gds-dtl.discnt-rubl ) (TOTAL)
        gds-dtl.fact-qnty * ( gds-dtl.price-base - gds-dtl.discnt-base ) (TOTAL)
      .
    END.

    find b-trn-doc no-lock
      where b-trn-doc.doc-code = buf_parts.in-code  no-error.

    if available b-trn-doc then
    do:
      find b-doc-line no-lock
        where b-doc-line.doc-code = b-trn-doc.doc-code
          and b-doc-line.artic = buf_goods.artic
          and b-doc-line.prod-type = buf_goods.prod-type
          and b-doc-line.prod-code = buf_goods.prod-code
      .
    end.

    if buf_parts.fact-qnty <> 0 then do:
      if available cli-suppl then do:
        find gds-cycl
          where gds-cycl.artic        = buf_goods.artic
            and gds-cycl.prod-type    = buf_goods.prod-type
            and gds-cycl.prod-code    = buf_goods.prod-code
            and gds-cycl.out-doc-code = buf_trn-doc.doc-code
            and gds-cycl.in-cli-code  = cli-suppl.obj-code
            and gds-cycl.in-cli-type  = cli-suppl.obj-type
/*            and gds-cycl.pay-code     = (if buf_trn-doc.pay-code = v-cntxp-ret-pay then v-cntxp-ret-pay else 0 )*/
        no-error.
      end.
      else do:
        find gds-cycl
          where gds-cycl.artic        = buf_goods.artic
            and gds-cycl.prod-type    = buf_goods.prod-type
            and gds-cycl.prod-code    = buf_goods.prod-code
            and gds-cycl.out-doc-code = buf_trn-doc.doc-code
            and gds-cycl.in-cli-code  = 0
            and gds-cycl.in-cli-type  = ""
/*            and gds-cycl.pay-code     = (if buf_trn-doc.pay-code = v-cntxp-ret-sup-pay then v-cntxp-ret-sup-pay else 0 )*/
        no-error.
      end.

      if available gds-cycl then do:
        assign
          gds-cycl.out-qnty = gds-cycl.out-qnty + buf_parts.fact-qnty
        .
        if p_typ_val = 1 then do: /* р у б л и */
          assign
            gds-cycl.out-sumc = gds-cycl.out-sumc + buf_parts.fact-qnty * b-doc-line.price-rubl
            gds-cycl.out-sum = gds-cycl.out-sum + buf_parts.fact-qnty * ( ACCUM TOTAL gds-dtl.fact-qnty * ( gds-dtl.price-rubl - gds-dtl.discnt-rubl ) ) / ( ACCUM TOTAL gds-dtl.fact-qnty )
          .
        end.
        else do:
          assign
            gds-cycl.out-sumc = gds-cycl.out-sumc + buf_parts.fact-qnty * b-doc-line.price-base
            gds-cycl.out-sum = gds-cycl.out-sum + buf_parts.fact-qnty * ( ACCUM TOTAL gds-dtl.fact-qnty * ( gds-dtl.price-base - gds-dtl.discnt-base ) ) / ( ACCUM TOTAL gds-dtl.fact-qnty )
          .
        end.
        next.
      end.

    create gds-cycl.
    assign
      gds-cycl.artic        = buf_goods.artic
      gds-cycl.prod-type    = buf_goods.prod-type
      gds-cycl.prod-code    = buf_goods.prod-code
      gds-cycl.gds-name     = buf_goods.gds-name
      gds-cycl.out-doc-date = buf_trn-doc.fact-date
      gds-cycl.out-doc-code = buf_trn-doc.doc-code
      gds-cycl.out-cli-code = buf_clients.obj-code
      gds-cycl.out-cli-type = buf_clients.obj-type
      gds-cycl.out-qnty     = buf_parts.fact-qnty
      gds-cycl.out-doc-type = buf_parts.doc-type
      gds-cycl.ext-doc-type = buf_trn-doc.ext-doc-type
      gds-cycl.pay-code     = buf_trn-doc.pay-code
    .
    if buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} then
      assign
        gds-cycl.out-cli-name = "Возврат поставщику"
        gds-cycl.type         = 0
      .
    else
      assign
        gds-cycl.out-cli-name = buf_clients.obj-name
        gds-cycl.type         = 1
      .

    if available cli-suppl then
      assign
        gds-cycl.in-cli-code = cli-suppl.obj-code
        gds-cycl.in-cli-type = cli-suppl.obj-type
        gds-cycl.in-cli-name = cli-suppl.obj-name
      .
    else
      assign
        gds-cycl.in-cli-code = 0
        gds-cycl.in-cli-type = ""
        gds-cycl.in-cli-name = "Поставщик не определен"
      .
    if available b-trn-doc then
    do:
      assign
        gds-cycl.in-qnty     = b-doc-line.fact-qnty
        gds-cycl.in-doc-date = b-trn-doc.fact-date
        gds-cycl.in-doc-code = b-trn-doc.doc-code
      .
      if p_typ_val = 1  then
        assign
          gds-cycl.in-sum = b-doc-line.fact-qnty * b-doc-line.price-rubl
        .
      else
        assign
          gds-cycl.in-sum = b-doc-line.fact-qnty * b-doc-line.price-base
        .
    end.
    else
      assign
        gds-cycl.in-qnty     = 0
        gds-cycl.in-sum      = 0
        gds-cycl.in-doc-date = ?
        gds-cycl.in-doc-code = "неизвестен"
      .

    if p_typ_val = 1  then
      assign
        gds-cycl.out-sumc = buf_parts.fact-qnty * b-doc-line.price-rubl
        gds-cycl.out-sum  = buf_parts.fact-qnty * ( ACCUM TOTAL gds-dtl.fact-qnty * ( gds-dtl.price-rubl - gds-dtl.discnt-rubl ) ) / ( ACCUM TOTAL gds-dtl.fact-qnty )
      .
    else
      assign
        gds-cycl.out-sumc = buf_parts.fact-qnty * b-doc-line.price-base
        gds-cycl.out-sum  = buf_parts.fact-qnty * ( ACCUM TOTAL gds-dtl.fact-qnty * ( gds-dtl.price-base - gds-dtl.discnt-base ) ) / ( ACCUM TOTAL gds-dtl.fact-qnty )
      .
    end.
  end.
end procedure.


PROCEDURE PrintProvOtchet :   /* Печать */
  def var Line as char no-undo.
  def var i as int no-undo.

  { gbl/working.i }

  Line = fill("-", 140).

  DEFINE FRAME Gds_cycl
        sym1 column-label ":!:" format "x(1)" space (0)
        gds-cycl.artic column-label " Артикул! " format "x(16)"  space (0)
        sym2 column-label ":!:" format "x(1)" space (0)
        gds-cycl.gds-name
        column-label " Наименование товара! " format "x(30)"  space (0)
        sym3 column-label ":!:" format "x(1)" space (0)
        gds-cycl.out-doc-date column-label " Дата!расхода" format "99/99/99"  space (0)
        sym8 column-label ":!:" format "x(1)" space (0)
        gds-cycl.out-doc-code column-label " N док.! " format "x(10)"  space (0)
        sym9 column-label ":!:" format "x(1)" space (0)
        gds-cycl.out-cli-name
        column-label " Получатель! " format "x(31)"  space (0)
        sym10 column-label ":!:" format "x(1)" space (0)
        gds-cycl.out-qnty  column-label "Кол-во  !(расход) " format "->>>>9.<<<"  space (0)
        sym11 column-label ":!:" format "x(1)" space (0)
        gds-cycl.out-sum  column-label "Сумма  !(расход) " format "->>>>>>9.99"  space (0)
        sym12 column-label ":!:" format "x(1)" space (0)
        gds-cycl.out-sumc  column-label "Сумма уч.ц.!(расход) " format "->>>>>>9.99"  space (0)
        sym13 column-label ":!:" format "x(1)" space (0)
    HEADER
        string( "Дата печати : " + string(TODAY , "99.99.9999") + " , " + string(TIME, "HH:MM") ) AT 5 format "X(100)"
        string( "Страница " + string( PAGE-NUMBER( OutStream )  , ">>9") ) AT 115 format "X(15)" SKIP
        Line format "X(135)" AT 1
  with width {&DOS_CW} down stream-io.

  { cmp/open-out.i stream OutStream}

  FORM HEADER
        Line format "X(135)" AT 1 SKIP
        "Продолжение - на следующей странице" AT 30 SKIP
        with FRAME BottomFrame width {&A4_CW} PAGE-BOTTOM NO-LABELS NO-BOX .
  VIEW stream OutStream FRAME BottomFrame .

  FORM with FRAME Gds_cycl .

  PUT stream OutStream SPACE(30) "О Т Ч Е Т    П О    П О С Т А В Щ И К А М  за период с: "
        x-date-start format "99/99/9999" "г. по: "  x-date-end format "99/99/9999" "г." SKIP(2).

  for each gds-cycl no-lock
    break by string( string( gds-cycl.in-cli-code ) + gds-cycl.in-cli-type )
          by gds-cycl.type
          by gds-cycl.out-doc-type
          by gds-cycl.artic :
    if FIRST-OF( string( string( gds-cycl.in-cli-code ) + gds-cycl.in-cli-type ) ) then do:
      DISPLAY stream OutStream sym1 sym13 with frame Gds_cycl.
      DOWN stream OutStream 1 WITH FRAME Gds_cycl.
      PUT stream OutStream
        sym1
        string( " ПОСТАВЩИК: " + gds-cycl.in-cli-name + " (" + gds-cycl.in-cli-type + " " + string( gds-cycl.in-cli-code ) + ") " ) format "X(100)"
        sym2 AT 135 .
      DISPLAY stream OutStream sym1 sym13 with frame Gds_cycl.
      DOWN stream OutStream 1 WITH FRAME Gds_cycl.
    end.

    if FIRST-OF( gds-cycl.type ) then do:
      if gds-cycl.type = 1 then PUT stream OutStream sym1 format "X(1)" " Расход/Возврат: "     format "X(100)" sym2 AT 135 skip .
      else                      PUT stream OutStream sym1 format "X(1)" " Возврат поставщику: " format "X(100)" sym2 AT 135 .
    end.

    if FIRST-OF( gds-cycl.out-doc-type ) then do:
      if gds-cycl.type = 1 then do:
        if gds-cycl.out-doc-type = {&return} then  PUT stream OutStream sym1 format "X(1)" " Возврат: " format "X(100)" sym2 AT 135 .
        else                                       PUT stream OutStream sym1 format "X(1)" " Расход: "  format "X(100)" sym2 AT 135 .
      end.
    end.

    if gds-cycl.out-doc-type = {&return} then do:
      assign
        gds-cycl.out-qnty = - gds-cycl.out-qnty
        gds-cycl.out-sum  = - gds-cycl.out-sum
        gds-cycl.out-sumc = - gds-cycl.out-sumc
      .
    end.

    DISPLAY stream OutStream
            sym1 gds-cycl.artic
            sym2 gds-cycl.gds-name
            sym3 gds-cycl.out-doc-date
            sym8 gds-cycl.out-doc-code
            sym9 gds-cycl.out-cli-name
            sym10 gds-cycl.out-qnty
            sym11 gds-cycl.out-sum
            sym12 gds-cycl.out-sumc
            sym13
            with frame Gds_cycl.
    DOWN stream OutStream 1 WITH FRAME Gds_cycl.

      ACCUMULATE
        gds-cycl.out-qnty (SUB-TOTAL BY string( string( gds-cycl.in-cli-code ) + gds-cycl.in-cli-type ) )
        gds-cycl.out-sum  (SUB-TOTAL BY string( string( gds-cycl.in-cli-code ) + gds-cycl.in-cli-type ) )
        gds-cycl.out-sumc (SUB-TOTAL BY string( string( gds-cycl.in-cli-code ) + gds-cycl.in-cli-type ) )
        gds-cycl.out-qnty (SUB-TOTAL BY gds-cycl.type)
        gds-cycl.out-sum  (SUB-TOTAL BY gds-cycl.type)
        gds-cycl.out-sumc (SUB-TOTAL BY gds-cycl.type)
        gds-cycl.out-qnty (SUB-TOTAL BY gds-cycl.out-doc-type)
        gds-cycl.out-sum  (SUB-TOTAL BY gds-cycl.out-doc-type)
        gds-cycl.out-sumc (SUB-TOTAL BY gds-cycl.out-doc-type)
        gds-cycl.out-qnty (TOTAL)
        gds-cycl.out-sum  (TOTAL)
        gds-cycl.out-sumc (TOTAL)
      .

    if LAST-OF( gds-cycl.out-doc-type ) then do:
      if gds-cycl.type = 1 then do:
        DISPLAY stream OutStream
          sym1 (if gds-cycl.out-doc-type = {&return} then " Возврат" else " Расход") @ gds-cycl.artic
          sym2 string( "(" + gds-cycl.in-cli-type + " " + string( gds-cycl.in-cli-code ) + "):" )  @ gds-cycl.gds-name
          sym3
          sym10 ( ACCUM SUB-TOTAL BY gds-cycl.out-doc-type gds-cycl.out-qnty ) @ gds-cycl.out-qnty
          sym11 ( ACCUM SUB-TOTAL BY gds-cycl.out-doc-type gds-cycl.out-sum ) @ gds-cycl.out-sum
          sym12 ( ACCUM SUB-TOTAL BY gds-cycl.out-doc-type gds-cycl.out-sumc ) @ gds-cycl.out-sumc
          sym13
        with frame Gds_cycl.
        DOWN stream OutStream 1 WITH FRAME Gds_cycl.
      end.
    end.

    if LAST-OF( gds-cycl.type ) then  do:
      DISPLAY stream OutStream
        sym1 ( if gds-cycl.type = 1 then " Расход-возврат" else " Возвр. пост-ку") @ gds-cycl.artic
        sym2 string( "(" + gds-cycl.in-cli-type + " " + string( gds-cycl.in-cli-code ) + "):" )  @ gds-cycl.gds-name
        sym3
        sym10 ( ACCUM SUB-TOTAL BY gds-cycl.type gds-cycl.out-qnty ) @ gds-cycl.out-qnty
        sym11 ( ACCUM SUB-TOTAL BY gds-cycl.type gds-cycl.out-sum ) @ gds-cycl.out-sum
        sym12 ( ACCUM SUB-TOTAL BY gds-cycl.type gds-cycl.out-sumc ) @ gds-cycl.out-sumc
        sym13
      with frame Gds_cycl.
      DOWN stream OutStream 1 WITH FRAME Gds_cycl.
    end.

    if LAST-OF( string( string( gds-cycl.in-cli-code ) + gds-cycl.in-cli-type ) ) then do:
      DISPLAY stream OutStream
        sym1
        Line @ gds-cycl.artic
        Line @ gds-cycl.gds-name
        Line @ gds-cycl.out-qnty
        Line @ gds-cycl.out-sum
        Line @ gds-cycl.out-sumc
        sym13
      with frame Gds_cycl.
      DOWN stream OutStream 1 WITH FRAME Gds_cycl.
      DISPLAY stream OutStream
        sym1 " ИТОГО ПО" @ gds-cycl.artic
        string( "(" + gds-cycl.in-cli-type + " " + string( gds-cycl.in-cli-code ) + "):" )  @ gds-cycl.gds-name
        ( ACCUM SUB-TOTAL BY string( string( gds-cycl.in-cli-code ) + gds-cycl.in-cli-type ) gds-cycl.out-qnty ) @ gds-cycl.out-qnty
        ( ACCUM SUB-TOTAL BY string( string( gds-cycl.in-cli-code ) + gds-cycl.in-cli-type ) gds-cycl.out-sum ) @ gds-cycl.out-sum
        ( ACCUM SUB-TOTAL BY string( string( gds-cycl.in-cli-code ) + gds-cycl.in-cli-type ) gds-cycl.out-sumc ) @ gds-cycl.out-sumc
        sym13
      with frame Gds_cycl.
      DOWN stream OutStream 1 WITH FRAME Gds_cycl.
    end.
    PROCESS EVENTS.
  END. /* FOR EACH gds-cycl */

  PUT STREAM OutStream Line format "X(135)".
  DISPLAY stream OutStream
        "ИТОГО" @ gds-cycl.artic
        ( ACCUM TOTAL gds-cycl.out-qnty ) @ gds-cycl.out-qnty
        ( ACCUM TOTAL gds-cycl.out-sum ) @ gds-cycl.out-sum
        ( ACCUM TOTAL gds-cycl.out-sumc ) @ gds-cycl.out-sumc
        with frame Gds_cycl.
  DOWN stream OutStream 1 WITH FRAME Gds_cycl.

  HIDE stream OutStream FRAME BottomFrame .
  OUTPUT stream OutStream CLOSE.

{ gbl/stopwork.i }

  define variable v-user-action as character no-undo .
  define variable v-printed as logical   no-undo .
  run gbl/prnfilen.w
    (input  ""
    ,input  0
    ,input  string(session :temp-directory) + {&DF_Name} + string( g#report-num )
    ,input 7
    ,output v-user-action
    ,output v-printed
    ) .
END.