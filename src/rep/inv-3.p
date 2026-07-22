block-level on error undo, throw.
/*

$Revision: ea50b6f7ec06, 1082, rls $
$Author: EShklyar $
$Date: Thu Oct 12 16:33:09 2017 +0300 $
$Workfile: inv-3.p $
$Archive: rep/inv-3.p $

Инвентаризационная опись и сличительная ведомость

Автор: Кочетков Михаил Юрьевич
Дата создания: 03/27/06
Author: Michael Kochetkov
Creation date: 03/27/06

*/

do
on error undo, return error
:
  define input parameter parParentProc      AS WIDGET-HANDLE NO-UNDO.
  define input parameter rec_id             as recid.
  define input parameter rep-tipe           as character no-undo.
  define input parameter p-grp              as character no-undo. /* используется для печати только сумм по группам */
  define input parameter print-graft        as logical          no-undo.

  define variable vss-revision    as character no-undo initial "$Revision: ea50b6f7ec06, 1082, rls $":U .
  define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
  define variable vss-date        as character no-undo initial "$Date: Thu Oct 12 16:33:09 2017 +0300 $":U .
  define variable vss-workfile    as character no-undo initial "$Workfile: inv-3.p $":U .
  define variable vss-archive     as character no-undo initial "$Archive: rep/inv-3.p $":U .
  define variable vss-description as character no-undo initial "Формы по инвентаризации ".

  define variable g#report-num as integer   no-undo .
  run get-report-num  in parParentProc ( output g#report-num ).

  { cmp/vssrevis.i     }
  { cmp/str-glbl.i     }
  { cmp/library.i      }
  { gbl/cur-time.i     }
  { cmp/r-pril.i       }
  { cmp/r-page1.i new  }
  { cmp/breakstr.i     }
  { rep/r-cliprp.i def }
  { str/trdcalib.i     }
  { rep/fmtcli.i       }
  { rep/torgconf.i     }
  { gbl/paramls.i      }
  { str/lib-trn.i      }
  { str/valddnst.i def }
  { ref/grplibfn.i     }
  define variable g#gds-engl as logical   no-undo .
  run get-gds-engl  in parParentProc ( output g#gds-engl ).

  define variable g#log as logical   no-undo .

  define variable g#quest-print as logical   no-undo .
  run get-quest-print in parParentProc ( output g#quest-print ).

  &glob format-inv      "X(185)"
  &glob format-sl       "X(162)"
  &glob format-sl-gold  "X(196)"
  &glob format-inv-gold "X(194)"
  &scop gds-len 40

  define shared variable sort-name   as logical no-undo.
  define shared variable sort-gr     as logical no-undo.
  define shared variable CostPrice   as logical no-undo .
  define shared variable PrintScale  as logical no-undo .
  define shared variable no-vat      as logical no-undo .

  define variable v-sys-key  as character no-undo .
  define variable v-par-type as character no-undo .

  define variable skod as logical   no-undo .

  define variable v-classify      as character  no-undo .
  define variable v-tog-level     as logical    no-undo .
  define variable v-var-level     as integer    no-undo .
  define variable p-ok            as logical    no-undo .
  define variable full-grp-name   as character  no-undo .

  { gbl/currsysk.i
    v-sys-key
    no-error
  }

  define variable v-sort-prod         as character         no-undo.

  if p-grp = "yes" then assign v-sort-prod = "no" .
  else do:
    if p-grp = "prod" then assign v-sort-prod = "yes" .
    else do:
      run gbl/conf-rd.p ("sort-prd", "", "", 0, "", "", "", no, output v-sort-prod, output v-par-type) no-error.
      if error-status :error then assign v-sort-prod = "no" .
    end.
  end.
  .
  if p-grp = "yes":U then do :
   run rep/inv3-grp.w (input parparentproc, output v-classify, output v-tog-level, output v-var-level, output p-ok ) .
   if p-ok ne true then do :
     return no-apply .
   end.
  end.

  if sort-name = no then message "Сортировать по коду? (При ответе 'нет' сортировка по артикулу)."  VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE skod.

  &Scop Sort-pole if sort-name then  temp-str.gds-name Else ( if skod then  temp-str.b-code Else temp-str.artic )

  define variable sort-group as logical   no-undo .

  if sort-gr or p-grp = "yes" then assign sort-group = yes .
  else                             assign sort-group = no .

  DEFINE temp-table temp-str no-undo
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
    field   schet             as character
    INDEX pi  IS PRIMARY   artic prod-type prod-code
    INDEX pi1              gds-name
    INDEX pi2              grp-name
    INDEX pi3              tb-code
  .

  define stream Out-Stream.

  define buffer buf_clients      for ub.clients .
  define buffer This_Object      for ub.clients .
  define buffer buf_doc-line     for ub.doc-line .
  define buffer buf_trn-doc      for ub.trn-doc .
  define buffer buf_goods        for ub.goods .
  define buffer buf_doc-line-sum for ub.doc-line-sum .
  define buffer buf_gds-dtl      for ub.gds-dtl .
  define buffer buf_gds-prt      for ub.gds-prt .
  define buffer bf_doc-attr      for ub.doc-attr .
  define buffer buf_gds-grp      for ub.gds-grp .

  define variable qnty as decimal   no-undo .
  define variable sum  as decimal   no-undo .

  define variable is-after      as logical initial yes no-undo .
  define variable is-after-cli  as logical initial yes no-undo .
  define variable is-wastage    as logical initial yes no-undo .
  define variable is-general    as logical initial yes no-undo .

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
  define variable sum1-ubl     as decimal initial 0  no-undo .
  define variable sum2-a-qnty  as decimal initial 0  no-undo .
  define variable sum2-b-qnty  as decimal initial 0  no-undo .
  define variable sum2-a-qnty1 as decimal initial 0  no-undo .
  define variable sum2-b-qnty1 as decimal initial 0  no-undo .
  define variable sum2-a-stoim as decimal initial 0  no-undo .
  define variable sum2-b-stoim as decimal initial 0  no-undo .
  define variable sum2-ubl     as decimal initial 0  no-undo .

  define variable v-line-price          as decimal      no-undo.
  define variable v-line-price-before   as decimal      no-undo.
  define variable v-line-price-after    as decimal      no-undo.
  define variable p-type                as character    no-undo.
  
  define variable FullNameGds as character no-undo .
  define variable gds-str as character no-undo.
  define variable gds-str1 as character no-undo.
  define variable gds-str2 as character no-undo.
  define variable i as integer no-undo.
  define variable j as integer no-undo.
  define variable Counter1 as integer initial 0  no-undo .

  define variable LineBuf    as character no-undo.
  define variable Line       as character no-undo.
  define variable UndLine    as character no-undo.

  define variable Lines_Counter as   integer  initial 0  no-undo.
  define variable Tmp_Counter   as   integer  initial 0  no-undo.

  define variable tdoc-date     like ub.trn-doc.doc-date no-undo.
  define variable tdoc-code     like ub.trn-doc.doc-code no-undo.

  define variable PgQnty            as  decimal no-undo.
  define variable PgQnty-v          as  decimal no-undo.
  define variable PgSum             as  decimal no-undo.
  define variable PgQnty-b          as  decimal no-undo.
  define variable PgQnty-b-v        as  decimal no-undo.
  define variable PgSum-b           as  decimal no-undo.
  define variable PgNPP             as  integer no-undo.

  define variable UBL-v      as decimal   no-undo .
  define variable b-code     as integer   no-undo .

  define variable PropisQnty        as  character no-undo.
  define variable PropisSumall      as  character no-undo.
  define variable Propiscount       as  character no-undo.
  define variable abbr              as  character no-undo.
  define variable pp                as  character no-undo.


  define variable sym1  as character initial ":"   no-undo.
  define variable sym2  as character initial ":"   no-undo.
  define variable sym3  as character initial ":"   no-undo.
  define variable sym4  as character initial ":"   no-undo.
  define variable sym5  as character initial ":"   no-undo.
  define variable sym6  as character initial ":"   no-undo.
  define variable sym7  as character initial ":"   no-undo.
  define variable sym8  as character initial ":"   no-undo.
  define variable sym9  as character initial ":"   no-undo.
  define variable sym10 as character initial ":"   no-undo.
  define variable sym11 as character initial ":"   no-undo.
  define variable sym12 as character initial ":"   no-undo.
  define variable sym13 as character initial ":"   no-undo.
  define variable sym14 as character initial ":"   no-undo.
  define variable sym15 as character initial ":"   no-undo.
  define variable sym16 as character initial ":"   no-undo.
  define variable sym17 as character initial ":"   no-undo.
  define variable sym18 as character initial ":"   no-undo.

  FUNCTION f-wp-qnty returns character ( INPUT p-dec as decimal ) :
    define variable pr as character no-undo .

    run rep/wp-qnty.p ( input p-dec, output Pr ).
    RETURN ( Pr ) .
  END FUNCTION. /* f-wp-qnty */

  FUNCTION f-wp-sum returns character ( INPUT p-dec as decimal ) :
    define variable pr as character no-undo .

    if PrintRubl = yes then do: run rep/wp-rub.p (                      input p-dec, output pr, output abbr ). end.
                       else do: run rep/wp.p     ( input parParentProc, input p-dec, output Pr, output abbr ). end.
    RETURN ( Pr ).
  END FUNCTION. /* f-wp-sum */

  DEFINE FRAME invent
        sym1 column-label ":!:!:!:!:"  format "X(1)" space(0)
        Lines_Counter COLUMN-LABEL "N!п/п! ! ! ":C7 format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.artic COLUMN-LABEL "Артикул! ! ! ! ":C25 format "X(24)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.gds-name COLUMN-LABEL "Наименование товара! ! ! ! ":C50 format "X(40)" space(0)
        Sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-code COLUMN-LABEL "Код товара! ! ! ! ":C15 format "X(14)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.OKEI COLUMN-LABEL "Ед.!-------!Код    !по!ОКЕИ":C7 format ">>>>" space(0)
        sym6 column-label " !-!:!:!:" format "X(1)" space(0)
        temp-str.unit-base COLUMN-LABEL  "изм.!-------!Наим!енов!ание":C7 format "X(6)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.Price-befor COLUMN-LABEL " ! Цена ! ! ! ":C13 format "->>>>>9.99" space(0)
        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.a-qnty COLUMN-LABEL "Фактическое !наличие!-------------------------!Количество ! ":C25 format "->>>>>>>9.<<<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-qnty COLUMN-LABEL "По данным! бухгалтерского учета!--------------------------!Количество ! ":C26 format "->>>>>9.99" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
       HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Инвентаризационная опись N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp) AT 150 format "X(29)"
        string( "Лист " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") ) AT 180 format "X(13)" SKIP
        UndLine format {&format-inv} AT 1
        with width {&DOS_CW_2} down stream-io use-text NO-BOX.

/*  DEFINE FRAME invent-gold                                                                                                        */
/*        sym1 column-label ":!:!:!:!:"  format "X(1)" space(0)                                                                     */
/*        Lines_Counter COLUMN-LABEL "N!п/п! ! ! ":C5 format ">>>>9" space(0)                                                       */
/*        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)                                                                      */
/*        temp-str.artic COLUMN-LABEL "Артикул! ! ! ! ":C17 format "X(17)" space(0)                                                 */
/*        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)                                                                      */
/*        temp-str.gds-name COLUMN-LABEL "Наименование товара! ! ! ! ":C40 format "X(40)" space(0)                                  */
/*        Sym4 column-label ":!:!:!:!:" format "X(1)" space(0)                                                                      */
/*        temp-str.b-code COLUMN-LABEL "Проба! ! ! ! " format "X(3)" space(0)                                                       */
/*        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)                                                                      */
/*        temp-str.OKEI COLUMN-LABEL "Ед.!----!Код ! по !ОКЕИ" format ">>>>" space(0)                                               */
/*        sym6 column-label         " !-!:!:!:" format "X(1)" space(0)                                                              */
/*        temp-str.unit-base COLUMN-LABEL  "изм.!----!Наим!енов!ание" format "X(4)" space(0)                                        */
/*        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)                                                                      */
/*        temp-str.Price-after COLUMN-LABEL "Фактическая!цена ! ! ! ":C12 format "->>>>>>>9.99" space(0)                            */
/*        sym8 column-label ":!:!:!:!:" format "X(1)" space(0)                                                                      */
/*        temp-str.a-qnty COLUMN-LABEL "Фактическое !--------------!Количество!осн.ед.изм! ":C14 format "->>>>>>>9.<<<" space(0)    */
/*        sym14 column-label            " !-!:!:!:" format "X(1)" space(0)                                                          */
/*        temp-str.a-qnty1 COLUMN-LABEL             "наличие   !-----------!Количество ! ! ":C11 format "->>>>>>>9.<<<" space(0)    */
/*        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)                                                                      */
/*        temp-str.a-stoim COLUMN-LABEL "Фактическое!наличие!Сумма! ! ":C15 format "->>>,>>>,>>9.99" space(0)                       */
/*        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)                                                                     */
/*        temp-str.Price-befor COLUMN-LABEL "До инв-ции!цена! ! ! ":C11 format "->>>>>>9.99" space(0)                               */
/*        sym11 column-label ":!:!:!:!:" format "X(1)" space(0)                                                                     */
/*        temp-str.b-qnty COLUMN-LABEL "     До инвент!--------------! Количество !осн.ед.изм! ":C14 format "->>>>>>>9.<<<" space(0)*/
/*        sym15 column-label           "а!-!:!:!:" format "X(1)" space(0)                                                           */
/*        temp-str.b-qnty1 COLUMN-LABEL            "ризации     !------------! Количество ! ! ":C12 format "->>>>>>>9.<<<" space(0) */
/*        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)                                                                     */
/*        temp-str.b-stoim COLUMN-LABEL "До инв-ции!Сумма! ! ! ":C14 format "->>>,>>>,>>9.99" space(0)                              */
/*        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)                                                                     */
/*       HEADER                                                                                                                     */
/*        cur-time-print() AT 5 format "X(35)"                                                                                      */
/*        string( "Инвентаризационная опись N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)" */
/*        string( pp) AT 150 format "X(29)"                                                                                         */
/*        string( "Лист " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") ) AT 180 format "X(13)" SKIP                              */
/*        UndLine format {&format-inv-gold} AT 1                                                                                    */
/*        with width {&DOS_CW_2} down stream-io use-text NO-BOX.                                                                    */
/*                                                                                                                                  */
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
        string( pp ) AT 130 format "X(29)"
        string( "Лист " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") ) AT 160 format "X(13)" SKIP
        UndLine format {&format-sl} AT 1
        with width {&DOS_CW_2} down stream-io use-text NO-BOX.

DEFINE FRAME sl-gold
        sym1 column-label ":!:!:!:!:"  format "X(1)" space(0)
        Lines_Counter COLUMN-LABEL "N!п/п! ! ! ":C5 format ">>>>9" space(0)
        sym2 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.artic COLUMN-LABEL "Артикул! ! ! ! ":C17 format "X(17)" space(0)
        sym3 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.gds-name COLUMN-LABEL "Наименование товара! ! ! ! ":C40 format "X(40)" space(0)
        Sym4 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-code COLUMN-LABEL "Проба! ! ! ! " format "X(3)" space(0)
        sym5 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.OKEI COLUMN-LABEL "Ед.!----!Код ! по !ОКЕИ" format ">>>>" space(0)
        sym6 column-label         " !-!:!:!:" format "X(1)" space(0)
        temp-str.unit-base COLUMN-LABEL  "изм.!----!Наим!енов!ание" format "X(4)" space(0)
        sym7 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.a-qnty COLUMN-LABEL "Изл!-------------!Количество !осн.ед.изм ! " format "->>>>>>>9.<<<" space(0)
        sym8 column-label "и!-!:!:!:" format "X(1)" space(0)
        temp-str.a-qnty1 COLUMN-LABEL "шек          !-------------!Количество ! ! " format "->>>>>>>9.<<<" space(0)
        sym9 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.a-stoim COLUMN-LABEL "Излишек!Сумма! ! ! ":C16 format "->>>,>>>,>>9.99" space(0)
        sym10 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-qnty COLUMN-LABEL "         Недос!--------------!Количество!осн.ед.изм! ":C14 format "->>>>>>>9.<<<" space(0)
        sym11 column-label "т!-!:!:!:" format "X(1)" space(0)
        temp-str.b-qnty1 COLUMN-LABEL "ача         !------------!Количество! ! ":C12 format "->>>>>>>9.<<<" space(0)
        sym12 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.b-stoim COLUMN-LABEL "Недостача!Сумма! ! ! ":C15 format "->>>,>>>,>>9.99" space(0)
        sym14 column-label ":!:!:!:!:" format "X(1)" space(0)
        temp-str.UBL COLUMN-LABEL   "Списано   !норм ес! !------------!осн.ед.изм":R12 format "->>>>>>>>>.<<" space(0)
        sym15 column-label         "в!т! !-!:" format "X(1)" space(0)
        UBL-v COLUMN-LABEL "   пределах!ественной!убыли!------------! ":L12 format "->>>>>>>>>.<<" space(0)
        sym13 column-label ":!:!:!:!:" format "X(1)" space(0)
       HEADER
        cur-time-print() AT 5 format "X(35)"
        string( "Сличительная ведомость N " + tdoc-code + "  от  " + string ( tdoc-date , "99/99/9999" ) ) AT 47 format "X(63)"
        string( pp ) AT 130 format "X(29)"
        string( "Лист " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") ) AT 160 format "X(13)" SKIP
        UndLine format {&format-sl-gold} AT 1
        with width {&DOS_CW_2} down stream-io use-text NO-BOX.

  FIND buf_trn-doc WHERE recid(buf_trn-doc) = rec_id NO-LOCK .
  assign
    tdoc-date = (if buf_trn-doc.status_ <> {&fact} then buf_trn-doc.doc-date else buf_trn-doc.fact-date)
    tdoc-code = buf_trn-doc.doc-code
  .

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

  run torgconf-get-self-param in this-procedure (
        input buf_trn-doc.obj-type
      , input buf_trn-doc.obj-code
      , input v-curr-code
  ) no-error.
  if error-status :error
  then do:
      message
      vss-workfile vss-revision vss-description
      skip "Ошибка чтения параметров объекта документа."
      skip return-value
      skip trim(error-status :get-message(1))
          trim(error-status :get-message(2))
          trim(error-status :get-message(3))
      view-as alert-box warning.
  end.

  run Check-Doc-Sum in this-procedure no-error  .
  if error-status :error then return error .

  if rep-tipe <> "sl" and PrintScale = true THEN DO:
    message "Инвентаризационная опись не проводится с разбиением по признакам !" view-as alert-box . PrintScale = false .
  End.

  { cmp/open-out.i STREAM Out-Stream " " {&LS_PS_A4}  }
  if rep-tipe begins "invent"
  and p-grp = "no"
  then do:
      run inv3xl-init in this-procedure .
  end.
  define variable v-prn0 as character no-undo .
  run gbl/conf-rd.p ("invprn0", "", "", 0, "", "", "", no, output v-prn0, output v-par-type) no-error.
  if error-status:error then v-prn0 = 'yes' .

  assign
    Line    = fill("-", 230)
    UndLine = fill("_", 230)
    LineBuf = fill("_", 240)
  .

  if  CostPrice then DO:
    if no-vat = no then do:
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

  FIND This_Object  WHERE This_Object.obj-type = buf_trn-doc.obj-type AND This_Object.obj-code = buf_trn-doc.obj-code  NO-LOCK.
  FIND clients      WHERE clients.obj-type     = {&cmp}           AND clients.obj-code     = buf_trn-doc.host-code NO-LOCK.

  { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
  { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

  /* сначала заполняем таблицу */
  { rep/inv3.i }

  run PrintTitul in this-procedure .

  /*на каждой странице */
  if rep-tipe = "invent" THEN  DO:
    FORM with frame invent .    FORM HEADER
      LineBuf format {&format-inv} SKIP
/*            String(sym1 + String(PgQnty ,  "->>>>>>>>>9.<<<" ) + sym2 + String(PgSum , "->>>>>>>>>>9.99"   ) +  sym6 + "                 " +       */
/*             sym3 + String(PgQnty-b,  "->>>>>>>>>>>>9.<<<" ) + sym4 + String(PgSum-b , "->>>>>>>>>>>>>9.99"   ) + sym5)  at 100 Format "x(90)" skip*/
      
      String("        " + "                " + "              " + String(PgQnty ,  "->>>>>>>>>9.<<<" ) + sym8 + "       "+
             String(PgQnty-b,  "->>>>>>>>>>>>9.<<<" ) + sym5 )  at 100 Format "x(90)" skip
      "Итого по странице : " skip
      "а) количество порядковых номеров " + string(PgNPP) + " (" + f-wp-qnty (decimal(PgNPP)) + ")" format {&format-inv} AT 18  skip
      "б) общее количество единиц фактически " + string(PgQnty) + " (" + f-wp-qnty (decimal(PgQnty)) + ")"  format {&format-inv} AT 18  SKIP
      "Вкладной лист к форме № ИНВ-3 №  " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") format "x(170)" AT 30 SKIP
    with FRAME BottomFrame width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW stream Out-Stream FRAME BottomFrame .
  End.
  if rep-tipe = "invent-gold" THEN DO:
    FORM with frame invent-gold .
    FORM HEADER
      LineBuf format {&format-inv-gold} SKIP
      String(sym1 + String(PgQnty ,  "->>>>>>>>>9.<<<" ) + String(PgQnty-v ,  "->>>>>>>>>9.<<<" ) + sym2 + String(PgSum , "->>>>>>>>>>9.99"   ) +
             sym6 + "           " + sym3 + String(PgQnty-b,   "->>>>>>>>9.<<<" ) + String(PgQnty-b-v, "->>>>>>>>9.<<<" ) +
             sym4 + String(PgSum-b , "->>>>>>>>>>>>>9.99"   ) + sym5)  at 100 Format "x(98)"       skip
      "Итого по странице : " skip
      "а) количество порядковых номеров " + string(PgNPP) + " (" + f-wp-qnty (decimal(PgNPP)) + ")" format {&format-inv-gold} AT 18  skip
      "б) общее количество единиц фактически " + string(PgQnty) + " (" + f-wp-qnty (decimal(PgQnty)) + ")"  format {&format-inv-gold} AT 18  SKIP
      "Вкладной лист к форме № ИНВ-3 №  " + string( PAGE-NUMBER(Out-Stream) - 1, ">>>>9") format "x(170)" AT 30 SKIP
    with FRAME BottomFrame2 width {&DOS_CW_2} PAGE-BOTTOM NO-LABELS NO-BOX .
    VIEW stream Out-Stream FRAME BottomFrame2 .
  end.
  if rep-tipe begins "invent" THEN DO:
    PUT stream Out-Stream SPACE(35) string ("Инвентаризационная опись N " + tdoc-code ) format "x(50)" SKIP
      SPACE(10) string (string (This_Object.obj-type , "X(3)") + ": " + trim(This_Object.obj-name) ) format "x(50)"
      string ("дата инвентаризации : " + string (tdoc-date, "99.99.9999") ) format "x(50)" SKIP.
  End.

  if rep-tipe = "sl" THEN  FORM with frame sl .
  if rep-tipe = "sl-gold" THEN  FORM with frame sl-gold .

  /* по строкам документа-------------------------------------------------------------------------------------------- */

  /* теперь печать с сортировками */
  if v-sort-prod = "yes" then do:
    if sort-group = yes then do:
      for each temp-str no-lock break by temp-str.prod-type by temp-str.prod-code by temp-str.grp-name by {&Sort-pole} :
        if first-of( temp-str.prod-code) then run print-prod in this-procedure .
        if p-grp <> "prod" and first-of( temp-str.grp-name)  then run print-grp in this-procedure .
        run print-line in this-procedure .
        if p-grp <> "prod" and last-of( temp-str.grp-name)   then run print-grp-itog in this-procedure .
        if last-of( temp-str.prod-code)  then run print-prod-itog in this-procedure .
      end.
    end.        /* sort-gr = yes */
    else do:
      for each temp-str no-lock break by temp-str.prod-type by temp-str.prod-code by {&Sort-pole} :
        if p-grp <> "prod" and first-of( temp-str.prod-code) then run print-prod in this-procedure .
        run print-line in this-procedure .
        if last-of( temp-str.prod-code)  then run print-prod-itog in this-procedure .
      end.
    end.        /* sort-gr <> yes */
  end.        /* v-sort-prod = yes */
  else do:
    if sort-group = yes then do:
      for each temp-str no-lock break by temp-str.grp-name by {&Sort-pole} :
        if p-grp = "no" and first-of( temp-str.grp-name) then run print-grp in this-procedure .
        run print-line in this-procedure .
        if last-of( temp-str.grp-name) then  run print-grp-itog in this-procedure .
      end.
    end.        /* sort-gr = yes */
    else do:
      for each temp-str no-lock break by {&Sort-pole} :
        run print-line in this-procedure .
      end.
    end.        /* sort-gr <> yes */
  end.        /* v-sort-prod <> yes */

  run print-all-itog in this-procedure .

  /* ... Подвал. --- */
  run on-same-page in this-procedure (input 14) .

  run PrintPodval in this-procedure .

  output stream Out-Stream CLOSE .
  { rep/repfrm.i off } /* Показать окно информации о текущем процессе */

    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-close in this-procedure .
    end.
  { rep/q-print.i 8}
end.

/* *************************************************************************************************** */

procedure print-grp :
  do  on error undo, return error return-value  :
    case rep-tipe :
      when "invent" THEN DO:
        DOWN stream Out-Stream 1 with FRAME invent .
        PUT stream Out-Stream UNFORMATTED String("_______________Группа : " + TRIM(CAPS(temp-str.grp-name)) + UndLine)  FORMAT {&format-inv}  skip  .
      End.
      when "invent-gold" THEN DO:
        DOWN stream Out-Stream 1 with FRAME invent-gold .
        PUT stream Out-Stream UNFORMATTED String("_______________Группа : " + TRIM(CAPS(temp-str.grp-name)) + UndLine)  FORMAT {&format-inv-gold}  skip  .
      End.
      when  "sl"  THEN DO:
        DOWN stream Out-Stream 1 with FRAME sl .
        PUT stream Out-Stream UNFORMATTED String("_______________Группа : " + TRIM(CAPS(temp-str.grp-name)) + UndLine)  FORMAT {&format-sl}  skip  .
      End.
      when  "sl-gold"  THEN DO:
        DOWN stream Out-Stream 1 with FRAME sl-gold .
        PUT stream Out-Stream UNFORMATTED String("_______________Группа : " + TRIM(CAPS(temp-str.grp-name)) + UndLine)  FORMAT {&format-sl-gold}  skip  .
      End.
    End.
  end.
end procedure. /* print-grp */


procedure print-prod :
  do  on error undo, return error return-value  :
    find first buf_clients no-lock
      where buf_clients.obj-type = temp-str.prod-type
        and buf_clients.obj-code = temp-str.prod-code
    .
    if p-grp <> "prod" then do:
      case rep-tipe :
        when "invent" THEN DO:
          DOWN stream Out-Stream 1 with FRAME invent .
          PUT stream Out-Stream UNFORMATTED String("________Производитель : " + TRIM(CAPS(buf_clients.obj-name)) + UndLine)  FORMAT {&format-inv}  skip  .
        End.
        when "invent-gold" THEN DO:
          DOWN stream Out-Stream 1 with FRAME invent-gold .
          PUT stream Out-Stream UNFORMATTED String("________Производитель : " + TRIM(CAPS(buf_clients.obj-name)) + UndLine)  FORMAT {&format-inv-gold}  skip  .
        End.
        when  "sl"  THEN DO:
          DOWN stream Out-Stream 1 with FRAME sl .
          PUT stream Out-Stream UNFORMATTED String("________Производитель : " + TRIM(CAPS(buf_clients.obj-name)) + UndLine)  FORMAT {&format-sl}  skip  .
        End.
        when  "sl-gold"  THEN DO:
          DOWN stream Out-Stream 1 with FRAME sl-gold .
          PUT stream Out-Stream UNFORMATTED String("________Производитель : " + TRIM(CAPS(buf_clients.obj-name)) + UndLine)  FORMAT {&format-sl-gold}  skip  .
        End.
      End.
    End.
  end.
end procedure. /* print-prod */


procedure print-line :
  do on error undo, return error return-value :

    case rep-tipe :
      when "invent"      THEN DO:  { rep/inv31.i invent      {&format-inv}      }  End.
      when "invent-gold" THEN DO:  { rep/inv31.i invent-gold {&format-inv-gold} }  End.
      when  "sl"         THEN DO:  { rep/inv31.i sl          {&format-sl}       }  End.
      when  "sl-gold"    THEN DO:  { rep/inv31.i sl-gold     {&format-sl-gold}  }  End.
    End CASE.
  end.
end procedure. /* print-line */


procedure print-grp-itog :
  do on error undo, return error return-value :
    case rep-tipe :
      when "invent" THEN DO:
        display stream Out-Stream
          "ИТОГО"      @  temp-str.artic
          TRIM(CAPS(temp-str.grp-name)) @ temp-str.gds-name
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10  sym8
          sum-a-qnty   @ temp-str.a-qnty
/*          sum-a-stoim  @ temp-str.a-stoim*/
          sum-b-qnty   @ temp-str.b-qnty
/*          sum-b-stoim  @ temp-str.b-stoim*/
        with FRAME invent.
        DOWN stream Out-Stream 1 with FRAME invent .
        if print-graft = false THEN Put stream Out-Stream LineBuf format {&format-inv} SKIP.
      End.
/*      when "invent-gold" THEN DO:                                                                */
/*        display stream Out-Stream                                                                */
/*          "ИТОГО"      @  temp-str.artic                                                         */
/*          TRIM(CAPS(temp-str.grp-name)) @ temp-str.gds-name                                      */
/*          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13 sym8 sym11                  */
/*          sum-a-qnty1  @ temp-str.a-qnty1                                                        */
/*          sum-b-qnty1  @ temp-str.b-qnty1                                                        */
/*          sum-a-qnty   @ temp-str.a-qnty                                                         */
/*          sum-a-stoim  @ temp-str.a-stoim                                                        */
/*          sum-b-qnty   @ temp-str.b-qnty                                                         */
/*          sum-b-stoim  @ temp-str.b-stoim                                                        */
/*        with FRAME invent-gold.                                                                  */
/*        DOWN stream Out-Stream 1 with FRAME invent-gold .                                        */
/*        if print-graft = false THEN Put stream Out-Stream LineBuf format {&format-inv-gold} SKIP.*/
/*      End.                                                                                       */
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
/*      when  "sl-gold"  THEN DO:                                                                  */
/*        display stream Out-Stream                                                                */
/*          "ИТОГО"      @  temp-str.artic                                                         */
/*          TRIM(CAPS(temp-str.grp-name)) @ temp-str.gds-name                                      */
/*          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13 sym8 sym11                  */
/*          sym14 sum-ubl @ temp-str.UBL                                                           */
/*          sym15 UBL-v                                                                            */
/*          sum-a-qnty1  @ temp-str.a-qnty1                                                        */
/*          sum-b-qnty1  @ temp-str.b-qnty1                                                        */
/*          sum-a-qnty   @ temp-str.a-qnty                                                         */
/*          sum-a-stoim  @ temp-str.a-stoim                                                        */
/*          sum-b-qnty   @ temp-str.b-qnty                                                         */
/*          sum-b-stoim  @ temp-str.b-stoim                                                        */
/*        with FRAME sl-gold.                                                                      */
/*        DOWN stream Out-Stream 1 with FRAME sl-gold .                                            */
/*        if print-graft = false THEN Put stream Out-Stream LineBuf format {&format-sl-gold} SKIP. */
/*      End.                                                                                       */
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
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym9   sym10  sym8 
          sum2-a-qnty   @ temp-str.a-qnty
/*          sum2-a-stoim  @ temp-str.a-stoim*/
          sum2-b-qnty   @ temp-str.b-qnty
/*          sum2-b-stoim  @ temp-str.b-stoim*/
        with FRAME invent.
        DOWN stream Out-Stream 1 with FRAME invent .
        if print-graft = false THEN Put stream Out-Stream LineBuf format {&format-inv} SKIP.
      End.
/*      when "invent-gold" THEN DO:                                                                */
/*        display stream Out-Stream                                                                */
/*          "ИТОГО"      @  temp-str.artic                                                         */
/*          TRIM(CAPS(buf_clients.obj-name)) @ temp-str.gds-name                                   */
/*          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13 sym8 sym11                  */
/*          sum2-a-qnty1  @ temp-str.a-qnty1                                                       */
/*          sum2-b-qnty1  @ temp-str.b-qnty1                                                       */
/*          sum2-a-qnty   @ temp-str.a-qnty                                                        */
/*          sum2-a-stoim  @ temp-str.a-stoim                                                       */
/*          sum2-b-qnty   @ temp-str.b-qnty                                                        */
/*          sum2-b-stoim  @ temp-str.b-stoim                                                       */
/*        with FRAME invent-gold.                                                                  */
/*        DOWN stream Out-Stream 1 with FRAME invent-gold .                                        */
/*        if print-graft = false THEN Put stream Out-Stream LineBuf format {&format-inv-gold} SKIP.*/
/*      End.                                                                                       */
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
        if print-graft = false THEN Put stream Out-Stream LineBuf format {&format-sl} SKIP.
      End.
/*      when  "sl-gold"  THEN DO:                                                                  */
/*        display stream Out-Stream                                                                */
/*          "ИТОГО"      @  temp-str.artic                                                         */
/*          TRIM(CAPS(buf_clients.obj-name)) @ temp-str.gds-name                                   */
/*          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13 sym8 sym11                  */
/*          sym14 sum2-ubl @ temp-str.UBL                                                          */
/*          sym15 UBL-v                                                                            */
/*          sum2-a-qnty1  @ temp-str.a-qnty1                                                       */
/*          sum2-b-qnty1  @ temp-str.b-qnty1                                                       */
/*          sum2-a-qnty   @ temp-str.a-qnty                                                        */
/*          sum2-a-stoim  @ temp-str.a-stoim                                                       */
/*          sum2-b-qnty   @ temp-str.b-qnty                                                        */
/*          sum2-b-stoim  @ temp-str.b-stoim                                                       */
/*        with FRAME sl-gold.                                                                      */
/*        DOWN stream Out-Stream 1 with FRAME sl-gold .                                            */
/*        if print-graft = false THEN Put stream Out-Stream LineBuf format {&format-sl-gold} SKIP. */
/*      End.                                                                                       */
    End.

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
          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10  sym8
          sum1-a-qnty   @ temp-str.a-qnty
/*          sum1-a-stoim  @ temp-str.a-stoim*/
          sum1-b-qnty   @ temp-str.b-qnty
/*          sum1-b-stoim  @ temp-str.b-stoim*/
        with FRAME invent.
        DOWN stream Out-Stream 1 with FRAME invent .
        Put stream Out-Stream LineBuf format {&format-inv} SKIP.
      End.
/*      when "invent-gold" THEN DO:                                                              */
/*        display stream Out-Stream                                                              */
/*          "ИТОГО"      @  temp-str.artic                                                       */
/*          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13 sym8 sym11                */
/*          sum1-a-qnty1  @ temp-str.a-qnty1                                                     */
/*          sum1-b-qnty1  @ temp-str.b-qnty1                                                     */
/*          sum1-a-qnty   @ temp-str.a-qnty                                                      */
/*          sum1-a-stoim  @ temp-str.a-stoim                                                     */
/*          sum1-b-qnty   @ temp-str.b-qnty                                                      */
/*          sum1-b-stoim  @ temp-str.b-stoim                                                     */
/*        with FRAME invent-gold.                                                                */
/*        DOWN stream Out-Stream 1 with FRAME invent-gold .                                      */
/*        Put stream Out-Stream LineBuf format {&format-inv-gold} SKIP.                          */
/*      End.                                                                                     */
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
        Put stream Out-Stream LineBuf format {&format-sl} SKIP.
      End.
/*      when  "sl-gold"  THEN DO:                                                                */
/*        display stream Out-Stream                                                              */
/*          "ИТОГО"      @  temp-str.artic                                                       */
/*          sym1 sym2 sym3 sym4 sym5 sym6 sym7 sym9 sym10 sym12  sym13 sym8 sym11    sym14  sym15*/
/*          sum1-a-qnty1  @ temp-str.a-qnty1                                                     */
/*          sum1-b-qnty1  @ temp-str.b-qnty1                                                     */
/*          sum1-a-qnty   @ temp-str.a-qnty                                                      */
/*          sum1-a-stoim  @ temp-str.a-stoim                                                     */
/*          sum1-b-qnty   @ temp-str.b-qnty                                                      */
/*          sum1-b-stoim  @ temp-str.b-stoim                                                     */
/*          sum1-ubl      @ temp-str.ubl                                                         */
/*        with FRAME sl-gold.                                                                    */
/*        DOWN stream Out-Stream 1 with FRAME sl-gold .                                          */
/*        Put stream Out-Stream LineBuf format {&format-sl-gold} SKIP.                           */
/*      End.                                                                                     */
    End.
  end.
end procedure. /* print-all-itog */


procedure PrintTitul :

    define variable v-organization  as character    no-undo.
    define variable v-object        as character    no-undo.
do
on error undo, return error return-value  :
    /* ---------------- Создание заголовка :--------------------------------------------------------------------------- */
    { rep/r-cliprp.i }
    define variable v-outprncd    as character no-undo.
    define variable v-par-type    as character no-undo.
    define variable v-buh-sum-str as character no-undo .
    define variable v-buh-sum     as decimal   no-undo .
    define variable v-str         as character no-undo .
    define variable v-abbr-str    as character no-undo .
    define variable v-doc-date    as character no-undo .
    define variable v-fact-date   as character no-undo .
    define variable v-frame-str   as character no-undo .
    define variable v-prikaz-num  as character no-undo .
    define variable v-prikaz-date as character no-undo .

    run gbl/conf-rd.p ("outprncd", "":U, "":U, 0, "":U, "":U, "":U, no, output v-outprncd, output v-par-type) no-error.
    if v-outprncd = "yes" then
    do:
      assign
        v-organization = string( "{&abbr_inn_allshift} " + t-inn + " " + CAPS( clients.obj-name ) + " (" + string(clients.obj-code) + ")" + t-addres + t-phone)
        v-object       = string( CAPS( This_Object.obj-name ) + " (" + string(This_Object.obj-code) + ")" )
      .
    end.
    else do:
      assign
        v-organization = string( "{&abbr_inn_allshift} " + t-inn + " " + CAPS( clients.obj-name ) + t-addres + t-phone)
        v-object       =  CAPS( This_Object.obj-name )
      .
    end.

    assign
      v-buh-sum-str = 'К началу проведения инвентаризации все расходные и приходные документы на товарно-материальные ценности сданы в бухгалтерию и все товарно-материальные ценности, поступившие на мою ( нашу ) отвественность, оприходованы, а выбывшие списаны в расход.'
    .

    if v-doc-date = ""
    then do:
      for each temp-str
      :
        assign
          v-buh-sum = v-buh-sum + temp-str.b-stoim
        .
      end.
      if PrintRubl = yes then do: run rep/wp-rub.p (                      input v-buh-sum, output v-str, output v-abbr-str ). end.
                         else do: run rep/wp.p     ( input parParentProc, input v-buh-sum, output v-str, output v-abbr-str ). end.
      assign
        v-buh-sum-str = v-buh-sum-str + " Остаток товара на начало инвентаризации составляет сумму: " + v-str
        v-object      = v-object + ", " + v-torgconf-self-obj-addres
      .
    end. /* if lookup( 'L-Rus' , v-sys-key) > 0 */
      { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-inv-date}
          v-doc-date
          p-type
          no-error
      }
      { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-prikaz-number}
          v-prikaz-num
          p-type
          no-error
      }
      { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-prikaz-date}
          v-prikaz-date
          p-type
          no-error
      }            
    
    v-prikaz-date = replace(v-prikaz-date,".","") .
    v-doc-date = replace(v-doc-date,".","") .
    
    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
/*        run inv3xl-write-cell-data in this-procedure ( input {&inv3xl-h_BuhSum} , input v-buh-sum-str ).*/
        run inv3xl-write-cell-data in this-procedure (
            input {&inv3xl-h_organization}
            , input v-organization
        ).
        run inv3xl-write-cell-data in this-procedure (
            input {&inv3xl-h_object}
            , input v-object
        ).
        run inv3xl-write-cell-data in this-procedure (
            input {&inv3xl-h_docCode}
            , input tdoc-code
        ).
        run inv3xl-write-cell-data in this-procedure (
            input {&inv3xl-h_docDate}
            , input string( tdoc-date, "99/99/9999")
        ).
          run inv3xl-write-cell-data in this-procedure (
              input {&inv3xl-h_tbl_prikaz_num}
              , input string(v-prikaz-num)
          ).
          run inv3xl-write-cell-data in this-procedure (
              input {&inv3xl-h_tbl_prikaz_date}
              , input string( v-prikaz-date, "99/99/9999")
          ).
          run inv3xl-write-cell-data in this-procedure (
              input {&inv3xl-h_tbl_startDate}
              , input string( if v-doc-date <> "" then string(v-doc-date, "99/99/9999") else string(buf_trn-doc.doc-date, "99/99/9999"))
          ).
        run inv3xl-write-cell-data in this-procedure (
            input {&inv3xl-h_tbl_endDate}
            , input ( if buf_trn-doc.status_ = {&fact} then string( tdoc-date, "99/99/9999") else "":U )
        ).
    end.


    if v-doc-date = ""
    then do:
      assign
        v-doc-date = string(buf_trn-doc.doc-date,"99999999")
        v-frame-str = "в расход."
      .
    end.
    if rep-tipe begins "invent"
    then do:
      PUT STREAM Out-Stream
        space(3) "Унифицированная форма N ИНВ-3" format "X(30)"  at 169 skip
        space(3) "Утверждена постановлением Госкомстата РФ" format "X(40)"  at 158 skip
        space(3) "от 18 августа 1998 г. N 88" format "X(26)"  at 172 skip
        space(5) Line format  "X(19)" AT 180 skip
        space(5) "| " AT 180 {&g___code} AT 188 "|" AT 198 skip
        space(5) "Форма по ОКУД" format "X(14)" AT 166 "| " AT 180 "0317004" "|" AT 198 skip
        space(5) v-organization format "X(160)"
                   "по ОКПО" format "X(7)" AT 172 "| " AT 180 t-okpo format "X(16)" "|" AT 198 skip
        space(5) v-object format "X(160)" "| " AT 180  "|" AT 198 skip
        space(5) "Вид деятельности по ОКДП" format "X(25)" AT 155 "| " AT 180 "|" AT 198 skip
        space(5) string( "Основание для проведения инвентаризации:                 приказ, постановление, распоряжение " ) format "X(160)"
                       "номер" format "X(5)" AT 174 "| " AT 180 v-prikaz-num "|" AT 198 skip
        space(5) string( "ненужное зачеркнуть " ) format "X(20)" AT 67
                       "дата" format "X(4)" AT 175 "| " AT 180 v-prikaz-date format "99/99/9999" "|" AT 198 skip
        space(5) "Дата начала инвентаризации" format "X(26)" AT 153 "| " AT 180 v-doc-date format "99/99/9999" "|" AT 198 skip
        space(5) "Дата окончания инвентаризации" format "X(29)" AT 150 "| " AT 180  tdoc-date format "99/99/9999" "|" AT 198 skip
        space(5) "Вид операции" format "X(12)" AT 167 "| " AT 180 " инвентаризация" format "X(16)" "|" AT 198 skip
        space(5) Line format  "X(19)" AT 180 skip(2)
        space(79) Line format "X(33)" skip
        space(54) string( "ИНВЕНТАРИЗАЦИОННАЯ ОПИСЬ | "
                                    + string( tdoc-code , "X(16)") + " | "
                                    + string( tdoc-date, "99/99/9999")
                                    + " | "  + (if buf_trn-doc.status_ <> {&fact} then string( "(" + CAPS(buf_trn-doc.status_) + ")" ) else "")
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
        space(5) v-frame-str format "X(193)" SKIP(1)
        space(5) "Материально ответственное (ые) лицо (а): " format "X(41)"
                       UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
        "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
        UndLine format "X(25)" AT 50 UndLine format "X(25)" AT 80 UndLine format "X(50)" AT 110 SKIP
        "должность" format "X(25)" AT 50 "подпись" format "X(25)" AT 80 "расшифровка подписи" format "X(50)" AT 110 SKIP(1)
        space(5) "Произведено снятие фактических остатков ценностей по состоянию на <<       >> _________________        г." format "X(193)" SKIP(4)
      .
    end.
    else do:
    PUT STREAM Out-Stream
        space(3) "Унифицированная форма N ИНВ-19" format "X(30)"  at 168 skip
        space(3) "Утверждена постановлением Госкомстата РФ" format "X(40)"  at 158 skip
        space(3) "от 18 августа 1998 г. N 88" format "X(26)"  at 172 skip
        space(5) Line format  "X(19)" AT 180 skip
        space(5) "| " AT 180 {&g___code} AT 188 "|" AT 198 skip
        space(5) "Форма по ОКУД" format "X(14)" AT 166 "| " AT 180 "0317017" "|" AT 198 skip
        space(5) v-organization format "X(160)"
                   "по ОКПО" format "X(7)" AT 172 "| " AT 180 t-okpo format "X(16)" "|" AT 198 skip
        space(5) v-object format "X(160)" "| " AT 180  "|" AT 198 skip
        space(5) "Вид деятельности по ОКДП" format "X(25)" AT 155 "| " AT 180 "|" AT 198 skip
        space(5) string( "Основание для проведения инвентаризации:                 приказ, постановление, распоряжение " ) format "X(160)"
                       "номер" format "X(5)" AT 174 "| " AT 180 v-prikaz-num "|" AT 198 skip
        space(5) string( "ненужное зачеркнуть " ) format "X(20)" AT 67
                       "дата" format "X(4)" AT 175 "| " AT 180 "|" AT 198 skip
        space(5) "Дата начала инвентаризации" format "X(26)" AT 153 "| " AT 180 buf_trn-doc.doc-date format "99/99/9999" "|" AT 198 skip
        space(5) "Дата окончания инвентаризации" format "X(29)" AT 150 "| " AT 180
                       (if buf_trn-doc.status_ <> {&fact} then tdoc-date else ?) format "99/99/9999" "|" AT 198 skip
        space(5) "Вид операции" format "X(12)" AT 167 "| " AT 180 " инвентаризация" format "X(16)" "|" AT 198 skip
        space(5) Line format  "X(19)" AT 180 skip(2)
        space(79) Line format "X(33)" skip
        space(56) string( "СЛИЧИТЕЛЬНАЯ ВЕДОМОСТЬ | "
                                    + string( tdoc-code , "X(16)") + " | "
                                    + string( tdoc-date, "99/99/9999")
                                    + " | "  + (if buf_trn-doc.status_ <> {&fact} then string( "(" + CAPS(buf_trn-doc.status_) + ")" ) else "")
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
    end.
    /* ... конец создания заголовка. --- */

    PAGE stream Out-Stream.

end.
end procedure. /* PrintTitul */


procedure PrintPodval :
  do on error undo, return error return-value  :
    run rep/wp-qnty.p ( num-ln , output PropisCount).
    if PropisCount = '' Then PropisCount = 'Ноль'.

    if rep-tipe begins "invent"  THEN DO:
      define variable v-pos-agent as character no-undo .
      define variable v-fio-agent as character no-undo .
      define variable v-pos-player1 as character no-undo .
      define variable v-fio-player1 as character no-undo .
      define variable v-pos-player2 as character no-undo .
      define variable v-fio-player2 as character no-undo .
      define variable v-pos-player3 as character no-undo .
      define variable v-fio-player3 as character no-undo .

            { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-fio-agent}
          v-fio-agent
          p-type
          
      }
            { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-pos-agent}
          v-pos-agent
          p-type
          no-error
      }
            { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-fio-player1}
          v-fio-player1
          p-type
          no-error
      }
            { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-pos-player1}
          v-pos-player1
          p-type
          no-error
      }
            { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-fio-player2}
          v-fio-player2
          p-type
          no-error
      }
            { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-pos-player2}
          v-pos-player2
          p-type
          no-error
      }
            { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-fio-player3}
          v-fio-player3
          p-type
          no-error
      }
            { str/tdatinv-val.i
          buf_trn-doc.doc-code
          {&trdcattr-pos-player3}
          v-pos-player3
          p-type
          no-error
      }      
      
      run inv3xl-write-cell-data in this-procedure (
        input {&inv3xl-itp_s_fio_agent}
        , input v-fio-agent
        ).      

      run inv3xl-write-cell-data in this-procedure (
        input {&inv3xl-itp_s_pos_agent}
        , input v-pos-agent
        ).      

      run inv3xl-write-cell-data in this-procedure (
        input {&inv3xl-itp_s_fio_player1}
        , input v-fio-player1
        ).      

      run inv3xl-write-cell-data in this-procedure (
        input {&inv3xl-itp_s_pos_player1}
        , input v-pos-player1
        ).      

      run inv3xl-write-cell-data in this-procedure (
        input {&inv3xl-itp_s_fio_player2}
        , input v-fio-player2
        ).      

      run inv3xl-write-cell-data in this-procedure (
        input {&inv3xl-itp_s_pos_player2}
        , input v-pos-player2
        ).      
        
      run inv3xl-write-cell-data in this-procedure (
        input {&inv3xl-itp_s_fio_player3}
        , input v-fio-player3
        ).      

      run inv3xl-write-cell-data in this-procedure (
        input {&inv3xl-itp_s_pos_player3}
        , input v-pos-player3
        ).              
      PAGE stream Out-Stream.
      HIDE stream Out-Stream FRAME BottomFrame .
      HIDE stream Out-Stream FRAME BottomFrame2 .

      run rep/wp-qnty.p ( sum1-a-qnty , output PropisQnty).
      if PropisQnty = '' Then PropisQnty = 'Ноль'.
      if PrintRubl = yes then do: run rep/wp-rub.p (                      input sum1-a-stoim, output PropisSumall, output abbr ). end.
                         else do: run rep/wp.p     ( input parParentProc, input sum1-a-stoim, output PropisSumall, output abbr ). end.

    if rep-tipe begins "invent"
    and p-grp = "no"
    then do:
        run inv3xl-write-cell-data in this-procedure (
              input {&inv3xl-f_itNumStr}
            , input PropisCount
        ).
        run inv3xl-write-cell-data in this-procedure (
              input {&inv3xl-f_itQntyFactStr}
            , input PropisQnty
        ).
