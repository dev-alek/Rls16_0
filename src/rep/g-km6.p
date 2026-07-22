block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-km6.p $
$Archive: rep/g-km6.p $

вызов отчета "сведения о показаниях счетчиков ККМ и выручке КМ-6"

Автор: Комаров Иван Сергеевич
Дата создания: 06/01/10
Author: Ivan Komarov
Creation date: 06/01/10

Автор1: Белоусов Илья Александрович
Дата создания1: 18.08.08

*/

define input parameter parParentProc    AS WIDGET-HANDLE    NO-UNDO .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: g-km6.p $":u .
define variable vss-archive     as character no-undo init "$Archive: rep/g-km6.p $":u .
define variable vss-description as character no-undo init "вызов отчета КМ-6" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-page1.i new }
{ gbl/getcntxt.i def }

define NEW SHARED variable cas-shft as logical no-undo init no.

/*сменный объект или нет*/
{ gbl/getcntxt.i get }
{ gbl/cas-shft.i v-cntxt-obj-type v-cntxt-obj-code cas-shft }

   run rep/d-report.w
      ( input parParentProc        /* 0               */
      , input 'rep/e-km6.w'            /* 1 RUN           */
      , input "КМ-6":U             /* 2 Title         */
    , input ( if cas-shft then 7 else 1 )   /* 3 dates         */
      , input ""                   /* 4 goods         */
    , input "{&o-currency}"                 /* 5 objects       */
      , input ""                   /* 6 Price         */
    , input ""                              /* 7 currency      */
    , input "{&shop},{&send-check}"         /* 8 object type   */
      , input no                   /* 9 одна закладка */
      ).
