block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: e-xldcdq.p $
$Archive: cmp/e-xldcdq.p $

Заполнение полей временной таблицы для отчета по постоянным клиентам

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

*/

/*вызвается с тремя параметрами компиляции - WHERE-Phrase для chk-doc.d-card и
where-phrase для dis-card
where-phrase для chk-gds.b-code -> bar--code*/
DEFINE INPUT PARAMETER DcardMode as char no-undo.
/*может быть ALL, ONE, LIST*/
DEFINE INPUT PARAMETER FixDCard as char no-undo.
DEFINE INPUT PARAMETER ProdMode as integer no-undo.
/*может быть {g-all} {&g-prod} {&g-grp}*/
DEFINE INPUT PARAMETER FixProdAttr as char no-undo.
DEFINE INPUT PARAMETER TotalOnly as logical no-undo.
DEFINE INPUT PARAMETER StartPoint as date no-undo.
DEFINE INPUT PARAMETER EndPoint as date no-undo.
DEFINE INPUT PARAMETER T-time as logical no-undo.
define input parameter T-zeros as logical no-undo .
define input parameter t-legacy  as logical no-undo .
define input parameter t-subsid  as logical no-undo .
define input parameter par-run-names as character no-undo .
define input parameter p-call-handle as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: e-xldcdq.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cmp/e-xldcdq.p $":U .
define variable vss-description as character no-undo init "Заполнение полей временной таблицы для отчета по постоянным клиентам".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i  }
{ cmp/library.i }
{ cmp/r-page1.i  " " cmp }
{ cmp/dc-list.i dc-list def "shared " }

define variable new-doc  as logical no-undo.
define variable Prodtype as character no-undo.
define variable prodCode as integer no-undo.
define variable v-grp-code like ub.gds-grp.node-code no-undo .
define variable v-gds-code like ub.goods.gds-code no-undo .
DEFINE VARIABLE vproc-check as character no-undo .
define variable v-grp-name like ub.goods.grp-name no-undo .
define variable v-card-num-chr as character no-undo .
define variable ii-grp as integer no-undo .
define variable v-found as logical no-undo .

{ cmp/e-xldcdq.i "SHARED" }

define temp-table obj-host no-undo
FIELd host-code like ub.sysconf.host-code
index pi is primary unique host-code.

define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.
define buffer buf_dis-card for ub.dis-card.
define buffer buf_dcards for dcards.
define buffer X_dis-card for ub.dis-card.

assign
vproc-check = entry(1, par-run-names, {&delim-par})
.

&if "{3}" = "ONE" &then
  &if "{4}" = "{&g-prod}" &then
  assign
  ProdType = Substr(FixProdAttr, 1, 3)
  ProdCode = integer(substr(FixProdAttr, 4))
  .
  &endif
  &if "{4}" = "{&g-grp}" &then
  assign
  v-grp-code = integer(FixProdAttr)
  .
  if valid-handle(p-call-handle)
  and p-call-handle:get-signature ('grplib-get-full-name':U) <> "":U then do:
    run grplib-get-full-name  in p-call-handle (
                                                input v-grp-code
                                                ,output v-grp-name).
  end.
  &endif
  &if "{4}" = "{&g-one}" &then
  assign
  v-gds-code = integer(FixProdAttr)
  .
  &endif
&endif

for each obj-host:
  DELETE obj-host.
end.

create obj-host.
assign
obj-host.host-code = 0
. /*для глобальных карт*/


FOR EACH obj-list :
  /*найдем по каким фирмам мы елозим это зависит от переключателя X_selectobject*/

    if obj-list.obj-type = {&shop} then do:
      find first buf_shop no-lock where
                buf_shop.obj-code = obj-list.obj-code.
      find first obj-host no-lock where
                 obj-host.host-code = buf_shop.host-code no-error .
      if not available obj-host then do:
        create
        obj-host.
        assign
        obj-host.host-code = buf_shop.host-code
        .
      end.
    end.
    else do:
      find first buf_store no-lock where
                buf_store.obj-code = obj-list.obj-code.
      find first obj-host no-lock where
                 obj-host.host-code = buf_store.host-code no-error .
      if not available obj-host then do:
        create
        obj-host.
        assign
        obj-host.host-code = buf_store.host-code
        .
      end.
    end.
   if can-find( FIRST chk-doc WHERE
                      chk-doc.obj-type = obj-list.obj-type AND
                      chk-doc.obj-code = obj-list.obj-code AND
                      chk-doc.chk-date >= StartPoint AND
                      chk-doc.chk-date <= EndPoint AND
                      chk-doc.d-card <> "" AND
                      chk-doc.out-code <> ? ) then DO:
       _chk-doc:
       FOR EACH chk-doc NO-LOCK WHERE
                chk-doc.obj-type = obj-list.obj-type AND
                chk-doc.obj-code = obj-list.obj-code AND
                chk-doc.chk-date >= StartPoint AND
                chk-doc.chk-date <= EndPoint AND
                chk-doc.out-code <> ?
