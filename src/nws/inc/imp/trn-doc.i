/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Программа импорта документа

Автор: Уханов Дмитрий Юрьевич
Дата создания: 03/23/99
Author: Dmitry Ukhanov
Creation date: 03/23/99

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

do counter = 1 to l-counter
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
on endkey undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:

  { nws/imps-nws.i rec-full }

  assign
    rec-name = entry( 1, rec-full, {&delim-nws} )
    .

  define variable part-key-rec as character no-undo.

  {&test-count}

  CASE rec-name :
    when {&table_doc-line}
    then do:
      create locb-doc-line.
      { nws/impl-nws.i "doc-line" "locb-" }
    end.
    when {&table_doc-line-attr}
    then do:
      create locb-doc-line-attr.
      { nws/impl-nws.i "doc-line-attr" "locb-" }
    end.
    when {&table_inv-doc}
    then do:
      create locb-inv-doc.
      { nws/impl-nws.i "inv-doc" "locb-" }
    end.
    when {&table_trn-doc-sum}
    then do:
      create locb-trn-doc-sum.
      { nws/impl-nws.i "trn-doc-sum" "locb-" }
    end.
    when {&table_inv-line}
    then do:
      create locb-inv-line.
      { nws/impl-nws.i "inv-line" "locb-" }
    end.
    when {&table_doc-line-sum}
    then do:
      create locb-doc-line-sum.
      { nws/impl-nws.i "doc-line-sum" "locb-" }
    end.
    when {&table_gds-dtl}
    then do:
      create locb-gds-dtl.
      { nws/impl-nws.i "gds-dtl" "locb-" }
    end.
    when {&table_parts}
    then do:
      create locb-parts.
      { nws/impl-nws.i "parts" "locb-" }
    end.
    when {&table_parts-root}
    then do:
      create locb-parts-root.
      { nws/impl-nws.i "parts-root" "locb-" }
    end.
    when {&table_parts-attr}
    then do:
      create locb-parts-attr.
      { nws/impl-nws.i "parts-attr" "locb-" }
    end.
    when {&table_parts-supp}
    then do:
      create locb-parts-supp.
      { nws/impl-nws.i "parts-supp" "locb-" }
    end.
    when {&table_doc-prts}
    then do:
      create locb-doc-prts.
      { nws/impl-nws.i "doc-prts" "locb-" }
    end.
    when {&table_doc-pl}
    then do:
      create locb-doc-pl.
      { nws/impl-nws.i "doc-pl" "locb-" }
    end.
    when {&table_doc-pl-attr}
    then do:
      create locb-doc-pl-attr.
      { nws/impl-nws.i "doc-pl-attr" "locb-" }
    end.
    when {&table_doc-pl-pump}
    then do:
      create locb-doc-pl-pump.
      { nws/impl-nws.i "doc-pl-pump" "locb-" }
    end.
    when {&table_doc-attr}
    then do:
      create locbt-doc-attr.
      { nws/impl-nws.i "doc-attr" "locbt-" }
    end.
    when {&table_doc-fbr-gds}
    then do:
      create locb-doc-fbr-gds.
      { nws/impl-nws.i "doc-fbr-gds" "locb-" }
    end.
    when {&table_arh-trn-doc-contract}
    then do:
      create locb-arh-trn-doc-contract.
      { nws/impl-nws.i "arh-trn-doc-contract" "locb-" }
    end.
    when "chk-doc" then do:
      create tdlocb-chk-doc.
      { nws/impl-nws.i "chk-doc" "tdlocb-" }
    end.
    when "chk-gds" then do:
      create tdlocb-chk-gds.
      { nws/impl-nws.i "chk-gds" "tdlocb-" }
    end.
    when "chk-gds-attr" then do:
      create tdlocb-chk-gds-attr.
      { nws/impl-nws.i "chk-gds-attr" "tdlocb-" }
    end.
    when "marking-chk" then do:
      create tdlocb-marking-chk.
      { nws/impl-nws.i "marking-chk" "tdlocb-" }
    end.
    when "chk-doc-attr" then do:
      create tdlocb-chk-doc-attr.
      { nws/impl-nws.i "chk-doc-attr" "tdlocb-" }
    end.
    when "c-chk-doc" then do:
      create tdlocb-c-chk-doc.
      { nws/impl-nws.i "c-chk-doc" "tdlocb-" }
    end.
    when "c-chk-gds" then do:
      create tdlocb-c-chk-gds.
      { nws/impl-nws.i "c-chk-gds" "tdlocb-" }
    end.
    when "c-chk-doc-attr" then do:
      create tdlocb-c-chk-doc-attr.
      { nws/impl-nws.i "c-chk-doc-attr" "tdlocb-" }
    end.
    when {&table_ord-chain}
    then do:
      create locb-ord-chain.
      { nws/impl-nws.i "ord-chain" "locb-" }
    end.
    when {&table_gen-attr}
    then do:
      create locb-gen-attr.
      { nws/impl-nws.i "gen-attr" "locb-" }
    end.
    when {&table_marking-lines}
    then do:
      create locb-marking-lines.
      { nws/impl-nws.i "marking-lines" "locb-" }
    end.

    otherwise do:
      message
        "nws/inc/imp/trn-doc.i: Не предусмотрен прием таблицы " rec-name skip
        "в составе накладной"
        view-as alert-box error.
      return error "nws/inc/imp/trn-doc.i: Не предусмотрен прием таблицы " + rec-name + {&new-line} + "в составе накладной".
    end.
  END CASE.
