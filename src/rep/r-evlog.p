block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-evlog.p $
$Archive: rep/r-evlog.p $

Отчет по логированию кассы TcasH

Автор: Комаров Иван Сергеевич
Дата создания: 11/13/09
Author: Ivan Komarov
Creation date: 11/13/09

*/
/*
Input:

Output:

*/
define input parameter parparentproc   as widget-handle    no-undo .
define input parameter p-event-list    as character        no-undo .
define input parameter p-cd-list       as character        no-undo .
define input parameter p-user-id       as character        no-undo .
define input parameter p-time-start    as integer          no-undo .
define input parameter p-time-end      as integer          no-undo .
define input parameter p-event-type    as character        no-undo .
define input parameter p-supmode-id    as character        no-undo .
define input parameter p-doc-num       as character        no-undo .
define input parameter p-b-codes       as character        no-undo .
define input parameter p-summ-min      as decimal          no-undo .
define input parameter p-summ-max      as decimal          no-undo .
define input parameter p-qnty-min      as decimal          no-undo .
define input parameter p-qnty-max      as decimal          no-undo .
define input parameter p-dc-num        as character        no-undo .
define input parameter p-bc-num        as character        no-undo .
define input parameter p-disc-type     as character        no-undo .
define input parameter p-disc-min      as decimal          no-undo .
define input parameter p-disc-max      as decimal          no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-evlog.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-evlog.p $":U .
define variable vss-description as character no-undo init "Отчет по логированию кассы TcasH".

define variable g#report-num    as integer      no-undo .

define variable v-cash-list         as character         no-undo .
define variable v-events-list       as character         no-undo .
define variable ii                  as integer           no-undo .

define stream out-stream.

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/showinf.i  }

{ cmp/r-page1.i  }
{ cmp/r-pril.i   }
{ gbl/paramls.i  }
{ gbl/waitfram.i }
{ rep/r-evlog.i  }
{ rep/repfrm.i    def } /* Показать окно информации о текущем процессе */
{ gbl/getcntxt.i  def }

do
on error undo, return error
:
   RUN fill-tt         IN THIS-PROCEDURE .

   run open-stream     IN THIS-PROCEDURE .

   run print-header    in this-procedure .

   run print-body      in this-procedure .

   run print-footer    in this-procedure .

   run close-stream    IN THIS-PROCEDURE .

end.


/*==========================================================================*/
procedure fill-tt :
define buffer buf_cd-event-log      for ub.cd-event-log .
define buffer buf_cd-events         for ub.cd-events .
define buffer buf_cash-desk         for ub.cash-desk .
define buffer buf_tt-line           for tt-line .

  DO ii = 1 TO num-entries( p-event-list ) :
              FIND FIRST buf_cd-events
                    WHERE recid( buf_cd-events ) = int(entry( ii, p-event-list ))
                    NO-LOCK
                    no-error
                    .
          ASSIGN
                    v-events-list = IF v-events-list = "" THEN string(buf_cd-events.event-id)
                                                            ELSE v-events-list + "," + STRING(buf_cd-events.event-id)
                  .
  end.
  DO ii = 1 TO num-entries( p-cd-list ) :
              FIND FIRST buf_cash-desk
                    WHERE recid( buf_cash-desk ) = int(entry( ii, p-cd-list ))
                    NO-LOCK
                    no-error
                    .
          ASSIGN
                    v-cash-list = IF v-cash-list = "" THEN string(buf_cash-desk.cash-num)
                                                            ELSE v-cash-list + "," + STRING(buf_cash-desk.cash-num)
                  .
  end.
