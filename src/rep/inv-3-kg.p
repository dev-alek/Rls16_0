block-level on error undo, throw.
/*

$Revision: 053a3dce2430, 1077, rls $
$Author: EShklyar $
$Date: Fri Oct 06 18:38:00 2017 +0300 $
$Workfile: inv-3-kg.p $
$Archive: rep/inv-3-kg.p $

Инвентаризационная опись и сличительная ведомость топлива в кг

Автор: Уханов Дмитрий Юрьевич
Дата создания: 10/05/09
Author: Dmitry Ukhanov
Creation date: 10/05/09

Автор1: Булгаков Андрей Николаевич
Дата создания1: 09/13/05

*/

&glob format-inv "x(185)":U
&glob format-sl  "x(162)":U
&scop gds-len    40
&scop Sort-pole  ( if sort-name = yes then temp-str.gds-name else ~
                 ( if sort-code = yes then temp-str.b-code   else temp-str.artic ) )

define input parameter parParentProc as widget-handle no-undo.
define input parameter rec_id        as recid         no-undo.
define input parameter rep-tipe      as character     no-undo.
define input parameter p-no-vat      as character     no-undo. /* используется для без НДС в цуме */
define input parameter p-grp         as character     no-undo. /* используется для печати только сумм по группам */
define input parameter print-graft    as logical          no-undo.

define variable vss-revision    as character no-undo initial "$Revision: 053a3dce2430, 1077, rls $":U.
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U.
define variable vss-date        as character no-undo initial "$Date: Fri Oct 06 18:38:00 2017 +0300 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: inv-3-kg.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: rep/inv-3-kg.p $":U.
define variable vss-description as character no-undo initial "Инвентаризационная опись и сличительная ведомость топлива в кг":U.

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/library.i      }
{ gbl/cur-time.i     }
{ cmp/r-pril.i       }
{ cmp/breakstr.i     }
{ rep/r-cliprp.i def }
{ str/trdcalib.i     }
{ gbl/paramls.i      }
{ str/lib-trn.i      }
{ str/valddnst.i def }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ gbl/getsect.i  def }

define variable g#report-num  as integer no-undo.
define variable g#gds-engl    as logical no-undo.
define variable g#log         as logical no-undo.
define variable g#quest-print as logical no-undo.

define shared variable sort-name   as logical no-undo.
define shared variable sort-gr     as logical no-undo.
define shared variable CostPrice   as logical no-undo.
define shared variable PrintScale  as logical no-undo.

define buffer buf_clients      for ub.clients.
define buffer This_Object      for ub.clients.
define buffer buf_trn-doc      for ub.trn-doc .
define buffer buf_doc-line     for ub.doc-line.
define buffer buf_goods        for ub.goods.
define buffer buf_doc-line-sum for ub.doc-line-sum.
define buffer buf_gds-dtl      for ub.gds-dtl.
define buffer buf_gds-prt      for ub.gds-prt.
define buffer bf_doc-attr      for ub.doc-attr.

define variable v-sort-prod         as   character           no-undo.
define variable sort-code           as   logical             no-undo.
define variable v-prn0              as   character           no-undo.
define variable sort-group          as   logical             no-undo.
define variable qnty                as   decimal             no-undo.
define variable sum                 as   decimal             no-undo.
define variable is-after            as   logical             no-undo initial yes.
define variable is-after-cli        as   logical             no-undo initial yes.
define variable is-wastage          as   logical             no-undo initial yes.
define variable is-general          as   logical             no-undo initial yes.
define variable v-root-node         as   integer             no-undo.
define variable num-ln              as   integer             no-undo.
define variable sum-a-qnty          as   decimal             no-undo initial 0.
define variable sum-b-qnty          as   decimal             no-undo initial 0.
define variable sum-a-qnty1         as   decimal             no-undo initial 0.
define variable sum-b-qnty1         as   decimal             no-undo initial 0.
define variable sum-a-stoim         as   decimal             no-undo initial 0.
define variable sum-b-stoim         as   decimal             no-undo initial 0.
define variable sum-ubl             as   decimal             no-undo initial 0.
define variable sum1-a-qnty         as   decimal             no-undo initial 0.
define variable sum1-b-qnty         as   decimal             no-undo initial 0.
define variable sum1-a-qnty1        as   decimal             no-undo initial 0.
define variable sum1-b-qnty1        as   decimal             no-undo initial 0.
define variable sum1-a-stoim        as   decimal             no-undo initial 0.
define variable sum1-b-stoim        as   decimal             no-undo initial 0.
define variable sum1-ubl            as   decimal             no-undo initial 0.
define variable sum2-a-qnty         as   decimal             no-undo initial 0.
define variable sum2-b-qnty         as   decimal             no-undo initial 0.
define variable sum2-a-qnty1        as   decimal             no-undo initial 0.
define variable sum2-b-qnty1        as   decimal             no-undo initial 0.
define variable sum2-a-stoim        as   decimal             no-undo initial 0.
define variable sum2-b-stoim        as   decimal             no-undo initial 0.
define variable sum2-ubl            as   decimal             no-undo initial 0.
define variable v-line-price        as   decimal             no-undo.
define variable v-line-price-before as   decimal             no-undo.
define variable v-line-price-after  as   decimal             no-undo.
define variable FullNameGds         as   character           no-undo.
define variable gds-str             as   character           no-undo.
define variable gds-str1            as   character           no-undo.
define variable gds-str2            as   character           no-undo.
define variable i                   as   integer             no-undo.
define variable j                   as   integer             no-undo.
define variable Counter1            as   integer             no-undo initial 0.
define variable LineBuf             as   character           no-undo.
define variable Line                as   character           no-undo.
define variable UndLine             as   character           no-undo.
define variable Lines_Counter       as   integer             no-undo initial 0.
define variable Tmp_Counter         as   integer             no-undo initial 0.
define variable PgQnty              as   decimal             no-undo.
define variable PgQnty-v            as   decimal             no-undo.
define variable PgSum               as   decimal             no-undo.
define variable PgQnty-b            as   decimal             no-undo.
define variable PgQnty-b-v          as   decimal             no-undo.
define variable PgSum-b             as   decimal             no-undo.
define variable PgNPP               as   integer             no-undo.
define variable UBL-v               as   decimal             no-undo.
define variable b-code              as   integer             no-undo.
define variable PropisQnty          as   character           no-undo.
define variable PropisSumall        as   character           no-undo.
define variable Propiscount         as   character           no-undo.
define variable abbr                as   character           no-undo.
define variable pp                  as   character           no-undo.
define variable sym1                as   character           no-undo initial ":".
define variable sym2                as   character           no-undo initial ":".
define variable sym3                as   character           no-undo initial ":".
define variable sym4                as   character           no-undo initial ":".
define variable sym5                as   character           no-undo initial ":".
define variable sym6                as   character           no-undo initial ":".
define variable sym7                as   character           no-undo initial ":".
define variable sym8                as   character           no-undo initial ":".
define variable sym9                as   character           no-undo initial ":".
define variable sym10               as   character           no-undo initial ":".
define variable sym11               as   character           no-undo initial ":".
define variable sym12               as   character           no-undo initial ":".
define variable sym13               as   character           no-undo initial ":".
define variable sym14               as   character           no-undo initial ":".
define variable sym15               as   character           no-undo initial ":".
define variable tdoc-date           like ub.trn-doc.doc-date no-undo.
define variable tdoc-code           like ub.trn-doc.doc-code no-undo.

