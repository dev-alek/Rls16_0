block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: h-pdfgds.p $
$Archive: ref/h-pdfgds.p $

Процедура для записи истории по строкам ДНЦ

Автор: Чернова Светлана Александровна
Дата создания: 02/07/06
Author: Svetlana Chernova
Creation date: 02/07/06

*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: h-pdfgds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/h-pdfgds.p $":U .
define variable vss-description as character no-undo init "Процедура для записи истории по строкам ДНЦ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }


define parameter buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds .
define input  parameter p-price-sale-doc as decimal   no-undo .
define input-output  parameter p-sec as integer   no-undo .

p-sec = next-value (s-corr-chip, {&db-name_schema}) .

/* message p-price-sale-doc skip p-sec . */

define variable v-today     as date      no-undo.
define variable start-time  as integer   no-undo .


main-block :
do transaction
on error undo main-block, return error
:


run cur-time in this-procedure(output v-today, output start-time).
      create ub.c-price-doc-forming-gds.
      BUFFER-COPY buf_price-doc-forming-gds TO ub.c-price-doc-forming-gds
      assign

        ub.c-price-doc-forming-gds.chip-num           = p-sec
        ub.c-price-doc-forming-gds.price-sale-doc     = p-price-sale-doc
        ub.c-price-doc-forming-gds.corr-time          = start-time
        ub.c-price-doc-forming-gds.corr-user-db-num   = g#db-num
        ub.c-price-doc-forming-gds.corr-user-name     = g#userid
        ub.c-price-doc-forming-gds.corr-date          = v-today
    .

      find first ub.c-price-doc-forming no-lock where
                 ub.c-price-doc-forming.chip-num    = ub.c-price-doc-forming-gds.chip-num and
                 ub.c-price-doc-forming.plt-id      = ub.c-price-doc-forming-gds.plt-id and
                 ub.c-price-doc-forming.plt-db-num  = ub.c-price-doc-forming-gds.plt-db-num and
                 ub.c-price-doc-forming.pdf-id      = ub.c-price-doc-forming-gds.pdf-id and
                 ub.c-price-doc-forming.pdf-db      = ub.c-price-doc-forming-gds.pdf-db no-error .
      if not available ub.c-price-doc-forming then do:
            find first ub.price-doc-forming no-lock where
                      ub.price-doc-forming.plt-id      = ub.c-price-doc-forming-gds.plt-id and
                      ub.price-doc-forming.plt-db-num  = ub.c-price-doc-forming-gds.plt-db-num and
                      ub.price-doc-forming.pdf-id      = ub.c-price-doc-forming-gds.pdf-id and
                      ub.price-doc-forming.pdf-db      = ub.c-price-doc-forming-gds.pdf-db no-error .

            if available ub.price-doc-forming then do :
                create ub.c-price-doc-forming.
                BUFFER-COPY ub.price-doc-forming TO ub.c-price-doc-forming
                assign
                  ub.c-price-doc-forming.chip-num           = ub.c-price-doc-forming-gds.chip-num
                  ub.c-price-doc-forming.corr-time          = start-time
                  ub.c-price-doc-forming.corr-user-db-num   = g#db-num
                  ub.c-price-doc-forming.corr-user-name     = g#userid
                  ub.c-price-doc-forming.corr-date          = v-today
              .
            end.
      end.
end.