end.

if not available tb-trn-doc
then do:
  create tb-trn-doc.
end.
else do:
  run trg/nwstdrs.p
    (input tb-trn-doc.doc-code /* p-doc-code       */
    ,input false               /* p-rsrv-direction */
    ) no-error .
  if error-status :error
  then do:
    run write-to-log in this-procedure
      (input substitute("&1 &2", error-status :get-message(1), return-value)
      ) .
    undo, return error substitute("Ошибка при снятии резервов по документу &1", tb-trn-doc.doc-code) .
  end.
end.

/* сохраняем историю изменения документа */
define variable v-old-trn-doc-status as character no-undo .
define variable v-new-trn-doc-status as character no-undo .
define variable v-str                as character no-undo .
define variable par-type             as character no-undo .
define variable v-gds-code           as integer   no-undo .

if tb-trn-doc.status_ = ""
or tb-trn-doc.status_ = ?
then do:
  assign
    v-old-trn-doc-status = ""
  .
end.
else do:
  assign
    v-old-trn-doc-status = tb-trn-doc.status_ + string(tb-trn-doc.flag_, '+/-':u)
  .
end.

assign
  v-new-trn-doc-status = wt-trn-doc.status_ + string(wt-trn-doc.flag_, '+/-':u)
.

run trg/nwsdochs.p
  (input g#db-num                  /* p-db-num       */
  ,input {&nwsdochs_action_update} /* p-action-type  */
  ,input wt-trn-doc.doc-code       /* p-doc-code     */
  ,input wt-trn-doc.obj-type       /* p-obj-type     */
  ,input wt-trn-doc.obj-code       /* p-obj-code     */
  ,input {&table_trn-doc}          /* p-doc-type     */
  ,input wt-trn-doc.ext-doc-type   /* p-ext-doc-type */
  ,input wt-trn-doc.fact-date      /* p-fact-date    */
  ,input wt-trn-doc.fact-qnty      /* p-fact-qnty    */
  ,input wt-trn-doc.fact-base      /* p-fact-base    */
  ,input wt-trn-doc.fact-rubl      /* p-fact-rubl    */
  ,input 0                         /* p-num-line     */
  ,input v-old-trn-doc-status      /* p-old-status   */
  ,input v-new-trn-doc-status      /* p-new-status   */
  ,input g#news-source-db          /* p-pck-db-num   */
  ,input p-pck-num                 /* p-pck-pack-num */
  ,input wt-trn-doc.user-db-num    /* p-user-db-num  */
  ,input wt-trn-doc.user-name      /* p-user-name    */
  ,input wt-trn-doc.sys-date       /* p-sys-date     */
  ,input wt-trn-doc.sys-time       /* p-sys-time     */
  ,input wt-trn-doc.sys-time-int   /* p-sys-time-int */
  ) no-error .
