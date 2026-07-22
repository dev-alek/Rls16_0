block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inv-pst.p $
$Archive: rep/inv-pst.p $

Печать документов инвентаризации с группировкой по поставщикам

Автор: Чернова Светлана Александровна
Дата создания: 03/02/06
Author: Svetlana Chernova
Creation date: 03/02/06


Creation date: 09/17/03 12:14

*/

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: inv-pst.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/inv-pst.p $":U .
define variable vss-description as character no-undo initial "Печать документов инвентаризации с группировкой по поставщикам    ":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ cmp/r-pril.i   }
{ cmp/breakstr.i }
{ rep/r-cliprp.i def }
{ str/trdcalib.i }
{ trg/factord.i  }
{ trg/partslib.i }
{ gbl/getcntxt.i def }
{ gbl/waitfram.i }
{ gbl/getsect.i  def }

&glob format-inv      "X(185)"
&glob format-sl       "X(162)"
&scop gds-len 40

define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter rec_id               as recid            no-undo.
define input parameter rep-tipe             as character        no-undo.
define input parameter p-no-vat             as character        no-undo.   /* используется для без НДС в цуме */
define input parameter p-grp                as character        no-undo.   /* используется для печати только сумм по группам */
define input parameter print-graft          as logical          no-undo.


define shared variable sort-name   as logical no-undo.
define shared variable sort-gr     as logical no-undo.
define shared variable CostPrice   as logical no-undo .
define shared variable PrintScale  as logical no-undo .

define variable l-b-stoim  as decimal no-undo .
define variable l-b-qnty   as decimal no-undo .
define variable l-a-stoim  as decimal no-undo .
define variable l-a-qnty   as decimal no-undo .

define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal no-undo .
define variable v-cur-rt as decimal no-undo .
define variable v-cur-ex as decimal no-undo .

define variable v-log as logical no-undo .

define variable g#report-num    as integer      no-undo.
define variable g#quest-print   as logical      no-undo.
define variable g#log           as logical      no-undo.
define variable g#gds-engl      as logical      no-undo.