define temp-table temp-str no-undo
    field   grp-name          as character
    field   gds-name          as character
    field   gds-code          as integer
    field   artic             as character
    field   prod-type         as character
    field   prod-code         as integer
    field   b-code            as character
    field   tb-code           as character
    field   OKEI              as integer
    field   unit-base         as character
    field   empty-scale       as logical
    field   Price-after       as decimal
    field   a-qnty            as decimal
    field   aa-qnty           as decimal
    field   a-qnty1           as decimal
    field   a-stoim           as decimal
    field   aa-stoim          as decimal
    field   price-befor       as decimal
    field   price             as decimal
    field   b-qnty            as decimal
    field   bb-stoim          as decimal
    field   b-qnty1           as decimal
    field   b-stoim           as decimal
    field   bb-price          as decimal
    field   ubl               as decimal
    field   inv-peresort-qnty as decimal
  index pi          is primary artic    prod-type prod-code
  index pi1                    gds-name
  index pi2                    grp-name
  index pi3                    tb-code.

function f-wp-qnty returns character ( input p-dec as decimal ) :
  define variable pr as character no-undo.

  run rep/wp-qnty.p ( input p-dec, output pr ).
  return ( pr ).
end function. /* f-wp-qnty */

function f-wp-sum  returns character ( input p-dec as decimal ) :
  define variable pr as character no-undo.

  if PrintRubl = yes then do: run rep/wp-rub.p (                      input p-dec, output pr, output abbr ). end.
                     else do: run rep/wp.p     ( input parParentProc, input p-dec, output Pr, output abbr ). end.
  return ( pr ).
end function. /* f-wp-sum */

define stream Out-Stream.

define frame invent
  sym1                 column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
  Lines_Counter        column-label "N!п/п! ! ! ":C5                                    format ">>>>9":U           space( 0 )
  sym2                 column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.artic       column-label "Артикул! ! ! ! ":C17                               format "x(17)":U           space( 0 )
  sym3                 column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.gds-name    column-label "Наименование товара! ! ! ! ":C40                   format "x(40)":U           space( 0 )
  Sym4                 column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.b-code      column-label "Код товара! ! ! ! ":C10                            format "x(9)":U            space( 0 )
  sym5                 column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.OKEI        column-label "Ед.!----!Код !по!ОКЕИ":C4                          format ">>>>":U            space( 0 )
  sym6                 column-label " !-!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.unit-base   column-label  "изм.!----!Наим!енов!ание"                         format "x(4)":U            space( 0 )
  sym7                 column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.Price-after column-label " ! Цена ! ! ! ":C13                                format "->>>>>9.99":U      space( 0 )
  sym8                 column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.a-qnty      column-label "Фактическое!-------------!Количество! ! ":C13      format "->>>>>>>9.<<<":U   space( 0 )
  sym9                 column-label " !-!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.a-stoim     column-label " наличие !--------------!Сумма! ! ":C15            format "->>>,>>>,>>9.99":U space( 0 )
  sym10                column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.Price-befor column-label "По данным!----------------!Цена! ! ":C17           format "->>>>>9.99":U      space( 0 )
  sym11                column-label " !-!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.b-qnty      column-label "бухгалтерского!---------------!Количество! ! ":C17 format "->>>>>>>9.<<<":U   space( 0 )
  sym12                column-label " !-!:!:!:"                                         format "x(1)":U            space( 0 )
  temp-str.b-stoim     column-label " учета !----------------!Сумма! ! ":C17            format "->>>,>>>,>>9.99":U space( 0 )
  sym13                column-label ":!:!:!:!:"                                         format "x(1)":U            space( 0 )
