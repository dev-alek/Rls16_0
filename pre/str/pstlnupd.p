block-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision: 66c80260f80d, 2644, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2020/10/23 18:03:38 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: pstlnupd.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/pstlnupd.p $":U .
define variable vss-description as character no-undo initial "Добавление связки пересортицы":U .
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
define temp-table tt-gds-dtl no-undo
field gds-code like ub.goods.gds-code
field prt-code like ub.gds-dtl.prt-code
field qnty     as   decimal
index pi is unique primary gds-code prt-code.
define temp-table tt-gds-dtl-plus no-undo
field gds-code like ub.goods.gds-code
field prt-code like ub.gds-dtl.prt-code
field qnty     as   decimal
index pi is unique primary gds-code prt-code.
define temp-table tt-pl-qty no-undo
field pl-code like ub.place.pl-code
field qnty-l  as   decimal
field qnty-kg as   decimal
index pi is unique primary pl-code.
define temp-table tt-pl-qty-plus no-undo
field pl-code like ub.place.pl-code
field qnty-l  as   decimal
field rsrv-l  as   decimal
field qnty-kg as   decimal
index pi is unique primary pl-code.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function octal-to-char return character
( p-string as character ) :
  def var v-asc     as integer no-undo .
  def var v-new-asc as integer no-undo .
  def var ind       as integer no-undo .
  if length(p-string) <> 3 then do:
    return ? .
  end.
  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.
  return chr(v-asc) .
end function .
function char-to-octal return character
( p-chr as character ) :
  def var v-asc    as integer   no-undo .
  def var ind      as integer   no-undo .
  def var v-string as character no-undo .
  if length(p-chr) <> 1 then do:
    return ? .
  end.
  assign
    v-asc    = asc(p-chr)
    v-string = ""
  .
  do ind = 1 to 3
  :
    assign
      v-string = chr( v-asc mod 8 + asc('0')) + v-string
    .
    assign
      v-asc = truncate(v-asc / 8, 0)
    .
  end.
  return v-string .
end.
function str-encode return character
(   p-init-string       as character
  , p-encode-char       as character
  , p-special-char-list as character
) :
  def var p-encode-string as character no-undo .
  def var ind                as integer no-undo .
  def var v-num-special-char as integer no-undo .
  def var v-special-char     as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = ? then do:
    return "?" .
  end.
  if p-init-string = "?" then do:
    return p-encode-char + char-to-octal("?") .
  end.
  assign
    v-num-special-char = length(p-special-char-list)
    p-encode-string    = replace(p-init-string
                                ,p-encode-char
                                ,p-encode-char + char-to-octal(p-encode-char)
                                )
  .
  do ind = 1 to v-num-special-char
  :
    assign
      v-special-char = substring(p-special-char-list, ind, 1)
    .
    if v-special-char <> p-encode-char then do:
      assign
        p-encode-string = replace (p-encode-string
                                  ,v-special-char
                                  ,p-encode-char + char-to-octal(v-special-char)
                                  )
      .
    end.
  end.
  return p-encode-string .
end.
function str-decode returns character
  (p-init-string   as character
  ,p-encode-char   as character
  ) :
  def var p-decode-string as character no-undo .
  def var ind                       as integer no-undo .
  def var v-num-entries-init-string as integer no-undo .
  def var v-sub-phrase              as character no-undo .
  def var v-special-char            as character no-undo .
  if p-encode-char = ?
  or p-encode-char = "" then do:
    assign
      p-encode-char = "~~"
    .
  end.
  if p-init-string = "?" then do:
    return ? .
  end.
  assign
    v-num-entries-init-string = num-entries(p-init-string, p-encode-char)
  .
  if v-num-entries-init-string > 1 then do:
    assign
      p-decode-string = entry(1, p-init-string, p-encode-char)
    .
    do ind = 2 to v-num-entries-init-string
    :
      assign
        v-sub-phrase = entry(ind, p-init-string, p-encode-char)
      .
      assign
        v-special-char = octal-to-char(substring(v-sub-phrase, 1, 3))
      .
      if v-special-char <> ? then do:
        assign
          p-decode-string = p-decode-string
                          + v-special-char
                          + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          p-decode-string = p-decode-string
                          + p-encode-char
                          + v-sub-phrase
        .
      end.
    end.
  end.
  else do:
    assign
      p-decode-string = p-init-string
    .
  end.
  return p-decode-string .
