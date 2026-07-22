block-level on error undo, throw.
using ibs.th.gbl.gbl-hndllib from propath.
define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Библиотека процедур для работы со складскими документами (2)":U .
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
define new global shared variable g#trdcalib as handle no-undo.
function diff-list returns character (
  input parfirst-list  as character,
  input parsecond-list as character,
  input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, parsecond-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function add-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  def var v-num-parsecond-list as integer no-undo .
  assign
    v-num-parsecond-list = num-entries(parsecond-list, pardelim)
  .
  do ind = 1 to v-num-parsecond-list
  :
    assign
      v-elem = entry(ind, parsecond-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0 then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function cross-list returns character (
 input parfirst-list  as character,
 input parsecond-list as character,
 input pardelim       as character).
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem as character no-undo .
  def var v-result-list as character no-undo init "".
  def var v-num-parfirst-list as integer no-undo .
  assign
    v-num-parfirst-list = num-entries(parfirst-list, pardelim)
  .
  do ind = 1 to v-num-parfirst-list
  :
    assign
      v-elem = entry(ind, parfirst-list, pardelim)
    .
    if lookup(v-elem, v-result-list, pardelim) = 0
    and lookup(v-elem, parsecond-list, pardelim) > 0
    then do:
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim else "")
                      + v-elem
      .
    end.
  end.
  return v-result-list .
end function.
function radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character)
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons)
                          ), par-rs-radio-buttons
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
function m-radio-label returns character (
 input par-rs-value  as character,
 input par-rs-radio-buttons as character,
 input par-delim as character
 )
 .
 DEFINE variable v-result-label as character no-undo.
 assign
 v-result-label =  ENTRY( (IF (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) MODULO 2 = 0)
                           then (LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim) - 1)
                           else LOOKUP(par-rs-value, par-rs-radio-buttons, par-delim)
                          ), par-rs-radio-buttons, par-delim
                        )
 v-result-label = REPLACE(v-result-label, "&":U, "":U)
 .
return v-result-label.
end function.
FUNCTION mixlist returns character
(
 input parfirst-list  as character
 ,input parsecond-list as character
 ,input pardelim       as character
 ,input pardelim-result as character ) :
  if pardelim = ""
  or pardelim = ?
  then do:
    assign
      pardelim = ","
    .
  end.
  def var ind as integer no-undo .
  def var v-elem1 as character no-undo .
  def var v-elem2 as character no-undo .
  def var v-result-list as character no-undo init "".
  do ind = 1 to num-entries(parfirst-list, pardelim)
  :
    assign
      v-elem1 = entry(ind, parfirst-list, pardelim)
      v-elem2 = entry(ind, parsecond-list, pardelim)
    .
      assign
        v-result-list = v-result-list
                      + (if v-result-list > "" then pardelim-result else "")
                      + v-elem1 + pardelim-result + v-elem2
      .
  end.
  return v-result-list .
END FUNCTION.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-parts no-undo   like ub.parts   field free-qnty as decimal   field free-cli-qnty as decimal .
procedure partslib-clear-temp-parts :
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error
  :
    for each buf_temp-parts
    on error undo, return error
    :
      delete buf_temp-parts .
    end.
  end.
end procedure.
procedure partslib-create-temp-parts :
  define parameter buffer buf_parts       for ub.parts .
  define parameter buffer buf_temp-parts  for temp-parts .
  define input  parameter p-goods-twounit as logical   no-undo .
  define variable v-base-part-code as character no-undo .
  do
  on error undo, return error
  :
    if p-goods-twounit = true
    then do:
      assign
        v-base-part-code = entry(1, buf_parts.part-code, '#':U)
      .
    end.
    else do:
      assign
        v-base-part-code = buf_parts.part-code
      .
    end.
    find first buf_temp-parts exclusive-lock
      where buf_temp-parts.obj-type  = buf_parts.obj-type
        and buf_temp-parts.obj-code  = buf_parts.obj-code
        and buf_temp-parts.artic     = buf_parts.artic
        and buf_temp-parts.prod-type = buf_parts.prod-type
        and buf_temp-parts.prod-code = buf_parts.prod-code
        and buf_temp-parts.in-code   = buf_parts.in-code
        and buf_temp-parts.out-code  = 'free-zone':U
        and buf_temp-parts.part-code = v-base-part-code
      no-error.
    if not available buf_temp-parts
    then do:
      create buf_temp-parts .
      buffer-copy buf_parts to buf_temp-parts
      assign
        buf_temp-parts.out-code  = 'free-zone':U
        buf_temp-parts.part-code = v-base-part-code
        buf_temp-parts.rsrv-free = yes
        buf_temp-parts.status_   = no
        buf_temp-parts.qnty      = 0
        buf_temp-parts.fact-qnty = 0
        buf_temp-parts.real-qnty = 0
        buf_temp-parts.cli-qnty  = 0
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info1 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    run partslib-clear-temp-parts in this-procedure .
    for each buf_parts
      where buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
        and buf_parts.rsrv-free = yes
        and buf_parts.status_   = no
        and buf_parts.in-code   <> buf_parts.out-code
    on error undo, return error
    :
      run partslib-create-temp-parts in this-procedure
        (buffer buf_parts
        ,buffer buf_temp-parts
        ,input  v-goods-twounit
        ) .
      define variable v-parts-qnty          as decimal   no-undo .
      define variable v-parts-cli-qnty      as decimal   no-undo .
      define variable v-parts-free-qnty     as decimal   no-undo .
      define variable v-parts-free-cli-qnty as decimal   no-undo .
      if buf_parts.out-code = 'free-zone':U
      then do:
        assign
          v-parts-qnty          = buf_parts.qnty
          v-parts-cli-qnty      = buf_parts.cli-qnty
          v-parts-free-qnty     = buf_parts.qnty
          v-parts-free-cli-qnty = buf_parts.cli-qnty
        .
      end.
      else do:
        assign
          v-parts-qnty          = abs(buf_parts.qnty)
          v-parts-cli-qnty      = abs(buf_parts.cli-qnty)
          v-parts-free-qnty     = 0
          v-parts-free-cli-qnty = 0
        .
      end.
      assign
        buf_temp-parts.qnty          = buf_temp-parts.qnty          + v-parts-qnty
        buf_temp-parts.fact-qnty     = buf_temp-parts.fact-qnty     + v-parts-qnty
        buf_temp-parts.real-qnty     = 0
        buf_temp-parts.cli-qnty      = buf_temp-parts.cli-qnty      + v-parts-cli-qnty
        buf_temp-parts.free-qnty     = buf_temp-parts.free-qnty     + v-parts-free-qnty
        buf_temp-parts.free-cli-qnty = buf_temp-parts.free-cli-qnty + v-parts-free-cli-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  do
  on error undo, return error
  :
    do transaction
    on error undo, return error
    :
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info1 skip
          "Невозможно найти товар на объекте" skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run partslib-init-temp-parts in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info1 skip
        "Ошибка при инициализации текущего остатка по партиям свободной зоны" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-include-fact-order = true
    then do:
      assign
        p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    define variable v-max-fact-order as character no-undo .
    run factord-max-fact-order in this-procedure
      (output v-max-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info1 skip
        "Ошибка при вызове процедуры factord-max-fact-order" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-update-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input p-fact-order
      ,input v-max-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info1 skip
        "Ошибка при вызове процедуры partslib-update-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-fact-order" p-fact-order skip
        "v-max-fact-order" v-max-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-update-by-factord :
  define input parameter p-obj-type           like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code           like ub.parts.obj-code  no-undo .
  define input parameter p-artic              like ub.parts.artic     no-undo .
  define input parameter p-prod-type          like ub.parts.prod-type no-undo .
  define input parameter p-prod-code          like ub.parts.prod-code no-undo .
  define input parameter p-start-fact-order   as decimal   no-undo .
  define input parameter p-end-fact-order     as decimal   no-undo .
  define input parameter p-lock-gds-obj       as logical   no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-factord: определение партий свободной зоны на любую дату".
  define buffer buf_gds-obj  for ub.gds-obj .
  define buffer buf_doc-line for ub.doc-line .
  define variable v-total-parts-qnty as decimal   no-undo .
  define variable v-goods-gds-goods  as logical   no-undo .
  define variable v-goods-twounit    as logical   no-undo .
  do
  on error undo, return error
  :
    if p-start-fact-order > p-end-fact-order
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info1 skip
        "Ошибка задания входных параметров" skip
        "Начало интервала превышает конец интервала" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "p-start-fact-order" p-start-fact-order skip
        "p-end-fact-order"   p-end-fact-order skip
        view-as alert-box error .
      undo, return error .
    end.
    if p-lock-gds-obj = true
    then do:
      do transaction
      on error undo, return error
      :
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info1 skip
            "Невозможно найти gds-obj" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        find current buf_gds-obj exclusive-lock .
      end.
    end.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'gds-goods=request':u
  ,output v-goods-gds-goods
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info1 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "gds-goods=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info1 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "twounit=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order > p-start-fact-order
        and buf_doc-line.fact-order <= p-end-fact-order
    on error undo, return error
    :
      run partslib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,input  v-goods-gds-goods
        ,input  v-goods-twounit
        ,output v-total-parts-qnty
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info1 skip
          "Ошибка при вызове процедуры partslib-process-document" skip
          "Документ" buf_doc-line.doc-code skip
          "Объект" p-obj-type p-obj-code skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "p-start-fact-order" p-start-fact-order skip
          "p-end-fact-order" p-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure partslib-process-document :
  define input  parameter p-doc-code         as character no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define input  parameter p-artic            as character no-undo .
  define input  parameter p-prod-type        as character no-undo .
  define input  parameter p-prod-code        as integer   no-undo .
  define input  parameter p-goods-gds-goods  as logical   no-undo .
  define input  parameter p-goods-twounit    as logical   no-undo .
  define output parameter p-total-parts-qnty as decimal   no-undo .
  define variable v-parts-sign as integer   no-undo .
  define buffer buf_trn-doc    for ub.trn-doc .
  define buffer buf_doc-line   for ub.doc-line .
  define buffer buf_parts      for ub.parts .
  define buffer buf_temp-parts for temp-parts .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc
    then do:
      undo, return error substitute("Ошибка при поиске документа. Документ &1"
                                   ,p-doc-code
                                   ) .
    end.
    case buf_trn-doc.doc-type
    :
      when 'при':U or
      when 'возврат':U or
      when 'инв':U
      then do:
        assign
          v-parts-sign = -1
        .
      end.
      when 'рас':U or
      when 'спи':U
      then do:
        assign
          v-parts-sign = 1
        .
      end.
      otherwise do:
        undo, return error substitute("Неизвестный тип документа &1"
                                    ,buf_trn-doc.doc-type
                                    ) .
      end.
    end.
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = p-artic
        and buf_doc-line.prod-type = p-prod-type
        and buf_doc-line.prod-code = p-prod-code
      no-error .
    if not available buf_doc-line
    then do:
      undo, return error substitute("Ошибка при поиске строки документа. Документ &1. Артикул &2 &3 &4"
                                   ,p-doc-code
                                   ,artic
                                   ,prod-type
                                   ,prod-code
                                   ) .
    end.
    assign
      p-total-parts-qnty = 0
    .
    if p-goods-gds-goods = true
    then do:
      for each buf_parts no-lock
        where buf_parts.out-code  = p-doc-code
          and buf_parts.obj-type  = p-obj-type
          and buf_parts.obj-code  = p-obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
      on error undo, return error
      :
        run partslib-create-temp-parts in this-procedure
          (buffer buf_parts
          ,buffer buf_temp-parts
          ,input  p-goods-twounit
          ) .
        assign
          p-total-parts-qnty        = p-total-parts-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.qnty       = buf_temp-parts.qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.fact-qnty  = buf_temp-parts.fact-qnty
                                    + v-parts-sign * buf_parts.fact-qnty
          buf_temp-parts.cli-qnty   = buf_temp-parts.cli-qnty
                                    + v-parts-sign * buf_parts.cli-qnty
        .
        if buf_temp-parts.qnty = 0
        then do:
          delete buf_temp-parts .
        end.
      end.
    end.
    else do:
      assign
        p-total-parts-qnty = p-total-parts-qnty
                           + v-parts-sign * buf_doc-line.fact-qnty
      .
    end.
  end.
end procedure.
procedure partslib-init-temp-parts-by-date :
  define input parameter p-obj-type        like ub.parts.obj-type  no-undo .
  define input parameter p-obj-code        like ub.parts.obj-code  no-undo .
  define input parameter p-artic           like ub.parts.artic     no-undo .
  define input parameter p-prod-type       like ub.parts.prod-type no-undo .
  define input parameter p-prod-code       like ub.parts.prod-code no-undo .
  define input parameter p-fact-date       as date      no-undo .
  define variable vss-description as character no-undo init "partslib-init-temp-parts-by-date: определение партий свободной зоны на любую дату".
  do
  on error undo, return error
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info1 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run partslib-init-temp-parts-by-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info1 skip
        "Ошибка при вызове метода partslib-init-temp-parts-by-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure partslib-calc-cost :
  define output parameter p-fact-qnty      as decimal   no-undo .
  define output parameter p-vat-pc         as decimal   no-undo .
  define output parameter p-slt-pc         as decimal   no-undo .
  define output parameter p-sum-base       as decimal   no-undo .
  define output parameter p-sum-rubl       as decimal   no-undo .
  define output parameter p-vat-base       as decimal   no-undo .
  define output parameter p-vat-rubl       as decimal   no-undo .
  define output parameter p-slt-base       as decimal   no-undo .
  define output parameter p-slt-rubl       as decimal   no-undo .
  define output parameter p-road-tax-base  as decimal   no-undo .
  define output parameter p-road-tax-rubl  as decimal   no-undo .
  define output parameter p-transport-base as decimal   no-undo .
  define output parameter p-transport-rubl as decimal   no-undo .
  define output parameter p-other-base     as decimal   no-undo .
  define output parameter p-other-rubl     as decimal   no-undo .
  define output parameter p-excise-base    as decimal   no-undo .
  define output parameter p-excise-rubl    as decimal   no-undo .
  define variable vss-description as character no-undo init "partslib-calc-cost: расчет сумм в учетных ценах".
  do
  on error undo, return error return-value
  :
    define buffer buf_temp-parts for temp-parts .
    define buffer   in-vatp-trn-doc  for ub.trn-doc .
    define buffer   in-vatp-parts    for ub.parts   .
    define buffer   in-vatp-doc      for ub.trn-doc .
    define buffer   in-vatp-goods    for ub.goods   .
    define buffer   in-vatp-sysconf  for ub.sysconf .
    define buffer   in-vatp_doc-attr for ub.doc-attr.
    define variable in-vatp-have-vat-slt       as   logical initial yes    no-undo.
    define variable vat-pc-loc                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprb                  as   character              no-undo.
    define variable slt-pc-loc                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rate              as   decimal                no-undo.
    define variable price-rubl-with-tax-loc    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loc    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loc     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loc like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loc like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loc  like ub.doc-line.price-base no-undo.
    define variable vat-base-loc               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loc               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loc               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loc                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loc          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loc           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loc         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loc         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loc          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loc             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loc             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loc              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loc          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envd             as   character              no-undo.
    define variable varinvatp-type             as   character              no-undo.
    for each buf_temp-parts
    on error undo, return error
    :
assign
  price-rubl-with-tax-loc = buf_temp-parts.price-rubl
  price-base-with-tax-loc = buf_temp-parts.price-base
.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_temp-parts.out-code = 'free-zone':U     or
     buf_temp-parts.out-code = 'out-zone':U   or
     buf_temp-parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_temp-parts.out-code
        and in-vatp_doc-attr.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attr then do:
      assign
        in-vatp-have-vat-slt = yes.
    end.
    else do:
         in-vatp-have-vat-slt = no.
    end.
  end.
  assign
   price-cli-with-tax-loc = buf_temp-parts.price-cli
   cli-base-rate          = buf_temp-parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_temp-parts.road-tax-base  = ? then 0 else buf_temp-parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_temp-parts.road-tax-rubl  = ? then 0 else buf_temp-parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_temp-parts.transport-base = ? then 0 else buf_temp-parts.transport-base)
          transport-rubl-loc = (if buf_temp-parts.transport-rubl = ? then 0 else buf_temp-parts.transport-rubl)
          other-base-loc     = (if buf_temp-parts.other-base     = ? then 0 else buf_temp-parts.other-base)
          other-rubl-loc     = (if buf_temp-parts.other-rubl     = ? then 0 else buf_temp-parts.other-rubl)
          vat-pc-loc         = (if buf_temp-parts.vat-pc         = ? then 0 else buf_temp-parts.vat-pc)
          slt-pc-loc         = (if buf_temp-parts.slt-pc         = ? then 0 else buf_temp-parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_temp-parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_temp-parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_temp-parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_temp-parts.price-cli .
  assign
    slt-cli-loc        = slt-rubl-loc       / exch-rate-cli-loc
    vat-cli-loc        = vat-rubl-loc       / exch-rate-cli-loc
    road-tax-cli-loc   = road-tax-rubl-loc  / exch-rate-cli-loc
    transport-cli-loc  = 0
    other-cli-loc      = 0
  .
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
      assign
        p-fact-qnty      = p-fact-qnty      + buf_temp-parts.fact-qnty
        p-vat-pc         = p-vat-pc         + vat-pc-loc
        p-slt-pc         = p-slt-pc         + slt-pc-loc
        p-sum-base       = p-sum-base       + price-base-with-tax-loc * buf_temp-parts.fact-qnty
        p-sum-rubl       = p-sum-rubl       + price-rubl-with-tax-loc * buf_temp-parts.fact-qnty
        p-vat-base       = p-vat-base       + vat-base-loc            * buf_temp-parts.fact-qnty
        p-vat-rubl       = p-vat-rubl       + vat-rubl-loc            * buf_temp-parts.fact-qnty
        p-slt-base       = p-slt-base       + slt-base-loc            * buf_temp-parts.fact-qnty
        p-slt-rubl       = p-slt-rubl       + slt-rubl-loc            * buf_temp-parts.fact-qnty
        p-road-tax-base  = p-road-tax-base  + road-tax-base-loc       * buf_temp-parts.fact-qnty
        p-road-tax-rubl  = p-road-tax-rubl  + road-tax-rubl-loc       * buf_temp-parts.fact-qnty
        p-transport-base = p-transport-base + transport-base-loc      * buf_temp-parts.fact-qnty
        p-transport-rubl = p-transport-rubl + transport-rubl-loc      * buf_temp-parts.fact-qnty
        p-other-base     = p-other-base     + other-base-loc          * buf_temp-parts.fact-qnty
        p-other-rubl     = p-other-rubl     + other-rubl-loc          * buf_temp-parts.fact-qnty
        p-excise-base    = p-excise-base    + 0
        p-excise-rubl    = p-excise-rubl    + 0
      .
    end.
    if p-fact-qnty      = ?
    or p-sum-base       = ?
    or p-sum-rubl       = ?
    or p-vat-base       = ?
    or p-vat-rubl       = ?
    or p-slt-base       = ?
    or p-slt-rubl       = ?
    or p-road-tax-base  = ?
    or p-road-tax-rubl  = ?
    or p-transport-base = ?
    or p-transport-rubl = ?
    or p-other-base     = ?
    or p-other-rubl     = ?
    or p-excise-base    = ?
    or p-excise-rubl    = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info1 skip
        "Программа in-vatp.i вернула неопределенные значения" skip
        "p-fact-qnty"      p-fact-qnty      skip
        "p-sum-base"       p-sum-base       skip
        "p-sum-rubl"       p-sum-rubl       skip
        "p-vat-base"       p-vat-base       skip
        "p-vat-rubl"       p-vat-rubl       skip
        "p-slt-base"       p-slt-base       skip
        "p-slt-rubl"       p-slt-rubl       skip
        "p-road-tax-base"  p-road-tax-base  skip
        "p-road-tax-rubl"  p-road-tax-rubl  skip
        "p-transport-base" p-transport-base skip
        "p-transport-rubl" p-transport-rubl skip
        "p-other-base"     p-other-base     skip
        "p-other-rubl"     p-other-rubl     skip
        "p-excise-base"    p-excise-base    skip
        "p-excise-rubl"    p-excise-rubl    skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
def var vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-allsum-line      no-undo
field sum-type           as   character
field fact-qnty          like ub.doc-line.fact-qnty
field cli-qnty           like ub.doc-line.cli-qnty
field sum-dsc-base-doc   like ub.doc-line.price-base
field sum-dsc-rubl-doc   like ub.doc-line.price-base
field dsc-base-doc       like ub.doc-line.price-base
field dsc-rubl-doc       like ub.doc-line.price-base
field vat-base-doc       like ub.doc-line.price-base
field vat-rubl-doc       like ub.doc-line.price-base
field vat-base-buyer-doc like ub.doc-line.price-base
field vat-rubl-buyer-doc like ub.doc-line.price-base
field slt-base-doc       like ub.doc-line.price-base
field slt-rubl-doc       like ub.doc-line.price-base
field road-tax-base-doc  like ub.doc-line.price-base
field road-tax-rubl-doc  like ub.doc-line.price-base
field excise-base-doc    like ub.doc-line.price-base
field excise-rubl-doc    like ub.doc-line.price-base
field sum-dsc-base-acc   like ub.doc-line.price-base
field sum-dsc-rubl-acc   like ub.doc-line.price-base
field sum-dsc-cli-acc    like ub.doc-line.price-cli
field dsc-base-acc       like ub.doc-line.price-base
field dsc-rubl-acc       like ub.doc-line.price-base
field dsc-cli-acc        like ub.doc-line.price-cli
field vat-base-acc       like ub.doc-line.price-base
field vat-rubl-acc       like ub.doc-line.price-base
field vat-cli-acc        like ub.doc-line.price-cli
field slt-base-acc       like ub.doc-line.price-base
field slt-rubl-acc       like ub.doc-line.price-base
field slt-cli-acc        like ub.doc-line.price-cli
field road-tax-base-acc  like ub.doc-line.price-base
field road-tax-rubl-acc  like ub.doc-line.price-base
field road-tax-cli-acc   like ub.doc-line.price-cli
field excise-base-acc    like ub.doc-line.price-base
field excise-rubl-acc    like ub.doc-line.price-base
field excise-cli-acc     like ub.doc-line.price-cli
field transport-base-acc like ub.doc-line.price-base
field transport-rubl-acc like ub.doc-line.price-base
field transport-cli-acc  like ub.doc-line.price-cli
field other-base-acc     like ub.doc-line.price-base
field other-rubl-acc     like ub.doc-line.price-base
field other-cli-acc      like ub.doc-line.price-cli
field sum-dsc-base-cur   like ub.doc-line.price-base
field sum-dsc-rubl-cur   like ub.doc-line.price-base
field dsc-base-cur       like ub.doc-line.price-base
field dsc-rubl-cur       like ub.doc-line.price-base
field vat-base-cur       like ub.doc-line.price-base
field vat-rubl-cur       like ub.doc-line.price-base
field vat-base-buyer-cur like ub.doc-line.price-base
field vat-rubl-buyer-cur like ub.doc-line.price-base
field slt-base-cur       like ub.doc-line.price-base
field slt-rubl-cur       like ub.doc-line.price-base
field road-tax-base-cur  like ub.doc-line.price-base
field road-tax-rubl-cur  like ub.doc-line.price-base
field excise-base-cur    like ub.doc-line.price-base
field excise-rubl-cur    like ub.doc-line.price-base
index sum-type is primary unique sum-type.
.
define temp-table tt-allsum no-undo
field sum-type           as   character
field fact-qnty             as decimal
field cli-qnty              as decimal
field sum-dsc-base-doc      as decimal
field sum-dsc-rubl-doc      as decimal
field dsc-base-doc          as decimal
field dsc-rubl-doc          as decimal
field vat-base-doc          as decimal
field vat-rubl-doc          as decimal
field vat-base-buyer-doc    as decimal
field vat-rubl-buyer-doc    as decimal
field slt-base-doc          as decimal
field slt-rubl-doc          as decimal
field road-tax-base-doc     as decimal
field road-tax-rubl-doc     as decimal
field excise-base-doc       as decimal
field excise-rubl-doc       as decimal
field sum-dsc-base-acc      as decimal
field sum-dsc-rubl-acc      as decimal
field sum-dsc-cli-acc       as decimal
field dsc-base-acc          as decimal
field dsc-rubl-acc          as decimal
field dsc-cli-acc           as decimal
field vat-base-acc          as decimal
field vat-rubl-acc          as decimal
field vat-cli-acc           as decimal
field slt-base-acc          as decimal
field slt-rubl-acc          as decimal
field slt-cli-acc           as decimal
field road-tax-base-acc     as decimal
field road-tax-rubl-acc     as decimal
field road-tax-cli-acc      as decimal
field excise-base-acc       as decimal
field excise-rubl-acc       as decimal
field excise-cli-acc        as decimal
field transport-base-acc    as decimal
field transport-rubl-acc    as decimal
field transport-cli-acc     as decimal
field other-base-acc        as decimal
field other-rubl-acc        as decimal
field other-cli-acc         as decimal
field sum-dsc-base-cur      as decimal
field sum-dsc-rubl-cur      as decimal
field dsc-base-cur          as decimal
field dsc-rubl-cur          as decimal
field vat-base-cur          as decimal
field vat-rubl-cur          as decimal
field vat-base-buyer-cur    as decimal
field vat-rubl-buyer-cur    as decimal
field slt-base-cur          as decimal
field slt-rubl-cur          as decimal
field road-tax-base-cur     as decimal
field road-tax-rubl-cur     as decimal
field excise-base-cur       as decimal
field excise-rubl-cur       as decimal
index sum-type is primary unique sum-type.
define temp-table tt-clcparts no-undo like ub.parts
field part-cur-base like ub.gds-dtl.price-base
field part-cur-road-tax like ub.gds-dtl.price-base
field part-cur-excise like ub.gds-dtl.price-base
.
define variable v-calcbypart as log no-undo.
procedure clcprtsl_calc-parts :
define input parameter parrec-parts        as   recid                   no-undo.
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcurroad-tax      like ub.doc-line.road-tax    no-undo.
define input parameter parcurexcise        like ub.doc-line.excise      no-undo.
define input parameter parcurvat-pc        like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define variable parartic        like ub.parts.artic         no-undo.
define variable parprod-type    like ub.parts.prod-type     no-undo.
define variable parprod-code    like ub.parts.prod-code     no-undo.
define variable pardoc-type     like ub.parts.doc-type      no-undo.
define variable pardoc-code     like ub.parts.out-code      no-undo.
define variable parobj-type     like ub.parts.obj-type      no-undo.
define variable parobj-code     like ub.parts.obj-code      no-undo.
define variable parprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable pardiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable pardiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable pardoc-qnty     like ub.parts.qnty          no-undo.
define variable parext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define variable parcurartic        like ub.parts.artic         no-undo.
define variable parcurprod-type    like ub.parts.prod-type     no-undo.
define variable parcurprod-code    like ub.parts.prod-code     no-undo.
define variable parcurdoc-type     like ub.parts.doc-type      no-undo.
define variable parcurdoc-code     like ub.parts.out-code      no-undo.
define variable parcurobj-type     like ub.parts.obj-type      no-undo.
define variable parcurobj-code     like ub.parts.obj-code      no-undo.
define variable parcurprice-base   like ub.gds-dtl.price-base  no-undo.
define variable parcurprice-rubl   like ub.gds-dtl.price-rubl  no-undo.
define variable parcurdiscnt-base  like ub.gds-dtl.discnt-base no-undo.
define variable parcurdiscnt-rubl  like ub.gds-dtl.discnt-rubl no-undo.
define variable parcurfact-qnty    like ub.parts.fact-qnty     no-undo.
define variable parcurcli-qnty     like ub.parts.cli-qnty      no-undo.
define variable parcurdoc-qnty     like ub.parts.qnty          no-undo.
define variable parcurbase-rate    like ub.trn-doc.base-rate   no-undo.
define variable parcurbase-scale   like ub.trn-doc.base-scale  no-undo.
define variable parcurext-doc-type like ub.trn-doc.ext-doc-type no-undo.
define buffer bf_tt-allsum     for tt-allsum.
define buffer bfs_tt-allsum    for tt-allsum.
define buffer bfpc_tt-allsum   for tt-allsum.
define buffer bfspc_tt-allsum  for tt-allsum.
define buffer bfacc_tt-allsum  for tt-allsum.
define buffer bfsacc_tt-allsum for tt-allsum.
define buffer cl_tt-clcparts   for tt-clcparts.
define buffer bf_trn-doc       for ub.trn-doc.
define buffer bf_sysconf       for ub.sysconf.
    define buffer   in-vatp-trn-doccl  for ub.trn-doc .
    define buffer   in-vatp-partscl    for ub.parts   .
    define buffer   in-vatp-doccl      for ub.trn-doc .
    define buffer   in-vatp-goodscl    for ub.goods   .
    define buffer   in-vatp-sysconfcl  for ub.sysconf .
    define buffer   in-vatp_doc-attrcl for ub.doc-attr.
    define variable in-vatp-have-vat-sltcl       as   logical initial yes    no-undo.
    define variable vat-pc-loccl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbcl                  as   character              no-undo.
    define variable slt-pc-loccl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-ratecl              as   decimal                no-undo.
    define variable price-rubl-with-tax-loccl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-loccl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-loccl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-loccl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-loccl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-loccl  like ub.doc-line.price-base no-undo.
    define variable vat-base-loccl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-loccl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-loccl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-loccl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-loccl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-loccl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-loccl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-loccl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-loccl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-loccl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-loccl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-loccl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-loccl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdcl             as   character              no-undo.
    define variable varinvatp-typecl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecl    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecl    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecl like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecl like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercl              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercl              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecl               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecl               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecl          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecl            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecl            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecl            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecl            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcl     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcl for ub.gds-dtl.
    define buffer out-vatp_partscl       for ub.parts.
    define buffer out-vatp_sysconfcl     for ub.sysconf.
    define buffer out-vatp_doc-linecl    for ub.doc-line.
    define buffer out-vatp_goodscl       for ub.goods.
    define buffer out-vatp_trn-doccl     for ub.trn-doc.
    define buffer out-vatp_doc-attrcl    for ub.doc-attr.
    define variable varprice-base-conscl      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscl      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecl         as   character                           no-undo.
    define variable varfrm-cnsvcl              as   character                           no-undo.
    define variable varroot-nodecl             as   integer                             no-undo.
    define variable varempty-scalecl           as   logical                             no-undo.
    define variable varis-cons-parts-havecl    as   logical                             no-undo.
    define variable varsum-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcl  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcl      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcl   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcl       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycl             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcl        as   logical                             no-undo.
    define variable varcurclprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurclprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcldiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcldiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcl               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcl    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococl  for ub.trn-doc .
    define buffer   in-vatp-partsocl    for ub.parts   .
    define buffer   in-vatp-dococl      for ub.trn-doc .
    define buffer   in-vatp-goodsocl    for ub.goods   .
    define buffer   in-vatp-sysconfocl  for ub.sysconf .
    define buffer   in-vatp_doc-attrocl for ub.doc-attr.
    define variable in-vatp-have-vat-sltocl       as   logical initial yes    no-undo.
    define variable vat-pc-lococl                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocl                  as   character              no-undo.
    define variable slt-pc-lococl                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocl              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococl    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococl    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococl     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococl like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococl like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococl  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococl               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococl               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococl               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococl                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococl          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococl           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococl         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococl         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococl          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococl             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococl             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococl              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococl          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocl             as   character              no-undo.
    define variable varinvatp-typeocl             as   character              no-undo.
    define  variable price-rubl-with-tax-salecur    like ub.doc-line.price-rubl no-undo.
    define  variable price-base-with-tax-salecur    like ub.doc-line.price-base no-undo.
    define  variable price-rubl-without-tax-salecur like ub.doc-line.price-rubl no-undo.
    define  variable price-base-without-tax-salecur like ub.doc-line.price-base no-undo.
    define  variable vat-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable vat-base-buyercur              like ub.doc-line.price-base no-undo.
    define  variable vat-rubl-buyercur              like ub.doc-line.price-rubl no-undo.
    define  variable slt-base-salecur               like ub.doc-line.price-base no-undo.
    define  variable slt-rubl-salecur               like ub.doc-line.price-rubl no-undo.
    define  variable road-tax-base-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable road-tax-rubl-salecur          like ub.doc-line.road-tax   no-undo.
    define  variable excise-base-salecur            like ub.doc-line.price-base no-undo.
    define  variable excise-rubl-salecur            like ub.doc-line.price-rubl no-undo.
    define  variable discnt-base-salecur            like ub.gds-dtl.discnt-base no-undo.
    define  variable discnt-rubl-salecur            like ub.gds-dtl.discnt-rubl no-undo.
    define buffer out-vatp_gds-dtlcur     for ub.gds-dtl.
    define buffer buf_out-vatp_gds-dtlcur for ub.gds-dtl.
    define buffer out-vatp_partscur       for ub.parts.
    define buffer out-vatp_sysconfcur     for ub.sysconf.
    define buffer out-vatp_doc-linecur    for ub.doc-line.
    define buffer out-vatp_goodscur       for ub.goods.
    define buffer out-vatp_trn-doccur     for ub.trn-doc.
    define buffer out-vatp_doc-attrcur    for ub.doc-attr.
    define variable varprice-base-conscur      like ub.doc-line.price-base initial 0.00 no-undo.
    define variable varprice-rubl-conscur      like ub.doc-line.price-rubl initial 0.00 no-undo.
    define variable varfrm-cnsv-typecur         as   character                           no-undo.
    define variable varfrm-cnsvcur              as   character                           no-undo.
    define variable varroot-nodecur             as   integer                             no-undo.
    define variable varempty-scalecur           as   logical                             no-undo.
    define variable varis-cons-parts-havecur    as   logical                             no-undo.
    define variable varsum-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-base-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-base-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-factovpcur  like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-factovpcur      like ub.gds-dtl.price-base               no-undo.
    define variable varsum-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varslt-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvat-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varvatcons-rubl-docovpcur   like ub.gds-dtl.price-base               no-undo.
    define variable vardsc-rubl-docovpcur       like ub.gds-dtl.price-base               no-undo.
    define variable varfact-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varcons-qntycur             like ub.parts.fact-qnty                  no-undo.
    define variable varis-one-gds-dtlcur        as   logical                             no-undo.
    define variable varcurcurprice-base         like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurprice-rubl         like ub.gds-dtl.price-base               no-undo.
    define variable varcurcurdiscnt-base        like ub.gds-dtl.cur-base                 no-undo.
    define variable varcurcurdiscnt-rubl        like ub.gds-dtl.price-base               no-undo.
    define variable varoutvprbcur               as   character                           no-undo.
    define variable out-vatp-have-vat-sltcur    as   logical initial yes                 no-undo.
    define buffer   in-vatp-trn-dococur  for ub.trn-doc .
    define buffer   in-vatp-partsocur    for ub.parts   .
    define buffer   in-vatp-dococur      for ub.trn-doc .
    define buffer   in-vatp-goodsocur    for ub.goods   .
    define buffer   in-vatp-sysconfocur  for ub.sysconf .
    define buffer   in-vatp_doc-attrocur for ub.doc-attr.
    define variable in-vatp-have-vat-sltocur       as   logical initial yes    no-undo.
    define variable vat-pc-lococur                 like ub.doc-line.vat-pc     no-undo.
    define variable varinvprbocur                  as   character              no-undo.
    define variable slt-pc-lococur                 like ub.doc-line.slt-pc     no-undo.
    define variable cli-base-rateocur              as   decimal                no-undo.
    define variable price-rubl-with-tax-lococur    like ub.doc-line.price-rubl no-undo.
    define variable price-base-with-tax-lococur    like ub.doc-line.price-base no-undo.
    define variable price-cli-with-tax-lococur     like ub.doc-line.price-cli  no-undo.
    define variable price-rubl-without-tax-lococur like ub.doc-line.price-rubl no-undo.
    define variable price-base-without-tax-lococur like ub.doc-line.price-base no-undo.
    define variable price-cli-without-tax-lococur  like ub.doc-line.price-base no-undo.
    define variable vat-base-lococur               like ub.doc-line.price-base no-undo.
    define variable vat-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable vat-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable slt-base-lococur               like ub.doc-line.price-base no-undo.
    define variable slt-rubl-lococur               like ub.doc-line.price-rubl no-undo.
    define variable slt-cli-lococur                like ub.doc-line.price-rubl no-undo.
    define variable road-tax-base-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-rubl-lococur          like ub.doc-line.road-tax   no-undo.
    define variable road-tax-cli-lococur           like ub.doc-line.road-tax   no-undo.
    define variable transport-base-lococur         like ub.doc-line.price-base no-undo.
    define variable transport-rubl-lococur         like ub.doc-line.price-rubl no-undo.
    define variable transport-cli-lococur          like ub.doc-line.price-rubl no-undo.
    define variable other-base-lococur             like ub.doc-line.price-base no-undo.
    define variable other-rubl-lococur             like ub.doc-line.price-rubl no-undo.
    define variable other-cli-lococur              like ub.doc-line.price-rubl no-undo.
    define variable exch-rate-cli-lococur          like ub.trn-doc.exch-rate   no-undo.
    define variable varinvatp-envdocur             as   character              no-undo.
    define variable varinvatp-typeocur             as   character              no-undo.
do on error undo, return error return-value :
find first cl_tt-clcparts where recid(cl_tt-clcparts) = parrec-parts no-lock.
for each bf_tt-allsum on error undo, return error return-value :
  delete bf_tt-allsum.
end.
assign
  price-rubl-with-tax-loccl = cl_tt-clcparts.price-rubl
  price-base-with-tax-loccl = cl_tt-clcparts.price-base
.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbcl
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltcl = yes.
  end.
  else do:
    find first in-vatp_doc-attrcl no-lock
      where in-vatp_doc-attrcl.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrcl then do:
      assign
        in-vatp-have-vat-sltcl = yes.
    end.
    else do:
         in-vatp-have-vat-sltcl = no.
    end.
  end.
  assign
   price-cli-with-tax-loccl = cl_tt-clcparts.price-cli
   cli-base-ratecl          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-loccl  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-loccl  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-loccl = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-loccl = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-loccl     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-loccl     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-loccl         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-loccl         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-base-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-base-with-tax-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
    ASSIGN   slt-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl)))                           * slt-pc-loccl / (100 + slt-pc-loccl))                        vat-rubl-loccl    = (if in-vatp-have-vat-sltcl = no then 0 else (price-rubl-with-tax-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))) * (1 - slt-pc-loccl / (100 + slt-pc-loccl)) * vat-pc-loccl / (100 + vat-pc-loccl)).
  assign
    exch-rate-cli-loccl = (cl_tt-clcparts.price-rubl - transport-rubl-loccl - other-rubl-loccl - road-tax-rubl-loccl - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-loccl else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-loccl else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-loccl        = slt-rubl-loccl       / exch-rate-cli-loccl
    vat-cli-loccl        = vat-rubl-loccl       / exch-rate-cli-loccl
    road-tax-cli-loccl   = road-tax-rubl-loccl  / exch-rate-cli-loccl
    transport-cli-loccl  = 0
    other-cli-loccl      = 0
  .
ASSIGN
          price-base-without-tax-loccl = price-base-with-tax-loccl - vat-base-loccl - slt-base-loccl - ((if road-tax-base-loccl  = ? then 0 else road-tax-base-loccl) + (if transport-base-loccl = ? then 0 else transport-base-loccl) + (if other-base-loccl = ? then 0 else other-base-loccl))
    price-rubl-without-tax-loccl = price-rubl-with-tax-loccl - vat-rubl-loccl - slt-rubl-loccl - ((if road-tax-rubl-loccl  = ? then 0 else road-tax-rubl-loccl) + (if transport-rubl-loccl = ? then 0 else transport-rubl-loccl) + (if other-rubl-loccl = ? then 0 else other-rubl-loccl))
.
if paris-doc then do:
  assign
    parartic     = cl_tt-clcparts.artic
    parprod-type = cl_tt-clcparts.prod-type
    parprod-code = cl_tt-clcparts.prod-code
    pardoc-type  = cl_tt-clcparts.doc-type
    pardoc-code  = cl_tt-clcparts.out-code
    parobj-type  = cl_tt-clcparts.obj-type
    parobj-code  = cl_tt-clcparts.obj-code.
if parext-doc-type = 'ot':U or
   parext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcl = yes.
end.
else do:
  find first out-vatp_doc-attrcl no-lock
    where out-vatp_doc-attrcl.doc-code  = pardoc-code
      and out-vatp_doc-attrcl.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcl then do:
    assign
      out-vatp-have-vat-sltcl = yes.
  end.
  else do:
     out-vatp-have-vat-sltcl = no.
  end.
end.
find first out-vatp_goodscl where out-vatp_goodscl.artic     = parartic     and
                                   out-vatp_goodscl.prod-type = parprod-type and
                                   out-vatp_goodscl.prod-code = parprod-code no-lock.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parartic
  ,input  parprod-type
  ,input  parprod-code
  ,output varroot-nodecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parartic parprod-type parprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecl
  ,input  'empty-scale=request'
  ,output varempty-scalecl
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parartic parprod-type parprod-code skip
    "Признак" varroot-nodecl skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcl
  )  .
if varoutvprbcl = "base":u then do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecl    =  (if parroad-tax = ? then 0 else parroad-tax / parbase-rate * parbase-scale)
    excise-base-salecl      =  (if parexcise   = ? then 0 else parexcise   / parbase-rate * parbase-scale)
  .
end.
if varoutvprbcl = "rubl":u then do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * 1)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecl    = (if parroad-tax = ? then 0 else parroad-tax * parbase-rate / parbase-scale)
    excise-rubl-salecl      = (if parexcise   = ? then 0 else parexcise   * parbase-rate / parbase-scale) .
end.
assign
  varis-cons-parts-havecl =  no.
assign
  varfact-qntycl       = 0
  varcons-qntycl       = 0
  varprice-base-conscl = 0
  varprice-rubl-conscl = 0.
find first out-vatp_doc-linecl where
           out-vatp_doc-linecl.doc-code   = pardoc-code
       and out-vatp_doc-linecl.artic      = parartic
       and out-vatp_doc-linecl.prod-type  = parprod-type
       and out-vatp_doc-linecl.prod-code  = parprod-code no-lock no-error.
if available out-vatp_doc-linecl           and
  (out-vatp_doc-linecl.status_ = 'запрос':U or out-vatp_goodscl.gds-type = 'у':U) then do:
  assign
    varfact-qntycl = out-vatp_doc-linecl.fact-qnty.
end.
else do:
  for each out-vatp_partscl where out-vatp_partscl.out-code   = pardoc-code
                               and out-vatp_partscl.obj-type   = parobj-type
                               and out-vatp_partscl.obj-code   = parobj-code
                               and out-vatp_partscl.artic      = parartic
                               and out-vatp_partscl.prod-type  = parprod-type
                               and out-vatp_partscl.prod-code  = parprod-code no-lock :
    if out-vatp_partscl.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococl = out-vatp_partscl.price-rubl
  price-base-with-tax-lococl = out-vatp_partscl.price-base
.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocl
  )  .
  if out-vatp_partscl.out-code = 'free-zone':U     or
     out-vatp_partscl.out-code = 'out-zone':U   or
     out-vatp_partscl.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocl = yes.
  end.
  else do:
    find first in-vatp_doc-attrocl no-lock
      where in-vatp_doc-attrocl.doc-code  = out-vatp_partscl.out-code
        and in-vatp_doc-attrocl.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocl then do:
      assign
        in-vatp-have-vat-sltocl = yes.
    end.
    else do:
         in-vatp-have-vat-sltocl = no.
    end.
  end.
  assign
   price-cli-with-tax-lococl = out-vatp_partscl.price-cli
   cli-base-rateocl          = out-vatp_partscl.cli-base-rate.
  ASSIGN   road-tax-base-lococl  = (if out-vatp_partscl.road-tax-base  = ? then 0 else out-vatp_partscl.road-tax-base)
           road-tax-rubl-lococl  = (if out-vatp_partscl.road-tax-rubl  = ? then 0 else out-vatp_partscl.road-tax-rubl).
  ASSIGN  transport-base-lococl = (if out-vatp_partscl.transport-base = ? then 0 else out-vatp_partscl.transport-base)
          transport-rubl-lococl = (if out-vatp_partscl.transport-rubl = ? then 0 else out-vatp_partscl.transport-rubl)
          other-base-lococl     = (if out-vatp_partscl.other-base     = ? then 0 else out-vatp_partscl.other-base)
          other-rubl-lococl     = (if out-vatp_partscl.other-rubl     = ? then 0 else out-vatp_partscl.other-rubl)
          vat-pc-lococl         = (if out-vatp_partscl.vat-pc         = ? then 0 else out-vatp_partscl.vat-pc)
          slt-pc-lococl         = (if out-vatp_partscl.slt-pc         = ? then 0 else out-vatp_partscl.slt-pc).
          ASSIGN   slt-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-base-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-base-with-tax-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
    ASSIGN   slt-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl)))                           * slt-pc-lococl / (100 + slt-pc-lococl))                        vat-rubl-lococl    = (if in-vatp-have-vat-sltocl = no then 0 else (price-rubl-with-tax-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))) * (1 - slt-pc-lococl / (100 + slt-pc-lococl)) * vat-pc-lococl / (100 + vat-pc-lococl)).
  assign
    exch-rate-cli-lococl = (out-vatp_partscl.price-rubl - transport-rubl-lococl - other-rubl-lococl - road-tax-rubl-lococl - (if out-vatp_partscl.vat-type <> 'в т. ч.':U then vat-rubl-lococl else 0) - (if out-vatp_partscl.slt-type <> 'в т. ч.':U then slt-rubl-lococl else 0)) / out-vatp_partscl.price-cli .
  assign
    slt-cli-lococl        = slt-rubl-lococl       / exch-rate-cli-lococl
    vat-cli-lococl        = vat-rubl-lococl       / exch-rate-cli-lococl
    road-tax-cli-lococl   = road-tax-rubl-lococl  / exch-rate-cli-lococl
    transport-cli-lococl  = 0
    other-cli-lococl      = 0
  .
ASSIGN
          price-base-without-tax-lococl = price-base-with-tax-lococl - vat-base-lococl - slt-base-lococl - ((if road-tax-base-lococl  = ? then 0 else road-tax-base-lococl) + (if transport-base-lococl = ? then 0 else transport-base-lococl) + (if other-base-lococl = ? then 0 else other-base-lococl))
    price-rubl-without-tax-lococl = price-rubl-with-tax-lococl - vat-rubl-lococl - slt-rubl-lococl - ((if road-tax-rubl-lococl  = ? then 0 else road-tax-rubl-lococl) + (if transport-rubl-lococl = ? then 0 else transport-rubl-lococl) + (if other-rubl-lococl = ? then 0 else other-rubl-lococl))
.
      assign
        varprice-base-conscl = varprice-base-conscl + (price-base-with-tax-lococl - (if road-tax-base-lococl = ? then 0 else road-tax-base-lococl))* out-vatp_partscl.fact-qnty
        varprice-rubl-conscl = varprice-rubl-conscl + (price-rubl-with-tax-lococl - (if road-tax-rubl-lococl = ? then 0 else road-tax-rubl-lococl))* out-vatp_partscl.fact-qnty.
      assign
        varis-cons-parts-havecl = yes
        varcons-qntycl          = varcons-qntycl + out-vatp_partscl.fact-qnty.
    end.
    assign
      varfact-qntycl = varfact-qntycl + out-vatp_partscl.fact-qnty.
  end.
end.
assign
  varprice-base-conscl = varprice-base-conscl / varcons-qntycl
  varprice-rubl-conscl = varprice-rubl-conscl / varcons-qntycl.
if varprice-base-conscl = ? then do:
  assign
    varprice-base-conscl = 0.
end.
if varprice-rubl-conscl = ? then do:
  assign
    varprice-rubl-conscl = 0.
end.
assign
  varsum-base-factovpcl     = 0
  varslt-base-factovpcl     = 0
  varvat-base-factovpcl     = 0
  varvatcons-base-factovpcl = 0
  vardsc-base-factovpcl     = 0
  varsum-base-docovpcl      = 0
  varslt-base-docovpcl      = 0
  varvat-base-docovpcl      = 0
  varvatcons-base-docovpcl  = 0
  vardsc-base-docovpcl      = 0
  varsum-rubl-factovpcl     = 0
  varslt-rubl-factovpcl     = 0
  varvat-rubl-factovpcl     = 0
  varvatcons-rubl-factovpcl = 0
  vardsc-rubl-factovpcl     = 0
  varsum-rubl-docovpcl      = 0
  varslt-rubl-docovpcl      = 0
  varvat-rubl-docovpcl      = 0
  varvatcons-rubl-docovpcl  = 0
  vardsc-rubl-docovpcl      = 0.
assign
  varis-one-gds-dtlcl = no.
find first out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                     out-vatp_gds-dtlcl.artic     = parartic     and
                                     out-vatp_gds-dtlcl.prod-type = parprod-type and
                                     out-vatp_gds-dtlcl.prod-code = parprod-code no-lock no-error.
if available out-vatp_gds-dtlcl then do:
  find first buf_out-vatp_gds-dtlcl where buf_out-vatp_gds-dtlcl.doc-code  =  pardoc-code                and
                                           buf_out-vatp_gds-dtlcl.artic     =  parartic                   and
                                           buf_out-vatp_gds-dtlcl.prod-type =  parprod-type               and
                                           buf_out-vatp_gds-dtlcl.prod-code =  parprod-code               and
                                           recid(buf_out-vatp_gds-dtlcl)    <> recid(out-vatp_gds-dtlcl) no-lock no-error.
  if not available buf_out-vatp_gds-dtlcl then do:
    assign
      varis-one-gds-dtlcl = yes.
  end.
  if varoutvprbcl = "base":u then do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
  end.
  else do:
    assign
      varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
      varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
  end.
  if varempty-scalecl    = yes or
     varis-one-gds-dtlcl = yes   then do:
    assign
                price-base-with-tax-salecl    = (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)
        slt-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-base-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-base-salecl            = out-vatp_gds-dtlcl.discnt-base
                price-rubl-with-tax-salecl    = (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)
        slt-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)
        vat-rubl-buyercl              = (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)
        discnt-rubl-salecl            = out-vatp_gds-dtlcl.discnt-rubl
        .
    if pardoc-type = 'инв':U then do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
    else do:
      ASSIGN
                vat-base-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl ) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
                vat-rubl-salecl               = (if out-vatp-have-vat-sltcl = no then 0 else (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl) / varfact-qntycl)
        .
    end.
  end.
  else do:
    for each out-vatp_gds-dtlcl where out-vatp_gds-dtlcl.doc-code  = pardoc-code  and
                                       out-vatp_gds-dtlcl.artic     = parartic     and
                                       out-vatp_gds-dtlcl.prod-type = parprod-type and
                                       out-vatp_gds-dtlcl.prod-code = parprod-code no-lock :
      if varoutvprbcl = "base":u then do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base * ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)).
      end.
      else do:
        assign
          varcurclprice-base = out-vatp_gds-dtlcl.cur-base / ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) / (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base))
          varcurclprice-rubl = out-vatp_gds-dtlcl.cur-base.
      end.
      assign
             varsum-base-factovpcl = varsum-base-factovpcl + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-base-factovpcl = varslt-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-base-factovpcl = varvat-base-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-base-factovpcl = varvatcons-base-factovpcl + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-factovpcl = vardsc-base-factovpcl + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.fact-qnty
       varsum-base-docovpcl  = varsum-base-docovpcl  + (out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-base-docovpcl  = varslt-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-base-docovpcl  = varvat-base-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-base-docovpcl  = varvatcons-base-docovpcl  + (((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl - varprice-base-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-base - out-vatp_gds-dtlcl.discnt-base                - road-tax-base-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-base-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-base-docovpcl  = vardsc-base-docovpcl  + out-vatp_gds-dtlcl.discnt-base * out-vatp_gds-dtlcl.doc-qnty
      .
      assign
             varsum-rubl-factovpcl = varsum-rubl-factovpcl + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.fact-qnty
       varslt-rubl-factovpcl = varslt-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvat-rubl-factovpcl = varvat-rubl-factovpcl + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.fact-qnty
       varvatcons-rubl-factovpcl = varvatcons-rubl-factovpcl + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.fact-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.fact-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-factovpcl = vardsc-rubl-factovpcl + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.fact-qnty
       varsum-rubl-docovpcl  = varsum-rubl-docovpcl  + (out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl)                 * out-vatp_gds-dtlcl.doc-qnty
       varslt-rubl-docovpcl  = varslt-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvat-rubl-docovpcl  = varvat-rubl-docovpcl  + (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc)                   * out-vatp_gds-dtlcl.doc-qnty
       varvatcons-rubl-docovpcl  = varvatcons-rubl-docovpcl  + (((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl - varprice-rubl-conscl) * parcons-vat-pc / (100 + parcons-vat-pc) * out-vatp_gds-dtlcl.doc-qnty * varcons-qntycl / varfact-qntycl + ((out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl) - (if out-vatp-have-vat-sltcl = no then 0 else out-vatp_gds-dtlcl.price-rubl - out-vatp_gds-dtlcl.discnt-rubl                - road-tax-rubl-salecl) * parSLT-pc / (100 + parSLT-pc) - road-tax-rubl-salecl) * parvat-pc / (100 + parvat-pc) * out-vatp_gds-dtlcl.doc-qnty * (varfact-qntycl - varcons-qntycl) / varfact-qntycl)
       vardsc-rubl-docovpcl  = vardsc-rubl-docovpcl  + out-vatp_gds-dtlcl.discnt-rubl * out-vatp_gds-dtlcl.doc-qnty   .
    end.
    if pardoc-type = 'инв':U then do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-docovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-docovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-docovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-docovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-docovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-docovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-docovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-docovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-docovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-docovpcl / varfact-qntycl.
    end.
    else do:
      ASSIGN
                price-base-with-tax-salecl    = varsum-base-factovpcl / varfact-qntycl
        slt-base-salecl               = varslt-base-factovpcl / varfact-qntycl
        vat-base-buyercl              = varvat-base-factovpcl / varfact-qntycl
        discnt-base-salecl            = vardsc-base-factovpcl / varfact-qntycl
        vat-base-salecl               = varvatcons-base-factovpcl / varfact-qntycl
                price-rubl-with-tax-salecl    = varsum-rubl-factovpcl / varfact-qntycl
        slt-rubl-salecl               = varslt-rubl-factovpcl / varfact-qntycl
        vat-rubl-buyercl              = varvat-rubl-factovpcl / varfact-qntycl
        discnt-rubl-salecl            = vardsc-rubl-factovpcl / varfact-qntycl
        vat-rubl-salecl               = varvatcons-rubl-factovpcl / varfact-qntycl.
    end.
  end.
end.
assign
  price-base-without-tax-salecl = price-base-with-tax-salecl - vat-base-salecl - slt-base-salecl - road-tax-base-salecl
  price-rubl-without-tax-salecl = price-rubl-with-tax-salecl - vat-rubl-salecl - slt-rubl-salecl - road-tax-rubl-salecl.
end.
if paris-cur then do:
  assign
    parcurartic      = cl_tt-clcparts.artic
    parcurprod-type  = cl_tt-clcparts.prod-type
    parcurprod-code  = cl_tt-clcparts.prod-code
    parcurdoc-type   = cl_tt-clcparts.doc-type
    parcurdoc-code   = cl_tt-clcparts.out-code
    parcurobj-type   = cl_tt-clcparts.obj-type
    parcurobj-code   = cl_tt-clcparts.obj-code.
  if parr-b = "base" then do:
    assign
      parcurprice-base = parcur-base
      parcurprice-rubl = parcur-base * parbase-rate / parbase-scale.
  end.
  else do:
    assign
      parcurprice-base = parcur-base / parbase-rate * parbase-scale
      parcurprice-rubl = parcur-base.
  end.
  assign
    parcurbase-rate   = parbase-rate
    parcurbase-scale  = parbase-scale
    parcurdiscnt-base = 0
    parcurdiscnt-rubl = 0
    parcurfact-qnty   = cl_tt-clcparts.fact-qnty
    parcurcli-qnty    = cl_tt-clcparts.cli-qnty
    parcurdoc-qnty    = cl_tt-clcparts.qnty.
if parcurext-doc-type = 'ot':U or
   parcurext-doc-type = ?                 then do:
  assign
   out-vatp-have-vat-sltcur = yes.
end.
else do:
  find first out-vatp_doc-attrcur no-lock
    where out-vatp_doc-attrcur.doc-code  = parcurdoc-code
      and out-vatp_doc-attrcur.attr-code = 'envd':U
      no-error .
  if not available out-vatp_doc-attrcur then do:
    assign
      out-vatp-have-vat-sltcur = yes.
  end.
  else do:
     out-vatp-have-vat-sltcur = no.
  end.
end.
find first out-vatp_goodscur where out-vatp_goodscur.artic     = parcurartic     and
                                   out-vatp_goodscur.prod-type = parcurprod-type and
                                   out-vatp_goodscur.prod-code = parcurprod-code no-lock.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  parcurartic
  ,input  parcurprod-type
  ,input  parcurprod-code
  ,output varroot-nodecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении корневого признака товара" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  varroot-nodecur
  ,input  'empty-scale=request'
  ,output varempty-scalecur
  ) no-error .
if error-status :error then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута признака" skip
    "Артикул" parcurartic parcurprod-type parcurprod-code skip
    "Признак" varroot-nodecur skip
    "Запрашивался атрибут" "empty-scale=request" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varoutvprbcur
  )  .
if varoutvprbcur = "base":u then do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   * 1)
  .
end.
else do:
  assign
        road-tax-base-salecur    =  (if parcurroad-tax = ? then 0 else parcurroad-tax / parcurbase-rate * parcurbase-scale)
    excise-base-salecur      =  (if parcurexcise   = ? then 0 else parcurexcise   / parcurbase-rate * parcurbase-scale)
  .
end.
if varoutvprbcur = "rubl":u then do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * 1)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * 1) .
end.
else do:
  assign
        road-tax-rubl-salecur    = (if parcurroad-tax = ? then 0 else parcurroad-tax * parcurbase-rate / parcurbase-scale)
    excise-rubl-salecur      = (if parcurexcise   = ? then 0 else parcurexcise   * parcurbase-rate / parcurbase-scale) .
end.
assign
  varis-cons-parts-havecur =  no.
assign
  varfact-qntycur       = 0
  varcons-qntycur       = 0
  varprice-base-conscur = 0
  varprice-rubl-conscur = 0.
if cl_tt-clcparts.purch-code = 2 then do:
assign
  price-rubl-with-tax-lococur = cl_tt-clcparts.price-rubl
  price-base-with-tax-lococur = cl_tt-clcparts.price-base
.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprbocur
  )  .
  if cl_tt-clcparts.out-code = 'free-zone':U     or
     cl_tt-clcparts.out-code = 'out-zone':U   or
     cl_tt-clcparts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-sltocur = yes.
  end.
  else do:
    find first in-vatp_doc-attrocur no-lock
      where in-vatp_doc-attrocur.doc-code  = cl_tt-clcparts.out-code
        and in-vatp_doc-attrocur.attr-code = 'envd':U
      no-error .
    if not available in-vatp_doc-attrocur then do:
      assign
        in-vatp-have-vat-sltocur = yes.
    end.
    else do:
         in-vatp-have-vat-sltocur = no.
    end.
  end.
  assign
   price-cli-with-tax-lococur = cl_tt-clcparts.price-cli
   cli-base-rateocur          = cl_tt-clcparts.cli-base-rate.
  ASSIGN   road-tax-base-lococur  = (if cl_tt-clcparts.road-tax-base  = ? then 0 else cl_tt-clcparts.road-tax-base)
           road-tax-rubl-lococur  = (if cl_tt-clcparts.road-tax-rubl  = ? then 0 else cl_tt-clcparts.road-tax-rubl).
  ASSIGN  transport-base-lococur = (if cl_tt-clcparts.transport-base = ? then 0 else cl_tt-clcparts.transport-base)
          transport-rubl-lococur = (if cl_tt-clcparts.transport-rubl = ? then 0 else cl_tt-clcparts.transport-rubl)
          other-base-lococur     = (if cl_tt-clcparts.other-base     = ? then 0 else cl_tt-clcparts.other-base)
          other-rubl-lococur     = (if cl_tt-clcparts.other-rubl     = ? then 0 else cl_tt-clcparts.other-rubl)
          vat-pc-lococur         = (if cl_tt-clcparts.vat-pc         = ? then 0 else cl_tt-clcparts.vat-pc)
          slt-pc-lococur         = (if cl_tt-clcparts.slt-pc         = ? then 0 else cl_tt-clcparts.slt-pc).
          ASSIGN   slt-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-base-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-base-with-tax-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
    ASSIGN   slt-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur)))                           * slt-pc-lococur / (100 + slt-pc-lococur))                        vat-rubl-lococur    = (if in-vatp-have-vat-sltocur = no then 0 else (price-rubl-with-tax-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))) * (1 - slt-pc-lococur / (100 + slt-pc-lococur)) * vat-pc-lococur / (100 + vat-pc-lococur)).
  assign
    exch-rate-cli-lococur = (cl_tt-clcparts.price-rubl - transport-rubl-lococur - other-rubl-lococur - road-tax-rubl-lococur - (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-rubl-lococur else 0) - (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-rubl-lococur else 0)) / cl_tt-clcparts.price-cli .
  assign
    slt-cli-lococur        = slt-rubl-lococur       / exch-rate-cli-lococur
    vat-cli-lococur        = vat-rubl-lococur       / exch-rate-cli-lococur
    road-tax-cli-lococur   = road-tax-rubl-lococur  / exch-rate-cli-lococur
    transport-cli-lococur  = 0
    other-cli-lococur      = 0
  .
ASSIGN
          price-base-without-tax-lococur = price-base-with-tax-lococur - vat-base-lococur - slt-base-lococur - ((if road-tax-base-lococur  = ? then 0 else road-tax-base-lococur) + (if transport-base-lococur = ? then 0 else transport-base-lococur) + (if other-base-lococur = ? then 0 else other-base-lococur))
    price-rubl-without-tax-lococur = price-rubl-with-tax-lococur - vat-rubl-lococur - slt-rubl-lococur - ((if road-tax-rubl-lococur  = ? then 0 else road-tax-rubl-lococur) + (if transport-rubl-lococur = ? then 0 else transport-rubl-lococur) + (if other-rubl-lococur = ? then 0 else other-rubl-lococur))
.
  assign
    varprice-base-conscur    = varprice-base-conscur + (price-base-with-tax-lococur - (if road-tax-base-lococur = ? then 0 else road-tax-base-lococur))* cl_tt-clcparts.fact-qnty
    varprice-rubl-conscur    = varprice-rubl-conscur + (price-rubl-with-tax-lococur - (if road-tax-rubl-lococur = ? then 0 else road-tax-rubl-lococur))* cl_tt-clcparts.fact-qnty
    varis-cons-parts-havecur = yes
    varcons-qntycur          = varcons-qntycur + cl_tt-clcparts.fact-qnty.
end.
assign
  varfact-qntycur = cl_tt-clcparts.fact-qnty.
assign
  varprice-base-conscur = varprice-base-conscur / varcons-qntycur
  varprice-rubl-conscur = varprice-rubl-conscur / varcons-qntycur.
if varprice-base-conscur = ? then do:
  assign
    varprice-base-conscur = 0.
end.
if varprice-rubl-conscur = ? then do:
  assign
    varprice-rubl-conscur = 0.
end.
assign
    slt-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-base-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-base-salecur            = parcurdiscnt-base
  price-base-with-tax-salecur    = (parcurprice-base - parcurdiscnt-base)
    slt-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc)
  vat-rubl-buyercur              = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc)
  discnt-rubl-salecur            = parcurdiscnt-rubl
  price-rubl-with-tax-salecur    = (parcurprice-rubl - parcurdiscnt-rubl)
  .
if parcurdoc-type = 'инв':U then do:
  assign
    varfact-qntycur = parcurdoc-qnty.
end.
else do:
  assign
    varfact-qntycur = parcurfact-qnty.
end.
if varis-cons-parts-havecur = no then do:
  assign
        vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc)
        vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc).
end.
else do:
  if parcurdoc-type = 'инв':U then do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurdoc-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * parcurdoc-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
  else do:
    assign
            vat-base-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-base-salecur - varprice-base-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-base - parcurdiscnt-base) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-base - parcurdiscnt-base                - road-tax-base-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-base-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
            vat-rubl-salecur               = (if out-vatp-have-vat-sltcur = no then 0 else (((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - road-tax-rubl-salecur - varprice-rubl-conscur) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * parcurfact-qnty * varcons-qntycur / varfact-qntycur + ((parcurprice-rubl - parcurdiscnt-rubl) - (if out-vatp-have-vat-sltcur = no then 0 else parcurprice-rubl - parcurdiscnt-rubl                - road-tax-rubl-salecur) * parcurSLT-pc / (100 + parcurSLT-pc) - varprice-rubl-conscur) * parcurvat-pc / (100 + parcurvat-pc) * parcurfact-qnty * (varfact-qntycur - varcons-qntycur) / varfact-qntycur) / varfact-qntycur)
     .
  end.
end.
assign
price-base-without-tax-salecur = price-base-with-tax-salecur - vat-base-salecur - slt-base-salecur - road-tax-base-salecur
price-rubl-without-tax-salecur = price-rubl-with-tax-salecur - vat-rubl-salecur - slt-rubl-salecur - road-tax-rubl-salecur.
end.
create bf_tt-allsum.
assign
  bf_tt-allsum.sum-type = 'основная_сумма':U.
assign
  bf_tt-allsum.fact-qnty          =  cl_tt-clcparts.fact-qnty
  bf_tt-allsum.cli-qnty           =  cl_tt-clcparts.cli-qnty
  bf_tt-allsum.sum-dsc-base-doc   =  (if price-base-with-tax-salecl  = ? then 0 else price-base-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-doc   =  (if price-rubl-with-tax-salecl  = ? then 0 else price-rubl-with-tax-salecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-doc       =  (if discnt-base-salecl          = ? then 0 else discnt-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-doc       =  (if discnt-rubl-salecl          = ? then 0 else discnt-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-doc       =  (if slt-base-salecl             = ? then 0 else slt-base-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-doc       =  (if slt-rubl-salecl             = ? then 0 else slt-rubl-salecl             * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-doc =  (if vat-base-buyercl            = ? then 0 else vat-base-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-doc =  (if vat-rubl-buyercl            = ? then 0 else vat-rubl-buyercl            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-doc  =  (if road-tax-base-salecl        = ? then 0 else road-tax-base-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-doc  =  (if road-tax-rubl-salecl        = ? then 0 else road-tax-rubl-salecl        * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-doc    =  (if excise-base-salecl          = ? then 0 else excise-base-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-doc    =  (if excise-rubl-salecl          = ? then 0 else excise-rubl-salecl          * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-base-cur   =  (if price-base-with-tax-salecur = ? then 0 else price-base-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-cur   =  (if price-rubl-with-tax-salecur = ? then 0 else price-rubl-with-tax-salecur * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-cur       =  (if discnt-base-salecur         = ? then 0 else discnt-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-rubl-cur       =  (if discnt-rubl-salecur         = ? then 0 else discnt-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-cur       =  (if slt-base-salecur            = ? then 0 else slt-base-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-cur       =  (if slt-rubl-salecur            = ? then 0 else slt-rubl-salecur            * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-base-buyer-cur =  (if vat-base-buyercur           = ? then 0 else vat-base-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-buyer-cur =  (if vat-rubl-buyercur           = ? then 0 else vat-rubl-buyercur           * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-cur  =  (if road-tax-base-salecur       = ? then 0 else road-tax-base-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-cur  =  (if road-tax-rubl-salecur       = ? then 0 else road-tax-rubl-salecur       * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-cur    =  (if excise-base-salecur         = ? then 0 else excise-base-salecur         * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-rubl-cur    =  (if excise-rubl-salecur         = ? then 0 else excise-rubl-salecur         * cl_tt-clcparts.fact-qnty)
  .
if cl_tt-clcparts.purch-code = integer('2':U) then do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl  - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl  - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcons-vat-pc / (100 + parcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur - (cl_tt-clcparts.price-base - cl_tt-clcparts.road-tax-base)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur - (cl_tt-clcparts.price-rubl - cl_tt-clcparts.road-tax-rubl)) * parcurcons-vat-pc / (100 + parcurcons-vat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
else do:
  assign
    bf_tt-allsum.vat-base-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecl  - road-tax-base-salecl  - slt-base-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-doc = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecl  - road-tax-rubl-salecl  - slt-rubl-salecl ) * parvat-pc / (100 + parvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-base-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-base-with-tax-salecur - road-tax-base-salecur - slt-base-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    bf_tt-allsum.vat-rubl-cur = (if out-vatp-have-vat-sltcur <> yes then 0 else (price-rubl-with-tax-salecur - road-tax-rubl-salecur - slt-rubl-salecur) * parcurvat-pc / (100 + parcurvat-pc) * cl_tt-clcparts.fact-qnty)
    .
end.
if bf_tt-allsum.vat-base-doc = ? then bf_tt-allsum.vat-base-doc = 0.
if bf_tt-allsum.vat-rubl-doc = ? then bf_tt-allsum.vat-rubl-doc = 0.
assign
  bf_tt-allsum.sum-dsc-base-acc     = (if price-base-with-tax-loccl    = ? then 0 else price-base-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-rubl-acc     = (if price-rubl-with-tax-loccl    = ? then 0 else price-rubl-with-tax-loccl    * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.sum-dsc-cli-acc      = (if (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl = ? then 0
                                        else
                                          (price-cli-with-tax-loccl +
                                           road-tax-cli-loccl       +
                                           (if cl_tt-clcparts.vat-type <> 'в т. ч.':U then vat-cli-loccl else 0) +
                                           (if cl_tt-clcparts.slt-type <> 'в т. ч.':U then slt-cli-loccl else 0)
                                           ) / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.dsc-base-acc         = 0
  bf_tt-allsum.dsc-rubl-acc         = 0
  bf_tt-allsum.dsc-cli-acc          = 0
  bf_tt-allsum.vat-base-acc         = (if vat-base-loccl      = ? then 0 else vat-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-rubl-acc         = (if vat-rubl-loccl      = ? then 0 else vat-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.vat-cli-acc          = (if vat-cli-loccl / cli-base-ratecl      = ? then 0 else vat-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-base-acc         = (if slt-base-loccl      = ? then 0 else slt-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-rubl-acc         = (if slt-rubl-loccl      = ? then 0 else slt-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.slt-cli-acc          = (if slt-cli-loccl / cli-base-ratecl      = ? then 0 else slt-cli-loccl / cli-base-ratecl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-base-acc    = (if road-tax-base-loccl = ? then 0 else road-tax-base-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-rubl-acc    = (if road-tax-rubl-loccl = ? then 0 else road-tax-rubl-loccl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.road-tax-cli-acc     = (if road-tax-cli-loccl / cli-base-ratecl = ? then 0 else road-tax-cli-loccl / cli-base-ratecl * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.excise-base-acc      = 0
  bf_tt-allsum.excise-rubl-acc      = 0
  bf_tt-allsum.excise-cli-acc       = 0
  bf_tt-allsum.transport-base-acc   = (if transport-base-loccl   = ? then 0 else transport-base-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-rubl-acc   = (if transport-rubl-loccl   = ? then 0 else transport-rubl-loccl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.transport-cli-acc    = (if transport-cli-loccl / cli-base-ratecl   = ? then 0 else transport-cli-loccl / cli-base-ratecl  * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-base-acc       = (if other-base-loccl       = ? then 0 else other-base-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-rubl-acc       = (if other-rubl-loccl       = ? then 0 else other-rubl-loccl      * cl_tt-clcparts.fact-qnty)
  bf_tt-allsum.other-cli-acc        = (if other-cli-loccl / cli-base-ratecl       = ? then 0 else other-cli-loccl     / cli-base-ratecl  * cl_tt-clcparts.fact-qnty).
create bfs_tt-allsum.
assign
  bfs_tt-allsum.sum-type = 'основная_сумма_со_знаком':U.
if pardoc-type = 'инв':U or
   pardoc-type = 'при':U    or
   pardoc-type = 'возврат':U    then do:
   buffer-copy bf_tt-allsum except bf_tt-allsum.sum-type to bfs_tt-allsum.
end.
else do:
  assign
    bfs_tt-allsum.fact-qnty           =  - bf_tt-allsum.fact-qnty
    bfs_tt-allsum.cli-qnty            =  - bf_tt-allsum.cli-qnty
    bfs_tt-allsum.sum-dsc-base-doc    =  - bf_tt-allsum.sum-dsc-base-doc
    bfs_tt-allsum.sum-dsc-rubl-doc    =  - bf_tt-allsum.sum-dsc-rubl-doc
    bfs_tt-allsum.dsc-base-doc        =  - bf_tt-allsum.dsc-base-doc
    bfs_tt-allsum.dsc-rubl-doc        =  - bf_tt-allsum.dsc-rubl-doc
    bfs_tt-allsum.vat-base-doc        =  - bf_tt-allsum.vat-base-doc
    bfs_tt-allsum.vat-rubl-doc        =  - bf_tt-allsum.vat-rubl-doc
    bfs_tt-allsum.vat-base-buyer-doc  =  - bf_tt-allsum.vat-base-buyer-doc
    bfs_tt-allsum.vat-rubl-buyer-doc  =  - bf_tt-allsum.vat-rubl-buyer-doc
    bfs_tt-allsum.slt-base-doc        =  - bf_tt-allsum.slt-base-doc
    bfs_tt-allsum.slt-rubl-doc        =  - bf_tt-allsum.slt-rubl-doc
    bfs_tt-allsum.road-tax-base-doc   =  - bf_tt-allsum.road-tax-base-doc
    bfs_tt-allsum.road-tax-rubl-doc   =  - bf_tt-allsum.road-tax-rubl-doc
    bfs_tt-allsum.excise-base-doc     =  - bf_tt-allsum.excise-base-doc
    bfs_tt-allsum.excise-rubl-doc     =  - bf_tt-allsum.excise-rubl-doc
    bfs_tt-allsum.sum-dsc-base-cur    =  - bf_tt-allsum.sum-dsc-base-cur
    bfs_tt-allsum.sum-dsc-rubl-cur    =  - bf_tt-allsum.sum-dsc-rubl-cur
    bfs_tt-allsum.dsc-base-cur        =  - bf_tt-allsum.dsc-base-cur
    bfs_tt-allsum.dsc-rubl-cur        =  - bf_tt-allsum.dsc-rubl-cur
    bfs_tt-allsum.vat-base-cur        =  - bf_tt-allsum.vat-base-cur
    bfs_tt-allsum.vat-rubl-cur        =  - bf_tt-allsum.vat-rubl-cur
    bfs_tt-allsum.vat-base-buyer-cur  =  - bf_tt-allsum.vat-base-buyer-cur
    bfs_tt-allsum.vat-rubl-buyer-cur  =  - bf_tt-allsum.vat-rubl-buyer-cur
    bfs_tt-allsum.slt-base-cur        =  - bf_tt-allsum.slt-base-cur
    bfs_tt-allsum.slt-rubl-cur        =  - bf_tt-allsum.slt-rubl-cur
    bfs_tt-allsum.road-tax-base-cur   =  - bf_tt-allsum.road-tax-base-cur
    bfs_tt-allsum.road-tax-rubl-cur   =  - bf_tt-allsum.road-tax-rubl-cur
    bfs_tt-allsum.excise-base-cur     =  - bf_tt-allsum.excise-base-cur
    bfs_tt-allsum.excise-rubl-cur     =  - bf_tt-allsum.excise-rubl-cur
    bfs_tt-allsum.sum-dsc-base-acc    =  - bf_tt-allsum.sum-dsc-base-acc
    bfs_tt-allsum.sum-dsc-rubl-acc    =  - bf_tt-allsum.sum-dsc-rubl-acc
    bfs_tt-allsum.sum-dsc-cli-acc     =  - bf_tt-allsum.sum-dsc-cli-acc
    bfs_tt-allsum.dsc-base-acc        =  - bf_tt-allsum.dsc-base-acc
    bfs_tt-allsum.dsc-rubl-acc        =  - bf_tt-allsum.dsc-rubl-acc
    bfs_tt-allsum.dsc-cli-acc         =  - bf_tt-allsum.dsc-cli-acc
    bfs_tt-allsum.vat-base-acc        =  - bf_tt-allsum.vat-base-acc
    bfs_tt-allsum.vat-rubl-acc        =  - bf_tt-allsum.vat-rubl-acc
    bfs_tt-allsum.vat-cli-acc         =  - bf_tt-allsum.vat-cli-acc
    bfs_tt-allsum.slt-base-acc        =  - bf_tt-allsum.slt-base-acc
    bfs_tt-allsum.slt-rubl-acc        =  - bf_tt-allsum.slt-rubl-acc
    bfs_tt-allsum.slt-cli-acc         =  - bf_tt-allsum.slt-cli-acc
    bfs_tt-allsum.road-tax-base-acc   =  - bf_tt-allsum.road-tax-base-acc
    bfs_tt-allsum.road-tax-rubl-acc   =  - bf_tt-allsum.road-tax-rubl-acc
    bfs_tt-allsum.road-tax-cli-acc    =  - bf_tt-allsum.road-tax-cli-acc
    bfs_tt-allsum.excise-base-acc     =  - bf_tt-allsum.excise-base-acc
    bfs_tt-allsum.excise-rubl-acc     =  - bf_tt-allsum.excise-rubl-acc
    bfs_tt-allsum.excise-cli-acc      =  - bf_tt-allsum.excise-cli-acc
    bfs_tt-allsum.transport-base-acc  =  - bf_tt-allsum.transport-base-acc
    bfs_tt-allsum.transport-rubl-acc  =  - bf_tt-allsum.transport-rubl-acc
    bfs_tt-allsum.transport-cli-acc   =  - bf_tt-allsum.transport-cli-acc
    bfs_tt-allsum.other-base-acc      =  - bf_tt-allsum.other-base-acc
    bfs_tt-allsum.other-rubl-acc      =  - bf_tt-allsum.other-rubl-acc
    bfs_tt-allsum.other-cli-acc       =  - bf_tt-allsum.other-cli-acc.
end.
create bfpc_tt-allsum.
create bfspc_tt-allsum.
case cl_tt-clcparts.purch-code :
when 1           then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_выкупу':U
    bfspc_tt-allsum.sum-type = 'сумма_по_выкупу_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 4    then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_старой_консигнации':U
    bfspc_tt-allsum.sum-type = 'сумма_по_старой_консигнации_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 3 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_ответственному_хранению':U
    bfspc_tt-allsum.sum-type = 'сумма_по_ответственному_хранению_со_знаком':U.
  buffer-copy bf_tt-allsum  except bf_tt-allsum.sum-type  to bfpc_tt-allsum.
  buffer-copy bfs_tt-allsum except bfs_tt-allsum.sum-type to bfspc_tt-allsum.
end.
when 2 then do:
  assign
    bfpc_tt-allsum.sum-type  = 'сумма_по_консигнации_выгода':U
    bfspc_tt-allsum.sum-type = 'сумма_по_консигнации_выгода_со_знаком':U.
  assign
    bfpc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfpc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfpc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-doc    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-doc    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-doc        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-doc        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-doc        = bf_tt-allsum.vat-base-doc
    bfpc_tt-allsum.vat-rubl-doc        = bf_tt-allsum.vat-rubl-doc
    bfpc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-buyer-doc  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-buyer-doc  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-doc        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-doc        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-doc   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-doc   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-doc
    bfpc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-doc
    bfpc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-cur    - bf_tt-allsum.sum-dsc-base-acc
    bfpc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-cur    - bf_tt-allsum.sum-dsc-rubl-acc
    bfpc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-cur        - bf_tt-allsum.dsc-base-acc
    bfpc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-cur        - bf_tt-allsum.dsc-rubl-acc
    bfpc_tt-allsum.vat-base-cur        = bf_tt-allsum.vat-base-cur
    bfpc_tt-allsum.vat-rubl-cur        = bf_tt-allsum.vat-rubl-cur
    bfpc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-buyer-cur  - bf_tt-allsum.vat-base-acc
    bfpc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-buyer-cur  - bf_tt-allsum.vat-rubl-acc
    bfpc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-cur        - bf_tt-allsum.slt-base-acc
    bfpc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-cur        - bf_tt-allsum.slt-rubl-acc
    bfpc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-cur   - bf_tt-allsum.road-tax-base-acc
    bfpc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-cur   - bf_tt-allsum.road-tax-rubl-acc
    bfpc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-cur
    bfpc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-cur
    bfpc_tt-allsum.sum-dsc-base-acc    = 0
    bfpc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfpc_tt-allsum.sum-dsc-cli-acc     = 0
    bfpc_tt-allsum.dsc-base-acc        = 0
    bfpc_tt-allsum.dsc-rubl-acc        = 0
    bfpc_tt-allsum.dsc-cli-acc         = 0
    bfpc_tt-allsum.vat-base-acc        = 0
    bfpc_tt-allsum.vat-rubl-acc        = 0
    bfpc_tt-allsum.vat-cli-acc         = 0
    bfpc_tt-allsum.slt-base-acc        = 0
    bfpc_tt-allsum.slt-rubl-acc        = 0
    bfpc_tt-allsum.slt-cli-acc         = 0
    bfpc_tt-allsum.road-tax-base-acc   = 0
    bfpc_tt-allsum.road-tax-rubl-acc   = 0
    bfpc_tt-allsum.road-tax-cli-acc    = 0
    bfpc_tt-allsum.excise-base-acc     = 0
    bfpc_tt-allsum.excise-rubl-acc     = 0
    bfpc_tt-allsum.excise-cli-acc      = 0
    bfpc_tt-allsum.transport-base-acc  = 0
    bfpc_tt-allsum.transport-rubl-acc  = 0
    bfpc_tt-allsum.transport-cli-acc   = 0
    bfpc_tt-allsum.other-base-acc      = 0
    bfpc_tt-allsum.other-rubl-acc      = 0
    bfpc_tt-allsum.other-cli-acc       = 0
    .
  assign
    bfspc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfspc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfspc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-doc    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-doc    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-doc        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-doc        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-doc        = bfs_tt-allsum.vat-base-doc
    bfspc_tt-allsum.vat-rubl-doc        = bfs_tt-allsum.vat-rubl-doc
    bfspc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-buyer-doc  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-buyer-doc  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-doc        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-doc        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-doc   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-doc   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-doc
    bfspc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-doc
    bfspc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-cur    - bfs_tt-allsum.sum-dsc-base-acc
    bfspc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-cur    - bfs_tt-allsum.sum-dsc-rubl-acc
    bfspc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-cur        - bfs_tt-allsum.dsc-base-acc
    bfspc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-cur        - bfs_tt-allsum.dsc-rubl-acc
    bfspc_tt-allsum.vat-base-cur        = bfs_tt-allsum.vat-base-cur
    bfspc_tt-allsum.vat-rubl-cur        = bfs_tt-allsum.vat-rubl-cur
    bfspc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-buyer-cur  - bfs_tt-allsum.vat-base-acc
    bfspc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-buyer-cur  - bfs_tt-allsum.vat-rubl-acc
    bfspc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-cur        - bfs_tt-allsum.slt-base-acc
    bfspc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-cur        - bfs_tt-allsum.slt-rubl-acc
    bfspc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-cur   - bfs_tt-allsum.road-tax-base-acc
    bfspc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-cur   - bfs_tt-allsum.road-tax-rubl-acc
    bfspc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-cur
    bfspc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-cur
    bfspc_tt-allsum.sum-dsc-base-acc    = 0
    bfspc_tt-allsum.sum-dsc-rubl-acc    = 0
    bfspc_tt-allsum.sum-dsc-cli-acc     = 0
    bfspc_tt-allsum.dsc-base-acc        = 0
    bfspc_tt-allsum.dsc-rubl-acc        = 0
    bfspc_tt-allsum.dsc-cli-acc         = 0
    bfspc_tt-allsum.vat-base-acc        = 0
    bfspc_tt-allsum.vat-rubl-acc        = 0
    bfspc_tt-allsum.vat-cli-acc         = 0
    bfspc_tt-allsum.slt-base-acc        = 0
    bfspc_tt-allsum.slt-rubl-acc        = 0
    bfspc_tt-allsum.slt-cli-acc         = 0
    bfspc_tt-allsum.road-tax-base-acc   = 0
    bfspc_tt-allsum.road-tax-rubl-acc   = 0
    bfspc_tt-allsum.road-tax-cli-acc    = 0
    bfspc_tt-allsum.excise-base-acc     = 0
    bfspc_tt-allsum.excise-rubl-acc     = 0
    bfspc_tt-allsum.excise-cli-acc      = 0
    bfspc_tt-allsum.transport-base-acc  = 0
    bfspc_tt-allsum.transport-rubl-acc  = 0
    bfspc_tt-allsum.transport-cli-acc   = 0
    bfspc_tt-allsum.other-base-acc      = 0
    bfspc_tt-allsum.other-rubl-acc      = 0
    bfspc_tt-allsum.other-cli-acc       = 0
    .
  create bfacc_tt-allsum.
  assign
    bfacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка':U.
  create bfsacc_tt-allsum.
  assign
    bfsacc_tt-allsum.sum-type = 'сумма_по_консигнации_закупка_со_знаком':U.
  assign
    bfacc_tt-allsum.fact-qnty           = bf_tt-allsum.fact-qnty
    bfacc_tt-allsum.cli-qnty            = bf_tt-allsum.cli-qnty
    bfacc_tt-allsum.sum-dsc-base-doc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-doc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-doc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-doc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-doc        = 0
    bfacc_tt-allsum.vat-rubl-doc        = 0
    bfacc_tt-allsum.vat-base-buyer-doc  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-doc  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-doc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-doc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-doc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-doc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-doc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-doc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-cur    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-cur    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.dsc-base-cur        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-cur        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.vat-base-cur        = 0
    bfacc_tt-allsum.vat-rubl-cur        = 0
    bfacc_tt-allsum.vat-base-buyer-cur  = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-buyer-cur  = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.slt-base-cur        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-cur        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.road-tax-base-cur   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-cur   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.excise-base-cur     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-cur     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.sum-dsc-base-acc    = bf_tt-allsum.sum-dsc-base-acc
    bfacc_tt-allsum.sum-dsc-rubl-acc    = bf_tt-allsum.sum-dsc-rubl-acc
    bfacc_tt-allsum.sum-dsc-cli-acc     = bf_tt-allsum.sum-dsc-cli-acc
    bfacc_tt-allsum.dsc-base-acc        = bf_tt-allsum.dsc-base-acc
    bfacc_tt-allsum.dsc-rubl-acc        = bf_tt-allsum.dsc-rubl-acc
    bfacc_tt-allsum.dsc-cli-acc         = bf_tt-allsum.dsc-cli-acc
    bfacc_tt-allsum.vat-base-acc        = bf_tt-allsum.vat-base-acc
    bfacc_tt-allsum.vat-rubl-acc        = bf_tt-allsum.vat-rubl-acc
    bfacc_tt-allsum.vat-cli-acc         = bf_tt-allsum.vat-cli-acc
    bfacc_tt-allsum.slt-base-acc        = bf_tt-allsum.slt-base-acc
    bfacc_tt-allsum.slt-rubl-acc        = bf_tt-allsum.slt-rubl-acc
    bfacc_tt-allsum.slt-cli-acc         = bf_tt-allsum.slt-cli-acc
    bfacc_tt-allsum.excise-base-acc     = bf_tt-allsum.excise-base-acc
    bfacc_tt-allsum.excise-rubl-acc     = bf_tt-allsum.excise-rubl-acc
    bfacc_tt-allsum.excise-cli-acc      = bf_tt-allsum.excise-cli-acc
    bfacc_tt-allsum.road-tax-base-acc   = bf_tt-allsum.road-tax-base-acc
    bfacc_tt-allsum.road-tax-rubl-acc   = bf_tt-allsum.road-tax-rubl-acc
    bfacc_tt-allsum.road-tax-cli-acc    = bf_tt-allsum.road-tax-cli-acc
    bfacc_tt-allsum.transport-base-acc  = bf_tt-allsum.transport-base-acc
    bfacc_tt-allsum.transport-rubl-acc  = bf_tt-allsum.transport-rubl-acc
    bfacc_tt-allsum.transport-cli-acc   = bf_tt-allsum.transport-cli-acc
    bfacc_tt-allsum.other-base-acc      = bf_tt-allsum.other-base-acc
    bfacc_tt-allsum.other-rubl-acc      = bf_tt-allsum.other-rubl-acc
    bfacc_tt-allsum.other-cli-acc       = bf_tt-allsum.other-cli-acc
    .
  assign
    bfsacc_tt-allsum.fact-qnty           = bfs_tt-allsum.fact-qnty
    bfsacc_tt-allsum.cli-qnty            = bfs_tt-allsum.cli-qnty
    bfsacc_tt-allsum.sum-dsc-base-doc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-doc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-doc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-doc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-doc        = 0
    bfsacc_tt-allsum.vat-rubl-doc        = 0
    bfsacc_tt-allsum.vat-base-buyer-doc  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-doc  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-doc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-doc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-doc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-doc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-doc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-doc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-cur    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-cur    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.dsc-base-cur        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-cur        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.vat-base-cur        = 0
    bfsacc_tt-allsum.vat-rubl-cur        = 0
    bfsacc_tt-allsum.vat-base-buyer-cur  = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-buyer-cur  = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.slt-base-cur        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-cur        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.road-tax-base-cur   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-cur   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.excise-base-cur     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-cur     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.sum-dsc-base-acc    = bfs_tt-allsum.sum-dsc-base-acc
    bfsacc_tt-allsum.sum-dsc-rubl-acc    = bfs_tt-allsum.sum-dsc-rubl-acc
    bfsacc_tt-allsum.sum-dsc-cli-acc     = bfs_tt-allsum.sum-dsc-cli-acc
    bfsacc_tt-allsum.dsc-base-acc        = bfs_tt-allsum.dsc-base-acc
    bfsacc_tt-allsum.dsc-rubl-acc        = bfs_tt-allsum.dsc-rubl-acc
    bfsacc_tt-allsum.dsc-cli-acc         = bfs_tt-allsum.dsc-cli-acc
    bfsacc_tt-allsum.vat-base-acc        = bfs_tt-allsum.vat-base-acc
    bfsacc_tt-allsum.vat-rubl-acc        = bfs_tt-allsum.vat-rubl-acc
    bfsacc_tt-allsum.vat-cli-acc         = bfs_tt-allsum.vat-cli-acc
    bfsacc_tt-allsum.slt-base-acc        = bfs_tt-allsum.slt-base-acc
    bfsacc_tt-allsum.slt-rubl-acc        = bfs_tt-allsum.slt-rubl-acc
    bfsacc_tt-allsum.slt-cli-acc         = bfs_tt-allsum.slt-cli-acc
    bfsacc_tt-allsum.excise-base-acc     = bfs_tt-allsum.excise-base-acc
    bfsacc_tt-allsum.excise-rubl-acc     = bfs_tt-allsum.excise-rubl-acc
    bfsacc_tt-allsum.excise-cli-acc      = bfs_tt-allsum.excise-cli-acc
    bfsacc_tt-allsum.road-tax-base-acc   = bfs_tt-allsum.road-tax-base-acc
    bfsacc_tt-allsum.road-tax-rubl-acc   = bfs_tt-allsum.road-tax-rubl-acc
    bfsacc_tt-allsum.road-tax-cli-acc    = bfs_tt-allsum.road-tax-cli-acc
    bfsacc_tt-allsum.transport-base-acc  = bfs_tt-allsum.transport-base-acc
    bfsacc_tt-allsum.transport-rubl-acc  = bfs_tt-allsum.transport-rubl-acc
    bfsacc_tt-allsum.transport-cli-acc   = bfs_tt-allsum.transport-cli-acc
    bfsacc_tt-allsum.other-base-acc      = bfs_tt-allsum.other-base-acc
    bfsacc_tt-allsum.other-rubl-acc      = bfs_tt-allsum.other-rubl-acc
    bfsacc_tt-allsum.other-cli-acc       = bfs_tt-allsum.other-cli-acc
    .
end.
otherwise do:
  return error substitute ("Неизвестный тип приобретения &1 по партии с кодом &2 по документу &3, порожденную документом &4 по товару &5 &6 &7.",
                           cl_tt-clcparts.purch-code,
                           cl_tt-clcparts.part-code,
                           cl_tt-clcparts.out-code,
                           cl_tt-clcparts.in-code,
                           cl_tt-clcparts.artic,
                           cl_tt-clcparts.prod-type,
                           cl_tt-clcparts.prod-code).
end.
end case.
end.
end procedure.
procedure clcprtsl_calc-line :
define input  parameter parrec-line as recid no-undo.
define variable v-tax-date         as   date                     no-undo.
define variable v-vat-pc           like ub.doc-line.vat-pc       no-undo.
define variable varr-b             as   character                no-undo.
define variable varr-btype         as   character                no-undo.
define variable varcur-base        like ub.gds-dtl.price-base    no-undo.
define variable varcur-road-tax    like ub.doc-line.road-tax     no-undo.
define variable varcur-excise      like ub.doc-line.excise       no-undo.
define variable varcur-vat-pc      like ub.doc-line.vat-pc       no-undo.
define variable varcur-cons-vat-pc like ub.doc-line.cons-vat-pc  no-undo.
define variable varcur-slt-pc      like ub.doc-line.slt-pc       no-undo.
define variable varcur-fact-qnty   like ub.gds-dtl.fact-qnty     no-undo.
define variable varb-code          like ub.bar-code.b-code       no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
define variable varlastcur-base        like ub.gds-dtl.price-base no-undo.
define variable varlastcur-road-tax    like ub.gds-dtl.price-base no-undo.
define variable varlastcur-excise      like ub.gds-dtl.price-base     no-undo.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable v-varsum           as decimal                  no-undo.
define variable varprice-salef as decimal   no-undo .
define buffer bf_trn-doc             for ub.trn-doc.
define buffer bf_doc-line            for ub.doc-line.
define buffer bf_gds-dtl             for ub.gds-dtl.
define buffer bf_goods               for ub.goods.
define buffer bf_parts               for ub.parts.
define buffer bf_sysconf             for ub.sysconf.
define buffer bf_tt-allsum-line      for tt-allsum-line.
define buffer bfs_tt-allsum-line     for tt-allsum-line.
define buffer bfo_tt-allsum-line     for tt-allsum-line.
define buffer bfos_tt-allsum-line    for tt-allsum-line.
define buffer buf_parts        for ub.parts.
v-calcbypart = no.
do on error undo, return error return-value :
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
  find first bf_doc-line where recid (bf_doc-line) = parrec-line no-lock.
  find first bf_trn-doc where bf_trn-doc.doc-code = bf_doc-line.doc-code no-lock.
  find first bf_goods where bf_goods.artic     = bf_doc-line.artic     and
                            bf_goods.prod-type = bf_doc-line.prod-type and
                            bf_goods.prod-code = bf_doc-line.prod-code no-lock.
  if bf_trn-doc.fact-date <> ?        then do:
    assign v-tax-date = bf_trn-doc.fact-date.
  end.
  else do:
    assign v-tax-date = ?.
  end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  v-tax-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output v-vat-pc
  ) no-error .
  if error-status :error
  or v-vat-pc = ? then do:
     return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
  end.
  if bf_goods.gds-type = 'у':U or
     bf_trn-doc.status_ = 'запрос':U then do:
    for each bf_tt-allsum-line
    on error undo, return error return-value
     :
      delete bf_tt-allsum-line.
    end.
    create bf_tt-allsum-line.
    assign
     bf_tt-allsum-line.sum-type = 'основная_сумма':U.
    for each bf_gds-dtl where bf_gds-dtl.doc-code  = bf_doc-line.doc-code  and
                              bf_gds-dtl.artic     = bf_doc-line.artic     and
                              bf_gds-dtl.prod-type = bf_doc-line.prod-type and
                              bf_gds-dtl.prod-code = bf_doc-line.prod-code no-lock on error undo, return error return-value :
      assign
        bf_tt-allsum-line.fact-qnty            =  bf_tt-allsum-line.fact-qnty        + bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-doc     =  bf_tt-allsum-line.sum-dsc-base-doc + (bf_gds-dtl.price-base - bf_gds-dtl.discnt-base) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-doc     =  bf_tt-allsum-line.sum-dsc-rubl-doc + (bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-base-doc         =  bf_tt-allsum-line.dsc-base-doc     + bf_gds-dtl.discnt-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.dsc-rubl-doc         =  bf_tt-allsum-line.dsc-rubl-doc     + bf_gds-dtl.discnt-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-cur     =  bf_tt-allsum-line.sum-dsc-base-cur + (if varr-b = "base" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base / bf_trn-doc.exch-rate * bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-cur     =  bf_tt-allsum-line.sum-dsc-rubl-cur + (if varr-b = "rubl" then bf_gds-dtl.cur-base else bf_gds-dtl.cur-base * bf_trn-doc.exch-rate / bf_trn-doc.exch-scale) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-base-acc     =  bf_tt-allsum-line.sum-dsc-base-acc + bf_doc-line.price-base * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-rubl-acc     =  bf_tt-allsum-line.sum-dsc-rubl-acc + bf_doc-line.price-rubl * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.sum-dsc-cli-acc      =  ?
        bf_tt-allsum-line.vat-base-acc         =  bf_tt-allsum-line.vat-base-acc     + bf_doc-line.price-base * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-rubl-acc         =  bf_tt-allsum-line.vat-rubl-acc     + bf_doc-line.price-rubl * v-vat-pc / (100 + v-vat-pc) * bf_gds-dtl.fact-qnty
        bf_tt-allsum-line.vat-cli-acc          =  ?
        .
    end.
    assign
      bf_tt-allsum-line.cli-qnty             =  ?
      bf_tt-allsum-line.slt-base-doc         =  bf_tt-allsum-line.sum-dsc-base-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-doc         =  bf_tt-allsum-line.sum-dsc-rubl-doc * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-base-doc - bf_tt-allsum-line.slt-base-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-doc   =  (bf_tt-allsum-line.sum-dsc-rubl-doc - bf_tt-allsum-line.slt-rubl-doc) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-doc    =  0
      bf_tt-allsum-line.road-tax-rubl-doc    =  0
      bf_tt-allsum-line.excise-base-doc      =  0
      bf_tt-allsum-line.excise-rubl-doc      =  0
      bf_tt-allsum-line.vat-base-doc         =  bf_tt-allsum-line.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-doc         =  bf_tt-allsum-line.vat-rubl-buyer-doc
      bf_tt-allsum-line.dsc-base-cur         =  0
      bf_tt-allsum-line.dsc-rubl-cur         =  0
      bf_tt-allsum-line.slt-base-cur         =  bf_tt-allsum-line.sum-dsc-base-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.slt-rubl-cur         =  bf_tt-allsum-line.sum-dsc-rubl-cur * bf_doc-line.slt-pc / (100 + bf_doc-line.slt-pc)
      bf_tt-allsum-line.vat-base-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-base-cur - bf_tt-allsum-line.slt-base-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.vat-rubl-buyer-cur   =  (bf_tt-allsum-line.sum-dsc-rubl-cur - bf_tt-allsum-line.slt-rubl-cur) * bf_doc-line.vat-pc / (100 + bf_doc-line.vat-pc)
      bf_tt-allsum-line.road-tax-base-cur    =  0
      bf_tt-allsum-line.road-tax-rubl-cur    =  0
      bf_tt-allsum-line.excise-base-cur      =  0
      bf_tt-allsum-line.excise-rubl-cur      =  0
      bf_tt-allsum-line.vat-base-cur         =  bf_tt-allsum-line.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-cur         =  bf_tt-allsum-line.vat-rubl-buyer-cur
      bf_tt-allsum-line.dsc-base-acc         =  0
      bf_tt-allsum-line.dsc-rubl-acc         =  0
      bf_tt-allsum-line.dsc-cli-acc          =  0
      bf_tt-allsum-line.slt-base-acc         =  0
      bf_tt-allsum-line.slt-rubl-acc         =  0
      bf_tt-allsum-line.slt-cli-acc          =  0
      bf_tt-allsum-line.road-tax-base-acc    =  0
      bf_tt-allsum-line.road-tax-rubl-acc    =  0
      bf_tt-allsum-line.road-tax-cli-acc     =  0
      bf_tt-allsum-line.excise-base-acc      =  0
      bf_tt-allsum-line.excise-rubl-acc      =  0
      bf_tt-allsum-line.excise-cli-acc       =  0
      bf_tt-allsum-line.transport-base-acc   =  0
      bf_tt-allsum-line.transport-rubl-acc   =  0
      bf_tt-allsum-line.transport-cli-acc    =  0
      bf_tt-allsum-line.other-base-acc       =  0
      bf_tt-allsum-line.other-rubl-acc       =  0
      bf_tt-allsum-line.other-cli-acc        =  0
      .
    create bfs_tt-allsum-line.
    assign
    bfs_tt-allsum-line.sum-type = 'основная_сумма_со_знаком':U.
    if bf_trn-doc.doc-type = 'инв':U or
       bf_trn-doc.doc-type = 'при':U    or
       bf_trn-doc.doc-type = 'возврат':U    then do:
       buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfs_tt-allsum-line.
    end.
    else do:
      assign
        bfs_tt-allsum-line.fact-qnty           =  - bf_tt-allsum-line.fact-qnty
        bfs_tt-allsum-line.cli-qnty            =  - bf_tt-allsum-line.cli-qnty
        bfs_tt-allsum-line.sum-dsc-base-doc    =  - bf_tt-allsum-line.sum-dsc-base-doc
        bfs_tt-allsum-line.sum-dsc-rubl-doc    =  - bf_tt-allsum-line.sum-dsc-rubl-doc
        bfs_tt-allsum-line.dsc-base-doc        =  - bf_tt-allsum-line.dsc-base-doc
        bfs_tt-allsum-line.dsc-rubl-doc        =  - bf_tt-allsum-line.dsc-rubl-doc
        bfs_tt-allsum-line.vat-base-doc        =  - bf_tt-allsum-line.vat-base-doc
        bfs_tt-allsum-line.vat-rubl-doc        =  - bf_tt-allsum-line.vat-rubl-doc
        bfs_tt-allsum-line.vat-base-buyer-doc  =  - bf_tt-allsum-line.vat-base-buyer-doc
        bfs_tt-allsum-line.vat-rubl-buyer-doc  =  - bf_tt-allsum-line.vat-rubl-buyer-doc
        bfs_tt-allsum-line.slt-base-doc        =  - bf_tt-allsum-line.slt-base-doc
        bfs_tt-allsum-line.slt-rubl-doc        =  - bf_tt-allsum-line.slt-rubl-doc
        bfs_tt-allsum-line.road-tax-base-doc   =  - bf_tt-allsum-line.road-tax-base-doc
        bfs_tt-allsum-line.road-tax-rubl-doc   =  - bf_tt-allsum-line.road-tax-rubl-doc
        bfs_tt-allsum-line.excise-base-doc     =  - bf_tt-allsum-line.excise-base-doc
        bfs_tt-allsum-line.excise-rubl-doc     =  - bf_tt-allsum-line.excise-rubl-doc
        bfs_tt-allsum-line.sum-dsc-base-cur    =  - bf_tt-allsum-line.sum-dsc-base-cur
        bfs_tt-allsum-line.sum-dsc-rubl-cur    =  - bf_tt-allsum-line.sum-dsc-rubl-cur
        bfs_tt-allsum-line.dsc-base-cur        =  - bf_tt-allsum-line.dsc-base-cur
        bfs_tt-allsum-line.dsc-rubl-cur        =  - bf_tt-allsum-line.dsc-rubl-cur
        bfs_tt-allsum-line.vat-base-cur        =  - bf_tt-allsum-line.vat-base-cur
        bfs_tt-allsum-line.vat-rubl-cur        =  - bf_tt-allsum-line.vat-rubl-cur
        bfs_tt-allsum-line.vat-base-buyer-cur  =  - bf_tt-allsum-line.vat-base-buyer-cur
        bfs_tt-allsum-line.vat-rubl-buyer-cur  =  - bf_tt-allsum-line.vat-rubl-buyer-cur
        bfs_tt-allsum-line.slt-base-cur        =  - bf_tt-allsum-line.slt-base-cur
        bfs_tt-allsum-line.slt-rubl-cur        =  - bf_tt-allsum-line.slt-rubl-cur
        bfs_tt-allsum-line.road-tax-base-cur   =  - bf_tt-allsum-line.road-tax-base-cur
        bfs_tt-allsum-line.road-tax-rubl-cur   =  - bf_tt-allsum-line.road-tax-rubl-cur
        bfs_tt-allsum-line.excise-base-cur     =  - bf_tt-allsum-line.excise-base-cur
        bfs_tt-allsum-line.excise-rubl-cur     =  - bf_tt-allsum-line.excise-rubl-cur
        bfs_tt-allsum-line.sum-dsc-base-acc    =  - bf_tt-allsum-line.sum-dsc-base-acc
        bfs_tt-allsum-line.sum-dsc-rubl-acc    =  - bf_tt-allsum-line.sum-dsc-rubl-acc
        bfs_tt-allsum-line.sum-dsc-cli-acc     =  - bf_tt-allsum-line.sum-dsc-cli-acc
        bfs_tt-allsum-line.dsc-base-acc        =  - bf_tt-allsum-line.dsc-base-acc
        bfs_tt-allsum-line.dsc-rubl-acc        =  - bf_tt-allsum-line.dsc-rubl-acc
        bfs_tt-allsum-line.dsc-cli-acc         =  - bf_tt-allsum-line.dsc-cli-acc
        bfs_tt-allsum-line.vat-base-acc        =  - bf_tt-allsum-line.vat-base-acc
        bfs_tt-allsum-line.vat-rubl-acc        =  - bf_tt-allsum-line.vat-rubl-acc
        bfs_tt-allsum-line.vat-cli-acc         =  - bf_tt-allsum-line.vat-cli-acc
        bfs_tt-allsum-line.slt-base-acc        =  - bf_tt-allsum-line.slt-base-acc
        bfs_tt-allsum-line.slt-rubl-acc        =  - bf_tt-allsum-line.slt-rubl-acc
        bfs_tt-allsum-line.slt-cli-acc         =  - bf_tt-allsum-line.slt-cli-acc
        bfs_tt-allsum-line.road-tax-base-acc   =  - bf_tt-allsum-line.road-tax-base-acc
        bfs_tt-allsum-line.road-tax-rubl-acc   =  - bf_tt-allsum-line.road-tax-rubl-acc
        bfs_tt-allsum-line.road-tax-cli-acc    =  - bf_tt-allsum-line.road-tax-cli-acc
        bfs_tt-allsum-line.excise-base-acc     =  - bf_tt-allsum-line.excise-base-acc
        bfs_tt-allsum-line.excise-rubl-acc     =  - bf_tt-allsum-line.excise-rubl-acc
        bfs_tt-allsum-line.excise-cli-acc      =  - bf_tt-allsum-line.excise-cli-acc
        bfs_tt-allsum-line.transport-base-acc  =  - bf_tt-allsum-line.transport-base-acc
        bfs_tt-allsum-line.transport-rubl-acc  =  - bf_tt-allsum-line.transport-rubl-acc
        bfs_tt-allsum-line.transport-cli-acc   =  - bf_tt-allsum-line.transport-cli-acc
        bfs_tt-allsum-line.other-base-acc      =  - bf_tt-allsum-line.other-base-acc
        bfs_tt-allsum-line.other-rubl-acc      =  - bf_tt-allsum-line.other-rubl-acc
        bfs_tt-allsum-line.other-cli-acc       =  - bf_tt-allsum-line.other-cli-acc
        .
    end.
    create bfo_tt-allsum-line.
    assign
      bfo_tt-allsum-line.sum-type = 'сумма_по_услуге':U.
    buffer-copy bf_tt-allsum-line except bf_tt-allsum-line.sum-type to bfo_tt-allsum-line.
    create bfos_tt-allsum-line.
    assign
      bfos_tt-allsum-line.sum-type = 'сумма_по_услуге_со_знаком':U.
    buffer-copy bfs_tt-allsum-line except bfs_tt-allsum-line.sum-type to bfos_tt-allsum-line.
  end.
  else do:
    assign
      varlastcur-base      = 0
      varlastcur-road-tax  = 0
      varlastcur-excise    = 0
      varcur-base          = 0
      varcur-road-tax      = 0
      varcur-excise        = 0
      varcur-vat-pc        = 0
      varcur-slt-pc        = 0
      varcur-fact-qnty     = 0
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  ?
  ,output varb-code
  )  .
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcprcex in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  ,output varcur-vat-pc
  ,output varcur-slt-pc
  )  .
    if varprice-sale = ?
    then do:
      assign
        varcur-vat-pc = 0
        varcur-slt-pc = 0
      .
    end.
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  bf_trn-doc.fact-date
  ,input  bf_trn-doc.host-code
  ,input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,output varcur-vat-pc
  ) no-error .
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Ошибка при поиске НДС для товара &1 &2 &3 документ &4", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code, bf_trn-doc.doc-code).
    end.
    v-calcbypart = no.
    if bf_doc-line.whole-send-news = integer('1':U)   then
    v-calcbypart = yes.
    else do:
    for each bf_gds-dtl no-lock
      where bf_gds-dtl.doc-code  = bf_doc-line.doc-code
        and bf_gds-dtl.artic     = bf_doc-line.artic
        and bf_gds-dtl.prod-type = bf_doc-line.prod-type
        and bf_gds-dtl.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-dtl.prt-code
  ,output varb-code
  ) no-error .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_trn-doc.obj-type
  ,input  bf_trn-doc.obj-code
  ,input  varb-code
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-sale
  ,output varroad-tax
  ,output varexcise
  )  .
          if varprice-sale = ?
          then do:
            assign
              varprice-sale = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
            varlastcur-base     = varprice-sale
            varlastcur-road-tax = varroad-tax
            varlastcur-excise   = varexcise
            varcur-base         = varcur-base      + varprice-sale * bf_gds-dtl.fact-qnty
            varcur-road-tax     = varcur-road-tax  + varroad-tax   * bf_gds-dtl.fact-qnty
            varcur-excise       = varcur-excise    + varexcise     * bf_gds-dtl.fact-qnty
            varcur-fact-qnty    = varcur-fact-qnty + bf_gds-dtl.fact-qnty
          .
      end.
    end.
    if varcur-fact-qnty = 0 then do:
      assign
        varcur-base      = varlastcur-base
        varcur-road-tax  = varlastcur-road-tax
        varcur-excise    = varlastcur-excise
      .
    end.
    else do:
      assign
        varcur-base      = varcur-base      / varcur-fact-qnty
        varcur-road-tax  = varcur-road-tax  / varcur-fact-qnty
        varcur-excise    = varcur-excise    / varcur-fact-qnty
      .
    end.
    if varcur-vat-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НДС по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    if varcur-slt-pc = ?
    then do:
      return error substitute ("Нет текущего продажного НП по товару &1 &2 &3", bf_goods.artic, bf_goods.prod-type, bf_goods.prod-code).
    end.
    find first bf_sysconf where bf_sysconf.host-code = bf_trn-doc.host-code no-lock.
    assign
      varcur-cons-vat-pc = bf_sysconf.cons-vat-pc.
    if varcur-cons-vat-pc = ? then do:
      return error substitute ("Нет текущего продажного консигнационного НДС по фирме &1", bf_trn-doc.host-code).
    end.
    define buffer buf_tt-clcparts for tt-clcparts .
    for each buf_tt-clcparts
    on error undo, return error return-value
    :
      delete buf_tt-clcparts.
    end.
    for each bf_parts no-lock
      where bf_parts.out-code  = bf_doc-line.doc-code
        and bf_parts.obj-type  = bf_doc-line.obj-type
        and bf_parts.obj-code  = bf_doc-line.obj-code
        and bf_parts.artic     = bf_doc-line.artic
        and bf_parts.prod-type = bf_doc-line.prod-type
        and bf_parts.prod-code = bf_doc-line.prod-code
    on error undo, return error return-value
    :
      create buf_tt-clcparts .
      buffer-copy bf_parts to buf_tt-clcparts .
      if v-calcbypart = yes   then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer bf_parts
  ,output v-b-pcode
  ) no-error .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_parts.obj-type
  ,input  bf_parts.obj-code
  ,input  v-b-pcode
  ,input  0
  ,input  bf_trn-doc.fact-order
  ,output vardoc-num
  ,output varprice-salef
  ,output varroad-tax
  ,output varexcise
  ) no-error .
          if varprice-sale = ?
          then do:
            assign
              varprice-salef = 0
              varroad-tax   = 0
              varexcise     = 0
            .
          end.
          assign
          part-cur-base  = varprice-salef
          part-cur-road-tax  = varroad-tax
          part-cur-excise = varexcise.
      end.
    end.
    run clcprtsl_calc-ttable in this-procedure
      (input yes,
       input yes,
       input bf_doc-line.road-tax,
       input bf_doc-line.excise,
       input bf_doc-line.vat-pc,
       input bf_doc-line.cons-vat-pc,
       input bf_doc-line.slt-pc,
       input bf_trn-doc.base-rate,
       input bf_trn-doc.base-scale,
       input varr-b,
       input varcur-base,
       input varcur-road-tax,
       input varcur-excise,
       input varcur-vat-pc,
       input varcur-cons-vat-pc,
       input varcur-slt-pc
       ) no-error.
    if error-status:error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры clcprtsl_calc-ttable." skip
        return-value skip
        trim(error-status :get-message(1))
        trim(error-status :get-message(2))
        trim(error-status :get-message(3))
        trim(error-status :get-message(4))
        trim(error-status :get-message(5)) skip
        view-as alert-box error.
      undo, return error .
    end.
  end.
end.
end.
procedure clcprtsl_calc-ttable :
define input parameter paris-doc           as   logical                 no-undo.
define input parameter paris-cur           as   logical                 no-undo.
define input parameter parroad-tax         like ub.doc-line.road-tax    no-undo.
define input parameter parexcise           like ub.doc-line.excise      no-undo.
define input parameter parvat-pc           like ub.doc-line.vat-pc      no-undo.
define input parameter parcons-vat-pc      like ub.doc-line.cons-vat-pc no-undo.
define input parameter parslt-pc           like ub.doc-line.slt-pc      no-undo.
define input parameter parbase-rate        like ub.trn-doc.base-rate    no-undo.
define input parameter parbase-scale       like ub.trn-doc.base-scale   no-undo.
define input parameter parr-b              as   character               no-undo.
define input parameter parcur-base         like ub.gds-dtl.cur-base     no-undo.
define input parameter parcur-road-tax     like ub.doc-line.road-tax    no-undo.
define input parameter parcur-excise       like ub.doc-line.excise      no-undo.
define input parameter parcur-vat-pc       like ub.doc-line.vat-pc      no-undo.
define input parameter parcurcons-vat-pc   like ub.doc-line.cons-vat-pc no-undo.
define input parameter parcurslt-pc        like ub.doc-line.slt-pc      no-undo.
define buffer bf_tt-allsum      for tt-allsum.
define buffer bf_tt-clcparts    for tt-clcparts.
define buffer bf_tt-allsum-line for tt-allsum-line.
define variable v-b-pcode          like ub.bar-code.b-code     no-undo.
define variable vardoc-num         like ub.price-doc.doc-num     no-undo.
define variable varprice-sale      like ub.price-list.price-sale no-undo.
define variable varroad-tax        like ub.price-list.road-tax   no-undo.
define variable varexcise          like ub.price-list.excise     no-undo.
do on error undo, return error return-value :
for each bf_tt-allsum-line
on error undo, return error return-value
 :
  delete bf_tt-allsum-line.
end.
for each bf_tt-allsum
on error undo, return error return-value
:
  delete bf_tt-allsum.
end.
for each bf_tt-clcparts
on error undo, return error return-value
:
if v-calcbypart then do:
          assign
          parcur-base =   bf_tt-clcparts.part-cur-base
          parcur-road-tax = bf_tt-clcparts.part-cur-road-tax
          parcur-excise =   bf_tt-clcparts.part-cur-excise
          .
end.
   run clcprtsl_calc-parts in this-procedure (
     input recid(bf_tt-clcparts),
     input paris-doc,
     input paris-cur,
     input parroad-tax,
     input parexcise,
     input parvat-pc,
     input parcons-vat-pc,
     input parslt-pc,
     input parbase-rate,
     input parbase-scale,
     input parr-b,
     input parcur-base,
     input parcur-road-tax,
     input parcur-excise,
     input parcur-vat-pc,
     input parcurcons-vat-pc,
     input parcurslt-pc
     ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      vss-include-info8 skip
      "Ошибка при обсчете партии" skip
      "Документ партии " bf_tt-clcparts.out-code skip
      "Товар" bf_tt-clcparts.artic bf_tt-clcparts.prod-type bf_tt-clcparts.prod-code skip
      return-value skip
      error-status:get-message(1) skip
      error-status:get-message(2) skip
      error-status:get-message(3) skip
      view-as alert-box error .
    undo, return error .
  end.
  for each bf_tt-allsum on error undo, return error return-value :
    find first bf_tt-allsum-line where bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type no-error.
    if not available bf_tt-allsum-line then do:
      create bf_tt-allsum-line.
      assign
        bf_tt-allsum-line.sum-type = bf_tt-allsum.sum-type.
    end.
    assign
      bf_tt-allsum-line.fact-qnty              = bf_tt-allsum-line.fact-qnty            + bf_tt-allsum.fact-qnty
      bf_tt-allsum-line.cli-qnty               = bf_tt-allsum-line.cli-qnty             + bf_tt-allsum.cli-qnty
      bf_tt-allsum-line.sum-dsc-base-doc       = bf_tt-allsum-line.sum-dsc-base-doc     + bf_tt-allsum.sum-dsc-base-doc
      bf_tt-allsum-line.sum-dsc-rubl-doc       = bf_tt-allsum-line.sum-dsc-rubl-doc     + bf_tt-allsum.sum-dsc-rubl-doc
      bf_tt-allsum-line.dsc-base-doc           = bf_tt-allsum-line.dsc-base-doc         + bf_tt-allsum.dsc-base-doc
      bf_tt-allsum-line.dsc-rubl-doc           = bf_tt-allsum-line.dsc-rubl-doc         + bf_tt-allsum.dsc-rubl-doc
      bf_tt-allsum-line.vat-base-doc           = bf_tt-allsum-line.vat-base-doc         + bf_tt-allsum.vat-base-doc
      bf_tt-allsum-line.vat-rubl-doc           = bf_tt-allsum-line.vat-rubl-doc         + bf_tt-allsum.vat-rubl-doc
      bf_tt-allsum-line.vat-base-buyer-doc     = bf_tt-allsum-line.vat-base-buyer-doc   + bf_tt-allsum.vat-base-buyer-doc
      bf_tt-allsum-line.vat-rubl-buyer-doc     = bf_tt-allsum-line.vat-rubl-buyer-doc   + bf_tt-allsum.vat-rubl-buyer-doc
      bf_tt-allsum-line.slt-base-doc           = bf_tt-allsum-line.slt-base-doc         + bf_tt-allsum.slt-base-doc
      bf_tt-allsum-line.slt-rubl-doc           = bf_tt-allsum-line.slt-rubl-doc         + bf_tt-allsum.slt-rubl-doc
      bf_tt-allsum-line.road-tax-base-doc      = bf_tt-allsum-line.road-tax-base-doc    + bf_tt-allsum.road-tax-base-doc
      bf_tt-allsum-line.road-tax-rubl-doc      = bf_tt-allsum-line.road-tax-rubl-doc    + bf_tt-allsum.road-tax-rubl-doc
      bf_tt-allsum-line.excise-base-doc        = bf_tt-allsum-line.excise-base-doc      + bf_tt-allsum.excise-base-doc
      bf_tt-allsum-line.excise-rubl-doc        = bf_tt-allsum-line.excise-rubl-doc      + bf_tt-allsum.excise-rubl-doc
      bf_tt-allsum-line.sum-dsc-base-cur       = bf_tt-allsum-line.sum-dsc-base-cur     + bf_tt-allsum.sum-dsc-base-cur
      bf_tt-allsum-line.sum-dsc-rubl-cur       = bf_tt-allsum-line.sum-dsc-rubl-cur     + bf_tt-allsum.sum-dsc-rubl-cur
      bf_tt-allsum-line.dsc-base-cur           = bf_tt-allsum-line.dsc-base-cur         + bf_tt-allsum.dsc-base-cur
      bf_tt-allsum-line.dsc-rubl-cur           = bf_tt-allsum-line.dsc-rubl-cur         + bf_tt-allsum.dsc-rubl-cur
      bf_tt-allsum-line.vat-base-cur           = bf_tt-allsum-line.vat-base-cur         + bf_tt-allsum.vat-base-cur
      bf_tt-allsum-line.vat-rubl-cur           = bf_tt-allsum-line.vat-rubl-cur         + bf_tt-allsum.vat-rubl-cur
      bf_tt-allsum-line.vat-base-buyer-cur     = bf_tt-allsum-line.vat-base-buyer-cur   + bf_tt-allsum.vat-base-buyer-cur
      bf_tt-allsum-line.vat-rubl-buyer-cur     = bf_tt-allsum-line.vat-rubl-buyer-cur   + bf_tt-allsum.vat-rubl-buyer-cur
      bf_tt-allsum-line.slt-base-cur           = bf_tt-allsum-line.slt-base-cur         + bf_tt-allsum.slt-base-cur
      bf_tt-allsum-line.slt-rubl-cur           = bf_tt-allsum-line.slt-rubl-cur         + bf_tt-allsum.slt-rubl-cur
      bf_tt-allsum-line.road-tax-base-cur      = bf_tt-allsum-line.road-tax-base-cur    + bf_tt-allsum.road-tax-base-cur
      bf_tt-allsum-line.road-tax-rubl-cur      = bf_tt-allsum-line.road-tax-rubl-cur    + bf_tt-allsum.road-tax-rubl-cur
      bf_tt-allsum-line.excise-base-cur        = bf_tt-allsum-line.excise-base-cur      + bf_tt-allsum.excise-base-cur
      bf_tt-allsum-line.excise-rubl-cur        = bf_tt-allsum-line.excise-rubl-cur      + bf_tt-allsum.excise-rubl-cur
      bf_tt-allsum-line.sum-dsc-base-acc       = bf_tt-allsum-line.sum-dsc-base-acc     + bf_tt-allsum.sum-dsc-base-acc
      bf_tt-allsum-line.sum-dsc-rubl-acc       = bf_tt-allsum-line.sum-dsc-rubl-acc     + bf_tt-allsum.sum-dsc-rubl-acc
      bf_tt-allsum-line.sum-dsc-cli-acc        = bf_tt-allsum-line.sum-dsc-cli-acc      + bf_tt-allsum.sum-dsc-cli-acc
      bf_tt-allsum-line.dsc-base-acc           = bf_tt-allsum-line.dsc-base-acc         + bf_tt-allsum.dsc-base-acc
      bf_tt-allsum-line.dsc-rubl-acc           = bf_tt-allsum-line.dsc-rubl-acc         + bf_tt-allsum.dsc-rubl-acc
      bf_tt-allsum-line.dsc-cli-acc            = bf_tt-allsum-line.dsc-cli-acc          + bf_tt-allsum.dsc-cli-acc
      bf_tt-allsum-line.vat-base-acc           = bf_tt-allsum-line.vat-base-acc         + bf_tt-allsum.vat-base-acc
      bf_tt-allsum-line.vat-rubl-acc           = bf_tt-allsum-line.vat-rubl-acc         + bf_tt-allsum.vat-rubl-acc
      bf_tt-allsum-line.vat-cli-acc            = bf_tt-allsum-line.vat-cli-acc          + bf_tt-allsum.vat-cli-acc
      bf_tt-allsum-line.slt-base-acc           = bf_tt-allsum-line.slt-base-acc         + bf_tt-allsum.slt-base-acc
      bf_tt-allsum-line.slt-rubl-acc           = bf_tt-allsum-line.slt-rubl-acc         + bf_tt-allsum.slt-rubl-acc
      bf_tt-allsum-line.slt-cli-acc            = bf_tt-allsum-line.slt-cli-acc          + bf_tt-allsum.slt-cli-acc
      bf_tt-allsum-line.road-tax-base-acc      = bf_tt-allsum-line.road-tax-base-acc    + bf_tt-allsum.road-tax-base-acc
      bf_tt-allsum-line.road-tax-rubl-acc      = bf_tt-allsum-line.road-tax-rubl-acc    + bf_tt-allsum.road-tax-rubl-acc
      bf_tt-allsum-line.road-tax-cli-acc       = bf_tt-allsum-line.road-tax-cli-acc     + bf_tt-allsum.road-tax-cli-acc
      bf_tt-allsum-line.excise-base-acc        = bf_tt-allsum-line.excise-base-acc      + bf_tt-allsum.excise-base-acc
      bf_tt-allsum-line.excise-rubl-acc        = bf_tt-allsum-line.excise-rubl-acc      + bf_tt-allsum.excise-rubl-acc
      bf_tt-allsum-line.excise-cli-acc         = bf_tt-allsum-line.excise-cli-acc       + bf_tt-allsum.excise-cli-acc
      bf_tt-allsum-line.transport-base-acc     = bf_tt-allsum-line.transport-base-acc   + bf_tt-allsum.transport-base-acc
      bf_tt-allsum-line.transport-rubl-acc     = bf_tt-allsum-line.transport-rubl-acc   + bf_tt-allsum.transport-rubl-acc
      bf_tt-allsum-line.transport-cli-acc      = bf_tt-allsum-line.transport-cli-acc    + bf_tt-allsum.transport-cli-acc
      bf_tt-allsum-line.other-base-acc         = bf_tt-allsum-line.other-base-acc       + bf_tt-allsum.other-base-acc
      bf_tt-allsum-line.other-rubl-acc         = bf_tt-allsum-line.other-rubl-acc       + bf_tt-allsum.other-rubl-acc
      bf_tt-allsum-line.other-cli-acc          = bf_tt-allsum-line.other-cli-acc        + bf_tt-allsum.other-cli-acc
      .
  end.
end.
end.
end procedure.
define temp-table tt-doc-line-sum     no-undo like ub.doc-line-sum.
define temp-table tt-old-doc-line-sum no-undo like tt-doc-line-sum.
define temp-table tt-wast-line        no-undo
  field obj-type            like ub.doc-line.obj-type
  field obj-code            like ub.doc-line.obj-code
  field status_             like ub.doc-line.status_
  field artic               like ub.doc-line.artic
  field prod-type           like ub.doc-line.prod-type
  field prod-code           like ub.doc-line.prod-code
  field fact-order          like ub.doc-line.fact-order
  field prev-inv-fact-order like ub.doc-line.fact-order
  index prev-inv-fact-order      prev-inv-fact-order.
  define new global shared variable g#lib-rwds as handle no-undo.
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  temp-table gds-list no-undo like ub.goods
  field qnty   as decimal
  field to-del as logical
  field order-num as integer
  field to-sel as logical
  field promo-code as character
  field ActionId  as int64
  field db-num as integer
  index art  is primary unique artic prod-type prod-code
  index code is         unique gds-code
  index oi order-num
  index isel to-sel
  .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define    temp-table gds-list-hist no-undo
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
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
procedure gdsoattr-name :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-name in g#attr-lib
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
end.
procedure gdsoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-tooltip in g#attr-lib
      (input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-value :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define output parameter p-type     as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-value in g#attr-lib
      (input  p-code
      ,input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-value
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-gds-code :
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input  parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define output parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-gds-code in g#attr-lib
      (input  p-code
      ,input  p-value
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-gds-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-write :
  define input parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define input parameter p-value    like ub.gds-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-write in g#attr-lib
      (input p-gds-code
      ,input p-obj-type
      ,input p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-exist :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-exist in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-delete :
  define input  parameter p-gds-code like ub.gds-obj-attr.gds-code   no-undo .
  define input  parameter p-obj-type like ub.gds-obj-attr.obj-type   no-undo .
  define input  parameter p-obj-code like ub.gds-obj-attr.obj-code   no-undo .
  define input  parameter p-code     like ub.gds-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-delete in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-doc-tickets :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-doc-tickets in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-dop-alt-name :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-dop-alt-name in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-gds-margins :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-gds-margins in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-obj-normal-wastage :
  define input  parameter p-gds-code    like ub.gds-obj-attr.gds-code no-undo .
  define input  parameter p-obj-type    like ub.gds-obj-attr.obj-type no-undo .
  define input  parameter p-obj-code    like ub.gds-obj-attr.obj-code no-undo .
  define input-output parameter p-value as character no-undo .
  define output parameter p-setted      as logical no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-obj-normal-wastage in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr-margin-value :
  define input  parameter p-gds-code         as integer   no-undo .
  define input  parameter p-obj-type         as character no-undo .
  define input  parameter p-obj-code         as integer   no-undo .
  define output parameter p-min-value        as decimal   no-undo initial ? .
  define output parameter p-max-value        as decimal   no-undo initial ? .
  define output parameter p-increase-pc      as decimal   no-undo initial ? .
  define output parameter p-rmethod          as character no-undo initial '':U .
  define output parameter p-base             as decimal   no-undo initial ? .
  define output parameter p-range-margin     as integer   no-undo .
  define output parameter p-exists-margin    as logical   no-undo .
  define output parameter p-range-increase   as integer   no-undo .
  define output parameter p-exists-increase  as logical   no-undo .
  define output parameter p-range-rmethod    as integer   no-undo .
  define output parameter p-exists-rmethod   as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-margin-value in g#attr-lib
      (input  p-gds-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,output p-min-value
      ,output p-max-value
      ,output p-increase-pc
      ,output p-rmethod
      ,output p-base
      ,output p-range-margin
      ,output p-exists-margin
      ,output p-range-increase
      ,output p-exists-increase
      ,output p-range-rmethod
      ,output p-exists-rmethod
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-o-normal-wastage-value :
  define input-output parameter objNormWast as class ibs.th.ref.normwastsub no-undo.
do
on error undo, return error
:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-o-normal-wastage-value in g#attr-lib
      (input-output objNormWast
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gdsoattr-copy :
  define input  parameter p-code as character no-undo .
  define output parameter p-copy as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-copy in g#attr-lib
      (input  p-code
      ,output p-copy
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
procedure gds-attr_check-code-dt-seasons :
  define input  parameter p-code     like ub.goods.gds-code   no-undo .
  define input  parameter p-obj-type like ub.clients.obj-type no-undo .
  define input  parameter p-obj-code like ub.clients.obj-code no-undo .
  define output parameter p-gds-code like ub.goods.gds-code   no-undo .
  define output parameter p-dt-code  as   integer             no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr_check-code-dt-seasons in g#attr-lib
      (input p-code
      ,input p-obj-type
      ,input p-obj-code
      ,output p-gds-code
      ,output p-dt-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end.
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
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-pl-gds no-undo   like ub.pl-gds .
define temp-table temp-prt-obj no-undo   field prt-code         like ub.prt-obj.prt-code     field price-sale       like ub.prt-obj.price-sale   field fact-qnty        like ub.prt-obj.fact-qnty    field price-list-qnty  like ub.prt-obj.fact-qnty    field is-term          as logical   field prt-obj-recid    as recid     field price-list-recid as recid     index xpk is primary unique prt-code   index xie1 is-term .
procedure prdoclib-process-goods :
  define input  parameter p-obj-type          as character no-undo .
  define input  parameter p-obj-code          as integer   no-undo .
  define input  parameter p-artic             as character no-undo .
  define input  parameter p-prod-type         as character no-undo .
  define input  parameter p-prod-code         as integer   no-undo .
  define input  parameter p-check-price-list  as logical   no-undo .
  define input  parameter p-check-price-parts as logical   no-undo .
  define input  parameter p-doc-num           as character no-undo .
  define input  parameter p-fact-date         as date      no-undo .
  define input  parameter p-corr-user-db-num  as integer   no-undo .
  define input  parameter p-corr-user-name    as character no-undo .
  define input  parameter p-corr-date         as date      no-undo .
  define input  parameter p-corr-time         as integer   no-undo .
  define input  parameter p-corr-time-str     as character no-undo .
  define output parameter p-gds-obj-fact-qnty as decimal   no-undo .
  define variable vss-description as character no-undo initial "prdoclib-process-goods-01: обработка продажных цен товара".
  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_prt-obj      for ub.prt-obj .
  define buffer buf_price-list   for ub.price-list .
  define buffer buf_bar-code     for ub.bar-code .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-gds-code             like ub.goods.gds-code    no-undo .
  define variable v-root-node            like ub.prt-obj.prt-code  no-undo .
  define variable v-root-b-code          like ub.bar-code.b-code   no-undo .
  define variable v-total-term-fact-qnty like ub.prt-obj.fact-qnty no-undo .
  define variable v-total-fact-sale      like ub.gds-obj.fact-sale no-undo .
  define variable v-doc-num     like ub.price-list.doc-num    no-undo .
  define variable v-price-sale  like ub.price-list.price-sale no-undo .
  define variable v-road-tax    like ub.price-list.road-tax   no-undo .
  define variable v-excise      like ub.price-list.excise     no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-root-node
  )  .
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  v-root-node
  ,buffer buf_gds-obj
  ,buffer buf_prt-obj
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Ошибка при начале товародвижения товара на объекте" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    find current buf_gds-obj  exclusive-lock .
    find current buf_prt-obj  exclusive-lock .
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  v-gds-code
  ,input  v-root-node
  ,output v-root-b-code
  )  .
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  v-root-b-code
  ,input  v-root-b-code
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Ошибка при определении цены признака на объекте" skip
        "Объект"     p-obj-type p-obj-code  skip
        "Бар-код"    v-root-b-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-init-temp-prt-obj in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-price-sale
      ) .
    find first buf_price-list no-lock
      where buf_price-list.doc-num    = v-doc-num
        and buf_price-list.price-type = ""
        and buf_price-list.b-code     = v-root-b-code
      .
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = v-root-node
      .
    assign
      buf_temp-prt-obj.price-sale       = v-price-sale
      buf_temp-prt-obj.price-list-qnty  = buf_price-list.doc-qnty
      buf_temp-prt-obj.price-list-recid = recid(buf_price-list)
    .
    define variable l-empty-scale as logical no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtat in g#library
  (input  v-root-node
  ,input  'empty-scale=request'
  ,output l-empty-scale
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Ошибка при определении атрибута шкалы" skip
        "Код признака" v-root-node skip
        "Запрашивался атрибут" "empty-scale=request" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      v-total-term-fact-qnty = 0
      v-total-fact-sale      = 0
    .
    if l-empty-scale = true
    then do:
      for each buf_price-list
        where buf_price-list.doc-num    = v-doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = p-artic
          and buf_price-list.prod-type  = p-prod-type
          and buf_price-list.prod-code  = p-prod-code
          and buf_price-list.price-type = ""
      on error undo, return error return-value
      :
        if buf_price-list.doc-qnty <> ? and p-check-price-parts
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info26 skip
            "Ошибка при закрытии переоценки" skip
            "Для неосновного бар-кода товара с пустой шкалой" skip
            "указано количество отличное от ?" skip
            "Переоценка" v-doc-num skip
            "Бар-код" buf_price-list.b-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Количество" buf_price-list.doc-qnty skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
    if l-empty-scale = false
    then do:
      define variable v-unit-base like ub.goods.unit-base no-undo .
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  v-gds-code
  ,output v-unit-base
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info26 skip
          "Ошибка при определении базовой единицы измерения товара" skip
          "Код товара" v-gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      for each buf_price-list
        where buf_price-list.doc-num    = v-doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = p-artic
          and buf_price-list.prod-type  = p-prod-type
          and buf_price-list.prod-code  = p-prod-code
          and buf_price-list.price-type = ""
      on error undo, return error
      :
        if buf_price-list.doc-qnty = ?
        then do:
          find first buf_bar-code no-lock
            where buf_bar-code.b-code = buf_price-list.b-code
            no-error .
          if  available buf_bar-code
          and buf_bar-code.unit-cli = v-unit-base
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info26 skip
              "Ошибка при закрытии переоценки" skip
              "Не задано количество для бар-кода с основной единицей измерения" skip
              "Переоценка" v-doc-num skip
              "Бар-код" buf_price-list.b-code skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Количество" buf_price-list.doc-qnty skip
              "Основная единица измерения" v-unit-base skip
              "Единица измерения бар-кода" buf_bar-code.unit-cli skip
              view-as alert-box error .
            undo, return error .
          end.
          next .
        end.
        find first buf_bar-code no-lock
          where buf_bar-code.b-code = buf_price-list.b-code
          no-error .
        if not available buf_bar-code
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info26 skip
            "В переоценке задан несуществующий бар-код" skip
            "Переоценка" v-doc-num skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Бар-код" buf_price-list.b-code skip
            view-as alert-box error .
          undo, return error .
        end.
        if buf_bar-code.in-code <> ""
        or buf_bar-code.part-code <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info26 skip
            "В переоценке задан бар-код партии" skip
            "Данная версия системы не рассчитана на работу со специальными ценами по партиям" skip
            "Переоценка" v-doc-num skip
            "Бар-код" buf_price-list.b-code skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            "Код ПН" buf_bar-code.in-code buf_bar-code.part-code skip
            view-as alert-box error .
          undo, return error .
        end.
        if buf_bar-code.node-code <> v-root-node
        then do:
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  buf_bar-code.node-code
  ,buffer buf_prt-obj
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info26 skip
              "Невозможно найти prt-obj" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          run prdoclib-create-temp-prt-obj in this-procedure
            (input  v-price-sale
            ,buffer buf_prt-obj
            ,buffer buf_temp-prt-obj
            ).
          assign
            buf_temp-prt-obj.price-sale       = buf_price-list.price-sale
            buf_temp-prt-obj.price-list-qnty  = buf_price-list.doc-qnty
            buf_temp-prt-obj.price-list-recid = recid(buf_price-list)
          .
        end.
      end.
      for each buf_temp-prt-obj
        where buf_temp-prt-obj.is-term = true
      :
        if buf_temp-prt-obj.price-list-recid <> ?
        then do:
          assign
            v-total-term-fact-qnty = v-total-term-fact-qnty
                                  + buf_temp-prt-obj.fact-qnty
            v-total-fact-sale = v-total-fact-sale
                              + buf_temp-prt-obj.fact-qnty * buf_temp-prt-obj.price-sale
          .
        end.
        if p-check-price-list = true
        then do:
          if buf_temp-prt-obj.price-list-recid = ?
          or buf_temp-prt-obj.fact-qnty = buf_temp-prt-obj.price-list-qnty
          then do:
          end.
          else do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info26 skip
              "Ошибка при закрытии переоценки" skip
              "Несовпадают текущие количества по признаку" skip
              "и количество признака в переоценке" skip
              "Переоценка" v-doc-num skip
              "Артикул" p-artic p-prod-type p-prod-code skip
              "Код признака" buf_temp-prt-obj.prt-code skip
              "Количество по признаку" buf_temp-prt-obj.fact-qnty skip
              "Количество по переоценке" buf_temp-prt-obj.price-list-qnty skip
              "Корень шкалы товара" v-root-node skip
              view-as alert-box error .
            undo, return error .
          end.
        end.
      end.
    end.
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = v-root-node
      .
    assign
      buf_temp-prt-obj.fact-qnty = buf_temp-prt-obj.fact-qnty
                                  - v-total-term-fact-qnty
    .
    if p-check-price-list = true
    then do:
      if buf_temp-prt-obj.fact-qnty <> buf_temp-prt-obj.price-list-qnty and p-check-price-parts
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info26 skip
          "Ошибка при закрытии переоценки" skip
          "Несовпадают текущие количества по корневому признаку" skip
          "и количество признака в переоценке" skip
          "Переоценка" v-doc-num skip
          "Артикул" p-artic p-prod-type p-prod-code skip
          "Код признака" buf_temp-prt-obj.prt-code skip
          "Количество по признаку" buf_temp-prt-obj.fact-qnty skip
          "Количество по переоценке" buf_temp-prt-obj.price-list-qnty skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    assign
      v-total-fact-sale = v-total-fact-sale
                        + buf_temp-prt-obj.fact-qnty * buf_temp-prt-obj.price-sale
    .
    if v-total-fact-sale = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Ошибка при вычислении суммы в продажных ценах" skip
        "Получено неопределенное значение" skip
        "Переоценка" v-doc-num skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Код признака" buf_temp-prt-obj.prt-code skip
        "Сумма в продажных ценах" v-total-fact-sale skip
        view-as alert-box error .
      undo, return error .
    end.
    define variable v-old-fact-qnty     as decimal   no-undo .
    define variable v-old-fact-cli-qnty as decimal   no-undo .
    define variable v-old-fact-base     as decimal   no-undo .
    define variable v-old-fact-rubl     as decimal   no-undo .
    define variable v-old-fact-sale     as decimal   no-undo .
    assign
      v-old-fact-qnty     = buf_gds-obj.fact-qnty
      v-old-fact-cli-qnty = buf_gds-obj.fact-cli-qnty
      v-old-fact-base     = buf_gds-obj.fact-base
      v-old-fact-rubl     = buf_gds-obj.fact-rubl
      v-old-fact-sale     = buf_gds-obj.fact-sale
    .
    assign
      buf_gds-obj.price-sale = v-price-sale
      buf_gds-obj.fact-sale  = v-total-fact-sale
    .
    define variable v-corr-date as date      no-undo .
    define variable v-corr-time as integer   no-undo .
    run cur-time in this-procedure
      (output v-corr-date
      ,output v-corr-time
      ) .
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gohist in g#library
  (input  buf_gds-obj.obj-type
  ,input  buf_gds-obj.obj-code
  ,input  buf_gds-obj.gds-code
  ,input  'close':U
  ,input  buf_gds-obj.fact-qnty
  ,input  buf_gds-obj.fact-cli-qnty
  ,input  buf_gds-obj.fact-base
  ,input  buf_gds-obj.fact-rubl
  ,input  buf_gds-obj.fact-sale
  ,input  v-old-fact-qnty
  ,input  v-old-fact-cli-qnty
  ,input  v-old-fact-base
  ,input  v-old-fact-rubl
  ,input  v-old-fact-sale
  ,input  'price-doc':U
  ,input  p-doc-num
  ,input  p-fact-date
  ,input  p-corr-user-db-num
  ,input  p-corr-user-name
  ,input  p-corr-date
  ,input  p-corr-time
  ,input  p-corr-time-str
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при создании истории по товару на объекте" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      p-gds-obj-fact-qnty = buf_gds-obj.fact-qnty
    .
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if  buf_gds-obj.first-doc <> ?
and buf_gds-obj.first-doc > p-fact-date then do:
  assign
    buf_gds-obj.first-doc  = p-fact-date
  .
end.
if  buf_gds-obj.last-doc <> ?
and buf_gds-obj.last-doc < p-fact-date then do:
  assign
    buf_gds-obj.last-doc   = p-fact-date
  .
end.
    for each buf_temp-prt-obj
    ,first buf_prt-obj exclusive-lock
      where recid(buf_prt-obj) = buf_temp-prt-obj.prt-obj-recid
    on error undo, return error return-value
    :
      assign
        buf_prt-obj.price-sale = buf_temp-prt-obj.price-sale
      .
    end.
  end.
end procedure.
procedure prdoclib-clear-temp-prt-obj :
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    for each buf_temp-prt-obj
    on error undo, return error return-value
    :
      delete buf_temp-prt-obj .
    end.
  end.
end procedure.
procedure prdoclib-create-temp-prt-obj :
  define input parameter  p-root-price-sale like ub.price-list.price-sale no-undo .
  define parameter buffer buf_prt-obj       for ub.prt-obj .
  define parameter buffer buf_temp-prt-obj  for temp-prt-obj .
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = buf_prt-obj.prt-code
      no-error .
    if not available buf_temp-prt-obj
    then do:
      create buf_temp-prt-obj .
      assign
        buf_temp-prt-obj.prt-code         = buf_prt-obj.prt-code
        buf_temp-prt-obj.price-sale       = ?
        buf_temp-prt-obj.fact-qnty        = buf_prt-obj.fact-qnty
        buf_temp-prt-obj.price-list-qnty  = ?
        buf_temp-prt-obj.prt-obj-recid    = recid(buf_prt-obj)
        buf_temp-prt-obj.price-list-recid = ?
      .
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = buf_temp-prt-obj.prt-code
        .
      assign
        buf_temp-prt-obj.is-term = buf_gds-prt.is-term
      .
      if buf_temp-prt-obj.is-term
      then do:
        assign
          buf_temp-prt-obj.price-sale = p-root-price-sale
        .
      end.
    end.
  end.
end procedure.
procedure prdoclib-temp-prt-obj-by-prt-root :
  define input parameter  p-prt-code like ub.prt-obj.prt-code no-undo .
  define parameter buffer buf_temp-prt-obj  for temp-prt-obj .
  define buffer buf_gds-prt for ub.gds-prt .
  do
  on error undo, return error return-value
  :
    find first buf_temp-prt-obj
      where buf_temp-prt-obj.prt-code = p-prt-code
      no-error .
    if not available buf_temp-prt-obj
    then do:
      create buf_temp-prt-obj .
      assign
        buf_temp-prt-obj.prt-code         = p-prt-code
        buf_temp-prt-obj.price-sale       = ?
        buf_temp-prt-obj.fact-qnty        = 0
        buf_temp-prt-obj.price-list-qnty  = ?
        buf_temp-prt-obj.prt-obj-recid    = ?
        buf_temp-prt-obj.price-list-recid = ?
      .
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = buf_temp-prt-obj.prt-code
        .
      assign
        buf_temp-prt-obj.is-term = buf_gds-prt.is-term
      .
      if buf_temp-prt-obj.is-term
      then do:
        assign
          buf_temp-prt-obj.price-sale = 0
        .
      end.
    end.
  end.
end procedure.
procedure prdoclib-init-temp-prt-obj :
  define input parameter p-obj-type        like ub.prt-obj.obj-type  no-undo .
  define input parameter p-obj-code        like ub.prt-obj.obj-code  no-undo .
  define input parameter p-artic           like ub.prt-obj.artic     no-undo .
  define input parameter p-prod-type       like ub.prt-obj.prod-type no-undo .
  define input parameter p-prod-code       like ub.prt-obj.prod-code no-undo .
  define input parameter p-root-price-sale like ub.prt-obj.price-sale no-undo .
  define buffer buf_prt-obj      for ub.prt-obj .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    run prdoclib-clear-temp-prt-obj in this-procedure .
    for each buf_prt-obj
      where buf_prt-obj.obj-type  = p-obj-type
        and buf_prt-obj.obj-code  = p-obj-code
        and buf_prt-obj.artic     = p-artic
        and buf_prt-obj.prod-type = p-prod-type
        and buf_prt-obj.prod-code = p-prod-code
    on error undo, return error return-value
    :
      run prdoclib-create-temp-prt-obj in this-procedure
        (input  p-root-price-sale
        ,buffer buf_prt-obj
        ,buffer buf_temp-prt-obj
        ).
    end.
  end.
end procedure.
procedure prdoclib-calc-fact-sale :
  define input  parameter p-price-list-recid   as recid     no-undo .
  define output parameter p-fact-qnty          as decimal   no-undo .
  define output parameter p-cur-base           as decimal   no-undo .
  define output parameter p-cur-VAT-base       as decimal   no-undo .
  define output parameter p-cur-SLT-base       as decimal   no-undo .
  define output parameter p-cur-road-tax-base  as decimal   no-undo .
  define output parameter p-cur-excise-base    as decimal   no-undo .
  define buffer buf_main_price-list for ub.price-list .
  define buffer buf_price-list      for ub.price-list .
  define buffer buf_goods           for ub.goods .
  define buffer buf_gds-obj         for ub.gds-obj .
  define buffer buf_bar-code        for ub.bar-code .
  define variable l-empty-scale   as logical   no-undo .
  do
  on error undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )
  on stop undo, return error substitute(" stop &1 &2" , return-value , error-status :get-message(1)  )
  on end-key undo, return error substitute(" end-key &1 &2" , return-value , error-status :get-message(1)  )
  :
    find first buf_main_price-list no-lock
      where recid(buf_main_price-list) = p-price-list-recid
      no-error .
    if not available buf_main_price-list
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка переоценки" skip
        "Код записи (recid)" p-price-list-recid skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )   .
    end.
    if buf_main_price-list.main-price <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Ошибка задания входных параметров" skip
        "Строка переоценки не является основной" skip
        "Код записи (recid)" p-price-list-recid skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        "Бар-код" buf_main_price-list.b-code skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  )  .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = buf_main_price-list.artic
        and buf_goods.prod-type = buf_main_price-list.prod-type
        and buf_goods.prod-code = buf_main_price-list.prod-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Не найден товар" skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
    end.
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_main_price-list.artic
  ,input  buf_main_price-list.prod-type
  ,input  buf_main_price-list.prod-code
  ,input  'empty-scale=request':u
  ,output l-empty-scale
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Ошибка при определении атрибута товара" skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        'empty-scale=request':u skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
    end.
    find first buf_gds-obj no-lock
      where buf_gds-obj.gds-code = buf_goods.gds-code
        and buf_gds-obj.obj-type = buf_main_price-list.obj-type
        and buf_gds-obj.obj-code = buf_main_price-list.obj-code
      no-error .
      if not available buf_gds-obj then do:
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  buf_main_price-list.obj-type
  ,input  buf_main_price-list.obj-code
  ,input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,buffer buf_gds-obj
  ) no-error .
        if error-status :error then do:
           undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
        end.
      end.
    define variable price-rubl-with-tax-sale-prl    as decimal   no-undo .
    define variable price-base-with-tax-sale-prl    as decimal   no-undo .
    define variable price-rubl-without-tax-sale-prl as decimal   no-undo .
    define variable price-base-without-tax-sale-prl as decimal   no-undo .
    define variable vat-base-sale-prl               as decimal   no-undo .
    define variable vat-rubl-sale-prl               as decimal   no-undo .
    define variable vat-base-buyer-prl              as decimal   no-undo .
    define variable vat-rubl-buyer-prl              as decimal   no-undo .
    define variable slt-base-sale-prl               as decimal   no-undo .
    define variable slt-rubl-sale-prl               as decimal   no-undo .
    define variable road-tax-base-sale-prl          as decimal   no-undo .
    define variable road-tax-rubl-sale-prl          as decimal   no-undo .
    define variable excise-base-sale-prl            as decimal   no-undo .
    define variable excise-rubl-sale-prl            as decimal   no-undo .
    define variable discnt-base-sale-prl            as decimal   no-undo .
    define variable discnt-rubl-sale-prl            as decimal   no-undo .
    if buf_main_price-list.doc-qnty <> 0
    then do:
      run prl-vat in this-procedure
        (input  recid(buf_main_price-list)
        ,output price-rubl-with-tax-sale-prl
        ,output price-base-with-tax-sale-prl
        ,output price-rubl-without-tax-sale-prl
        ,output price-base-without-tax-sale-prl
        ,output vat-base-sale-prl
        ,output vat-rubl-sale-prl
        ,output vat-base-buyer-prl
        ,output vat-rubl-buyer-prl
        ,output slt-base-sale-prl
        ,output slt-rubl-sale-prl
        ,output road-tax-base-sale-prl
        ,output road-tax-rubl-sale-prl
        ,output excise-base-sale-prl
        ,output excise-rubl-sale-prl
        ,output discnt-base-sale-prl
        ,output discnt-rubl-sale-prl
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info26 skip
          "Ошибка при вызове процеды prl-vat" skip
          "Документ" buf_main_price-list.doc-num skip
          "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
      end.
    end.
    else do:
      assign
        price-rubl-with-tax-sale-prl    = 0
        price-base-with-tax-sale-prl    = 0
        price-rubl-without-tax-sale-prl = 0
        price-base-without-tax-sale-prl = 0
        vat-base-sale-prl               = 0
        vat-rubl-sale-prl               = 0
        vat-base-buyer-prl              = 0
        vat-rubl-buyer-prl              = 0
        slt-base-sale-prl               = 0
        slt-rubl-sale-prl               = 0
        road-tax-base-sale-prl          = 0
        road-tax-rubl-sale-prl          = 0
        excise-base-sale-prl            = 0
        excise-rubl-sale-prl            = 0
        discnt-base-sale-prl            = 0
        discnt-rubl-sale-prl            = 0
      .
    end.
    define variable v-curr-r-b as character no-undo .
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
    if v-curr-r-b = 'base':U
    then do:
      assign
        p-fact-qnty         = buf_main_price-list.doc-qnty
        p-cur-base          = price-base-with-tax-sale-prl * buf_main_price-list.doc-qnty
        p-cur-VAT-base      = vat-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-SLT-base      = slt-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-road-tax-base = road-tax-base-sale-prl * buf_main_price-list.doc-qnty
        p-cur-excise-base   = excise-base-sale-prl * buf_main_price-list.doc-qnty
      .
    end.
    else do:
      assign
        p-fact-qnty         = buf_main_price-list.doc-qnty
        p-cur-base          = price-rubl-with-tax-sale-prl * buf_main_price-list.doc-qnty
        p-cur-VAT-base      = vat-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-SLT-base      = slt-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-road-tax-base = road-tax-rubl-sale-prl * buf_main_price-list.doc-qnty
        p-cur-excise-base   = excise-rubl-sale-prl * buf_main_price-list.doc-qnty
      .
    end.
      define variable v-unit-base like ub.goods.unit-base no-undo .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run unitbase in g#library
  (input  buf_goods.gds-code
  ,output v-unit-base
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info26 skip
          "Ошибка при определении базовой единицы измерения товара" skip
          "Код товара" buf_goods.gds-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
      end.
      for each buf_price-list no-lock
        where buf_price-list.doc-num    = buf_main_price-list.doc-num
          and buf_price-list.main-price = false
          and buf_price-list.artic      = buf_main_price-list.artic
          and buf_price-list.prod-type  = buf_main_price-list.prod-type
          and buf_price-list.prod-code  = buf_main_price-list.prod-code
      :
        if buf_price-list.doc-qnty = ?
        then do:
          find first buf_bar-code no-lock
            where buf_bar-code.b-code = buf_price-list.b-code
            no-error .
          if available buf_bar-code
          and buf_bar-code.unit-cli = v-unit-base
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info26 skip
              "Ошибка при закрытии переоценки" skip
              "Не задано количество для бар-кода с основной единицей измерения" skip
              "Переоценка" buf_main_price-list.doc-num skip
              "Бар-код" buf_price-list.b-code skip
              "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
              "Количество" buf_price-list.doc-qnty skip
              "Основная единица измерения" v-unit-base skip
              "Единица измерения бар-кода" buf_bar-code.unit-cli skip
              view-as alert-box error .
            undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
          end.
          next .
        end.
        if not can-find
          (first buf_bar-code
          where buf_bar-code.b-code = buf_price-list.b-code
          )
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info26 skip
            "В переоценке задан несуществующий бар-код" skip
            "Переоценка" buf_price-list.doc-num skip
            "Артикул" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
            "Бар-код" buf_price-list.b-code skip
            view-as alert-box error .
          undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
        end.
        if buf_price-list.doc-qnty <> 0
        then do:
          run prl-vat in this-procedure
            (input  recid(buf_price-list)
            ,output price-rubl-with-tax-sale-prl
            ,output price-base-with-tax-sale-prl
            ,output price-rubl-without-tax-sale-prl
            ,output price-base-without-tax-sale-prl
            ,output vat-base-sale-prl
            ,output vat-rubl-sale-prl
            ,output vat-base-buyer-prl
            ,output vat-rubl-buyer-prl
            ,output slt-base-sale-prl
            ,output slt-rubl-sale-prl
            ,output road-tax-base-sale-prl
            ,output road-tax-rubl-sale-prl
            ,output excise-base-sale-prl
            ,output excise-rubl-sale-prl
            ,output discnt-base-sale-prl
            ,output discnt-rubl-sale-prl
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info26 skip
              "Ошибка при вызове процеды prl-vat" skip
              "Документ" buf_price-list.doc-num skip
              "Артикул" buf_price-list.artic buf_price-list.prod-type buf_price-list.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error substitute("  &1 &2 " , return-value , error-status :get-message(1)  ) .
          end.
        end.
        else do:
          assign
            price-rubl-with-tax-sale-prl    = 0
            price-base-with-tax-sale-prl    = 0
            price-rubl-without-tax-sale-prl = 0
            price-base-without-tax-sale-prl = 0
            vat-base-sale-prl               = 0
            vat-rubl-sale-prl               = 0
            vat-base-buyer-prl              = 0
            vat-rubl-buyer-prl              = 0
            slt-base-sale-prl               = 0
            slt-rubl-sale-prl               = 0
            road-tax-base-sale-prl          = 0
            road-tax-rubl-sale-prl          = 0
            excise-base-sale-prl            = 0
            excise-rubl-sale-prl            = 0
            discnt-base-sale-prl            = 0
            discnt-rubl-sale-prl            = 0
          .
        end.
        if v-curr-r-b = 'base':U
        then do:
          assign
            p-fact-qnty         = p-fact-qnty
                                + buf_price-list.doc-qnty
            p-cur-base          = p-cur-base
                                + price-base-with-tax-sale-prl * buf_price-list.doc-qnty
            p-cur-VAT-base      = p-cur-VAT-base
                                + vat-base-sale-prl * buf_price-list.doc-qnty
            p-cur-SLT-base      = p-cur-SLT-base
                                + slt-base-sale-prl * buf_price-list.doc-qnty
            p-cur-road-tax-base = p-cur-road-tax-base
                                + road-tax-base-sale-prl * buf_price-list.doc-qnty
            p-cur-excise-base   = p-cur-excise-base
                                + excise-base-sale-prl * buf_price-list.doc-qnty
          .
        end.
        else do:
          assign
            p-fact-qnty         = p-fact-qnty
                                + buf_price-list.doc-qnty
            p-cur-base          = p-cur-base
                                + price-rubl-with-tax-sale-prl * buf_price-list.doc-qnty
            p-cur-VAT-base      = p-cur-VAT-base
                                + vat-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-SLT-base      = p-cur-SLT-base
                                + slt-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-road-tax-base = p-cur-road-tax-base
                                + road-tax-rubl-sale-prl * buf_price-list.doc-qnty
            p-cur-excise-base   = p-cur-excise-base
                                + excise-rubl-sale-prl * buf_price-list.doc-qnty
          .
        end.
      end.
  end.
end procedure.
procedure prdoclib-calc-prc :
  define input  parameter p-price-doc-recid as   recid                  no-undo.
  define input  parameter p-cons-pay        as   integer                no-undo.
  define output parameter p-ov-cons         like ub.doc-line.price-base no-undo.
  define output parameter p-ov-VAT-cons     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-SLT-cons     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-prch         like ub.doc-line.price-base no-undo.
  define output parameter p-ov-VAT-prch     like ub.doc-line.price-base no-undo.
  define output parameter p-ov-SLT-prch     like ub.doc-line.price-base no-undo.
  do
  on error undo, return error return-value
  :
    define buffer buf_price-doc       for ub.price-doc .
    define buffer buf_price-list      for ub.price-list .
    define buffer buf_parts           for ub.parts .
    define variable v-ov-qnty     as decimal   no-undo .
    define variable v-ov-base     as decimal   no-undo .
    define variable v-ov-VAT-base as decimal   no-undo .
    define variable v-ov-SLT-base as decimal   no-undo .
    define variable v-cons-qnty   as decimal   no-undo .
    define variable v-prch-qnty   as decimal   no-undo .
    define variable v-cons-mult   as decimal   no-undo .
    define variable v-prch-mult   as decimal   no-undo .
    find first buf_price-doc no-lock
      where recid(buf_price-doc) = p-price-doc-recid
      no-error .
    if not available buf_price-doc
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Ошибка задания входных параметров" skip
        "Не найден документ переоценки" skip
        "Код записи (recid)" p-price-doc-recid skip
        view-as alert-box error .
      undo, return error .
    end.
    for each buf_price-list no-lock
      where buf_price-list.doc-num    = buf_price-doc.doc-num
        and buf_price-list.main-price = true
    on error undo, return error return-value
    :
      run prdoclib-calc-ov
        (input recid(buf_price-list)
        ,output v-ov-qnty
        ,output v-ov-base
        ,output v-ov-VAT-base
        ,output v-ov-SLT-base
        ) no-error .
      if error-status :error
      then do:
        if error-status :get-message(1) <> ""
        then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info26 skip
            "Ошибка при вызове процедуры prdoclib-calc-ov" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
        end.
        undo, return error return-value .
      end.
      assign
        v-cons-qnty = 0
        v-prch-qnty = 0
      .
      for each buf_parts no-lock
        where buf_parts.out-code  = buf_price-list.doc-num
          and buf_parts.obj-type  = buf_price-list.obj-type
          and buf_parts.obj-code  = buf_price-list.obj-code
          and buf_parts.artic     = buf_price-list.artic
          and buf_parts.prod-type = buf_price-list.prod-type
          and buf_parts.prod-code = buf_price-list.prod-code
      on error undo, return error return-value
      :
        if buf_parts.pay-code = p-cons-pay
        then do:
          assign
            v-cons-qnty = v-cons-qnty + buf_parts.fact-qnty
          .
        end.
        else do:
          assign
            v-prch-qnty = v-prch-qnty + buf_parts.fact-qnty
          .
        end.
      end.
      if (v-cons-qnty + v-prch-qnty) = 0
      then do:
        assign
          v-cons-mult = 0
          v-prch-mult = 1
        .
      end.
      else do:
        assign
          v-cons-mult = v-cons-qnty / (v-cons-qnty + v-prch-qnty)
          v-prch-mult = v-prch-qnty / (v-cons-qnty + v-prch-qnty)
        .
      end.
      assign
        p-ov-cons     = p-ov-cons     + v-ov-base     * v-cons-mult
        p-ov-VAT-cons = p-ov-VAT-cons + v-ov-VAT-base * v-cons-mult
        p-ov-SLT-cons = p-ov-SLT-cons + v-ov-SLT-base * v-cons-mult
        p-ov-prch     = p-ov-prch     + v-ov-base     * v-prch-mult
        p-ov-VAT-prch = p-ov-VAT-prch + v-ov-VAT-base * v-prch-mult
        p-ov-SLT-prch = p-ov-SLT-prch + v-ov-SLT-base * v-prch-mult
      .
    end.
  end.
end procedure.
procedure prdoclib-calc-ov :
  define input  parameter p-price-list-recid as recid     no-undo .
  define output parameter p-fact-qnty        as decimal   no-undo .
  define output parameter p-ov-base          as decimal   no-undo .
  define output parameter p-ov-VAT-base      as decimal   no-undo .
  define output parameter p-ov-SLT-base      as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_main_price-list    for ub.price-list .
    define buffer buf_prev_price-list    for ub.price-list .
    define buffer buf_special_price-list for ub.price-list .
    define buffer buf_goods              for ub.goods .
    define variable v-fact-qnty             like ub.doc-line.price-base no-undo.
    define variable v-cur-base              like ub.doc-line.price-base no-undo.
    define variable v-cur-VAT-base          like ub.doc-line.price-base no-undo.
    define variable v-cur-SLT-base          like ub.doc-line.price-base no-undo.
    define variable v-cur-road-tax-base     like ub.doc-line.price-base no-undo.
    define variable v-cur-excise-base       like ub.doc-line.price-base no-undo.
    define variable v-prev-price-list-recid as   recid                  no-undo.
    define variable v-prev-cli-base-rate    like ub.goods.cli-base-rate no-undo.
    define variable v-prev-fact-qnty        like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-base         like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-VAT-base     like ub.doc-line.price-base no-undo.
    define variable v-prev-cur-SLT-base     like ub.doc-line.price-base no-undo.
    find first buf_main_price-list no-lock
      where recid(buf_main_price-list) = p-price-list-recid
      no-error .
    if not available buf_main_price-list
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Ошибка задания входных параметров" skip
        "Не найдена строка переоценки" skip
        "Код записи (recid)" p-price-list-recid skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_main_price-list.main-price <> true
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Ошибка задания входных параметров" skip
        "Строка переоценки не является основной" skip
        "Код записи (recid)" p-price-list-recid skip
        "Переоценка" buf_main_price-list.doc-num skip
        "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        "Бар-код" buf_main_price-list.b-code skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-calc-fact-sale in this-procedure
      (input  recid(buf_main_price-list)
      ,output v-fact-qnty
      ,output v-cur-base
      ,output v-cur-VAT-base
      ,output v-cur-SLT-base
      ,output v-cur-road-tax-base
      ,output v-cur-excise-base
      ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Ошибка при расчете сумм переоценки." skip
        "Документ переоценки" buf_main_price-list.doc-num skip
        "Товар" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  buf_main_price-list.obj-type
  ,input  buf_main_price-list.obj-code
  ,input  buf_main_price-list.b-code
  ,input  buf_main_price-list.b-code
  ,input  buf_main_price-list.fact-order
  ,output v-prev-price-list-recid
  ,output v-prev-cli-base-rate
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Ошибка при поиске предыдущей переоценки." skip
        "Документ переоценки " buf_main_price-list.doc-num skip
        "Товар " buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    if v-prev-price-list-recid <> ?
    then do:
      find first buf_prev_price-list no-lock
        where recid(buf_prev_price-list) = v-prev-price-list-recid
        .
      find first buf_special_price-list no-lock
        where buf_special_price-list.doc-num    = buf_prev_price-list.doc-num
          and buf_special_price-list.main-price = false
          and buf_special_price-list.artic      = buf_prev_price-list.artic
          and buf_special_price-list.prod-type  = buf_prev_price-list.prod-type
          and buf_special_price-list.prod-code  = buf_prev_price-list.prod-code
          and buf_special_price-list.doc-qnty   <> ?
        no-error .
      if available buf_special_price-list
      then do:
        message
          "Товар имеет специальные цены на признаки" skip
          "Разбиение суммы переоценки по консигнации, выкупу невозможно" skip
          "Переоценка" buf_prev_price-list.doc-num skip
          "Товар" buf_prev_price-list.artic buf_prev_price-list.prod-type buf_prev_price-list.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.
      find first buf_goods no-lock
        where buf_goods.artic     = buf_main_price-list.artic
          and buf_goods.prod-type = buf_main_price-list.prod-type
          and buf_goods.prod-code = buf_main_price-list.prod-code
        no-error .
      if not available buf_goods
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info26 skip
          "Не найден товар" skip
          "Переоценка" buf_main_price-list.doc-num skip
          "Артикул" buf_main_price-list.artic buf_main_price-list.prod-type buf_main_price-list.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.
      if buf_prev_price-list.vat-pc = ?
      or buf_prev_price-list.slt-pc = ?
      then do:
        message
          "В переоценке не заданы налоги товара" skip
          "Разбиение суммы переоценки по консигнации, выкупу невозможно" skip
          "Переоценка" buf_prev_price-list.doc-num skip
          "Товар" buf_prev_price-list.artic buf_prev_price-list.prod-type buf_prev_price-list.prod-code skip
          "НДС" buf_prev_price-list.vat-pc skip
          "НП" buf_prev_price-list.slt-pc skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      define variable v-prev-cur-SLT-pc as decimal no-undo .
      assign
        v-prev-cur-SLT-pc   = buf_prev_price-list.price-sale * buf_prev_price-list.slt-pc / (100 + buf_prev_price-list.slt-pc)
      .
      assign
        v-prev-cur-base     = v-fact-qnty * buf_prev_price-list.price-sale
        v-prev-cur-VAT-base = v-fact-qnty
                            * (buf_prev_price-list.price-sale - v-prev-cur-SLT-pc)
                            * buf_prev_price-list.vat-pc / (100 + buf_prev_price-list.vat-pc)
        v-prev-cur-SLT-base = v-fact-qnty * v-prev-cur-SLT-pc
      .
      assign
        p-fact-qnty   = v-fact-qnty
        p-ov-base     = v-cur-base     - v-prev-cur-base
        p-ov-VAT-base = v-cur-VAT-base - v-prev-cur-VAT-base
        p-ov-SLT-base = v-cur-SLT-base - v-prev-cur-SLT-base
      .
    end.
    else do:
      assign
        v-prev-cur-base     = 0
        v-prev-cur-VAT-base = 0
        v-prev-cur-SLT-base = 0
        .
      assign
        p-fact-qnty   = v-fact-qnty
        p-ov-base     = v-cur-base     - v-prev-cur-base
        p-ov-VAT-base = v-cur-VAT-base - v-prev-cur-VAT-base
        p-ov-SLT-base = v-cur-SLT-base - v-prev-cur-SLT-base
      .
    end.
  end.
end procedure.
procedure prdoclib-init-prt-obj-by-factord :
  define input parameter p-obj-type           like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code           like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic              like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type          like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code          like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-prt-obj-by-factord: определение остатков по признакам на любой момент времени".
  define buffer buf_gds-obj      for ub.gds-obj .
  define buffer buf_doc-line     for ub.doc-line .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-total-gds-dtl-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    do transaction
    on error undo, return error return-value
    :
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info26 skip
          "Невозможно найти gds-obj" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    run prdoclib-init-temp-prt-obj in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input 0
      ) .
    for each buf_temp-prt-obj
      where buf_temp-prt-obj.is-term <> true
    on error undo, return error return-value
    :
      delete buf_temp-prt-obj .
    end.
    if p-include-fact-order = true
    then do:
      assign
       p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order >= p-fact-order
    on error undo, return error return-value
    :
      run prdoclib-process-document in this-procedure
        (input  buf_doc-line.doc-code
        ,input  p-obj-type
        ,input  p-obj-code
        ,input  p-artic
        ,input  p-prod-type
        ,input  p-prod-code
        ,output v-total-gds-dtl-qnty
        ) .
    end.
  end.
end procedure.
procedure prdoclib-process-document :
  define input  parameter p-doc-code           as character no-undo .
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-artic              as character no-undo .
  define input  parameter p-prod-type          as character no-undo .
  define input  parameter p-prod-code          as integer   no-undo .
  define output parameter p-total-gds-dtl-qnty as decimal   no-undo .
  define buffer buf_trn-doc      for ub.trn-doc .
  define buffer buf_gds-dtl      for ub.gds-dtl .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  do
  on error undo, return error return-value
  :
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Ошибка при поиске документа" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-total-gds-dtl-qnty = 0
    .
    for each buf_gds-dtl no-lock
      where buf_gds-dtl.doc-code  = p-doc-code
        and buf_gds-dtl.artic     = p-artic
        and buf_gds-dtl.prod-type = p-prod-type
        and buf_gds-dtl.prod-code = p-prod-code
    on error undo, return error
    :
      define variable v-term-node as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  buf_gds-dtl.prt-code
  ,output v-term-node
  )  .
      run prdoclib-temp-prt-obj-by-prt-root in this-procedure
        (input  v-term-node
        ,buffer buf_temp-prt-obj
        ) .
      if buf_temp-prt-obj.is-term <> true then do:
        undo, return error substitute("Документ ссылается на нетерминальный признак. Код признака &1"
                                     ,buf_gds-dtl.prt-code
                                     ) .
      end.
      case buf_trn-doc.doc-type :
        when 'при':U or
        when 'возврат':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        - buf_gds-dtl.fact-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        - buf_gds-dtl.fact-qnty
          .
        end.
        when 'рас':U or
        when 'спи':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        + buf_gds-dtl.fact-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        + buf_gds-dtl.fact-qnty
          .
        end.
        when 'инв':U
        then do:
          assign
            p-total-gds-dtl-qnty        = p-total-gds-dtl-qnty
                                        - buf_gds-dtl.doc-qnty
            buf_temp-prt-obj.fact-qnty  = buf_temp-prt-obj.fact-qnty
                                        - buf_gds-dtl.doc-qnty
          .
        end.
        otherwise do:
          undo, return error substitute("Неизвестный тип документа &1"
                                       ,buf_trn-doc.doc-type
                                       ) .
        end.
      end.
    end.
  end.
end procedure.
procedure prdoclib-prc-pl-document :
  define input  parameter p-doc-code              as character no-undo .
  define input  parameter p-obj-type              as character no-undo .
  define input  parameter p-obj-code              as integer   no-undo .
  define input  parameter p-gds-code              as integer   no-undo .
  define output parameter p-total-pl-gds-qnty     as decimal   no-undo .
  define output parameter p-total-pl-gds-cli-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    define buffer buf_trn-doc      for ub.trn-doc .
    define buffer buf_doc-pl       for ub.doc-pl .
    define buffer buf_temp-pl-gds for temp-pl-gds .
    define variable v-sign as decimal   no-undo .
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code
      no-error .
    if not available buf_trn-doc then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Ошибка при поиске документа" skip
        "Документ" p-doc-code skip
        "Объект" p-obj-type p-obj-code skip
        "Товар" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      p-total-pl-gds-qnty     = 0
      p-total-pl-gds-cli-qnty = 0
    .
    for each buf_doc-pl no-lock
      where buf_doc-pl.out-code  = p-doc-code
        and buf_doc-pl.gds-code  = p-gds-code
    on error undo, return error return-value
    :
      find first buf_temp-pl-gds
        where buf_temp-pl-gds.obj-type = buf_trn-doc.obj-type
          and buf_temp-pl-gds.obj-code = buf_trn-doc.obj-code
          and buf_temp-pl-gds.pl-code  = buf_doc-pl.pl-code
        .
      case buf_trn-doc.doc-type :
        when 'при':U
        or when 'возврат':U
        or when 'инв':U
        then do:
          assign
            v-sign = -1.0
          .
        end.
        when 'рас':U or
        when 'спи':U
        then do:
          assign
            v-sign = 1.0
          .
        end.
        otherwise do:
          undo, return error substitute("(prdoclib-prc-pl-document) Неизвестный тип документа &1", buf_trn-doc.doc-type ) .
        end.
      end case.
      assign
        p-total-pl-gds-qnty           = p-total-pl-gds-qnty           + buf_doc-pl.fact-qnty     * v-sign
        p-total-pl-gds-cli-qnty       = p-total-pl-gds-cli-qnty       + buf_doc-pl.cli-fact-qnty * v-sign
        buf_temp-pl-gds.fact-qnty     = buf_temp-pl-gds.fact-qnty     + buf_doc-pl.fact-qnty     * v-sign
        buf_temp-pl-gds.cli-fact-qnty = buf_temp-pl-gds.cli-fact-qnty + buf_doc-pl.cli-fact-qnty * v-sign
      .
    end.
  end.
end procedure.
procedure prdoclib-init-prt-obj-by-date :
  define input parameter p-obj-type   like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code   like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic      like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type  like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code  like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-date  as date      no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-prt-obj-by-date: определение остатков по признакам на конец дня".
  do
  on error undo, return error return-value
  :
    define variable v-fact-order                as decimal   no-undo .
    define variable v-shift-end-fact-order      as decimal   no-undo .
    define variable v-day-end-fact-order        as decimal   no-undo .
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  ?
      ,input  0
      ,input  false
      ,output v-fact-order
      ,output v-shift-end-fact-order
      ,output v-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Ошибка при определении момента времени, на который требуется остаток" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
    run prdoclib-init-prt-obj-by-date-factord in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input p-artic
      ,input p-prod-type
      ,input p-prod-code
      ,input v-day-end-fact-order
      ,input false
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info26 skip
        "Ошибка при вызове метода prdoclib-init-prt-obj-by-date-factord" skip
        "Объект" p-obj-type p-obj-code skip
        "Артикул" p-artic p-prod-type p-prod-code skip
        "Дата" p-fact-date skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
end procedure.
procedure prdoclib-calc-temp-fact-sale :
  define input  parameter p-obj-type           as character no-undo .
  define input  parameter p-obj-code           as integer   no-undo .
  define input  parameter p-gds-code           as integer   no-undo .
  define input  parameter p-day-end-fact-order as decimal   no-undo .
  define input  parameter p-curr-r-b           as character no-undo .
  define output parameter p-fact-qnty          as decimal   no-undo .
  define output parameter p-cur-base           as decimal   no-undo .
  define output parameter p-cur-VAT-base       as decimal   no-undo .
  define output parameter p-cur-SLT-base       as decimal   no-undo .
  define output parameter p-cur-road-tax-base  as decimal   no-undo .
  define output parameter p-cur-excise-base    as decimal   no-undo .
  define buffer buf_temp-prt-obj for temp-prt-obj .
  define variable v-prt-b-code        like ub.bar-code.b-code no-undo .
  define variable v-cli-base-rate     like ub.bar-code.cli-base-rate no-undo .
  define variable parrecid-prl        as recid     no-undo .
  define variable v-fact-qnty         as decimal   no-undo .
  define variable v-cur-base          as decimal   no-undo .
  define variable v-cur-VAT-base      as decimal   no-undo .
  define variable v-cur-SLT-base      as decimal   no-undo .
  define variable v-cur-road-tax-base as decimal   no-undo .
  define variable v-cur-excise-base   as decimal   no-undo .
  define variable price-rubl-with-tax-sale-prl    as decimal   no-undo .
  define variable price-base-with-tax-sale-prl    as decimal   no-undo .
  define variable price-rubl-without-tax-sale-prl as decimal   no-undo .
  define variable price-base-without-tax-sale-prl as decimal   no-undo .
  define variable vat-base-sale-prl               as decimal   no-undo .
  define variable vat-rubl-sale-prl               as decimal   no-undo .
  define variable vat-base-buyer-prl              as decimal   no-undo .
  define variable vat-rubl-buyer-prl              as decimal   no-undo .
  define variable slt-base-sale-prl               as decimal   no-undo .
  define variable slt-rubl-sale-prl               as decimal   no-undo .
  define variable road-tax-base-sale-prl          as decimal   no-undo .
  define variable road-tax-rubl-sale-prl          as decimal   no-undo .
  define variable excise-base-sale-prl            as decimal   no-undo .
  define variable excise-rubl-sale-prl            as decimal   no-undo .
  define variable discnt-base-sale-prl            as decimal   no-undo .
  define variable discnt-rubl-sale-prl            as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    for each buf_temp-prt-obj no-lock
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  buf_temp-prt-obj.prt-code
  ,output v-prt-b-code
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении бар-кода признака" skip
          "Код товара"   p-gds-code skip
          "Код признака" buf_temp-prt-obj.prt-code skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  v-prt-b-code
  ,input  0
  ,input  p-day-end-fact-order
  ,output parrecid-prl
  ,output v-cli-base-rate
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении цены бар-кода" skip
          "Объект" p-obj-type p-obj-code skip
          "Бар-код" v-prt-b-code skip
          "fact-order" p-day-end-fact-order skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
      if parrecid-prl <> ?
      then do:
        run prl-vat in this-procedure
          (input  parrecid-prl
          ,output price-rubl-with-tax-sale-prl
          ,output price-base-with-tax-sale-prl
          ,output price-rubl-without-tax-sale-prl
          ,output price-base-without-tax-sale-prl
          ,output vat-base-sale-prl
          ,output vat-rubl-sale-prl
          ,output vat-base-buyer-prl
          ,output vat-rubl-buyer-prl
          ,output slt-base-sale-prl
          ,output slt-rubl-sale-prl
          ,output road-tax-base-sale-prl
          ,output road-tax-rubl-sale-prl
          ,output excise-base-sale-prl
          ,output excise-rubl-sale-prl
          ,output discnt-base-sale-prl
          ,output discnt-rubl-sale-prl
          ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при вызове процеды prl-vat" skip
            "Объект" p-obj-type p-obj-code skip
            "Код товара" p-gds-code skip
            "Указатель на запись переоценки" parrecid-prl skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
      else do:
        assign
          price-rubl-with-tax-sale-prl    = 0
          price-base-with-tax-sale-prl    = 0
          price-rubl-without-tax-sale-prl = 0
          price-base-without-tax-sale-prl = 0
          vat-base-sale-prl               = 0
          vat-rubl-sale-prl               = 0
          slt-base-sale-prl               = 0
          slt-rubl-sale-prl               = 0
          road-tax-base-sale-prl          = 0
          road-tax-rubl-sale-prl          = 0
          excise-base-sale-prl            = 0
          excise-rubl-sale-prl            = 0
          discnt-base-sale-prl            = 0
          discnt-rubl-sale-prl            = 0
        .
      end.
      assign
        v-fact-qnty         = v-fact-qnty
                            + buf_temp-prt-obj.fact-qnty
        v-cur-base          = v-cur-base
                            + (if p-curr-r-b = 'base':U
                                then price-base-with-tax-sale-prl
                                else price-rubl-with-tax-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-VAT-base      = v-cur-VAT-base
                            + (if p-curr-r-b = 'base':U
                                then vat-base-sale-prl
                                else vat-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-SLT-base      = v-cur-SLT-base
                            + (if p-curr-r-b = 'base':U
                                then slt-base-sale-prl
                                else slt-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-road-tax-base = v-cur-road-tax-base
                            + (if p-curr-r-b = 'base':U
                                then road-tax-base-sale-prl
                                else road-tax-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
        v-cur-excise-base   = v-cur-excise-base
                            + (if p-curr-r-b = 'base':U
                                then excise-base-sale-prl
                                else excise-rubl-sale-prl
                              )
                            * buf_temp-prt-obj.fact-qnty
      .
    end.
    assign
      p-fact-qnty         = v-fact-qnty
      p-cur-base          = v-cur-base
      p-cur-VAT-base      = v-cur-VAT-base
      p-cur-SLT-base      = v-cur-SLT-base
      p-cur-road-tax-base = v-cur-road-tax-base
      p-cur-excise-base   = v-cur-excise-base
    .
  end.
end procedure.
procedure prdoclib-clear-temp-pl-gds :
  define buffer buf_temp-pl-gds for temp-pl-gds .
  do
  on error undo, return error return-value
  :
    for each buf_temp-pl-gds
    on error undo, return error return-value
    :
      delete buf_temp-pl-gds .
    end.
  end.
end procedure.
procedure prdoclib-init-temp-pl-gds :
  define input parameter p-obj-type        like ub.pl-gds.obj-type  no-undo .
  define input parameter p-obj-code        like ub.pl-gds.obj-code  no-undo .
  define input parameter p-gds-code        like ub.pl-gds.gds-code  no-undo .
  define buffer buf_pl-gds      for ub.pl-gds .
  define buffer buf_temp-pl-gds for temp-pl-gds .
  do
  on error undo, return error return-value
  :
    run prdoclib-clear-temp-pl-gds in this-procedure .
    for each buf_pl-gds
      where buf_pl-gds.obj-type = p-obj-type
        and buf_pl-gds.obj-code = p-obj-code
        and buf_pl-gds.gds-code = p-gds-code
    on error undo, return error return-value
    :
      create buf_temp-pl-gds .
      buffer-copy buf_pl-gds to buf_temp-pl-gds .
    end.
  end.
end procedure.
procedure prdoclib-init-pl-gds-by-factord :
  define input parameter p-obj-type           like ub.gds-obj.obj-type  no-undo .
  define input parameter p-obj-code           like ub.gds-obj.obj-code  no-undo .
  define input parameter p-artic              like ub.gds-obj.artic     no-undo .
  define input parameter p-prod-type          like ub.gds-obj.prod-type no-undo .
  define input parameter p-prod-code          like ub.gds-obj.prod-code no-undo .
  define input parameter p-fact-order         as decimal   no-undo .
  define input parameter p-include-fact-order as logical   no-undo .
  define variable vss-description as character no-undo init "prdoclib-init-pl-gds-by-factord: определение остатков по признакам на любой момент времени".
  define buffer buf_goods       for ub.goods .
  define buffer buf_gds-obj     for ub.gds-obj .
  define buffer buf_doc-line    for ub.doc-line .
  define buffer buf_temp-pl-gds for temp-pl-gds .
  define variable v-total-pl-gds-qnty     as decimal   no-undo .
  define variable v-total-pl-gds-cli-qnty as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    do transaction
    on error undo, return error return-value
    :
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info26 skip
          "Невозможно найти gds-obj" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find current buf_gds-obj exclusive-lock .
    end.
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    run prdoclib-init-temp-pl-gds in this-procedure
      (input p-obj-type
      ,input p-obj-code
      ,input buf_goods.gds-code
      ) .
    if p-include-fact-order = true
    then do:
      assign
       p-fact-order = p-fact-order - 0.0000000001
      .
    end.
    for each buf_doc-line no-lock
      where buf_doc-line.obj-type   = p-obj-type
        and buf_doc-line.obj-code   = p-obj-code
        and buf_doc-line.artic      = p-artic
        and buf_doc-line.prod-type  = p-prod-type
        and buf_doc-line.prod-code  = p-prod-code
        and buf_doc-line.status_    = 'факт':U
        and buf_doc-line.fact-order >= p-fact-order
    on error undo, return error return-value
    :
      run prdoclib-prc-pl-document in this-procedure
        ( input  buf_doc-line.doc-code
         ,input  p-obj-type
         ,input  p-obj-code
         ,input  buf_goods.gds-code
         ,output v-total-pl-gds-qnty
         ,output v-total-pl-gds-cli-qnty
        ) .
    end.
  end.
end procedure.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure factord :
  define input  parameter p-fact-date            as date    no-undo .
  define input  parameter p-fact-time            as integer no-undo .
  define input  parameter p-fact-num             as integer no-undo .
  define input  parameter p-shift-date           as date    no-undo .
  define input  parameter p-shift-num            as integer no-undo .
  define input  parameter p-shift-on             as logical no-undo .
  define output parameter p-fact-order           as decimal no-undo .
  define output parameter p-shift-end-fact-order as decimal no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  define variable vss-description as character no-undo init "factord: Определение порядкового номера документа".
  if p-fact-date = ?
  then do:
    return error "Не указана фактическая дата" .
  end.
  define variable v-fact-date-num as integer no-undo .
  assign
    v-fact-date-num = integer(p-fact-date)
  .
  if p-fact-num = ?
  or p-fact-num = 0
  then do:
    return error "Не задан p-fact-num " + string(p-fact-num) .
  end.
  if p-fact-num < 0
  then do:
    return error "Отрицательный fact-num " + string(p-fact-num) .
  end.
  if p-fact-num >= 100000000
  then do:
    return error "Недопустимо большой fact-num " + string(p-fact-num) .
  end.
  if p-shift-on = true
  then do:
    if p-shift-date = ?
    then do:
      return error "Не задана дата смены" .
    end.
    if p-shift-num = ?
    or p-shift-num = 0
    then do:
      return error "Не задан номер смены" .
    end.
  end.
  else do:
    assign
      p-shift-date = p-fact-date
      p-shift-num  = 24
    .
  end.
  define variable v-shift-offset as integer no-undo .
  if p-shift-date = p-fact-date
  then do:
    assign
      v-shift-offset = 1
    .
  end.
  if p-shift-date < p-fact-date
  then do:
    assign
      v-shift-offset = 0
    .
  end.
  if p-shift-date > p-fact-date
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильная дата закрытия смены" skip
      "Дата закрытия не смены не может быть раньше чем дата открытия смены" skip
      view-as alert-box error .
    undo, return error
      substitute("Дата закрытия не смены &1 не может быть раньше чем дата открытия смены &2"
        ,string(p-fact-date, '99/99/9999':U)
        ,string(p-shift-date, '99/99/9999':U)
        )
    .
  end.
  if p-shift-num < 1
  or p-shift-num > 24
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Неправильный номер смены" skip
      "p-shift-num" p-shift-num skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    p-fact-order           = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02 - 0.01
                           + p-fact-num     * 0.0000000001
    p-shift-end-fact-order = v-fact-date-num
                           + v-shift-offset * 0.5
                           + p-shift-num    * 0.02
    p-day-end-fact-order   = v-fact-date-num
                           + 0.99
  .
  if p-fact-order           <= v-fact-date-num
  or p-shift-end-fact-order <= v-fact-date-num
  or p-fact-order           >= p-shift-end-fact-order - 0.0000000001
  or p-shift-end-fact-order >= p-day-end-fact-order
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Внутренняя ошибка при генерации фактического номера" skip
      "p-fact-date"            p-fact-date            skip
      "p-fact-time"            p-fact-time            skip
      "p-fact-num"             p-fact-num             skip
      "p-shift-date"           p-shift-date           skip
      "p-shift-num"            p-shift-num            skip
      "p-shift-on"             p-shift-on             skip
      "p-shift-end-fact-order" p-shift-end-fact-order skip
      "p-day-end-fact-order"   p-day-end-fact-order   skip
      "v-fact-date-num"        v-fact-date-num        skip
      view-as alert-box error .
    undo, return error return-value .
  end.
end procedure.
procedure day-begin-fact-order :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-begin-fact-order as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      assign
        p-day-begin-fact-order = 0
      .
    end.
    else do:
      assign
        p-day-begin-fact-order = integer(p-fact-date)
      .
    end.
  end.
end procedure.
procedure factord-max-fact-order :
  define output parameter p-max-fact-order as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    run day-begin-fact-order in this-procedure
      (input  date(1, 1, 5000)
      ,output p-max-fact-order
      ) .
  end.
end procedure.
procedure factord-cut-archive :
  define input  parameter p-obj-type             as character no-undo .
  define input  parameter p-obj-code             as integer   no-undo .
  define input  parameter p-fact-date            as date      no-undo .
  define output parameter p-shift-on             as logical   no-undo .
  define output parameter p-shift-date           as date      no-undo .
  define output parameter p-shift-num            as integer   no-undo .
  define output parameter p-day-end-fact-order   as decimal   no-undo .
  define output parameter p-shift-end-fact-order as decimal   no-undo .
  define variable v-fact-order as decimal   no-undo .
  define buffer buf_shift-obj for ub.shift-obj .
  do
  on error undo, return error return-value
  :
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output p-shift-on
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении атрибута объекта" skip
        "Объект" p-obj-type p-obj-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-shift-on = false
    then do:
      assign
        p-shift-date               = ?
        p-shift-num                = 0
      .
    end.
    else do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно вычислить последнюю смену" skip
          "Отсутствует закрытая смена с датой большей чем дата инициализации архива" skip
          "Объект" p-obj-type p-obj-code skip
          "Дата" p-fact-date skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find last buf_shift-obj share-lock
        where buf_shift-obj.obj-type = p-obj-type
          and buf_shift-obj.obj-code = p-obj-code
          and buf_shift-obj.shift-date <= p-fact-date
        use-index pi
        no-error .
      if available buf_shift-obj
      then do:
        if  buf_shift-obj.status_ = 'зкр':U
        then do:
          assign
            p-shift-date = buf_shift-obj.shift-date
            p-shift-num  = buf_shift-obj.shift-num
          .
        end.
        else do:
          message
            vss-workfile vss-revision vss-description skip
            "Невозможно вычислить последнюю смену" skip
            "Статус смены отличен от статуса" 'зкр':U skip
            "Объект" p-obj-type p-obj-code skip
            "Дата" p-fact-date skip
            "Смена" buf_shift-obj.shift-date buf_shift-obj.shift-num skip
            view-as alert-box error .
          undo, return error return-value .
        end.
      end.
      else do:
        assign
          p-shift-date = p-fact-date - 1
          p-shift-num  = 1
        .
      end.
    end.
    run factord in this-procedure
      (input  p-fact-date
      ,input  1
      ,input  1
      ,input  p-shift-date
      ,input  p-shift-num
      ,input  p-shift-on
      ,output v-fact-order
      ,output p-shift-end-fact-order
      ,output p-day-end-fact-order
      ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при вызове процедуры factord"
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
  end.
end procedure.
procedure factord-lock-shift :
  define input  parameter p-obj-type  as character no-undo .
  define input  parameter p-obj-code  as integer   no-undo .
  define input  parameter p-fact-date as date      no-undo .
  define parameter buffer buf_shift-obj for ub.shift-obj .
  define variable v-shift-on      as logical   no-undo .
  define variable v-extra-message as character no-undo .
  define variable v-error as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
      v-error = substitute("Ошибка при определении атрибута объекта  &1 &2 &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value) .
      undo, return error v-error .
    end.
    if v-shift-on = true
    then do:
      find first buf_shift-obj share-lock
        where buf_shift-obj.obj-type   = p-obj-type
          and buf_shift-obj.obj-code   = p-obj-code
          and buf_shift-obj.shift-date > p-fact-date
        use-index pi
        no-error .
      if not available buf_shift-obj
      or buf_shift-obj.status_ <> 'зкр':U
      then do:
        find last buf_shift-obj
          where buf_shift-obj.obj-type = p-obj-type
            and buf_shift-obj.obj-code = p-obj-code
            and buf_shift-obj.status_  = 'зкр':U
          use-index stts
          no-error .
        if available buf_shift-obj
        then do:
          assign
            v-extra-message =
                  substitute("Дата начала последеней закрытой смены на объекте &1"
                            ,string(buf_shift-obj.shift-date, '99/99/9999':u)
                            )
          .
        end.
        v-error = substitute("Ошибка при блокировке смены объекта  &1 &2 Отсутствует закрытая смена с датой большей чем указанная дата  &5  &3 &4" ,p-obj-type , p-obj-code  , error-status :get-message(1) , return-value , p-fact-date) .
        undo, return error v-error .
      end.
    end.
  end.
end procedure.
procedure factord-end-day :
  define input  parameter p-fact-date            as date    no-undo .
  define output parameter p-day-end-fact-order   as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-date = ?
    then do:
      return error "Не указана фактическая дата" .
    end.
    assign
      p-day-end-fact-order = integer(p-fact-date) + 0.99
    .
  end.
end procedure.
procedure factord-to-date :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-date  as date    no-undo .
  define variable v-ref-date  as date      no-undo .
  define variable v-ref-delta as integer   no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
      v-ref-date  = date(1, 1, 2000)
    .
    assign
      v-ref-delta = integer(truncate(p-fact-order, 0)) - integer(v-ref-date)
    .
    assign
      p-fact-date = v-ref-date + v-ref-delta
    .
  end.
end procedure.
procedure factord-to-fact-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-fact-num   as integer no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)
    .
    assign
      p-fact-num = (p-fact-order - v-fact-order-trunc ) * 10000000000
    .
  end.
end procedure.
procedure factord-to-shift-num :
  define input  parameter p-fact-order as decimal no-undo .
  define output parameter p-shift-num   as integer no-undo .
  define variable  p-shift-numd  as decimal   no-undo .
  define variable v-fact-order-trunc as decimal no-undo .
  do
  on error undo, return error return-value
  :
    if p-fact-order = ?
    or p-fact-order = 0
    then do:
      return error "Не указан fact-order" .
    end.
    assign
     v-fact-order-trunc = truncate(p-fact-order, 2)  - truncate(p-fact-order,0)
    .
    if v-fact-order-trunc < 0.5 then do:
      v-fact-order-trunc = v-fact-order-trunc + 0.5.
    end.
    assign
      p-shift-numd = (( v-fact-order-trunc  * 100 - 50 ) + 1 ) / 2
      .
     assign
      p-shift-num = truncate (p-shift-numd , 0)
    .
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
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
procedure placelib_write-attr:
define input  parameter p-code     like ub.place-attr.attr-code .
define input  parameter p-obj-code like ub.place-attr.obj-code .
define input  parameter p-obj-type like ub.place-attr.obj-type .
define input  parameter p-pl-code  like ub.place-attr.pl-code .
define input  parameter p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if not available buf_place-attr then do :
        create buf_place-attr.
        assign
          buf_place-attr.attr-code   = p-code
          buf_place-attr.attr-value  = p-value
          buf_place-attr.obj-code    = p-obj-code
          buf_place-attr.obj-type    = p-obj-type
          buf_place-attr.pl-code     = p-pl-code
        .
        p-ok = true.
     end.
     else do:
        buf_place-attr.attr-value  = p-value .
        p-ok = true.
     end.
  end.
end.
procedure placelib_get-attr:
define input  parameter  p-code     like ub.place-attr.attr-code .
define input  parameter  p-obj-code like ub.place-attr.obj-code .
define input  parameter  p-obj-type like ub.place-attr.obj-type .
define input  parameter  p-pl-code  like ub.place-attr.pl-code .
define output parameter  p-value    like ub.place-attr.attr-value .
define output parameter  p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr no-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
       p-value = buf_place-attr.attr-value.
       p-ok = true.
     end.
     else do :
       p-ok = false.
     end.
  end.
end.
procedure placelib_del-attr:
define input parameter  p-code     like ub.place-attr.attr-code .
define input parameter  p-obj-code like ub.place-attr.obj-code .
define input parameter  p-obj-type like ub.place-attr.obj-type .
define input parameter  p-pl-code  like ub.place-attr.pl-code .
define input parameter  p-value    like ub.place-attr.attr-value .
define output parameter p-ok       as logical.
define buffer buf_place-attr for ub.place-attr .
  do on error undo, return error return-value :
     p-ok = false.
     find first buf_place-attr exclusive-lock where buf_place-attr.attr-code   = p-code
                                                and buf_place-attr.obj-code    = p-obj-code
                                                and buf_place-attr.obj-type    = p-obj-type
                                                and buf_place-attr.pl-code     = p-pl-code no-error.
     if available buf_place-attr then do :
        delete buf_place-attr.
        p-ok = true.
     end.
  end.
end.
function is-sug returns logical
        (input p-gds-code as integer):
define variable result as logical no-undo.
define variable c-value as character no-undo.
define variable c-type as character no-undo.
do on error undo, return error:
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-attr-value in g#attr-lib
      (input  p-gds-code
      ,input  'fuel-type':U
      ,output c-value
      ,output c-type) no-error.
end.
result = logical(c-value = 'lgas':U) no-error.
return result.
end function.
define variable lns-cnt  as integer no-undo.
define variable line-rec as recid   no-undo.
if valid-handle (g#lib-trn2)
and g#lib-trn2 <> this-procedure :handle
and g#lib-trn2 :get-signature('lib-trn2_crinvdoc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки для работы с документами" skip
    g#lib-trn2 skip
    g#lib-trn2 :type skip
    g#lib-trn2 :file-name skip
    valid-handle(g#lib-trn2) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error .
end.
else do:
  assign
    g#lib-trn2 = this-procedure :handle
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-trn2", g#lib-trn2).
  delete object gbl-hndllibObj.
end.
on delete of this-procedure do:
  assign
    g#lib-trn2 = ?
  .
  def var gbl-hndllibObj as class gbl-hndllib no-undo.
  gbl-hndllibObj = new gbl-hndllib ().
  gbl-hndllibObj:InitHndl("g#lib-trn2", g#lib-trn2).
  delete object gbl-hndllibObj.
end.
define stream str-err.
procedure lib-trn2_crinvdoc :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer cr_trn-doc for ub.trn-doc.
define variable varwastagevalue as character no-undo.
define variable varwastagetype  as character no-undo.
define variable varinvclcwt     as character no-undo.
define variable varinvclcwttype as character no-undo.
define variable varinvclcas     as character no-undo.
define variable varinvclcastype as character no-undo.
do on error undo, return error return-value :
find first cr_trn-doc where cr_trn-doc.doc-code = pardoc-code no-lock.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'inv-global':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'invclcas'  then varinvclcas = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
    if thbjattr_thbj-attr.prop-code = 'invclcwt'  then varinvclcwt = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
end.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input cr_trn-doc.obj-type
  ,input cr_trn-doc.obj-code
  ,input 'inv-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
for each thbjattr_thbj-attr :
    if thbjattr_thbj-attr.prop-code = 'wastage'  then varwastagevalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
end.
empty temp-table thbjattr_thbj-attr.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input cr_trn-doc.doc-code ,
                       input 'othermoves':U ,
                       input yes ) no-error .
if error-status :error then do:
  return error substitute( "Ошибка при вызове процедуры tdat-wrt &1 &2"
                         , return-value
                         , error-status :get-message( 1 ) ).
end.
if varwastagevalue = "yes" and
   varinvclcwt     = "yes" then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input cr_trn-doc.doc-code ,
                       input 'clcaswt':U ,
                       input yes ) no-error .
   if error-status :error then do:
     return error substitute( "Ошибка при вызове процедуры tdat-wrt &1 &2"
                            , return-value
                            , error-status :get-message( 1 ) ).
   end.
end.
else do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input cr_trn-doc.doc-code ,
                       input 'clcaswt':U ,
                       input no ) no-error .
   if error-status :error then do:
     return error substitute( "Ошибка при вызове процедуры tdat-wrt &1 &2"
                            , return-value
                            , error-status :get-message( 1 ) ).
   end.
end.
if varinvclcas = "yes" then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input cr_trn-doc.doc-code ,
                       input 'clcasol':U ,
                       input yes ) no-error .
   if error-status :error then do:
     return error substitute( "Ошибка при вызове процедуры tdat-wrt &1 &2"
                            , return-value
                            , error-status :get-message( 1 ) ).
   end.
end.
else do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-wrt in g#trdcalib ( input cr_trn-doc.doc-code ,
                       input 'clcasol':U ,
                       input no ) no-error .
   if error-status :error then do:
     return error substitute( "Ошибка при вызове процедуры tdat-wrt &1 &2"
                            , return-value
                            , error-status :get-message( 1 ) ).
   end.
end.
end.
end procedure.
procedure lib-trn2_reclctsl :
define input parameter pardoc-code like ub.trn-doc.doc-code     no-undo.
define input parameter parsum-type like ub.trn-doc-sum.sum-type no-undo.
define buffer bf_trn-doc-sum         for ub.trn-doc-sum.
define buffer bf-ext_trn-doc-sum     for ub.trn-doc-sum.
define buffer bf-mis_trn-doc-sum     for ub.trn-doc-sum.
define buffer bf-ext-cli_trn-doc-sum for ub.trn-doc-sum.
define buffer bf-mis-cli_trn-doc-sum for ub.trn-doc-sum.
define buffer bf_doc-line-sum        for ub.doc-line-sum.
define variable vartime as integer no-undo.
do on error undo, return error return-value :
assign
  vartime = time.
find first bf_trn-doc-sum where bf_trn-doc-sum.doc-code = pardoc-code and
                                bf_trn-doc-sum.sum-type = parsum-type no-error.
if error-status :error then do:
  return error substitute( "Не найдена запись дополнительных сумм по документу &1. Тип суммы &2."
                         , pardoc-code
                         , parsum-type ).
end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cltrnsum in g#lib-rwds ( input pardoc-code ,
                       input parsum-type ) no-error .
if error-status :error then do:
  return error substitute( "Ошибка при вызове процедуры lib-rwds_cltrnsum для документа &1. Тип суммы &2."
                         , pardoc-code
                         , parsum-type ).
end.
if parsum-type = 'gen':U then do:
  find first bf-ext_trn-doc-sum where bf-ext_trn-doc-sum.doc-code = pardoc-code      and
                                      bf-ext_trn-doc-sum.sum-type = 'ext':U no-error.
  if error-status :error then do:
    return error substitute( "Не найдена запись дополнительных сумм по документу &1. Тип суммы &2."
                           , pardoc-code
                           , parsum-type ).
  end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cltrnsum in g#lib-rwds ( input pardoc-code ,
                       input 'ext':U ) no-error .
  if error-status :error then do:
    return error substitute( "Ошибка при вызове процедуры lib-rwds_cltrnsum для документа &1. Тип суммы &2."
                           , pardoc-code
                           , parsum-type ).
  end.
  find first bf-mis_trn-doc-sum where bf-mis_trn-doc-sum.doc-code = pardoc-code      and
                                      bf-mis_trn-doc-sum.sum-type = 'mis':U no-error.
  if error-status :error then do:
    return error substitute( "Не найдена запись дополнительных сумм по документу &1. Тип суммы &2."
                           , pardoc-code
                           , parsum-type ).
  end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cltrnsum in g#lib-rwds ( input pardoc-code ,
                       input 'mis':U ) no-error .
  if error-status :error then do:
    return error substitute( "Ошибка при вызове процедуры lib-rwds_cltrnsum для документа &1. Тип суммы &2."
                           , pardoc-code
                           , parsum-type ).
  end.
end.
if parsum-type = 'genc':U then do:
  find first bf-ext-cli_trn-doc-sum where bf-ext-cli_trn-doc-sum.doc-code = pardoc-code          and
                                          bf-ext-cli_trn-doc-sum.sum-type = 'extc':U no-error.
  if error-status :error then do:
    return error substitute( "Не найдена запись дополнительных сумм по документу &1. Тип суммы &2."
                           , pardoc-code
                           , parsum-type ).
  end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cltrnsum in g#lib-rwds ( input pardoc-code ,
                       input 'extc':U ) no-error .
  if error-status :error then do:
    return error substitute( "Ошибка при вызове процедуры lib-rwds_cltrnsum для документа &1. Тип суммы &2."
                           , pardoc-code
                           , parsum-type ).
  end.
  find first bf-mis-cli_trn-doc-sum where bf-mis-cli_trn-doc-sum.doc-code = pardoc-code      and
                                          bf-mis-cli_trn-doc-sum.sum-type = 'misc':U no-error.
  if error-status :error then do:
    return error substitute( "Не найдена запись дополнительных сумм по документу &1. Тип суммы &2."
                           , pardoc-code
                           , parsum-type ).
  end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cltrnsum in g#lib-rwds ( input pardoc-code ,
                       input 'misc':U ) no-error .
  if error-status :error then do:
    return error substitute( "Ошибка при вызове процедуры lib-rwds_cltrnsum для документа &1. Тип суммы &2."
                           , pardoc-code
                           , parsum-type ).
  end.
end.
for each bf_doc-line-sum where bf_doc-line-sum.doc-code = pardoc-code and
                               bf_doc-line-sum.sum-type = parsum-type on error undo, return error return-value :
   assign
    bf_trn-doc-sum.fact-qnty             = bf_trn-doc-sum.fact-qnty            + bf_doc-line-sum.fact-qnty
    bf_trn-doc-sum.sale-sum-base         = bf_trn-doc-sum.sale-sum-base        + bf_doc-line-sum.sale-sum-base
    bf_trn-doc-sum.sale-sum-rubl         = bf_trn-doc-sum.sale-sum-rubl        + bf_doc-line-sum.sale-sum-rubl
    bf_trn-doc-sum.sale-VAT-base         = bf_trn-doc-sum.sale-VAT-base        + bf_doc-line-sum.sale-VAT-base
    bf_trn-doc-sum.sale-VAT-rubl         = bf_trn-doc-sum.sale-VAT-rubl        + bf_doc-line-sum.sale-VAT-rubl
    bf_trn-doc-sum.sale-SLT-base         = bf_trn-doc-sum.sale-SLT-base        + bf_doc-line-sum.sale-SLT-base
    bf_trn-doc-sum.sale-SLT-rubl         = bf_trn-doc-sum.sale-SLT-rubl        + bf_doc-line-sum.sale-SLT-rubl
    bf_trn-doc-sum.sale-road-tax-base    = bf_trn-doc-sum.sale-road-tax-base   + bf_doc-line-sum.sale-road-tax-base
    bf_trn-doc-sum.sale-road-tax-rubl    = bf_trn-doc-sum.sale-road-tax-rubl   + bf_doc-line-sum.sale-road-tax-rubl
    bf_trn-doc-sum.sale-excise-base      = bf_trn-doc-sum.sale-excise-base     + bf_doc-line-sum.sale-excise-base
    bf_trn-doc-sum.sale-excise-rubl      = bf_trn-doc-sum.sale-excise-rubl     + bf_doc-line-sum.sale-excise-rubl
    bf_trn-doc-sum.sale-transport-base   = bf_trn-doc-sum.sale-transport-base  + bf_doc-line-sum.sale-transport-base
    bf_trn-doc-sum.sale-transport-rubl   = bf_trn-doc-sum.sale-transport-rubl  + bf_doc-line-sum.sale-transport-rubl
    bf_trn-doc-sum.sale-other-base       = bf_trn-doc-sum.sale-other-base      + bf_doc-line-sum.sale-other-base
    bf_trn-doc-sum.sale-other-rubl       = bf_trn-doc-sum.sale-other-rubl      + bf_doc-line-sum.sale-other-rubl
    bf_trn-doc-sum.sale-discnt-base      = bf_trn-doc-sum.sale-discnt-base     + bf_doc-line-sum.sale-discnt-base
    bf_trn-doc-sum.sale-discnt-rubl      = bf_trn-doc-sum.sale-discnt-rubl     + bf_doc-line-sum.sale-discnt-rubl
    bf_trn-doc-sum.crsa-sum-base         = bf_trn-doc-sum.crsa-sum-base        + bf_doc-line-sum.crsa-sum-base
    bf_trn-doc-sum.crsa-sum-rubl         = bf_trn-doc-sum.crsa-sum-rubl        + bf_doc-line-sum.crsa-sum-rubl
    bf_trn-doc-sum.crsa-VAT-base         = bf_trn-doc-sum.crsa-VAT-base        + bf_doc-line-sum.crsa-VAT-base
    bf_trn-doc-sum.crsa-VAT-rubl         = bf_trn-doc-sum.crsa-VAT-rubl        + bf_doc-line-sum.crsa-VAT-rubl
    bf_trn-doc-sum.crsa-SLT-base         = bf_trn-doc-sum.crsa-SLT-base        + bf_doc-line-sum.crsa-SLT-base
    bf_trn-doc-sum.crsa-SLT-rubl         = bf_trn-doc-sum.crsa-SLT-rubl        + bf_doc-line-sum.crsa-SLT-rubl
    bf_trn-doc-sum.crsa-road-tax-base    = bf_trn-doc-sum.crsa-road-tax-base   + bf_doc-line-sum.crsa-road-tax-base
    bf_trn-doc-sum.crsa-road-tax-rubl    = bf_trn-doc-sum.crsa-road-tax-rubl   + bf_doc-line-sum.crsa-road-tax-rubl
    bf_trn-doc-sum.crsa-excise-base      = bf_trn-doc-sum.crsa-excise-base     + bf_doc-line-sum.crsa-excise-base
    bf_trn-doc-sum.crsa-excise-rubl      = bf_trn-doc-sum.crsa-excise-rubl     + bf_doc-line-sum.crsa-excise-rubl
    bf_trn-doc-sum.crsa-transport-base   = bf_trn-doc-sum.crsa-transport-base  + bf_doc-line-sum.crsa-transport-base
    bf_trn-doc-sum.crsa-transport-rubl   = bf_trn-doc-sum.crsa-transport-rubl  + bf_doc-line-sum.crsa-transport-rubl
    bf_trn-doc-sum.crsa-other-base       = bf_trn-doc-sum.crsa-other-base      + bf_doc-line-sum.crsa-other-base
    bf_trn-doc-sum.crsa-other-rubl       = bf_trn-doc-sum.crsa-other-rubl      + bf_doc-line-sum.crsa-other-rubl
    bf_trn-doc-sum.crsa-discnt-base      = bf_trn-doc-sum.crsa-discnt-base     + bf_doc-line-sum.crsa-discnt-base
    bf_trn-doc-sum.crsa-discnt-rubl      = bf_trn-doc-sum.crsa-discnt-rubl     + bf_doc-line-sum.crsa-discnt-rubl
    bf_trn-doc-sum.cost-sum-base         = bf_trn-doc-sum.cost-sum-base        + bf_doc-line-sum.cost-sum-base
    bf_trn-doc-sum.cost-sum-rubl         = bf_trn-doc-sum.cost-sum-rubl        + bf_doc-line-sum.cost-sum-rubl
    bf_trn-doc-sum.cost-VAT-base         = bf_trn-doc-sum.cost-VAT-base        + bf_doc-line-sum.cost-VAT-base
    bf_trn-doc-sum.cost-VAT-rubl         = bf_trn-doc-sum.cost-VAT-rubl        + bf_doc-line-sum.cost-VAT-rubl
    bf_trn-doc-sum.cost-SLT-base         = bf_trn-doc-sum.cost-SLT-base        + bf_doc-line-sum.cost-SLT-base
    bf_trn-doc-sum.cost-SLT-rubl         = bf_trn-doc-sum.cost-SLT-rubl        + bf_doc-line-sum.cost-SLT-rubl
    bf_trn-doc-sum.cost-road-tax-base    = bf_trn-doc-sum.cost-road-tax-base   + bf_doc-line-sum.cost-road-tax-base
    bf_trn-doc-sum.cost-road-tax-rubl    = bf_trn-doc-sum.cost-road-tax-rubl   + bf_doc-line-sum.cost-road-tax-rubl
    bf_trn-doc-sum.cost-excise-base      = bf_trn-doc-sum.cost-excise-base     + bf_doc-line-sum.cost-excise-base
    bf_trn-doc-sum.cost-excise-rubl      = bf_trn-doc-sum.cost-excise-rubl     + bf_doc-line-sum.cost-excise-rubl
    bf_trn-doc-sum.cost-transport-base   = bf_trn-doc-sum.cost-transport-base  + bf_doc-line-sum.cost-transport-base
    bf_trn-doc-sum.cost-transport-rubl   = bf_trn-doc-sum.cost-transport-rubl  + bf_doc-line-sum.cost-transport-rubl
    bf_trn-doc-sum.cost-other-base       = bf_trn-doc-sum.cost-other-base      + bf_doc-line-sum.cost-other-base
    bf_trn-doc-sum.cost-other-rubl       = bf_trn-doc-sum.cost-other-rubl      + bf_doc-line-sum.cost-other-rubl
    bf_trn-doc-sum.cost-discnt-base      = bf_trn-doc-sum.cost-discnt-base     + bf_doc-line-sum.cost-discnt-base
    bf_trn-doc-sum.cost-discnt-rubl      = bf_trn-doc-sum.cost-discnt-rubl     + bf_doc-line-sum.cost-discnt-rubl
    .
  if parsum-type = 'gen':U then do:
    if bf_doc-line-sum.fact-qnty > 0 then do:
      assign
        bf-ext_trn-doc-sum.fact-qnty             = bf-ext_trn-doc-sum.fact-qnty            + bf_doc-line-sum.fact-qnty .
    end.
    else do:
      assign
        bf-mis_trn-doc-sum.fact-qnty             = bf-mis_trn-doc-sum.fact-qnty            - bf_doc-line-sum.fact-qnty .
    end.
    if bf_doc-line-sum.sale-sum-base > 0 then do:
      assign
        bf-ext_trn-doc-sum.sale-sum-base         = bf-ext_trn-doc-sum.sale-sum-base        + bf_doc-line-sum.sale-sum-base
        bf-ext_trn-doc-sum.sale-sum-rubl         = bf-ext_trn-doc-sum.sale-sum-rubl        + bf_doc-line-sum.sale-sum-rubl
        bf-ext_trn-doc-sum.sale-VAT-base         = bf-ext_trn-doc-sum.sale-VAT-base        + bf_doc-line-sum.sale-VAT-base
        bf-ext_trn-doc-sum.sale-VAT-rubl         = bf-ext_trn-doc-sum.sale-VAT-rubl        + bf_doc-line-sum.sale-VAT-rubl
        bf-ext_trn-doc-sum.sale-SLT-base         = bf-ext_trn-doc-sum.sale-SLT-base        + bf_doc-line-sum.sale-SLT-base
        bf-ext_trn-doc-sum.sale-SLT-rubl         = bf-ext_trn-doc-sum.sale-SLT-rubl        + bf_doc-line-sum.sale-SLT-rubl
        bf-ext_trn-doc-sum.sale-road-tax-base    = bf-ext_trn-doc-sum.sale-road-tax-base   + bf_doc-line-sum.sale-road-tax-base
        bf-ext_trn-doc-sum.sale-road-tax-rubl    = bf-ext_trn-doc-sum.sale-road-tax-rubl   + bf_doc-line-sum.sale-road-tax-rubl
        bf-ext_trn-doc-sum.sale-excise-base      = bf-ext_trn-doc-sum.sale-excise-base     + bf_doc-line-sum.sale-excise-base
        bf-ext_trn-doc-sum.sale-excise-rubl      = bf-ext_trn-doc-sum.sale-excise-rubl     + bf_doc-line-sum.sale-excise-rubl
        bf-ext_trn-doc-sum.sale-transport-base   = bf-ext_trn-doc-sum.sale-transport-base  + bf_doc-line-sum.sale-transport-base
        bf-ext_trn-doc-sum.sale-transport-rubl   = bf-ext_trn-doc-sum.sale-transport-rubl  + bf_doc-line-sum.sale-transport-rubl
        bf-ext_trn-doc-sum.sale-other-base       = bf-ext_trn-doc-sum.sale-other-base      + bf_doc-line-sum.sale-other-base
        bf-ext_trn-doc-sum.sale-other-rubl       = bf-ext_trn-doc-sum.sale-other-rubl      + bf_doc-line-sum.sale-other-rubl
        bf-ext_trn-doc-sum.sale-discnt-base      = bf-ext_trn-doc-sum.sale-discnt-base     + bf_doc-line-sum.sale-discnt-base
        bf-ext_trn-doc-sum.sale-discnt-rubl      = bf-ext_trn-doc-sum.sale-discnt-rubl     + bf_doc-line-sum.sale-discnt-rubl
      .
    end.
    else do:
      assign
        bf-mis_trn-doc-sum.sale-sum-base         = bf-mis_trn-doc-sum.sale-sum-base        - bf_doc-line-sum.sale-sum-base
        bf-mis_trn-doc-sum.sale-sum-rubl         = bf-mis_trn-doc-sum.sale-sum-rubl        - bf_doc-line-sum.sale-sum-rubl
        bf-mis_trn-doc-sum.sale-VAT-base         = bf-mis_trn-doc-sum.sale-VAT-base        - bf_doc-line-sum.sale-VAT-base
        bf-mis_trn-doc-sum.sale-VAT-rubl         = bf-mis_trn-doc-sum.sale-VAT-rubl        - bf_doc-line-sum.sale-VAT-rubl
        bf-mis_trn-doc-sum.sale-SLT-base         = bf-mis_trn-doc-sum.sale-SLT-base        - bf_doc-line-sum.sale-SLT-base
        bf-mis_trn-doc-sum.sale-SLT-rubl         = bf-mis_trn-doc-sum.sale-SLT-rubl        - bf_doc-line-sum.sale-SLT-rubl
        bf-mis_trn-doc-sum.sale-road-tax-base    = bf-mis_trn-doc-sum.sale-road-tax-base   - bf_doc-line-sum.sale-road-tax-base
        bf-mis_trn-doc-sum.sale-road-tax-rubl    = bf-mis_trn-doc-sum.sale-road-tax-rubl   - bf_doc-line-sum.sale-road-tax-rubl
        bf-mis_trn-doc-sum.sale-excise-base      = bf-mis_trn-doc-sum.sale-excise-base     - bf_doc-line-sum.sale-excise-base
        bf-mis_trn-doc-sum.sale-excise-rubl      = bf-mis_trn-doc-sum.sale-excise-rubl     - bf_doc-line-sum.sale-excise-rubl
        bf-mis_trn-doc-sum.sale-transport-base   = bf-mis_trn-doc-sum.sale-transport-base  - bf_doc-line-sum.sale-transport-base
        bf-mis_trn-doc-sum.sale-transport-rubl   = bf-mis_trn-doc-sum.sale-transport-rubl  - bf_doc-line-sum.sale-transport-rubl
        bf-mis_trn-doc-sum.sale-other-base       = bf-mis_trn-doc-sum.sale-other-base      - bf_doc-line-sum.sale-other-base
        bf-mis_trn-doc-sum.sale-other-rubl       = bf-mis_trn-doc-sum.sale-other-rubl      - bf_doc-line-sum.sale-other-rubl
        bf-mis_trn-doc-sum.sale-discnt-base      = bf-mis_trn-doc-sum.sale-discnt-base     - bf_doc-line-sum.sale-discnt-base
        bf-mis_trn-doc-sum.sale-discnt-rubl      = bf-mis_trn-doc-sum.sale-discnt-rubl     - bf_doc-line-sum.sale-discnt-rubl
      .
    end.
    if bf_doc-line-sum.crsa-sum-base > 0 then do:
      assign
        bf-ext_trn-doc-sum.crsa-sum-base         = bf-ext_trn-doc-sum.crsa-sum-base        + bf_doc-line-sum.crsa-sum-base
        bf-ext_trn-doc-sum.crsa-sum-rubl         = bf-ext_trn-doc-sum.crsa-sum-rubl        + bf_doc-line-sum.crsa-sum-rubl
        bf-ext_trn-doc-sum.crsa-VAT-base         = bf-ext_trn-doc-sum.crsa-VAT-base        + bf_doc-line-sum.crsa-VAT-base
        bf-ext_trn-doc-sum.crsa-VAT-rubl         = bf-ext_trn-doc-sum.crsa-VAT-rubl        + bf_doc-line-sum.crsa-VAT-rubl
        bf-ext_trn-doc-sum.crsa-SLT-base         = bf-ext_trn-doc-sum.crsa-SLT-base        + bf_doc-line-sum.crsa-SLT-base
        bf-ext_trn-doc-sum.crsa-SLT-rubl         = bf-ext_trn-doc-sum.crsa-SLT-rubl        + bf_doc-line-sum.crsa-SLT-rubl
        bf-ext_trn-doc-sum.crsa-road-tax-base    = bf-ext_trn-doc-sum.crsa-road-tax-base   + bf_doc-line-sum.crsa-road-tax-base
        bf-ext_trn-doc-sum.crsa-road-tax-rubl    = bf-ext_trn-doc-sum.crsa-road-tax-rubl   + bf_doc-line-sum.crsa-road-tax-rubl
        bf-ext_trn-doc-sum.crsa-excise-base      = bf-ext_trn-doc-sum.crsa-excise-base     + bf_doc-line-sum.crsa-excise-base
        bf-ext_trn-doc-sum.crsa-excise-rubl      = bf-ext_trn-doc-sum.crsa-excise-rubl     + bf_doc-line-sum.crsa-excise-rubl
        bf-ext_trn-doc-sum.crsa-transport-base   = bf-ext_trn-doc-sum.crsa-transport-base  + bf_doc-line-sum.crsa-transport-base
        bf-ext_trn-doc-sum.crsa-transport-rubl   = bf-ext_trn-doc-sum.crsa-transport-rubl  + bf_doc-line-sum.crsa-transport-rubl
        bf-ext_trn-doc-sum.crsa-other-base       = bf-ext_trn-doc-sum.crsa-other-base      + bf_doc-line-sum.crsa-other-base
        bf-ext_trn-doc-sum.crsa-other-rubl       = bf-ext_trn-doc-sum.crsa-other-rubl      + bf_doc-line-sum.crsa-other-rubl
        bf-ext_trn-doc-sum.crsa-discnt-base      = bf-ext_trn-doc-sum.crsa-discnt-base     + bf_doc-line-sum.crsa-discnt-base
        bf-ext_trn-doc-sum.crsa-discnt-rubl      = bf-ext_trn-doc-sum.crsa-discnt-rubl     + bf_doc-line-sum.crsa-discnt-rubl
      .
    end.
    else do:
      assign
        bf-mis_trn-doc-sum.crsa-sum-base         = bf-mis_trn-doc-sum.crsa-sum-base        - bf_doc-line-sum.crsa-sum-base
        bf-mis_trn-doc-sum.crsa-sum-rubl         = bf-mis_trn-doc-sum.crsa-sum-rubl        - bf_doc-line-sum.crsa-sum-rubl
        bf-mis_trn-doc-sum.crsa-VAT-base         = bf-mis_trn-doc-sum.crsa-VAT-base        - bf_doc-line-sum.crsa-VAT-base
        bf-mis_trn-doc-sum.crsa-VAT-rubl         = bf-mis_trn-doc-sum.crsa-VAT-rubl        - bf_doc-line-sum.crsa-VAT-rubl
        bf-mis_trn-doc-sum.crsa-SLT-base         = bf-mis_trn-doc-sum.crsa-SLT-base        - bf_doc-line-sum.crsa-SLT-base
        bf-mis_trn-doc-sum.crsa-SLT-rubl         = bf-mis_trn-doc-sum.crsa-SLT-rubl        - bf_doc-line-sum.crsa-SLT-rubl
        bf-mis_trn-doc-sum.crsa-road-tax-base    = bf-mis_trn-doc-sum.crsa-road-tax-base   - bf_doc-line-sum.crsa-road-tax-base
        bf-mis_trn-doc-sum.crsa-road-tax-rubl    = bf-mis_trn-doc-sum.crsa-road-tax-rubl   - bf_doc-line-sum.crsa-road-tax-rubl
        bf-mis_trn-doc-sum.crsa-excise-base      = bf-mis_trn-doc-sum.crsa-excise-base     - bf_doc-line-sum.crsa-excise-base
        bf-mis_trn-doc-sum.crsa-excise-rubl      = bf-mis_trn-doc-sum.crsa-excise-rubl     - bf_doc-line-sum.crsa-excise-rubl
        bf-mis_trn-doc-sum.crsa-transport-base   = bf-mis_trn-doc-sum.crsa-transport-base  - bf_doc-line-sum.crsa-transport-base
        bf-mis_trn-doc-sum.crsa-transport-rubl   = bf-mis_trn-doc-sum.crsa-transport-rubl  - bf_doc-line-sum.crsa-transport-rubl
        bf-mis_trn-doc-sum.crsa-other-base       = bf-mis_trn-doc-sum.crsa-other-base      - bf_doc-line-sum.crsa-other-base
        bf-mis_trn-doc-sum.crsa-other-rubl       = bf-mis_trn-doc-sum.crsa-other-rubl      - bf_doc-line-sum.crsa-other-rubl
        bf-mis_trn-doc-sum.crsa-discnt-base      = bf-mis_trn-doc-sum.crsa-discnt-base     - bf_doc-line-sum.crsa-discnt-base
        bf-mis_trn-doc-sum.crsa-discnt-rubl      = bf-mis_trn-doc-sum.crsa-discnt-rubl     - bf_doc-line-sum.crsa-discnt-rubl
      .
    end.
    if bf_doc-line-sum.cost-sum-base > 0 then do:
      assign
        bf-ext_trn-doc-sum.cost-sum-base         = bf-ext_trn-doc-sum.cost-sum-base        + bf_doc-line-sum.cost-sum-base
        bf-ext_trn-doc-sum.cost-sum-rubl         = bf-ext_trn-doc-sum.cost-sum-rubl        + bf_doc-line-sum.cost-sum-rubl
        bf-ext_trn-doc-sum.cost-VAT-base         = bf-ext_trn-doc-sum.cost-VAT-base        + bf_doc-line-sum.cost-VAT-base
        bf-ext_trn-doc-sum.cost-VAT-rubl         = bf-ext_trn-doc-sum.cost-VAT-rubl        + bf_doc-line-sum.cost-VAT-rubl
        bf-ext_trn-doc-sum.cost-SLT-base         = bf-ext_trn-doc-sum.cost-SLT-base        + bf_doc-line-sum.cost-SLT-base
        bf-ext_trn-doc-sum.cost-SLT-rubl         = bf-ext_trn-doc-sum.cost-SLT-rubl        + bf_doc-line-sum.cost-SLT-rubl
        bf-ext_trn-doc-sum.cost-road-tax-base    = bf-ext_trn-doc-sum.cost-road-tax-base   + bf_doc-line-sum.cost-road-tax-base
        bf-ext_trn-doc-sum.cost-road-tax-rubl    = bf-ext_trn-doc-sum.cost-road-tax-rubl   + bf_doc-line-sum.cost-road-tax-rubl
        bf-ext_trn-doc-sum.cost-excise-base      = bf-ext_trn-doc-sum.cost-excise-base     + bf_doc-line-sum.cost-excise-base
        bf-ext_trn-doc-sum.cost-excise-rubl      = bf-ext_trn-doc-sum.cost-excise-rubl     + bf_doc-line-sum.cost-excise-rubl
        bf-ext_trn-doc-sum.cost-transport-base   = bf-ext_trn-doc-sum.cost-transport-base  + bf_doc-line-sum.cost-transport-base
        bf-ext_trn-doc-sum.cost-transport-rubl   = bf-ext_trn-doc-sum.cost-transport-rubl  + bf_doc-line-sum.cost-transport-rubl
        bf-ext_trn-doc-sum.cost-other-base       = bf-ext_trn-doc-sum.cost-other-base      + bf_doc-line-sum.cost-other-base
        bf-ext_trn-doc-sum.cost-other-rubl       = bf-ext_trn-doc-sum.cost-other-rubl      + bf_doc-line-sum.cost-other-rubl
        bf-ext_trn-doc-sum.cost-discnt-base      = bf-ext_trn-doc-sum.cost-discnt-base     + bf_doc-line-sum.cost-discnt-base
        bf-ext_trn-doc-sum.cost-discnt-rubl      = bf-ext_trn-doc-sum.cost-discnt-rubl     + bf_doc-line-sum.cost-discnt-rubl
      .
    end.
    else do:
      assign
        bf-mis_trn-doc-sum.cost-sum-base         = bf-mis_trn-doc-sum.cost-sum-base        - bf_doc-line-sum.cost-sum-base
        bf-mis_trn-doc-sum.cost-sum-rubl         = bf-mis_trn-doc-sum.cost-sum-rubl        - bf_doc-line-sum.cost-sum-rubl
        bf-mis_trn-doc-sum.cost-VAT-base         = bf-mis_trn-doc-sum.cost-VAT-base        - bf_doc-line-sum.cost-VAT-base
        bf-mis_trn-doc-sum.cost-VAT-rubl         = bf-mis_trn-doc-sum.cost-VAT-rubl        - bf_doc-line-sum.cost-VAT-rubl
        bf-mis_trn-doc-sum.cost-SLT-base         = bf-mis_trn-doc-sum.cost-SLT-base        - bf_doc-line-sum.cost-SLT-base
        bf-mis_trn-doc-sum.cost-SLT-rubl         = bf-mis_trn-doc-sum.cost-SLT-rubl        - bf_doc-line-sum.cost-SLT-rubl
        bf-mis_trn-doc-sum.cost-road-tax-base    = bf-mis_trn-doc-sum.cost-road-tax-base   - bf_doc-line-sum.cost-road-tax-base
        bf-mis_trn-doc-sum.cost-road-tax-rubl    = bf-mis_trn-doc-sum.cost-road-tax-rubl   - bf_doc-line-sum.cost-road-tax-rubl
        bf-mis_trn-doc-sum.cost-excise-base      = bf-mis_trn-doc-sum.cost-excise-base     - bf_doc-line-sum.cost-excise-base
        bf-mis_trn-doc-sum.cost-excise-rubl      = bf-mis_trn-doc-sum.cost-excise-rubl     - bf_doc-line-sum.cost-excise-rubl
        bf-mis_trn-doc-sum.cost-transport-base   = bf-mis_trn-doc-sum.cost-transport-base  - bf_doc-line-sum.cost-transport-base
        bf-mis_trn-doc-sum.cost-transport-rubl   = bf-mis_trn-doc-sum.cost-transport-rubl  - bf_doc-line-sum.cost-transport-rubl
        bf-mis_trn-doc-sum.cost-other-base       = bf-mis_trn-doc-sum.cost-other-base      - bf_doc-line-sum.cost-other-base
        bf-mis_trn-doc-sum.cost-other-rubl       = bf-mis_trn-doc-sum.cost-other-rubl      - bf_doc-line-sum.cost-other-rubl
        bf-mis_trn-doc-sum.cost-discnt-base      = bf-mis_trn-doc-sum.cost-discnt-base     - bf_doc-line-sum.cost-discnt-base
        bf-mis_trn-doc-sum.cost-discnt-rubl      = bf-mis_trn-doc-sum.cost-discnt-rubl     - bf_doc-line-sum.cost-discnt-rubl
      .
    end.
  end.
  if parsum-type = 'genc':U then do:
    if bf_doc-line-sum.fact-qnty > 0 then do:
      assign
        bf-ext-cli_trn-doc-sum.fact-qnty             = bf-ext-cli_trn-doc-sum.fact-qnty            + bf_doc-line-sum.fact-qnty .
    end.
    else do:
      assign
        bf-mis-cli_trn-doc-sum.fact-qnty          = bf-mis-cli_trn-doc-sum.fact-qnty            - bf_doc-line-sum.fact-qnty .
    end.
    if bf_doc-line-sum.sale-sum-base > 0 then do:
      assign
        bf-ext-cli_trn-doc-sum.sale-sum-base         = bf-ext-cli_trn-doc-sum.sale-sum-base        + bf_doc-line-sum.sale-sum-base
        bf-ext-cli_trn-doc-sum.sale-sum-rubl         = bf-ext-cli_trn-doc-sum.sale-sum-rubl        + bf_doc-line-sum.sale-sum-rubl
        bf-ext-cli_trn-doc-sum.sale-VAT-base         = bf-ext-cli_trn-doc-sum.sale-VAT-base        + bf_doc-line-sum.sale-VAT-base
        bf-ext-cli_trn-doc-sum.sale-VAT-rubl         = bf-ext-cli_trn-doc-sum.sale-VAT-rubl        + bf_doc-line-sum.sale-VAT-rubl
        bf-ext-cli_trn-doc-sum.sale-SLT-base         = bf-ext-cli_trn-doc-sum.sale-SLT-base        + bf_doc-line-sum.sale-SLT-base
        bf-ext-cli_trn-doc-sum.sale-SLT-rubl         = bf-ext-cli_trn-doc-sum.sale-SLT-rubl        + bf_doc-line-sum.sale-SLT-rubl
        bf-ext-cli_trn-doc-sum.sale-road-tax-base    = bf-ext-cli_trn-doc-sum.sale-road-tax-base   + bf_doc-line-sum.sale-road-tax-base
        bf-ext-cli_trn-doc-sum.sale-road-tax-rubl    = bf-ext-cli_trn-doc-sum.sale-road-tax-rubl   + bf_doc-line-sum.sale-road-tax-rubl
        bf-ext-cli_trn-doc-sum.sale-excise-base      = bf-ext-cli_trn-doc-sum.sale-excise-base     + bf_doc-line-sum.sale-excise-base
        bf-ext-cli_trn-doc-sum.sale-excise-rubl      = bf-ext-cli_trn-doc-sum.sale-excise-rubl     + bf_doc-line-sum.sale-excise-rubl
        bf-ext-cli_trn-doc-sum.sale-transport-base   = bf-ext-cli_trn-doc-sum.sale-transport-base  + bf_doc-line-sum.sale-transport-base
        bf-ext-cli_trn-doc-sum.sale-transport-rubl   = bf-ext-cli_trn-doc-sum.sale-transport-rubl  + bf_doc-line-sum.sale-transport-rubl
        bf-ext-cli_trn-doc-sum.sale-other-base       = bf-ext-cli_trn-doc-sum.sale-other-base      + bf_doc-line-sum.sale-other-base
        bf-ext-cli_trn-doc-sum.sale-other-rubl       = bf-ext-cli_trn-doc-sum.sale-other-rubl      + bf_doc-line-sum.sale-other-rubl
        bf-ext-cli_trn-doc-sum.sale-discnt-base      = bf-ext-cli_trn-doc-sum.sale-discnt-base     + bf_doc-line-sum.sale-discnt-base
        bf-ext-cli_trn-doc-sum.sale-discnt-rubl      = bf-ext-cli_trn-doc-sum.sale-discnt-rubl     + bf_doc-line-sum.sale-discnt-rubl
      .
    end.
    else do:
      assign
        bf-mis-cli_trn-doc-sum.sale-sum-base         = bf-mis-cli_trn-doc-sum.sale-sum-base        - bf_doc-line-sum.sale-sum-base
        bf-mis-cli_trn-doc-sum.sale-sum-rubl         = bf-mis-cli_trn-doc-sum.sale-sum-rubl        - bf_doc-line-sum.sale-sum-rubl
        bf-mis-cli_trn-doc-sum.sale-VAT-base         = bf-mis-cli_trn-doc-sum.sale-VAT-base        - bf_doc-line-sum.sale-VAT-base
        bf-mis-cli_trn-doc-sum.sale-VAT-rubl         = bf-mis-cli_trn-doc-sum.sale-VAT-rubl        - bf_doc-line-sum.sale-VAT-rubl
        bf-mis-cli_trn-doc-sum.sale-SLT-base         = bf-mis-cli_trn-doc-sum.sale-SLT-base        - bf_doc-line-sum.sale-SLT-base
        bf-mis-cli_trn-doc-sum.sale-SLT-rubl         = bf-mis-cli_trn-doc-sum.sale-SLT-rubl        - bf_doc-line-sum.sale-SLT-rubl
        bf-mis-cli_trn-doc-sum.sale-road-tax-base    = bf-mis-cli_trn-doc-sum.sale-road-tax-base   - bf_doc-line-sum.sale-road-tax-base
        bf-mis-cli_trn-doc-sum.sale-road-tax-rubl    = bf-mis-cli_trn-doc-sum.sale-road-tax-rubl   - bf_doc-line-sum.sale-road-tax-rubl
        bf-mis-cli_trn-doc-sum.sale-excise-base      = bf-mis-cli_trn-doc-sum.sale-excise-base     - bf_doc-line-sum.sale-excise-base
        bf-mis-cli_trn-doc-sum.sale-excise-rubl      = bf-mis-cli_trn-doc-sum.sale-excise-rubl     - bf_doc-line-sum.sale-excise-rubl
        bf-mis-cli_trn-doc-sum.sale-transport-base   = bf-mis-cli_trn-doc-sum.sale-transport-base  - bf_doc-line-sum.sale-transport-base
        bf-mis-cli_trn-doc-sum.sale-transport-rubl   = bf-mis-cli_trn-doc-sum.sale-transport-rubl  - bf_doc-line-sum.sale-transport-rubl
        bf-mis-cli_trn-doc-sum.sale-other-base       = bf-mis-cli_trn-doc-sum.sale-other-base      - bf_doc-line-sum.sale-other-base
        bf-mis-cli_trn-doc-sum.sale-other-rubl       = bf-mis-cli_trn-doc-sum.sale-other-rubl      - bf_doc-line-sum.sale-other-rubl
        bf-mis-cli_trn-doc-sum.sale-discnt-base      = bf-mis-cli_trn-doc-sum.sale-discnt-base     - bf_doc-line-sum.sale-discnt-base
        bf-mis-cli_trn-doc-sum.sale-discnt-rubl      = bf-mis-cli_trn-doc-sum.sale-discnt-rubl     - bf_doc-line-sum.sale-discnt-rubl
      .
    end.
    if bf_doc-line-sum.crsa-sum-base > 0 then do:
      assign
        bf-ext-cli_trn-doc-sum.crsa-sum-base         = bf-ext-cli_trn-doc-sum.crsa-sum-base        + bf_doc-line-sum.crsa-sum-base
        bf-ext-cli_trn-doc-sum.crsa-sum-rubl         = bf-ext-cli_trn-doc-sum.crsa-sum-rubl        + bf_doc-line-sum.crsa-sum-rubl
        bf-ext-cli_trn-doc-sum.crsa-VAT-base         = bf-ext-cli_trn-doc-sum.crsa-VAT-base        + bf_doc-line-sum.crsa-VAT-base
        bf-ext-cli_trn-doc-sum.crsa-VAT-rubl         = bf-ext-cli_trn-doc-sum.crsa-VAT-rubl        + bf_doc-line-sum.crsa-VAT-rubl
        bf-ext-cli_trn-doc-sum.crsa-SLT-base         = bf-ext-cli_trn-doc-sum.crsa-SLT-base        + bf_doc-line-sum.crsa-SLT-base
        bf-ext-cli_trn-doc-sum.crsa-SLT-rubl         = bf-ext-cli_trn-doc-sum.crsa-SLT-rubl        + bf_doc-line-sum.crsa-SLT-rubl
        bf-ext-cli_trn-doc-sum.crsa-road-tax-base    = bf-ext-cli_trn-doc-sum.crsa-road-tax-base   + bf_doc-line-sum.crsa-road-tax-base
        bf-ext-cli_trn-doc-sum.crsa-road-tax-rubl    = bf-ext-cli_trn-doc-sum.crsa-road-tax-rubl   + bf_doc-line-sum.crsa-road-tax-rubl
        bf-ext-cli_trn-doc-sum.crsa-excise-base      = bf-ext-cli_trn-doc-sum.crsa-excise-base     + bf_doc-line-sum.crsa-excise-base
        bf-ext-cli_trn-doc-sum.crsa-excise-rubl      = bf-ext-cli_trn-doc-sum.crsa-excise-rubl     + bf_doc-line-sum.crsa-excise-rubl
        bf-ext-cli_trn-doc-sum.crsa-transport-base   = bf-ext-cli_trn-doc-sum.crsa-transport-base  + bf_doc-line-sum.crsa-transport-base
        bf-ext-cli_trn-doc-sum.crsa-transport-rubl   = bf-ext-cli_trn-doc-sum.crsa-transport-rubl  + bf_doc-line-sum.crsa-transport-rubl
        bf-ext-cli_trn-doc-sum.crsa-other-base       = bf-ext-cli_trn-doc-sum.crsa-other-base      + bf_doc-line-sum.crsa-other-base
        bf-ext-cli_trn-doc-sum.crsa-other-rubl       = bf-ext-cli_trn-doc-sum.crsa-other-rubl      + bf_doc-line-sum.crsa-other-rubl
        bf-ext-cli_trn-doc-sum.crsa-discnt-base      = bf-ext-cli_trn-doc-sum.crsa-discnt-base     + bf_doc-line-sum.crsa-discnt-base
        bf-ext-cli_trn-doc-sum.crsa-discnt-rubl      = bf-ext-cli_trn-doc-sum.crsa-discnt-rubl     + bf_doc-line-sum.crsa-discnt-rubl
      .
    end.
    else do:
      assign
        bf-mis-cli_trn-doc-sum.crsa-sum-base         = bf-mis-cli_trn-doc-sum.crsa-sum-base        - bf_doc-line-sum.crsa-sum-base
        bf-mis-cli_trn-doc-sum.crsa-sum-rubl         = bf-mis-cli_trn-doc-sum.crsa-sum-rubl        - bf_doc-line-sum.crsa-sum-rubl
        bf-mis-cli_trn-doc-sum.crsa-VAT-base         = bf-mis-cli_trn-doc-sum.crsa-VAT-base        - bf_doc-line-sum.crsa-VAT-base
        bf-mis-cli_trn-doc-sum.crsa-VAT-rubl         = bf-mis-cli_trn-doc-sum.crsa-VAT-rubl        - bf_doc-line-sum.crsa-VAT-rubl
        bf-mis-cli_trn-doc-sum.crsa-SLT-base         = bf-mis-cli_trn-doc-sum.crsa-SLT-base        - bf_doc-line-sum.crsa-SLT-base
        bf-mis-cli_trn-doc-sum.crsa-SLT-rubl         = bf-mis-cli_trn-doc-sum.crsa-SLT-rubl        - bf_doc-line-sum.crsa-SLT-rubl
        bf-mis-cli_trn-doc-sum.crsa-road-tax-base    = bf-mis-cli_trn-doc-sum.crsa-road-tax-base   - bf_doc-line-sum.crsa-road-tax-base
        bf-mis-cli_trn-doc-sum.crsa-road-tax-rubl    = bf-mis-cli_trn-doc-sum.crsa-road-tax-rubl   - bf_doc-line-sum.crsa-road-tax-rubl
        bf-mis-cli_trn-doc-sum.crsa-excise-base      = bf-mis-cli_trn-doc-sum.crsa-excise-base     - bf_doc-line-sum.crsa-excise-base
        bf-mis-cli_trn-doc-sum.crsa-excise-rubl      = bf-mis-cli_trn-doc-sum.crsa-excise-rubl     - bf_doc-line-sum.crsa-excise-rubl
        bf-mis-cli_trn-doc-sum.crsa-transport-base   = bf-mis-cli_trn-doc-sum.crsa-transport-base  - bf_doc-line-sum.crsa-transport-base
        bf-mis-cli_trn-doc-sum.crsa-transport-rubl   = bf-mis-cli_trn-doc-sum.crsa-transport-rubl  - bf_doc-line-sum.crsa-transport-rubl
        bf-mis-cli_trn-doc-sum.crsa-other-base       = bf-mis-cli_trn-doc-sum.crsa-other-base      - bf_doc-line-sum.crsa-other-base
        bf-mis-cli_trn-doc-sum.crsa-other-rubl       = bf-mis-cli_trn-doc-sum.crsa-other-rubl      - bf_doc-line-sum.crsa-other-rubl
        bf-mis-cli_trn-doc-sum.crsa-discnt-base      = bf-mis-cli_trn-doc-sum.crsa-discnt-base     - bf_doc-line-sum.crsa-discnt-base
        bf-mis-cli_trn-doc-sum.crsa-discnt-rubl      = bf-mis-cli_trn-doc-sum.crsa-discnt-rubl     - bf_doc-line-sum.crsa-discnt-rubl
      .
    end.
    if bf_doc-line-sum.cost-sum-base > 0 then do:
      assign
        bf-ext-cli_trn-doc-sum.cost-sum-base         = bf-ext-cli_trn-doc-sum.cost-sum-base        + bf_doc-line-sum.cost-sum-base
        bf-ext-cli_trn-doc-sum.cost-sum-rubl         = bf-ext-cli_trn-doc-sum.cost-sum-rubl        + bf_doc-line-sum.cost-sum-rubl
        bf-ext-cli_trn-doc-sum.cost-VAT-base         = bf-ext-cli_trn-doc-sum.cost-VAT-base        + bf_doc-line-sum.cost-VAT-base
        bf-ext-cli_trn-doc-sum.cost-VAT-rubl         = bf-ext-cli_trn-doc-sum.cost-VAT-rubl        + bf_doc-line-sum.cost-VAT-rubl
        bf-ext-cli_trn-doc-sum.cost-SLT-base         = bf-ext-cli_trn-doc-sum.cost-SLT-base        + bf_doc-line-sum.cost-SLT-base
        bf-ext-cli_trn-doc-sum.cost-SLT-rubl         = bf-ext-cli_trn-doc-sum.cost-SLT-rubl        + bf_doc-line-sum.cost-SLT-rubl
        bf-ext-cli_trn-doc-sum.cost-road-tax-base    = bf-ext-cli_trn-doc-sum.cost-road-tax-base   + bf_doc-line-sum.cost-road-tax-base
        bf-ext-cli_trn-doc-sum.cost-road-tax-rubl    = bf-ext-cli_trn-doc-sum.cost-road-tax-rubl   + bf_doc-line-sum.cost-road-tax-rubl
        bf-ext-cli_trn-doc-sum.cost-excise-base      = bf-ext-cli_trn-doc-sum.cost-excise-base     + bf_doc-line-sum.cost-excise-base
        bf-ext-cli_trn-doc-sum.cost-excise-rubl      = bf-ext-cli_trn-doc-sum.cost-excise-rubl     + bf_doc-line-sum.cost-excise-rubl
        bf-ext-cli_trn-doc-sum.cost-transport-base   = bf-ext-cli_trn-doc-sum.cost-transport-base  + bf_doc-line-sum.cost-transport-base
        bf-ext-cli_trn-doc-sum.cost-transport-rubl   = bf-ext-cli_trn-doc-sum.cost-transport-rubl  + bf_doc-line-sum.cost-transport-rubl
        bf-ext-cli_trn-doc-sum.cost-other-base       = bf-ext-cli_trn-doc-sum.cost-other-base      + bf_doc-line-sum.cost-other-base
        bf-ext-cli_trn-doc-sum.cost-other-rubl       = bf-ext-cli_trn-doc-sum.cost-other-rubl      + bf_doc-line-sum.cost-other-rubl
        bf-ext-cli_trn-doc-sum.cost-discnt-base      = bf-ext-cli_trn-doc-sum.cost-discnt-base     + bf_doc-line-sum.cost-discnt-base
        bf-ext-cli_trn-doc-sum.cost-discnt-rubl      = bf-ext-cli_trn-doc-sum.cost-discnt-rubl     + bf_doc-line-sum.cost-discnt-rubl
      .
    end.
    else do:
      assign
        bf-mis-cli_trn-doc-sum.cost-sum-base         = bf-mis-cli_trn-doc-sum.cost-sum-base        - bf_doc-line-sum.cost-sum-base
        bf-mis-cli_trn-doc-sum.cost-sum-rubl         = bf-mis-cli_trn-doc-sum.cost-sum-rubl        - bf_doc-line-sum.cost-sum-rubl
        bf-mis-cli_trn-doc-sum.cost-VAT-base         = bf-mis-cli_trn-doc-sum.cost-VAT-base        - bf_doc-line-sum.cost-VAT-base
        bf-mis-cli_trn-doc-sum.cost-VAT-rubl         = bf-mis-cli_trn-doc-sum.cost-VAT-rubl        - bf_doc-line-sum.cost-VAT-rubl
        bf-mis-cli_trn-doc-sum.cost-SLT-base         = bf-mis-cli_trn-doc-sum.cost-SLT-base        - bf_doc-line-sum.cost-SLT-base
        bf-mis-cli_trn-doc-sum.cost-SLT-rubl         = bf-mis-cli_trn-doc-sum.cost-SLT-rubl        - bf_doc-line-sum.cost-SLT-rubl
        bf-mis-cli_trn-doc-sum.cost-road-tax-base    = bf-mis-cli_trn-doc-sum.cost-road-tax-base   - bf_doc-line-sum.cost-road-tax-base
        bf-mis-cli_trn-doc-sum.cost-road-tax-rubl    = bf-mis-cli_trn-doc-sum.cost-road-tax-rubl   - bf_doc-line-sum.cost-road-tax-rubl
        bf-mis-cli_trn-doc-sum.cost-excise-base      = bf-mis-cli_trn-doc-sum.cost-excise-base     - bf_doc-line-sum.cost-excise-base
        bf-mis-cli_trn-doc-sum.cost-excise-rubl      = bf-mis-cli_trn-doc-sum.cost-excise-rubl     - bf_doc-line-sum.cost-excise-rubl
        bf-mis-cli_trn-doc-sum.cost-transport-base   = bf-mis-cli_trn-doc-sum.cost-transport-base  - bf_doc-line-sum.cost-transport-base
        bf-mis-cli_trn-doc-sum.cost-transport-rubl   = bf-mis-cli_trn-doc-sum.cost-transport-rubl  - bf_doc-line-sum.cost-transport-rubl
        bf-mis-cli_trn-doc-sum.cost-other-base       = bf-mis-cli_trn-doc-sum.cost-other-base      - bf_doc-line-sum.cost-other-base
        bf-mis-cli_trn-doc-sum.cost-other-rubl       = bf-mis-cli_trn-doc-sum.cost-other-rubl      - bf_doc-line-sum.cost-other-rubl
        bf-mis-cli_trn-doc-sum.cost-discnt-base      = bf-mis-cli_trn-doc-sum.cost-discnt-base     - bf_doc-line-sum.cost-discnt-base
        bf-mis-cli_trn-doc-sum.cost-discnt-rubl      = bf-mis-cli_trn-doc-sum.cost-discnt-rubl     - bf_doc-line-sum.cost-discnt-rubl
      .
    end.
  end.
end.
end.
end procedure.
procedure lib-trn2_filinvon :
define input  parameter pariodoc-code like ub.trn-doc.doc-code   no-undo.
define input  parameter pariostatus   like ub.trn-doc.status_    no-undo.
define input  parameter parioflag     like ub.trn-doc.flag_      no-undo.
define input  parameter parchk-rsrv   as   logical               no-undo.
define input  parameter parhandle     as   handle                no-undo.
define output parameter parchg-inv    as   logical               no-undo.
define output parameter table for gds-list.
define variable variocur-qnty         like ub.doc-line.fact-qnty   no-undo.
define variable variocur-cli-qnty     like ub.doc-line.fact-qnty   no-undo.
define variable wastagevalue          as   character               no-undo.
define variable wastagetype           as   character               no-undo.
define variable varchg-inv            as   logical                 no-undo.
define variable varlns-cnt            as   integer                 no-undo.
define variable varvalue              like ub.doc-attr.attr-value  no-undo.
define variable vartype               as   character               no-undo.
define variable varvaluewt            as   character               no-undo.
define variable vartypewt             as   character               no-undo.
define variable varvalueol            as   character               no-undo.
define variable vartypeol             as   character               no-undo.
define variable is-petrol             as   logical                 no-undo.
define variable is-pieces             as   logical                 no-undo.
define variable v-density             like ub.doc-line.doc-density no-undo.
define buffer io_trn-doc              for ub.trn-doc.
define buffer io_doc-line             for ub.doc-line.
define buffer io_inv-line             for ub.inv-line.
define buffer io_goods                for ub.goods.
define buffer io_parts                for ub.parts.
define buffer io-bef_trn-doc-sum      for ub.trn-doc-sum.
define buffer io-bef-cli_trn-doc-sum  for ub.trn-doc-sum.
define buffer io-wst_trn-doc-sum      for ub.trn-doc-sum.
define buffer io-wst-cli_trn-doc-sum  for ub.trn-doc-sum.
define buffer io-bef_doc-line-sum     for ub.doc-line-sum.
define buffer io-bef-cli_doc-line-sum for ub.doc-line-sum.
define buffer io-wst_doc-line-sum     for ub.doc-line-sum.
define buffer io-wst-cli_doc-line-sum for ub.doc-line-sum.
define buffer io-aft-cli_doc-line-sum for ub.doc-line-sum.
define buffer io-aft_doc-line-sum     for ub.doc-line-sum.
define buffer buf_doc-prts for ub.doc-prts  .
define variable varinvclcspvalue as character no-undo.
define variable varinvclcsptype  as character no-undo.
define variable vartime          as integer   no-undo.
define variable varcount         as integer   no-undo.
define variable varmessage       as character no-undo.
bl-inv-on:
do transaction on error undo bl-inv-on, return error substitute( "Ошибка &1 &2 при вызове процедуры inv-on."
                                                               , return-value
                                                               , error-status :get-message( 1 ) ) :
  find first io_trn-doc where io_trn-doc.doc-code = pariodoc-code.
  if io_trn-doc.ext-doc-type <> 'vt':U              and
     io_trn-doc.ext-doc-type <> 'ap':U   and
     io_trn-doc.ext-doc-type <> 'pc':U   and
     io_trn-doc.ext-doc-type <> 'mp':U and
     io_trn-doc.ext-doc-type <> 'vp':U         then do:
     return error substitute( "Неверный расширенный тип документа &1.", io_trn-doc.ext-doc-type ).
  end.
  run trg/lock-gds.p
    (input io_trn-doc.doc-code
    ,input (if io_trn-doc.ext-doc-type = 'vt':U then yes else no)
    ,input (if io_trn-doc.ext-doc-type = 'vt':U then yes else no)
    ,input 0
    ,input 0
    ,input false
    ,input false
    ) no-error.
  if error-status :error then do:
    run waitfram-hide in parhandle no-error.
    undo bl-inv-on, return error return-value.
  end.
  assign
    io_trn-doc.doc-qnty    = 0
    io_trn-doc.tot-calc    = 0
    io_trn-doc.discnt-rubl = 0
  .
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input io_trn-doc.obj-type
  ,input io_trn-doc.obj-code
  ,input 'inv-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'invclcsp'  then varinvclcspvalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
        if thbjattr_thbj-attr.prop-code = 'wastage'   then wastagevalue  = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
    end.
    empty temp-table thbjattr_thbj-attr.
  assign
    vartime = time.
  if io_trn-doc.ext-doc-type = 'vt':U      or
     io_trn-doc.ext-doc-type = 'vp':U then do:
    if io_trn-doc.ext-doc-type = 'vt':U then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input io_trn-doc.doc-code ,
                        input 'clcaswt':U ,
                       output varvaluewt ,
                       output vartypewt ) no-error .
      if error-status :error then do:
        undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры tdat-val &1 &2."
                                               , return-value
                                               , error-status :get-message( 1 ) ).
      end.
    end.
    else do:
      assign
        wastagevalue = "no":u.
    end.
    if io_trn-doc.ext-doc-type = 'vp':U then do:
      assign
        varvalueol = "yes":u.
    end.
    else do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input io_trn-doc.doc-code ,
                        input 'clcasol':U ,
                       output varvalueol ,
                       output vartypeol ) no-error .
      if error-status :error then do:
        undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры tdat-val &1 &2."
                                               , return-value
                                               , error-status :get-message( 1 ) ).
      end.
    end.
    assign
      varinvclcspvalue = "no".
  end.
  if io_trn-doc.status_ = 'разрешен':U and
     not io_trn-doc.flag_              then do:
    if io_trn-doc.ext-doc-type = 'vt':U then do:
      run waitfram-show in parhandle ("Очистка сумм <перед документом>.").
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cltrnsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'bd':U ) no-error .
      if error-status :error then do:
        run waitfram-hide in parhandle no-error.
        undo bl-inv-on, return error return-value.
      end.
      for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo, return error return-value :
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cllinsum in g#lib-rwds ( input io_doc-line.doc-code ,
                       input 'bd':U ,
                       input io_doc-line.artic ,
                       input io_doc-line.prod-type ,
                       input io_doc-line.prod-code ) no-error .
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
      end.
      find first io-bef_trn-doc-sum where io-bef_trn-doc-sum.doc-code = io_trn-doc.doc-code and
                                          io-bef_trn-doc-sum.sum-type = 'bd':U   exclusive-lock.
      if varinvclcspvalue = "yes" then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cltrnsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'bcd':U ) no-error .
        if error-status :error then do:
          undo bl-inv-on, return error return-value.
        end.
        for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo, return error return-value :
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cllinsum in g#lib-rwds ( input io_doc-line.doc-code ,
                       input 'bcd':U ,
                       input io_doc-line.artic ,
                       input io_doc-line.prod-type ,
                       input io_doc-line.prod-code ) no-error .
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
        end.
        find first io-bef-cli_trn-doc-sum where io-bef-cli_trn-doc-sum.doc-code = io_trn-doc.doc-code   and
                                                io-bef-cli_trn-doc-sum.sum-type = 'bcd':U exclusive-lock.
      end.
    end.
  end.
  else do:
    if io_trn-doc.ext-doc-type = 'vt':U      or
       io_trn-doc.ext-doc-type = 'vp':U then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crtrnsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'bd':U ) no-error .
      if error-status :error then do:
        run waitfram-hide in parhandle no-error.
        undo bl-inv-on, return error return-value.
      end.
      find first io-bef_trn-doc-sum where io-bef_trn-doc-sum.doc-code = io_trn-doc.doc-code and
                                          io-bef_trn-doc-sum.sum-type = 'bd':U   exclusive-lock.
      if varinvclcspvalue = "yes" then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crtrnsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'bcd':U ) no-error .
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
        find first io-bef-cli_trn-doc-sum where io-bef-cli_trn-doc-sum.doc-code = io_trn-doc.doc-code and
                                                io-bef-cli_trn-doc-sum.sum-type = 'bcd':U   exclusive-lock.
      end.
      define buffer free_parts    for ub.parts  .
      define buffer out_parts     for ub.parts  .
      define buffer free_bar-code for ub.bar-code  .
      for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo, return error return-value :
        find first io_goods where io_goods.artic     = io_doc-line.artic     and
                                  io_goods.prod-type = io_doc-line.prod-type and
                                  io_goods.prod-code = io_doc-line.prod-code no-lock.
        for each free_parts no-lock where
                 free_parts.artic     = io_goods.artic     and
                 free_parts.prod-type = io_goods.prod-type and
                 free_parts.prod-code = io_goods.prod-code and
                 free_parts.obj-type  = io_trn-doc.obj-type and
                 free_parts.obj-code  = io_trn-doc.obj-code and
                 free_parts.out-code  = 'free-zone':U
                 :
            find first free_bar-code no-lock where
                       free_bar-code.in-code   = free_parts.in-code   and
                       free_bar-code.part-code = free_parts.part-code and
                       free_bar-code.gds-code  = io_goods.gds-code
                       no-error .
          if available free_bar-code then do:
             find first buf_doc-prts exclusive-lock where
                        buf_doc-prts.out-code = io_trn-doc.doc-code and
                        buf_doc-prts.b-code   = free_bar-code.b-code no-error .
             if not available buf_doc-prts then do:
                 create buf_doc-prts.
             end.
             assign
                buf_doc-prts.gds-code = free_bar-code.gds-code
                buf_doc-prts.out-code = io_trn-doc.doc-code
                buf_doc-prts.b-code   = free_bar-code.b-code
                buf_doc-prts.fact-qnty = free_parts.fact-qnty
             .
          end.
        end.
        for each out_parts no-lock where
                 out_parts.artic     = io_goods.artic     and
                 out_parts.prod-type = io_goods.prod-type and
                 out_parts.prod-code = io_goods.prod-code and
                 out_parts.obj-type  = io_trn-doc.obj-type and
                 out_parts.obj-code  = io_trn-doc.obj-code and
                 out_parts.out-code  = 'out-zone':U
                 :
            find first free_bar-code no-lock where
                       free_bar-code.in-code   = out_parts.in-code   and
                       free_bar-code.part-code = out_parts.part-code and
                       free_bar-code.gds-code  = io_goods.gds-code
                       no-error .
          if available free_bar-code then do:
             find first buf_doc-prts exclusive-lock where
                        buf_doc-prts.out-code = io_trn-doc.doc-code and
                        buf_doc-prts.b-code   = free_bar-code.b-code no-error .
             if not available buf_doc-prts then do:
                 create buf_doc-prts.
                  assign
                      buf_doc-prts.gds-code = free_bar-code.gds-code
                      buf_doc-prts.out-code = io_trn-doc.doc-code
                      buf_doc-prts.b-code   = free_bar-code.b-code
                      buf_doc-prts.fact-qnty = 0
                  .
             end.
          end.
        end.
        find first io-aft_doc-line-sum where io-aft_doc-line-sum.doc-code = io_doc-line.doc-code and
                                             io-aft_doc-line-sum.gds-code = io_goods.gds-code    and
                                             io-aft_doc-line-sum.sum-type = 'ad':U
                                             no-error.
        if available io-aft_doc-line-sum then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cctrnsum in g#lib-rwds ( input              io_doc-line.doc-code ,
                       input              io_doc-line.artic ,
                       input              io_doc-line.prod-type ,
                       input              io_doc-line.prod-code ,
                       input              'ad':U ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 "
                                                   + "документ &3 товар &4 &5 &6"
                                                   , return-value
                                                   , error-status :get-message( 1 )
                                                   , io_trn-doc.doc-code
                                                   , io_doc-line.artic
                                                   , io_doc-line.prod-type
                                                   , io_doc-line.prod-code ).
          end.
        end.
        if varinvclcspvalue = "yes" then do:
          find first io-aft-cli_doc-line-sum where io-aft-cli_doc-line-sum.doc-code = io_doc-line.doc-code and
                                                   io-aft-cli_doc-line-sum.gds-code = io_goods.gds-code    and
                                                   io-aft-cli_doc-line-sum.sum-type = 'acd':U no-error.
          if available io-aft-cli_doc-line-sum then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cctrnsum in g#lib-rwds ( input              io_doc-line.doc-code ,
                       input              io_doc-line.artic ,
                       input              io_doc-line.prod-type ,
                       input              io_doc-line.prod-code ,
                       input              'acd':U ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
            if error-status :error then do:
              run waitfram-hide in parhandle no-error.
              undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 "
                                                     + "документ &3 товар &4 &5 &6"
                                                     , return-value
                                                     , error-status :get-message( 1 )
                                                     , io_trn-doc.doc-code
                                                     , io_doc-line.artic
                                                     , io_doc-line.prod-type
                                                     , io_doc-line.prod-code ).
            end.
          end.
        end.
      end.
    end.
  end.
  assign
    varcount = 0.
  for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo bl-inv-on, return error :
    find first io_goods where io_goods.artic     = io_doc-line.artic     and
                              io_goods.prod-type = io_doc-line.prod-type and
                              io_goods.prod-code = io_doc-line.prod-code no-lock.
    assign
      varcount = varcount + 1.
    run waitfram-join in parhandle (  input "Заполнение  сумм <перед документом>."
                                   ,  input substitute( "Обработано строк: &1.", varcount )
                                   ,  input substitute( "Время: &1.", string( time - vartime, "hh:mm:ss":U ) )
                                   , output varmessage ).
    run waitfram-show in parhandle (  input varmessage ) no-error.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_filinvbd in g#lib-trn2
( input  io_trn-doc.ext-doc-type
 ,input  pariostatus
 ,input  parioflag
 ,input  io_trn-doc.doc-code
 ,input  io_trn-doc.obj-type
 ,input  io_trn-doc.obj-code
 ,input  io_doc-line.artic
 ,input  io_doc-line.prod-type
 ,input  io_doc-line.prod-code
 ,input  varinvclcspvalue
 ,input  varvalueol
 ,output variocur-qnty
 ,output variocur-cli-qnty
) no-error
.
    if error-status :error then do:
      run waitfram-hide in parhandle no-error.
      undo bl-inv-on, return error substitute( "Ошибка при пересчете документа &1 процедурой str/filinvbd.i &2 &3"
                                             , io_trn-doc.doc-code
                                             , return-value
                                             , error-status :get-message( 1 ) ).
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input io_doc-line.artic
  ,  input io_doc-line.prod-type
  ,  input io_doc-line.prod-code
  , output is-petrol
  , output is-pieces
  ) .
    if is-petrol = yes
      and is-pieces = no
    then do:
      find first io_inv-line
        where io_inv-line.doc-code  = io_doc-line.doc-code
          and io_inv-line.artic     = io_doc-line.artic
          and io_inv-line.prod-type = io_doc-line.prod-type
          and io_inv-line.prod-code = io_doc-line.prod-code
        .
      assign
        io_inv-line.before-cli-qnty = variocur-cli-qnty
      .
    end.
    if io_trn-doc.ext-doc-type = 'vt':U then do:
      if pariostatus = 'накл':U
        and parioflag   = yes
      then do:
        assign
          io_doc-line.doc-qnty  = variocur-qnty
          io_doc-line.fact-qnty = 0
        .
        if is-petrol = yes
          and is-pieces = no
        then do:
          assign
            io_doc-line.cli-qnty        = 0
            io_inv-line.wast-cli-qnty   = io_inv-line.before-cli-qnty
          .
        end.
      end.
      else do:
        run recalc-rasr- in this-procedure
          ( input  recid(io_doc-line)
           ,input  variocur-qnty
           ,input  (if available io_inv-line then recid(io_inv-line) else ? )
           ,input  variocur-cli-qnty
           ,output varchg-inv
          ) no-error.
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error substitute( "Ошибка при пересчете линии пересортицы: &1 &2."
                                                 , return-value
                                                 , error-status :get-message( 1 ) ).
        end.
      end.
    end.
    else do:
      if io_trn-doc.ext-doc-type = 'vp':U and
         parioflag = no                              then do:
        assign
          io_doc-line.doc-qnty  = variocur-qnty + io_doc-line.fact-qnty
        .
        if is-petrol = yes
          and is-pieces = no
        then do:
          assign
            io_inv-line.wast-cli-qnty   = io_doc-line.cli-qnty + variocur-cli-qnty
          .
        end.
      end.
      else do:
        assign
          io_doc-line.doc-qnty  = variocur-qnty
          io_doc-line.fact-qnty = 0
        .
        if is-petrol = yes
          and is-pieces = no
        then do:
          assign
            io_doc-line.cli-qnty        = 0
            io_inv-line.wast-cli-qnty   = io_inv-line.before-cli-qnty
          .
        end.
      end.
    end.
    if is-petrol = yes
      and is-pieces = no
    then do:
      assign
        io_inv-line.after-cli-qnty  = io_inv-line.wast-cli-qnty
        v-density = io_inv-line.after-cli-qnty / io_doc-line.doc-qnty
      .
      if v-density = ?
        or v-density = 0.0
      then do:
        assign
          v-density = 1 / io_goods.cli-base-rate
        .
        if valid-density( v-density, (io_goods.unit-base = io_goods.unit-cli) ) <> true then do:
          undo, return error substitute(  'В карточке товара указан некорректный коэффициент единиц измерения поставщика.&1'
                                          + 'Невозможно установить плотность товара.&1'
                                          + 'Документ: &2&1'
                                          + 'Товар: &3&1'
                                          + 'Плотность: &4&1'
                                          ,chr(10)
                                          ,io_trn-doc.doc-code
                                          ,io_goods.gds-code
                                          ,v-density
                                        ).
        end.
      end.
      assign
        io_doc-line.doc-density  = v-density
        io_doc-line.fact-density = io_doc-line.doc-density
      .
    end.
    run waitfram-show in parhandle ("Проверка возможности инвентаризации по товарам.") no-error.
    if parchk-rsrv = yes then do:
      for
 each io_parts no-lock
        where
            (     io_parts.prod-type = io_doc-line.prod-type
              and io_parts.prod-code = io_doc-line.prod-code
              and io_parts.artic     = io_doc-line.artic
              and io_parts.obj-type  = io_doc-line.obj-type
              and io_parts.obj-code  = io_doc-line.obj-code
              and io_parts.rsrv-free = true
              and io_parts.status_   = false
              and io_parts.out-code  <> 'free-zone':U
              and io_parts.out-code  <> io_trn-doc.doc-code
            )
            or
            (     io_parts.prod-type = io_doc-line.prod-type
              and io_parts.prod-code = io_doc-line.prod-code
              and io_parts.artic     = io_doc-line.artic
              and io_parts.obj-type  = io_doc-line.obj-type
              and io_parts.obj-code  = io_doc-line.obj-code
              and io_parts.rsrv-free = false
              and io_parts.status_   = false
              and io_parts.out-code  <> 'out-zone':U
              and io_parts.out-code  <> io_trn-doc.doc-code
            )
            on error undo bl-inv-on, return error
      :
        if io_trn-doc.ext-doc-type = 'vt':U then do:
          undo bl-inv-on, return error substitute( "Включить инвентаризацию нельзя - на товарах есть резервы. Товар &1 &2 "
                                                 + "&3. Документ &4 Список мешающих документов - на кнопке Список в докуме"
                                                 + "нте инвентаризации. Снятие по ним резервов - Главное меню / Сервис."
                                                 , io_doc-line.artic
                                                 , io_doc-line.prod-type
                                                 , io_doc-line.prod-code
                                                 , io_parts.out-code ).
        end.
        else do:
          undo bl-inv-on, return error substitute
                         ("Включить инвентаризацию нельзя - на товарах есть резервы. Товар &1 &2 &3. Документ &4.",
                         io_doc-line.artic,
                         io_doc-line.prod-type,
                         io_doc-line.prod-code,
                         io_parts.out-code).
        end.
      end.
    end.
  end.
  if io_trn-doc.ext-doc-type = 'vt':U      or
     io_trn-doc.ext-doc-type = 'vp':U then do:
    if (io_trn-doc.ext-doc-type = 'vt':U      and pariostatus = 'накл':U and parioflag   = yes or
        io_trn-doc.ext-doc-type = 'vp':U and pariostatus = 'накл':U and parioflag   = no     ) then do:
      if varvalueol = "yes" then do:
        run waitfram-show in parhandle ("Создание основных сумм по документу.") no-error.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crtrnsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'gen':U ) no-error .
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crtrnsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'ext':U ) no-error .
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crtrnsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'mis':U ) no-error .
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crtrnsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'ad':U ) no-error .
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
        if varinvclcspvalue = "yes" then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crtrnsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'extc':U ) no-error .
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crtrnsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'misc':U ) no-error .
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crtrnsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'genc':U ) no-error .
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crtrnsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'acd':U ) no-error .
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
        end.
        for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo, return error return-value :
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crlinsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'gen':U ,
                       input io_doc-line.artic ,
                       input io_doc-line.prod-type ,
                       input io_doc-line.prod-code ) no-error .
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
          if io_trn-doc.ext-doc-type = 'vp':U then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cctrnsum in g#lib-rwds ( input              io_doc-line.doc-code ,
                       input              io_doc-line.artic ,
                       input              io_doc-line.prod-type ,
                       input              io_doc-line.prod-code ,
                       input              'gen':U ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
            if error-status :error then do:
              undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 документ &3 " +
                                                       "товар &4 &5 &6"
                                                       , return-value
                                                       , error-status :get-message( 1 )
                                                       , io_trn-doc.doc-code
                                                       , io_doc-line.artic
                                                       , io_doc-line.prod-type
                                                       , io_doc-line.prod-code ).
            end.
          end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crlinsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'ad':U ,
                       input io_doc-line.artic ,
                       input io_doc-line.prod-type ,
                       input io_doc-line.prod-code ) no-error .
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cctrnsum in g#lib-rwds ( input              io_doc-line.doc-code ,
                       input              io_doc-line.artic ,
                       input              io_doc-line.prod-type ,
                       input              io_doc-line.prod-code ,
                       input              'ad':U ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 документ &3 товар &4 &5 &6", return-value, error-status :get-message( 1 ), io_trn-doc.doc-code, io_doc-line.artic, io_doc-line.prod-type, io_doc-line.prod-code).
          end.
          if varinvclcspvalue = "yes" then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crlinsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'genc':U ,
                       input io_doc-line.artic ,
                       input io_doc-line.prod-type ,
                       input io_doc-line.prod-code ) no-error .
            if error-status :error then do:
              run waitfram-hide in parhandle no-error.
              undo bl-inv-on, return error return-value.
            end.
            if io_trn-doc.ext-doc-type = 'vp':U then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cctrnsum in g#lib-rwds ( input              io_doc-line.doc-code ,
                       input              io_doc-line.artic ,
                       input              io_doc-line.prod-type ,
                       input              io_doc-line.prod-code ,
                       input              'genc':U ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
              if error-status :error then do:
                undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 документ &3 " +
                                                         "товар &4 &5 &6"
                                                         , return-value
                                                         , error-status :get-message( 1 )
                                                         , io_trn-doc.doc-code
                                                         , io_doc-line.artic
                                                         , io_doc-line.prod-type
                                                         , io_doc-line.prod-code ).
              end.
            end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crlinsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'acd':U ,
                       input io_doc-line.artic ,
                       input io_doc-line.prod-type ,
                       input io_doc-line.prod-code ) no-error .
            if error-status :error then do:
              run waitfram-hide in parhandle no-error.
              undo bl-inv-on, return error return-value.
            end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cctrnsum in g#lib-rwds ( input              io_doc-line.doc-code ,
                       input              io_doc-line.artic ,
                       input              io_doc-line.prod-type ,
                       input              io_doc-line.prod-code ,
                       input              'acd':U ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
            if error-status :error then do:
              run waitfram-hide in parhandle no-error.
              undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 документ &3 товар &4 &5 &6", return-value, error-status :get-message( 1 ), io_trn-doc.doc-code, io_doc-line.artic, io_doc-line.prod-type, io_doc-line.prod-code).
            end.
          end.
        end.
      end.
    end.
    run waitfram-show in parhandle ("Расчет сумм 'перед документом' по документу.") no-error.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input io_trn-doc.doc-code,
 input 'bd':U
) no-error
.
    if error-status :error then do:
      run waitfram-hide in parhandle no-error.
      undo bl-inv-on, return error substitute( "Ошибка: <&1 &2> при вызове процедуры str/reclctsl.i для документа &3. Тип суммы &4.", return-value, error-status :get-message( 1 ), io_trn-doc.doc-code, 'bd':U).
    end.
    if varinvclcspvalue = "yes" then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input io_trn-doc.doc-code,
 input 'bcd':U
) no-error
.
      if error-status :error then do:
        run waitfram-hide in parhandle no-error.
        undo bl-inv-on, return error substitute( "Ошибка: <&1 &2> при вызове процедуры str/reclctsl.i для документа &1. Тип суммы &2.", return-value, error-status :get-message( 1 ), io_trn-doc.doc-code, 'bcd':U).
      end.
    end.
    if varvalueol = "yes" then do:
      if io_trn-doc.ext-doc-type = 'vp':U then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input io_trn-doc.doc-code,
 input 'gen':U
) no-error
.
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input io_trn-doc.doc-code,
 input 'ad':U
) no-error
.
      if error-status :error then do:
        run waitfram-hide in parhandle no-error.
        undo bl-inv-on, return error return-value.
      end.
      if varinvclcspvalue = "yes" then do:
        if io_trn-doc.ext-doc-type = 'vp':U then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input io_trn-doc.doc-code,
 input 'genc':U
) no-error
.
        end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input io_trn-doc.doc-code,
 input 'acd':U
) no-error
.
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
      end.
    end.
    if io_trn-doc.status_ = 'разрешен':U and
       not io_trn-doc.flag_              then do:
      if wastagevalue = "yes" and
         varvaluewt   = "yes" then do:
        run waitfram-show in parhandle ("Очистка сумм <естественная убыль>.").
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cltrnsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'wst':U ) no-error .
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
        find first io-wst_trn-doc-sum where io-wst_trn-doc-sum.doc-code = io_trn-doc.doc-code and
                                            io-wst_trn-doc-sum.sum-type = 'wst':U  exclusive-lock.
        for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo, return error return-value :
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cllinsum in g#lib-rwds ( input io_doc-line.doc-code ,
                       input 'wst':U ,
                       input io_doc-line.artic ,
                       input io_doc-line.prod-type ,
                       input io_doc-line.prod-code ) no-error .
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
        end.
        if varinvclcspvalue = "yes" then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cltrnsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'wstc':U ) no-error .
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
          find first io-wst-cli_trn-doc-sum where io-wst-cli_trn-doc-sum.doc-code = io_trn-doc.doc-code    and
                                                  io-wst-cli_trn-doc-sum.sum-type = 'wstc':U exclusive-lock.
          for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo, return error return-value :
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cllinsum in g#lib-rwds ( input io_doc-line.doc-code ,
                       input 'wstc':U ,
                       input io_doc-line.artic ,
                       input io_doc-line.prod-type ,
                       input io_doc-line.prod-code ) no-error .
            if error-status :error then do:
              run waitfram-hide in parhandle no-error.
              undo bl-inv-on, return error return-value.
            end.
          end.
        end.
      end.
    end.
    else do:
      if wastagevalue = "yes" and
         varvaluewt   = "yes" then do:
        run waitfram-show in parhandle ("Создание сумм естественной убыли по документу.") no-error.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crtrnsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'wst':U ) no-error .
        if error-status :error then do:
          run waitfram-hide in parhandle no-error.
          undo bl-inv-on, return error return-value.
        end.
        find first io-wst_trn-doc-sum where io-wst_trn-doc-sum.doc-code = io_trn-doc.doc-code and
                                            io-wst_trn-doc-sum.sum-type = 'wst':U  exclusive-lock.
        for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo, return error return-value :
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crlinsum in g#lib-rwds ( input io_doc-line.doc-code ,
                       input 'wst':U ,
                       input io_doc-line.artic ,
                       input io_doc-line.prod-type ,
                       input io_doc-line.prod-code ) no-error .
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
        end.
        if varinvclcspvalue = "yes" then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crtrnsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'wstc':U ) no-error .
          if error-status :error then do:
            run waitfram-hide in parhandle no-error.
            undo bl-inv-on, return error return-value.
          end.
          find first io-wst-cli_trn-doc-sum where io-wst-cli_trn-doc-sum.doc-code = io_trn-doc.doc-code   and
                                                  io-wst-cli_trn-doc-sum.sum-type = 'wstc':U exclusive-lock.
          for each io_doc-line where io_doc-line.doc-code = io_trn-doc.doc-code on error undo, return error return-value :
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crlinsum in g#lib-rwds ( input io_doc-line.doc-code ,
                       input 'wstc':U ,
                       input io_doc-line.artic ,
                       input io_doc-line.prod-type ,
                       input io_doc-line.prod-code ) no-error .
            if error-status :error then do:
              run waitfram-hide in parhandle no-error.
              undo bl-inv-on, return error return-value.
            end.
          end.
        end.
      end.
    end.
    if wastagevalue = "yes" and
       varvaluewt   = "yes" then do:
      run waitfram-show in parhandle ("Расчет естественной убыли по документу.") no-error.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_ccwstsum in g#lib-rwds ( input              io_trn-doc.doc-code ,
                       input              parhandle ,
                       input-output table tt-wast-line ) no-error .
      if error-status :error then do:
         run waitfram-hide in parhandle no-error.
         undo bl-inv-on, return error substitute( "Ошибка &1 &2 при расчете норм естественной убыли.",
                                                  return-value,
                                                  error-status :get-message( 1 ) ).
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input io_trn-doc.doc-code,
 input 'wst':U
) no-error
.
      if error-status :error then do:
         run waitfram-hide in parhandle no-error.
         undo bl-inv-on, return error substitute( "Ошибка &1 &2 при записи в шапку документа естественной убыли.",
                                      return-value,
                                      error-status :get-message( 1 ) ).
      end.
      if varinvclcspvalue = "yes" then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input io_trn-doc.doc-code,
 input 'wstc':U
) no-error
.
        if error-status :error then do:
           run waitfram-hide in parhandle no-error.
           undo bl-inv-on, return error substitute( "Ошибка &1 &2 при записи в шапку документа естественной убыли.",
                                        return-value,
                                        error-status :get-message( 1 ) ).
        end.
      end.
    end.
  end.
end.
run waitfram-hide in parhandle no-error.
end procedure.
procedure lib-trn2_filinvln :
define input  parameter pariodoc-code   like ub.doc-line.doc-code   no-undo.
define input  parameter parioartic      like ub.doc-line.artic      no-undo.
define input  parameter parioprod-type  like ub.doc-line.prod-type  no-undo.
define input  parameter parioprod-code  like ub.doc-line.prod-code  no-undo.
define input  parameter parhandle       as   handle                 no-undo.
define variable variocur-qnty         like ub.doc-line.fact-qnty  no-undo.
define variable variocur-cli-qnty     like ub.doc-line.fact-qnty  no-undo.
define variable wastagevalue          as   character              no-undo.
define variable wastagetype           as   character              no-undo.
define variable varchg-inv            as   logical                no-undo.
define variable varlns-cnt            as   integer                no-undo.
define variable varvalue              like ub.doc-attr.attr-value no-undo.
define variable vartype               as   character              no-undo.
define variable varvaluewt            as   character              no-undo.
define variable vartypewt             as   character              no-undo.
define variable varvalueol            as   character              no-undo.
define variable vartypeol             as   character              no-undo.
define buffer io_trn-doc              for ub.trn-doc.
define buffer io_doc-line             for ub.doc-line.
define buffer io_goods                for ub.goods.
define buffer io_parts                for ub.parts.
define buffer io-bef_trn-doc-sum      for ub.trn-doc-sum.
define buffer io-bef-cli_trn-doc-sum  for ub.trn-doc-sum.
define buffer io-wst_trn-doc-sum      for ub.trn-doc-sum.
define buffer io-wst-cli_trn-doc-sum  for ub.trn-doc-sum.
define buffer io-bef_doc-line-sum     for ub.doc-line-sum.
define buffer io-bef-cli_doc-line-sum for ub.doc-line-sum.
define buffer io-wst_doc-line-sum     for ub.doc-line-sum.
define buffer io-wst-cli_doc-line-sum for ub.doc-line-sum.
define buffer io-aft-cli_doc-line-sum for ub.doc-line-sum.
define buffer io-aft_doc-line-sum     for ub.doc-line-sum.
define variable varinvclcspvalue as character no-undo.
define variable varinvclcsptype  as character no-undo.
define variable vartime          as integer   no-undo.
define variable varcount         as integer   no-undo.
define variable varmessage       as character no-undo.
bl-inv-on:
do transaction on error undo bl-inv-on, return error substitute( "Ошибка &1 &2 при вызове процедуры filinvln.", return-value, error-status :get-message( 1 ) ):
  find first io_trn-doc  where io_trn-doc.doc-code =  pariodoc-code.
  find first io_doc-line where io_doc-line.doc-code  = io_trn-doc.doc-code and
                               io_doc-line.artic     = parioartic          and
                               io_doc-line.prod-type = parioprod-type      and
                               io_doc-line.prod-code = parioprod-code      .
  find first io_goods where io_goods.artic     = io_doc-line.artic     and
                            io_goods.prod-type = io_doc-line.prod-type and
                            io_goods.prod-code = io_doc-line.prod-code no-lock.
  if not ( io_trn-doc.ext-doc-type = 'vt':U      or
           io_trn-doc.ext-doc-type = 'vp':U )
     then do:
     return error substitute( "Неверный расширенный тип документа &1.", io_trn-doc.ext-doc-type).
  end.
  run trg/lock-gds.p
    (input io_trn-doc.doc-code
    ,input yes
    ,input yes
    ,input 0
    ,input 0
    ,input false
    ,input false
    ) no-error.
  if error-status :error then do:
    undo bl-inv-on, return error return-value.
  end.
  assign
    vartime = time.
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input io_trn-doc.obj-type
  ,input io_trn-doc.obj-code
  ,input 'inv-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'invclcsp'  then varinvclcspvalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
        if thbjattr_thbj-attr.prop-code = 'wastage'   then wastagevalue  = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
    end.
    empty temp-table thbjattr_thbj-attr.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input io_trn-doc.doc-code ,
                        input 'clcaswt':U ,
                       output varvaluewt ,
                       output vartypewt ) no-error .
  if error-status :error then do:
    undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры tdat-val &1 &2."
                                           , return-value
                                           , error-status :get-message( 1 ) ).
  end.
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input io_trn-doc.doc-code ,
                        input 'clcasol':U ,
                       output varvalueol ,
                       output vartypeol ) no-error .
  if error-status :error then do:
    undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры tdat-val &1 &2."
                                           , return-value
                                           , error-status :get-message( 1 ) ).
  end.
  find first io-bef_trn-doc-sum where io-bef_trn-doc-sum.doc-code = io_trn-doc.doc-code and
                                      io-bef_trn-doc-sum.sum-type = 'bd':U   exclusive-lock.
  if varinvclcspvalue = "yes" then do:
    find first io-bef-cli_trn-doc-sum where io-bef-cli_trn-doc-sum.doc-code = io_trn-doc.doc-code   and
                                            io-bef-cli_trn-doc-sum.sum-type = 'bcd':U exclusive-lock.
  end.
  if varinvclcspvalue = "yes" then do:
    find first io-bef-cli_trn-doc-sum where io-bef-cli_trn-doc-sum.doc-code = io_trn-doc.doc-code and
                                            io-bef-cli_trn-doc-sum.sum-type = 'bcd':U   exclusive-lock.
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_filinvbd in g#lib-trn2
( input  io_trn-doc.ext-doc-type
 ,input  'накл':U
 ,input  yes
 ,input  io_trn-doc.doc-code
 ,input  io_trn-doc.obj-type
 ,input  io_trn-doc.obj-code
 ,input  io_doc-line.artic
 ,input  io_doc-line.prod-type
 ,input  io_doc-line.prod-code
 ,input  varinvclcspvalue
 ,input  varvalueol
 ,output variocur-qnty
 ,output variocur-cli-qnty
) no-error
.
  if error-status :error then do:
    undo bl-inv-on, return error substitute( "Ошибка при пересчете документа &1 процедурой str/filinvbd.i &2 &3", io_trn-doc.doc-code, return-value, error-status :get-message( 1 ) ).
  end.
  if varvalueol = "yes" then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crlinsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'gen':U ,
                       input io_doc-line.artic ,
                       input io_doc-line.prod-type ,
                       input io_doc-line.prod-code ) no-error .
    if error-status :error then do:
      undo bl-inv-on, return error return-value.
    end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crlinsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'ad':U ,
                       input io_doc-line.artic ,
                       input io_doc-line.prod-type ,
                       input io_doc-line.prod-code ) no-error .
    if error-status :error then do:
      undo bl-inv-on, return error return-value.
    end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cctrnsum in g#lib-rwds ( input              io_doc-line.doc-code ,
                       input              io_doc-line.artic ,
                       input              io_doc-line.prod-type ,
                       input              io_doc-line.prod-code ,
                       input              'ad':U ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
    if error-status :error then do:
      undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 документ &3 товар &4 &5 &6", return-value, error-status :get-message( 1 ), io_trn-doc.doc-code, io_doc-line.artic, io_doc-line.prod-type, io_doc-line.prod-code).
    end.
    if varinvclcspvalue = "yes" then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crlinsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'genc':U ,
                       input io_doc-line.artic ,
                       input io_doc-line.prod-type ,
                       input io_doc-line.prod-code ) no-error .
      if error-status :error then do:
        undo bl-inv-on, return error return-value.
      end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crlinsum in g#lib-rwds ( input io_trn-doc.doc-code ,
                       input 'acd':U ,
                       input io_doc-line.artic ,
                       input io_doc-line.prod-type ,
                       input io_doc-line.prod-code ) no-error .
      if error-status :error then do:
        undo bl-inv-on, return error return-value.
      end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cctrnsum in g#lib-rwds ( input              io_doc-line.doc-code ,
                       input              io_doc-line.artic ,
                       input              io_doc-line.prod-type ,
                       input              io_doc-line.prod-code ,
                       input              'acd':U ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
      if error-status :error then do:
        undo bl-inv-on, return error substitute( "Ошибка при вызове процедуры lib-rwds_cctrnsum &1 &2 документ &3 товар &4 &5 &6", return-value, error-status :get-message( 1 ), io_trn-doc.doc-code, io_doc-line.artic, io_doc-line.prod-type, io_doc-line.prod-code).
      end.
    end.
  end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input io_trn-doc.doc-code,
 input 'bd':U
) no-error
.
  if error-status :error then do:
    undo bl-inv-on, return error substitute( "Ошибка: <&1 &2> при вызове процедуры str/reclctsl.i для документа &3. Тип суммы &4.", return-value, error-status :get-message( 1 ), io_trn-doc.doc-code, 'bd':U).
  end.
  if varinvclcspvalue = "yes" then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input io_trn-doc.doc-code,
 input 'bcd':U
) no-error
.
    if error-status :error then do:
      undo bl-inv-on, return error substitute( "Ошибка: <&1 &2> при вызове процедуры str/reclctsl.i для документа &1. Тип суммы &2.", return-value, error-status :get-message( 1 ), io_trn-doc.doc-code, 'bcd':U).
    end.
  end.
  if varvalueol = "yes" then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input io_trn-doc.doc-code,
 input 'ad':U
) no-error
.
    if error-status :error then do:
      undo bl-inv-on, return error return-value.
    end.
    if varinvclcspvalue = "yes" then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input io_trn-doc.doc-code,
 input 'acd':U
) no-error
.
      if error-status :error then do:
        undo bl-inv-on, return error return-value.
      end.
    end.
  end.
  if wastagevalue = "yes" and
     varvaluewt   = "yes" then do:
    find first io-wst_trn-doc-sum where io-wst_trn-doc-sum.doc-code = io_trn-doc.doc-code and
                                        io-wst_trn-doc-sum.sum-type = 'wst':U  exclusive-lock.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crlinsum in g#lib-rwds ( input io_doc-line.doc-code ,
                       input 'wst':U ,
                       input io_doc-line.artic ,
                       input io_doc-line.prod-type ,
                       input io_doc-line.prod-code ) no-error .
    if error-status :error then do:
      undo bl-inv-on, return error return-value.
    end.
    if varinvclcspvalue = "yes" then do:
      find first io-wst-cli_trn-doc-sum where io-wst-cli_trn-doc-sum.doc-code = io_trn-doc.doc-code   and
                                              io-wst-cli_trn-doc-sum.sum-type = 'wstc':U exclusive-lock.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crlinsum in g#lib-rwds ( input io_doc-line.doc-code ,
                       input 'wstc':U ,
                       input io_doc-line.artic ,
                       input io_doc-line.prod-type ,
                       input io_doc-line.prod-code ) no-error .
      if error-status :error then do:
        undo bl-inv-on, return error return-value.
      end.
    end.
  end.
  if wastagevalue = "yes" and
     varvaluewt   = "yes" then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_ccwstsum in g#lib-rwds ( input              io_trn-doc.doc-code ,
                       input              parhandle ,
                       input-output table tt-wast-line ) no-error .
    if error-status :error then do:
       undo bl-inv-on, return error substitute( "Ошибка &1 &2 при расчете норм естественной убыли.",
                                                return-value,
                                                error-status :get-message( 1 ) ).
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input io_trn-doc.doc-code,
 input 'wst':U
) no-error
.
    if error-status :error then do:
       undo bl-inv-on, return error substitute( "Ошибка &1 &2 при записи в шапку документа естественной убыли.",
                                    return-value,
                                    error-status :get-message( 1 ) ).
    end.
    if varinvclcspvalue = "yes" then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:   run str/lib-trn2.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn2) <> true) then do:     message       "Error starting lib-trn2.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn2_reclctsl in g#lib-trn2
(input io_trn-doc.doc-code,
 input 'wstc':U
) no-error
.
      if error-status :error then do:
         undo bl-inv-on, return error substitute( "Ошибка &1 &2 при записи в шапку документа естественной убыли.",
                                      return-value,
                                      error-status :get-message( 1 ) ).
      end.
    end.
  end.
end.
end procedure.
procedure lib-trn2_filinvbd :
  define input parameter  par-cb-ext-doc-type like ub.trn-doc.ext-doc-type    no-undo.
  define input parameter  par-cb-status       like ub.trn-doc.doc-code        no-undo.
  define input parameter  par-cb-flag         like ub.trn-doc.flag_           no-undo.
  define input parameter  par-cb-doc-code     like ub.trn-doc.doc-code        no-undo.
  define input parameter  par-cb-obj-type     like ub.trn-doc.obj-type        no-undo.
  define input parameter  par-cb-obj-code     like ub.trn-doc.obj-code        no-undo.
  define input parameter  par-cb-artic        like ub.doc-line.artic          no-undo.
  define input parameter  par-cb-prod-type    like ub.doc-line.prod-type      no-undo.
  define input parameter  par-cb-prod-code    like ub.doc-line.prod-code      no-undo.
  define input parameter  parinvclcspvalue    as   character                  no-undo.
  define input parameter  parvalueol          as   character                  no-undo.
  define output parameter parcur-qnty         like ub.doc-line.fact-qnty       no-undo.
  define output parameter parcur-cli-qnty     like ub.inv-line.before-cli-qnty no-undo.
  do
  on error undo, return error return-value
  :
    define variable vartot-doc              like ub.trn-doc.doc-code  no-undo.
    define variable vartot-rubl             like ub.trn-doc.tot-rubl  no-undo.
    define variable v-ts-doc-line_tot-ov    like ub.trn-doc.tot-ov    no-undo.
    define variable v-ts-doc-line_fact-rubl like ub.trn-doc.fact-rubl no-undo.
    define variable v-ts-doc-line_fact-base like ub.trn-doc.fact-base no-undo.
    define variable v-ts-doc-line_fact-qnty like ub.trn-doc.fact-qnty no-undo.
    define variable v-ts-doc-line_doc-qnty  like ub.trn-doc.doc-qnty  no-undo.
    define variable v-ts-doc-line_cli-qnty  like ub.trn-doc.cli-qnty  no-undo.
    define variable varfact-date            as date      no-undo.
    define variable varfact-time            as integer   no-undo.
    define variable varfact-num             as integer   no-undo.
    define variable varshift-date           as date      no-undo.
    define variable varshift-num            as integer   no-undo.
    define variable varshift-on             as logical   no-undo.
    define variable varfact-order           as decimal   no-undo.
    define variable varshift-fo             as decimal   no-undo.
    define variable varday-fo               as decimal   no-undo.
    define variable v-pl-qnty               as decimal   no-undo.
    define variable v-pl-cli-qnty           as decimal   no-undo.
    define variable v-reserv-pl             as logical   no-undo .
    define variable v-rowid                 as rowid     no-undo .
    define variable is-petrol               as logical   no-undo.
    define variable is-pieces               as logical   no-undo.
    define variable v-day                   as date      no-undo .
    define variable v-ok                    as logical   no-undo .
    define variable v-value                 as character no-undo .
    define buffer cb_gds-obj    for ub.gds-obj.
    define buffer cb_trn-doc    for ub.trn-doc.
    define buffer cb_doc-line   for ub.doc-line.
    define buffer cb_inv-line   for ub.inv-line .
    define buffer cb_prt-obj    for ub.prt-obj.
    define buffer cb_gds-dtl    for ub.gds-dtl.
    define buffer cb_doc-pl     for ub.doc-pl.
    define buffer cb_goods      for ub.goods .
    define buffer cb_pl-gds     for ub.pl-gds .
    define buffer prev_doc-line for ub.doc-line .
    define buffer prev_inv-line for ub.inv-line .
    find first cb_trn-doc
      where cb_trn-doc.doc-code = par-cb-doc-code
      .
    find first cb_doc-line
      where cb_doc-line.doc-code  = cb_trn-doc.doc-code
        and cb_doc-line.artic     = par-cb-artic
        and cb_doc-line.prod-type = par-cb-prod-type
        and cb_doc-line.prod-code = par-cb-prod-code
      .
    find first cb_goods
      where cb_goods.artic     = par-cb-artic
        and cb_goods.prod-type = par-cb-prod-type
        and cb_goods.prod-code = par-cb-prod-code
      .
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  cb_doc-line.obj-type
  ,input  cb_doc-line.obj-code
  ,input  cb_doc-line.artic
  ,input  cb_doc-line.prod-type
  ,input  cb_doc-line.prod-code
  ,input  'place-rsrv=request'
  ,output v-reserv-pl
  )  .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input cb_doc-line.artic
  ,  input cb_doc-line.prod-type
  ,  input cb_doc-line.prod-code
  , output is-petrol
  , output is-pieces
  ) .
    if cb_trn-doc.fact-date = ? then do:
      assign
        varfact-order = ?
      .
      find first cb_gds-obj
          where cb_gds-obj.obj-type  = par-cb-obj-type
            and cb_gds-obj.obj-code  = par-cb-obj-code
            and cb_gds-obj.artic     = par-cb-artic
            and cb_gds-obj.prod-type = par-cb-prod-type
            and cb_gds-obj.prod-code = par-cb-prod-code
          no-error .
      if available cb_gds-obj then do:
        assign
          cb_trn-doc.doc-qnty    = cb_trn-doc.doc-qnty    + cb_gds-obj.fact-qnty
          cb_trn-doc.tot-calc    = cb_trn-doc.tot-calc    + cb_gds-obj.fact-base
          cb_trn-doc.discnt-rubl = cb_trn-doc.discnt-rubl + cb_gds-obj.fact-rubl
          parcur-qnty            = cb_gds-obj.fact-qnty.
      end.
      else do:
        assign
          parcur-qnty = cb_gds-obj.fact-qnty.
      end.
      if cb_trn-doc.ext-doc-type = 'vp':U then do:
        for each cb_gds-dtl exclusive-lock
          where cb_gds-dtl.doc-code  = cb_doc-line.doc-code
            and cb_gds-dtl.artic     = cb_doc-line.artic
            and cb_gds-dtl.prod-type = cb_doc-line.prod-type
            and cb_gds-dtl.prod-code = cb_doc-line.prod-code
        on error undo, return error return-value
        :
          find first cb_prt-obj
            where cb_prt-obj.obj-type  = par-cb-obj-type
              and cb_prt-obj.obj-code  = par-cb-obj-code
              and cb_prt-obj.artic     = par-cb-artic
              and cb_prt-obj.prod-type = par-cb-prod-type
              and cb_prt-obj.prod-code = par-cb-prod-code
              and cb_prt-obj.prt-code  = cb_gds-dtl.prt-code
            no-error.
          if available cb_prt-obj then do:
            assign
              cb_gds-dtl.fact-qnty = cb_gds-dtl.doc-qnty + cb_prt-obj.fact-qnty
            .
          end.
          else do:
            assign
              cb_gds-dtl.fact-qnty = cb_gds-dtl.doc-qnty
            .
          end.
        end.
      end.
      if v-reserv-pl = true then do:
        for each cb_pl-gds share-lock
          where cb_pl-gds.gds-code  = cb_goods.gds-code
            and cb_pl-gds.obj-type  = cb_doc-line.obj-type
            and cb_pl-gds.obj-code  = cb_doc-line.obj-code
        on error undo, return error return-value
        :
          run placelib_get-attr  ( input "place-com-tanks"
                                  ,input cb_pl-gds.obj-code
                                  ,input cb_pl-gds.obj-type
                                  ,input cb_pl-gds.pl-code
                                  ,output v-value
                                  ,output v-ok      ) no-error.
          if  v-ok
          and v-value > ""
          then do :
            run placelib_get-attr  ( input "place-is-main"
                                    ,input cb_pl-gds.obj-code
                                    ,input cb_pl-gds.obj-type
                                    ,input cb_pl-gds.pl-code
                                    ,output v-value
                                    ,output v-ok      ) no-error.
            if v-ok and logical(v-value)
            then do :
            end .
            else do :
              next .
            end .
          end .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdocpl in g#lib-trn
(input  cb_doc-line.doc-code
,input  cb_pl-gds.gds-code
,input  cb_pl-gds.pl-code
,input  cb_pl-gds.obj-type
,input  cb_pl-gds.obj-code
,output v-rowid
)
.
          find first cb_doc-pl exclusive-lock
            where rowid(cb_doc-pl) = v-rowid
            .
          assign
            cb_doc-pl.rest-bf-qnty     = cb_pl-gds.fact-qnty
            cb_doc-pl.cli-rest-bf-qnty = cb_pl-gds.cli-fact-qnty
          .
        end.
      end.
    end.
    else do:
      assign
        varfact-date  = cb_trn-doc.fact-date
        varfact-time  = cb_trn-doc.fact-time
        varfact-num   = current-value( s-trn-fact, ub ) + 1
        varshift-date = cb_trn-doc.shift-date
        varshift-num  = cb_trn-doc.shift-num
      .
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  cb_trn-doc.obj-type
  ,input  cb_trn-doc.obj-code
  ,input  'shift-on=request'
  ,output varshift-on
  ) no-error .
      if error-status :error or
        varshift-on = ? then do:
        assign
          varshift-date = ?
          varshift-num  = 0
          varshift-on   = no
        .
      end.
      if varfact-time = ? or
         varfact-time = 0 then do:
        run cur-time in this-procedure
          ( output v-day
           ,output varfact-time
          ) .
      end.
      if varshift-on = yes then do:
        if varshift-date = ? then do:
          return error substitute ("Установлена фактическая дата закрытия документа задним числом, но не установлена дата смены. Номер документа: &1.", cb_trn-doc.doc-code).
        end.
        if varshift-num = 0 or
          varshift-num = ? then do:
          return error substitute ("Установлена фактическая дата закрытия документа задним числом, но не установлен номер смены. Номер документа: &1.", cb_trn-doc.doc-code).
        end.
      end.
      run factord in this-procedure
        ( input varfact-date
         ,input varfact-time
         ,input varfact-num
         ,input varshift-date
         ,input varshift-num
         ,input varshift-on
         ,output varfact-order
         ,output varshift-fo
         ,output varday-fo
        ) no-error.
      if error-status:error then do:
        return error substitute ("Ошибка при определении fact-order для документа закрываемого задним числом. Дата документа &1 время &2 фактический номер &3 дата смены &4 номер смены &5.",
                                varfact-date,
                                varfact-time,
                                varfact-num,
                                varshift-date,
                                varshift-num).
      end.
      for each temp-prt-obj
      on error undo, return error return-value
      :
        delete temp-prt-obj.
      end.
      run prdoclib-init-prt-obj-by-factord in this-procedure
        ( input cb_doc-line.obj-type
         ,input cb_doc-line.obj-code
         ,input cb_doc-line.artic
         ,input cb_doc-line.prod-type
         ,input cb_doc-line.prod-code
         ,input varfact-order
         ,input true
        ) no-error.
      if error-status:error then do:
        return error substitute ("Документ &1. Ошибка при расчете остатка по признакам товара &2.", cb_doc-line.doc-code, return-value).
      end.
      assign
        parcur-qnty = 0.0
      .
      for each temp-prt-obj
      on error undo, return error return-value
      :
        assign
          parcur-qnty = parcur-qnty + temp-prt-obj.fact-qnty
        .
      end.
      for each cb_gds-dtl exclusive-lock
        where cb_gds-dtl.doc-code  = cb_doc-line.doc-code
          and cb_gds-dtl.artic     = cb_doc-line.artic
          and cb_gds-dtl.prod-type = cb_doc-line.prod-type
          and cb_gds-dtl.prod-code = cb_doc-line.prod-code
      on error undo, return error return-value
      :
        find first temp-prt-obj
          where temp-prt-obj.prt-code = cb_gds-dtl.prt-code
          no-error.
        if available temp-prt-obj then do:
          assign
            cb_gds-dtl.fact-qnty = cb_gds-dtl.doc-qnty + temp-prt-obj.fact-qnty.
        end.
        else do:
          assign
            cb_gds-dtl.fact-qnty = cb_gds-dtl.doc-qnty.
        end.
      end.
      if v-reserv-pl = true then do:
        run prdoclib-init-pl-gds-by-factord in this-procedure
          ( input cb_doc-line.obj-type
           ,input cb_doc-line.obj-code
           ,input cb_doc-line.artic
           ,input cb_doc-line.prod-type
           ,input cb_doc-line.prod-code
           ,input varfact-order
           ,input true
          ) no-error.
        if error-status:error then do:
          return error substitute ("Документ &2.&1Ошибка при расчете остатка по местам хранения товара.&1&3.", chr(10), cb_doc-line.doc-code, return-value).
        end.
        for each temp-pl-gds
        on error undo, return error return-value
        :
          run placelib_get-attr  ( input "place-com-tanks"
                                  ,input temp-pl-gds.obj-code
                                  ,input temp-pl-gds.obj-type
                                  ,input temp-pl-gds.pl-code
                                  ,output v-value
                                  ,output v-ok      ) no-error.
          if  v-ok
          and v-value > ""
          then do :
            run placelib_get-attr  ( input "place-is-main"
                                    ,input temp-pl-gds.obj-code
                                    ,input temp-pl-gds.obj-type
                                    ,input temp-pl-gds.pl-code
                                    ,output v-value
                                    ,output v-ok      ) no-error.
            if v-ok and logical(v-value)
            then do :
            end .
            else do :
              next .
            end .
          end .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_crdocpl in g#lib-trn
(input  cb_doc-line.doc-code
,input  temp-pl-gds.gds-code
,input  temp-pl-gds.pl-code
,input  temp-pl-gds.obj-type
,input  temp-pl-gds.obj-code
,output v-rowid
)
.
          find first cb_doc-pl exclusive-lock
            where rowid(cb_doc-pl) = v-rowid
            .
          assign
            cb_doc-pl.rest-bf-qnty     = temp-pl-gds.fact-qnty
            cb_doc-pl.cli-rest-bf-qnty = temp-pl-gds.cli-fact-qnty
          .
        end.
      end.
    end.
    if v-reserv-pl = true then do:
      assign
        v-pl-qnty     = 0.0
        v-pl-cli-qnty = 0.0
      .
      for each cb_doc-pl exclusive-lock
        where cb_doc-pl.out-code = cb_doc-line.doc-code
          and cb_doc-pl.gds-code = cb_goods.gds-code
          and cb_doc-pl.obj-type = cb_doc-line.obj-type
          and cb_doc-pl.obj-code = cb_doc-line.obj-code
      on error undo, return error return-value
      :
        find first cb_pl-gds share-lock
          where cb_pl-gds.obj-type = cb_doc-pl.obj-type
            and cb_pl-gds.obj-code = cb_doc-pl.obj-code
            and cb_pl-gds.pl-code  = cb_doc-pl.pl-code
            and cb_pl-gds.gds-code = cb_doc-pl.gds-code
          no-error .
        if not available cb_pl-gds then do:
          delete cb_doc-pl.
        end.
        else do:
          assign
            cb_doc-pl.rest-af-qnty     = cb_doc-pl.rest-bf-qnty     + (if cb_doc-pl.fact-qnty <> ? then cb_doc-pl.fact-qnty else 0.0)
            cb_doc-pl.cli-rest-af-qnty = cb_doc-pl.cli-rest-bf-qnty + (if cb_doc-pl.cli-fact-qnty <> ? then cb_doc-pl.cli-fact-qnty else 0.0)
            v-pl-qnty                  = v-pl-qnty     + cb_doc-pl.rest-bf-qnty
            v-pl-cli-qnty              = v-pl-cli-qnty + cb_doc-pl.cli-rest-bf-qnty
          .
        end.
      end.
      if v-pl-qnty <> parcur-qnty then do:
        return error substitute( "Документ &2.&1"
                                + "Ошибка при расчете остатка по местам хранения товара.&1"
                                + "Товар: &3&1"
                                + "Остаток по товару: &4 (&6)&1"
                                + "Остаток по местам хранения: &5 (&6)&1"
                                ,chr(10)
                                ,cb_doc-line.doc-code
                                ,cb_goods.gds-code
                                ,parcur-qnty
                                ,v-pl-qnty
                                ,cb_goods.unit-base
                                ).
      end.
      if is-petrol = yes
        and is-pieces = no
      then do:
        find first cb_inv-line
          where cb_inv-line.doc-code  = cb_doc-line.doc-code
            and cb_inv-line.artic     = cb_doc-line.artic
            and cb_inv-line.prod-type = cb_doc-line.prod-type
            and cb_inv-line.prod-code = cb_doc-line.prod-code
          .
        assign
          parcur-cli-qnty = 0.0
        .
        if varfact-order = ? then do:
          find last prev_doc-line no-lock
            where prev_doc-line.obj-type   = cb_doc-line.obj-type
              and prev_doc-line.obj-code   = cb_doc-line.obj-code
              and prev_doc-line.prod-type  = cb_doc-line.prod-type
              and prev_doc-line.prod-code  = cb_doc-line.prod-code
              and prev_doc-line.artic      = cb_doc-line.artic
              and prev_doc-line.status_    = 'факт':U
              and prev_doc-line.fact-order > 0
            use-index fact-order
            no-error.
        end.
        else do:
          find last prev_doc-line no-lock
            where prev_doc-line.obj-type   = cb_doc-line.obj-type
              and prev_doc-line.obj-code   = cb_doc-line.obj-code
              and prev_doc-line.prod-type  = cb_doc-line.prod-type
              and prev_doc-line.prod-code  = cb_doc-line.prod-code
              and prev_doc-line.artic      = cb_doc-line.artic
              and prev_doc-line.status_    = 'факт':U
              and prev_doc-line.fact-order > 0
              and prev_doc-line.fact-order < varfact-order
            use-index fact-order
            no-error.
        end.
        if available prev_doc-line then do:
          find first prev_inv-line no-lock
            where prev_inv-line.doc-code  = prev_doc-line.doc-code
              and prev_inv-line.artic     = prev_doc-line.artic
              and prev_inv-line.prod-code = prev_doc-line.prod-code
              and prev_inv-line.prod-type = prev_doc-line.prod-type
            no-error.
          if available prev_inv-line then do:
            assign
              parcur-cli-qnty = prev_inv-line.after-cli-qnty
            .
            if parcur-cli-qnty <> v-pl-cli-qnty and abs (v-pl-cli-qnty - parcur-cli-qnty) <= 0.001
            then do:
              for last cb_doc-pl exclusive-lock
                where cb_doc-pl.out-code = cb_doc-line.doc-code
                  and cb_doc-pl.gds-code = cb_goods.gds-code
                  and cb_doc-pl.obj-type = cb_doc-line.obj-type
                  and cb_doc-pl.obj-code = cb_doc-line.obj-code
              on error undo, return error return-value
              :
                  assign
                    cb_doc-pl.cli-rest-bf-qnty = cb_doc-pl.cli-rest-bf-qnty - (v-pl-cli-qnty - parcur-cli-qnty)
                    v-pl-cli-qnty = v-pl-cli-qnty -  (v-pl-cli-qnty - parcur-cli-qnty)
                  .
              end.
            end.
          end.
        end.
        if parcur-cli-qnty <> v-pl-cli-qnty then do:
          return error substitute( "Документ &2.&1"
                                  + "Ошибка при расчете остатка по местам хранения товара.&1"
                                  + "Товар: &3&1"
                                  + "Остаток по товару: &4 (&6)&1"
                                  + "Остаток по местам хранения: &5 (&6)&1"
                                  ,chr(10)
                                  ,cb_doc-line.doc-code
                                  ,cb_goods.gds-code
                                  ,parcur-cli-qnty
                                  ,v-pl-cli-qnty
                                  ,cb_goods.unit-cli
                                  ).
        end.
      end.
    end.
    if par-cb-ext-doc-type = 'vt':U      or
      par-cb-ext-doc-type = 'vp':U then do:
      if (par-cb-ext-doc-type = 'vt':U      and par-cb-status = 'накл':U and par-cb-flag   = yes or
          par-cb-ext-doc-type = 'vp':U and par-cb-status = 'накл':U and par-cb-flag   = no    ) then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crlinsum in g#lib-rwds ( input cb_trn-doc.doc-code ,
                       input 'bd':U ,
                       input cb_doc-line.artic ,
                       input cb_doc-line.prod-type ,
                       input cb_doc-line.prod-code ) no-error .
        if error-status :error then do:
          return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
        end.
        if parinvclcspvalue = "yes" then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_crlinsum in g#lib-rwds ( input cb_trn-doc.doc-code ,
                       input 'bcd':U ,
                       input cb_doc-line.artic ,
                       input cb_doc-line.prod-type ,
                       input cb_doc-line.prod-code ) no-error .
          if error-status :error then do:
            return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
          end.
        end.
        if parinvclcspvalue = "yes" then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cctrnsum in g#lib-rwds ( input              cb_trn-doc.doc-code ,
                       input              cb_doc-line.artic ,
                       input              cb_doc-line.prod-type ,
                       input              cb_doc-line.prod-code ,
                       input              'bd,bcd':U ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
          if error-status :error then do:
            return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
          end.
        end.
        else do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cctrnsum in g#lib-rwds ( input              cb_trn-doc.doc-code ,
                       input              cb_doc-line.artic ,
                       input              cb_doc-line.prod-type ,
                       input              cb_doc-line.prod-code ,
                       input              'bd':U ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
          if error-status :error then do:
            return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
          end.
        end.
      end.
      else do:
        if cb_trn-doc.status_ = 'разрешен':U and
          cb_trn-doc.flag_   = no      then do:
          if parvalueol = "yes" then do:
            if parinvclcspvalue = "yes" then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cctrnsum in g#lib-rwds ( input              cb_trn-doc.doc-code ,
                       input              cb_doc-line.artic ,
                       input              cb_doc-line.prod-type ,
                       input              cb_doc-line.prod-code ,
                       input              'bd,bcd,gen,genc,ad,acd':U ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
              if error-status :error then undo, return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
            end.
            else do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cctrnsum in g#lib-rwds ( input              cb_trn-doc.doc-code ,
                       input              cb_doc-line.artic ,
                       input              cb_doc-line.prod-type ,
                       input              cb_doc-line.prod-code ,
                       input              'bd,gen,ad':U ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
              if error-status :error then undo, return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
            end.
          end.
          else do:
            if parinvclcspvalue = "yes" then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cctrnsum in g#lib-rwds ( input              cb_trn-doc.doc-code ,
                       input              cb_doc-line.artic ,
                       input              cb_doc-line.prod-type ,
                       input              cb_doc-line.prod-code ,
                       input              'bd,bcd':U ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
              if error-status :error then undo, return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
            end.
            else do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cctrnsum in g#lib-rwds ( input              cb_trn-doc.doc-code ,
                       input              cb_doc-line.artic ,
                       input              cb_doc-line.prod-type ,
                       input              cb_doc-line.prod-code ,
                       input              'bd':U ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
              if error-status :error then undo, return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
            end.
          end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_acc-cost in g#lib-trn
(
 input  cb_doc-line.obj-type
,input  cb_doc-line.obj-code
,input  cb_doc-line.doc-code
,input  cb_doc-line.artic
,input  cb_doc-line.prod-type
,input  cb_doc-line.prod-code
,input  cb_doc-line.cli-qnty
,input  cb_doc-line.doc-qnty
,input  cb_doc-line.fact-qnty
,input  cb_doc-line.price-base
,input  cb_doc-line.price-rubl
,input  ''
,output v-ts-doc-line_tot-ov
,output v-ts-doc-line_fact-rubl
,output v-ts-doc-line_fact-base
,output v-ts-doc-line_fact-qnty
,output v-ts-doc-line_doc-qnty
,output v-ts-doc-line_cli-qnty
)
no-error.
          if error-status :error then do:
            return error substitute( "&1 &2", return-value, error-status :get-message( 1 ) ).
          end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clclninv in g#lib-trn
(
 input  recid(cb_doc-line)
,input  no
,input  ''
,output vartot-doc
,output vartot-rubl
)
no-error.
          if error-status :error then do:
            return error return-value.
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure recalc-rasr- :
define input parameter  par-rc-doc-line      as   recid                 no-undo.
define input parameter  par-rc-cur-qnty      like ub.doc-line.fact-qnty no-undo.
define input parameter  par-rc-inv-line      as   recid                 no-undo.
define input parameter  par-rc-cur-cli-qnty  like ub.doc-line.fact-qnty no-undo.
define output parameter par-rc-chg-inv       as   logical               no-undo.
do
on error undo, return error return-value
:
  define variable var-rc-cur-qnty     like ub.doc-line.fact-qnty no-undo.
  define variable var-rc-cur-cli-qnty like ub.doc-line.fact-qnty no-undo.
  define buffer rc_doc-line for ub.doc-line.
  define buffer rc_inv-line for ub.inv-line.
  define buffer rc_gds-dtl  for ub.gds-dtl.
  define buffer rc_prt-obj  for ub.prt-obj.
  define buffer rc_doc-pl   for ub.doc-pl.
  define buffer rc_pl-gds   for ub.pl-gds.
  define buffer rc_goods    for ub.goods.
  for each gds-list :
    delete gds-list.
  end.
  find first rc_doc-line where recid(rc_doc-line) = par-rc-doc-line.
  if par-rc-inv-line <> ? then do:
    find first rc_inv-line where recid(rc_inv-line) = par-rc-inv-line.
  end.
  find rc_goods no-lock
    where rc_goods.artic     = rc_doc-line.artic
      and rc_goods.prod-type = rc_doc-line.prod-type
      and rc_goods.prod-code = rc_doc-line.prod-code
  .
  if rc_doc-line.doc-qnty <> par-rc-cur-qnty + rc_doc-line.fact-qnty then do:
    assign par-rc-chg-inv = yes.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = rc_goods.prod-type
    and gds-list.prod-code = rc_goods.prod-code
    and gds-list.artic     = rc_goods.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last55 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last55 = gds-list.order-num .
  end.
  else do:
    v-last55 = 0 .
  end.
  create gds-list .
  buffer-copy rc_goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last55 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
    assign
      rc_doc-line.doc-qnty = par-rc-cur-qnty + rc_doc-line.fact-qnty
    .
    if available rc_inv-line then do:
      assign
        rc_inv-line.wast-cli-qnty   = rc_doc-line.cli-qnty + par-rc-cur-cli-qnty
      .
    end.
  end.
  for each rc_gds-dtl exclusive-lock
    where rc_gds-dtl.doc-code  = rc_doc-line.doc-code
      and rc_gds-dtl.artic     = rc_doc-line.artic
      and rc_gds-dtl.prod-code = rc_doc-line.prod-code
      and rc_gds-dtl.prod-type = rc_doc-line.prod-type
  on error undo, return error return-value
  :
    find rc_prt-obj no-lock
      where rc_prt-obj.obj-type   = rc_doc-line.obj-type
        and rc_prt-obj.obj-code   = rc_doc-line.obj-code
        and rc_prt-obj.artic      = rc_doc-line.artic
        and rc_prt-obj.prod-type  = rc_doc-line.prod-type
        and rc_prt-obj.prod-code  = rc_doc-line.prod-code
        and rc_prt-obj.prt-code   = rc_gds-dtl.prt-code
      no-error .
    if available rc_prt-obj then do:
      assign
        var-rc-cur-qnty = rc_prt-obj.fact-qnty
      .
    end.
    else do:
      assign
        var-rc-cur-qnty = 0
      .
    end.
    if rc_gds-dtl.fact-qnty <> var-rc-cur-qnty + rc_gds-dtl.doc-qnty then do:
      if par-rc-chg-inv <> yes then do:
        assign par-rc-chg-inv = yes.
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = rc_goods.prod-type
    and gds-list.prod-code = rc_goods.prod-code
    and gds-list.artic     = rc_goods.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last56 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last56 = gds-list.order-num .
  end.
  else do:
    v-last56 = 0 .
  end.
  create gds-list .
  buffer-copy rc_goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last56 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
      end.
      assign
        rc_gds-dtl.fact-qnty = var-rc-cur-qnty + rc_gds-dtl.doc-qnty
      .
    end.
  end.
  for each rc_doc-pl exclusive-lock
    where rc_doc-pl.out-code = rc_doc-line.doc-code
      and rc_doc-pl.gds-code = rc_goods.gds-code
  on error undo, return error return-value
  :
    find first rc_pl-gds no-lock
      where rc_pl-gds.obj-type   = rc_doc-line.obj-type
        and rc_pl-gds.obj-code   = rc_doc-line.obj-code
        and rc_pl-gds.pl-code    = rc_doc-pl.pl-code
        and rc_pl-gds.gds-code   = rc_goods.gds-code
      no-error .
    if available rc_pl-gds then do:
      assign
        var-rc-cur-qnty     = rc_pl-gds.fact-qnty
        var-rc-cur-cli-qnty = rc_pl-gds.cli-fact-qnty
      .
    end.
    else do:
      assign
        var-rc-cur-qnty     = 0.0
        var-rc-cur-cli-qnty = 0.0
      .
    end.
    if rc_doc-pl.rest-af-qnty <> var-rc-cur-qnty + rc_doc-pl.doc-qnty
      or rc_doc-pl.cli-rest-af-qnty <> var-rc-cur-cli-qnty + rc_doc-pl.cli-doc-qnty
    then do:
      if par-rc-chg-inv <> yes then do:
        assign par-rc-chg-inv = yes.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
find gds-list
  where gds-list.prod-type = rc_goods.prod-type
    and gds-list.prod-code = rc_goods.prod-code
    and gds-list.artic     = rc_goods.artic
  no-error .
if available gds-list then do:
  assign
    gds-list.to-del = no
  .
end.
else do:
  define variable v-last57 as integer no-undo .
  find last gds-list use-index oi no-error.
  if available gds-list then do:
    v-last57 = gds-list.order-num .
  end.
  else do:
    v-last57 = 0 .
  end.
  create gds-list .
  buffer-copy rc_goods to gds-list
  assign
    gds-list.to-del = no
    gds-list.order-num = v-last57 + 1
  .
  assign
    lns-cnt = lns-cnt + 1
    line-rec = recid (gds-list)
  .
end.
      end.
      assign
        rc_doc-pl.rest-bf-qnty     = var-rc-cur-qnty
        rc_doc-pl.cli-rest-bf-qnty = var-rc-cur-cli-qnty
        rc_doc-pl.rest-af-qnty     = rc_doc-pl.rest-bf-qnty + rc_doc-pl.doc-qnty
        rc_doc-pl.cli-rest-af-qnty = rc_doc-pl.cli-rest-bf-qnty + rc_doc-pl.cli-doc-qnty
      .
    end.
  end.
end.
end procedure.
procedure lib-trn2_reclcinv :
  define input parameter work-mode   as   character           no-undo.
  define input parameter parrec-line as   recid               no-undo.
  define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
  define input-output parameter vartot-docold                       like ub.trn-doc.tot-doc            no-undo.
  define input-output parameter vartot-rublold                      like ub.trn-doc.tot-rubl           no-undo.
  define input-output parameter i-total-doc-line_tot-ovold          like ub.trn-doc.tot-ov             no-undo.
  define input-output parameter i-total-doc-line_fact-rublold       like ub.trn-doc.fact-rubl          no-undo.
  define input-output parameter i-total-doc-line_fact-baseold       like ub.trn-doc.fact-base          no-undo.
  define input-output parameter i-total-doc-line_fact-qntyold       like ub.trn-doc.fact-qnty          no-undo.
  define input-output parameter i-total-doc-line_doc-qntyold        like ub.trn-doc.doc-qnty           no-undo.
  define input-output parameter i-total-doc-line_cli-qntyold        like ub.trn-doc.cli-qnty           no-undo.
  define input-output parameter i-total-parts_fact-baseold          as   decimal                       no-undo.
  define input-output parameter i-total-parts_fact-rublold          as   decimal                       no-undo.
  define input-output parameter i-total-parts_fact-qntyold          as   decimal                       no-undo.
  define variable vartot-docnew                       like ub.trn-doc.tot-doc            no-undo.
  define variable vartot-rublnew                      like ub.trn-doc.tot-rubl           no-undo.
  define variable i-total-doc-line_tot-ovnew          like ub.trn-doc.tot-ov             no-undo.
  define variable i-total-doc-line_fact-rublnew       like ub.trn-doc.fact-rubl          no-undo.
  define variable i-total-doc-line_fact-basenew       like ub.trn-doc.fact-base          no-undo.
  define variable i-total-doc-line_fact-qntynew       like ub.trn-doc.fact-qnty          no-undo.
  define variable i-total-doc-line_doc-qntynew        like ub.trn-doc.doc-qnty           no-undo.
  define variable i-total-doc-line_cli-qntynew        like ub.trn-doc.cli-qnty           no-undo.
  define variable i-total-parts_fact-basenew          as   decimal                       no-undo.
  define variable i-total-parts_fact-rublnew          as   decimal                       no-undo.
  define variable i-total-parts_fact-qntynew          as   decimal                       no-undo.
  define variable varvalueol                          as   character                     no-undo.
  define variable vartypeol                           as   character                     no-undo.
  define variable varr-b                              as   character                     no-undo.
  define buffer rc_trn-doc           for ub.trn-doc.
  define buffer rc_doc-line          for ub.doc-line.
  define buffer rc_goods             for ub.goods.
  define buffer rc-old_doc-line-sum  for ub.doc-line-sum.
  do on error undo, return error return-value :
    find first rc_doc-line where recid(rc_doc-line)  = parrec-line.
    find first rc_trn-doc  where rc_trn-doc.doc-code = pardoc-code.
    find first rc_goods    where
               rc_goods.artic      = rc_doc-line.artic     and
               rc_goods.prod-type  = rc_doc-line.prod-type and
               rc_goods.prod-code  = rc_doc-line.prod-code no-error.
    if not available rc_goods then do:
      return error substitute( "Не найден товар &1 &2 &3", rc_goods.artic, rc_goods.prod-type, rc_goods.prod-code ).
    end.
    define variable varinvclcspvalue as character no-undo.
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input rc_trn-doc.obj-type
  ,input rc_trn-doc.obj-code
  ,input 'inv-obj':U
  ,input  ""
  ,output v-value-character
  ,output v-value-date
  ,output v-value-decimal
  ,output v-value-integer
  ,output v-value-logical
  ,output par-type
  ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
  ) no-error .
    for each thbjattr_thbj-attr :
        if thbjattr_thbj-attr.prop-code = 'invclcsp'  then varinvclcspvalue = string( thbjattr_thbj-attr.property-value-logical, "yes/no").
    end.
    empty temp-table thbjattr_thbj-attr.
    if work-mode = "old":u then do:
      assign
        vartot-docold             = 0
        vartot-rublold            = 0 .
      if rc_trn-doc.ext-doc-type = 'vt':U      or
         rc_trn-doc.ext-doc-type = 'vp':U then do:
        for each tt-old-doc-line-sum where
                 tt-old-doc-line-sum.doc-code  = rc_doc-line.doc-code  and
                 tt-old-doc-line-sum.gds-code  = rc_goods.gds-code     on error undo, return error return-value :
          delete tt-old-doc-line-sum.
        end.
        for each rc-old_doc-line-sum where
                 rc-old_doc-line-sum.doc-code  = rc_doc-line.doc-code  and
                 rc-old_doc-line-sum.gds-code  = rc_goods.gds-code     on error undo, return error return-value :
          create tt-old-doc-line-sum.
          buffer-copy rc-old_doc-line-sum to tt-old-doc-line-sum.
        end.
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clclninv in g#lib-trn
(
 input  recid(rc_doc-line)
,input  no
,input  'old'
,output vartot-docold
,output vartot-rublold
)
no-error.
      assign
        i-total-doc-line_tot-ovold       = 0
        i-total-doc-line_fact-rublold    = 0
        i-total-doc-line_fact-baseold    = 0
        i-total-doc-line_fact-qntyold    = 0
        i-total-doc-line_doc-qntyold     = 0
        i-total-doc-line_cli-qntyold     = 0
        i-total-parts_fact-baseold       = 0
        i-total-parts_fact-rublold       = 0
        i-total-parts_fact-qntyold       = 0
      .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_acc-cost in g#lib-trn
(
 input  rc_doc-line.obj-type
,input  rc_doc-line.obj-code
,input  rc_doc-line.doc-code
,input  rc_doc-line.artic
,input  rc_doc-line.prod-type
,input  rc_doc-line.prod-code
,input  rc_doc-line.cli-qnty
,input  rc_doc-line.doc-qnty
,input  rc_doc-line.fact-qnty
,input  rc_doc-line.price-base
,input  rc_doc-line.price-rubl
,input  'old':u
,output i-total-doc-line_tot-ovold
,output i-total-doc-line_fact-rublold
,output i-total-doc-line_fact-baseold
,output i-total-doc-line_fact-qntyold
,output i-total-doc-line_doc-qntyold
,output i-total-doc-line_cli-qntyold
)
no-error.
      if error-status :error then do:
        message
          "Ошибка при обсчете документа инвентаризации." skip
          return-value skip
          trim( error-status :get-message( 1 ) )
        view-as alert-box error.
        undo, return error .
      end.
    end.
    if work-mode = "update":u or
       work-mode = "delete":u then do:
      assign
        vartot-docnew             = 0
        vartot-rublnew            = 0
        .
      if rc_trn-doc.status_ = 'факт':U then do:
        assign
          varvalueol = "yes".
      end.
      else do:
        if rc_trn-doc.status_ = 'разрешен':U then do:
if valid-handle( g#trdcalib ) <> yes then do:       run str/trdcalib.p persistent no-error.       if error-status :error or valid-handle( g#trdcalib ) <> yes then do:         message "Error starting trdcalib.p"    skip( 0 )                 g#trdcalib                     skip( 0 )                 g#trdcalib   :type             skip( 0 )                 g#trdcalib   :file-name        skip( 0 )                 error-status :get-message( 1 ) skip( 0 )                 return-value                   skip( 0 )         view-as alert-box error.         stop.       end.      end.     run trdcalib_tdat-val in g#trdcalib (  input rc_doc-line.doc-code ,
                        input 'clcasol':U ,
                       output varvalueol ,
                       output vartypeol ) no-error .
          if error-status :error then do:
            return error return-value.
          end.
        end.
        else do:
          assign
            varvalueol = "no".
        end.
      end.
      if work-mode = "update":u then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_clclninv in g#lib-trn
(
 input  recid(rc_doc-line)
,input  yes
,input  'new'
,output vartot-docnew
,output vartot-rublnew
)
no-error.
        if error-status :error then do:
          message
            "Ошибка при обсчете линии документа инвентаризации." skip
            return-value skip
            trim( error-status :get-message( 1 ) )
          view-as alert-box error.
          undo, return error .
        end.
      end.
      if varr-b = "rubl":u then do:
        assign
          rc_trn-doc.tot-rubl = rc_trn-doc.tot-rubl + vartot-rublnew - vartot-rublold
          rc_trn-doc.tot-doc  = rc_trn-doc.tot-rubl / rc_trn-doc.base-rate * rc_trn-doc.base-scale
        .
      end.
      else do:
        assign
          rc_trn-doc.tot-doc  = rc_trn-doc.tot-doc + vartot-docnew - vartot-docold
          rc_trn-doc.tot-rubl = rc_trn-doc.tot-doc * rc_trn-doc.base-rate / rc_trn-doc.base-scale
        .
      end.
      if varvalueol = "yes" and
         (rc_trn-doc.ext-doc-type = 'vt':U or rc_trn-doc.ext-doc-type = 'vp':U) then do:
        if work-mode = "update":u then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cllinsum in g#lib-rwds ( input rc_doc-line.doc-code ,
                       input 'gen':U ,
                       input rc_doc-line.artic ,
                       input rc_doc-line.prod-type ,
                       input rc_doc-line.prod-code ) no-error .
          if error-status :error then do:
            return error return-value.
          end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cllinsum in g#lib-rwds ( input rc_doc-line.doc-code ,
                       input 'ad':U ,
                       input rc_doc-line.artic ,
                       input rc_doc-line.prod-type ,
                       input rc_doc-line.prod-code ) no-error .
          if error-status :error then do:
            return error return-value.
          end.
          if varinvclcspvalue = "yes" then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cllinsum in g#lib-rwds ( input rc_doc-line.doc-code ,
                       input 'genc':U ,
                       input rc_doc-line.artic ,
                       input rc_doc-line.prod-type ,
                       input rc_doc-line.prod-code ) no-error .
            if error-status :error then do:
              return error return-value.
            end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cllinsum in g#lib-rwds ( input rc_doc-line.doc-code ,
                       input 'acd':U ,
                       input rc_doc-line.artic ,
                       input rc_doc-line.prod-type ,
                       input rc_doc-line.prod-code ) no-error .
            if error-status :error then do:
              return error return-value.
            end.
          end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_ttdlsdel in g#lib-rwds ( input              rc_doc-line.doc-code ,
                       input              rc_doc-line.artic ,
                       input              rc_doc-line.prod-type ,
                       input              rc_doc-line.prod-code ,
                       input-output table tt-doc-line-sum ) no-error .
          if error-status :error then do:
            undo, return error return-value.
          end.
          if varinvclcspvalue = "yes" then do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cctrnsum in g#lib-rwds ( input              rc_doc-line.doc-code ,
                       input              rc_doc-line.artic ,
                       input              rc_doc-line.prod-type ,
                       input              rc_doc-line.prod-code ,
                       input              'gen,genc,ad,acd':U ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
            if error-status :error then do:
              return error return-value.
            end.
          end.
          else do:
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_cctrnsum in g#lib-rwds ( input              rc_doc-line.doc-code ,
                       input              rc_doc-line.artic ,
                       input              rc_doc-line.prod-type ,
                       input              rc_doc-line.prod-code ,
                       input              'gen,ad':U ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-clcparts ,
                       input-output table temp-parts ) no-error .
            if error-status :error then do:
              return error return-value.
            end.
          end.
        end.
if valid-handle( g#lib-rwds ) <> yes then do:       run str/lib-rwds.p persistent no-error.       if error-status :error or valid-handle( g#lib-rwds ) <> yes then do:         message "Error starting lib-rwds.p" skip( 0 )           g#lib-rwds                        skip( 0 )           g#lib-rwds   :type                skip( 0 )           g#lib-rwds   :file-name           skip( 0 )           error-status :get-message( 1 )    skip( 0 )           return-value                      skip( 0 )         view-as alert-box error.         stop.       end.      end.     run lib-rwds_updtrsum in g#lib-rwds ( input              rc_doc-line.doc-code ,
                       input              rc_doc-line.artic ,
                       input              rc_doc-line.prod-type ,
                       input              rc_doc-line.prod-code ,
                       input              work-mode ,
                       input-output table tt-allsum-line ,
                       input-output table tt-doc-line-sum ,
                       input-output table tt-old-doc-line-sum ) no-error .
        if error-status :error then do:
          return error return-value.
        end.
      end.
      assign
        i-total-doc-line_tot-ovnew       = 0
        i-total-doc-line_fact-rublnew    = 0
        i-total-doc-line_fact-basenew    = 0
        i-total-doc-line_fact-qntynew    = 0
        i-total-doc-line_doc-qntynew     = 0
        i-total-doc-line_cli-qntynew     = 0
        i-total-parts_fact-basenew       = 0
        i-total-parts_fact-rublnew       = 0
        i-total-parts_fact-qntynew       = 0
      .
      if work-mode = "update":u then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_acc-cost in g#lib-trn
(
 input  rc_doc-line.obj-type
,input  rc_doc-line.obj-code
,input  rc_doc-line.doc-code
,input  rc_doc-line.artic
,input  rc_doc-line.prod-type
,input  rc_doc-line.prod-code
,input  rc_doc-line.cli-qnty
,input  rc_doc-line.doc-qnty
,input  rc_doc-line.fact-qnty
,input  rc_doc-line.price-base
,input  rc_doc-line.price-rubl
,input  'new'
,output i-total-doc-line_tot-ovnew
,output i-total-doc-line_fact-rublnew
,output i-total-doc-line_fact-basenew
,output i-total-doc-line_fact-qntynew
,output i-total-doc-line_doc-qntynew
,output i-total-doc-line_cli-qntynew
)
no-error.
        if error-status :error then do:
          message
            "Ошибка при расчете шапки документа инвентаризации." skip
            return-value skip
            trim( error-status :get-message( 1 ) )
          view-as alert-box error.
          undo, return error .
        end.
      end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_ass-cost in g#lib-trn
(
 input recid(rc_trn-doc)
,input i-total-doc-line_tot-ovnew
,input i-total-doc-line_fact-rublnew
,input i-total-doc-line_fact-basenew
,input i-total-doc-line_fact-qntynew
,input i-total-doc-line_doc-qntynew
,input i-total-doc-line_cli-qntynew
,input i-total-doc-line_tot-ovold
,input i-total-doc-line_fact-rublold
,input i-total-doc-line_fact-baseold
,input i-total-doc-line_fact-qntyold
,input i-total-doc-line_doc-qntyold
,input i-total-doc-line_cli-qntyold
)
no-error.
      if error-status :error then do:
        message
          "Ошибка при редактировании шапки документа инвентаризации." skip
          return-value skip
          trim( error-status :get-message( 1 ) )
        view-as alert-box error.
        undo, return error .
      end.
    end.
  end.
end procedure.
procedure lib-trn2_chkprdtl :
define input parameter pardoc-code like ub.trn-doc.doc-code no-undo.
define buffer bf_trn-doc for ub.trn-doc.
define buffer bf_gds-dtl for ub.gds-dtl.
define buffer bf_goods   for ub.goods  .
define variable varmax-disc-str              as   character                   no-undo.
define variable varmax-disc                  as   decimal                     no-undo.
define variable vartype                      as   character                   no-undo.
define variable varr-b                       as   character                   no-undo.
define variable v-is-mdificator-null-price   as   character                   no-undo.
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable gp-doc-num    like ub.price-list.doc-num    no-undo.
define variable gp-price-sale like ub.price-list.price-sale no-undo.
define variable gp-road-tax   like ub.price-list.road-tax   no-undo.
define variable gp-excise     like ub.price-list.excise     no-undo.
define variable gp-b-code     like ub.bar-code.b-code       no-undo.
define variable gp-fact-order as decimal   no-undo .
define variable gp-price-sale-parts as decimal   no-undo .
do on error undo, return error return-value :
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varr-b
  )  .
find first bf_trn-doc where bf_trn-doc.doc-code = pardoc-code no-lock.
for each bf_gds-dtl where bf_gds-dtl.doc-code  = pardoc-code on error undo, return error return-value :
  find first bf_goods where bf_goods.artic     = bf_gds-dtl.artic     and
                            bf_goods.prod-type = bf_gds-dtl.prod-type and
                            bf_goods.prod-code = bf_gds-dtl.prod-code no-lock.
  if bf_trn-doc.ext-doc-type = 'ee':U then do:
    define variable v-limit as decimal no-undo .
    define buffer buf_dis-gds-rule for ub.dis-gds-rule.
    define buffer buf_dis-rule for ub.dis-rule.
    _buf_dis-gds-rule:
    for each buf_dis-gds-rule no-lock where
              buf_dis-gds-rule.gds-code = bf_goods.gds-code
         and  buf_dis-gds-rule.obj-type = bf_gds-dtl.obj-type
         and  buf_dis-gds-rule.obj-code = bf_gds-dtl.obj-code
         and  buf_dis-gds-rule.pos-type = '-':U
         and  buf_dis-gds-rule.discnt-role = 'max-disc':U,
        first buf_dis-rule no-lock where
              buf_dis-rule.rule-num = buf_dis-gds-rule.rule-num
          and buf_dis-rule.sts = integer('0':U):
      leave _buf_dis-gds-rule.
    end.
    if available buf_dis-gds-rule then do:
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
gp-fact-order = 0 .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bf_goods.gds-code
  ,input  bf_gds-dtl.prt-code
  ,output gp-b-code
  ) no-error .
if error-status:error then do:
  message
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  return error.
end.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  bf_gds-dtl.obj-type
  ,input  bf_gds-dtl.obj-code
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
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_avprpart in g#lib-trn3
  (input  bf_gds-dtl.obj-type
  ,input  bf_gds-dtl.obj-code
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
        if buf_Dis-rule.value-type = integer('1':U) then do:
          v-limit = gp-price-sale * ( 1 - buf_Dis-rule.discnt-value * 0.01 ).
          varmax-disc-str = substitute("&1%", buf_Dis-rule.discnt-value).
        end.
        if buf_Dis-rule.value-type = integer('2':U) then do:
          v-limit = gp-price-sale - varmax-disc.
          varmax-disc-str = substitute("&1 (&2)"
                                      , buf_Dis-rule.discnt-value
                                      , if varr-b = "rubl":u
                                        then "нац.вал."
                                        else "баз.вал."
                                      ).
        end.
        if varr-b = "rubl":u then do:
          if bf_gds-dtl.price-rubl - bf_gds-dtl.discnt-rubl < v-limit then do:
            return error substitute( "Текущая цена по товару &1 &2 &3 &4 равна &5. Максимальная скидка при продаже через расходную накладную &6. Цена в документе &7, равная &8, меньше минимальной цены с максимальной скидкой, равной &9. (gds-dtl)",
                                     bf_goods.artic,
                                     bf_goods.prod-type,
                                     bf_goods.prod-code,
                                     bf_goods.gds-name,
                                     gp-price-sale,
                                     varmax-disc-str,
                                     bf_gds-dtl.doc-code,
                                     bf_gds-dtl.price-rubl,
                                     v-limit
                                    ).
          end.
        end.
        else do:
          if bf_gds-dtl.price-base - bf_gds-dtl.discnt-base < v-limit then do:
            return error substitute( "Текущая цена по товару &1 &2 &3 &4 равна &5. Максимальная скидка при продаже через расходную накладную &6. Цена в документе &7, равная &8, меньше минимальной цены с максимальной скидкой, равной &9. (gds-dtl)",
                                     bf_goods.artic,
                                     bf_goods.prod-type,
                                     bf_goods.prod-code,
                                     bf_goods.gds-name,
                                     gp-price-sale,
                                     varmax-disc-str,
                                     bf_gds-dtl.doc-code,
                                     bf_gds-dtl.price-base,
                                     v-limit
                                    ).
          end.
        end.
      end.
    end.
  end.
end.
end.
end procedure.