&if (NOT "{1}"  = "TRUE" or NOT "{2}"  = "TRUE") AND "{5}" = "legacy" &then
&else
  &if NOT "{1}"  = "TRUE" &then
              AND  chk-doc.d-card = FixDCard
  &endif
  &if NOT "{2}"  = "TRUE" &then
                          ,
            FIRST dc-list No-LOCK WHERE
                  dc-list.d-card = chk-doc.d-card
  &endif
&endif
                         :
           if chk-doc.d-card = '':U then next _chk-doc.
           if LOOKUP(string(chk-doc.chk-type), {&no-d-card-receipt-codes}) > 0 then next _CHk-doc.
           PROCESS EVENTS .
           ACCUMULATE     chk-doc.doc-code ( COUNT ) .
           if ( ( ACCUM COUNT chk-doc.doc-code ) modulo 10 ) = 0 AND
                ( ACCUM COUNT chk-doc.doc-code ) >= 10 then do:
            if valid-handle(p-call-handle)
            and p-call-handle:get-signature ('waifram-show':U) <> "":U then do:
              run waitfram-show in p-call-handle (
                                                  obj-list.obj-type + " N" + string( obj-list.obj-code ) +
                                                  vproc-check + string( ACCUM COUNT chk-doc.doc-code )
                                                  ).
            end.
           end.
           new-doc = yes.
           IF T-time and NOT can-find(FIRST times where
                                            times.time1  <= chk-doc.chk-time AND
                                            times.time2 >= chk-doc.chk-time) then do:
              NEXT _chk-doc.

           end.
            IF TotalOnly AND PRODMODE = {&g-all} then do:
                   FIND FIRST dcards WHERE dcards.d-card = chk-doc.d-card NO-ERROR .
                   if NOT available dcards then  do:
                    CREATE dcards .
                    assign
                    dcards.date_  = chk-doc.chk-date
                    dcards.d-card = chk-doc.d-card
                    dcards.artic = ""
                    dcards.b-code =  0
                    dcards.prod-type = ""
                    dcards.prod-code = 0
                    dcards.qnty = 0
                    dcards.node-code = 0
                    .
                    if t-legacy or t-subsid then do:
                      find first buf_dis-card no-lock where
                                 buf_dis-card.d-card = chk-doc.d-card no-error .
                      if available buf_dis-card then do:
                        assign
                        v-card-num-chr = (if t-legacy and t-subsid
                                          then buf_dis-card.first-main-card
                                          else (if t-legacy and not t-subsid
                                                then  buf_dis-card.first-card
                                                else  buf_dis-card.main-card
                                                )
                                          ).
                        assign
                        dcards.cli-type-code   = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
                        dcards.card-num        = buf_dis-card.card-num
                        dcards.d-card          = buf_dis-card.d-card
                        dcards.card-num-chr    = v-card-num-chr
                        dcards.main-card       = buf_dis-card.main-card
                        dcards.first-card      = buf_dis-card.first-card
                        dcards.first-main-card = buf_dis-card.first-main-card
                        dcards.cli-type-code   = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
                        .
                      end.
                    end.
                    else do:
                       if chk-doc.cli-type = ?
                       or chk-doc.cli-code = ?
                       or chk-doc.cli-type = '':U
                       or chk-doc.cli-code = 0 then do:
                          find first buf_dis-card no-lock where
                                    buf_dis-card.d-card = chk-doc.d-card no-error .
                          if available buf_dis-card then do:
                            assign
                            dcards.cli-type-code = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
                            .
                          end.
                       end.
                       else do:
                          assign
                          dcards.cli-type-code = chk-doc.cli-type + string(chk-doc.cli-code)
                          .
                       end.
                    end. /*bot legacy*/
                  end. /*IF NOT AVAIL dcards*/
               assign
               dcards.qnty = 0
               dcards.sale-price = 0
               dcards.discount = dcards.discount + chk-doc.discnt
               dcards.sum = dcards.sum + chk-doc.tot-doc
               dcards.counter = (if new-doc then dcards.counter + 1 else dcards.counter ) .
               new-doc = no.
            end. /*IF TOTALONLY*/
            else do:
                _chk:
                FOR EACH chk-gds WHERE chk-gds.doc-code = chk-doc.doc-code,
                    FIRST bar-code No-LOCK WHERE
                          bar-code.b-code = chk-gds.b-code,
                    FIRST goods No-LOCK WHERE
                          goods.gds-code = bar-code.gds-code
