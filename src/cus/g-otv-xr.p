block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: g-otv-xr.p $
$Archive: cus/g-otv-xr.p $

Объединенная счет-фактура по ответственному хранению

Автор: Булгаков Андрей Николаевич
Дата создания: 09/14/05
Author: Andrew Bulgakoff
Creation date: 09/14/05

*/

DEFINE INPUT PARAMETER p-parent-proc AS WIDGET-HANDLE NO-UNDO.

DEFINE VARIABLE vss-revision    AS CHARACTER NO-UNDO INITIAL "$Revision: aea5316774be, 0, rls $":U.
DEFINE VARIABLE vss-author      AS CHARACTER NO-UNDO INITIAL "$Author: expertek $":U.
DEFINE VARIABLE vss-date        AS CHARACTER NO-UNDO INITIAL "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
DEFINE VARIABLE vss-workfile    AS CHARACTER NO-UNDO INITIAL "$Workfile: g-otv-xr.p $":U.
DEFINE VARIABLE vss-archive     AS CHARACTER NO-UNDO INITIAL "$Archive: cus/g-otv-xr.p $":U.
DEFINE VARIABLE vss-description AS CHARACTER NO-UNDO INITIAL "объединенная счет-фактура по ответственному хранению":U.

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/r-page1.i  NEW }
{ cmp/library.i      }

DEFINE VARIABLE v_r-b            AS CHARACTER NO-UNDO.
DEFINE VARIABLE v_data-type      AS CHARACTER NO-UNDO.
DEFINE VARIABLE v_param-pay-hide AS CHARACTER NO-UNDO.

{ gbl/curr-r-b.i
  v_r-b
  no-error
}

IF ERROR-STATUS :ERROR THEN DO:
  MESSAGE vss-workfile SKIP vss-revision SKIP vss-description SKIP( 1 )
          "Ошибка при чтении параметра конфигурации r-b!"     SKIP( 1 )
          ERROR-STATUS :GET-MESSAGE( 1 ) SKIP ERROR-STATUS :GET-MESSAGE( 2 ) SKIP RETURN-VALUE
  VIEW-AS ALERT-BOX ERROR.
  RETURN.
END.
ASSIGN v_param-pay-hide = ( IF v_r-b = "rubl" THEN "{&v-rubl}":U ELSE "{&v-rubl},{&v-base}":U ).

run rep/d-report.w ( INPUT p-parent-proc,                             /* указатель на главное меню */
                 INPUT "cus/e-otv-xr.w",                              /* procname       */
                 INPUT "счет-фактура по ответственному хранению", /* namereport     */
                 INPUT 2,                                         /* param-date     */
                 INPUT "":U,                                      /* param-goods    */
                 INPUT "{&o-firm},{&o-currency},{&o-choice}":U,   /* param-obj      */
                 INPUT "":U,                                      /* param-Pay      */
                 INPUT v_param-pay-hide,                          /* param-Pay-hide */
                 INPUT "all",                                     /* param-Obj-type */
                 INPUT NO                                         /* param-alon     */ ).