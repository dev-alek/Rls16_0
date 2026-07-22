block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-wthres.p $
$Archive: rep/r-wthres.p $

Остатки материальных ценностей

Автор: Белоусов Илья Александрович
Дата создания: 05/19/08
Author: Ilia Belousov
Creation date: 05/19/08

Input:

Output:

*/
define input parameter parparentproc      as widget-handle no-undo .
define input parameter p-wth-all          as logical       no-undo.
define input parameter p-wth-pl-all       as logical       no-undo.
define input parameter p-wth-list         as character     no-undo .
define input parameter p-wth-pl-list      as character     no-undo .



define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-wthres.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-wthres.p $":U .
define variable vss-description as character no-undo init "Остатки материальных ценностей".

define variable g#report-num        as integer              no-undo .
define variable v-fact-order        as decimal      no-undo.
define variable v-empty-1           as decimal      no-undo.
define variable v-empty-2           as decimal      no-undo.
define variable v-obj-shift         as logical   no-undo .
define variable v-firm              as character    no-undo.
define variable v-period            as date    no-undo.
define variable v-place-name-list   as character    no-undo.

define stream out-stream.

define buffer buf_clients     for ub.clients .

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
{ rep/r-wthres.i }
{ trg/factord.i  }

do
on error undo, return error
:
   { gbl/getcntxt.i get }

   { gbl/objat.i
         v-cntxt-obj-type
         v-cntxt-obj-code
         "'shift-on=request'"
         v-obj-shift
         no-error
   }
   if error-status :error
   then do:
      message
         vss-workfile vss-revision vss-description skip
         "Ошибка при запуске процедуры objat" skip
         error-status :get-message(1) skip
         return-value skip
         view-as alert-box error .
      return.
   end.
   IF v-obj-shift
   THEN DO:
      RUN factord IN THIS-PROCEDURE ( INPUT x-date-alone + 1
                                    , INPUT 0
                                    , INPUT 1
                                    , INPUT x-date-alone + 1
                                    , INPUT X-shift-Alone
                                    , INPUT yes
                                    , OUTPUT v-fact-order
                                    , OUTPUT v-empty-1
                                    , OUTPUT v-empty-2
                                    ) .
      ASSIGN
         v-period = x-date-alone
      .
   END.
   ELSE DO:
      RUN factord IN THIS-PROCEDURE ( INPUT x-date-alone
                                    , INPUT 0
                                    , INPUT 1
                                    , INPUT X-date-Start
                                    , INPUT X-shift-Alone + 1
                                    , INPUT no
                                    , OUTPUT v-fact-order
                                    , OUTPUT v-empty-1
                                    , OUTPUT v-empty-2
                                    ) .
      ASSIGN
         v-period = X-date-Start
      .
   END.
   FIND FIRST buf_clients
         where buf_clients.obj-type = {&cmp}
         AND buf_clients.obj-code = v-cntxt-host-code-obj
         no-lock
         .
   assign
      v-firm   = buf_clients.obj-name
   .

   run open-stream     IN THIS-PROCEDURE .

   run fill-temp-table in this-procedure .

    run wthres-write-cell-data in this-procedure (
          input {&wthres-sheet1-firm}
        , input v-firm
    ).
    run wthres-write-cell-data in this-procedure (
          input {&wthres-sheet1-period}
        , input v-period
    ).
    run wthres-write-cell-data in this-procedure (
          input {&wthres-sheet1-place}
        , input v-place-name-list
    ).

   run close-stream    IN THIS-PROCEDURE .

end.




/*==========================================================================*/
procedure fill-temp-table :
define buffer buf_wth-place  for ub.wth-place .
define buffer buf_wealth     for ub.wealth .

define variable v-count    as integer      no-undo.
define variable v-qnty-free-total-pl    as integer      no-undo.
define variable v-qnty-put-total-pl     as integer      no-undo.
define variable v-qnty-free    as integer      no-undo.
define variable v-qnty-put     as integer      no-undo.

