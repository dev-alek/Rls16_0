/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

DO counter = 1 TO l-counter
on error  undo, return error
on endkey undo, return error :

  { nws/imps-nws.i rec-full }

  assign
    rec-name = entry( 1, rec-full, {&delim-nws} )
    .

  {&test-count}

  CASE rec-name :
    when "c-doc-line" then do:
      create locb-c-doc-line.
      { nws/impl-nws.i "c-doc-line" "locb-" }
    end.
    when "c-doc-line-attr" then do:
      create locb-c-doc-line-attr.
      { nws/impl-nws.i "c-doc-line-attr" "locb-" }
    end.
    when "c-gds-dtl" then do:
      create locb-c-gds-dtl.
      { nws/impl-nws.i "c-gds-dtl" "locb-" }
    end.
    when "c-parts" then do:
      create locb-c-parts.
      { nws/impl-nws.i "c-parts" "locb-" }
    end.
    when "c-parts-attr" then do:
      create locb-c-parts-attr.
      { nws/impl-nws.i "c-parts-attr" "locb-" }
    end.
    when "c-parts-root" then do:
      create locb-c-parts-root.
      { nws/impl-nws.i "c-parts-root" "locb-" }
    end.
    when "c-doc-prts" then do:
      create locb-c-doc-prts.
      { nws/impl-nws.i "c-doc-prts" "locb-" }
    end.
    when "c-doc-pl" then do:
      create locb-c-doc-pl.
      { nws/impl-nws.i "c-doc-pl" "locb-" }
    end.
    when "c-doc-pl-pump" then do:
      create locb-c-doc-pl-pump.
      { nws/impl-nws.i "c-doc-pl-pump" "locb-" }
    end.
    when "c-doc-attr" then do:
      create locbt-c-doc-attr.
      { nws/impl-nws.i "c-doc-attr" "locbt-" }
    end.
    when "c-doc-fbr-gds" then do:
      create locb-c-doc-fbr-gds.
      { nws/impl-nws.i "c-doc-fbr-gds" "locb-" }
    end.
    otherwise do:
      message "nws/inc/imp/c-trn-do.i: Не предусмотрен прием таблицы " rec-name skip
              "в составе накладной"
              view-as alert-box error.
      return error "nws/inc/imp/c-trn-do.i: Не предусмотрен прием таблицы " + rec-name + {&new-line} + "в составе накладной".
    end.
  END CASE.
end.

if not available tb-c-trn-doc then do:
  create tb-c-trn-doc.
end.
buffer-copy wt-c-trn-doc to tb-c-trn-doc.
/* ------------------------------- c-gds-dtl ---------------------------------------------- */
for each buf_c-gds-dtl where buf_c-gds-dtl.doc-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-gds-dtl.
end.
for each locb-c-gds-dtl where locb-c-gds-dtl.doc-code = wt-c-trn-doc.doc-code
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-gds-dtl.
  buffer-copy locb-c-gds-dtl to buf_c-gds-dtl.
end.
/* ------------------------------- c-doc-line ---------------------------------------------- */
on delete of ub.c-doc-line override do: end.
for each buf_c-doc-line where buf_c-doc-line.doc-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-doc-line.
end.
for each locb-c-doc-line where locb-c-doc-line.doc-code = wt-c-trn-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-doc-line.
  buffer-copy locb-c-doc-line to buf_c-doc-line.
end.
/* ------------------------------- c-parts ---------------------------------------------- */
for each buf_c-parts where buf_c-parts.out-code = wt-c-trn-doc.doc-code
                       and buf_c-parts.obj-code = wt-c-trn-doc.obj-code
                       and buf_c-parts.obj-type = wt-c-trn-doc.obj-type
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-parts.
end.
for each locb-c-parts where locb-c-parts.out-code = wt-c-trn-doc.doc-code
                        and locb-c-parts.obj-code = wt-c-trn-doc.obj-code
                        and locb-c-parts.obj-type = wt-c-trn-doc.obj-type
                      no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-parts.
  buffer-copy locb-c-parts to buf_c-parts
    assign
      buf_c-parts.status_   = no
      buf_c-parts.rsrv-free = ?
    .
end.
/* ------------------------------- c-doc-prts ---------------------------------------------- */
for each buf_c-doc-prts where buf_c-doc-prts.out-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-doc-prts.
end.
for each locb-c-doc-prts where locb-c-doc-prts.out-code = wt-c-trn-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-doc-prts.
  buffer-copy locb-c-doc-prts to buf_c-doc-prts.