end.
define input  parameter parparentproc      as   handle              no-undo.
define input  parameter parcallback        as   handle              no-undo.
define input  parameter pardoc-code        like ub.trn-doc.doc-code no-undo.
define input  parameter parold-supp-cntr   as   logical             no-undo.
define input  parameter parpstunqtn-log    as   logical             no-undo.
define input  parameter parpstunit         as   logical             no-undo.
define input  parameter parmxpcicp-dec     as   decimal             no-undo.
define input  parameter parmxpcdcp-dec     as   decimal             no-undo.
define input  parameter parmxsmicp-dec     as   decimal             no-undo.
define input  parameter parmxsmdcp-dec     as   decimal             no-undo.
define input  parameter parrec-minus-line  as   recid               no-undo.
define input  parameter parrec-plus-line   as   recid               no-undo.
define output parameter parchg             as   logical initial no  no-undo.
define buffer bf_trn-doc           for ub.trn-doc.
define buffer bf-chg_goods         for ub.goods.
define buffer bf-chg-plus_goods    for ub.goods.
define buffer bf-chg_doc-line      for ub.doc-line.
define buffer bf-chg-plus_doc-line for ub.doc-line.
define buffer bf_parts-root        for ub.parts-root.
define buffer bf-plus_parts        for ub.parts.
define buffer bf_parts             for ub.parts.
define buffer bf_gds-prt           for ub.gds-prt.
define buffer bf-plus_gds-prt      for ub.gds-prt.
define buffer bf-chg_doc-pl        for ub.doc-pl.
define buffer bf-chg-plus_doc-pl   for ub.doc-pl.
define buffer bf-chg_gds-dtl       for ub.gds-dtl.
define buffer bf-chg-plus_gds-dtl  for ub.gds-dtl.
define buffer bf-chg_parts         for ub.parts.
define buffer bf-chg-plus_parts    for ub.parts.
define buffer bf-all_parts-root    for ub.parts-root.
define buffer bf-all-plus_parts    for ub.parts.
define variable varqnty             as decimal no-undo.
define variable varqnty-plus        as decimal no-undo.
define variable varqnty-kg          as decimal no-undo.
define variable varqnty-kg-plus     as decimal no-undo.
define variable varis-petrol        as logical no-undo.
define variable varis-pieces        as logical no-undo.
define variable varis-petrol-plus   as logical no-undo.
define variable varis-pieces-plus   as logical no-undo.
define variable varoutgds-code      as integer no-undo.
define variable varoutgds-code-plus as integer no-undo.
define variable varoutqnty          as decimal no-undo.
define variable varoutqnty-plus     as decimal no-undo.
define variable varoutqnty-kg       as decimal no-undo.
define variable varoutqnty-kg-plus  as decimal no-undo.
define variable varhave-chg         as logical no-undo.
define variable vareq               as logical no-undo.
define variable vartotal-chg-qnty         as decimal no-undo.
define variable vartotal-chg-qnty-plus    as decimal no-undo.
define variable vartotal-chg-qnty-kg      as decimal no-undo.
define variable vartotal-chg-qnty-plus-kg as decimal no-undo.
define variable varkoeff                  as decimal no-undo.
define variable varqnty-check             as decimal no-undo.
define variable varqnty-check-plus        as decimal no-undo.
define variable varqnty-check-pl          as decimal no-undo.
define variable varqnty-check-pl-plus     as decimal no-undo.
define variable varqnty-check-pl-kg       as decimal no-undo.
define variable varqnty-check-pl-kg-plus  as decimal no-undo.
define variable varchg-qnty               as decimal no-undo.
define variable varmem-qnty               as decimal no-undo.
define variable varrsrv-qnty              as decimal no-undo.
define variable vardel-qnty               as decimal no-undo.
define variable varreal-del-qnty          as decimal no-undo.
define variable varparts-qnty             as decimal no-undo.
define variable varcorrect-qnty             as decimal no-undo.
define variable varqnty-parts             as integer no-undo.
define variable vartotal-rsrv-qnty-parts  like ub.parts.fact-qnty  no-undo.
define variable varcorrect                as   logical             no-undo.
define variable varcorrect-many           as   logical             no-undo initial no .
define variable varqnty-pieces            as   decimal             no-undo.
define variable varpices-varkoeff         as   decimal             no-undo.
define variable Loc-cr-varkoeff           as   decimal             no-undo.
define variable varoutqnty-plus-temp      as   decimal             no-undo.
define variable varoutqnty-temp           as   decimal             no-undo.
define temp-table tt-parts            no-undo like ub.parts.
define temp-table tt-mem-gds-dtl      no-undo like tt-gds-dtl.
define temp-table tt-mem-gds-dtl-plus no-undo like tt-gds-dtl-plus.
define temp-table tt-mem-pl-qty       no-undo like tt-pl-qty.
define temp-table tt-mem-pl-qty-plus  no-undo like tt-pl-qty-plus.
define temp-table tt-chg-gds-dtl      no-undo like tt-gds-dtl.
define temp-table tt-chg-gds-dtl-plus no-undo like tt-gds-dtl-plus.
define temp-table tt-chg-pl-qty       no-undo like tt-pl-qty.
define temp-table tt-chg-pl-qty-plus  no-undo like tt-pl-qty-plus.
do on error undo, return error return-value :
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code.
find first bf-chg_doc-line where recid (bf-chg_doc-line)      = parrec-minus-line.
find first bf-chg_goods    where bf-chg_goods.artic     = bf-chg_doc-line.artic     and
                                 bf-chg_goods.prod-type = bf-chg_doc-line.prod-type and
                                 bf-chg_goods.prod-code = bf-chg_doc-line.prod-code .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf-chg_goods.artic
  ,  input bf-chg_goods.prod-type
  ,  input bf-chg_goods.prod-code
  , output varis-petrol
  , output varis-pieces
  ) .
if varis-petrol     and
   not varis-pieces then do:
  return error substitute ("Товар &1 &2 &3 &4 - топливо. Топливо не обрабатывается в процедуре на изменение.", bf-chg_goods.artic, bf-chg_goods.prod-type, bf-chg_goods.prod-code, bf-chg_goods.gds-name).
end.
find first bf-chg-plus_doc-line where recid (bf-chg-plus_doc-line) = parrec-plus-line.
find first bf-chg-plus_goods    where bf-chg-plus_goods.artic     = bf-chg-plus_doc-line.artic     and
                                      bf-chg-plus_goods.prod-type = bf-chg-plus_doc-line.prod-type and
                                      bf-chg-plus_goods.prod-code = bf-chg-plus_doc-line.prod-code .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf-chg-plus_goods.artic
  ,  input bf-chg-plus_goods.prod-type
  ,  input bf-chg-plus_goods.prod-code
  , output varis-petrol-plus
  , output varis-pieces-plus
  ) .
if varis-petrol-plus     and
   not varis-pieces-plus then do:
  return error substitute ("Товар &1 &2 &3 &4 - топливо. Топливо не обрабатывается в процедуре на изменение.", bf-chg-plus_goods.artic, bf-chg-plus_goods.prod-type, bf-chg-plus_goods.prod-code, bf-chg-plus_goods.gds-name).
end.
find first bf_gds-prt      where bf_gds-prt.upper-code      = bf-chg_goods.prt-root      no-lock.
find first bf-plus_gds-prt where bf-plus_gds-prt.upper-code = bf-chg-plus_goods.prt-root no-lock.
for each tt-gds-dtl on error undo, return error return-value :
  delete tt-gds-dtl.
end.
for each tt-gds-dtl-plus on error undo, return error return-value :
  delete tt-gds-dtl-plus.
end.
for each bf_parts-root where bf_parts-root.doc-code      = bf_trn-doc.doc-code        and
                             bf_parts-root.orig-gds-code = bf-chg_goods.gds-code      and
                             bf_parts-root.gds-code      = bf-chg-plus_goods.gds-code use-index pi on error undo, return error return-value :
  find first bf-plus_parts where bf-plus_parts.obj-type  = bf_trn-doc.obj-type          and
                                 bf-plus_parts.obj-code  = bf_trn-doc.obj-code          and
                                 bf-plus_parts.artic     = bf-chg-plus_goods.artic      and
                                 bf-plus_parts.prod-type = bf-chg-plus_goods.prod-type  and
                                 bf-plus_parts.prod-code = bf-chg-plus_goods.prod-code  and
                                 bf-plus_parts.in-code   = bf_parts-root.in-code        and
                                 bf-plus_parts.out-code  = bf_parts-root.doc-code       and
                                 bf-plus_parts.part-code = bf_parts-root.part-code  .
  find first bf_parts where bf_parts.obj-type  = bf_trn-doc.obj-type          and
                            bf_parts.obj-code  = bf_trn-doc.obj-code          and
                            bf_parts.artic     = bf-chg_goods.artic           and
                            bf_parts.prod-type = bf-chg_goods.prod-type       and
                            bf_parts.prod-code = bf-chg_goods.prod-code       and
                            bf_parts.in-code   = bf_parts-root.orig-in-code   and
                            bf_parts.out-code  = bf_parts-root.doc-code       and
                            bf_parts.part-code = bf_parts-root.orig-part-code .
  assign
    varqnty      = varqnty      + bf-plus_parts.real-qnty
    varqnty-plus = varqnty-plus + bf-plus_parts.fact-qnty.
