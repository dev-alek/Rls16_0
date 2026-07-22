block-level on error undo, throw.
define input parameter p-inkas-code like ub.inkas.inkas-code no-undo .
define input parameter p-ext-doc-type like ub.trn-doc.ext-doc-type no-undo .
define input parameter p-by-pay-desk as logical no-undo .
define input parameter p-by-pay-card-prefix as logical no-undo .
define input parameter p-petrol as logical no-undo .
define input parameter p-goods as logical no-undo .
define input parameter p-services as logical no-undo .
define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision: aea5316774be, 0, rls $":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author: expertek $":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile: bgepych2.p $":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive: bge/bgepych2.p $":U.
define variable vss-description AS CHAR NO-UNDO INIT "$Разброс чеков по документу продажи $":U.
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define shared temp-table temp-cpa-pcep no-undo
field cdpay-code like ub.cash-pay.cdpay-code
field curr-code like ub.cash-pay.cdpay-code
field prefix as character
index pi is primary
cdpay-code
curr-code
.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE SHARED TEMP-TABLE treal-2 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD qnty2 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(18)"
FIELD is-pay as logical
FIELD ii as integer
FIELD pay-desk as integer
FIELD prefix as character
FIELD netto-rubl as decimal
INDEX pi IS
  unique
  primary
      gds-code
      pay-desk
      cpay-code
      curr-code
      prefix
      is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE SHARED TEMP-TABLE treal-3 no-undo
FIELD gds-code like ub.goods.gds-code
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD ii as integer
FIELD pay-desk as integer
FIELD prefix as character
FIELD netto-rubl as decimal
INDEX pi IS UNIQUE PRIMARY
        gds-code
        pay-desk
        cpay-code
        curr-code
        prefix
        is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE SHARED TEMP-TABLE treal-4 no-undo
FIELD gds-code as integer
FIELD cpay-code as integer
FIELD curr-code as integer
FIELD qnty1 as decimal
FIELD netto as decimal
FIELD out-name as character format "X(20)"
FIELD is-pay as logical
FIELD ii as integer
FIELD pay-desk as integer
FIELD prefix as character
FIELD netto-rubl as decimal
INDEX pi IS UNIQUE PRIMARY
      gds-code
      pay-desk
      cpay-code
      curr-code
      prefix
      is-pay DESCENDING
INDEX vi
      gds-code
      ii
