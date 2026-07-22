block-level on error undo, throw.
/*

$Revision: 45afebdf84b6, 1359, rls $
$Author: EShklyar $
$Date: Tue May 22 14:25:55 2018 +0300 $
$Workfile: g-corchk.p $
$Archive: rep/g-corchk.p $

Общий Отчет о количестве кассовых чеков коррекции за период

Автор: Шкляр Елена
Дата создания: 04/29/10
Author: Elena Shklyar
Creation date: 04/29/10



*/
define input parameter parParentProc    AS WIDGET-HANDLE    NO-UNDO .

define variable vss-revision    as character no-undo init "$Revision: 45afebdf84b6, 1359, rls $":u .
define variable vss-author      as character no-undo init "$Author: EShklyar $":u .
define variable vss-date        as character no-undo init "$Date: Tue May 22 14:25:55 2018 +0300 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: g-corchk.p $":u .
define variable vss-archive     as character no-undo init "$Archive: rep/g-corchk.p $":u .
define variable vss-description as character no-undo init "Общий Отчет о количестве кассовых чеков коррекции за период" .
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
    , input 'rep/r-corchkr.p'                   /* 1 RUN           */
    , input "Общий отчет по чекам коррекции":U                        /* 2 Title         */
    , input 4   /* 3 dates         */
    , input ""                              /* 4 goods         */
    , input "*"                           /* 5 objects       */
    , input ""                              /* 6 Price         */
    , input ""                              /* 7 currency      */
    , input "{&shop},{&send-check}"         /* 8 object type   */
    , input yes                              /* 9 одна закладка */
    ).