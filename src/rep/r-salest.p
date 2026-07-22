block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-salest.p $
$Archive: rep/r-salest.p $

Отчет структура продаж по поставщикам

Автор: Белоусов Илья Александрович
Дата создания: 05/27/08
Author: Ilia Belousov
Creation date: 05/27/08

Input:

Output:

*/
define input parameter parparentproc  as widget-handle no-undo .
define input parameter p-supp-list    as character     no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-salest.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-salest.p $":U .
define variable vss-description as character no-undo init "Отчет структура продаж по поставщикам".

define variable g#report-num    as integer      no-undo .
define variable v-total-cost    as decimal      no-undo .
define variable v-total-sale    as decimal      no-undo .

define stream out-stream.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }

{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ gbl/paramls.i  }
{ trg/factord.i  }
{ ref/grplibfn.i }
{ gbl/waitfram.i }
{ rep/r-salest.i }
{ rep/repfrm.i def } /* Показать окно информации о текущем процессе */
{ gbl/getcntxt.i  def }
{ gbl/getcntxt.i  get }


do
on error undo, return error
:

   run fill-temp-table in this-procedure .

   run open-stream     IN THIS-PROCEDURE .

   run print-header    in this-procedure .

   run print-body      in this-procedure .

   run print-footer    in this-procedure .

   run close-stream    IN THIS-PROCEDURE .

end.



/*==========================================================================*/
procedure fill-temp-table :
define variable v-count       as integer     no-undo .
DEFINE VARIABLE v-list-doc-type-sale  AS CHAR    NO-UNDO.
DEFINE VARIABLE v-list-doc-type-ret AS CHAR    NO-UNDO.
DEFINE VARIABLE v-doc-type      AS INTEGER NO-UNDO.
define variable v-fact-order-start  as decimal              no-undo .
define variable v-fact-order-end    as decimal              no-undo .
define variable v-empty-1           as decimal      no-undo.
define variable v-empty-2           as decimal      no-undo.
define variable v-curr-grp-name    as character    no-undo.
define variable v-doc-num     as character      no-undo.
define variable v-dprice-sale as decimal      no-undo.
define variable v-droad-tax   as decimal      no-undo.
define variable v-dexcise     as decimal      no-undo.

define buffer buf_clients    for ub.clients .
define buffer prod_clients   for ub.clients .
define buffer buf_doc-line   for ub.doc-line .
define buffer buf_ot-supp-line    for ub.ot-supp-line .
define buffer buf_goods      for ub.goods .
define buffer buf_parts      for ub.parts .
define buffer buf_stk-line       for ub.stk-line .
define buffer buf_gds-obj     for ub.gds-obj .
/*
define buffer buf_tt-supp     for tt-supp .
*/