.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-line-num as integer no-undo .
define variable v-curr-r-b as character no-undo .
define variable v-base-code like ub.sysconf.base-code no-undo .
define buffer buf_Inkas for ub.inkas.
define buffer buf_chk-gds-pay for ub.chk-gds-pay.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-pay-desk as integer   no-undo .
define variable v-pay-card as character no-undo .
define variable v-doc-code as character no-undo .
define variable v-doc-code-r as character no-undo .
define variable v-doc-code-v as character no-undo .
define variable v-density as decimal no-undo .
DEFINE BUFFER b-treal-2 for treal-2.
DEFINE BUFFER b-treal-3 for treal-3.
DEFINE BUFFER b-treal-4 for treal-4.
DEFINE BUFFER b2-treal-2 for treal-2.
DEFINE BUFFER b2-treal-3 for treal-3.
DEFINE BUFFER b2-treal-4 for treal-4.
DEFINE BUFFER b3-treal-2 for treal-2.
DEFINE BUFFER b3-treal-3 for treal-3.
DEFINE BUFFER b3-treal-4 for treal-4.
define buffer buf_temp-cpa-pcep for temp-cpa-pcep.
define buffer buf_bar-code for ub.bar-code.
define buffer buf_cash-pay for ub.cash-pay.
define buffer buf_doc-line for ub.doc-line.
define buffer buf_goods for ub.goods.
define buffer ras-doc for ub.trn-doc.
define buffer ret-doc for ub.trn-doc.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
do
on error undo, return error
:
  find first buf_inkas no-lock where
             buf_inkas.inkas-code = p-inkas-code.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  buf_inkas.host-code
  ,output v-base-code
  )  .
  for each treal-2:
    delete treal-2.
  end.
  for each treal-3:
    delete treal-3.
  end.
  for each treal-4:
    delete treal-4.
  end.
  run rep/rpychk0.p ( input "bgepych2"
                      ,input buf_inkas.obj-type
                      ,input buf_inkas.obj-code
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input buf_inkas.inkas-code
                      ) no-error.
  if error-status:error then
    return error return-value.
 _chk-doc:
 FOR EACH ub.chk-doc No-LOCK WHERE
          ub.chk-doc.obj-type = buf_inkas.obj-type AND
          ub.chk-doc.obj-code = buf_inkas.obj-code AND
          ub.chk-doc.out-code = p-inkas-code:
    case p-ext-doc-type:
      when 'es':U then do:
        if ub.chk-doc.netto < 0 then do:
          NEXT _chk-doc.
        end.
      end.
      when 'rs':U then do:
        if ub.chk-doc.netto >= 0 then do:
          NEXT _chk-doc.
        end.
      end.
      when "":U then do:
      end.
    END CASE.
    if lookup(string(ub.chk-doc.chk-type), '14,15,16,36,17,8,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) > 0 then next _chk-doc.
    if p-by-pay-desk then do:
      assign
      v-pay-desk = ub.chk-doc.pay-desk
      .
    end.
    else do:
      assign
      v-pay-desk = 0
      .
    end.
    for each buf_chk-gds-pay no-lock where
            buf_chk-gds-pay.doc-code = ub.chk-doc.doc-code
        and buf_chk-gds-pay.algo-num = "1.8",
        first buf_bar-code no-lock where
            buf_bar-code.b-code = buf_chk-gds-pay.b-code,
        first buf_cash-pay no-lock where
            buf_cash-pay.cdpay-code = buf_chk-gds-pay.pay-code
        and buf_cash-pay.curr-code = buf_chk-gds-pay.curr-code:
      if p-by-pay-card-prefix  then do:
        find first buf_temp-cpa-pcep no-lock where
                  buf_temp-cpa-pcep.cdpay-code = buf_chk-gds-pay.pay-code
              AND buf_temp-cpa-pcep.curr-code = buf_chk-gds-pay.curr-code
              AND buf_chk-gds-pay.pay-card begins buf_temp-cpa-pcep.prefix no-error .
        if available buf_temp-cpa-pcep then
        assign
        v-pay-card = buf_temp-cpa-pcep.prefix
        .
        else
        assign
        v-pay-card = 'other':U
        .
      end.
      else do:
        assign
        v-pay-card = '':U
        .
      end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
CASE entry(1, buf_chk-gds-pay.line-type, chr(4)):
  WHEN 'топ':U  then do:
    if p-petrol then do:
      if ub.chk-doc.netto < 0 then do:
        if v-doc-code-r <> ub.chk-doc.out-code
        then do:
          find first ras-doc no-lock
            where ras-doc.doc-code = ub.chk-doc.out-code
            no-error .
          if not available ras-doc then do:
            message
            substitute("Отсутствует документ расхода по чеку &1"
                        , ub.chk-doc.doc-code
                        )   skip
            "ЭКСПОРТ НЕ МОЖЕТ БЫТЬ ОСУЩЕСТВЛЕН" SKIP
            view-as alert-box error .
            return error .
          end.
          v-doc-code-r = ras-doc.doc-code.
          find first ret-doc no-lock where
                    ret-doc.doc-code = ras-doc.out-code no-error .
          if not available ret-doc then do:
            message
            substitute("Отсутствует документ возврата по чеку &1"
                      , ub.chk-doc.doc-code
                      )   skip
            "ЭКСПОРТ НЕ МОЖЕТ БЫТЬ ОСУЩЕСТВЛЕН" SKIP
            view-as alert-box error .
            return error .
          end.
          v-doc-code-v = ret-doc.doc-code.
        end.
        assign
        v-doc-code = v-doc-code-v
        .
      end.
      else do:
        assign
        v-doc-code = ub.chk-doc.out-code
        .
      end.
      if p-by-pay-card-prefix
      and v-pay-card <> "other"
      then do:
        FIND FIRST b2-treal-2 No-LOCK WHERE
                  b2-treal-2.gds-code = buf_bar-code.gds-code
              AND b2-treal-2.cpay-code = buf_chk-gds-pay.pay-code
              AND b2-treal-2.curr-code = buf_chk-gds-pay.curr-code
              AND b2-treal-2.is-pay = yes
              AND b2-treal-2.pay-desk = v-pay-desk
              AND b2-treal-2.prefix = v-pay-card  No-ERROR.
        IF NOT AVAIL  b2-treal-2 then do:
          FIND last b3-treal-2 No-LOCK WHERE
                    b3-treal-2.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
          create b2-treal-2.
          assign
          b2-treal-2.gds-code = buf_bar-code.gds-code
          b2-treal-2.cpay-code = buf_chk-gds-pay.pay-code
          b2-treal-2.curr-code = buf_chk-gds-pay.curr-code
          b2-treal-2.out-name = buf_cash-pay.obj-name
          b2-treal-2.is-pay = yes
          b2-treal-2.ii = (if avail b3-treal-2
                        then b3-treal-2.ii + 1
                        else 1)
          b2-treal-2.pay-desk = v-pay-desk
          b2-treal-2.prefix   = v-pay-card
          .
        END.
        find first buf_goods  no-lock where
                  buf_goods.gds-code  = buf_bar-code.gds-code .
        find first buf_doc-line no-lock where
                  buf_doc-line.doc-code  = v-doc-code
              and buf_doc-line.artic     = buf_goods.artic
              and buf_doc-line.prod-type = buf_goods.prod-type
              and buf_doc-line.prod-code = buf_goods.prod-code  no-error.
        assign
        v-density = ( if available buf_doc-line
                          then buf_doc-line.fact-density
                          else 0 ).
        assign
        b2-treal-2.netto = b2-treal-2.netto +
                                        (if v-curr-r-b = 'base':U
                                        or v-base-code = 0
                                        then buf_chk-gds-pay.tot-r-b
                                        else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
        b2-treal-2.qnty1 = b2-treal-2.qnty1 + buf_chk-gds-pay.eff-doc-qnty
        b2-treal-2.qnty2 = b2-treal-2.qnty2 + buf_chk-gds-pay.eff-doc-qnty * v-density
        b2-treal-2.netto-rubl = b2-treal-2.netto-rubl +
                                        (if v-curr-r-b = 'rubl':U
                                        or v-base-code = 0
                                        then buf_chk-gds-pay.tot-r-b
                                        else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate))
        .
      end.
      FIND FIRST treal-2 No-LOCK WHERE
                treal-2.gds-code = buf_bar-code.gds-code
            AND  treal-2.cpay-code = buf_chk-gds-pay.pay-code
            AND  treal-2.curr-code = buf_chk-gds-pay.curr-code
            AND  treal-2.is-pay = yes
            AND treal-2.pay-desk = v-pay-desk
            AND treal-2.prefix = '':U  No-ERROR.
      IF NOT AVAIL treal-2 then do:
        FIND last b-treal-2 No-LOCK WHERE
                  b-treal-2.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
          create treal-2.
          assign
          treal-2.gds-code = buf_bar-code.gds-code
          treal-2.cpay-code = buf_chk-gds-pay.pay-code
          treal-2.curr-code = buf_chk-gds-pay.curr-code
          treal-2.out-name = buf_cash-pay.obj-name
          treal-2.is-pay = yes
          treal-2.ii = (if avail b-treal-2
                        then b-treal-2.ii + 1
                        else 1)
          treal-2.pay-desk = v-pay-desk
          treal-2.prefix   = '':U
          .
      END.
      assign
      treal-2.netto = treal-2.netto + (if v-curr-r-b = 'base':U
                                        or v-base-code = 0
                                        then buf_chk-gds-pay.tot-r-b
                                        else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
      treal-2.qnty1 = treal-2.qnty1 + buf_chk-gds-pay.eff-doc-qnty
      treal-2.qnty2 = treal-2.qnty2 + buf_chk-gds-pay.eff-doc-qnty * v-density
      treal-2.netto-rubl = treal-2.netto-rubl + (if v-curr-r-b = 'rubl':U
                                        or v-base-code = 0
                                        then buf_chk-gds-pay.tot-r-b
                                        else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate))
      .
    end.
  end.
  WHEN 'т':U  then do:
    if p-goods then do:
      if p-by-pay-card-prefix
      and v-pay-card <> "other"
      then do:
        FIND FIRST b2-treal-3 No-LOCK WHERE
                  b2-treal-3.gds-code = buf_bar-code.gds-code
              AND b2-treal-3.cpay-code = buf_chk-gds-pay.pay-code
              AND b2-treal-3.curr-code = buf_chk-gds-pay.curr-code
              AND b2-treal-3.pay-desk = v-pay-desk
              AND b2-treal-3.prefix = v-pay-card No-ERROR.
        IF NOT AVAIL b2-treal-3 then do:
          FIND last b3-treal-3 No-LOCK WHERE
                    b3-treal-3.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
          create b2-treal-3.
          assign
          b2-treal-3.gds-code = buf_bar-code.gds-code
          b2-treal-3.cpay-code = buf_chk-gds-pay.pay-code
          b2-treal-3.curr-code = buf_chk-gds-pay.curr-code
          b2-treal-3.qnty1  =  0
          b2-treal-3.netto = 0
          b2-treal-3.out-name = buf_cash-pay.obj-name
          b2-treal-3.is-pay = yes
          b2-treal-3.ii =  (if avail b3-treal-3
                            then b3-treal-3.ii + 1
                            else 1)
          b2-treal-3.pay-desk = v-pay-desk
          b2-treal-3.prefix   = v-pay-card
          .
        END.
        assign
        b2-treal-3.netto = b2-treal-3.netto + (if v-curr-r-b = 'base':U
                                              or v-base-code = 0
                                              then buf_chk-gds-pay.tot-r-b
                                              else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
        b2-treal-3.qnty1 = b2-treal-3.qnty1 + buf_chk-gds-pay.eff-doc-qnty
        b2-treal-3.netto-rubl = b2-treal-3.netto-rubl + (if v-curr-r-b = 'rubl':U
                                                          or v-base-code = 0
                                                          then buf_chk-gds-pay.tot-r-b
                                                          else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate))
        .
      end.
      FIND FIRST treal-3 No-LOCK WHERE
                treal-3.gds-code = buf_bar-code.gds-code
            AND treal-3.cpay-code = buf_chk-gds-pay.pay-code
            AND treal-3.curr-code = buf_chk-gds-pay.curr-code
            AND treal-3.pay-desk = v-pay-desk
            AND treal-3.prefix = '':U No-ERROR.
      IF NOT AVAIL treal-3 then do:
        FIND last b-treal-3 No-LOCK WHERE
                  b-treal-3.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
          create treal-3.
          assign
          treal-3.gds-code = buf_bar-code.gds-code
          treal-3.cpay-code = buf_chk-gds-pay.pay-code
          treal-3.curr-code = buf_chk-gds-pay.curr-code
          treal-3.qnty1  =  0
          treal-3.netto = 0
          treal-3.out-name = buf_cash-pay.obj-name
          treal-3.is-pay = yes
          treal-3.ii =  (if avail b-treal-3
                            then b-treal-3.ii + 1
                            else 1)
          treal-3.pay-desk = v-pay-desk
          treal-3.prefix   = '':U
          .
      END.
      assign
      treal-3.netto = treal-3.netto + (if v-curr-r-b = 'base':U
                                      or v-base-code = 0
                                      then buf_chk-gds-pay.tot-r-b
                                      else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
      treal-3.qnty1 = treal-3.qnty1 + buf_chk-gds-pay.eff-doc-qnty
      treal-3.netto-rubl = treal-3.netto-rubl + (if v-curr-r-b = 'rubl':U
                                                or v-base-code = 0
                                                then buf_chk-gds-pay.tot-r-b
                                                else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate))
      .
    END.
  END.
  WHEN 'у':U then do:
    if p-services then do:
      if p-by-pay-card-prefix
      and v-pay-card <> "other"
      then do:
        FIND FIRST b2-treal-4 No-LOCK WHERE
                  b2-treal-4.gds-code = buf_bar-code.gds-code
              AND b2-treal-4.cpay-code = buf_chk-gds-pay.pay-code
              AND b2-treal-4.curr-code = buf_chk-gds-pay.curr-code
              AND b2-treal-4.is-pay = yes
              AND b2-treal-4.pay-desk = v-pay-desk
              AND b2-treal-4.prefix = v-pay-card No-ERROR.
        IF NOT AVAIL b2-treal-4 then do:
          FIND last b3-treal-4 No-LOCK WHERE
                    b3-treal-4.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
          create b2-treal-4.
          assign
          b2-treal-4.gds-code = buf_bar-code.gds-code
          b2-treal-4.cpay-code = buf_chk-gds-pay.pay-code
          b2-treal-4.curr-code = buf_chk-gds-pay.curr-code
          b2-treal-4.qnty1  =  0
          b2-treal-4.netto = 0
          b2-treal-4.out-name = buf_Cash-pay.obj-name
          b2-treal-4.is-pay = yes
          b2-treal-4.ii = (if avail b3-treal-4
                          then b3-treal-4.ii + 1
                          else 1)
          b2-treal-4.pay-desk = v-pay-desk
          b2-treal-4.prefix   = v-pay-card
          .
        END.
        assign
        b2-treal-4.netto = b2-treal-4.netto + (if v-curr-r-b = 'base':U
                                              or v-base-code = 0
                                              then buf_chk-gds-pay.tot-r-b
                                              else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
        b2-treal-4.qnty1 = b2-treal-4.qnty1 + buf_chk-gds-pay.eff-doc-qnty
        b2-treal-4.netto-rubl = b2-treal-4.netto-rubl + (if v-curr-r-b = 'rubl':U
                                                or v-base-code = 0
                                                then buf_chk-gds-pay.tot-r-b
                                                else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate))
        .
      end.
      fIND FIRST treal-4 No-LOCK WHERE
                treal-4.gds-code = buf_bar-code.gds-code
            AND treal-4.cpay-code = buf_chk-gds-pay.pay-code
            AND treal-4.curr-code = buf_chk-gds-pay.curr-code
            AND treal-4.is-pay = yes
            AND treal-4.pay-desk = v-pay-desk
            AND treal-4.prefix = '':U  No-ERROR.
      IF NOT AVAIL treal-4 then do:
        FIND last b-treal-4 No-LOCK WHERE
                  b-treal-4.gds-code = buf_bar-code.gds-code use-index vi No-ERROR.
        create treal-4.
        assign
        treal-4.gds-code = buf_bar-code.gds-code
        treal-4.cpay-code = buf_chk-gds-pay.pay-code
        treal-4.curr-code = buf_chk-gds-pay.curr-code
        treal-4.qnty1  =  0
        treal-4.netto = 0
        treal-4.out-name = buf_Cash-pay.obj-name
        treal-4.is-pay = yes
        treal-4.ii = (if avail b-treal-4
                        then b-treal-4.ii + 1
                        else 1)
        treal-4.pay-desk = v-pay-desk
        treal-4.prefix   = '':U
        .
      END.
      assign
      treal-4.netto = treal-4.netto + (if v-curr-r-b = 'base':U
                                      or v-base-code = 0
                                      then buf_chk-gds-pay.tot-r-b
                                      else (buf_chk-gds-pay.tot-r-b / buf_chk-gds-pay.eff-base-rate))
      treal-4.qnty1 = treal-4.qnty1 + buf_chk-gds-pay.eff-doc-qnty
      treal-4.netto-rubl = treal-4.netto-rubl + (if v-curr-r-b = 'rubl':U
                                                or v-base-code = 0
                                                then buf_chk-gds-pay.tot-r-b
                                                else (buf_chk-gds-pay.tot-r-b * buf_chk-gds-pay.eff-base-rate))
      .
    END.
  END.
END CASE.
    end.
end.
end.
