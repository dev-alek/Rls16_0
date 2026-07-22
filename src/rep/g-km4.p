block-level on error undo, throw.
/*

$Revision: 0500dccfad42, 789, rls $
$Author: PGridchina $
$Date: Wed Sep 14 14:42:19 2016 +0300 $
$Workfile: g-km4.p $
$Archive: rep/g-km4.p $

вызов отчета "Журнал кассира операциониста КМ-4"

Автор: Комаров Иван Сергеевич
Дата создания: 06/01/10
Author: Ivan Komarov
Creation date: 06/01/10

Автор1: Белоусов Илья Александрович
Дата создания1: 18.08.08

*/

define input parameter parParentProc    AS WIDGET-HANDLE    NO-UNDO .

define variable vss-revision    as character no-undo init "$Revision: 0500dccfad42, 789, rls $":u .
define variable vss-author      as character no-undo init "$Author: PGridchina $":u .
define variable vss-date        as character no-undo init "$Date: Wed Sep 14 14:42:19 2016 +0300 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: g-km4.p $":u .
define variable vss-archive     as character no-undo init "$Archive: rep/g-km4.p $":u .
define variable vss-description as character no-undo init "вызов отчета КМ-4" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-page1.i new }
{ gbl/getcntxt.i def }

define variable cas-shift as logical no-undo.
define NEW SHARED variable cas-shft as logical no-undo init no.

/*сменный объект или нет*/
{ gbl/getcntxt.i get }
{ gbl/cas-shft.i v-cntxt-obj-type v-cntxt-obj-code cas-shft }

run rep/d-report.w
    ( input parParentProc                   /* 0               */
    , input 'rep/e-km4.w'                   /* 1 RUN           */
    , input "КМ-4":U                        /* 2 Title         */
    , input ( if cas-shft then 7 else 1 )   /* 3 dates         */
    , input ""                              /* 4 goods         */
    , input "{&o-currency}"                 /* 5 objects       */
    , input ""                              /* 6 Price         */
    , input ""                              /* 7 currency      */
    , input "{&shop},{&send-check}"         /* 8 object type   */
    , input no                              /* 9 одна закладка */
    ).