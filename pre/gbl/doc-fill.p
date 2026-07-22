block-level on error undo, throw.
define input parameter pis-trn-doc as integer no-undo .
define input parameter rs-list-method as character no-undo .
define input parameter par-run-name as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
define input parameter p-curr-host-code like ub.sysconf.host-code no-undo .
define input parameter p-table-name as character no-undo .
define input parameter p-filter-var as character no-undo .
define output parameter lns-cnt as integer no-undo .
define output parameter line-rec as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: doc-fill.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/doc-fill.p $":U .
define variable vss-description as character no-undo init "Фильтр в списке документов".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared  temp-table doc-list no-undo
field doc-date   like ub.trn-doc.doc-date
field doc-code   like ub.trn-doc.doc-code
field obj-type   like ub.trn-doc.obj-type
field obj-code   like ub.trn-doc.obj-code
field fact-num   like ub.trn-doc.fact-num
field fact-date  like ub.trn-doc.fact-date
field shift-date like ub.trn-doc.shift-date
field shift-num  like ub.trn-doc.shift-num
field shift-name like ub.trn-doc.shift-name
field fact-order as decimal
field is-trn-doc as logical
field is-del as logical
field doc-type   like ub.trn-doc.doc-type
field ext-doc-type   like ub.trn-doc.ext-doc-type
field sel-order  as integer
field znak       as integer
field to-del     as logical
field is-archive-exist as logical
index xpk is primary unique doc-code doc-type
index xfact fact-num
index xfact-date fact-date
index sel-order sel-order
index znak-order znak sel-order
index isdel is-del
.
define buffer inkas_trn-doc for ub.trn-doc .
define buffer c-inkas_trn-doc for ub.c-trn-doc .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   shared   temp-table doc-list-hist no-undo
field list-table as character
field id as integer
field line as integer
field hist-mode as character
field des as character
field num-recs as integer
field option_ as character
field item_ as character
field status_ as character
field num-add as integer
field num-ignored as integer
field done as logical
field err_ as logical
field err-mes as character
index pi is primary
id
line
index isdone
done
.
define variable dsp-rs as character format "x(50)" no-undo.
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
define query trn-doc-fill for ub.trn-doc.
define query price-doc-fill for ub.price-doc.
define query inkas-fill for ub.inkas.
define query fbr-doc-fill for ub.fbr-doc.
define frame abc
dsp-rs no-label
with view-as dialog-box SIDE-LABELS NO-UNDERLINE THREE-D SCROLLABLE
TITLE par-run-name.
view frame abc.
display dsp-rs
with frame abc.
case p-table-name:
  when 'trn-doc':U then do:
    v-prepare-string = substitute('for each trn-doc no-lock where trn-doc.host-code = &1 ' +
                                   p-filter-var
                                  , p-curr-host-code
                                  ).
    glog = query trn-doc-fill:handle:query-prepare(v-prepare-string) no-error.
    if not glog
    or error-status:error then do:
      message
      substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                , chr(10)
                , error-status:get-message(1)
                , p-filter-var)
      view-as alert-box error .
      undo, return error .
    end.
    glog = query trn-doc-fill:handle:query-open() no-error.
    if not glog
    or error-status:error then do:
      message
      substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                , chr(10)
                , error-status:get-message(1)
                , p-filter-var)
      view-as alert-box error .
      undo, return error .
    end.
    REPEAT WITH FRAME abc:
       query trn-doc-fill:handle:GET-NEXT().
       IF query trn-doc-fill:handle:QUERY-OFF-END THEN LEAVE.
       process events.
       run ex-doc in this-procedure ( input 1, input rs-list-method, input rs-status, input line-mode) .
    end.
    glog = query trn-doc-fill:handle:query-close() no-error.
  end.
  when 'price-doc':U then do:
    v-prepare-string = substitute('for each price-doc no-lock where price-doc.host-code = &1 ' +
                                   p-filter-var
                                  , p-curr-host-code
                                  ).
    glog = query price-doc-fill:handle:query-prepare(v-prepare-string) no-error.
    if not glog
    or error-status:error then do:
      message
      substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                , chr(10)
                , error-status:get-message(1)
                , p-filter-var)
      view-as alert-box error .
      undo, return error .
    end.
    glog = query price-doc-fill:handle:query-open() no-error.
    if not glog
    or error-status:error then do:
      message
      substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                , chr(10)
                , error-status:get-message(1)
                , p-filter-var)
      view-as alert-box error .
      undo, return error .
    end.
    REPEAT WITH FRAME abc:
      query price-doc-fill:handle:GET-NEXT().
      IF query price-doc-fill:handle:QUERY-OFF-END THEN LEAVE.
      process events.
      run ex-doc in this-procedure ( input 0, input rs-list-method, input rs-status, input line-mode) .
    end.
    glog = query price-doc-fill:handle:query-close() no-error.
  end.
  when 'inkas':U then do:
    v-prepare-string = substitute('for each inkas no-lock where inkas.host-code = &1 ' +
                                   p-filter-var
                                  , p-curr-host-code
                                  ).
    glog = query inkas-fill:handle:query-prepare(v-prepare-string) no-error.
    if not glog
    or error-status:error then do:
      message
      substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                , chr(10)
                , error-status:get-message(1)
                , p-filter-var)
      view-as alert-box error .
      undo, return error .
    end.
    glog = query inkas-fill:handle:query-open() no-error.
    if not glog
    or error-status:error then do:
      message
      substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                , chr(10)
                , error-status:get-message(1)
                , p-filter-var)
      view-as alert-box error .
      undo, return error .
    end.
    REPEAT WITH FRAME abc:
      query inkas-fill:handle:GET-NEXT().
      IF query inkas-fill:handle:QUERY-OFF-END THEN LEAVE.
      process events.
      run ex-doc in this-procedure ( input 2, input rs-list-method, input rs-status, input line-mode) .
    end.
    glog = query inkas-fill:handle:query-close() no-error.
  end.
  when 'fbr-doc':U then do:
    v-prepare-string = substitute('for each fbr-doc no-lock where fbr-doc.host-code = &1 ' +
                                   p-filter-var
                                  , p-curr-host-code
                                  ).
    glog = query fbr-doc-fill:handle:query-prepare(v-prepare-string) no-error.
    if not glog
    or error-status:error then do:
      message
      substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                , chr(10)
                , error-status:get-message(1)
                , p-filter-var)
      view-as alert-box error .
      undo, return error .
    end.
    glog = query fbr-doc-fill:handle:query-open() no-error.
    if not glog
    or error-status:error then do:
      message
      substitute("Ошибка при заполнении по фильтру&1:&2&1Выражение для Фильтра:&1&3"
                , chr(10)
                , error-status:get-message(1)
                , p-filter-var)
      view-as alert-box error .
      undo, return error .
    end.
    REPEAT WITH FRAME abc:
      query fbr-doc-fill:handle:GET-NEXT().
      IF query fbr-doc-fill:handle:QUERY-OFF-END THEN LEAVE.
      process events.
      run ex-doc in this-procedure ( input 3, input rs-list-method, input rs-status, input line-mode) .
    end.
    glog = query fbr-doc-fill:handle:query-close() no-error.
  end.
