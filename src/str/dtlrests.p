block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: dtlrests.p $
$Archive: str/dtlrests.p $

Процедура сбора информации по отрицательным остаткам по продаже

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/26/06
Author: Bakhtadze Natalya
Creation date: 04/26/06

*/

define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter from-close as logical.
define input parameter p-method as character no-undo .
define input parameter p-all-goods as logical no-undo .
define input parameter p-is-catering like ub.shop.is-catering no-undo .
define input parameter p-is-tpsi-obj as logical no-undo .
define input parameter p-neg-tpsi-weight as logical no-undo .
define input parameter p-neg-tpsi-qnty as decimal no-undo .
define input parameter p-neg-tpsi-oper as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: dtlrests.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/dtlrests.p $":U .
define variable vss-description as character no-undo init "Процедура сбора информации по отрицательным остаткам по продаже".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }
{ str/lib-def.i }
{ str/tpsidoc.i "shared" }
{ str/dtl-rest.i " " "DEF" }
{ str/dtlrestm.i " shared " }
{ gbl/cur-time.i }
{ gbl/waitfram.i }
{ str/trdcalib.i }

/*all - ошибки и по партиям и по признакам*/
/*parts - ошибки по партиям*/
/*dtl - ошибки по признакам*/
define buffer buf_inkas  for ub.inkas .
define buffer b-goods for ub.goods.
define buffer buf_gds-prt for ub.gds-prt.
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
define buffer buf_shop for ub.shop .
define variable out-dir-doc-code as character no-undo .
define variable in-dir-doc-code as character no-undo .
define variable free-qnty as dec no-undo.
define variable res-ras-qnty as dec no-undo.
define variable res-voz-qnty as dec no-undo.
define variable out-qnty as dec no-undo.
define variable res-ras-born-qnty as dec no-undo.
define variable res-voz-born-qnty as dec no-undo.
define variable first-gds-dtl as logical init yes.
define variable v-root-code like ub.gds-prt.upper-code no-undo .
define variable is-prt as logical no-undo init no.
define variable conf-par as char no-undo.                  /* для чтения параметра конфигурации */
define variable par-type as char no-undo.
define variable v-is-dish as character no-undo .
define variable v-proprietor-host-code      like ub.clients.host-code no-undo .
define variable v-proprietor-obj-type       like ub.clients.obj-type no-undo .
define variable v-proprietor-obj-code       like ub.clients.obj-code no-undo .
define variable v-other-doc-qnty            like ub.gds-dtl.doc-qnty no-undo .
define variable v-prop as integer no-undo .
define variable v-weight as logical no-undo .
define buffer buf_gds-dtl for ub.gds-dtl.
define buffer buf_prt-obj for ub.prt-obj.
define buffer buf_parts for ub.parts.
define buffer buf_tt0-gds-dtl for tt0-gds-dtl.
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf_gds-obj for ub.gds-obj.
define buffer buf_units for ub.units.

