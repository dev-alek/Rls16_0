block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inv-8l.p $
$Archive: rep/inv-8l.p $

Акт инвентаризации по форме ИНВ-8

Автор: Белоусов Илья Александрович
Дата создания:
Author: Ilia Belousov
Creation date:

*/

define input parameter parParentProc      AS WIDGET-HANDLE NO-UNDO.
define input parameter rec_id   as recid.

/*  define input parameter print-graft    as logical          no-undo. сжатая */

define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: inv-8l.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/inv-8l.p $":U .
define variable vss-description as character no-undo initial "Акт инвентаризации по форме ИНВ-8".

define variable g#report-num as integer   no-undo .
define variable g#quest-print as logical   no-undo .
define variable g#log as logical   no-undo .

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
  { rep/inv8xl.i       }
  { gbl/getsect.i  def }
&glob format-inv-gold "X(183)"
/*&Scop Sort-pole temp-str.artic*/

DEFINE temp-table temp-str no-undo
  field   gds-name         as character
  field   artic            as character
  field   prod-type        as character
  field   prod-code        as integer
  field   b-code           as character
  field   EI               as character
  field   WeightItemLigat  as decimal
  field   WeightItemClear  as decimal
  /* before */
  field   qntyBuh          as decimal
  /*
  field   b-weightItem     as decimal
  field   b-weight         as decimal
  */
  /* after */
  field   qntyFact         as decimal
  /*
  field   a-weightItem     as decimal
  field   a-weight         as decimal
  */

  INDEX pi  IS PRIMARY UNIQUE
               artic
               prod-type
               prod-code
.

define stream Out-Stream.

define buffer buf_clients      for clients .
define buffer This_Object      for clients .
define buffer buf_doc-line     for doc-line .
define buffer buf_goods        for goods .
define buffer buf_doc-line-sum for doc-line-sum .
define buffer buf_gds-dtl      for gds-dtl .
define buffer buf_gds-prt      for gds-prt .
define buffer bf_doc-attr      for doc-attr .
define buffer buf_prod-bc      for prod-bc .


define variable sum1-qntyFact   as decimal initial 0     no-undo .
define variable sum1-qntyBuh    as decimal initial 0     no-undo .
define variable sum1-weightFact-l as decimal initial 0     no-undo .
define variable sum1-weightBuh-l  as decimal initial 0     no-undo .
define variable sum1-weightFact-c as decimal initial 0     no-undo .
define variable sum1-weightBuh-c  as decimal initial 0     no-undo .
define variable weightitem      as decimal initial 0     no-undo .
define variable PgQnty          as decimal               no-undo .
define variable PgWeight-l        as decimal               no-undo .
define variable PgWeight-c        as decimal               no-undo .
define variable PgQntyBuh       as decimal               no-undo .
define variable PgWeightBuh-l     as decimal               no-undo .
define variable PgWeightBuh-c     as decimal               no-undo .

define variable PgNPP           as integer               no-undo .
define variable v-b-code        as integer               no-undo .
define variable num-ln          as integer               no-undo .
/* !!! */ define variable i as integer no-undo.
/* !!! */ define variable j as integer no-undo.
define variable Counter1        as integer initial 0     no-undo .
define variable Lines_Counter   as integer initial 0     no-undo .
define variable Tmp_Counter     as integer initial 0     no-undo .

define variable Line            as character             no-undo .
define variable LineBuf         as character             no-undo .
define variable UndLine         as character             no-undo .
define variable PropisQnty      as character             no-undo .
define variable PropisSumall-l  as character             no-undo .
define variable PropisSumall-c  as character             no-undo .
define variable Propiscount     as character             no-undo .
define variable sym1            as character initial ":" no-undo .
define variable sym2            as character initial ":" no-undo .
define variable sym3            as character initial ":" no-undo .
define variable sym4            as character initial ":" no-undo .
define variable sym5            as character initial ":" no-undo .
define variable sym6            as character initial ":" no-undo .
define variable sym7            as character initial ":" no-undo .
define variable sym8            as character initial ":" no-undo .
define variable sym9            as character initial ":" no-undo .
define variable sym10           as character initial ":" no-undo .
define variable sym11           as character initial ":" no-undo .
define variable sym12           as character initial ":" no-undo .
define variable v-prn0          as character             no-undo .
define variable v-par-type      as character             no-undo .
define variable tdoc-date       like trn-doc.doc-date    no-undo .
define variable tdoc-code       like trn-doc.doc-code    no-undo .



