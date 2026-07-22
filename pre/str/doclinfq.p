block-level on error undo, throw.
define input  parameter parparentproc as widget-handle no-undo.
define parameter buffer t-doc for ub.trn-doc .
define parameter buffer doc-line for ub.doc-line .
define input  parameter p-fact-qnty   as decimal   no-undo .
define output parameter p-edit-ok     as logical   no-undo .
define output parameter p-err-message as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: f80e41f51855, 1693, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Tue Dec 11 10:07:53 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: doclinfq.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/doclinfq.p $":U .
define variable vss-description as character no-undo init "–едактирование фактического количества в приходной накладной".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable is-petrolium as logical no-undo .
define variable is-pieces    as logical no-undo .
define variable line-rec     as recid   no-undo .
define variable v-part-code  as character no-undo.
define variable v-alcohol-prod as logical no-undo .
define variable v-hold-doc as logical   no-undo .
define buffer bf_parts    for ub.parts.
do
on error undo, return error return-value
:
  update_block:
  do transaction
  on error undo update_block, return error
  :
    if not available t-doc
    then do:
      undo, return error "Ќе задан документ" .
    end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  t-doc.doc-code
  ,output v-hold-doc
  )  .
    if not available doc-line
    then do:
      undo, return error "Ќе задана строка документа" .
    end.
    define variable v-gds-code as integer   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  doc-line.artic
  ,input  doc-line.prod-type
  ,input  doc-line.prod-code
  ,output v-gds-code
  )  .
    if p-fact-qnty <> doc-line.fact-qnty
    then do:
      if  p-fact-qnty = ?
      and t-doc.flag_ = true
      then do:
        assign
          p-edit-ok     = false
          p-err-message = "Ќе указано фактическое количество"
        .
        undo update_block, return .
      end.
      if  p-fact-qnty > doc-line.doc-qnty
      and v-hold-doc = true
      then do:
        assign
          p-edit-ok     = false
          p-err-message = "ƒанный документ был автоматически создан по перемещению от своей фирмы."
                        + chr(10) + "Ќельз€ указывать фактическое количество больше документарного"
        .
        undo update_block, return .
      end.
      define variable v-goods-serial as logical   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  v-gds-code
  ,input  'serial=request':u
  ,output v-goods-serial
  ) no-error .
      if error-status :error
      then do:
        undo update_block, return error "ќшибка при определении свойства товара 'serial=request':u" .
      end.
      if v-goods-serial = true
      then do:
        assign
          p-edit-ok     = false
          p-err-message = "¬ серийном товаре нельз€ редактировать фактическое количество"
        .
        undo update_block, return .
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input doc-line.artic
  ,  input doc-line.prod-type
  ,  input doc-line.prod-code
  , output is-petrolium
  , output is-pieces
  ) no-error.
      if is-petrolium and not is-pieces then do:
        assign
          p-edit-ok     = false
          p-err-message = "¬ жидком топливе нельз€ редактировать фактическое количество"
        .
        undo update_block, return .
      end.
      assign
        v-part-code = ?
      .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  v-gds-code
  ,input  'alcohol-prod=request':u
  ,output v-alcohol-prod
  )  .
      if v-alcohol-prod then do:
        find first bf_parts no-lock
          where bf_parts.obj-type  = doc-line.obj-type  and
                bf_parts.obj-code  = doc-line.obj-code  and
                bf_parts.prod-type = doc-line.prod-type and
                bf_parts.prod-code = doc-line.prod-code and
                bf_parts.artic     = doc-line.artic     and
                bf_parts.out-code  = doc-line.doc-code
          no-error.
        if available bf_parts then do:
          assign
            v-part-code = bf_parts.part-code
          .
        end.
      end.
      assign
        line-rec = recid(doc-line)
      .
      run str/cor-line.p
        (input parparentproc
        ,input-output line-rec
        ,input doc-line.doc-code
        ,input doc-line.prod-type
        ,input doc-line.prod-code
        ,input doc-line.artic
        ,input doc-line.cli-qnty
        ,input doc-line.cli-base-rate
        ,input p-fact-qnty
        ,input doc-line.doc-qnty
        ,input doc-line.unit-cli
        ,input doc-line.vat-pc
        ,input doc-line.slt-pc
        ,input doc-line.price-cli
        ,input doc-line.price-base
        ,input doc-line.price-rubl
        ,input doc-line.new-price-sale
        ,input doc-line.num-place
        ,input doc-line.wt-brutto
        ,input doc-line.road-tax
        ,input doc-line.excise
        ,input doc-line.doc-density
        ,input doc-line.temperature
        ,input ?
        ,input ?
        ,input ?
        ,input doc-line.fact-density
        ,input ?
        ,input no
        ,input v-part-code
        ,input ?
        ,input ?
        ,input ?
        ,input ?
        ,input ?
        ,input ?
        ,input ?
        ,input ?
        ) no-error.
      if error-status :error
      then do:
        undo update_block, return error substitute("ќшибка при вызове процедуры создани€ линии документа &1", return-value).
      end.
      assign
        line-rec = recid(doc-line)
      .
      run str/chk-prt.p
        (input  line-rec
        ,input  no
        ,buffer t-doc
        ) .
    end.
  end.
  assign
    p-edit-ok     = true
    p-err-message = ''
  .
end.