if error-status :error then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error .
end.

/* обновляем документ */
buffer-copy wt-trn-doc to tb-trn-doc .

/* ------------------------------- inv-line ---------------------------------------------- */
for each buf_inv-line exclusive-lock
  where buf_inv-line.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_inv-line.
end.
for each locb-inv-line no-lock
  where locb-inv-line.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_inv-line.
  buffer-copy locb-inv-line to buf_inv-line.
end.
/* ------------------------------- doc-line-sum ---------------------------------------------- */
for each buf_doc-line-sum exclusive-lock
  where buf_doc-line-sum.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_doc-line-sum.
end.
for each locb-doc-line-sum no-lock
  where locb-doc-line-sum.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_doc-line-sum.
  buffer-copy locb-doc-line-sum to buf_doc-line-sum.
end.

/* ------------------------------- inv-doc ---------------------------------------------- */
for each buf_inv-doc exclusive-lock
  where buf_inv-doc.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_inv-doc.
end.
for each locb-inv-doc no-lock
  where locb-inv-doc.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_inv-doc.
  buffer-copy locb-inv-doc to buf_inv-doc.
end.

/* ------------------------------- trn-doc-sum ---------------------------------------------- */
for each buf_trn-doc-sum exclusive-lock
  where buf_trn-doc-sum.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_trn-doc-sum.
end.
for each locb-trn-doc-sum no-lock
  where locb-trn-doc-sum.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_trn-doc-sum.
  buffer-copy locb-trn-doc-sum to buf_trn-doc-sum.
end.

/* ------------------------------- gds-dtl ---------------------------------------------- */
for each buf_gds-dtl exclusive-lock
  where buf_gds-dtl.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_gds-dtl.
end.
for each locb-gds-dtl no-lock
  where locb-gds-dtl.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_gds-dtl.
  buffer-copy locb-gds-dtl to buf_gds-dtl.
end.

/* ------------------------------- doc-line ---------------------------------------------- */
on delete of ub.doc-line override do: end.

for each buf_doc-line exclusive-lock
  where buf_doc-line.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_doc-line.
end.
for each locb-doc-line no-lock
  where locb-doc-line.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_doc-line.
  buffer-copy locb-doc-line to buf_doc-line.
end.

/* ------------------------------- ord-chain ---------------------------------------------- */
on delete of ub.ord-chain override do: end.

for each buf_ord-chain exclusive-lock
  where buf_ord-chain.rel-doc-code = wt-trn-doc.doc-code
    and buf_ord-chain.rel-doc-type = 'trn'
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_ord-chain.
end.


for each locb-ord-chain no-lock
  where locb-ord-chain.rel-doc-code = wt-trn-doc.doc-code
    and locb-ord-chain.rel-doc-type = 'trn'
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:

    find first buf_ord-chain exclusive-lock
      where buf_ord-chain.rel-id = locb-ord-chain.rel-id
        and buf_ord-chain.db-num = locb-ord-chain.db-num
      no-error.
    if available buf_ord-chain then do:
       assign
         buf_ord-chain.rel-id = locb-ord-chain.rel-id * (-1)
       .
    end.

  create buf_ord-chain.
  buffer-copy locb-ord-chain to buf_ord-chain .

end.

