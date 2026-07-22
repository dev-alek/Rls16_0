block-level on error undo, throw.
define  input parameter p-obj-type     like ub.clients.obj-type     no-undo .
define  input parameter p-obj-code     like ub.clients.obj-code     no-undo .
define  input parameter p-shift-date   like ub.shift-obj.shift-date no-undo .
define  input parameter p-shift-num    like ub.shift-obj.shift-num  no-undo .
define  input parameter p-gds-code     like ub.goods.gds-code       no-undo .
define  input parameter p-rvs-code     like ub.rvs-doc.rvs-code     no-undo .
define  input parameter p-with-expense as   logical                 no-undo .
define output parameter p-density      as   decimal                 no-undo .
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Расчет средней плотности по топливу за смену на объекте":U .
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
define variable is_shift-on       as   logical               no-undo .
define variable is-petrol         as   logical               no-undo .
define variable is-pieces         as   logical               no-undo .
define variable d_fact-order      like ub.rvs-doc.fact-order no-undo .
define variable d_fact-order-prev like ub.rvs-doc.fact-order no-undo .
define variable d_density-acc     as   decimal               no-undo .
define variable j_num-place       as   integer               no-undo .
define variable rec-rvs-doc       as   recid                 no-undo .
define variable varshift-name     as   character             no-undo .
define variable varshift-name-num as   character             no-undo .
define buffer bf_rvs-doc  for ub.rvs-doc .
define buffer bf_cur-doc  for ub.rvs-doc .
define buffer bf_cur-line for ub.rvs-line .
do on error undo, return error :
  find first ub.clients no-lock where
             ub.clients.obj-type = p-obj-type and
             ub.clients.obj-code = p-obj-code no-error .
  if not available ub.clients
  then do:
    return error substitute( "Не найден объект: &1 &2."
                           , p-obj-type
                           , p-obj-code
                           ) .
  end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output is_shift-on
  ) no-error .
  if error-status :error
  then do:
    return error trim( return-value ) +
                 trim( error-status :get-message( 1 ) ) +
                 trim( error-status :get-message( 2 ) ) +
                 trim( error-status :get-message( 3 ) ) +
                 trim( error-status :get-message( 4 ) ) +
                 trim( error-status :get-message( 5 ) ) .
  end.
  if is_shift-on <> yes
  then do:
    return error "На объекте не работают смены." .
  end.
  find first ub.goods no-lock where
             ub.goods.gds-code = p-gds-code no-error .
  if not available ub.goods
  then do:
    return error substitute( "Не найден товар с внутренним кодом &1."
                           , p-gds-code
                           ) .
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ub.goods.artic
  ,  input ub.goods.prod-type
  ,  input ub.goods.prod-code
  , output is-petrol
  , output is-pieces
  ) no-error.
  if error-status :error
  then do:
    return error "Ошибка при вызове программы lib-trn_is-petrl из avrgdens.p. " + return-value .
  end.
  if is-petrol <> yes or
     is-pieces <> no
  then do:
    return error substitute( "Товар &1 &2 &3 не является весовым топливом."
                           , ub.goods.artic
                           , ub.goods.prod-type
                           , ub.goods.prod-code
                           ) .
  end.
  if p-rvs-code <> ?
  then do:
    find first bf_cur-doc no-lock where
               bf_cur-doc.rvs-code = p-rvs-code no-error .
    if not available bf_cur-doc
    then do:
       return error substitute( "Не найдена сверка с номером &1 ."
                              , p-rvs-code
                              ) .
    end.
    find first bf_cur-line no-lock where
               bf_cur-line.rvs-code = bf_cur-doc.rvs-code and
               bf_cur-line.gds-code = ub.goods.gds-code   no-error .
    if not available bf_cur-line
    then do:
      return error substitute( "Товар &1 &2 &3 не участвует в сверке &4. Плотность не может быть вычислена. "
                             , ub.goods.artic
                             , ub.goods.prod-type
                             , ub.goods.prod-code
                             , bf_cur-doc.rvs-code
                             ) .
    end.
    assign
      d_fact-order = bf_cur-doc.fact-order
    .
  end.
  else do:
    assign
      d_fact-order = ?
    .
    for each ub.rvs-doc no-lock where
             ub.rvs-doc.obj-type   = p-obj-type   and
             ub.rvs-doc.obj-code   = p-obj-code   and
             ub.rvs-doc.shift-date = p-shift-date and
             ub.rvs-doc.shift-num  = p-shift-num  and
             ub.rvs-doc.status_    = 'факт':U      and
             ub.rvs-doc.rvs-type  <> 'проверка':U
      , each ub.rvs-line no-lock where
             ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code and
             ub.rvs-line.obj-type = ub.rvs-doc.obj-type and
             ub.rvs-line.obj-code = ub.rvs-doc.obj-code and
             ub.rvs-line.gds-code = ub.goods.gds-code
    :
      assign
        d_fact-order = ub.rvs-doc.fact-order
      .
      leave .
    end.
  end.
  if d_fact-order <> ? then do:
    find last bf_rvs-doc no-lock where
              bf_rvs-doc.obj-type   = p-obj-type   and
              bf_rvs-doc.obj-code   = p-obj-code   and
              bf_rvs-doc.status_    = 'факт':U      and
              bf_rvs-doc.fact-order < d_fact-order and
              bf_rvs-doc.rvs-type   = 'смена':U use-index stat-fact no-error .
    assign
      d_fact-order-prev = ( if available bf_rvs-doc then bf_rvs-doc.fact-order else 0.00 )
    .
    assign
      j_num-place   = 0
      d_density-acc = 0.00
      p-density     = 0.00
    .
    for each ub.rvs-doc no-lock where
             ub.rvs-doc.obj-type    = p-obj-type        and
             ub.rvs-doc.obj-code    = p-obj-code        and
             ub.rvs-doc.status_     = 'факт':U           and
             ub.rvs-doc.fact-order <= d_fact-order      and
             ub.rvs-doc.fact-order >= d_fact-order-prev and
             ub.rvs-doc.rvs-type   <> 'проверка':U
      , each ub.rvs-line no-lock where
             ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code and
             ub.rvs-line.obj-type = ub.rvs-doc.obj-type and
             ub.rvs-line.obj-code = ub.rvs-doc.obj-code and
             ub.rvs-line.gds-code = p-gds-code
    break by ub.rvs-line.obj-type
          by ub.rvs-line.obj-code
          by ub.rvs-line.pl-code
    on error undo, return error
    :
      assign
        d_density-acc = d_density-acc + ( if ub.rvs-line.state-density <> ? then ub.rvs-line.state-density else 0 )
        j_num-place   = j_num-place   + 1
      .
    end.
    if p-with-expense = yes
    then do:
      for each ub.doc-line no-lock where
               ub.doc-line.obj-type      = p-obj-type         and
               ub.doc-line.obj-code      = p-obj-code         and
               ub.doc-line.prod-type     = ub.goods.prod-type and
               ub.doc-line.prod-code     = ub.goods.prod-code and
               ub.doc-line.artic         = ub.goods.artic     and
               ub.doc-line.ext-doc-type  = 'ee':U and
               ub.doc-line.status_       = 'факт':U            and
               ub.doc-line.fact-order   <= d_fact-order       and
               ub.doc-line.fact-order   >= d_fact-order-prev
      on error undo, return error
      :
        assign
          d_density-acc = d_density-acc + ( if ub.doc-line.fact-density <> ? then ub.doc-line.fact-density else 0 )
          j_num-place   = j_num-place   + 1
        .
      end.
    end.
  end.
  else do:
    find last bf_rvs-doc no-lock where
              bf_rvs-doc.obj-type   = p-obj-type   and
              bf_rvs-doc.obj-code   = p-obj-code   and
              bf_rvs-doc.status_    = 'факт':U      and
              bf_rvs-doc.rvs-type   = 'смена':U use-index stat-fact no-error .
    assign
      d_fact-order-prev = ( if available bf_rvs-doc then bf_rvs-doc.fact-order else 0.00 )
    .
    assign
      j_num-place   = 0
      d_density-acc = 0.00
      p-density     = 0.00
    .
    for each ub.rvs-doc no-lock where
             ub.rvs-doc.obj-type    = p-obj-type        and
             ub.rvs-doc.obj-code    = p-obj-code        and
             ub.rvs-doc.status_     = 'факт':U           and
             ub.rvs-doc.fact-order >= d_fact-order-prev and
             ub.rvs-doc.rvs-type   <> 'проверка':U
      , each ub.rvs-line no-lock where
             ub.rvs-line.rvs-code = ub.rvs-doc.rvs-code and
             ub.rvs-line.obj-type = ub.rvs-doc.obj-type and
             ub.rvs-line.obj-code = ub.rvs-doc.obj-code and
             ub.rvs-line.gds-code = p-gds-code
    break by ub.rvs-line.obj-type
          by ub.rvs-line.obj-code
          by ub.rvs-line.pl-code
    on error undo, return error
    :
      assign
        d_density-acc = d_density-acc + ( if ub.rvs-line.state-density <> ? then ub.rvs-line.state-density else 0 )
        j_num-place   = j_num-place   + 1
      .
    end.
    if p-with-expense = yes
    then do:
      for each ub.doc-line no-lock where
               ub.doc-line.obj-type      = p-obj-type         and
               ub.doc-line.obj-code      = p-obj-code         and
               ub.doc-line.prod-type     = ub.goods.prod-type and
               ub.doc-line.prod-code     = ub.goods.prod-code and
               ub.doc-line.artic         = ub.goods.artic     and
               ub.doc-line.ext-doc-type  = 'ee':U and
               ub.doc-line.status_       = 'факт':U            and
               ub.doc-line.fact-order   >= d_fact-order-prev
      on error undo, return error
      :
        assign
          d_density-acc = d_density-acc + ( if ub.doc-line.fact-density <> ? then ub.doc-line.fact-density else 0 )
          j_num-place   = j_num-place   + 1
        .
      end.
    end.
  end.
  assign
    p-density = d_density-acc / j_num-place
  .
end.
