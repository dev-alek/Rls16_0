block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: exp-sap-sng.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/exp-sap-sng.p $":U .
define variable vss-description as character no-undo init "Передача данных в SAP СНГ".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define input parameter p_xml as character no-undo.
define input parameter p_obj-type as character no-undo.
define input parameter p_obj-code as integer no-undo.
define input parameter p_shift-num as integer no-undo.
define input parameter p_shift-date as date no-undo.
define input parameter p_agregation_nds as logical no-undo.
define input-output parameter p_operation-id as integer no-undo.
define variable hSAXWriter as handle no-undo.
define variable is-petrolium as logical no-undo.
define variable is-pieces as logical no-undo.
define variable v-host-code as integer no-undo.
define variable v-ser-code as integer no-undo.
define variable v-db-num like ub.wth-ser.db-num no-undo.
define variable v-stts as integer no-undo.
define variable v-wth-code like ub.wth-parts.wth-code no-undo.
define variable v-gds-code like ub.wth-parts.gds-code no-undo.
define variable v-par-code like ub.wth-parts.par-code no-undo.
define variable v-zone as character no-undo.
define variable v-FromDate as date no-undo.
define variable v-ToDate as date no-undo.
define variable v-priceRubl like ub.wth-parts.price-rubl  no-undo.
define variable v-priceBase like ub.wth-parts.price-base  no-undo.
define variable v-range like ub.wth-parts.fact-rangeFrom  no-undo.
define buffer buf_rvs-doc for ub.rvs-doc.
define buffer buf_prev_rvs-doc for ub.rvs-doc.
define buffer buf_rvs-line for ub.rvs-line.
define buffer buf_prev_rvs-line for ub.rvs-line.
define buffer buf_rvs-line-pump for ub.rvs-line-pump.
define buffer buf_prev_rvs-line-pump for ub.rvs-line-pump.
define buffer buf_previous-shift-obj for ub.shift-obj.
define buffer buf_place for ub.place.
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_doc-line for doc-line.
define buffer buf_doc-pl for ub.doc-pl.
define buffer buf_goods for ub.goods.
define buffer buf_chk-doc for ub.chk-doc.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define buffer buf_chk-gds for ub.chk-gds.
define buffer buf_chk-pay for ub.chk-pay.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_tax-rate-gds for ub.tax-rate-gds.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_wealth for ub.wealth.
define buffer buf_wth-par for ub.wth-par.
define temp-table tt_goods-rls no-undo
field bn-mode like ub.chk-gds-pay.pay-code
field sum like ub.chk-gds-pay.tot-r-b
field tax-code like ub.tax-rate-gds.rate-code
field barcode like ub.goods.gds-code
field num as decimal
field price like ub.chk-gds-pay.price-base.
define temp-table tt_office-rls no-undo
field bn-mode like ub.chk-gds-pay.pay-code
field service-id like ub.goods.gds-code
field sum like ub.chk-gds-pay.tot-r-b.
define temp-table tt_petrol-rls no-undo
field bn-mode like ub.chk-gds-pay.pay-code
field gas like ub.goods.gds-code
field preset as decimal
field litres as decimal
field weight as decimal
field price as decimal
field sum as decimal
field trk as integer
field tank as character
field density as decimal
field nozzle as integer.
define temp-table tt_pay-types
field bn-mode like ub.chk-gds-pay.pay-code
field curr-code like ub.chk-gds-pay.curr-code
field card-type as character.
define temp-table tt_pay-cards
field row-id as rowid
field id as character
field card-type as character.
function record_time returns character():
        return substitute("&1-&2-&3 &4", string(year(today),"9999"),
                                         string(month(today),"99"),
                                         string(day(today),"99"),
                                         string(time,"HH:MM:SS":U)).
end function.
find first buf_rvs-doc where buf_rvs-doc.obj-type = p_obj-type
                         and buf_rvs-doc.obj-code = p_obj-code
                         and buf_rvs-doc.shift-num = p_shift-num
                         and buf_rvs-doc.shift-date = p_shift-date
                         and buf_rvs-doc.rvs-type = 'смена':U
                         and buf_rvs-doc.status_ = 'факт':U no-lock no-error.