/* ------------------------------- parts-attr ---------------------------------------------- */
for each locb-parts-attr no-lock
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  find buf_parts-attr no-lock
    where buf_parts-attr.in-code   = locb-parts-attr.in-code
      and buf_parts-attr.gds-code  = locb-parts-attr.gds-code
      and buf_parts-attr.part-code = locb-parts-attr.part-code
    no-error .
  if not available buf_parts-attr
  then do:
    find first buf_goods no-lock
      where buf_goods.gds-code = locb-parts-attr.gds-code
      .
    for each buf_parts exclusive-lock
      where buf_parts.in-code   = locb-parts-attr.in-code
        and buf_parts.artic     = buf_goods.artic
        and buf_parts.prod-type = buf_goods.prod-type
        and buf_parts.prod-code = buf_goods.prod-code
        and buf_parts.prt-code = locb-parts-attr.prt-code
        and buf_parts.part-code = locb-parts-attr.part-code
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      if buf_parts.contract-code <> locb-parts-attr.contract-code
      then do:
       /*
        undo, return error substitute("Уже существуют партии с кодом договора &1, отличным от кода договора в атрибуте партии &2", buf_parts.contract-code, locb-parts-attr.contract-code)
          + {&new-line}
          + substitute("Номер документа &1", wt-trn-doc.doc-code)
          .
       */
        assign
          buf_parts.contract-code = locb-parts-attr.contract-code
        .
      end.
    end.

    create buf_parts-attr .
    buffer-copy locb-parts-attr to buf_parts-attr .
  end.
end.
/* ------------------------------- parts ---------------------------------------------- */
for each buf_parts exclusive-lock
  where buf_parts.out-code = wt-trn-doc.doc-code
    and buf_parts.obj-code = wt-trn-doc.obj-code
    and buf_parts.obj-type = wt-trn-doc.obj-type
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                    ,input (buffer buf_parts:handle)
                                    ,output part-key-rec).                                

  
  for each buf_gen-attr exclusive-lock
    where buf_gen-attr.p-key = part-key-rec
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    delete buf_gen-attr.
  end.
  delete buf_parts .
end.
for each buf_marking-lines where
      buf_marking-lines.obj-type = wt-trn-doc.obj-type
  and buf_marking-lines.obj-code = wt-trn-doc.obj-code
  and buf_marking-lines.out-code = wt-trn-doc.doc-code
on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) ) :
  delete buf_marking-lines.        
end.   


for each locb-parts no-lock
  where locb-parts.out-code = wt-trn-doc.doc-code
    and locb-parts.obj-code = wt-trn-doc.obj-code
    and locb-parts.obj-type = wt-trn-doc.obj-type
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  { gbl/gds-code.i
    locb-parts.artic
    locb-parts.prod-type
    locb-parts.prod-code
    v-gds-code
  }
  find first buf_parts-attr no-lock
    where buf_parts-attr.in-code   = locb-parts.in-code
      and buf_parts-attr.gds-code  = v-gds-code
      and buf_parts-attr.part-code = locb-parts.part-code
    no-error .
  if available buf_parts-attr
    and locb-parts.contract-code <> buf_parts-attr.contract-code
  then do:
    assign
      varrecalc-arh-trn-doc    = yes
      locb-parts.contract-code = buf_parts-attr.contract-code
    .
  end.
  else do:
    assign
      varrecalc-arh-trn-doc = no
    .
  end.

  create buf_parts .
  buffer-copy locb-parts to buf_parts
  assign
    buf_parts.status_   = yes
    buf_parts.rsrv-free = ?
  .
  

  run gen-key-rec IN THIS-PROCEDURE (  input {&table_parts}
                                    ,input (buffer buf_parts:handle)
                                    ,output part-key-rec).                                

  
  for each locb-gen-attr no-lock
    where locb-gen-attr.p-key = part-key-rec
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    create buf_gen-attr.
    buffer-copy locb-gen-attr to buf_gen-attr.
  end.

  for each locb-marking-lines where
        locb-marking-lines.obj-type = buf_parts.obj-type
    and locb-marking-lines.obj-code = buf_parts.obj-code
    and locb-marking-lines.in-code = buf_parts.in-code
    and locb-marking-lines.out-code = buf_parts.out-code
    and locb-marking-lines.part-code = buf_parts.part-code
    and locb-marking-lines.prt-code = buf_parts.prt-code
    and locb-marking-lines.gds-code = v-gds-code
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    create buf_marking-lines.
    buffer-copy locb-marking-lines to buf_marking-lines.
  end. 