HEADER cur-time-print( ) at 5 format "x(35)":U
      string( "Инвентаризационная опись N " + tdoc-code + "  от  " + string( tdoc-date, "99/99/9999":U ) ) at 47 format "x(63)":U
      string( pp ) at 160 format "x(27)":U string( "Лист " + string( page-number( Out-Stream ) - 1, ">>>>9":U ) ) at 180 format "x(13)":U skip
      UndLine format {&format-inv} at 1
with width {&DOS_CW_2} down stream-io use-text no-box.

define frame sl
  sym1               column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  Lines_Counter      column-label "N!п/п! ! ! ":C5                                 format ">>>>9":U           space( 0 )
  sym2               column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.artic     column-label "Артикул! ! ! ! ":C17                            format "x(17)":U           space( 0 )
  sym3               column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.gds-name  column-label "Наименование товара! ! ! ! ":C40                format "x(40)":U           space( 0 )
  Sym4               column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.b-code    column-label "Код товара! ! ! ! ":C13                         format "x(13)":U           space( 0 )
  sym5               column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.OKEI      column-label "Ед.!----!Код ! по !ОКЕИ"                        format ">>>>":U            space( 0 )
  sym6               column-label " !-!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.unit-base column-label  "изм.!----!Наим!енов!ание"                      format "x(4)":U            space( 0 )
  sym7               column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.a-qnty    column-label "Излишек!Количество! ! ! ":C12                   format "->>>>>>>9.<<<":U   space( 0 )
  sym9               column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.a-stoim   column-label "Излишек!Сумма! ! ! ":C15                        format "->>>,>>>,>>9.99":U space( 0 )
  sym10              column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.b-qnty    column-label "Недостача!Количество! ! ! ":C12                 format "->>>>>>>9.<<<":U   space( 0 )
  sym12              column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.b-stoim   column-label "Недостача!Сумма! ! ! ":C15                      format "->>>,>>>,>>9.99":U space( 0 )
  sym14              column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
  temp-str.UBL       column-label "Списано!в пределах!норм!естественной!убыли":C13 format "->>>>>>>>>.<<":U   space( 0 )
  sym13              column-label ":!:!:!:!:"                                      format "x(1)":U            space( 0 )
header cur-time-print( ) at 5 format "x(35)":U
       string( "Сличительная ведомость N " + tdoc-code + "  от  " + string( tdoc-date, "99/99/9999":U ) ) at 47 format "x(63)":U
       string( pp ) at 134 format "x(19)":U string( "Лист " + string( page-number( Out-Stream ) - 1, ">>>>9":U ) ) at 160 format "x(13)":U skip
       UndLine format {&format-sl} at 1
with width {&DOS_CW_2} down stream-io use-text no-box.