do
on error undo, return error return-value
:

  find first buf_inkas exclusive-lock where
             buf_inkas.inkas-code = p-inkas-code no-error .
  if not available buf_inkas then do:
    if locked (buf_inkas) then return error ("Продажа" + {&space-char} + p-inkas-code + {&space-char} + "занята").
    else do:
       return error ("Не найдена продажа" + {&space-char} + p-inkas-code).
    end.
  end.
  { gbl/conf-rd.i
  "'is-prt'"
  0
  "''"
  0
  "''"
  "''"
  "''"
  no
  conf-par
  par-type
  no-error
  }
  IF not error-status:error then
  is-prt = (conf-par = "yes").

  find first buf_shop no-lock where
           buf_shop.obj-code = buf_inkas.obj-code.
  assign
  is-prt = is-prt and buf_shop.doc-prt
  .

  if not buf_inkas.status_ = {&fact} then do:
    for each dtl-rests:
      delete dtl-rests.
    end.
    if not from-close then do:
      for each dtl-rests-mark:
        delete dtl-rests-mark.
      end.
    end.
    /*проверка по партиям*/
    find first buf_gds-prt no-lock where
                  buf_gds-prt.root = true
              and buf_gds-prt.node-name = {&empty-scale} no-error .
    if available buf_gds-prt then do:
      assign
        v-root-code = buf_gds-prt.upper-code
      .
    end.
    for each buf_sale-doc where
            buf_sale-doc.inkas-code = p-inkas-code
        and buf_sale-doc.order > 0 :
      if buf_sale-doc.doc-kind = {&sale-add-return-write-off} then NEXT.
      /*для услуг нет отриц остатков*/
      if buf_sale-doc.chr-office = {&gds-office} then next.
      _cycle:
      FOR EACH buf_gds-dtl NO-LOCK WHERE
                buf_gds-dtl.doc-code = buf_sale-doc.doc-code,
          FIRST b-goods NO-LOCK WHERE
                b-goods.artic = buf_gds-dtl.artic AND
                b-goods.prod-type = buf_gds-dtl.prod-type AND
                b-goods.prod-code = buf_gds-dtl.prod-code,
          FIRST ub.bar-code WHERE
                ub.bar-code.gds-code = b-goods.gds-code AND
                ub.bar-code.node-code = buf_gds-dtl.prt-code AND
                ub.bar-code.in-code = "" AND
                ub.bar-code.part-code = "" AND
                ub.bar-code.unit-cli = b-goods.unit-base NO-LOCK
        on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
        :
        find first buf_gds-obj exclusive-lock where
                  buf_gds-obj.obj-type = buf_inkas.obj-type
              and buf_gds-obj.obj-code = buf_inkas.obj-code no-error .
        find first buf_prt-obj WHERE
                  buf_prt-obj.obj-type = buf_inkas.obj-type
              AND buf_prt-obj.obj-code = buf_inkas.obj-code
              AND buf_prt-obj.artic = buf_gds-dtl.artic
              AND buf_prt-obj.prod-type = buf_gds-dtl.prod-type
              AND buf_prt-obj.prod-code = buf_gds-dtl.prod-code
              AND buf_prt-obj.prt-code = buf_gds-dtl.prt-code  NO-LOCK no-error .
        assign
        v-other-doc-qnty = 0
        v-prop = 0
        v-weight = no
        .
        if false /*p-is-catering*/ then do:
        /*для ресторана запрещены отриц остатки*/
        end.
        else do: /*11*/
          /*если это объект член ТПСИ*/
          if p-is-tpsi-obj then do:
            /*найдем владельца*/
            find first buf_tt0-gds-dtl where
                    buf_tt0-gds-dtl.artic     = buf_gds-dtl.artic
                AND  buf_tt0-gds-dtl.prod-type = buf_gds-dtl.prod-type
                AND  buf_tt0-gds-dtl.prod-code = buf_gds-dtl.prod-code
                AND  buf_tt0-gds-dtl.prt-code = buf_gds-dtl.prt-code no-error .
            if available buf_tt0-gds-dtl then do:
              assign
              v-other-doc-qnty = buf_tt0-gds-dtl.doc-qnty.
              .
              if not (buf_tt0-gds-dtl.obj-type = buf_gds-dtl.obj-type
                    and buf_tt0-gds-dtl.obj-code = buf_gds-dtl.obj-code) then do:
                assign
                v-prop = 1
                .
                find first buf_units no-lock where
                          buf_units.unit-name = b-goods.unit-base .
                v-weight = lookup({&WEIGHT}, buf_units.type) > 0.
              end.
            end.
          end.
          if p-all-goods = no
          and b-goods.negative-rest = yes
          and (not p-is-tpsi-obj
              or not available buf_tt0-gds-dtl
              or v-prop = 0)
          then do:
            v-is-dish = string(0).
            if p-is-catering
            and b-goods.negative-rest = yes
            then do:
              { gbl/fgdsobjt.i buf_gds-dtl.obj-type buf_gds-dtl.obj-code b-goods.gds-code "'is-dish=request'" v-is-dish }
            end.
            if integer(v-is-dish) = 0 then do:
              next _cycle.
            end.
          end.
        end. /*11*/
        IF p-method = "parts" and not
            b-goods.prt-root = v-root-code then next _cycle.
        FIND FIRST dtl-rests WHERE
                  dtl-rests.gds-code = b-goods.gds-code AND
                  dtl-rests.prt-code = buf_gds-dtl.prt-code AND
                  dtl-rests.b-code = bar-code.b-code NO-ERROR .
        { gbl/fgdsobjt.i buf_gds-dtl.obj-type buf_gds-dtl.obj-code b-goods.gds-code "'is-dish=request'" v-is-dish }
        if NOT available dtl-rests then do:
          CREATE dtl-rests .
          assign
          dtl-rests.prop =  v-prop
          dtl-rests.weight = v-weight
          dtl-rests.is-neg-tpsi-weight = (p-neg-tpsi-weight and dtl-rests.weight)
          dtl-rests.fbr = integer(v-is-dish)
          dtl-rests.rest-fact-qnty = 0
          dtl-rests.artic = buf_gds-dtl.artic
          dtl-rests.prod-code = buf_gds-dtl.prod-code
          dtl-rests.prod-type = buf_gds-dtl.prod-type
          dtl-rests.prt-code = buf_gds-dtl.prt-code
          dtl-rests.unit-base = b-goods.unit-base
          dtl-rests.b-code = bar-code.b-code
          dtl-rests.gds-code = b-goods.gds-code
          .
        end.  /*not avail dtl-rests*/
        assign
        dtl-rests.rest-fact-qnty = rest-fact-qnty  + buf_sale-doc.msign * (buf_gds-dtl.fact-qnty - v-other-doc-qnty)
        dtl-rests.maybe-qnty = dtl-rests.maybe-qnty + buf_sale-doc.msign * (buf_gds-dtl.fact-qnty - buf_gds-dtl.doc-qnty - v-other-doc-qnty )
        dtl-rests.prt-qnty = (if available buf_prt-obj then buf_prt-obj.fact-qnty else 0)
        dtl-rests.free-qnty = (if available buf_prt-obj then buf_prt-obj.free-qnty else 0)
        dtl-rests.need-qnty = dtl-rests.maybe-qnty
        dtl-rests.is-neg-tpsi-qnty = (dtl-rests.prop > 0 and dtl-rests.need-qnty <= p-neg-tpsi-qnty)
        dtl-rests.ok-prop = (dtl-rests.is-neg-tpsi-qnty or dtl-rests.is-neg-tpsi-weight)
        dtl-rests.ok = ((dtl-rests.prt-qnty - dtl-rests.rest-fact-qnty ) >= 0 AND
                         (dtl-rests.free-qnty - dtl-rests.maybe-qnty ) >= 0
                        )
        dtl-rests.to-view =  (not p-is-tpsi-obj
                              or not available buf_tt0-gds-dtl
                              or dtl-rests.prop = 0
                              or (v-other-doc-qnty > 0 and not dtl-rests.ok)
                              )
        .
        release dtl-rests.
        if p-method = "all":U or p-method = "parts":U then do:
          if false /*p-is-catering*/ then do:
          /*для ресторана запрещены отриц остатки*/
          end.
          else do:
            if p-all-goods = no
            and b-goods.negative-rest = yes
            and (not p-is-tpsi-obj
                or not available buf_tt0-gds-dtl
                or v-prop = 0)
            then do:
              if not (p-is-catering
                      and
                      integer(v-is-dish) > 0
                      ) then do:
                next _cycle.
              end.
            end.
          end.
          assign
          free-qnty = 0
          out-qnty = 0
          res-ras-qnty = 0
          res-voz-qnty = 0
          res-ras-born-qnty = 0
          res-voz-born-qnty = 0.
          FOR EACH Buf_parts WHERE
                  Buf_parts.prod-type = buf_gds-dtl.prod-type AND
                  Buf_parts.prod-code = buf_gds-dtl.prod-code AND
                  Buf_parts.artic     = buf_gds-dtl.artic AND
                  Buf_parts.obj-type  = buf_inkas.obj-type AND
                  Buf_parts.obj-code  = buf_inkas.obj-code AND
                  Buf_parts.status_   = no USE-INDEX artic:
            CASE Buf_parts.out-code:
              when {&free-code} then do:
                free-qnty = free-qnty + Buf_parts.fact-qnty.
              end.
              when {&output-code} then do:
                out-qnty = out-qnty + Buf_parts.fact-qnty.
              end.
              otherwise do:
                if buf_sale-doc.dir = 1 then do:
                  if Buf_parts.out-code = Buf_parts.in-code then
                  res-ras-born-qnty = res-ras-born-qnty + Buf_parts.fact-qnty.
                  else
                  res-ras-qnty = res-ras-qnty + Buf_parts.fact-qnty.
                end.
                if buf_sale-doc.dir = - 1  then do:
                  if Buf_parts.out-code = Buf_parts.in-code and Buf_parts.is-supp = no then
                  res-voz-born-qnty = res-voz-born-qnty + Buf_parts.fact-qnty.
                  else
                  res-voz-qnty = res-voz-qnty + Buf_parts.fact-qnty.
                end.
              end.
            END CASE.
          END. /*for each Buf_parts*/
          IF not (p-is-catering and integer(v-is-dish) > 0)
          AND (free-qnty - res-ras-born-qnty + res-voz-qnty + res-voz-born-qnty >= 0 AND
              out-qnty - res-voz-born-qnty + res-ras-qnty + res-ras-born-qnty >= 0)
      /*                        AND not from-close                */
          then NEXT _cycle.
          ELSE  DO: /*ELSE  DO:*/
            FIND FIRST dtl-rests NO-LOCK WHERE
                        dtl-rests.gds-code = b-goods.gds-code NO-ERROR .
            IF not avail dtl-rests or
            (is-prt AND v-root-code <> b-goods.prt-root) then do:
              { gbl/fgdsobjt.i buf_gds-dtl.obj-type buf_gds-dtl.obj-code b-goods.gds-code "'is-dish=request'" v-is-dish }
              if integer(v-is-dish) = 0
              and  (free-qnty - res-ras-born-qnty + res-voz-qnty + res-voz-born-qnty >= 0 AND
              out-qnty - res-voz-born-qnty + res-ras-qnty + res-ras-born-qnty >= 0) then NEXT _cycle.
              CREATE dtl-rests .
              assign
              dtl-rests.prop =  v-prop
              dtl-rests.weight = v-weight
              dtl-rests.is-neg-tpsi-weight = (p-neg-tpsi-weight and dtl-rests.weight)
              dtl-rests.rest-fact-qnty = 0
              dtl-rests.artic = buf_gds-dtl.artic
              dtl-rests.fbr = integer(v-is-dish)
              dtl-rests.unit-base = b-goods.unit-base
              dtl-rests.prod-code = buf_gds-dtl.prod-code
              dtl-rests.prod-type = buf_gds-dtl.prod-type
              dtl-rests.prt-code = -1
              dtl-rests.rest-fact-qnty = res-ras-qnty
              dtl-rests.maybe-qnty = res-voz-qnty
              dtl-rests.ok = no
              dtl-rests.prt-qnty = buf_sale-doc.msign * (buf_gds-dtl.fact-qnty - buf_gds-dtl.doc-qnty - v-other-doc-qnty)
              dtl-rests.gds-code = b-goods.gds-code
              dtl-rests.need-qnty = dtl-rests.prt-qnty
              .
            END.
            else do:
              if dtl-rests.fbr = 0
              and  (free-qnty - res-ras-born-qnty + res-voz-qnty + res-voz-born-qnty >= 0 AND
              out-qnty - res-voz-born-qnty + res-ras-qnty + res-ras-born-qnty >= 0) then NEXT _cycle.
              assign
              dtl-rests.prt-qnty = dtl-rests.prt-qnty +  buf_sale-doc.msign * (buf_gds-dtl.fact-qnty - buf_gds-dtl.doc-qnty - v-other-doc-qnty)
              dtl-rests.need-qnty = (if dtl-rests.prt-code = -1
                                    then prt-qnty
                                    else dtl-rests.maybe-qnty)
              .
            end.
            assign
            dtl-rests.is-neg-tpsi-qnty = (dtl-rests.prop > 0 and dtl-rests.need-qnty <= p-neg-tpsi-qnty)
            dtl-rests.ok-prop = (dtl-rests.is-neg-tpsi-qnty or dtl-rests.is-neg-tpsi-weight)
            dtl-rests.to-view =  (not p-is-tpsi-obj
                                  or dtl-rests.prop = 0
                                  or (v-other-doc-qnty > 0
                                      and
                                      not  (free-qnty - res-ras-born-qnty + res-voz-qnty + res-voz-born-qnty >= 0 AND
                                      out-qnty - res-voz-born-qnty + res-ras-qnty + res-ras-born-qnty >= 0)
                                  ))
            .
          END.
        end. /*if p-method = "all":U or p-method = "parts":U then do:`*/
      END. /*for each buf_gds-dtl*/
    end. /*for each buf_sale-doc*/
  end. /*stats = fact*/
end. /*doe*/