end.
/* ------------------------------- doc-prts ---------------------------------------------- */
for each buf_doc-prts exclusive-lock
  where buf_doc-prts.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_doc-prts.
end.
for each locb-doc-prts no-lock
  where locb-doc-prts.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_doc-prts.
  buffer-copy locb-doc-prts to buf_doc-prts.
end.
/* ------------------------------- doc-pl ---------------------------------------------- */
for each buf_doc-pl exclusive-lock
  where buf_doc-pl.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_doc-pl.
end.
for each locb-doc-pl no-lock
  where locb-doc-pl.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_doc-pl.
  buffer-copy locb-doc-pl to buf_doc-pl.
end.
/* ------------------------------- doc-pl-attr ---------------------------------------------- */
for each buf_doc-pl-attr exclusive-lock
  where buf_doc-pl-attr.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_doc-pl-attr.
end.
for each locb-doc-pl-attr no-lock
  where locb-doc-pl-attr.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_doc-pl-attr.
  buffer-copy locb-doc-pl-attr to buf_doc-pl-attr.
end.
/* ------------------------------- doc-pl-pump ---------------------------------------------- */
for each buf_doc-pl-pump exclusive-lock
  where buf_doc-pl-pump.obj-type = wt-trn-doc.obj-type
    and buf_doc-pl-pump.obj-code = wt-trn-doc.obj-code
    and buf_doc-pl-pump.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_doc-pl-pump.
end.
for each locb-doc-pl-pump no-lock
  where locb-doc-pl-pump.obj-type = wt-trn-doc.obj-type
    and locb-doc-pl-pump.obj-code = wt-trn-doc.obj-code
    and locb-doc-pl-pump.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_doc-pl-pump.
  buffer-copy locb-doc-pl-pump to buf_doc-pl-pump.
end.
/* ------------------------------- doc-line-attr ---------------------------------------------- */
for each buf_doc-line-attr exclusive-lock
  where buf_doc-line-attr.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_doc-line-attr.
end.
for each locb-doc-line-attr no-lock
  where locb-doc-line-attr.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_doc-line-attr.
  buffer-copy locb-doc-line-attr to buf_doc-line-attr.
end.
/* ------------------------------- parts-root ---------------------------------------------- */
for each buf_parts-root exclusive-lock
  where buf_parts-root.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_parts-root.
end.

for each locb-parts-root no-lock
  where locb-parts-root.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_parts-root.
  buffer-copy locb-parts-root to buf_parts-root.
end.
/* ------------------------------- parts-supp ---------------------------------------------- */
for each locb-parts-supp no-lock
  where locb-parts-supp.in-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  find buf_parts-supp no-lock
    where buf_parts-supp.in-code   = locb-parts-supp.in-code
      and buf_parts-supp.artic     = locb-parts-supp.artic
      and buf_parts-supp.prod-type = locb-parts-supp.prod-type
      and buf_parts-supp.prod-code = locb-parts-supp.prod-code
      and buf_parts-supp.part-code = locb-parts-supp.part-code
    no-error.
  if not available buf_parts-supp then do:
    create buf_parts-supp.
    buffer-copy locb-parts-supp to buf_parts-supp.
  end.