do
on error undo, return error
:
   FOR EACH  buf_cd-event-log
       WHERE
             (
             (buf_cd-event-log.event-date >  X-date-start)  OR
             (buf_cd-event-log.event-date =  X-date-start AND
              buf_cd-event-log.event-time >= p-time-start)
              )
         AND
             (
             (buf_cd-event-log.event-date <  X-date-end)  OR
             (buf_cd-event-log.event-date =  X-date-end AND
              buf_cd-event-log.event-time <= p-time-end)
             )

         AND
            (
             p-user-id = "":U OR
             buf_cd-event-log.user-id = p-user-id
            )
         AND
            (     p-event-list = "All":U
              OR  p-event-list = "":U
              OR  LOOKUP(string(buf_cd-event-log.event-id), v-events-list, {&comma-char} ) > 0
            )
         AND
            (     p-cd-list = "All":U
              OR  p-cd-list = "":U
              OR  LOOKUP(string(buf_cd-event-log.cash-num), v-cash-list, {&comma-char} ) > 0
            )

         AND
            (     p-event-type = "All":U
              OR  p-event-type = "":U
              OR  buf_cd-event-log.event-type = p-event-type
            )
         AND
            (     p-supmode-id = "":U
              OR  buf_cd-event-log.cd-mode = p-supmode-id
            )
         AND
            (     p-doc-num = "":U
              OR  buf_cd-event-log.doc-code = p-doc-num
            )
         AND
            (     p-b-codes = "":U
              OR  buf_cd-event-log.src-code = p-b-codes
            )
         AND
            (     p-b-codes = "":U
              OR  buf_cd-event-log.src-code = p-b-codes
            )
         AND
            (     (p-summ-min = 0 AND p-summ-max = 0)
              OR  (buf_cd-event-log.tot-sum >= p-summ-min AND
                   buf_cd-event-log.tot-sum <= p-summ-max
                  )
            )
         AND
            (     (p-qnty-min = 0 AND p-qnty-max = 0)
              OR  (buf_cd-event-log.doc-qnty >= p-qnty-min AND
                   buf_cd-event-log.doc-qnty <= p-qnty-max
                  )
            )
         AND
            (     (p-disc-min = 0 AND p-disc-max = 0)
              OR  (buf_cd-event-log.discnt >= p-disc-min AND
                   buf_cd-event-log.discnt <= p-disc-max
                  )
            )
         AND
            (     p-dc-num = "":U
              OR  buf_cd-event-log.d-card   = p-dc-num
            )

         AND
            (     p-bc-num = "":U
              OR  buf_cd-event-log.pay-card = p-bc-num
            )

         AND /* !!! */
            (     p-disc-type = "1"
              OR  buf_cd-event-log.dsc-type = p-disc-type
            )
       NO-LOCK
       :
       /* !!!
                 obj-list
            */

       FIND FIRST buf_cd-events
            WHERE buf_cd-events.event-id = buf_cd-event-log.event-id
            no-lock
            .
       CREATE buf_tt-line.
       BUFFER-COPY buf_cd-event-log TO buf_tt-line.
       ASSIGN
          buf_tt-line.event-name = buf_cd-events.event-name
       .


   END.

end. /* do on error */
end procedure. /* fill-tt */



/*==========================================================================*/
procedure open-stream :