&if "{3}"  = "ONE" &then
  &if "{4}" = "{&g-prod}" &then
                        AND goods.prod-type = ProdType
                        AND goods.prod-code = ProdCode
  &endif
  &if "{4}" = "{&g-grp}" &then
                        AND goods.grp-name begins v-grp-name
  &endif
  &if "{4}" = "{&g-one}" &then
                        AND goods.gds-code = v-gds-code
  &endif
&endif
                 :
                 /*списание по расходу не попадает - списание по возврату попадает*/
                   if chk-gds.write-off-code <> ?
                   and chk-gds.write-off-code > 0 then NEXT _CHk.
&if "{3}"  = "LIST" &then
  &if "{4}" = "{&g-prod}" &then
                        IF NOT can-find(first g#cli No-LOCK where
                                              g#cli.obj-type = goods.prod-type AND
                                              g#cli.obj-code = goods.prod-code) then NEXT _chk.
  &endif
  &if "{4}" = "{&g-grp}" &then
      assign
      v-grp-name = ""
      v-found = no
      .
      _ii-grp:
      do ii-grp = 1 to num-entries(goods.grp-name, {&delim-grp}) - 1:
         assign
         v-grp-name = v-grp-name + entry(ii-grp, goods.grp-name, {&delim-grp}) + {&delim-grp}.
         /*message "ii-grp" ii-grp v-grp-name view-as alert-box .*/
         IF can-find(first tmp#grp No-LOCK where
                           tmp#grp.grp-name = v-grp-name) then do:
           assign
           v-found = yes
           .
           leave _ii-grp.
         end.
     end.
     if not v-found then do:
       next _chk.
     end.
  &endif
  &if "{4}" = "{&g-choice}" &then
                        IF NOT can-find(first gds-list No-LOCK where
                                              gds-list.gds-code = goods.gds-code) then NEXT _chk.
  &endif
&endif
                   FIND FIRST dcards WHERE
                              dcards.date_ = chk-doc.chk-date AND
                              dcards.d-card = chk-doc.d-card AND
                              dcards.b-code = bar-code.b-code AND
                              dcards.sale-price = chk-gds.price-base
                                       NO-ERROR .

                if NOT available dcards then do:
                  CREATE dcards .
                  assign
                  dcards.date_  = chk-doc.chk-date
                  dcards.d-card = chk-doc.d-card
                  dcards.artic = goods.artic
                  dcards.b-code = bar-code.b-code
                  dcards.prod-type = goods.prod-type
                  dcards.prod-code = goods.prod-code
                  dcards.qnty = 0
                  dcards.node-code = bar-code.node-code
                  .
                  if t-legacy or t-subsid then do:
                    find first buf_dis-card no-lock where
                                buf_dis-card.d-card = chk-doc.d-card no-error .
                    assign
                    v-card-num-chr = (if t-legacy and t-subsid
                                      then buf_dis-card.first-main-card
                                      else (if t-legacy and not t-subsid
                                            then  buf_dis-card.first-card
                                            else  buf_dis-card.main-card
                                            )
                                      ).
                    assign
                    dcards.d-card          = buf_dis-card.d-card
                    dcards.card-num-chr    = v-card-num-chr
                    dcards.first-card      = buf_dis-card.first-card
                    dcards.main-card       = buf_dis-card.main-card
                    dcards.first-main-card = buf_dis-card.first-main-card
                    dcards.cli-type-code = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
                    dcards.card-num      = buf_dis-card.card-num
                    .
                  end.
                  else do:
                      if chk-doc.cli-type = ?
                      or chk-doc.cli-code = ?
                      or chk-doc.cli-type = '':U
                      or chk-doc.cli-code = 0 then do:
                        find first buf_dis-card no-lock where
                                  buf_dis-card.d-card = chk-doc.d-card no-error .
                        if available buf_dis-card then do:
                          assign
                          dcards.cli-type-code = buf_dis-card.cli-type + string(buf_dis-card.cli-code)
                          .
                        end.
                      end.
                      else do:
                        assign
                        dcards.cli-type-code = chk-doc.cli-type + string(chk-doc.cli-code)
                        .
                      end.
                  end. /*not legacy*/
                end.
                assign
                dcards.qnty = dcards.qnty + chk-gds.doc-qnty
                dcards.sale-price = chk-gds.price-base
                dcards.discount = dcards.discount + ( chk-gds.doc-qnty *
                        ( chk-gds.discnt + ( dcards.sale-price - chk-gds.price-base ) ) )
                dcards.sum = dcards.sum + ( chk-gds.doc-qnty * dcards.sale-price )
                dcards.counter = (if new-doc then dcards.counter + 1 else dcards.counter ) .
                new-doc = no.
            end.
           END.
       END.    /* FOR EACH chk-doc WHERE ... */
/*
   При необходимости учета по покупкам постоянных оптовиков -
   добавить кусок, аналогичный тому, что есть в   x l s e a s o n . w
   отчет по производителю и классификатору
*/
   END. /*IF can-find(first chk-doc)*/
END. /* FOR EACH obj-list : */

if T-zeros then do:
  CASE dcardmode :
&if NOT "{2}"  = "TRUE" &then
    when "LIST":U then do:
      FOR EACH dc-list no-LOCK:
        if not can-find(first dcards no-lock where
                              dcards.d-card = dc-list.d-card) then do:
          CREATE dcards .
          assign
          dcards.date_  = 01/01/1990
          dcards.d-card = dc-list.d-card
          dcards.artic = "":U
          dcards.b-code = 0
          dcards.prod-type = "":U
          dcards.prod-code = 0
          dcards.qnty = 0
          dcards.node-code = 0
          dcards.cli-type-code = dc-list.cli-type + string(dc-list.cli-code)
          dcards.card-num  = dc-list.card-num
          .
          if t-legacy or t-subsid then do:
            assign
            v-card-num-chr = (if t-legacy and t-subsid
                              then dc-list.first-main-card
                              else (if t-legacy and not t-subsid
                                    then  dc-list.first-card
                                    else  dc-list.main-card
                                    )
                              ).
            assign
            dcards.d-card        = dc-list.d-card
            dcards.card-num-chr  = v-card-num-chr
            dcards.first-card    = dc-list.first-card
            dcards.main-card     = dc-list.main-card
            dcards.first-main-card = dc-list.first-main-card
            dcards.cli-type-code = dc-list.cli-type + string(dc-list.cli-code)
            .
          end.
        end.
      END.
    end.
&endif
    when "ALL":U then do:
      for each X_dis-card no-lock,
          first obj-host no-lock where
                obj-host.host-code = X_dis-card.emitent-host-code:
        if not can-find(first dcards no-lock where
                              dcards.d-card = X_dis-card.d-card) then do:
          CREATE dcards .
          assign
          dcards.date_  = 01/01/1990
          dcards.d-card = X_dis-card.d-card
          dcards.artic = "":U
          dcards.b-code = 0
          dcards.prod-type = "":U
          dcards.prod-code = 0
          dcards.qnty = 0
          dcards.node-code = 0
          dcards.cli-type-code = X_dis-card.cli-type + string(X_dis-card.cli-code)
          dcards.card-num  = X_dis-card.card-num
          .
          if t-legacy then do:
            assign
            v-card-num-chr = (if t-legacy and t-subsid
                              then X_dis-card.first-main-card
                              else (if t-legacy and not t-subsid
                                    then  X_dis-card.first-card
                                    else  X_dis-card.main-card
                                    )
                              ).
            assign
            dcards.d-card          = X_dis-card.d-card
            dcards.card-num-chr    = v-card-num-chr
            dcards.first-card      = X_dis-card.first-card
            dcards.main-card       = X_dis-card.main-card
            dcards.first-main-card = X_dis-card.first-main-card
            dcards.cli-type-code = X_dis-card.cli-type + string(X_dis-card.cli-code)
            .
          end.
        end.
        else do:
        end. /*not legacy*/
      end.
    end.
    when "ONE":U then do:
      if not can-find (first dcards no-lock where
                              dcards.d-card = FIXdcard) then do:
          CREATE dcards .
          assign
          dcards.date_  = 01/01/1990
          dcards.d-card = X_dis-card.d-card
          dcards.artic = "":U
          dcards.b-code = 0
          dcards.prod-type = "":U
          dcards.prod-code = 0
          dcards.qnty = 0
          dcards.node-code = 0
          dcards.cli-type-code = X_dis-card.cli-type + string(X_dis-card.cli-code)
          dcards.card-num  = X_dis-card.card-num
          .
        if t-legacy then do:
          assign
          v-card-num-chr = (if t-legacy and t-subsid
                            then X_dis-card.first-main-card
                            else (if t-legacy and not t-subsid
                                  then  X_dis-card.first-card
                                  else  X_dis-card.main-card
                                  )).
          assign
          dcards.d-card          = X_dis-card.d-card
          dcards.card-num-chr    = v-card-num-chr
          dcards.main-card       = X_dis-card.main-card
          dcards.first-main-card = X_dis-card.first-main-card
          dcards.first-card      = X_dis-card.first-card
          dcards.cli-type-code   = X_dis-card.cli-type + string(X_dis-card.cli-code)
          .
        end.
      end.
    end.
  END CASE.
end.

if valid-handle(p-call-handle)
and p-call-handle:get-signature ('waifram-hide':U) <> "":U then do:
  run waitfram-hide in p-call-handle .
end.