find last buf_previous-shift-obj where buf_previous-shift-obj.obj-type = p_obj-type
                                   and buf_previous-shift-obj.obj-code = p_obj-code
                                   and ((buf_previous-shift-obj.shift-date = p_shift-date
                                        and buf_previous-shift-obj.shift-num < p_shift-num)
                                    or buf_previous-shift-obj.shift-date < p_shift-date) no-lock no-error.
find first buf_prev_rvs-doc where buf_prev_rvs-doc.obj-type = p_obj-type
                              and buf_prev_rvs-doc.obj-code = p_obj-code
                              and buf_prev_rvs-doc.shift-num = buf_previous-shift-obj.shift-num
                              and buf_prev_rvs-doc.shift-date = buf_previous-shift-obj.shift-date
                              and buf_prev_rvs-doc.rvs-type = 'смена':U
                              and buf_prev_rvs-doc.status_ = 'факт':U no-lock no-error.
if not available buf_prev_rvs-doc then
find first buf_prev_rvs-doc where buf_prev_rvs-doc.obj-type = p_obj-type
                              and buf_prev_rvs-doc.obj-code = p_obj-code
                              and buf_prev_rvs-doc.shift-date = p_shift-date
                              and buf_prev_rvs-doc.shift-num = p_shift-num
                              and buf_prev_rvs-doc.status_ = 'факт':U
                              and buf_prev_rvs-doc.rvs-type = 'контроль':U no-lock.