end.
for each bf-chg_gds-dtl where bf-chg_gds-dtl.doc-code  = bf_trn-doc.doc-code    and
                              bf-chg_gds-dtl.artic     = bf-chg_goods.artic     and
                              bf-chg_gds-dtl.prod-type = bf-chg_goods.prod-type and
                              bf-chg_gds-dtl.prod-code = bf-chg_goods.prod-code on error undo, return error return-value :
  create tt-mem-gds-dtl.
  assign
    tt-mem-gds-dtl.gds-code = bf-chg_goods.gds-code
    tt-mem-gds-dtl.prt-code = bf-chg_gds-dtl.prt-code
    tt-mem-gds-dtl.qnty     = - bf-chg_gds-dtl.doc-qnty.
end.
for each bf-chg-plus_gds-dtl where bf-chg-plus_gds-dtl.doc-code  = bf_trn-doc.doc-code         and
                                   bf-chg-plus_gds-dtl.artic     = bf-chg-plus_goods.artic     and
                                   bf-chg-plus_gds-dtl.prod-type = bf-chg-plus_goods.prod-type and
                                   bf-chg-plus_gds-dtl.prod-code = bf-chg-plus_goods.prod-code on error undo, return error return-value :
  create tt-mem-gds-dtl-plus.
  assign
    tt-mem-gds-dtl-plus.gds-code = bf-chg-plus_goods.gds-code
    tt-mem-gds-dtl-plus.prt-code = bf-chg-plus_gds-dtl.prt-code
    tt-mem-gds-dtl-plus.qnty     = bf-chg-plus_gds-dtl.doc-qnty.
end.
run str/prst-gds.w (input  parparentproc,
                input  bf_trn-doc.doc-code,
                input  'ИЗМЕНЕНИЕ':U,
                input  bf_trn-doc.obj-type,
                input  bf_trn-doc.obj-code,
                input  bf-chg_goods.gds-code,
                input  bf-chg-plus_goods.gds-code,
                input  varqnty,
                input  ?,
                input  varqnty-plus,
                input  ?,
                input  parpstunqtn-log,
                input  parpstunit,
                input  parmxpcicp-dec,
                input  parmxpcdcp-dec,
                input  parmxsmicp-dec,
                input  parmxsmdcp-dec,
                output varoutgds-code,
                output varoutgds-code-plus,
                output table tt-gds-dtl,
                output table tt-pl-qty,
                output varoutqnty,
                output varoutqnty-plus,
                output varoutqnty-kg,
                output varoutqnty-kg-plus,
                output table tt-gds-dtl-plus,
                output table tt-pl-qty-plus,
                output varhave-chg) no-error.