end.
/*-------------------------- doc-attr ---------------------------------*/
for each buf_doc-attr exclusive-lock
  where buf_doc-attr.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_doc-attr.
end.
for each locbt-doc-attr no-lock
  where locbt-doc-attr.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_doc-attr.
  buffer-copy locbt-doc-attr to buf_doc-attr.
end.

/* ------------------------------- doc-fbr-gds ---------------------------------------------- */
for each buf_doc-fbr-gds exclusive-lock
  where buf_doc-fbr-gds.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_doc-fbr-gds.
end.
for each locb-doc-fbr-gds no-lock
  where locb-doc-fbr-gds.out-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  create buf_doc-fbr-gds.
  buffer-copy locb-doc-fbr-gds to buf_doc-fbr-gds.
end.

/* ------------------------------- arh-trn-doc-contract ---------------------------------------------- */

for each buf_arh-trn-doc-contract exclusive-lock
  where buf_arh-trn-doc-contract.doc-code  = wt-trn-doc.doc-code
on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete buf_arh-trn-doc-contract.
end.
for each locb-arh-trn-doc-contract no-lock
  where locb-arh-trn-doc-contract.doc-code = wt-trn-doc.doc-code
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  for each buf-rc_arh-trn-doc-contract exclusive-lock
    where buf-rc_arh-trn-doc-contract.host-code     = locb-arh-trn-doc-contract.host-code
      and buf-rc_arh-trn-doc-contract.contract-code = locb-arh-trn-doc-contract.contract-code
      and buf-rc_arh-trn-doc-contract.cli-type      = locb-arh-trn-doc-contract.cli-type
      and buf-rc_arh-trn-doc-contract.cli-code      = locb-arh-trn-doc-contract.cli-code
      and buf-rc_arh-trn-doc-contract.obj-type      = locb-arh-trn-doc-contract.obj-type
      and buf-rc_arh-trn-doc-contract.obj-code      = locb-arh-trn-doc-contract.obj-code
      and buf-rc_arh-trn-doc-contract.ext-doc-type  = locb-arh-trn-doc-contract.ext-doc-type
      and buf-rc_arh-trn-doc-contract.sum-type      = locb-arh-trn-doc-contract.sum-type
      and buf-rc_arh-trn-doc-contract.fact-order    > locb-arh-trn-doc-contract.fact-order
  on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    delete buf-rc_arh-trn-doc-contract.
  end.
end.
if varrecalc-arh-trn-doc = no then do:
  for each locb-arh-trn-doc-contract no-lock
    where locb-arh-trn-doc-contract.doc-code = wt-trn-doc.doc-code
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
  :
    for each locb-rc-arh-trn-doc-contract no-lock
      where locb-rc-arh-trn-doc-contract.host-code     = locb-arh-trn-doc-contract.host-code
        and locb-rc-arh-trn-doc-contract.contract-code = locb-arh-trn-doc-contract.contract-code
        and locb-rc-arh-trn-doc-contract.cli-type      = locb-arh-trn-doc-contract.cli-type
        and locb-rc-arh-trn-doc-contract.cli-code      = locb-arh-trn-doc-contract.cli-code
        and locb-rc-arh-trn-doc-contract.obj-type      = locb-arh-trn-doc-contract.obj-type
        and locb-rc-arh-trn-doc-contract.obj-code      = locb-arh-trn-doc-contract.obj-code
        and locb-rc-arh-trn-doc-contract.ext-doc-type  = locb-arh-trn-doc-contract.ext-doc-type
        and locb-rc-arh-trn-doc-contract.sum-type      = locb-arh-trn-doc-contract.sum-type
        and locb-rc-arh-trn-doc-contract.fact-order    > locb-arh-trn-doc-contract.fact-order
    on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
    :
      create buf-rc_arh-trn-doc-contract.
      buffer-copy locb-rc-arh-trn-doc-contract to buf-rc_arh-trn-doc-contract.
    end.
    create buf_arh-trn-doc-contract.
    buffer-copy locb-arh-trn-doc-contract to buf_arh-trn-doc-contract.
  end.