do
on error undo, return error
:
   IF p-wth-pl-all
   THEN DO:
      FOR EACH  buf_wth-place
          WHERE (    v-cntxt-db-num = 0
                 AND buf_wth-place.host-code = v-cntxt-host-code-obj
                )
              OR
                (    v-cntxt-db-num <> 0
                 AND buf_wth-place.obj-type = v-cntxt-obj-type
                 AND buf_wth-place.obj-code = v-cntxt-obj-code
                )
          NO-LOCK
          :
          find first buf_clients
               where buf_clients.obj-type = buf_wth-place.obj-type
                 and buf_clients.obj-code = buf_wth-place.obj-code
               no-lock
               .

          assign
             v-qnty-free-total-pl = 0
             v-qnty-put-total-pl  = 0
             v-place-name-list = IF v-place-name-list = "":U THEN SUBSTITUTE("&1 (&2)", buf_wth-place.w-p-name, buf_clients.obj-name)
                                                             ELSE SUBSTITUTE("&1, &2 (&3)", v-place-name-list, buf_wth-place.w-p-name, buf_clients.obj-name)
          .
          run wthres-sheet1-write-line-data in this-procedure  ( INPUT SUBSTITUTE("&1 (&2)", buf_wth-place.w-p-name, buf_clients.obj-name)
                                                               , INPUT "":U
                                                               , INPUT "":U
                                                               , INPUT "":U
                                                               ) .

          run wthres-sheet1-write-line-style in this-procedure  ( INPUT {&wthres_title}
                                                                ) .
            IF p-wth-all
            THEN DO:
               FOR EACH buf_wealth
                  NO-LOCK
                  :
                    RUN print-one-wth IN THIS-PROCEDURE ( INPUT buf_wealth.wth-code
                                                    , INPUT buf_wth-place.obj-type
                                                    , INPUT buf_wth-place.obj-code
                                                    , INPUT buf_wth-place.w-p-code
                                                    , INPUT buf_wealth.wth-name
                                                    , OUTPUT v-qnty-free
                                                    , OUTPUT v-qnty-put
                                                    ) .
                     assign
                        v-qnty-free-total-pl = v-qnty-free-total-pl + v-qnty-free
                        v-qnty-put-total-pl  = v-qnty-put-total-pl  + v-qnty-put
                     .
               END. /* EACH buf_wealth */
            END. /* p-wth-all */
            ELSE DO:
               DO v-count = 1 TO NUM-ENTRIES(p-wth-list)
               on error undo, next
               :
                  find first buf_wealth
                     where   buf_wealth.wth-code = INTEGER(ENTRY(v-count, p-wth-list))
                     no-lock
                     no-error
                     .
                  IF AVAILABLE buf_wealth
                  THEN DO:
                    RUN print-one-wth IN THIS-PROCEDURE ( INPUT buf_wealth.wth-code
                                                    , INPUT buf_wth-place.obj-type
                                                    , INPUT buf_wth-place.obj-code
                                                    , INPUT buf_wth-place.w-p-code
                                                    , INPUT buf_wealth.wth-name
                                                    , OUTPUT v-qnty-free
                                                    , OUTPUT v-qnty-put
                                                    ) .
                     assign
                        v-qnty-free-total-pl = v-qnty-free-total-pl + v-qnty-free
                        v-qnty-put-total-pl  = v-qnty-put-total-pl  + v-qnty-put
                     .
                  END. /* AVAILABLE buf_wealth */
               END. /* DO v-count = 1 TO NUM-ENTRIES(p-wth-list) */
            END. /* NOT p-wth-all */
            run wthres-sheet1-write-line-data in this-procedure  ( INPUT SUBSTITUTE("Итого по &1 (&2):", buf_wth-place.w-p-name, buf_clients.obj-name)
                                                                  , INPUT "":U
                                                                  , INPUT v-qnty-free-total-pl
                                                                  , INPUT v-qnty-put-total-pl
                                                                  ) .
      END. /* EACH  buf_wth-place */
   END. /* p-wth-pl-all */
   ELSE DO:
      DO v-count = 1 TO NUM-ENTRIES(p-wth-pl-list)
      on error undo, next
      :
         find first buf_wth-place
            where RECID(buf_wth-place) = INTEGER(ENTRY(v-count, p-wth-pl-list))
            no-lock
            no-error
            .
         IF AVAILABLE buf_wth-place
         THEN DO:
          find first buf_clients
               where buf_clients.obj-type = buf_wth-place.obj-type
                 and buf_clients.obj-code = buf_wth-place.obj-code
               no-lock
               .
          assign
             v-qnty-free-total-pl = 0
             v-qnty-put-total-pl  = 0
             v-place-name-list = IF v-place-name-list = "":U THEN SUBSTITUTE("&1 (&2)", buf_wth-place.w-p-name, buf_clients.obj-name)
                                                             ELSE SUBSTITUTE("&1, &2 (&3)", v-place-name-list, buf_wth-place.w-p-name, buf_clients.obj-name)
          .
          run wthres-sheet1-write-line-data in this-procedure  ( INPUT SUBSTITUTE("&1 (&2)", buf_wth-place.w-p-name, buf_clients.obj-name)
                                                               , INPUT "":U
                                                               , INPUT "":U
                                                               , INPUT "":U
                                                               ) .

          run wthres-sheet1-write-line-style in this-procedure  ( INPUT {&wthres_title}
                                                                ) .
            IF p-wth-all
            THEN DO:
               FOR EACH buf_wealth
                  NO-LOCK
                  :
                    RUN print-one-wth IN THIS-PROCEDURE ( INPUT buf_wealth.wth-code
                                                    , INPUT buf_wth-place.obj-type
                                                    , INPUT buf_wth-place.obj-code
                                                    , INPUT buf_wth-place.w-p-code
                                                    , INPUT buf_wealth.wth-name
                                                    , OUTPUT v-qnty-free
                                                    , OUTPUT v-qnty-put
                                                    ) .
                     assign
                        v-qnty-free-total-pl = v-qnty-free-total-pl + v-qnty-free
                        v-qnty-put-total-pl  = v-qnty-put-total-pl  + v-qnty-put
                     .
               END. /* EACH buf_wealth */
            END. /* p-wth-all */
            ELSE DO:
               DO v-count = 1 TO NUM-ENTRIES(p-wth-list)
               on error undo, next
               :
                  find first buf_wealth
                     where   buf_wealth.wth-code = INTEGER(ENTRY(v-count, p-wth-list))
                     no-lock
                     no-error
                     .
                  IF AVAILABLE buf_wealth
                  THEN DO:
                    RUN print-one-wth IN THIS-PROCEDURE ( INPUT buf_wealth.wth-code
                                                    , INPUT buf_wth-place.obj-type
                                                    , INPUT buf_wth-place.obj-code
                                                    , INPUT buf_wth-place.w-p-code
                                                    , INPUT buf_wealth.wth-name
                                                    , OUTPUT v-qnty-free
                                                    , OUTPUT v-qnty-put
                                                    ) .
                     assign
                        v-qnty-free-total-pl = v-qnty-free-total-pl + v-qnty-free
                        v-qnty-put-total-pl  = v-qnty-put-total-pl  + v-qnty-put
                     .
                  END. /* AVAILABLE buf_wealth */
               END. /* DO v-count = 1 TO NUM-ENTRIES(p-wth-list) */
            END. /* NOT p-wth-all */
            run wthres-sheet1-write-line-data in this-procedure  ( INPUT SUBSTITUTE("Итого по &1 (&2):", buf_wth-place.w-p-name, buf_clients.obj-name)
                                                                  , INPUT "":U
                                                                  , INPUT v-qnty-free-total-pl
                                                                  , INPUT v-qnty-put-total-pl
                                                                  ) .
         END. /* AVAILABLE buf_wth-place */
      END. /* v-count = 1 TO NUM-ENTRIES(p-wth-pl-list) */
   END. /* NOT p-wth-pl-all */



