block-level on error undo, throw.
define input parameter p-mainmenu-handle    as handle           no-undo.
define input parameter p-trn-doc-doc-code   as character    no-undo .
define input parameter p-gds-code           as integer      no-undo .
define input parameter p-required-qnty      as decimal      no-undo .
define input parameter p-price-cost         as decimal      no-undo .
define input parameter p-base-rate          as decimal      no-undo.
define input parameter p-base-scale         as integer      no-undo.
define input parameter p-line-num           as integer      no-undo.
define variable vss-revision    as character no-undo init "$Revision: 5baf537283c9, 2487, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: 2020/06/26 13:47:04 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rcscredl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rcs/rcscredl.p $":U .
define variable vss-description as character no-undo init "".
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
    define variable v-doc-line-recid            as recid     no-undo .
    define variable v-out-price-base            as decimal   no-undo .
    define variable v-out-price-rubl            as decimal   no-undo .
    define variable v-allsum-sum-dsc-base-acc   as decimal   no-undo .
    define variable v-allsum-sum-dsc-rubl-acc   as decimal   no-undo .
    define variable v-allsum-vat-base-acc       as decimal   no-undo .
    define variable v-allsum-vat-rubl-acc       as decimal   no-undo .
    define variable v-vat-pc                    as decimal   no-undo .
    define variable v-host-code                 as integer   no-undo.
    define variable v-cons-vat-pc               as decimal   no-undo.
    define buffer buf_goods         for goods.
    define buffer buf_gds-prt       for gds-prt.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.
    define buffer buf_gds-dtl       for gds-dtl.
do
for buf_goods
  , buf_gds-prt
  , buf_trn-doc
  , buf_doc-line
  , buf_gds-dtl
on error undo, return error
:
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    find first buf_gds-prt no-lock
         where buf_gds-prt.upper-code = buf_goods.prt-root
    .
    find first buf_trn-doc exclusive-lock
         where buf_trn-doc.doc-code = p-trn-doc-doc-code
    .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcvat in g#library
  (input  v-host-code
  ,output v-cons-vat-pc
  )  .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  buf_trn-doc.obj-type
  ,input  buf_trn-doc.obj-code
  ,output v-vat-pc
  )  .
    find first buf_doc-line exclusive-lock
         where buf_doc-line.doc-code  = buf_trn-doc.doc-code
           and buf_doc-line.artic     = buf_goods.artic
           and buf_doc-line.prod-type = buf_goods.prod-type
           and buf_doc-line.prod-code = buf_goods.prod-code
    no-error.
    if not available buf_doc-line
    then do:
        create buf_doc-line.
        assign
            buf_doc-line.doc-code      = buf_trn-doc.doc-code
            buf_doc-line.status_       = buf_trn-doc.status_
            buf_doc-line.artic         = buf_goods.artic
            buf_doc-line.prod-type     = buf_goods.prod-type
            buf_doc-line.prod-code     = buf_goods.prod-code
            buf_doc-line.obj-type      = buf_trn-doc.obj-type
            buf_doc-line.obj-code      = buf_trn-doc.obj-code
            buf_doc-line.prt-root      = buf_goods.prt-root
            buf_doc-line.cli-qnty      = p-required-qnty / buf_goods.cli-base-rate
            buf_doc-line.doc-qnty      = p-required-qnty
            buf_doc-line.fact-qnty     = p-required-qnty
            buf_doc-line.price-rubl    = p-price-cost
            buf_doc-line.price-base    = p-price-cost / p-base-rate * p-base-scale
            buf_doc-line.price-cli     = p-price-cost
            buf_doc-line.VAT-pc        = v-vat-pc
            buf_doc-line.VAT-pc        = 0
            buf_doc-line.line-num      = p-line-num
            buf_doc-line.unit-cli      = buf_goods.unit-base
            buf_doc-line.cli-base-rate = 1
            buf_doc-line.prt-ok        = yes
            buf_doc-line.cons-vat-pc   = v-cons-vat-pc
            buf_doc-line.doc-qnty      = p-required-qnty
        .
    end.
    else do:
        message
                 vss-workfile vss-revision vss-description
            skip "Строка с импортируемым товаром уже есть в документе."
            skip "Номер документа:" buf_trn-doc.doc-code
            skip "Товар:" buf_goods.artic buf_goods.gds-name
            skip return-value
            skip trim(error-status :get-message(1))
                 trim(error-status :get-message(2))
                 trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    assign
        v-doc-line-recid = recid( buf_doc-line )
    .
    run rsrv-good in this-procedure (
          input buf_goods.gds-code
        , input buf_trn-doc.doc-code
        , input v-doc-line-recid
        , input p-price-cost
        , input p-price-cost / p-base-rate * p-base-scale
        , input p-required-qnty
    ) no-error.
    if error-status :error
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Ошибка резервирования товара."
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    find first buf_gds-dtl exclusive-lock
         where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
           and buf_gds-dtl.artic     = buf_goods.artic
           and buf_gds-dtl.prod-type = buf_goods.prod-type
           and buf_gds-dtl.prod-code = buf_goods.prod-code
           and buf_gds-dtl.prt-code  = buf_gds-prt.node-code
     .
    assign
        buf_gds-dtl.doc-qnty    = p-required-qnty
        buf_gds-dtl.fact-qnty   = p-required-qnty
    .
