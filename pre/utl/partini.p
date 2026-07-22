block-level on error undo, throw.
define input parameter l-update-free-zone     as logical no-undo .
define input parameter l-update-out-zone      as logical no-undo .
define input parameter l-update-archive-parts as logical no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: partini.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/partini.p $":U .
define variable vss-description as character no-undo init "Инициализация партий на основании складских документов".
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
if l-update-free-zone then do:
  for each ub.parts
    where ub.parts.out-code = 'free-zone':U
  :
    run process-part.
    process events.
  end.
end.
if l-update-out-zone then do:
  for each ub.parts
    where ub.parts.out-code = 'out-zone':U
  :
    run process-part.
    process events.
  end.
end.
if l-update-archive-parts then do:
  for each ub.parts
    where ub.parts.out-code <> 'free-zone':U
      and ub.parts.out-code <> 'out-zone':U
  :
    run process-part.
    process events.
  end.
end.
procedure process-part :
  output to process.txt append .
  export ub.parts .
  output close .
  if ub.parts.doc-type = 'акт':U then do:
    assign
      rsrv-free = ?
    .
    next .
  end.
  find ub.trn-doc no-lock
    where ub.trn-doc.doc-code = ub.parts.in-code
    no-error.
  if available trn-doc then do:
    assign
      ub.parts.doc-type  = ub.trn-doc.doc-type
      ub.parts.host-code = ub.trn-doc.host-code
      ub.parts.exch-code = ub.trn-doc.exch-code
      ub.parts.pay-code  = ub.trn-doc.pay-code
      ub.parts.supp-code = ub.trn-doc.cli-code
      ub.parts.supp-type = ub.trn-doc.cli-type
      ub.parts.VAT-type  = ub.trn-doc.VAT-type
      ub.parts.SLT-type  = ub.trn-doc.SLT-type
      ub.parts.fact-num  = ub.trn-doc.fact-num
      ub.parts.fact-date = ub.trn-doc.fact-date
      ub.parts.is-supp   = (ub.trn-doc.doc-type = 'при':U
                            and not ub.trn-doc.internal
                           )
    .
    find ub.doc-line no-lock
      where ub.doc-line.doc-code  = ub.parts.in-code
        and ub.doc-line.artic     = ub.parts.artic
        and ub.doc-line.prod-type = ub.parts.prod-type
        and ub.doc-line.prod-code = ub.parts.prod-code
      no-error.
    if available doc-line then do:
      assign
        ub.parts.VAT-pc        = ub.doc-line.VAT-pc
        ub.parts.SLT-pc        = ub.doc-line.SLT-pc
        ub.parts.cli-base-rate = ub.doc-line.cli-base-rate
        ub.parts.price-base    = ub.doc-line.price-base
        ub.parts.price-rubl    = ub.doc-line.price-rubl
        ub.parts.price-cli     = ub.doc-line.price-cli
      .
    end.
    else do:
      assign
        ub.parts.VAT-pc = 20
        ub.parts.SLT-pc = 0
        ub.parts.cli-base-rate = 1
      .
    end.
    if ub.parts.cli-base-rate <> 0 then do:
      assign
        ub.parts.cli-qnty  = ub.parts.qnty / ub.parts.cli-base-rate
      .
    end.
    if ub.trn-doc.exch-rate <> 0 then do:
      assign
        ub.parts.price-cli  = ub.parts.price-rubl
                            * ( ub.trn-doc.exch-scale / ub.trn-doc.exch-rate )
                            * ub.parts.cli-base-rate
      .
    end.
    else do:
      assign
        ub.parts.price-cli  = 0
      .
    end.
  end.
  else do:
    output to ini-part.txt append .
    export 'trn-doc: bad in-code ' parts.in-code recid(parts).
    output close .
  end.
  case parts.out-code:
    when 'free-zone':U or
    when 'out-zone':U then do:
      assign
        parts.status_   = no
        parts.rsrv-free =
       (if ub.parts.out-code = 'free-zone':U then yes else no)
      .
    end.
    otherwise do:
      find trn-doc no-lock
        where trn-doc.doc-code = parts.out-code
        no-error.
      if available trn-doc then do:
        assign
          parts.doc-type = trn-doc.doc-type
        .
        if trn-doc.status_ = 'факт':U then do:
          assign
            parts.fact-num  = trn-doc.fact-num
            parts.fact-date = trn-doc.fact-date
            parts.rsrv-free = ?
            parts.status_   = yes
          .
        end.
        else do:
          if trn-doc.internal then do:
          end.
          else do:
            assign
              parts.rsrv-free =
        ( (lookup(ub.trn-doc.doc-type, 'рас,спи':U) > 0 )
      or (ub.trn-doc.doc-type = 'инв':U and ub.parts.fact-qnty < 0))
            .
          end.
        end.
      end.
      else do:
        output to ini-part.txt append .
        export 'trn-doc: bad out-code' parts.out-code recid(parts).
        output close .
        assign
          parts.rsrv-free = ?
          parts.status_   = yes
        .
      end.
    end.
  end case.
end procedure.