if varhave-chg = yes then do:
  if not (varoutqnty > 0)  then do:
    undo, return error substitute ("Неверно задано количество по списываемому товару: &1.", varoutqnty).
  end.
  if not (varoutqnty-plus > 0)  then do:
    undo, return error substitute ("Неверно задано количество по оприходуемому товару: &1.", varoutqnty-plus).
  end.
  if varqnty      = varoutqnty      and
     varqnty-plus = varoutqnty-plus then do:
     assign
       vareq = yes.
  end.
  else do:
    assign
      vareq = no.
  end.
  for each tt-gds-dtl on error undo, return error return-value :
    find first tt-mem-gds-dtl where tt-mem-gds-dtl.gds-code = tt-gds-dtl.gds-code and
                                    tt-mem-gds-dtl.prt-code = tt-gds-dtl.prt-code no-error.
    if not available tt-mem-gds-dtl then do:
      assign
        vareq = no.
      create tt-chg-gds-dtl.
      buffer-copy tt-gds-dtl to tt-chg-gds-dtl.
    end.
    else do:
      if tt-mem-gds-dtl.qnty <> tt-gds-dtl.qnty then do:
        assign
          vareq = no.
        create tt-chg-gds-dtl.
        buffer-copy tt-gds-dtl except qnty to tt-chg-gds-dtl.
        assign
          tt-chg-gds-dtl.qnty = tt-gds-dtl.qnty - tt-mem-gds-dtl.qnty .
      end.
    end.
  end.
  for each tt-mem-gds-dtl on error undo, return error return-value :
    find first tt-gds-dtl where tt-gds-dtl.gds-code = tt-mem-gds-dtl.gds-code and
                                tt-gds-dtl.prt-code = tt-mem-gds-dtl.prt-code no-error.
    if not available tt-gds-dtl then do:
      assign
        vareq = no.
      create tt-chg-gds-dtl.
      buffer-copy tt-mem-gds-dtl except qnty to tt-chg-gds-dtl.
      assign
        tt-chg-gds-dtl.qnty = - tt-mem-gds-dtl.qnty.
    end.
  end.
  for each tt-gds-dtl-plus on error undo, return error return-value :
    find first tt-mem-gds-dtl-plus where tt-mem-gds-dtl-plus.gds-code = tt-gds-dtl-plus.gds-code and
                                         tt-mem-gds-dtl-plus.prt-code = tt-gds-dtl-plus.prt-code no-error.
    if not available tt-mem-gds-dtl-plus then do:
      assign
        vareq = no.
      create tt-chg-gds-dtl-plus.
      buffer-copy tt-gds-dtl-plus to tt-chg-gds-dtl-plus.
    end.
    else do:
      if tt-mem-gds-dtl-plus.qnty <> tt-gds-dtl-plus.qnty then do:
        assign
          vareq = no.
        create tt-chg-gds-dtl-plus.
        buffer-copy tt-gds-dtl-plus except qnty to tt-chg-gds-dtl-plus.
        assign
          tt-chg-gds-dtl-plus.qnty = tt-gds-dtl-plus.qnty - tt-mem-gds-dtl-plus.qnty .
      end.
    end.
  end.
  for each tt-mem-gds-dtl-plus on error undo, return error return-value :
    find first tt-gds-dtl-plus where tt-gds-dtl-plus.gds-code = tt-mem-gds-dtl-plus.gds-code and
                                     tt-gds-dtl-plus.prt-code = tt-mem-gds-dtl-plus.prt-code no-error.
    if not available tt-gds-dtl-plus then do:
      assign
        vareq = no.
      create tt-chg-gds-dtl-plus.
      buffer-copy tt-mem-gds-dtl-plus except qnty to tt-chg-gds-dtl-plus.
      assign
        tt-chg-gds-dtl-plus.qnty = - tt-mem-gds-dtl-plus.qnty.
    end.
  end.
  if vareq = yes then do:
    message "Не было изменений по списанным и оприходованным товарам." view-as alert-box information.
    return.
  end.
  assign
    parchg = yes.
  assign
    varkoeff                  = varoutqnty-plus / varoutqnty
    vartotal-chg-qnty         = varoutqnty         - varqnty
    vartotal-chg-qnty-plus    = varoutqnty-plus    - varqnty-plus
    vartotal-chg-qnty-kg      = varoutqnty-kg      - varqnty-kg
    vartotal-chg-qnty-plus-kg = varoutqnty-kg-plus - varqnty-kg-plus
    varoutqnty-plus-temp = varoutqnty-plus
    varoutqnty-temp = varoutqnty
  .
  assign
    varqnty-check            = 0.00
    varqnty-check-plus       = 0.00
    varqnty-check-pl         = 0.00
    varqnty-check-pl-plus    = 0.00
    varqnty-check-pl-kg      = 0.00
    varqnty-check-pl-kg-plus = 0.00
    .
  for each tt-gds-dtl on error undo, return error return-value :
    if tt-gds-dtl.gds-code <> bf-chg_goods.gds-code then do:
      undo, return error substitute ("Критическая ошибка. В признаках для списания товара указан товар с внутренним кодом: &1. Товар для списания с внутренним кодом: &2", tt-gds-dtl.gds-code, bf-chg_goods.gds-code).
    end.
  end.
  for each tt-chg-gds-dtl on error undo, return error return-value :
    assign
      varqnty-check = varqnty-check + tt-chg-gds-dtl.qnty.
  end.
  for each tt-gds-dtl-plus on error undo, return error return-value :
    if tt-gds-dtl-plus.gds-code <> bf-chg-plus_goods.gds-code then do:
      undo, return error substitute ("Критическая ошибка. В признаках для оприходования товара указан товар с внутренним кодом: &1. Товар для оприходования с внутренним кодом: &2.", tt-gds-dtl-plus.gds-code, bf-chg-plus_goods.gds-code).
    end.
  end.
  for each tt-chg-gds-dtl-plus on error undo, return error return-value :
    assign
      varqnty-check-plus = varqnty-check-plus + tt-chg-gds-dtl-plus.qnty.
  end.
  if varoutqnty - varqnty <> varqnty-check then do:
    undo, return error substitute ("Ошибка в количестве по списываемому товару: &1 &2 &3 &4. Количество для списания: &5. Количество для списания по признакам: &6.", bf-chg_goods.artic, bf-chg_goods.prod-type, bf-chg_goods.prod-code, bf-chg_goods.gds-name, varoutqnty - varqnty, varqnty-check) .
  end.
  if varoutqnty-plus - varqnty-plus <> varqnty-check-plus then do:
    undo, return error substitute("Ошибка в количестве по оприходоваемому товару: &1 &2 &3 &4. Количество для оприходования: &5. Количество для приходования по признакам: &6.", bf-chg-plus_goods.artic, bf-chg-plus_goods.prod-type, bf-chg-plus_goods.prod-code, bf-chg-plus_goods.gds-name, varoutqnty-plus - varqnty-plus, varqnty-check-plus).
  end.
  run local-recalc in parcallback (input "old":u,
                                   input recid(bf-chg_doc-line),
                                   input yes) no-error.
  if error-status:error then do:
    undo, return error substitute ("Ошибка при пересчете строки документа: ", return-value).
  end.
  for each tt-parts on error undo, return error return-value :
    delete tt-parts.
  end.
  for each bf-chg_parts where bf-chg_parts.out-code   = bf_trn-doc.doc-code    and
                              bf-chg_parts.obj-type   = bf_trn-doc.obj-type    and
                              bf-chg_parts.obj-code   = bf_trn-doc.obj-code    and
                              bf-chg_parts.artic      = bf-chg_goods.artic     and
                              bf-chg_parts.prod-type  = bf-chg_goods.prod-type and
                              bf-chg_parts.prod-code  = bf-chg_goods.prod-code and
                              bf-chg_parts.fact-qnty  < 0                      on error undo, return error return-value :
    create tt-parts.
    buffer-copy bf-chg_parts to tt-parts.
  end.
  find first bf-chg_gds-dtl where bf-chg_gds-dtl.doc-code  = bf_trn-doc.doc-code    and
                                  bf-chg_gds-dtl.artic     = bf-chg_goods.artic     and
                                  bf-chg_gds-dtl.prod-type = bf-chg_goods.prod-type and
                                  bf-chg_gds-dtl.prod-code = bf-chg_goods.prod-code .
  if vartotal-chg-qnty > 0 then do:
    assign
      varchg-qnty = - vartotal-chg-qnty
      varmem-qnty = varchg-qnty.
    run trg/rsrv-dtl.p (input parparentproc,
                    'reserv':U + ',' + 'negative-check':U + "=2",
                    buffer bf-chg_gds-dtl,
                    input-output varchg-qnty,
                    input-output bf-chg_doc-line.price-base,
                    input-output bf-chg_doc-line.price-rubl,
                    -1, "") no-error.
    if error-status:error then do:
      undo, return error substitute ("Ошибка при резервировании по товару &1 &2 &3 &4: &5.", bf-chg_goods.artic, bf-chg_goods.prod-type, bf-chg_goods.prod-code, bf-chg_goods.gds-name, return-value).
    end.
    if varmem-qnty <> varchg-qnty then do:
      undo, return error substitute("Не все количество было зарезервировано по товару: &1 &2 &3 &4. Количество для резервирования: &5. Зарезервированное количество: &6.", bf-chg_goods.artic, bf-chg_goods.prod-type, bf-chg_goods.prod-code, bf-chg_goods.gds-name, varmem-qnty, varchg-qnty).
    end.
  end.
  else do:
    if vartotal-chg-qnty < 0 then do:
      assign
        varchg-qnty = - vartotal-chg-qnty.
      rsrv-parts-root:
      for each bf_parts-root where bf_parts-root.doc-code      = bf_trn-doc.doc-code        and
                                   bf_parts-root.orig-gds-code = bf-chg_goods.gds-code      and
                                   bf_parts-root.gds-code      = bf-chg-plus_goods.gds-code ,
         first bf-chg_parts where bf-chg_parts.obj-type  = bf_trn-doc.obj-type          and
                                  bf-chg_parts.obj-code  = bf_trn-doc.obj-code          and
                                  bf-chg_parts.artic     = bf-chg_goods.artic           and
                                  bf-chg_parts.prod-type = bf-chg_goods.prod-type       and
                                  bf-chg_parts.prod-code = bf-chg_goods.prod-code       and
                                  bf-chg_parts.in-code   = bf_parts-root.orig-in-code   and
                                  bf-chg_parts.out-code  = bf_trn-doc.doc-code          and
                                  bf-chg_parts.part-code = bf_parts-root.orig-part-code and
                                  bf-chg_parts.fact-qnty < 0                            on error undo, return error return-value :
        if - bf-chg_parts.fact-qnty >= varchg-qnty then do:
          assign
            varrsrv-qnty = varchg-qnty
            varmem-qnty  = varrsrv-qnty.
          run trg/rsrv-dtl.p (input parparentproc,
                         'reserv':U
                         + "," + 'rsrv-single-part':U
                         + "," + 'rsrv-in-code':U   + "=" + str-encode(bf-chg_parts.in-code, "", ",=":u)
                         + "," + 'rsrv-part-code':U + "=" + str-encode(bf-chg_parts.part-code, "", ",=":u)
                         + ',' + 'negative-check':U + "=2",
                          buffer bf-chg_gds-dtl,
                          input-output varrsrv-qnty,
                          input-output bf-chg_doc-line.price-base,
                          input-output bf-chg_doc-line.price-rubl,
                         -1, "") no-error.
          if error-status:error then do:
            undo, return error substitute ("Ошибка при резервировании по товару &1 &2 &3 &4: &5.", bf-chg_goods.artic, bf-chg_goods.prod-type, bf-chg_goods.prod-code, bf-chg_goods.gds-name, return-value).
          end.
          if varmem-qnty <> varrsrv-qnty then do:
            undo, return error substitute("Не все количество было зарезервировано по товару: &1 &2 &3 &4. Количество для резервирования: &5. Зарезервированное количество: &6.", bf-chg_goods.artic, bf-chg_goods.prod-type, bf-chg_goods.prod-code, bf-chg_goods.gds-name, varmem-qnty, varrsrv-qnty).
          end.
          assign
            varchg-qnty        = 0.
          if available bf-chg_parts and
             bf-chg_parts.qnty = 0 then do:
             delete bf-chg_parts.
          end.
          leave rsrv-parts-root.
        end.
        else do:
          assign
            varrsrv-qnty = - bf-chg_parts.fact-qnty
            varmem-qnty  = varrsrv-qnty
            varchg-qnty  = varchg-qnty + bf-chg_parts.fact-qnty.
          run trg/rsrv-dtl.p (input parparentproc,
                         'reserv':U
                         + "," + 'rsrv-single-part':U
                         + "," + 'rsrv-in-code':U   + "=" + str-encode(bf-chg_parts.in-code, "", ",=":u)
                         + "," + 'rsrv-part-code':U + "=" + str-encode(bf-chg_parts.part-code, "", ",=":u)
                         + ',' + 'negative-check':U + "=2",
                          buffer bf-chg_gds-dtl,
                          input-output varrsrv-qnty,
                          input-output bf-chg_doc-line.price-base,
                          input-output bf-chg_doc-line.price-rubl,
                         -1, "") no-error.
          if error-status:error then do:
            undo, return error substitute ("Ошибка при резервировании по товару &1 &2 &3 &4: &5.", bf-chg_goods.artic, bf-chg_goods.prod-type, bf-chg_goods.prod-code, bf-chg_goods.gds-name, return-value).
          end.
          if varmem-qnty <> varrsrv-qnty then do:
            undo, return error substitute("Не все количество было зарезервировано по товару: &1 &2 &3 &4. Количество для резервирования: &5. Зарезервированное количество: &6.", bf-chg_goods.artic, bf-chg_goods.prod-type, bf-chg_goods.prod-code, bf-chg_goods.gds-name, varmem-qnty, varrsrv-qnty).
          end.
        end.
      end.
    end.
    if varchg-qnty <> 0 then do:
      return error substitute ("Не удалось изменить списанное количество по товару &1 &2 &3 &4. Запрос на резерв &5. Недорезервировано &6.",
                               bf-chg_goods.artic,
                               bf-chg_goods.prod-type,
                               bf-chg_goods.prod-code,
                               bf-chg_goods.gds-name,
                               varmem-qnty,
                               varchg-qnty).
    end.
  end.
  assign
    bf-chg_doc-line.fact-qnty      = bf-chg_doc-line.fact-qnty     - (varoutqnty    - varqnty)
    bf-chg_doc-line.cli-qnty       = bf-chg_doc-line.cli-qnty      - (varoutqnty-kg - varqnty-kg)
  .
  for each tt-chg-gds-dtl on error undo, return error return-value :
    find first bf-chg_gds-dtl where bf-chg_gds-dtl.doc-code  = bf_trn-doc.doc-code      and
                                    bf-chg_gds-dtl.artic     = bf-chg_goods.artic       and
                                    bf-chg_gds-dtl.prod-type = bf-chg_goods.prod-type   and
                                    bf-chg_gds-dtl.prod-code = bf-chg_goods.prod-code   and
                                    bf-chg_gds-dtl.prt-code  = tt-chg-gds-dtl.prt-code  no-error.
    if not available bf-chg_gds-dtl then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input bf_trn-doc.obj-code
   ,input bf_trn-doc.obj-type
   ,input bf_trn-doc.doc-code
   ,input bf-chg_goods.artic
   ,input bf-chg_goods.prod-code
   ,input bf-chg_goods.prod-type
   ,input tt-chg-gds-dtl.prt-code
   ,input yes
  ) no-error .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(bf-chg_gds-dtl)
  , input no
  , input ?
  ) no-error.
      if error-status:error then do:
        undo, return error substitute ("Ошибка при установке цены признака товара: &1 &2 &3 &4 &5 на объекте: &6 &7.", bf-chg_goods.artic, bf-chg_goods.prod-type, bf-chg_goods.prod-code, bf-chg_goods.gds-name, tt-chg-gds-dtl.prt-code, bf_trn-doc.obj-type, bf_trn-doc.obj-code).
      end.
    end.
    assign
      bf-chg_gds-dtl.doc-qnty = bf-chg_gds-dtl.doc-qnty - tt-chg-gds-dtl.qnty .
  end.
  run local-recalc in parcallback (input "update":u,
                                   input recid(bf-chg_doc-line),
                                   input yes) no-error.
  if error-status:error then do:
    undo, return error substitute ("Ошибка при пересчете строки документа: ", return-value).
  end.
  run local-recalc in parcallback (input "old":u,
                                   input recid(bf-chg-plus_doc-line),
                                   input no) no-error.
  if error-status:error then do:
    undo, return error substitute ("Ошибка при пересчете строки документа: ", return-value).
  end.
  if vartotal-chg-qnty > 0 then do:
    for each bf-chg_parts where bf-chg_parts.out-code   = bf_trn-doc.doc-code    and
                                bf-chg_parts.obj-type   = bf_trn-doc.obj-type    and
                                bf-chg_parts.obj-code   = bf_trn-doc.obj-code    and
                                bf-chg_parts.artic      = bf-chg_goods.artic     and
                                bf-chg_parts.prod-type  = bf-chg_goods.prod-type and
                                bf-chg_parts.prod-code  = bf-chg_goods.prod-code and
                                bf-chg_parts.fact-qnty  < 0                      on error undo, return error return-value :
      find first tt-parts where tt-parts.obj-type  = bf-chg_parts.obj-type  and
                                tt-parts.obj-code  = bf-chg_parts.obj-code  and
                                tt-parts.artic     = bf-chg_parts.artic     and
                                tt-parts.prod-type = bf-chg_parts.prod-type and
                                tt-parts.prod-code = bf-chg_parts.prod-code and
                                tt-parts.in-code   = bf-chg_parts.in-code   and
                                tt-parts.out-code  = bf-chg_parts.out-code  and
                                tt-parts.part-code = bf-chg_parts.part-code  no-error.
      if not available tt-parts then do:
        run local-create-parts in this-procedure
          (input 0,
           input 0,
           input 0,
           input 0,
           input 0,
           input 0,
           (if parold-supp-cntr then bf-chg_parts.supp-type     else bf_trn-doc.cli-type),
           (if parold-supp-cntr then bf-chg_parts.supp-code     else bf_trn-doc.cli-code),
           (if parold-supp-cntr then bf-chg_parts.contract-code else bf_trn-doc.contract-code)
          ) no-error.
        if error-status :error then do:
          undo, return error substitute ("Ошибка при создании партии: &1", return-value).
        end.
      end.
    end.
  end.
  else do:
    for each tt-parts on error undo, return error return-value :
      find first bf-chg_parts where bf-chg_parts.obj-type  = tt-parts.obj-type   and
                                    bf-chg_parts.obj-code  = tt-parts.obj-code   and
                                    bf-chg_parts.artic     = tt-parts.artic      and
                                    bf-chg_parts.prod-type = tt-parts.prod-type  and
                                    bf-chg_parts.prod-code = tt-parts.prod-code  and
                                    bf-chg_parts.in-code   = tt-parts.in-code    and
                                    bf-chg_parts.out-code  = tt-parts.out-code   and
                                    bf-chg_parts.part-code = tt-parts.part-code  no-error.
      if not available bf-chg_parts then do:
        assign
          vardel-qnty      = tt-parts.fact-qnty
          varreal-del-qnty = 0.
        for each bf_parts-root where bf_parts-root.doc-code       = bf_trn-doc.doc-code   and
                                     bf_parts-root.orig-in-code   = tt-parts.in-code      and
                                     bf_parts-root.orig-gds-code  = bf-chg_goods.gds-code and
                                     bf_parts-root.orig-part-code = tt-parts.part-code    ,
          first bf-chg-plus_parts where bf-chg-plus_parts.obj-type  = bf_trn-doc.obj-type         and
                                        bf-chg-plus_parts.obj-code  = bf_trn-doc.obj-code         and
                                        bf-chg-plus_parts.artic     = bf-chg-plus_goods.artic     and
                                        bf-chg-plus_parts.prod-type = bf-chg-plus_goods.prod-type and
                                        bf-chg-plus_parts.prod-code = bf-chg-plus_goods.prod-code and
                                        bf-chg-plus_parts.in-code   = bf_parts-root.in-code       and
                                        bf-chg-plus_parts.out-code  = bf_trn-doc.doc-code         and
                                        bf-chg-plus_parts.part-code = bf_parts-root.part-code     on error undo, return error return-value :
          assign
            varreal-del-qnty = varreal-del-qnty + bf-chg-plus_parts.real-qnty.
          delete bf-chg-plus_parts.
          delete bf_parts-root.
        end.
        if - vardel-qnty <> varreal-del-qnty then do:
          return error substitute ("При удалении партий оприходованного товара по удаляемым партиям списанного товара не удалось удалить должное количество партий. Удалялась списываемая партия (пн &1 код &2) с количеством &3. Партии оприходуемого товара покрывают списываемое количество &4", tt-parts.in-code, tt-parts.part-code, vardel-qnty, varreal-del-qnty).
        end.
      end.
    end.
  end.
  assign
    vartotal-rsrv-qnty-parts = 0.00
    varpices-varkoeff = varkoeff
  .
  for each bf_parts-root where bf_parts-root.doc-code      = bf_trn-doc.doc-code        and
                               bf_parts-root.orig-gds-code = bf-chg_goods.gds-code      and
                               bf_parts-root.gds-code      = bf-chg-plus_goods.gds-code on error undo, return error return-value :
    find first bf-chg_parts where bf-chg_parts.obj-type  = bf_trn-doc.obj-type          and
                                  bf-chg_parts.obj-code  = bf_trn-doc.obj-code          and
                                  bf-chg_parts.artic     = bf-chg_goods.artic           and
                                  bf-chg_parts.prod-type = bf-chg_goods.prod-type       and
                                  bf-chg_parts.prod-code = bf-chg_goods.prod-code       and
                                  bf-chg_parts.in-code   = bf_parts-root.orig-in-code   and
                                  bf-chg_parts.out-code  = bf_trn-doc.doc-code          and
                                  bf-chg_parts.part-code = bf_parts-root.orig-part-code and
                                  bf-chg_parts.fact-qnty < 0                            .
    assign
      varcorrect-qnty = 0
      varqnty-parts = 0.
    for each bf-all_parts-root where bf-all_parts-root.doc-code       = bf_trn-doc.doc-code    and
                                     bf-all_parts-root.orig-in-code   = bf-chg_parts.in-code   and
                                     bf-all_parts-root.orig-gds-code  = bf-chg_goods.gds-code  and
                                     bf-all_parts-root.orig-part-code = bf-chg_parts.part-code on error undo, return error :
      if bf-all_parts-root.gds-code <> bf-chg-plus_goods.gds-code then do :
        find first bf-all-plus_parts where bf-all-plus_parts.obj-type  = bf_trn-doc.obj-type         and
                                           bf-all-plus_parts.obj-code  = bf_trn-doc.obj-code         and
                                           (bf-all-plus_parts.artic    <> bf-chg-plus_goods.artic     or
                                           bf-all-plus_parts.prod-type <> bf-chg-plus_goods.prod-type or
                                           bf-all-plus_parts.prod-code <> bf-chg-plus_goods.prod-code) and
                                           bf-all-plus_parts.in-code   = bf-all_parts-root.in-code   and
                                           bf-all-plus_parts.out-code  = bf_trn-doc.doc-code         and
                                           bf-all-plus_parts.part-code = bf-all_parts-root.part-code no-error.
        if available bf-all-plus_parts then do :
            assign
                varcorrect-qnty = varcorrect-qnty + bf-all-plus_parts.fact-qnty
                varcorrect-many = yes
            .
        end.
      end.
      else assign
        varqnty-parts = varqnty-parts + 1.
      if varqnty-parts > 1 and bf-all_parts-root.gds-code = bf-chg-plus_goods.gds-code then do:
        find first bf-all-plus_parts where bf-all-plus_parts.obj-type  = bf_trn-doc.obj-type         and
                                           bf-all-plus_parts.obj-code  = bf_trn-doc.obj-code         and
                                           bf-all-plus_parts.artic     = bf-chg-plus_goods.artic     and
                                           bf-all-plus_parts.prod-type = bf-chg-plus_goods.prod-type and
                                           bf-all-plus_parts.prod-code = bf-chg-plus_goods.prod-code and
                                           bf-all-plus_parts.in-code   = bf-all_parts-root.in-code   and
                                           bf-all-plus_parts.out-code  = bf_trn-doc.doc-code         and
                                           bf-all-plus_parts.part-code = bf-all_parts-root.part-code no-error.
        delete bf-all-plus_parts no-error.
        delete bf-all_parts-root.
      end.
    end.
    find first bf-chg-plus_parts where bf-chg-plus_parts.obj-type  = bf_trn-doc.obj-type         and
                                       bf-chg-plus_parts.obj-code  = bf_trn-doc.obj-code         and
                                       bf-chg-plus_parts.artic     = bf-chg-plus_goods.artic     and
                                       bf-chg-plus_parts.prod-type = bf-chg-plus_goods.prod-type and
                                       bf-chg-plus_parts.prod-code = bf-chg-plus_goods.prod-code and
                                       bf-chg-plus_parts.in-code   = bf_parts-root.in-code       and
                                       bf-chg-plus_parts.out-code  = bf_trn-doc.doc-code         and
                                       bf-chg-plus_parts.part-code = bf_parts-root.part-code .
    if varis-pieces-plus and not varis-petrol-plus then do:
        if varoutqnty = (if available tt-parts then - (bf-chg_parts.fact-qnty - tt-parts.fact-qnty) else - bf-chg_parts.fact-qnty) then varqnty-pieces = varoutqnty-plus.
        else  varqnty-pieces = max(1,(if available tt-parts then - truncate((bf-chg_parts.fact-qnty - tt-parts.fact-qnty) * varpices-varkoeff, 0) else - truncate(bf-chg_parts.fact-qnty * varpices-varkoeff, 0))).
        Loc-cr-varkoeff =  varqnty-pieces / (if available tt-parts then - (bf-chg_parts.fact-qnty - tt-parts.fact-qnty)  else - bf-chg_parts.fact-qnty).
        assign
          bf-chg-plus_parts.qnty          = ( - bf-chg_parts.fact-qnty - (if varcorrect-many then varcorrect-qnty else 0)) * Loc-cr-varkoeff
          bf-chg-plus_parts.fact-qnty     = bf-chg-plus_parts.qnty
          bf-chg-plus_parts.cli-qnty      = bf-chg-plus_parts.qnty
          bf-chg-plus_parts.price-cli     = bf-chg_parts.price-rubl / Loc-cr-varkoeff
          bf-chg-plus_parts.cli-base-rate = 1
          bf-chg-plus_parts.real-qnty     = ( - bf-chg_parts.fact-qnty - (if varcorrect-many then varcorrect-qnty else 0))
          bf-chg-plus_parts.price-base    = bf-chg_parts.price-base / Loc-cr-varkoeff
          bf-chg-plus_parts.price-rubl    = bf-chg_parts.price-rubl / Loc-cr-varkoeff
        .
        varoutqnty-plus = varoutqnty-plus - varqnty-pieces.
        varoutqnty = varoutqnty - (if available tt-parts then - (bf-chg_parts.fact-qnty - tt-parts.fact-qnty)  else - bf-chg_parts.fact-qnty).
        varpices-varkoeff = varoutqnty-plus / varoutqnty.
    end.
    else do:
        assign
          bf-chg-plus_parts.qnty          = - bf-chg_parts.fact-qnty * varkoeff
          bf-chg-plus_parts.fact-qnty     = bf-chg-plus_parts.qnty
          bf-chg-plus_parts.cli-qnty      = bf-chg-plus_parts.qnty
          bf-chg-plus_parts.price-cli     = bf-chg_parts.price-rubl / varkoeff
          bf-chg-plus_parts.cli-base-rate = 1
          bf-chg-plus_parts.real-qnty     = - bf-chg_parts.fact-qnty
          bf-chg-plus_parts.price-base    = bf-chg_parts.price-base / varkoeff
          bf-chg-plus_parts.price-rubl    = bf-chg_parts.price-rubl / varkoeff
        .
    end.
    assign
      vartotal-rsrv-qnty-parts = vartotal-rsrv-qnty-parts + bf-chg-plus_parts.qnty.
  end.
  assign
    bf-chg-plus_doc-line.fact-qnty = bf-chg-plus_doc-line.fact-qnty + (varoutqnty-plus-temp - varqnty-plus)
    bf-chg-plus_doc-line.cli-qnty  = bf-chg-plus_doc-line.cli-qnty  + (varoutqnty-kg-plus - varqnty-kg-plus)
  .
  if vartotal-rsrv-qnty-parts <> bf-chg-plus_doc-line.fact-qnty then do:
    if vartotal-rsrv-qnty-parts <> bf-chg-plus_doc-line.fact-qnty then do:
      if abs (vartotal-rsrv-qnty-parts - bf-chg-plus_doc-line.fact-qnty) > 0.01 then do:
         message "Невозможно зарезервировать данную связку товаров при установленных количествах." skip
                 "Зарезервированное количество по партиям:" vartotal-rsrv-qnty-parts skip
                 "Зарезервированное количество по строке: " bf-chg-plus_doc-line.fact-qnty
         view-as alert-box.
         return error.
      end.
      assign
        varcorrect = no.
      for each bf_parts-root where bf_parts-root.doc-code      = bf_trn-doc.doc-code        and
                                   bf_parts-root.orig-gds-code = bf-chg_goods.gds-code      and
                                   bf_parts-root.gds-code      = bf-chg-plus_goods.gds-code,
        first bf-chg-plus_parts where bf-chg-plus_parts.out-code   = bf_trn-doc.doc-code         and
                                      bf-chg-plus_parts.obj-type   = bf_trn-doc.obj-type         and
                                      bf-chg-plus_parts.obj-code   = bf_trn-doc.obj-code         and
                                      bf-chg-plus_parts.artic      = bf-chg-plus_goods.artic     and
                                      bf-chg-plus_parts.prod-type  = bf-chg-plus_goods.prod-type and
                                      bf-chg-plus_parts.prod-code  = bf-chg-plus_goods.prod-code and
                                      bf-chg-plus_parts.in-code    = bf_parts-root.in-code       and
                                      bf-chg-plus_parts.part-code  = bf_parts-root.part-code     and
                                      bf-chg-plus_parts.fact-qnty  > 0                           and
                                      bf-chg-plus_parts.fact-qnty  > vartotal-rsrv-qnty-parts - bf-chg-plus_doc-line.fact-qnty :
        assign
          bf-chg-plus_parts.fact-qnty = bf-chg-plus_parts.fact-qnty - (vartotal-rsrv-qnty-parts - bf-chg-plus_doc-line.fact-qnty)
          varcorrect = yes.
        leave.
      end.
      if varcorrect = no then do:
         message "Невозможно зарезервировать данную связку товаров при установленных количествах." skip
         view-as alert-box.
         return error.
      end.
    end.
  end.
  for each tt-chg-gds-dtl-plus on error undo, return error return-value :
    find first bf-chg-plus_gds-dtl where bf-chg-plus_gds-dtl.doc-code  = bf_trn-doc.doc-code          and
                                         bf-chg-plus_gds-dtl.artic     = bf-chg-plus_goods.artic      and
                                         bf-chg-plus_gds-dtl.prod-type = bf-chg-plus_goods.prod-type  and
                                         bf-chg-plus_gds-dtl.prod-code = bf-chg-plus_goods.prod-code  and
                                         bf-chg-plus_gds-dtl.prt-code  = tt-chg-gds-dtl-plus.prt-code no-error.
    if not available bf-chg-plus_gds-dtl then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input bf_trn-doc.obj-code
   ,input bf_trn-doc.obj-type
   ,input bf_trn-doc.doc-code
   ,input bf-chg-plus_goods.artic
   ,input bf-chg-plus_goods.prod-code
   ,input bf-chg-plus_goods.prod-type
   ,input tt-chg-gds-dtl-plus.prt-code
   ,input yes
  ) no-error .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(bf-chg-plus_gds-dtl)
  , input no
  , input ?
  ) no-error.
      if error-status:error then do:
        undo, return error substitute ("Ошибка при установке цены признака товара: &1 &2 &3 &4 &5 на объекте: &6 &7.", bf-chg-plus_goods.artic, bf-chg-plus_goods.prod-type, bf-chg-plus_goods.prod-code, bf-chg-plus_goods.gds-name, tt-chg-gds-dtl-plus.prt-code, bf_trn-doc.obj-type, bf_trn-doc.obj-code).
      end.
    end.
    assign
      bf-chg-plus_gds-dtl.doc-qnty = bf-chg-plus_gds-dtl.doc-qnty + tt-chg-gds-dtl-plus.qnty .
  end.
  run local-recalc in parcallback (input "update":u,
                                   input recid(bf-chg-plus_doc-line),
                                   input no) no-error.
  if error-status:error then do:
    undo, return error substitute ("Ошибка при пересчете строки документа: ", return-value).
  end.
