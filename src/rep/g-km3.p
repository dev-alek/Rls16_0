block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-km3.p $
$Archive: rep/g-km3.p $

вызов отчета "сведения о показаниях счетчиков ККМ и выручке КМ-3"

Автор: Комаров Иван Сергеевич
Дата создания: 21/10/09
Author: Ivan Komarov
Creation date: 21/10/09

*/
define input parameter parParentProc    AS WIDGET-HANDLE    NO-UNDO .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: g-km3.p $":u .
define variable vss-archive     as character no-undo init "$Archive: rep/g-km3.p $":u .
define variable vss-description as character no-undo init "вызов отчета КМ-3" .
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-page1.i new }
{ gbl/getcntxt.i def }

/* define variable cas-shift as logical no-undo.                    */
/* define NEW SHARED variable cas-shft as logical no-undo init no.  */
/*                                                                  */
/* /*найдем параметр - использовать смены на кассе или нет*/        */
/* { gbl/getcntxt.i get }                                           */
/* { gbl/cas-shft.i v-cntxt-obj-type v-cntxt-obj-code cas-shft }    */
/*     MESSAGE cas-shift VIEW-AS ALERT-BOX.                         */

/* IF cas-shift THEN DO:                                                              */
/*    run rep/d-report.w                                                              */
/*       ( input parParentProc        /* 0               */                           */
/*       , input 'rep/e-km3.w'            /* 1 RUN           */                       */
/*       , input "КМ-3":U             /* 2 Title         */                           */
/*       , input 5                    /* 3 dates         */                           */
/*       , input ""                   /* 4 goods         */                           */
/*       , input ""                   /* {&o-currency},{&o-choice} 5 objects       */ */
/*       , input ""                   /* 6 Price         */                           */
/*       , input "{&v-rubl}"          /* 7 currency      */                           */
/*       , input "{&shop}"            /* 8 object type   */                           */
/*       , input no                   /* 9 одна закладка */                           */
/*       ).                                                                           */
/* END.                                                                               */
/* ELSE DO:                                                                           */
   run rep/d-report.w
      ( input parParentProc        /* 0               */
      , input 'rep/e-km3.w'        /* 1 RUN           */
      , input "КМ-3":U             /* 2 Title         */
      , input 8                    /* 3 dates         */
      , input ""                   /* 4 goods         */
      , input ""                   /* {&o-currency},{&o-choice} 5 objects       */
      , input ""                   /* 6 Price         */
      , input "{&v-rubl}"          /* 7 currency      */
      , input "{&shop}"            /* 8 object type   */
      , input no                   /* 9 одна закладка */
      ).
/* END.  */