do
on error undo, return error
:

   { gbl/getcntxt.i  get }

   run get-report-num in parparentproc (output g#report-num).

   { gbl/working.i }

   { cmp/open-out.i stream out-stream " " {&CS_PS} }

   put stream out-stream unformatted
         {&new-line}
      + "Печатная форма предназначена только для вывода в Microsoft Excel."
      + {&new-line}
   .
   output stream out-stream close.

   run evlog-init in this-procedure.


end. /* do on error */
end procedure. /* open-stream */




/*==========================================================================*/
procedure print-header :

do on error undo, return error
:
   RUN evlog-write-cell-data IN THIS-PROCEDURE
       ( INPUT {&evlog-date-start}
       , INPUT string(X-date-start, "99/99/9999")
       ) .
   RUN evlog-write-cell-data IN THIS-PROCEDURE
       ( INPUT {&evlog-date-end}
       , INPUT string(X-date-end, "99/99/9999")
       ) .
   RUN evlog-write-cell-data IN THIS-PROCEDURE
       ( INPUT {&evlog-time-start}
       , INPUT STRING(p-time-start, "HH:MM:SS")
       ) .
   RUN evlog-write-cell-data IN THIS-PROCEDURE
       ( INPUT {&evlog-time-end}
       , INPUT STRING(p-time-end, "HH:MM:SS")
       ) .

   IF p-event-list = "":U
   THEN DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-event-list}
         , INPUT "Все"
         ) .
   END.
   ELSE DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-event-list}
         , INPUT v-events-list
         ) .
   END.

   IF p-cd-list = "":U
   THEN DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-cd-list}
         , INPUT "Все"
         ) .
   END.
   ELSE DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-cd-list}
         , INPUT v-cash-list
         ) .
   END.
   IF p-user-id = "":U
   THEN DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-user-id}
         , INPUT "Все"
         ) .
   END.
   ELSE DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-user-id}
         , INPUT p-user-id
         ) .
   END.


   IF p-event-type = "":U
   THEN DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-event-type}
         , INPUT "Все"
         ) .
   END.
   ELSE DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-event-type}
         , INPUT p-event-type
         ) .
   END.
   IF p-supmode-id = "":U
   THEN DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-supmode-id}
         , INPUT "Все"
         ) .
   END.
   ELSE DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-supmode-id}
         , INPUT p-supmode-id
         ) .
   END.
   IF p-doc-num = "":U
   THEN DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-doc-num}
         , INPUT "Все"
         ) .
   END.
   ELSE DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-doc-num}
         , INPUT p-doc-num
         ) .
   END.
   IF p-b-codes = "":U
   THEN DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-b-codes}
         , INPUT "Все"
         ) .
   END.
   ELSE DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-b-codes}
         , INPUT p-b-codes
         ) .
   END.
   IF p-summ-min = 0
   THEN DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-summ-min}
         , INPUT " ":U
         ) .
   END.
   ELSE DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-summ-min}
         , INPUT p-summ-min
         ) .
   END.
   IF p-summ-max = 0
   THEN DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-summ-max}
         , INPUT " "
         ) .
   END.
   ELSE DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-summ-max}
         , INPUT p-summ-max
         ) .
   END.
   IF p-qnty-min = 0
   THEN DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-qnty-min}
         , INPUT " ":U
         ) .
   END.
   ELSE DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-qnty-min}
         , INPUT p-qnty-min
         ) .
   END.
   IF p-qnty-max = 0
   THEN DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-qnty-max}
         , INPUT " ":U
         ) .
   END.
   ELSE DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-qnty-max}
         , INPUT p-qnty-max
         ) .
   END.
   IF p-dc-num = "":U
   THEN DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-dc-num}
         , INPUT "Все"
         ) .
   END.
   ELSE DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-dc-num}
         , INPUT p-dc-num
         ) .
   END.
   IF p-bc-num = "":U
   THEN DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-bc-num}
         , INPUT "Все"
         ) .
   END.
   ELSE DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-bc-num}
         , INPUT p-bc-num
         ) .
   END.
   IF p-disc-type = "":U
   THEN DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-disc-type}
         , INPUT "Все"
         ) .
   END.
   ELSE DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-disc-type}
         , INPUT p-disc-type
         ) .
   END.
   IF p-disc-min = 0
   THEN DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-disc-min}
         , INPUT " ":U
         ) .
   END.
   ELSE DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-disc-min}
         , INPUT p-disc-min
         ) .
   END.
   IF p-disc-max = 0
   THEN DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-disc-max}
         , INPUT " ":U
         ) .
   END.
   ELSE DO:
      RUN evlog-write-cell-data IN THIS-PROCEDURE
         ( INPUT {&evlog-disc-max}
         , INPUT p-disc-max
         ) .
   END.


end. /* do on error */
end procedure. /* print-header */




/*==========================================================================*/
procedure print-body :

do
on error undo, return error
:
    RUN evlog-sheet1-write-line-data IN THIS-PROCEDURE.

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
   run evlog-close in this-procedure .
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