end. /* do on error */
end procedure. /* fill-temp-table */




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

    run wthres-init in this-procedure.

end. /* do on error */
end procedure. /* open-stream */


/*==========================================================================*/
procedure close-stream :

do
on error undo, return error
:
    run wthres-close in this-procedure .
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
procedure print-one-wth :
define input parameter p-wth-code as integer          no-undo.
define input parameter p-obj-type as character        no-undo.
define input parameter p-obj-code as integer          no-undo.
define input parameter p-w-p-code as integer          no-undo.
define input parameter p-wth-name as character        no-undo.
define output parameter p-qnty-free as integer          no-undo.
define output parameter p-qnty-put as integer          no-undo.

define buffer buf_arh-wth-w-p    for ub.arh-wth-w-p .
define buffer buf_wth-par     for ub.wth-par .

do
on error undo, return error
:

   FOR EACH  buf_wth-par
       WHERE buf_wth-par.wth-code = p-wth-code
       NO-LOCK
       :

       FIND  LAST buf_arh-wth-w-p
            WHERE buf_arh-wth-w-p.obj-type   = p-obj-type
              and buf_arh-wth-w-p.obj-code   = p-obj-code
              and buf_arh-wth-w-p.w-p-code   = p-w-p-code
              and buf_arh-wth-w-p.wth-code   = p-wth-code
              AND buf_arh-wth-w-p.par-code   = buf_wth-par.par-code
              AND buf_arh-wth-w-p.out-code   = {&free-code}
              AND buf_arh-wth-w-p.fact-order <= v-fact-order
            NO-LOCK
            NO-ERROR
            .
       IF AVAILABLE buf_arh-wth-w-p
       THEN DO:
         ASSIGN
            p-qnty-free = buf_arh-wth-w-p.in-qnty - buf_arh-wth-w-p.out-qnty
         .
       END.
       FIND  LAST buf_arh-wth-w-p
            WHERE buf_arh-wth-w-p.obj-type = p-obj-type
              and buf_arh-wth-w-p.obj-code = p-obj-code
              and buf_arh-wth-w-p.w-p-code = p-w-p-code
              and buf_arh-wth-w-p.wth-code = p-wth-code
              AND buf_arh-wth-w-p.par-code = buf_wth-par.par-code
              AND buf_arh-wth-w-p.out-code = {&put-zone}
              AND buf_arh-wth-w-p.fact-order <= v-fact-order
            NO-LOCK
            NO-ERROR
            .
       IF AVAILABLE buf_arh-wth-w-p
       THEN DO:
         ASSIGN
            p-qnty-put = buf_arh-wth-w-p.in-qnty - buf_arh-wth-w-p.out-qnty
         .
       END.
       run wthres-sheet1-write-line-data in this-procedure  ( INPUT p-wth-name
                                                            , INPUT SUBSTITUTE ("&1 &2", buf_wth-par.par-val, buf_wth-par.par-unit)
                                                            , INPUT p-qnty-free
                                                            , INPUT p-qnty-put
                                                            ) .

   END.
end. /* do on error */
end procedure. /* print-one-wth */