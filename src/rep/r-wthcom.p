block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-wthcom.p $
$Archive: rep/r-wthcom.p $

Сводный отчет о реализованных талонах

Автор: Хныкин Павел Андреевич
Дата создания: 02/02/10
Author: Pavel Khnykin
Creation date: 02/02/10

Input:

Output:

*/
define input parameter parParentProc    AS WIDGET-HANDLE    NO-UNDO .
define input parameter p-begin-date     as date             no-undo .
define input parameter p-end-date       as date             no-undo .
define input parameter p-begin-shift    as integer          no-undo .
define input parameter p-end-shift      as integer          no-undo .
define input parameter p-cli-recid-list as character        no-undo .
define input parameter p-wth-recid-list as character        no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-wthcom.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-wthcom.p $":U .
define variable vss-description as character no-undo init "Сводный отчет о реализованных талонах".

define variable g#report-num              as integer              no-undo .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }
{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ gbl/paramls.i  }
{ gbl/getcntxt.i  def }
/*
{ gbl/waitfram.i }
*/


define stream out-stream.

define variable v-obj-grp-list  as character    no-undo.

do
ON ERROR UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
:
   { gbl/getcntxt.i get }

   run get-report-num in parparentproc (output g#report-num).
   { rep/r-wthcom.i }

   run fill-temp-table in this-procedure .

   run open-stream     IN THIS-PROCEDURE .

   run print-header    in this-procedure .

   run print-body      in this-procedure .

   run print-footer    in this-procedure .

   run close-stream    IN THIS-PROCEDURE .

end.

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE fill-temp-table {&FRAME-NAME}
PROCEDURE fill-temp-table :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_cli-grp     for ub.cli-grp .
define buffer buf_wealth      for ub.wealth .
define buffer buf_wth-par     for ub.wth-par .
define buffer buf_wth-parts   for ub.wth-parts .
define buffer buf_clients     for ub.clients .
define buffer find_clients    for ub.clients .

define buffer buf_tt-grp      for tt-grp .
define buffer buf_tt-wth-par  for tt-wth-par .
define buffer buf_tt-line     for tt-line .


define variable v-count    as integer      no-undo.
define variable v-num      as integer      no-undo.

do
on error undo, return error
:

   DO v-count = 1 TO NUM-ENTRIES(p-cli-recid-list) /*! не recid - code */
   on error undo, next
   :
      find first buf_cli-grp
           where buf_cli-grp.node-code = INTEGER(ENTRY(v-count, p-cli-recid-list))
           no-lock
           no-error
           .
      IF AVAILABLE buf_cli-grp
      THEN DO:
         create buf_tt-grp.
         assign
            buf_tt-grp.grp-code = buf_cli-grp.node-code
            buf_tt-grp.grp-name = buf_cli-grp.node-name
         .
      END.
   END. /* объекты по списку групп */

   assign
      v-num = 1
   .
   /* матценности по списку */
   DO v-count = 1 TO NUM-ENTRIES(p-wth-recid-list)
   on error undo, next
   :
      find first buf_wealth
           where buf_wealth.wth-code = INTEGER(ENTRY(v-count, p-wth-recid-list))
           no-lock
           no-error
           .

      IF AVAILABLE buf_wealth
      THEN DO:
         FOR EACH  buf_wth-par
             WHERE buf_wth-par.wth-code = buf_wealth.wth-code
             no-lock
             :
             create buf_tt-wth-par.
             assign
               buf_tt-wth-par.wth-code       = buf_wealth.wth-code
               buf_tt-wth-par.wth-par-code   = buf_wth-par.par-code
               buf_tt-wth-par.wth-name       = buf_wealth.wth-name
               buf_tt-wth-par.wth-par-name   = SUBSTITUTE ("&1 &2", buf_wth-par.par-val, buf_wth-par.par-unit)
               buf_tt-wth-par.par-rate       = buf_wth-par.par-val
               buf_tt-wth-par.number         = v-num
               v-num                         = v-num + 1
             .
         END. /* EACH  buf_wth-par */
      END. /* AVAILABLE buf_wealth */
   end. /* матценности по списку */

   FOR EACH buf_tt-wth-par
       :
       FOR each buf_tt-grp
       :
         create buf_tt-line.
         assign
            buf_tt-line.grp-code     = buf_tt-grp.grp-code
            buf_tt-line.wth-par-code = buf_tt-wth-par.wth-par-code
            buf_tt-line.wth-code     = buf_tt-wth-par.wth-code
         .

         FOR EACH  buf_clients
             WHERE buf_clients.grp-code = buf_tt-grp.grp-code
               AND buf_clients.obj-type = {&shop}
             no-lock
             :

            /* 4-6 */
            FOR EACH  buf_wth-parts
               WHERE buf_wth-parts.ext-doc-type = {&WDEDT_Exp_Ext}
               AND buf_wth-parts.wth-code     = buf_tt-wth-par.wth-code
               AND buf_wth-parts.par-code     = buf_tt-wth-par.wth-par-code
               AND buf_wth-parts.beg-dt       >= p-begin-date
               AND buf_wth-parts.beg-dt       <= p-end-date
               AND buf_wth-parts.obj-type     = buf_clients.obj-type
               AND buf_wth-parts.obj-code     = buf_clients.obj-code
               NO-LOCK
               :
               /*
               message
                  "X"    buf_wth-parts.doc-code
                  skip   buf_wth-parts.fact-qnty
                  skip   buf_tt-wth-par.wth-par-name
                  skip   buf_wth-parts.out-code
               view-as alert-box information.
               */
               if lookup(buf_wth-parts.out-code,{&WDEDT_List-Zone}) <> 0
               OR buf_wth-parts.fact-order <= 0 then next.  /* партия НЕ относится к документу, */

               assign
                  buf_tt-line.summ-4 = buf_tt-line.summ-4 + buf_wth-parts.fact-qnty
                  buf_tt-line.summ-5 = buf_tt-line.summ-5 + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                  buf_tt-line.summ-6 = buf_tt-line.summ-6 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
               .
            END.
            FOR EACH  buf_wth-parts
               WHERE buf_wth-parts.ext-doc-type       = {&WDEDT_exch}
               AND buf_wth-parts.type = {&expense}
               AND buf_wth-parts.wth-code     = buf_tt-wth-par.wth-code
               AND buf_wth-parts.par-code     = buf_tt-wth-par.wth-par-code
               AND buf_wth-parts.beg-dt       >= p-begin-date
               AND buf_wth-parts.beg-dt       <= p-end-date
               AND buf_wth-parts.obj-type     = buf_clients.obj-type
               AND buf_wth-parts.obj-code     = buf_clients.obj-code
               NO-LOCK
               :
               /*
               message
                  skip  "№ документа ОБМЕН+расход" buf_wth-parts.out-code
                  skip      "№ документа пред. док." buf_wth-parts.doc-code
                  skip  "ДАты " buf_wth-parts.beg-dt
                  skip  "МЦ" buf_tt-wth-par.wth-name buf_tt-wth-par.wth-par-name
                  skip  "количество" buf_wth-parts.fact-qnty
                  skip {&WDEDT_List-Zone}
                  skip buf_wth-parts.ext-doc-type {&expense}
                  skip buf_wth-parts.type         {&WDEDT_exch}
               view-as alert-box information.
               */
               if lookup(buf_wth-parts.out-code,{&WDEDT_List-Zone}) <> 0
               OR buf_wth-parts.fact-order <= 0 then next.  /* партия НЕ относится к документу, */

               assign
                  buf_tt-line.summ-4 = buf_tt-line.summ-4 + buf_wth-parts.fact-qnty
                  buf_tt-line.summ-5 = buf_tt-line.summ-5 + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                  buf_tt-line.summ-6 = buf_tt-line.summ-6 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
               .
            END.
            /* 4-6 */


            /* 7-8 */
            FOR EACH  buf_wth-parts
               WHERE buf_wth-parts.ext-doc-type       = {&WDEDT_Put_Cli}
               AND buf_wth-parts.wth-code     = buf_tt-wth-par.wth-code
               AND buf_wth-parts.par-code     = buf_tt-wth-par.wth-par-code
               AND buf_wth-parts.beg-dt       >= p-begin-date
               AND buf_wth-parts.beg-dt       <= p-end-date
               AND buf_wth-parts.obj-type     = buf_clients.obj-type
               AND buf_wth-parts.obj-code     = buf_clients.obj-code
               NO-LOCK
               :
               if lookup(buf_wth-parts.out-code,{&WDEDT_List-Zone}) <> 0
               OR buf_wth-parts.fact-order <= 0 then next.  /* партия НЕ относится к документу, */

               assign
                  buf_tt-line.summ-7 = buf_tt-line.summ-7 + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                  buf_tt-line.summ-8 = buf_tt-line.summ-8 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
               .
            END.
            FOR EACH  buf_wth-parts
               WHERE buf_wth-parts.ext-doc-type    = {&WDEDT_exch}
               AND buf_wth-parts.type              = {&income}
               AND buf_wth-parts.wth-code     = buf_tt-wth-par.wth-code
               AND buf_wth-parts.par-code     = buf_tt-wth-par.wth-par-code
               AND buf_wth-parts.beg-dt       >= p-begin-date
               AND buf_wth-parts.beg-dt       <= p-end-date
               AND buf_wth-parts.obj-type     = buf_clients.obj-type
               AND buf_wth-parts.obj-code     = buf_clients.obj-code
               NO-LOCK
               :
               if lookup(buf_wth-parts.out-code,{&WDEDT_List-Zone}) <> 0
               OR buf_wth-parts.fact-order <= 0 then next.  /* партия НЕ относится к документу, */

               assign
                  buf_tt-line.summ-7 = buf_tt-line.summ-7 + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                  buf_tt-line.summ-8 = buf_tt-line.summ-8 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
               .
            END.


            /* 9-12 */
            FOR EACH  buf_wth-parts
               WHERE buf_wth-parts.ext-doc-type       = {&WDEDT_Put_Cash}
               AND buf_wth-parts.wth-code     = buf_tt-wth-par.wth-code
               AND buf_wth-parts.par-code     = buf_tt-wth-par.wth-par-code
               AND buf_wth-parts.beg-dt       >= p-begin-date
               AND buf_wth-parts.beg-dt       <= p-end-date
               AND buf_wth-parts.out-obj-type     = buf_clients.obj-type
               AND buf_wth-parts.out-obj-code     = buf_clients.obj-code
               NO-LOCK
               :
               if lookup(buf_wth-parts.out-code,{&WDEDT_List-Zone}) <> 0
               OR buf_wth-parts.fact-order <= 0 then next.  /* партия НЕ относится к документу, */

               IF CAN-FIND( FIRST find_clients
                            WHERE find_clients.obj-type = buf_wth-parts.sale-obj-type
                              AND find_clients.obj-code = buf_wth-parts.sale-obj-code
                              AND find_clients.grp-code = buf_tt-grp.grp-code
                            NO-LOCK)
               /* 9-10 */
               THEN DO:
                  assign
                     buf_tt-line.summ-9  = buf_tt-line.summ-9  + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                     buf_tt-line.summ-10 = buf_tt-line.summ-10 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
                  .
               END.
               /* 11-12 */
               ELSE DO:
                  assign
                     buf_tt-line.summ-11 = buf_tt-line.summ-11 + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                     buf_tt-line.summ-12 = buf_tt-line.summ-12 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
                  .
               END.
            END.
            FOR EACH  buf_wth-parts
               WHERE buf_wth-parts.ext-doc-type       = {&WDEDT_Put_Sale}
               AND buf_wth-parts.wth-code     = buf_tt-wth-par.wth-code
               AND buf_wth-parts.par-code     = buf_tt-wth-par.wth-par-code
               AND buf_wth-parts.beg-dt       >= p-begin-date
               AND buf_wth-parts.beg-dt       <= p-end-date
               AND buf_wth-parts.out-obj-type     = buf_clients.obj-type
               AND buf_wth-parts.out-obj-code     = buf_clients.obj-code
               NO-LOCK
               :
               if lookup(buf_wth-parts.out-code,{&WDEDT_List-Zone}) <> 0
               OR buf_wth-parts.fact-order <= 0 then next.  /* партия НЕ относится к документу, */

               IF CAN-FIND( FIRST find_clients
                            WHERE find_clients.obj-type = buf_wth-parts.sale-obj-type
                              AND find_clients.obj-code = buf_wth-parts.sale-obj-code
                              AND find_clients.grp-code = buf_tt-grp.grp-code
                            NO-LOCK)
               /* 9-10 */
               THEN DO:
                  assign
                     buf_tt-line.summ-9  = buf_tt-line.summ-9  + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                     buf_tt-line.summ-10 = buf_tt-line.summ-10 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
                  .
               END.
               /* 11-12 */
               ELSE DO:
                  assign
                     buf_tt-line.summ-11 = buf_tt-line.summ-11 + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                     buf_tt-line.summ-12 = buf_tt-line.summ-12 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
                  .
               END.
            END.
            /* 9-12 */

            /* 13-14 */
            /* считаем при печати */

            /* 15-16 */
            FOR EACH  buf_wth-parts
               WHERE buf_wth-parts.ext-doc-type = {&WDEDT_Dst_Cli}
               AND buf_wth-parts.wth-code     = buf_tt-wth-par.wth-code
               AND buf_wth-parts.w-p-code     = buf_tt-wth-par.wth-par-code
               AND buf_wth-parts.beg-dt       >= p-begin-date
               AND buf_wth-parts.beg-dt       <= p-end-date
               AND buf_wth-parts.obj-type     = buf_clients.obj-type
               AND buf_wth-parts.obj-code     = buf_clients.obj-code
               NO-LOCK
               :
               if lookup(buf_wth-parts.out-code,{&WDEDT_List-Zone}) <> 0
               OR buf_wth-parts.fact-order <= 0 then next.  /* партия НЕ относится к документу, */

               assign
                  buf_tt-line.summ-15 = buf_tt-line.summ-15 + buf_wth-parts.fact-qnty * buf_tt-wth-par.par-rate
                  buf_tt-line.summ-16 = buf_tt-line.summ-16 + buf_wth-parts.fact-qnty * buf_wth-parts.price-rubl
               .
            END.
            /* 15-16 */
         END. /* EACH  buf_clients */
      END. /* each buf_tt-grp */
   END. /* EACH buf_wth-par */

end.  /* do on error */
END PROCEDURE. /* fill-temp-table */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-header {&FRAME-NAME}
PROCEDURE print-header :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
do
on error undo, return error
:

    /* первый лист */
    run wthcom-write-cell-data in this-procedure (
          input {&wthcom-sheet1-date1}
        , input SUBSTITUTE("за период с &1 по &2", p-begin-date , p-end-date )
    ).

end.  /* do on error */
END PROCEDURE. /* print-header */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-body {&FRAME-NAME}
PROCEDURE print-body :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define buffer buf_tt-grp      for tt-grp .
define buffer buf_tt-line     for tt-line .
define buffer buf_tt-wth-par  for tt-wth-par .

do
on error undo, return error
:

   run wthcom-sheet1-write-line-data IN THIS-PROCEDURE .

end.  /* do on error */
END PROCEDURE. /* print-body */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE print-footer {&FRAME-NAME}
PROCEDURE print-footer :
/*------------------------------------------------------------------------------
  Purpose:
  Parameters:  <none>
  Notes:
------------------------------------------------------------------------------*/
define variable v-dir    as character    no-undo.
define variable v-glbuh    as character    no-undo.
define variable v-oper    as character    no-undo.

define buffer buf_firm           for ub.firm .
define buffer buf_sysconf        for ub.sysconf .
define buffer buf_user-account   for ub.user-account .
do
on error undo, return error
:
   find  first buf_firm
         where buf_firm.firm-code = v-cntxt-host-code-obj
         no-lock
         no-error
         .
   IF AVAILABLE buf_firm
   THEN DO:
      assign
         v-dir   = buf_firm.director
      .
   END.
   ELSE DO:
      assign
         v-dir   = " "
      .
   END.
   find  first buf_sysconf
         where buf_sysconf.host-code = v-cntxt-host-code-obj
         no-lock
         no-error
         .
   IF AVAILABLE buf_sysconf
   THEN DO:
      assign
         v-glbuh   = buf_sysconf.snr-accnt
      .
   END.
   ELSE DO:
      assign
         v-glbuh   = " "
      .
   END.

   FIND FIRST buf_user-account
        WHERE buf_user-account.user-id = v-cntxt-userid
        no-lock
        no-error
        .
   IF AVAILABLE buf_user-account
   THEN DO:
   assign
      v-oper  = SUBSTITUTE("&1 &2 &3", buf_user-account.last-name, buf_user-account.first-name, buf_user-account.second-name )
   .
   END.
   ELSE DO:
   assign
      v-oper  = " "
   .
   END.

    /* первый лист */
    run wthcom-write-cell-data in this-procedure (
          input {&wthcom-sheet1-dir}
        , input v-dir
    ).
    run wthcom-write-cell-data in this-procedure (
          input {&wthcom-sheet1-glbuh}
        , input v-glbuh
    ).
    run wthcom-write-cell-data in this-procedure (
          input {&wthcom-sheet1-oper}
        , input v-oper
    ).

end.  /* do on error */
END PROCEDURE. /* print-footer */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

/*==========================================================================*/
procedure open-stream :

do
on error undo, return error
:

    { gbl/working.i }

    { cmp/open-out.i stream out-stream " " }

    put stream out-stream unformatted
          {&new-line}
        + "Печатная форма предназначена только для вывода в Microsoft Excel."
        + {&new-line}
    .
    output stream out-stream close.

    run wthcom-init in this-procedure.


end. /* do on error */
end procedure. /* open-stream */


/*==========================================================================*/
procedure close-stream :

do
on error undo, return error
:

    run wthcom-close in this-procedure .
    os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
    os-rename
        value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
        value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
    .
    { gbl/stopwork.i }

    /* печатаем */
    define variable v-user-action   as character no-undo .
    define variable v-printed       as logical   no-undo .
    define variable DisabledOptions as integer   no-undo .
    define variable v-orient-page as character no-undo .
    run gbl/prnfilen.w (
          input "":U
        , input 8
        , input string(session :temp-directory) + {&DF_Name} + string( g#report-num )
        , input ReportFontNum
        , output v-user-action
        , output v-printed
    ).
    os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .

end. /* do on error */
end procedure. /* close-stream */