end case.
hide frame abc.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE ex-doc :
DEFINE INPUT PARAMETER loc-is-trn-doc as integer no-undo.
define input parameter rs-list-method as character no-undo .
define input parameter rs-status as character no-undo .
define input parameter line-mode as character no-undo .
  if line-mode = 'удаление':U or line-mode = 'ОСТАВИТЬ':U then do:
    CASE loc-is-trn-doc:
      when 1 then do:
        if ub.trn-doc.host-code <> p-curr-host-code then return.
        find first doc-list where
                  doc-list.doc-code = ub.trn-doc.doc-code
             and  doc-list.doc-type = ub.trn-doc.doc-type
                  no-error.
      end.
      when 101 then do:
        if ub.c-trn-doc.host-code <> p-curr-host-code then return.
        find first doc-list where
                  doc-list.doc-code = ub.c-trn-doc.doc-code
             and  doc-list.doc-type = "-" + ub.c-trn-doc.doc-type
                  no-error.
      end.
      when 0 then do:
        if ub.price-doc.host-code <> p-curr-host-code then return.
        find first doc-list where
                  doc-list.doc-code = ub.price-doc.doc-num
             and  doc-list.doc-type = 'переоценка':U
                  no-error.
      end.
      when 2 then do:
        if ub.inkas.host-code <> p-curr-host-code then return.
        find first doc-list where
                  doc-list.doc-code = ub.inkas.inkas-code
             and  doc-list.doc-type = 'касс':U
                  no-error.
      end.
      when 102 then do:
        if ub.c-inkas.host-code <> p-curr-host-code then return.
        find first doc-list where
                  doc-list.doc-code = ub.c-inkas.inkas-code
             and  doc-list.doc-type = "-" + 'касс':U
                  no-error.
      end.
      when 3 then do:
        if ub.fbr-doc.host-code <> p-curr-host-code then return.
        find first doc-list where
                  doc-list.doc-code = ub.fbr-doc.doc-code
             and  doc-list.doc-type = 'производство':U
                  no-error.
      end.
      when 4 then do:
        message
        ub.ord-doc.host-code <> p-curr-host-code
        view-as alert-box .
        if ub.ord-doc.host-code <> p-curr-host-code then return.
        find first doc-list where
                  doc-list.doc-code = ub.ord-doc.doc-code
             and  doc-list.doc-type = ub.ord-doc.doc-type
                  no-error.
      end.
    end CASE.
    if available doc-list then do:
      if line-mode = 'удаление':U then do:
         lns-cnt = lns-cnt + 1.
         delete doc-list.
      end.
      if line-mode = 'ОСТАВИТЬ':U then do:
        if doc-list.to-del = ? then .
        else do:
          lns-cnt = lns-cnt + 1.
          doc-list.to-del = ?.
        end.
      end.
    end.
  end.
  else
    if line-mode = 'ДОБАВЛЕНИЕ':U
    then do:
      define variable v-sel-order as integer   no-undo .
      define buffer buf_sel_order_doc-list for doc-list .
      find last buf_sel_order_doc-list
        use-index sel-order
        no-error .
      if available buf_sel_order_doc-list
      then do:
        assign
          v-sel-order = buf_sel_order_doc-list.sel-order + 1
        .
      end.
      else do:
        assign
          v-sel-order = 1
        .
      end.
      CASE loc-is-trn-doc:
        when 1 then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = ub.trn-doc.doc-code
    and doc-list.doc-type = ub.trn-doc.doc-type
  no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  if ub.trn-doc.host-code <> p-curr-host-code then return.
  create doc-list .
  assign
  doc-list.doc-code   = ub.trn-doc.doc-code
  doc-list.obj-type   = ub.trn-doc.obj-type
  doc-list.obj-code   = ub.trn-doc.obj-code
  doc-list.fact-num   = ub.trn-doc.fact-num
  doc-list.doc-date   = ub.trn-doc.doc-date
  doc-list.fact-date  = ub.trn-doc.fact-date
  doc-list.shift-date = ub.trn-doc.shift-date
  doc-list.shift-num  = ub.trn-doc.shift-num
  doc-list.fact-order = ub.trn-doc.fact-order
  doc-list.is-trn-doc = yes
  doc-list.is-del     = no
  doc-list.doc-type   = ub.trn-doc.doc-type
  doc-list.ext-doc-type   = ub.trn-doc.ext-doc-type
  doc-list.sel-order  = v-sel-order
  doc-list.znak       = if can-do ('рас,спи':U, doc-list.doc-type) then -1 else 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        end.
        when 101 then do:
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = ub.c-trn-doc.doc-code
    and doc-list.doc-type = "-" + ub.c-trn-doc.doc-type
  no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  if ub.c-trn-doc.host-code <> p-curr-host-code then return.
  create doc-list .
  assign
  doc-list.doc-code   = ub.c-trn-doc.doc-code
  doc-list.obj-type   = ub.c-trn-doc.obj-type
  doc-list.obj-code   = ub.c-trn-doc.obj-code
  doc-list.fact-num   = ub.c-trn-doc.fact-num
  doc-list.doc-date   = ub.c-trn-doc.doc-date
  doc-list.fact-date  = ub.c-trn-doc.fact-date
  doc-list.shift-date = ub.c-trn-doc.shift-date
  doc-list.shift-num  = ub.c-trn-doc.shift-num
  doc-list.fact-order = ub.c-trn-doc.fact-order
  doc-list.is-trn-doc = yes
  doc-list.doc-type   = "-" + ub.c-trn-doc.doc-type
  doc-list.ext-doc-type   = ub.c-trn-doc.ext-doc-type
  doc-list.is-del     = yes
  doc-list.sel-order  = v-sel-order
  doc-list.znak       = if can-do ('рас,спи':U, doc-list.doc-type) then -1 else 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        end.
        when 0 then do:
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = ub.price-doc.doc-num
    and doc-list.doc-type = 'переоценка':U
  no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  if ub.price-doc.host-code <> p-curr-host-code then return.
  create doc-list .
  assign
  doc-list.doc-code   = ub.price-doc.doc-num
  doc-list.obj-type   = ub.price-doc.obj-type
  doc-list.obj-code   = ub.price-doc.obj-code
  doc-list.fact-num   = ub.price-doc.fact-num
  doc-list.fact-date  = ub.price-doc.fact-date
  doc-list.shift-date = ub.price-doc.shift-date
  doc-list.shift-num  = ub.price-doc.shift-num
  doc-list.fact-order = ub.price-doc.fact-order
  doc-list.is-trn-doc = no
  doc-list.is-del     = no
  doc-list.doc-type   = 'переоценка':U
  doc-list.ext-doc-type   = 'ot':U
  doc-list.sel-order  = v-sel-order
  doc-list.znak       = 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        end.
        when 2 then do:
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = ub.inkas.inkas-code
  and doc-list.doc-type = 'касс':U
  no-error .
