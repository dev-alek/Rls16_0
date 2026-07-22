block-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision: 5baf537283c9, 2487, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: 2020/06/26 13:47:04 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: lib-calc.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/lib-calc.p $":U .
define variable vss-description as character no-undo initial "Библиотека процедур для расчета данных по складским документам":U .
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
function cross-list returns logical (
  input parfirst-stream  as character,
  input parsecond-stream as character,
  input pardelim         as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  define variable vari            as integer no-undo .
  define variable varresult-cross as logical no-undo .
  assign
    varresult-cross = no
  .
  def var v-num-parfirst-stream as integer no-undo .
  assign
    v-num-parfirst-stream = num-entries(parfirst-stream, pardelim)
  .
  do vari = 1 to v-num-parfirst-stream
  :
    if lookup(entry(vari, parfirst-stream, pardelim)
             ,parsecond-stream
             ,pardelim
             ) > 0 then do:
      assign
        varresult-cross = yes
      .
      leave.
    end.
  end.
  return varresult-cross .
end function.
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure clntattr-code :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-code in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-value :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-value    like ub.clients-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-value in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-write :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.clients-attr.attr-value no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-write in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-exist :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-exist in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-delete :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.clients-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-delete in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-copy-to :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-copy-to in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-auto-author-attr :
  define output parameter p-archive-attr-list as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-auto-author-attr in g#attr-lib
      (output  p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-get-archive-by-type :
  define input  parameter p-archive-type      as character no-undo .
  define output parameter p-archive-attr-list as character no-undo .
  define variable vss-description as character no-undo initial "clntattr-get-archive-by-type-01: возвращает список атрибутов для складского архива".
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-get-archive-by-type in g#attr-lib
      (input  p-archive-type
      ,output p-archive-attr-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-vat-register :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-vat-register in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-requisite-alc-decl :
  define input parameter p-obj-type like ub.clients.obj-type no-undo .
  define input parameter p-obj-code like ub.clients.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-requisite-alc-decl in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure clntattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run clntattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
function hvrdtax return logical (input parrecid as recid):
define variable varresult as logical no-undo.
run hvrdtax-proc (input parrecid, output varresult).
return varresult.
end function.
procedure hvrdtax-proc:
define input  parameter parrecid  as recid   no-undo.
define output parameter parresult as logical no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_units for ub.units.
define buffer rt_tax   for ub.tax.
find first rt_tax   where rt_tax.tax-code    = integer('3':U) no-lock no-error.
find first bf_goods where recid(bf_goods)    = parrecid              no-lock.
find first bf_units where bf_units.unit-name = bf_goods.unit-base    no-lock.
if available rt_tax and
    can-find(first ub.tax-units No-LOCK WHERE
                   ub.tax-units.tax-code = rt_tax.tax-code AND
                   LOOKUP(ub.tax-units.type, bf_units.type) > 0) then assign parresult = yes.
                                                    else assign parresult = no.
end procedure.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable ptrlprop-denstclc      as character no-undo initial 'shft_rvs-inc':U .
define variable ptrlprop-inpptrl       as character no-undo initial 'weight':U .
define variable ptrlprop-expptrl       as character no-undo initial 'volume':U .
define variable ptrlprop-autopump      as logical   no-undo initial false .
define variable ptrlprop-avtinvpm      as logical   no-undo initial false .
define variable ptrlprop-rvsnmter      as logical   no-undo initial false .
define variable ptrlprop-olddens       as logical   no-undo initial false .
define variable ptrlprop-invclipt      as integer   no-undo initial ? .
define variable ptrlprop-algrvspt      as integer   no-undo initial 1 .
define variable ptrlprop-temp-for-pomi as integer   no-undo initial 1 .
define variable ptrlprop-algoincome as integer no-undo init 0.
define variable ptrlprop-mand-choice-autocar as logical no-undo init false.
define variable ptrlprop-Delta-mass-horiz      as character no-undo .
define variable ptrlprop-Delta-mass-vert       as character no-undo .
define variable ptrlprop-calc-free-vol as logical no-undo init false.
define variable ptrlprop-calc-free-vol-sug as logical no-undo init false.
define variable ptrlprop-trn-reas-sug as logical no-undo init true.
define variable ptrlprop-rvd-own-nb as logical no-undo init false.
define variable ptrlprop-qr-scan-time as integer no-undo init 5000 .
define variable ptrlprop-block-nozzle as logical no-undo init false.
define variable ptrlprop-timeout-block-nozzle as integer no-undo init 5 .
define variable ptrlprop-autopump-skip-time as integer no-undo init 0 .
procedure get-ptrl-prop :
  define input  parameter p-obj-type as character no-undo .
  define input  parameter p-obj-code as integer   no-undo .
  do
  on error  undo, return error substitute( "&1 (get-ptrl-prop). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1 (get-ptrl-prop). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (get-ptrl-prop). endkey", vss-workfile )
  :
    define variable par-type          as character no-undo.
    define variable v-value-character as character no-undo .
    define variable v-value-date      as date      no-undo .
    define variable v-value-decimal   as decimal   no-undo .
    define variable v-value-integer   as integer   no-undo .
    define variable v-value-logical   as logical   no-undo .
    for each thbjattr_thbj-attr
    :
      delete thbjattr_thbj-attr .
    end.
    run adm/shattri.p
      ( input "get":U
      , input p-obj-type
      , input p-obj-code
      , input 'petrol':U
      , input  ""
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output par-type
      , input-output table thbjattr_thbj-attr
      ) no-error .
    for each thbjattr_thbj-attr
    on error undo, return error return-value
    :
      case thbjattr_thbj-attr.prop-code :
        when 'denstclc':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-denstclc = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'expptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-expptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'inpptrl':U then do:
          if lookup( thbjattr_thbj-attr.property-value-character, 'volume,weight,volume+,weight+':U ) > 0
            and thbjattr_thbj-attr.prop-value-type = 'character':U
          then do:
            assign
              ptrlprop-inpptrl = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'autopump':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-autopump = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'rvsnmter':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvsnmter = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'avtinvpm':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-avtinvpm = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'invclipt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-invclipt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'olddens':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-olddens = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'algrvspt':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algrvspt = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'temp-for-pomi':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-temp-for-pomi = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'algoincome':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-algoincome = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'mand-choice-autocar':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-mand-choice-autocar = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-block-nozzle = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'timeout-block-nozzle':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-timeout-block-nozzle = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'Delta-mass-horiz':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-horiz = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'Delta-mass-vert':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'character':U then do:
            assign
              ptrlprop-Delta-mass-vert = thbjattr_thbj-attr.property-value-character
            .
          end.
        end.
        when 'calc-free-vol':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'calc-free-vol-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-calc-free-vol-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'trn-reas-sug':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-trn-reas-sug = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
              when 'rvd-own-nb':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'logical':U then do:
            assign
              ptrlprop-rvd-own-nb = thbjattr_thbj-attr.property-value-logical
            .
          end.
        end.
        when 'qr-scan-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-qr-scan-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
        when 'autopump-skip-time':U then do:
          if thbjattr_thbj-attr.prop-value-type = 'integer':U then do:
            assign
              ptrlprop-autopump-skip-time = thbjattr_thbj-attr.property-value-integer
            .
          end.
        end.
      end case.
      delete thbjattr_thbj-attr .
    end.
  end.
  return .
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gds-attr-name :
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-name in g#attr-lib
      (input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-value :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define output parameter p-value    as character no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-write :
  define input parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define input parameter p-value    like ub.goods-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-write in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-exist :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-delete :
  define input  parameter p-gds-code like ub.goods-attr.gds-code   no-undo .
  define input  parameter p-code     like ub.goods-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy-to :
  define input  parameter p-gds-code as integer   no-undo .
  define input  parameter p-code     as character no-undo .
  define input  parameter p-bh       as handle no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy-to in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-bh
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-ptrl-divis :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-ptrl-divis in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-glob-sum-grps :
  define input  parameter p-mode        as character no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code no-undo .
  define input-output parameter p-value as integer no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-glob-sum-grps in g#attr-lib
      (input p-mode
      ,input p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-ptrl-densities :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-ptrl-densities in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_gds-CommodityCode :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input-output  parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_gds-CommodityCode in g#attr-lib
      (input  p-gds-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-office-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-office-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-mark-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-mark-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-emrc-type :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-emrc-type in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-group-np :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-group-np in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-item-matter-mark :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-item-matter-mark in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-type-method-calc :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-type-method-calc in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-is-loyalty-payment :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-is-loyalty-payment in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-15x80 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-15x80 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-8x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-8x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_init-6x50 :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-attr-value  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_init-6x50 in g#attr-lib
      (input  p-gds-code
      ,output p-attr-value
      ) no-error .
    if error-status :error
    then do:
      message error-status:get-message(1) skip return-value view-as alert-box .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-manual-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr-batch-edit :
  define input  parameter p-code        as character no-undo .
  define output parameter p-section-num as integer   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-energy-value :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define input  parameter p-code        like ub.goods-attr.attr-code  no-undo .
  define input  parameter p-value       as character no-undo .
  define input  parameter p-mode        as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-energy-value in g#attr-lib
      (input  p-gds-code
      ,input  p-code
      ,input  p-value
      ,input  p-mode
      ,output p-correct
      ,output p-error-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure gds-attr_check-can-set-dt-seasons :
  define input  parameter p-gds-code    like ub.goods-attr.gds-code     no-undo .
  define output parameter p-can-set  as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-can-set-dt-seasons in g#attr-lib
      (input  p-gds-code
      ,output p-can-set
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isExemplarGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isExemplarGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure isVolumArticGoods :
  define input  parameter p-obj-type like ub.clients-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.clients-attr.obj-code   no-undo .
  define input  parameter p-gds-code as   integer                    no-undo .
  define output parameter o-result   as   logical                    no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run isVolumArticGoods in g#attr-lib
      (input  p-obj-type
      ,input  p-obj-code
      ,input p-gds-code
      ,output o-result
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
if valid-handle (g#lib-calc)
and g#lib-calc <> this-procedure :handle
and lookup('lib-calc_clcrdtax':u, g#lib-calc :internal-entries) > 0
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для раcчета складских документов" skip
    g#lib-calc skip
    g#lib-calc :type skip
    g#lib-calc :file-name skip
    valid-handle(g#lib-calc) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-calc = this-procedure :handle
  .
end.
on delete of this-procedure do:
  assign
    g#lib-calc = ?
  .
end.
procedure lib-calc_clcrdtax:
define input  parameter pargds-code      like ub.goods.gds-code         no-undo.
define input  parameter parext-gds-type  as   character                 no-undo.
define input  parameter parcli-base-rate like ub.doc-line.cli-base-rate no-undo.
define input  parameter pardoc-qnty      like ub.doc-line.doc-qnty      no-undo.
define input  parameter pardensity       like ub.doc-line.doc-density   no-undo.
define input  parameter parroad-tax-cli  like ub.doc-line.road-tax      no-undo.
define input  parameter parbase-rate     like ub.trn-doc.base-rate      no-undo.
define input  parameter parbase-scale    like ub.trn-doc.base-scale     no-undo.
define input  parameter parexch-rate     like ub.trn-doc.base-rate      no-undo.
define input  parameter parexch-scale    like ub.trn-doc.base-scale     no-undo.
define output parameter parroad-tax      like ub.doc-line.road-tax      no-undo.
define variable varr-b as character no-undo.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
define buffer bf_goods for ub.goods.
find first bf_goods where bf_goods.gds-code = pargds-code no-lock.
if not hvrdtax (recid(bf_goods)) then return error "Для данного типа товара: " + parext-gds-type + " пересчет налога 3.".
case parext-gds-type:
when 'bg':U then do:
  if varr-b = "rubl":u then do:
    assign parroad-tax = parroad-tax-cli
           * parexch-rate / parexch-scale.
  end.
  else do:
    assign parroad-tax = parroad-tax-cli
             / parbase-rate * parbase-scale
           * parexch-rate / parexch-scale.
  end.
end.
when 'pp':U then do:
  if varr-b = "rubl":u then do:
    assign parroad-tax = parroad-tax-cli
           * parexch-rate / parexch-scale
           / parcli-base-rate.
  end.
  else do:
    assign parroad-tax = parroad-tax-cli
             / parbase-rate * parbase-scale
           * parexch-rate / parexch-scale
           / parcli-base-rate.
  end.
end.
when 'lp':U then do:
  if varr-b = "rubl":u then do:
    assign parroad-tax = parroad-tax-cli
           * parexch-rate / parexch-scale
           * (round(pardoc-qnty * pardensity, 0) / pardoc-qnty).
  end.
  else do:
    assign parroad-tax = parroad-tax-cli
           / parbase-rate * parbase-scale
           * parexch-rate / parexch-scale
           * (round(pardoc-qnty * pardensity, 0) / pardoc-qnty).
  end.
end.
when 'kp':U then do:
  if varr-b = "rubl":u then do:
    assign parroad-tax = parroad-tax-cli
           * parexch-rate / parexch-scale
           * pardensity.
  end.
  else do:
    assign parroad-tax = parroad-tax-cli
           / parbase-rate * parbase-scale
           * parexch-rate / parexch-scale
           * pardensity.
  end.
end.
otherwise do:
   return error "Для данного типа товара: " + parext-gds-type + " пересчет налога 3.".
end.
end case.
end procedure.
procedure lib-calc_clcdocqt:
define input  parameter parext-gds-type  as   character                 no-undo.
define input  parameter parcli-qnty      like ub.doc-line.cli-qnty      no-undo.
define input  parameter parcli-base-rate like ub.doc-line.cli-base-rate no-undo.
define input  parameter pardensity       like ub.doc-line.doc-density       no-undo.
define output parameter pardoc-qnty      like ub.doc-line.doc-qnty      no-undo.
case parext-gds-type:
  when 'og':U     or
  when 'os':U then do:
     assign pardoc-qnty = parcli-qnty * parcli-base-rate.
  end.
  when 'sg':U then do:
  end.
  when 'bg':U then do:
     assign pardoc-qnty = parcli-qnty.
  end.
  when 'kp':U then do:
     assign pardoc-qnty = parcli-qnty / pardensity.
  end.
  otherwise do:
     return error "Для данного типа товара: " + parext-gds-type + " пересчет количества в базовых единицах недопустим.".
  end.
end case.
end procedure.
procedure lib-calc_clccliqt:
define input  parameter parext-gds-type  as   character                 no-undo.
define input  parameter pardoc-qnty      like ub.doc-line.doc-qnty      no-undo.
define input  parameter parcli-base-rate like ub.doc-line.cli-base-rate no-undo.
define input  parameter pardensity       like ub.doc-line.doc-density       no-undo.
define input  parameter parround         as   integer                   no-undo.
define output parameter parcli-qnty      like ub.doc-line.cli-qnty      no-undo.
case parext-gds-type:
  when 'sg':U then do:
  end.
  when 'pp':U then do:
     assign  parcli-qnty = pardoc-qnty / parcli-base-rate.
  end.
  when 'lp':U then do:
     assign parcli-qnty = pardoc-qnty * pardensity .
  end.
  otherwise do:
     return error "Для данного типа товара: " + parext-gds-type + " пересчет кол-ва по ТТН недопустим.".
  end.
end case.
end.
procedure lib-calc_clcdens:
define input  parameter parext-gds-type  as   character                 no-undo.
define input  parameter parcli-qnty      like ub.doc-line.cli-qnty      no-undo.
define input  parameter pardoc-qnty      like ub.doc-line.doc-qnty      no-undo.
define output parameter pardensity       like ub.doc-line.doc-density   no-undo.
case parext-gds-type:
  when 'lp':U
  or when 'kp':U then do:
     assign pardensity = parcli-qnty / pardoc-qnty .
  end.
  otherwise do:
     return error "Для данного типа товара: " + parext-gds-type + " пересчет плотности недопустим.".
  end.
end case.
end.
procedure lib-calc_clcclirt:
define input  parameter parext-gds-type  as   character                 no-undo.
define input  parameter parcli-qnty      like ub.doc-line.cli-qnty      no-undo.
define input  parameter pardoc-qnty      like ub.doc-line.doc-qnty      no-undo.
define input  parameter pardensity       like ub.doc-line.doc-density       no-undo.
define input  parameter parround         as   integer                   no-undo.
define output parameter parcli-base-rate like ub.doc-line.cli-base-rate no-undo.
case parext-gds-type:
  when 'sg':U then do:
     assign parcli-base-rate = 1.
  end.
  when 'bg':U then do:
     assign parcli-base-rate = 1.
  end.
  when 'gg':U then do:
     assign parcli-base-rate = pardoc-qnty / parcli-qnty .
     if parcli-base-rate  = ? then parcli-base-rate = 1.
  end.
  when 'lp':U then do:
     assign parcli-base-rate = 1 / pardensity .
  end.
  when 'kp':U then do:
     assign parcli-base-rate = 1 / pardensity.
  end.
  otherwise do:
     return error "Для данного типа товара: " + parext-gds-type + " пересчет коэф-та поставщика недопустим.".
  end.
end case.
end procedure.
procedure lib-calc_kndinpin:
define input  parameter pargds-code            like ub.goods.gds-code        no-undo.
define input  parameter parcli-type            like ub.clients.obj-type      no-undo.
define input  parameter parcli-code            like ub.clients.obj-code      no-undo.
define input  parameter parobj-type            like ub.clients.obj-type      no-undo.
define input  parameter parobj-code            like ub.clients.obj-code      no-undo.
define output parameter parext-gds-type        as   character      initial ? no-undo.
define output parameter parcli-qnty-input      as   logical        initial ? no-undo.
define output parameter pardensity-input       as   logical        initial ? no-undo.
define output parameter parcli-base-rate-input as   logical        initial ? no-undo.
define output parameter pardoc-qnty-input      as   logical        initial ? no-undo.
define output parameter parfact-qnty-input     as   logical        initial ? no-undo.
define output parameter parprice-cli-input     as   logical        initial ? no-undo.
define output parameter parbase-price-input    as   logical        initial ? no-undo.
define output parameter partax-3-input         as   logical        initial ? no-undo.
define output parameter parcli-qnty-calc       as   character      initial ? no-undo.
define output parameter pardensity-calc        as   character      initial ? no-undo.
define output parameter parcli-base-rate-calc  as   character      initial ? no-undo.
define output parameter pardoc-qnty-calc       as   character      initial ? no-undo.
define output parameter parfact-qnty-calc      as   character      initial ? no-undo.
define output parameter parprice-cli-calc      as   character      initial ? no-undo.
define output parameter parbase-price-calc     as   character      initial ? no-undo.
define output parameter partax-3-calc          as   character      initial ? no-undo.
define output parameter parround               as   integer        initial ? no-undo.
define variable varis-petrolium as logical             no-undo.
define variable varis-pieces    as logical             no-undo.
define variable varhvrdtax      as logical             no-undo.
define variable varupd-fact-qnty as logical   no-undo initial yes.
define variable varrevision      as logical   no-undo initial no.
define variable varpercrev       as decimal   no-undo initial ?.
define variable varauto-tank     as logical   no-undo initial no.
define variable varpercauto      as decimal   no-undo initial ?.
define variable varinv           as logical   no-undo initial no.
define variable varpercinv       as decimal   no-undo initial ?.
define variable varinv-set       as logical   no-undo initial no.
define variable stfactplvalue    as character no-undo initial ?.
define variable stfactpltype     as character no-undo initial ?.
define variable varvalue         as character no-undo initial ?.
define variable vartype          as character no-undo initial ?.
define buffer bf_goods        for ub.goods.
define buffer bf_units        for ub.units.
define buffer bf_clients-attr for ub.clients-attr.
find first bf_goods where bf_goods.gds-code = pargds-code no-lock no-error.
if not available bf_goods then do:
   return error "Не найден товар с внутренним кодом " + string(pargds-code) + " .".
end.
find first bf_units where bf_units.unit-name = bf_goods.unit-base no-lock.
if hvrdtax (recid(bf_goods)) then assign varhvrdtax = yes.
                             else assign varhvrdtax = no.
if cross-list(bf_units.type, 'сте':U, ?) then do:
   if bf_goods.cli-base-rate <> 1 then
      return error "Неверно заведен товар стеклопосуда. Коэффициент поставщика: " + string(bf_goods.cli-base-rate) + " .".
   if bf_goods.unit-base <> bf_goods.unit-cli then
      return error "Неверно заведен товар стеклопосуда. Базовая единица: " + bf_goods.unit-base + " не равна единице поставщика " +  bf_goods.unit-cli + " .".
   assign
     parext-gds-type         = 'bg':U
     parcli-qnty-input       = yes
     pardensity-input        = no
     parcli-base-rate-input  = no
     pardoc-qnty-input       = no
     parfact-qnty-input      = yes
     parprice-cli-input      = yes
     parbase-price-input     = no
     partax-3-input          = varhvrdtax
     parcli-qnty-calc        = "doc-qnty":U
     pardensity-calc         = ""
     parcli-base-rate-calc   = ""
     pardoc-qnty-calc        = ""
     parfact-qnty-calc       = ""
     parprice-cli-calc       = "acc-price":U
     parbase-price-calc      = ""
     partax-3-calc           = (if varhvrdtax then "road-tax,acc-price":U else "").
end.
else do:
   if cross-list(bf_units.type, '2ед':U, ?) then do:
      assign
        parext-gds-type         = 'gg':U
        parcli-qnty-input       = yes
        pardensity-input        = no
        parcli-base-rate-input  = no
        pardoc-qnty-input       = yes
        parfact-qnty-input      = yes
        parprice-cli-input      = no
        parbase-price-input     = yes
        partax-3-input          = no
        parcli-qnty-calc        = "cli-base-rate,cli-price":U
        pardensity-calc         = ""
        parcli-base-rate-calc   = ""
        pardoc-qnty-calc        = "cli-base-rate,cli-price":U
        parfact-qnty-calc       = ""
        parprice-cli-calc       = ""
        parbase-price-calc      = "cli-price":U
        partax-3-calc           = "".
   end.
   else do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input bf_goods.artic
  ,  input bf_goods.prod-type
  ,  input bf_goods.prod-code
  , output varis-petrolium
  , output varis-pieces
  ) no-error.
      if error-status :error then return error "Ошибка при вызове процедуры is-petrl "
                                + return-value + error-status :get-message( 1 ) + error-status :get-message( 2 ) + " .".
      if varis-petrolium then do:
         if varis-pieces then do:
            assign
                parext-gds-type         = 'pp':U
                parcli-qnty-input       = no
                pardensity-input        = no
                parcli-base-rate-input  = yes
                pardoc-qnty-input       = yes
                parfact-qnty-input      = yes
                parprice-cli-input      = no
                parbase-price-input     = yes
                partax-3-input          = varhvrdtax
                parcli-qnty-calc        = ""
                pardensity-calc         = ""
                parcli-base-rate-calc   = "cli-qnty,cli-price":U
                pardoc-qnty-calc        = "cli-qnty":U
                parfact-qnty-calc       = ""
                parprice-cli-calc       = ""
                parbase-price-calc      = "cli-price":U
                partax-3-calc           = (if varhvrdtax then "road-tax,acc-price":U else "").
         end.
         else do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input parobj-type
  , input parobj-code
  ) .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'stfactpl'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output stfactplvalue
  ,output stfactpltype
  ) no-error .
            if stfactplvalue <> "":U then do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_chkqtpl in g#lib-calc
  (  input stfactplvalue
  , output varupd-fact-qnty
  , output varrevision
  , output varpercrev
  , output varauto-tank
  , output varpercauto
  , output varinv
  , output varpercinv
  , output varinv-set
  )  .
            end.
            find first bf_clients-attr where
                       bf_clients-attr.obj-type   = parcli-type      and
                       bf_clients-attr.obj-code   = parcli-code      and
                       bf_clients-attr.attr-code  = 'shftrep2':U and
                       bf_clients-attr.attr-value = "yes":U          no-lock no-error.
            if available bf_clients-attr then do:
              if ptrlprop-expptrl = 'weight':U then do:
                assign
                  ptrlprop-inpptrl = 'weight':U
                .
              end.
              else do:
                assign
                  ptrlprop-inpptrl = 'volume':U
                .
              end.
            end.
            run gds-attr-value in this-procedure
              (  input pargds-code
              ,  input 'fuel-type':U
              , output varvalue
              , output vartype
              ) no-error .
           case varvalue:
             when 'lgas' then do:
                ptrlprop-inpptrl = 'weight':U.
             end.
             when 'metan' then do:
                ptrlprop-inpptrl = 'volume':U.
             end.
           end.
            if lookup( ptrlprop-inpptrl, "weight,weight+":U ) > 0 then do:
              assign
                parext-gds-type         = 'kp':U
                parcli-qnty-input       = yes
                parcli-base-rate-input  = no
                parfact-qnty-input      = varupd-fact-qnty
                parprice-cli-input      = yes
                parbase-price-input     = no
                partax-3-input          = varhvrdtax
                parcli-base-rate-calc   = ""
                parfact-qnty-calc       = "":U
                parprice-cli-calc       = "acc-price":U
                parbase-price-calc      = ""
                partax-3-calc           = (if varhvrdtax then "road-tax,acc-price":U else "")
              .
              if ptrlprop-inpptrl = 'weight+':U
                and bf_goods.unit-base <> bf_goods.unit-cli
              then do:
                assign
                  pardensity-input        = no
                  pardoc-qnty-input       = (if bf_goods.unit-base <> bf_goods.unit-cli then true else false)
                  parcli-qnty-calc        = "density,cli-base-rate,acc-price":U
                  pardensity-calc         = "":U
                  pardoc-qnty-calc        = "density,cli-base-rate,acc-price":U
                .
              end.
              else do:
                assign
                  pardensity-input        = (if bf_goods.unit-base <> bf_goods.unit-cli then true else false)
                  pardoc-qnty-input       = no
                  parcli-qnty-calc        = "doc-qnty,acc-price":U
                  pardensity-calc         = "cli-base-rate,doc-qnty,acc-price":U
                  pardoc-qnty-calc        = "":U
                .
              end.
            end.
            else do:
              assign
                parext-gds-type         = 'lp':U
                parcli-base-rate-input  = no
                pardoc-qnty-input       = yes
                parfact-qnty-input      = varupd-fact-qnty
                parprice-cli-input      = no
                parbase-price-input     = yes
                partax-3-input          = varhvrdtax
                parcli-base-rate-calc   = ""
                parfact-qnty-calc       = ""
                parprice-cli-calc       = "":U
                parbase-price-calc      = "cli-price":U
                partax-3-calc           = (if varhvrdtax then "road-tax,acc-price":U else "")
              .
              if ptrlprop-inpptrl = 'volume+':U
                and bf_goods.unit-base <> bf_goods.unit-cli
              then do:
                assign
                  pardensity-input        = no
                  parcli-qnty-input       = (if bf_goods.unit-base <> bf_goods.unit-cli then true else false)
                  parcli-qnty-calc        = "density,cli-base-rate,acc-price":U
                  pardensity-calc         = "":U
                  pardoc-qnty-calc        = "density,cli-base-rate,acc-price":U
                .
              end.
              else do:
                assign
                  pardensity-input        = (if bf_goods.unit-base <> bf_goods.unit-cli then true else false)
                  parcli-qnty-input       = no
                  parcli-qnty-calc        = ""
                  pardensity-calc         = "cli-qnty,cli-base-rate,acc-price":U
                  pardoc-qnty-calc        = "cli-qnty,cli-base-rate,acc-price":U
                .
              end.
            end.
         end.
      end.
      else do:
          if LOOKUP('сер':U, bf_units.type) > 0 then do:
             assign
               parext-gds-type         = 'sg':U
               parcli-qnty-input       = no
               pardensity-input        = no
               parcli-base-rate-input  = no
               pardoc-qnty-input       = no
               parfact-qnty-input      = no
               parprice-cli-input      = yes
               parbase-price-input     = no
               partax-3-input          = varhvrdtax
               parcli-qnty-calc        = ""
               pardensity-calc         = ""
               parcli-base-rate-calc   = ""
               pardoc-qnty-calc        = ""
               parfact-qnty-calc       = ""
               parprice-cli-calc       = "acc-price":U
               parbase-price-calc      = ""
               partax-3-calc           = (if varhvrdtax then "road-tax,acc-price":U else "").
          end.
          else do:
             assign
               parext-gds-type         = (if bf_goods.gds-type = 'у':U then 'os':U else 'og':U)
               parcli-qnty-input       = yes
               pardensity-input        = no
               parcli-base-rate-input  = yes
               pardoc-qnty-input       = no
               parfact-qnty-input      = yes
               parprice-cli-input      = yes
               parbase-price-input     = no
               partax-3-input          = varhvrdtax
               parcli-qnty-calc        = "doc-qnty":U
               pardensity-calc         = ""
               parcli-base-rate-calc   = "doc-qnty,acc-price":U
               pardoc-qnty-calc        = ""
               parfact-qnty-calc       = ""
               parprice-cli-calc       = "acc-price":U
               parbase-price-calc      = ""
               partax-3-calc           = (if varhvrdtax then "road-tax,acc-price":U else "").
          end.
      end.
   end.
end.
end.
procedure lib-calc_stfactqt :
  define input        parameter parstfactpl          as   character              no-undo .
  define input        parameter pardoc-qnty          like ub.doc-line.doc-qnty   no-undo .
  define input        parameter pardensity           like ub.doc-line.doc-density    no-undo .
  define input        parameter parrvs-before-qnty   like ub.doc-line.fact-qnty  no-undo .
  define input        parameter parrvs-after-qnty    like ub.doc-line.fact-qnty  no-undo .
  define input        parameter parauto-tank-qnty    like ub.doc-line.fact-qnty  no-undo .
  define input        parameter parauto-tank-density like ub.doc-line.fact-density    no-undo .
  define input        parameter parcheck-place       as   logical                no-undo .
  define input-output parameter parfact-qnty         like ub.doc-line.fact-qnty  no-undo .
  define       output parameter parchg               as   logical                no-undo .
  define       output parameter parst-doc            as   logical                no-undo .
  define variable varupdate    as logical no-undo initial yes .
  define variable varrevision  as logical no-undo initial no  .
  define variable varpercrev   as decimal no-undo initial ?   .
  define variable varauto-tank as logical no-undo initial no  .
  define variable varpercauto  as decimal no-undo initial ?   .
  define variable varinv       as logical no-undo initial no  .
  define variable varpercinv   as decimal no-undo initial ?   .
  define variable varinv-set   as logical no-undo initial no  .
  define variable vardelta     as decimal no-undo .
  define variable varnewqt     as decimal no-undo .
  define variable varoldqt     as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if parstfactpl = ""
    then do:
      return .
    end.
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_chkqtpl in g#lib-calc
  (  input parstfactpl
  , output varupdate
  , output varrevision
  , output varpercrev
  , output varauto-tank
  , output varpercauto
  , output varinv
  , output varpercinv
  , output varinv-set
  ) no-error .
    if error-status :error then do:
      return error substitute( "Ошибка при проверке параметра stfactpl : &1"
                             , return-value
                             ) .
    end.
    assign
      parchg    = no
      parst-doc = no
    .
    if varupdate <> true
      and varrevision <> true
      and varauto-tank <> true
    then do:
      assign
        parfact-qnty = pardoc-qnty
        parst-doc    = true
      .
    end.
    else do:
      if varrevision  = true
      then do:
        assign
          vardelta = pardoc-qnty * varpercrev * 0.01
          varnewqt = parrvs-after-qnty - parrvs-before-qnty
        .
        if varpercrev = 0.00 or
                pardoc-qnty - varnewqt   > vardelta or
           abs( pardoc-qnty - varnewqt ) > vardelta and parcheck-place = yes
        then do:
          if varnewqt < 0
          then do:
            return error substitute( "Неверное количество по сверкам: &1. Количество должно быть больше 0."
                                   , varnewqt
                                   ) .
          end.
          assign
            parfact-qnty = varnewqt
            parchg       = yes
          .
        end.
        else do:
          if varupdate      <> yes or
             parcheck-place  = yes
          then do:
            assign
              parfact-qnty = pardoc-qnty
              parst-doc    = yes
            .
          end.
        end.
      end.
      if varauto-tank = yes
      then do:
        assign
          varoldqt = pardoc-qnty * pardensity
          vardelta = varoldqt * varpercauto * 0.01
          varnewqt = parauto-tank-qnty * parauto-tank-density
        .
        if varpercauto = 0.00 or
                varoldqt - varnewqt   > vardelta or
           abs( varoldqt - varnewqt ) > vardelta and parcheck-place = yes
        then do:
          assign
            parfact-qnty = parauto-tank-qnty
            parchg       = yes
          .
        end.
        else do:
          if varupdate <> yes
          then do:
            assign
              parfact-qnty = pardoc-qnty
              parst-doc    = yes
            .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure lib-calc_chkqtpl :
  define  input parameter p-stfactpl  as character no-undo.
  define output parameter p-update    as logical   no-undo initial true.
  define output parameter p-revision  as logical   no-undo initial false.
  define output parameter p-percrev   as decimal   no-undo initial ?.
  define output parameter p-auto-tank as logical   no-undo initial false.
  define output parameter p-percauto  as decimal   no-undo initial ?.
  define output parameter p-inv       as logical   no-undo initial false.
  define output parameter p-percinv   as decimal   no-undo initial ?.
  define output parameter p-inv-set   as logical   no-undo initial false.
  do
  on error undo, return error return-value
  :
    define variable v-count    as integer no-undo.
    define variable v-num      as integer no-undo.
    define variable v-cnt-true as integer   no-undo .
    assign
      v-num      = num-entries( p-stfactpl, ";" )
      v-cnt-true = 0
    .
    do v-count = 1 to v-num :
      case trim( entry( 1, trim( entry( v-count, p-stfactpl, ";" ) ), "=" ) ) :
        when "read-only":U then do:
          assign
            p-update = false
          .
        end.
        when "inv-set":U then do:
          assign
            p-inv-set = true
          .
        end.
        when "revision":U  then do:
          assign
            v-cnt-true = v-cnt-true + 1
            p-revision = yes
            p-percrev  = decimal( entry( 2, trim( entry( v-count, p-stfactpl, ";" ) ), "=" ) )
            no-error.
          if error-status :error
            or p-percrev < 0.00
          then do:
            return error "Неверно задан процент отклонения в подпараметре revision параметра stfactpl.".
          end.
        end.
        when "auto-tank":U then do:
          assign
            v-cnt-true  = v-cnt-true + 1
            p-auto-tank = true
            p-percauto  = decimal( entry( 2, trim( entry( v-count, p-stfactpl, ";" ) ), "=" ) )
            no-error.
          if error-status :error
            or p-percauto < 0.00
          then do:
            return error "Неверно задан процент отклонения в подпараметре auto-tank параметра stfactpl.".
          end.
        end.
        when "inv":U then do:
          assign
            p-inv      = true
            p-percinv  = decimal( entry( 2, trim( entry( v-count, p-stfactpl, ";" ) ), "=" ) )
            no-error.
          if error-status :error
            or p-percinv < 0.00
          then do:
            return error "Неверно задан процент отклонения в подпараметре inv параметра stfactpl.".
          end.
        end.
        otherwise             do:
          return error substitute( "Неизвестный подпараметр &1 в параметре stfactpl.", trim( entry( v-count, p-stfactpl, ";" ) ) ).
        end.
      end case.
    end.
    if v-cnt-true > 1 then do:
      return error "Ошибка параметра stfactpl. Нельзя определять установку фактического количества сразу из двух источников измерений." +
                   "(В параметре не должны присутствовать revision, auto-tank, inv одновременно.)".
    end.
  end.
end procedure.
procedure lib-calc_lnfactqt :
  define input parameter parparentproc as   widget-handle      no-undo.
  define input parameter parrec-line   as   recid              no-undo.
  define input parameter paris-update  as   logical            no-undo.
  define input parameter parstatus     like ub.trn-doc.status_ no-undo.
  define input parameter parflag       like ub.trn-doc.flag_   no-undo.
  define variable varstfactpl          as   character             no-undo.
  define variable varstfactpltype      as   character             no-undo.
  define variable vardoc-qnty          like ub.doc-line.doc-qnty  no-undo.
  define variable varrvs-before-qnty   like ub.doc-line.fact-qnty no-undo.
  define variable varrvs-after-qnty    like ub.doc-line.fact-qnty no-undo.
  define variable varauto-tank-qnty    like ub.doc-line.fact-qnty no-undo.
  define variable varauto-tank-density as   decimal               no-undo.
  define variable varfact-qnty         like ub.doc-line.fact-qnty no-undo.
  define variable varis-petrol         as   logical               no-undo.
  define variable varis-pieces         as   logical               no-undo.
  define variable varupdate            as   logical initial yes   no-undo.
  define variable varrevision          as   logical initial no    no-undo.
  define variable varpercrev           as   decimal initial ?     no-undo.
  define variable varauto-tank         as   logical initial no    no-undo.
  define variable varpercauto          as   decimal initial ?     no-undo.
  define variable varinv               as   logical initial no    no-undo.
  define variable varpercinv           as   decimal initial ?     no-undo.
  define variable varinv-set           as   logical initial no    no-undo .
  define variable varchg-qnty          like ub.gds-dtl.fact-qnty  no-undo.
  define variable varb-c               as   integer               no-undo.
  define variable varchg               as   logical               no-undo.
  define variable varst-doc            as   logical               no-undo.
  define buffer ln_doc-line        for ub.doc-line.
  define buffer ln_trn-doc         for ub.trn-doc.
  define buffer ln_goods           for ub.goods.
  define buffer ln_doc-line-attr   for ub.doc-line-attr.
  define buffer ln_rvs-doc-before  for ub.rvs-doc.
  define buffer ln_rvs-doc-after   for ub.rvs-doc.
  define buffer ln_rvs-line-before for ub.rvs-line.
  define buffer ln_rvs-line-after  for ub.rvs-line.
  define buffer ln_gds-dtl         for ub.gds-dtl.
  do on error undo, return error :
find first ln_doc-line where recid (ln_doc-line) = parrec-line.
find first ln_goods where ln_goods.artic     = ln_doc-line.artic     and
                          ln_goods.prod-type = ln_doc-line.prod-type and
                          ln_goods.prod-code = ln_doc-line.prod-code no-lock.
if parstatus = 'накл':U and
   parflag   = yes     then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ln_goods.artic
  ,  input ln_goods.prod-type
  ,  input ln_goods.prod-code
  , output varis-petrol
  , output varis-pieces
  ) no-error.
   if error-status :error then do:
     return error return-value.
   end.
   if varis-petrol     and
      not varis-pieces then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'stfactpl':U
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output varstfactpl
  ,output varstfactpltype
  ) no-error .
     find first ln_goods where ln_goods.artic     = ln_doc-line.artic     and
                               ln_goods.prod-type = ln_doc-line.prod-type and
                               ln_goods.prod-code = ln_doc-line.prod-code no-lock.
     find first ln_doc-line-attr where ln_doc-line-attr.doc-code  = ln_doc-line.doc-code and
                                       ln_doc-line-attr.gds-code  = ln_goods.gds-code    and
                                       ln_doc-line-attr.attr-code = "tank-vol":U           no-error.
     if available ln_doc-line-attr then do:
       assign varauto-tank-qnty = decimal (ln_doc-line-attr.attr-value).
     end.
     else do:
       assign varauto-tank-qnty = 0.
     end.
     find first ln_doc-line-attr where ln_doc-line-attr.doc-code  = ln_doc-line.doc-code and
                                       ln_doc-line-attr.gds-code  = ln_goods.gds-code    and
                                       ln_doc-line-attr.attr-code = "tank-weight":U       no-error.
     if available ln_doc-line-attr then do:
       assign varauto-tank-density = decimal (ln_doc-line-attr.attr-value) / varauto-tank-qnty no-error.
     end.
     else do:
       assign varauto-tank-density = ?.
     end.
     if varauto-tank-density = ? then do:
        find first ln_doc-line-attr where ln_doc-line-attr.doc-code  = ln_doc-line.doc-code and
                                       ln_doc-line-attr.gds-code  = ln_goods.gds-code    and
                                       ln_doc-line-attr.attr-code = "tank-density":U       no-error.
         if available ln_doc-line-attr then do:
           assign varauto-tank-density = decimal (ln_doc-line-attr.attr-value)  no-error.
         end.
     end.
     assign
       varrvs-before-qnty = 0
       varrvs-after-qnty  = 0.
     find first ln_rvs-doc-before where ln_rvs-doc-before.rvs-type = 'перед_док':U    and
                                        ln_rvs-doc-before.out-code = ln_doc-line.doc-code no-error.
     if available ln_rvs-doc-before then do:
       find first ln_rvs-doc-after where ln_rvs-doc-after.rvs-type = 'после_док':U     and
                                         ln_rvs-doc-after.out-code = ln_doc-line.doc-code no-error.
       if available ln_rvs-doc-after then do:
         for each ln_rvs-line-before where ln_rvs-line-before.gds-code = ln_goods.gds-code          and
                                           ln_rvs-line-before.rvs-code = ln_rvs-doc-before.rvs-code and
                                           ln_rvs-line-before.obj-type = ln_doc-line.obj-type       and
                                           ln_rvs-line-before.obj-code = ln_doc-line.obj-code       :
             if varrvs-before-qnty = ? then do:
               assign varrvs-before-qnty = 0.00.
             end.
             assign varrvs-before-qnty = varrvs-before-qnty + ln_rvs-line-before.state-measure-qnty.
         end.
         for each ln_rvs-line-after where ln_rvs-line-after.gds-code = ln_goods.gds-code          and
                                          ln_rvs-line-after.rvs-code = ln_rvs-doc-after.rvs-code  and
                                          ln_rvs-line-after.obj-type = ln_doc-line.obj-type       and
                                          ln_rvs-line-after.obj-code = ln_doc-line.obj-code       :
             if varrvs-after-qnty = ? then do:
               assign varrvs-after-qnty = 0.00.
             end.
             assign varrvs-after-qnty = varrvs-after-qnty + ln_rvs-line-after.state-measure-qnty.
         end.
       end.
     end.
     assign
       varfact-qnty = ln_doc-line.fact-qnty
       vardoc-qnty  = ln_doc-line.doc-qnty
     .
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_stfactqt in g#lib-calc
  ( input        varstfactpl
  , input        vardoc-qnty
  , input        ln_doc-line.doc-density
  , input        varrvs-before-qnty
  , input        varrvs-after-qnty
  , input        varauto-tank-qnty
  , input        varauto-tank-density
  , input        no
  , input-output varfact-qnty
  ,       output varchg
  ,       output varst-doc
  )              no-error
.
     if error-status :error then do:
        return error substitute ("Ошибка при вызове процедуры lib-calc_stfactqt из процедуры lib-calc_lnfactqt: &1.", return-value).
     end.
     if paris-update = yes then do:
       find ln_gds-dtl where ln_gds-dtl.doc-code  = ln_doc-line.doc-code  and
                             ln_gds-dtl.artic     = ln_doc-line.artic     and
                             ln_gds-dtl.prod-type = ln_doc-line.prod-type and
                             ln_gds-dtl.prod-code = ln_doc-line.prod-code .
      assign
         varchg-qnty  = varfact-qnty - ln_gds-dtl.fact-qnty.
       run trg/rsrv-dtl.p ( input        parparentproc,
                        input        ( 'reserv':U + "," + 'no-message':U ),
                        buffer       ln_gds-dtl,
                        input-output varchg-qnty,
                        input-output ln_doc-line.price-base,
                        input-output ln_doc-line.price-rubl,
                        input        varb-c,
                        input "" ) no-error.
       if error-status :error then do:
         return error return-value.
       end.
       assign
         ln_gds-dtl.fact-qnty  = ln_gds-dtl.fact-qnty  + varchg-qnty
         ln_doc-line.fact-qnty = ln_doc-line.fact-qnty + varchg-qnty .
     end.
     else do:
     end.
   end.
end.
  end.
end procedure.
procedure lib-calc_accgdspr:
define input  parameter parrec-line         as recid     no-undo.
define input  parameter parupd-price        as logical   no-undo.
define output parameter paragsum-base-doc   like ub.gds-dtl.price-base no-undo.
define output parameter paragsum-rubl-doc   like ub.gds-dtl.price-rubl no-undo.
define output parameter paragsum-base-fact  like ub.gds-dtl.price-base no-undo.
define output parameter paragsum-rubl-fact  like ub.gds-dtl.price-rubl no-undo.
define output parameter paragcount          as integer                 no-undo.
define buffer ag_doc-line for ub.doc-line.
define buffer ag_gds-dtl  for ub.gds-dtl.
define buffer ag_goods    for ub.goods.
define buffer ag_units    for ub.units.
define buffer ag_parts    for ub.parts.
define variable varagfact-qnty like ub.parts.fact-qnty   no-undo.
define variable varagroad-tax  like ub.doc-line.road-tax no-undo.
define variable varr-b         as   character            no-undo.
do on error undo, return error return-value :
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
find first ag_doc-line where recid(ag_doc-line) = parrec-line.
for each ag_gds-dtl where ag_gds-dtl.doc-code  = ag_doc-line.doc-code
                      and ag_gds-dtl.prod-code = ag_doc-line.prod-code
                      and ag_gds-dtl.prod-type = ag_doc-line.prod-type
                      and ag_gds-dtl.artic     = ag_doc-line.artic :
    if parupd-price <> no then do:
       if parupd-price = yes then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(ag_gds-dtl)
  , input no
  , input ?
  ) no-error.
          if error-status :error then return error return-value.
       end.
       find first ag_goods where ag_goods.artic     = ag_gds-dtl.artic     and
                                 ag_goods.prod-type = ag_gds-dtl.prod-type and
                                 ag_goods.prod-code = ag_gds-dtl.prod-code no-lock.
       find first ag_units where ag_units.unit-name = ag_goods.unit-base no-lock.
       if cross-list(ag_units.type, 'сте':U, ?) then do:
          assign varagfact-qnty = 0
                 varagroad-tax  = 0.
          for each ag_parts where ag_parts.out-code  = ag_doc-line.doc-code  and
                                  ag_parts.obj-type  = ag_doc-line.obj-type  and
                                  ag_parts.obj-code  = ag_doc-line.obj-code  and
                                  ag_parts.artic     = ag_doc-line.artic     and
                                  ag_parts.prod-type = ag_doc-line.prod-type and
                                  ag_parts.prod-code = ag_doc-line.prod-code :
              assign
              varagfact-qnty = varagfact-qnty + ag_parts.fact-qnty
              .
              if varr-b = "rubl":u then do:
                assign
                  varagroad-tax  = varagroad-tax  + ag_parts.road-tax-rubl * ag_parts.fact-qnty.
              end.
              else do:
                assign
                  varagroad-tax  = varagroad-tax  + ag_parts.road-tax-base * ag_parts.fact-qnty.
              end.
          end.
          assign ag_doc-line.road-tax = varagroad-tax / varagfact-qnty.
       end.
   end.
   assign
   paragsum-base-doc   = paragsum-base-doc  +  ag_gds-dtl.price-base * ag_gds-dtl.doc-qnty
   paragsum-rubl-doc   = paragsum-rubl-doc  +  ag_gds-dtl.price-rubl * ag_gds-dtl.doc-qnty
   paragsum-base-fact  = paragsum-base-fact +  ag_gds-dtl.price-base * ag_gds-dtl.fact-qnty
   paragsum-rubl-fact  = paragsum-rubl-fact +  ag_gds-dtl.price-rubl * ag_gds-dtl.fact-qnty
   paragcount          = paragcount         +  1 .
end.
end.
end procedure.
procedure lib-calc_acsupacc:
define input  parameter parrec-line                         as   recid                 no-undo.
define output parameter parroad-tax-fact-base               like ub.gds-dtl.price-base no-undo.
define output parameter parexcise-fact-base                 like ub.gds-dtl.price-base no-undo.
define output parameter parslt-fact-base                    like ub.gds-dtl.price-base no-undo.
define output parameter parvat-fact-base                    like ub.gds-dtl.price-base no-undo.
define output parameter parslt-doc-base                     like ub.gds-dtl.price-base no-undo.
define output parameter parvat-doc-base                     like ub.gds-dtl.price-base no-undo.
define output parameter parsum-fact-out-dsc-slt-vat-base    like ub.gds-dtl.price-base no-undo.
define output parameter parroad-tax-fact-rubl               like ub.gds-dtl.price-base no-undo.
define output parameter parexcise-fact-rubl                 like ub.gds-dtl.price-base no-undo.
define output parameter parslt-fact-rubl                    like ub.gds-dtl.price-base no-undo.
define output parameter parvat-fact-rubl                    like ub.gds-dtl.price-base no-undo.
define output parameter parslt-doc-rubl                     like ub.gds-dtl.price-base no-undo.
define output parameter parvat-doc-rubl                     like ub.gds-dtl.price-base no-undo.
define output parameter parsum-fact-out-dsc-slt-vat-rubl    like ub.gds-dtl.price-base no-undo.
define output parameter parsum-fact-out-dsc-base            like ub.gds-dtl.price-base no-undo.
define output parameter parsum-fact-out-dsc-rubl            like ub.gds-dtl.price-base no-undo.
define output parameter parsum-fact-cur                     like ub.gds-dtl.price-base no-undo.
define output parameter parov-fact-base                     like ub.gds-dtl.price-base no-undo.
define output parameter parov-vat-fact-base                 like ub.gds-dtl.price-base no-undo.
define output parameter parsum-doc-cur                      like ub.gds-dtl.price-base no-undo.
define output parameter parov-doc-base                      like ub.gds-dtl.price-base no-undo.
define output parameter parov-vat-doc-base                  like ub.gds-dtl.price-base no-undo.
define output parameter parsum-doc-base                     like ub.gds-dtl.price-base no-undo.
define output parameter parsum-doc-rubl                     like ub.gds-dtl.price-base no-undo.
define output parameter parroad-tax-fact                    like ub.gds-dtl.price-base no-undo.
define output parameter parexcise-fact                      like ub.gds-dtl.price-base no-undo.
define output parameter parroad-tax-doc                     like ub.gds-dtl.price-base no-undo.
define output parameter parexcise-doc                       like ub.gds-dtl.price-base no-undo.
define output parameter pardiscnt-base-doc                  like ub.gds-dtl.price-base no-undo.
define output parameter pardiscnt-rubl-doc                  like ub.gds-dtl.price-base no-undo.
define output parameter pardiscnt-base-fact                 like ub.gds-dtl.price-base no-undo.
define output parameter pardiscnt-rubl-fact                 like ub.gds-dtl.price-base no-undo.
define buffer as_doc-line for ub.doc-line.
define buffer as_gds-dtl  for ub.gds-dtl.
define buffer as_trn-doc  for ub.trn-doc.
define variable varr-b as character no-undo.
do on error undo, return error return-value :
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
find first as_doc-line where recid(as_doc-line) = parrec-line.
find first as_trn-doc  where as_trn-doc.doc-code = as_doc-line.doc-code.
    define  variable price-rubl-with-tax-saleas    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-saleas    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-saleas like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-saleas like ub.doc-line.price-base no-undo.
    define  variable vat-base-saleas               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-saleas               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyeras              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyeras              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-saleas               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-saleas               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-saleas          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-saleas          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-saleas            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-saleas            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-saleas            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-saleas            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlas     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlas for ub.gds-dtl.
    define buffer out-vatp_partsas       for ub.parts.
    define buffer out-vatp_sysconfas     for ub.sysconf.
    define buffer out-vatp_doc-lineas    for ub.doc-line.
    define buffer out-vatp_goodsas       for ub.goods.
    define buffer out-vatp_trn-docas     for ub.trn-doc.
    define buffer out-vatp_doc-attras    for ub.doc-attr.
    define variable varprice-base-consas      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-consas      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typeas         as   character                           no-undo.
    define variable varfrm-cnsvas              as   character                           no-undo.
    define variable varroot-nodeas             as   integer                             no-undo.
    define variable varempty-scaleas           as   logical                             no-undo.
    define variable varis-cons-parts-haveas    as   logical                             no-undo.
    define variable varsum-base-factovpas      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpas      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpas      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpas  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpas      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpas       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpas       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpas       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpas   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpas       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpas      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpas      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpas      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpas  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpas      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpas       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpas       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpas       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpas   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpas       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntyas             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntyas             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlas        as   logical                             no-undo.
    define variable varcurasprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurasprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurasdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurasdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbas               as   character                           no-undo.
    define variable out-vatp-have-vat-sltas    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-docoas  for ub.trn-doc .
    define buffer   in-vatp-partsoas    for ub.parts   .
    define buffer   in-vatp-docoas      for ub.trn-doc .
    define buffer   in-vatp-goodsoas    for ub.goods   .
    define buffer   in-vatp-sysconfoas  for ub.sysconf .
    define buffer   in-vatp_doc-attroas for ub.doc-attr.
    define variable in-vatp-have-vat-sltoas       as   logical initial yes    no-undo.
    define variable vat-pc-locoas                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprboas                  as   character              no-undo.
    define variable slt-pc-locoas                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateoas              as   decimal                no-undo.
    define variable price-rubl-with-tax-locoas    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-locoas    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-locoas     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-locoas like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-locoas like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-locoas  like ub.doc-line.price-base no-undo.
    define variable vat-base-locoas               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-locoas               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-locoas                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-locoas               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-locoas               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-locoas                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-locoas          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-locoas          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-locoas           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-locoas         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-locoas         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-locoas          like ub.doc-line.price-rubl no-undo.
    define variable other-base-locoas             like ub.doc-line.price-base no-undo.
    define variable other-rubl-locoas             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-locoas              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-locoas          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdoas             as   character              no-undo.
    define variable varinvatp-typeoas             as   character              no-undo.
if as_trn-doc.ext-doc-type = 'ot':U or
   as_trn-doc.ext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltas = yes.
end.
else do:
  find first out-vatp_doc-attras no-lock
    where out-vatp_doc-attras.doc-code  = as_trn-doc.doc-code
      and out-vatp_doc-attras.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attras then do:
    assign
      out-vatp-have-vat-sltas = yes.
  end.
  else do:
     out-vatp-have-vat-sltas = no.
  end.
end.
find first out-vatp_goodsas where out-vatp_goodsas.artic     = as_doc-line.artic     and
                                   out-vatp_goodsas.prod-type = as_doc-line.prod-type and
                                   out-vatp_goodsas.prod-code = as_doc-line.prod-code no-lock.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  as_doc-line.artic
  ,input  as_doc-line.prod-type
  ,input  as_doc-line.prod-code
  ,output varroot-nodeas
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" as_doc-line.artic as_doc-line.prod-type as_doc-line.prod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodeas
  ,input  'empty-scale=request'
  ,output varempty-scaleas
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" as_doc-line.artic as_doc-line.prod-type as_doc-line.prod-code skip
    "Признак" varroot-nodeas skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbas
  )  .
if varoutvprbas = "base":u then do:
  assign
        road-tax-base-saleas    =  (if as_doc-line.road-tax = ? then 0 else as_doc-line.road-tax * 1)
    excise-base-saleas      =  (if as_doc-line.excise   = ? then 0 else as_doc-line.excise   * 1)
  .
end.
else do:
  assign
        road-tax-base-saleas    =  (if as_doc-line.road-tax = ? then 0 else as_doc-line.road-tax / as_trn-doc.base-rate * as_trn-doc.base-scale)
    excise-base-saleas      =  (if as_doc-line.excise   = ? then 0 else as_doc-line.excise   / as_trn-doc.base-rate * as_trn-doc.base-scale)
  .
end.
if varoutvprbas = "rubl":u then do:
  assign
        road-tax-rubl-saleas    = (if as_doc-line.road-tax = ? then 0 else as_doc-line.road-tax * 1)
    excise-rubl-saleas      = (if as_doc-line.excise   = ? then 0 else as_doc-line.excise   * 1) .
end.
else do:
  assign
        road-tax-rubl-saleas    = (if as_doc-line.road-tax = ? then 0 else as_doc-line.road-tax * as_trn-doc.base-rate / as_trn-doc.base-scale)
    excise-rubl-saleas      = (if as_doc-line.excise   = ? then 0 else as_doc-line.excise   * as_trn-doc.base-rate / as_trn-doc.base-scale) .
end.
assign
  varis-cons-parts-haveas =  no.
assign
  varfact-qntyas       = 0
  varcons-qntyas       = 0
  varprice-base-consas = 0
  varprice-rubl-consas = 0.
find first out-vatp_doc-lineas where
           out-vatp_doc-lineas.doc-code   = as_trn-doc.doc-code
       and out-vatp_doc-lineas.artic      = as_doc-line.artic
       and out-vatp_doc-lineas.prod-type  = as_doc-line.prod-type
       and out-vatp_doc-lineas.prod-code  = as_doc-line.prod-code no-lock no-error.
if available out-vatp_doc-lineas           and
  (out-vatp_doc-lineas.status_ = 'запрос':U or out-vatp_goodsas.gds-type = 'у':U) then do:
  assign
    varfact-qntyas = out-vatp_doc-lineas.fact-qnty.
end.
else do:
  for each out-vatp_partsas where out-vatp_partsas.out-code   = as_trn-doc.doc-code
                               and out-vatp_partsas.obj-type   = as_trn-doc.obj-type
                               and out-vatp_partsas.obj-code   = as_trn-doc.obj-code
                               and out-vatp_partsas.artic      = as_doc-line.artic
                               and out-vatp_partsas.prod-type  = as_doc-line.prod-type
                               and out-vatp_partsas.prod-code  = as_doc-line.prod-code no-lock :
    if out-vatp_partsas.purch-code = 2 then do:
assign
  price-rubl-with-tax-locoas = out-vatp_partsas.price-rubl
  price-base-with-tax-locoas = out-vatp_partsas.price-base
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprboas
  )  .
  if out-vatp_partsas.out-code = 'free-zone':U     or
     out-vatp_partsas.out-code = 'out-zone':U   or
     out-vatp_partsas.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltoas = yes.
  end.
  else do:
    find first in-vatp_doc-attroas no-lock
      where in-vatp_doc-attroas.doc-code  = out-vatp_partsas.out-code
        and in-vatp_doc-attroas.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attroas then do:
      assign
        in-vatp-have-vat-sltoas = yes.
    end.
    else do:
         in-vatp-have-vat-sltoas = no.
    end.
  end.
  assign
   price-cli-with-tax-locoas = out-vatp_partsas.price-cli
   cli-base-rateoas          = out-vatp_partsas.cli-base-rate.
  ASSIGN   road-tax-base-locoas  = (if out-vatp_partsas.road-tax-base  = ? then 0 else out-vatp_partsas.road-tax-base)
           road-tax-rubl-locoas  = (if out-vatp_partsas.road-tax-rubl  = ? then 0 else out-vatp_partsas.road-tax-rubl).
  ASSIGN  transport-base-locoas = (if out-vatp_partsas.transport-base = ? then 0 else out-vatp_partsas.transport-base)
          transport-rubl-locoas = (if out-vatp_partsas.transport-rubl = ? then 0 else out-vatp_partsas.transport-rubl)
          other-base-locoas     = (if out-vatp_partsas.other-base     = ? then 0 else out-vatp_partsas.other-base)
          other-rubl-locoas     = (if out-vatp_partsas.other-rubl     = ? then 0 else out-vatp_partsas.other-rubl)
          vat-pc-locoas         = (if out-vatp_partsas.vat-pc         = ? then 0 else out-vatp_partsas.vat-pc)
          slt-pc-locoas         = (if out-vatp_partsas.slt-pc         = ? then 0 else out-vatp_partsas.slt-pc).
          ASSIGN   slt-base-locoas    = (if in-vatp-have-vat-sltoas = no then 0 else (price-base-with-tax-locoas - ((if road-tax-base-locoas  = ? then 0 else road-tax-base-locoas) + (if transport-base-locoas = ? then 0 else transport-base-locoas) + (if other-base-locoas = ? then 0 else other-base-locoas)))                           * slt-pc-locoas / (100 + slt-pc-locoas))                        vat-base-locoas    = (if in-vatp-have-vat-sltoas = no then 0 else (price-base-with-tax-locoas - ((if road-tax-base-locoas  = ? then 0 else road-tax-base-locoas) + (if transport-base-locoas = ? then 0 else transport-base-locoas) + (if other-base-locoas = ? then 0 else other-base-locoas))) * (1 - slt-pc-locoas / (100 + slt-pc-locoas)) * vat-pc-locoas / (100 + vat-pc-locoas)).
    ASSIGN   slt-rubl-locoas    = (if in-vatp-have-vat-sltoas = no then 0 else (price-rubl-with-tax-locoas - ((if road-tax-rubl-locoas  = ? then 0 else road-tax-rubl-locoas) + (if transport-rubl-locoas = ? then 0 else transport-rubl-locoas) + (if other-rubl-locoas = ? then 0 else other-rubl-locoas)))                           * slt-pc-locoas / (100 + slt-pc-locoas))                        vat-rubl-locoas    = (if in-vatp-have-vat-sltoas = no then 0 else (price-rubl-with-tax-locoas - ((if road-tax-rubl-locoas  = ? then 0 else road-tax-rubl-locoas) + (if transport-rubl-locoas = ? then 0 else transport-rubl-locoas) + (if other-rubl-locoas = ? then 0 else other-rubl-locoas))) * (1 - slt-pc-locoas / (100 + slt-pc-locoas)) * vat-pc-locoas / (100 + vat-pc-locoas)).
  assign
    exch-rate-cli-locoas = (out-vatp_partsas.price-rubl - transport-rubl-locoas - other-rubl-locoas - road-tax-rubl-locoas - (if out-vatp_partsas.vat-type <> 'в т. ч.':U then vat-rubl-locoas else 0) - (if out-vatp_partsas.slt-type <> 'в т. ч.':U then slt-rubl-locoas else 0)) / out-vatp_partsas.price-cli .
  assign
    slt-cli-locoas        = slt-rubl-locoas       / exch-rate-cli-locoas
    vat-cli-locoas        = vat-rubl-locoas       / exch-rate-cli-locoas
    road-tax-cli-locoas   = road-tax-rubl-locoas  / exch-rate-cli-locoas
    transport-cli-locoas  = 0
    other-cli-locoas      = 0
  .
ASSIGN
          price-base-without-tax-locoas = price-base-with-tax-locoas - vat-base-locoas - slt-base-locoas - ((if road-tax-base-locoas  = ? then 0 else road-tax-base-locoas) + (if transport-base-locoas = ? then 0 else transport-base-locoas) + (if other-base-locoas = ? then 0 else other-base-locoas))
    price-rubl-without-tax-locoas = price-rubl-with-tax-locoas - vat-rubl-locoas - slt-rubl-locoas - ((if road-tax-rubl-locoas  = ? then 0 else road-tax-rubl-locoas) + (if transport-rubl-locoas = ? then 0 else transport-rubl-locoas) + (if other-rubl-locoas = ? then 0 else other-rubl-locoas))
.
      assign
        varprice-base-consas = varprice-base-consas + (price-base-with-tax-locoas - (if road-tax-base-locoas = ? then 0 else road-tax-base-locoas))* out-vatp_partsas.fact-qnty
        varprice-rubl-consas = varprice-rubl-consas + (price-rubl-with-tax-locoas - (if road-tax-rubl-locoas = ? then 0 else road-tax-rubl-locoas))* out-vatp_partsas.fact-qnty.
      assign
        varis-cons-parts-haveas = yes
        varcons-qntyas          = varcons-qntyas + out-vatp_partsas.fact-qnty.
    end.
    assign
      varfact-qntyas = varfact-qntyas + out-vatp_partsas.fact-qnty.
  end.
end.
assign
  varprice-base-consas = varprice-base-consas / varcons-qntyas
  varprice-rubl-consas = varprice-rubl-consas / varcons-qntyas.
if varprice-base-consas = ? then do:
  assign
    varprice-base-consas = 0.
end.
if varprice-rubl-consas = ? then do:
  assign
    varprice-rubl-consas = 0.
end.
assign
  varsum-base-factovpas     = 0
  varslt-base-factovpas     = 0
  varvat-base-factovpas     = 0
  varvatcons-base-factovpas = 0
  vardsc-base-factovpas     = 0
  varsum-base-docovpas      = 0
  varslt-base-docovpas      = 0
  varvat-base-docovpas      = 0
  varvatcons-base-docovpas  = 0
  vardsc-base-docovpas      = 0
  varsum-rubl-factovpas     = 0
  varslt-rubl-factovpas     = 0
  varvat-rubl-factovpas     = 0
  varvatcons-rubl-factovpas = 0
  vardsc-rubl-factovpas     = 0
  varsum-rubl-docovpas      = 0
  varslt-rubl-docovpas      = 0
  varvat-rubl-docovpas      = 0
  varvatcons-rubl-docovpas  = 0
  vardsc-rubl-docovpas      = 0.
assign
  varis-one-gds-dtlas = no.
find first out-vatp_gds-dtlas where out-vatp_gds-dtlas.doc-code  = as_trn-doc.doc-code  and
                                     out-vatp_gds-dtlas.artic     = as_doc-line.artic     and
                                     out-vatp_gds-dtlas.prod-type = as_doc-line.prod-type and
                                     out-vatp_gds-dtlas.prod-code = as_doc-line.prod-code no-lock no-error.
if available out-vatp_gds-dtlas then do:
  find first buf_out-vatp_gds-dtlas where buf_out-vatp_gds-dtlas.doc-code  =  as_trn-doc.doc-code                and
                                           buf_out-vatp_gds-dtlas.artic     =  as_doc-line.artic                   and
                                           buf_out-vatp_gds-dtlas.prod-type =  as_doc-line.prod-type               and
                                           buf_out-vatp_gds-dtlas.prod-code =  as_doc-line.prod-code               and
                                           recid(buf_out-vatp_gds-dtlas)    <> recid(out-vatp_gds-dtlas) no-lock no-error.
  if not available buf_out-vatp_gds-dtlas then do:
    assign
      varis-one-gds-dtlas = yes.
  end.
  if varoutvprbas = "base":u then do:
    assign
      varcurasprice-base = out-vatp_gds-dtlas.cur-base
      varcurasprice-rubl = out-vatp_gds-dtlas.cur-base * ((out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl) / (out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base)).
  end.
  else do:
    assign
      varcurasprice-base = out-vatp_gds-dtlas.cur-base / ((out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl) / (out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base))
      varcurasprice-rubl = out-vatp_gds-dtlas.cur-base.
  end.
  if varempty-scaleas    = yes or
     varis-one-gds-dtlas = yes   then do:
    assign
                price-base-with-tax-saleas    = (out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base)
        slt-base-saleas               = (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base                - road-tax-base-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc)
        vat-base-buyeras              = (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base                - road-tax-base-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-base-saleas) * as_doc-line.vat-pc / (100 + as_doc-line.vat-pc)
        discnt-base-saleas            = out-vatp_gds-dtlas.discnt-base
                price-rubl-with-tax-saleas    = (out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl)
        slt-rubl-saleas               = (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl                - road-tax-rubl-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc)
        vat-rubl-buyeras              = (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl                - road-tax-rubl-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-rubl-saleas) * as_doc-line.vat-pc / (100 + as_doc-line.vat-pc)
        discnt-rubl-saleas            = out-vatp_gds-dtlas.discnt-rubl
        .
    if as_trn-doc.doc-type = 'инв':U then do:
      ASSIGN
                vat-base-saleas               = (if out-vatp-have-vat-sltas = no then 0 else (((out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base) - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base                - road-tax-base-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-base-saleas - varprice-base-consas) * as_doc-line.cons-vat-pc / (100 + as_doc-line.cons-vat-pc) * out-vatp_gds-dtlas.doc-qnty * varcons-qntyas / varfact-qntyas + ((out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base) - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base                - road-tax-base-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-base-saleas) * as_doc-line.vat-pc / (100 + as_doc-line.vat-pc) * out-vatp_gds-dtlas.doc-qnty * (varfact-qntyas - varcons-qntyas) / varfact-qntyas) / varfact-qntyas)
                vat-rubl-saleas               = (if out-vatp-have-vat-sltas = no then 0 else (((out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl) - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl                - road-tax-rubl-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-rubl-saleas - varprice-rubl-consas) * as_doc-line.cons-vat-pc / (100 + as_doc-line.cons-vat-pc) * out-vatp_gds-dtlas.doc-qnty * varcons-qntyas / varfact-qntyas + ((out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl) - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl                - road-tax-rubl-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-rubl-saleas) * as_doc-line.vat-pc / (100 + as_doc-line.vat-pc) * out-vatp_gds-dtlas.doc-qnty * (varfact-qntyas - varcons-qntyas) / varfact-qntyas) / varfact-qntyas)
        .
    end.
    else do:
      ASSIGN
                vat-base-saleas               = (if out-vatp-have-vat-sltas = no then 0 else (((out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base) - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base                - road-tax-base-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-base-saleas - varprice-base-consas) * as_doc-line.cons-vat-pc / (100 + as_doc-line.cons-vat-pc) * out-vatp_gds-dtlas.fact-qnty * varcons-qntyas / varfact-qntyas + ((out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base) - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base                - road-tax-base-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-base-saleas ) * as_doc-line.vat-pc / (100 + as_doc-line.vat-pc) * out-vatp_gds-dtlas.fact-qnty * (varfact-qntyas - varcons-qntyas) / varfact-qntyas) / varfact-qntyas)
                vat-rubl-saleas               = (if out-vatp-have-vat-sltas = no then 0 else (((out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl) - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl                - road-tax-rubl-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-rubl-saleas - varprice-rubl-consas) * as_doc-line.cons-vat-pc / (100 + as_doc-line.cons-vat-pc) * out-vatp_gds-dtlas.fact-qnty * varcons-qntyas / varfact-qntyas + ((out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl) - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl                - road-tax-rubl-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-rubl-saleas) * as_doc-line.vat-pc / (100 + as_doc-line.vat-pc) * out-vatp_gds-dtlas.fact-qnty * (varfact-qntyas - varcons-qntyas) / varfact-qntyas) / varfact-qntyas)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtlas where out-vatp_gds-dtlas.doc-code  = as_trn-doc.doc-code  and
                                       out-vatp_gds-dtlas.artic     = as_doc-line.artic     and
                                       out-vatp_gds-dtlas.prod-type = as_doc-line.prod-type and
                                       out-vatp_gds-dtlas.prod-code = as_doc-line.prod-code no-lock :
      if varoutvprbas = "base":u then do:
        assign
          varcurasprice-base = out-vatp_gds-dtlas.cur-base
          varcurasprice-rubl = out-vatp_gds-dtlas.cur-base * ((out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl) / (out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base)).
      end.
      else do:
        assign
          varcurasprice-base = out-vatp_gds-dtlas.cur-base / ((out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl) / (out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base))
          varcurasprice-rubl = out-vatp_gds-dtlas.cur-base.
      end.
      assign
             varsum-base-factovpas = varsum-base-factovpas + (out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base)                 * out-vatp_gds-dtlas.fact-qnty
       varslt-base-factovpas = varslt-base-factovpas + (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base                - road-tax-base-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc)                   * out-vatp_gds-dtlas.fact-qnty
       varvat-base-factovpas = varvat-base-factovpas + (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base                - road-tax-base-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-base-saleas) * as_doc-line.vat-pc / (100 + as_doc-line.vat-pc)                   * out-vatp_gds-dtlas.fact-qnty
       varvatcons-base-factovpas = varvatcons-base-factovpas + (((out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base) - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base                - road-tax-base-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-base-saleas - varprice-base-consas) * as_doc-line.cons-vat-pc / (100 + as_doc-line.cons-vat-pc) * out-vatp_gds-dtlas.fact-qnty * varcons-qntyas / varfact-qntyas + ((out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base) - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base                - road-tax-base-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-base-saleas) * as_doc-line.vat-pc / (100 + as_doc-line.vat-pc) * out-vatp_gds-dtlas.fact-qnty * (varfact-qntyas - varcons-qntyas) / varfact-qntyas)
       vardsc-base-factovpas = vardsc-base-factovpas + out-vatp_gds-dtlas.discnt-base * out-vatp_gds-dtlas.fact-qnty
       varsum-base-docovpas  = varsum-base-docovpas  + (out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base)                 * out-vatp_gds-dtlas.doc-qnty
       varslt-base-docovpas  = varslt-base-docovpas  + (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base                - road-tax-base-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc)                   * out-vatp_gds-dtlas.doc-qnty
       varvat-base-docovpas  = varvat-base-docovpas  + (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base                - road-tax-base-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-base-saleas) * as_doc-line.vat-pc / (100 + as_doc-line.vat-pc)                   * out-vatp_gds-dtlas.doc-qnty
       varvatcons-base-docovpas  = varvatcons-base-docovpas  + (((out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base) - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base                - road-tax-base-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-base-saleas - varprice-base-consas) * as_doc-line.cons-vat-pc / (100 + as_doc-line.cons-vat-pc) * out-vatp_gds-dtlas.doc-qnty * varcons-qntyas / varfact-qntyas + ((out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base) - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-base - out-vatp_gds-dtlas.discnt-base                - road-tax-base-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-base-saleas) * as_doc-line.vat-pc / (100 + as_doc-line.vat-pc) * out-vatp_gds-dtlas.doc-qnty * (varfact-qntyas - varcons-qntyas) / varfact-qntyas)
       vardsc-base-docovpas  = vardsc-base-docovpas  + out-vatp_gds-dtlas.discnt-base * out-vatp_gds-dtlas.doc-qnty
      .
      assign
             varsum-rubl-factovpas = varsum-rubl-factovpas + (out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl)                 * out-vatp_gds-dtlas.fact-qnty
       varslt-rubl-factovpas = varslt-rubl-factovpas + (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl                - road-tax-rubl-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc)                   * out-vatp_gds-dtlas.fact-qnty
       varvat-rubl-factovpas = varvat-rubl-factovpas + (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl                - road-tax-rubl-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-rubl-saleas) * as_doc-line.vat-pc / (100 + as_doc-line.vat-pc)                   * out-vatp_gds-dtlas.fact-qnty
       varvatcons-rubl-factovpas = varvatcons-rubl-factovpas + (((out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl) - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl                - road-tax-rubl-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-rubl-saleas - varprice-rubl-consas) * as_doc-line.cons-vat-pc / (100 + as_doc-line.cons-vat-pc) * out-vatp_gds-dtlas.fact-qnty * varcons-qntyas / varfact-qntyas + ((out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl) - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl                - road-tax-rubl-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-rubl-saleas) * as_doc-line.vat-pc / (100 + as_doc-line.vat-pc) * out-vatp_gds-dtlas.fact-qnty * (varfact-qntyas - varcons-qntyas) / varfact-qntyas)
       vardsc-rubl-factovpas = vardsc-rubl-factovpas + out-vatp_gds-dtlas.discnt-rubl * out-vatp_gds-dtlas.fact-qnty
       varsum-rubl-docovpas  = varsum-rubl-docovpas  + (out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl)                 * out-vatp_gds-dtlas.doc-qnty
       varslt-rubl-docovpas  = varslt-rubl-docovpas  + (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl                - road-tax-rubl-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc)                   * out-vatp_gds-dtlas.doc-qnty
       varvat-rubl-docovpas  = varvat-rubl-docovpas  + (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl                - road-tax-rubl-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-rubl-saleas) * as_doc-line.vat-pc / (100 + as_doc-line.vat-pc)                   * out-vatp_gds-dtlas.doc-qnty
       varvatcons-rubl-docovpas  = varvatcons-rubl-docovpas  + (((out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl) - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl                - road-tax-rubl-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-rubl-saleas - varprice-rubl-consas) * as_doc-line.cons-vat-pc / (100 + as_doc-line.cons-vat-pc) * out-vatp_gds-dtlas.doc-qnty * varcons-qntyas / varfact-qntyas + ((out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl) - (if out-vatp-have-vat-sltas = no then 0 else out-vatp_gds-dtlas.price-rubl - out-vatp_gds-dtlas.discnt-rubl                - road-tax-rubl-saleas) * as_doc-line.SLT-pc / (100 + as_doc-line.SLT-pc) - road-tax-rubl-saleas) * as_doc-line.vat-pc / (100 + as_doc-line.vat-pc) * out-vatp_gds-dtlas.doc-qnty * (varfact-qntyas - varcons-qntyas) / varfact-qntyas)
       vardsc-rubl-docovpas  = vardsc-rubl-docovpas  + out-vatp_gds-dtlas.discnt-rubl * out-vatp_gds-dtlas.doc-qnty   .
    end.
    if as_trn-doc.doc-type = 'инв':U then do:
      ASSIGN
                price-base-with-tax-saleas    = varsum-base-docovpas / varfact-qntyas
        slt-base-saleas               = varslt-base-docovpas / varfact-qntyas
        vat-base-buyeras              = varvat-base-docovpas / varfact-qntyas
        discnt-base-saleas            = vardsc-base-docovpas / varfact-qntyas
        vat-base-saleas               = varvatcons-base-docovpas / varfact-qntyas
                price-rubl-with-tax-saleas    = varsum-rubl-docovpas / varfact-qntyas
        slt-rubl-saleas               = varslt-rubl-docovpas / varfact-qntyas
        vat-rubl-buyeras              = varvat-rubl-docovpas / varfact-qntyas
        discnt-rubl-saleas            = vardsc-rubl-docovpas / varfact-qntyas
        vat-rubl-saleas               = varvatcons-rubl-docovpas / varfact-qntyas.
    end.
    else do:
      ASSIGN
                price-base-with-tax-saleas    = varsum-base-factovpas / varfact-qntyas
        slt-base-saleas               = varslt-base-factovpas / varfact-qntyas
        vat-base-buyeras              = varvat-base-factovpas / varfact-qntyas
        discnt-base-saleas            = vardsc-base-factovpas / varfact-qntyas
        vat-base-saleas               = varvatcons-base-factovpas / varfact-qntyas
                price-rubl-with-tax-saleas    = varsum-rubl-factovpas / varfact-qntyas
        slt-rubl-saleas               = varslt-rubl-factovpas / varfact-qntyas
        vat-rubl-buyeras              = varvat-rubl-factovpas / varfact-qntyas
        discnt-rubl-saleas            = vardsc-rubl-factovpas / varfact-qntyas
        vat-rubl-saleas               = varvatcons-rubl-factovpas / varfact-qntyas.
    end.
  end.
end.
assign
  price-base-without-tax-saleas = price-base-with-tax-saleas - vat-base-saleas - slt-base-saleas - road-tax-base-saleas
  price-rubl-without-tax-saleas = price-rubl-with-tax-saleas - vat-rubl-saleas - slt-rubl-saleas - road-tax-rubl-saleas.
if as_trn-doc.ext-doc-type = 'vt':U
  or as_trn-doc.ext-doc-type = 'vp':U
then do:
  assign
    parroad-tax-doc                  = (if varr-b = "base" then road-tax-base-saleas else road-tax-rubl-saleas) * as_doc-line.fact-qnty
    parslt-doc-base                  = slt-base-saleas * as_doc-line.fact-qnty
    parvat-doc-base                  = vat-base-saleas * as_doc-line.fact-qnty
    parsum-doc-base                  = (price-base-with-tax-saleas + discnt-base-saleas) * as_doc-line.fact-qnty
    parsum-doc-rubl                  = (price-rubl-with-tax-saleas + discnt-rubl-saleas) * as_doc-line.fact-qnty
    pardiscnt-base-doc               = discnt-base-saleas * as_doc-line.fact-qnty
    pardiscnt-rubl-doc               = discnt-rubl-saleas * as_doc-line.fact-qnty
    parexcise-doc                    = (if varr-b = "base" then excise-base-saleas else excise-rubl-saleas) * as_doc-line.fact-qnty
    parslt-doc-rubl                  = slt-base-saleas * as_doc-line.fact-qnty
    parvat-doc-rubl                  = vat-base-saleas * as_doc-line.fact-qnty.
end.
else do:
  assign
    parroad-tax-fact-base            = road-tax-base-saleas * as_doc-line.fact-qnty
    parexcise-fact-base              = excise-base-saleas * as_doc-line.fact-qnty
    parslt-fact-base                 = slt-base-saleas * as_doc-line.fact-qnty
    parvat-fact-base                 = vat-base-saleas * as_doc-line.fact-qnty
    parsum-fact-out-dsc-slt-vat-base = (price-base-with-tax-saleas - vat-base-saleas - slt-base-saleas) * as_doc-line.fact-qnty
    parsum-fact-out-dsc-base         = price-base-with-tax-saleas * as_doc-line.fact-qnty
    parsum-fact-out-dsc-rubl         = price-rubl-with-tax-saleas * as_doc-line.fact-qnty
    pardiscnt-base-fact              = discnt-base-saleas * as_doc-line.fact-qnty
    pardiscnt-rubl-fact              = discnt-rubl-saleas * as_doc-line.fact-qnty
    parroad-tax-fact-rubl            = road-tax-rubl-saleas * as_doc-line.fact-qnty
    parexcise-fact-rubl              = excise-rubl-saleas * as_doc-line.fact-qnty
    parslt-fact-rubl                 = slt-rubl-saleas * as_doc-line.fact-qnty
    parvat-fact-rubl                 = vat-rubl-saleas * as_doc-line.fact-qnty
    parsum-fact-out-dsc-slt-vat-rubl = (price-rubl-with-tax-saleas - vat-rubl-saleas - slt-rubl-saleas) * as_doc-line.fact-qnty
    parroad-tax-fact                 = (if varr-b = "base" then road-tax-base-saleas else road-tax-rubl-saleas) * as_doc-line.fact-qnty
    parexcise-fact                   = (if varr-b = "base" then excise-base-saleas else excise-rubl-saleas) * as_doc-line.fact-qnty.
end.
for each as_gds-dtl where as_gds-dtl.artic     = as_doc-line.artic
                      and as_gds-dtl.prod-type = as_doc-line.prod-type
                      and as_gds-dtl.prod-code = as_doc-line.prod-code
                      and as_gds-dtl.doc-code  = as_doc-line.doc-code no-lock:
  assign
    parsum-fact-cur                  =  parsum-fact-cur                  + as_gds-dtl.cur-base * as_gds-dtl.fact-qnty
    parsum-doc-cur                   =  parsum-doc-cur                   + as_gds-dtl.cur-base * as_gds-dtl.doc-qnty
  .
  if varr-b = "rubl":u then do:
    assign
      parov-fact-base                  =  parov-fact-base                  + (as_gds-dtl.cur-base - as_gds-dtl.price-rubl) * as_gds-dtl.fact-qnty
      parov-vat-fact-base              =  parov-vat-fact-base              + (as_gds-dtl.cur-base - as_gds-dtl.price-rubl) * as_gds-dtl.fact-qnty * as_doc-line.vat-pc / ( 100 + as_doc-line.vat-pc)
      parov-doc-base                   =  parov-doc-base                   + (as_gds-dtl.cur-base - as_gds-dtl.price-rubl) * as_gds-dtl.doc-qnty
      parov-vat-doc-base               =  parov-vat-doc-base               + (as_gds-dtl.cur-base - as_gds-dtl.price-rubl) * as_gds-dtl.doc-qnty * as_doc-line.vat-pc / ( 100 + as_doc-line.vat-pc)
    .
  end.
  else do:
    assign
      parov-fact-base                  =  parov-fact-base                  + (as_gds-dtl.cur-base - as_gds-dtl.price-base) * as_gds-dtl.fact-qnty
      parov-vat-fact-base              =  parov-vat-fact-base              + (as_gds-dtl.cur-base - as_gds-dtl.price-base) * as_gds-dtl.fact-qnty * as_doc-line.vat-pc / ( 100 + as_doc-line.vat-pc)
      parov-doc-base                   =  parov-doc-base                   + (as_gds-dtl.cur-base - as_gds-dtl.price-base) * as_gds-dtl.doc-qnty
      parov-vat-doc-base               =  parov-vat-doc-base               + (as_gds-dtl.cur-base - as_gds-dtl.price-base) * as_gds-dtl.doc-qnty * as_doc-line.vat-pc / ( 100 + as_doc-line.vat-pc)
    .
  end.
end.
end.
end procedure.