/*        run inv3xl-write-cell-data in this-procedure (*/
/*              input {&inv3xl-f_itSumFactStr}          */
/*            , input PropisSumall                      */
/*        ).                                            */
        run inv3xl-write-cell-data in this-procedure (
              input {&inv3xl-it_qntyFact}
            , input string( sum1-a-qnty )
        ).
/*        run inv3xl-write-cell-data in this-procedure (*/
/*              input {&inv3xl-it_sumFact}              */
/*            , input string( sum1-a-stoim )            */
/*        ).                                            */
        run inv3xl-write-cell-data in this-procedure (
              input {&inv3xl-it_qntyBuh}
            , input string( sum1-b-qnty )
        ).
        run inv3xl-write-cell-data in this-procedure (
              input {&inv3xl-it_sumBuh}
            , input string( sum1-b-stoim )
        ).
        run inv3xl-write-cell-data in this-procedure (
              input {&inv3xl-itp_s_pos_agent}
            , input string( v-pos-agent )
        ).    
        run inv3xl-write-cell-data in this-procedure (
              input {&inv3xl-itp_s_fio_agent}
            , input string( v-fio-agent )
        ).   
        run inv3xl-write-cell-data in this-procedure (
              input {&inv3xl-itp_s_pos_player1}
            , input string( v-pos-player1 )
        ).    
        run inv3xl-write-cell-data in this-procedure (
              input {&inv3xl-itp_s_fio_player1}
            , input string( v-fio-player1 )
        ).                      
        run inv3xl-write-cell-data in this-procedure (
              input {&inv3xl-itp_s_pos_player2}
            , input string( v-pos-player2 )
        ).    
        run inv3xl-write-cell-data in this-procedure (
              input {&inv3xl-itp_s_fio_player2}
            , input string( v-fio-player2 )
        ).  
        run inv3xl-write-cell-data in this-procedure (
              input {&inv3xl-itp_s_pos_player3}
            , input string( v-pos-player3 )
        ).    
        run inv3xl-write-cell-data in this-procedure (
              input {&inv3xl-itp_s_fio_player3}
            , input string( v-fio-player3 )
        ).          
    end.

      run inv3xl-write-cell-data in this-procedure (
        input {&inv3xl-itp_s_num}
        , input string( PropisCount )
        ). 
      run inv3xl-write-cell-data in this-procedure (
        input {&inv3xl-itp_s_qntyFact}
        , input string( PropisQnty )
        ). 
      PUT  STREAM Out-Stream
              "Итого по описи :" Skip
                "а) количество порядковых номеров: " + string( num-ln ) + " (" + PropisCount + ")"  format "x(179)"                         at 18 SKIP
                "б) общее количество единиц фактически: " + string( sum1-a-qnty ) + " (" + PropisQnty + ")"  format "x(179)"  at 18 SKIP
              "   Все цены, подсчеты итогов по строкам, страницам и в целом по инвентаризационной описи товарно-материальных ценностей проверены." SKIP

              "Председатель комиссии:: " format "X(25)" AT 10 SKIP
              string(v-pos-agent) format "X(25)" AT 10 "" format "X(25)" AT 40 string(v-fio-agent) format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
                           
              "Состав комиссии: " format "X(25)" AT 10 SKIP
              string(v-pos-player1) format "X(25)" AT 10 "" format "X(25)" AT 40 string(v-fio-player1) format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              string(v-pos-player2) format "X(25)" AT 10 "" format "X(25)" AT 40 string(v-fio-player2) format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              string(v-pos-player3) format "X(25)" AT 10 "" format "X(25)" AT 40 string(v-fio-player3) format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 skip .

      if PgNPP = 0 then 
      do:
        PUT  STREAM Out-Stream
          "   Все товарно-материальные ценности, поименованные  в  настоящей  инвентаризационной  описи  с № 0 по № " + string(PgNPP) format "x(179)" skip.
      end.
      else 
      do:
        PUT  STREAM Out-Stream
          "   Все товарно-материальные ценности, поименованные  в  настоящей  инвентаризационной  описи  с № 1 по № " + string(PgNPP) format "x(179)" skip.
      end. 
       PUT  STREAM Out-Stream
                 "комиссией проверены в натуре в моем (нашем) личном присутствии  и внесены в опись, в связи с чем претензий к инвентаризационной " SKIP
          "комиссии не имею (не имеем). Товарно-материальные ценности, перечисленные в описи, находятся на моем (нашем) ответственном хранении." SKIP(1)
              "   Лицо(а), ответственное(ые) за сохранность товарно-материальных ценностей : " SKIP(1)
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              LineBuf format "X(25)" AT 10 LineBuf format "X(25)" AT 40 LineBuf format "X(50)" AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP

              "<<       >> _________________        г. "   SKIP(1)
              "Указанные в настоящей описи данные и расчеты проверил"
                  LineBuf format "X(25)" AT 10 LineBuf format "X(25)"   AT 40 LineBuf format "X(50)"               AT 70 SKIP
              "должность" format "X(25)" AT 10 "подпись" format "X(25)" AT 40 "расшифровка подписи" format "X(50)" AT 70 SKIP
              "<<       >> _________________        г. " SKIP
      .
    End.
    ELSE DO:
      if PrintRubl = yes then do: run rep/wp-rub.p (                      input ( sum1-a-stoim - sum1-b-stoim ), output PropisSumall, output abbr ). end.
                         else do: run rep/wp.p     ( input parParentProc, input ( sum1-a-stoim - sum1-b-stoim ), output PropisSumall, output abbr ). end.
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
    { str/tdat-val.i buf_trn-doc.doc-code
                 {&trdcattr-addsum}
                 v-attr-value
                 v-attr-type        }
    if buf_trn-doc.status_ = {&fact} then do:
      case rep-tipe:
        when "invent" then do: /* это инвентариз. опись */
          if lookup( {&sum-before-doc}, v-attr-value ) = 0 or
             lookup( {&sum-after-doc}, v-attr-value ) = 0  then run utl/uaddsum.p (buf_trn-doc.doc-code, no, no, no) no-error  .
          if error-status :error then  message return-value error-status :GET-MESSAGE( 1 )  view-as alert-box error .
        end.
        when "invent-gold" THEN DO:
          if lookup( {&sum-before-doc}, v-attr-value ) = 0 or
             lookup( {&sum-after-doc}, v-attr-value ) = 0  or
             lookup( {&sum-before-cli-doc}, v-attr-value ) = 0  or
             lookup( {&sum-after-cli-doc}, v-attr-value ) = 0 then run utl/uaddsum.p (buf_trn-doc.doc-code, yes, no, yes) no-error .
          if error-status :error then  message return-value error-status :GET-MESSAGE( 1 )  view-as alert-box error .
        End.
        when  "sl"  or when  "sl-gold" THEN DO:
          if lookup( {&sum-general-doc}, v-attr-value ) = 0 or
             lookup( {&sum-wastage-doc}, v-attr-value ) = 0  then run utl/uaddsum.p (buf_trn-doc.doc-code, yes, yes, no) no-error .
          if error-status :error then  message return-value error-status :GET-MESSAGE( 1 )  view-as alert-box error .
        End.
      End.
    end.
    else
      case rep-tipe:
        when "invent" or when "invent-gold" then do: /* это инвентариз. опись */
          if lookup( {&sum-before-doc}, v-attr-value ) = 0 then do:
            message "Не рассчитаны данные до начала инвентаризации!" view-as alert-box.
            undo, return error .
          end.
          if lookup( {&sum-after-doc}, v-attr-value ) = 0  then do:
            if no-vat then do:
              message "Не рассчитаны данные после инвентаризации!" view-as alert-box.
              undo, return error .
            end.
            else assign is-after = no .
          end.
          if rep-tipe = "invent-gold" then do:
            if lookup( {&sum-before-cli-doc}, v-attr-value ) = 0 then do:
              message "Не рассчитано кол-во в един. изм. поставщика до начала инвентаризации!" view-as alert-box.
              undo, return error .
            end.
            if lookup( {&sum-after-cli-doc}, v-attr-value ) = 0 then assign is-after-cli = no .
          end.
        End.
        when  "sl"  or when  "sl-gold" THEN DO:
          if lookup( {&sum-wastage-doc}, v-attr-value ) = 0  then do:
            message "Не рассчитаны нормы естественной убыли! Напечатать документ без их учета?" view-as alert-box QUESTION BUTTONS YES-NO UPDATE ask.
            if ask then assign is-wastage = no .
            else undo, return error .
          end.
          if lookup( {&sum-general-doc}, v-attr-value ) = 0 then assign is-general = no .
        End.
      End.

  end.
end procedure. /* Check-Doc-Sum */