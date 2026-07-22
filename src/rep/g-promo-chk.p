block-level on error undo, throw.
/*

$Revision: 38e7c64866ed, 3182, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:25 $
$Workfile: g-promo-chk.p $
$Archive: rep/g-promo-chk.p $

Оперативный отчет по реализации промо-акций.

Автор: Шкляр Елена
Дата создания: 04/29/10
Author: Elena Shklyar
Creation date: 04/29/10



*/
define input parameter parParentProc    AS WIDGET-HANDLE    NO-UNDO .

define variable vss-revision    as character no-undo init "$Revision: 38e7c64866ed, 3182, rls $":u .
define variable vss-author      as character no-undo init "$Author: EShklyar $":u .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:25 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: g-promo-chk.p $":u .
define variable vss-archive     as character no-undo init "$Archive: rep/g-promo-chk.p $":u .
define variable vss-description as character no-undo init "Оперативный отчет по реализации промо-акций на СТ." .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-page1.i new }
{ gbl/getcntxt.i def }

define NEW SHARED variable cas-shft as logical no-undo init no.

/*найдем параметр - использовать смены на кассе или нет*/
{ gbl/getcntxt.i get }
/*{ gbl/cas-shft.i v-cntxt-obj-type v-cntxt-obj-code cas-shft }*/

run rep/d-report.w
    ( input parParentProc                   /* 0               */
    , input 'rep/e-work_promo.w'                   /* 1 RUN           */
    , input "Оперативный отчет по реализации промо-акций на СТ":U                        /* 2 Title         */
    , input 4   /* 3 dates         */
    , input ""                              /* 4 goods         */
    , input "*"                           /* 5 objects       */
    , input ""                              /* 6 Price         */
    , input ""                              /* 7 currency      */
    , input "{&shop},{&send-check}"         /* 8 object type   */
    , input no                              /* 9 одна закладка */
    ).