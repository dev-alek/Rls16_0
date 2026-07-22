block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: r-vuidcr.p $
$Archive: cus/r-vuidcr.p $

ÎÒ×ÅÒ ÏÎ ÏÎÊÓÏÊÀÌ ÏÎÑÒÎßÍÍÛÕ ÊËÈÅÍÒÎÂ ( Ñ ÄÈÑ.ÊÀÐÒÀÌÈ) äëÿ Lui Vuitton - ñáîð äàííûõ

Àâòîð: Áàõòàäçå Íàòàëüÿ Âèêòîðîâíà
Äàòà ñîçäàíèÿ: 09/23/03
Author: Bakhtadze Natalya
Creation date: 09/23/03

*/

define input parameter parparentproc as widget-handle no-undo .
DEFINE INPUT PARAMETER ProdMode as integer no-undo.
/*ìîæåò áûòü {g-all} {&g-prod} {&g-grp} {&g-choice} {&g-one} */
DEFINE INPUT PARAMETER FixProdAttr as char no-undo.
DEFINE INPUT PARAMETER StartPoint as date no-undo.
DEFINE INPUT PARAMETER EndPoint as date no-undo.
define input parameter p-list as character no-undo .
define input parameter v-proc-check as character no-undo .
define input parameter p-call-handle as handle no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-vuidcr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/r-vuidcr.p $":U .
define variable vss-description as character no-undo init "ÎÒ×ÅÒ ÏÎ ÏÎÊÓÏÊÀÌ ÏÎÑÒÎßÍÍÛÕ ÊËÈÅÍÒÎÂ ( Ñ ÄÈÑ.ÊÀÐÒÀÌÈ) äëÿ Lui Vuitton - ñáîð äàííûõ".
{ cmp/vssrevis.i }

{ cmp/str-glbl.i }
{ cmp/library.i }
{ cmp/r-page1.i }

{ cus/r-vuidcd.i "SHARED" }

define variable Prodtype as char no-undo.
define variable prodCode as integer no-undo.
define variable v-grp-name as character no-undo .
define variable v-gds-code like ub.goods.gds-code no-undo .
define variable v-is-grp as logical no-undo .
define variable v-first-level as character no-undo .


define temp-table obj-host no-undo
FIELd host-code like ub.sysconf.host-code
index pi is primary unique host-code.

define buffer buf_shop for ub.shop.
define buffer buf_store for ub.store.

if p-list = "ONE":U then do:
  CASE prodmode:
    when {&g-prod} then do:
      assign
      ProdType = Substr(FixProdAttr, 1, 3)
      ProdCode = integer(substr(FixProdAttr, 4))
      .
    end.
    when {&g-grp} then do:
      assign
      v-grp-name = FixProdAttr
      .
    end.
    when {&g-one} then do:
      assign
      v-gds-code = integer(FixProdAttr)
      .
    end.
  end case.
end.


for each temp-cards:
  delete temp-cards.
end.

for each temp-gds:
  delete temp-gds.
end.

for each obj-host:
  DELETE obj-host.
end.
create obj-host.
assign
obj-host.host-code = 0
. /*äëÿ ãëîáàëüíûõ êàðò*/

FOR EACH obj-list :
 /*íàéäåì ïî êàêèì ôèðìàì ìû åëîçèì ýòî çàâèñèò îò ïåðåêëþ÷àòåëÿ X_selectobject*/
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
  if can-find( FIRST ub.chk-doc WHERE
                    ub.chk-doc.obj-type = obj-list.obj-type AND
                    ub.chk-doc.obj-code = obj-list.obj-code AND
                    ub.chk-doc.chk-date >= startpoint AND
                    ub.chk-doc.chk-date <= endpoint AND
                    ub.chk-doc.d-card <> "" AND
                    ub.chk-doc.out-code <> ? ) then DO:
    _chk-doc:
    FOR EACH ub.chk-doc NO-LOCK WHERE
            ub.chk-doc.obj-type = obj-list.obj-type AND
            ub.chk-doc.obj-code = obj-list.obj-code AND
            ub.chk-doc.chk-date >= startpoint AND
            ub.chk-doc.chk-date <= endpoint AND
            ub.chk-doc.out-code <> ? ,
        FIRST ub.dis-card No-LOCK WHERE
              ub.dis-card.d-card = ub.chk-doc.d-card:
      if lookup(string(ub.chk-doc.chk-type), {&no-d-card-receipt-codes}) > 0 then next _chk-doc.
      PROCESS EVENTS .
      ACCUMULATE     ub.chk-doc.doc-code ( COUNT ) .
      if ( ( ACCUM COUNT ub.chk-doc.doc-code ) modulo 10 ) = 0 AND
          ( ACCUM COUNT ub.chk-doc.doc-code ) >= 10 then do:
        if valid-handle(p-call-handle)
        and p-call-handle:get-signature ('waifram-show':U) <> "":U then do:
          run waitfram-show in p-call-handle (
                                              obj-list.obj-type + " N" + string( obj-list.obj-code ) +
                                              v-proc-check + string( ACCUM COUNT ub.chk-doc.doc-code )
                                              ).
        end.
      end.
      _gds:
      for each ub.chk-gds no-lock where
              ub.chk-gds.doc-code = ub.chk-doc.doc-code,
          FIRST ub.bar-code No-LOCK WHERE
                ub.bar-code.b-code = ub.chk-gds.b-code,
          FIRST ub.goods No-LOCK WHERE
                ub.goods.gds-code = ub.bar-code.gds-code
                 :
