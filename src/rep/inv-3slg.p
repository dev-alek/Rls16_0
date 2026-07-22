block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inv-3slg.p $
$Archive: rep/inv-3slg.p $

Инвентаризационная опись и сличительная ведомость

Автор: Демин Алексей Сергеевич
Дата создания: 03/27/06
Author: Alexey Demin
Creation date: 03/27/06

*/
define input parameter parParentProc     AS WIDGET-HANDLE NO-UNDO.
define input parameter  rec_id    as recid.
define input parameter print-graft        as logical          no-undo.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: inv-3slg.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/inv-3slg.p $":U .
define variable vss-description as character no-undo init "Формы по инвентаризации ".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/breakstr.i }
{ rep/r-cliprp.i def}
{ str/trdcalib.i }
{ ref/grplib.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/getsect.i  def }


do
on error undo, return error
:

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).


  define variable g#gds-engl as logical   no-undo .
  run get-gds-engl  in parParentProc ( output g#gds-engl ).

  define variable g#log as logical   no-undo .

  define variable g#quest-print as logical   no-undo .
  run get-quest-print in parParentProc ( output g#quest-print ).

  &glob format-inv      "X(164)"
  &scop gds-len 40

  define shared variable sort-name   as logical no-undo.
  define shared variable sort-gr     as logical no-undo.
  define shared variable CostPrice   as logical no-undo .
  define shared variable PrintScale  as logical no-undo .

  define variable v-par-type   as character  no-undo .
  define variable v-sort-prod  as character  no-undo .

  { gbl/getsect.i run "''" 0  {&attr-prt-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'sort-prd' then v-sort-prod = string( thbjattr_thbj-attr.property-value-logical) .
  end.

  define variable v-nedost as logical initial yes no-undo .
  define variable min-sum  as decimal initial 0  no-undo .
  define variable s-pole   as integer   no-undo .
  define variable all-grp  as integer   no-undo .
  define variable list-grp as character no-undo .
  if sort-name then assign s-pole = 1 .
  else              assign s-pole = 2 .

  find first trn-doc no-lock where recid(trn-doc) = rec_id .

  run rep/inv-slg.w
      ( input parParentProc
      ,input trn-doc.obj-type
      ,input trn-doc.obj-code
      ,input-output s-pole
      ,output min-sum
      ,output v-nedost
      ,output all-grp
      ,output list-grp) .

  &Scop Sort-pole if s-pole = 1 then  temp-str.gds-name Else temp-str.artic

  define variable sort-group as logical   no-undo .
  if sort-gr then assign sort-group = yes .
  else            assign sort-group = no .

  DEFINE temp-table temp-str no-undo
    field   grp-name          as  char
    field   gds-name          as  char
    field   gds-code          as  integer
    field   artic             as  char
    field   prod-type         as  char
    field   prod-code         as  integer
    field   unit-base         as  char
    field   empty-scale       as logical
    field   a-qnty            as decimal
    field   a-stoim           as decimal
    field   b-qnty            as decimal
    field   b-stoim           as decimal
    field   delta             as decimal
    INDEX pi  IS PRIMARY   artic prod-type prod-code
    INDEX pi1              gds-name
    INDEX pi2              grp-name
    INDEX pi3              delta DESCENDING
  .

  DEFINE temp-table temp-grp no-undo
    field   grp-name          as  char
    field   grp-code          as  integer
    INDEX pi  IS PRIMARY  grp-name
  .

  def stream Out-Stream.

  def buffer buf_clients for  clients .
  def buffer buf_doc-line     for doc-line .
  def buffer buf_goods        for goods .
  def buffer buf_doc-line-sum for doc-line-sum .
  def buffer buf_gds-dtl      for gds-dtl .

  define variable sum  as decimal   no-undo .
  define variable pp as character no-undo .

  define variable is-after      as logical initial yes no-undo .

/*  define variable num-ln as integer   no-undo .*/

  define variable FullNameGds as character no-undo .
  define variable gds-str as char no-undo.
  define variable gds-str1 as char no-undo.
  define variable gds-str2 as char no-undo.
  define variable i as int no-undo.
  define variable j as int no-undo.
  define variable Counter1 as integer init 0  no-undo .

  define variable Line       as char    no-undo.

  define variable     tdoc-date     like trn-doc.doc-date no-undo.
  define variable     tdoc-code     like trn-doc.doc-code no-undo.

  define variable sym1 as char  init ":"   no-undo.
  define variable sym2 as char  init ":"   no-undo.
  define variable sym3 as char  init ":"   no-undo.
  define variable sym4 as char  init ":"   no-undo.
  define variable sym5 as char  init ":"   no-undo.
  define variable sym6 as char  init ":"   no-undo.
  define variable sym7 as char  init ":"   no-undo.
  define variable sym8 as char  init ":"   no-undo.

  DEFINE FRAME invent
    sym1              column-label ":!:!:"                                format "X(1)"
    temp-str.artic    column-label "     Артикул! ! "                     format "x(17)"
    sym2              column-label ":!:!:"                                format "X(1)"
    temp-str.gds-name column-label "       Наименование товара! ! "       format "X(40)"
    sym3              column-label ":!:!:"                                format "X(1)"
    temp-str.b-qnty   column-label "К о л!-----------------!Было       "  format "->>>>>>>>9.<<<"
    sym4              column-label "-!:!:"                                format "X(1)"
    temp-str.a-qnty   column-label "в о              !-----------------!Стало       "   format "->>>>>>>>9.<<<"
    sym5              column-label ":!:!:"                                format "X(1)"
    temp-str.b-stoim  column-label "С у!-----------------! Было      "      format "->,>>>,>>>,>>9.99"
    sym6              column-label "м!:!:"                                format "X(1)"
    temp-str.a-stoim  column-label "м а              !-----------------!Стало      "   format "->,>>>,>>>,>>9.99"
    sym7              column-label ":!:!:"                                format "X(1)"
    temp-str.delta    column-label "Разница     !Сумма      ! "           format "->,>>>,>>>,>>9.99"
    sym8              column-label ":!:!:"                                format "X(1)"
    HEADER
      cur-time-print() AT 5 format "X(35)"
      string( "Инвентаризация N " + tdoc-code + " от " + string ( tdoc-date , "99/99/9999" ) ) AT 40 format "X(43)"
      string( pp) AT 85 format "X(60)" string( "Лист " + string( PAGE-NUMBER(Out-Stream) , ">>>>9") ) AT 145 format "X(13)" SKIP
      Line format {&format-inv} AT 1
  with width {&DOS_CW_2} down stream-io use-text NO-BOX.

  run Check-Doc-Sum in this-procedure no-error  .
  if error-status :error then return error .

  { cmp/open-out.i STREAM Out-Stream " " {&LS_PS_A4}  }

  assign  Line    = fill("-", 230) .

  if  CostPrice then DO:
    IF PrintRubl THEN Assign PP = "Учетные цены ".
    Else Assign PP = "Учетные цены (б.в.)" .
  End.
  Else DO:
    IF PrintRubl THEN Assign PP = "Цены док-та".
    Else Assign PP = "Цены док-та (б.в.)" .
  End.

  if v-nedost then Assign PP = PP + "  анализ недостачи >= " + string(min-sum) .
  else             Assign PP = PP + "  анализ излишков >= " + string(min-sum) .

  PUT stream Out-Stream UNFORMATTED  space(50) string( "ИНВЕНТАРИЗАЦИЯ " + string( tdoc-code , "X(16)") + " от " + string( tdoc-date, "99/99/9999")
     + (if trn-doc.status_ <> {&fact} then string( "(" + CAPS(trn-doc.status_) + ")" ) else "")) format "X(100)" skip .

  /* по строкам документа-------------------------------------------------------------------------------------------- */

  { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

  /* сначала заполняем таблицу */
  if all-grp = 2 then do:
    do i = 1 to num-entries (list-grp):
      find first gds-grp no-lock where recid(gds-grp) = integer (entry (i, list-grp)) no-error .
      if available gds-grp then do:
        if gds-grp.is-term then do:
          create temp-grp .
          assign temp-grp.grp-code = gds-grp.node-code .
          run grplib-get-full-name in this-procedure ( input gds-grp.node-code, output temp-grp.grp-name) .
        end.
        else run fill-temp-grp (input gds-grp.node-code) .
      end.
    end.
  end.

  for each buf_doc-line no-lock where buf_doc-line.doc-code = trn-doc.doc-code :
    find first buf_goods no-lock
      where buf_goods.prod-type = buf_doc-line.prod-type
        and buf_goods.prod-code = buf_doc-line.prod-code
        and buf_goods.artic     = buf_doc-line.artic
    no-error .

    if all-grp = 2 then do:
      find first temp-grp where temp-grp.grp-name = buf_goods.grp-name no-error .
      if not available temp-grp then next.
    end.

    assign Counter1 = Counter1 + 1.
    { rep/repfrm.i disp Counter1 }

    create temp-str .
    assign
      temp-str.grp-name    = buf_goods.grp-name
      temp-str.artic       = buf_goods.artic
      temp-str.prod-type   = buf_goods.prod-type
      temp-str.prod-code   = buf_goods.prod-code
      temp-str.gds-code    = buf_goods.gds-code
    .
    if g#gds-engl then assign temp-str.gds-name = buf_goods.engl-name.
    else               assign temp-str.gds-name = buf_goods.gds-name.

    find first buf_doc-line-sum no-lock
      where buf_doc-line-sum.doc-code = buf_doc-line.doc-code
        and buf_doc-line-sum.gds-code = buf_goods.gds-code
        and buf_doc-line-sum.sum-type = {&sum-before-doc}
      no-error .

    if costprice = true then do:
      if PrintRubl then assign temp-str.b-stoim = buf_doc-line-sum.cost-sum-rubl .
      else              assign temp-str.b-stoim = buf_doc-line-sum.cost-sum-base .
    end.
    else do:
      if PrintRubl then assign temp-str.b-stoim = buf_doc-line-sum.crsa-sum-rubl .
      else              assign temp-str.b-stoim = buf_doc-line-sum.crsa-sum-base .
    end.
    assign temp-str.b-qnty      = buf_doc-line-sum.fact-qnty .

    if is-after then do: /* уже рассчитаны суммы после */
      find first buf_doc-line-sum no-lock
        where buf_doc-line-sum.doc-code = buf_doc-line.doc-code
          and buf_doc-line-sum.gds-code = buf_goods.gds-code
          and buf_doc-line-sum.sum-type = {&sum-after-doc}
      no-error .
      if costprice = true then do:
        if PrintRubl then assign temp-str.a-stoim = buf_doc-line-sum.cost-sum-rubl .
        else              assign temp-str.a-stoim = buf_doc-line-sum.cost-sum-base .
      end.
      else do:
        if PrintRubl then assign temp-str.a-stoim = buf_doc-line-sum.crsa-sum-rubl .
        else              assign temp-str.a-stoim = buf_doc-line-sum.crsa-sum-base .
      end.
      assign temp-str.a-qnty      = buf_doc-line-sum.fact-qnty .
    end.
    else do:         /* нет сумм после ! */
      if costprice = true then do:
        if PrintRubl then assign sum = buf_doc-line.price-rubl * buf_doc-line.fact-qnty .
        else              assign sum = buf_doc-line.price-base * buf_doc-line.fact-qnty .
      end.
      else do:
        assign sum = 0 .
        for each buf_gds-dtl no-lock
          where buf_gds-dtl.doc-code  = buf_doc-line.doc-code
            and buf_gds-dtl.artic     = buf_doc-line.artic
            and buf_gds-dtl.prod-type = buf_doc-line.prod-type
            and buf_gds-dtl.prod-code = buf_doc-line.prod-code
          :
          if PrintRubl then assign sum = sum + buf_gds-dtl.price-rubl * buf_gds-dtl.doc-qnty .
          else              assign sum = sum + buf_gds-dtl.price-base * buf_gds-dtl.doc-qnty.
        end.
      end.
      assign
        temp-str.a-stoim     = temp-str.b-stoim + sum
        temp-str.a-qnty      = temp-str.b-qnty + buf_doc-line.fact-qnty
      .
    end.
    assign sum = temp-str.a-stoim - temp-str.b-stoim .

    /* Анализируем суммы */
    if v-nedost then do:
      if sum > 0 or ( ABS(sum) < min-sum ) then delete temp-str .
      else temp-str.delta = - sum .
    end.
    else do:
      if sum < 0 or sum < min-sum then delete temp-str .
      else temp-str.delta = sum .
    end.
  end.

  /* теперь печать с сортировками */
  if v-sort-prod = "yes" then do:
    if sort-group = yes then do:
      if s-pole < 3 then do:
        for each temp-str no-lock break by temp-str.prod-type by temp-str.prod-code by temp-str.grp-name by {&Sort-pole} :
          if first-of( temp-str.prod-code) then run print-prod in this-procedure .
          if first-of( temp-str.grp-name)  then run print-grp in this-procedure .
          run print-line in this-procedure .
/*        if last-of( temp-str.grp-name)   then run print-grp-itog in this-procedure .*/
/*        if last-of( temp-str.prod-code)  then run print-prod-itog in this-procedure .*/
        end.
      end.
      else do:
        for each temp-str no-lock break by temp-str.prod-type by temp-str.prod-code by temp-str.grp-name by temp-str.delta :
          if first-of( temp-str.prod-code) then run print-prod in this-procedure .
          if first-of( temp-str.grp-name)  then run print-grp in this-procedure .
          run print-line in this-procedure .
/*        if last-of( temp-str.grp-name)   then run print-grp-itog in this-procedure .*/
/*        if last-of( temp-str.prod-code)  then run print-prod-itog in this-procedure .*/
        end.
      end.
    end.        /* sort-gr = yes */
    else do:
      if s-pole < 3 then do:
        for each temp-str no-lock break by temp-str.prod-type by temp-str.prod-code by {&Sort-pole} :
          if first-of( temp-str.prod-code) then run print-prod in this-procedure .
          run print-line in this-procedure .
/*        if last-of( temp-str.prod-code)  then run print-prod-itog in this-procedure .*/
        end.
      end.
      else do:
        for each temp-str no-lock break by temp-str.prod-type by temp-str.prod-code by temp-str.delta  :
          if first-of( temp-str.prod-code) then run print-prod in this-procedure .
          run print-line in this-procedure .
/*        if last-of( temp-str.prod-code)  then run print-prod-itog in this-procedure .*/
        end.
      end.
    end.        /* sort-gr <> yes */
  end.        /* v-sort-prod = yes */
  else do:
    if sort-group = yes then do:
      if s-pole < 3 then do:
        for each temp-str no-lock break by temp-str.grp-name by {&Sort-pole} :
          if first-of( temp-str.grp-name) then run print-grp in this-procedure .
          run print-line in this-procedure .
/*        if last-of( temp-str.grp-name) then  run print-grp-itog in this-procedure .*/
        end.
      end.
      else do:
        for each temp-str no-lock break by temp-str.grp-name by temp-str.delta  :
          if first-of( temp-str.grp-name) then run print-grp in this-procedure .
          run print-line in this-procedure .
/*        if last-of( temp-str.grp-name) then  run print-grp-itog in this-procedure .*/
        end.
      end.
    end.        /* sort-gr = yes */
    else do:
      if s-pole < 3 then do:
        for each temp-str no-lock break by {&Sort-pole} :
          run print-line in this-procedure .
        end.
      end.
      else do:
        for each temp-str no-lock break by {&Sort-pole} :
          run print-line in this-procedure .
        end.
      end.
    end.        /* sort-gr <> yes */
  end.        /* v-sort-prod <> yes */
  PUT stream Out-Stream Line  FORMAT {&format-inv}  skip  .

  output stream Out-Stream CLOSE .
  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  { rep/q-print.i 8}
end.

/* *************************************************************************************************** */

procedure print-grp :
  do  on error undo, return error return-value  :
    DOWN stream Out-Stream 1 with FRAME invent .
    PUT stream Out-Stream UNFORMATTED String("_______________Группа : " + TRIM(CAPS(temp-str.grp-name)) + Line)  FORMAT {&format-inv}  skip  .
  end.
end procedure. /* print-grp */


procedure print-prod :
  do  on error undo, return error return-value  :
    find first buf_clients no-lock
      where buf_clients.obj-type = temp-str.prod-type
        and buf_clients.obj-code = temp-str.prod-code
    .
    DOWN stream Out-Stream 1 with FRAME invent .
    PUT stream Out-Stream UNFORMATTED String("________Производитель : " + TRIM(CAPS(buf_clients.obj-name)) + Line)  FORMAT {&format-inv}  skip  .
  end.
end procedure. /* print-prod */


procedure print-line :
  do on error undo, return error return-value :
  if line-counter( out-stream ) + 2 > page-size( out-stream ) then page stream out-stream.

/*  assign*/
/*    num-ln = num-ln + 1*/
/*  .*/

  /* полное название на несколько строк */
/*  FullNameGds = temp-str.gds-name .*/
/*  gds-str1 = breakstr(FullNameGds, {&gds-len}, input-output  gds-str1, input-output gds-str2).*/
/*  assign j = 0.*/
/*  DO WHILE gds-str2 <> "" :*/
/*    assign gds-str = gds-str2.*/
/*    gds-str1 = breakstr(gds-str, {&gds-len}, input-output gds-str1, input-output gds-str2).*/
/*    assign j = j + 1.*/
/*  END. /* DO WHILE ... */*/
/*  if line-counter( Out-Stream ) + j > page-size( Out-Stream ) then  PAGE STREAM Out-Stream.*/

/*  gds-str1 = breakstr(FullNameGds, {&gds-len}, input-output  gds-str1, input-output gds-str2).*/

  display stream Out-Stream
    sym1    temp-str.artic
    sym2    temp-str.gds-name
    sym3    temp-str.b-qnty
    sym4    temp-str.a-qnty
    sym5    temp-str.b-stoim
    sym6    temp-str.a-stoim
    sym7    temp-str.delta
    sym8  with FRAME invent.
  DOWN stream Out-Stream 1 with FRAME invent .

  if print-graft = false THEN  Put stream Out-Stream Line format {&format-inv} SKIP.

  end.
end procedure. /* print-line */


procedure print-grp-itog :
  do on error undo, return error return-value :
/*        display stream Out-Stream*/
/*          "ИТОГО"      @  temp-str.artic*/
/*          TRIM(CAPS(temp-str.grp-name)) @ temp-str.gds-name*/
/*          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym8 */
/*          sum-a-qnty   @ temp-str.a-qnty*/
/*          sum-a-stoim  @ temp-str.a-stoim*/
/*          sum-b-qnty   @ temp-str.b-qnty*/
/*          sum-b-stoim  @ temp-str.b-stoim*/
/*        with FRAME invent.*/
/*        DOWN stream Out-Stream 1 with FRAME invent .*/
/*        if print-graft = false THEN Put stream Out-Stream LineBuf format {&format-inv} SKIP.*/
  end.
end procedure. /* print-grp-itog */



procedure Check-Doc-Sum :
  do  on error undo, return error return-value  :
    define variable v-attr-value as character no-undo .
    define variable v-attr-type as character no-undo .
    define variable ask as logical   no-undo .
    { str/tdat-val.i trn-doc.doc-code {&trdcattr-addsum} v-attr-value v-attr-type }
    if trn-doc.status_ = {&fact} then do:
      if lookup( {&sum-before-doc}, v-attr-value ) = 0 or
         lookup( {&sum-after-doc}, v-attr-value ) = 0  then run utl/uaddsum.p (trn-doc.doc-code, no, ?, ?) no-error  .
      if error-status :error then  message return-value error-status :GET-MESSAGE( 1 )  view-as alert-box error .
    end.
    else do:
      if lookup( {&sum-before-doc}, v-attr-value ) = 0 then do:
        message "Не рассчитаны данные до начала инвентаризации!" view-as alert-box.
        undo, return error .
      end.
      if lookup( {&sum-after-doc}, v-attr-value ) = 0  then assign is-after = no .
    End.
  end.
end procedure. /* Check-Doc-Sum */


procedure fill-temp-grp :
  do
  on error undo, return error return-value
  :
    define input  parameter p-up-code as integer   no-undo .

    for each gds-grp no-lock where gds-grp.upper-code = p-up-code :
      if gds-grp.is-term then do:
        create temp-grp .
        assign temp-grp.grp-code = gds-grp.node-code .
        run grplib-get-full-name in this-procedure ( input gds-grp.node-code, output temp-grp.grp-name) .
      end.
      else do:
        run fill-temp-grp (input gds-grp.node-code) .
      end.
    end.
  end.
end procedure. /* fill-temp-grp */