do
on error undo, return error
:
   CASE X-Radio-Task  :
   WHEN 3 THEN DO:
      run factord IN THIS-PROCEDURE
                  ( INPUT X-date-start
                  , INPUT 0
                  , INPUT 1
                  , INPUT X-date-start
                  , INPUT X-shift-Start
                  , INPUT yes
                  , OUTPUT v-fact-order-start
                  , OUTPUT v-empty-1
                  , OUTPUT v-empty-2
                  ) .
      run factord IN THIS-PROCEDURE
                  ( INPUT X-date-end
                  , INPUT 0
                  , INPUT 1
                  , INPUT X-date-end
                  , INPUT X-shift-end + 1
                  , INPUT yes
                  , OUTPUT v-fact-order-end
                  , OUTPUT v-empty-1
                  , OUTPUT v-empty-2
                  ) .
   END.
   WHEN 4 THEN DO:
      /*
      run factord IN THIS-PROCEDURE
                  ( INPUT X-date-start
                  , INPUT 0
                  , INPUT 1
                  , INPUT X-date-start
                  , INPUT X-shift-Alone
                  , INPUT yes
                  , OUTPUT v-fact-order-start
                  , OUTPUT v-empty-1
                  , OUTPUT v-empty-2
                  ) .
      run factord IN THIS-PROCEDURE
                  ( INPUT X-date-start
                  , INPUT 0
                  , INPUT 99999999
                  , INPUT X-date-start
                  , INPUT X-shift-Alone
                  , INPUT yes
                  , OUTPUT v-fact-order-end
                  , OUTPUT v-empty-1
                  , OUTPUT v-empty-2
                  ) .
      */
      return.
   END.
   WHEN 1 OR
   WHEN 2
   THEN DO:
      run factord-end-day IN THIS-PROCEDURE
               ( input  x-date-start - 1
               , output v-fact-order-start
               ) .
      run factord-end-day IN THIS-PROCEDURE
               ( input x-date-end
               , output v-fact-order-end
               ) .
   END. /*WHEN NO*/
   END CASE.


   /* 1 */
   for each tmp#grp
         no-lock
         :
      run grplib-get-full-name in this-procedure( input tmp#grp.node-code, output v-curr-grp-name ) .

      FIND FIRST tt-total
            WHERE tt-total.grp-code  = tmp#grp.node-code
            NO-ERROR
            .
      IF NOT AVAILABLE tt-total THEN DO:
         CREATE tt-total.
         ASSIGN
            tt-total.grp-code  = tmp#grp.node-code
         .
      END. /* NOT AVAILABLE tt-total */

      /* 2 */
      FOR EACH obj-list
         NO-lock
         ,
         each buf_gds-obj no-lock
         where buf_gds-obj.grp-name begins v-curr-grp-name
           AND buf_gds-obj.obj-type = obj-list.obj-type
           AND buf_gds-obj.obj-code = obj-list.obj-code
      :
         DO v-count = 1 TO NUM-ENTRIES(p-supp-list)
         :
            find first buf_clients
               where recid( buf_clients ) = INTEGER(ENTRY(v-count, p-supp-list))
               NO-LOCK
               no-error.
            IF NOT AVAILABLE buf_clients
            THEN DO:
               NEXT.
            END.


            FIND FIRST tt-line
               WHERE tt-line.grp-code  = tmp#grp.node-code
                  AND tt-line.supp-type = buf_clients.obj-type
                  AND tt-line.supp-code = buf_clients.obj-code
               NO-ERROR
               .
            IF NOT AVAILABLE tt-line THEN DO:
               CREATE tt-line.
               ASSIGN
                  tt-line.grp-code  = tmp#grp.node-code
                  tt-line.supp-type = buf_clients.obj-type
                  tt-line.supp-code = buf_clients.obj-code
                  tt-line.supp-name = buf_clients.obj-name
                  tt-line.grp-name  = TRIM(tmp#grp.grp-name, "/")
               .
            END. /* NOT AVAILABLE tt-line */

            /* 4 */
                  FOR  EACH  buf_ot-supp-line
               where   buf_ot-supp-line.artic        = buf_gds-obj.artic
                  and  buf_ot-supp-line.prod-code    = buf_gds-obj.prod-code
                  and  buf_ot-supp-line.prod-type    = buf_gds-obj.prod-type
                        and  buf_ot-supp-line.cli-type     = tt-line.supp-type
                        and  buf_ot-supp-line.cli-code     = tt-line.supp-code
                        and  buf_ot-supp-line.fact-order   < v-fact-order-end
                        and  buf_ot-supp-line.fact-order   >  v-fact-order-start
                        and  buf_ot-supp-line.obj-code     = obj-list.obj-code
                        and  buf_ot-supp-line.obj-type     = obj-list.obj-type
                        and  buf_ot-supp-line.sum-type     = {&arh-cost}
                  and  (  buf_ot-supp-line.ext-doc-type = {&TDEDT_Ras_Vnesh_Kass}
                        OR buf_ot-supp-line.ext-doc-type = {&TDEDT_Ras_Vnesh}
                        )
                     NO-LOCK
                         :
                        { gbl/bcodeprc.i
                     buf_gds-obj.obj-type
                     buf_gds-obj.obj-code
                     buf_gds-obj.gds-code
                           0
                           buf_ot-supp-line.fact-order
                           v-doc-num
                           v-dprice-sale
                           v-droad-tax
                           v-dexcise
                           no-error
                        }

                        ASSIGN
                           tt-line.prod-summ-cost = tt-line.prod-summ-cost - buf_ot-supp-line.sum-rubl / 1000
                           tt-total.grp-summ-cost = tt-total.grp-summ-cost - buf_ot-supp-line.sum-rubl / 1000
                     /*
                           v-total-cost           = v-total-cost           - buf_ot-supp-line.sum-rubl / 1000
                     */

                           tt-line.prod-summ-sale = tt-line.prod-summ-sale - buf_ot-supp-line.fact-qnty * v-dprice-sale / 1000
                           tt-total.grp-summ-sale = tt-total.grp-summ-sale - buf_ot-supp-line.fact-qnty * v-dprice-sale / 1000
                           v-total-sale           = v-total-sale           - buf_ot-supp-line.fact-qnty * v-dprice-sale / 1000
                        .
                  END. /* EACH buf_doc-line  */

            /* 4 */
                  FOR  EACH  buf_ot-supp-line
               where   buf_ot-supp-line.artic        = buf_gds-obj.artic
                  and  buf_ot-supp-line.prod-code    = buf_gds-obj.prod-code
                  and  buf_ot-supp-line.prod-type    = buf_gds-obj.prod-type
                        and  buf_ot-supp-line.cli-type     = tt-line.supp-type
                        and  buf_ot-supp-line.cli-code     = tt-line.supp-code
                        and  buf_ot-supp-line.fact-order   < v-fact-order-end
                        and  buf_ot-supp-line.fact-order   >  v-fact-order-start
                        and  buf_ot-supp-line.obj-code     = obj-list.obj-code
                        and  buf_ot-supp-line.obj-type     = obj-list.obj-type
                        and  buf_ot-supp-line.sum-type     = {&arh-cost}
                  and  (  buf_ot-supp-line.ext-doc-type = {&TDEDT_Vozvrat_Vnesh_Kass}
                        OR buf_ot-supp-line.ext-doc-type = {&TDEDT_vozvrat_vnesh}
                        )
                     NO-LOCK
                         :

                        { gbl/bcodeprc.i
                     buf_gds-obj.obj-type
                     buf_gds-obj.obj-code
                     buf_gds-obj.gds-code
                           0
                           buf_ot-supp-line.fact-order
                           v-doc-num
                           v-dprice-sale
                           v-droad-tax
                           v-dexcise
                           no-error
                        }
                        ASSIGN
                           tt-line.prod-summ-cost = tt-line.prod-summ-cost - buf_ot-supp-line.sum-rubl / 1000
                           tt-total.grp-summ-cost = tt-total.grp-summ-cost - buf_ot-supp-line.sum-rubl / 1000
                     /*
                           v-total-cost           = v-total-cost           - buf_ot-supp-line.sum-rubl / 1000
                     */

                           tt-line.prod-summ-sale = tt-line.prod-summ-sale - buf_ot-supp-line.fact-qnty * v-dprice-sale / 1000
                           tt-total.grp-summ-sale = tt-total.grp-summ-sale - buf_ot-supp-line.fact-qnty * v-dprice-sale / 1000
                           v-total-sale           = v-total-sale           - buf_ot-supp-line.fact-qnty * v-dprice-sale / 1000
                        .
                  END. /* EACH buf_doc-line  */
         END. /* DO v-count supp-list */
         end.
   end.  /* EACH tmp-grp */
end. /* do on error */
end procedure. /* fill-temp-table */




/*==========================================================================*/
procedure open-stream :

do
on error undo, return error
:

   run get-report-num in parparentproc (output g#report-num).

   { gbl/working.i }

   { cmp/open-out.i stream out-stream " " {&CS_PS} }

   put stream out-stream unformatted
         {&new-line}
      + "Печатная форма предназначена только для вывода в Microsoft Excel."
      + {&new-line}
   .
   output stream out-stream close.

   run salest-init in this-procedure.


end. /* do on error */
end procedure. /* open-stream */




/*==========================================================================*/
procedure print-header :

do
on error undo, return error
:

end. /* do on error */
end procedure. /* print-header */




/*==========================================================================*/
procedure print-body :

do
on error undo, return error
:
   run salest-sheet1-write-line-data in this-procedure .

end. /* do on error */
end procedure. /* print-body */




/*==========================================================================*/
procedure print-footer :

do
on error undo, return error
:

end. /* do on error */
end procedure. /* print-footer */




/*==========================================================================*/
procedure close-stream :

do
on error undo, return error
:

   output stream out-stream close.
   run salest-close in this-procedure .
   { rep/repfrm.i off }
   { gbl/stopwork.i }

   /* передаем управление пользователю */
   os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .
   os-rename
      value( string( session:temp-directory ) + "$" + string( g#report-num ) + ".txl" )
      value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )
   .

   define variable v-user-action   as character no-undo .
   define variable v-printed       as logical   no-undo .
   define variable DisabledOptions as integer   no-undo .
   define variable v-orient-page as character no-undo .
   run gbl/prnfilen.w   ( input "":U
                        , input 20
                        , input string(session :temp-directory) + {&DF_Name} + string( g#report-num )
                        , input ReportFontNum
                        , output v-user-action
                        , output v-printed
                        ) .

   os-delete value( string( session:temp-directory ) + {&DF_Name} + string( g#report-num ) + ".txl" )  .

end. /* do on error */
end procedure. /* close-stream */