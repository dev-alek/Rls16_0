block-level on error undo, throw.
/*

$Revision: 770d6d87d9f3, 729, rls $
$Author: ASMorozov $
$Date: Tue Jul 26 10:34:43 2016 +0300 $
$Workfile: vtrecalc.p $
$Archive: str/vtrecalc.p $

Пересчет последующих инвентаризаций

Автор: Чернова Светлана Александровна
Дата создания: 11/03/06
Author: Svetlana Chernova
Creation date: 11/03/06

*/
/* message "YRA!!"  . */

define input  parameter parparentproc as handle no-undo .
define input  parameter par-recid as recid no-undo .

define variable vss-revision    as character no-undo init "$Revision: 770d6d87d9f3, 729, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Tue Jul 26 10:34:43 2016 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: vtrecalc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/vtrecalc.p $":U .
define variable vss-description as character no-undo init "Пересчет последующих инвентаризаций".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ trg/partslib.i }
{ trg/prdoclib.i }
{ trg/factord.i  }
{ gbl/waitfram.i }
{ str/get-pr.i def }

define buffer inv_trn-doc   for ub.trn-doc  .
define buffer inv_doc-line  for ub.doc-line .
define buffer next_trn-doc  for ub.trn-doc  .
define buffer next_doc-line for ub.doc-line .

define temp-table temp-tt no-undo
field doc-code   as character
field fact-order as decimal
field fact-date  as date
index pi1
      fact-order
      doc-code
.

define temp-table temp-tt-goods no-undo
field doc-code  as character
field artic     as character
field prod-type as character
field prod-code as integer
index pi1
      doc-code
      artic
      prod-type
      prod-code
.
define variable v-fact-order-end as decimal   no-undo .
find first  inv_trn-doc no-lock where
     recid (inv_trn-doc) = par-recid no-error .

/* message 'inv_trn-doc.fact-order' inv_trn-doc.fact-order inv_trn-doc.is-back-date. */
run waitfram-show in this-procedure ( "Проверка последующих инвентаризаций") .
for each temp-tt : delete temp-tt . end.

define variable all-invent as character no-undo .
define variable x-inv as character no-undo .
define variable i as integer   no-undo .
define variable nei as integer   no-undo .

all-invent = {&TDEDT_Inv}               + "," +
             {&TDEDT_Peresort}          + "," +
             {&TDEDT_Corr_Acc_Price}   /* + "," + */
           /*{&TDEDT_Corr_Minus_Parts}  + "," + */    /* не ругатся , а вот пересчитывать нужно ли ? */
           /*{&TDEDT_Chg_Purch_Code} */                /* не ругатся , а вот пересчитывать нужно ли ? */

             .
nei = num-entries( all-invent ).
repeat  i =  1 to nei :
x-inv = entry ( i , all-invent ) .
for each inv_doc-line no-lock where
         inv_doc-line.doc-code = inv_trn-doc.doc-code :
        for each next_doc-line exclusive-lock where
                 next_doc-line.obj-type  = inv_doc-line.obj-type and
                 next_doc-line.obj-code  = inv_doc-line.obj-code and
                 next_doc-line.artic     = inv_doc-line.artic and
                 next_doc-line.prod-type = inv_doc-line.prod-type and
                 next_doc-line.prod-code = inv_doc-line.prod-code and
                 next_doc-line.status_      = {&fact} and
                 next_doc-line.ext-doc-type = x-inv and
                 next_doc-line.fact-order   > inv_trn-doc.fact-order ,
            first next_trn-doc exclusive-lock where
                  next_trn-doc.doc-code     = next_doc-line.doc-code  and
                  next_trn-doc.fact-date   >= inv_trn-doc.fact-date and
                  next_trn-doc.status_      = {&fact}
                  :
                  /* message next_doc-line.ext-doc-type 'next_doc-line.ext-doc-type' . */
                  find first temp-tt where
                             temp-tt.doc-code   = next_trn-doc.doc-code   and
                             temp-tt.fact-order = next_trn-doc.fact-order
                             no-error .
                            if not available temp-tt then do:
                                create temp-tt.
                                assign
                                  temp-tt.doc-code   = next_trn-doc.doc-code
                                  temp-tt.fact-order = next_trn-doc.fact-order
                                  temp-tt.fact-date = next_trn-doc.fact-date
                                .
                            end.
                            create temp-tt-goods.
                            assign
                              temp-tt-goods.doc-code   = next_trn-doc.doc-code
                              temp-tt-goods.artic      = next_doc-line.artic
                              temp-tt-goods.prod-type  = next_doc-line.prod-type
                              temp-tt-goods.prod-code  = next_doc-line.prod-code
                            .
        end.