find first inkas_trn-doc where
           inkas_trn-doc.doc-code = ub.inkas.inkas-code no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  if ub.inkas.host-code <> p-curr-host-code then return.
  create doc-list .
  assign
  doc-list.doc-code   = ub.inkas.inkas-code
  doc-list.obj-type   = ub.inkas.obj-type
  doc-list.obj-code   = ub.inkas.obj-code
  doc-list.fact-num   = inkas_trn-doc.fact-num
  doc-list.fact-date  = ub.inkas.fact-date
  doc-list.shift-date = ub.inkas.shift-date
  doc-list.shift-num  = ub.inkas.shift-num
  doc-list.fact-order = inkas_trn-doc.fact-order
  doc-list.is-trn-doc = no
  doc-list.is-del     = no
  doc-list.doc-type   = 'касс':U
  doc-list.ext-doc-type   = 'касс':U
  doc-list.sel-order  = v-sel-order
  doc-list.znak       = 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        end.
        when 102 then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = ub.c-inkas.inkas-code
  and doc-list.doc-type = "-" + 'касс':U
  no-error .
find first c-inkas_trn-doc where
           c-inkas_trn-doc.doc-code = ub.c-inkas.inkas-code
     and  c-inkas_trn-doc.is-del = yes  no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  if ub.c-inkas.host-code <> p-curr-host-code then return.
  create doc-list .
  assign
  doc-list.doc-code   = ub.c-inkas.inkas-code
  doc-list.obj-type   = ub.c-inkas.obj-type
  doc-list.obj-code   = ub.c-inkas.obj-code
  doc-list.fact-num   = (if available c-inkas_trn-doc then c-inkas_trn-doc.fact-num else 0)
  doc-list.fact-date  = ub.c-inkas.fact-date
  doc-list.shift-date = ub.c-inkas.shift-date
  doc-list.shift-num  = ub.c-inkas.shift-num
  doc-list.fact-order = (if available c-inkas_trn-doc then c-inkas_trn-doc.fact-order else ?)
  doc-list.is-trn-doc = no
  doc-list.is-del     = yes
  doc-list.doc-type   =   "-" + 'касс':U
  doc-list.ext-doc-type = 'касс':U
  doc-list.sel-order  = v-sel-order
  doc-list.znak       = 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        end.
        when 3 then do:
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = ub.fbr-doc.doc-code
    and doc-list.doc-type = 'производство':U
  no-error .
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  if ub.fbr-doc.host-code <> p-curr-host-code then return.
  create doc-list .
  assign
  doc-list.doc-code   = ub.fbr-doc.doc-code
  doc-list.obj-type   = ub.fbr-doc.obj-type
  doc-list.obj-code   = ub.fbr-doc.obj-code
  doc-list.fact-num   = 0
  doc-list.fact-date  = ub.fbr-doc.fact-date
  doc-list.shift-date = ub.fbr-doc.shift-date
  doc-list.shift-num  = ub.fbr-doc.shift-num
  doc-list.fact-order = 0
  doc-list.is-trn-doc = no
  doc-list.doc-type   = 'производство':U
  doc-list.ext-doc-type   = 'производство':U
  doc-list.sel-order  = v-sel-order
  doc-list.znak       = 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        end.
        when 4 then do:
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find doc-list
  where doc-list.doc-code = ub.ord-doc.doc-code
  and doc-list.doc-type = ub.ord-doc.doc-type no-error.
if available doc-list then do:
  assign
    doc-list.to-del = no
  .
end.
else do:
  if ub.ord-doc.host-code <> p-curr-host-code then return.
  create doc-list .
  assign
  doc-list.doc-code   = ub.ord-doc.doc-code
  doc-list.obj-type   = ub.ord-doc.obj-type
  doc-list.obj-code   = ub.ord-doc.obj-code
  doc-list.fact-num   = ub.ord-doc.fact-num
  doc-list.fact-date  = ub.ord-doc.fact-date
  doc-list.shift-date = ub.ord-doc.shift-date
  doc-list.shift-num  = ub.ord-doc.shift-num
  doc-list.fact-order = ub.ord-doc.fact-order
  doc-list.is-trn-doc = no
  doc-list.is-del     = no
  doc-list.doc-type   = ub.ord-doc.doc-type
  doc-list.ext-doc-type   = ub.ord-doc.doc-type
  doc-list.sel-order  = v-sel-order
  doc-list.znak       = 1
  doc-list.to-del = no
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (doc-list)
  .
end.
        end.
      END CASE.
    end.
  display
   "Ждите..." + string (lns-cnt) @ dsp-rs
   with frame abc.
end PROCEDURE.