end.
end.
procedure local-create-parts:
define input parameter parqnty          as decimal   no-undo.
define input parameter parcli-qnty      as decimal   no-undo.
define input parameter parprice-cli     as decimal   no-undo.
define input parameter parcli-base-rate as decimal   no-undo.
define input parameter parreal-qnty     as decimal   no-undo.
define input parameter parpl-code       as integer   no-undo.
define input parameter parsupp-type     as character no-undo.
define input parameter parsupp-code     as integer   no-undo.
define input parameter parcontract-code as integer   no-undo.
define buffer bf-chg-cr_parts-root for ub.parts-root.
define buffer bf-chg-plus-cr_parts for ub.parts.
define variable varpart-code as character no-undo.
do on error undo, return error return-value :
  run holdprts-get-part-code in parcallback ( input bf_trn-doc.doc-code
                                             ,output varpart-code
                                            ) no-error .
  if error-status:error then do:
    undo, return error substitute ("Ошибка при получении кода партии: &1", return-value).
  end.
  create bf-chg-plus-cr_parts.
  assign
    bf-chg-plus-cr_parts.prod-type      = bf-chg-plus_goods.prod-type
    bf-chg-plus-cr_parts.prod-code      = bf-chg-plus_goods.prod-code
    bf-chg-plus-cr_parts.artic          = bf-chg-plus_goods.artic
    bf-chg-plus-cr_parts.in-code        = bf_trn-doc.doc-code
    bf-chg-plus-cr_parts.out-code       = bf_trn-doc.doc-code
    bf-chg-plus-cr_parts.price-base     = bf-chg_parts.price-base / varkoeff
    bf-chg-plus-cr_parts.price-rubl     = bf-chg_parts.price-rubl / varkoeff
    bf-chg-plus-cr_parts.obj-type       = bf_trn-doc.obj-type
    bf-chg-plus-cr_parts.obj-code       = bf_trn-doc.obj-code
    bf-chg-plus-cr_parts.VAT-pc         = bf-chg_parts.vat-pc
    bf-chg-plus-cr_parts.part-code      = varpart-code
    bf-chg-plus-cr_parts.PS             = bf-chg_parts.PS
    bf-chg-plus-cr_parts.pay-code       = bf-chg_parts.pay-code
    bf-chg-plus-cr_parts.status_        = no
    bf-chg-plus-cr_parts.supp-type      = parsupp-type
    bf-chg-plus-cr_parts.supp-code      = parsupp-code
    bf-chg-plus-cr_parts.rsrv-free      = ?
    bf-chg-plus-cr_parts.doc-type       = bf_trn-doc.doc-type
    bf-chg-plus-cr_parts.pl-code        = 0
    bf-chg-plus-cr_parts.VAT-type       = bf-chg_parts.vat-type
    bf-chg-plus-cr_parts.exch-code      = 0
    bf-chg-plus-cr_parts.SLT-pc         = bf-chg_parts.slt-pc
    bf-chg-plus-cr_parts.host-code      = bf_trn-doc.host-code
    bf-chg-plus-cr_parts.is-supp        = yes
    bf-chg-plus-cr_parts.SLT-type       = bf-chg_parts.slt-type
    bf-chg-plus-cr_parts.cst-code       = "":u
    bf-chg-plus-cr_parts.last-date      = ?
    bf-chg-plus-cr_parts.road-tax-base  = bf-chg_parts.road-tax-base  / varkoeff
    bf-chg-plus-cr_parts.road-tax-rubl  = bf-chg_parts.road-tax-rubl  / varkoeff
    bf-chg-plus-cr_parts.transport-base = bf-chg_parts.transport-base / varkoeff
    bf-chg-plus-cr_parts.transport-rubl = bf-chg_parts.transport-rubl / varkoeff
    bf-chg-plus-cr_parts.other-base     = bf-chg_parts.other-base     / varkoeff
    bf-chg-plus-cr_parts.other-rubl     = bf-chg_parts.other-rubl     / varkoeff
    bf-chg-plus-cr_parts.purch-code     = bf-chg_parts.purch-code
    bf-chg-plus-cr_parts.contract-code  = parcontract-code
    bf-chg-plus-cr_parts.qnty           = parqnty
    bf-chg-plus-cr_parts.cli-qnty       = parcli-qnty
    bf-chg-plus-cr_parts.price-cli      = parprice-cli
    bf-chg-plus-cr_parts.cli-base-rate  = parcli-base-rate
    bf-chg-plus-cr_parts.real-qnty      = parreal-qnty
    bf-chg-plus-cr_parts.fact-qnty      = bf-chg-plus-cr_parts.qnty
    bf-chg-plus-cr_parts.pl-code        = parpl-code
  .
  if bf-chg-plus-cr_parts.supp-type = bf-chg-plus-cr_parts.obj-type and
     bf-chg-plus-cr_parts.supp-code = bf-chg-plus-cr_parts.obj-code then do:
    assign
      bf-chg-plus-cr_parts.is-supp = no.
  end.
  create bf-chg-cr_parts-root.
  assign
    bf-chg-cr_parts-root.doc-code       = bf-chg_parts.out-code
    bf-chg-cr_parts-root.orig-in-code   = bf-chg_parts.in-code
    bf-chg-cr_parts-root.orig-gds-code  = bf-chg_goods.gds-code
    bf-chg-cr_parts-root.orig-part-code = bf-chg_parts.part-code
    bf-chg-cr_parts-root.in-code        = bf-chg-plus-cr_parts.in-code
    bf-chg-cr_parts-root.gds-code       = bf-chg-plus_goods.gds-code
    bf-chg-cr_parts-root.part-code      = bf-chg-plus-cr_parts.part-code
  .
end.
end procedure.