end.
procedure rsrv-good :
do
on error undo, return error
:
define input parameter p-gds-code           as integer   no-undo .
define input parameter p-trn-doc-doc-code   as character no-undo .
define input parameter p-doc-line-recid     as recid     no-undo .
define input parameter p-price-cost-rubl    as decimal   no-undo .
define input parameter p-price-cost-base    as decimal   no-undo .
define input parameter p-required-qnty      as decimal   no-undo .
    define variable v-r-b-is-base   as logical      no-undo.
    define buffer buf_goods         for goods.
    define buffer buf_gds-prt       for gds-prt.
    define buffer buf_gds-dtl       for gds-dtl.
    define buffer buf_trn-doc       for trn-doc.
    define buffer buf_doc-line      for doc-line.
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    find first buf_gds-prt no-lock
         where buf_gds-prt.upper-code = buf_goods.prt-root
    .
    find first buf_trn-doc no-lock
         where buf_trn-doc.doc-code = p-trn-doc-doc-code
    .
    find first buf_doc-line no-lock
         where recid( buf_doc-line ) = p-doc-line-recid
    .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-r-b-is-base
  )  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input buf_trn-doc.obj-code
   ,input buf_trn-doc.obj-type
   ,input buf_trn-doc.doc-code
   ,input buf_goods.artic
   ,input buf_goods.prod-code
   ,input buf_goods.prod-type
   ,input buf_gds-prt.node-code
   ,input yes
  ) no-error .
    if error-status:error
    then do:
        message
            "Ошибка при создании признака."
            skip return-value
        view-as alert-box error.
    end.
    find first buf_gds-dtl
         where buf_gds-dtl.doc-code  = buf_trn-doc.doc-code
           and buf_gds-dtl.artic     = buf_goods.artic
           and buf_gds-dtl.prod-type = buf_goods.prod-type
           and buf_gds-dtl.prod-code = buf_goods.prod-code
           and buf_gds-dtl.prt-code  = buf_gds-prt.node-code
     .
    if p-required-qnty = 0
    then do:
        message
          vss-workfile vss-revision vss-description
          skip "Невозможно зарезервировать количество 0."
          skip "Товар: " buf_goods.artic buf_goods.gds-name
          skip return-value
          skip trim(error-status :get-message(1))
               trim(error-status :get-message(2))
               trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if p-price-cost-rubl <= 0
    then do:
        message
            "Неправильные цены резервирования:"
            skip "Учетная цена, рубли:   " p-price-cost-rubl
            skip "Товар: " buf_goods.artic buf_goods.gds-name
        view-as alert-box error.
        undo, return error.
    end.
    run trg/rsrv-dtl.p (
          input p-mainmenu-handle
        , input 'reserv':U
        , buffer buf_gds-dtl
        , input-output p-required-qnty
        , input-output p-price-cost-base
        , input-output p-price-cost-rubl
        , input -1
        , input ""
    ) no-error.
    if error-status :error
    then do:
        if error-status :get-message(1) <> ""
        then do:
            message
                    vss-workfile vss-revision vss-description
                skip "Ошибка при резервировании товара."
                skip return-value
                skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
            view-as alert-box error.
            undo, return error .
        end.
    end.
end.
end procedure.
