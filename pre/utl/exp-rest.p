define temp-table tt-stk-gd no-undo
  field gds-code      as integer
  field gds-name      as character
  field fact-qnty     as decimal
  field sum-rubl-cost as decimal
  field vat-rubl      as decimal
  field sum-rubl-crsa as decimal
  index pi is primary gds-code
.
define temp-table tt-stk-fu no-undo
  field gds-code      as integer
  field gds-name      as character
  field fact-qnty-lt  as decimal
  field fact-qnty-kg  as decimal
  index pi is primary gds-code
.
define input  parameter p-obj-code       as integer no-undo .
define input  parameter p-obj-type       as character no-undo .
define output parameter table for tt-stk-gd .
define output parameter table for tt-stk-fu .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "¬ыгружает текущие остатки дл€ сравнени€ остатков в 16_0 после импорта".
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
define variable is-petrolium as logical no-undo .
define variable is-pieces    as logical no-undo .
define variable v-today      as date no-undo .
define variable v-line-count as integer no-undo .
define buffer buf_gds-obj   for ub.gds-obj .
define buffer buf_goods     for ub.goods .
define buffer buf_pl-gds    for ub.pl-gds .
define buffer buf_stk-line  for ub.stk-line .
    v-today = today .
  define variable v-date-start as date no-undo .
  define variable v-date-end   as date no-undo .
  define variable v-archive-ok as logical no-undo .
  define variable v-comment    as character no-undo .
  define variable v-can-print  as logical no-undo .
  assign
    v-date-start = v-today
    v-date-end   = v-today
  .
  run rep/chk-ahz.p
  (input p-obj-type
  ,input p-obj-code
  ,input false
  ,input true
  ,input false
  ,input false
  ,input false
  ,input 0
  ,input ""
  ,input-output v-date-start
  ,input-output v-date-end
  ,output       v-archive-ok
  ,output       v-comment
  ,output       v-can-print
  ) .
    empty temp-table tt-stk-gd .
    empty temp-table tt-stk-fu .
    v-line-count = 0 .
    for each buf_gds-obj no-lock
       where buf_gds-obj.obj-type = p-obj-type
         and buf_gds-obj.obj-code = p-obj-code :
      v-line-count = v-line-count + 1 .
      find first buf_goods no-lock where buf_goods.gds-code = buf_gds-obj.gds-code no-error .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_gds-obj.artic
  ,  input buf_gds-obj.prod-type
  ,  input buf_gds-obj.prod-code
  , output is-petrolium
  , output is-pieces
  ) .
      if is-petrolium then do :
        create tt-stk-fu .
        assign
          tt-stk-fu.gds-code     = buf_gds-obj.gds-code
          tt-stk-fu.gds-name     = if available buf_goods then buf_goods.gds-name else "товар отсутствует"
          tt-stk-fu.fact-qnty-lt = 0
          tt-stk-fu.fact-qnty-kg = 0
        .
        for each buf_pl-gds no-lock
           where buf_pl-gds.gds-code = buf_gds-obj.gds-code
             and buf_pl-gds.obj-type = buf_gds-obj.obj-type
             and buf_pl-gds.obj-code = buf_gds-obj.obj-code :
          assign
            tt-stk-fu.fact-qnty-lt = tt-stk-fu.fact-qnty-lt + buf_pl-gds.fact-qnty
            tt-stk-fu.fact-qnty-kg = tt-stk-fu.fact-qnty-kg + buf_pl-gds.cli-fact-qnty
          .
        end .
      end .
      else do :
        create tt-stk-gd .
        assign
          tt-stk-gd.gds-code      = buf_gds-obj.gds-code
          tt-stk-gd.gds-name      = if available buf_goods then buf_goods.gds-name else "товар отсутствует"
          tt-stk-gd.fact-qnty     = 0
          tt-stk-gd.sum-rubl-cost = 0
          tt-stk-gd.vat-rubl      = 0
          tt-stk-gd.sum-rubl-crsa = 0
        .
        find last buf_stk-line no-lock
            where buf_stk-line.obj-type   = buf_gds-obj.obj-type
              and buf_stk-line.obj-code   = buf_gds-obj.obj-code
              and buf_stk-line.artic      = buf_gds-obj.artic
              and buf_stk-line.prod-type  = buf_gds-obj.prod-type
              and buf_stk-line.prod-code  = buf_gds-obj.prod-code
              and buf_stk-line.sum-type   = 'cost':U
              and buf_stk-line.cat-id     = '##,##':U
              and buf_stk-line.fact-date <= v-today
        use-index category no-error.
        if available buf_stk-line then assign
          tt-stk-gd.fact-qnty     = buf_stk-line.fact-qnty
          tt-stk-gd.sum-rubl-cost = buf_stk-line.sum-rubl
          tt-stk-gd.vat-rubl      = buf_stk-line.VAT-rubl
        .
        find last buf_stk-line no-lock
            where buf_stk-line.obj-type   = buf_gds-obj.obj-type
              and buf_stk-line.obj-code   = buf_gds-obj.obj-code
              and buf_stk-line.artic      = buf_gds-obj.artic
              and buf_stk-line.prod-type  = buf_gds-obj.prod-type
              and buf_stk-line.prod-code  = buf_gds-obj.prod-code
              and buf_stk-line.sum-type   = 'crsa':U
              and buf_stk-line.cat-id     = '##,##':U
              and buf_stk-line.fact-date <= v-today
        use-index category no-error.
        if available buf_stk-line then assign
          tt-stk-gd.fact-qnty     = buf_stk-line.fact-qnty when tt-stk-gd.fact-qnty = 0
          tt-stk-gd.sum-rubl-crsa = buf_stk-line.sum-rubl
        .
      end .
    end .
