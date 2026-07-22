block-level on error undo, throw.
/*

$Revision: 9d317961b21e, 1143, rls $
$Author: ASMorozov $
$Date: Thu Dec 14 02:13:55 2017 +0300 $
$Workfile: clcprtsl.p $
$Archive: str/clcprtsl.p $

Расчет сумм, скидок и налогов по партии и строке в ценах документа

Обертка для класса

Автор: Морозов Александр Сереевич
Дата создания: 24/11/2017
Author: Svetlana Chernova
Creation date: 24/11/2017


Если сказать первым параметром only-one-parts,
то будет доступна только процедура clcprtsl_calc-parts, нельзя будет считать по строке или совокупности партий,
но уменьшаться сегменты.
Eсли {2} = doc , то будут рассчитываться документарные суммы.
*/


define variable vss-revision    as character no-undo initial "$Revision: 9d317961b21e, 1143, rls $":U .
define variable vss-author      as character no-undo initial "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo initial "$Date: Thu Dec 14 02:13:55 2017 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: clcprtsl.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/clcprtsl.p $":U .
define variable vss-description as character no-undo initial "Документ пересортица":U .


{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/clcprtsl.i }

define output parameter proc-hndl  as handle no-undo .
do:
  proc-hndl = this-procedure. 
end.


procedure clcprtsl_calc-parts-inkaps:
  define input-output parameter table for tt-clcparts.
  define input-output parameter table for tt-allsum.

  /*Recid временной таблицы tt-clcparts. Если у Вас есть реальная партия Вы должны создать по ней запись временной таблицы.*/

  /*Нужны ли докуменарные(продажные) компоненты партии*/
  define input parameter paris-doc           as   logical                 no-undo.
  /*Нужны ли текущие продажные компоненты партии*/
  define input parameter paris-cur           as   logical                 no-undo.
  /*Налоги для подсчета сумм по документу и в текущих продажных ценах. Если суммы по документу и текущие продажные не нужны можете заполнить нулями*/
  define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
  define input parameter parexcise           like ub.doc-line.excise      no-undo.
  define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
  define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
  define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
  define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
  define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
  define input parameter parr-b              as   character               no-undo.
  define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
  define input parameter parcurroad-tax      like ub.doc-line.road-tax    no-undo.
  define input parameter parcurexcise        like ub.doc-line.excise      no-undo.
  define input parameter parcurvat-pc        like ub.doc-line.vat-pc      no-undo.
  define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
  define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.

  DEFINE BUFFER bf-loc-plus_doc-line FOR ub.doc-line.
  define variable parrec-parts as recid no-undo.
  find first tt-clcparts.
  parrec-parts = recid( tt-clcparts ).

  run clcprtsl_calc-parts (
                                          input parrec-parts
                                        , input yes
                                        , input no
                                        , input parroad-tax     /* parroad-tax      */
                                        , input parexcise       /* parexcise        */
                                        , input parvat-pc         /* parvat-pc        */
                                        , input parcons-vat-pc /* parcons-vat-pc   */
                                        , input parslt-pc  /* parslt-pc        */
                                        , input parbase-rate      /* parbase-rate     */
                                        , input parbase-scale     /* parbase-scale    */
                                        , input parr-b            /* parr-b           */
                                        , input parcur-base       /* parcur-base      */
                                        , input parcurroad-tax    /* parcurroad-tax   */
                                        , input parcurexcise      /* parcurexcise     */
                                        , input parcurvat-pc      /* parcurvat-pc     */
                                        , input parcurcons-vat-pc /* parcurcons-vat-pc*/
                                        , input parcurslt-pc      /* parcurslt-pc     */
                                    ).


end.