CASE p-list:
  when "ONE":U then do:
    case prodmode:
      when {&g-prod} then do:
        if (not ub.goods.prod-code = prodcode) or (not ub.goods.prod-type = Prodtype) then do:
          NEXT _GDS.
        end.
      end.
      WHEN {&g-grp} then do:
        if (not ub.goods.grp-name begins v-grp-name) then do:
          NEXT _GDS.
        end.
      end.
      when {&g-one} then do:
        if (not ub.goods.gds-code = v-gds-code) then do:
          NEXT _GDS.
        end.
      end.
    end case.
  end.
  when "LIST":U then do:
    case prodmode:
      when {&g-prod} then do:
        IF NOT can-find(first g#cli No-LOCK where
                              g#cli.obj-type = ub.goods.prod-type AND
                              g#cli.obj-code = ub.goods.prod-code) then NEXT _gds.
      end.
      when {&g-grp} then do:
        assign
        v-first-level = substr(ub.goods.grp-name, 1, index(ub.goods.grp-name, {&delim-grp}))
        .
        IF NOT can-find(first tmp#grp No-LOCK where
                              tmp#grp.grp-name begins v-first-level ) then NEXT _gds.
        else do:
          assign
          v-is-grp = no
          .
          for each tmp#grp no-lock where
                   tmp#grp.grp-name begins v-first-level:
            if goods.grp-name begins tmp#grp.grp-name then assign v-is-grp = yes.
          end.
          if not v-is-grp then NEXT _gds.
        end.
      end.
      when {&g-choice} then do:
        IF NOT can-find(first gds-list No-LOCK where
                              gds-list.gds-code = ub.goods.gds-code) then NEXT _gds.
      end.
    end case.
  end.
  otherwise do:
  end.
end CASE.

        create temp-gds.
        assign
        temp-gds.d-card = ub.chk-doc.d-card
        temp-gds.cli-type = ub.dis-card.cli-type
        temp-gds.cli-code = ub.dis-card.cli-code
        temp-gds.gds-code = ub.goods.gds-code
        temp-gds.artic = ub.goods.artic
        temp-gds.prod-type = ub.goods.prod-type
        temp-gds.prod-code = ub.goods.prod-code
        temp-gds.gds-name = ub.goods.gds-name
        temp-gds.src-d-pcnt = (if (ub.chk-doc.src-d-pcnt <> ?)
                               AND (ub.chk-doc.src-d-pcnt <> 0)
                               then ub.chk-doc.src-d-pcnt
                               else round(ub.chk-doc.discnt / ub.chk-doc.tot-doc * 100, 2)
                               )
        temp-gds.chk-date = ub.chk-doc.chk-date
        temp-gds.obj-code = ub.chk-doc.obj-code
        temp-gds.cashier = ub.chk-doc.cashier
        temp-gds.cashier-psn-code = ub.chk-doc.cashier-psn-code
        temp-gds.sales-man = ub.chk-doc.sales-man
        temp-gds.salesman-psn-code = ub.chk-doc.salesman-psn-code
        temp-gds.d-pcnt = round(ub.chk-gds.discnt / ub.chk-gds.price-base * 100, 2)
        temp-gds.doc-qnty = ub.chk-gds.doc-qnty
        temp-gds.price-base = ub.chk-gds.price-base
        temp-gds.discnt = ub.chk-gds.discnt
        temp-gds.cash-rate = ub.chk-doc.cash-rate
        temp-gds.cash-scale = ub.chk-doc.cash-scale
        .
        FIND FIRST temp-cards WHERE
                  temp-cards.d-card = ub.chk-doc.d-card NO-ERROR .
        if NOT available temp-cards then  do:
          CREATE temp-cards .
          assign
          temp-cards.d-card = ub.chk-doc.d-card
          temp-cards.cli-type = ub.dis-card.cli-type
          temp-cards.cli-code = ub.dis-card.cli-code
          temp-cards.last-date = ub.chk-doc.chk-date
          temp-cards.last-time = ub.chk-doc.chk-time
          temp-cards.last-obj-type = ub.chk-doc.obj-type
          temp-cards.last-obj-code = ub.chk-doc.obj-code
          .
        end.
        else do:
          if ub.chk-doc.chk-date > temp-cards.last-date
          OR (ub.chk-doc.chk-date = temp-cards.last-date
              AND
              ub.chk-doc.chk-time >= temp-cards.last-time) then do:
            assign
            temp-cards.last-date = ub.chk-doc.chk-date
            temp-cards.last-time = ub.chk-doc.chk-time
            temp-cards.last-obj-type = ub.chk-doc.obj-type
            temp-cards.last-obj-code = ub.chk-doc.obj-code
            .
          end.
        end.
      END.  /*for each chk-gds*/
    END.    /* FOR EACH chk-doc WHERE ... */
  END. /*IF can-find(first chk-doc)*/
END. /* FOR EACH obj-list : */