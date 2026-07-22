block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: inv-26.p $
$Archive: rep/inv-26.p $

ВЕДОМОСТЬ УЧЕТА РЕЗУЛЬТАТОВ, ВЫЯВЛЕННЫХ ИНВЕНТАРИЗАЦИЕЙ (ИНВ-26)

Автор: Белоусов Илья Александрович
Дата создания: 07/27/07
Author: Ilia Belousov
Creation date: 07/27/07

*/



/* ***************************  Definitions  ************************** */
define input parameter parParentProc      AS WIDGET-HANDLE NO-UNDO.
define input parameter p-rec-id   as recid. /* recid(trn-doc) */

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: inv-26.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/inv-26.p $":U .
define variable vss-description as character no-undo init "(ИНВ-26)".


define variable g#quest-print as logical   no-undo .
define variable g#log as logical   no-undo .

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/r-pril.i       }
{ cmp/breakstr.i     }
{ rep/r-cliprp.i def }
{ str/lib-trn.i      }
{ gbl/paramls.i      }
{ gbl/cur-time.i     }
{ str/trdcalib.i     }
{ str/valddnst.i def }
{ cmp/abbr-nc.i      }

define variable g#report-num as integer   no-undo .
{ rep/inv26xl.i      }

define temp-table inv-by-VAT
      field miss  like ub.trn-doc.tot-rubl
      field extra like ub.trn-doc.tot-rubl
      field wasta like ub.trn-doc.tot-rubl
      field VAT      like ub.doc-line.VAT-pc
index pu as primary unique
      VAT
      .


define variable v-prn0           as character             no-undo .
define variable v-par-type       as character             no-undo .
define variable v-Line           as character             no-undo .
define variable v-LineBuf        as character             no-undo .
define variable v-UndLine        as character             no-undo .

define variable v-doc-date       like ub.trn-doc.doc-date no-undo .
define variable v-doc-code       like ub.trn-doc.doc-code no-undo .
/* излишки */
define variable v-docextra       like ub.trn-doc.tot-rubl no-undo .
/* недостача */
define variable v-docmiss        like ub.trn-doc.tot-rubl no-undo .
/* естественная убыль */
define variable v-docwaste       like ub.trn-doc.tot-rubl no-undo .

define variable v-rub     as character no-undo.
define variable var-type  as character no-undo.

define variable sym1            as character initial "|" no-undo .
define variable sym2            as character initial "|" no-undo .
define variable sym3            as character initial "|" no-undo .
define variable sym4            as character initial "|" no-undo .
define variable sym5            as character initial "|" no-undo .
define variable sym6            as character initial "|" no-undo .
define variable sym7            as character initial "|" no-undo .
define variable sym8            as character initial "|" no-undo .
define variable sym9            as character initial "|" no-undo .
define variable sym10           as character initial "|" no-undo .
define variable sym11           as character initial "|" no-undo .

define variable s1            as character  no-undo .
define variable s2            as character  no-undo .
define variable s3            as character  no-undo .
define variable s6            as character  no-undo .
define variable s7            as character  no-undo .
define variable s9            as character  no-undo .
define variable s10           as character  no-undo .
define variable s11           as character  no-undo .

define buffer buf_trn-doc     for trn-doc .
define buffer buf_inv-by-VAT  for inv-by-vat .

define stream Out-Stream.