create sax-writer hSAXWriter.
hSAXWriter:set-output-destination("file":U, p_xml).
hSAXWriter:formatted = true.
hSAXWriter:encoding = "UTF-8":U.
hSAXWriter:standalone = no.
hSAXWriter:start-document().
hSAXWriter:write-external-dtd("oilix-log":U,"oilix-log.dtd":U).
hSAXWriter:start-element("oilix-log":U).
    hSAXWriter:start-element("record":U).
        hSAXWriter:insert-attribute ("time":U, record_time()).
        hSAXWriter:write-empty-element("log-start":U).
            hSAXWriter:insert-attribute("shift":U,string(p_shift-num)) no-error.
            hSAXWriter:insert-attribute("source":U,substitute("azk-&1",p_obj-code)) no-error.
            hSAXWriter:insert-attribute("log-name":U,p_xml) no-error.
            hSAXWriter:insert-attribute("prev-log-name":U,"") no-error.
    hSAXWriter:end-element("record":U).
    for each buf_prev_rvs-line where buf_prev_rvs-line.rvs-code = buf_prev_rvs-doc.rvs-code no-lock:
        find first buf_place where buf_place.obj-type = buf_prev_rvs-line.obj-type
                               and buf_place.obj-code = buf_prev_rvs-line.obj-code
                               and buf_place.pl-code = buf_prev_rvs-line.pl-code no-lock.
        hSAXWriter:start-element("record":U).
            hSAXWriter:insert-attribute ("time":U, record_time()).
            hSAXWriter:write-empty-element("tank-start":U).
                hSAXWriter:insert-attribute("tank":U,buf_place.loc1) no-error.
                hSAXWriter:insert-attribute("litres":U,string(buf_prev_rvs-line.state-measure-qnty)) no-error.
                hSAXWriter:insert-attribute("weight":U,string(buf_prev_rvs-line.state-measure-cli-qnty)) no-error.
                hSAXWriter:insert-attribute("gas":U,string(buf_prev_rvs-line.gds-code)) no-error.
        hSAXWriter:end-element("record":U).
    end.
    for each buf_rvs-line where buf_rvs-line.rvs-code = buf_prev_rvs-doc.rvs-code no-lock:
        find first buf_place where buf_place.obj-type = buf_rvs-line.obj-type
                               and buf_place.obj-code = buf_rvs-line.obj-code
                               and buf_place.pl-code = buf_rvs-line.pl-code no-lock.
        for each buf_rvs-line-pump where buf_rvs-line-pump.rvs-code = buf_rvs-line.rvs-code
                                     and buf_rvs-line-pump.obj-code = buf_rvs-line.obj-code
                                     and buf_rvs-line-pump.obj-type = buf_rvs-line.obj-type
                                     and buf_rvs-line-pump.pl-code = buf_rvs-line.pl-code
                                     and buf_rvs-line-pump.gds-code = buf_rvs-line.gds-code no-lock:
            find first buf_prev_rvs-line-pump where buf_prev_rvs-line-pump.rvs-code = buf_prev_rvs-doc.rvs-code
                                                and buf_prev_rvs-line-pump.obj-type = buf_prev_rvs-doc.obj-type
                                                and buf_prev_rvs-line-pump.obj-code = buf_prev_rvs-doc.obj-code
                                                and buf_prev_rvs-line-pump.pl-code = buf_rvs-line-pump.pl-code
                                                and buf_prev_rvs-line-pump.gds-code = buf_rvs-line-pump.gds-code
                                                and buf_prev_rvs-line-pump.pump-code = buf_rvs-line-pump.pump-code
                                                and buf_prev_rvs-line-pump.nozzle-code = buf_rvs-line-pump.nozzle-code no-lock.
            hSAXWriter:start-element("record":U).
                hSAXWriter:insert-attribute ("time":U, record_time()).
                hSAXWriter:write-empty-element("nozzle-info":U).
                    hSAXWriter:insert-attribute("nozzle":U,string(buf_rvs-line-pump.nozzle-code)) no-error.
                    hSAXWriter:insert-attribute("start-counter":U,string(buf_prev_rvs-line-pump.state-mh-cnt)) no-error.
                    hSAXWriter:insert-attribute("end-counter":U,string(buf_rvs-line-pump.state-mh-cnt)) no-error.
                    hSAXWriter:insert-attribute("litres":U,string(buf_rvs-line-pump.state-mh-qnty)) no-error.
                    hSAXWriter:insert-attribute("tank":U,buf_place.loc1) no-error.
                    hSAXWriter:insert-attribute("trk":U,string(buf_rvs-line-pump.pump-code)) no-error.
            hSAXWriter:end-element("record":U).
        end.
    end.
    for each buf_rvs-line where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code no-lock:
        find first buf_place where buf_place.obj-type = buf_rvs-line.obj-type
                               and buf_place.obj-code = buf_rvs-line.obj-code
                               and buf_place.pl-code = buf_rvs-line.pl-code no-lock.
        hSAXWriter:start-element("record":U).
            hSAXWriter:insert-attribute ("time":U, record_time()).
            hSAXWriter:write-empty-element("tank-end":U).
                hSAXWriter:insert-attribute("tank":U,buf_place.loc1) no-error.
                hSAXWriter:insert-attribute("level":U,left-trim(string(buf_rvs-line.state-level-petrol,">>>>>>> >>>>>9.999"))) no-error.
                hSAXWriter:insert-attribute("litres":U,left-trim(string(buf_rvs-line.state-measure-qnty,">>>>>>>>>>>>9.999"))) no-error.
                hSAXWriter:insert-attribute("weight":U,left-trim(string(buf_rvs-line.state-measure-cli-qnty,">>>>>>>>>>>>9.999"))) no-error.
                hSAXWriter:insert-attribute("lms-level":U,left-trim(string(buf_rvs-line.state-level-total,">>>>>>>>>>>>9.999"))) no-error.
                hSAXWriter:insert-attribute("lms-litres":U,left-trim(string(buf_rvs-line.measure-qnty,">>>>>>>>>>>>9.999"))) no-error.
                hSAXWriter:insert-attribute("lms-water":U,left-trim(string(buf_rvs-line.brutto-qnty - buf_rvs-line.measure-qnty,">>>>>>>>>>>>9.999"))) no-error.
                hSAXWriter:insert-attribute("lms-density":U,left-trim(string(buf_rvs-line.density,">>>>>>>>>>>>9.999"))) no-error.
                hSAXWriter:insert-attribute("lms-temperature":U,string(buf_rvs-line.temperature)) no-error.
                hSAXWriter:insert-attribute("log-name":U,p_xml) no-error.
                hSAXWriter:insert-attribute("next-log-name":U,"") no-error.
        hSAXWriter:end-element("record":U).
    end.
    for each buf_trn-doc where buf_trn-doc.obj-type = p_obj-type
                           and buf_trn-doc.obj-code = p_obj-code
                           and buf_trn-doc.shift-date = p_shift-date
                           and buf_trn-doc.shift-num = p_shift-num
                           and buf_trn-doc.status_ = 'факт':U
                           and lookup(buf_trn-doc.ext-doc-type, "ie,iv":U,",") > 0 no-lock:
        for each buf_doc-line where buf_doc-line.doc-code = buf_trn-doc.doc-code no-lock:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_doc-line.artic
  ,  input buf_doc-line.prod-type
  ,  input buf_doc-line.prod-code
  , output is-petrolium
  , output is-pieces
  ) .
            if is-petrolium = true then do:
                find first buf_goods where buf_goods.prod-type = buf_doc-line.prod-type
                                       and buf_goods.prod-code = buf_doc-line.prod-code
                                       and buf_goods.artic = buf_doc-line.artic no-lock.
                for each buf_doc-pl where buf_doc-pl.obj-type = p_obj-type
                                      and buf_doc-pl.obj-code = p_obj-code
                                      and buf_doc-pl.out-code = buf_doc-line.doc-code
                                      and buf_doc-pl.gds-code = buf_goods.gds-code no-lock:
                    find first buf_place where buf_place.obj-type = buf_doc-pl.obj-type
                                           and buf_place.obj-code = buf_doc-pl.obj-code
                                           and buf_place.pl-code = buf_doc-pl.pl-code no-lock.
                    hSAXWriter:start-element("record":U).
                        hSAXWriter:insert-attribute ("time":U, record_time()).
                        hSAXWriter:write-empty-element("tank-income":U).
                            hSAXWriter:insert-attribute("tank":U,buf_place.loc1) no-error.
                            hSAXWriter:insert-attribute("ttn-volume":U,left-trim(string(buf_doc-pl.doc-qnty,">>>>>>>>>>>>9.999"))) no-error.
                            hSAXWriter:insert-attribute("ttn-weight":U,left-trim(string(buf_doc-pl.cli-qnty,">>>>>>>>>>>>9.999"))) no-error.
                            hSAXWriter:insert-attribute("temperature":U,string(buf_doc-line.temperature)) no-error.
                            hSAXWriter:insert-attribute("density":U,left-trim(string(buf_doc-line.fact-density,">>>>>>>>>>>>9.999"))) no-error.
                            hSAXWriter:insert-attribute("income-volume":U,string(buf_doc-pl.fact-qnty)) no-error.
                            hSAXWriter:insert-attribute("income-weight":U,string(buf_doc-pl.cli-fact-qnty)) no-error.
                            hSAXWriter:insert-attribute("ttn":U,buf_doc-line.doc-code) no-error.
                    hSAXWriter:end-element("record":U).
                end.
            end.
        end.
    end.
    for each buf_chk-gds-pay where buf_chk-gds-pay.obj-code = p_obj-code
                               and buf_chk-gds-pay.obj-type = p_obj-type
                               and buf_chk-gds-pay.shift-date = p_shift-date
                               and buf_chk-gds-pay.shift-num = p_shift-num no-lock:
        find first buf_bar-code where buf_bar-code.b-code = buf_chk-gds-pay.b-code no-lock.
        case entry(1,buf_chk-gds-pay.line-type,chr(4)) :
            when 'т':U then do:
                find first tt_goods-rls where tt_goods-rls.barcode = buf_bar-code.gds-code
                                          and tt_goods-rls.bn-mode = buf_chk-gds-pay.pay-code no-error.
                if not available(tt_goods-rls) then do:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p_obj-type
  ,input  p_obj-code
  ,output v-host-code
  )  .
                    find last buf_tax-rate-gds where buf_tax-rate-gds.gds-code = buf_bar-code.gds-code
                                                 and buf_tax-rate-gds.tax-code = integer('1':U)
                                                 and buf_tax-rate-gds.host-code = v-host-code
                                                 and buf_tax-rate-gds.obj-code = p_obj-code
                                                 and buf_tax-rate-gds.obj-type = p_obj-type
                                                 and buf_tax-rate-gds.fact-order <= integer(p_shift-date) no-lock no-error.
                    if not available(buf_tax-rate-gds) then
                        find last buf_tax-rate-gds where buf_tax-rate-gds.gds-code  = buf_bar-code.gds-code
                                                     and buf_tax-rate-gds.tax-code  = integer('1':U)
                                                     and buf_tax-rate-gds.host-code  = 0
                                                     and buf_tax-rate-gds.obj-type  = ''
                                                     and buf_tax-rate-gds.obj-code  = 0
                                                     and buf_tax-rate-gds.fact-order <= integer(p_shift-date) no-lock no-error.
                    create tt_goods-rls.
                    assign
                    tt_goods-rls.bn-mode = buf_chk-gds-pay.pay-code
                    tt_goods-rls.tax-code = buf_tax-rate-gds.rate-code
                    tt_goods-rls.barcode = buf_bar-code.gds-code.
                end.
                assign
                tt_goods-rls.sum = tt_goods-rls.sum + buf_chk-gds-pay.tot-r-b
                tt_goods-rls.num = tt_goods-rls.num + buf_chk-gds-pay.eff-doc-qnty
                tt_goods-rls.price = tt_goods-rls.price + buf_chk-gds-pay.price-base * buf_chk-gds-pay.eff-doc-qnty.
            end.
            when 'у':U then do:
                find first tt_office-rls where tt_office-rls.service-id = buf_bar-code.gds-code
                                          and tt_office-rls.bn-mode = buf_chk-gds-pay.pay-code no-error.
                if not available(tt_office-rls) then do:
                    create tt_office-rls.
                    assign
                    tt_office-rls.bn-mode = buf_chk-gds-pay.pay-code
                    tt_office-rls.service-id = buf_bar-code.gds-code.
                end.
                tt_office-rls.sum = tt_office-rls.sum + buf_chk-gds-pay.tot-r-b.
            end.
            when 'топ':U then do:
                find first buf_chk-gds where buf_chk-gds.doc-code = buf_chk-gds-pay.doc-code
                                         and buf_chk-gds.line-num = buf_chk-gds-pay.line-num no-lock no-error.
                find first tt_petrol-rls where tt_petrol-rls.bn-mode = buf_chk-gds-pay.pay-code
                                           and tt_petrol-rls.gas = buf_bar-code.gds-code
                                           and tt_petrol-rls.tank = buf_chk-gds.loc1
                                           and tt_petrol-rls.trk = buf_chk-gds.pump
                                           and tt_petrol-rls.nozzle = buf_chk-gds.nozzle-code no-error.
                find first tt_pay-types where tt_pay-types.bn-mode = tt_petrol-rls.bn-mode
                                          and tt_pay-types.curr-code = buf_chk-gds-pay.curr-code no-error.
                if not available(tt_petrol-rls) then do:
                    create tt_petrol-rls.
                    assign
                    tt_petrol-rls.bn-mode = buf_chk-gds-pay.pay-code
                    tt_petrol-rls.gas = buf_bar-code.gds-code
                    tt_petrol-rls.tank = buf_chk-gds.loc1
                    tt_petrol-rls.trk = buf_chk-gds.pump
                    tt_petrol-rls.nozzle = buf_chk-gds.nozzle-code
                    tt_petrol-rls.density = buf_chk-gds.density no-error.
                    if not available(tt_pay-types) then do:
                        create tt_pay-types.
                        assign
                        tt_pay-types.bn-mode = tt_petrol-rls.bn-mode
                        tt_pay-types.curr-code = buf_chk-gds-pay.curr-code.
                        find first buf_cash-pay where buf_cash-pay.cdpay-code = tt_petrol-rls.bn-mode
                                                  and buf_cash-pay.curr-code = buf_chk-gds-pay.curr-code no-error.
                            if buf_cash-pay.atr128 then tt_pay-types.card-type = 's':U.
                            else do:
                                find first buf_wealth where buf_wealth.wth-code = buf_cash-pay.wth-code no-error.
                                if available(buf_wealth) and buf_wealth.is-ser = 1 then tt_pay-types.card-type = 't':U.
                                else tt_pay-types.card-type = 'o':U.
                            end.
                    end.
                end.
                if tt_pay-types.card-type = 's':U or tt_pay-types.card-type = 't':U then do:
                    create tt_pay-cards.
                    assign
                    tt_pay-cards.id = buf_chk-gds-pay.pay-card
                    tt_pay-cards.card-type = tt_pay-types.card-type
                    tt_pay-cards.row-id = rowid(tt_petrol-rls).
                end.
                assign
                tt_petrol-rls.litres = tt_petrol-rls.litres + buf_chk-gds-pay.eff-doc-qnty
                tt_petrol-rls.preset = tt_petrol-rls.litres
                tt_petrol-rls.sum  = tt_petrol-rls.sum + buf_chk-gds-pay.tot-r-b
                tt_petrol-rls.weight = tt_petrol-rls.litres * tt_petrol-rls.density
                tt_petrol-rls.price = tt_petrol-rls.sum / tt_petrol-rls.litres no-error.
            end.
        end case.
    end.
    for each tt_petrol-rls no-lock:
                hSAXWriter:start-element("record":U).
                    hSAXWriter:insert-attribute ("time":U, record_time()).
                    hSAXWriter:start-element("filling":U).
                        hSAXWriter:insert-attribute("operation-id":U,string(p_operation-id)) no-error.
                        hSAXWriter:insert-attribute("bn-mode":U,string(tt_petrol-rls.bn-mode)) no-error.
                        hSAXWriter:insert-attribute("gas":U,string(tt_petrol-rls.gas)) no-error.
                        hSAXWriter:insert-attribute("preset":U,left-trim(string(tt_petrol-rls.preset,">>>>>>>>>>>>9.999"))) no-error.
                        hSAXWriter:insert-attribute("litres":U,left-trim(string(tt_petrol-rls.litres,">>>>>>>>>>>>9.999"))) no-error.
                        hSAXWriter:insert-attribute("weight":U,left-trim(string(tt_petrol-rls.weight,">>>>>>>>>>>>9.999"))) no-error.
                        hSAXWriter:insert-attribute("price":U,left-trim(string(tt_petrol-rls.price,">>>>>>>>>>>>9.99"))) no-error.
                        hSAXWriter:insert-attribute("sum":U,left-trim(string(tt_petrol-rls.sum,">>>>>>>>>>>>9.99"))) no-error.
                        hSAXWriter:insert-attribute("trk":U,string(tt_petrol-rls.trk)) no-error.
                        hSAXWriter:insert-attribute("tank":U,tt_petrol-rls.tank) no-error.
                        hSAXWriter:insert-attribute("density":U,left-trim(string(tt_petrol-rls.density,">>>>>>>>>>>>9.999"))) no-error.
                        hSAXWriter:insert-attribute("nozzle":U,string(tt_petrol-rls.nozzle)) no-error.
                        p_operation-id = p_operation-id + 1.
                        for each tt_pay-cards where tt_pay-cards.row-id = rowid(tt_petrol-rls) break by tt_pay-cards.card-type:
                            if tt_pay-cards.card-type = 's':U then do:
                                hSAXWriter:write-empty-element("card-info":U).
                                    hSAXWriter:insert-attribute("card",tt_pay-cards.id) no-error.
                            end.
                            if tt_pay-cards.card-type = 't':U then do:
                                run str/wthidnt.p (input tt_pay-cards.id
                                                  ,output v-ser-code
                                                  ,output v-db-num
                                                  ,output v-stts
                                                  ,output v-wth-code
                                                  ,output v-gds-code
                                                  ,output v-par-code
                                                  ,output v-zone
                                                  ,output v-FromDate
                                                  ,output v-ToDate
                                                  ,output v-range) no-error.
                                find first buf_wth-par where buf_wth-par.wth-code = v-wth-code
                                                         and buf_wth-par.par-code = v-par-code no-lock no-error.
                                hSAXWriter:start-element("ticket-info-list":U).
                                    hSAXWriter:write-empty-element("ticket-info":U).
                                        hSAXWriter:insert-attribute("id":U,tt_pay-cards.id) no-error.
                                        hSAXWriter:insert-attribute("litres":U,left-trim(string(buf_wth-par.par-val,">>>>>>>>>>>>9.999"))) no-error.
                                hSAXWriter:end-element("ticket-info-list":U).
                            end.
                        end.
                    hSAXWriter:end-element("filling":U).
                hSAXWriter:end-element("record":U).
    end.
    for each tt_office-rls no-lock:
        hSAXWriter:start-element("record":U).
            hSAXWriter:insert-attribute ("time":U, record_time()).
            hSAXWriter:write-empty-element("service":U).
                hSAXWriter:insert-attribute("operation-id":U,string(p_operation-id)) no-error.
                hSAXWriter:insert-attribute("bn-mode":U,string(tt_office-rls.bn-mode)) no-error.
                hSAXWriter:insert-attribute("service-id":U,string(tt_office-rls.service-id)) no-error.
                hSAXWriter:insert-attribute("sum":U,left-trim(string(tt_office-rls.sum,">>>>>>>>>>>>9.99"))) no-error.
                p_operation-id = p_operation-id + 1.
        hSAXWriter:end-element("record":U).
    end.
    if p_agregation_nds then do:
        for each tt_goods-rls break by tt_goods-rls.tax-code by tt_goods-rls.bn-mode:
            accumulate tt_goods-rls.sum (total by tt_goods-rls.bn-mode).
            accumulate tt_goods-rls.num (total by tt_goods-rls.bn-mode).
            if last-of(tt_goods-rls.bn-mode) then do:
                hSAXWriter:start-element("record":U).
                    hSAXWriter:insert-attribute ("time":U, record_time()).
                    hSAXWriter:write-empty-element("payment":U).
                        hSAXWriter:insert-attribute("operation-id":U,string(p_operation-id)) no-error.
                        hSAXWriter:insert-attribute("bn-mode":U,string(tt_goods-rls.bn-mode)) no-error.
                        hSAXWriter:insert-attribute("sum":U,left-trim(string(accum total by tt_goods-rls.bn-mode tt_goods-rls.sum,">>>>>>>>>>>>9.99"))) no-error.
                        p_operation-id = p_operation-id + 1.
                        hSAXWriter:start-element("sellings":U).
                            hSAXWriter:write-empty-element("selling":U).
                                hSAXWriter:insert-attribute("tax-code":U,string(tt_goods-rls.tax-code)) no-error.
                                hSAXWriter:insert-attribute("barcode":U,"") no-error.
                                hSAXWriter:insert-attribute("num":U,left-trim(string(accum total by tt_goods-rls.bn-mode tt_goods-rls.num,">>>>>>>>>>>>9.999"))) no-error.
                                hSAXWriter:insert-attribute("price":U,"") no-error.
                        hSAXWriter:end-element("sellings":U).
                hSAXWriter:end-element("record":U).
            end.
        end.
    end.
    else do:
        for each tt_goods-rls no-lock:
            hSAXWriter:start-element("record":U).
                hSAXWriter:insert-attribute ("time":U, record_time()).
                hSAXWriter:write-empty-element("payment":U).
                    hSAXWriter:insert-attribute("operation-id":U,string(p_operation-id)) no-error.
                    hSAXWriter:insert-attribute("bn-mode":U,string(tt_goods-rls.bn-mode)) no-error.
                    hSAXWriter:insert-attribute("sum":U,left-trim(string(tt_goods-rls.sum,">>>>>>>>>>>>9.99"))) no-error.
                    p_operation-id = p_operation-id + 1.
                    hSAXWriter:start-element("sellings":U).
                        hSAXWriter:write-empty-element("selling":U).
                            hSAXWriter:insert-attribute("tax-code":U,string(tt_goods-rls.tax-code)) no-error.
                            hSAXWriter:insert-attribute("barcode":U,string(tt_goods-rls.barcode)) no-error.
                            hSAXWriter:insert-attribute("num":U,string(tt_goods-rls.num)) no-error.
                            hSAXWriter:insert-attribute("price":U,string(tt_goods-rls.price / tt_goods-rls.num)) no-error.
                    hSAXWriter:end-element("sellings":U).
            hSAXWriter:end-element("record":U).
        end.
    end.
hSAXWriter:end-element("oilix-log":U).
hSAXWriter:end-document().
delete object hSAXWriter no-error.