end.
else do:
  if wt-trn-doc.status_ = {&fact} then do:
    run clntattr-value in p-imp-handle
      ( input wt-trn-doc.obj-type
       ,input wt-trn-doc.obj-code
       ,input  {&attr-arh-trn-doc-contract}
       ,output v-str
       ,output par-type
      ) no-error .
    if error-status:error or v-str = "no" then do:
      run clntattr-write in p-imp-handle
        ( input wt-trn-doc.obj-type
         ,input wt-trn-doc.obj-code
         ,input {&attr-arh-trn-doc-contract}
         ,input "yes":u
        ).
    end.
  end.
end.

run proc-load-trn-doc-inv-chk in this-procedure
  ( input tb-trn-doc.doc-code
  ) no-error.
if error-status :error
then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error substitute("Ошибка при обработке чеков инвентаризации по документу &1", tb-trn-doc.doc-code) .
end.

/* выполняем резервирование по документу */
run trg/nwstdrs.p
  (input tb-trn-doc.doc-code /* p-doc-code       */
  ,input true                /* p-rsrv-direction */
  ) no-error .
if error-status :error
then do:
  run write-to-log in this-procedure
    (input substitute("&1 &2", error-status :get-message(1), return-value )
    ) .
  undo, return error substitute("Ошибка при резервировании по документу &1", tb-trn-doc.doc-code) .
end.

/*запишем атрибут необходимости расчета ДК - пока команда cmdp-dc еще не пришла*/
if g#db-num = 0
and (tb-trn-doc.ext-doc-type = {&TDEDT_Vozvrat_Vnesh} OR
     tb-trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh})
     and tb-trn-doc.d-card       <> ""
     and tb-trn-doc.d-card       <> ?
     and tb-trn-doc.status_ = {&fact}
then do:
  { str/tdat-wrt.i
    tb-trn-doc.doc-code
    ~{&trdcattr-need-saledc~}
    string(1)
  }
end.

if tb-trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} and
   tb-trn-doc.status_      = {&inquiry} and
   tb-trn-doc.flag_        = true
then do:
  run cus/ord-mrz.p ( ? , recid(tb-trn-doc)) no-error .
end.




/* ------------------------ почистим за собой ---------------------------------------------- */

for each locb-doc-line
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-doc-line.
end.

for each locb-ord-chain
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-ord-chain.
end.

for each locb-doc-line-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-doc-line-attr.
end.
for each locb-inv-doc
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-inv-doc.
end.
for each locb-trn-doc-sum
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-trn-doc-sum.
end.

for each locb-inv-line
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-inv-line.
end.
for each locb-doc-line-sum
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-doc-line-sum.
end.

for each locb-gds-dtl
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-gds-dtl.
end.
for each locb-parts
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-parts.
end.
for each locb-parts-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-parts-attr.
end.
for each locb-parts-root
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-parts-root.
end.
for each locb-parts-supp
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-parts-supp.
end.
for each locb-doc-prts
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-doc-prts.
end.
for each locb-doc-pl
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-doc-pl.
end.
for each locb-doc-pl-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-doc-pl-attr.
end.
for each locb-doc-pl-pump
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-doc-pl-pump.
end.
for each locbt-doc-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locbt-doc-attr.
end.
for each locb-doc-fbr-gds
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-doc-fbr-gds.
end.

for each locb-arh-trn-doc-contract
on error undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-arh-trn-doc-contract.
end.
for each locb-gen-attr
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-gen-attr.
end.
for each locb-marking-lines
on error  undo, return error substitute( "&1. &2&3&4", vss-include-info{&vssseq}, return-value, {&new-line}, error-status :get-message ( 1 ) )
:
  delete locb-marking-lines.
end.
/* $Workfile$ e n d */