DEFINE FRAME invent-gold
      sym1                 column-label ":!:!:!:!:"                           format "X(1)"  space(0)
      num-ln               column-label "N!по!поряк!ку!":C5                   format ">>>>9" space(0)

      sym3                 column-label ":!:!:!:!:"                           format "X(1)" space(0)
      temp-str.gds-name    column-label " Драгоченные металлы и изделия из них !----------------------------------------! ! Наименование ! ":C40           format "X(40)" space(0)

      sym2                 column-label " !-!:!:!:"                           format "X(1)" space(0)
      temp-str.artic       column-label " !-----------------! ! код ! ":C17                     format "X(17)" space(0)

      Sym4                 column-label " !-!:!:!:"                           format "X(1)" space(0)
      temp-str.b-code      column-label " !-------------! ! бар-код ! ":C13                  format "X(13)" space(0)

      sym5                 column-label ":!:!:!:!:"                           format "X(1)" space(0)
      temp-str.EI          column-label "Проба!или!процент!драг.!металла":C8  format "x(8)" space(0)

      sym6                 column-label ":!:!:!:!:"                           format "X(1)" space(0)
      temp-str.qntyFact    column-label "Фактическое !--------------! !Количество! ":C14 format "->>>>>>>9.<<<" space(0)

      sym7                 column-label " !-!:!:!:"                           format "X(1)" space(0)
      sum1-weightfact-l    column-label " наличие!---------------! Масса !---------------!Лигатурная":C15   format "->>>,>>>,>>9.99" space(0)

      sym8                 column-label " !-! !-!:"                           format "X(1)" space(0)
      sum1-weightfact-c    column-label "!---------------! !---------------! чистая ":C15   format "->>>,>>>,>>9.99" space(0)

      sym9                 column-label ":!:!:!:!:"                           format "X(1)" space(0)
      temp-str.qntyBuh     column-label " Числится !--------------! ! Количество ! ":C14 format "->>>>>>>9.<<<" space(0)

      sym10                column-label " !-!:!:!:"                           format "X(1)" space(0)
      sum1-weightbuh-l     column-label " по данным !---------------! Масса !---------------!лигатурная":C15   format "->>>,>>>,>>9.99" space(0)

      sym11                column-label " !-! !-!:"                           format "X(1)" space(0)
      sum1-weightbuh-c     column-label " учета !---------------! !---------------! чистая ":C15   format "->>>,>>>,>>9.99" space(0)

      sym12                column-label ":!:!:!:!:"                           format "X(1)" space(0)

     HEADER
/*      cur-time-print() AT 5 format "X(35)"*/
/*      string( "Инвентаризационная опись N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"*/
/*      string( "Лист " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") ) AT 180 format "X(13)" SKIP*/
      Line format {&format-inv-gold} AT 1
      with width {&DOS_CW_2} down stream-io use-text NO-BOX.

/* число прописью */
FUNCTION f-wp-qnty returns character ( INPUT p-dec as decimal ) :
  define variable pr as character no-undo .

  run rep/wp-qnty.p ( input p-dec, output Pr ).
  if Pr = '' then do:
     Pr = 'Ноль'.
  end.
  RETURN ( Pr ) .
END FUNCTION. /* f-wp-qnty */