end.
end.

/* проверка параметра */
define variable v-param-value as character no-undo .
define variable v-param-type  as character no-undo .

find first  temp-tt  no-error .
if available temp-tt then do:
  { gbl/conf-rd.i
    "'inv-fix'"
    0
    "'':U"
    0
    "'':U"
    "'':U"
    "'':U"
    no
    v-param-value
    v-param-type
    no-error
  }
   if error-status :error  then v-param-value = "no" .
   else do:
     if v-param-value <> "yes" then v-param-value = "no" .
   end.
   if v-param-value = "no" then
      return error substitute ( "Документ нельзя закрыть или удалить , так как существует инвентаризация после него &1 &3 (&2) установлен параметр inv-fix=&4"  ,temp-tt.doc-code , temp-tt.fact-order , temp-tt.fact-date /*string( date(int(temp-tt.fact-order)), "99/99/9999")*/ , v-param-value ) .
end.


/* пересчет документов инвентаризаций */
for each temp-tt by temp-tt.fact-order :
    run waitfram-show  in this-procedure
      (input substitute(" Пересчет документа инвентаризации &1  " , temp-tt.doc-code )).
    run proc-recalc in this-procedure ( temp-tt.doc-code  ) .

end.
run waitfram-hide in this-procedure .



procedure proc-recalc :
define input  parameter p-doc-code as character no-undo .
define buffer buf_trn-doc for ub.trn-doc  .
  do
  on error undo, return error return-value
  :
  find first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = p-doc-code no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    "Ошибка поиска"
    view-as alert-box error
  .
    /*run def-factorder in this-procedure (
          input recid(buf_trn-doc) ,
          output v-fact-order-end ). */

    v-fact-order-end =  buf_trn-doc.fact-order.

    for each temp-tt-goods where temp-tt-goods.doc-code = p-doc-code :
       run proc-recalc-line in this-procedure
           ( temp-tt-goods.doc-code  ,
             temp-tt-goods.artic     ,
             temp-tt-goods.prod-type ,
             temp-tt-goods.prod-code
           ).
    end.

    run gbl/calc-trn.p (input parparentproc, input recid(buf_trn-doc)) no-error .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "Ошибка gbl/calc-trn.p"
      view-as alert-box error
    .
     run str/clcsumga.p ( input buf_trn-doc.doc-code ) no-error  .
     if error-status :error then
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "Ошибка str/clcsumga.p"
       view-as alert-box error
     .

  run str/trn-hist.p
    ( buffer buf_trn-doc ,
      input  buf_trn-doc.obj-type ,
      input  buf_trn-doc.obj-code ,
      input  "Пересчет инв."
    ) no-error .

    buf_trn-doc.ps = trim(buf_trn-doc.ps) + substitute(" Пересчитана по накладной № &1 ", inv_trn-doc.doc-code ).
  end.

end procedure. /* proc-recalc */

procedure proc-recalc-line :
define input  parameter p-doc-code  as character no-undo .
define input  parameter p-artic     as character no-undo .
define input  parameter p-prod-type as character no-undo .
define input  parameter p-prod-code as integer   no-undo .
define buffer buf_doc-line for ub.doc-line  .
define buffer buf_gds-dtl  for ub.gds-dtl .

  do
  on error undo, return error return-value
  :
find first buf_doc-line exclusive-lock where
      buf_doc-line.doc-code  = p-doc-code  and
      buf_doc-line.artic     = p-artic     and
      buf_doc-line.prod-type = p-prod-type and
      buf_doc-line.prod-code = p-prod-code no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        ""
        view-as alert-box error
      .

 run doc-qnty-by-factord in this-procedure (
      input  buf_doc-line.obj-type ,
      input  buf_doc-line.obj-code ,
      input  buf_doc-line.artic    ,
      input  buf_doc-line.prod-type,
      input  buf_doc-line.prod-code,
      input   v-fact-order-end     ,
      output  buf_doc-line.doc-qnty ) .

   for each buf_gds-dtl exclusive-lock where
            buf_gds-dtl.doc-code  = buf_doc-line.doc-code  and
            buf_gds-dtl.artic     = buf_doc-line.artic     and
            buf_gds-dtl.prod-type = buf_doc-line.prod-type and
            buf_gds-dtl.prod-code = buf_doc-line.prod-code  :

      run doc-qnty-by-factord-prt in this-procedure (
          input   buf_doc-line.obj-type ,
          input   buf_doc-line.obj-code ,
          input   buf_doc-line.artic    ,
          input   buf_doc-line.prod-type,
          input   buf_doc-line.prod-code,
          input   buf_gds-dtl.prt-code  ,
          input   v-fact-order-end  ,
          output  buf_gds-dtl.fact-qnty  ).
    end.

  end.

