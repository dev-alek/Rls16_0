block-level on error undo, throw.
using ibs.th.gbl.gbl-hndllib from propath.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Библиотека процедур для работы со складскими документами":U.
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
  define new global shared variable g#lib-rvs as handle no-undo.
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
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
procedure plgdsfnd :
  define input  parameter p-chk-and-chs    as logical               no-undo .
  define input  parameter p-obj-type       like ub.gds-obj.obj-type no-undo .
  define input  parameter p-obj-code       like ub.gds-obj.obj-code no-undo .
  define input  parameter p-gds-code       like ub.goods.gds-code   no-undo .
  define output parameter p-reserv-pl-code as   logical             no-undo .
  define output parameter p-pl-code        like ub.pl-gds.pl-code   no-undo .
  define buffer buf_goods         for ub.goods .
  define buffer buf_pl-gds        for ub.pl-gds .
  define buffer buf_second_pl-gds for ub.pl-gds .
  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .
  if not available buf_goods
  then do:
    return error "Не найден товар. Первичный бар-код " + string( p-gds-code ) .
  end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'place-rsrv=request'
  ,output p-reserv-pl-code
  ) no-error .
  if error-status :error
  then do:
    return error substitute("Ошибка при запросе атрибута place-rsrv товара на объекте  &1 &2 " , error-status :get-message(1) , return-value  )  .
  end.
  if p-reserv-pl-code = no
  then do:
    return .
  end.
  if p-chk-and-chs <> yes
  then do:
    return .
  end.
  find first buf_pl-gds no-lock where
             buf_pl-gds.obj-type = p-obj-type and
             buf_pl-gds.obj-code = p-obj-code and
             buf_pl-gds.gds-code = p-gds-code no-error .
  if not available buf_pl-gds
  then do:
    return error "К товару не привязано ни одного места хранения" .
  end.
  find first buf_second_pl-gds no-lock where
             buf_second_pl-gds.obj-type  = p-obj-type          and
             buf_second_pl-gds.obj-code  = p-obj-code          and
             buf_second_pl-gds.gds-code  = p-gds-code          and
             recid( buf_second_pl-gds ) <> recid( buf_pl-gds ) no-error .
  if not available buf_second_pl-gds
  then do:
    assign
      p-pl-code = buf_pl-gds.pl-code
    .
  end.
  else do:
    return error "Не выбрано место хранения " + chr(10) .
  end.
end procedure.
define variable vss-include-info6 as character format "X(65)":U no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEFINE VARIABLE v-S_CONTRACT               AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-S_CODE_LAST_MASTER_NUM   AS CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE v-DELIM_CHR_3              AS CHARACTER NO-UNDO INITIAL "".
ASSIGN
   v-S_CONTRACT                = "Contract":U
   v-S_CODE_LAST_MASTER_NUM    = "LastMasterNum":U
   v-DELIM_CHR_3               = ","
   .
DEFINE VARIABLE i-gl-Host-Code      AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Contract-Code  AS INTEGER NO-UNDO INITIAL 0.
DEFINE VARIABLE i-gl-Extent3        AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
FUNCTION Can-Find-Spec RETURN LOGICAL (
   INPUT iHost-Code    AS INTEGER,
   INPUT iContract-Num AS INTEGER,
   INPUT iGds-Code     AS INTEGER ):
   DEFINE BUFFER buf_Spec FOR ub.Contract-Specif.
   DEFINE VARIABLE iTmp-Host-Code     AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Contract-Num  AS INTEGER NO-UNDO INITIAL 0.
   DEFINE VARIABLE iTmp-Extent3       AS INTEGER NO-UNDO INITIAL 0 EXTENT 3.
   DEFINE VARIABLE lRet               AS LOGICAL NO-UNDO INITIAL FALSE.
   RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
       INPUT  iHost-Code,
       INPUT  iContract-Num,
       OUTPUT iTmp-Extent3
       ).
   IF iTmp-Extent3[1] = 2 THEN DO:
      ASSIGN
         iTmp-Host-Code      = iTmp-Extent3[2]
         iTmp-Contract-Num   = iTmp-Extent3[3]
         .
   END. ELSE DO:
      ASSIGN
         iTmp-Host-Code      = iHost-Code
         iTmp-Contract-Num   = iContract-Num
         .
   END.
   IF iGds-Code = ? THEN DO:
      ASSIGN
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                        ).
   END. ELSE DO:
         lRet = CAN-FIND(FIRST buf_Spec NO-LOCK WHERE
                               buf_Spec.Host-Code     = iTmp-Host-Code
                           AND buf_Spec.Contract-Num  = iTmp-Contract-Num
                           AND buf_Spec.Gds-Code      = iGds-Code
                         ).
   END.
   RETURN (lRet).
END FUNCTION.
PROCEDURE MS-Contract-EXTENT-3:
   DEFINE INPUT  PARAMETER i-Host-Code     AS INTEGER NO-UNDO.
   DEFINE INPUT  PARAMETER i-Contract-Code AS INTEGER NO-UNDO.
   DEFINE OUTPUT PARAMETER i-Ret           AS INTEGER NO-UNDO EXTENT 3 INITIAL 0.
   DEFINE BUFFER buf_Ext-Classif FOR ub.Ext-Classif.
   DEFINE BUFFER buf_Cont        FOR ub.Contract.
   DEFINE BUFFER buf_Cont-2      FOR ub.Contract.
   FIND FIRST buf_Cont-2 WHERE
              buf_Cont-2.Host-Code      = i-Host-Code
          AND buf_Cont-2.Contract-Code  = i-Contract-Code
        NO-LOCK NO-ERROR.
   IF NOT AVAILABLE buf_Cont-2 THEN DO:
      RETURN.
   END.
   FOR FIRST buf_Ext-Classif WHERE
             buf_Ext-Classif.Classif-name = v-S_CONTRACT
        AND  buf_Ext-Classif.CharKey_One  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                            STRING(i-Contract-code)
        AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
       NO-LOCK,
       EACH buf_Cont WHERE
            buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3 ))
        AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_Two, v-DELIM_CHR_3))
       NO-LOCK:
       ASSIGN
          i-Ret[1] = 1
          i-Ret[2] = buf_Cont.Host-code
          i-Ret[3] = buf_Cont.Contract-code
          .
       LEAVE.
   END.
   IF i-Ret[1] <> 1 THEN DO:
      FOR FIRST buf_Ext-Classif WHERE
                buf_Ext-Classif.Classif-name = v-S_CONTRACT
           AND  buf_Ext-Classif.CharKey_Two  = STRING(i-Host-code) + v-DELIM_CHR_3 +
                                               STRING(i-Contract-code)
           AND  buf_Ext-classif.db-num       = buf_Cont-2.Db-num
          NO-LOCK,
          EACH buf_Cont WHERE
               buf_Cont.Host-code     = INTEGER(ENTRY(1, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
           AND buf_Cont.Contract-code = INTEGER(ENTRY(2, buf_Ext-classif.charKey_One, v-DELIM_CHR_3))
          NO-LOCK:
          ASSIGN
             i-Ret[1] = 2
             i-Ret[2] = buf_Cont.Host-code
             i-Ret[3] = buf_Cont.Contract-code
             .
          LEAVE.
      END.
   END.
   RETURN.
END PROCEDURE.
procedure cpprclig :
  define input        parameter pardoc-code       as   character                  no-undo.
  define input        parameter parcli-code       like ub.trn-doc.cli-code        no-undo.
  define input        parameter parcli-type       like ub.trn-doc.cli-type        no-undo.
  define input        parameter parhost-code      like ub.trn-doc.host-code       no-undo.
  define input        parameter parbase-rate      like ub.trn-doc.base-rate       no-undo.
  define input        parameter parbase-scale     like ub.trn-doc.base-scale      no-undo.
  define input        parameter parexch-rate      like ub.trn-doc.exch-rate       no-undo.
  define input        parameter parexch-scale     like ub.trn-doc.exch-scale      no-undo.
  define input        parameter parvat-type       like ub.trn-doc.vat-type        no-undo.
  define input        parameter parslt-type       like ub.trn-doc.slt-type        no-undo.
  define input        parameter parartic          like ub.doc-line.artic          no-undo.
  define input        parameter parprod-type      like ub.doc-line.prod-type      no-undo.
  define input        parameter parprod-code      like ub.doc-line.prod-code      no-undo.
  define input        parameter paris-cli-tax     as   logical                    no-undo.
  define input        parameter parcli-base-rate  like ub.doc-line.cli-base-rate  no-undo.
  define input        parameter partransport-rubl like ub.doc-line.transport-rubl no-undo.
  define input        parameter parother-rubl     like ub.doc-line.other-rubl     no-undo.
  define output       parameter parprice-cli      like ub.doc-line.price-cli      no-undo.
  define output       parameter parprice-base     like ub.doc-line.price-base     no-undo.
  define output       parameter parprice-rubl     like ub.doc-line.price-rubl     no-undo.
  define input-output parameter parvat-pc         like ub.doc-line.vat-pc         no-undo.
  define input-output parameter parslt-pc         like ub.doc-line.slt-pc         no-undo.
  define input-output parameter parroad-tax       like ub.doc-line.road-tax       no-undo.
  define input-output parameter parexcise         like ub.doc-line.excise         no-undo.
  define variable varprice-cli                like ub.doc-line.price-rubl no-undo.
  define variable varprice-cli-unit-base      like ub.doc-line.price-rubl no-undo.
  define variable varprice-road-tax           like ub.doc-line.price-rubl no-undo.
  define variable varprice-other-exp          like ub.doc-line.price-rubl no-undo.
  define variable varprice-transport-exp      like ub.doc-line.price-rubl no-undo.
  define variable varprice-without-abs        like ub.doc-line.price-rubl no-undo.
  define variable varprice-slt                like ub.doc-line.price-rubl no-undo.
  define variable varprice-no-slt             like ub.doc-line.price-rubl no-undo.
  define variable varprice-vat                like ub.doc-line.price-rubl no-undo.
  define variable varprice-no-vat-slt         like ub.doc-line.price-rubl no-undo.
  define variable varprice-rubl               like ub.doc-line.price-rubl no-undo.
  define variable varprice-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
  define variable varprice-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
  define variable varprice-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
  define variable varprice-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
  define variable varprice-slt-rubl           like ub.doc-line.price-rubl no-undo.
  define variable varprice-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
  define variable varprice-vat-rubl           like ub.doc-line.price-rubl no-undo.
  define variable varprice-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
  define variable varprice-base               like ub.doc-line.price-base no-undo.
  define variable varprice-road-tax-base      like ub.doc-line.price-base no-undo.
  define variable varprice-other-exp-base     like ub.doc-line.price-base no-undo.
  define variable varprice-transport-exp-base like ub.doc-line.price-base no-undo.
  define variable varprice-without-abs-base   like ub.doc-line.price-base no-undo.
  define variable varprice-slt-base           like ub.doc-line.price-base no-undo.
  define variable varprice-no-slt-base        like ub.doc-line.price-base no-undo.
  define variable varprice-vat-base           like ub.doc-line.price-base no-undo.
  define variable varprice-no-vat-slt-base    like ub.doc-line.price-base no-undo.
  define variable v-specif-found              as   logical                no-undo.
  define variable v-rcv-found                 as   logical                no-undo .
  define buffer bf_cli-gds         for ub.cli-gds .
  define buffer bf_doc-line        for ub.doc-line.
  define buffer bf_trn-doc         for ub.trn-doc.
  define buffer bf_goods           for ub.goods.
  define buffer bf_contract-specif for ub.contract-specif.
  define buffer buf_ord-chain      for ub.ord-chain .
  define buffer buf_ord-doc-rcv    for ub.ord-doc-rcv .
  define buffer buf_ord-line-rcv   for ub.ord-line-rcv .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info6, return-value, chr(10), error-status :get-message ( 1 ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info6 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info6 )
  :
    assign
      v-rcv-found    = false
      v-specif-found = false
    .
    find first buf_ord-chain no-lock
      where buf_ord-chain.rel-doc-code =  pardoc-code
        and buf_ord-chain.rel-doc-type = 'trn':u
      no-error .
    if available buf_ord-chain then do:
      find first buf_ord-doc-rcv no-lock
        where buf_ord-doc-rcv.rcv-code = buf_ord-chain.doc-code
      no-error .
      if available buf_ord-doc-rcv then do:
        find first buf_ord-line-rcv no-lock
          where buf_ord-line-rcv.doc-code  = buf_ord-doc-rcv.doc-code
            and buf_ord-line-rcv.artic     = parartic
            and buf_ord-line-rcv.prod-type = parprod-type
            and buf_ord-line-rcv.prod-code = parprod-code
          no-error .
        if available buf_ord-line-rcv then do:
          find first bf_trn-doc  no-lock
            where bf_trn-doc.doc-code = pardoc-code
          .
          assign
            parprice-cli = buf_ord-line-rcv.price-cli
            parroad-tax  = buf_ord-line-rcv.road-tax
            parexcise    = buf_ord-line-rcv.excise
            v-rcv-found  = true
            .
          if parslt-type <> 'без':U then do:
            if bf_trn-doc.slt-type <> 'без':U then do:
              assign
                parslt-pc = buf_ord-line-rcv.slt-pc
              .
            end.
          end.
          else do:
            assign
              parslt-pc = 0
            .
          end.
          if parvat-type <> 'без':U then do:
            if bf_trn-doc.vat-type <> 'без':U then do:
              assign
                parvat-pc = buf_ord-line-rcv.vat-pc
              .
            end.
          end.
          else do:
            assign
              parvat-pc = 0
            .
          end.
        end.
      end.
    end.
    if v-rcv-found = false then do:
      find first bf_trn-doc no-lock
        where bf_trn-doc.doc-code = pardoc-code
        no-error.
      if available bf_trn-doc
        and bf_trn-doc.contract-code <> 0
      then do:
        find first bf_goods no-lock
          where bf_goods.artic     = parartic
            and bf_goods.prod-code = parprod-code
            and bf_goods.prod-type = parprod-type
          no-error.
        if available bf_goods then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  bf_trn-doc.host-code,
    INPUT  bf_trn-doc.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = bf_trn-doc.host-code
      i-gl-Contract-Code  = bf_trn-doc.contract-code
      .
END.
    FIND FIRST bf_contract-specif
           NO-LOCK
           WHERE
               bf_contract-specif.Host-code    = i-gl-Host-Code
           AND bf_contract-specif.Contract-num = i-gl-Contract-Code
           AND bf_contract-specif.Gds-code     = bf_goods.gds-code
           NO-ERROR
           .
          if available bf_contract-specif then do:
            assign
              parprice-cli   = (bf_contract-specif.price-cli / bf_contract-specif.cli-base-rate)  * parcli-base-rate
              parvat-type    = bf_contract-specif.vat-type
              parvat-pc      = bf_contract-specif.vat-pc
              v-specif-found = yes
            .
          end.
        end.
      end.
      find first bf_cli-gds no-lock
        where bf_cli-gds.cli-code  = parcli-code
          and bf_cli-gds.cli-type  = parcli-type
          and bf_cli-gds.host-code = parhost-code
          and bf_cli-gds.artic     = parartic
          and bf_cli-gds.prod-code = parprod-code
          and bf_cli-gds.prod-type = parprod-type
        no-error.
      if available bf_cli-gds then do:
        if v-specif-found = false then do:
          assign
            parprice-cli = bf_cli-gds.price-cli
          .
        end.
        if paris-cli-tax then do:
          find first bf_doc-line no-lock
            where bf_doc-line.doc-code  = bf_cli-gds.in-code
              and bf_doc-line.artic     = bf_cli-gds.artic
              and bf_doc-line.prod-type = bf_cli-gds.prod-type
              and bf_doc-line.prod-code = bf_cli-gds.prod-code
            no-error.
          if available bf_doc-line then do:
            find first bf_trn-doc where bf_trn-doc.doc-code = bf_doc-line.doc-code no-lock.
            assign
              parroad-tax = bf_doc-line.road-tax
              parexcise   = bf_doc-line.excise
            .
            if parslt-type <> 'без':U then do:
              if bf_trn-doc.slt-type <> 'без':U then do:
                assign
                  parslt-pc = bf_doc-line.slt-pc
                .
              end.
            end.
            else do:
              assign
                parslt-pc = 0
              .
            end.
            if parvat-type <> 'без':U then do:
              if bf_trn-doc.vat-type <> 'без':U then do:
                if v-specif-found = false then do:
                  assign
                    parvat-pc = bf_doc-line.vat-pc
                  .
                end.
              end.
            end.
            else do:
              assign
                parvat-pc = 0
              .
            end.
          end.
        end.
      end.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   pardoc-code
  ,input   parbase-rate
  ,input   parbase-scale
  ,input   parexch-rate
  ,input   parexch-scale
  ,input   parvat-type
  ,input   parslt-type
  ,input   parartic
  ,input   parprod-type
  ,input   parprod-code
  ,input   parprice-cli
  ,input   parcli-base-rate
  ,input   parprice-rubl
  ,input   parvat-pc
  ,input   parslt-pc
  ,input   parroad-tax
  ,input   partransport-rubl
  ,input   parother-rubl
  ,output  varprice-cli
  ,output  varprice-cli-unit-base
  ,output  varprice-road-tax
  ,output  varprice-other-exp
  ,output  varprice-transport-exp
  ,output  varprice-without-abs
  ,output  varprice-slt
  ,output  varprice-no-slt
  ,output  varprice-vat
  ,output  varprice-no-vat-slt
  ,output  varprice-rubl
  ,output  varprice-road-tax-rubl
  ,output  varprice-other-exp-rubl
  ,output  varprice-transport-exp-rubl
  ,output  varprice-without-abs-rubl
  ,output  varprice-slt-rubl
  ,output  varprice-no-slt-rubl
  ,output  varprice-vat-rubl
  ,output  varprice-no-vat-slt-rubl
  ,output  varprice-base
  ,output  varprice-road-tax-base
  ,output  varprice-other-exp-base
  ,output  varprice-transport-exp-base
  ,output  varprice-without-abs-base
  ,output  varprice-slt-base
  ,output  varprice-no-slt-base
  ,output  varprice-vat-base
  ,output  varprice-no-vat-slt-base
  ) no-error.
    if error-status:error then do:
      return error "Ошибка при пересчете линии документа".
    end.
    assign
      parprice-cli  = varprice-cli
      parprice-rubl = varprice-rubl
      parprice-base = varprice-base
    .
  end.
end procedure.
define new global shared variable g#libtfarh as handle no-undo .
define variable vss-include-info9 as character no-undo format "x(65)":U initial "@(#)$Workfile$ $Revision$":U.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure valid-ren-art-tbl-list :
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-workfile )
  on endkey undo, return error substitute( "&1. endkey", vss-workfile )
  :
    define variable v-std-list        as character no-undo .
    define variable v-ignore-list     as character no-undo .
    define variable v-special-list    as character no-undo .
    assign
      v-std-list     = "cli-gds,cli-gds-attr,cli-art,cli-art-attr,contract-specif,c-contract-specif,doc-line,c-doc-line,fbr-line,c-fbr-line,fbr-recipe,fbr-recipe-gds,fbr-pln-line,c-fbr-pln-line,gds-dtl,c-gds-dtl,gds-dtl-attr,c-gds-dtl-attr,gds-obj,inv-line,inv-line-attr,c-inv-line,ot-supp-line,ot-supp-line-attr,ot-line-attr,ord-line,c-ord-line,ord-line-rcv,ord-dtl,c-ord-dtl,ord-dtl-attr,ord-dtl-rcv,ord-dtl-cons,ord-gds-cons,prt-obj,prt-obj-attr,parts,c-parts,parts-supp,parts-supp-attr,price-list,c-price-list,price-doc-forming-gds,c-price-doc-forming-gds,price-doc-forming-gds-qnty,c-price-doc-forming-gds-qnty,price-doc-forming-gds-sum,c-price-doc-forming-gds-sum,price-doc-forming-gds-tnv,c-price-doc-forming-gds-tnv,recipe,recipe-gds,c-recipe,c-recipe-gds,c-recipe-hist,stk-supp-line,stk-supp-line-attr,stk-line-attr,tmp-sale-dtl,tmp-sale-dtl-attr,tmp-sale-gds,tmp-sale-gds-attr":U
      v-ignore-list  = "c-goods,c-order-line":U
      v-special-list = "goods,ot-line,stk-line,order-line":U
    .
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
    define variable v-ind         as integer   no-undo .
    define variable v-num-entries as integer   no-undo .
    define variable v-inform      as character no-undo .
    define variable bh_tbl-name   as handle    no-undo .
    define variable v-tbl-not-idx as character no-undo .
    define variable v-idx-avail   as logical   no-undo .
    define variable new-tbl-list  as character no-undo .
    define variable old-tbl-list  as character no-undo .
    define variable old-tbl-avail as logical   no-undo .
    define variable v-double-tbl  as character no-undo .
    define variable v-tbl-name    as character no-undo .
    define variable v-msg         as character no-undo .
    assign
      v-msg         = "":U
      v-tbl-not-idx = "":U
      new-tbl-list  = "":U
    .
    for each ub._Field no-lock
      where ub._Field._Field-Name = 'artic':U
    ,first ub._File of ub._Field
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      if  lookup( ub._File._File-Name, v-std-list     ) = 0
      and lookup( ub._File._File-Name, v-ignore-list  ) = 0
      and lookup( ub._File._File-Name, v-special-list ) = 0
      then do:
        assign
          new-tbl-list = new-tbl-list + chr(10) + ub._File._File-Name
        .
      end.
      if lookup( ub._File._File-Name, v-std-list ) <> 0
        or lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0
      then do:
        create buffer bh_tbl-name for table substitute( "ub.&1":U, ub._File._File-Name ) .
        assign
          v-idx-avail = false
          v-inform    = bh_tbl-name:index-information(1)
          v-ind       = 2
        .
        block_chk-idx:
        do while v-inform <> ?
        on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
        :
          if v-inform <> ?
              and lookup( entry( 5, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
              and lookup( entry( 7, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
              and lookup( entry( 9, v-inform, ",":U ), "artic,prod-type,prod-code":U ) > 0
          then do:
            assign
              v-idx-avail = true
            .
            leave block_chk-idx.
          end.
          assign
            v-inform = bh_tbl-name:index-information( v-ind )
            v-ind    = v-ind + 1
          .
        end.
        if v-idx-avail = false then do:
          if lookup( ub._File._File-Name, new-tbl-list, chr(10) ) <> 0 then do:
            assign
              new-tbl-list = new-tbl-list + " (индекса нет)"
            .
          end.
          else do:
            assign
              v-tbl-not-idx = v-tbl-not-idx + chr(10) + ub._File._File-Name
            .
          end.
        end.
        delete object bh_tbl-name.
      end.
    end.
    assign
      old-tbl-list  = "":U
      v-double-tbl  = "":U
      v-num-entries = num-entries( v-std-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name    = entry( v-ind, v-std-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'artic':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-type"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-code"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > v-ind
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-ignore-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-ignore-list )
        old-tbl-avail = false
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if not available ub._File then do:
        assign
          old-tbl-avail = true
        .
      end.
      else do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'artic':U
          no-error .
        if not available ub._Field then do:
          assign
            old-tbl-avail = true
          .
        end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-type"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
          find first ub._Field no-lock
            where ub._Field._File-recid = recid( ub._File )
              and ub._Field._Field-Name = "prod-code"
            no-error .
          if not available ub._Field then do:
            assign
              old-tbl-avail = true
            .
          end.
      end.
      if old-tbl-avail = true then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > v-ind
           or lookup( v-tbl-name, v-special-list ) > 0
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    assign
      v-num-entries = num-entries( v-special-list )
    .
    do v-ind = 1 to v-num-entries
    on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
    :
      assign
        v-tbl-name = entry( v-ind, v-special-list )
      .
      find first ub._File no-lock
        where ub._File._File-Name = v-tbl-name
        no-error .
      if available ub._File then do:
        find first ub._Field no-lock
          where ub._Field._File-recid = recid( ub._File )
            and ub._Field._Field-Name = 'artic':U
          no-error .
      end.
      if not available ub._File
        or ( available ub._File
             and not available ub._Field
           )
      then do:
        assign
          old-tbl-list = old-tbl-list + chr(10) + v-tbl-name
        .
      end.
      if ( lookup( v-tbl-name, v-std-list ) > 0
           or lookup( v-tbl-name, v-ignore-list ) > 0
           or lookup( v-tbl-name, v-special-list ) > v-ind
         )
        and lookup( v-tbl-name, v-double-tbl, chr(10) ) = 0
      then do:
        assign
          v-double-tbl = v-double-tbl + chr(10) + v-tbl-name
        .
      end.
    end.
    if v-tbl-not-idx <> "" then do:
      assign
        v-msg = v-msg + substitute( "Таблицы не имеют индекса с полями &3 на первом месте и нет спецобработки: &2&1&1", chr(10), v-tbl-not-idx, 'artic, prod-type, prod-code':U )
      .
    end.
    if new-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "Нет обработки таблиц: &2&1&1", chr(10), new-tbl-list )
      .
    end.
    if v-double-tbl <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть задублированные таблицы: &2&1&1", chr(10), v-double-tbl )
      .
    end.
    if old-tbl-list <> "":U then do:
      assign
        v-msg = v-msg + substitute( "В списках есть несуществующие таблицы или таблицы в которых отсутствуют переименовываемые поля: &2&1&1", chr(10), old-tbl-list )
      .
    end.
    if v-msg <> "":U then do:
      return error substitute( "Утилита переименования &3 не корректна.&1&1&2", chr(10), v-msg, 'artic, prod-type, prod-code':U ) .
    end.
  end.
end procedure.
procedure check-use-artic :
  define input  parameter p-tbl-name  as   character                      no-undo .
  define input  parameter p-artic     like ub.goods.artic     no-undo .
  define input  parameter p-prod-type like ub.goods.prod-type no-undo .
  define input  parameter p-prod-code like ub.goods.prod-code no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info9, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop",   vss-include-info9 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info9 )
  :
    define buffer buf_goods for ub.goods .
    if lookup( p-tbl-name, "c-goods,c-order-line":U ) = 0 then do:
      find first buf_goods no-lock
        where buf_goods.artic     = p-artic
          and buf_goods.prod-type = p-prod-type
          and buf_goods.prod-code = p-prod-code
        no-error .
      if not available buf_goods then do:
        return error substitute( "&1 (check-use-artic). Не найден товар с артикулом &2 и производителем &3 &4", vss-include-info9, p-artic, p-prod-type, p-prod-code ) .
      end.
      if buf_goods.stts = integer('51':U) then do:
        return error substitute( "&1 (check-use-artic). Нельзя использовать товар с артикулом &2 и производителем &3 &4&5"
                                + "Выполняется переименование артикула и(или) производителя"
                                ,vss-include-info9
                                ,p-artic
                                ,p-prod-type
                                ,p-prod-code
                                ,chr(10)
                              ) .
      end.
    end.
    return .
  end.
end procedure.
  function valid-density returns logical ( input p-density as decimal, input p-unit-base-cli-eq as logical ) :
    define variable v-answ as logical no-undo .
    if ( p-unit-base-cli-eq = true
         and p-density = 1.0
       )
      or ( p-unit-base-cli-eq = false
           and p-density <> ?
           and p-density > 0.0
           and p-density < 1.0
         )
    then do:
      assign
        v-answ = true
      .
    end.
    else do:
      assign
        v-answ = false
      .
    end.
    return v-answ.
  end function.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var objSrv as class ibs.th.gbl.sys.objsrv no-undo.
run gbl/getobjsrvhndl.p (input-output ObjSrv).
define variable g-varr-b as character no-undo.
if valid-handle (g#lib-trn)
and g#lib-trn <> this-procedure :handle
and g#lib-trn :get-signature('lib-trn_acc-cost':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с документами" skip
    g#lib-trn skip
    g#lib-trn :type skip
    g#lib-trn :file-name skip
    valid-handle(g#lib-trn) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-trn = this-procedure :handle
  .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output g-varr-b
  ) no-error .
  if error-status :error then do:
    return error "Ошибка при определении валюты продажи.".
  end.
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-trn", g#lib-trn).
  delete object gbl-hndllibObj.
end.
on delete of this-procedure do:
  assign
    g#lib-trn = ?
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-trn", g#lib-trn).
  delete object gbl-hndllibObj.
end.
define stream str-err.
procedure lib-trn_acc-cost:
define input  parameter parobj-type                      like ub.doc-line.obj-type      no-undo.
define input  parameter parobj-code                      like ub.doc-line.obj-code      no-undo.
define input  parameter pardoc-code                      like ub.doc-line.doc-code      no-undo.
define input  parameter parartic                         like ub.doc-line.artic         no-undo.
define input  parameter parprod-type                     like ub.doc-line.prod-type     no-undo.
define input  parameter parprod-code                     like ub.doc-line.prod-code     no-undo.
define input  parameter parcli-qnty                      like ub.doc-line.cli-qnty      no-undo.
define input  parameter pardoc-qnty                      like ub.doc-line.doc-qnty      no-undo.
define input  parameter parfact-qnty                     like ub.doc-line.fact-qnty     no-undo.
define input  parameter parprice-base                    like ub.doc-line.price-base    no-undo.
define input  parameter parprice-rubl                    like ub.doc-line.price-rubl    no-undo.
define input  parameter parmode                          as   character                 no-undo.
define output parameter partotal-doc-line_tot-ov         like ub.trn-doc.tot-ov         no-undo.
define output parameter partotal-doc-line_fact-rubl      like ub.trn-doc.fact-rubl      no-undo.
define output parameter partotal-doc-line_fact-base      like ub.trn-doc.fact-base      no-undo.
define output parameter partotal-doc-line_fact-qnty      like ub.trn-doc.fact-qnty      no-undo.
define output parameter partotal-doc-line_doc-qnty       like ub.trn-doc.doc-qnty       no-undo.
define output parameter partotal-doc-line_cli-qnty       like ub.trn-doc.cli-qnty       no-undo.
define variable vartotal-parts_fact-base like ub.parts.price-base no-undo.
define variable vartotal-parts_fact-rubl like ub.parts.price-rubl no-undo.
define variable vartotal-parts_fact-qnty like ub.parts.fact-qnty  no-undo.
define variable rec-inv-lin              as   recid               no-undo.
define variable varfact-qnty-kg          as   decimal             no-undo.
define variable varis-petrolium as logical no-undo.
define variable varis-pieces    as logical no-undo.
define buffer inv-line-ch for ub.inv-line.
define buffer gds-dtl-ch  for ub.gds-dtl.
define buffer doc-line-ch for ub.doc-line.
define buffer parts-ch    for ub.parts.
define buffer trn-doc-ch  for ub.trn-doc.
do on error undo, return error return-value :
  find first trn-doc-ch  where trn-doc-ch.doc-code = pardoc-code.
  if trn-doc-ch.doc-type <> 'инв':U then do:
    assign
      partotal-doc-line_fact-base = parfact-qnty * parprice-base
      partotal-doc-line_fact-rubl = parfact-qnty * parprice-rubl
    .
  end.
  else do:
    assign
      vartotal-parts_fact-base = 0
      vartotal-parts_fact-rubl = 0
      vartotal-parts_fact-qnty = 0
    .
    for each parts-ch
      where parts-ch.obj-type  = parobj-type
        and parts-ch.obj-code  = parobj-code
        and parts-ch.artic     = parartic
        and parts-ch.prod-type = parprod-type
        and parts-ch.prod-code = parprod-code
        and parts-ch.out-code  = pardoc-code
    :
      assign
        vartotal-parts_fact-base  = vartotal-parts_fact-base
                                    + parts-ch.fact-qnty * parts-ch.price-base
        vartotal-parts_fact-rubl  = vartotal-parts_fact-rubl
                                    + parts-ch.fact-qnty * parts-ch.price-rubl
        vartotal-parts_fact-qnty  = vartotal-parts_fact-qnty
                                    + parts-ch.fact-qnty
      .
    end.
    assign
      partotal-doc-line_fact-base = vartotal-parts_fact-base
      partotal-doc-line_fact-rubl = vartotal-parts_fact-rubl
    .
  end.
  assign
    partotal-doc-line_fact-qnty = parfact-qnty
    partotal-doc-line_doc-qnty  = pardoc-qnty
    partotal-doc-line_cli-qnty  = parcli-qnty
  .
  ASSIGN partotal-doc-line_tot-ov = 0.
  for each gds-dtl-ch where gds-dtl-ch.doc-code  = pardoc-code  and
                            gds-dtl-ch.artic     = parartic     and
                            gds-dtl-ch.prod-type = parprod-type and
                            gds-dtl-ch.prod-code = parprod-code no-lock :
     if g-varr-b = "rubl":U then do:
      assign
       partotal-doc-line_tot-ov = partotal-doc-line_tot-ov
                                + (gds-dtl-ch.cur-base - gds-dtl-ch.price-rubl) * gds-dtl-ch.fact-qnty.
    end.
    else do:
      assign
       partotal-doc-line_tot-ov = partotal-doc-line_tot-ov
                                + (gds-dtl-ch.cur-base - gds-dtl-ch.price-base) * gds-dtl-ch.fact-qnty.
    end.
  end.
  find first doc-line-ch no-lock where
             doc-line-ch.doc-code  = pardoc-code  and
             doc-line-ch.artic     = parartic     and
             doc-line-ch.prod-type = parprod-type and
             doc-line-ch.prod-code = parprod-code .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input doc-line-ch.artic
  ,  input doc-line-ch.prod-type
  ,  input doc-line-ch.prod-code
  , output varis-petrolium
  , output varis-pieces
  ) no-error.
  if varis-petrolium and
     not varis-pieces then do:
    find first inv-line-ch no-lock where
               inv-line-ch.doc-code  = pardoc-code  and
               inv-line-ch.artic     = parartic     and
               inv-line-ch.prod-type = parprod-type and
               inv-line-ch.prod-code = parprod-code no-error.
    if available inv-line-ch then do:
      assign
        varfact-qnty-kg = inv-line-ch.wast-cli-qnty.
    end.
    else do:
      assign
        varfact-qnty-kg = ?.
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_chkinvln in g#lib-trn3 (  input  pardoc-code ,
                        input  parartic ,
                        input  parprod-type ,
                        input  parprod-code ,
                        input  ? ,
                        input  ? ,
                        input  ? ,
                        input  ? ,
                        input  varfact-qnty-kg ,
                        input doc-line-ch.fact-density ,
                       output rec-inv-lin ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
end.
end procedure.
procedure lib-trn_ass-cost:
define input parameter parrecid-doc              as recid                       no-undo.
define input parameter parinc_tot-ovnew          like ub.trn-doc.tot-ov         no-undo.
define input parameter parinc_fact-rublnew       like ub.trn-doc.fact-rubl      no-undo.
define input parameter parinc_fact-basenew       like ub.trn-doc.fact-base      no-undo.
define input parameter parinc_fact-qntynew       like ub.trn-doc.fact-qnty      no-undo.
define input parameter parinc_doc-qntynew        like ub.trn-doc.doc-qnty       no-undo.
define input parameter parinc_cli-qntynew        like ub.trn-doc.cli-qnty       no-undo.
define input parameter parinc_tot-ovold          like ub.trn-doc.tot-ov         no-undo.
define input parameter parinc_fact-rublold       like ub.trn-doc.fact-rubl      no-undo.
define input parameter parinc_fact-baseold       like ub.trn-doc.fact-base      no-undo.
define input parameter parinc_fact-qntyold       like ub.trn-doc.fact-qnty      no-undo.
define input parameter parinc_doc-qntyold        like ub.trn-doc.doc-qnty       no-undo.
define input parameter parinc_cli-qntyold        like ub.trn-doc.cli-qnty       no-undo.
define buffer ass_trn-doc for ub.trn-doc.
do on error undo, return error return-value :
  find first ass_trn-doc where recid(ass_trn-doc) = parrecid-doc.
  assign
    ass_trn-doc.fact-qnty = ass_trn-doc.fact-qnty + parinc_fact-qntynew - parinc_fact-qntyold
    ass_trn-doc.cli-qnty  = ass_trn-doc.cli-qnty  + parinc_cli-qntynew  - parinc_cli-qntyold
    ass_trn-doc.fact-base = ass_trn-doc.fact-base + parinc_fact-basenew - parinc_fact-baseold
    ass_trn-doc.fact-rubl = ass_trn-doc.fact-rubl + parinc_fact-rublnew - parinc_fact-rublold
    ass_trn-doc.tot-ov    = ass_trn-doc.tot-ov    + parinc_tot-ovnew    - parinc_tot-ovold.
  if ass_trn-doc.doc-type <> 'инв':U then do:
    assign
    ass_trn-doc.doc-qnty  = ass_trn-doc.doc-qnty  + parinc_doc-qntynew  - parinc_doc-qntyold.
  end.
end.
end procedure.
procedure lib-trn_calc-in:
define input parameter parparentproc AS WIDGET-HANDLE NO-UNDO.
define input parameter parrec-doc as recid  no-undo.
define input parameter parhandle  as handle no-undo.
define variable varcount   as integer   no-undo.
define variable vartime    as integer   no-undo.
define variable varmessage as character no-undo.
define buffer   rc_trn-doc  for ub.trn-doc.
define buffer   d-l-b       for ub.doc-line.
do on error undo, return error return-value :
assign
  vartime = time.
find first rc_trn-doc where recid(rc_trn-doc) = parrec-doc.
assign
  rc_trn-doc.VAT-rubl   = 0
  rc_trn-doc.VAT-base   = 0
  rc_trn-doc.SLT-rubl   = 0
  rc_trn-doc.SLT-base   = 0
  rc_trn-doc.doc-qnty   = 0
  rc_trn-doc.fact-qnty  = 0
  rc_trn-doc.tot-calc   = 0
  rc_trn-doc.cli-qnty   = 0
  rc_trn-doc.tot-doc    = 0
  rc_trn-doc.tot-fact   = 0
  rc_trn-doc.tot-sale   = 0
  rc_trn-doc.tot-rubl   = 0
  rc_trn-doc.fact-base  = 0
  rc_trn-doc.fact-rubl  = 0
  rc_trn-doc.tot-lines  = 0
  rc_trn-doc.tot-ov     = 0
  rc_trn-doc.road-tax   = 0
  .
if rc_trn-doc.status_ = 'факт':U then do:
  assign
    rc_trn-doc.tot-other  = 0
    rc_trn-doc.tot-transp = 0.
end.
assign
  varcount = 0.
for each d-l-b where d-l-b.doc-code = rc_trn-doc.doc-code on error undo, return error return-value :
  run waitfram-join in parhandle (substitute ("Пересчет шапки документа &1.", rc_trn-doc.doc-code),
                                  substitute ("Товар &1 &2 &3. ", d-l-b.artic, d-l-b.prod-type, d-l-b.prod-code),
                                  substitute (" Всего обработано строк: &1", varcount) +
                                  substitute (" Время: &1.", string(time - vartime, "hh:mm:ss")),
                                  output varmessage
                                  ) no-error.
  run waitfram-show in parhandle (varmessage) no-error.
  assign
    varcount = varcount + 1.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcintrn in g#lib-trn
  (
   input parparentproc
  ,input recid(d-l-b)
  ,input d-l-b.doc-code
  ,input d-l-b.artic
  ,input d-l-b.prod-type
  ,input d-l-b.prod-code
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 'create':U
  ,input '':U
  ) .
end.
end.
end procedure.
procedure lib-trn_calc-inv:
define input parameter parrec-doc as recid  no-undo.
define input parameter parhandle  as handle no-undo.
define buffer fc_trn-doc  for ub.trn-doc.
define buffer fc_doc-line for ub.doc-line.
define variable vartot-doc        like ub.trn-doc.tot-doc  no-undo.
define variable vartot-rubl       like ub.trn-doc.tot-rubl no-undo.
define variable vartotal-tot-doc  like ub.trn-doc.tot-doc  no-undo.
define variable vartotal-tot-rubl like ub.trn-doc.tot-rubl no-undo.
define variable varcount   as integer   no-undo.
define variable vartime    as integer   no-undo.
define variable varmessage as character no-undo.
define variable vartotal-doc-qnty as decimal   no-undo .
do transaction on error undo, return error return-value :
assign
  vartime  = time
  varcount = 0
  vartotal-doc-qnty = 0 .
find first fc_trn-doc where recid(fc_trn-doc) = parrec-doc.
for each fc_doc-line
  where fc_doc-line.doc-code = fc_trn-doc.doc-code
on error undo, return error
:
  run waitfram-join in parhandle (substitute ("Пересчет шапки документа &1.", fc_trn-doc.doc-code),
                                  substitute ("Товар &1 &2 &3. ", fc_doc-line.artic, fc_doc-line.prod-type, fc_doc-line.prod-code),
                                  substitute (" Всего обработано строк: &1", varcount) +
                                  substitute (" Время: &1.", string(time - vartime, "hh:mm:ss")),
                                  output varmessage
                                  ) no-error.
  run waitfram-show in parhandle (varmessage) no-error.
  assign
    varcount = varcount + 1.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clclninv in g#lib-trn
(
 input  recid(fc_doc-line)
,input  yes
,input  '':U
,output vartot-doc
,output vartot-rubl
)
no-error.
  if error-status :error then do:
     return error return-value.
  end.
  assign
    vartotal-doc-qnty   =  vartotal-doc-qnty + fc_doc-line.doc-qnty - fc_doc-line.fact-qnty
    vartotal-tot-doc    =  vartotal-tot-doc  + vartot-doc
    vartotal-tot-rubl   =  vartotal-tot-rubl + vartot-rubl
  .
end.
fc_trn-doc.doc-qnty = vartotal-doc-qnty .
if g-varr-b = "rubl":u then do:
  assign
    fc_trn-doc.tot-rubl = vartotal-tot-rubl
    fc_trn-doc.tot-doc  = fc_trn-doc.tot-rubl / fc_trn-doc.base-rate * fc_trn-doc.base-scale
 .
end.
else do:
  assign
    fc_trn-doc.tot-doc  = vartotal-tot-doc
    fc_trn-doc.tot-rubl = fc_trn-doc.tot-doc * fc_trn-doc.base-rate / fc_trn-doc.base-scale
 .
end.
run str/calc-hd.p (INPUT fc_trn-doc.doc-code) no-error.
    if error-status :error then do:
      return error return-value.
    end.
end.
end procedure.
procedure lib-trn_clclninv:
define input  parameter parrec-line            as   recid               no-undo.
define input  parameter parstate-price         as   logical             no-undo.
define input  parameter parmode                as   character           no-undo.
define output parameter partot-doc             like ub.trn-doc.tot-doc            no-undo.
define output parameter partot-rubl            like ub.trn-doc.tot-rubl           no-undo.
define buffer cdl_doc-line for ub.doc-line.
define buffer cdl_goods    for ub.goods.
define buffer cdl_inv-line for ub.inv-line.
define buffer cdl_gds-dtl  for ub.gds-dtl.
define buffer cdl_trn-doc  for ub.trn-doc.
define variable varsum-sale like ub.gds-dtl.price-rubl no-undo.
define variable rec-inv-lin as   recid                 no-undo.
define variable varis-petrolium as logical no-undo.
define variable varis-pieces    as logical no-undo.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
do on error undo, return error return-value :
find first cdl_doc-line where recid(cdl_doc-line)  = parrec-line.
find first cdl_inv-line
  where cdl_inv-line.doc-code  = cdl_doc-line.doc-code
    and cdl_inv-line.artic     = cdl_doc-line.artic
    and cdl_inv-line.prod-type = cdl_doc-line.prod-type
    and cdl_inv-line.prod-code = cdl_doc-line.prod-code
  no-error.
find first cdl_trn-doc  where cdl_trn-doc.doc-code = cdl_doc-line.doc-code no-error.
if not available cdl_trn-doc then do:
  return error substitute ("Не найден документ с номером &1.", cdl_doc-line.doc-code).
end.
find first cdl_goods where cdl_goods.artic     = cdl_doc-line.artic and
                           cdl_goods.prod-type = cdl_doc-line.prod-type and
                           cdl_goods.prod-code = cdl_doc-line.prod-code no-lock.
for each cdl_gds-dtl where cdl_gds-dtl.doc-code  = cdl_doc-line.doc-code
                       and cdl_gds-dtl.prod-code = cdl_doc-line.prod-code
                       and cdl_gds-dtl.prod-type = cdl_doc-line.prod-type
                       and cdl_gds-dtl.artic     = cdl_doc-line.artic on error undo, return error :
   if parstate-price then do:
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
 gp-fact-order = cdl_trn-doc.fact-order .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  cdl_goods.gds-code
  ,input  cdl_gds-dtl.prt-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  cdl_gds-dtl.obj-type
  ,input  cdl_gds-dtl.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  cdl_gds-dtl.obj-type
  ,input  cdl_gds-dtl.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  return error.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
     if gp-price-sale <> ? then do:
       if g-varr-b = "rubl":u then do:
         assign
           cdl_doc-line.excise      = gp-excise
           cdl_doc-line.road-tax    = gp-road-tax
           cdl_gds-dtl.price-rubl   = gp-price-sale-parts.
       end.
       else do:
         assign
           cdl_doc-line.excise      = gp-excise
           cdl_doc-line.road-tax    = gp-road-tax
           cdl_gds-dtl.price-base   = gp-price-sale-parts.
       end.
     end.
     else do:
       if g-varr-b = "rubl":u then do:
         assign
           cdl_gds-dtl.price-rubl = 0.
       end.
       else do:
         assign
           cdl_gds-dtl.price-base = 0.
       end.
     end.
    if g-varr-b = "base":u then do:
      assign
        cdl_gds-dtl.price-rubl = cdl_gds-dtl.price-base * cdl_trn-doc.base-rate / cdl_trn-doc.base-scale.
    end.
    else do:
      assign
        cdl_gds-dtl.price-base = cdl_gds-dtl.price-rubl / cdl_trn-doc.base-rate * cdl_trn-doc.base-scale.
    end.
   end.
   if g-varr-b = "base":u then do:
     assign varsum-sale = varsum-sale + cdl_gds-dtl.price-base * cdl_gds-dtl.doc-qnty.
   end.
   else do:
     assign varsum-sale = varsum-sale + cdl_gds-dtl.price-rubl * cdl_gds-dtl.doc-qnty.
   end.
end.
  if g-varr-b = "base":u then do:
    assign
      partot-doc   = varsum-sale
      partot-rubl  = partot-doc * cdl_trn-doc.base-rate / cdl_trn-doc.base-scale
    .
  end.
  else do:
    assign
      partot-rubl  = varsum-sale
      partot-doc   = partot-rubl / cdl_trn-doc.base-rate * cdl_trn-doc.base-scale
   .
  end.
  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input cdl_doc-line.artic
  ,  input cdl_doc-line.prod-type
  ,  input cdl_doc-line.prod-code
  , output varis-petrolium
  , output varis-pieces
  ) no-error.
  if varis-petrolium
    and not varis-pieces
  then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_chkinvln in g#lib-trn3 (  input  cdl_trn-doc.doc-code ,
                        input  cdl_doc-line.artic ,
                        input  cdl_doc-line.prod-type ,
                        input  cdl_doc-line.prod-code ,
                        input  ? ,
                        input  ? ,
                        input  ? ,
                        input  ? ,
                        input  (if available cdl_inv-line then cdl_inv-line.wast-cli-qnty else ?) ,
                        input cdl_doc-line.doc-density ,
                       output rec-inv-lin ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
end.
end procedure.
procedure lib-trn_chpsltpc :
define input  parameter parinternal     like ub.trn-doc.internal     no-undo.
define input  parameter pardoc-type     like ub.trn-doc.doc-type     no-undo.
define input  parameter parpay-code     like ub.trn-doc.pay-code     no-undo.
define input  parameter parcash-pay     as   integer                 no-undo.
define input  parameter parslt-type     like ub.parts.slt-type       no-undo.
define input  parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define output parameter parslt-yes      as   logical                 no-undo.
if not parinternal
   and (    ( parpay-code = parcash-pay and can-do ('рас,возврат':U, pardoc-type) )
         or ( pardoc-type = 'при':U   and parslt-type <> 'без':U           )
         or parext-doc-type = 'ap':U
       )
then do:
  assign
    parslt-yes = yes.
end.
else do:
  assign
    parslt-yes = no.
end.
end procedure.
procedure lib-trn_st-sltpc :
do
on error undo, return error
:
def input  parameter p-goods-recid    as recid                    no-undo.
def input  parameter p-trn-doc-recid  as recid                    no-undo.
def input  parameter p-cash-pay       as integer                  no-undo.
def output parameter p-st-sltpc-slt   like ub.doc-line.SLT-pc     no-undo.
def var v-host-code     like ub.sysconf.host-code  no-undo.
define variable varslt-yes as logical no-undo.
def buffer buf_st-sltpc_goods   for ub.goods.
def buffer buf_st-sltpc_trn-doc for ub.trn-doc.
find first buf_st-sltpc_goods   where recid(buf_st-sltpc_goods)     = p-goods-recid.
find first buf_st-sltpc_trn-doc where recid(buf_st-sltpc_trn-doc)   = p-trn-doc-recid.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_chpsltpc in g#lib-trn
(
 input  buf_st-sltpc_trn-doc.internal
,input  buf_st-sltpc_trn-doc.doc-type
,input  buf_st-sltpc_trn-doc.pay-code
,input  p-cash-pay
,input  buf_st-sltpc_trn-doc.slt-type
,input  buf_st-sltpc_trn-doc.ext-doc-type
,output varslt-yes
)
no-error.
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при проверке установки налога с продаж " skip
    " для товара " buf_st-sltpc_goods.artic buf_st-sltpc_goods.prod-type buf_st-sltpc_goods.prod-code skip
    " в документе " buf_st-sltpc_trn-doc.doc-code skip
    return-value skip
    trim(error-status :get-message(1))
    trim(error-status :get-message(2))
    trim(error-status :get-message(3))
    trim(error-status :get-message(4))
    trim(error-status :get-message(5)) skip
    view-as alert-box error.
  undo, return error .
end.
if varslt-yes
then do:
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_st-sltpc_trn-doc.obj-type
  ,input  buf_st-sltpc_trn-doc.obj-code
  ,output v-host-code
  )  .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_st-sltpc_goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-host-code
  ,input  buf_st-sltpc_trn-doc.obj-type
  ,input  buf_st-sltpc_trn-doc.obj-code
  ,output p-st-sltpc-slt
  ) no-error .
end.
else do:
    assign
        p-st-sltpc-slt      = 0
    .
end.
end.
end procedure.
procedure lib-trn_calc-out :
define input parameter parrec-doc      as recid  no-undo.
define input parameter parrecalc-price as logical no-undo.
define input parameter parhandle       as handle  no-undo.
define buffer cd_trn-doc  for ub.trn-doc.
define buffer cd_sysconf  for ub.sysconf.
define buffer cd_doc-line for ub.doc-line.
define buffer cd_goods    for ub.goods.
define buffer p-doc-line  for ub.doc-line.
define buffer p-goods     for ub.goods.
define variable is-petrolium-out-body                     as logical                 no-undo.
define variable is-pieces-out-body                        as logical                 no-undo.
define variable varagsum-base-doc                         like ub.gds-dtl.price-base no-undo.
define variable varagsum-rubl-doc                         like ub.gds-dtl.price-rubl no-undo.
define variable varagsum-base-fact                        like ub.gds-dtl.price-base no-undo.
define variable varagsum-rubl-fact                        like ub.gds-dtl.price-rubl no-undo.
define variable varagcount                                as integer                 no-undo.
define variable vartotal-agsum-base-doc                   like ub.gds-dtl.price-base no-undo.
define variable vartotal-agsum-rubl-doc                   like ub.gds-dtl.price-rubl no-undo.
define variable vartotal-agsum-base-fact                  like ub.gds-dtl.price-base no-undo.
define variable vartotal-agsum-rubl-fact                  like ub.gds-dtl.price-rubl no-undo.
define variable vartotal-agcount                          as integer                 no-undo.
define variable varroad-tax-fact-base                     like ub.gds-dtl.price-base no-undo.
define variable varexcise-fact-base                       like ub.gds-dtl.price-base no-undo.
define variable varslt-fact-base                          like ub.gds-dtl.price-base no-undo.
define variable varvat-fact-base                          like ub.gds-dtl.price-base no-undo.
define variable varslt-doc-base                           like ub.gds-dtl.price-base no-undo.
define variable varvat-doc-base                           like ub.gds-dtl.price-base no-undo.
define variable varsum-fact-out-dsv-base                  like ub.gds-dtl.price-base no-undo.
define variable varroad-tax-fact-rubl                     like ub.gds-dtl.price-base no-undo.
define variable varexcise-fact-rubl                       like ub.gds-dtl.price-base no-undo.
define variable varslt-fact-rubl                          like ub.gds-dtl.price-base no-undo.
define variable varvat-fact-rubl                          like ub.gds-dtl.price-base no-undo.
define variable varslt-doc-rubl                           like ub.gds-dtl.price-base no-undo.
define variable varvat-doc-rubl                           like ub.gds-dtl.price-base no-undo.
define variable varsum-fact-out-dsv-rubl                  like ub.gds-dtl.price-base no-undo.
define variable varsum-fact-out-dsc-base                  like ub.gds-dtl.price-base no-undo.
define variable varsum-fact-out-dsc-rubl                  like ub.gds-dtl.price-base no-undo.
define variable varsum-fact-cur                           like ub.gds-dtl.price-base no-undo.
define variable varov-fact-base                           like ub.gds-dtl.price-base no-undo.
define variable varov-vat-fact-base                       like ub.gds-dtl.price-base no-undo.
define variable varsum-doc-cur                            like ub.gds-dtl.price-base no-undo.
define variable varov-doc-base                            like ub.gds-dtl.price-base no-undo.
define variable varov-vat-doc-base                        like ub.gds-dtl.price-base no-undo.
define variable varsum-doc-base                           like ub.gds-dtl.price-base no-undo.
define variable varsum-doc-rubl                           like ub.gds-dtl.price-base no-undo.
define variable varroad-tax-fact                          like ub.gds-dtl.price-base no-undo.
define variable varexcise-fact                            like ub.gds-dtl.price-base no-undo.
define variable varroad-tax-doc                           like ub.gds-dtl.price-base no-undo.
define variable varexcise-doc                             like ub.gds-dtl.price-base no-undo.
define variable vardiscnt-base-doc                        like ub.gds-dtl.price-base no-undo.
define variable vardiscnt-rubl-doc                        like ub.gds-dtl.price-base no-undo.
define variable vardiscnt-base-fact                       like ub.gds-dtl.price-base no-undo.
define variable vardiscnt-rubl-fact                       like ub.gds-dtl.price-base no-undo.
define variable vartotal-road-tax-fact-base               like ub.gds-dtl.price-base no-undo.
define variable vartotal-excise-fact-base                 like ub.gds-dtl.price-base no-undo.
define variable vartotal-slt-fact-base                    like ub.gds-dtl.price-base no-undo.
define variable vartotal-vat-fact-base                    like ub.gds-dtl.price-base no-undo.
define variable vartotal-slt-doc-base                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-vat-doc-base                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-sum-fact-out-dsv-base            like ub.gds-dtl.price-base no-undo.
define variable vartotal-road-tax-fact-rubl               like ub.gds-dtl.price-base no-undo.
define variable vartotal-excise-fact-rubl                 like ub.gds-dtl.price-base no-undo.
define variable vartotal-slt-fact-rubl                    like ub.gds-dtl.price-base no-undo.
define variable vartotal-vat-fact-rubl                    like ub.gds-dtl.price-base no-undo.
define variable vartotal-slt-doc-rubl                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-vat-doc-rubl                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-sum-fact-out-dsv-rubl            like ub.gds-dtl.price-base no-undo.
define variable vartotal-sum-fact-out-dsc-base            like ub.gds-dtl.price-base no-undo.
define variable vartotal-sum-fact-out-dsc-rubl            like ub.gds-dtl.price-base no-undo.
define variable vartotal-sum-fact-cur                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-ov-fact-base                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-ov-vat-fact-base                 like ub.gds-dtl.price-base no-undo.
define variable vartotal-sum-doc-cur                      like ub.gds-dtl.price-base no-undo.
define variable vartotal-ov-doc-base                      like ub.gds-dtl.price-base no-undo.
define variable vartotal-ov-vat-doc-base                  like ub.gds-dtl.price-base no-undo.
define variable vartotal-sum-doc-base                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-sum-doc-rubl                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-road-tax-fact                    like ub.gds-dtl.price-base no-undo.
define variable vartotal-excise-fact                      like ub.gds-dtl.price-base no-undo.
define variable vartotal-road-tax-doc                     like ub.gds-dtl.price-base no-undo.
define variable vartotal-excise-doc                       like ub.gds-dtl.price-base no-undo.
define variable vartotal-discnt-base-doc                  like ub.gds-dtl.price-base no-undo.
define variable vartotal-discnt-rubl-doc                  like ub.gds-dtl.price-base no-undo.
define variable vartotal-discnt-base-fact                 like ub.gds-dtl.price-base no-undo.
define variable vartotal-discnt-rubl-fact                 like ub.gds-dtl.price-base no-undo.
define variable vartime                                   as   integer               no-undo.
define variable varcount                                  as   integer               no-undo.
define variable varmessage                                as   character             no-undo.
do on error undo, return error return-value :
assign vartime = time.
find first cd_trn-doc where recid(cd_trn-doc) = parrec-doc.
assign
cd_trn-doc.doc-qnty    = 0
cd_trn-doc.tot-doc     = 0
cd_trn-doc.tot-rubl    = 0
cd_trn-doc.fact-qnty   = 0
cd_trn-doc.tot-fact    = 0
cd_trn-doc.tot-sale    = 0
cd_trn-doc.tot-lines   = 0
cd_trn-doc.tot-cli     = 0
cd_trn-doc.road-tax    = 0
cd_trn-doc.excise      = 0
cd_trn-doc.slt-base    = 0
cd_trn-doc.vat-base    = 0
cd_trn-doc.slt-rubl    = 0
cd_trn-doc.vat-rubl    = 0.
find cd_sysconf where cd_sysconf.host-code = cd_trn-doc.host-code no-lock.
assign varcount = 0.
for each cd_doc-line where cd_doc-line.doc-code = cd_trn-doc.doc-code exclusive:
    find cd_goods where cd_doc-line.prod-code = cd_goods.prod-code
                    and cd_doc-line.prod-type = cd_goods.prod-type
                    and cd_doc-line.artic     = cd_goods.artic no-lock.
  run waitfram-join in parhandle (substitute ("Устанавливаем продажные цены в строках документа &1.", cd_trn-doc.doc-code),
                                  substitute ("Товар &1 &2 &3. ", cd_doc-line.artic, cd_doc-line.prod-type, cd_doc-line.prod-code),
                                  substitute (" Всего обработано строк: &1", varcount) +
                                  substitute (" Время: &1.", string(time - vartime, "hh:mm:ss")),
                                  output varmessage
                                  ) no-error.
  run waitfram-show in parhandle (varmessage) no-error.
  assign
    varcount = varcount + 1.
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_accgdspr in g#lib-calc
(
 input  recid(cd_doc-line)
,input  (if parrecalc-price = yes then yes else no)
,output varagsum-base-doc
,output varagsum-rubl-doc
,output varagsum-base-fact
,output varagsum-rubl-fact
,output varagcount
) .
   if (varagcount) = 0 then delete cd_doc-line.
   assign
   vartotal-agsum-base-doc    = vartotal-agsum-base-doc   + varagsum-base-doc
   vartotal-agsum-rubl-doc    = vartotal-agsum-rubl-doc   + varagsum-rubl-doc
   vartotal-agsum-base-fact   = vartotal-agsum-base-fact  + varagsum-base-fact
   vartotal-agsum-rubl-fact   = vartotal-agsum-rubl-fact  + varagsum-rubl-fact
   vartotal-agcount           = vartotal-agcount          + varagcount       .
END.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcdocpr in g#lib-trn
(
 input  recid(cd_trn-doc)
,input  vartotal-agsum-base-doc
,input  vartotal-agsum-rubl-doc
,input  vartotal-agsum-base-fact
,input  vartotal-agsum-rubl-fact
,input  vartotal-agcount
,input  0
,input  0
,input  0
,input  0
,input  0
  ) no-error.
if error-status :error then do:
  return error return-value.
end.
assign varcount = 0.
for each cd_doc-line where cd_doc-line.doc-code = cd_trn-doc.doc-code on error undo, return error :
  run waitfram-join in parhandle (substitute ("Вычисление и распространение скидок &1.", cd_trn-doc.doc-code),
                                  substitute ("Товар &1 &2 &3. ", cd_doc-line.artic, cd_doc-line.prod-type, cd_doc-line.prod-code),
                                  substitute (" Всего обработано строк: &1", varcount) +
                                  substitute (" Время: &1.", string(time - vartime, "hh:mm:ss")),
                                  output varmessage
                                  ) no-error.
  run waitfram-show in parhandle (varmessage) no-error.
  assign
    varcount = varcount + 1.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_reclcdsc in g#lib-trn3
  (input recid(cd_doc-line)
  ) no-error.
   if error-status :error then do:
      return error return-value.
   end.
end.
if cd_trn-doc.discnt-type <> 'сумма':U then do:
    assign
      cd_trn-doc.tot-calc    = 0
      cd_trn-doc.discnt-rubl = 0
      .
end.
assign varcount = 0.
for each cd_doc-line where cd_doc-line.doc-code = cd_trn-doc.doc-code:
  run waitfram-join in parhandle (substitute ("Вычисление НДС &1.", cd_trn-doc.doc-code),
                                  substitute ("Товар &1 &2 &3. ", cd_doc-line.artic, cd_doc-line.prod-type, cd_doc-line.prod-code),
                                  substitute (" Всего обработано строк: &1", varcount) +
                                  substitute (" Время: &1.", string(time - vartime, "hh:mm:ss")),
                                  output varmessage
                                  ) no-error.
  run waitfram-show in parhandle (varmessage) no-error.
  assign
    varcount = varcount + 1.
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_acsupacc in g#lib-calc
  (
   input  recid(cd_doc-line)
  ,output varroad-tax-fact-base
  ,output varexcise-fact-base
  ,output varslt-fact-base
  ,output varvat-fact-base
  ,output varslt-doc-base
  ,output varvat-doc-base
  ,output varsum-fact-out-dsv-base
  ,output varroad-tax-fact-rubl
  ,output varexcise-fact-rubl
  ,output varslt-fact-rubl
  ,output varvat-fact-rubl
  ,output varslt-doc-rubl
  ,output varvat-doc-rubl
  ,output varsum-fact-out-dsv-rubl
  ,output varsum-fact-out-dsc-base
  ,output varsum-fact-out-dsc-rubl
  ,output varsum-fact-cur
  ,output varov-fact-base
  ,output varov-vat-fact-base
  ,output varsum-doc-cur
  ,output varov-doc-base
  ,output varov-vat-doc-base
  ,output varsum-doc-base
  ,output varsum-doc-rubl
  ,output varroad-tax-fact
  ,output varexcise-fact
  ,output varroad-tax-doc
  ,output varexcise-doc
  ,output vardiscnt-base-doc
  ,output vardiscnt-rubl-doc
  ,output vardiscnt-base-fact
  ,output vardiscnt-rubl-fact
  ) no-error.
 if error-status :error then do:
   return error return-value.
 end.
 assign
   vartotal-road-tax-fact-base              = vartotal-road-tax-fact-base               + varroad-tax-fact-base
   vartotal-excise-fact-base                = vartotal-excise-fact-base                 + varexcise-fact-base
   vartotal-slt-fact-base                   = vartotal-slt-fact-base                    + varslt-fact-base
   vartotal-vat-fact-base                   = vartotal-vat-fact-base                    + varvat-fact-base
   vartotal-slt-doc-base                    = vartotal-slt-doc-base                     + varslt-doc-base
   vartotal-vat-doc-base                    = vartotal-vat-doc-base                     + varvat-doc-base
   vartotal-sum-fact-out-dsv-base           = vartotal-sum-fact-out-dsv-base            + varsum-fact-out-dsv-base
   vartotal-road-tax-fact-rubl              = vartotal-road-tax-fact-rubl               + varroad-tax-fact-rubl
   vartotal-excise-fact-rubl                = vartotal-excise-fact-rubl                 + varexcise-fact-rubl
   vartotal-slt-fact-rubl                   = vartotal-slt-fact-rubl                    + varslt-fact-rubl
   vartotal-vat-fact-rubl                   = vartotal-vat-fact-rubl                    + varvat-fact-rubl
   vartotal-slt-doc-rubl                    = vartotal-slt-doc-rubl                     + varslt-doc-rubl
   vartotal-vat-doc-rubl                    = vartotal-vat-doc-rubl                     + varvat-doc-rubl
   vartotal-sum-fact-out-dsv-rubl           = vartotal-sum-fact-out-dsv-rubl            + varsum-fact-out-dsv-rubl
   vartotal-sum-fact-out-dsc-base           = vartotal-sum-fact-out-dsc-base            + varsum-fact-out-dsc-base
   vartotal-sum-fact-out-dsc-rubl           = vartotal-sum-fact-out-dsc-rubl            + varsum-fact-out-dsc-rubl
   vartotal-sum-fact-cur                    = vartotal-sum-fact-cur                     + varsum-fact-cur
   vartotal-ov-fact-base                    = vartotal-ov-fact-base                     + varov-fact-base
   vartotal-ov-vat-fact-base                = vartotal-ov-vat-fact-base                 + varov-vat-fact-base
   vartotal-sum-doc-cur                     = vartotal-sum-doc-cur                      + varsum-doc-cur
   vartotal-ov-doc-base                     = vartotal-ov-doc-base                      + varov-doc-base
   vartotal-ov-vat-doc-base                 = vartotal-ov-vat-doc-base                  + varov-vat-doc-base
   vartotal-sum-doc-base                    = vartotal-sum-doc-base                     + varsum-doc-base
   vartotal-sum-doc-rubl                    = vartotal-sum-doc-rubl                     + varsum-doc-rubl
   vartotal-road-tax-fact                   = vartotal-road-tax-fact                    + varroad-tax-fact
   vartotal-excise-fact                     = vartotal-excise-fact                      + varexcise-fact
   vartotal-road-tax-doc                    = vartotal-road-tax-doc                     + varroad-tax-doc
   vartotal-excise-doc                      = vartotal-excise-doc                       + varexcise-doc
   vartotal-discnt-base-doc                 = vartotal-discnt-base-doc                  + vardiscnt-base-doc
   vartotal-discnt-rubl-doc                 = vartotal-discnt-rubl-doc                  + vardiscnt-rubl-doc
   vartotal-discnt-base-fact                = vartotal-discnt-base-fact                 + vardiscnt-base-fact
   vartotal-discnt-rubl-fact                = vartotal-discnt-rubl-fact                 + vardiscnt-rubl-fact              .
end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clcpttrn in g#lib-trn
  (
   input recid(cd_trn-doc)
  ,input vartotal-discnt-base-fact
  ,input vartotal-discnt-rubl-fact
  ,input vartotal-road-tax-fact
  ,input vartotal-excise-fact
  ,input vartotal-slt-fact-base
  ,input vartotal-vat-fact-base
  ,input vartotal-slt-fact-rubl
  ,input vartotal-vat-fact-rubl
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ,input 0
  ) no-error.
run str/calc-hd.p (cd_trn-doc.doc-code) no-error.
if error-status :error then do:
   return error return-value.
end.
end.
end procedure.
procedure lib-trn_clcdocpr :
define input parameter parrec-doc               as recid                   no-undo.
define input parameter parargsum-base-doc-new   like ub.gds-dtl.price-base no-undo.
define input parameter parargsum-rubl-doc-new   like ub.gds-dtl.price-rubl no-undo.
define input parameter parargsum-base-fact-new  like ub.gds-dtl.price-base no-undo.
define input parameter parargsum-rubl-fact-new  like ub.gds-dtl.price-rubl no-undo.
define input parameter parargcount-new          as integer                 no-undo.
define input parameter parargsum-base-doc-old   like ub.gds-dtl.price-base no-undo.
define input parameter parargsum-rubl-doc-old   like ub.gds-dtl.price-rubl no-undo.
define input parameter parargsum-base-fact-old  like ub.gds-dtl.price-base no-undo.
define input parameter parargsum-rubl-fact-old  like ub.gds-dtl.price-rubl no-undo.
define input parameter parargcount-old          as integer                 no-undo.
define buffer ct_trn-doc for ub.trn-doc.
do on error undo, return error return-value :
find first ct_trn-doc where recid(ct_trn-doc) = parrec-doc.
assign
    ct_trn-doc.tot-doc   = ct_trn-doc.tot-doc   + parargsum-base-doc-new   - parargsum-base-doc-old
    ct_trn-doc.tot-rubl  = ct_trn-doc.tot-rubl  + parargsum-rubl-doc-new   - parargsum-rubl-doc-old
    ct_trn-doc.tot-fact  = ct_trn-doc.tot-fact  + parargsum-base-fact-new  - parargsum-base-fact-old
    ct_trn-doc.tot-sale  = ct_trn-doc.tot-sale  + parargsum-rubl-fact-new  - parargsum-rubl-fact-old
    ct_trn-doc.tot-lines = ct_trn-doc.tot-lines + parargcount-new          - parargcount-old
    .
if not can-do ('процент,карта,группа,сумма,строка,прайс-лист':U, ct_trn-doc.discnt-type) and
   ct_trn-doc.discnt-type <> 'касс':U              and
   ct_trn-doc.discnt-type <> 'прво':U           and
   ct_trn-doc.internal    =  no                        then
  assign
    ct_trn-doc.discnt-type = 'процент':U
    ct_trn-doc.discnt-pc = 0.
if ct_trn-doc.discnt-type = 'сумма':U then do:
  if ct_trn-doc.print-rubl then do:
    assign
      ct_trn-doc.discnt-pc = ct_trn-doc.discnt-rubl * 100 / ct_trn-doc.tot-rubl
      ct_trn-doc.tot-calc  = ct_trn-doc.discnt-rubl * ct_trn-doc.base-scale / ct_trn-doc.base-rate.
  end.
  else do:
    assign
      ct_trn-doc.discnt-pc   = ct_trn-doc.tot-calc * 100 / ct_trn-doc.tot-doc
      ct_trn-doc.discnt-rubl = ct_trn-doc.tot-calc * ct_trn-doc.base-rate / ct_trn-doc.base-scale.
  end.
if ct_trn-doc.discnt-pc = ? then do:
  assign
    ct_trn-doc.discnt-pc = 0.
end.
end.
end.
end procedure.
procedure lib-trn_clcpttrn:
define input parameter parrec-doc                 as   recid               no-undo.
define input parameter pardiscnt-base-fact-new  like ub.trn-doc.tot-calc no-undo.
define input parameter pardiscnt-rubl-fact-new  like ub.trn-doc.tot-calc no-undo.
define input parameter parroad-tax-fact-new     like ub.trn-doc.tot-calc no-undo.
define input parameter parexcise-fact-new       like ub.trn-doc.tot-calc no-undo.
define input parameter parslt-fact-base-new     like ub.trn-doc.tot-calc no-undo.
define input parameter parvat-fact-base-new     like ub.trn-doc.tot-calc no-undo.
define input parameter parslt-fact-rubl-new     like ub.trn-doc.tot-calc no-undo.
define input parameter parvat-fact-rubl-new     like ub.trn-doc.tot-calc no-undo.
define input parameter pardiscnt-base-fact-old  like ub.trn-doc.tot-calc no-undo.
define input parameter pardiscnt-rubl-fact-old  like ub.trn-doc.tot-calc no-undo.
define input parameter parroad-tax-fact-old     like ub.trn-doc.tot-calc no-undo.
define input parameter parexcise-fact-old       like ub.trn-doc.tot-calc no-undo.
define input parameter parslt-fact-base-old     like ub.trn-doc.tot-calc no-undo.
define input parameter parvat-fact-base-old     like ub.trn-doc.tot-calc no-undo.
define input parameter parslt-fact-rubl-old     like ub.trn-doc.tot-calc no-undo.
define input parameter parvat-fact-rubl-old     like ub.trn-doc.tot-calc no-undo.
define buffer ct_trn-doc for ub.trn-doc.
do on error undo, return error return-value :
find first ct_trn-doc where recid(ct_trn-doc) = parrec-doc.
if ct_trn-doc.discnt-type <> 'сумма':U then do:
    assign
      ct_trn-doc.tot-calc    = ct_trn-doc.tot-calc    + pardiscnt-base-fact-new - pardiscnt-base-fact-old
      ct_trn-doc.discnt-rubl = ct_trn-doc.discnt-rubl + pardiscnt-rubl-fact-new - pardiscnt-rubl-fact-old .
end.
if not can-do ('процент,карта,группа':U, ct_trn-doc.discnt-type) then do:
  assign
    ct_trn-doc.discnt-pc   = ( if ct_trn-doc.print-rubl then ( if ct_trn-doc.tot-sale = 0 then 0 else ct_trn-doc.discnt-rubl * 100 / ct_trn-doc.tot-sale )
                                                        else ( if ct_trn-doc.tot-fact = 0 then 0 else ct_trn-doc.tot-calc    * 100 / ct_trn-doc.tot-fact ) ).
  if ct_trn-doc.discnt-pc = ? then do:
    assign
      ct_trn-doc.discnt-pc = 0.
  end.
end.
assign ct_trn-doc.tot-cli = ct_trn-doc.tot-doc - ct_trn-doc.tot-calc.
ASSIGN
   ct_trn-doc.road-tax = ct_trn-doc.road-tax + parroad-tax-fact-new - parroad-tax-fact-old
   ct_trn-doc.excise   = ct_trn-doc.excise   + parexcise-fact-new   - parexcise-fact-old
   ct_trn-doc.slt-base = ct_trn-doc.slt-base + parslt-fact-base-new - parslt-fact-base-old
   ct_trn-doc.vat-base = ct_trn-doc.vat-base + parvat-fact-base-new - parvat-fact-base-old
   ct_trn-doc.slt-rubl = ct_trn-doc.slt-rubl + parslt-fact-rubl-new - parslt-fact-rubl-old
   ct_trn-doc.vat-rubl = ct_trn-doc.vat-rubl + parvat-fact-rubl-new - parvat-fact-rubl-old
   .
END.
end procedure.
procedure lib-trn_fill-ext-inc:
define input parameter parparentproc    AS WIDGET-HANDLE               NO-UNDO.
define input parameter pardoc-code      like ub.trn-doc.doc-code       no-undo.
define input parameter parartic         like ub.doc-line.artic         no-undo.
define input parameter parprod-type     like ub.doc-line.prod-type     no-undo.
define input parameter parprod-code     like ub.doc-line.prod-code     no-undo.
define input parameter parprice-base    like ub.doc-line.price-base    no-undo.
define input parameter parprice-rubl    like ub.doc-line.price-rubl    no-undo.
define input parameter parcli-base-rate like ub.doc-line.cli-base-rate no-undo.
define input parameter parprice-vat     like ub.doc-line.price-base no-undo.
define input parameter paradd-param     as   character              no-undo.
define buffer ei_trn-doc  for ub.trn-doc.
define buffer ei_gds-dtl  for ub.gds-dtl.
do on error undo, return error return-value :
find first ei_trn-doc where ei_trn-doc.doc-code = pardoc-code.
if ei_trn-doc.doc-type = 'при':U and
   ei_trn-doc.internal = no        then do:
    for each ei_gds-dtl where ei_gds-dtl.doc-code  = ei_trn-doc.doc-code   and
                              ei_gds-dtl.artic     = parartic     and
                              ei_gds-dtl.prod-code = parprod-code and
                              ei_gds-dtl.prod-type = parprod-type :
       assign ei_gds-dtl.price-base = parprice-base
              ei_gds-dtl.price-rubl = parprice-rubl.
    end.
    run trg/partsupd.p
      (input parparentproc
      ,input ei_trn-doc.doc-code
      ,input ei_trn-doc.obj-type
      ,input ei_trn-doc.obj-code
      ,input parartic
      ,input parprod-type
      ,input parprod-code
      ,input true
      ,input paradd-param
      ) no-error.
   if error-status :error then do:
      undo, return error.
   end.
end.
end.
end procedure.
procedure lib-trn_have-vat-slt:
define input  parameter pardoc-code     like ub.trn-doc.doc-code no-undo.
define output parameter parhave-vat-slt as   logical             no-undo.
define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_sysconf for ub.sysconf.
define variable varenvd as character no-undo.
define variable vartype as character no-undo.
do on error undo, return error return-value :
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input pardoc-code ,
                        input 'envd':U ,
                       output varenvd ,
                       output vartype )  .
if varenvd <> "yes":u then do:
  assign
    parhave-vat-slt = yes.
end.
else do:
find first bf_trn-doc where bf_trn-doc.doc-code  = pardoc-code          no-lock.
find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
  if ( bf_trn-doc.ext-doc-type = 'es':U                                               or
       bf_trn-doc.ext-doc-type = 'rs':U                                           or
      (bf_trn-doc.ext-doc-type = 'ee':U     and bf_sysconf.cash-pay = bf_trn-doc.pay-code) or
      (bf_trn-doc.ext-doc-type = 're':U and bf_sysconf.cash-pay = bf_trn-doc.pay-code)
     ) then do:
    assign
      parhave-vat-slt = no.
  end.
  else do:
    assign
      parhave-vat-slt = yes.
  end.
  end.
end.
end procedure.
procedure lib-trn_in-vat:
define input  parameter pardoc-code-or-zone         as   character               no-undo.
define input  parameter parbase-rate                like ub.trn-doc.base-rate    no-undo.
define input  parameter parbase-scale               like ub.trn-doc.base-scale   no-undo.
define input  parameter parexch-rate                like ub.trn-doc.exch-rate    no-undo.
define input  parameter parexch-scale               like ub.trn-doc.exch-scale   no-undo.
define input  parameter parvat-type                 like ub.parts.vat-type       no-undo.
define input  parameter parslt-type                 like ub.parts.slt-type       no-undo.
define input  parameter parartic                    like ub.parts.artic          no-undo.
define input  parameter parprod-type                like ub.parts.prod-type      no-undo.
define input  parameter parprod-code                like ub.parts.prod-code      no-undo.
define input  parameter parpr-cli                   like ub.parts.price-cli      no-undo.
define input  parameter parcli-base-rate            like ub.parts.cli-base-rate  no-undo.
define input  parameter parpr-rubl                  like ub.parts.price-rubl     no-undo.
define input  parameter parvat-pc                   like ub.parts.slt-pc         no-undo.
define input  parameter parslt-pc                   like ub.parts.slt-pc         no-undo.
define input  parameter parroad-tax                 like ub.parts.road-tax-rubl  no-undo.
define input  parameter partransport-rubl           like ub.parts.transport-rubl no-undo.
define input  parameter parother-rubl               like ub.parts.other-rubl     no-undo.
define output parameter parprice-cli                like ub.doc-line.price-rubl no-undo.
define output parameter parprice-cli-unit-base      like ub.doc-line.price-rubl no-undo.
define output parameter parprice-road-tax           like ub.doc-line.price-rubl no-undo.
define output parameter parprice-other-exp          like ub.doc-line.price-rubl no-undo.
define output parameter parprice-transport-exp      like ub.doc-line.price-rubl no-undo.
define output parameter parprice-without-abs        like ub.doc-line.price-rubl no-undo.
define output parameter parprice-slt                like ub.doc-line.price-rubl no-undo.
define output parameter parprice-no-slt             like ub.doc-line.price-rubl no-undo.
define output parameter parprice-vat                like ub.doc-line.price-rubl no-undo.
define output parameter parprice-no-vat-slt         like ub.doc-line.price-rubl no-undo.
define output parameter parprice-rubl               like ub.doc-line.price-rubl no-undo.
define output parameter parprice-road-tax-rubl      like ub.doc-line.price-rubl no-undo.
define output parameter parprice-other-exp-rubl     like ub.doc-line.price-rubl no-undo.
define output parameter parprice-transport-exp-rubl like ub.doc-line.price-rubl no-undo.
define output parameter parprice-without-abs-rubl   like ub.doc-line.price-rubl no-undo.
define output parameter parprice-slt-rubl           like ub.doc-line.price-rubl no-undo.
define output parameter parprice-no-slt-rubl        like ub.doc-line.price-rubl no-undo.
define output parameter parprice-vat-rubl           like ub.doc-line.price-rubl no-undo.
define output parameter parprice-no-vat-slt-rubl    like ub.doc-line.price-rubl no-undo.
define output parameter parprice-base               like ub.doc-line.price-base no-undo.
define output parameter parprice-road-tax-base      like ub.doc-line.price-base no-undo.
define output parameter parprice-other-exp-base     like ub.doc-line.price-base no-undo.
define output parameter parprice-transport-exp-base like ub.doc-line.price-base no-undo.
define output parameter parprice-without-abs-base   like ub.doc-line.price-base no-undo.
define output parameter parprice-slt-base           like ub.doc-line.price-base no-undo.
define output parameter parprice-no-slt-base        like ub.doc-line.price-base no-undo.
define output parameter parprice-vat-base           like ub.doc-line.price-base no-undo.
define output parameter parprice-no-vat-slt-base    like ub.doc-line.price-base no-undo.
define buffer iv-goods    for ub.goods.
define buffer iv-units    for ub.units.
define variable vartype   as character no-undo.
define variable varpetrol as logical   no-undo.
define variable varpieces as logical   no-undo.
define variable varhave-vat-slt as logical no-undo.
define buffer buf_trn-doc for ub.trn-doc .
do
on error undo, return error return-value
:
if pardoc-code-or-zone = "zakaz":u then do:
  assign
    varhave-vat-slt  = yes
    ptrlprop-expptrl = 'weight':U
  .
end.
else do:
  run lib-trn_have-vat-slt in this-procedure
    (input  pardoc-code-or-zone,
     output varhave-vat-slt).
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = pardoc-code-or-zone
    no-error .
  if available buf_trn-doc then do:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run get-ptrl-prop in this-procedure
  ( input buf_trn-doc.obj-type
  , input buf_trn-doc.obj-code
  ) .
    def var varvalue as character no-undo.
    find first ub.goods no-lock where
            ub.goods.artic = parartic
        and ub.goods.prod-type = parprod-type
        and ub.goods.prod-code = parprod-code.
    run gds-attr-value in this-procedure
      (  input ub.goods.gds-code
      ,  input 'fuel-type':U
      , output varvalue
      , output vartype
      ) no-error .
    if varvalue = 'lgas' then
    do:
      ptrlprop-expptrl = 'weight':U.
    end.
    find first ub.goods no-lock where
            ub.goods.artic = parartic
        and ub.goods.prod-type = parprod-type
        and ub.goods.prod-code = parprod-code.
    run gds-attr-value in this-procedure
      (  input ub.goods.gds-code
      ,  input 'fuel-type':U
      , output varvalue
      , output vartype
      ) no-error .
    if varvalue = 'lgas' then
    do:
      ptrlprop-expptrl = 'weight':U.
    end.
  end.
end.
find first iv-goods where iv-goods.artic     = parartic       and
                          iv-goods.prod-type = parprod-type   and
                          iv-goods.prod-code = parprod-code   no-lock.
find first iv-units where iv-units.unit-name = iv-goods.unit-base no-lock.
if lookup('2ед':U, iv-units.type) = 0
  and not ( lookup('топ':U,  iv-units.type) > 0
            and lookup('шту':U, iv-units.type) > 0
          )
  and not ( lookup('топ':U,  iv-units.type) > 0
            and lookup('шту':U, iv-units.type) = 0
            and lookup( ptrlprop-inpptrl, "volume,volume+" ) > 0
          )
then do:
  assign vartype = "cli".
end.
else do:
  assign vartype = "rubl".
end.
if vartype = "rubl" then do:
  assign parprice-rubl = parpr-rubl.
  run lib-trn_in-vat-incl in this-procedure (input  parother-rubl                  ,
                           input  partransport-rubl              ,
                           input  parroad-tax                    ,
                           input  parprice-rubl                  ,
                           input  parvat-pc                      ,
                           input  parslt-pc                      ,
                           input  parbase-rate                   ,
                           input  parbase-scale                  ,
                           input  varhave-vat-slt                ,
                           output parprice-other-exp-rubl        ,
                           output parprice-transport-exp-rubl    ,
                           output parprice-road-tax-rubl         ,
                           output parprice-without-abs-rubl      ,
                           output parprice-SLT-rubl              ,
                           output parprice-no-slt-rubl           ,
                           output parprice-VAT-rubl              ,
                           output parprice-no-VAT-slt-rubl    ) no-error.
  if error-status :error then do:
     return error return-value.
  end.
  assign parprice-cli-unit-base = (parprice-no-vat-slt-rubl +
                         (if parvat-type =  'в т. ч.':U then parprice-vat-rubl else 0) +
                         (if parslt-type =  'в т. ч.':U then parprice-slt-rubl else 0) )
                         / parexch-rate  * parexch-scale
         parprice-cli = parprice-cli-unit-base * parcli-base-rate.
end.
else do:
  assign parprice-cli           = parpr-cli
         parprice-cli-unit-base = parprice-cli / parcli-base-rate.
end.
ASSIGN
parprice-other-exp     = (if parother-rubl     <> ? then parother-rubl     else 0)
                         / parexch-rate * parexch-scale
                         * parcli-base-rate
parprice-transport-exp = (if partransport-rubl <> ? then partransport-rubl else 0)
                         / parexch-rate * parexch-scale
                         * parcli-base-rate
.
if g-varr-b = "rubl":u then do:
  assign
    parprice-road-tax      = parroad-tax
                             / parexch-rate * parexch-scale
                             * parcli-base-rate
  .
end.
else do:
  assign
    parprice-road-tax      = parroad-tax
                             * parbase-rate / parbase-scale
                             / parexch-rate * parexch-scale
                             * parcli-base-rate
  .
end.
case parvat-type:
when 'без':U then do:
  if parvat-pc <> 0 then do:
    return error substitute(" В документе установлен тип НДС - без, а ставка НДС отлична от 0.( = &1 )" ,parvat-pc ) .
  end.
  if parslt-type = 'нет':U      or
     parslt-Type = 'без':U then do:
    assign
      parprice-VAT        = 0
      parprice-slt        = (if varhave-vat-slt <> yes then 0 else parprice-cli * parslt-pc / 100)
      parprice-no-vat-slt = parprice-cli.
  end.
  else do:
    assign
      parprice-VAT        = 0
      parprice-slt        = (if varhave-vat-slt <> yes then 0 else parprice-cli * parslt-pc / (100 + parslt-pc))
      parprice-no-vat-slt = parprice-cli - parprice-slt.
  end.
end.
when 'нет':U then do:
  if parslt-type = 'нет':U      or
     parslt-Type = 'без':U then do:
    assign
      parprice-VAT        = (if varhave-vat-slt <> yes then 0 else parprice-cli                         * parvat-pc / 100)
      parprice-slt        = (if varhave-vat-slt <> yes then 0 else parprice-cli * (1 + parvat-pc / 100) * parslt-pc / 100)
      parprice-no-vat-slt = parprice-cli.
  end.
  else do:
    assign
      parprice-VAT        = (if varhave-vat-slt <> yes then 0 else parprice-cli / ((100 / parvat-pc) * (1 + parslt-pc / 100) + parslt-pc / 100))
      parprice-slt        = (if varhave-vat-slt <> yes then 0 else parprice-cli * ( 1 - 1 / (1 + parslt-pc / 100 + parslt-pc / 100 * parvat-pc / 100 )))
      parprice-no-vat-slt = parprice-cli - parprice-slt.
  end.
end.
when 'в т. ч.':U then do:
  if parslt-type = 'нет':U      or
     parslt-Type = 'без':U then do:
    assign
      parprice-VAT        = (if varhave-vat-slt <> yes then 0 else parprice-cli   * parvat-pc / (100 + parvat-pc))
      parprice-slt        = (if varhave-vat-slt <> yes then 0 else parprice-cli   * parslt-pc / 100)
      parprice-no-vat-slt = parprice-cli - parprice-VAT.
  end.
  else do:
    assign
      parprice-VAT        = (if varhave-vat-slt <> yes then 0 else parprice-cli * (100 / ( 100 + parslt-pc)) * parvat-pc / (100 + parvat-pc))
      parprice-slt        = (if varhave-vat-slt <> yes then 0 else parprice-cli                              * parslt-pc / (100 + parslt-pc))
      parprice-no-vat-slt = parprice-cli - parprice-VAT - parprice-SLT.
  end.
end.
end case.
assign parprice-without-abs = parprice-no-vat-slt + parprice-VAT + parprice-slt.
if vartype = "cli" then do:
  assign
  parprice-rubl  = (parprice-without-abs
                    * parexch-rate / parexch-scale
                    / parcli-base-rate
                    +
                    parroad-tax * (if g-varr-b = "base":u then parbase-rate  /  parbase-scale else 1) +
                    (if partransport-rubl <> ? then partransport-rubl else 0)  +
                    (if parother-rubl     <> ? then parother-rubl     else 0)
                    ).
  run lib-trn_in-vat-incl in this-procedure (input  parother-rubl                  ,
                           input  partransport-rubl              ,
                           input  parroad-tax                    ,
                           input  parprice-rubl                  ,
                           input  parvat-pc                      ,
                           input  parslt-pc                      ,
                           input  parbase-rate                   ,
                           input  parbase-scale                  ,
                           input  varhave-vat-slt                ,
                           output parprice-other-exp-rubl        ,
                           output parprice-transport-exp-rubl    ,
                           output parprice-road-tax-rubl         ,
                           output parprice-without-abs-rubl      ,
                           output parprice-SLT-rubl              ,
                           output parprice-no-slt-rubl           ,
                           output parprice-VAT-rubl              ,
                           output parprice-no-VAT-slt-rubl    ) no-error.
  if error-status :error then do:
     return error return-value.
  end.
end.
assign
parprice-base               = parprice-rubl               / parbase-rate * parbase-scale
parprice-road-tax-base      = parprice-road-tax-rubl      / parbase-rate * parbase-scale
parprice-other-exp-base     = parprice-other-exp-rubl     / parbase-rate * parbase-scale
parprice-transport-exp-base = parprice-transport-exp-rubl / parbase-rate * parbase-scale
parprice-without-abs-base   = parprice-without-abs-rubl   / parbase-rate * parbase-scale
parprice-slt-base           = parprice-slt-rubl           / parbase-rate * parbase-scale
parprice-no-slt-base        = parprice-no-slt-rubl        / parbase-rate * parbase-scale
parprice-vat-base           = parprice-vat-rubl           / parbase-rate * parbase-scale
parprice-no-vat-slt-base    = parprice-no-vat-slt-rubl    / parbase-rate * parbase-scale
.
end.
end procedure.
procedure lib-trn_in-vat-incl:
define input  parameter parother-rubl                like ub.parts.other-rubl     no-undo.
define input  parameter partransport-rubl            like ub.parts.transport-rubl no-undo.
define input  parameter parroad-tax                  like ub.parts.road-tax-base  no-undo.
define input  parameter parpr-rubl                   like ub.parts.price-rubl     no-undo.
define input  parameter parvat-pc                    like ub.parts.vat-pc         no-undo.
define input  parameter parslt-pc                    like ub.parts.slt-pc         no-undo.
define input  parameter parbase-rate                 like ub.trn-doc.base-rate    no-undo.
define input  parameter parbase-scale                like ub.trn-doc.base-scale   no-undo.
define input  parameter parhave-vat-slt              as   logical                 no-undo.
define output parameter parprice-other-exp-rubl      like ub.parts.other-rubl     no-undo.
define output parameter parprice-transport-exp-rubl  like ub.parts.transport-rubl no-undo.
define output parameter parprice-road-tax-rubl       like ub.parts.road-tax-rubl  no-undo.
define output parameter parprice-without-abs-rubl    like ub.parts.price-rubl     no-undo.
define output parameter parprice-SLT-rubl            like ub.parts.price-rubl     no-undo.
define output parameter parprice-no-slt-rubl         like ub.parts.price-rubl     no-undo.
define output parameter parprice-VAT-rubl            like ub.parts.price-rubl     no-undo.
define output parameter parprice-no-VAT-slt-rubl     like ub.parts.price-rubl     no-undo.
define variable varr-b as character no-undo.
do on error undo, return error return-value :
  ASSIGN
  parprice-other-exp-rubl     = (if parother-rubl     <> ? then parother-rubl     else 0)
  parprice-transport-exp-rubl = (if partransport-rubl <> ? then partransport-rubl else 0)
  parprice-road-tax-rubl      = parroad-tax *  (if varr-b = "base":u THEN parbase-rate / parbase-scale else 1 )
  parprice-without-abs-rubl   = parpr-rubl                  -
                                parprice-other-exp-rubl     -
                                parprice-transport-exp-rubl -
                                parprice-road-tax-rubl.
  assign parprice-SLT-rubl    = (if parhave-vat-slt <> yes then 0 else parprice-without-abs-rubl * parslt-pc / (parslt-pc + 100))
         parprice-no-slt-rubl = parprice-without-abs-rubl - parprice-slt-rubl.
  assign
      parprice-VAT-rubl        = (if parhave-vat-slt <> yes then 0 else parprice-no-slt-rubl * parvat-pc / (parvat-pc + 100))
      parprice-no-VAT-slt-rubl = parprice-no-slt-rubl - parprice-VAT-rubl.
end.
end procedure.
procedure lib-trn_is-petrl :
  define  input parameter parartic        like ub.goods.artic     no-undo.
  define  input parameter parprod-type    like ub.goods.prod-type no-undo.
  define  input parameter parprod-code    like ub.goods.prod-code no-undo.
  define output parameter paris-petrolium as   logical            no-undo.
  define output parameter paris-pieces    as   logical            no-undo.
  define buffer bf_goods for ub.goods.
  define buffer bf_units for ub.units.
  do on error undo, return error
              substitute( 'lib-trn_is-petrl: ошибка определения товара на топливо: товар &1 ' + if parprod-type eq ? then '(код &3).' else '(производитель &2 &3).',
                          parartic, parprod-type, parprod-code ) :
    if parprod-type ne ?
    then
       find first bf_goods no-lock where
                  bf_goods.artic     = parartic     and
                  bf_goods.prod-type = parprod-type and
                  bf_goods.prod-code = parprod-code no-error.
    else
       find first bf_goods no-lock where
                  bf_goods.gds-code     = parprod-code no-error.
    if not available bf_goods then do:
      undo, return error substitute( "lib-trn_is-petrl: не найден товар &1 " + if parprod-type eq ? then '(код &3).' else '(производитель &2 &3).',
                                     parartic, parprod-type, parprod-code ).
    end.
    find first bf_units no-lock where bf_units.unit-name = bf_goods.unit-base no-error.
    if not available bf_units then do:
      return error substitute( 'lib-trn_is-petrl: не найдена базовая ед.изм. "&1" в товаре &2 ' + if parprod-type eq ? then '(код &4).' else '(производитель &3 &4).',
                               bf_goods.unit-base, parartic, parprod-type, parprod-code ).
        end.
    assign paris-petrolium = ( if lookup( 'топ':U, bf_units.type ) > 0 then yes else no ).
    if lookup( 'шту':U, bf_units.type ) = 0 then do:
      if paris-petrolium = yes and lookup( 'дро':U, bf_units.type ) = 0 then do:
        undo, return error substitute( 'lib-trn_is-petrl: Неверная связка типов единиц измерения для топлива: "&1" .',
                                       bf_units.type ).
      end.
      assign paris-pieces = no.
    end.
    else do:
      assign paris-pieces = yes.
    end.
  end.
end procedure.
procedure lib-trn_clcintrn:
define input parameter parparentproc     AS WIDGET-HANDLE                NO-UNDO.
define input parameter parrec-linenew    as recid                        no-undo.
define input parameter pardoc-code       like ub.doc-line.doc-code       no-undo.
define input parameter parartic          like ub.doc-line.artic          no-undo.
define input parameter parprod-type      like ub.doc-line.prod-type      no-undo.
define input parameter parprod-code      like ub.doc-line.prod-code      no-undo.
define input parameter parprice-cli      like ub.doc-line.price-cli      no-undo.
define input parameter parprice-rubl     like ub.doc-line.price-rubl     no-undo.
define input parameter parprice-base     like ub.doc-line.price-base     no-undo.
define input parameter parcli-qnty       like ub.doc-line.cli-qnty       no-undo.
define input parameter parcli-base-rate  like ub.doc-line.cli-base-rate  no-undo.
define input parameter parfact-qnty      like ub.doc-line.fact-qnty      no-undo.
define input parameter pardoc-qnty       like ub.doc-line.doc-qnty       no-undo.
define input parameter parvat-pc         like ub.doc-line.vat-pc         no-undo.
define input parameter parslt-pc         like ub.doc-line.slt-pc         no-undo.
define input parameter parroad-tax       like ub.doc-line.road-tax       no-undo.
define input parameter parexcise         like ub.doc-line.excise         no-undo.
define input parameter partransport-rubl like ub.doc-line.transport-rubl no-undo.
define input parameter parother-rubl     like ub.doc-line.other-rubl     no-undo.
define input parameter parmode           as character                    no-undo.
define input parameter parrsrv-inf       as character                    no-undo.
define variable v-clcdoc-vat-pc                     like ub.doc-line.vat-pc        no-undo.
define variable v-clcdoc-slt-pc                     like ub.doc-line.slt-pc        no-undo.
define variable v-clcdoc-have-slt-pc                like ub.doc-line.slt-pc        no-undo.
define variable v-clcdoc-host-code                  like ub.sysconf.host-code         no-undo.
define variable v-total-doc-line_tot-ovnew          like ub.trn-doc.tot-ov         no-undo.
define variable v-total-doc-line_fact-rublnew       like ub.trn-doc.fact-rubl      no-undo.
define variable v-total-doc-line_fact-basenew       like ub.trn-doc.fact-base      no-undo.
define variable v-total-doc-line_fact-qntynew       like ub.trn-doc.fact-qnty      no-undo.
define variable v-total-doc-line_doc-qntynew        like ub.trn-doc.doc-qnty       no-undo.
define variable v-total-doc-line_cli-qntynew        like ub.trn-doc.cli-qnty       no-undo.
define variable v-total-parts_fact-basenew          as   decimal                   no-undo.
define variable v-total-parts_fact-rublnew          as   decimal                   no-undo.
define variable v-total-parts_fact-qntynew          as   decimal                   no-undo.
define variable v-total-doc-line_tot-ovold          like ub.trn-doc.tot-ov         no-undo.
define variable v-total-doc-line_fact-rublold       like ub.trn-doc.fact-rubl      no-undo.
define variable v-total-doc-line_fact-baseold       like ub.trn-doc.fact-base      no-undo.
define variable v-total-doc-line_fact-qntyold       like ub.trn-doc.fact-qnty      no-undo.
define variable v-total-doc-line_doc-qntyold        like ub.trn-doc.doc-qnty       no-undo.
define variable v-total-doc-line_cli-qntyold        like ub.trn-doc.cli-qnty       no-undo.
define variable v-total-parts_fact-baseold          as   decimal                   no-undo.
define variable v-total-parts_fact-rublold          as   decimal                   no-undo.
define variable v-total-parts_fact-qntyold          as   decimal                   no-undo.
define variable delta-line-vat                      like ub.trn-doc.vat-base       no-undo.
define variable delta-line-slt                      like ub.trn-doc.slt-base       no-undo.
define variable v-inout-price                       like ub.store.inout-price      no-undo.
define variable v-cash-pay                          like ub.sysconf.cash-pay       no-undo.
define variable varprice-clinew                     like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-basenew           like ub.doc-line.price-rubl no-undo.
define variable varprice-road-taxnew                like ub.doc-line.price-rubl no-undo.
define variable varprice-other-expnew               like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-expnew           like ub.doc-line.price-rubl no-undo.
define variable varprice-without-absnew             like ub.doc-line.price-rubl no-undo.
define variable varprice-sltnew                     like ub.doc-line.price-rubl no-undo.
define variable varprice-no-sltnew                  like ub.doc-line.price-rubl no-undo.
define variable varprice-vatnew                     like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-sltnew              like ub.doc-line.price-rubl no-undo.
define variable varprice-rublnew                    like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rublnew           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rublnew          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rublnew      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rublnew        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rublnew                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rublnew             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rublnew                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rublnew         like ub.doc-line.price-rubl no-undo.
define variable varprice-basenew                    like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-basenew           like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-basenew          like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-basenew      like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-basenew        like ub.doc-line.price-base no-undo.
define variable varprice-slt-basenew                like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-basenew             like ub.doc-line.price-base no-undo.
define variable varprice-vat-basenew                like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-basenew         like ub.doc-line.price-base no-undo.
define variable varprice-cliold                     like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-baseold           like ub.doc-line.price-rubl no-undo.
define variable varprice-road-taxold                like ub.doc-line.price-rubl no-undo.
define variable varprice-other-expold               like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-expold           like ub.doc-line.price-rubl no-undo.
define variable varprice-without-absold             like ub.doc-line.price-rubl no-undo.
define variable varprice-sltold                     like ub.doc-line.price-rubl no-undo.
define variable varprice-no-sltold                  like ub.doc-line.price-rubl no-undo.
define variable varprice-vatold                     like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-sltold              like ub.doc-line.price-rubl no-undo.
define variable varprice-rublold                    like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rublold           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rublold          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rublold      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rublold        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rublold                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rublold             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rublold                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rublold         like ub.doc-line.price-rubl no-undo.
define variable varprice-baseold                    like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-baseold           like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-baseold          like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-baseold      like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-baseold        like ub.doc-line.price-base no-undo.
define variable varprice-slt-baseold                like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-baseold             like ub.doc-line.price-base no-undo.
define variable varprice-vat-baseold                like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-baseold         like ub.doc-line.price-base no-undo.
define buffer tc_doc-line-new for ub.doc-line.
define buffer tc_trn-doc      for ub.trn-doc.
define buffer tc_store        for ub.store.
define buffer tc_shop         for ub.shop.
define buffer tc_goods        for ub.goods.
define buffer tc_sysconf      for ub.sysconf.
do on error undo, return error return-value :
find first tc_trn-doc  where tc_trn-doc.doc-code = pardoc-code.
if parmode <> "delete" then do:
  find first tc_doc-line-new where recid(tc_doc-line-new) = parrec-linenew.
  if tc_trn-doc.obj-type = 'скл':U then do:
    find tc_store where tc_store.obj-code = tc_trn-doc.obj-code no-lock.
    assign
      v-inout-price = tc_store.inout-price.
    find tc_sysconf where tc_sysconf.host-code = tc_store.host-code no-lock.
  end.
  else do:
    find tc_shop where tc_shop.obj-code = tc_trn-doc.obj-code no-lock.
    assign
      v-inout-price = tc_shop.inout-price.
    find tc_sysconf where tc_sysconf.host-code = tc_shop.host-code no-lock.
  end.
  assign
         v-cash-pay  = tc_sysconf.cash-pay.
  if not v-inout-price               and
     tc_trn-doc.doc-type = 'при':U and
     not tc_trn-doc.internal         and
     tc_trn-doc.doc-type = 'накл':U   and
     not tc_trn-doc.flag_         then do:
      find tc_goods where tc_goods.artic     = tc_doc-line-new.artic     and
                          tc_goods.prod-type = tc_doc-line-new.prod-type and
                          tc_goods.prod-code = tc_doc-line-new.prod-code
      no-lock.
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  tc_doc-line-new.obj-type
  ,input  tc_doc-line-new.obj-code
  ,output v-clcdoc-host-code
  )  .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  tc_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-clcdoc-host-code
  ,input  tc_doc-line-new.obj-type
  ,input  tc_doc-line-new.obj-code
  ,output v-clcdoc-vat-pc
  ) no-error .
      assign
          tc_doc-line-new.vat-pc = v-clcdoc-vat-pc
      .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_st-sltpc in g#lib-trn
(
 input  recid(tc_goods)
,input  recid(tc_trn-doc)
,input  v-cash-pay
,output v-clcdoc-slt-pc
)
no-error.
      if error-status :error then return error.
      assign tc_doc-line-new.slt-pc = v-clcdoc-slt-pc.
   end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   tc_trn-doc.doc-code
  ,input   tc_trn-doc.base-rate
  ,input   tc_trn-doc.base-scale
  ,input   tc_trn-doc.exch-rate
  ,input   tc_trn-doc.exch-scale
  ,input   tc_trn-doc.vat-type
  ,input   tc_trn-doc.slt-type
  ,input   tc_doc-line-new.artic
  ,input   tc_doc-line-new.prod-type
  ,input   tc_doc-line-new.prod-code
  ,input   tc_doc-line-new.price-cli
  ,input   tc_doc-line-new.cli-base-rate
  ,input   tc_doc-line-new.price-rubl
  ,input   tc_doc-line-new.vat-pc
  ,input   tc_doc-line-new.slt-pc
  ,input   tc_doc-line-new.road-tax
  ,input   tc_doc-line-new.transport-rubl
  ,input   tc_doc-line-new.other-rubl
  ,output  varprice-clinew
  ,output  varprice-cli-unit-basenew
  ,output  varprice-road-taxnew
  ,output  varprice-other-expnew
  ,output  varprice-transport-expnew
  ,output  varprice-without-absnew
  ,output  varprice-sltnew
  ,output  varprice-no-sltnew
  ,output  varprice-vatnew
  ,output  varprice-no-vat-sltnew
  ,output  varprice-rublnew
  ,output  varprice-road-tax-rublnew
  ,output  varprice-other-exp-rublnew
  ,output  varprice-transport-exp-rublnew
  ,output  varprice-without-abs-rublnew
  ,output  varprice-slt-rublnew
  ,output  varprice-no-slt-rublnew
  ,output  varprice-vat-rublnew
  ,output  varprice-no-vat-slt-rublnew
  ,output  varprice-basenew
  ,output  varprice-road-tax-basenew
  ,output  varprice-other-exp-basenew
  ,output  varprice-transport-exp-basenew
  ,output  varprice-without-abs-basenew
  ,output  varprice-slt-basenew
  ,output  varprice-no-slt-basenew
  ,output  varprice-vat-basenew
  ,output  varprice-no-vat-slt-basenew
  ) no-error.
   if error-status :error then do:
     return error substitute ("Ошибка при вычисление компонентов линии документа &1.", return-value).
   end.
   assign delta-line-VAT =  tc_doc-line-new.fact-qnty *
                            varprice-vatnew /
                            tc_doc-line-new.cli-base-rate.
   assign delta-line-SLT = tc_doc-line-new.fact-qnty *
                           varprice-sltnew /
                           tc_doc-line-new.cli-base-rate.
   run lib-trn_fill-ext-inc in this-procedure (input parparentproc,
                             input tc_doc-line-new.doc-code,
                             input tc_doc-line-new.artic,
                             input tc_doc-line-new.prod-type,
                             input tc_doc-line-new.prod-code,
                             input tc_doc-line-new.price-base,
                             input tc_doc-line-new.price-rubl,
                             input tc_doc-line-new.cli-base-rate,
                             input varprice-vatnew,
                             input parrsrv-inf) no-error.
   if error-status :error then do:
     return error return-value.
   end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_acc-cost in g#lib-trn
(
 input  tc_doc-line-new.obj-type
,input  tc_doc-line-new.obj-code
,input  tc_doc-line-new.doc-code
,input  tc_doc-line-new.artic
,input  tc_doc-line-new.prod-type
,input  tc_doc-line-new.prod-code
,input  tc_doc-line-new.cli-qnty
,input  tc_doc-line-new.doc-qnty
,input  tc_doc-line-new.fact-qnty
,input  tc_doc-line-new.price-base
,input  tc_doc-line-new.price-rubl
,input  'new':U
,output v-total-doc-line_tot-ovnew
,output v-total-doc-line_fact-rublnew
,output v-total-doc-line_fact-basenew
,output v-total-doc-line_fact-qntynew
,output v-total-doc-line_doc-qntynew
,output v-total-doc-line_cli-qntynew
)
no-error.
   if error-status :error then do:
     return error return-value.
   end.
end.
else do:
  assign
  v-total-doc-line_tot-ovnew       = 0
  v-total-doc-line_fact-rublnew    = 0
  v-total-doc-line_fact-basenew    = 0
  v-total-doc-line_fact-qntynew    = 0
  v-total-doc-line_doc-qntynew     = 0
  v-total-doc-line_cli-qntynew     = 0
  .
end.
if parmode <> "create" then do:
   run lib-trn_in-vat in this-procedure (
    input  tc_trn-doc.doc-code          ,
    input  tc_trn-doc.base-rate         ,
    input  tc_trn-doc.base-scale        ,
    input  tc_trn-doc.exch-rate         ,
    input  tc_trn-doc.exch-scale        ,
    input  tc_trn-doc.vat-type          ,
    input  tc_trn-doc.slt-type          ,
    input  parartic                     ,
    input  parprod-type                 ,
    input  parprod-code                 ,
    input  parprice-cli                 ,
    input  parcli-base-rate             ,
    input  parprice-rubl                ,
    input  parvat-pc                    ,
    input  parslt-pc                    ,
    input  parroad-tax                  ,
    input  partransport-rubl            ,
    input  parother-rubl                ,
    output varprice-cliold                              ,
    output varprice-cli-unit-baseold                    ,
    output varprice-road-taxold                         ,
    output varprice-other-expold                        ,
    output varprice-transport-expold                    ,
    output varprice-without-absold                      ,
    output varprice-sltold                              ,
    output varprice-no-sltold                           ,
    output varprice-vatold                              ,
    output varprice-no-vat-sltold                       ,
    output varprice-rublold                             ,
    output varprice-road-tax-rublold                    ,
    output varprice-other-exp-rublold                   ,
    output varprice-transport-exp-rublold               ,
    output varprice-without-abs-rublold                 ,
    output varprice-slt-rublold                         ,
    output varprice-no-slt-rublold                      ,
    output varprice-vat-rublold                         ,
    output varprice-no-vat-slt-rublold                  ,
    output varprice-baseold                             ,
    output varprice-road-tax-baseold                    ,
    output varprice-other-exp-baseold                   ,
    output varprice-transport-exp-baseold               ,
    output varprice-without-abs-baseold                 ,
    output varprice-slt-baseold                         ,
    output varprice-no-slt-baseold                      ,
    output varprice-vat-baseold                         ,
    output varprice-no-vat-slt-baseold                  ) no-error.
  if error-status :error then do:
     return error substitute ("Ошибка при вычисление компонентов линии документа &1.", return-value).
  end.
  ASSIGN delta-line-VAT =  delta-line-vat -
                           parfact-qnty * varprice-vatold / parcli-base-rate
         delta-line-SLT =  delta-line-slt -
                           parfact-qnty * varprice-sltold / parcli-base-rate.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_acc-cost in g#lib-trn
(
 input  tc_trn-doc.obj-type
,input  tc_trn-doc.obj-code
,input  pardoc-code
,input  parartic
,input  parprod-type
,input  parprod-code
,input  parcli-qnty
,input  pardoc-qnty
,input  parfact-qnty
,input  parprice-base
,input  parprice-rubl
,input  'old':U
,output v-total-doc-line_tot-ovold
,output v-total-doc-line_fact-rublold
,output v-total-doc-line_fact-baseold
,output v-total-doc-line_fact-qntyold
,output v-total-doc-line_doc-qntyold
,output v-total-doc-line_cli-qntyold
)
no-error.
  if error-status :error then do:
    return error return-value.
  end.
end.
else do:
  assign
  v-total-doc-line_tot-ovold       = 0
  v-total-doc-line_fact-rublold    = 0
  v-total-doc-line_fact-baseold    = 0
  v-total-doc-line_fact-qntyold    = 0
  v-total-doc-line_doc-qntyold     = 0
  v-total-doc-line_cli-qntyold     = 0
  .
end.
if tc_trn-doc.doc-qnty = ? then tc_trn-doc.doc-qnty = 0.
if delta-line-vat      = ? then delta-line-vat      = 0.
if delta-line-slt      = ? then delta-line-slt      = 0.
if parmode <> "delete" then do:
   if tc_doc-line-new.fact-qnty = ? then do:
     assign
      tc_doc-line-new.fact-qnty = 0.
   end.
end.
assign
  tc_trn-doc.vat-rubl = tc_trn-doc.vat-rubl + delta-line-vat * tc_trn-doc.exch-rate / tc_trn-doc.exch-scale
  tc_trn-doc.vat-base = tc_trn-doc.vat-rubl / tc_trn-doc.base-rate * tc_trn-doc.base-scale
  tc_trn-doc.slt-rubl = tc_trn-doc.slt-rubl + delta-line-slt * tc_trn-doc.exch-rate / tc_trn-doc.exch-scale
  tc_trn-doc.slt-base = tc_trn-doc.slt-rubl / tc_trn-doc.base-rate * tc_trn-doc.base-scale
  tc_trn-doc.tot-calc = tc_trn-doc.tot-calc +
                  (if parmode <> "delete" then (tc_doc-line-new.cli-qnty * tc_doc-line-new.price-cli) else 0) -
                  (if parmode <> "create" then (parcli-qnty * parprice-cli) else 0)
  tc_trn-doc.tot-doc  = tc_trn-doc.tot-doc +
                  (if parmode <> "delete" then (tc_doc-line-new.doc-qnty * tc_doc-line-new.price-base) else 0) -
                  (if parmode <> "create" then (pardoc-qnty * parprice-base) else 0)
  tc_trn-doc.tot-fact = tc_trn-doc.tot-fact +
                  (if parmode <> "delete" then (tc_doc-line-new.fact-qnty * tc_doc-line-new.price-base) else 0)  -
                  (if parmode <> "create" then (parfact-qnty * parprice-base) else 0)
  tc_trn-doc.road-tax = tc_trn-doc.road-tax  +
                  (if parmode <> "delete" then (tc_doc-line-new.fact-qnty * tc_doc-line-new.road-tax) else 0) -
                  (if parmode <> "create" then (parfact-qnty * parroad-tax) else 0)
  tc_trn-doc.excise = tc_trn-doc.excise +
                  (if parmode <> "delete" then (tc_doc-line-new.fact-qnty * tc_doc-line-new.excise) else 0) -
                  (if parmode <> "create" then (parfact-qnty * parexcise) else 0)
  tc_trn-doc.tot-sale = tc_trn-doc.tot-sale +
                  (if parmode <> "delete" then (tc_doc-line-new.fact-qnty * tc_doc-line-new.price-rubl) else 0) -
                  (if parmode <> "create" then (parfact-qnty * parprice-rubl) else 0)
  tc_trn-doc.tot-rubl = tc_trn-doc.tot-rubl +
                  (if parmode <> "delete" then (tc_doc-line-new.doc-qnty * tc_doc-line-new.price-rubl) else 0) -
                  (if parmode <> "create" then (pardoc-qnty * parprice-rubl) else 0)
                  .
if tc_trn-doc.status_ = 'факт':U then do:
  assign
      tc_trn-doc.tot-transp = tc_trn-doc.tot-transp +
                  (if parmode <> "delete" then (tc_doc-line-new.fact-qnty * tc_doc-line-new.transport-rubl) else 0) -
                  (if parmode <> "create" then (parfact-qnty * partransport-rubl) else 0)
      tc_trn-doc.tot-other = tc_trn-doc.tot-other +
                  (if parmode <> "delete" then (tc_doc-line-new.fact-qnty * tc_doc-line-new.other-rubl) else 0) -
                  (if parmode <> "create" then (parfact-qnty * parother-rubl) else 0).
end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_ass-cost in g#lib-trn
(
 input recid(tc_trn-doc)
,input v-total-doc-line_tot-ovnew
,input v-total-doc-line_fact-rublnew
,input v-total-doc-line_fact-basenew
,input v-total-doc-line_fact-qntynew
,input v-total-doc-line_doc-qntynew
,input v-total-doc-line_cli-qntynew
,input v-total-doc-line_tot-ovold
,input v-total-doc-line_fact-rublold
,input v-total-doc-line_fact-baseold
,input v-total-doc-line_fact-qntyold
,input v-total-doc-line_doc-qntyold
,input v-total-doc-line_cli-qntyold
)
no-error.
  if error-status :error then undo, return error.
if parmode = "delete" then do:
  assign tc_trn-doc.tot-lines = tc_trn-doc.tot-lines - 1.
end.
if parmode = "create" then do:
  assign tc_trn-doc.tot-lines = tc_trn-doc.tot-lines + 1.
end.
if substr (tc_trn-doc.PS, 1, 1) = "@" then
        tc_trn-doc.PS = "@  Строк в документе : " + string (tc_trn-doc.tot-lines).
end.
end procedure.
procedure lib-trn_chkwhole:
define input parameter pardoc-code  like ub.trn-doc.doc-code   no-undo.
define input parameter parartic     like ub.doc-line.artic     no-undo.
define input parameter parprod-type like ub.doc-line.prod-type no-undo.
define input parameter parprod-code like ub.doc-line.prod-code no-undo.
define input parameter parcli-qnty  like ub.doc-line.cli-qnty  no-undo.
define input parameter pardoc-qnty  like ub.doc-line.doc-qnty  no-undo.
define input parameter parfact-qnty like ub.doc-line.fact-qnty no-undo.
define input parameter parrecalc    as   logical               no-undo.
define variable is-unit-error as logical no-undo.
define variable g-log as logical no-undo.
define buffer cw-cli-units  for ub.units.
define buffer cw-base-units for ub.units.
define buffer cw-goods      for ub.goods.
define buffer cw-doc-line   for ub.doc-line.
define buffer cw-trn-doc    for ub.trn-doc.
find first cw-goods      where cw-goods.artic     = parartic                  and
                               cw-goods.prod-type = parprod-type              and
                               cw-goods.prod-code = parprod-code              no-lock.
find first cw-doc-line   where cw-doc-line.doc-code    = pardoc-code          and
                               cw-doc-line.artic       = cw-goods.artic       and
                               cw-doc-line.prod-type   = cw-goods.prod-type   and
                               cw-doc-line.prod-code   = cw-goods.prod-code   .
find first cw-base-units where cw-base-units.unit-name = cw-goods.unit-base   no-lock.
find first cw-trn-doc    where cw-trn-doc.doc-code     = pardoc-code          no-lock.
if cw-doc-line.unit-cli <> "" then do:
   find first cw-cli-units  where cw-cli-units.unit-name  = cw-doc-line.unit-cli no-lock.
   if lookup('шту':U, cw-cli-units.type) > 0 and
      trunc(parcli-qnty, 0) <> parcli-qnty     then do:
      run str/ck-uncli.p (input cw-goods.unit-base,
                      input cw-goods.gds-code,
                      input cw-trn-doc.obj-type,
                      input cw-trn-doc.obj-code,
                      input cw-trn-doc.hold-doc-code-parent,
                      input cw-trn-doc.hold-doc-code-child,
                      output is-unit-error) no-error.
      if error-status :error then return error return-value.
      if is-unit-error or
         not (cw-trn-doc.doc-type = 'при':U and
              not cw-trn-doc.internal) then do:
         return error substitute ("Товар : &1 &2 имеет штучную единицу измерения поставщика &3 Количество в единицах поставщика &4.",
                cw-goods.artic,
                cw-goods.gds-name,
                cw-doc-line.unit-cli,
                parcli-qnty).
      end.
      else do:
        if not parrecalc then do:
          return error substitute ("Товар : &1 &2 имеет штучную единицу измерения поставщика &3 Количество в единицах поставщика &4",
                        cw-goods.artic,
                        cw-goods.gds-name,
                        cw-doc-line.unit-cli,
                        parcli-qnty).
        end.
        else do:
            assign cw-doc-line.unit-cli      =  cw-goods.unit-base
                   cw-doc-line.cli-qnty      =  cw-doc-line.cli-qnty * cw-doc-line.cli-base-rate
                   cw-doc-line.price-cli     =  cw-doc-line.price-cli / cw-doc-line.cli-base-rate
                   cw-doc-line.cli-base-rate = 1.
            run str/rc-price.p (input recid(cw-doc-line)) no-error.
            return  " Изменены единицы измерения поставщика на: " + string (cw-doc-line.unit-cli) + " ".
        end.
      end.
   end.
end.
if lookup('шту':U, cw-base-units.type) > 0  and
   trunc (pardoc-qnty, 0) <> pardoc-qnty
then do:
    return error substitute("Базовая единица товара &1  - штучная. Кол-во по документу должно быть целым.",
                            cw-goods.unit-base).
end.
if lookup('шту':U, cw-base-units.type) > 0  and
   trunc(parfact-qnty, 0) <> parfact-qnty
then do:
    return error substitute ("Базовая единица товара &1 - штучная. Кол-во по факту должно быть целым.", cw-goods.unit-base).
end.
end procedure.
procedure lib-trn_crgdsdtl:
define input parameter parobj-code  like ub.clients.obj-code  no-undo.
define input parameter parobj-type  like ub.clients.obj-type  no-undo.
define input parameter pardoc-code  like ub.trn-doc.doc-code  no-undo.
define input parameter parartic     like ub.goods.artic       no-undo.
define input parameter parprod-code like ub.goods.prod-code   no-undo.
define input parameter parprod-type like ub.goods.prod-type   no-undo.
define input parameter parprt-code  like ub.gds-dtl.prt-code  no-undo.
define input parameter parcheck     as   logical              no-undo.
define variable        varis-new    as   logical              no-undo.
define buffer bf_gds-dtl  for ub.gds-dtl.
define buffer bf_clients  for ub.clients.
define buffer bf_trn-doc  for ub.trn-doc.
define buffer bf_goods    for ub.goods.
define buffer bf_bar-code for ub.bar-code.
do on error undo, return error return-value :
find first bf_gds-dtl where bf_gds-dtl.doc-code   = pardoc-code
                        and bf_gds-dtl.artic      = parartic
                        and bf_gds-dtl.prod-code  = parprod-code
                        and bf_gds-dtl.prod-type  = parprod-type
                        and bf_gds-dtl.prt-code   = parprt-code   no-error.
if not available bf_gds-dtl then do:
   if parcheck = yes then do:
      find first bf_clients where bf_clients.obj-type = parobj-type and
                                  bf_clients.obj-code = parobj-code no-lock no-error.
      if not available bf_clients then do:
         return error subst("Создание признака невозможно. Не найден объект &1 &2.", parobj-type, parobj-code) .
      end.
      find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock no-error.
      if not available bf_trn-doc then do:
         return error subst("Создание признака невозможно. Не найден документ &1.", pardoc-code) .
      end.
      if bf_trn-doc.obj-type <> bf_clients.obj-type or
         bf_trn-doc.obj-code <> bf_clients.obj-code then do:
         return error subst("Создание признака невозможно. Документ &1 "
                          + " не принадлежит объекту &2 &3 . ", bf_trn-doc.doc-code, bf_clients.obj-type, bf_clients.obj-code).
      end.
   end.
   find first bf_goods where bf_goods.artic     = parartic     and
                             bf_goods.prod-type = parprod-type and
                             bf_goods.prod-code = parprod-code no-lock no-error.
   if not available bf_goods then do:
      return error subst("Создание признака невозможно. Не найден товар &1 &2 &3.", parartic, parprod-code, parprod-code).
   end.
   tr:
   do transaction on error undo tr, return error return-value :
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  bf_goods.gds-code
  ,input  parprt-code
  ,input  ''
  ,input  ''
  ,input  bf_goods.unit-base
  ,input  ?
  ,output varis-new
  ,buffer bf_bar-code
  )  .
     run check-use-artic in this-procedure ( input "gds-dtl":U,
                                             input parartic,
                                             input parprod-type,
                                             input parprod-code  ) no-error.
     if error-status :error then do:
       undo tr, return error substitute( 'lib-trn_crgdsdtl: &1', return-value ).
     end.
     create bf_gds-dtl.
     assign
       bf_gds-dtl.obj-code      = parobj-code
       bf_gds-dtl.obj-type      = parobj-type
       bf_gds-dtl.doc-code      = pardoc-code
       bf_gds-dtl.artic         = parartic
       bf_gds-dtl.prod-code     = parprod-code
       bf_gds-dtl.prod-type     = parprod-type
       bf_gds-dtl.prt-code      = parprt-code.
   end.
end.
end.
end procedure.
procedure lib-trn_create-doc-line:
define input parameter parartic     like ub.doc-line.artic     no-undo.
define input parameter parprod-type like ub.doc-line.prod-type no-undo.
define input parameter parprod-code like ub.doc-line.prod-code no-undo.
define input parameter parrec-doc as recid no-undo.
define buffer cd_trn-doc  for ub.trn-doc.
define buffer cd_doc-line for ub.doc-line.
define buffer cd_goods    for ub.goods.
define buffer cd_sysconf  for ub.sysconf.
define buffer cd_gds-obj  for ub.gds-obj.
define variable v-host-code like ub.sysconf.host-code no-undo.
define variable v-cash-pay  like ub.sysconf.cash-pay  no-undo.
define variable varslt-pc   like ub.doc-line.slt-pc   no-undo.
define variable varvat-pc   like ub.doc-line.vat-pc   no-undo.
do on error undo, return error return-value :
find first cd_trn-doc where recid(cd_trn-doc) = parrec-doc.
find first cd_goods where cd_goods.artic     = parartic     and
                          cd_goods.prod-type = parprod-type and
                          cd_goods.prod-code = parprod-code no-lock.
find cd_doc-line where cd_doc-line.doc-code  = cd_trn-doc.doc-code
                   and cd_doc-line.artic     = cd_goods.artic
                   and cd_doc-line.prod-code = cd_goods.prod-code
                   and cd_doc-line.prod-type = cd_goods.prod-type no-error.
if not available cd_doc-line then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  cd_trn-doc.obj-type
  ,input  cd_trn-doc.obj-code
  ,output v-host-code
  )  .
  find first cd_sysconf where cd_sysconf.host-code = v-host-code no-lock.
  assign
    v-cash-pay = cd_sysconf.cash-pay.
  if cd_sysconf.cons-vat-pc = ? then do:
    return error "У Вас не установлен НДС для консигнационного товара по фирме.".
  end.
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  cd_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-host-code
  ,input  cd_trn-doc.obj-type
  ,input  cd_trn-doc.obj-code
  ,output varvat-pc
  ) no-error .
   if error-status :error then do:
     message return-value view-as alert-box.
     return error return-value.
   end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_st-sltpc in g#lib-trn
(
 input  recid(cd_goods)
,input  recid(cd_trn-doc)
,input  v-cash-pay
,output varslt-pc
)
no-error.
  if error-status :error then do:
    return error return-value.
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdoclin in g#lib-trn
(input cd_trn-doc.doc-code
,input cd_goods.artic
,input cd_goods.prod-type
,input cd_goods.prod-code
,input cd_trn-doc.obj-type
,input cd_trn-doc.obj-code
,input cd_trn-doc.status_
,input cd_trn-doc.ext-doc-type
,input cd_goods.prt-root
,input varvat-pc
,input varslt-pc
,input cd_sysconf.cons-vat-pc
) no-error
.
  if error-status :error then do:
    return error return-value.
  end.
  find first cd_doc-line where cd_doc-line.doc-code  = cd_trn-doc.doc-code and
                               cd_doc-line.artic     = cd_goods.artic      and
                               cd_doc-line.prod-type = cd_goods.prod-type  and
                               cd_doc-line.prod-code = cd_goods.prod-code  exclusive-lock.
  assign
   cd_doc-line.cli-qnty        = 0
   cd_doc-line.doc-qnty        = 0
   cd_doc-line.fact-qnty       = 0
   .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  cd_doc-line.obj-type
  ,input  cd_doc-line.obj-code
  ,input  cd_doc-line.artic
  ,input  cd_doc-line.prod-type
  ,input  cd_doc-line.prod-code
  ,buffer cd_gds-obj
  ) no-error .
  if error-status :error then do:
    undo, return error return-value.
  end.
end.
end.
end procedure.
procedure lib-trn_lgl-node:
define input  parameter parartic      like ub.gds-dtl.artic     no-undo.
define input  parameter parprod-type  like ub.gds-dtl.prod-type no-undo.
define input  parameter parprod-code  like ub.gds-dtl.prod-code no-undo.
define input  parameter parprt-code   like ub.gds-dtl.prt-code  no-undo.
define input  parameter parobj-type   like ub.trn-doc.obj-type  no-undo.
define input  parameter parobj-code   like ub.trn-doc.obj-code  no-undo.
define output parameter parlegal-node like ub.gds-prt.node-code no-undo.
define variable g-doc-prt as logical no-undo.
define variable v-root-node like ub.gds-prt.node-code no-undo.
do on error undo, return error return-value :
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  parobj-type
  ,input  parobj-code
  ,input  'doc-prt=request'
  ,output g-doc-prt
  )  .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parartic
  ,input  parprod-type
  ,input  parprod-code
  ,output v-root-node
  )  .
if g-doc-prt              = no  then do:
   assign
     parlegal-node = v-root-node.
end.
else do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  parprt-code
  ,output parlegal-node
  )  .
end.
end.
end procedure.
procedure lib-trn_copy-inh :
  define input  parameter parparentproc     as widget-handle no-undo.
  define input  parameter parrec-doc        as recid         no-undo.
  define input  parameter parmode           as character     no-undo.
  define input  parameter parrecalc         as logical       no-undo.
  define input  parameter parrsrv-fact-qnty as logical       no-undo.
  define input parameter table for lib-trn_ret-doc.
  define input parameter table for lib-trn_ret-line.
  define input parameter table for lib-trn_ret-line-attr.
  define input parameter table for lib-trn_ret-dtl.
  define input parameter table for lib-trn_ret-parts.
  define buffer ca_lib-trn_ret-doc       for lib-trn_ret-doc.
  define buffer ca_lib-trn_ret-line      for lib-trn_ret-line.
  define buffer ca_lib-trn_ret-line-attr for lib-trn_ret-line-attr.
  define buffer ca_lib-trn_ret-dtl       for lib-trn_ret-dtl.
  define buffer ca_lib-trn_ret-parts     for lib-trn_ret-parts.
  define variable varroot-node                   like ub.bar-code.node-code    no-undo.
  define variable delta-line-vat                 like ub.trn-doc.vat-base      no-undo.
  define variable delta-line-slt                 like ub.trn-doc.vat-base      no-undo.
  define variable chg-qnty                       like ub.gds-dtl.doc-qnty      no-undo.
  define variable fix-qnty                       like ub.gds-dtl.doc-qnty      no-undo.
  define variable mem-qnty                       like ub.gds-dtl.doc-qnty      no-undo.
  define variable temp-mes                       as   character                no-undo.
  define variable temp-ok                        as   logical                  no-undo initial yes.
  define variable v-insalepr                     as   logical                  no-undo initial ?.
  define variable parsale-price                  like ub.price-list.price-sale no-undo initial ?.
  define variable varcst-rsrv                    as   character                no-undo.
  define variable varlast-date-rsrv              as   character                no-undo.
  define variable varprice-cli-ca                like ub.doc-line.price-rubl   no-undo.
  define variable varprice-cli-unit-base-ca      like ub.doc-line.price-rubl   no-undo.
  define variable varprice-road-tax-ca           like ub.doc-line.price-rubl   no-undo.
  define variable varprice-other-exp-ca          like ub.doc-line.price-rubl   no-undo.
  define variable varprice-transport-exp-ca      like ub.doc-line.price-rubl   no-undo.
  define variable varprice-without-abs-ca        like ub.doc-line.price-rubl   no-undo.
  define variable varprice-slt-ca                like ub.doc-line.price-rubl   no-undo.
  define variable varprice-no-slt-ca             like ub.doc-line.price-rubl   no-undo.
  define variable varprice-vat-ca                like ub.doc-line.price-rubl   no-undo.
  define variable varprice-no-vat-slt-ca         like ub.doc-line.price-rubl   no-undo.
  define variable varprice-rubl-ca               like ub.doc-line.price-rubl   no-undo.
  define variable varprice-road-tax-rubl-ca      like ub.doc-line.price-rubl   no-undo.
  define variable varprice-other-exp-rubl-ca     like ub.doc-line.price-rubl   no-undo.
  define variable varprice-transport-exp-rubl-ca like ub.doc-line.price-rubl   no-undo.
  define variable varprice-without-abs-rubl-ca   like ub.doc-line.price-rubl   no-undo.
  define variable varprice-slt-rubl-ca           like ub.doc-line.price-rubl   no-undo.
  define variable varprice-no-slt-rubl-ca        like ub.doc-line.price-rubl   no-undo.
  define variable varprice-vat-rubl-ca           like ub.doc-line.price-rubl   no-undo.
  define variable varprice-no-vat-slt-rubl-ca    like ub.doc-line.price-rubl   no-undo.
  define variable varprice-base-ca               like ub.doc-line.price-base   no-undo.
  define variable varprice-road-tax-base-ca      like ub.doc-line.price-base   no-undo.
  define variable varprice-other-exp-base-ca     like ub.doc-line.price-base   no-undo.
  define variable varprice-transport-exp-base-ca like ub.doc-line.price-base   no-undo.
  define variable varprice-without-abs-base-ca   like ub.doc-line.price-base   no-undo.
  define variable varprice-slt-base-ca           like ub.doc-line.price-base   no-undo.
  define variable varprice-no-slt-base-ca        like ub.doc-line.price-base   no-undo.
  define variable varprice-vat-base-ca           like ub.doc-line.price-base   no-undo.
  define variable varprice-no-vat-slt-base-ca    like ub.doc-line.price-base   no-undo.
  define variable varlegal-node                  like ub.gds-prt.node-code     no-undo.
  define variable full-rsrv-qnty                 like ub.gds-dtl.fact-qnty     no-undo.
  define variable conf-par                       as   character                no-undo.
  define variable par-type                       as   character                no-undo.
  define variable g-doc-prt                      as   logical                  no-undo.
  define variable varr-btype                     as   character                no-undo.
  define variable varerr-recalc                  as   logical                  no-undo.
  define variable v-accum-cli-qnty               like ub.doc-line.cli-qnty     no-undo.
  define variable varpart-code-rsrv              as   character              no-undo.
  define variable var_is-petrol                  as   logical                  no-undo.
  define variable var_is-pieces                  as   logical                  no-undo.
  define variable v-density                      like ub.doc-line.fact-density no-undo.
  define variable is-doc-hold                    as   logical                  no-undo.
  define variable l_place-rsrv                   as   logical                  no-undo.
  define variable is_doc-pl_rsrv                 as   logical                  no-undo initial no.
  define variable varpl-inf                      as   character                no-undo.
  define variable v-doc-pl-rowid                 as   rowid                    no-undo.
  define variable v-has-part                     as   logical                  no-undo.
  define variable v-gds-mark       as   logical              no-undo.
  define variable v-gds-attr-value as   character            no-undo.
  define variable v-gds-attr-type  as   character            no-undo.
  define variable v-level          as   integer              no-undo.
  define variable v-is-in-doc      as   logical              no-undo init no .
  define variable v-program-name   as   character            no-undo.
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
  define buffer d-l-b       for ub.doc-line.
  define buffer old-doc     for ub.trn-doc.
  define buffer old-line    for ub.doc-line.
  define buffer old-dtl     for ub.gds-dtl.
  define buffer ca_trn-doc  for ub.trn-doc.
  define buffer ca_doc-line for ub.doc-line.
  define buffer ca_doc-line-attr for ub.doc-line-attr.
  define buffer ca_gds-dtl  for ub.gds-dtl.
  define buffer ca_parts    for ub.parts.
  define buffer ca_goods    for ub.goods.
  define buffer ca_units    for ub.units.
  define buffer ca_gds-prt  for ub.gds-prt.
  define buffer ca_shop     for ub.shop.
  define buffer ca_store    for ub.store.
  define buffer ca_doc-pl   for ub.doc-pl.
  define buffer bf_parts    for ub.parts.
  define buffer ca_clients  for ub.clients.
  define buffer bf_trn-doc  for ub.trn-doc.
do
on error undo, return error return-value
:
  if not can-do ("cr-upd,copy", parmode) then do:
    return error "Некорректный параметр parmode передан процедуре lib-trn_copy-inh.".
  end.
find first ca_trn-doc where recid(ca_trn-doc) = parrec-doc.
find first ca_clients where ca_clients.obj-type = ca_trn-doc.obj-type and
                            ca_clients.obj-code = ca_trn-doc.obj-code no-lock no-error.
if ca_trn-doc.out-code <> "" and ca_trn-doc.out-code <> ? then do:
  find first bf_trn-doc where bf_trn-doc.doc-code = ca_trn-doc.out-code no-lock no-error.
end.
find ca_lib-trn_ret-doc.
find ca_lib-trn_ret-line.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  ca_lib-trn_ret-doc.doc-code
  ,output is-doc-hold
  ) no-error .
if error-status :error or is-doc-hold = ? then do: assign is-doc-hold = no. end.
find ca_goods where ca_goods.artic        = ca_lib-trn_ret-line.artic
                and ca_goods.prod-type    = ca_lib-trn_ret-line.prod-type
                and ca_goods.prod-code    = ca_lib-trn_ret-line.prod-code no-lock.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input ca_goods.artic
  ,  input ca_goods.prod-type
  ,  input ca_goods.prod-code
  , output var_is-petrol
  , output var_is-pieces
  ) no-error.
if error-status :error then do:
  return error substitute( 'Ошибка при определении атрибута товара "топливо".&1'
                         + 'Артикул &2 &3 &4&1&7&1&8'
                         , chr(10)
                         , ca_goods.artic
                         , ca_goods.prod-type
                         , ca_goods.prod-code
                         , return-value
                         , error-status :get-message(1)
                         ).
end.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ca_trn-doc.obj-type
  ,input  ca_trn-doc.obj-code
  ,input  ca_goods.artic
  ,input  ca_goods.prod-type
  ,input  ca_goods.prod-code
  ,input  'place-rsrv=request':U
  ,output l_place-rsrv
  ) no-error .
if error-status :error then do:
  return error substitute( 'Ошибка при определении атрибута товара на объекте.&1'
                         + 'Атрибут &2&1Документ &3&1Артикул &4 &5 &6&1&7&1&8'
                         , chr(10)
                         , "'place-rsrv=request':U"
                         , ca_lib-trn_ret-doc.doc-code
                         , ca_goods.artic
                         , ca_goods.prod-type
                         , ca_goods.prod-code
                         , return-value
                         , error-status :get-message(1)
                         ).
end.
RUN gds-attr-value (
                    INPUT ca_goods.gds-code,
                    INPUT 'mark-type':U,
                    OUTPUT v-gds-attr-value,
                    OUTPUT v-gds-attr-type
                    ).
if v-gds-attr-value > ""
and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(ca_trn-doc.obj-type, ca_trn-doc.obj-code):GetIsMarkingForType(v-gds-attr-value)
then
  v-gds-mark = true .
else
  v-gds-mark = false .
assign v-level = 2 .
repeat while program-name( v-level ) <> ? :
  v-program-name = program-name( v-level ) .
  v-is-in-doc = index(v-program-name, "in-doc.") > 0 .
  if v-is-in-doc then leave .
  assign
    v-level = v-level + 1
  .
end.
if v-gds-attr-value > ""
and v-is-in-doc
and ca_trn-doc.ext-doc-type = 'ie':U
and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(ca_trn-doc.obj-type, ca_trn-doc.obj-code):IsEDO
and (ObjSrv:Env:ParametrsOfSection:GetSectionEDO(ca_trn-doc.obj-type, ca_trn-doc.obj-code):GetIsArticForType(v-gds-attr-value)
  or ObjSrv:Env:ParametrsOfSection:GetSectionEDO(ca_trn-doc.obj-type, ca_trn-doc.obj-code):GetIsEdoForType(v-gds-attr-value))
then do :
  return error ("Товар:" + ca_goods.artic + " " + ca_goods.prod-type + " " + string(ca_goods.prod-code) + " " + ca_goods.gds-name + " " + chr(10) +
                "нельзя добавлять в ручном режиме, так как он подлежит маркировке.") .
end .
if l_place-rsrv = yes then do:
  if ca_lib-trn_ret-doc.obj-type = ca_trn-doc.obj-type
    and ca_lib-trn_ret-doc.obj-code = ca_trn-doc.obj-code
  then do:
    assign
      is_doc-pl_rsrv = yes
    .
  end.
  else do:
    assign
      is_doc-pl_rsrv = no
    .
  end.
end.
find first ca_lib-trn_ret-line-attr where ca_lib-trn_ret-line-attr.doc-code  = ca_lib-trn_ret-line.doc-code and
                                          ca_lib-trn_ret-line-attr.gds-code  = ca_goods.gds-code and
                                          ca_lib-trn_ret-line-attr.attr-code = 'cst-code':U        no-error.
if available ca_lib-trn_ret-line-attr                  and
             ca_lib-trn_ret-line-attr.attr-value <> ?  and
             ca_lib-trn_ret-line-attr.attr-value <> "" then do:
   assign varcst-rsrv = "," + 'cst-code':U + "=":u + str-encode (ca_lib-trn_ret-line-attr.attr-value,  "", ",=":u ).
end.
else varcst-rsrv = "".
find first ca_lib-trn_ret-line-attr where ca_lib-trn_ret-line-attr.doc-code  = ca_lib-trn_ret-line.doc-code and
                                          ca_lib-trn_ret-line-attr.gds-code  = ca_goods.gds-code and
                                          ca_lib-trn_ret-line-attr.attr-code = 'last-date':U        no-error.
if available ca_lib-trn_ret-line-attr                  and
             ca_lib-trn_ret-line-attr.attr-value <> ?  and
             ca_lib-trn_ret-line-attr.attr-value <> "" then do:
   assign varlast-date-rsrv = "," + 'last-date':U + "=":u + str-encode (ca_lib-trn_ret-line-attr.attr-value,  "", ",=":u ).
end.
else varlast-date-rsrv = "".
for each  ca_lib-trn_ret-line-attr where ca_lib-trn_ret-line-attr.doc-code  = ca_lib-trn_ret-line.doc-code and
                                         ca_lib-trn_ret-line-attr.gds-code  = ca_goods.gds-code :
   find first  ca_doc-line-attr no-lock where
               ca_doc-line-attr.doc-code  = ca_trn-doc.doc-code and
               ca_doc-line-attr.gds-code  = ca_goods.gds-code and
               ca_doc-line-attr.attr-code = ca_lib-trn_ret-line-attr.attr-code no-error .
   if not available ca_doc-line-attr then do:
      create ca_doc-line-attr.
      buffer-copy ca_lib-trn_ret-line-attr to  ca_doc-line-attr
          assign   ca_doc-line-attr.doc-code = ca_trn-doc.doc-code
      .
   end.
end.
if ca_lib-trn_ret-line.part-code <> ?  and
   ca_lib-trn_ret-line.part-code <> "" then do:
  assign
    varpart-code-rsrv = "," + 'cre-part-code':U + "=":u
                      + str-encode (ca_lib-trn_ret-line.part-code, "", ",=":u )
  .
end.
else do:
  varpart-code-rsrv = "".
end.
find ca_gds-prt where ca_gds-prt.upper-code = ca_goods.prt-root  no-lock.
find ca_units   where ca_units.unit-name    = ca_goods.unit-base no-lock.
run lib-trn_create-doc-line in this-procedure
  ( input ca_lib-trn_ret-line.artic
   , input ca_lib-trn_ret-line.prod-type
   , input ca_lib-trn_ret-line.prod-code
   , input recid(ca_trn-doc)
  ) no-error.
if error-status :error then do:
  undo, return error return-value.
end.
find first ca_doc-line
  where ca_doc-line.doc-code  = ca_trn-doc.doc-code
    and ca_doc-line.artic     = ca_lib-trn_ret-line.artic
    and ca_doc-line.prod-type = ca_lib-trn_ret-line.prod-type
    and ca_doc-line.prod-code = ca_lib-trn_ret-line.prod-code
  .
assign
  ca_doc-line.prt-OK   = ca_lib-trn_ret-line.prt-OK
  ca_doc-line.prt-root = ca_goods.prt-root.
if ca_lib-trn_ret-doc.doc-type = 'при':U
  and ca_lib-trn_ret-doc.internal = false
then do:
  assign
     ca_doc-line.unit-cli       = ca_lib-trn_ret-line.unit-cli
     ca_doc-line.cli-base-rate  = ca_lib-trn_ret-line.cli-base-rate
     ca_doc-line.temperature    = ca_lib-trn_ret-line.temperature
     ca_doc-line.num-place      = ca_lib-trn_ret-line.num-place
     ca_doc-line.wt-brutto      = ca_lib-trn_ret-line.wt-brutto
     ca_doc-line.new-price-sale = ca_lib-trn_ret-line.new-price-sale
     ca_doc-line.vat-pc         = ca_lib-trn_ret-line.vat-pc
     ca_doc-line.slt-pc         = if ca_trn-doc.slt-type = 'без':U then 0 else ca_lib-trn_ret-line.slt-pc.
end.
else do:
  assign
     ca_doc-line.unit-cli       = ca_lib-trn_ret-line.unit-cli
     ca_doc-line.cli-base-rate  = ca_lib-trn_ret-line.cli-base-rate
   .
end.
if ca_lib-trn_ret-doc.doc-type = 'рас':U and
   not ca_lib-trn_ret-doc.internal          and
   not (ca_lib-trn_ret-doc.hold-doc-code-child = ""       or
        ca_lib-trn_ret-doc.hold-doc-code-child = "no-hold")
   then do:
  assign
    ca_doc-line.vat-pc        = ca_lib-trn_ret-line.vat-pc
    ca_doc-line.slt-pc        = if ca_trn-doc.slt-type = 'без':U then 0 else ca_lib-trn_ret-line.slt-pc.
end.
if lookup('сер':U, ca_units.type) > 0 then do:
   assign
   ca_doc-line.price-cli     = ca_lib-trn_ret-line.price-cli
   ca_doc-line.price-base    = ca_lib-trn_ret-line.price-base
   ca_doc-line.price-rubl    = ca_lib-trn_ret-line.price-rubl
   ca_doc-line.road-tax      = ca_lib-trn_ret-line.road-tax
   ca_doc-line.excise        = ca_lib-trn_ret-line.excise.
   if parmode = "cr-upd" then do:
     assign
     ca_doc-line.cli-qnty      = ca_lib-trn_ret-line.cli-qnty
     ca_doc-line.fact-qnty     = ca_lib-trn_ret-line.fact-qnty
     ca_doc-line.doc-qnty      = ca_lib-trn_ret-line.doc-qnty.
  end.
end.
else do:
  if parmode = "cr-upd" then do:
   assign
     ca_doc-line.cli-qnty      = ca_lib-trn_ret-line.cli-qnty
     ca_doc-line.fact-qnty     = ca_lib-trn_ret-line.fact-qnty
     ca_doc-line.doc-qnty      = ca_lib-trn_ret-line.doc-qnty
     ca_doc-line.doc-density   = ca_lib-trn_ret-line.doc-density
     ca_doc-line.fact-density  = ca_lib-trn_ret-line.fact-density
   .
  end.
  else do:
    if not (ca_lib-trn_ret-doc.status_ = "temp" and ca_trn-doc.flag_) then do:
      if l_place-rsrv = yes
        and var_is-petrol = true
        and var_is-pieces = false
      then do:
        assign
          ca_doc-line.doc-density  = (if parrsrv-fact-qnty then ca_lib-trn_ret-line.fact-density else ca_lib-trn_ret-line.doc-density)
          ca_doc-line.fact-density = ca_doc-line.doc-density
        .
        if valid-density( ca_doc-line.doc-density, (ca_goods.unit-base = ca_goods.unit-cli) ) <> true then do:
          undo, return error substitute( "Плотность в документе источнике имеет некорректное значение &1.", v-density ) .
        end.
        assign
          ca_doc-line.unit-cli      = ca_goods.unit-cli
          ca_doc-line.cli-base-rate = 1 / ca_doc-line.doc-density
        .
      end.
      if ca_lib-trn_ret-doc.doc-type = 'при':U
        and ca_lib-trn_ret-doc.internal = false
      then do:
        assign
          ca_doc-line.doc-qnty      = ca_doc-line.doc-qnty + (if parrsrv-fact-qnty then ca_lib-trn_ret-line.fact-qnty else ca_lib-trn_ret-line.doc-qnty)
          ca_doc-line.fact-qnty     = ca_doc-line.doc-qnty
        .
      end.
      else do:
        ca_doc-line.prt-ok      = yes.
      end.
      assign
        ca_doc-line.cli-qnty = ca_doc-line.cli-qnty +
                               ( if parrsrv-fact-qnty = yes
                                 then ca_lib-trn_ret-line.fact-qnty / ca_lib-trn_ret-line.cli-base-rate
                                 else ca_lib-trn_ret-line.doc-qnty  / ca_lib-trn_ret-line.cli-base-rate ).
    end.
  end.
  if ca_doc-line.doc-qnty = ? then do:
     assign
      ca_doc-line.doc-qnty = 0.
  end.
  if ca_lib-trn_ret-doc.doc-type = 'при':U
    and ca_lib-trn_ret-doc.internal = false
  then do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ca_trn-doc.obj-type
  ,input  ca_trn-doc.obj-code
  ,input  ca_goods.artic
  ,input  ca_goods.prod-type
  ,input  ca_goods.prod-code
  ,input  'insalepr=request':U
  ,output v-insalepr
  ) no-error .
   if error-status:error then do :
     v-insalepr = false .
   end .
   if v-insalepr = true then do:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  ca_goods.gds-code
  ,input  ca_gds-prt.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error return-value.
end.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  ca_trn-doc.obj-type
  ,input  ca_trn-doc.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  undo, return error return-value.
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  ca_trn-doc.obj-type
  ,input  ca_trn-doc.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  undo, return error return-value.
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
      if gp-price-sale = ? then do:
           undo, return error substitute ("Не могу найти продажную цену для товара: &1 &2 &3 &4.", ca_goods.artic, ca_goods.prod-type, ca_goods.prod-code, ca_goods.gds-name).
      end.
      else do:
        ASSIGN
          ca_doc-line.price-cli  = gp-price-sale * (IF g-varr-b = "base":u THEN ca_trn-doc.base-rate / ca_trn-doc.base-scale else 1)
                               / ca_trn-doc.exch-rate * ca_trn-doc.exch-scale * ca_doc-line.cli-base-rate
          ca_doc-line.price-base = gp-price-sale / (IF g-varr-b = "base":u THEN 1 else ca_trn-doc.base-rate * ca_trn-doc.base-scale)
          ca_doc-line.price-rubl = gp-price-sale * (IF g-varr-b = "base":u THEN ca_trn-doc.base-rate / ca_trn-doc.base-scale else 1)
          ca_doc-line.road-tax   = gp-road-tax
          ca_doc-line.excise     = gp-excise.
      end.
   end.
   else  do:
     if ca_doc-line.cli-base-rate <> 1 then do:
       if ca_lib-trn_ret-line.cli-base-rate <> ? and
          ca_lib-trn_ret-line.cli-base-rate <> 0 then do:
         assign
           ca_doc-line.price-cli  = ca_lib-trn_ret-line.price-cli * ca_doc-line.cli-base-rate / ca_lib-trn_ret-line.cli-base-rate.
       end.
       else do:
        assign
           ca_doc-line.price-cli  = ca_lib-trn_ret-line.price-cli * ca_doc-line.cli-base-rate.
       end.
     end.
     else do:
       assign
         ca_doc-line.price-cli  = ca_lib-trn_ret-line.price-cli.
     end.
     assign
       ca_doc-line.price-base = ca_lib-trn_ret-line.price-base
       ca_doc-line.price-rubl = ca_lib-trn_ret-line.price-rubl
       ca_doc-line.road-tax   = ca_lib-trn_ret-line.road-tax
       ca_doc-line.excise     = ca_lib-trn_ret-line.excise.
   end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   ca_trn-doc.doc-code
  ,input   ca_trn-doc.base-rate
  ,input   ca_trn-doc.base-scale
  ,input   ca_trn-doc.exch-rate
  ,input   ca_trn-doc.exch-scale
  ,input   ca_trn-doc.vat-type
  ,input   ca_trn-doc.slt-type
  ,input   ca_doc-line.artic
  ,input   ca_doc-line.prod-type
  ,input   ca_doc-line.prod-code
  ,input   ca_doc-line.price-cli
  ,input   ca_doc-line.cli-base-rate
  ,input   ca_doc-line.price-rubl
  ,input   ca_doc-line.vat-pc
  ,input   ca_doc-line.slt-pc
  ,input   ca_doc-line.road-tax
  ,input   ca_doc-line.transport-rubl
  ,input   ca_doc-line.other-rubl
  ,output  varprice-cli-ca
  ,output  varprice-cli-unit-base-ca
  ,output  varprice-road-tax-ca
  ,output  varprice-other-exp-ca
  ,output  varprice-transport-exp-ca
  ,output  varprice-without-abs-ca
  ,output  varprice-slt-ca
  ,output  varprice-no-slt-ca
  ,output  varprice-vat-ca
  ,output  varprice-no-vat-slt-ca
  ,output  varprice-rubl-ca
  ,output  varprice-road-tax-rubl-ca
  ,output  varprice-other-exp-rubl-ca
  ,output  varprice-transport-exp-rubl-ca
  ,output  varprice-without-abs-rubl-ca
  ,output  varprice-slt-rubl-ca
  ,output  varprice-no-slt-rubl-ca
  ,output  varprice-vat-rubl-ca
  ,output  varprice-no-vat-slt-rubl-ca
  ,output  varprice-base-ca
  ,output  varprice-road-tax-base-ca
  ,output  varprice-other-exp-base-ca
  ,output  varprice-transport-exp-base-ca
  ,output  varprice-without-abs-base-ca
  ,output  varprice-slt-base-ca
  ,output  varprice-no-slt-base-ca
  ,output  varprice-vat-base-ca
  ,output  varprice-no-vat-slt-base-ca
  ) no-error.
    if error-status :error then do:
      undo, return error return-value.
    end.
    assign
     ca_doc-line.price-cli  = varprice-cli-ca
     ca_doc-line.price-rubl = varprice-rubl-ca
     ca_doc-line.price-base = varprice-base-ca.
  end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt':u
  ,input  0
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  yes
  ,output conf-par
  ,output par-type
  ) no-error .
  if ca_trn-doc.obj-type = 'маг':U then do:
     find first ca_shop where ca_shop.obj-code = ca_trn-doc.obj-code no-lock.
     if conf-par = "yes" and
        ca_shop.doc-prt  then do:
       assign
       g-doc-prt = yes.
     end.
     else do:
       assign
       g-doc-prt = no.
     end.
  end.
  else do:
    find first ca_store where ca_store.obj-code = ca_trn-doc.obj-code no-lock.
    if conf-par = "yes" and
       ca_store.doc-prt  then do:
      assign
      g-doc-prt = yes.
    end.
    else do:
      assign
      g-doc-prt = no.
    end.
  end.
  if parmode = "cr-upd" then do:
    assign varlegal-node = ca_gds-prt.node-code.
    if (ca_gds-prt.node-name = '_Пустая шкала':U or not g-doc-prt) then do:
       find ca_gds-dtl where ca_gds-dtl.doc-code   = ca_trn-doc.doc-code
                         and ca_gds-dtl.artic      = ca_goods.artic
                         and ca_gds-dtl.prod-code  = ca_goods.prod-code
                         and ca_gds-dtl.prod-type  = ca_goods.prod-type
                         and ca_gds-dtl.prt-code   = varlegal-node no-error.
       if not available ca_gds-dtl then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input ca_trn-doc.obj-code
   ,input ca_trn-doc.obj-type
   ,input ca_trn-doc.doc-code
   ,input ca_goods.artic
   ,input ca_goods.prod-code
   ,input ca_goods.prod-type
   ,input varlegal-node
   ,input yes
  ) no-error .
         if error-status :error then do:
            return error return-value.
         end.
         find first ca_gds-dtl where ca_gds-dtl.doc-code  = ca_trn-doc.doc-code and
                                     ca_gds-dtl.artic     = ca_goods.artic         and
                                     ca_gds-dtl.prod-code = ca_goods.prod-code     and
                                     ca_gds-dtl.prod-type = ca_goods.prod-type     and
                                     ca_gds-dtl.prt-code  = varlegal-node.
         assign
             ca_gds-dtl.doc-qnty      = 0
             ca_gds-dtl.fact-qnty     = 0.
        end.
        if is_doc-pl_rsrv = yes then do:
          for each ca_parts no-lock
            where ca_parts.obj-type  = ca_trn-doc.obj-type
              and ca_parts.obj-code  = ca_trn-doc.obj-code
              and ca_parts.artic     = ca_goods.artic
              and ca_parts.prod-type = ca_goods.prod-type
              and ca_parts.prod-code = ca_goods.prod-code
              and ca_parts.in-code   = ca_trn-doc.doc-code
              and ca_parts.out-code  = ca_trn-doc.doc-code
          on error undo, return error return-value
          :
            find first ca_doc-pl no-lock
              where ca_doc-pl.obj-type = ca_parts.obj-type
                and ca_doc-pl.obj-code = ca_parts.obj-code
                and ca_doc-pl.out-code = ca_trn-doc.doc-code
                and ca_doc-pl.gds-code = ca_goods.gds-code
                and ca_doc-pl.pl-code  = ca_parts.pl-code
              no-error .
            if not available ca_doc-pl then do:
              assign
                chg-qnty = 0.0 - ca_parts.fact-qnty
                mem-qnty = chg-qnty
              .
              run trg/rsrv-dtl.p
                ( input        parparentproc,
                  input        'reserv':U
                              + (
                                  if ca_lib-trn_ret-line.cst-code <> ? and ca_lib-trn_ret-line.cst-code <> ""
                                  then "," + 'cst-code':U + "=":u + str-encode( ca_lib-trn_ret-line.cst-code, "", ",=":u )
                                  else ""
                                )
                              + "," + 'cli-qnty':U      + "=":U + string( 0 )
                              + "," + 'cre-part-code':U + "=":U + string( ca_parts.pl-code  )
                              + "," + 'plcode':U       + "=":U + string( ca_parts.pl-code  )
                              ,
                  buffer       ca_gds-dtl,
                  input-output chg-qnty,
                  input-output ca_doc-line.price-base,
                  input-output ca_doc-line.price-rubl,
                  input        -1,
                  input        if v-gds-mark then ("copy-ret" + chr(4) + ca_lib-trn_ret-doc.doc-code) else ""
                ) no-error.
              if error-status :error
                or chg-qnty <> mem-qnty
              then do:
                undo, return error return-value.
              end.
            end.
          end.
          for each ca_doc-pl no-lock
            where ca_doc-pl.obj-type = ca_doc-line.obj-type
              and ca_doc-pl.obj-code = ca_doc-line.obj-code
              and ca_doc-pl.out-code = ca_doc-line.doc-code
              and ca_doc-pl.gds-code = ca_goods.gds-code
            break by ca_doc-pl.pl-code
          on error undo, return error return-value
          :
            find first ca_parts no-lock
              where ca_parts.obj-type  = ca_trn-doc.obj-type
                and ca_parts.obj-code  = ca_trn-doc.obj-code
                and ca_parts.artic     = ca_goods.artic
                and ca_parts.prod-type = ca_goods.prod-type
                and ca_parts.prod-code = ca_goods.prod-code
                and ca_parts.in-code   = ca_trn-doc.doc-code
                and ca_parts.out-code  = ca_trn-doc.doc-code
                and ca_parts.pl-code   = ca_doc-pl.pl-code
              no-error.
            assign
              chg-qnty = ( if ca_trn-doc.flag_ = yes then ca_doc-pl.fact-qnty else ca_doc-pl.doc-qnty )
                         - ( if available ca_parts then ca_parts.fact-qnty else 0.00 )
              mem-qnty = chg-qnty
            .
            run trg/rsrv-dtl.p
              ( input        parparentproc,
                input        'reserv':U
                            + (
                                if ca_lib-trn_ret-line.cst-code <> ? and ca_lib-trn_ret-line.cst-code <> ""
                                then "," + 'cst-code':U + "=":u + str-encode( ca_lib-trn_ret-line.cst-code, "", ",=":u )
                                else ""
                              )
                            + "," + 'cli-qnty':U      + "=":U + string( ca_doc-pl.cli-qnty )
                            + "," + 'cre-part-code':U + "=":U + string( ca_doc-pl.pl-code  )
                            + "," + 'plcode':U       + "=":U + string( ca_doc-pl.pl-code  )
                            ,
                buffer       ca_gds-dtl,
                input-output chg-qnty,
                input-output ca_doc-line.price-base,
                input-output ca_doc-line.price-rubl,
                input        -1,
                input        if v-gds-mark then ("copy-ret" + chr(4) + ca_lib-trn_ret-doc.doc-code) else ""
              ) no-error.
            if error-status :error
              or chg-qnty <> mem-qnty
            then do:
              undo, return error return-value.
            end.
          end.
          for each ca_doc-pl no-lock
            where ca_doc-pl.obj-type = ca_trn-doc.obj-type
              and ca_doc-pl.obj-code = ca_trn-doc.obj-code
              and ca_doc-pl.out-code = ca_trn-doc.doc-code
              and ca_doc-pl.gds-code = ca_goods.gds-code
            break by ca_doc-pl.pl-code
          on error undo, return error return-value
          :
            find first ca_parts no-lock
              where ca_parts.obj-type  = ca_doc-pl.obj-type
                and ca_parts.obj-code  = ca_doc-pl.obj-code
                and ca_parts.artic     = ca_goods.artic
                and ca_parts.prod-type = ca_goods.prod-type
                and ca_parts.prod-code = ca_goods.prod-code
                and ca_parts.in-code   = ca_trn-doc.doc-code
                and ca_parts.out-code  = ca_trn-doc.doc-code
                and ca_parts.pl-code   = ca_doc-pl.pl-code
              no-error.
            if available ca_parts then do:
              find first bf_parts no-lock
                where bf_parts.obj-type  =  ca_parts.obj-type
                  and bf_parts.obj-code  =  ca_parts.obj-code
                  and bf_parts.artic     =  ca_parts.artic
                  and bf_parts.prod-type =  ca_parts.prod-type
                  and bf_parts.prod-code =  ca_parts.prod-code
                  and bf_parts.in-code   =  ca_parts.in-code
                  and bf_parts.out-code  =  ca_parts.out-code
                  and bf_parts.part-code <> ca_parts.part-code
                  and bf_parts.pl-code   =  ca_parts.pl-code
                no-error.
              if available bf_parts then do:
                undo, return error substitute ("Найдены две партии товара &1 &2 &3 привязанные к одному месту хранения &4.", ca_goods.artic, ca_goods.prod-type, ca_goods.prod-code, ca_doc-pl.pl-code).
              end.
            end.
            else do:
              find first bf_parts no-lock
                where bf_parts.obj-type  = ca_trn-doc.obj-type
                  and bf_parts.obj-code  = ca_trn-doc.obj-code
                  and bf_parts.artic     = ca_goods.artic
                  and bf_parts.prod-type = ca_goods.prod-type
                  and bf_parts.prod-code = ca_goods.prod-code
                  and bf_parts.in-code   = ca_trn-doc.doc-code
                  and bf_parts.out-code  = ca_trn-doc.doc-code
                no-error.
              if available bf_parts
                and ( bf_parts.pl-code = 0
                      or bf_parts.pl-code = ?
                    )
              then do:
                undo, return error substitute ("Обнаружены партии по товару &1 &2 &3 не привязанные к месту хранения!!!", ca_goods.artic, ca_goods.prod-type, ca_goods.prod-code).
              end.
            end.
          end.
        end.
        else do:
          assign
            chg-qnty = (if ca_trn-doc.flag_ then (ca_doc-line.fact-qnty - ca_gds-dtl.fact-qnty) else (ca_doc-line.doc-qnty - ca_gds-dtl.doc-qnty))
            mem-qnty = chg-qnty
          .
          run trg/rsrv-dtl.p
            ( input parparentproc
             ,input 'reserv':U
                    + (
                        if ca_lib-trn_ret-line.cst-code <> ? and ca_lib-trn_ret-line.cst-code <> "" then "," + 'cst-code':U + "=":u + str-encode (ca_lib-trn_ret-line.cst-code,  "", ",=":u ) else "")
                        + "," + 'cli-qnty':U + "=":u + string(ca_doc-line.cli-qnty)
                        + varpart-code-rsrv
             ,buffer ca_gds-dtl
             ,input-output chg-qnty
             ,input-output ca_doc-line.price-base
             ,input-output ca_doc-line.price-rubl
             ,input -1
             ,input if v-gds-mark then ("copy-ret" + chr(4) + ca_lib-trn_ret-doc.doc-code) else ""
            ) no-error.
          if error-status :error
            or chg-qnty <> mem-qnty
          then do:
            undo, return error return-value.
          end.
        end.
        assign
          ca_gds-dtl.doc-qnty     = ca_doc-line.doc-qnty
          ca_gds-dtl.fact-qnty    = ca_doc-line.fact-qnty
          ca_doc-line.prt-OK      = yes
        .
    end.
  end.
  else do:
    for each ca_lib-trn_ret-dtl no-lock
      where ca_lib-trn_ret-dtl.prod-type = ca_goods.prod-type
        and ca_lib-trn_ret-dtl.prod-code = ca_goods.prod-code
        and ca_lib-trn_ret-dtl.artic     = ca_goods.artic
        and ca_lib-trn_ret-dtl.doc-code  = ca_lib-trn_ret-line.doc-code
      break by ca_lib-trn_ret-dtl.prod-type
            by ca_lib-trn_ret-dtl.prod-code
            by ca_lib-trn_ret-dtl.artic
    on error undo, return error return-value
    :
       if ca_doc-line.price-cli = 0 or ca_doc-line.price-cli = ? then do:
         if ca_lib-trn_ret-doc.doc-type = 'при':U and
            not ca_lib-trn_ret-doc.internal then do:
            if lookup('2ед':U, ca_units.type) = 0 then do:
              assign
              ca_doc-line.price-cli  = ca_lib-trn_ret-line.price-cli.
            end.
            else do:
              assign
              ca_doc-line.price-base = ca_lib-trn_ret-line.price-base
              ca_doc-line.price-rubl = ca_lib-trn_ret-line.price-rubl.
            end.
            assign
              ca_doc-line.road-tax   = ca_lib-trn_ret-line.road-tax
              ca_doc-line.excise     = ca_lib-trn_ret-line.excise.
         end.
         else do:
           if ca_trn-doc.exch-code           = 0 and
              (ca_lib-trn_ret-dtl.price-rubl - ca_lib-trn_ret-dtl.discnt-rubl) <> 0 and
              (ca_lib-trn_ret-dtl.price-rubl - ca_lib-trn_ret-dtl.discnt-rubl) <> ? then do:
              assign
                ca_doc-line.price-cli = (ca_lib-trn_ret-dtl.price-rubl - ca_lib-trn_ret-dtl.discnt-rubl - (if g-varr-b = "rubl" then ca_lib-trn_ret-line.road-tax else ca_lib-trn_ret-line.road-tax * ca_trn-doc.base-rate / ca_trn-doc.base-scale)) * ca_doc-line.cli-base-rate.
                ca_doc-line.road-tax  = ca_lib-trn_ret-line.road-tax.
           end.
           else do:
             if ca_trn-doc.exch-code  = ca_lib-trn_ret-doc.exch-code                  and
                ca_lib-trn_ret-doc.exch-code   <> 0                                   and
                (ca_lib-trn_ret-dtl.price-base - ca_lib-trn_ret-dtl.discnt-base) <> 0 and
                (ca_lib-trn_ret-dtl.price-base - ca_lib-trn_ret-dtl.discnt-base) <> ? then do:
                assign
                  ca_doc-line.price-cli = (ca_lib-trn_ret-dtl.price-base - ca_lib-trn_ret-dtl.discnt-base - (if g-varr-b = "base" then ca_lib-trn_ret-line.road-tax else ca_lib-trn_ret-line.road-tax / ca_trn-doc.base-rate * ca_trn-doc.base-scale)) * ca_doc-line.cli-base-rate.
                  ca_doc-line.road-tax  = ca_lib-trn_ret-line.road-tax.
             end.
           end.
         end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   ca_trn-doc.doc-code
  ,input   ca_trn-doc.base-rate
  ,input   ca_trn-doc.base-scale
  ,input   ca_trn-doc.exch-rate
  ,input   ca_trn-doc.exch-scale
  ,input   ca_trn-doc.vat-type
  ,input   ca_trn-doc.slt-type
  ,input   ca_doc-line.artic
  ,input   ca_doc-line.prod-type
  ,input   ca_doc-line.prod-code
  ,input   ca_doc-line.price-cli
  ,input   ca_doc-line.cli-base-rate
  ,input   ca_doc-line.price-rubl
  ,input   ca_doc-line.vat-pc
  ,input   ca_doc-line.slt-pc
  ,input   ca_doc-line.road-tax
  ,input   ca_doc-line.transport-rubl
  ,input   ca_doc-line.other-rubl
  ,output  varprice-cli-ca
  ,output  varprice-cli-unit-base-ca
  ,output  varprice-road-tax-ca
  ,output  varprice-other-exp-ca
  ,output  varprice-transport-exp-ca
  ,output  varprice-without-abs-ca
  ,output  varprice-slt-ca
  ,output  varprice-no-slt-ca
  ,output  varprice-vat-ca
  ,output  varprice-no-vat-slt-ca
  ,output  varprice-rubl-ca
  ,output  varprice-road-tax-rubl-ca
  ,output  varprice-other-exp-rubl-ca
  ,output  varprice-transport-exp-rubl-ca
  ,output  varprice-without-abs-rubl-ca
  ,output  varprice-slt-rubl-ca
  ,output  varprice-no-slt-rubl-ca
  ,output  varprice-vat-rubl-ca
  ,output  varprice-no-vat-slt-rubl-ca
  ,output  varprice-base-ca
  ,output  varprice-road-tax-base-ca
  ,output  varprice-other-exp-base-ca
  ,output  varprice-transport-exp-base-ca
  ,output  varprice-without-abs-base-ca
  ,output  varprice-slt-base-ca
  ,output  varprice-no-slt-base-ca
  ,output  varprice-vat-base-ca
  ,output  varprice-no-vat-slt-base-ca
  ) no-error.
         if error-status :error then do:
           undo, return error return-value.
         end.
         assign
           ca_doc-line.price-cli  = varprice-cli-ca
           ca_doc-line.price-rubl = varprice-rubl-ca
           ca_doc-line.price-base = varprice-base-ca.
       end.
       if ca_trn-doc.status_ = 'накл':U and
          ca_doc-line.price-cli = ? then do:
          undo, return error substitute ("Артикул : &1 &2 Цена не может быть определена !", ca_goods.artic, ca_goods.gds-name).
       end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_lgl-node in g#lib-trn
  ( input  ca_lib-trn_ret-dtl.artic
   ,input  ca_lib-trn_ret-dtl.prod-type
   ,input  ca_lib-trn_ret-dtl.prod-code
   ,input  ca_lib-trn_ret-dtl.prt-code
   ,input  ca_trn-doc.obj-type
   ,input  ca_trn-doc.obj-code
   ,output varlegal-node
  ) no-error .
       if error-status :error then return error return-value.
       find ca_gds-dtl where ca_gds-dtl.doc-code   = ca_trn-doc.doc-code
                         and ca_gds-dtl.artic      = ca_goods.artic
                         and ca_gds-dtl.prod-code  = ca_goods.prod-code
                         and ca_gds-dtl.prod-type  = ca_goods.prod-type
                         and ca_gds-dtl.prt-code   = varlegal-node no-error.
       if not available ca_gds-dtl then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input ca_trn-doc.obj-code
   ,input ca_trn-doc.obj-type
   ,input ca_trn-doc.doc-code
   ,input ca_goods.artic
   ,input ca_goods.prod-code
   ,input ca_goods.prod-type
   ,input varlegal-node
   ,input yes
  ) no-error .
         if error-status :error then do:
            return error return-value.
         end.
         find first ca_gds-dtl where ca_gds-dtl.doc-code  = ca_trn-doc.doc-code and
                                     ca_gds-dtl.artic     = ca_goods.artic      and
                                     ca_gds-dtl.prod-code = ca_goods.prod-code  and
                                     ca_gds-dtl.prod-type = ca_goods.prod-type  and
                                     ca_gds-dtl.prt-code  = varlegal-node.
         assign
           ca_gds-dtl.doc-qnty      = 0
           ca_gds-dtl.fact-qnty     = 0.
       end.
        if is_doc-pl_rsrv = yes then do:
          if first-of(ca_lib-trn_ret-dtl.artic) then do:
            assign
              full-rsrv-qnty = 0
            .
            for each ca_lib-trn_ret-parts no-lock
              where ca_lib-trn_ret-parts.out-code  = ca_lib-trn_ret-dtl.doc-code
                and ca_lib-trn_ret-parts.obj-type  = ca_lib-trn_ret-dtl.obj-type
                and ca_lib-trn_ret-parts.obj-code  = ca_lib-trn_ret-dtl.obj-code
                and ca_lib-trn_ret-parts.artic     = ca_lib-trn_ret-dtl.artic
                and ca_lib-trn_ret-parts.prod-type = ca_lib-trn_ret-dtl.prod-type
                and ca_lib-trn_ret-parts.prod-code = ca_lib-trn_ret-dtl.prod-code
            on error undo, return error return-value
            :
              assign
                chg-qnty = (if parrsrv-fact-qnty then ca_lib-trn_ret-parts.fact-qnty else ca_lib-trn_ret-parts.qnty)
                fix-qnty = chg-qnty
              .
              run trg/rsrv-dtl.p
                ( input        parparentproc,
                  input        'reserv':U
                              + (
                                  if ca_lib-trn_ret-line.cst-code <> ? and ca_lib-trn_ret-line.cst-code <> ""
                                  then "," + 'cst-code':U + "=":u + str-encode( ca_lib-trn_ret-line.cst-code, "", ",=":u )
                                  else ""
                                )
                              + "," + 'cli-qnty':U      + "=":U + string( chg-qnty / ca_doc-line.cli-base-rate )
                              + "," + 'cre-part-code':U + "=":U + string( ca_lib-trn_ret-parts.pl-code  )
                              + "," + 'plcode':U       + "=":U + string( ca_lib-trn_ret-parts.pl-code  )
                              ,
                  buffer       ca_gds-dtl,
                  input-output chg-qnty,
                  input-output ca_doc-line.price-base,
                  input-output ca_doc-line.price-rubl,
                  input        -1,
                  input        if v-gds-mark then ("copy-ret" + chr(4) + ca_lib-trn_ret-doc.doc-code) else ""
                ) no-error.
              if chg-qnty <> fix-qnty then do:
                undo, return error substitute( "Не удалось скопировать полностью товар: &1 &2 &3 во внешнюю приходную накладную."
                                               ,ca_gds-dtl.artic
                                               ,ca_gds-dtl.prod-type
                                               ,ca_gds-dtl.prod-code
                                             ).
              end.
              assign
                full-rsrv-qnty = full-rsrv-qnty + chg-qnty
              .
              find first ca_doc-pl
                where ca_doc-pl.obj-type = ca_trn-doc.obj-type
                  and ca_doc-pl.obj-code = ca_trn-doc.obj-code
                  and ca_doc-pl.pl-code  = ca_lib-trn_ret-parts.pl-code
                  and ca_doc-pl.out-code = ca_trn-doc.doc-code
                  and ca_doc-pl.gds-code = ca_goods.gds-code
                no-error .
              if not available ca_doc-pl then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdocpl in g#lib-trn
(input  ca_trn-doc.doc-code
,input  ca_goods.gds-code
,input  ca_lib-trn_ret-parts.pl-code
,input  ca_trn-doc.obj-type
,input  ca_trn-doc.obj-code
,output v-doc-pl-rowid
) no-error
.
                find first ca_doc-pl
                  where rowid( ca_doc-pl ) = v-doc-pl-rowid
                  .
              end.
              assign
                ca_doc-pl.doc-qnty      = ca_doc-pl.doc-qnty + chg-qnty
                ca_doc-pl.fact-qnty     = ca_doc-pl.doc-qnty
                ca_doc-pl.cli-qnty      = ca_doc-pl.doc-qnty / ca_doc-line.cli-base-rate
                ca_doc-pl.cli-doc-qnty  = ca_doc-pl.doc-qnty * ca_doc-line.doc-density
                ca_doc-pl.cli-fact-qnty = ca_doc-pl.cli-doc-qnty
              .
            end.
          end.
          if not ( ca_lib-trn_ret-doc.doc-type = 'при':U
                   and ca_lib-trn_ret-doc.internal = false
                  )
          then do:
            assign
              ca_doc-line.doc-qnty     = ca_doc-line.doc-qnty + full-rsrv-qnty
              ca_doc-line.cli-qnty     = ca_doc-line.doc-qnty / ca_doc-line.cli-base-rate
              ca_doc-line.fact-qnty    = ca_doc-line.doc-qnty
            .
          end.
        end.
        else do:
          if ca_lib-trn_ret-doc.status_ = "temp":u
            and ca_trn-doc.flag_
          then do:
            assign chg-qnty = ca_lib-trn_ret-dtl.fact-qnty.
            run trg/rsrv-dtl.p (input parparentproc,
                                'reserv':U + varcst-rsrv + varlast-date-rsrv + varpart-code-rsrv,
                                buffer ca_gds-dtl,
                                input-output chg-qnty,
                                input-output ca_doc-line.price-base,
                                input-output ca_doc-line.price-rubl,
                                input -1,
                                input if v-gds-mark then ("copy-ret" + chr(4) + ca_lib-trn_ret-doc.doc-code) else ""
                                ) no-error.
            if error-status :error then undo, return error return-value.
            assign
              ca_gds-dtl.fact-qnty  = ca_gds-dtl.fact-qnty  + chg-qnty
              ca_doc-line.fact-qnty = ca_doc-line.fact-qnty + chg-qnty.
          end.
          else do:
            assign full-rsrv-qnty = 0.
            if ca_lib-trn_ret-doc.status_                  = 'запрос':U or
              substring(ca_lib-trn_ret-doc.doc-code, 1, 6) = "import"   then do:
              v-has-part = can-find ( first ca_lib-trn_ret-parts no-lock
                      where ca_lib-trn_ret-parts.out-code  = ca_lib-trn_ret-dtl.doc-code
                        and ca_lib-trn_ret-parts.obj-type  = ca_lib-trn_ret-dtl.obj-type
                        and ca_lib-trn_ret-parts.obj-code  = ca_lib-trn_ret-dtl.obj-code
                        and ca_lib-trn_ret-parts.artic     = ca_lib-trn_ret-dtl.artic
                        and ca_lib-trn_ret-parts.prod-type = ca_lib-trn_ret-dtl.prod-type
                        and ca_lib-trn_ret-parts.prod-code = ca_lib-trn_ret-dtl.prod-code ) .
                if ca_lib-trn_ret-doc.status_  = 'запрос':U or v-has-part = false  then do:
                        assign
                          chg-qnty = ca_lib-trn_ret-dtl.fact-qnty.
                        run trg/rsrv-dtl.p (
                            input parparentproc,
                            'reserv':U + varcst-rsrv + varlast-date-rsrv + varpart-code-rsrv,
                            buffer ca_gds-dtl,
                            input-output chg-qnty,
                            input-output ca_doc-line.price-base,
                            input-output ca_doc-line.price-rubl,
                            input -1,
                            input if v-gds-mark then ("copy-ret" + chr(4) + ca_lib-trn_ret-doc.doc-code) else ""
                            )  no-error.
                end.
                if substring(ca_lib-trn_ret-doc.doc-code, 1, 6) = "import" and v-has-part = true  then do:
                    assign
                      full-rsrv-qnty = 0
                    .
                    for each ca_lib-trn_ret-parts no-lock
                      where ca_lib-trn_ret-parts.out-code  = ca_lib-trn_ret-dtl.doc-code
                        and ca_lib-trn_ret-parts.obj-type  = ca_lib-trn_ret-dtl.obj-type
                        and ca_lib-trn_ret-parts.obj-code  = ca_lib-trn_ret-dtl.obj-code
                        and ca_lib-trn_ret-parts.artic     = ca_lib-trn_ret-dtl.artic
                        and ca_lib-trn_ret-parts.prod-type = ca_lib-trn_ret-dtl.prod-type
                        and ca_lib-trn_ret-parts.prod-code = ca_lib-trn_ret-dtl.prod-code
                    on error undo, return error return-value
                    :
                      assign
                        chg-qnty = (if parrsrv-fact-qnty then ca_lib-trn_ret-parts.fact-qnty else ca_lib-trn_ret-parts.qnty)
                        fix-qnty = chg-qnty
                      .
                      run trg/rsrv-dtl.p
                        ( input        parparentproc,
                          input        'reserv':U
                                      + ( if ca_lib-trn_ret-parts.cst-code <> ? and ca_lib-trn_ret-parts.cst-code <> ""
                                          then "," + 'cst-code':U + "=":u  + str-encode( ca_lib-trn_ret-parts.cst-code, "", ",=":u )
                                          else ""
                                        )
                                      + ( if ca_lib-trn_ret-parts.dop <> ""
                                          then  "," + 'dop':u + "=":U + str-encode(string(ca_lib-trn_ret-parts.dop), "", ",=":u)
                                          else ""
                                        )
                                      + ( if ca_lib-trn_ret-parts.last-date <> ?
                                          then  "," + 'last-date':U + "=":U + str-encode(string(ca_lib-trn_ret-parts.last-date), "", ",=":u)
                                          else ""
                                        )
                                      + "," + 'cli-qnty':U      + "=":U + string( chg-qnty / ca_doc-line.cli-base-rate )
                                      + ( if ca_lib-trn_ret-parts.part-code <> ? and ca_lib-trn_ret-parts.part-code <> ""
                                          then  "," + 'cre-part-code':U + "=":U + str-encode (ca_lib-trn_ret-parts.part-code, "", ",=":u )
                                          else ""
                                        )
                                      ,
                          buffer       ca_gds-dtl,
                          input-output chg-qnty,
                          input-output ca_doc-line.price-base,
                          input-output ca_doc-line.price-rubl,
                          input        -1,
                          input        if v-gds-mark then ("copy-ret" + chr(4) + ca_lib-trn_ret-doc.doc-code) else ""
                        ) no-error.
                    end.
                end.
              if error-status :error then undo, return error return-value.
              assign
                ca_gds-dtl.doc-qnty  = ca_gds-dtl.doc-qnty + chg-qnty.
                ca_gds-dtl.fact-qnty = ca_gds-dtl.doc-qnty.
              assign full-rsrv-qnty = chg-qnty.
            end.
            else do:
              if ca_trn-doc.doc-type = 'при':U and
                  not ca_trn-doc.internal         and
                  (ca_lib-trn_ret-doc.status_ <> "temp" or
                  ca_trn-doc.hold-doc-code-parent <> "") and
                  parrsrv-fact-qnty               = yes
                  then do:
                  if first-of(ca_lib-trn_ret-dtl.artic) then do:
                    for each ca_lib-trn_ret-parts where ca_lib-trn_ret-parts.out-code  = ca_lib-trn_ret-dtl.doc-code  AND
                                                        ca_lib-trn_ret-parts.obj-type  = ca_lib-trn_ret-dtl.obj-type  AND
                                                        ca_lib-trn_ret-parts.obj-code  = ca_lib-trn_ret-dtl.obj-code  AND
                                                        ca_lib-trn_ret-parts.artic     = ca_lib-trn_ret-dtl.artic     AND
                                                        ca_lib-trn_ret-parts.prod-type = ca_lib-trn_ret-dtl.prod-type AND
                                                        ca_lib-trn_ret-parts.prod-code = ca_lib-trn_ret-dtl.prod-code NO-LOCK:
                      ASSIGN
                        chg-qnty = ca_lib-trn_ret-parts.fact-qnty
                        fix-qnty = chg-qnty
                      .
                      assign
                          varpl-inf = (if ca_trn-doc.ext-doc-type = 'ie':U and trim(ca_lib-trn_ret-parts.part-code) > "" then "," +  'cre-part-code':U + "=":U + str-encode(ca_lib-trn_ret-parts.part-code, "", ",=":u) else "":u).
                      if ca_trn-doc.hold-doc-code-parent <> "" then do:
                        run trg/rsrv-dtl.p
                          (input parparentproc,
                          'reserv':U + "," +
                            'hold-code-parent':U + "=" + str-encode(ca_lib-trn_ret-parts.in-code, "", ",=":u)
                            + "," + 'part-code-parent':U + "=" + str-encode(ca_lib-trn_ret-parts.part-code, "", ",=":u)
                            + "," + 'hold-date':U        + "=" + str-encode(string(ca_lib-trn_ret-parts.hold-date), "", ",=":u)
                            + "," + 'last-date':U        + "=" + str-encode(string(ca_lib-trn_ret-parts.last-date), "", ",=":u)
                            + "," + 'cst-code':U + "=" + str-encode(ca_lib-trn_ret-parts.cst-code, "", ",=":u)
                            + "," + 'cli-qnty':U + "=" + string(ca_lib-trn_ret-parts.cli-qnty)
                            + varpl-inf
                            ,
                            buffer ca_gds-dtl,
                            input-output chg-qnty,
                            input-output ca_doc-line.price-base,
                            input-output ca_doc-line.price-rubl,
                            input -1,
                            input if v-gds-mark then ("copy-ret" + chr(4) + ca_lib-trn_ret-doc.doc-code) else ""
                            ) no-error.
                        if error-status :error then do:
                            undo, return error return-value.
                        end.
                      end.
                      else do:
                        assign
                          varpl-inf = (if available bf_trn-doc and bf_trn-doc.ext-doc-type = 'we':U and ca_lib-trn_ret-parts.pl-code <> 0 and ca_lib-trn_ret-parts.pl-code <> ? then "," +  'plcode':U + "=":U + string( ca_lib-trn_ret-parts.pl-code  ) else "":u).
                        run trg/rsrv-dtl.p
                          (input parparentproc,
                          'reserv':U
                            + "," + 'cst-code':U + "=" + str-encode(ca_lib-trn_ret-parts.cst-code, "", ",=":u)
                            + "," + 'cre-part-code':U + "=" + (if ca_lib-trn_ret-doc.doc-type = 'при':U and ca_lib-trn_ret-doc.internal = no then str-encode(ca_lib-trn_ret-parts.part-code, "", ",=":u) else str-encode("#":u + ca_lib-trn_ret-parts.in-code, "", ",=":u))
                            + "," + 'last-date':U + "=" + str-encode(string(ca_lib-trn_ret-parts.last-date), "", ",=":u)
                            + varpl-inf
                            ,
                            buffer ca_gds-dtl,
                            input-output chg-qnty,
                            input-output ca_doc-line.price-base,
                            input-output ca_doc-line.price-rubl,
                            input -1,
                            input if v-gds-mark then ("copy-ret" + chr(4) + ca_lib-trn_ret-doc.doc-code) else ""
                            ) no-error.
                        if error-status :error then do:
                            undo, return error return-value.
                        end.
                      end.
                      if chg-qnty <> fix-qnty then do:
                          undo, return error substitute ("Не удалось скопировать полностью товар: &1 &2 &3 во внешнюю приходную накладную.",
                                                        ca_gds-dtl.artic,
                                                        ca_gds-dtl.prod-type,
                                                        ca_gds-dtl.prod-code ) .
                      end.
                    end.
                  end.
                  assign
                    ca_gds-dtl.doc-qnty  = ca_gds-dtl.doc-qnty + ca_lib-trn_ret-dtl.doc-qnty.
                    ca_gds-dtl.fact-qnty = ca_gds-dtl.doc-qnty.
                  assign full-rsrv-qnty = ca_lib-trn_ret-dtl.doc-qnty.
              end.
              else do:
                  if parrsrv-fact-qnty then do:
                    assign
                      chg-qnty = ca_lib-trn_ret-dtl.fact-qnty.
                  end.
                  else do:
                    assign
                      chg-qnty = ca_lib-trn_ret-dtl.doc-qnty.
                  end.
                  run trg/rsrv-dtl.p (input parparentproc,
                            'reserv':U + varcst-rsrv + varlast-date-rsrv + varpart-code-rsrv,
                            buffer ca_gds-dtl,
                            input-output chg-qnty,
                            input-output ca_doc-line.price-base,
                            input-output ca_doc-line.price-rubl,
                            input -1,
                            input if v-gds-mark then ("copy-ret" + chr(4) + ca_lib-trn_ret-doc.doc-code) else ""
                            ) no-error.
                  if error-status :error then undo, return error return-value.
                  assign
                    ca_gds-dtl.doc-qnty  = ca_gds-dtl.doc-qnty + chg-qnty
                    ca_gds-dtl.fact-qnty = ca_gds-dtl.doc-qnty.
                  assign full-rsrv-qnty = chg-qnty.
              end.
            end.
            if not ( ca_lib-trn_ret-doc.doc-type = 'при':U
                    and ca_lib-trn_ret-doc.internal = false
                    )
            then do:
              assign
                ca_doc-line.doc-qnty  = ca_doc-line.doc-qnty + full-rsrv-qnty
                ca_doc-line.cli-qnty  = ca_doc-line.doc-qnty / ca_doc-line.cli-base-rate
                ca_doc-line.fact-qnty = ca_doc-line.doc-qnty
              .
            end.
          end.
        end.
       find ca_gds-prt where ca_gds-prt.upper-code = ca_goods.prt-root no-lock.
       if ca_gds-prt.node-name <> '_Пустая шкала':U   and
          ca_lib-trn_ret-doc.doc-type      = 'при':U        and
          not ca_lib-trn_ret-doc.internal                     and
          ca_trn-doc.status_    = 'накл':U          and
          ca_lib-trn_ret-doc.status_       = 'запрос':U       and
          ca_trn-doc.ord-num    = ca_lib-trn_ret-doc.doc-code then do:
         for each old-doc no-lock where
                  old-doc.ord-num = ca_lib-trn_ret-doc.doc-code :
           find old-dtl where old-dtl.doc-code  = old-doc.doc-code
                          and old-dtl.artic     = ca_lib-trn_ret-dtl.artic
                          and old-dtl.prod-type = ca_lib-trn_ret-dtl.prod-type
                          and old-dtl.prod-code = ca_lib-trn_ret-dtl.prod-code
                          and old-dtl.prt-code  = varlegal-node no-error.
           if available old-dtl then do:
             if old-dtl.obj-type = ca_lib-trn_ret-dtl.obj-type and
                old-dtl.obj-code = ca_lib-trn_ret-dtl.obj-code then do:
               accumulate old-dtl.doc-qnty (total).
             end.
             else do:
               message "На объекте " old-dtl.obj-type " " old-dtl.obj-code skip
                       " был заведен документ " old-dtl.doc-code " связаный с заказом " ca_lib-trn_ret-dtl.doc-code skip
                       " в нем есть признак товара " old-dtl.artic " " old-dtl.prod-type " " old-dtl.prod-code skip
                       " с количеством " old-dtl.doc-qnty " ." skip
                       "Данное количество не будет учтено при расчете накладной."
               view-as alert-box.
             end.
           end.
         end.
         if ca_lib-trn_ret-dtl.doc-qnty - (accum total old-dtl.doc-qnty) < 0 then do:
           assign
             chg-qnty = - (accum total old-dtl.doc-qnty) + ca_lib-trn_ret-dtl.doc-qnty.
           run trg/rsrv-dtl.p (input parparentproc,
                           'reserv':U + varcst-rsrv + varlast-date-rsrv + varpart-code-rsrv,
                           buffer ca_gds-dtl, input-output chg-qnty,
                                  input-output ca_doc-line.price-base, input-output ca_doc-line.price-rubl, -1, "") no-error.
           if error-status :error then do:
              undo, return error return-value.
           end.
           assign
             ca_gds-dtl.doc-qnty  = ca_gds-dtl.doc-qnty + chg-qnty
             ca_gds-dtl.fact-qnty = ca_gds-dtl.doc-qnty.
         end.
         accumulate ca_gds-dtl.doc-qnty (total).
       end.
    end.
    if ca_lib-trn_ret-doc.doc-type     = 'при':U  and
       not ca_lib-trn_ret-doc.internal              and
       ca_trn-doc.status_   = 'накл':U    and
       ca_lib-trn_ret-doc.status_      = 'запрос':U and
       ca_trn-doc.ord-num  = ca_lib-trn_ret-doc.doc-code then do:
      if ca_gds-prt.node-name = '_Пустая шкала':U then do:
         assign
         v-accum-cli-qnty = 0.
         for each old-doc no-lock where
                  old-doc.ord-num = ca_lib-trn_ret-doc.doc-code :
          find old-line where old-line.doc-code  = old-doc.doc-code
                          and old-line.artic     = ca_doc-line.artic
                          and old-line.prod-type = ca_doc-line.prod-type
                          and old-line.prod-code = ca_doc-line.prod-code no-error.
          if available old-line then do:
            if old-line.obj-type = ca_doc-line.obj-type
              and old-line.obj-code = ca_doc-line.obj-code
            then do:
              assign v-accum-cli-qnty = v-accum-cli-qnty + old-line.fact-qnty / old-line.cli-base-rate.
            end.
            else do:
              message "На объекте " old-line.obj-type " " old-line.obj-code skip
                      " был заведен документ " old-line.doc-code " связанный с данным заказом " skip
                      " в нем есть признак товара " old-line.artic " " old-line.prod-type " " old-line.prod-code skip
                      " с количеством " old-line.doc-qnty " ." skip
                      "Данное количество не будет учтено при расчете накладной."
              view-as alert-box.
            end.
          end.
        end.
        if ca_lib-trn_ret-line.cli-qnty - v-accum-cli-qnty   < 0 then do:
          find ca_gds-dtl where ca_gds-dtl.doc-code  = ca_trn-doc.doc-code
                            and ca_gds-dtl.artic     = ca_doc-line.artic
                            and ca_gds-dtl.prod-code = ca_doc-line.prod-code
                            and ca_gds-dtl.prod-type = ca_doc-line.prod-type
                            and ca_gds-dtl.prt-code  = ca_gds-prt.node-code.
          assign
            chg-qnty = (- v-accum-cli-qnty + ca_lib-trn_ret-line.cli-qnty) * ca_doc-line.cli-base-rate.
          if chg-qnty <> 0 then do:
            run trg/rsrv-dtl.p (input parparentproc,
                            'reserv':U + varcst-rsrv + varlast-date-rsrv + varpart-code-rsrv,
                            buffer ca_gds-dtl, input-output chg-qnty,
                            input-output ca_doc-line.price-base, input-output ca_doc-line.price-rubl,-1, "") no-error.
            if error-status :error then do:
              undo, return error return-value.
            end.
            assign
              ca_doc-line.cli-qnty  = ca_doc-line.cli-qnty + chg-qnty / ca_doc-line.cli-base-rate
              ca_doc-line.doc-qnty  = ca_doc-line.cli-qnty * ca_doc-line.cli-base-rate
              ca_doc-line.fact-qnty = ca_doc-line.doc-qnty
              ca_gds-dtl.doc-qnty   = ca_doc-line.doc-qnty
              ca_gds-dtl.fact-qnty  = ca_doc-line.doc-qnty.
          end.
        end.
      end.
      else do:
        if ca_doc-line.doc-qnty <> (accum total ca_gds-dtl.doc-qnty) then do:
          assign
            ca_doc-line.doc-qnty = (accum total ca_gds-dtl.doc-qnty)
            ca_doc-line.fact-qnty = ca_doc-line.doc-qnty.
          if ca_doc-line.unit-cli = ca_goods.unit-base then do:
            assign
             ca_doc-line.cli-qnty = ca_doc-line.doc-qnty.
          end.
          else do:
            assign
             ca_doc-line.cli-qnty = ca_doc-line.doc-qnty / ca_doc-line.cli-base-rate.
          end.
        end.
      end.
    end.
  end.
  if ca_doc-line.cli-qnty <= 0 or
     ca_doc-line.doc-qnty <= 0 then do:
     delete ca_doc-line.
  end.
  if available ca_doc-line then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_chkwhole in g#lib-trn
  ( input ca_doc-line.doc-code
   ,input ca_doc-line.artic
   ,input ca_doc-line.prod-type
   ,input ca_doc-line.prod-code
   ,input ca_doc-line.cli-qnty
   ,input ca_doc-line.doc-qnty
   ,input ca_doc-line.fact-qnty
   ,input parrecalc
  ) no-error .
    if error-status :error then do:
      undo, return error return-value.
    end.
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_lnfactqt in g#lib-calc
(
 input parparentproc
,input recid(ca_doc-line)
,input no
,input ca_trn-doc.status_
,input ca_trn-doc.flag_       )
no-error.
    if error-status :error then do:
      undo, return error return-value .
    end.
  end.
end.
end.
end procedure.
procedure lib-trn_copy-scn:
define input  parameter parparentproc AS WIDGET-HANDLE           NO-UNDO.
define input  parameter parrec-doc    as   recid                 no-undo.
define input  parameter parb-code     like ub.bar-code.b-code    no-undo.
define input  parameter b-qnty        like ub.gds-dtl.doc-qnty   no-undo.
define input  parameter paris-all     as   logical               no-undo.
define input  parameter paradd-sens   as   logical               no-undo.
define input  parameter parline-mode  as character no-undo.
define output parameter parmes        as character no-undo.
define output parameter parok         as character no-undo.
define variable v-is-zam as logical   no-undo .
define variable parts-qnty like ub.parts.fact-qnty     no-undo.
define variable parts-qnty-doc like ub.parts.fact-qnty no-undo.
define variable parts-scan as decimal   no-undo .
define variable prt-qnty like ub.prt-obj.fact-qnty     no-undo.
define variable gds-qnty like ub.gds-obj.fact-qnty     no-undo.
define variable b-c      as   integer                  no-undo.
define variable inv-qnty    like ub.gds-dtl.fact-qnty     no-undo.
define variable memexp-qnty like ub.gds-dtl.doc-qnty      no-undo.
define variable g-doc-prt as logical no-undo.
define buffer cs_trn-doc  for ub.trn-doc.
define buffer cs_doc-line for ub.doc-line.
define buffer cs_gds-dtl  for ub.gds-dtl.
define buffer cs_parts    for ub.parts.
define buffer cs_goods    for ub.goods.
define buffer cs_units    for ub.units.
define buffer cs_gds-prt  for ub.gds-prt.
define buffer cs_bar-code for ub.bar-code.
define buffer cs_shop     for ub.shop.
define buffer cs_store    for ub.store.
define buffer cs_prt-obj  for ub.prt-obj.
define buffer cs_gds-obj  for ub.gds-obj.
define buffer cli-gds-cs for ub.cli-gds.
define variable v-insalepr                     as   logical      initial ? no-undo.
define variable parsale-price                  like ub.price-list.price-sale initial ? no-undo.
define variable varcst-rsrv                    as   character              no-undo.
define variable varprice-cli-cs                like ub.doc-line.price-rubl no-undo.
define variable varprice-cli-unit-base-cs      like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-cs           like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-cs          like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-cs      like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-cs        like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-cs                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-cs             like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-cs                like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-cs         like ub.doc-line.price-rubl no-undo.
define variable varprice-rubl-cs               like ub.doc-line.price-rubl no-undo.
define variable varprice-road-tax-rubl-cs      like ub.doc-line.price-rubl no-undo.
define variable varprice-other-exp-rubl-cs     like ub.doc-line.price-rubl no-undo.
define variable varprice-transport-exp-rubl-cs like ub.doc-line.price-rubl no-undo.
define variable varprice-without-abs-rubl-cs   like ub.doc-line.price-rubl no-undo.
define variable varprice-slt-rubl-cs           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-slt-rubl-cs        like ub.doc-line.price-rubl no-undo.
define variable varprice-vat-rubl-cs           like ub.doc-line.price-rubl no-undo.
define variable varprice-no-vat-slt-rubl-cs    like ub.doc-line.price-rubl no-undo.
define variable varprice-base-cs               like ub.doc-line.price-base no-undo.
define variable varprice-road-tax-base-cs      like ub.doc-line.price-base no-undo.
define variable varprice-other-exp-base-cs     like ub.doc-line.price-base no-undo.
define variable varprice-transport-exp-base-cs like ub.doc-line.price-base no-undo.
define variable varprice-without-abs-base-cs   like ub.doc-line.price-base no-undo.
define variable varprice-slt-base-cs           like ub.doc-line.price-base no-undo.
define variable varprice-no-slt-base-cs        like ub.doc-line.price-base no-undo.
define variable varprice-vat-base-cs           like ub.doc-line.price-base no-undo.
define variable varprice-no-vat-slt-base-cs    like ub.doc-line.price-base no-undo.
define variable varlegal-node like ub.gds-prt.node-code no-undo.
define variable varis-petrolium as logical no-undo.
define variable varis-pieces    as logical no-undo.
define variable varis-term as logical no-undo.
define variable varr-b-type as character no-undo.
define variable conf-par  as char    no-undo.
define variable par-type  as char    no-undo.
define variable g-log as logical no-undo.
define variable chg-qnty                       like ub.gds-dtl.doc-qnty       no-undo.
define variable fix-qnty                       like ub.gds-dtl.doc-qnty       no-undo.
define variable mem-qnty                       like ub.gds-dtl.doc-qnty       no-undo.
define variable rec-inv-line as recid no-undo.
parts-scan = b-qnty .
v-is-zam = paris-all .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
do transaction on error undo, return error return-value :
find first cs_trn-doc where recid(cs_trn-doc) = parrec-doc.
find first cs_bar-code where cs_bar-code.b-code = parb-code.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-prt':u
  ,input  0
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  yes
  ,output conf-par
  ,output par-type
  ) no-error .
if cs_trn-doc.obj-type = 'маг':U then do:
   find first cs_shop where cs_shop.obj-code = cs_trn-doc.obj-code no-lock.
   if conf-par = "yes" and
      cs_shop.doc-prt  then do:
     assign
     g-doc-prt = yes.
   end.
   else do:
     assign
     g-doc-prt = no.
   end.
end.
else do:
  find first cs_store where cs_store.obj-code = cs_trn-doc.obj-code no-lock.
  if conf-par = "yes" and
     cs_store.doc-prt  then do:
    assign
    g-doc-prt = yes.
  end.
  else do:
    assign
    g-doc-prt = no.
  end.
end.
find first cs_goods   where cs_goods.gds-code     = cs_bar-code.gds-code no-lock.
find first cs_gds-prt where cs_gds-prt.upper-code = cs_goods.prt-root  no-lock.
find first cs_units   where cs_units.unit-name    = cs_goods.unit-base no-lock.
find cs_doc-line where cs_doc-line.doc-code  = cs_trn-doc.doc-code
                   and cs_doc-line.artic     = cs_goods.artic
                   and cs_doc-line.prod-code = cs_goods.prod-code
                   and cs_doc-line.prod-type = cs_goods.prod-type no-error.
if not available cs_doc-line and
   (paradd-sens = no  or
    cs_trn-doc.doc-type = 'инв':U ) then do:
   return error substitute("&1 Нельзя добавить строку документа : &2 .", parmes, cs_goods.artic).
end.
if not available cs_doc-line then do:
  run lib-trn_create-doc-line in this-procedure (input cs_goods.artic,
                                                 input cs_goods.prod-type,
                                                 input cs_goods.prod-code,
                                                 recid(cs_trn-doc)) no-error.
  if error-status :error then do:
    return error substitute("&1 &2", parmes, return-value).
  end.
  find first cs_doc-line where cs_doc-line.doc-code  = cs_trn-doc.doc-code and
                               cs_doc-line.artic     = cs_goods.artic      and
                               cs_doc-line.prod-type = cs_goods.prod-type  and
                               cs_doc-line.prod-code = cs_goods.prod-code .
  assign
    cs_doc-line.unit-cli      = cs_goods.unit-cli
    cs_doc-line.cli-base-rate = cs_goods.cli-base-rate.
end.
if cs_trn-doc.doc-type = 'инв':U then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  cs_bar-code.node-code
  ,input  'terminal-prt=request':u
  ,output varis-term
  )  .
   if varis-term <> yes and
      g-doc-prt         then do:
      return error substitute("&1 Бар-код &2 не является бар-кодом терминального признака.", parmes, cs_bar-code.b-code).
   end.
end.
find cs_gds-dtl where cs_gds-dtl.doc-code   = cs_trn-doc.doc-code
                  and cs_gds-dtl.artic      = cs_goods.artic
                  and cs_gds-dtl.prod-code  = cs_goods.prod-code
                  and cs_gds-dtl.prod-type  = cs_goods.prod-type
                  and cs_gds-dtl.prt-code   = cs_bar-code.node-code no-error.
if not available cs_gds-dtl then do:
   if not paradd-sens and cs_trn-doc.doc-type <> 'инв':U then do:
     return error substitute("Нельзя добавить признак по товару &1 &2 &3 с бар-кодом &4.", cs_goods.artic, cs_goods.prod-type, cs_goods.prod-code, cs_bar-code.b-code).
   end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input cs_trn-doc.obj-code
   ,input cs_trn-doc.obj-type
   ,input cs_trn-doc.doc-code
   ,input cs_goods.artic
   ,input cs_goods.prod-code
   ,input cs_goods.prod-type
   ,input cs_bar-code.node-code
   ,input yes
  ) no-error .
   if error-status :error then do:
      return error substitute("&1 &2", parmes, return-value).
   end.
   find first cs_gds-dtl where cs_gds-dtl.doc-code  = cs_trn-doc.doc-code and
                               cs_gds-dtl.artic     = cs_goods.artic      and
                               cs_gds-dtl.prod-code = cs_goods.prod-code  and
                               cs_gds-dtl.prod-type = cs_goods.prod-type  and
                               cs_gds-dtl.prt-code  = cs_bar-code.node-code.
end.
parts-qnty-doc = 0 .
if cs_bar-code.in-code <> "" THEN DO:
  find first cs_parts WHERE cs_parts.obj-code    = cs_trn-doc.obj-code
                        and cs_parts.obj-type    = cs_trn-doc.obj-type
                        and cs_parts.artic       = cs_doc-line.artic
                        and cs_parts.prod-type   = cs_doc-line.prod-type
                        and cs_parts.prod-code   = cs_doc-line.prod-code
                        and cs_parts.in-code     = cs_bar-code.in-code
                        and cs_parts.part-code   = cs_bar-code.part-code no-error.
   if not available cs_parts and
      cs_bar-code.in-code <> "" then do:
        undo, return error substitute("&1 Ссылка на несуществующую партию: &2.", parmes, cs_bar-code.part-code).
   end.
   find first cs_parts where cs_parts.out-code    = cs_trn-doc.doc-code
                         and cs_parts.obj-code    = cs_trn-doc.obj-code
                         and cs_parts.obj-type    = cs_trn-doc.obj-type
                         and cs_parts.artic       = cs_doc-line.artic
                         and cs_parts.prod-type   = cs_doc-line.prod-type
                         and cs_parts.prod-code   = cs_doc-line.prod-code
                         and cs_parts.in-code     = cs_bar-code.in-code
                         and cs_parts.part-code   = cs_bar-code.part-code no-error.
   if not available cs_parts    and
      cs_bar-code.in-code <> "" and
      paris-all = yes  then do:
   end.
   if available cs_parts then do:
      parts-qnty-doc = cs_parts.fact-qnty .
   end.
end.
if cs_bar-code.in-code <> ""                                                             and
   ((can-do ('рас,спи,возврат':U, cs_trn-doc.doc-type) and not cs_trn-doc.flag_) or
    (cs_trn-doc.doc-type = 'инв':U and
     cs_trn-doc.status_ = 'разрешен':U)) then do:
      assign
        parmes = parmes + " Партия: " + cs_bar-code.part-code + " ".
      if paris-all = ? then do:
         g-log = no.
         if available cs_parts then do:
            message "Товар :" cs_goods.artic cs_goods.gds-name skip
                    "Партия :" cs_parts.part-code "-  количество не 0 !" skip (2)
                    "yes - переписать количество со сканера в партию :" b-qnty skip (2)
                    "no  - прибавить количество со сканера к партии :"  cs_parts.qnty "+" b-qnty
                    view-as alert-box question buttons yes-no update g-log.
                    v-is-zam = g-log .
         end.
         else do:
            message "Товар :" cs_goods.artic cs_goods.gds-name skip
                    "Партия :" cs_bar-code.part-code skip(2)
                    "Режим замены осуществить невозможно. Только добавление." skip
                    "yes - Пропустить партию." skip
                    "no  - прибавить количество со сканера к партии :" b-qnty
            view-as alert-box question buttons yes-no update g-log.
            if g-log = yes then do:
               undo, return error substitute ("&1 Невозможно осуществить режим замены. Партия: &2 не привязана к данному документу.", parmes, cs_bar-code.part-code).
            end.
            v-is-zam = g-log .
         end.
      end.
      else g-log = paris-all.
      if g-log then do:
      assign
        parmes  = parmes + " Количество заменено на: " + string (b-qnty) + " "
        b-qnty = b-qnty - parts-qnty-doc
        .
      end.
      if b-qnty = 0 then return.
      assign
        b-c = cs_bar-code.b-code.
end.
else do:
  if cs_trn-doc.doc-type = 'инв':U then do:
     find cs_prt-obj where cs_prt-obj.obj-type  = cs_trn-doc.obj-type
                       and cs_prt-obj.obj-code  = cs_trn-doc.obj-code
                       and cs_prt-obj.artic     = cs_gds-dtl.artic
                       and cs_prt-obj.prod-code = cs_gds-dtl.prod-code
                       and cs_prt-obj.prod-type = cs_gds-dtl.prod-type
                       and cs_prt-obj.prt-code  = cs_gds-dtl.prt-code no-lock no-error.
     if available cs_prt-obj then do:
        assign
        prt-qnty   = cs_prt-obj.fact-qnty.
     end.
     else do:
       assign
       prt-qnty = 0.
     end.
     if paris-all = ? then do:
      g-log = no.
      message "Товар :" cs_goods.artic cs_goods.gds-name
              " Было  количество " prt-qnty + cs_gds-dtl.doc-qnty skip (2)
              "yes - переписать количество со сканера в документ :" b-qnty skip (2)
              "no - прибавить количество со сканера к документу :"  prt-qnty + cs_gds-dtl.doc-qnty "+" b-qnty
              view-as alert-box question buttons yes-no update g-log.
     end.
     else g-log = paris-all.
     if g-log then do:
       assign
        parmes = parmes + " Количество заменено на: " + string (b-qnty).
     end.
     else do:
       assign
         b-qnty = prt-qnty + cs_gds-dtl.doc-qnty + b-qnty.
     end.
  end.
  else do:
    if cs_gds-dtl.fact-qnty <> 0 then do:
      if paris-all = ? then do:
        g-log = no.
        message "Товар :" cs_goods.artic cs_goods.gds-name
                " -  количество не 0 !" skip (2)
                "yes - переписать количество со сканера в документ :" b-qnty skip (2)
                "no - прибавить количество со сканера к документу :" cs_doc-line.fact-qnty "+" b-qnty
                view-as alert-box question buttons yes-no update g-log.
      end.
      else g-log = paris-all.
      if g-log then do:
         assign
         parmes = parmes + " Количество заменено на: " + string (b-qnty) + " "
         b-qnty = b-qnty - cs_gds-dtl.fact-qnty.
      end.
    end.
  end.
  b-c = -1.
end.
if cs_trn-doc.doc-type = 'инв':U and
   cs_trn-doc.status_  = 'разрешен':U then do:
    find cs_gds-obj where cs_gds-obj.obj-type  = cs_trn-doc.obj-type
                      and cs_gds-obj.obj-code  = cs_trn-doc.obj-code
                      and cs_gds-obj.artic     = cs_gds-dtl.artic
                      and cs_gds-obj.prod-code = cs_gds-dtl.prod-code
                      and cs_gds-obj.prod-type = cs_gds-dtl.prod-type   no-lock no-error.
    if available cs_gds-obj then do:
      assign
       gds-qnty = cs_gds-obj.fact-qnty.
    end.
    else do:
      assign
      gds-qnty = 0.
    end.
    define buffer cs_doc-prts for ub.doc-prts  .
    find first cs_doc-prts no-lock where
               cs_doc-prts.b-code    = cs_bar-code.b-code and
               cs_doc-prts.out-code  = cs_trn-doc.doc-code
               no-error.
    if available cs_doc-prts then do:
      assign
       parts-qnty = cs_doc-prts.fact-qnty.
    end.
    else do:
      assign
      parts-qnty = 0.
      if cs_bar-code.in-code <> "" then do:
         message 'Необходимо пересобрать инвентаризацию  с  разр+ до накл-. Не рассчиталось БЫЛО по партиям !' view-as alert-box information .
         return error .
      end.
    end.
    if cs_bar-code.in-code <> "" then do:
          if v-is-zam = false then do:
             b-qnty   = parts-qnty + parts-qnty-doc + parts-scan .
          end.
          else do:
              b-qnty   = parts-scan .
          end.
          chg-qnty = b-qnty - parts-qnty -  parts-qnty-doc  .
    end.
    else do:
        if not available cs_parts then do:
          assign
            chg-qnty = b-qnty - (prt-qnty + cs_gds-dtl.doc-qnty).
        end.
        else do:
          assign
            chg-qnty = b-qnty.
        end.
    end.
    assign inv-qnty = chg-qnty.
    define variable v-rsrv-mode as character no-undo .
    if b-c > 0 then do:
       v-rsrv-mode =  'reserv':U
            + ",":U + 'rsrv-single-part':U
            + ",":U + 'rsrv-in-code':U   + "=":U + str-encode ( cs_bar-code.in-code  ,  "", ",=":U )
            + ",":U + 'rsrv-part-code':U + "=":U + str-encode ( cs_bar-code.part-code,  "", ",=":U )
            .
    end.
    else do:
       v-rsrv-mode = 'reserv':U + "," +
                     'no-message':U +
                     varcst-rsrv .
    end.
    run trg/rsrv-dtl.p
        ( input parparentproc,
          input v-rsrv-mode ,
          buffer cs_gds-dtl,
          input-output chg-qnty,
          input-output cs_doc-line.price-base,
          input-output cs_doc-line.price-rubl,
          b-c, "" )
          no-error.
    if error-status :error then do:
       undo, return error substitute ("&1 Ошибка при резервировании &2", parmes, return-value).
    end.
    if inv-qnty <> chg-qnty then do:
       undo, return error substitute ("&1 Ошибка при резервировании &2. Не удалось зарезервировать все количество.", parmes, return-value).
    end.
    assign
      cs_doc-line.doc-qnty  = cs_doc-line.doc-qnty + chg-qnty
      cs_gds-dtl.doc-qnty   = cs_gds-dtl.doc-qnty  + chg-qnty
      cs_doc-line.fact-qnty = cs_doc-line.doc-qnty - gds-qnty
      cs_gds-dtl.fact-qnty  = prt-qnty + cs_gds-dtl.doc-qnty
    .
    if b-c > 0 then do:
        assign
          cs_gds-dtl.fact-qnty  = cs_doc-line.doc-qnty
          cs_gds-dtl.doc-qnty   = cs_doc-line.fact-qnty
        .
    end.
    if cs_trn-doc.exch-rate <> 0 then do:
      assign
        cs_doc-line.price-cli  = cs_doc-line.price-rubl
                            * ( cs_trn-doc.exch-scale / cs_trn-doc.exch-rate )
                            * cs_doc-line.cli-base-rate
      .
    end.
    else assign cs_doc-line.price-cli  = 0.
    if cs_gds-dtl.doc-qnty = 0 then do:
      delete cs_gds-dtl.
    end.
    assign
      cs_doc-line.prt-OK = no.
    find cs_gds-prt where cs_gds-prt.upper-code = cs_goods.prt-root no-lock.
    for each cs_gds-dtl where cs_gds-dtl.prod-code = cs_goods.prod-code
                          and cs_gds-dtl.prod-type = cs_goods.prod-type
                          and cs_gds-dtl.artic     = cs_goods.artic
                          and cs_gds-dtl.doc-code  = cs_doc-line.doc-code:
      if cs_gds-dtl.doc-qnty <> 0 and
         cs_gds-dtl.prt-code <> cs_gds-prt.node-code then do:
         assign
         cs_doc-line.prt-OK = yes.
      end.
    end.
end.
if can-do ('рас,при,возврат,спи':U, cs_trn-doc.doc-type)
and (cs_trn-doc.status_ = 'накл':U or cs_trn-doc.status_ = 'запрос':U)
and not cs_trn-doc.flag_ then do:
  def var l-inv-on as logical no-undo .
  if cs_trn-doc.status_ <> 'запрос':U and
     not (cs_trn-doc.doc-type = 'при':U and cs_trn-doc.flag_ = no) then do:
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  cs_doc-line.obj-type
  ,input  cs_doc-line.obj-code
  ,input  cs_doc-line.artic
  ,input  cs_doc-line.prod-type
  ,input  cs_doc-line.prod-code
  ,input  'inv-on=request'
  ,output l-inv-on
  ) no-error .
    if error-status :error then do:
        undo, return error substitute ("&1 Ошибка получения признака товара на объекте &2 &3.", parmes, error-status :get-message(1), return-value).
    end.
    if l-inv-on then do:
       undo, return error substitute ("&1 товар в инвентаризации", parmes).
    end.
  end.
  case cs_trn-doc.doc-type :
    when 'при':U then do:
      if available cs_parts then do:
        if paris-all = ? then do:
          g-log = no.
          message "Товар :" cs_goods.artic cs_goods.gds-name skip
                  "Партия :" cs_parts.part-code "-  количество не 0 !" skip (2)
                  "yes - переписать количество со сканера в партию :" b-qnty skip (2)
                  "no  - прибавить количество со сканера к партии :" cs_parts.qnty "+" b-qnty
          view-as alert-box question buttons yes-no update g-log.
        end.
        else g-log = paris-all.
        if g-log then do:
           assign
            parmes = parmes + " Партия : " + cs_parts.part-code + " Заменено кол-во на : " + string (b-qnty)
            b-qnty = b-qnty - cs_parts.qnty.
        end.
        else do:
          assign
           parmes = parmes + " Партия : " + cs_parts.part-code + " Прибавлено к кол-ву : " + string (cs_parts.qnty) + " + " + string (b-qnty).
        end.
        assign
        b-c = cs_bar-code.b-code.
      end.
      else b-c = -1.
      assign memexp-qnty = b-qnty.
      if cs_trn-doc.status_ <> 'запрос':U then do:
         run trg/rsrv-dtl.p (input parparentproc,
                         'reserv':U + ',' + 'no-message':U + varcst-rsrv, buffer cs_gds-dtl, input-output b-qnty, input-output cs_doc-line.price-base, input-output cs_doc-line.price-rubl, b-c, "") no-error.
         if error-status :error then do:
            undo, return error substitute("&1 &2", parmes, return-value).
         end.
      end.
      assign
        cs_doc-line.doc-qnty  = cs_doc-line.doc-qnty + b-qnty
        cs_gds-dtl.doc-qnty   = cs_gds-dtl.doc-qnty  + b-qnty
        cs_doc-line.fact-qnty = cs_doc-line.doc-qnty
        cs_gds-dtl.fact-qnty  = cs_gds-dtl.doc-qnty
      .
      if memexp-qnty <> b-qnty then do:
        assign
        parmes = parmes + " количество " + string (memexp-qnty) + " недоступно. Заменено на " + string (b-qnty)
        parok = "qnty=" + string(memexp-qnty - b-qnty).
      end.
      assign cs_doc-line.cli-qnty = cs_doc-line.doc-qnty / cs_doc-line.cli-base-rate.
      if cs_trn-doc.exch-rate <> 0 then do:
        assign
          cs_doc-line.price-cli  = cs_doc-line.price-rubl
                              * ( cs_trn-doc.exch-scale / cs_trn-doc.exch-rate )
                              * cs_doc-line.cli-base-rate .
      end.
      else do:
        assign
          cs_doc-line.price-cli  = 0.
      end.
      if cs_doc-line.price-base = ? or
         cs_doc-line.price-base = 0 then do:
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  cs_trn-doc.obj-type
  ,input  cs_trn-doc.obj-code
  ,input  cs_goods.artic
  ,input  cs_goods.prod-type
  ,input  cs_goods.prod-code
  ,input  'insalepr=request':U
  ,output v-insalepr
  )  .
        if v-insalepr = true then do:
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  cs_goods.gds-code
  ,input  cs_gds-prt.node-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error substitute('&1 &2', parmes, return-value).
end.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  cs_trn-doc.obj-type
  ,input  cs_trn-doc.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  undo, return error substitute('&1 &2', parmes, return-value).
end.
gp-price-sale-parts = gp-price-sale.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  cs_trn-doc.obj-type
  ,input  cs_trn-doc.obj-code
  ,input  gp-b-code
  ,input  0
  ,input  gp-fact-order
  ,output gp-doc-num
  ,output gp-price-sale-parts
  ,output gp-road-tax
  ,output gp-excise
  ) no-error .
if error-status:error then do:
  undo, return error substitute('&1 &2', parmes, return-value).
end.
if gp-price-sale-parts <> 0 and gp-price-sale-parts <> ? then do:
    gp-price-sale = gp-price-sale-parts.
 end.
           if gp-price-sale <> ? then undo, return error substitute("&1 &2", parmes, return-value).
           assign
             cs_doc-line.price-cli  = gp-price-sale * (if g-varr-b = "base" then cs_trn-doc.base-rate / cs_trn-doc.base-scale else 1)
                                   / cs_trn-doc.exch-rate * cs_trn-doc.exch-scale * cs_doc-line.cli-base-rate
             cs_doc-line.price-base = gp-price-sale / (if g-varr-b = "base":u then 1 else cs_trn-doc.base-rate * cs_trn-doc.base-scale)
             cs_doc-line.price-rubl = gp-price-sale * (if g-varr-b = "base":u then cs_trn-doc.base-rate / cs_trn-doc.base-scale else 1)
             cs_doc-line.excise     = gp-excise
             cs_doc-line.road-tax   = gp-road-tax.
        end.
        else do:
          run cpprclig in this-procedure   (
          input        cs_trn-doc.doc-code              ,
          input        cs_trn-doc.cli-code              ,
          input        cs_trn-doc.cli-type              ,
          input        cs_trn-doc.host-code             ,
          input        cs_trn-doc.base-rate             ,
          input        cs_trn-doc.base-scale            ,
          input        cs_trn-doc.exch-rate             ,
          input        cs_trn-doc.exch-scale            ,
          input        cs_trn-doc.vat-type              ,
          input        cs_trn-doc.slt-type              ,
          input        cs_doc-line.artic                ,
          input        cs_doc-line.prod-type            ,
          input        cs_doc-line.prod-code            ,
          input        yes                              ,
          input        cs_doc-line.cli-base-rate        ,
          input        cs_doc-line.transport-rubl       ,
          input        cs_doc-line.other-rubl           ,
          output       cs_doc-line.price-cli            ,
          output       cs_doc-line.price-base           ,
          output       cs_doc-line.price-rubl           ,
          input-output cs_doc-line.vat-pc               ,
          input-output cs_doc-line.slt-pc               ,
          input-output cs_doc-line.road-tax             ,
          input-output cs_doc-line.excise               ) no-error.
        end.
        if cs_doc-line.vat-pc = ? then do:
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  cs_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  cs_trn-doc.host-code
  ,input  cs_trn-doc.obj-type
  ,input  cs_trn-doc.obj-code
  ,output cs_doc-line.vat-pc
  ) no-error .
        end.
        if cs_doc-line.slt-pc   = ?              and
           cs_trn-doc.slt-type <> 'без':U then do:
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  cs_goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  cs_trn-doc.host-code
  ,input  cs_trn-doc.obj-type
  ,input  cs_trn-doc.obj-code
  ,output cs_doc-line.slt-pc
  ) no-error .
        end.
        assign cs_doc-line.prt-OK = yes.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_in-vat in g#lib-trn
  (
   input   cs_trn-doc.doc-code
  ,input   cs_trn-doc.base-rate
  ,input   cs_trn-doc.base-scale
  ,input   cs_trn-doc.exch-rate
  ,input   cs_trn-doc.exch-scale
  ,input   cs_trn-doc.vat-type
  ,input   cs_trn-doc.slt-type
  ,input   cs_doc-line.artic
  ,input   cs_doc-line.prod-type
  ,input   cs_doc-line.prod-code
  ,input   cs_doc-line.price-cli
  ,input   cs_doc-line.cli-base-rate
  ,input   cs_doc-line.price-rubl
  ,input   cs_doc-line.vat-pc
  ,input   cs_doc-line.slt-pc
  ,input   cs_doc-line.road-tax
  ,input   cs_doc-line.transport-rubl
  ,input   cs_doc-line.other-rubl
  ,output  varprice-cli-cs
  ,output  varprice-cli-unit-base-cs
  ,output  varprice-road-tax-cs
  ,output  varprice-other-exp-cs
  ,output  varprice-transport-exp-cs
  ,output  varprice-without-abs-cs
  ,output  varprice-slt-cs
  ,output  varprice-no-slt-cs
  ,output  varprice-vat-cs
  ,output  varprice-no-vat-slt-cs
  ,output  varprice-rubl-cs
  ,output  varprice-road-tax-rubl-cs
  ,output  varprice-other-exp-rubl-cs
  ,output  varprice-transport-exp-rubl-cs
  ,output  varprice-without-abs-rubl-cs
  ,output  varprice-slt-rubl-cs
  ,output  varprice-no-slt-rubl-cs
  ,output  varprice-vat-rubl-cs
  ,output  varprice-no-vat-slt-rubl-cs
  ,output  varprice-base-cs
  ,output  varprice-road-tax-base-cs
  ,output  varprice-other-exp-base-cs
  ,output  varprice-transport-exp-base-cs
  ,output  varprice-without-abs-base-cs
  ,output  varprice-slt-base-cs
  ,output  varprice-no-slt-base-cs
  ,output  varprice-vat-base-cs
  ,output  varprice-no-vat-slt-base-cs
  ) no-error.
            if error-status :error then do:
              undo, return error substitute ("&1 &2", parmes, return-value).
            end.
            assign
            cs_doc-line.price-cli  = varprice-cli-cs
            cs_doc-line.price-rubl = varprice-rubl-cs
            cs_doc-line.price-base = varprice-base-cs.
      end.
    end.
    when 'рас':U   or
    when 'спи':U or
    when 'возврат':U    then do:
      assign
      cs_gds-dtl.discnt-pc = cs_trn-doc.discnt-pc.
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(cs_gds-dtl)
  , input no
  , input ?
  ) no-error.
      if error-status :error then do:
        undo, return error substitute ("&1 &2", parmes, return-value).
      end.
      assign
        cs_doc-line.fact-qnty = cs_doc-line.doc-qnty.
        cs_gds-dtl.fact-qnty  = cs_gds-dtl.doc-qnty.
      assign memexp-qnty = b-qnty.
      if cs_trn-doc.status_ <> 'запрос':U then do:
         run trg/rsrv-dtl.p (input parparentproc,
                       'reserv':U + ',' + 'no-message':U + varcst-rsrv,buffer cs_gds-dtl, input-output b-qnty, input-output cs_doc-line.price-base, input-output cs_doc-line.price-rubl, b-c, "") no-error.
         if error-status :error then do:
           undo, return error substitute ("&1 &2", parmes, return-value).
         end.
      end.
      assign
        cs_doc-line.doc-qnty  = cs_doc-line.doc-qnty + b-qnty
        cs_gds-dtl.doc-qnty   = cs_gds-dtl.doc-qnty  + b-qnty
        cs_doc-line.fact-qnty = cs_doc-line.doc-qnty
        cs_gds-dtl.fact-qnty  = cs_gds-dtl.doc-qnty
        .
      if memexp-qnty <> b-qnty then do:
        assign
        parmes = parmes + " количество " + string (memexp-qnty) + " недоступно. Заменено на " + string (b-qnty)
        parok = "qnty=" + string(memexp-qnty - b-qnty).
      end.
      if parline-mode <> "b-c" then do:
         if cs_gds-dtl.doc-qnty  = 0 then delete cs_gds-dtl.
         if cs_doc-line.doc-qnty = 0 then delete cs_doc-line.
      end.
    end.
  end.
end.
if (can-do ('рас,спи,возврат':U, cs_trn-doc.doc-type) and
    cs_trn-doc.status_ = 'разрешен':U) or
   (cs_trn-doc.doc-type = 'при':U and
    cs_trn-doc.status_ = 'накл':U    and
    cs_trn-doc.flag_) then do:
  if available cs_parts then do:
    if cs_parts.fact-qnty = 0 then do:
       assign
       parmes = parmes + " Партия : " + cs_parts.part-code +
                     " Записано кол-во ФАКТ : " + string (b-qnty).
    end.
    else do:
     if paris-all = ? then do:
      g-log = no.
      message "Товар :" cs_goods.artic cs_goods.gds-name skip
              "Партия :" cs_parts.part-code "- ФАКТ количество не 0 !" skip (2)
              "yes - переписать количество со сканера в партию :" b-qnty skip (2)
              "no - прибавить количество со сканера к партии :" cs_parts.fact-qnty "+" b-qnty
      view-as alert-box question buttons yes-no update g-log.
     end.
     else g-log = paris-all.
     if g-log then do:
       assign
        parmes = parmes + " Партия : " + cs_parts.part-code +
                      " Заменено кол-во ФАКТ на : " + string (b-qnty)
        cs_doc-line.fact-qnty = cs_doc-line.fact-qnty - cs_parts.fact-qnty
        cs_gds-dtl.fact-qnty = cs_gds-dtl.fact-qnty - cs_parts.fact-qnty
        cs_parts.fact-qnty = 0.
      end.
      else do:
        assign
        parmes = parmes + " Партия : " + cs_parts.part-code +
                            " Прибавлено к кол-ву ФАКТ : " + string (cs_parts.fact-qnty) + " + " + string (b-qnty).
      end.
    end.
    if (cs_parts.fact-qnty + b-qnty > cs_parts.qnty) and
       (cs_trn-doc.doc-type <> 'при':U or cs_trn-doc.internal) then do:
      parmes = parmes + " Партия : " + cs_parts.part-code +
                    " ФАКТ количество : " + string (cs_parts.fact-qnty + b-qnty) + " уменьшено до кол-ва по док. : " + string (cs_parts.qnty).
      b-qnty = cs_parts.qnty - cs_parts.fact-qnty.
    end.
    assign
    cs_parts.fact-qnty    = cs_parts.fact-qnty    + b-qnty
    cs_doc-line.fact-qnty = cs_doc-line.fact-qnty + b-qnty
    cs_gds-dtl.fact-qnty  = cs_gds-dtl.fact-qnty  + b-qnty.
  end.
  else do:
     if (cs_gds-dtl.fact-qnty + b-qnty > cs_gds-dtl.doc-qnty) and (cs_trn-doc.doc-type <> 'при':U or cs_trn-doc.internal) then do:
        parmes = parmes + " Признак : " + string (cs_gds-dtl.prt-code) +
                      " ФАКТ количество : " + string (cs_gds-dtl.fact-qnty + b-qnty) + " уменьшено до кол-ва по док. : " + string (cs_gds-dtl.doc-qnty).
        b-qnty = cs_gds-dtl.doc-qnty - cs_gds-dtl.fact-qnty.
     end.
  end.
  assign memexp-qnty = b-qnty.
  run trg/rsrv-dtl.p (input parparentproc,
                 'reserv':U + ',' + 'no-message':U + varcst-rsrv, buffer cs_gds-dtl,input-output b-qnty,input-output cs_doc-line.price-base,input-output cs_doc-line.price-rubl, b-c, "") no-error.
  if error-status :error then undo, return error substitute ("&1 &2", parmes, parok).
  assign
  cs_doc-line.fact-qnty = cs_doc-line.fact-qnty + b-qnty
  cs_gds-dtl.fact-qnty  = cs_gds-dtl.fact-qnty  + b-qnty.
  if memexp-qnty <> b-qnty then
   assign
   parmes = parmes + " количество " + string (memexp-qnty) + " недоступно. Заменено на " + string (b-qnty)
   parok = "qnty=" + string(memexp-qnty - b-qnty).
end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_chkwhole in g#lib-trn
  ( input cs_doc-line.doc-code
   ,input cs_doc-line.artic
   ,input cs_doc-line.prod-type
   ,input cs_doc-line.prod-code
   ,input cs_doc-line.cli-qnty
   ,input cs_doc-line.doc-qnty
   ,input cs_doc-line.fact-qnty
   ,input yes
  ) no-error .
if error-status :error then do:
  return error substitute("&1 &2", parmes, return-value).
end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input cs_doc-line.artic
  ,  input cs_doc-line.prod-type
  ,  input cs_doc-line.prod-code
  , output varis-petrolium
  , output varis-pieces
  ) no-error.
if varis-petrolium  and
   not varis-pieces then do:
if (valid-handle(g#lib-calc) <> true) then do:   run str/lib-calc.p persistent no-error .   if error-status :error or (valid-handle(g#lib-calc) <> true) then do:     message       "Error starting lib-calc.p" skip       g#lib-calc skip       g#lib-calc :type skip       g#lib-calc :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-calc_lnfactqt in g#lib-calc
(
 input parparentproc
,input recid(cs_doc-line)
,input no
,input cs_trn-doc.status_
,input cs_trn-doc.flag_       )
no-error.
  if error-status :error then do:
    undo, return error substitute("&1 &2", parmes, return-value).
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_corinvln in g#lib-trn3
( input  cs_doc-line.doc-code
 ,input  cs_doc-line.artic
 ,input  cs_doc-line.prod-type
 ,input  cs_doc-line.prod-code
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  ?
 ,output rec-inv-line
 ) no-error.
  if error-status :error then do:
    undo, return error substitute( "&1 &2", parmes, return-value ).
  end.
end.
end.
end procedure.
procedure lib-trn_crtrndoc:
define input parameter paracc-date     like ub.trn-doc.acc-date     no-undo.
define input parameter parbge-date     like ub.trn-doc.bge-date     no-undo.
define input parameter parbase-rate    like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale   like ub.trn-doc.base-scale   no-undo.
define input parameter parcli-code     like ub.trn-doc.cli-code     no-undo.
define input parameter parcli-type     like ub.trn-doc.cli-type     no-undo.
define input parameter parcli-name     like ub.trn-doc.cli-name     no-undo.
define input parameter parcr-db-num    like ub.trn-doc.cr-db-num    no-undo.
define input parameter parcreid        like ub.trn-doc.creid        no-undo.
define input parameter pardiscnt-type  like ub.trn-doc.discnt-type  no-undo.
define input parameter pardoc-code     like ub.trn-doc.doc-code     no-undo.
define input parameter pardoc-date     like ub.trn-doc.doc-date     no-undo.
define input parameter pardoc-type     like ub.trn-doc.doc-type     no-undo.
define input parameter parflag_        like ub.trn-doc.flag_        no-undo.
define input parameter parhost-code    like ub.trn-doc.host-code    no-undo.
define input parameter parinternal     like ub.trn-doc.internal     no-undo.
define input parameter parobj-code     like ub.trn-doc.obj-code     no-undo.
define input parameter parobj-type     like ub.trn-doc.obj-type     no-undo.
define input parameter paroffice       like ub.trn-doc.office       no-undo.
define input parameter parpay-code     like ub.trn-doc.pay-code     no-undo.
define input parameter parps           like ub.trn-doc.ps           no-undo.
define input parameter parret-supp     like ub.trn-doc.ret-supp     no-undo.
define input parameter parslt-type     like ub.trn-doc.slt-type     no-undo.
define input parameter parstatus_      like ub.trn-doc.status_      no-undo.
define input parameter parvat-type     like ub.trn-doc.vat-type     no-undo.
define input parameter parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define input parameter parpurch-code   like ub.trn-doc.purch-code   no-undo.
define buffer cr_trn-doc for ub.trn-doc.
define variable varenvd as character no-undo.
define variable vartype as character no-undo.
define variable v-type       as character no-undo .
define variable varstfactdt      as logical   no-undo .
define variable varstfactdt-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
do for cr_trn-doc transaction on error undo, return error return-value :
find first cr_trn-doc where cr_trn-doc.doc-code = pardoc-code no-error.
if not available cr_trn-doc then do:
  create cr_trn-doc.
  assign
    cr_trn-doc.acc-date     = paracc-date
    cr_trn-doc.bge-date     = parbge-date
    cr_trn-doc.base-rate    = parbase-rate
    cr_trn-doc.base-scale   = parbase-scale
    cr_trn-doc.cli-code     = parcli-code
    cr_trn-doc.cli-type     = parcli-type
    cr_trn-doc.cli-name     = parcli-name
    cr_trn-doc.cr-db-num    = parcr-db-num
    cr_trn-doc.creid        = parcreid
    cr_trn-doc.discnt-type  = pardiscnt-type
    cr_trn-doc.doc-code     = pardoc-code
    cr_trn-doc.doc-date     = pardoc-date
    cr_trn-doc.doc-type     = pardoc-type
    cr_trn-doc.flag_        = parflag_
    cr_trn-doc.host-code    = parhost-code
    cr_trn-doc.internal     = parinternal
    cr_trn-doc.obj-code     = parobj-code
    cr_trn-doc.obj-type     = parobj-type
    cr_trn-doc.office       = paroffice
    cr_trn-doc.pay-code     = parpay-code
    cr_trn-doc.ps           = parps
    cr_trn-doc.ret-supp     = parret-supp
    cr_trn-doc.slt-type     = parslt-type
    cr_trn-doc.status_      = parstatus_
    cr_trn-doc.vat-type     = parvat-type
    cr_trn-doc.ext-doc-type = parext-doc-type
    cr_trn-doc.purch-code   = parpurch-code
    .
  run clntattr-value in this-procedure (
      cr_trn-doc.obj-type,
      cr_trn-doc.obj-code,
      'envd':U,
      output varenvd,
      output vartype).
  if varenvd = "yes":u then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input cr_trn-doc.doc-code ,
                       input 'envd':U ,
                       input 'yes':U )  .
  end.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_trn-rsn in g#lib-trn3 ( input pardoc-code )  no-error .
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  run adm/shattri.p (
      input "get":U
      ,input cr_trn-doc.obj-type
      ,input cr_trn-doc.obj-code
      ,input 'nakl_par':U
      ,input  "stfactdt"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output varstfactdt
      ,output varstfactdt-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then varstfactdt = false .
   define variable l-shift-on as logical no-undo.
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  cr_trn-doc.obj-type
  ,input  cr_trn-doc.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
  if (cr_trn-doc.ext-doc-type = 'ie':U or
      cr_trn-doc.ext-doc-type = 'ee':U ) and
      varstfactdt = yes                              and
      l-shift-on <> yes                              then do:
    assign
      cr_trn-doc.fact-date = cr_trn-doc.doc-date
      cr_trn-doc.fact-time = time.
  end.
end.
end.
end procedure.
procedure lib-trn_crdoclin:
  define input parameter pardoc-code      like ub.doc-line.doc-code     no-undo.
  define input parameter parartic         like ub.doc-line.artic        no-undo.
  define input parameter parprod-type     like ub.doc-line.prod-type    no-undo.
  define input parameter parprod-code     like ub.doc-line.prod-code    no-undo.
  define input parameter parobj-type      like ub.doc-line.obj-type     no-undo.
  define input parameter parobj-code      like ub.doc-line.obj-code     no-undo.
  define input parameter parstatus_       like ub.doc-line.status_      no-undo.
  define input parameter parext-doc-type  like ub.doc-line.ext-doc-type no-undo.
  define input parameter parprt-root      like ub.doc-line.prt-root     no-undo.
  define input parameter parvat-pc        like ub.doc-line.vat-pc       no-undo.
  define input parameter parslt-pc        like ub.doc-line.slt-pc       no-undo.
  define input parameter parcons-vat-pc   like ub.doc-line.cons-vat-pc  no-undo.
  do transaction
  on error undo, return error return-value
  :
    define variable varis-petrolium as logical no-undo.
    define variable varis-pieces    as logical no-undo.
    define buffer cr_doc-line for ub.doc-line.
    define buffer last_doc-line for ub.doc-line.
    define variable varline-num as integer no-undo.
    define variable rec-inv-line as recid no-undo.
    find last last_doc-line where last_doc-line.doc-code = pardoc-code use-index line-num no-lock no-error.
    if not available last_doc-line then do:
      assign varline-num = 1.
    end.
    else do:
      assign varline-num = last_doc-line.line-num + 1.
    end.
    find first cr_doc-line where cr_doc-line.doc-code  = pardoc-code  and
                                cr_doc-line.artic     = parartic     and
                                cr_doc-line.prod-type = parprod-type and
                                cr_doc-line.prod-code = parprod-code no-error.
    if not available cr_doc-line then do:
      run check-use-artic in this-procedure ( input "doc-line":U,
                                              input parartic,
                                              input parprod-type,
                                              input parprod-code  ) no-error.
      if error-status :error then do:
        undo, return error substitute( 'lib-trn_crdoclin: &1', return-value ).
      end.
      create cr_doc-line.
      assign
        cr_doc-line.doc-code      =  pardoc-code
        cr_doc-line.artic         =  parartic
        cr_doc-line.prod-type     =  parprod-type
        cr_doc-line.prod-code     =  parprod-code
        cr_doc-line.obj-type      =  parobj-type
        cr_doc-line.obj-code      =  parobj-code
        cr_doc-line.status_       =  parstatus_
        cr_doc-line.ext-doc-type  =  parext-doc-type
        cr_doc-line.prt-root      =  parprt-root
        cr_doc-line.vat-pc        =  parvat-pc
        cr_doc-line.slt-pc        =  parslt-pc
        cr_doc-line.cons-vat-pc   =  parcons-vat-pc
        cr_doc-line.line-num      =  varline-num
        .
      if ( cr_doc-line.cli-base-rate = 0 or cr_doc-line.cli-base-rate = ? )
        then
        cr_doc-line.cli-base-rate = 1 .
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_corinvln in g#lib-trn3
( input  pardoc-code
 ,input  parartic
 ,input  parprod-type
 ,input  parprod-code
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  ?
 ,input  ?
 ,output rec-inv-line
 ) no-error.
    if error-status :error then do:
      undo, return error return-value.
    end.
  end.
end procedure.
procedure lib-trn_crdocpl:
  define input parameter  p-doc-code like ub.doc-line.doc-code no-undo .
  define input parameter  p-gds-code like ub.goods.gds-code    no-undo .
  define input parameter  p-pl-code  like ub.pl-gds.pl-code    no-undo .
  define input parameter  p-obj-type like ub.doc-line.obj-type no-undo .
  define input parameter  p-obj-code like ub.doc-line.obj-code no-undo .
  define output parameter p-rowid    as   rowid                no-undo .
  do transaction
  on error undo, return error return-value
  :
    define buffer buf_doc-pl for ub.doc-pl .
    find first buf_doc-pl share-lock
      where buf_doc-pl.obj-type = p-obj-type
        and buf_doc-pl.obj-code = p-obj-code
        and buf_doc-pl.pl-code  = p-pl-code
        and buf_doc-pl.out-code = p-doc-code
        and buf_doc-pl.gds-code = p-gds-code
      no-error.
    if not available buf_doc-pl then do:
      create buf_doc-pl.
      assign
        buf_doc-pl.obj-type         = p-obj-type
        buf_doc-pl.obj-code         = p-obj-code
        buf_doc-pl.pl-code          = p-pl-code
        buf_doc-pl.out-code         = p-doc-code
        buf_doc-pl.gds-code         = p-gds-code
        buf_doc-pl.cli-qnty         = 0.0
        buf_doc-pl.doc-qnty         = 0.0
        buf_doc-pl.cli-doc-qnty     = 0.0
        buf_doc-pl.fact-qnty        = 0.0
        buf_doc-pl.cli-fact-qnty    = 0.0
        buf_doc-pl.rest-af-qnty     = ?
        buf_doc-pl.rest-bf-qnty     = ?
        buf_doc-pl.cli-rest-af-qnty = ?
        buf_doc-pl.cli-rest-bf-qnty = ?
      .
    end.
    assign
      p-rowid = rowid( buf_doc-pl )
    .
  end.
end procedure.
procedure lib-trn_del-doc :
  define  input parameter parparentproc      as   widget-handle                no-undo.
  define  input parameter pardoc-code        like ub.trn-doc.doc-code          no-undo.
  define  input parameter parcurdb-num       like ub.clients.db-num            no-undo.
  define  input parameter parfile-name-err   as   character                    no-undo.
  define  input parameter parcorr-inkas-code like ub.c-trn-doc.corr-inkas-code no-undo.
  define  input parameter parcorr-fbr-code   like ub.c-trn-doc.corr-fbr-code   no-undo.
  define  input parameter paruserid          as   character                    no-undo.
  define  input parameter parphdoc-code      like ub.trn-doc.doc-code          no-undo.
  define  input parameter parphchip-num      as   integer                      no-undo.
  define output parameter parchip-num        as   integer                      no-undo.
  define  input parameter parhandle          as   handle                       no-undo.
  define buffer del_trn-doc         for ub.trn-doc.
  define buffer del_clients         for ub.clients.
  define buffer delc_clients        for ub.clients.
  define buffer del_shop            for ub.shop.
  define buffer del_store           for ub.store.
  define buffer del_firm            for ub.firm.
  define buffer del_parts           for ub.parts .
  define buffer del_doc-line        for ub.doc-line.
  define buffer del_rvs-doc         for ub.rvs-doc.
  define buffer bf_fin-ob           for ub.fin-ob.
  define buffer del_fin-ob          for ub.fin-ob.
  define buffer bf_fin-ob-before    for ub.fin-ob-before.
  define buffer del_fin-ob-trn      for ub.fin-ob-trn.
  define buffer bf_fin-ob-trn       for ub.fin-ob-trn.
  define buffer bf_fin-gds-part     for ub.fin-gds-part.
  define buffer bf_clients          for ub.clients.
  define buffer bf-c_clients        for ub.clients.
  define buffer bf_ord-doc          for ub.ord-doc.
  define buffer bf_ord-doc-rcv      for ub.ord-doc-rcv.
  define buffer bufz_trn-doc        for ub.trn-doc.
  define buffer del_turnover-buyer  for ub.turnover-buyer  .
  define variable varactive        like ub.store.active         no-undo.
  define variable varhold          as   character               no-undo.
  define variable varhold-type     as   character               no-undo.
  define variable varflag-doc-err  as   logical                 no-undo.
  define variable g-log            as   logical                 no-undo.
  define variable varmes-line      as   character               no-undo.
  define variable varmes           as   character               no-undo.
  define variable varobj-date      as   date                    no-undo.
  define variable varshift-date    like ub.shift-obj.shift-date no-undo.
  define variable varshift-num     like ub.shift-obj.shift-num  no-undo.
  define variable varshift-name    as   character                no-undo.
  define variable l-shift-on       as   logical                 no-undo.
  define variable vartime          as   integer                 no-undo.
  define variable vardel-line      as   integer                 no-undo.
  define variable varmessage       as   character               no-undo.
  define variable varchip-num-main as   integer                 no-undo.
  define variable l-inv-on         as   logical                 no-undo.
  define variable varcut-status    as   integer                 no-undo.
  define variable varcut-date      as   date                    no-undo.
  define variable varcut-fin-date  as   date                    no-undo.
  define variable vardoc-hold      as   logical                 no-undo.
  define variable is-petrol        as   logical                 no-undo.
  define variable is-pieces        as   logical                 no-undo.
  define variable varsale-auto     as   character               no-undo.
  define variable vartype          as   character               no-undo.
  define variable parhost-code     like ub.trn-doc.host-code    no-undo.
  define variable parobj-type      like ub.trn-doc.obj-type     no-undo.
  define variable parobj-code      like ub.trn-doc.obj-code     no-undo.
  define variable pararm-code      as   character               no-undo.
  define variable varcli-qnty      as   decimal                 no-undo.
  define variable v-mess           as character no-undo .
  define variable v-flag-del as logical   no-undo .
  define variable v-attr-value  as character no-undo .
  define variable v-attr-type  as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date  no-undo .
define variable v-date-close-period as date      no-undo .
define variable v-value-decimal as decimal   no-undo .
define variable v-value-integer as integer   no-undo .
define variable v-value-logical as logical   no-undo .
define variable v-value-type as character no-undo .
define variable v-back-date as logical   no-undo .
define variable v-back-date-type as character no-undo .
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
  do on error undo, return error return-value :
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
    assign
      vartime = time.
    run waitfram-show in parhandle ( input substitute( "Удаления документа &1.", pardoc-code ) + chr(10) +
                                           substitute( "Время: &1.", string( time - vartime, "hh:mm:ss":U ) ) ) no-error.
    find first del_trn-doc where
               del_trn-doc.doc-code = pardoc-code.
    find first del_clients where
               del_clients.obj-type = del_trn-doc.obj-type and
               del_clients.obj-code = del_trn-doc.obj-code .
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curobjdt in g#library
  (input  del_trn-doc.obj-type
  ,input  del_trn-doc.obj-code
  ,output varobj-date
  ) no-error .
    if error-status :error or
       varobj-date = ?     then do:
      return error "Нет текущей даты на объекте документа.".
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cutd-obj in g#library
  (input  del_trn-doc.obj-type
  ,input  del_trn-doc.obj-code
  ,output varcut-status
  ,output varcut-date
  ,output varcut-fin-date
  ) no-error .
    if error-status :error then do:
      return error substitute( "Ошибка при определении состояния объекта по обрезанию данных &1 &2.", return-value , error-status :get-message(1)  ).
    end.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  del_trn-doc.obj-type
  ,input  del_trn-doc.obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
    if l-shift-on = yes then do:
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curshift in g#library
  (input  del_trn-doc.obj-type
  ,input  del_trn-doc.obj-code
  ,output varshift-date
  ,output varshift-num
  ,output varshift-name
  ) no-error .
      if del_trn-doc.status_ = 'факт':U and error-status :error then do:
        return error "Ошибка при поиске текущей смены на объекте".
      end.
    end.
    else do:
      assign
        varshift-date = ?
        varshift-num  = ?
        varshift-name = ?.
    end.
    if del_clients.obj-type = 'маг':U then do:
      assign
        varactive = yes.
    end.
    else do:
      find first del_store where del_store.obj-code = del_clients.obj-code.
      assign
        varactive = del_store.active.
    end.
    if del_trn-doc.status_ = 'разрешен':U or
       del_trn-doc.status_ = 'накл':U      and del_trn-doc.flag_ = yes and del_trn-doc.doc-type = 'при':U
    then do:
      run waitfram-hide in parhandle no-error.
      return error "Данный документ не может быть удален.".
    end.
    if not ( ( parcurdb-num          = del_clients.db-num and
               varactive             = yes              ) or
             ( parcurdb-num          = 0                  and
               varactive             = no               ) or
             ( parcurdb-num          = 0                  and
               del_trn-doc.flag_     = no                 and
               del_trn-doc.cr-db-num = 0                  and
             ( del_trn-doc.status_   = 'накл':U            or
               del_trn-doc.status_   = 'прво':U    or
               del_trn-doc.status_   = 'запрос':U   ) ) )
    then do:
      run waitfram-hide in parhandle no-error.
      return error "Накладная может быть удалена только на активной стороне или в месте ее создания в начальном статусе.".
    end.
    if not ( del_trn-doc.status_ = 'накл':U         and not del_trn-doc.flag_ or
             del_trn-doc.status_ = 'прво':U and not del_trn-doc.flag_ or
             del_trn-doc.status_ = 'накл':U         and     del_trn-doc.flag_ and not del_trn-doc.doc-type = 'при':U or
             del_trn-doc.status_ = 'запрос':U      and not del_trn-doc.flag_ or
             del_trn-doc.status_ = 'факт':U  ) then do:
      run waitfram-hide in parhandle no-error.
      return error substitute( "Некорректный статус-флаг &1-&2 документа &3.",
                               del_trn-doc.status_, string( del_trn-doc.flag_, "+/-":U ), del_trn-doc.doc-code ).
    end.
      define variable is-addcharges as logical   no-undo .
      define variable v-kol-rel as integer   no-undo .
      define buffer buf_add-trn  for ub.add-trn  .
      define buffer buf2_add-trn for ub.add-trn  .
      define buffer buf_add-doc  for ub.add-doc  .
      run chk-is-addcharges in parparentproc (output is-addcharges) no-error .
        if error-status :error then is-addcharges = false .
        if is-addcharges = true then do:
           find first buf_add-trn no-lock where
                      buf_add-trn.trn-doc-code = del_trn-doc.doc-code no-error .
           if available  buf_add-trn then do:
              v-kol-rel = 0 .
              for each  buf2_add-trn no-lock where
                        buf2_add-trn.doc-code = buf_add-trn.doc-code :
                        v-kol-rel = v-kol-rel + 1.
              end.
              if v-kol-rel > 1 then  return error substitute( "Для накладной № &1 есть ДопРасход № &2 на несколько накладных . Удаление документа невозможно. Удалите сначала ДопРасход", del_trn-doc.doc-code ,buf_add-trn.doc-code ).
              if v-kol-rel = 1 then do:
                 find first buf_add-doc exclusive-lock where
                            buf_add-doc.doc-code = buf_add-trn.doc-code no-error .
                 if available buf_add-doc then do:
                    delete buf_add-doc .
                 end.
              end.
           end.
        end.
    if del_trn-doc.status_ = 'факт':U then do:
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  run adm/shattri.p (
      input "get":U
      ,input del_trn-doc.obj-type
      ,input del_trn-doc.obj-code
      ,input 'nakl_par':U
      ,input  "back-date"
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-back-date
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then v-back-date = false .
      if v-back-date <> true then do:
          if del_trn-doc.fact-date <> varobj-date  then do:
            return error substitute( "Запрещено работать с документами (в данном случае удалять) задним числом ") .
          end.
      end.
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  run adm/shattri.p (
      input "get":U
      ,input del_trn-doc.obj-type
      ,input del_trn-doc.obj-code
      ,input 'nakl_par':U
      ,input  "date-close-period"
      ,output v-value-character
      ,output v-date-close-period
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then v-date-close-period = date('').
   if v-date-close-period <> date('') then do:
  if  del_trn-doc.fact-date < v-date-close-period
  then do:
    return error substitute(
      "Дата закрытия документа &1 более ранняя, чем дата закрытия периода &2
       Дата закрытия документа  &3 &2
       Дата закрытия периода    &4 &2
       Объект &5 &6 "
       ,
       del_trn-doc.doc-code  ,
       chr(10)  ,
       string ( del_trn-doc.fact-date, "99/99/9999") ,
       string ( v-date-close-period,   "99/99/9999") ,
                del_trn-doc.obj-type ,
                del_trn-doc.obj-code  ) .
  end.
  end.
  if del_trn-doc.cli-type = 'маг':U or del_trn-doc.cli-type = 'скл':U  then do:
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
      run adm/shattri.p (
          input "get":U
          ,input del_trn-doc.cli-type
          ,input del_trn-doc.cli-code
          ,input 'nakl_par':U
          ,input  "date-close-period"
          ,output v-value-character
          ,output v-date-close-period
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-value-type
          ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
          ) no-error .
          if error-status :error then v-date-close-period = date('').
      if v-date-close-period <> date('') then do:
      if  del_trn-doc.fact-date < v-date-close-period
      then do:
        return error substitute(
          "Дата закрытия документа &1 более ранняя, чем дата закрытия периода &2
          Дата закрытия документа  &3 &2
          Дата закрытия периода    &4 &2
          Объект &5 &6 "
          ,
          del_trn-doc.doc-code  ,
          chr(10)  ,
          string ( del_trn-doc.fact-date, "99/99/9999") ,
          string ( v-date-close-period,   "99/99/9999") ,
                    del_trn-doc.cli-type ,
                    del_trn-doc.cli-code  ) .
      end.
  end.
  end.
  if del_trn-doc.hold-obj-type = 'маг':U or del_trn-doc.hold-obj-type = 'скл':U  then do:
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
      run adm/shattri.p (
          input "get":U
          ,input del_trn-doc.hold-obj-type
          ,input del_trn-doc.hold-obj-code
          ,input 'nakl_par':U
          ,input  "date-close-period"
          ,output v-value-character
          ,output v-date-close-period
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-value-type
          ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
          ) no-error .
          if error-status :error then v-date-close-period = date('').
      if v-date-close-period <> date('') then do:
      if  del_trn-doc.fact-date < v-date-close-period
      then do:
        return error substitute(
          "Дата закрытия документа &1 более ранняя (или равна), чем дата закрытия периода &2
          Дата закрытия документа  &3 &2
          Дата закрытия периода    &4 &2
          Объект &5 &6 "
          ,
          del_trn-doc.doc-code  ,
          chr(10)  ,
          string ( del_trn-doc.fact-date, "99/99/9999") ,
          string ( v-date-close-period,   "99/99/9999") ,
                    del_trn-doc.hold-obj-type ,
                    del_trn-doc.hold-obj-code  ) .
      end.
  end.
  end.
  define variable v-arh-detail-date as date      no-undo .
  run clntattr-value in this-procedure
    (input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  'arh-detail':U
    ,output v-attr-value
    ,output v-attr-type
    ) .
  if v-attr-type = 'T':U
  then do:
    assign
      v-arh-detail-date = date(v-attr-value)
    .
  end.
  if  v-arh-detail-date <> ?
  and del_trn-doc.fact-date < v-arh-detail-date
  then do:
    return error substitute(
      "Дата закрытия документа &1 более ранняя, чем дата начала подробного складского архива по товарам &2
       Дата закрытия документа  &3 &2
       Дата начала подробного складского архива по товарам &4" ,
       del_trn-doc.doc-code  ,
       chr(10)  ,
       string ( del_trn-doc.fact-date, "99/99/9999") ,
       string ( v-arh-detail-date,     "99/99/9999")
       ) .
  end.
      case varcut-status :
        when 1 then do:
        end.
        when 2 then do:
        end.
        when 3 then do:
          if varcut-date > del_trn-doc.fact-date then do:
            return error substitute( "В главной базе данных проводилось обрезание &3 по объекту &1 &2. База данных этого объекта не была выгружена. Удаление документа невозможно.", del_trn-doc.obj-type, del_trn-doc.obj-code ,varcut-date ).
          end.
        end.
        when 4 then do:
        end.
        otherwise do:
          return error substitute( "Неверный статус объекта &1 получен от программы cutd-obj.", varcut-status ).
        end.
      end case.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'holding':u
  ,input  0
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output varhold
  ,output varhold-type
  ) no-error .
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  del_trn-doc.doc-code
  ,output vardoc-hold
  )  .
      if varhold     = "yes" and
         vardoc-hold =  yes  then do:
        run waitfram-hide in parhandle no-error.
        if del_trn-doc.ext-doc-type = 'ie':U     or
           del_trn-doc.ext-doc-type = 'ee':U     or
           del_trn-doc.ext-doc-type = 'ep':U  or
           del_trn-doc.ext-doc-type = 're':U then do:
          case del_trn-doc.doc-type :
            when 'при':U
            then do:
define variable vss-include-info55 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_hold-income_del-fact':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  yes
    ,output g-log
    ) no-error .
end.
            end.
            when 'рас':U
            then do:
define variable vss-include-info56 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_hold-expense_del-fact':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  yes
    ,output g-log
    ) no-error .
end.
            end.
            when 'возврат':U
            then do:
define variable vss-include-info57 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_hold-return_del-fact':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  yes
    ,output g-log
    ) no-error .
end.
            end.
          end case.
          if error-status :error or
             g-log = no          then do:
            run waitfram-hide in parhandle no-error.
            undo, return error "Вы не имеете прав на удаление документа, закрытого на факт.".
          end.
        end.
      end.
      if del_trn-doc.ext-doc-type = 'iv':U     or
         del_trn-doc.ext-doc-type = 'ev':U     or
         del_trn-doc.ext-doc-type = 'rv':U then do:
        find first bf_clients no-lock where
                   bf_clients.obj-type = del_trn-doc.obj-type and
                   bf_clients.obj-code = del_trn-doc.obj-code .
        find first bf-c_clients no-lock where
                   bf-c_clients.obj-type = del_trn-doc.cli-type and
                   bf-c_clients.obj-code = del_trn-doc.cli-code .
        if bf_clients.db-num <> bf-c_clients.db-num then do:
          return error substitute( "Во внутреннем документе &1 по объекту &2 &3 базы данных &4 контрагентом является объект &5 &6 базы данных &7. Нельзя удалять внутренние документы относящиеся к разным базам данных.",
                                   del_trn-doc.doc-code,
                                   del_trn-doc.obj-type,
                                   del_trn-doc.obj-code,
                                   bf_clients.db-num,
                                   del_trn-doc.cli-type,
                                   del_trn-doc.cli-code,
                                   bf-c_clients.db-num
                                 ) .
        end.
      end.
      if LOOKUP(del_trn-doc.ext-doc-type, 'we,we,we,we,ee':U) > 0 then do:
        define buffer buf_sale-doc for ub.sale-doc.
        find first buf_sale-doc no-lock where
                 buf_sale-doc.doc-code = del_trn-doc.doc-code
             and buf_sale-doc.inkas-code = del_trn-doc.out-code
             and buf_sale-doc.order > 0 no-error.
        if available buf_sale-doc then do:
          run waitfram-hide in parhandle no-error.
          undo, return error substitute("Автодокумент &1, созданный по чекам продажи &2, удаляется только при удалении продажи"
                                  ,del_trn-doc.doc-code
                                  ,del_trn-doc.out-code
                                  ).
        end.
      end.
      if del_trn-doc.ext-doc-type = 'ev':U
      then do:
define variable vss-include-info58 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_tdedt-ras-perem_del-fact':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
      end.
      else do:
        if del_trn-doc.ext-doc-type = 'vp':U
        then do:
define variable vss-include-info59 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_tdedt-peresort_del-fact':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
        end.
        else do:
          case del_trn-doc.doc-type
          :
            when 'при':U
            then do:
define variable vss-include-info60 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_income_del-fact':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
            end.
            when 'рас':U
            then do:
define variable vss-include-info61 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_expense_del-fact':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
            end.
            when 'спи':U
            then do:
define variable vss-include-info62 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_write-off_del-fact':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
            end.
            when 'возврат':U
            then do:
define variable vss-include-info63 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_return_del-fact':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
            end.
            when 'инв':U
            then do:
define variable vss-include-info64 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_inventory_del-fact':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                "Неизвестный тип документа" skip
                "Тип документа" del_trn-doc.doc-type skip
                "Код документа" del_trn-doc.doc-code skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end case.
        end.
      end.
      if g-log = no
      then do:
        run waitfram-hide in parhandle no-error.
        undo, return error "Вы не имеете прав на удаление документа, закрытого на факт.".
      end.
    end.
    else do:
      if del_trn-doc.ext-doc-type = 'ap':U
      then do:
define variable vss-include-info65 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_corr-acc-pr-view_preparation':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
      end.
      else do:
        if del_trn-doc.ext-doc-type = 'vp':U
        then do:
define variable vss-include-info66 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_tdedt-peresort_preparation':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
        end.
        else do:
          case del_trn-doc.doc-type
          :
            when 'при':U
            then do:
define variable vss-include-info67 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_income_preparation':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
            end.
            when 'рас':U
            then do:
              if del_trn-doc.status_ = 'запрос':U then do:
define variable vss-include-info68 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_expense_del-inquiry':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
              end.
              else if del_trn-doc.status_ = 'накл':U and del_trn-doc.flag_ then do:
define variable vss-include-info69 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_expense_del-wayb':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
              end.
              else if del_trn-doc.status_ = 'накл':U and not del_trn-doc.flag_ then do:
define variable vss-include-info70 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_expense_del-wayb-minus':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
              end.
              else do:
define variable vss-include-info71 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_expense_preparation':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
              end.
            end.
            when 'спи':U
            then do:
define variable vss-include-info72 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_write-off_preparation':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
            end.
            when 'возврат':U
            then do:
define variable vss-include-info73 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_return_preparation':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
            end.
            when 'инв':U
            then do:
define variable vss-include-info74 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  parcurdb-num
    ,input  paruserid
    ,input  0
    ,input  'actn_inventory_delete':u
    ,input  'object':U
    ,input  del_trn-doc.host-code
    ,input  del_trn-doc.obj-type
    ,input  del_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
            end.
            otherwise do:
              message
                vss-workfile vss-revision vss-description skip
                "Неизвестный тип документа" skip
                "Тип документа" del_trn-doc.doc-type skip
                "Код документа" del_trn-doc.doc-code skip
                view-as alert-box error .
              undo, return error return-value .
            end.
          end case.
        end.
      end.
      if g-log <> true
      then do:
        run waitfram-hide in parhandle no-error.
        return error "Вы не имеете прав на удаление документа.".
      end.
    end.
    do on error undo, return error return-value :
      for each  bufz_trn-doc exclusive-lock where
                bufz_trn-doc.doc-code = del_trn-doc.out-code and
                bufz_trn-doc.status_  = 'готов':U             :
        assign
            bufz_trn-doc.status_ = 'отказ':U
        .
      end.
      if del_trn-doc.status_ = 'факт':U
      then do:
        run str/chkdeltr.p
          ( input parcurdb-num
          , input paruserid
          , input del_trn-doc.doc-code
          , input parphdoc-code
          , input parfile-name-err
          ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:   run str/lib-trn4.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn4) <> true) then do:     message       "Error starting lib-trn4.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn4 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn4_corrsprc in g#lib-trn4
  (input  '-'
  ,input  del_trn-doc.doc-code
  ,output v-mess
  ) no-error .
        if error-status :error
        then do:
          undo, return error return-value .
        end.
      end.
      if del_trn-doc.status_ <> 'факт':U    and
         del_trn-doc.status_ <> 'запрос':U then do:
        assign
          del_trn-doc.flag_ = no.
        assign
          vardel-line = 0.
        for each del_doc-line where
                 del_doc-line.doc-code = del_trn-doc.doc-code
        on error undo, return error return-value :
          run waitfram-join in parhandle (
             input substitute( "Разрезервирование строк документа &1 перед удалением.", pardoc-code ),
             input substitute( " Товар &1 &2 &3.", del_doc-line.artic, del_doc-line.prod-type, del_doc-line.prod-code ),
             input substitute( " Всего удалено строк: &1", vardel-line ) +
                   substitute( " Время: &1.", string( time - vartime, "hh:mm:ss":U ) ),
            output varmessage            ) no-error.
          run waitfram-show in parhandle ( input varmessage ) no-error.
          assign
            vardel-line = vardel-line + 1.
          if del_trn-doc.ext-doc-type = 'vp':U then do:
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  del_doc-line.obj-type
  ,input  del_doc-line.obj-code
  ,input  del_doc-line.artic
  ,input  del_doc-line.prod-type
  ,input  del_doc-line.prod-code
  ,input  'inv-on=false'
  ,output l-inv-on
  ) no-error .
            if error-status :error then do:
              undo, return error SUBSTITUTE ("Ошибка установки атрибута товара на объекте. Документ &1. Объект &2 &3. Артикул &4 &5 &6. Признак товара в инвентаризации &7.",
                                            del_doc-line.doc-code, del_doc-line.obj-type, del_doc-line.obj-code, del_doc-line.artic, del_doc-line.prod-type, del_doc-line.prod-code, l-inv-on).
            end.
          end.
          run trg/rsrv-del.p ( input del_doc-line.doc-code,
                           input del_doc-line.artic,
                           input del_doc-line.prod-type,
                           input del_doc-line.prod-code ) no-error.
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo, return error "Ошибка при разрезервировании.".
          end.
        end.
      end.
      if del_trn-doc.status_ = 'факт':U then do:
        if parphchip-num <> ? then do:
          assign
            varchip-num-main = parphchip-num.
        end.
        else do:
          assign
            varchip-num-main = next-value( s-corr-chip, ub )
          .
        end.
        assign
          parchip-num = varchip-num-main
        .
        for each del_rvs-doc exclusive-lock
          where del_rvs-doc.out-code = del_trn-doc.doc-code
        on error undo, return error return-value
        :
          run waitfram-join in parhandle (
             input substitute( "Создание истории по сверкам документа &1 и их удаление.", pardoc-code ),
             input '':U,
             input substitute( " Время: &1.", string( time - vartime, "hh:mm:ss":U ) ),
            output varmessage            ) no-error.
          run waitfram-show in parhandle ( input varmessage ) no-error.
if valid-handle( g#lib-rvs ) <> yes then do:       run str/lib-rvs.p persistent no-error.       if error-status :error or valid-handle( g#lib-rvs ) <> yes then do:         message "Error starting lib-rvs.p" skip( 0 )           g#lib-rvs                        skip( 0 )           g#lib-rvs    :type               skip( 0 )           g#lib-rvs    :file-name          skip( 0 )           error-status :get-message( 1 )   skip( 0 )           return-value                     skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rvs_hstc-rvs in g#lib-rvs
( buffer del_rvs-doc
 ,input integer('99':U)
 ,input del_trn-doc.doc-code
 ,input varchip-num-main
) no-error.
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo, return error return-value.
          end.
          assign
            del_rvs-doc.is-del = yes
          .
          delete del_rvs-doc.
        end.
        run waitfram-join in parhandle (  input substitute( "Создание истории по удаляемому документу &1.", pardoc-code ),
                                          input '':U,
                                          input substitute( " Время: &1.", string( time - vartime, "hh:mm:ss":U ) ),
                                         output varmessage ) no-error.
        run waitfram-show in parhandle (  input varmessage ) no-error.
        assign
          del_trn-doc.is-del = yes
        .
        if del_trn-doc.d-card <> "":U and del_trn-doc.d-card <> ? then do:
          run str/saledc.p ( input parparentproc
                      , input ?
                      , input ?
                      , input 'trn-doc-delete':U
                      , input ?
                      , input ""
                      , input 0
                      , input 0
                      , input 0
                      , input parcurdb-num
                      , input del_trn-doc.doc-code
                      , input del_trn-doc.doc-date
                      , input del_trn-doc.fact-date
                      , input ?
                      , input ( -1 )
                      , input ( if del_trn-doc.ext-doc-type = 're':U then -1 else 1 )
                      , input yes
                      ) no-error .
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo, return error return-value.
          end.
        end.
        run lib-trn_hstd-trn in this-procedure ( input del_trn-doc.doc-code, input varchip-num-main ) no-error.
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo, return error return-value.
        end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_hstc-trn in g#lib-trn
  (
    input recid(del_trn-doc)
  , input varobj-date
  , input varshift-date
  , input varshift-num
  , input varshift-name
  , input parcorr-inkas-code
  , input parcorr-fbr-code
  , input paruserid
  , input parcurdb-num
  , input varchip-num-main
  ) no-error.
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo, return error return-value.
        end.
        run trg/trndocdl.p ( input del_trn-doc.doc-code, input varchip-num-main ) no-error.
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo, return error substitute("Ошибка при удалении складского документа &2&1&3", chr(10), del_trn-doc.doc-code, return-value ).
        end.
      end.
      else do :
        define variable v-del-fo as logical no-undo .
        define variable v-kol-trn-fo as integer no-undo .
        v-del-fo = true .
        v-kol-trn-fo = 0.
        for each del_fin-ob-trn where del_fin-ob-trn.trn-doc-code = del_trn-doc.doc-code  and
                                      del_fin-ob-trn.host-code    = del_trn-doc.host-code exclusive-lock,
                each del_fin-ob where del_fin-ob.doc-code = del_fin-ob-trn.doc-code  exclusive-lock
                :
                for each bf_fin-ob-trn where bf_fin-ob-trn.doc-code = del_fin-ob.doc-code and
                                                 bf_fin-ob-trn.trn-doc-code <> del_trn-doc.doc-code      no-lock:
                      v-kol-trn-fo = v-kol-trn-fo + 1.
                end.
                    if v-kol-trn-fo > 0 then do :
                      assign
                        v-del-fo = false .
                      message substitute ("ФО №&1 по данной накладной не будет удалено, т.к. сформированно по нескольким накладным", del_fin-ob.doc-code) view-as alert-box .
                    end.
                if del_fin-ob.status_ <> 'факт':U or (del_fin-ob.status_ = 'факт':U and del_fin-ob.con-stat = 0) and v-del-fo then do :
                  assign
                    del_fin-ob.is-doc-del = yes.
                    del_fin-ob-trn.is-doc-del = yes.
                  delete del_fin-ob.
                  if available del_fin-ob-trn then delete del_fin-ob-trn.
                end.
                else if del_fin-ob.status_ = 'факт':U and del_fin-ob.con-stat <> 0 then do :
                    message substitute ("ФО №&1 по данной накладной не будет удалено, т.к. есть платежи", del_fin-ob.doc-code) view-as alert-box .
                end.
        end.
      end.
      if del_trn-doc.ext-doc-type = 'ap':U then do:
        assign
          vardel-line = 0.
        for each del_doc-line where
                 del_doc-line.doc-code = del_trn-doc.doc-code
        on error undo, return error return-value :
          run waitfram-join in parhandle (
             input substitute( "Снятие атрибута 'товар в инвентаризации' со строк документа &1.", pardoc-code ),
             input substitute( " Товар &1 &2 &3.", del_doc-line.artic, del_doc-line.prod-type, del_doc-line.prod-code ),
             input substitute( " Всего удалено строк: ", vardel-line ) +
                   substitute( " Время: &1.", string( time - vartime, "hh:mm:ss":U ) ),
            output varmessage            ) no-error.
          run waitfram-show in parhandle ( input varmessage ) no-error.
          assign
            vardel-line = vardel-line + 1.
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  del_doc-line.obj-type
  ,input  del_doc-line.obj-code
  ,input  del_doc-line.artic
  ,input  del_doc-line.prod-type
  ,input  del_doc-line.prod-code
  ,input  'inv-on=false'
  ,output l-inv-on
  ) no-error .
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo, return error substitute(
              "Ошибка установки атрибута товара на объекте. Документ &1 Объект &2 &3 Товар &4 &5 &6 l-inv-on &7."
              , del_doc-line.doc-code
              , del_doc-line.obj-type
              , del_doc-line.obj-code
              , del_doc-line.artic
              , del_doc-line.prod-type
              , del_doc-line.prod-code
              , l-inv-on                 ).
          end.
        end.
      end.
   for each ub.ord-chain exclusive-lock where
            ub.ord-chain.rel-doc-code = del_trn-doc.doc-code and
            ub.ord-chain.rel-doc-type = 'trn'
            :
      if ub.ord-chain.doc-type = 'rcv'  then do:
          find first bf_ord-doc-rcv exclusive-lock where
                     bf_ord-doc-rcv.rcv-code =  ub.ord-chain.doc-code
          no-error .
          if available bf_ord-doc-rcv then do:
             bf_ord-doc-rcv.status_ = 'поставка':U.
          end.
      end.
      delete ub.ord-chain.
   end.
     find first bf_ord-doc exclusive-lock where bf_ord-doc.doc-code = bf_ord-doc-rcv.doc-code and
                                                bf_ord-doc.doc-type = 'ОР':U no-error .
     if available bf_ord-doc then do:
       assign
        bf_ord-doc.status_ =  'запрос':U
        bf_ord-doc.flag_   =  true
        bf_ord-doc.fact-date  =  ?
       .
     end.
      if del_trn-doc.ext-doc-type = 'vt':U then do:
        run str/del-invc.p ( input del_trn-doc.doc-code
                        ,input del_trn-doc.obj-type
                        ,input del_trn-doc.obj-code ).
      end.
      if del_trn-doc.status_ = 'факт':U then do:
        run str/vtrecalc.p ( input parparentproc
                           , input recid (del_trn-doc)
                           ) no-error .
        if error-status :error then do:
           run waitfram-hide in parhandle no-error.
           undo, return error return-value .
        end.
      end.
      if del_trn-doc.status_ = 'факт':U then do:
        v-flag-del = false .
        for each   del_turnover-buyer exclusive-lock where
                   del_turnover-buyer.doc-code = del_trn-doc.doc-code :
            delete del_turnover-buyer .
            v-flag-del = true  .
        end.
        if v-flag-del = true then
            run ref/calctur1.p ( input del_trn-doc.cli-type,
                                input del_trn-doc.cli-code,
                                input del_trn-doc.obj-type,
                                input del_trn-doc.obj-code,
                                input del_trn-doc.fact-order - 0.0000000001
                                ).
      end.
      run waitfram-hide in parhandle no-error.
      delete del_trn-doc.
    end.
  end.
end procedure.
procedure lib-trn_chkaddln :
define input  parameter pardb-num       as integer   no-undo .
define input  parameter paruserid       as character no-undo .
define input parameter parobj-type      like ub.trn-doc.obj-type     no-undo.
define input parameter parobj-code      like ub.trn-doc.obj-code     no-undo.
define input parameter parartic         like ub.doc-line.artic       no-undo.
define input parameter parprod-type     like ub.doc-line.prod-type   no-undo.
define input parameter parprod-code     like ub.doc-line.prod-code   no-undo.
define input parameter pardoc-code      like ub.trn-doc.doc-code     no-undo.
define input parameter parfact-order    like ub.trn-doc.fact-order   no-undo.
define input parameter pardoc-type      like ub.trn-doc.doc-type     no-undo.
define input parameter parext-doc-type  like ub.trn-doc.ext-doc-type no-undo.
define input parameter parshift-date    like ub.trn-doc.shift-date   no-undo.
define input parameter parshift-num     like ub.trn-doc.shift-num    no-undo.
define input parameter parfact-qnty     like ub.trn-doc.fact-qnty    no-undo.
define input parameter parfile-name-err as   character               no-undo.
define buffer cad_goods       for ub.goods.
define buffer cadinv_doc-line for ub.doc-line.
define buffer cad_shift-obj   for ub.shift-obj.
define buffer cad_rvs-doc     for ub.rvs-doc.
define buffer cad_rvs-line    for ub.rvs-line.
define buffer cad_doc-line    for ub.doc-line.
define buffer cad_price-list  for ub.price-list.
define buffer cad_bar-code    for ub.bar-code.
define variable varflag-err     as logical no-undo.
define variable l-shift-on      as logical no-undo.
define variable varis-petrolium as logical no-undo.
define variable varis-pieces    as logical no-undo.
define variable g-log           as logical no-undo.
define variable v-root-node     as integer no-undo.
define variable varis-new       as logical no-undo.
define variable v-action        as character no-undo .
define variable v-chk-act-host-code as integer   no-undo .
do
on error undo, return error return-value
:
assign g-log = no.
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-chk-act-host-code
  )  .
define variable v-value-character as character no-undo .
define variable v-value-date      as date no-undo .
define variable v-value-decimal   as decimal no-undo .
define variable v-value-integer   as integer no-undo .
define variable v-value-logical   as logical no-undo .
define variable v-tth             as handle no-undo .
define variable v-back-date as logical   no-undo .
define variable v-back-date-type as character no-undo .
      delete object v-tth no-error.
      run adm/shattri.p (
           input "get":U
          ,input parobj-type
          ,input parobj-code
          ,input 'nakl_par':U
          ,input  "back-date"
          ,output v-value-character
          ,output v-value-date
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-back-date
          ,output v-back-date-type
          ,INPUT-OUTPUT table-handle v-tth
          ) no-error .
          if error-status :error  then v-back-date = false .
          delete object v-tth no-error.
    if v-back-date <> true then do:
        output stream str-err to value(parfile-name-err) append.
        put stream str-err unformatted substitute (" Запрещено добавление документов прошедшей датой." ).
        output stream str-err close.
        return error "CRITICAL".
    end.
case pardoc-type
:
  when 'при':U then do:
    assign
      v-action = 'actn_income_add-back-date':u
    .
  end.
  when 'рас':U then do:
    assign
      v-action = 'actn_expense_add-back-date':u
    .
  end.
  when 'спи':U then do:
    assign
      v-action = 'actn_write-off_add-back-date':u
    .
  end.
  when 'возврат':U then do:
    assign
      v-action = 'actn_return_add-back-date':u
    .
  end.
  when 'инв':U then do:
    assign
      v-action = 'actn_inventory_add-back-date':u
    .
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный тип документа" skip
      "Тип документа" pardoc-type skip
      "Код документа" pardoc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end case.
define variable vss-include-info78 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  pardb-num
    ,input  paruserid
    ,input  0
    ,input  v-action
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  parobj-type
    ,input  parobj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
if not g-log then do:
  output stream str-err to value(parfile-name-err) append.
  put stream str-err unformatted substitute (" Вы не имеете прав на добавление документов прошедшей датой." ).
  output stream str-err close.
  return error "CRITICAL".
end.
find first cad_goods no-lock
  where cad_goods.artic     = parartic
    and cad_goods.prod-type = parprod-type
    and cad_goods.prod-code = parprod-code
  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input parartic
  ,  input parprod-type
  ,  input parprod-code
  , output varis-petrolium
  , output varis-pieces
  ) no-error.
if error-status :error then do:
  output stream str-err to value(parfile-name-err) append.
  put stream str-err unformatted return-value.
  output stream str-err close.
  return error "CRITICAL".
end.
if varis-petrolium = yes
  and varis-pieces    = no
then do:
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  parobj-type
  ,input  parobj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
  if l-shift-on then do:
    find first cad_shift-obj
      where cad_shift-obj.obj-type = parobj-type
        and cad_shift-obj.obj-code = parobj-code
        and cad_shift-obj.status_  = 'тек':U
      no-error.
    if not available cad_shift-obj
      or cad_shift-obj.shift-date <> parshift-date
      or cad_shift-obj.shift-num  <> parshift-num
    then do:
      case pardoc-type
      :
        when 'при':U then do:
          assign
            v-action = 'actn_income_add-ptrl-prev-shft':u
          .
        end.
        when 'рас':U then do:
          assign
            v-action = 'actn_expense_add-ptrl-prev-shft':u
          .
        end.
        when 'спи':U then do:
          assign
            v-action = 'actn_write-off_add-ptrl-prev-shft':u
          .
        end.
        when 'возврат':U then do:
          assign
            v-action = 'actn_return_add-ptrl-prev-shft':u
          .
        end.
        when 'инв':U then do:
          assign
            v-action = 'actn_inventory_add-ptrl-prev-shft':u
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Неизвестный тип документа" skip
            "Тип документа" pardoc-type skip
            "Код документа" pardoc-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end case.
define variable vss-include-info80 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  pardb-num
    ,input  paruserid
    ,input  0
    ,input  v-action
    ,input  'object':U
    ,input  v-chk-act-host-code
    ,input  parobj-type
    ,input  parobj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output g-log
    )  .
end.
      if not g-log then do:
        output stream str-err to value(parfile-name-err) append.
        put stream str-err unformatted substitute ("Товар &1 &2 &3 &4 - топливо. Вы не имеете прав на создание документов по топливу в предыдущих сменах. Документы можно добавлять только в текущей смене."
                                , parartic
                                , parprod-type
                                , parprod-code
                                , cad_goods.gds-name).
        output stream str-err close.
        return error "CRITICAL".
      end.
    end.
  end.
      for each cad_rvs-doc where cad_rvs-doc.obj-type = parobj-type and                                              cad_rvs-doc.obj-code = parobj-code and                                              cad_rvs-doc.status_  > 'факт':U and                                           cad_rvs-doc.rvs-type ne 'проверка':U and                                            cad_rvs-doc.out-code <> pardoc-code no-lock ,                first cad_rvs-line where cad_rvs-line.gds-code = cad_goods.gds-code   and                                    cad_rvs-line.rvs-code = cad_rvs-doc.rvs-code and                                    cad_rvs-line.obj-type = parobj-type          and                                    cad_rvs-line.obj-code = parobj-code          no-lock   on error undo, return error return-value                                        :                                                                                 output stream str-err to value(parfile-name-err) append.                        put stream str-err unformatted substitute ("По товару &1 &2 &3 &4 есть незакрытая сверка &5",                                                       parartic,                                                                      parprod-type,                                                                  parprod-code,                                                                  cad_goods.gds-name,                                                            cad_rvs-line.rvs-code) skip.     output stream str-err close.                                                  assign varflag-err = yes.     end.
    for each cad_rvs-doc where cad_rvs-doc.obj-type = parobj-type and                                              cad_rvs-doc.obj-code = parobj-code and                                              cad_rvs-doc.status_  < 'факт':U and                                           cad_rvs-doc.rvs-type ne 'проверка':U and                                            cad_rvs-doc.out-code <> pardoc-code no-lock ,                first cad_rvs-line where cad_rvs-line.gds-code = cad_goods.gds-code   and                                    cad_rvs-line.rvs-code = cad_rvs-doc.rvs-code and                                    cad_rvs-line.obj-type = parobj-type          and                                    cad_rvs-line.obj-code = parobj-code          no-lock   on error undo, return error return-value                                        :                                                                                 output stream str-err to value(parfile-name-err) append.                        put stream str-err unformatted substitute ("По товару &1 &2 &3 &4 есть незакрытая сверка &5",                                                       parartic,                                                                      parprod-type,                                                                  parprod-code,                                                                  cad_goods.gds-name,                                                            cad_rvs-line.rvs-code) skip.     output stream str-err close.                                                  assign varflag-err = yes.     end.
end.
for each cad_doc-line where cad_doc-line.obj-type  = parobj-type   and                                     cad_doc-line.obj-code  = parobj-code   and                                     cad_doc-line.prod-type = parprod-type  and                                     cad_doc-line.prod-code = parprod-code  and                                     cad_doc-line.artic     = parartic      and                                     cad_doc-line.ext-doc-type = 'vt':U and                                   cad_doc-line.status_   > 'факт':U and                                   cad_doc-line.doc-code  <> pardoc-code  no-lock    on error undo, return error return-value                                      :                                                                                  output stream str-err to value(parfile-name-err) append.                      put stream str-err unformatted  substitute ("По товару &1 &2 &3 &4 есть открытый документ &5.",                                                  parartic,                                                                     parprod-type,                                                                 parprod-code,                                                                 cad_goods.gds-name,                                                           cad_doc-line.doc-code) skip.     output stream str-err close.                                                  assign varflag-err = yes.   end.
for each cad_doc-line where cad_doc-line.obj-type  = parobj-type   and                                     cad_doc-line.obj-code  = parobj-code   and                                     cad_doc-line.prod-type = parprod-type  and                                     cad_doc-line.prod-code = parprod-code  and                                     cad_doc-line.artic     = parartic      and                                     cad_doc-line.ext-doc-type = 'vt':U and                                   cad_doc-line.status_   < 'факт':U and                                   cad_doc-line.doc-code  <> pardoc-code  no-lock    on error undo, return error return-value                                      :                                                                                  output stream str-err to value(parfile-name-err) append.                      put stream str-err unformatted  substitute ("По товару &1 &2 &3 &4 есть открытый документ &5.",                                                  parartic,                                                                     parprod-type,                                                                 parprod-code,                                                                 cad_goods.gds-name,                                                           cad_doc-line.doc-code) skip.     output stream str-err close.                                                  assign varflag-err = yes.   end.
for each cad_doc-line where cad_doc-line.obj-type  = parobj-type   and                                     cad_doc-line.obj-code  = parobj-code   and                                     cad_doc-line.prod-type = parprod-type  and                                     cad_doc-line.prod-code = parprod-code  and                                     cad_doc-line.artic     = parartic      and                                     cad_doc-line.ext-doc-type = 'vp':U and                                   cad_doc-line.status_   > 'факт':U and                                    cad_doc-line.doc-code  <> pardoc-code  no-lock    on error undo, return error return-value                                      :                                                                                  output stream str-err to value(parfile-name-err) append.                      put stream str-err unformatted  substitute ("По товару &1 &2 &3 &4 есть открытый документ &5.",                                                  parartic,                                                                     parprod-type,                                                                 parprod-code,                                                                 cad_goods.gds-name,                                                           cad_doc-line.doc-code) skip.     output stream str-err close.                                                  assign varflag-err = yes.   end.
for each cad_doc-line where cad_doc-line.obj-type  = parobj-type   and                                     cad_doc-line.obj-code  = parobj-code   and                                     cad_doc-line.prod-type = parprod-type  and                                     cad_doc-line.prod-code = parprod-code  and                                     cad_doc-line.artic     = parartic      and                                     cad_doc-line.ext-doc-type = 'vp':U and                                   cad_doc-line.status_   < 'факт':U and                                    cad_doc-line.doc-code  <> pardoc-code  no-lock    on error undo, return error return-value                                      :                                                                                  output stream str-err to value(parfile-name-err) append.                      put stream str-err unformatted  substitute ("По товару &1 &2 &3 &4 есть открытый документ &5.",                                                  parartic,                                                                     parprod-type,                                                                 parprod-code,                                                                 cad_goods.gds-name,                                                           cad_doc-line.doc-code) skip.     output stream str-err close.                                                  assign varflag-err = yes.   end.
if varflag-err = yes then do:
  return error.
end.
end.
end procedure.
procedure lib-trn_hstc-trn :
  define input parameter parrec-trn-doc     as   recid                        no-undo.
  define input parameter parobj-date        as   date                         no-undo.
  define input parameter parshift-date      like ub.shift-obj.shift-date      no-undo.
  define input parameter parshift-num       like ub.shift-obj.shift-num       no-undo.
  define input parameter parshift-name      like ub.shift-obj.shift-name      no-undo.
  define input parameter parcorr-incas-code like ub.c-trn-doc.corr-inkas-code no-undo.
  define input parameter parcorr-fbr-code   like ub.c-trn-doc.corr-fbr-code   no-undo.
  define input parameter paruserid          as   character                    no-undo.
  define input parameter parcurdb-num       as   integer                      no-undo.
  define input parameter parchip-num        as   integer                      no-undo.
  define buffer hstc_trn-doc         for ub.trn-doc.
  define buffer hstc_trn-doc-sum     for ub.trn-doc-sum.
  define buffer hstc_doc-line        for ub.doc-line.
  define buffer hstc_doc-line-attr   for ub.doc-line-attr.
  define buffer hstc_doc-line-sum    for ub.doc-line-sum.
  define buffer hstc_gds-dtl         for ub.gds-dtl.
  define buffer hstc_parts           for ub.parts.
  define buffer hstc_parts-root      for ub.parts-root.
  define buffer hstc_parts-attr      for ub.parts-attr.
  define buffer hstc_doc-prts        for ub.doc-prts.
  define buffer hstc_doc-pl          for ub.doc-pl.
  define buffer hstc_doc-pl-pump     for ub.doc-pl-pump.
  define buffer hstc_doc-attr        for ub.doc-attr.
  define buffer hstc_doc-fbr-gds     for ub.doc-fbr-gds.
  define buffer hstc_c-trn-doc       for ub.c-trn-doc.
  define buffer hstc_c-trn-doc-sum   for ub.c-trn-doc-sum.
  define buffer hstc_c-doc-line      for ub.c-doc-line.
  define buffer hstc_c-doc-line-attr for ub.c-doc-line-attr.
  define buffer hstc_c-doc-line-sum  for ub.c-doc-line-sum.
  define buffer hstc_c-gds-dtl       for ub.c-gds-dtl.
  define buffer hstc_c-parts         for ub.c-parts.
  define buffer hstc_c-parts-root    for ub.c-parts-root.
  define buffer hstc_c-parts-attr    for ub.c-parts-attr.
  define buffer hstc_c-doc-prts      for ub.c-doc-prts.
  define buffer hstc_c-doc-pl        for ub.c-doc-pl.
  define buffer hstc_c-doc-pl-pump   for ub.c-doc-pl-pump.
  define buffer hstc_c-doc-attr      for ub.c-doc-attr.
  define buffer hstc_c-doc-fbr-gds   for ub.c-doc-fbr-gds.
  do on error undo, return error return-value :
    find first hstc_trn-doc where recid( hstc_trn-doc ) = parrec-trn-doc.
    create hstc_c-trn-doc.
    buffer-copy hstc_trn-doc to hstc_c-trn-doc.
    assign
      hstc_c-trn-doc.chip-num        = parchip-num
      hstc_c-trn-doc.corr-user-name  = paruserid
      hstc_c-trn-doc.corr-user-db-num = parcurdb-num
      hstc_c-trn-doc.corr-inkas-code = parcorr-incas-code
      hstc_c-trn-doc.corr-fbr-code   = parcorr-fbr-code
      hstc_c-trn-doc.corr-date       = parobj-date
      hstc_c-trn-doc.corr-shift-date = parshift-date
      hstc_c-trn-doc.corr-shift-num  = parshift-num
      hstc_c-trn-doc.corr-shift-name = parshift-name
      hstc_c-trn-doc.bge-date        = ?
      hstc_c-trn-doc.scf-date        = ?
    .
    for each hstc_trn-doc-sum where hstc_trn-doc-sum.doc-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-trn-doc-sum.
      buffer-copy hstc_trn-doc-sum to hstc_c-trn-doc-sum.
      assign hstc_c-trn-doc-sum.chip-num         = hstc_c-trn-doc.chip-num
             hstc_c-trn-doc-sum.corr-user-db-num = hstc_c-trn-doc.user-db-num
      .
    end.
    for each hstc_doc-attr where hstc_doc-attr.doc-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-doc-attr.
      buffer-copy hstc_doc-attr to hstc_c-doc-attr.
      assign hstc_c-doc-attr.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_doc-line where hstc_doc-line.doc-code = hstc_trn-doc.doc-code on error undo, return error return-value :
        create hstc_c-doc-line.
        buffer-copy hstc_doc-line to hstc_c-doc-line.
        assign hstc_c-doc-line.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_doc-line-attr where hstc_doc-line-attr.doc-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-doc-line-attr.
      buffer-copy hstc_doc-line-attr to hstc_c-doc-line-attr.
      assign hstc_c-doc-line-attr.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_doc-line-sum where hstc_doc-line-sum.doc-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-doc-line-sum.
      buffer-copy hstc_doc-line-sum to hstc_c-doc-line-sum.
      assign hstc_c-doc-line-sum.chip-num         = hstc_c-trn-doc.chip-num
             hstc_c-doc-line-sum.corr-user-db-num = hstc_c-trn-doc.user-db-num
      .
    end.
    for each hstc_gds-dtl where hstc_gds-dtl.doc-code = hstc_trn-doc.doc-code on error undo, return error return-value :
        create hstc_c-gds-dtl.
        buffer-copy hstc_gds-dtl to hstc_c-gds-dtl.
        assign hstc_c-gds-dtl.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_parts where hstc_parts.out-code = hstc_trn-doc.doc-code on error undo, return error return-value :
        create hstc_c-parts.
        buffer-copy hstc_parts to hstc_c-parts.
        assign hstc_c-parts.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_parts-root where hstc_parts-root.doc-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-parts-root.
      buffer-copy hstc_parts-root to hstc_c-parts-root.
      assign hstc_c-parts-root.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_parts-attr where hstc_parts-attr.in-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-parts-attr.
      buffer-copy hstc_parts-attr to hstc_c-parts-attr.
      assign hstc_c-parts-attr.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_doc-prts where hstc_doc-prts.out-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-doc-prts.
      buffer-copy hstc_doc-prts to hstc_c-doc-prts.
      assign hstc_c-doc-prts.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_doc-pl where hstc_doc-pl.out-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-doc-pl.
      buffer-copy hstc_doc-pl to hstc_c-doc-pl.
      assign hstc_c-doc-pl.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_doc-pl-pump where hstc_doc-pl-pump.out-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-doc-pl-pump.
      buffer-copy hstc_doc-pl-pump to hstc_c-doc-pl-pump.
      assign hstc_c-doc-pl-pump.chip-num = hstc_c-trn-doc.chip-num.
    end.
    for each hstc_doc-fbr-gds where hstc_doc-fbr-gds.out-code = hstc_trn-doc.doc-code on error undo, return error return-value :
      create hstc_c-doc-fbr-gds.
      buffer-copy hstc_doc-fbr-gds to hstc_c-doc-fbr-gds.
      assign hstc_c-doc-fbr-gds.chip-num = hstc_c-trn-doc.chip-num.
    end.
  if hstc_c-trn-doc.need-buyer = 1   and
     hstc_c-trn-doc.cr-fo-buyer   = yes then do:
    assign
      hstc_c-trn-doc.cr-fo-buyer      = no
      hstc_c-trn-doc.buyer-fo-date    = 01/01/1990.
  end.
  else do:
    assign
      hstc_c-trn-doc.need-buyer = 0
      hstc_c-trn-doc.cr-fo-buyer   = no
      hstc_c-trn-doc.buyer-fo-date = 01/01/1990.
  end.
  if hstc_c-trn-doc.need-incfo = 1   and
     hstc_c-trn-doc.cr-incfo   = yes then do:
    assign
      hstc_c-trn-doc.cr-incfo      = no
      hstc_c-trn-doc.incfo-date    = 01/01/1990.
  end.
  else do:
    assign
      hstc_c-trn-doc.need-incfo = 0
      hstc_c-trn-doc.cr-incfo   = no
      hstc_c-trn-doc.incfo-date = 01/01/1990.
  end.
  if hstc_c-trn-doc.need-expfo = 1   and
     hstc_c-trn-doc.cr-expfo   = yes then do:
    assign
      hstc_c-trn-doc.cr-expfo      = no
      hstc_c-trn-doc.expfo-date    = 01/01/1990.
  end.
  else do:
    assign
      hstc_c-trn-doc.need-expfo = 0
      hstc_c-trn-doc.cr-expfo   = no
      hstc_c-trn-doc.incfo-date = 01/01/1990.
  end.
  if hstc_c-trn-doc.need-incfo = 1 or
     hstc_c-trn-doc.need-expfo = 1 then do:
    assign
      hstc_c-trn-doc.need-incorexpfo = 1.
  end.
  if hstc_c-trn-doc.cr-incfo = yes or
     hstc_c-trn-doc.cr-expfo = yes then do:
    assign
      hstc_c-trn-doc.cr-incorexpfo = yes.
  end.
  end.
end procedure.
procedure lib-trn_hstd-trn :
  define input parameter p-doc-code like ub.trn-doc.doc-code   no-undo.
  define input parameter p-chip-num like ub.c-trn-doc.chip-num no-undo.
  define buffer bf_goods       for ub.goods.
  define buffer bf_pl-gds-pump for ub.pl-gds-pump.
  define buffer bf_place       for ub.place.
  define buffer bf_rvs-doc     for ub.rvs-doc.
  do on error   undo, return error return-value
     on end-key undo, return error return-value
     on stop    undo, return error return-value :
    for each ub.c-trn-doc where
             ub.c-trn-doc.doc-code  = p-doc-code and
             ub.c-trn-doc.chip-num <> p-chip-num :
      delete ub.c-trn-doc.
    end.
    for each ub.c-trn-doc-sum where
             ub.c-trn-doc-sum.doc-code  = p-doc-code and
             ub.c-trn-doc-sum.chip-num <> p-chip-num :
      delete ub.c-trn-doc-sum.
    end.
    for each ub.c-doc-attr where
             ub.c-doc-attr.doc-code  = p-doc-code and
             ub.c-doc-attr.chip-num <> p-chip-num :
      delete ub.c-doc-attr.
    end.
    for each bf_rvs-doc no-lock where bf_rvs-doc.out-code = p-doc-code :
      for each ub.c-rvs-doc where
               ub.c-rvs-doc.rvs-code =  bf_rvs-doc.rvs-code and
               ub.c-rvs-doc.chip-num <> p-chip-num          :
        delete ub.c-rvs-doc.
      end.
    end.
    for each ub.c-doc-line where
             ub.c-doc-line.doc-code =  p-doc-code and
             ub.c-doc-line.chip-num <> p-chip-num :
      find first bf_goods no-lock where
                 bf_goods.artic     = ub.c-doc-line.artic     and
                 bf_goods.prod-type = ub.c-doc-line.prod-type and
                 bf_goods.prod-code = ub.c-doc-line.prod-code .
      for each ub.c-parts where
               ub.c-parts.out-code  =  ub.c-doc-line.doc-code  and
               ub.c-parts.obj-type  =  ub.c-doc-line.obj-type  and
               ub.c-parts.obj-code  =  ub.c-doc-line.obj-code  and
               ub.c-parts.artic     =  ub.c-doc-line.artic     and
               ub.c-parts.prod-type =  ub.c-doc-line.prod-type and
               ub.c-parts.prod-code =  ub.c-doc-line.prod-code and
               ub.c-parts.chip-num  <> p-chip-num              :
        for each ub.c-parts-root where
                 ub.c-parts-root.doc-code       =  ub.c-parts.out-code  and
                 ub.c-parts-root.orig-in-code   =  ub.c-parts.in-code   and
                 ub.c-parts-root.orig-gds-code  =  ub.c-goods.gds-code  and
                 ub.c-parts-root.orig-part-code =  ub.c-parts.part-code and
                 ub.c-parts-root.chip-num       <> p-chip-num           :
          delete ub.c-parts-root.
        end.
        delete ub.c-parts.
      end.
      for each ub.c-parts-attr where
               ub.c-parts-attr.in-code  =  ub.c-doc-line.doc-code and
               ub.c-parts-attr.gds-code =  ub.c-goods.gds-code    and
               ub.c-parts-attr.chip-num <> p-chip-num             :
        delete ub.c-parts-attr.
      end.
      for each ub.c-gds-dtl where
               ub.c-gds-dtl.doc-code  =  ub.c-doc-line.doc-code  and
               ub.c-gds-dtl.artic     =  ub.c-doc-line.artic     and
               ub.c-gds-dtl.prod-type =  ub.c-doc-line.prod-type and
               ub.c-gds-dtl.prod-code =  ub.c-doc-line.prod-code and
               ub.c-gds-dtl.chip-num  <> p-chip-num              :
        delete ub.c-gds-dtl.
      end.
      for each ub.c-doc-prts where
               ub.c-doc-prts.out-code =  ub.c-doc-line.doc-code and
               ub.c-doc-prts.gds-code =  ub.c-goods.gds-code    and
               ub.c-doc-prts.chip-num <> p-chip-num             :
        delete ub.c-doc-prts.
      end.
      for each ub.c-doc-pl where
               ub.c-doc-pl.out-code =  ub.c-doc-line.doc-code and
               ub.c-doc-pl.gds-code =  ub.c-goods.gds-code    and
               ub.c-doc-pl.chip-num <> p-chip-num             :
        delete ub.c-doc-pl.
      end.
      find first ub.c-doc-pl-pump where ub.c-doc-pl-pump.gds-code = bf_goods.gds-code no-error.
      if available ub.c-doc-pl-pump then do:
        for each bf_place       no-lock where
                 bf_place.obj-type       = ub.c-doc-line.obj-type and
                 bf_place.obj-code       = ub.c-doc-line.obj-code
          , each bf_pl-gds-pump no-lock where
                 bf_pl-gds-pump.obj-type = bf_place.obj-type      and
                 bf_pl-gds-pump.obj-code = bf_place.obj-code      and
                 bf_pl-gds-pump.pl-code  = bf_place.pl-code       and
                 bf_pl-gds-pump.gds-code = bf_goods.gds-code      :
          for each ub.c-doc-pl-pump where
                   ub.c-doc-pl-pump.obj-type  =  bf_pl-gds-pump.obj-type  and
                   ub.c-doc-pl-pump.obj-code  =  bf_pl-gds-pump.obj-code  and
                   ub.c-doc-pl-pump.pl-code   =  bf_pl-gds-pump.pl-code   and
                   ub.c-doc-pl-pump.pump-code =  bf_pl-gds-pump.pump-code and
                   ub.c-doc-pl-pump.out-code  =  ub.c-doc-line.doc-code   and
                   ub.c-doc-pl-pump.gds-code  =  bf_goods.gds-code        and
                   ub.c-doc-pl-pump.chip-num  <> p-chip-num               :
            delete ub.c-doc-pl-pump.
          end.
        end.
      end.
      for each ub.c-doc-line-attr where
               ub.c-doc-line-attr.doc-code =  ub.c-doc-line.doc-code and
               ub.c-doc-line-attr.gds-code =  bf_goods.gds-code      and
               ub.c-doc-line-attr.chip-num <> p-chip-num             :
        delete ub.c-doc-line-attr.
      end.
      for each ub.c-doc-line-sum where
               ub.c-doc-line-sum.doc-code =  ub.c-doc-line.doc-code and
               ub.c-doc-line-sum.gds-code =  bf_goods.gds-code      and
               ub.c-doc-line-sum.chip-num <> p-chip-num             :
        delete ub.c-doc-line-sum.
      end.
      for each ub.c-doc-fbr-gds where
               ub.c-doc-fbr-gds.out-code =  ub.c-doc-line.doc-code and
               ub.c-doc-fbr-gds.gds-code =  bf_goods.gds-code      and
               ub.c-doc-fbr-gds.chip-num <> p-chip-num             :
        delete ub.c-doc-fbr-gds.
      end.
      delete ub.c-doc-line.
    end.
  end.
end procedure.
procedure lib-trn_crdoclno :
  define input parameter pardoc-code    like ub.trn-doc.doc-code     no-undo.
  define input parameter parobj-type    like ub.trn-doc.obj-type     no-undo.
  define input parameter parobj-code    like ub.trn-doc.obj-code     no-undo.
  define input parameter parartic       like ub.goods.artic          no-undo.
  define input parameter parprod-type   like ub.goods.prod-type      no-undo.
  define input parameter parprod-code   like ub.goods.prod-code      no-undo.
  define input parameter pargds-name    like ub.goods.gds-name       no-undo.
  define input parameter parprt-root    like ub.goods.prt-root       no-undo.
  define input parameter parvat-pc      like ub.doc-line.vat-pc      no-undo.
  define input parameter parcons-vat-pc like ub.doc-line.cons-vat-pc no-undo.
  define input parameter parcash-pay    like ub.sysconf.cash-pay     no-undo.
  define variable l-inv-on           as logical             no-undo .
  define variable v-clcdoc-host-code like ub.sysconf.host-code no-undo .
  define variable v-clcdoc-vat-pc    like ub.doc-line.vat-pc   no-undo .
  define variable v-clcdoc-slt-pc    like ub.doc-line.slt-pc   no-undo .
  define variable g-log              as logical             no-undo .
  define buffer crd_doc-line for ub.doc-line.
  define buffer crd_trn-doc  for ub.trn-doc.
  define buffer crd_goods    for ub.goods.
  define buffer crd_sysconf  for ub.sysconf.
  do on error undo, return error return-value :
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  parobj-type
  ,input  parobj-code
  ,input  parartic
  ,input  parprod-type
  ,input  parprod-code
  ,input  'inv-on=request'
  ,output l-inv-on
  ) no-error .
    if error-status :error then do:
      undo, return error substitute( "Ошибка получения признака товара на объекте &1 &2.",
                                     error-status :get-message( 1 ), return-value ).
    end.
    if l-inv-on = yes then do:
      assign g-log = yes.
      message "Артикул :" parartic pargds-name "- товар в инвентаризации." skip (2)
              "Добавление невозможно." skip (2)
              "OK - пропустить товар, Cancel - отменить копирование"
      view-as alert-box question buttons OK-Cancel update g-log.
      if g-log = true then do:
        return "next".
      end.
      else do:
        undo, return error.
      end.
    end.
    find crd_doc-line where crd_doc-line.doc-code  = pardoc-code
                        and crd_doc-line.artic     = parartic
                        and crd_doc-line.prod-code = parprod-code
                        and crd_doc-line.prod-type = parprod-type no-error.
    if not available crd_doc-line then do:
      find first crd_trn-doc where crd_trn-doc.doc-code = pardoc-code.
      find first crd_goods where crd_goods.artic     = parartic     and
                                 crd_goods.prod-type = parprod-type and
                                 crd_goods.prod-code = parprod-code no-lock no-error.
      if error-status :error then do:
        return error substitute( "Нет товара &1 &2 &3.", crd_doc-line.artic, crd_doc-line.prod-type, crd_doc-line.prod-code ).
      end.
      if parvat-pc = ? then do:
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parobj-type
  ,input  parobj-code
  ,output v-clcdoc-host-code
  )  .
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  crd_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-clcdoc-host-code
  ,input  parobj-type
  ,input  parobj-code
  ,output v-clcdoc-vat-pc
  ) no-error .
      end.
      find first crd_sysconf where crd_sysconf.host-code = crd_trn-doc.host-code.
      if crd_sysconf.cons-vat-pc = ? then do:
        return error "У Вас не установлен НДС для консигнационного товара по фирме.".
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_st-sltpc in g#lib-trn
(
 input  recid(crd_goods)
,input  recid(crd_trn-doc)
,input  parcash-pay
,output v-clcdoc-slt-pc
)
no-error.
      if error-status :error then do:
        return error return-value.
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdoclin in g#lib-trn
(input pardoc-code
,input parartic
,input parprod-type
,input parprod-code
,input parobj-type
,input parobj-code
,input crd_trn-doc.status_
,input crd_trn-doc.ext-doc-type
,input parprt-root
,input (if parvat-pc = ? then v-clcdoc-vat-pc else parvat-pc)
,input v-clcdoc-slt-pc
,input crd_sysconf.cons-vat-pc
) no-error
.
      if error-status :error then do:
        return error return-value.
      end.
      find first crd_doc-line where crd_doc-line.doc-code  = pardoc-code  and
                                    crd_doc-line.artic     = parartic     and
                                    crd_doc-line.prod-type = parprod-type and
                                    crd_doc-line.prod-code = parprod-code exclusive-lock.
      if crd_doc-line.cli-base-rate = 0 or crd_doc-line.cli-base-rate = ? then
         crd_doc-line.cli-base-rate = 1 .
      assign
        crd_doc-line.prt-OK     = yes
        crd_doc-line.doc-qnty   = 0.
    end.
  end.
end procedure.
define temp-table tt-doc-line no-undo like lib-trn_ret-line.
define temp-table tt-gds-dtl  no-undo like ub.gds-dtl.
define temp-table tt-parts    no-undo like ub.parts.
procedure lib-trn_copy-ret :
define input parameter parparentproc  AS WIDGET-HANDLE            NO-UNDO.
define input parameter pardoc-code    like ub.trn-doc.doc-code    no-undo.
define input parameter pardoc-type    like ub.trn-doc.doc-type    no-undo.
define input parameter parstatus_     like ub.trn-doc.status_     no-undo.
define input parameter parinternal    like ub.trn-doc.internal    no-undo.
define input parameter parcli-type    like ub.trn-doc.cli-type    no-undo.
define input parameter parcli-code    like ub.trn-doc.cli-code    no-undo.
define input parameter pardiscnt-type like ub.trn-doc.discnt-type no-undo.
define input parameter partot-calc    like ub.trn-doc.tot-calc    no-undo.
define input parameter pardiscnt-pc   like ub.trn-doc.discnt-pc   no-undo.
define input parameter paragnt        like ub.trn-doc.agnt        no-undo.
define input parameter parboss        like ub.trn-doc.boss        no-undo.
define input parameter parwrkr        like ub.trn-doc.wrkr        no-undo.
define input parameter parbase-rate   like ub.trn-doc.base-rate   no-undo.
define input parameter parbase-scale  like ub.trn-doc.base-scale  no-undo.
define input parameter parexch-code   like ub.trn-doc.exch-code   no-undo.
define input parameter parvat-type    like ub.trn-doc.vat-type    no-undo.
define input parameter pardstdoc-code     like ub.trn-doc.doc-code    no-undo.
define input parameter parinp-discnt-type as   logical                no-undo.
define input parameter parinp-discnt-pc   like ub.trn-doc.discnt-pc   no-undo.
define input parameter parinp-agnt        like ub.trn-doc.agnt        no-undo.
define input parameter parinp-boss        like ub.trn-doc.boss        no-undo.
define input parameter parinp-wrkr        like ub.trn-doc.wrkr        no-undo.
define input parameter parinp-base-rate   like ub.trn-doc.base-rate   no-undo.
define input parameter parinp-base-scale  like ub.trn-doc.base-scale  no-undo.
define input parameter parcash-pay        like ub.sysconf.cash-pay    no-undo.
define input parameter parglob-base-code  like ub.sysconf.base-code   no-undo.
define input-output parameter table for tt-doc-line.
define input-output parameter table for tt-gds-dtl.
define input-output parameter table for tt-parts.
define input parameter paruse-parts       as   logical                no-undo.
define input parameter parall-qnty        as   logical                no-undo.
define input parameter parfix-price       as   logical                no-undo.
define input parameter parrsrv-fact-qnty  as   logical                no-undo.
define buffer crt_trn-doc    for ub.trn-doc.
define buffer crt_goods      for ub.goods.
define buffer crt_doc-line   for ub.doc-line.
define buffer crt_gds-dtl    for ub.gds-dtl.
define buffer bf-cas_trn-doc for ub.trn-doc.
define buffer crt_doc-pl     for ub.doc-pl.
define buffer crt_lib-trn_ret-doc       for ub.trn-doc.
define buffer crt_lib-trn_ret-parts     for ub.parts.
define variable fix-price        as   logical              no-undo.
define variable end-price        as   logical              no-undo.
define variable real-type        like ub.goods.gds-type    no-undo.
define variable legal-node       like ub.gds-prt.node-code no-undo.
define variable chg-qnty         like ub.gds-dtl.fact-qnty no-undo.
define variable mem-qnty         like ub.gds-dtl.fact-qnty no-undo.
define variable fix-qnty         like ub.gds-dtl.doc-qnty  no-undo.
define variable varchg-qnty      like ub.gds-dtl.fact-qnty no-undo.
define variable varcheck-qnty    like ub.gds-dtl.fact-qnty no-undo.
define variable g-log            as   logical              no-undo.
define variable v-is-hold        as   logical              no-undo.
define variable v-add-par        as   character            no-undo.
define variable v-reserv-pl-code as   logical              no-undo.
define variable var_is-petrol    as   logical              no-undo.
define variable var_is-pieces    as   logical              no-undo.
define variable l_place-rsrv     as   logical              no-undo.
define variable is_doc-pl_rsrv   as   logical              no-undo initial no.
define variable full-rsrv-qnty   like ub.gds-dtl.fact-qnty no-undo.
define variable v-doc-pl-rowid   as   rowid                no-undo.
define variable v-density        like ub.doc-line.fact-density no-undo.
define variable v-gds-mark       as   logical              no-undo.
define variable v-gds-attr-value as   character            no-undo.
define variable v-gds-attr-type  as   character            no-undo.
define variable vIsExemplarGoods  as   logical              no-undo.
define variable vIsVolumArticGoods as   logical              no-undo.
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
c-l:
do
on error undo c-l, return error return-value
on stop  undo c-l, return error "(copy-ret) stop"
:
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
find first crt_trn-doc where crt_trn-doc.doc-code = pardstdoc-code.
find first crt_lib-trn_ret-doc where crt_lib-trn_ret-doc.doc-code = pardoc-code.
if paruse-parts      =  yes and
   parrsrv-fact-qnty <> yes then do:
  return error "Неверно установлены параметры для процедуры copy-ret. Резервирование по партиям можно проводить только по фактическому количеству.".
end.
if paruse-parts = yes and
   parall-qnty  <> yes then do:
  return error "Неверно установлены параметры для процедуры copy-ret. Резервирование по партиям можно проводить только по всему количеству.".
end.
assign
  fix-price = parfix-price.
if fix-price <> yes then do:
  if crt_trn-doc.internal and
     crt_trn-doc.doc-type <> 'при':U                  or
     crt_trn-doc.ext-doc-type = 'ep':U and
     crt_trn-doc.status_ <> 'запрос':U      then do:
    assign
     fix-price = no.
  end.
  else do:
    fix-price = no.
    message "Зафиксировать исходные цены ?" skip (2)
            "Цены в добавляемых строках будут :" skip
            "YES - равны ценам документа - источника;" skip
            "NO - подставлены текущие цены продажи."
            view-as alert-box question buttons YES-NO update fix-price.
    assign
      g-log = yes.
    if fix-price and can-do
      ('рас':U, crt_trn-doc.doc-type)
    then do:
define variable vss-include-info86 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_expense_price':U
    ,input  'object':U
    ,input  crt_trn-doc.host-code
    ,input  crt_trn-doc.obj-type
    ,input  crt_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
    end.
    if fix-price
    and can-do ('возврат':U, crt_trn-doc.doc-type)
    then do:
define variable vss-include-info87 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_return_price':U
    ,input  'object':U
    ,input  crt_trn-doc.host-code
    ,input  crt_trn-doc.obj-type
    ,input  crt_trn-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output g-log
    )  .
end.
    end.
    if not g-log then do:
      return error "У Вас нет прав для назначения произвольных цен в документе, поэтому копирование цен из выбранного источника невозможно.".
    end.
  end.
end.
assign
  end-price = no.
if pardoc-type          = 'рас':U             and
   parstatus_           = 'факт':U                and
   parinternal          = no                     and
   crt_trn-doc.doc-type = 'возврат':U              and
   crt_trn-doc.internal = no                     and
   parcli-type          = crt_trn-doc.cli-type   and
   parcli-code          = crt_trn-doc.cli-code   and
   can-do ('процент,карта,группа,сумма,строка,прайс-лист':U, pardiscnt-type)       then do:
   assign
     crt_trn-doc.out-code = pardoc-code.
   if fix-price then do:
     assign
       end-price = yes.
   end.
end.
if parinp-discnt-type = yes and
   parinp-discnt-pc   = 0   and
   can-do ('процент,карта,группа,сумма,строка,прайс-лист':U, pardiscnt-type)
   then do:
  assign
    crt_trn-doc.tot-calc    = partot-calc
    crt_trn-doc.discnt-pc   = pardiscnt-pc
    crt_trn-doc.discnt-type = pardiscnt-type.
end.
if parinp-agnt = ? then do:
  assign
    crt_trn-doc.agnt = paragnt.
end.
if parinp-boss = ? then do:
  assign
    crt_trn-doc.boss = parboss.
end.
if parinp-wrkr = ? then do:
  assign
    crt_trn-doc.wrkr = parwrkr.
end.
if parinp-base-rate  = ? then do:
  assign
    crt_trn-doc.base-rate  = parbase-rate.
end.
if parinp-base-scale = ? then do:
  assign
    crt_trn-doc.base-scale = parbase-scale.
end.
find first tt-doc-line where tt-doc-line.doc-code = pardoc-code no-lock no-error.
if available tt-doc-line then do:
  find crt_goods where crt_goods.artic     = tt-doc-line.artic
                   and crt_goods.prod-type = tt-doc-line.prod-type
                   and crt_goods.prod-code = tt-doc-line.prod-code no-lock.
  if crt_goods.gds-type = 'у':U and
     (crt_trn-doc.doc-type <> 'рас':U or crt_trn-doc.internal) then do:
    return error "В данный документ нельзя копировать услуги.".
  end.
  assign
    real-type = crt_goods.gds-type.
  find first crt_doc-line where crt_doc-line.doc-code = crt_trn-doc.doc-code no-lock no-error.
  if available crt_doc-line then do:
    find crt_goods where crt_goods.artic     = crt_doc-line.artic
                     and crt_goods.prod-type = crt_doc-line.prod-type
                     and crt_goods.prod-code = crt_doc-line.prod-code no-lock.
    if crt_goods.gds-type <> real-type then do:
      return error "Услуги и товары не могут быть добавлены в один и тот же документ.".
    end.
  end.
  else do:
    assign
      crt_trn-doc.office = (if real-type = 'у':U then yes else no).
  end.
end.
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hold-doc in g#library
  (input  pardstdoc-code
  ,output v-is-hold
  )  .
r-l:
for each tt-doc-line where tt-doc-line.doc-code = pardoc-code by tt-doc-line.line-num on error undo, return error return-value :
  find crt_goods where crt_goods.artic     = tt-doc-line.artic
                   and crt_goods.prod-type = tt-doc-line.prod-type
                   and crt_goods.prod-code = tt-doc-line.prod-code no-lock.
  if crt_trn-doc.ext-doc-type = 'ep':U then
  do:
      run isExemplarGoods in this-procedure
          (tt-doc-line.obj-type, tt-doc-line.obj-code, crt_goods.gds-code, output vIsExemplarGoods).
      run isVolumArticGoods in this-procedure
          (tt-doc-line.obj-type, tt-doc-line.obj-code, crt_goods.gds-code, output vIsVolumArticGoods).
      if vIsExemplarGoods or vIsVolumArticGoods then
      do:
        message substitute("Товар &1 &2 &3 &4 подлежит обязательной маркировке. Для возврата используйте документ Расход внешний.~nТовар в документ добавлен не будет."
               , crt_goods.artic
               , crt_goods.prod-type
               , crt_goods.prod-code
               , crt_goods.gds-name
               )
        view-as alert-box .
        varcheck-qnty = varcheck-qnty + tt-doc-line.fact-qnty.
        next r-l.
      end.
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdoclno in g#lib-trn
( input crt_trn-doc.doc-code
 ,input crt_trn-doc.obj-type
 ,input crt_trn-doc.obj-code
 ,input crt_goods.artic
 ,input crt_goods.prod-type
 ,input crt_goods.prod-code
 ,input crt_goods.gds-name
 ,input crt_goods.prt-root
 ,input ?
 ,input ?
 ,input parcash-pay
  ) no-error .
  if error-status :error then do:
    undo c-l, return error return-value.
  end.
  if return-value = "next" then do:
    next r-l.
  end.
  find first crt_doc-line where crt_doc-line.doc-code  = crt_trn-doc.doc-code and
                                crt_doc-line.artic     = crt_goods.artic      and
                                crt_doc-line.prod-type = crt_goods.prod-type  and
                                crt_doc-line.prod-code = crt_goods.prod-code .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input crt_goods.artic
  ,  input crt_goods.prod-type
  ,  input crt_goods.prod-code
  , output var_is-petrol
  , output var_is-pieces
  ) no-error.
  if error-status :error then do:
    return error substitute( 'Ошибка при определении атрибута товара "топливо".&1'
                          + 'Артикул &2 &3 &4&1&7&1&8'
                          , chr(10)
                          , crt_goods.artic
                          , crt_goods.prod-type
                          , crt_goods.prod-code
                          , return-value
                          , error-status :get-message(1)
                          ).
  end.
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  crt_trn-doc.obj-type
  ,input  crt_trn-doc.obj-code
  ,input  crt_goods.artic
  ,input  crt_goods.prod-type
  ,input  crt_goods.prod-code
  ,input  'place-rsrv=request':U
  ,output l_place-rsrv
  ) no-error .
  if error-status :error
  then do:
    undo c-l, return error substitute ("Ошибка при запросе атрибута place-rsrv товара на объекте. &1 &2", return-value, error-status :get-message (1)).
  end.
  if l_place-rsrv = yes then do:
      if  crt_lib-trn_ret-doc.obj-type = crt_trn-doc.obj-type
      and crt_lib-trn_ret-doc.obj-code = crt_trn-doc.obj-code
      then do:
        assign
          is_doc-pl_rsrv = yes
        .
      end.
      else do:
        assign
          is_doc-pl_rsrv = no
        .
      end.
  end.
  if not (crt_lib-trn_ret-doc.status_ = "temp" and crt_trn-doc.flag_) then do:
    if l_place-rsrv = yes
      and var_is-petrol = true
      and var_is-pieces = false
    then do:
      assign
        crt_doc-line.doc-density  = (if parrsrv-fact-qnty then tt-doc-line.fact-density else tt-doc-line.doc-density)
        crt_doc-line.fact-density = crt_doc-line.doc-density
      .
      if valid-density( crt_doc-line.doc-density, (crt_goods.unit-base = crt_goods.unit-cli) ) <> true then do:
        undo, return error substitute( "Плотность в документе источнике имеет некорректное значение &1.", v-density ) .
      end.
      assign
        crt_doc-line.unit-cli      = crt_goods.unit-cli
        crt_doc-line.cli-base-rate = 1 / crt_doc-line.doc-density
      .
    end.
  end.
  RUN gds-attr-value (
                          INPUT crt_goods.gds-code,
                          INPUT 'mark-type':U,
                          OUTPUT v-gds-attr-value,
                          OUTPUT v-gds-attr-type
                          ).
  if v-gds-attr-value > ""
  and ObjSrv:Env:ParametrsOfSection:GetSectionEDO(crt_trn-doc.obj-type, crt_trn-doc.obj-code):GetIsMarkingForType(v-gds-attr-value)
  then
    v-gds-mark = true .
  else
    v-gds-mark = false .
  _tt-gds-dtl:
  for each tt-gds-dtl where tt-gds-dtl.prod-type = tt-doc-line.prod-type and
                            tt-gds-dtl.prod-code = tt-doc-line.prod-code and
                            tt-gds-dtl.artic     = tt-doc-line.artic     and
                            tt-gds-dtl.doc-code  = tt-doc-line.doc-code
                            break by tt-gds-dtl.artic
                                  by tt-gds-dtl.prod-type
                                  by tt-gds-dtl.prod-code
                            :
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_lgl-node in g#lib-trn
  ( input  tt-gds-dtl.artic
   ,input  tt-gds-dtl.prod-type
   ,input  tt-gds-dtl.prod-code
   ,input  tt-gds-dtl.prt-code
   ,input  tt-doc-line.obj-type
   ,input  tt-doc-line.obj-code
   ,output legal-node
  ) no-error .
    if error-status :error then do:
       undo c-l, return error substitute ("&1 &2", return-value, error-status :get-message (1)).
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crgdsdtl in g#lib-trn
  ( input crt_trn-doc.obj-code
   ,input crt_trn-doc.obj-type
   ,input crt_trn-doc.doc-code
   ,input crt_goods.artic
   ,input crt_goods.prod-code
   ,input crt_goods.prod-type
   ,input legal-node
   ,input yes
  ) no-error .
     if error-status :error then do:
        return error substitute ("Ошибка при создании признака &1.", return-value) .
     end.
     find first crt_gds-dtl where crt_gds-dtl.doc-code  = crt_trn-doc.doc-code and
                                  crt_gds-dtl.artic     = crt_goods.artic      and
                                  crt_gds-dtl.prod-code = crt_goods.prod-code  and
                                  crt_gds-dtl.prod-type = crt_goods.prod-type  and
                                  crt_gds-dtl.prt-code  = legal-node.
        if is_doc-pl_rsrv = yes then do:
          if first-of(tt-gds-dtl.artic) then do:
            assign
              full-rsrv-qnty = 0
            .
            for each crt_lib-trn_ret-parts no-lock
              where crt_lib-trn_ret-parts.out-code  = tt-gds-dtl.doc-code
                and crt_lib-trn_ret-parts.obj-type  = tt-gds-dtl.obj-type
                and crt_lib-trn_ret-parts.obj-code  = tt-gds-dtl.obj-code
                and crt_lib-trn_ret-parts.artic     = tt-gds-dtl.artic
                and crt_lib-trn_ret-parts.prod-type = tt-gds-dtl.prod-type
                and crt_lib-trn_ret-parts.prod-code = tt-gds-dtl.prod-code
            on error undo, return error return-value
            :
              assign
                chg-qnty = (if parrsrv-fact-qnty then crt_lib-trn_ret-parts.fact-qnty else crt_lib-trn_ret-parts.qnty)
                fix-qnty = chg-qnty
              .
              find first crt_doc-pl
                where crt_doc-pl.obj-type = crt_trn-doc.obj-type
                  and crt_doc-pl.obj-code = crt_trn-doc.obj-code
                  and crt_doc-pl.pl-code  = crt_lib-trn_ret-parts.pl-code
                  and crt_doc-pl.out-code = crt_trn-doc.doc-code
                  and crt_doc-pl.gds-code = crt_goods.gds-code
                no-error .
              if not available crt_doc-pl then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdocpl in g#lib-trn
(input  crt_trn-doc.doc-code
,input  crt_goods.gds-code
,input  crt_lib-trn_ret-parts.pl-code
,input  crt_trn-doc.obj-type
,input  crt_trn-doc.obj-code
,output v-doc-pl-rowid
) no-error
.
                find first crt_doc-pl
                  where rowid( crt_doc-pl ) = v-doc-pl-rowid
                  .
              end.
              assign
                crt_doc-pl.doc-qnty      = crt_doc-pl.doc-qnty + chg-qnty
                crt_doc-pl.fact-qnty     = crt_doc-pl.doc-qnty
                crt_doc-pl.cli-qnty      = crt_doc-pl.doc-qnty / crt_doc-line.cli-base-rate
                crt_doc-pl.cli-doc-qnty  = crt_doc-pl.doc-qnty * crt_doc-line.doc-density
                crt_doc-pl.cli-fact-qnty = crt_doc-pl.cli-doc-qnty
              .
              assign
                v-add-par = (
                                        if tt-doc-line.cst-code <> ? and tt-doc-line.cst-code <> ""
                                        then "," + 'cst-code':U + "=":u + str-encode( tt-doc-line.cst-code, "", ",=":u )
                                        else ""
                                      )
                                    + "," + 'cli-qnty':U      + "=":U + string( chg-qnty / crt_doc-line.cli-base-rate )
                                    + "," + 'cre-part-code':U + "=":U + string( crt_lib-trn_ret-parts.pl-code )
                                    + "," + 'plcode':U       + "=":U + string( crt_lib-trn_ret-parts.pl-code )
                .
              if chg-qnty <> fix-qnty then do:
                undo, return error substitute( "Не удалось скопировать полностью товар: &1 &2 &3 в накладную."
                                               ,crt_gds-dtl.artic
                                               ,crt_gds-dtl.prod-type
                                               ,crt_gds-dtl.prod-code
                                             ).
              end.
              assign
                full-rsrv-qnty = full-rsrv-qnty + chg-qnty
              .
            end.
          end.
        end.
    assign
      crt_gds-dtl.ov           = fix-price
      crt_gds-dtl.price-base   = tt-gds-dtl.price-base
      crt_gds-dtl.price-rubl   = tt-gds-dtl.price-rubl.
    if can-do ('процент,карта,группа,сумма,строка,прайс-лист':U, pardiscnt-type) then do:
      assign
        crt_gds-dtl.discnt-base  = tt-gds-dtl.discnt-base
        crt_gds-dtl.discnt-rubl  = tt-gds-dtl.discnt-rubl
        crt_gds-dtl.discnt-pc    = tt-gds-dtl.discnt-pc
        crt_gds-dtl.discnt-type  = tt-gds-dtl.discnt-type.
    end.
    if crt_trn-doc.ext-doc-type = 'ep':U  and
       pardoc-type = 'при':U                           and
       parinternal = no                                  and
       crt_trn-doc.cli-type = parcli-type                and
       crt_trn-doc.cli-code = parcli-code                then do:
      if parexch-code = 0         and
         parvat-type = 'в т. ч.':U then do:
         assign
           crt_gds-dtl.price-rubl = tt-doc-line.price-rubl - tt-doc-line.transport-rubl - tt-doc-line.other-rubl
           crt_gds-dtl.price-base = crt_gds-dtl.price-rubl / crt_trn-doc.base-rate * crt_trn-doc.base-scale
           crt_gds-dtl.ov         = yes.
      end.
      if parexch-code = parglob-base-code and
         parvat-type = 'в т. ч.':U then do:
         assign
           crt_gds-dtl.price-base = tt-doc-line.price-base - tt-doc-line.transport-base - tt-doc-line.other-base
           crt_gds-dtl.price-rubl = crt_gds-dtl.price-base * crt_trn-doc.base-rate / crt_trn-doc.base-scale
           crt_gds-dtl.ov         = yes
         .
      end.
    end.
    if end-price then do:
      assign
        crt_gds-dtl.ov             = yes
        crt_gds-dtl.price-base     = tt-gds-dtl.price-base
        crt_gds-dtl.discnt-base    = tt-gds-dtl.discnt-base
        crt_gds-dtl.price-rubl     = tt-gds-dtl.price-rubl
        crt_gds-dtl.discnt-rubl    = tt-gds-dtl.discnt-rubl
        crt_gds-dtl.discnt-pc      = tt-gds-dtl.discnt-pc
        crt_gds-dtl.discnt-type    = (if crt_trn-doc.discnt-type = 'процент':U then yes else no).
    end.
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_set-pr in g#lib-trn3
  ( input recid(crt_gds-dtl)
  , input no
  , input ?
  ) no-error.
    if error-status :error then do:
      undo c-l, return error return-value.
    end.
    if (crt_gds-dtl.price-rubl = ? or crt_gds-dtl.price-base = ?) and
       crt_gds-dtl.ov then do:
      undo c-l, return error substitute ("При добавлении с фиксацией взятых из документа - источника цен требуется, чтобы ни одна из цен источника не была '?'. Добавляйте с текущими ценами продажи или выберите другой источник. Товар &1 &2 &3", crt_gds-dtl.artic, crt_gds-dtl.prod-type, crt_gds-dtl.prod-code).
    end.
    if paruse-parts = true
    then do:
      if first-of (tt-gds-dtl.prod-code) then do:
        _tt-parts:
        for each tt-parts
          where tt-parts.out-code  = pardoc-code
            and tt-parts.artic     = tt-gds-dtl.artic
            and tt-parts.prod-type = tt-gds-dtl.prod-type
            and tt-parts.prod-code = tt-gds-dtl.prod-code
        on error undo, return error return-value
        :
          if tt-parts.fact-qnty = 0 then NEXT _tt-parts.
          assign
            chg-qnty = tt-parts.fact-qnty
            mem-qnty = chg-qnty
          .
          if v-is-hold = true then do:
            run trg/rsrv-dtl.p
              ( input parparentproc
               ,input 'reserv':U
                      + "," + 'hold-date':U + "=" + str-encode( string (tt-parts.hold-date), "", ",=":u)
                      + "," + 'hold-code-parent':U + "=" + str-encode(tt-parts.in-code, "", ",=":u)
                      + "," + 'part-code-parent':U + "=" + str-encode(tt-parts.part-code, "", ",=":u)
                      + "," + 'cst-code':U + "=" + str-encode(tt-parts.cst-code, "", ",=":u)
               ,buffer crt_gds-dtl
               ,input-output chg-qnty
               ,input-output crt_doc-line.price-base
               ,input-output crt_doc-line.price-rubl
               ,input -1
               ,input if v-gds-mark then ("copy-ret" + chr(4) + pardoc-code) else ""
              ) no-error.
            if error-status :error then do:
              undo c-l, return error return-value.
            end.
          end.
          else do:
            assign
              v-add-par = ( if tt-parts.pl-code <> 0 and tt-parts.pl-code <> ?
                            then ",":U + 'plcode':U + "=":U + string(tt-parts.pl-code)
                            else "":U
                           )
            .
            run trg/rsrv-dtl.p
              ( input parparentproc
               ,input 'reserv':U
                      + "," + 'rsrv-single-part':U
                      + "," + 'rsrv-in-code':U + "=" + str-encode(tt-parts.in-code, "", ",=":u)
                      + "," + 'rsrv-part-code':U + "=" + str-encode(tt-parts.part-code, "", ",=":u)
                      + "," + 'cst-code':U + "=" + str-encode(tt-parts.cst-code, "", ",=":u)
                      + v-add-par
               ,buffer crt_gds-dtl
               ,input-output chg-qnty
               ,input-output crt_doc-line.price-base
               ,input-output crt_doc-line.price-rubl
               ,input -1
               ,input if v-gds-mark then ("copy-ret" + chr(4) + pardoc-code) else ""
              ) no-error.
            if error-status :error then do:
              undo c-l, return error return-value.
            end.
          end.
          if chg-qnty <> mem-qnty then do:
            undo c-l, return error substitute("Не удалось зарезервировать все количество по товару &1 &2 &3 партия &4 &5.", crt_doc-line.artic, crt_doc-line.prod-type, crt_doc-line.prod-code, tt-parts.in-code, tt-parts.part-code).
          end.
          assign
            crt_doc-line.doc-qnty  = crt_doc-line.doc-qnty + chg-qnty
            crt_doc-line.fact-qnty = crt_doc-line.doc-qnty
            crt_doc-line.cli-qnty  = crt_doc-line.doc-qnty / crt_doc-line.cli-base-rate
            crt_gds-dtl.doc-qnty   = crt_gds-dtl.doc-qnty  + chg-qnty
            crt_gds-dtl.fact-qnty  = crt_gds-dtl.doc-qnty
            varchg-qnty            = varchg-qnty           + chg-qnty
            varcheck-qnty          = varcheck-qnty         + chg-qnty
            tt-parts.fact-qnty     = 0
            tt-parts.qnty          = tt-parts.qnty         + chg-qnty
          .
        end.
        assign
          tt-gds-dtl.fact-qnty     = 0
          tt-gds-dtl.doc-qnty      = crt_gds-dtl.doc-qnty
        .
      end.
    end.
    else do:
      if parrsrv-fact-qnty = yes then do:
        if tt-gds-dtl.fact-qnty = 0 then NEXT _tt-gds-dtl.
        assign
          chg-qnty = tt-gds-dtl.fact-qnty
          mem-qnty = chg-qnty
        .
      end.
      else do:
        if tt-gds-dtl.doc-qnty = 0 then NEXT _tt-gds-dtl.
        assign
          chg-qnty = tt-gds-dtl.doc-qnty
          mem-qnty = chg-qnty
        .
      end.
      find first bf-cas_trn-doc no-lock
        where bf-cas_trn-doc.doc-code = crt_trn-doc.out-code
        no-error.
      if available bf-cas_trn-doc
        and bf-cas_trn-doc.ext-doc-type = 'es':U
      then do:
        assign
          v-add-par = ',':U + 'negative-check':U + "=2":U
        .
      end.
      else do:
        assign
          v-add-par = "":U
        .
      end.
      run trg/rsrv-dtl.p
        ( input parparentproc
         ,input 'reserv':U + v-add-par
         ,buffer crt_gds-dtl
         ,input-output chg-qnty
         ,input-output crt_doc-line.price-base
         ,input-output crt_doc-line.price-rubl
         ,input -1
         ,input if v-gds-mark then ("copy-ret" + chr(4) + pardoc-code) else ""
        ) no-error.
      if error-status :error then do:
        undo c-l, return error return-value.
      end.
      if parall-qnty
        and chg-qnty <> mem-qnty
      then do:
         undo c-l, return error substitute("Не удалось зарезервировать все количество по товару &1 &2 &3.", crt_doc-line.artic, crt_doc-line.prod-type, crt_doc-line.prod-code).
      end.
      assign
        crt_doc-line.doc-qnty  = crt_doc-line.doc-qnty + chg-qnty
        crt_gds-dtl.doc-qnty   = crt_gds-dtl.doc-qnty  + chg-qnty
        crt_gds-dtl.fact-qnty  = crt_gds-dtl.doc-qnty
        crt_doc-line.fact-qnty = crt_doc-line.doc-qnty
        crt_doc-line.cli-qnty  = crt_doc-line.doc-qnty / crt_doc-line.cli-base-rate
      .
      assign
        varchg-qnty   = varchg-qnty   + chg-qnty
        varcheck-qnty = varcheck-qnty + (if parrsrv-fact-qnty = yes then tt-gds-dtl.fact-qnty else tt-gds-dtl.doc-qnty)
        tt-gds-dtl.fact-qnty     = (if parrsrv-fact-qnty
                                    then (tt-gds-dtl.fact-qnty - chg-qnty)
                                    else crt_gds-dtl.fact-qnty)
        tt-gds-dtl.doc-qnty      = (if parrsrv-fact-qnty
                                    then crt_gds-dtl.doc-qnty
                                    else (tt-gds-dtl.doc-qnty - chg-qnty))
        tt-doc-line.fact-qnty     = (if parrsrv-fact-qnty
                                      then (tt-doc-line.fact-qnty - chg-qnty)
                                      else crt_doc-line.fact-qnty)
        tt-doc-line.doc-qnty      = (if parrsrv-fact-qnty
                                      then crt_doc-line.doc-qnty
                                      else (tt-doc-line.doc-qnty - chg-qnty))
      .
    end.
    if crt_gds-dtl.doc-qnty = 0 then do:
      delete crt_gds-dtl.
    end.
  end.
  if crt_doc-line.doc-qnty = 0 then do:
    delete crt_doc-line.
  end.
end.
if varcheck-qnty <> varchg-qnty and
   not (available bf-cas_trn-doc and bf-cas_trn-doc.ext-doc-type = 'es':U) then do:
  message
  substitute(("Внимание !!!&1&1" +
             "НЕ ВСЕ количество из документа &2 - источника УДАЛОСЬ добавить в заполняемый документ &3!&1&1" +
             "Общее количество в документе - источнике : &4&1"  +
             "Удалось добавить в документ : &5")
              , chr(10)
              , pardoc-code
              , pardstdoc-code
              , varcheck-qnty
              , varchg-qnty)
 view-as alert-box .
end.
end.
end procedure.