/* main block */
do on error undo, return error
   :

   run get-report-num  in parParentProc ( output g#report-num ).

   run get-quest-print in parParentProc ( output g#quest-print ).

   FIND trn-doc WHERE recid(trn-doc) = rec_id NO-LOCK .
   assign
     tdoc-date = (if trn-doc.status_ <> {&fact} then trn-doc.doc-date else trn-doc.fact-date)
     tdoc-code = trn-doc.doc-code
   .

  { gbl/getsect.i run "''" 0 {&attr-prt-glob} }
  for each thbjattr_thbj-attr :
      if thbjattr_thbj-attr.prop-code = 'invprn0'  then v-prn0      = string( thbjattr_thbj-attr.property-value-logical) .
  end.


   if session:set-wait-state("compiler") then.

   { cmp/open-out.i STREAM Out-Stream " " {&LS_PS_A4}  }

   run inv8xl-init in this-procedure .

   assign
     UndLine = fill("_", 230)
     Line    = fill("-", 230)
     LineBuf = fill("_", 240)
   .

   FIND This_Object  WHERE This_Object.obj-type = trn-doc.obj-type AND This_Object.obj-code = trn-doc.obj-code  NO-LOCK.
   FIND clients      WHERE clients.obj-type     = {&cmp}           AND clients.obj-code     = trn-doc.host-code NO-LOCK.

   /* Шапка */
   run PrintTitul in this-procedure .

   /*на каждой странице */
   FORM with frame invent-gold .
   /*
   FORM HEADER
     UndLine format {&format-inv-gold} AT 1
     String("Итого:"
            + sym1
            + String(PgQnty ,     "->>>>>>>>>9.<<<"    )
            + sym2
            + String(PgWeight ,   "->>>>>>>>>>9.99"    )
            + sym3
            + "              "
            + sym4
            + String(PgQntyBuh,   "->>>>>>>>9.<<<"     )
            + sym4
            + String(PgWeightBuh, "->>>>>>>>>>>>>9.99" )
            + sym5)  at 100 Format "x(98)"
            skip
     "Итого по странице : " skip
     "а) количество порядковых номеров "      + f-wp-qnty (decimal(PgNPP))    AT 18 SKIP
     "б) общее количество единиц фактически " + f-wp-qnty (decimal(PgQnty))   AT 18 SKIP
     "в) масса драгоценных металлов фактически: "                             AT 18 SKIP
     "лигатурная "                            + f-wp-qnty (decimal(PgWeight)) AT 25 SKIP
     "чистая "                                                                AT 25 SKIP
   with FRAME BottomFrame2 width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
   VIEW stream Out-Stream FRAME BottomFrame2 .
   */

   /* по строкам документа */
   { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
   { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

   /* сначала заполняем таблицу */
   { rep/inv8l.i }

   /* тело */
   for each temp-str no-lock
                     /*break by {&Sort-pole}*/
                     :
       run print-line in this-procedure .
   end.
   display stream Out-Stream
         Line format {&format-inv-gold} AT 1 skip
         String("Итого"
                + sym6
                + String(PgQnty ,     "->>>>>>>>9.999"    )
                + sym7
                + String(PgWeight-l ,   "->>>>>>>>>9.999"    )
                + sym8
                + String(PgWeight-c ,   "->>>>>>>>>9.999"    )
                + sym9
                + String(PgQntyBuh,   "->>>>>>>>9.999"     )
                + sym10
                + String(PgWeightBuh-l, "->>>>>>>>>9.999" )
                + sym11
                + String(PgWeightBuh-c, "->>>>>>>>>9.999" )
                + sym12)  at 84 Format "x(100)"
                skip
         String("Всего по акту"
                + sym6
                + String(sum1-qntyFact ,     "->>>>>>>>9.999"    )
                + sym7
                + String(sum1-weightFact-l ,   "->>>>>>>>>9.999"    )
                + sym8
                + String(sum1-weightFact-c ,   "->>>>>>>>>9.999"    )
                + sym9
                + String(sum1-qntyBuh ,   "->>>>>>>>9.999"     )
                + sym10
                + String(sum1-weightBuh-l , "->>>>>>>>>9.999" )
                + sym11
                + String(sum1-weightBuh-c , "->>>>>>>>>9.999" )
                + sym12)  at 76 Format "x(108)"
                skip
         UndLine format {&format-inv-gold} AT 1 skip
         "Итого по странице : " skip
         "а) количество порядковых номеров "           AT 18 "(" STRING(PgNPP)    ")" f-wp-qnty (decimal(PgNPP)) FORMAT "x(90)"   SKIP
         "б) общее количество единиц фактически "      AT 18 "(" STRING(PgQnty)   ")" f-wp-qnty (decimal(PgQnty)) FORMAT "x(90)"   SKIP
         "в) масса драгоценных металлов фактически: "  AT 18                               SKIP
         "лигатурная "                                 AT 25 "(" STRING(PgWeight-l) ")" f-wp-qnty (decimal(PgWeight-l)) FORMAT "x(90)"  SKIP
         "чистая "                                     AT 25 "(" STRING(PgWeight-c) ")" f-wp-qnty (decimal(PgWeight-c)) FORMAT "x(90)"  SKIP
   with FRAME PageFrame2 width {&DOS_CW_2} NO-LABELS NO-BOX .
   DOWN stream Out-Stream 1 with FRAME PageFrame.
   page stream out-stream.


   /* total text
   run print-all-itog in this-procedure .
   */

   /* Подвал */
   run on-same-page in this-procedure (input 14) .

   run PrintPodval in this-procedure .

   output stream Out-Stream CLOSE .
   { rep/repfrm.i off } /* Показать окно информации о текущем процессе */
   run inv8xl-close in this-procedure .

   { rep/q-print.i 8}

end. /* main block */

/* *************************************************************************************************** */



procedure print-line :
  do on error undo, return error return-value :
     { rep/inv81l.i invent-gold }
  end.
end procedure. /* print-line */

/* !!! Итоговые суммы TEXT
procedure print-all-itog :
  do on error undo, return error return-value :
        display stream Out-Stream
          "ИТОГО"         @ temp-str.EI
          sym6 sym7 sym8 sym9 sym10 sym11 sym12
          sum1-qntyFact   @ temp-str.qntyFact
          sum1-weightFact
          sum1-qntyBuh    @ temp-str.qntyBuh
          sum1-weightBuh
        with FRAME invent-gold.
        DOWN stream Out-Stream 1 with FRAME invent-gold .
        Put stream Out-Stream LineBuf format {&format-inv-gold} SKIP.
  end.
end procedure. print-all-itog */


procedure PrintTitul :

define variable v-organization  as character    no-undo.
define variable v-object        as character    no-undo.
do on error undo, return error return-value  :
   /* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
   { rep/r-cliprp.i }
   assign
       v-organization = string( "{&abbr_inn_allshift} " + t-inn + " " + CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")"
                             + t-addres + t-phone)
       v-object       = string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" )
   .

   /* Excel */
   run inv8xl-write-cell-data in this-procedure (
       input {&inv8xl-h_organization}
       , input v-organization
   ).
   run inv8xl-write-cell-data in this-procedure (
       input {&inv8xl-h_object}
       , input v-object
   ).
   run inv8xl-write-cell-data in this-procedure (
       input {&inv8xl-h_docCode}
       , input tdoc-code
   ).
   run inv8xl-write-cell-data in this-procedure (
       input {&inv8xl-h_docDate}
       , input string( tdoc-date, "99/99/9999")
   ).

   /* !!! Text */
   PUT STREAM Out-Stream
       "Унифицированная форма N ИНВ-8"             AT 138 skip
       "Утверждена постановлением Госкомстата РФ"  AT 138 skip
       "от 18 августа 1998 г. N 88"                AT 138 skip
       "+----------------+"                        AT 166 skip
       "|      Код       |"                        AT 166 skip
       "+----------------+"                        AT 166 skip
       "Форма по ОКУД|     0317008    |"           AT 153 skip
       space(5) v-organization format "X(140)" "+----------------+" AT 166 skip
       space(5) Line           format "X(140)" "по ОКПО" format "X(7)" AT 156 "|" AT 166 t-okpo format "X(16)" "|" AT 183 skip
       space(35) "организация" format "X(120)" "+----------------+" AT 166 skip

       space(5) v-object format "X(120)" "| " AT 166  "|" AT 183 skip
       space(5) Line format  "X(120)"  "+----------------+" AT 166 skip
       space(35) "структурное подразделение" format "x(85)" "Вид деятельности" AT 150 "| " AT 166 "|" AT 183 skip
       "+--------+----------------+"                         AT 157 skip
       "Основание для     приказ, постановление, распоряжение    |  номер |                |" AT 100 skip
       "проведения        -----------------------------------    +--------+----------------+" AT 100 skip
       "инвентаризации:           ненужное зачеркнуть            |  дата  |                |" AT 100 skip
       "+--------+----------------+"         AT 157 skip
       "Вид операции| инвентаризация |"      AT 154 skip
       "+----------------+"                  AT 166 skip
                         "+----------------+----------------+" AT 132 skip
       space(54) " АКТ " "| Номер документа|Дата составления|" AT 132 skip
       space(34) "инвентаризации драгоценных металлов и изделий из них"  "+----------------+----------------+" AT 132 skip
       "|" AT 132 STRING(tdoc-code,"X(14)")  AT 134 "|   " AT 149 STRING(tdoc-date, "99/99/9999") AT 153 "   |" AT 163 skip
       space(54) "РАСПИСКА" format "X(8)" "+----------------+----------------+" AT 132 skip
       space(15) "К началу проведения инвентаризации все расходные и  приходные  документы на драгоценные металлы и изделия из них сданы в бухгалтерию, и все " SKIP
       space(10) "драгоценные металлы и изделия из них, поступившие на мою (нашу)  ответственность, оприходованы, а выбывшие списаны в расход." SKIP(1)
       space(15) "Материально ответственное (ые) лицо (а): " format "X(41)" skip(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       space(15) "Акт составлен  комиссией  о  том,   что   проведена   инвентаризаци драгоценных металлов и изделий из них по состоянию на <<       >> _________________        г." SKIP(1)
       space(15) "При инвентаризации установлено следующее:" SKIP
   .
   PAGE stream Out-Stream.
   PUT STREAM Out-Stream
   "+------------+--------------+-------------+"  AT 141 skip
   ":            :      Единица измерения     :"  AT 141 skip
   "+            +--------------+-------------+"  AT 141 skip
   ":            : наименование : код по ОКЕИ :"  AT 141 skip
   "+------------+--------------+-------------+"  AT 141 skip
   ": количество :              :             :"  AT 141 skip
   "+------------+--------------+-------------+"  AT 141 skip
   ":   масса    :    грамм     :     163     :"  AT 141 skip
   "+------------+--------------+-------------+"  AT 141 skip
   .
end.
end procedure. /* PrintTitul */


procedure PrintPodval :
do on error undo, return error return-value  :
   run rep/wp-qnty.p ( num-ln , output PropisCount).
   if PropisCount = '' Then PropisCount = 'Ноль'.

   PAGE stream Out-Stream.
   HIDE stream Out-Stream FRAME BottomFrame .
   HIDE stream Out-Stream FRAME BottomFrame2 .

   run rep/wp-qnty.p ( sum1-qntyFact , output PropisQnty).
   if PropisQnty = ''
   Then PropisQnty = 'Ноль'.

   run rep/wp-qnty.p ( sum1-weightFact-l, output PropisSumall-l).
   if PropisQnty = ''
   Then PropisQnty = 'Ноль'.

   run rep/wp-qnty.p ( sum1-weightFact-c, output PropisSumall-c).
   if PropisQnty = ''
   Then PropisQnty = 'Ноль'.

   /* Excel */
   run inv8xl-write-cell-data in this-procedure (
         input {&inv8xl-it_s_Num}
       , input PropisCount
   ).
   run inv8xl-write-cell-data in this-procedure (
         input {&inv8xl-it_s_QntyFact}
       , input PropisQnty
   ).
   run inv8xl-write-cell-data in this-procedure (
         input {&inv8xl-it_s_WeightFact}
       , input PropisSumall-l
   ).
   run inv8xl-write-cell-data in this-procedure (
         input {&inv8xl-it_qntyFact}
       , input string( sum1-qntyFact )
   ).
   run inv8xl-write-cell-data in this-procedure (
         input {&inv8xl-it_WeightFact}
       , input string( sum1-weightFact-l )
   ).
   run inv8xl-write-cell-data in this-procedure (
         input {&inv8xl-it_qntyBuh}
       , input string( sum1-qntyBuh )
   ).
   run inv8xl-write-cell-data in this-procedure (
         input {&inv8xl-it_WeightBuh}
       , input string( sum1-weightBuh-l )
   ).
   /* !!! TEXT */
   PAGE STREAM Out-Stream.
   PUT STREAM Out-Stream
       "Итого по акту:" Skip
         "а) количество порядковых номеров: " + string( num-ln ) + " (" + PropisCount + ")"  format "x(179)"                         at 18 SKIP
         "б) общее количество единиц фактически: " + string( sum1-qntyFact ) + " (" + PropisQnty + ")"  format "x(179)"  at 18 SKIP
         "в) масса драгоценных металлов фактически: "  AT 18                               SKIP
         "лигатурная "                                 AT 25 "(" STRING(sum1-weightFact-l) ")" f-wp-qnty (decimal(sum1-weightFact-l)) FORMAT "x(90)"  SKIP
         "чистая "                                     AT 25 "(" STRING(sum1-weightFact-c) ")" f-wp-qnty (decimal(sum1-weightFact-c)) FORMAT "x(90)"  SKIP
       space(15) "Все подсчеты итогов по строкам, страницам и в целом по акту инвентаризации проверены." SKIP
       space(15) "Председатель комиссии: " SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       space(15) "Члены комиссии: " format "X(25)" SKIP
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       space(15) "Все  ценности,  поименованные  в настоящем инвентаризационном акте с N ________ по N ___________,  комиссией проверены в натуре в моем (нашем)" SKIP
       space(10) "присутствии и внесены в акт, в связи с чем претензий к инвентаризационной комиссии не имею (не имеем). Ценности, перечисленные в акте, находя-" SKIP
       space(10) "тся на моем (нашем) ответственном хранении." SKIP
       space(15) "Материально ответственное (ые) лицо (а): "  SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       space(15) "<<       >> _________________        г. "   SKIP
       space(15) "Указанные в настоящем акте данные и расчеты проверил" SKIP(1)
       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
       "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
       space(15) "<<       >> _________________        г. "
   .
end.
end procedure. /* PrintPodval */



PROCEDURE on-same-page :
  define input parameter p-line-number as integer  no-undo .
  if p-line-number > page-size( Out-Stream ) then return .
  if line-counter( Out-Stream ) + p-line-number > page-size( Out-Stream ) then  page stream Out-Stream .
end procedure. /* on-same-page */