do
on error undo, return error
:
  { gbl/getcntxt.i get " " p-mainmenu-handle }
  run get-report-num in p-mainmenu-handle (
      output g#report-num
  ).
  run get-quest-print in p-mainmenu-handle (
      output g#quest-print
  ).
  run get-gds-engl in p-mainmenu-handle (
      output g#gds-engl
  ).
  define variable skod as logical   no-undo .
  if sort-name = no then message "Сортировать по коду? (При ответе 'нет' сортировка по артикулу)."  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE skod.

  &Scop Sort-pole if sort-name then  temp-str.gds-name Else ( if skod then  temp-str.b-code Else temp-str.artic )

  define variable sort-group as logical   no-undo .
  if sort-gr or p-grp = "yes" then assign sort-group = yes .
  else                             assign sort-group = no .


  DEFINE temp-table temp-str no-undo
    field   grp-name          as  char
    field   gds-name          as  char
    field   gds-code         as  integer
    field   artic             as  char
    field   prod-type         as  char
    field   prod-code         as  integer
    field   supp-type         as  char
    field   supp-code         as  integer
    field   supp-name          as  char
    field   b-code            as character
    field   tb-code           as  char
    field   OKEI              as  integer
    field   unit-base         as  char
    field   empty-scale       as logical
    field   Price-after       as decimal
    field   a-qnty            as decimal
    field   a-qnty1           as decimal
    field   a-stoim           as decimal
    field   price-befor       as decimal
    field   b-qnty            as decimal
    field   b-qnty1           as decimal
    field   b-stoim           as decimal
    field   ubl               as decimal
    INDEX pi  IS PRIMARY   supp-type supp-code artic prod-type prod-code
    INDEX pi1              gds-name
    INDEX pi2              grp-name
    INDEX pi3              tb-code
  .


  def stream Out-Stream.

  def buffer This_Object      for ub.clients .
  def buffer buf_doc-line     for ub.doc-line .
  def buffer buf_goods        for ub.goods .
  def buffer buf_doc-line-sum for ub.doc-line-sum .
  def buffer buf_gds-dtl      for ub.gds-dtl .
  def buffer buf_gds-prt      for ub.gds-prt .
  def buffer buf_parts        for ub.parts .
  define buffer bf_doc-attr   for ub.doc-attr .
  define buffer buf_clients   for ub.clients.

  define variable qnty as decimal   no-undo .
  define variable sum  as decimal   no-undo .

  define variable is-after      as logical initial yes no-undo .
  define variable is-after-cli  as logical initial yes no-undo .
  define variable is-wastage    as logical initial yes no-undo .

  define variable v-root-node   as integer   no-undo .
  define variable num-ln as integer   no-undo .

  define variable sum-a-qnty   as decimal initial 0  no-undo .
  define variable sum-b-qnty   as decimal initial 0  no-undo .
  define variable sum-a-qnty1  as decimal initial 0  no-undo .
  define variable sum-b-qnty1  as decimal initial 0  no-undo .
  define variable sum-a-stoim  as decimal initial 0  no-undo .
  define variable sum-b-stoim  as decimal initial 0  no-undo .
  define variable sum-ubl      as decimal initial 0  no-undo .
  define variable sum1-a-qnty  as decimal initial 0  no-undo .
  define variable sum1-b-qnty  as decimal initial 0  no-undo .
  define variable sum1-a-qnty1 as decimal initial 0  no-undo .
  define variable sum1-b-qnty1 as decimal initial 0  no-undo .
  define variable sum1-a-stoim as decimal initial 0  no-undo .
  define variable sum1-b-stoim as decimal initial 0  no-undo .
  define variable p-sum-a-qnty   as decimal initial 0  no-undo .
  define variable p-sum-b-qnty   as decimal initial 0  no-undo .
  define variable p-sum-a-qnty1  as decimal initial 0  no-undo .
  define variable p-sum-b-qnty1  as decimal initial 0  no-undo .
  define variable p-sum-a-stoim  as decimal initial 0  no-undo .
  define variable p-sum-b-stoim  as decimal initial 0  no-undo .
  define variable p-sum-ubl      as decimal initial 0  no-undo .

  def var FullNameGds as character no-undo .
  def var gds-str as char no-undo.
  def var gds-str1 as char no-undo.
  def var gds-str2 as char no-undo.
  def var i as int no-undo.
  def var j as int no-undo.
  define variable Counter1 as integer init 0  no-undo .

  def var LineBuf       as char    no-undo.
  def var Line       as char    no-undo.
  def var UndLine    as char    no-undo.

  def var     Lines_Counter as   int  init 0  no-undo.
  def var     Tmp_Counter   as   int  init 0  no-undo.

  def var     tdoc-date     like ub.trn-doc.doc-date no-undo.
  def var     tdoc-code     like ub.trn-doc.doc-code no-undo.

  def var  PgQnty            as  dec no-undo.
  def var  PgQnty-v          as  dec no-undo.
  def var  PgSum             as  dec no-undo.
  def var  PgQnty-b          as  dec no-undo.
  def var  PgQnty-b-v        as  dec no-undo.
  def var  PgSum-b           as  dec no-undo.
  def var  PgNPP             as  int no-undo.

  define variable UBL-v      as decimal   no-undo .
  define variable b-code     as integer   no-undo .

  def var  PropisQnty        as  char no-undo.
  def var  PropisSumall      as  char no-undo.
  def var  Propiscount       as  char no-undo.
  def var  abbr              as  char no-undo.
  def var  pp                as  char no-undo.


  def var sym1 as char  init ":"   no-undo.
  def var sym2 as char  init ":"   no-undo.
  def var sym3 as char  init ":"   no-undo.
  def var sym4 as char  init ":"   no-undo.
  def var sym5 as char  init ":"   no-undo.
  def var sym6 as char  init ":"   no-undo.
  def var sym7 as char  init ":"   no-undo.
  def var sym8 as char  init ":"   no-undo.
  def var sym9 as char  init ":"   no-undo.
  def var sym10 as char init ":"   no-undo.
  def var sym11 as char init ":"   no-undo.
  def var sym12 as char init ":"   no-undo.
  def var sym13 as char init ":"   no-undo.
  def var sym14 as char init ":"   no-undo.
  def var sym15 as char init ":"   no-undo.

  FUNCTION f-wp-qnty  char (INPUT p-dec as decimal ).
    def var  pr as char no-undo .
    run rep/wp-qnty.p ( p-dec, output Pr ).
    RETURN( Pr ) .
  END FUNCTION.

  FUNCTION f-wp-sum  char (INPUT p-dec as decimal ).
    def var  pr as char no-undo .
    if NOT PrintRubl then  run rep/wp.p ( input p-mainmenu-handle, p-dec, output Pr, output abbr).
    else                   run rep/wp-rub.p ( p-dec, output pr, output abbr).
    RETURN( Pr ) .
  END FUNCTION.


  DEFINE FRAME invent
        sym1 column-label ":!:!:!:!:"  format "X(1)" space(0)
        Lines_Counter COLUMN-LABEL "N!п/п! ! ! ":C5 format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.artic COLUMN-LABEL "Артикул! ! ! ! ":C17 format "X(17)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.gds-name COLUMN-LABEL "Наименование товара! ! ! ! ":C40 format "X(40)" space(0)
        Sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-code COLUMN-LABEL "Код товара! ! ! ! ":C10 format "X(9)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.OKEI COLUMN-LABEL "Ед.!----!Код !по!ОКЕИ":C4 format ">>>>" space(0)
        sym6 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.unit-base COLUMN-LABEL  "изм.!----!Наим!енов!ание" format "X(4)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.Price-after COLUMN-LABEL " ! Цена ! ! ! ":C13 format "->>>>>9.99" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.a-qnty COLUMN-LABEL "Фактическое!-------------!Количество! ! ":C13 format "->>>>>>>9.<<<" space(0)
        sym9 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.a-stoim COLUMN-LABEL " наличие !--------------!Сумма! ! ":C15 format "->>>,>>>,>>9.99" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.Price-befor COLUMN-LABEL "По данным!----------------!Цена! ! ":C17 format "->>>>>9.99" space(0)
        sym11 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.b-qnty COLUMN-LABEL "бухгалтерского!---------------!Количество! ! ":C17 format "->>>>>>>9.<<<" space(0)
        sym12 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.b-stoim COLUMN-LABEL " учета !----------------!Сумма! ! ":C17 format "->>>,>>>,>>9.99" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)

       HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Инвентаризационная опись N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp) AT 160 format "X(27)"
        string( "Лист " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") ) AT 180 format "X(13)" SKIP
        UndLine format {&format-inv} AT 1
        with width {&DOS_CW_2} down stream-io use-text NO-BOX.


DEFINE FRAME sl
        sym1 column-label ":!:!:!:!:"  format "X(1)" space(0)
        Lines_Counter COLUMN-LABEL "N!п/п! ! ! ":C5 format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.artic COLUMN-LABEL "Артикул! ! ! ! ":C17 format "X(17)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.gds-name COLUMN-LABEL "Наименование товара! ! ! ! ":C40 format "X(40)" space(0)
        Sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-code COLUMN-LABEL "Код товара! ! ! ! ":C13 format "X(13)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.OKEI COLUMN-LABEL "Ед.!----!Код ! по !ОКЕИ" format ">>>>" space(0)
        sym6 column-label         " !-!:!:!:" format "X(1)" space(0)
        temp-str.unit-base COLUMN-LABEL  "изм.!----!Наим!енов!ание" format "X(4)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.a-qnty COLUMN-LABEL "Излишек!Количество! ! ! ":C12 format "->>>>>>>9.<<<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.a-stoim COLUMN-LABEL "Излишек!Сумма! ! ! ":C15 format "->>>,>>>,>>9.99" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-qnty COLUMN-LABEL "Недостача!Количество! ! ! ":C12 format "->>>>>>>9.<<<" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-stoim COLUMN-LABEL "Недостача!Сумма! ! ! ":C15 format "->>>,>>>,>>9.99" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.UBL COLUMN-LABEL "Списано!в пределах!норм!естественной!убыли":C13 format "->>>>>>>>>.<<" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)

       HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Сличительная ведомость N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp ) AT 134 format "X(19)"
        string( "Лист " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") ) AT 160 format "X(13)" SKIP
        UndLine format {&format-sl} AT 1
        with width {&DOS_CW_2} down stream-io use-text NO-BOX.


  FIND ub.trn-doc WHERE recid(ub.trn-doc) = rec_id NO-LOCK .
  assign
    tdoc-date = (if ub.trn-doc.status_ <> {&fact} then ub.trn-doc.doc-date else ub.trn-doc.fact-date)
    tdoc-code = ub.trn-doc.doc-code
  .

  run Check-Doc-Sum in this-procedure no-error  .
  if error-status :error then return error .

  if rep-tipe <> "sl" and PrintScale = true THEN DO:
    message "Инвентаризационная опись не проводится с разбиением по признакам !" view-as alert-box . PrintScale = false .
  End.

  if session :set-wait-state( "compiler":U ) then.

  { cmp/open-out.i STREAM Out-Stream " " {&LS_PS_A4}  }


  define variable v-prn0 as character no-undo .
  { gbl/getsect.i run "''" 0  {&attr-prt-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'invprn0'  then v-prn0      = string( thbjattr_thbj-attr.property-value-logical) .
  end.


  assign
    Line    = fill("-", 230)
    UndLine = fill("_", 230)
    LineBuf = fill("_", 240)
  .

 /* CostPrice = true . */
  if  CostPrice then DO:
    if p-no-vat = "no" then do:
      IF PrintRubl THEN Assign PP = "Учетные цены ".
      Else Assign PP = "Учетные цены (б.в.)" .
    end.
    else do:
      IF PrintRubl THEN Assign PP = "Учетные цены без НДС ".
      Else Assign PP = "Учетные цены без НДС (б.в.)" .
    end.
  End.
  Else DO:
    IF PrintRubl THEN Assign PP = "Цены док-та".
    Else Assign PP = "Цены док-та (б.в.)" .
  End.

  run waitfram-show in this-procedure ( input {&MyWaitMess} ).

  FIND This_Object  WHERE This_Object.obj-type = ub.trn-doc.obj-type AND This_Object.obj-code = ub.trn-doc.obj-code  NO-LOCK.
  FIND ub.clients      WHERE ub.clients.obj-type     = {&cmp}           AND ub.clients.obj-code     = ub.trn-doc.host-code NO-LOCK.

  run PrintTitul in this-procedure .

  /*на каждой странице */
  if rep-tipe = "invent" THEN  DO:
    FORM with frame invent .
    FORM HEADER
      LineBuf format {&format-inv} SKIP
      String(sym1 + String(PgQnty ,  "->>>>>>>>>9.<<<" ) + sym2 + String(PgSum , "->>>>>>>>>>9.99"   ) +  sym6 + "                 " +
             sym3 + String(PgQnty-b,  "->>>>>>>>>>>>9.<<<" ) + sym4 + String(PgSum-b , "->>>>>>>>>>>>>9.99"   ) + sym5)  at 100 Format "x(90)" skip
      "Итого по странице : " skip
      "а) количество порядковых номеров " + string(PgNPP) + " (" + f-wp-qnty (decimal(PgNPP)) + ")" format {&format-inv} AT 18  skip
      "б) общее количество единиц фактически " + string(PgQnty) + " (" + f-wp-qnty (decimal(PgQnty)) + ")"  format {&format-inv} AT 18  SKIP
      "в) на сумму фактически " + trim(string(PgSum, "->,>>>,>>>,>>>,>>>,>>>,>>9.99")) + abbr + " (" + f-wp-sum (decimal(PgSum)) + ")"  format {&format-inv} AT 18 SKIP(1)
      "Вкладной лист к форме № ИНВ-3 №  " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") format "x(170)" AT 30 SKIP
    with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW stream Out-Stream FRAME BottomFrame .
  End.
  if rep-tipe begins "invent" THEN DO:
    PUT stream Out-Stream SPACE(35) string ("Инвентаризационная опись N " + tdoc-code ) format "x(50)" SKIP
      SPACE(10) string (string (v-cntxt-obj-type , "X(3)") + ": " + trim(This_Object.obj-name) ) format "x(50)"
      string ("дата инвентаризации : " + string (tdoc-date, "99.99.9999") ) format "x(50)" SKIP.
  End.

  if rep-tipe = "sl" THEN  FORM with frame sl .


  /* по строкам документа-------------------------------------------------------------------------------------------- */

  { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 10  } /* Показать окно информации о текущем процессе */

  /* сначала заполняем таблицу */
  { rep/inv3-pst.i }

  /* теперь печать с сортировками */
  if sort-group = yes then do:
    for each temp-str no-lock break by temp-str.supp-name by temp-str.grp-name by {&Sort-pole} :
      if first-of(temp-str.supp-name) then run print-supp in this-procedure .
          if p-grp = "no" and first-of( temp-str.grp-name) then run print-grp in this-procedure .
          run print-line in this-procedure .
          if last-of( temp-str.grp-name) then  run print-grp-itog in this-procedure .
      if last-of( temp-str.supp-name) then  run print-supp-itog in this-procedure .
    end.
  end.        /* sort-gr = yes */
  else do:
    for each temp-str no-lock break by temp-str.supp-name by {&Sort-pole} :
      if first-of(temp-str.supp-name) then run print-supp in this-procedure .
        run print-line in this-procedure .
      if last-of( temp-str.supp-name) then  run print-supp-itog in this-procedure .
    end.
  end.        /* sort-gr <> yes */
  run print-all-itog in this-procedure .

  /* ... Подвал. --- */
  run on-same-page in this-procedure (input 14) .

  run PrintPodval in this-procedure .

  output stream Out-Stream CLOSE .
  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

  if session :set-wait-state( "":U ) then.
  run waitfram-hide in this-procedure.

  { rep/q-print.i 8 }
end.

/* *************************************************************************************************** */

procedure print-grp :
  do  on error undo, return error return-value  :
    case rep-tipe :
      when "invent" THEN DO:
        DOWN stream Out-Stream 1 with FRAME invent .
        PUT stream Out-Stream UNFORMATTED String("_______________Группа : " + TRIM(CAPS(temp-str.grp-name)) + UndLine)  FORMAT {&format-inv}  skip  .
      End.
      when  "sl"  THEN DO:
        DOWN stream Out-Stream 1 with FRAME sl .
        PUT stream Out-Stream UNFORMATTED String("_______________Группа : " + TRIM(CAPS(temp-str.grp-name)) + UndLine)  FORMAT {&format-sl}  skip  .
      End.
    End.
  end.
end procedure. /* print-grp */

procedure print-supp :
  do  on error undo, return error return-value  :
    case rep-tipe :
      when "invent" THEN DO:
        DOWN stream Out-Stream 1 with FRAME invent .
        PUT stream Out-Stream UNFORMATTED String("______ПОСТАВЩИК : " + TRIM(CAPS(temp-str.supp-name)) + UndLine)  FORMAT {&format-inv}  skip  .
      End.
      when  "sl"  THEN DO:
        DOWN stream Out-Stream 1 with FRAME sl .
        PUT stream Out-Stream UNFORMATTED String("______ПОСТАВЩИК : " + TRIM(CAPS(temp-str.supp-name)) + UndLine)  FORMAT {&format-sl}  skip  .
      End.
    End.
  end.
end procedure. /* print-grp */




procedure print-line :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent"      THEN DO:  { rep/inv-pst1.i invent      {&format-inv}      }  End.
      when  "sl"         THEN DO:  { rep/inv-pst1.i sl          {&format-sl}       }  End.
    End.
  end.
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
        if print-graft = false THEN Put stream Out-Stream LineBuf format {&format-inv} SKIP.
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
        if print-graft = false THEN Put stream Out-Stream LineBuf format {&format-sl} SKIP.
      End.
    End.

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

procedure print-supp-itog :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent" THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(temp-str.supp-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym8 sym11
          p-sum-a-qnty   @ temp-str.a-qnty
          p-sum-a-stoim  @ temp-str.a-stoim
          p-sum-b-qnty   @ temp-str.b-qnty
          p-sum-b-stoim  @ temp-str.b-stoim
        with FRAME invent.
        DOWN stream Out-Stream 1 with FRAME invent .
        if print-graft = false THEN Put stream Out-Stream LineBuf format {&format-inv} SKIP.
      End.
      when  "sl"  THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(temp-str.supp-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13
          sym14 sum-ubl @ temp-str.UBL
          p-sum-a-qnty   @ temp-str.a-qnty
          p-sum-a-stoim  @ temp-str.a-stoim
          p-sum-b-qnty   @ temp-str.b-qnty
          p-sum-b-stoim  @ temp-str.b-stoim
        with FRAME sl.
        DOWN stream Out-Stream 1 with FRAME sl .
        if print-graft = false THEN Put stream Out-Stream LineBuf format {&format-sl} SKIP.
      End.
    End.

    assign
      p-sum-a-qnty  = 0
      p-sum-b-qnty  = 0
      p-sum-a-qnty1 = 0
      p-sum-b-qnty1 = 0
      p-sum-a-stoim = 0
      p-sum-b-stoim = 0
      p-sum-ubl     = 0
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
        Put stream Out-Stream LineBuf format {&format-inv} SKIP.
      End.
      when  "sl"  THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13  sym14
          sum1-a-qnty   @ temp-str.a-qnty
          sum1-a-stoim  @ temp-str.a-stoim
          sum1-b-qnty   @ temp-str.b-qnty
          sum1-b-stoim  @ temp-str.b-stoim
        with FRAME sl.
        DOWN stream Out-Stream 1 with FRAME sl .
        Put stream Out-Stream LineBuf format {&format-sl} SKIP.
      End.
    End.
  end.
end procedure. /* print-all-itog */


procedure PrintTitul :
  do  on error undo, return error return-value  :
    /* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
    { rep/r-cliprp.i ub. }
    if rep-tipe begins "invent"   THEN
      PUT STREAM Out-Stream
        space(5) Line format  "X(19)" AT 180 skip
        space(5) "| " AT 180 {&g___code} AT 188 "|" AT 198 skip
        space(5) "Форма по ОКУД" format "X(14)" AT 166 "| " AT 180 "0317004" "|" AT 198 skip
        space(5) string( "{&abbr_inn_allshift} " + t-inn + " " + CAPS( ub.clients.obj-name ) + " (" + string(ub.clients.obj-code) + ")"
                              + t-addres + t-phone) format "X(160)"
                   "по ОКПО" format "X(7)" AT 172 "| " AT 180 t-okpo format "X(16)" "|" AT 198 skip
        space(5) string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" ) format "X(160)" "| " AT 180  "|" AT 198 skip
        space(5) "Вид деятельности по ОКДП" format "X(25)" AT 155 "| " AT 180 "|" AT 198 skip
        space(5) string( "Основание для проведения инвентаризации:                 приказ, постановление, распоряжение " ) format "X(160)"
                       "номер" format "X(5)" AT 174 "| " AT 180 "|" AT 198 skip
        space(5) string( "ненужное зачеркнуть " ) format "X(20)" AT 67
                       "дата" format "X(4)" AT 175 "| " AT 180 "|" AT 198 skip
        space(5) "Дата начала инвентаризации" format "X(26)" AT 153 "| " AT 180 ub.trn-doc.doc-date format "99/99/9999" "|" AT 198 skip
        space(5) "Дата окончания инвентаризации" format "X(29)" AT 150 "| " AT 180
                       (if ub.trn-doc.status_ <> {&fact} then tdoc-date else ?) format "99/99/9999" "|" AT 198 skip
        space(5) "Вид операции" format "X(12)" AT 167 "| " AT 180 " инвентаризация" format "X(16)" "|" AT 198 skip
        space(5) Line format  "X(19)" AT 180 skip(2)
        space(79) Line format "X(33)" skip
        space(54) string( "ИНВЕНТАРИЗАЦИОННАЯ ОПИСЬ | "
                                    + string( tdoc-code , "X(16)") + " | "
                                    + string( tdoc-date, "99/99/9999")
                                    + " | "  + (if ub.trn-doc.status_ <> {&fact} then string( "(" + CAPS(ub.trn-doc.status_) + ")" ) else "")
                                    ) format "X(100)" skip
        space(79) Line format "X(33)" skip
        space(54) "товарно-материальных ценностей" format "X(30)" skip(1)
        space(5) UndLine format "X(191)" " ," skip
        space(52) "вид товарно-материальных ценностей" format "X(34)" skip(1)
        space(5) string( "находящиеся " + UndLine ) format "X(193)" skip
        space(52) "в собственности организации, полученные для переработки" format "X(55)" skip(2)
        space(60) "РАСПИСКА" format "X(8)" skip(2)
        space(10) "К началу проведения инвентаризации все расходные и приходные документы на товарно-материальные ценности сданы" format "X(188)" skip
        space(5) "в бухгалтерию и все  товарно-материальные ценности,  поступившие  на  мою (нашу) ответственность,  оприходованы,  а выбывшие  списаны" format "X(193)" SKIP
        space(5) "в расход." format "X(193)" SKIP(1)
        space(5) "Материально ответственное (ые) лицо (а): " format "X(41)"
                       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
        "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
        UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
        "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
        space(5) "Произведено снятие фактических остатков ценностей по состоянию на <<       >> _________________        г." format "X(193)" SKIP(4)
      .
    Else
    PUT STREAM Out-Stream
        space(5) Line format  "X(19)" AT 180 skip
        space(5) "| " AT 180 {&g___code} AT 188 "|" AT 198 skip
        space(5) "Форма по ОКУД" format "X(14)" AT 166 "| " AT 180 "0317017" "|" AT 198 skip
        space(5) string( "{&abbr_inn_allshift} " + t-inn + " " + CAPS( ub.clients.obj-name ) + " (" + string(ub.clients.obj-code) + ")"
                                  + t-addres + t-phone) format "X(160)"
                       "по ОКПО" format "X(7)" AT 172 "| " AT 180 t-okpo format "X(16)" "|" AT 198 skip
        space(5) string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" ) format "X(160)" "| " AT 180  "|" AT 198 skip
        space(5) "Вид деятельности по ОКДП" format "X(25)" AT 155 "| " AT 180 "|" AT 198 skip
        space(5) string( "Основание для проведения инвентаризации:                 приказ, постановление, распоряжение " ) format "X(160)"
                       "номер" format "X(5)" AT 174 "| " AT 180 "|" AT 198 skip
        space(5) string( "ненужное зачеркнуть " ) format "X(20)" AT 67
                       "дата" format "X(4)" AT 175 "| " AT 180 "|" AT 198 skip
        space(5) "Дата начала инвентаризации" format "X(26)" AT 153 "| " AT 180 ub.trn-doc.doc-date format "99/99/9999" "|" AT 198 skip
        space(5) "Дата окончания инвентаризации" format "X(29)" AT 150 "| " AT 180
                       (if ub.trn-doc.status_ <> {&fact} then tdoc-date else ?) format "99/99/9999" "|" AT 198 skip
        space(5) "Вид операции" format "X(12)" AT 167 "| " AT 180 " инвентаризация" format "X(16)" "|" AT 198 skip
        space(5) Line format  "X(19)" AT 180 skip(2)
        space(79) Line format "X(33)" skip
        space(56) string( "СЛИЧИТЕЛЬНАЯ ВЕДОМОСТЬ | "
                                    + string( tdoc-code , "X(16)") + " | "
                                    + string( tdoc-date, "99/99/9999")
                                    + " | "  + (if ub.trn-doc.status_ <> {&fact} then string( "(" + CAPS(ub.trn-doc.status_) + ")" ) else "")
                                    ) format "X(100)" skip
        space(79) Line format "X(33)" skip
        space(40) "результатов инвентаризации товарно-материальных ценностей" format "X(130)" skip(2)
        space(52) "Проведена инвентаризация фактического наличия ценностей, находящихся на ответственном хранении" format "X(134)" skip(3)
         UndLine format "X(25)" AT 10 UndLine format "X(90)" at 50 SKIP
        "должность" format "X(25)" AT 10 "фамилия,имя,отчество" format "X(50)"   AT 50 SKIP(1)
        UndLine format "X(25)" AT 10 UndLine format "X(90)" at 50 SKIP
        "должность" format "X(25)" AT 10 "фамилия,имя,отчество" format "X(50)"  AT 50 SKIP(1)
        space(5) "По состоянию на <<       >> _________________        г." format "X(193)" SKIP(2)
        space(5) "При инвентаризации установлено следующее :" SKIP
      .
    /* ... конец создания заголовка. --- */

    PAGE stream Out-Stream.

  end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :
    run rep/wp-qnty.p ( num-ln , output PropisCount).
    if PropisCount = '' Then PropisCount = 'Ноль'.

    if rep-tipe begins "invent"  THEN DO:
      PAGE stream Out-Stream.
      HIDE stream Out-Stream FRAME BottomFrame .
      HIDE stream Out-Stream FRAME BottomFrame2 .

      run rep/wp-qnty.p ( sum1-a-qnty , output PropisQnty).
      if PropisQnty = '' Then PropisQnty = 'Ноль'.
      if NOT PrintRubl then  run rep/wp.p ( input p-mainmenu-handle, sum1-a-stoim, output PropisSumall, output abbr).
      Else                   run rep/wp-rub.p ( sum1-a-stoim , output PropisSumall , output abbr).

      PUT  STREAM Out-Stream
              "Итого по описи :" Skip
                "а) количество порядковых номеров: " + string( num-ln ) + " (" + PropisCount + ")"  format "x(179)"                         at 18 SKIP
                "б) общее количество единиц фактически: " + string( sum1-a-qnty ) + " (" + PropisQnty + ")"  format "x(179)"  at 18 SKIP
                "в) на сумму фактически : " + trim(string((sum1-a-stoim ), "->,>>>,>>>,>>>,>>>,>>>,>>9.99")) + abbr +
                              " (" + PropisSumall + ")"  format "x(179)"                                                 at 18 SKIP(1)
              "   Все цены, подсчеты итогов по строкам, страницам и в целом по инвентаризационной описи товарно-материальных ценностей проверены." SKIP
              "Председатель комиссии: " format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              " " format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              "Члены комиссии: " format "X(25)" AT 10 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              "   Все товарно-материальные ценности, поименованные  в  настоящей  инвентаризационной  описи  с № ___________ по № _________" SKIP
              "комиссией проверены в натуре в моем (нашем) личном присутствии  и внесены в опись, в связи с чем претензий к инвентаризационной " SKIP
              "комиссии не имею (не имеем). Товарно-материальные ценности, перечисленные в описи, находятся на моем (нашем) ответственном хранении." SKIP(1)
              "   Лицо(а), ответственное(ые) за сохранность товарно-материальных ценностей : " SKIP(1)
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP(1)
              "<<       >> _________________        г. "   SKIP(1)
              "Указанные в настоящей описи данные и расчеты проверил"
                  LineBuf format "X(25)" AT 10 LineBuf format "X(25)"   AT 40 LineBuf format "X(50)"               AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              "<<       >> _________________        г. "
      .
    End.
    ELSE DO:
      if NOT PrintRubl then run rep/wp.p ( input p-mainmenu-handle, (sum1-a-stoim - sum1-b-stoim), output PropisSumall, output abbr).
      else                  run rep/wp-rub.p ( ( sum1-a-stoim - sum1-b-stoim ), output PropisSumall, output abbr).
      run rep/wp-qnty.p ( (sum1-a-qnty - sum1-b-qnty), output PropisQnty).
      if PropisQnty  = '' Then PropisQnty = 'Ноль'.
      PUT  STREAM Out-Stream
           "Итого по ведомости :" Skip
           "а) количество порядковых номеров: " + string(num-ln) + " (" + PropisCount + ")"  format "x(179)"                         at 18 SKIP
           "б) общее количество единиц (излишки - недостача): " + string( sum1-a-qnty - sum1-b-qnty ) + " (" + PropisQnty + ")"  format "x(179)"  at 18 SKIP
           "в) на сумму (излишки - недостача) : " + trim(string((sum1-a-stoim - sum1-b-stoim ), "->,>>>,>>>,>>>,>>>,>>>,>>9.99")) + abbr + " (" + PropisSumall + ")"  format "x(179)"    at 18 SKIP(1)
           "С результатами сличения ознакомлен : "  Skip "        Бухгалтер" LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
           "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP(1) "Материально ответственное(ые)  лицо(а)"  Skip
           LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
           "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
           LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
           "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP(1)
      .
    End.
    /* ... конец создания Подвал. --- */
  end.
end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( Out-Stream ) then return .
  if line-counter( Out-Stream ) + p-line-number > page-size( Out-Stream ) then  page stream Out-Stream .
end procedure. /* on-same-page */



procedure Check-Doc-Sum :
  do  on error undo, return error return-value  :
    define variable v-attr-value as character no-undo .
    define variable v-attr-type as character no-undo .
    define variable ask as logical   no-undo .
    { str/tdat-val.i ub.trn-doc.doc-code {&trdcattr-addsum} v-attr-value v-attr-type }
    if ub.trn-doc.status_ = {&fact} then do:
      case rep-tipe:
        when "invent" then do: /* это инвентариз. опись */
          if lookup( {&sum-before-doc}, v-attr-value ) = 0 or
             lookup( {&sum-after-doc}, v-attr-value ) = 0  then run utl/uaddsum.p (ub.trn-doc.doc-code, no, ?, ?) no-error  .
          if error-status :error then  message return-value error-status :GET-MESSAGE( 1 )  view-as alert-box error .
        end.
        when  "sl"  or when  "sl-gold" THEN DO:
          if lookup( {&sum-general-doc}, v-attr-value ) = 0 or
             lookup( {&sum-wastage-doc}, v-attr-value ) = 0  then run utl/uaddsum.p (ub.trn-doc.doc-code, no, ?, ?) no-error .
          if error-status :error then  message return-value error-status :GET-MESSAGE( 1 )  view-as alert-box error .
        End.
      End.
    end.
    else
      case rep-tipe:
        when "invent" then do: /* это инвентариз. опись */
          if lookup( {&sum-before-doc}, v-attr-value ) = 0 then do:
            message "Не рассчитаны данные до начала инвентаризации!" view-as alert-box.
            undo, return error .
          end.
          if lookup( {&sum-after-doc}, v-attr-value ) = 0  then do:
            if p-no-vat = "yes" then do:
              message "Не рассчитаны данные после инвентаризации!" view-as alert-box.
              undo, return error .
            end.
            else assign is-after = no .
          end.
        End.
        when  "sl"  THEN DO:
          if lookup( {&sum-wastage-doc}, v-attr-value ) = 0  then do:
            message "Не рассчитаны нормы естественной убыли! Напечатать документ без их учета?" view-as alert-box QUESTION BUTTONS YES-NO UPDATE ask.
            if ask then assign is-wastage = no .
            else undo, return error .
          end.
        End.
      End.

  end.
end procedure. /* Check-Doc-Sum */



procedure ubl :
 do
 on error undo, return error return-value
 :
        if is-wastage then do:
          find first buf_doc-line-sum no-lock
            where buf_doc-line-sum.doc-code = buf_doc-line.doc-code
              and buf_doc-line-sum.gds-code = buf_goods.gds-code
              and buf_doc-line-sum.sum-type = {&sum-wastage-doc}
          no-error .
          if available  buf_doc-line-sum then do:
                          if PrintRubl then assign temp-str.ubl = buf_doc-line-sum.cost-sum-rubl .
                                       else assign temp-str.ubl = buf_doc-line-sum.cost-sum-base .
            if sum < temp-str.ubl then assign temp-str.ubl = sum .
          end.
        end.


 end. /* do */
end procedure. /* ubl */