end procedure. /* proc-recalc-line */


procedure def-factorder :
define input  parameter par-recid     as recid no-undo .
define output parameter v-fact-order-end as decimal   no-undo .

define variable v-shift-on  as logical   no-undo .
define variable v-shift-end-fact-order as decimal   no-undo .
define variable v-day-end-fact-order   as decimal   no-undo .
define buffer buf_trn-doc for ub.trn-doc  .
  do
  on error undo, return error return-value
  :
find first buf_trn-doc no-lock  where recid(buf_trn-doc) =  par-recid no-error .
{ gbl/objat.i
  buf_trn-doc.obj-type
  buf_trn-doc.obj-code
  "'shift-on=request'"
  v-shift-on
  no-error
}
    if error-status :error then do:
      message
          vss-workfile vss-revision vss-description
          skip "Ошибка при запросе, включены ли смены"
          skip error-status :get-message(1)
          skip return-value
      view-as alert-box error .
      undo, return error .
    end.
        run factord in this-procedure (
              input  buf_trn-doc.fact-date  /* p-fact-date            */
            , input  buf_trn-doc.fact-time  /* p-fact-time            */
            , input  buf_trn-doc.fact-time  /* p-fact-num             */
            , input  buf_trn-doc.shift-date /* p-shift-date           */
            , input  buf_trn-doc.shift-num  /* p-shift-num            */
            , input  v-shift-on              /* p-shift-on             */
            , output v-fact-order-end        /* p-fact-order           */
            , output v-shift-end-fact-order  /* p-shift-end-fact-order */
            , output v-day-end-fact-order    /* p-day-end-fact-order   */
        ) no-error .
     if v-shift-on = true then  v-fact-order-end = v-shift-end-fact-order .
                          else  v-fact-order-end = v-day-end-fact-order .

  end.

end procedure. /* def-factorder */


procedure doc-qnty-by-factord-prt :
/* Подсчет "было" на fact-order документа по признаку  */
define input  parameter par-obj-type  like ub.doc-line.obj-type  no-undo .
define input  parameter par-obj-code  like ub.doc-line.obj-code  no-undo .
define input  parameter par-artic     like ub.doc-line.artic     no-undo .
define input  parameter par-prod-type like ub.doc-line.prod-type no-undo .
define input  parameter par-prod-code like ub.doc-line.prod-code no-undo .
define input  parameter par-prt-code  like ub.prt-obj.prt-code no-undo .
define input  parameter par-fact-order-end as decimal   no-undo .
define output parameter v-doc-qnty    as decimal   no-undo .

  do
  on error undo, return error return-value
  :

v-doc-qnty = 0 .

  run prdoclib-init-prt-obj-by-factord in this-procedure
    ( input par-obj-type,
      input par-obj-code,
      input par-artic,
      input par-prod-type,
      input par-prod-code,
      input par-fact-order-end,
      input false ) .

      v-doc-qnty =  0 .
      for each temp-prt-obj where temp-prt-obj.prt-code  = par-prt-code :
        v-doc-qnty = v-doc-qnty +  temp-prt-obj.fact-qnty .
      end.
end.
end procedure. /* doc-qnty-by-factord */


procedure doc-qnty-by-factord :

/* Подсчет "было" на fact-order документа */
define input  parameter par-obj-type  like ub.doc-line.obj-type  no-undo .
define input  parameter par-obj-code  like ub.doc-line.obj-code  no-undo .
define input  parameter par-artic     like ub.doc-line.artic     no-undo .
define input  parameter par-prod-type like ub.doc-line.prod-type no-undo .
define input  parameter par-prod-code like ub.doc-line.prod-code no-undo .
define input  parameter par-fact-order-end       as decimal   no-undo .
define output parameter v-doc-qnty    as decimal   no-undo .
  do
  on error undo, return error return-value
  :

  for each temp-parts : delete  temp-parts.  end.

  run partslib-init-temp-parts-by-factord in this-procedure
    ( input par-obj-type  ,
      input par-obj-code  ,
      input par-artic     ,
      input par-prod-type ,
      input par-prod-code ,
      input par-fact-order-end ,
      input false ) .

  end.

v-doc-qnty = 0 .
for each temp-parts:
  v-doc-qnty =  v-doc-qnty + temp-parts.fact-qnty .
end.

end procedure. /* doc-qnty-by-factord */