DEFINE FRAME invent-26
      sym1                 no-label  format "X(1)"  space(0)
      s1                   no-label  format "x(10)" space(0)

      sym3                 no-label  format "X(1)"  space(0)
      s2                   no-label  format "X(14)" space(0)

      sym2                 no-label  format "X(1)"  space(0)
      s3                   no-label  format "X(7)"  space(0)

      Sym4                 no-label  format "X(1)"  space(0)
      v-docextra      no-label  format "->>>>>>>9.99" space(0)

      sym5                 no-label  format "X(1)"  space(0)
      v-docmiss       no-label  format "->>>>>>>9.99"  space(0)

      sym6                 no-label  format "X(1)"  space(0)
      s6                   no-label  format "x(13)" space(0)

      sym7                 no-label  format "X(1)"  space(0)
      s7                   no-label  format "x(13)" space(0)

      sym8                 no-label  format "X(1)"  space(0)
      v-docwaste      no-label  format "->>>>>>>>>>9.99"  space(0)

      sym9                 no-label  format "X(1)"  space(0)
      s9                   no-label  format "x(14)"  space(0)

      sym10                no-label  format "X(1)"  space(0)
      s10                  no-label  format "x(15)" space(0)

      sym11                no-label  format "X(1)" space(0)

     HEADER
         "----------------------------------------------------------------------------------------------------------------------------------------" skip
         "| Номер по | Наименование | Номер |    Результаты,          | Установлена |    Из общей суммы недостач и потерь                        |" skip
         "| порядку  | счета        | счета |    выявленные           | порча       |      от порчи имущества, {&abbr_rub}. {&abbr_kop}.                         |" skip
         "|          |              |       |    инвентаризацией,     | имущества,  |------------------------------------------------------------|" skip
         "|          |              |       |    сумма, {&abbr_rub}.{&abbr_kop}.      | сумма,      | зачтено по  | списано в     | отнесено на  | списано сверх |" skip
         "|          |              |       |-------------------------| {&abbr_rub}. {&abbr_kop}.   | пересортице | пределах норм | виновных лиц | норм          |" skip
         "|          |              |       | излишки    | недостача  |             |             | естественной  |              | естественной  |" skip
         "|          |              |       |            |            |             |             | убыли         |              | убыли         |" skip
         "|----------|--------------|-------|------------|------------|-------------|-------------|---------------|--------------|---------------|" skip
         "|   1      |      2       |   3   |    4       |   5        |      6      |     7       |      8        |     9        |   10          |" skip
       /*"|----------|--------------|-------|------------|------------|-------------|-------------|---------------|--------------|---------------|"*/
      with width {&A4_CW0} down stream-io use-text no-label NO-BOX.