do on error undo, return error :
  run get-report-num  in parParentProc ( output g#report-num  ).
  run get-gds-engl    in parParentProc ( output g#gds-engl    ).
  run get-quest-print in parParentProc ( output g#quest-print ).

  { gbl/getsect.i run "''"  0 {&attr-prt-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'sort-prd' then v-sort-prod = string( thbjattr_thbj-attr.property-value-logical) .
      if thbjattr_thbj-attr.prop-code = 'invprn0'  then v-prn0      = string( thbjattr_thbj-attr.property-value-logical) .
  end.


  if      p-grp = "yes"  then do: assign v-sort-prod = "no".  end.
  else if p-grp = "prod" then do: assign v-sort-prod = "yes". end.
  else do:
     /* из параметра */
  end.

  if sort-name = no then do:
    message 'Сортировать по коду?' skip
            'При ответе "НЕТ(NO)" - сортировка по артикулу.'
    view-as alert-box question buttons yes-no update sort-code.
  end.
  assign sort-group = ( if sort-gr = yes or p-grp = "yes" then yes else no ).

  find first buf_trn-doc no-lock where recid( buf_trn-doc ) = rec_id.
  assign tdoc-date = ( if buf_trn-doc.status_ <> {&fact} then buf_trn-doc.doc-date else buf_trn-doc.fact-date )
         tdoc-code = buf_trn-doc.doc-code.

  run Check-Doc-Sum in this-procedure no-error.
  if error-status :error then do: return error. end.

  if rep-tipe = "invent" and PrintScale = yes then do:
    message "Инвентаризационная опись не проводится с разбиением по признакам !" view-as alert-box.
    assign PrintScale = no.
  end.
  if session :set-wait-state( "COMPILER":U ) then do: end.
  define variable v-host-code as integer   no-undo .
  define variable v-curr-code as integer   no-undo .
  { gbl/hostcode.i
      buf_trn-doc.obj-type
      buf_trn-doc.obj-code
      v-host-code
  }
  if printRubl = yes
  then do:
      assign
          v-curr-code = 0
      .
  end.
  else do:
      { gbl/basecode.i
          v-host-code
          v-curr-code
      }
  end.
  { rep/inv3xl.i }
  { cmp/open-out.i stream Out-Stream " " {&LS_PS_A4} }

  if rep-tipe = "invent" and p-grp = "no" then do: run inv3xl-init in this-procedure. end.

  assign Line    = fill( "-", 230 )
         UndLine = fill( "_", 230 )
         LineBuf = fill( "_", 240 ).

  if CostPrice = yes then DO:
    if p-no-vat = "no" then do:
      assign PP = ( if PrintRubl = yes then "Учетные цены " else "Учетные цены (б.в.)" ).
    end.
    else do:
      assign PP = ( if PrintRubl = yes then "Учетные цены без НДС " else "Учетные цены без НДС (б.в.)" ).
    end.
  end.
  else do:
    assign PP = ( if PrintRubl = yes then "Цены док-та" else "Цены док-та (б.в.)" ).
  end.

  find This_Object no-lock where
       This_Object.obj-type = buf_trn-doc.obj-type  and
       This_Object.obj-code = buf_trn-doc.obj-code.
  find ub.clients  no-lock where
       ub.clients.obj-type  = {&cmp}               and
       ub.clients.obj-code  = buf_trn-doc.host-code.
  run PrintTitul in this-procedure.

  /* на каждой странице */
  if rep-tipe = "invent" then do:
    form with frame invent.
    form header
      LineBuf format {&format-inv} skip
      string( sym1 + string( PgQnty,   "->>>>>>>>>9.<<<":U    ) + sym2 + string( PgSum,   "->>>>>>>>>>9.99":U    ) + sym6 + "                 ":U +
              sym3 + string( PgQnty-b, "->>>>>>>>>>>>9.<<<":U ) + sym4 + string( PgSum-b, "->>>>>>>>>>>>>9.99":U ) + sym5 ) at 100 format "x(90)":U skip
      "Итого по странице : " skip
      "а) количество порядковых номеров "      +       string( PgNPP  ) + " (" + f-wp-qnty( decimal( PgNPP  ) ) + ")" format {&format-inv} at 18 skip
      "б) общее количество единиц фактически " +       string( PgQnty ) + " (" + f-wp-qnty( decimal( PgQnty ) ) + ")" format {&format-inv} at 18 skip
      "в) на сумму фактически "                + trim( string( PgSum, "->,>>>,>>>,>>>,>>>,>>>,>>9.99":U ) ) + abbr + " (" + f-wp-sum( decimal( PgSum ) ) + ")" format {&format-inv} at 18 skip( 1 )
      "Вкладной лист к форме № ИНВ-3 №  "      +       string( page-number( Out-Stream ) - 1, ">>>>9":U ) format "x(170)":U at 30 skip
    with frame BottomFrame width {&DOS_CW_2} page-bottom no-labels no-box.
    view stream Out-Stream frame BottomFrame.
    put  stream Out-Stream space( 35 ) string( "Инвентаризационная опись N " + tdoc-code ) format "x(50)":U skip
      space(  10 ) string( string( This_Object.obj-type, "x(3)":U ) + ": " + trim( This_Object.obj-name ) ) format "x(50)":U
      string( "дата инвентаризации : " + string( tdoc-date, "99.99.9999":U ) ) format "x(50)":U skip.
  end.
  if rep-tipe = "sl" then do: form with frame sl. end.

  { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

  /* сначала заполняем таблицу */
  { rep/inv3kg.i }

  /* теперь печать с сортировками */
  if v-sort-prod = "yes" then do:
    if sort-group = yes then do:
      for each temp-str no-lock
      break by temp-str.prod-type
            by temp-str.prod-code
            by temp-str.grp-name
            by {&Sort-pole}
      :
        if first-of( temp-str.prod-code ) then do: run print-prod in this-procedure. end.
        if p-grp <> "prod" and first-of( temp-str.grp-name ) then do: run print-grp      in this-procedure. end.
        run print-line in this-procedure.
        if p-grp <> "prod" and  last-of( temp-str.grp-name ) then do: run print-grp-itog in this-procedure. end.
        if last-of( temp-str.prod-code ) then do: run print-prod-itog in this-procedure. end.
      end. /* for each temp-str */
    end. /* sort-gr = yes */
    else do:
      for each temp-str no-lock
      break by temp-str.prod-type
            by temp-str.prod-code
            by {&Sort-pole}
      :
        if p-grp <> "prod" and first-of( temp-str.prod-code ) then do: run print-prod in this-procedure. end.
        run print-line in this-procedure.
        if last-of( temp-str.prod-code ) then do: run print-prod-itog in this-procedure. end.
      end. /* for each temp-str */
    end. /* sort-gr <> yes */
  end. /* v-sort-prod = yes */
  else do:
    if sort-group = yes then do:
      for each temp-str no-lock
      break by temp-str.grp-name
            by {&Sort-pole}
      :
        if p-grp = "no" and first-of( temp-str.grp-name ) then do: run print-grp in this-procedure. end.
        run print-line in this-procedure.
        if last-of( temp-str.grp-name ) then do: run print-grp-itog in this-procedure. end.
      end. /* for each temp-str */
    end. /* sort-gr = yes */
    else do:
      for each temp-str no-lock break by {&Sort-pole} :
        run print-line in this-procedure.
      end.
    end. /* sort-gr <> yes */
  end. /* v-sort-prod <> yes */
  run print-all-itog in this-procedure.

  /* ... Подвал. --- */
  run on-same-page in this-procedure ( input 14 ).
  run PrintPodval  in this-procedure.

  output stream Out-Stream close.
  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
  if rep-tipe = "invent" and p-grp = "no" then do: run inv3xl-close in this-procedure. end.
  { rep/q-print.i 8 }
end. /* on error */

/* *************************************************************************************************** */
procedure print-grp :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent" then do:
        down stream Out-Stream 1 with frame invent.
        put  stream Out-Stream unformatted string( "_______________Группа : " + trim( caps( temp-str.grp-name ) ) + UndLine ) format {&format-inv} skip.
      end.
      when "sl"     then do:
        down stream Out-Stream 1 with FRAME sl.
        put  stream Out-Stream unformatted string( "_______________Группа : " + trim( caps( temp-str.grp-name ) ) + UndLine ) format {&format-sl}  skip.
      end.
    end case.
  end.
end procedure. /* print-grp */

procedure print-prod :
  do on error undo, return error return-value :
    if p-grp = "prod" then do: return. end.
    find first buf_clients no-lock where
               buf_clients.obj-type = temp-str.prod-type and
               buf_clients.obj-code = temp-str.prod-code.
    case rep-tipe :
      when "invent" then do:
        down stream Out-Stream 1 with frame invent.
        put  stream Out-Stream unformatted string( "________Производитель : " + trim( caps( buf_clients.obj-name ) ) + UndLine ) format {&format-inv} skip.
      end.
      when "sl"     then do:
        down stream Out-Stream 1 with FRAME sl .
        put  stream Out-Stream unformatted string( "________Производитель : " + trim( caps( buf_clients.obj-name ) ) + UndLine ) format {&format-sl}  skip.
      end.
    end case.
  end.
end procedure. /* print-prod */

procedure print-line :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent" then do: { rep/inv31.i invent {&format-inv} } end.
      when "sl"     then do: { rep/inv31.i sl     {&format-sl}  } end.
    end case. /* rep-tipe */
  end. /* on error */
end procedure. /* print-line */

procedure print-grp-itog :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent" THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(temp-str.grp-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym8 sym11
          sum-a-qnty   @ temp-str.a-qnty
          sum-a-stoim  @ temp-str.a-stoim
          sum-b-qnty   @ temp-str.b-qnty
          sum-b-stoim  @ temp-str.b-stoim
        with FRAME invent.
        DOWN stream Out-Stream 1 with FRAME invent .
        if print-graft = no THEN Put stream Out-Stream LineBuf format {&format-inv} skip.
      End.
      when  "sl"  THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(temp-str.grp-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13
          sym14 sum-ubl @ temp-str.UBL
          sum-a-qnty   @ temp-str.a-qnty
          sum-a-stoim  @ temp-str.a-stoim
          sum-b-qnty   @ temp-str.b-qnty
          sum-b-stoim  @ temp-str.b-stoim
        with FRAME sl.
        DOWN stream Out-Stream 1 with FRAME sl .
        if print-graft = no THEN Put stream Out-Stream LineBuf format {&format-sl} skip.
      End.
    end.

    assign
      sum-a-qnty  = 0
      sum-b-qnty  = 0
      sum-a-qnty1 = 0
      sum-b-qnty1 = 0
      sum-a-stoim = 0
      sum-b-stoim = 0
      sum-ubl     = 0
    .

  end.
end procedure. /* print-grp-itog */

procedure print-prod-itog :
  do on error undo, return error return-value :
    find first buf_clients no-lock
      where buf_clients.obj-type = temp-str.prod-type
        and buf_clients.obj-code = temp-str.prod-code
    .
    case rep-tipe :
      when "invent" THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(buf_clients.obj-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym8 sym11
          sum2-a-qnty   @ temp-str.a-qnty
          sum2-a-stoim  @ temp-str.a-stoim
          sum2-b-qnty   @ temp-str.b-qnty
          sum2-b-stoim  @ temp-str.b-stoim
        with FRAME invent.
        DOWN stream Out-Stream 1 with FRAME invent .
        if print-graft = no THEN Put stream Out-Stream LineBuf format {&format-inv} skip.
      End.
      when  "sl"  THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(buf_clients.obj-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym14
          sum2-ubl     @ temp-str.UBL
          sum2-a-qnty   @ temp-str.a-qnty
          sum2-a-stoim  @ temp-str.a-stoim
          sum2-b-qnty   @ temp-str.b-qnty
          sum2-b-stoim  @ temp-str.b-stoim
        with FRAME sl.
        DOWN stream Out-Stream 1 with FRAME sl .
        if print-graft = no THEN Put stream Out-Stream LineBuf format {&format-sl} skip.
      End.
    end.

    assign
      sum2-a-qnty  = 0
      sum2-b-qnty  = 0
      sum2-a-qnty1 = 0
      sum2-b-qnty1 = 0
      sum2-a-stoim = 0
      sum2-b-stoim = 0
      sum2-ubl     = 0
    .

  end.
end procedure. /* print-grp-itog */

procedure print-all-itog :
  do on error undo, return error return-value :
  /* Итоговые суммы */
    case rep-tipe :
      when "invent" THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym8 sym11
          sum1-a-qnty   @ temp-str.a-qnty
          sum1-a-stoim  @ temp-str.a-stoim
          sum1-b-qnty   @ temp-str.b-qnty
          sum1-b-stoim  @ temp-str.b-stoim
        with FRAME invent.
        DOWN stream Out-Stream 1 with FRAME invent .
        Put stream Out-Stream LineBuf format {&format-inv} skip.
      End.
      when  "sl"  THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym14
          sum1-a-qnty   @ temp-str.a-qnty
          sum1-a-stoim  @ temp-str.a-stoim
          sum1-b-qnty   @ temp-str.b-qnty
          sum1-b-stoim  @ temp-str.b-stoim
          sum1-ubl      @ temp-str.ubl
        with FRAME sl.
        DOWN stream Out-Stream 1 with FRAME sl .
        Put stream Out-Stream LineBuf format {&format-sl} skip.
      End.
    End.
  end.
end procedure. /* print-all-itog */

procedure PrintTitul :
  define variable v-organization  as character    no-undo.
  define variable v-object        as character    no-undo.

  do on error undo, return error return-value  :
    /* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
    { rep/r-cliprp.i ub. }
    assign
        v-organization = string( "{&abbr_inn_allshift} " + t-inn + " " + CAPS( ub.clients.obj-name ) + " (" + string(ub.clients.obj-code) + ")"
                              + t-addres + t-phone)
        v-object       = string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" )
    .
    if rep-tipe = "invent" then do:
      if p-grp = "no" then do:
        run inv3xl-write-cell-data in this-procedure ( input {&inv3xl-h_organization} , input v-organization ).
        run inv3xl-write-cell-data in this-procedure ( input {&inv3xl-h_object} , input v-object ).
        run inv3xl-write-cell-data in this-procedure ( input {&inv3xl-h_docCode} , input tdoc-code ).
        run inv3xl-write-cell-data in this-procedure ( input {&inv3xl-h_docDate} , input string( tdoc-date, "99/99/9999") ).
        run inv3xl-write-cell-data in this-procedure ( input {&inv3xl-h_tbl_startDate} , input string( buf_trn-doc.doc-date, "99/99/9999") ).
        run inv3xl-write-cell-data in this-procedure ( input {&inv3xl-h_tbl_endDate} , input ( if buf_trn-doc.status_ <> {&fact} then string( tdoc-date, "99/99/9999") else "":U ) ).
      end.
      put stream Out-Stream
        space(5) Line format  "x(19)":U at 180 skip
        space(5) "| " at 180 {&g___code} at 188 "|" at 198 skip
        space(5) "Форма по ОКУД" format "x(14)":U at 166 "| " at 180 "0317004" "|" at 198 skip
        space(5) v-organization format "x(160)"
                   "по ОКПО" format "x(7)":U at 172 "| " at 180 t-okpo format "x(16)":U "|" at 198 skip
        space(5) v-object format "x(160)":U "| " at 180  "|" at 198 skip
        space(5) "Вид деятельности по ОКДП" format "x(25)":U at 155 "| " at 180 "|" at 198 skip
        space(5) string( "Основание для проведения инвентаризации:                 приказ, постановление, распоряжение " ) format "x(160)"
                       "номер" format "x(5)":U at 174 "| " at 180 "|" at 198 skip
        space(5) string( "ненужное зачеркнуть " ) format "x(20)":U at 67
                       "дата" format "x(4)":U at 175 "| " at 180 "|" at 198 skip
        space(5) "Дата начала инвентаризации" format "x(26)":U at 153 "| " at 180 buf_trn-doc.doc-date format "99/99/9999" "|" at 198 skip
        space(5) "Дата окончания инвентаризации" format "x(29)":U at 150 "| " at 180
                       (if buf_trn-doc.status_ <> {&fact} then tdoc-date else ?) format "99/99/9999" "|" at 198 skip
        space(5) "Вид операции" format "x(12)":U at 167 "| " at 180 " инвентаризация" format "x(16)":U "|" at 198 skip
        space(5) Line format  "x(19)":U at 180 skip(2)
        space(79) Line format "x(33)":U skip
        space(54) string( "ИНВЕНТАРИЗАЦИОННАЯ ОПИСЬ | "
                                    + string( tdoc-code , "x(16)") + " | "
                                    + string( tdoc-date, "99/99/9999")
                                    + " | "  + (if buf_trn-doc.status_ <> {&fact} then string( "(" + CAPS(buf_trn-doc.status_) + ")" ) else "")
                                    ) format "x(100)":U skip
        space(79) Line format "x(33)":U skip
        space(54) "товарно-материальных ценностей" format "x(30)":U skip( 1 )
        space(5) UndLine format "x(191)":U " ," skip
        space(52) "вид товарно-материальных ценностей" format "x(34)":U skip( 1 )
        space(5) string( "находящиеся " + UndLine ) format "x(193)":U skip
        space(52) "в собственности организации, полученные для переработки" format "x(55)":U skip(2)
        space(60) "РАСПИСКА" format "x(8)":U skip(2)
        space(10) "К началу проведения инвентаризации все расходные и приходные документы на товарно-материальные ценности сданы" format "x(188)":U skip
        space(5) "в бухгалтерию и все  товарно-материальные ценности,  поступившие  на  мою (нашу) ответственность,  оприходованы,  а выбывшие  списаны" format "x(193)":U skip
        space(5) "в расход." format "x(193)":U skip( 1 )
        space(5) "Материально ответственное (ые) лицо (а): " format "x(41)"
                       UndLine format "x(25)":U at 50 UndLine format "x(25)":U at 80 UndLine format "x(50)":U at 110 skip
        "должность" format "x(25)":U at 50 "подпись" format "x(25)":U at 80 "расшифровка подписи" format "x(50)":U at 110 skip( 1 )
        UndLine format "x(25)":U at 50 UndLine format "x(25)":U at 80 UndLine format "x(50)":U at 110 skip
        "должность" format "x(25)":U at 50 "подпись" format "x(25)":U at 80 "расшифровка подписи" format "x(50)":U at 110 skip( 1 )
        space(5) "Произведено снятие фактических остатков ценностей по состоянию на <<       >> _________________        г." format "x(193)":U skip(4)
      .
    end.
    else do:
      put stream Out-Stream
        space(5) Line format  "x(19)":U at 180 skip
        space(5) "| " at 180 {&g___code} at 188 "|" at 198 skip
        space(5) "Форма по ОКУД" format "x(14)":U at 166 "| " at 180 "0317017" "|" at 198 skip
        space(5) string( "{&abbr_inn_allshift} " + t-inn + " " + CAPS( ub.clients.obj-name ) + " (" + string(ub.clients.obj-code) + ")"
                                  + t-addres + t-phone) format "x(160)"
                       "по ОКПО" format "x(7)":U at 172 "| " at 180 t-okpo format "x(16)":U "|" at 198 skip
        space(5) string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" ) format "x(160)":U "| " at 180  "|" at 198 skip
        space(5) "Вид деятельности по ОКДП" format "x(25)":U at 155 "| " at 180 "|" at 198 skip
        space(5) string( "Основание для проведения инвентаризации:                 приказ, постановление, распоряжение " ) format "x(160)"
                       "номер" format "x(5)":U at 174 "| " at 180 "|" at 198 skip
        space(5) string( "ненужное зачеркнуть " ) format "x(20)":U at 67
                       "дата" format "x(4)":U at 175 "| " at 180 "|" at 198 skip
        space(5) "Дата начала инвентаризации" format "x(26)":U at 153 "| " at 180 buf_trn-doc.doc-date format "99/99/9999" "|" at 198 skip
        space(5) "Дата окончания инвентаризации" format "x(29)":U at 150 "| " at 180
                       (if buf_trn-doc.status_ <> {&fact} then tdoc-date else ?) format "99/99/9999" "|" at 198 skip
        space(5) "Вид операции" format "x(12)":U at 167 "| " at 180 " инвентаризация" format "x(16)":U "|" at 198 skip
        space(5) Line format  "x(19)":U at 180 skip(2)
        space(79) Line format "x(33)":U skip
        space(56) string( "СЛИЧИТЕЛЬНАЯ ВЕДОМОСТЬ | "
                                    + string( tdoc-code , "x(16)") + " | "
                                    + string( tdoc-date, "99/99/9999")
                                    + " | "  + (if buf_trn-doc.status_ <> {&fact} then string( "(" + CAPS(buf_trn-doc.status_) + ")" ) else "")
                                    ) format "x(100)":U skip
        space(79) Line format "x(33)":U skip
        space(40) "результатов инвентаризации товарно-материальных ценностей" format "x(130)":U skip(2)
        space(52) "Проведена инвентаризация фактического наличия ценностей, находящихся на ответственном хранении" format "x(134)":U skip(3)
         UndLine format "x(25)":U at 10 UndLine format "x(90)":U at 50 skip
        "должность" format "x(25)":U at 10 "фамилия,имя,отчество" format "x(50)":U   at 50 skip( 1 )
        UndLine format "x(25)":U at 10 UndLine format "x(90)":U at 50 skip
        "должность" format "x(25)":U at 10 "фамилия,имя,отчество" format "x(50)":U  at 50 skip( 1 )
        space(5) "По состоянию на <<       >> _________________        г." format "x(193)":U skip(2)
        space(5) "При инвентаризации установлено следующее :" skip
      .
    end.
    /* ... конец создания заголовка. --- */
    page stream Out-Stream.
  end.
end procedure. /* PrintTitul */

procedure PrintPodval :
  do on error undo, return error return-value  :
    run rep/wp-qnty.p ( num-ln , output PropisCount).
    if PropisCount = '' Then PropisCount = 'Ноль'.

    if rep-tipe = "invent" then do:
      PAGE stream Out-Stream.
      HIDE stream Out-Stream FRAME BottomFrame.
      HIDE stream Out-Stream FRAME BottomFrame2.

      run rep/wp-qnty.p ( sum1-a-qnty , output PropisQnty).
      if PropisQnty = '' Then PropisQnty = 'Ноль'.
      if PrintRubl = yes then do: run rep/wp-rub.p (                      input sum1-a-stoim, output PropisSumall, output abbr ). end.
                         else do: run rep/wp.p     ( input parParentProc, input sum1-a-stoim, output PropisSumall, output abbr ). end.

      if p-grp = "no" then do:
        run inv3xl-write-cell-data in this-procedure ( input {&inv3xl-f_itNumStr} , input PropisCount ).
        run inv3xl-write-cell-data in this-procedure ( input {&inv3xl-f_itQntyFactStr} , input PropisQnty ).
        run inv3xl-write-cell-data in this-procedure ( input {&inv3xl-f_itSumFactStr} , input PropisSumall ).
        run inv3xl-write-cell-data in this-procedure ( input {&inv3xl-it_qntyFact} , input string( sum1-a-qnty ) ).
        run inv3xl-write-cell-data in this-procedure ( input {&inv3xl-it_sumFact} , input string( sum1-a-stoim ) ).
        run inv3xl-write-cell-data in this-procedure ( input {&inv3xl-it_qntyBuh} , input string( sum1-b-qnty ) ).
        run inv3xl-write-cell-data in this-procedure ( input {&inv3xl-it_sumBuh} , input string( sum1-b-stoim ) ).
      end.
      put stream Out-Stream
              "Итого по описи :" skip
                "а) количество порядковых номеров: " + string( num-ln ) + " (" + PropisCount + ")"  format "x(179)":U                         at 18 skip
                "б) общее количество единиц фактически: " + string( sum1-a-qnty ) + " (" + PropisQnty + ")"  format "x(179)":U  at 18 skip
                "в) на сумму фактически : " + trim(string((sum1-a-stoim ), "->,>>>,>>>,>>>,>>>,>>>,>>9.99")) + abbr +
                              " (" + PropisSumall + ")"  format "x(179)":U                                                 at 18 skip( 1 )
              "   Все цены, подсчеты итогов по строкам, страницам и в целом по инвентаризационной описи товарно-материальных ценностей проверены." skip
              "Председатель комиссии: " format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
              " " format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip
              "Члены комиссии: " format "x(25)":U at 10 skip
              LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
              "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip
              LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
              "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip
              LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
              "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip
              "   Все товарно-материальные ценности, поименованные  в  настоящей  инвентаризационной  описи  с № ___________ по № _________" skip
              "комиссией проверены в натуре в моем (нашем) личном присутствии  и внесены в опись, в связи с чем претензий к инвентаризационной " skip
              "комиссии не имею (не имеем). Товарно-материальные ценности, перечисленные в описи, находятся на моем (нашем) ответственном хранении." skip( 1 )
              "   Лицо(а), ответственное(ые) за сохранность товарно-материальных ценностей : " skip( 1 )
              LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
              "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip
              LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
              "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip
              LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
              "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip( 1 )
              "<<       >> _________________        г. "   skip( 1 )
              "Указанные в настоящей описи данные и расчеты проверил"
                  LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U   at 40 LineBuf format "x(50)":U               at 70 skip
              "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip
              "<<       >> _________________        г. "
      .
    end.
    else do:
      if PrintRubl = yes then do: run rep/wp-rub.p (                      input ( sum1-a-stoim - sum1-b-stoim ), output PropisSumall, output abbr ). end.
                         else do: run rep/wp.p     ( input parParentProc, input ( sum1-a-stoim - sum1-b-stoim ), output PropisSumall, output abbr ). end.
      run rep/wp-qnty.p ( input ( sum1-a-qnty - sum1-b-qnty ), output PropisQnty ).
      if PropisQnty  = '' Then PropisQnty = 'Ноль'.
      PUT  STREAM Out-Stream
           "Итого по ведомости :" skip
           "а) количество порядковых номеров: " + string(num-ln) + " (" + PropisCount + ")"  format "x(179)":U                         at 18 skip
           "б) общее количество единиц (излишки - недостача): " + string( sum1-a-qnty - sum1-b-qnty ) + " (" + PropisQnty + ")" format "x(179)":U  at 18 skip
           "в) на сумму (излишки - недостача) : " + trim(string((sum1-a-stoim - sum1-b-stoim ), "->,>>>,>>>,>>>,>>>,>>>,>>9.99")) + abbr + " (" + PropisSumall + ")"  format "x(179)"    at 18 skip( 1 )
           "С результатами сличения ознакомлен : "  skip "        Бухгалтер" LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
           "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip( 1 ) "Материально ответственное(ые)  лицо(а)" skip
           LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
           "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip
           LineBuf format "x(25)":U at 10 LineBuf format "x(25)":U at 40 LineBuf format "x(50)":U at 70 skip
           "должность" format "x(25)":U at 10 "подпись" format "x(25)":U at 40 "расшифровка подписи" format "x(50)":U at 70 skip( 1 )
      .
    end.
    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */

PROCEDURE on-same-page :
  define input parameter p-line-number as integer no-undo.

  if p-line-number > page-size( Out-Stream ) then do: return. end.
  if line-counter( Out-Stream ) + p-line-number > page-size( Out-Stream ) then do: page stream Out-Stream. end.
end procedure. /* on-same-page */

procedure Check-Doc-Sum :
  define variable v-attr-value as character no-undo.
  define variable v-attr-type  as character no-undo.
  define variable ask          as logical   no-undo.

  do on error undo, return error return-value :
    { str/tdat-val.i buf_trn-doc.doc-code
                 {&trdcattr-addsum}
                 v-attr-value
                 v-attr-type         }
    if buf_trn-doc.status_ = {&fact} then do:
      case rep-tipe :
        when "invent" then do: /* это инвентариз. опись */
          if lookup( {&sum-before-doc}, v-attr-value ) = 0 or
             lookup( {&sum-after-doc},  v-attr-value ) = 0 then do:
            run utl/uaddsum.p ( input buf_trn-doc.doc-code, input no, input no, input no ) no-error.
            if error-status :error then do: message return-value error-status :get-message( 1 ) view-as alert-box error. end.
          end.
        end.
        when "sl"     then do:
          if lookup( {&sum-general-doc}, v-attr-value ) = 0 or
             lookup( {&sum-wastage-doc}, v-attr-value ) = 0 then do:
            run utl/uaddsum.p ( input buf_trn-doc.doc-code, input yes, input yes, input no ) no-error.
            if error-status :error then do: message return-value error-status :get-message( 1 ) view-as alert-box error. end.
          end.
        end.
      end case.
    end.
    else do:
      case rep-tipe :
        when "invent" then do: /* это инвентариз. опись */
          if lookup( {&sum-before-doc}, v-attr-value ) = 0 then do:
            message "Не рассчитаны данные до начала инвентаризации!" view-as alert-box.
            undo, return error.
          end.
          if lookup( {&sum-after-doc}, v-attr-value ) = 0 then do:
            if p-no-vat = "yes" then do:
              message "Не рассчитаны данные после инвентаризации!" view-as alert-box.
              undo, return error.
            end.
            assign is-after = no.
          end.
        end.
        when "sl"     then do:
          if lookup( {&sum-wastage-doc}, v-attr-value ) = 0 then do:
            message "Не рассчитаны нормы естественной убыли!" skip
                    "Напечатать документ без их учета?"
            view-as alert-box question buttons yes-no update ask.
            if ask = yes then do: assign is-wastage = no. end.
                         else do: undo, return error. end.
          end.
          if lookup( {&sum-general-doc}, v-attr-value ) = 0 then do: assign is-general = no. end.
        end.
      end case.
    end.
  end.
end procedure. /* Check-Doc-Sum */