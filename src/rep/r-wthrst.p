block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-wthrst.p $
$Archive: rep/r-wthrst.p $

Текущие остатки серийных МЦ

Автор: Белоусов Илья Александрович
Дата создания: 05/12/09
Author: Ilia Belousov
Creation date: 05/12/09

Input:

Output:

*/
define input parameter parParentProc    AS WIDGET-HANDLE    NO-UNDO .
define input parameter p-wth-recid-list as character        no-undo .
define input parameter p-free-zone      as logical          no-undo .
define input parameter p-put-zone       as logical          no-undo .
define input parameter p-all-wth        as logical          no-undo .
define input parameter p-all-obj        as logical          no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-wthrst.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-wthrst.p $":U .
define variable vss-description as character no-undo init "Текущие остатки серийных МЦ".

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

define variable v-obj-list  as character    no-undo.
define variable v-wth-list  as character    no-undo.
define variable v-hide-list as character    no-undo.
define variable v-firm      as character    no-undo.

do
ON ERROR UNDO, RETURN ERROR substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
:
   { gbl/getcntxt.i get }

   run get-report-num in parparentproc (output g#report-num).

   { rep/r-wthrst.i }

   run get-hide-list in this-procedure ( output v-hide-list ).

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
define buffer buf_wth-par     for ub.wth-par .
define buffer buf_wth-parts   for ub.wth-parts .
define buffer buf_wealth      for ub.wealth .

define buffer buf_tt-line     for tt-line .


define variable v-count    as integer      no-undo.
define variable v-num      as integer      no-undo.

do
on error undo, return error
:

   /* номиналы матценностей по списку */
   DO v-count = 1 TO NUM-ENTRIES(p-wth-recid-list, {&comma-char} )
   on error undo, next
   :
      find first buf_wth-par
           where buf_wth-par.wth-code = integer( ENTRY(1, entry( v-count, p-wth-recid-list, {&comma-char}), {&delim-par} ))
             and buf_wth-par.par-code = integer( ENTRY(2, entry( v-count, p-wth-recid-list, {&comma-char}), {&delim-par} ))
            no-lock
            no-error
            .
      FIND FIRST buf_wealth
         WHERE buf_wealth.wth-code  = buf_wth-par.wth-code
/*           and buf_wealth.is-ser    = 1*/
         NO-LOCK
         NO-ERROR
         .

      IF NOT AVAILABLE buf_wealth
      THEN DO:
         NEXT.
      END. /* AVAILABLE buf_wealth */

      IF NOT p-all-wth
      THEN DO:
         ASSIGN
            v-wth-list = v-wth-list + ", " + buf_wealth.wth-name + " " + SUBSTITUTE ("&1 &2", buf_wth-par.par-val, buf_wth-par.par-unit)
         .
      END.

      FOR EACH obj-list
         :
         create buf_tt-line.
         assign
            buf_tt-line.wth-par-code = buf_wth-par.par-code
            buf_tt-line.wth-code     = buf_wth-par.wth-code
            buf_tt-line.wth-name     = buf_wealth.wth-name
            buf_tt-line.wth-num      = SUBSTITUTE ("&1 &2", buf_wth-par.par-val, buf_wth-par.par-unit)
            buf_tt-line.obj-type     = obj-list.obj-type
            buf_tt-line.obj-code     = obj-list.obj-code
            buf_tt-line.obj-name     = obj-list.obj-name
         .
            /* 5-6 */
            FOR EACH buf_wth-parts
               WHERE buf_wth-parts.wth-code = buf_wth-par.wth-code
                 AND buf_wth-parts.par-code = buf_wth-par.par-code
                 AND buf_wth-parts.obj-type = obj-list.obj-type
                 AND buf_wth-parts.obj-code = obj-list.obj-code
                 AND p-free-zone            = TRUE
                 AND buf_wth-parts.out-code = {&free-code}
               NO-LOCK
               :
               assign
                  buf_tt-line.summ-4 = buf_tt-line.summ-4 + buf_wth-parts.fact-qnty
                  buf_tt-line.summ-5 = buf_tt-line.summ-5 + buf_wth-parts.fact-qnty * buf_wth-par.par-rate
               .
            END.

            /* 7-8 */
            FOR EACH buf_wth-parts
               WHERE buf_wth-parts.wth-code = buf_wth-par.wth-code
                 AND buf_wth-parts.par-code = buf_wth-par.par-code
                 AND buf_wth-parts.obj-type = obj-list.obj-type
                 AND buf_wth-parts.obj-code = obj-list.obj-code
                 AND p-put-zone             = TRUE
                 AND buf_wth-parts.out-code = {&put-zone}
               NO-LOCK
               :
               assign
                  buf_tt-line.summ-6 = buf_tt-line.summ-6 + buf_wth-parts.fact-qnty
                  buf_tt-line.summ-7 = buf_tt-line.summ-7 + buf_wth-parts.fact-qnty * buf_wth-par.par-rate
               .
            END.

         END. /* EACH obj-list */
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
define buffer buf_clients     for ub.clients .
do
on error undo, return error
:
   find  first buf_clients
         where buf_clients.obj-code = v-cntxt-host-code-obj
           AND buf_clients.obj-type = {&cmp}
         no-lock
         no-error
         .
   IF AVAILABLE buf_clients
   THEN DO:
      assign
         v-firm   = buf_clients.obj-name
      .
   END.

   ASSIGN
      v-wth-list = TRIM(v-wth-list, ", ")
   .
   IF p-all-wth
   THEN DO:
      ASSIGN
         v-wth-list = "Все"
      .
   END.

   IF p-all-obj
   THEN DO:
      ASSIGN
         v-obj-list = "Все"
      .
   END.
   ELSE DO:
      ASSIGN
         v-obj-list = "":U
      .
      FOR EACH obj-list:
         ASSIGN
            v-obj-list = v-obj-list + ", " + obj-list.obj-name
         .
      END.
      ASSIGN
         v-obj-list = TRIM(v-obj-list, ", ")
      .
   END.

    /* первый лист */
    run wthrst-write-cell-data in this-procedure (
          input {&wthrst-sheet1-date1}
        , input SUBSTITUTE("&1 &2", TODAY , STRING(TIME, "HH:MM:SS") )
    ).
    run wthrst-write-cell-data in this-procedure (
          input {&wthrst-sheet1-firm}
        , input v-firm
    ).
    run wthrst-write-cell-data in this-procedure (
          input {&wthrst-sheet1-obj-list}
        , input v-obj-list
    ).
    run wthrst-write-cell-data in this-procedure (
          input {&wthrst-sheet1-wth-list}
        , input v-wth-list
    ).
    run wthrst-write-cell-data in this-procedure (
          input {&wthrst-sheet1_hideColList}
        , input v-hide-list
    ).
   put stream out-stream unformatted
      v-firm skip( 2 )
      SPACE( 25 ) "ТЕКУЩИЕ ОСТАТКИ СЕРИЙНЫХ МЦ" skip( 2 )
      "     Объекты: " v-obj-list skip
      "          МЦ: " v-wth-list skip
      "Дата и время: " SUBSTITUTE("&1 &2", TODAY , STRING(TIME, "HH:MM:SS") ) skip
   .

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
define buffer buf_tt-line     for tt-line .

do
on error undo, return error
:

   run wthrst-sheet1-write-line-data IN THIS-PROCEDURE .

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

do
on error undo, return error
:

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

    run wthrst-init in this-procedure.


end. /* do on error */
end procedure. /* open-stream */


/*==========================================================================*/
procedure close-stream :

do
on error undo, return error
:

    output stream out-stream close.

    run wthrst-close in this-procedure .
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


/*==========================================================================*/
procedure get-hide-list :
define output parameter p-hide-list         as character        no-undo.

define variable v-counter       as integer      no-undo.
define variable v-rec-amount    as integer      no-undo.
define variable v-ext-doc-type  as character    no-undo.

    define buffer buf_temp_hideCol      for temp_hideCol.
do
for buf_temp_hideCol
on error undo, return error
:
    empty temp-table buf_temp_hideCol.
    if p-free-zone = no
    then do:
        assign
            v-rec-amount =  num-entries( {&wthrst-sheet1_withoutFree} )
        .
        do v-counter = 1 to v-rec-amount
        :
            run hide-list-add-item in this-procedure ( input entry( v-counter, {&wthrst-sheet1_withoutFree} ) ).
        end.
    end.
    if p-put-zone = no
    then do:
        assign
            v-rec-amount =  num-entries( {&wthrst-sheet1_withoutPut} )
        .
        do v-counter = 1 to v-rec-amount
        :
            run hide-list-add-item in this-procedure ( input entry( v-counter, {&wthrst-sheet1_withoutPut} ) ).
        end.
    end.
    assign
        p-hide-list = "":U
    .
    for each buf_temp_hideCol
    on error undo, return error
    :
        assign
            p-hide-list = substitute( "&1&2&3"
                                    , p-hide-list
                                    , ( if p-hide-list = "":U then "":U else ",":U )
                                    , buf_temp_hideCol.colName )
        .
    end.        /* for each buf_temp_hideCol */
end.
end procedure. /* get-hide-list */

/*==========================================================================*/
procedure hide-list-add-item :
define input parameter p-item-name  as character        no-undo.

    define buffer buf_temp_hideCol      for temp_hideCol.
do
for buf_temp_hideCol
on error undo, return error
:
   find first buf_temp_hideCol
      where buf_temp_hideCol.colName = p-item-name
   no-error.
   if not available buf_temp_hideCol
   then do:
      create buf_temp_hideCol.
      assign
         buf_temp_hideCol.colName = p-item-name
      .
   end.
end.
end procedure. /* hide-list-add-item */