end.
/* ------------------------------- c-doc-pl ---------------------------------------------- */
for each buf_c-doc-pl where buf_c-doc-pl.out-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-doc-pl.
end.
for each locb-c-doc-pl where locb-c-doc-pl.out-code = wt-c-trn-doc.doc-code
                     no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-doc-pl.
  buffer-copy locb-c-doc-pl to buf_c-doc-pl.
end.
/* ------------------------------- c-doc-pl-pump ---------------------------------------------- */
for each buf_c-doc-pl-pump where buf_c-doc-pl-pump.obj-type = wt-c-trn-doc.obj-type
                             and buf_c-doc-pl-pump.obj-code = wt-c-trn-doc.obj-code
                             and buf_c-doc-pl-pump.out-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-doc-pl-pump.
end.
for each locb-c-doc-pl-pump  where locb-c-doc-pl-pump.obj-type = wt-c-trn-doc.obj-type
                               and locb-c-doc-pl-pump.obj-code = wt-c-trn-doc.obj-code
                               and locb-c-doc-pl-pump.out-code = wt-c-trn-doc.doc-code
                             no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-doc-pl-pump.
  buffer-copy locb-c-doc-pl-pump to buf_c-doc-pl-pump.
end.
/* ------------------------------- c-doc-line-attr ---------------------------------------------- */
for each buf_c-doc-line-attr where buf_c-doc-line-attr.doc-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-doc-line-attr.
end.
for each locb-c-doc-line-attr where locb-c-doc-line-attr.doc-code = wt-c-trn-doc.doc-code
                            no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-doc-line-attr.
  buffer-copy locb-c-doc-line-attr to buf_c-doc-line-attr.
end.
/* ------------------------------- c-parts-attr ---------------------------------------------- */
for each locb-c-parts-attr where locb-c-parts-attr.in-code = wt-c-trn-doc.doc-code
                         no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  find buf_c-parts-attr no-lock
    where buf_c-parts-attr.chip-num  = locb-c-parts-attr.chip-num
      and buf_c-parts-attr.in-code   = locb-c-parts-attr.in-code
      and buf_c-parts-attr.gds-code  = locb-c-parts-attr.gds-code
      and buf_c-parts-attr.part-code = locb-c-parts-attr.part-code
    no-error .
  if not available buf_c-parts-attr
  then do:
    create buf_c-parts-attr.
    buffer-copy locb-c-parts-attr to buf_c-parts-attr.
  end.
end.
/* ------------------------------- c-parts-root ---------------------------------------------- */
for each buf_c-parts-root where buf_c-parts-root.doc-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-parts-root.
end.
for each locb-c-parts-root where locb-c-parts-root.doc-code = wt-c-trn-doc.doc-code
                            no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-parts-root.
  buffer-copy locb-c-parts-root to buf_c-parts-root.
end.

/*-------------------------------- c-doc-attr   -----------------------------------------------*/
for each buf_c-doc-attr where buf_c-doc-attr.doc-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-doc-attr.
end.
for each locbt-c-doc-attr where locbt-c-doc-attr.doc-code = wt-c-trn-doc.doc-code
                       no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-doc-attr.
  buffer-copy locbt-c-doc-attr to buf_c-doc-attr.
end.

/* ------------------------------- c-doc-fbr-gds ---------------------------------------------- */
for each buf_c-doc-fbr-gds where buf_c-doc-fbr-gds.out-code = wt-c-trn-doc.doc-code
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete buf_c-doc-fbr-gds.
end.
for each locb-c-doc-fbr-gds where locb-c-doc-fbr-gds.out-code = wt-c-trn-doc.doc-code
                     no-lock
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  create buf_c-doc-fbr-gds.
  buffer-copy locb-c-doc-fbr-gds to buf_c-doc-fbr-gds.
end.


/* ------------------------ почистим за собой ---------------------------------------------- */

for each locb-c-doc-line
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-line.
end.
for each locb-c-doc-line-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-line-attr.
end.
for each locb-c-gds-dtl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-gds-dtl.
end.
for each locb-c-parts
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-parts.
end.
for each locb-c-parts-root
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-parts-root.
end.

for each locb-c-parts-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-parts-attr.
end.
for each locb-c-doc-prts
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-prts.
end.
for each locb-c-doc-pl
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-pl.
end.
for each locb-c-doc-pl-pump
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-pl-pump.
end.
for each locbt-c-doc-attr
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locbt-c-doc-attr.
end.
for each locb-c-doc-fbr-gds
on error  undo, return error
on stop   undo, return error
on endkey undo, return error :
  delete locb-c-doc-fbr-gds.
end.



/* $Workfile$ e n d */