/* ***************************  Main Block  *************************** */
main-block:
do
on error undo main-block, return error
:

   run get-report-num  in parParentProc ( output g#report-num ).

   run get-quest-print in parParentProc ( output g#quest-print ).

   /* взять документ */
   FIND FIRST buf_trn-doc
        WHERE recid(buf_trn-doc) = p-rec-id
        NO-LOCK
        .

   /* даты документа */
   assign
     v-doc-date = (if buf_trn-doc.status_ <> {&fact} then buf_trn-doc.doc-date
                                                     else buf_trn-doc.fact-date)
     v-doc-code = buf_trn-doc.doc-code
   .

   { rep/repfrm.i def }   /* Показать окно информации о текущем процессе */
   { rep/repfrm.i on 25 } /* Показать окно информации о текущем процессе */

   if session:set-wait-state("compiler") then.

   { cmp/open-out.i STREAM Out-Stream " " {&CS_PS}  }

   run inv26xl-init in this-procedure .

   /* Шапка */
   run print-top in this-procedure .

   /* тело !!! */
   run print-body in this-procedure.

   /* Подвал */
   run print-bottom in this-procedure .

   output stream Out-Stream CLOSE .
   { rep/repfrm.i off }
   run inv26xl-close in this-procedure .

   { rep/q-print.i 1}
end. /* main-block */



/* **********************  Internal Procedures  *********************** */
PROCEDURE on-same-page :
define input parameter p-line-number as integer  no-undo .

do
on error undo, return error return-value
:
   if p-line-number > page-size( Out-Stream )
   then do:
      return .
   end.
   if line-counter( Out-Stream ) + p-line-number > page-size( Out-Stream )
   then do:
      page stream Out-Stream .
   end.
end.
end procedure. /* on-same-page */



procedure print-top :

define buffer buf_firm_clients for ub.clients .
define buffer this_object      for ub.clients .

define variable v-organization  as character    no-undo.
define variable v-object        as character    no-undo.

do
on error undo, return error return-value
:
   /* объект для заголовка */
   FIND FIRST this_object
        WHERE This_Object.obj-type = buf_trn-doc.obj-type
          AND This_Object.obj-code = buf_trn-doc.obj-code
        NO-LOCK
        .
   /* фирма для заголовка */
   FIND FIRST buf_firm_clients
        WHERE buf_firm_clients.obj-type = {&cmp}
          AND buf_firm_clients.obj-code = buf_trn-doc.host-code
        NO-LOCK
        .

   { rep/r-cliprp.i buf_firm_ }
   assign
       v-organization = string( "{&abbr_inn_allshift} "
                              + t-inn
                              + " "
                              + CAPS( buf_firm_clients.obj-name )
                              + " ("
                              + string(buf_firm_clients.obj-code)
                              + ")"
                              + t-addres
                              + t-phone
                              )
       v-object       = string( CAPS( This_Object.obj-name )
                              + " ("
                              + string(This_Object.obj-code)
                              + ")"
                              )
   .

   /* Excel */
   run inv26xl-write-cell-data in this-procedure (
       input {&inv26xl-h_organization}
       , input v-organization
       ) .
   run inv26xl-write-cell-data in this-procedure (
       input {&inv26xl-h_object}
       , input v-object
       ) .
   run inv26xl-write-cell-data in this-procedure (
       input {&inv26xl-h_OKPO}
       , input t-okpo
       ) .
   run inv26xl-write-cell-data in this-procedure (
       input {&inv26xl-h_docCode}
       , input v-doc-code
       ) .
   run inv26xl-write-cell-data in this-procedure (
       input {&inv26xl-h_docDate}
       , input string( v-doc-date, "99/99/9999")
       ) .

   /* !!! Text */
   PUT STREAM Out-Stream
     "                                                 УТВЕРЖДЕНА           " skip
     "                                    Постановлением Госкомстата России " skip
     "                                                от 27 марта 2000 года " skip
     "                                                                 N 26 " skip
     "                                       Унифицированная форма N ИНВ-26 " skip
     "                                                                      " skip
     "--------------------------------------------------------------------  " skip
     "|                                                  |      Код      |  " skip
     "|                                                  |---------------|  " skip
     "|                                    Форма по ОКУД |    0317022    |  " skip
     "|" v-organization format "X(49)"                  "|---------------|  " AT 52 skip
     "| ---------------------------------------- по ОКПО | " t-OKPO   "|" at 68 skip
     "|        организация                               |---------------|  " skip
     "|" v-object format "X(49)"                        "|               |  " AT 52 skip
     "| ------------------------------------------------ |---------------|  " skip
     "|  структурное подразделение                       |               |  " skip
     "|                         Вид деятельности по ОКДП |---------------|  " skip
     "|                                     Вид операции |               |  " skip
     "--------------------------------------------------------------------  " skip
     "                  ------------------------------ -------------------  " skip
     "                  |    Номер     |    Дата     | | Отчетный период |  " skip
     "                  |  документа   | составления | |-----------------|  " skip
     "                  |              |             | |    с   |   по   |  "  skip
     "                  |--------------|-------------| |--------|--------|  " skip
     "                  |" STRING(v-doc-code,"X(14)") FORMAT "x(14)" "|" at 34 STRING(v-doc-date, "99/99/9999") at 36           "| |        |        |  " at 48 skip
     "                  ------------------------------ -------------------  " skip
     "                                                                      " skip
     "                              ВЕДОМОСТЬ                               " skip
     "            УЧЕТА РЕЗУЛЬТАТОВ, ВЫЯВЛЕННЫХ ИНВЕНТАРИЗАЦИЕЙ             " skip (1)
   .

end.
end procedure. /* print-top */



procedure print-body :

define buffer buf_goods       for goods.
define buffer buf_doc-line    for doc-line.
define buffer buf_doc-line-sum      for doc-line-sum.
define buffer bf_doc-line-sum      for doc-line-sum.

define variable v-host-code    as integer   no-undo.
define variable v-vat          as decimal   no-undo.
define variable v-attr-value   as character no-undo .
define variable v-attr-type    as character no-undo .
define variable v-summ-wasta   as decimal   FORMAT "->>>,>>>,>>>,>>9.99" no-undo.
define variable v-summ-extra   as decimal   FORMAT "->>>,>>>,>>>,>>9.99" no-undo.
define variable v-summ-miss    as decimal   FORMAT "->>>,>>>,>>>,>>9.99" no-undo.

do
on error undo, return error return-value
:
   { str/tdat-val.i
        buf_trn-doc.doc-code
        {&trdcattr-addsum}
        v-attr-value
        v-attr-type
    }
   if (lookup( {&sum-before-doc},  v-attr-value ) = 0
   or lookup( {&sum-after-doc},   v-attr-value ) = 0
   or lookup( {&sum-wastage-doc}, v-attr-value ) = 0)
   then do:
      run utl/uaddsum.p (buf_trn-doc.doc-code, yes, yes, no) no-error  .
      if error-status :error
      then do:
         message "Невозможно рассчитать суммы по инвентаризации"
               SKIP return-value
               SKIP error-status :GET-MESSAGE( 1 )
         view-as alert-box error .
         return error.
      end.
   end.

   FOR EACH  buf_doc-line
      WHERE buf_doc-line.doc-code        = buf_trn-doc.doc-code
      NO-LOCK
      :

      assign
         v-summ-miss   = 0
         v-summ-extra  = 0
         v-summ-wasta  = 0
      .
      find first buf_goods no-lock
            where buf_goods.prod-type = buf_doc-line.prod-type
            and buf_goods.prod-code = buf_doc-line.prod-code
            and buf_goods.artic     = buf_doc-line.artic
            no-error.
      /* extra */
      /* miss */
      find first buf_doc-line-sum no-lock where
                  buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                  bUf_doc-line-sum.gds-code = buf_goods.gds-code and
                  bUf_doc-line-sum.sum-type = {&sum-general-doc}.

      if v-rub = "base" then do:
         if bUf_doc-line-sum.sale-sum-base < 0 then do:
            v-summ-miss = buf_doc-line-sum.sale-sum-base.
         end.
         else do:
            v-summ-extra = buf_doc-line-sum.sale-sum-base.
         end.
      end.
      else do:
         if buf_doc-line-sum.sale-sum-rubl < 0 then do:
            v-summ-miss = buf_doc-line-sum.sale-sum-rubl.
         end.
         else do:
            v-summ-extra = buf_doc-line-sum.sale-sum-rubl.
         end.
      end.
      /* wasta */
      find first bf_doc-line-sum no-lock where
                  bf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                  bf_doc-line-sum.gds-code = buf_goods.gds-code and
                  bf_doc-line-sum.sum-type = {&sum-general-doc}.
      find first buf_doc-line-sum no-lock where
                  buf_doc-line-sum.doc-code = buf_doc-line.doc-code and
                  buf_doc-line-sum.gds-code = buf_goods.gds-code and
                  buf_doc-line-sum.sum-type = {&sum-wastage-doc}.
      if bf_doc-line-sum.sale-sum-base < 0 then do:
         if v-rub = "base" then do:
            if buf_doc-line-sum.sale-sum-base > - bf_doc-line-sum.sale-sum-base
            then do:
               v-summ-wasta = - bf_doc-line-sum.sale-sum-base.
            end.
            else do:
               v-summ-wasta = buf_doc-line-sum.sale-sum-base.
            end.
         end.
         else do:
            if buf_doc-line-sum.sale-sum-rubl > - bf_doc-line-sum.sale-sum-rubl
            then do:
               v-summ-wasta = - bf_doc-line-sum.sale-sum-rubl.
            end.
            else do:
               v-summ-wasta = buf_doc-line-sum.sale-sum-rubl.
            end.
         end.
      end.
      else do:
         v-summ-wasta = 0.00.
      end.

      FIND FIRST buf_inv-by-VAT
           where buf_inv-by-VAT.vat = buf_doc-line.VAT-pc
           no-lock
           no-error
           .
      IF NOT available buf_inv-by-VAT then do:
         create buf_inv-by-VAT.
         assign
            buf_inv-by-VAT.VAT = buf_doc-line.VAT-pc
         .
      end.
      assign
         buf_inv-by-VAT.extra = buf_inv-by-VAT.extra + v-summ-extra
         buf_inv-by-VAT.miss  = buf_inv-by-VAT.miss  + v-summ-miss
         buf_inv-by-VAT.wasta = buf_inv-by-VAT.wasta + v-summ-wasta
         v-docextra      = v-docextra + v-summ-extra
         v-docmiss       = v-docmiss   + v-summ-miss
         v-docwaste      = v-docwaste + v-summ-wasta
      .

   end. /* for each */

   FOR each buf_inv-by-VAT
       :
      run inv26xl-write-line-data in this-procedure (
         input "10%"
         , input buf_inv-by-VAT.extra
         , input buf_inv-by-VAT.miss
         , input buf_inv-by-VAT.wasta
      ).
      display stream Out-Stream
         sym1     buf_inv-by-VAT.vat @ s1
         sym2     s2
         sym3     s3
         sym4     buf_inv-by-VAT.extra @ v-docextra
         sym5     buf_inv-by-VAT.miss  @ v-docmiss
         sym6     s6
         sym7     s7
         sym8     buf_inv-by-VAT.wasta @ v-docwaste
         sym9     s9
         sym10    s10
         sym11
         skip
      with FRAME invent-26.
      .
      DOWN stream Out-Stream 1 with FRAME invent-26.
   end. /* each buf_inv-by-VAT */

   display stream Out-Stream
         "|---------------------------------|------------|------------|-------------|-------------|---------------|--------------|---------------" skip
         "|                           Итого |" + STRING(v-docextra, "->>>>>>>9.99")  + "|" + STRING(v-docmiss, "->>>>>>>9.99") +   "|             |             |" +   STRING( v-docwaste, "->>>>>>>>>>9.99") +         "|              |             "  FORMAT "x(135)" skip
         "---------------------------------------------------------------------------------------------------------------------------------------" skip(1)
   with FRAME PageFrame width {&A4_CW0} NO-LABELS NO-BOX .
end. /* do on error */
end procedure. /* print-body */



procedure print-bottom :
do
on error undo, return error return-value
:
   /* Excel */
   run inv26xl-write-cell-data in this-procedure (
         input {&inv26xl-it_docextra-rubl}
       , input string( v-docextra )
   ).
   run inv26xl-write-cell-data in this-procedure (
         input {&inv26xl-it_docmiss-rubl}
       , input string( v-docmiss )
   ).
   run inv26xl-write-cell-data in this-procedure (
         input {&inv26xl-it_docwaste-rubl}
       , input string( v-docwaste )
   ).


   PAGE STREAM Out-Stream.
   PUT STREAM Out-Stream
       skip(2)
         "Руководитель --------------- ------- ---------------------------------" skip
         "               должность    подпись               расшифровка подписи " skip
       skip(2)
         "Главный бухгалтер ------- --------------------------------------------" skip
         "                  подпись                          расшифровка подписи" skip
       skip(2)
         "Председатель инвентаризационной                                       " skip
         "комиссии                        ---------- -------- -------------------------------" skip
         "                                 должность  подпись             расшифровка подписи  " skip
   .
end.
end procedure. /* print-bottom */