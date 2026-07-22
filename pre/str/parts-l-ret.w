using ibs.th.str.mercury.*.
using ibs.th.gbl.storage.*.
using ibs.th.gbl.*.
using ibs.th.str.marking.sts.*.
define input  parameter parparentproc  as widget-handle no-undo.
define input  parameter v-obj-type   as character no-undo .
define input  parameter v-obj-code   as integer   no-undo .
define input  parameter p-gds-code   as integer   no-undo .
define input  parameter p-doc-code   as character no-undo .
define input  parameter p-edit-mode  as character no-undo .
define input  parameter p-r-parts    as character no-undo .
define input  parameter p-one-all    as character no-undo .
define input  parameter p-call-point as character no-undo .
define output parameter part-recid   as recid     no-undo .
define variable v-prt-rec as recid no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Просмотр/Редактирование партий".
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
    assign
      p-vss-parameters = substitute('&1|&2|&3|&4|&5|&6|&7|&8':u,v-obj-type,v-obj-code,p-gds-code,p-doc-code,p-edit-mode,p-r-parts,p-one-all,p-call-point)
    .
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
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable c-point  as character no-undo .
define variable tbl      as character no-undo .
define variable join-tbl as character no-undo .
define variable fld      as character no-undo .
define variable lab      as character no-undo .
define variable spr      as character no-undo .
define variable dim      as character no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure fltfield-clear :
  define output parameter loc-fld as character no-undo.
  define output parameter loc-lab as character no-undo .
  define output parameter loc-spr as character no-undo .
  define output parameter loc-dim as character no-undo .
  assign
    loc-fld = ""
    loc-lab = ""
    loc-spr = ""
    loc-dim = "0"
  .
end procedure .
procedure fltfield-add :
  define input        parameter par-fld as character no-undo.
  define input        parameter par-lab as character no-undo .
  define input        parameter par-spr as character no-undo .
  define input-output parameter loc-fld as character no-undo.
  define input-output parameter loc-lab as character no-undo .
  define input-output parameter loc-spr as character no-undo .
  define input-output parameter loc-dim as character no-undo .
  do
  on error undo, return error
  :
    assign
    loc-fld = if loc-dim = '0'
              then par-fld
              else (loc-fld + chr(44) + par-fld)
    loc-lab = if loc-dim = '0'
              then par-lab
              else (loc-lab + chr(44) + par-lab)
    loc-spr = if loc-dim = '0'
              then par-spr
              else (loc-spr + chr(44) + par-spr)
    loc-dim = (if num-entries(loc-dim) > 1 then (entry(1, loc-dim) + chr(44)) else "") +
              string(integer(if num-entries(loc-dim) > 1
                            then entry(2, loc-dim)
                            else entry(1, loc-dim)
                            ) + 1)
    no-error
    .
  end.
end procedure.
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    if not valid-handle( parparentproc )
    then do:
      return error "Не выбрано место хранения " + chr(10) .
    end.
    run str/plgdssel.p
      (
         input parparentproc
      ,  input p-obj-type
      ,  input p-obj-code
      ,  input p-gds-code
      , output p-pl-code
      ) no-error .
    if error-status :error
    then do:
      return error substitute( 'Ошибка при вызове программы &1&2&3&2&4&2'
                             , 'plgdssel.p':U
                             , chr(10)
                             , error-status :get-message( 1 )
                             , return-value
                             ) .
    end.
    if p-pl-code = ? or
       p-pl-code = 0
    then do:
      return error "Не выбрано место хранения " + chr(10) .
    end.
  end.
end procedure.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR BLACK_COLOR        AS INTEGER NO-UNDO INIT  0.
DEF VAR DARK_BLUE_COLOR    AS INTEGER NO-UNDO INIT  1.
DEF VAR DARK_GREEN_COLOR   AS INTEGER NO-UNDO INIT  2.
DEF VAR CYAN_COLOR         AS INTEGER NO-UNDO INIT  3.
DEF VAR BROWN_COLOR        AS INTEGER NO-UNDO INIT  4.
DEF VAR DARK_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR DARK_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GRAY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR VERY_GREY_COLOR    AS INTEGER NO-UNDO INIT  7.
DEF VAR GRAY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR GREY_COLOR         AS INTEGER NO-UNDO INIT  8.
DEF VAR BLUE_COLOR         AS INTEGER NO-UNDO INIT  9.
DEF VAR GREEN_COLOR        AS INTEGER NO-UNDO INIT 10.
DEF VAR RED_COLOR          AS INTEGER NO-UNDO INIT 12.
DEF VAR LIGHT_RED_COLOR    AS INTEGER NO-UNDO INIT 13.
DEF VAR YELLOW_COLOR       AS INTEGER NO-UNDO INIT 14.
DEF VAR WHITE_COLOR        AS INTEGER NO-UNDO INIT 15.
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure rsrgdsck :
  define input  parameter p-doc-code               like ub.doc-line.doc-code  no-undo .
  define input  parameter p-doc-type               like ub.trn-doc.doc-type   no-undo .
  define input  parameter p-obj-type               like ub.doc-line.obj-type  no-undo .
  define input  parameter p-obj-code               like ub.doc-line.obj-code  no-undo .
  define input  parameter p-artic                  like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type              like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code              like ub.doc-line.prod-code no-undo .
  define output parameter p-free-parts-qnty        like ub.parts.qnty         no-undo .
  define output parameter p-free-parts-fact-qnty   like ub.parts.fact-qnty    no-undo .
  define output parameter p-free-parts-cli-qnty    like ub.parts.cli-qnty     no-undo .
  define output parameter p-free-parts-price-base  as decimal                 no-undo .
  define output parameter p-free-parts-price-rubl  as decimal                 no-undo .
  define output parameter p-out-parts-qnty         like ub.parts.qnty         no-undo .
  define output parameter p-out-parts-fact-qnty    like ub.parts.fact-qnty    no-undo .
  define output parameter p-out-parts-cli-qnty     like ub.parts.cli-qnty     no-undo .
  define output parameter p-out-parts-price-base   as decimal                 no-undo .
  define output parameter p-out-parts-price-rubl   as decimal                 no-undo .
  define buffer buf_parts    for ub.parts.
  assign
    p-free-parts-qnty       = 0
    p-free-parts-fact-qnty  = 0
    p-free-parts-cli-qnty   = 0
    p-free-parts-price-base = 0
    p-free-parts-price-rubl = 0
    p-out-parts-qnty        = 0
    p-out-parts-fact-qnty   = 0
    p-out-parts-cli-qnty    = 0
    p-out-parts-price-base  = 0
    p-out-parts-price-rubl  = 0
  .
  for each buf_parts no-lock
    where buf_parts.out-code  = p-doc-code
      and buf_parts.obj-type  = p-obj-type
      and buf_parts.obj-code  = p-obj-code
      and buf_parts.artic     = p-artic
      and buf_parts.prod-type = p-prod-type
      and buf_parts.prod-code = p-prod-code
  on error undo, return error
  :
    if can-do('при,рас,спи':U, p-doc-type)
    or (p-doc-type = 'инв':U
        and buf_parts.fact-qnty < 0)
    then do:
      assign
        p-free-parts-qnty       = p-free-parts-qnty
                                + abs(buf_parts.qnty)
        p-free-parts-fact-qnty  = p-free-parts-fact-qnty
                                + abs(buf_parts.fact-qnty)
        p-free-parts-cli-qnty   = p-free-parts-cli-qnty
                                + abs(buf_parts.cli-qnty)
        p-free-parts-price-base = p-free-parts-price-base
                                + abs(buf_parts.fact-qnty) * buf_parts.price-base
        p-free-parts-price-rubl = p-free-parts-price-rubl
                                + abs(buf_parts.fact-qnty) * buf_parts.price-rubl
      .
    end.
    else do:
      assign
        p-out-parts-qnty        = p-out-parts-qnty
                                + buf_parts.qnty
        p-out-parts-fact-qnty   = p-out-parts-fact-qnty
                                + buf_parts.fact-qnty
        p-out-parts-cli-qnty    = p-out-parts-cli-qnty
                                + buf_parts.cli-qnty
        p-out-parts-price-base  = p-out-parts-price-base
                                + buf_parts.fact-qnty * buf_parts.price-base
        p-out-parts-price-rubl  = p-out-parts-price-rubl
                                + buf_parts.fact-qnty * buf_parts.price-rubl
      .
    end.
  end.
end procedure.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-trndocrs-gds-dtl-rsrv no-undo
  field prt-code         like ub.gds-dtl.prt-code
  field rsrv-qnty        like ub.gds-dtl.fact-qnty
  field rsrv-out-qnty    like ub.gds-dtl.fact-qnty
  index xpk is primary unique prt-code
.
define temp-table temp-trndocrs-pl-gds-rsrv no-undo
  field pl-code          like ub.pl-gds.pl-code
  field rsrv-qnty        like ub.pl-gds.free-qnty
  field cli-rsrv-qnty    like ub.pl-gds.cli-free-qnty
  field rsrv-out-qnty    like ub.pl-gds.fact-qnty
  field before-free-qnty like ub.pl-gds.fact-qnty
  field before-out-qnty  like ub.pl-gds.fact-qnty
  field after-free-qnty  like ub.pl-gds.fact-qnty
  field after-out-qnty   like ub.pl-gds.fact-qnty
  field fact-qnty        like ub.pl-gds.fact-qnty
  field cli-qnty         like ub.pl-gds.cli-qnty
  field cli-fact-qnty    like ub.pl-gds.cli-fact-qnty
  index xpk is primary unique pl-code
.
procedure trndocrs-gds-dtl-clear :
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-gds-dtl-rsrv .
    end.
  end.
end procedure.
procedure trndocrs-pl-gds-clear :
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-pl-gds-rsrv .
    end.
  end.
end procedure.
procedure trndocrs-clear :
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-gds-dtl-rsrv .
    end.
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      delete buf_temp-trndocrs-pl-gds-rsrv .
    end.
  end.
end procedure.
procedure trndocrs-pl-gds-accum :
  define input parameter p-pl-code       like ub.pl-gds.pl-code       no-undo .
  define input parameter p-rsrv-qnty     like ub.pl-gds.free-qnty     no-undo .
  define input parameter p-cli-rsrv-qnty like ub.pl-gds.cli-free-qnty no-undo .
  define input parameter p-fact-qnty     like ub.pl-gds.fact-qnty     no-undo .
  define input parameter p-cli-fact-qnty like ub.pl-gds.cli-fact-qnty no-undo .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    find first buf_temp-trndocrs-pl-gds-rsrv
      where buf_temp-trndocrs-pl-gds-rsrv.pl-code = p-pl-code
      no-error .
    if not available buf_temp-trndocrs-pl-gds-rsrv then do:
      create buf_temp-trndocrs-pl-gds-rsrv .
      assign
        buf_temp-trndocrs-pl-gds-rsrv.pl-code = p-pl-code
      .
    end.
    assign
      buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty     = buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty     + p-rsrv-qnty
      buf_temp-trndocrs-pl-gds-rsrv.cli-rsrv-qnty = buf_temp-trndocrs-pl-gds-rsrv.cli-rsrv-qnty + p-cli-rsrv-qnty
      buf_temp-trndocrs-pl-gds-rsrv.fact-qnty     = buf_temp-trndocrs-pl-gds-rsrv.fact-qnty     + p-fact-qnty
      buf_temp-trndocrs-pl-gds-rsrv.cli-fact-qnty = buf_temp-trndocrs-pl-gds-rsrv.cli-fact-qnty + p-cli-fact-qnty
    .
  end.
end procedure.
procedure trndocrs-gds-dtl-accum :
  define input parameter p-prt-code   like ub.gds-dtl.prt-code   no-undo .
  define input parameter p-rsrv-qnty like ub.gds-dtl.fact-qnty no-undo .
  define buffer buf_temp-trndocrs-gds-dtl-rsrv  for temp-trndocrs-gds-dtl-rsrv .
  do
  on error undo, return error return-value
  :
    find first buf_temp-trndocrs-gds-dtl-rsrv
      where buf_temp-trndocrs-gds-dtl-rsrv.prt-code = p-prt-code
      no-error .
    if not available buf_temp-trndocrs-gds-dtl-rsrv then do:
      create buf_temp-trndocrs-gds-dtl-rsrv .
      assign
        buf_temp-trndocrs-gds-dtl-rsrv.prt-code = p-prt-code
      .
    end.
    assign
      buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty = buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty
                                             + p-rsrv-qnty
    .
  end.
end procedure.
procedure trndocrs-pl-gds-request :
  define input parameter p-doc-code               like ub.doc-line.doc-code  no-undo .
  define input parameter p-doc-type               like ub.trn-doc.doc-type   no-undo .
  define input parameter p-obj-type               like ub.doc-line.obj-type  no-undo .
  define input parameter p-obj-code               like ub.doc-line.obj-code  no-undo .
  define input parameter p-artic                  like ub.doc-line.artic     no-undo .
  define input parameter p-prod-type              like ub.doc-line.prod-type no-undo .
  define input parameter p-prod-code              like ub.doc-line.prod-code no-undo .
  define input parameter p-field-accum            as character no-undo .
  define variable vss-description as character no-undo init "trndocrs-pl-gds-request: Сбор информации о партиях на складских местах".
  define buffer buf_temp-trndocrs-pl-gds-rsrv for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    if lookup(p-field-accum, "before,after":u ) = 0 then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка задания входных параметров параметров" skip
        "Неизвестное значение параметра" skip
        "p-field-accum" p-field-accum skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    case p-field-accum :
      when "before":u then do:
        for each buf_temp-trndocrs-pl-gds-rsrv
        on error undo, return error return-value
        :
          assign
            buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty = 0
            buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty  = 0
          .
        end.
      end.
      when "after":u then do:
        for each buf_temp-trndocrs-pl-gds-rsrv
        on error undo, return error return-value
        :
          assign
            buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty  = 0
            buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty   = 0
          .
        end.
      end.
      otherwise do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info5 skip
          "Ошибка задания входных параметров параметров" skip
          "Неизвестное значение параметра" skip
          "p-field-accum" p-field-accum skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    define buffer buf_parts for ub.parts.
    for each buf_parts no-lock
      where buf_parts.out-code  = p-doc-code
        and buf_parts.obj-type  = p-obj-type
        and buf_parts.obj-code  = p-obj-code
        and buf_parts.artic     = p-artic
        and buf_parts.prod-type = p-prod-type
        and buf_parts.prod-code = p-prod-code
    on error undo, return error return-value
    :
      find first buf_temp-trndocrs-pl-gds-rsrv
        where buf_temp-trndocrs-pl-gds-rsrv.pl-code = buf_parts.pl-code
        no-error .
      if not available buf_temp-trndocrs-pl-gds-rsrv then do:
        create buf_temp-trndocrs-pl-gds-rsrv .
        assign
          buf_temp-trndocrs-pl-gds-rsrv.pl-code = buf_parts.pl-code
        .
      end.
      if can-do('при,рас,спи':U, p-doc-type)
      or (p-doc-type = 'инв':U
          and buf_parts.fact-qnty < 0)
      then do:
        case p-field-accum :
          when "before":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          when "after":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info5 skip
              "Ошибка задания входных параметров параметров" skip
              "Неизвестное значение параметра" skip
              "p-field-accum" p-field-accum skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
      else do:
        case p-field-accum :
          when "before":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          when "after":u then do:
            assign
              buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty
                = buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty
                + abs(buf_parts.fact-qnty)
            .
          end.
          otherwise do:
            message
              vss-workfile vss-revision vss-description skip
              vss-include-info5 skip
              "Ошибка задания входных параметров параметров" skip
              "Неизвестное значение параметра" skip
              "p-field-accum" p-field-accum skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
      end.
    end.
  end.
end procedure.
procedure trndocrs-pl-gds-calc-rsrv :
  define variable vss-description as character no-undo init "trndocrs-pl-gds-calc-rsrv: Сбор информации о партиях на складских местах".
  define buffer buf_temp-trndocrs-pl-gds-rsrv for temp-trndocrs-pl-gds-rsrv .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      assign
        buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty
          = buf_temp-trndocrs-pl-gds-rsrv.after-free-qnty
          - buf_temp-trndocrs-pl-gds-rsrv.before-free-qnty
        buf_temp-trndocrs-pl-gds-rsrv.rsrv-out-qnty
          = buf_temp-trndocrs-pl-gds-rsrv.after-out-qnty
          - buf_temp-trndocrs-pl-gds-rsrv.before-out-qnty
      .
    end.
  end.
end procedure.
procedure trndocrs-need-rsrv :
  define input  parameter p-doc-type     like ub.trn-doc.doc-type no-undo .
  define input  parameter p-artic        like ub.doc-line.artic     no-undo .
  define input  parameter p-prod-type    like ub.doc-line.prod-type no-undo .
  define input  parameter p-prod-code    like ub.doc-line.prod-code no-undo .
  define output parameter p-need-rsrv    as logical   no-undo .
  define buffer buf_goods   for ub.goods .
  do
  on error undo, return error return-value
  :
    find first buf_goods no-lock
      where buf_goods.artic     = p-artic
        and buf_goods.prod-type = p-prod-type
        and buf_goods.prod-code = p-prod-code
      .
    if buf_goods.gds-type = 'т':U
    and ( p-doc-type = 'рас':U
          or p-doc-type = 'спи':U
        )
    then do:
      assign
        p-need-rsrv = true
      .
    end.
    else do:
      assign
        p-need-rsrv = false
      .
    end.
  end.
end procedure.
procedure trndocrs-need-create-doc-pl :
  define input  parameter p-extended-doc-type  as character no-undo .
  define input  parameter p-news               as logical   no-undo .
  define input  parameter p-sale-auto          as logical   no-undo .
  define output parameter p-need-create-doc-pl as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if  not p-news
    and p-extended-doc-type <> 'ie':U
    and p-extended-doc-type <> 'es':U
    and p-extended-doc-type <> 'rs':U
    and not p-sale-auto
    then do:
      assign
        p-need-create-doc-pl = true
      .
    end.
    else do:
      assign
        p-need-create-doc-pl = false
      .
    end.
  end.
end procedure.
procedure trndocrs-validate :
  define input parameter p-place-rsrv as logical no-undo .
  define input parameter p-chg-qnty   as decimal no-undo .
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  define variable v-total-gds-dtl-rsrv-qnty as decimal no-undo .
  define variable v-total-pl-gds-rsrv-qnty as decimal no-undo .
  assign
    v-total-gds-dtl-rsrv-qnty = 0
    v-total-pl-gds-rsrv-qnty  = 0
  .
  do
  on error undo, return error return-value
  :
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
      assign
        v-total-gds-dtl-rsrv-qnty = v-total-gds-dtl-rsrv-qnty
                                  + buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty
      .
    end.
    for each buf_temp-trndocrs-pl-gds-rsrv
    on error undo, return error return-value
    :
      assign
        v-total-pl-gds-rsrv-qnty = v-total-pl-gds-rsrv-qnty
                                 + buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty
      .
    end.
    if round(v-total-gds-dtl-rsrv-qnty, 0) <> round(p-chg-qnty, 0) then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при резервировании свободных количеств" skip
        "Запрошено резервирование:" skip
        "По товару" p-chg-qnty skip
        "По признакам" v-total-gds-dtl-rsrv-qnty skip
        "По складским местам" v-total-pl-gds-rsrv-qnty skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-place-rsrv then do:
      if round(v-total-pl-gds-rsrv-qnty, 0) <> round(p-chg-qnty, 0) then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info5 skip
          "Ошибка при резервировании свободных количеств" skip
          "Запрошено резервирование:" skip
          "По товару" p-chg-qnty skip
          "По признакам" v-total-gds-dtl-rsrv-qnty skip
          "По складским местам" v-total-pl-gds-rsrv-qnty skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
  end.
end procedure.
procedure trndocrs :
  define input parameter p-doc-code   like ub.doc-line.doc-code  no-undo .
  define input parameter p-obj-type   like ub.doc-line.obj-type  no-undo .
  define input parameter p-obj-code   like ub.doc-line.obj-code  no-undo .
  define input parameter p-artic      like ub.doc-line.artic     no-undo .
  define input parameter p-prod-type  like ub.doc-line.prod-type no-undo .
  define input parameter p-prod-code  like ub.doc-line.prod-code no-undo .
  define input parameter p-chg-qnty   as decimal no-undo .
  define buffer buf_db         for ub.db .
  define buffer buf_gds-obj    for ub.gds-obj .
  define buffer buf_prt-obj    for ub.prt-obj .
  define buffer buf_gds-prt    for ub.gds-prt .
  define buffer buf_goods      for ub.goods .
  define buffer buf_pl-gds     for ub.pl-gds .
  define buffer buf_temp-trndocrs-pl-gds-rsrv  for temp-trndocrs-pl-gds-rsrv .
  define buffer buf_temp-trndocrs-gds-dtl-rsrv for temp-trndocrs-gds-dtl-rsrv .
  define variable v-node-code   like ub.gds-prt.node-code no-undo .
  define variable v-curr-db-num like ub.db.db-num         no-undo .
  define variable v-cmd         as   character            no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,buffer buf_gds-obj
  ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Ошибка при поиске товара на объекте" skip
        "p-obj-type"  p-obj-type  skip
        "p-obj-code"  p-obj-code  skip
        "p-artic"     p-artic     skip
        "p-prod-type" p-prod-type skip
        "p-prod-code" p-prod-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    find current buf_gds-obj exclusive-lock .
    run trndocrs-validate in this-procedure
      (input buf_gds-obj.place-rsrv
      ,input p-chg-qnty
      ) no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        vss-include-info5 skip
        "Противоречивые данные для резервирования" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    assign
      buf_gds-obj.free-qnty   = buf_gds-obj.free-qnty - p-chg-qnty
      buf_gds-obj.on-line-rest = buf_gds-obj.free-qnty
    .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rum-runa in g#library
  (input ?
  ,input this-procedure:handle
  ,input ?
  ,input  'rest-update':U
  ,input ?
  ,input  buffer buf_gds-obj:handle
  ,input 'fact-qnty,free-qnty'
  ,input ''
  ) no-error .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-curr-db-num
  )  .
    find first buf_db no-lock
      where buf_db.db-num = v-curr-db-num
      .
    if buf_db.db-num <> 0
      and buf_db.on-line-rest = true
    then do:
      assign
        v-cmd = "command":U + chr(1)
                + "create":U + chr(1)
                + "on-line-rest":U + chr(1)
                + substitute( "&1", buf_gds-obj.obj-type ) + chr(1)
                + substitute( "&1", buf_gds-obj.obj-code ) + chr(1)
                + substitute( "&1", buf_gds-obj.artic ) + chr(1)
                + substitute( "&1", buf_gds-obj.prod-type ) + chr(1)
                + substitute( "&1", buf_gds-obj.prod-code ) + chr(1)
                + substitute( "&1", buf_gds-obj.free-qnty ) + chr(1)
      .
      run nws/cr-route.p
        ( input 'send-cmd':U
          ,input v-cmd
          ,input ?
          ,input "0":U
        ).
    end.
    if buf_gds-obj.place-rsrv = true then do:
      for each buf_temp-trndocrs-pl-gds-rsrv
      on error undo, return error return-value
      :
        find first buf_goods no-lock
          where buf_goods.artic     = p-artic
            and buf_goods.prod-type = p-prod-type
            and buf_goods.prod-code = p-prod-code
          no-error .
        if not available buf_goods then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info5 skip
            "Не найдена товар" skip
            "Артикул" p-artic p-prod-type p-prod-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        find first buf_pl-gds exclusive-lock
          where buf_pl-gds.obj-type = p-obj-type
            and buf_pl-gds.obj-code = p-obj-code
            and buf_pl-gds.gds-code = buf_goods.gds-code
            and buf_pl-gds.pl-code  = buf_temp-trndocrs-pl-gds-rsrv.pl-code
          no-error .
        if not available buf_pl-gds then do:
          message
            vss-workfile vss-revision vss-description skip
            vss-include-info5 skip
            "Не найдена привязка товара к складскому месту" skip
            "Код товара" buf_temp-trndocrs-pl-gds-rsrv.pl-code skip
            view-as alert-box error .
          undo, return error return-value .
        end.
        assign
          buf_pl-gds.free-qnty     = buf_pl-gds.free-qnty     - buf_temp-trndocrs-pl-gds-rsrv.rsrv-qnty
          buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-free-qnty - buf_temp-trndocrs-pl-gds-rsrv.cli-rsrv-qnty
        .
        if buf_pl-gds.free-qnty = buf_pl-gds.fact-qnty
          and absolute( buf_pl-gds.cli-free-qnty - buf_pl-gds.cli-fact-qnty ) <= 0.01
        then do:
          assign
            buf_pl-gds.cli-free-qnty = buf_pl-gds.cli-fact-qnty
          .
        end.
      end.
    end.
    for each buf_temp-trndocrs-gds-dtl-rsrv
    on error undo, return error return-value
    :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run termnode in g#library
  (input  buf_temp-trndocrs-gds-dtl-rsrv.prt-code
  ,output v-node-code
  ) no-error .
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          vss-include-info5 skip
          "Ошибка при определении первого терминального признака" skip
          "prt-code" buf_temp-trndocrs-gds-dtl-rsrv.prt-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
      find first buf_gds-prt no-lock
        where buf_gds-prt.node-code = v-node-code
        .
      do while available buf_gds-prt
      on error undo, return error return-value
      :
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prtobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,input  buf_gds-prt.node-code
  ,buffer buf_prt-obj
  )  .
        find current buf_prt-obj exclusive-lock .
        assign
          buf_prt-obj.free-qnty = buf_prt-obj.free-qnty - buf_temp-trndocrs-gds-dtl-rsrv.rsrv-qnty
        .
        assign
          v-node-code = buf_gds-prt.upper-code
        .
        find first buf_gds-prt no-lock
          where buf_gds-prt.node-code = v-node-code
          no-error .
      end.
    end.
  end.
end procedure.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION get-parts-part-code RETURNS CHARACTER
  ( BUFFER buf_parts FOR ub.parts
  , INPUT p-goods-alcohol-prod AS LOGICAL
  ) :
  define variable v-show-part-code as character no-undo .
  if (p-goods-alcohol-prod = false) and (buf_parts.part-code = '':u)
  then do:
    return '------':u .
  end.
  run partsfnc_get-parts-show-code in this-procedure
    (input  buf_parts.part-code
    ,input  buf_parts.mark-db-num
    ,input  buf_parts.mark-code
    ,input  buf_parts.alc-bottling-date
    ,input  p-goods-alcohol-prod
    ,output v-show-part-code
    ) .
  return v-show-part-code .
END FUNCTION.
procedure partsfnc_get-parts-show-code :
  define input  parameter p-part-code          as character no-undo .
  define input  parameter p-mark-db-num        as integer   no-undo .
  define input  parameter p-mark-code          as integer   no-undo .
  define input  parameter p-alc-bottling-date  as date      no-undo .
  define input  parameter p-goods-alcohol-prod as logical   no-undo .
  define output parameter p-show-code          as character no-undo .
  define variable v-alc-mark-name as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-show-code = '':u
    .
    if p-goods-alcohol-prod = true
    then do:
      run alc-lib_mark-name in this-procedure
        (input  p-mark-db-num
        ,input  p-mark-code
        ,output v-alc-mark-name
        ) .
      assign
        p-show-code = substitute('&1,&2':u
                                ,v-alc-mark-name
                                ,string(p-alc-bottling-date,'99/99/9999':u)
                                )
      .
    end.
    else do:
      assign
        p-show-code = p-part-code
      .
    end.
    return '':u .
  end.
end procedure.
FUNCTION get-parts-out-code RETURNS CHARACTER
  ( BUFFER buf_parts FOR ub.parts ) :
  case buf_parts.out-code :
    when 'free-zone':U then do:
      return "свободно" .
    end.
    when 'out-zone':U then do:
      return "расход" .
    end.
    otherwise do:
      if buf_parts.doc-type = 'акт':U then do:
        return caps("ЦН") + " № " + buf_parts.out-code .
      end.
      else do:
        define variable v-ext-name       as character no-undo .
        define variable v-trn-doc-status as character no-undo .
        define buffer buf_trn-doc for ub.trn-doc .
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_parts.out-code
          no-error .
        if available buf_trn-doc then do:
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run docextnm in g#library
  (input  buf_parts.out-code
  ,output v-ext-name
  )  .
          assign
            v-trn-doc-status = (if buf_trn-doc.status_ = 'факт':U then 'факт':U else "")
          .
        end.
        else do:
          assign
            v-ext-name       = caps(substring(buf_parts.doc-type, 1, 1))
            v-trn-doc-status = (if buf_parts.status_ = ? then 'факт':U else "")
          .
        end.
        return substitute("&1 № &2 &3"
           ,v-ext-name
           ,buf_parts.out-code
           ,v-trn-doc-status
           ) .
      end.
    end.
  end case .
  return "".
END FUNCTION.
FUNCTION get-parts-cli-qnty RETURNS DECIMAL
  ( BUFFER buf_parts FOR ub.parts
  , INPUT p-goods-twounit AS LOGICAL
  ) :
  if p-goods-twounit then do:
    RETURN buf_parts.cli-qnty .
  end.
  else do:
    RETURN buf_parts.fact-qnty / buf_parts.cli-base-rate .
  end.
  RETURN ? .
END FUNCTION.
FUNCTION get-parts-cli-base-rate RETURNS DECIMAL
  ( BUFFER buf_parts FOR ub.parts
  , INPUT p-goods-twounit AS LOGICAL
  ) :
  if p-goods-twounit then do:
    RETURN buf_parts.fact-qnty / buf_parts.cli-qnty .
  end.
  else do:
    RETURN buf_parts.cli-base-rate .
  end.
  RETURN ? .
END FUNCTION.
def var vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure tax-name:
define input  parameter pardef-tax  as character           no-undo.
define output parameter parname-tax as character initial ? no-undo.
define buffer bf_tax for ub.tax.
do on error undo, return error :
   case pardef-tax:
      when 'vat':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('1':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '1':U(не задействован)".
      end.
      when 'slt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('2':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '2':U(не задействован)".
      end.
      when 'rdt':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('3':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '3':U(не задействован)".
      end.
      when 'exc':U then do:
                  find first bf_tax where bf_tax.tax-code = integer('4':U) no-lock no-error.                     if available bf_tax then do:                                                                              assign parname-tax = bf_tax.tax-name.                                                               end.                                                                                                   else assign parname-tax = "Налог '4':U(не задействован)".
      end.
      otherwise do:
         return error "Задан неверный параметр " + pardef-tax + " .".
      end.
   end case.
end.
end procedure.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-waitfram-action01         as character   no-undo .
define variable v-waitfram-action02         as character   no-undo .
define variable v-waitfram-action03         as character   no-undo .
define variable mWaitFramTextBeg            as character   no-undo.
define variable mWaitFramTextEnd            as character   no-undo.
define variable mWaitFramView               as logical     no-undo.
define variable mWaitProcEvent              as logical     no-undo init yes.
define variable mWaitFramInterval           as integer     no-undo init 1 .
define variable mWaitFramStop               as logical     no-undo.
define variable mWaitFramStopUser           as logical     no-undo.
define variable mWaitFramStopTimeOut        as logical     no-undo.
define variable mWaitFramStartProc          as datetime-tz no-undo.
define variable mWaitFramTimeOut            as decimal     no-undo init ?.
define button B-WaitFramStop auto-end-key
     label "Стоп"
     size 10 by 1 tooltip "Остоновить процесс".
define button B-viewProcInfo
     label "Информация"
     size 15 by 1 tooltip "Информация о процесс".
define frame waitfram
  v-waitfram-action01 format "x(72)" no-label skip
  v-waitfram-action02 format "x(72)" no-label skip
  v-waitfram-action03 format "x(72)" no-label skip
  B-viewProcInfo
  B-WaitFramStop at row 4 col 30
  with view-as dialog-box side-labels three-d cancel-button B-WaitFramStop
  .
define new global shared variable mBatchMode as logical no-undo init ?.
define variable mFramBachModHandle as handle no-undo.
mFramBachModHandle = frame waitfram:handle.
define variable mFameOldVis as logical no-undo.
define variable mVisCUrentVin as logical no-undo.
if session:batch-mode
then
   mBatchMode = yes.
if mBatchMode = ? then do:
  mVisCUrentVin = current-window:visible.
  mFameOldVis = mFramBachModHandle:visible.
  mFramBachModHandle:visible  = yes.
  mBatchMode = mFramBachModHandle:visible ne yes.
  mFramBachModHandle:visible = mFameOldVis.
  current-window:visible = mVisCUrentVin.
end.
 if  log-manager:logfile-name ne ?
  then DO:
      log-manager:write-message("Logname=" + log-manager:logfile-name , "frameRepError").
      log-manager:write-message("Batch-mod=" + string(session:batch-mode) , "frameRepError").
      log-manager:write-message("visible-frame-mod=" + string(mFramBachModHandle:visible), "frameRepError").
  end.
on choose of B-WaitFramStop in frame waitfram
do:
  mWaitFramStop = yes.
  mWaitFramStopUser = yes.
end.
function waitfram-check-timeout returns logical():
   define variable vtime as int64 no-undo.
   if mWaitFramStopTimeOut
   then
      return yes.
   vtime = ( now - mWaitFramStartProc ) / 1000 .
   if     mWaitFramTimeOut ne ?
      and mWaitFramTimeOut ne 0
      and mWaitFramTimeOut lt vtime
   then do:
      mWaitFramStopTimeOut = yes.
   end.
   return mWaitFramStopTimeOut.
end.
procedure waitfram-hide :
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    pause 0 before-hide .
    if not mBatchMode then
      hide frame waitfram .
  if     not mWaitFramView
     and mWaitProcEvent
  then
    process events .
  end.
end procedure.
procedure waitfram-show :
  define input  parameter p-message as character no-undo .
  define variable v-left-margin as integer   no-undo .
  if not session:batch-mode
  then do
  on error undo, return error return-value
  :
    if length(p-message) <= 70 then do:
      assign
        v-left-margin = integer((70 - length(p-message)) / 2)
      .
      assign
        v-left-margin = max(0, v-left-margin - (v-left-margin mod 5))
      .
      assign
        v-waitfram-action01 = " "
        v-waitfram-action02 = " "
                                 + fill(" ", v-left-margin)
                                 + p-message
        v-waitfram-action03 = " "
      .
    end.
    else do:
      define variable vRindex1 as integer no-undo.
      define variable vRindex2 as integer no-undo.
      vRindex1 = r-index(p-message," ",70).
      if vRindex1 = 0
      then
         vRindex1 = 70.
      if length(p-message)  <= vRindex1 + 70 then do:
        assign
          v-waitfram-action01 = " "
          v-waitfram-action02 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action03 = " " + substring(p-message,  vRindex1 + 1, 70      )
        .
      end.
      else do:
        vRindex2 = r-index(p-message," ",vRindex1 + 70).
        if vRindex2 <= vRindex1
        then
           vRindex2 = vRindex1 + 70.
        assign
          v-waitfram-action01 = " " + substring(p-message,   1          , vRindex1)
          v-waitfram-action02 = " " + substring(p-message,  vRindex1 + 1, vRindex2 - vRindex1 )
          v-waitfram-action03 = " " + substring(p-message,  vRindex2 + 1, 70)
        .
      end.
    end.
    B-viewProcInfo:visible   in frame waitfram = no.
    B-viewProcInfo:sensitive in frame waitfram = no.
    B-WaitFramStop:visible   in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    B-WaitFramStop:sensitive in frame waitfram = if not mBatchMode and mWaitFramView then yes else no .
    if  (   mWaitFramView
       or  mWaitProcEvent)
       and not mBatchMode
    then
       display
          v-waitfram-action01 skip
          v-waitfram-action02 skip
          v-waitfram-action03 skip
       with frame waitfram .
    if     mWaitFramView
       then do:
          if     mWaitFramInterval ne ?
             and not mBatchMode
          then
             wait-for go of frame waitfram pause mWaitFramInterval.
       end.
       else
          if     mWaitProcEvent
             and not mBatchMode
          then
             process events .
  end.
end procedure.
   procedure waitfram-show-this:
      define input  parameter iInterval as int64 no-undo.
      define variable vtime as int64 no-undo.
      vtime = ( now - mWaitFramStartProc  ) / 1000 .
      mWaitFramInterval = iInterval.
      run waitfram-show (substitute("&1&2 &3&4" ,
                                    mWaitFramTextBeg ,
                                    if vtime eq ? then "" else substitute (" Прошло: &1 сек" , string( vtime)),
                                    if mWaitFramTimeOut ne 0 and mWaitFramTimeOut ne ? then " из " + string(mWaitFramTimeOut) + " сек. " else "",
                                    mWaitFramTextEnd
                                   )
                        ).
   end.
   procedure WaitFramRunPause:
      define input  parameter iInterval as dec no-undo.
      define variable vStart  as datetime-tz no-undo.
      define variable vend    as datetime-tz no-undo.
      define variable vint as int64 no-undo.
      define variable vOk as logical no-undo.
      vStart = now.
      vend   = vStart.
      publish "WaitFramPause" (iInterval,output vOk).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and (   vint > 0
              or (    not vOk
                  and iInterval eq ?
                  )
              )
      then
         run waitfram-show-this (iInterval).
      vend   =  now.
      vint = vend - vStart.
      vint = iInterval - vint / 1000.
      if     not mWaitFramStop
         and vint > 0
      then do:
         run gbl/pause.p (vint * 1000).
      end.
      if iInterval ne ?
      then
         publish "WaitFramStop".
      waitfram-check-timeout().
   end.
   procedure WaitFramWaitFor:
      define input  parameter iInterval as dec no-undo.
      assign
         mWaitFramStartProc   = now
         mWaitFramStopUser    = no
         mWaitFramStopTimeOut = no
      .
      block-wait:
      do while not mWaitFramStop:
         run WaitFramRunPause (iInterval).
         if  waitfram-check-timeout()
         then do:
            leave block-wait.
         end.
      end.
      run waitfram-hide.
   end.
procedure waitfram-join :
  define input  parameter p-line-1  as character no-undo .
  define input  parameter p-line-2  as character no-undo .
  define input  parameter p-line-3  as character no-undo .
  define output parameter p-message as character no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-message = substring(p-line-1 + fill(' ', 70), 1, 70)
                + substring(p-line-2 + fill(' ', 70), 1, 70)
                + substring(p-line-3 + fill(' ', 70), 1, 70)
    .
  end.
end procedure.
function waitfram-join-function returns character
  (input p-line-1 as character
  ,input p-line-2 as character
  ,input p-line-3 as character
  ).
  define variable v-message as character no-undo .
  run waitfram-join in this-procedure
    (input  p-line-1
    ,input  p-line-2
    ,input  p-line-3
    ,output v-message
    ) .
  return v-message .
end function .
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure alc-lib_mark-name :
  define input  parameter p-mark-db-num   as integer   no-undo .
  define input  parameter p-mark-code     as integer   no-undo .
  define output parameter p-mark-name     as character no-undo .
  define buffer buf_ex-mark for ub.ex-mark .
  do
  on error undo, return error return-value
  :
    if p-mark-db-num = ?
    or p-mark-code   = ?
    then do:
      assign
        p-mark-name = '?':u
      .
      return .
    end.
    if  p-mark-db-num = 0
    and p-mark-code   = 0
    then do:
      assign
        p-mark-name = ""
      .
      return .
    end.
    find first buf_ex-mark no-lock
      where buf_ex-mark.db-num    = p-mark-db-num
        and buf_ex-mark.mark-code = p-mark-code
      no-error .
    if available buf_ex-mark
    then do:
      assign
        p-mark-name = substitute('&1':u
                                ,buf_ex-mark.mark-name
                                )
      .
    end.
  end.
end procedure.
procedure alc-lib_get-new-part-code :
  define input  parameter p-obj-type       as character no-undo .
  define input  parameter p-obj-code       as integer   no-undo .
  define input  parameter p-prod-type      as character no-undo .
  define input  parameter p-prod-code      as integer   no-undo .
  define input  parameter p-artic          as character no-undo .
  define input  parameter p-doc-code       as character no-undo .
  define output parameter p-new-part-code  as character no-undo .
  define variable v-cur-part-code as integer no-undo.
  define variable v-max-part-code as integer no-undo.
  define variable i               as integer no-undo.
  define buffer bf_parts for ub.parts .
  do
  on error undo, return error return-value
  :
    assign
      v-max-part-code = 0
    .
    for each bf_parts no-lock
          where bf_parts.obj-type  = p-obj-type  and
                bf_parts.obj-code  = p-obj-code  and
                bf_parts.prod-type = p-prod-type and
                bf_parts.prod-code = p-prod-code and
                bf_parts.artic     = p-artic     and
                bf_parts.out-code  = p-doc-code
      :
      assign
        v-cur-part-code = integer(bf_parts.part-code)
        no-error.
      if error-status:error = no and v-cur-part-code > v-max-part-code then do:
        assign
          v-max-part-code = v-cur-part-code
        .
      end.
    end.
    assign
      p-new-part-code = string (v-max-part-code + 1)
    .
  end.
end procedure.
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-fltopend-rowid as rowid extent 18 no-undo .
procedure fltopend_fltopend :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
  do
  on error undo, return error
  :
define variable v-prepare-string as character no-undo .
define variable glog as logical no-undo .
assign
v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                   p-where-cond + chr(32)  +
                   p-use-indFIRST-query-tail + chr(32) +
                   p-use-ind-sort-clmn-by + chr(32) +
                   p-indexed-reposition
.
assign
glog = p-qh:query-prepare(v-prepare-string) no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
assign
glog = p-qh:query-open no-error .
if not glog
or error-status:error then do:
  message error-status:get-message(1) view-as alert-box .
  undo, return error .
end.
  end.
end procedure.
procedure fltopend_fltfindd :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-rowid as rowid no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-bh as handle no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-index-phrase as character no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo .
define variable v-recid as recid no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  glog = p-bh:find-by-rowid( p-rowid, p-lock) no-error.
  create buffer v-bh for table p-bh buffer-name p-bh:name.
  create query v-qh.
  v-qh:set-buffers(v-bh).
  v-prepare-string = substitute("for each &1 &2 &3"
                                  ,v-bh:name
                                  ,p-where-cond
                                  ,p-use-index-phrase).
  glog = v-qh:query-prepare(v-prepare-string) no-error.
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    delete object v-bh.
    undo, return error .
  end.
  if p-next then do:
    v-qh:reposition-to-rowid(p-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  v-recid = v-bh:recid no-error .
  delete object v-qh.
  delete object v-bh.
  return string(v-recid) .
end.
end procedure.
procedure fltopend_fltfindq :
define input parameter p-parent-handle as handle no-undo .
define input parameter p-qh as handle no-undo .
define input parameter p-next as logical no-undo .
define input parameter p-lock as integer no-undo .
define input parameter p-flt-open-open-query  as character no-undo .
define input parameter p-where-cond as character no-undo .
define input parameter p-use-indFIRST-query-tail as character no-undo .
define input parameter p-use-ind-sort-clmn-by as character no-undo .
define input parameter p-indexed-reposition as character no-undo .
define output parameter p-fltopend-rowid as rowid extent 18 no-undo .
define variable glog as logical no-undo .
define variable v-qh as handle no-undo .
define variable v-bh as handle no-undo extent 18.
define variable v-rowid as rowid no-undo extent 18.
define variable v-ii as integer no-undo .
define variable v-prepare-string as character no-undo .
do
on error undo, return error
on stop undo, return error
:
  create query v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    create buffer v-bh[v-ii] for table p-qh:get-buffer-handle(v-ii) buffer-name p-qh:get-buffer-handle(v-ii):name .
    assign
    v-rowid[v-ii] = p-qh:get-buffer-handle(v-ii):rowid
    no-error.
    v-qh:add-buffer(v-bh[v-ii]).
  end.
  assign
  v-prepare-string = p-flt-open-open-query + " where " + chr(32) +
                    p-where-cond + chr(32)  +
                    p-use-indFIRST-query-tail + chr(32) +
                    p-use-ind-sort-clmn-by + chr(32) +
                    p-indexed-reposition
  .
  glog = v-qh:query-prepare( v-prepare-string) no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  glog = v-qh:query-open no-error .
  if not glog then do:
    delete object v-qh.
    do v-ii = 1 to p-qh:num-buffers:
      delete object v-bh[v-ii].
    end.
    undo, return error .
  end.
  if p-next then do:
    glog = v-qh:reposition-to-rowid(v-rowid) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    glog = v-qh:get-next( p-lock) no-error .
    if not glog or v-qh:query-off-end = yes then do:
      glog = v-qh:get-first( p-lock) no-error .
    end.
  end.
  else do:
    glog = v-qh:get-first( p-lock) no-error .
  end.
  do v-ii = 1 to p-qh:num-buffers:
    assign
    p-fltopend-rowid[v-ii] = v-bh[v-ii]:rowid
    no-error.
  end.
  delete object v-qh.
  do v-ii = 1 to p-qh:num-buffers:
    delete object v-bh[v-ii].
  end.
end.
end procedure.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
def var vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define temp-table tt-utd like ub.utd
  field stts        as character
  field stts-edi    as character
  field cli-name    as character
  field EDoTypeName as character
  field ModifyTime_ as character
  field orig-code   as character
  field GrayZone    as logical
  field obj-name    as character
  field is-initial  as character
  field scan-qnty   as decimal
  field free-qnty   as decimal
  .
define temp-table tt-sert-utd
  field doc-id like ub.utd.doc-id
  field db-num like ub.utd.db-num
  field DocumentDate like ub.utd.DocumentDate
  field DocumentNumber like ub.utd.DocumentNumber
  field cli-code as integer
  field cli-type as character
  index pi  db-num doc-id
  .
define temp-table tt-utd-lines-filtr no-undo
    field db-num  as integer
    field doc-id  as integer
    field linenum as integer
    field bar-code as character
    index pi  db-num doc-id LineNum
    index bar-code bar-code db-num doc-id LineNum
.
define temp-table tt-utd-lines like ub.utd-lines
  field qnty-scan as decimal
  field qnty-mark as integer
  field stts      as character
  field gds-name  as character
  field TaxRate_  as character
  field fact-qnty as decimal
  field free-qnty as decimal
  field sts_err   as logical
  field DelivCodeMis   as logical
  field UnitCli   as character
  field UnitCliQnty as decimal
  field isMarking   as logical
  field isArtic     as logical
  field isWeight    as logical
  field isVarWeight as logical
  field isSelect    as logical
  field markType    as character
  field PieceTTH    as character
  field PieceFact   as character
  index pi  db-num doc-id LineNum
  index gds-code gds-code
  index sts stts sts
  .
define temp-table tt-marking-lines no-undo like ub.marking-lines
  field mark-parent like ub.marking.mark-parent
  field stts        as character
  field sts-utd     as integer
  field stts-utd    as character
  field unit        as character
  field unit-ext    as character
  field site        as character
  field box-qnty    as decimal
  field gds-name    as character
  field db-num      as integer
  field doc-id      as integer
  field LineNum     as integer
  field GrayZone    as logical
  field isMark      as logical
  field isWeight    as logical
  field marking-string as character
  field old-sts     as integer
  field weight      as character
  index pi  doc-level   sts
  index pi2 mark-parent sts
  index pi3 unit-ext
  index pi4 mark obj-type obj-code gds-code in-code out-code part-code prt-code
  index part gds-code obj-type obj-code in-code out-code part-code prt-code
  index gds-code gds-code
  index obj obj-code obj-type
  .
define temp-table tt-mark-line like ub.marking-lines
  field date_    as date
  field doc-type as character
  field type     as integer
  field doc-id   as integer
  field db-num   as integer
  field EdocType as integer
  index pi mark out-code doc-type .
define temp-table tt-marking like ub.marking
  .
define temp-table tt-utd-marking-lines like ub.utd-marking-lines
  .
define temp-table tt-inv-marking no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty          as decimal
  field qnty-scan     as decimal
  field qnty-confirm  as integer
  field qnty-scan-not as integer
  field qnty-not      as integer
  index pi gds-code
  .
define temp-table tt-tech-mark no-undo
  field gds-code      as integer
  field gds-name      as character
  field qnty-fact     as integer
  field qnty-doc      as integer
  field doc-code      as character
  field line-num      as integer
  index pi as UNIQUE doc-code line-num gds-code
  .
define temp-table tt-utd-err like ub.utd-err
  field descr as character
  field gds-code as integer
  field LineNum  as integer
  field type     as integer
  .
define variable v-need-reserv          as logical   no-undo .
define variable v-need-check-diff-qnty as logical   no-undo .
define variable v-chg-qnty             as decimal   no-undo .
define variable mark                    as character                no-undo column-label "*"                format "x(1)"  .
define variable parts-part-code         as character                no-undo column-label "Партия"           format "x(40)" .
define variable parts-out-code          as character                no-undo column-label "Статус"           format "x(18)" .
define variable parts-object            as character                no-undo column-label "Объект"           format "x(10)" .
define variable parts-b-code            like ub.bar-code.b-code     no-undo column-label "Бар-код"           .
define variable parts-purch-code        as character                no-undo column-label "Тип приобретения" format "x(20)" .
define variable parts-contract-prn-code as character                no-undo column-label "Договор"          format "x(16)" .
define variable in-code-date as character no-undo .
define variable vprice-prod1 as decimal   no-undo .
define variable vprice-prod2 as decimal   no-undo .
define variable vsdsubsObj as class vsdsubs no-undo.
define variable vsdsubObj  as class vsdsub no-undo.
define variable vsdStorageObj as class vsdtostorage no-undo.
define variable vsdSts as class vsdstatustype no-undo.
define variable v-vozvr-perem-no-fact as logical no-undo.
define variable v-marking as logical no-undo .
define variable v-marking-value as character no-undo .
define variable v-marking-type as character no-undo .
define variable varvalue as character no-undo .
define variable vartype as character no-undo .
define variable v-ext-mode as character no-undo .
define variable v-sum-parts-qnty as decimal no-undo .
define variable bcol    as handle    extent no-undo.
define variable hBrowse as handle    no-undo.
define variable ic as integer no-undo .
define variable ObjSrv as class ibs.th.gbl.sys.objsrv no-undo.
define variable EDOParSec as class ibs.th.gbl.env.prmtrs.edo .
define new shared buffer  parts for ub.parts  .
define buffer  buf_trn for ub.trn-doc  .
FUNCTION get-in-code-date RETURNS CHARACTER
  ( input p-recid as recid ) :
define buffer buf_parts for ub.parts  .
define buffer buf_parts-attr for ub.parts-attr  .
define buffer buf_goods      for ub.goods       .
find first  buf_parts no-lock where recid(buf_parts) = p-recid no-error .
find first buf_goods no-lock where
            buf_goods.artic =  buf_parts.artic and
            buf_goods.prod-code =  buf_parts.prod-code and
            buf_goods.prod-type =  buf_parts.prod-type no-error .
find first buf_parts-attr no-lock
     where buf_parts-attr.part-code = buf_parts.part-code and
           buf_parts-attr.in-code   = buf_parts.in-code   and
           buf_parts-attr.gds-code  = buf_goods.gds-code  no-error .
           if available buf_parts-attr then return string ( buf_parts-attr.fact-date, "99/99/9999" ) .
           else return "" .
END FUNCTION.
FUNCTION get-price-prod1 RETURNS DECIMAL
  ( input p-recid as recid ) :
define buffer buf_parts for ub.parts  .
define variable       p-price as decimal   no-undo .
define variable       p-priceWithVat as decimal   no-undo .
define variable       p-vat-pc as decimal   no-undo .
find first  buf_parts no-lock where recid(buf_parts) = p-recid no-error .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partppric in g#library
(  buffer buf_parts
 , output p-price
 , output p-priceWithVat
 , output p-vat-pc
        ) no-error .
return p-price .
END FUNCTION.
FUNCTION get-price-prod2 RETURNS DECIMAL
  ( input p-recid as recid ) :
define buffer buf_parts for ub.parts  .
define variable       p-price as decimal   no-undo .
define variable       p-priceWithVat as decimal   no-undo .
define variable       p-vat-pc as decimal   no-undo .
find first  buf_parts no-lock where recid(buf_parts) = p-recid no-error .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partppric in g#library
(  buffer buf_parts
 , output p-price
 , output p-priceWithVat
 , output p-vat-pc
        ) no-error .
return p-priceWithVat .
END FUNCTION.
def var Marking as class mark no-undo .
FUNCTION StatusTHName RETURNS CHARACTER
  (input p-stsTH as integer)  .
  Return Marking:GetLabel(p-stsTH) .
END FUNCTION .
FUNCTION get-b-code RETURNS integer
  ( BUFFER buf_parts FOR parts ) :
  define variable v-b-code like ub.bar-code.b-code no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer parts
  ,output v-b-code
  ) no-error .
  if error-status :error
  then do:
    return 0 .
  end.
  else do:
    return v-b-code .
  end.
END FUNCTION.
FUNCTION get-price-sale RETURNS DECIMAL
  ( input p-recid as recid ) :
define buffer buf_parts for ub.parts  .
define variable v-price as decimal   no-undo .
define variable v-cur-dn as character no-undo .
define variable v-cur-rt as decimal   no-undo .
define variable v-cur-ex as decimal   no-undo .
define variable v-b-code as integer   no-undo .
v-price = 0.
find first  buf_parts no-lock where recid(buf_parts) = p-recid no-error .
v-b-code = get-b-code(buffer buf_parts) .
if v-b-code = 0 then return .0 .
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_parts.obj-type
  ,input  buf_parts.obj-code
  ,input  v-b-code
  ,input  0
  ,input  0
  ,output v-cur-dn
  ,output v-price
  ,output v-cur-rt
  ,output v-cur-ex
  ) no-error .
   if error-status :error then do:
     v-price = ? .
   end.
   return  v-price .
END FUNCTION.
FUNCTION get-price-doc RETURNS character
  ( input p-recid as recid ) :
define buffer buf_parts for ub.parts  .
define variable v-price as decimal   no-undo .
define variable v-cur-dn as character no-undo .
define variable v-cur-rt as decimal   no-undo .
define variable v-cur-ex as decimal   no-undo .
define variable v-b-code as integer   no-undo .
v-cur-dn = "".
find first  buf_parts no-lock where recid(buf_parts) = p-recid no-error .
v-b-code = get-b-code(buffer buf_parts) .
if v-b-code = 0 then return "".
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf_parts.obj-type
  ,input  buf_parts.obj-code
  ,input  v-b-code
  ,input  0
  ,input  0
  ,output v-cur-dn
  ,output v-price
  ,output v-cur-rt
  ,output v-cur-ex
  ) no-error .
   if error-status :error then do:
     v-cur-dn = ? .
   end.
   return substitute("&1 №&2" , v-price ,v-cur-dn) .
END FUNCTION.
FUNCTION get-in-code-dateS RETURNS date
  ( input p-recid as recid ) :
define buffer buf_parts for ub.parts  .
define buffer buf_parts-attr for ub.parts-attr  .
define buffer buf_goods      for ub.goods       .
find first  buf_parts no-lock where recid(buf_parts) = p-recid no-error .
find first buf_goods no-lock where
            buf_goods.artic =  buf_parts.artic and
            buf_goods.prod-code =  buf_parts.prod-code and
            buf_goods.prod-type =  buf_parts.prod-type no-error .
find first buf_parts-attr no-lock
     where buf_parts-attr.part-code = buf_parts.part-code and
           buf_parts-attr.in-code   = buf_parts.in-code   and
           buf_parts-attr.gds-code  = buf_goods.gds-code  no-error .
           if available buf_parts-attr then return  buf_parts-attr.fact-date .
           else return date("") .
END FUNCTION.
define variable v-edit-parts as logical   no-undo init false .
define variable v-add-parts as logical   no-undo init false .
define variable v-need-rsrv-gds as logical no-undo init false .
define variable v-is-petrol     as logical no-undo init false .
define variable v-is-pieces     as logical no-undo init false .
define variable v-data-changed  as logical no-undo init false .
define variable v-reserv-pl-code            as logical   no-undo init ? .
define variable v-pl-code                   as integer   no-undo init 0 .
define variable v-goods-twounit             as logical   no-undo .
define variable v-goods-alcohol-prod        as logical   no-undo .
define variable v-free-parts-qnty           as decimal   no-undo .
define variable v-free-parts-fact-qnty      as decimal   no-undo .
define variable v-free-parts-cli-qnty       as decimal   no-undo .
define variable v-free-parts-price-base     as decimal   no-undo .
define variable v-free-parts-price-rubl     as decimal   no-undo .
define variable v-out-parts-qnty            as decimal   no-undo .
define variable v-out-parts-fact-qnty       as decimal   no-undo .
define variable v-out-parts-cli-qnty        as decimal   no-undo .
define variable v-out-parts-price-base      as decimal   no-undo .
define variable v-out-parts-price-rubl      as decimal   no-undo .
define variable v-new-free-parts-qnty       as decimal   no-undo .
define variable v-new-free-parts-fact-qnty  as decimal   no-undo .
define variable v-new-free-parts-cli-qnty   as decimal   no-undo .
define variable v-new-free-parts-price-base as decimal   no-undo .
define variable v-new-free-parts-price-rubl as decimal   no-undo .
define variable v-new-out-parts-qnty        as decimal   no-undo .
define variable v-new-out-parts-fact-qnty   as decimal   no-undo .
define variable v-new-out-parts-cli-qnty    as decimal   no-undo .
define variable v-new-out-parts-price-base  as decimal   no-undo .
define variable v-new-out-parts-price-rubl  as decimal   no-undo .
define variable rid                         as recid     no-undo .
define variable conf-par                    as character no-undo .
define variable par-type                    as character no-undo .
define variable old-mode                    as character no-undo .
define variable old-handle                  as handle    no-undo .
define variable old-type                    as character no-undo .
define variable old-stat                    as character no-undo .
define variable old-flag                    as logical   no-undo .
define variable old-internal                as logical   no-undo .
define variable del-list                    as character no-undo.
define variable filter-point                as character no-undo init "parts-l" .
define variable sort-column-name            as character no-undo .
define variable v-mode-name                 as character no-undo .
FUNCTION get-contract-prn-code RETURNS CHARACTER
  ( input p-recid as recid  )  FORWARD.
FUNCTION get-country-name RETURNS CHARACTER
  ( BUFFER buf_parts FOR parts )  FORWARD.
FUNCTION get-mark RETURNS CHARACTER
  ( BUFFER buf_parts FOR parts )  FORWARD.
FUNCTION get-purch-code RETURNS CHARACTER
  ( BUFFER buf_parts FOR parts )  FORWARD.
DEFINE BUTTON b-add
     LABEL "&Добавить"
     SIZE 10 BY 1.
DEFINE BUTTON b-alc-attr
     LABEL "АлкАт&р"
     SIZE 10 BY 1 TOOLTIP "Атрибуты алкогольной продукции".
DEFINE BUTTON b-b-alt
     LABEL "&Коды"
     SIZE 10 BY 1.
DEFINE BUTTON b-chg
     LABEL "&Изменить"
     SIZE 10 BY 1.
DEFINE BUTTON b-contract
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL "b-contract"
     SIZE 3 BY 1 TOOLTIP "Посмотреть До&говор".
DEFINE BUTTON b-del
     LABEL "&Удалить"
     SIZE 10 BY 1.
DEFINE BUTTON b-doc
     LABEL "Д&окумент"
     SIZE 10 BY 1.
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-in
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL "П&Н"
     SIZE 3 BY 1 TOOLTIP "Документ, создавший партию или изменивший её параметры".
DEFINE BUTTON b-income-in-code
     IMAGE-UP FILE "cmp/btn-fnd.bmp":U
     IMAGE-DOWN FILE "cmp/btn-fnd.bmp":U
     IMAGE-INSENSITIVE FILE "cmp/btn-fnd.bmp":U NO-CONVERT-3D-COLORS
     LABEL "Вне&ш.ПН"
     SIZE 3 BY 1 TOOLTIP "Внешний приходный документ, создавший партию".
DEFINE BUTTON b-lkp
     LABEL "&Просмотр"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-mark
     LABEL "&*"
     SIZE 3 BY 1.
DEFINE BUTTON b-marking
     LABEL "&Марки"
     SIZE 10 BY 1 TOOLTIP "Марки".
DEFINE BUTTON b-pl
     LABEL "&Место"
     SIZE 10 BY 1.
DEFINE BUTTON b-print
     LABEL "Пе&чать"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-sch
     LABEL "&Фильтр"
     SIZE 3 BY 1.
DEFINE BUTTON b-sel AUTO-GO
     LABEL "Вы&бор "
     SIZE 10 BY 1.
DEFINE BUTTON b-vsd
     LABEL "ВС&Д"
     SIZE 10 BY 1 TOOLTIP "Ветеренарная справка".
DEFINE VARIABLE ed-notes AS CHARACTER
     VIEW-AS EDITOR
     SIZE 25.5 BY 1.75
     BGCOLOR 8 FGCOLOR 4 FONT 2 NO-UNDO.
DEFINE VARIABLE fi-b-code AS INTEGER FORMAT ">>>>>>>>>>>>9":U INITIAL 0
     LABEL "Бар-код"
      VIEW-AS TEXT
     SIZE 14 BY .79 TOOLTIP "Бар-код"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-free-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Свободно"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-free-rsrv-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Резерв Свободно"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-income-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Приход док"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-income-qnty-fact AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Приход факт"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-label-filter-object AS CHARACTER FORMAT "X(256)":U INITIAL ""
      VIEW-AS TEXT
     SIZE 8 BY .88 NO-UNDO.
DEFINE VARIABLE fi-label-filter-status AS CHARACTER FORMAT "X(256)":U INITIAL ""
      VIEW-AS TEXT
     SIZE 7 BY .67 NO-UNDO.
DEFINE VARIABLE F-date-to AS DATE FORMAT "99/99/9999":U
     VIEW-AS FILL-IN
     SIZE 10.8 BY 1 NO-UNDO.
DEFINE VARIABLE F-date-from AS DATE FORMAT "99/99/9999":U
     LABEL "Период "
     VIEW-AS FILL-IN
     SIZE 10.8 BY 1 NO-UNDO.
DEFINE VARIABLE fi-out-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Расход"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE fi-out-rsrv-qnty AS DECIMAL FORMAT "->>>,>>>,>>9.999":U INITIAL 0
     LABEL "Резерв Расход"
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FI_contract-prn-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Договор"
      VIEW-AS TEXT
     SIZE 36.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FI_country-name AS CHARACTER FORMAT "X(256)":U
     LABEL "Страна"
      VIEW-AS TEXT
     SIZE 21.13 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FI_currency_curr-abbr AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 10 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_doc-line_doc-qnty AS DECIMAL FORMAT "->>,>>9.99" INITIAL ?
     LABEL "По док-ту"
      VIEW-AS TEXT
     SIZE 13 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_doc-line_fact-qnty AS DECIMAL FORMAT "->>,>>9.99" INITIAL 0
     LABEL "Факт"
      VIEW-AS TEXT
     SIZE 13 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_last-date AS CHARACTER FORMAT "X(10)":U
     LABEL "Годен до"
      VIEW-AS TEXT
     SIZE 11.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FI_obj-code AS INTEGER FORMAT ">>>>>>>>9" INITIAL 0
      VIEW-AS TEXT
     SIZE 11.5 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_obj-name AS CHARACTER FORMAT "X(40)"
     LABEL "Пост-к"
      VIEW-AS TEXT
     SIZE 29.5 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_obj-type AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_orig-purch-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип приобретения"
      VIEW-AS TEXT
     SIZE 25 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FI_parts_cli-base-rate AS DECIMAL FORMAT "->>,>>9.99" INITIAL 0
     LABEL "Коэфф. пост."
      VIEW-AS TEXT
     SIZE 17 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_parts_cli-qnty AS DECIMAL FORMAT "->>,>>9.99" INITIAL 0
     LABEL "Кол. пост."
      VIEW-AS TEXT
     SIZE 17 BY .67 TOOLTIP "Документарное"
     FGCOLOR 4 .
DEFINE VARIABLE FI_parts_fact-date AS DATE FORMAT "99/99/9999"
     LABEL "Дата"
      VIEW-AS TEXT
     SIZE 12 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_parts_in-code AS CHARACTER FORMAT "X(14)"
     LABEL "ПН"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_parts_orig-fact-date AS DATE FORMAT "99/99/9999"
     LABEL "Дата"
      VIEW-AS TEXT
     SIZE 12 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_parts_orig-in-code AS CHARACTER FORMAT "X(14)"
     LABEL "Внеш.ПН"
      VIEW-AS TEXT
     SIZE 14 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_parts_price-cli AS DECIMAL FORMAT "->>,>>>,>>9.99" INITIAL 0
     LABEL "Цена пост."
      VIEW-AS TEXT
     SIZE 22.75 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_parts_SLT-pc AS DECIMAL FORMAT "->>,>>9.99" INITIAL 0
     LABEL "%"
      VIEW-AS TEXT
     SIZE 6 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_parts_SLT-type AS CHARACTER FORMAT "X(8)"
     LABEL "НП"
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_parts_VAT-pc AS DECIMAL FORMAT "->>,>>9.99" INITIAL 0
     LABEL "%"
      VIEW-AS TEXT
     SIZE 7 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_parts_VAT-type AS CHARACTER FORMAT "X(8)"
     LABEL "НДС"
      VIEW-AS TEXT
     SIZE 9 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_pay-name AS CHARACTER FORMAT "X(40)"
     LABEL "Оплата"
      VIEW-AS TEXT
     SIZE 28 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_price-doc AS CHARACTER FORMAT "X(256)":U
     LABEL "Продажная цена"
      VIEW-AS TEXT
     SIZE 25.5 BY .67 TOOLTIP "Текущая продажная цена баркода и № переоценки"
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE FI_purch-code AS CHARACTER FORMAT "X(256)":U
     LABEL "Тип приобретения"
      VIEW-AS TEXT
     SIZE 22.5 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE FI_unit-base AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE FI_unit_cli-abbr AS CHARACTER FORMAT "X(3)"
      VIEW-AS TEXT
     SIZE 4.5 BY .67
     FGCOLOR 4 .
DEFINE VARIABLE s-code AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 11.5 BY .88 TOOLTIP "Поиск по" NO-UNDO.
DEFINE VARIABLE R-find AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "№ партии", 1,
"Бар-код", 2
     SIZE 20.38 BY .88 TOOLTIP "Поиск" NO-UNDO.
DEFINE VARIABLE rs-one-all AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Текущий объект", "текущий",
"Все объекты", "все"
     SIZE 29.5 BY .88 TOOLTIP "Выбор объекта"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE rs-parts AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "Все", "все",
"Факт остатки", "остатки",
"Свободно", "свободно",
"Документ", "документ"
     SIZE 46.5 BY .67 TOOLTIP "Выбор статуса"
     FGCOLOR 4  NO-UNDO.
DEFINE RECTANGLE RECT-4
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 37.25 BY 5.13.
DEFINE RECTANGLE RECT-7
     EDGE-PIXELS 2 GRAPHIC-EDGE  NO-FILL
     SIZE 58.13 BY 2.17.
DEFINE QUERY br-parts FOR
      parts SCROLLING.
DEFINE BROWSE br-parts
  QUERY br-parts DISPLAY
      get-mark(buffer parts) @ mark
      get-parts-part-code(buffer parts, v-goods-alcohol-prod) @ parts-part-code
      get-parts-out-code(buffer parts) @ parts-out-code
      parts.qnty COLUMN-LABEL "По док./ Свобод."
      parts.fact-qnty COLUMN-LABEL "Факт / Остаток"
      parts.price-base format "->>,>>>,>>9.99"
      parts.price-rubl
      parts.cli-qnty column-label "Кол. пост."
      parts.cli-base-rate column-label "Коэфф. пост."
      parts.transport-base column-label "Трансп. (вал)"
      parts.transport-rubl column-label "Трансп. (abbr_rub)"
      parts.road-tax-base column-label "Дор.налог (вал)"
      parts.road-tax-rubl column-label "Дор.налог (abbr_rub)"
      parts.other-base column-label "Другое (вал)"
      parts.other-rubl column-label "Другое (abbr_rub)"
      (parts.obj-type + " " + STRING (parts.obj-code)) @ parts-object
      parts.is-supp format "+/-" column-label "П"
      parts.cst-code FORMAT "X(31)"
      parts.last-date format '99/99/9999':u column-label "Годен до"
      parts.hold-date format '99/99/9999':u column-label "Дата МФ"
      parts.pl-code column-label "Место"
      get-b-code(buffer parts) @ parts-b-code
      get-purch-code(buffer parts) @ parts-purch-code
      get-contract-prn-code(recid(parts)) @ parts-contract-prn-code column-label "Договор" format "x(20)"
      parts.part-code column-label "Код партии в БД" format "x(20)"
      parts.in-code column-label "Источник" format "x(20)"
      (get-in-code-date(recid(parts))) column-label "Дата ист."  format "x(10)"
      (get-price-sale(recid(parts)))  column-label "Тек.прод.цена"  format ">>>>>>>>>9.99"
      (get-price-prod1(recid(parts)))  @  vprice-prod1 column-label "Цена Произв."  format ">>>>>>>>>9.99"
      (get-price-prod2(recid(parts)))  @  vprice-prod2 column-label "Цена Прзв_с_НДС"  format ">>>>>>>>>>>9.99"
    if parts.defect = logical('yes':U) then "+"  else "" column-label "Ф" format "x(1)"
  ENABLE
      parts.qnty
      parts.fact-qnty
    WITH NO-ROW-MARKERS SEPARATORS SIZE 96 BY 8.42
         BGCOLOR 15  ROW-HEIGHT-CHARS .67.
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     b-mark AT ROW 1 COL 21
     b-sel AT ROW 1 COL 24
     b-lkp AT ROW 1 COL 34
     b-add AT ROW 1 COL 44
     b-chg AT ROW 1 COL 54
     b-del AT ROW 1 COL 64
     b-vsd AT ROW 1 COL 74
     b-sch AT ROW 1 COL 88
     b-print AT ROW 1 COL 91
     b-help AT ROW 1 COL 94
     b-doc AT ROW 2 COL 24
     b-b-alt AT ROW 2 COL 34
     b-pl AT ROW 2 COL 44
     b-alc-attr AT ROW 2 COL 64
     b-marking AT ROW 2 COL 54
     rs-parts AT ROW 3.13 COL 10 NO-LABEL
     rs-one-all AT ROW 3.92 COL 10 NO-LABEL
     R-find AT ROW 3.92 COL 65.5 NO-LABEL WIDGET-ID 6
     s-code AT ROW 3.92 COL 84 COLON-ALIGNED HELP
          "Поиск по бар-коду" NO-LABEL
     br-parts AT ROW 5.08 COL 1
     b-income-in-code AT ROW 13.79 COL 46.5
     b-in AT ROW 16.75 COL 46.5
     ed-notes AT ROW 20 COL 71.5 NO-LABEL
     b-contract AT ROW 22.54 COL 91.38
     FI_doc-line_doc-qnty AT ROW 2.21 COL 79.5 COLON-ALIGNED
     fi-label-filter-status AT ROW 3.04 COL 2.63 NO-LABEL
     f-date-from at row 3.5 col 5
     f-date-to at row 3.5 col 26 no-label
     FI_doc-line_fact-qnty AT ROW 3.13 COL 79.5 COLON-ALIGNED
     FI_unit-base AT ROW 3.17 COL 91.63 COLON-ALIGNED NO-LABEL
     fi-label-filter-object AT ROW 3.92 COL 1.63 NO-LABEL
     fi-b-code AT ROW 4 COL 48.88 COLON-ALIGNED
     fi-free-qnty AT ROW 13.83 COL 77 COLON-ALIGNED
     FI_parts_orig-in-code AT ROW 13.92 COL 10 COLON-ALIGNED
     FI_parts_orig-fact-date AT ROW 13.92 COL 32 COLON-ALIGNED
     fi-free-rsrv-qnty AT ROW 14.63 COL 77 COLON-ALIGNED
     FI_orig-purch-code AT ROW 14.79 COL 19 COLON-ALIGNED
     fi-income-qnty AT ROW 15.42 COL 77 COLON-ALIGNED
     fi-income-qnty-fact AT ROW 16.21 COL 77 COLON-ALIGNED WIDGET-ID 2
     FI_parts_in-code AT ROW 17 COL 7.5 COLON-ALIGNED
     FI_parts_fact-date AT ROW 17 COL 32 COLON-ALIGNED
     fi-out-qnty AT ROW 17.13 COL 77 COLON-ALIGNED
     FI_obj-name AT ROW 17.79 COL 7.5 COLON-ALIGNED
     FI_obj-type AT ROW 17.79 COL 39 COLON-ALIGNED NO-LABEL
     FI_obj-code AT ROW 17.79 COL 46 COLON-ALIGNED NO-LABEL
     fi-out-rsrv-qnty AT ROW 17.96 COL 77 COLON-ALIGNED
     FI_pay-name AT ROW 18.58 COL 7.5 COLON-ALIGNED
     FI_last-date AT ROW 18.67 COL 46 COLON-ALIGNED
     FI_price-doc AT ROW 19.25 COL 69.5 COLON-ALIGNED WIDGET-ID 4
     FI_parts_price-cli AT ROW 19.67 COL 11.5 COLON-ALIGNED
     FI_currency_curr-abbr AT ROW 19.67 COL 36.5 COLON-ALIGNED NO-LABEL
     FI_parts_cli-qnty AT ROW 20.46 COL 11.5 COLON-ALIGNED
     FI_unit_cli-abbr AT ROW 20.46 COL 31 COLON-ALIGNED NO-LABEL
     FI_parts_cli-base-rate AT ROW 20.46 COL 51.5 COLON-ALIGNED
     FI_parts_VAT-type AT ROW 21.54 COL 4.5 COLON-ALIGNED
     FI_parts_VAT-pc AT ROW 21.54 COL 18 COLON-ALIGNED
     FI_parts_SLT-type AT ROW 21.54 COL 37.5 COLON-ALIGNED
     FI_parts_SLT-pc AT ROW 21.54 COL 51.5 COLON-ALIGNED
     FI_country-name AT ROW 21.92 COL 73 COLON-ALIGNED
     FI_purch-code AT ROW 22.83 COL 18 COLON-ALIGNED
     FI_contract-prn-code AT ROW 22.83 COL 51.5 COLON-ALIGNED
     RECT-4 AT ROW 13.63 COL 60
     RECT-7 AT ROW 13.58 COL 1.5
     SPACE(38.36) SKIP(7.87)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Партии"
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE.
ASSIGN
       b-alc-attr:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       b-marking:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       b-vsd:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       br-parts:NUM-LOCKED-COLUMNS IN FRAME Dialog-Frame     = 3.
ON GO OF FRAME Dialog-Frame
DO:
  run save-changes in this-procedure no-error .
  if error-status :error
  then do:
    undo, return no-apply .
  end.
END.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
define variable vss-include-info24 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  do
  on error undo, return no-apply
  on stop  undo, return no-apply
  :
    if p-doc-code = ""
    then do:
      message
        "Добавление партий возможно только в интерфейсе документа"
        view-as alert-box .
      return no-apply .
    end.
    if v-reserv-pl-code = ?
    then do:
      message
        "Неизвестно место складирования товара. Добавление партий невозможно."
        view-as alert-box .
      return no-apply .
    end.
    assign
      v-prt-rec = ?
    .
    run str/parts-f.w
      (input        parparentproc
      ,input        this-procedure
      ,input        'ДОБАВЛЕНИЕ':U
      ,input        p-doc-code
      ,input        p-gds-code
      ,input        v-pl-code
      ,input-output v-prt-rec
      ).
    run reopen-query .
  end.
END.
ON leave OF F-date-from IN FRAME Dialog-Frame
DO:
  define variable is-changed as logical no-undo .
  is-changed = no .
  if string(F-date-from, "99/99/9999") <> F-date-from:screen-value then
  do:
      is-changed = yes .
      assign F-date-from .
  end.
  if F-date-from > F-date-to then
  do:
      message "Дата начала не может быть больше конечной даты"
          view-as alert-box.
      return no-apply .
  end.
  if is-changed
  then do :
    run reopen-query .
  end .
END.
ON leave OF F-date-to IN FRAME Dialog-Frame
DO:
  define variable is-changed as logical no-undo .
  is-changed = no .
  if string(F-date-to, "99/99/9999") <> F-date-to:screen-value then
  do:
      is-changed = yes .
      assign F-date-to .
  end.
  if F-date-from > F-date-to then
  do:
      message "Дата начала не может быть больше конечной даты"
          view-as alert-box.
      return no-apply .
  end.
  if is-changed
  then do :
    run reopen-query .
  end .
END.
ON CHOOSE OF b-alc-attr IN FRAME Dialog-Frame
DO:
define variable vss-include-info25 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable v-parts-ps  as character no-undo .
  define variable v-gds-code  as integer   no-undo .
  define variable v-save-flag as logical   no-undo .
define variable p-mode as char no-undo.
p-mode = 'ПРОСМОТР':U.
if not available parts then do:
    message
    "Нет партий по товару"
    view-as alert-box.
    return no-apply.
    end.
if p-edit-mode = 'update-alc-attr' then do:
    p-mode = 'ИЗМЕНЕНИЕ':U.
  if v-goods-alcohol-prod <> true then do:
    return no-apply.
  end.
  if p-doc-code = "" then do:
    message
      "Редактирование атрибутов партий возможно только в интерфейсе документа"
      view-as alert-box .
    return no-apply .
  end.
  if p-doc-code <> parts.out-code  then do:
    message
      "Редактирование атрибутов возможно только для партий, " +
      "относящихся к данному документу"
      view-as alert-box .
    return no-apply .
  end.
end.
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  parts.artic
  ,input  parts.prod-type
  ,input  parts.prod-code
  ,output v-gds-code
  ) no-error .
  do
  on error undo, return no-apply
  :
    define variable v-alc-mark-db-num          as integer   no-undo .
    define variable v-alc-mark-code            as integer   no-undo .
    define variable v-alc-bottling-date        as date      no-undo .
    define variable v-alc-ref-ab-path          as character no-undo .
    define variable v-alc-quality-certif-path  as character no-undo .
    define variable v-alc-certif-path          as character no-undo .
    define variable v-alc-imp-type             as character no-undo .
    define variable v-alc-imp-code             as integer   no-undo .
    define variable v-mode-alc                 as character no-undo .
    assign
      v-alc-mark-db-num         = parts.mark-db-num
      v-alc-mark-code           = parts.mark-code
      v-alc-bottling-date       = parts.alc-bottling-date
      v-alc-ref-ab-path         = parts.alc-ref-ab-path
      v-alc-quality-certif-path = parts.alc-quality-certif-path
      v-alc-certif-path         = parts.alc-certif-path
      v-alc-imp-type            = parts.alc-imp-type
      v-alc-imp-code            = parts.alc-imp-code
    .
    if p-mode = 'ПРОСМОТР':U and ub.parts.out-code = 'free-zone':U
    then do:
      v-mode-alc = 'ИЗМЕНЕНИЕ':U.
    end.
    else do:
      v-mode-alc = p-mode.
    end.
    run str/in-alc.w
      (input        parparentproc
      ,input       p-mode
      ,input p-gds-code
      ,input p-doc-code
      ,buffer ub.parts
      ,input-output v-alc-mark-db-num
      ,input-output v-alc-mark-code
      ,input-output v-alc-bottling-date
      ,input-output v-alc-ref-ab-path
      ,input-output v-alc-quality-certif-path
      ,input-output v-alc-certif-path
      ,input-output v-alc-imp-type
      ,input-output v-alc-imp-code
      ,output       v-save-flag
      ) no-error
      .
    if error-status :error
    then do:
      if error-status :get-message(1) <> '':u
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры in-alc.w" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      undo, return no-apply .
    end.
    if v-save-flag then do:
      run waitfram-show ("Сохранение новых значений и отправка их по новостям ...").
      run trg/partps.p ( input v-gds-code
                       , input parts.in-code
                       , input if ub.parts.doc-type = 'рас':U or ub.parts.out-code = 'free-zone':U then ub.parts.out-code else ?
                       , input parts.part-code
                       , input v-alc-mark-db-num
                       , input v-alc-mark-code
                       , input v-alc-bottling-date
                       , input v-alc-ref-ab-path
                       , input v-alc-quality-certif-path
                       , input v-alc-certif-path
                       , input v-alc-imp-type
                       , input v-alc-imp-code
                       ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при вызове процедуры partps.p" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        run waitfram-hide.
        undo, return no-apply .
      end.
      run waitfram-hide.
      find current parts no-lock.
      br-parts:refresh() in frame Dialog-Frame.
      run display-parts-info in this-procedure .
      apply "entry":u to br-parts.
    end.
  end.
END.
ON CHOOSE OF b-b-alt IN FRAME Dialog-Frame
DO:
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if available parts
  then do:
    define variable v-b-code like ub.bar-code.b-code no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run partbcod in g#library
  (buffer parts
  ,output v-b-code
  )  .
    run ref/alt-bc.w
      (
       input parparentproc
      ,input v-obj-type
      ,input v-obj-code
      ,input v-b-code
      ).
  end.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
define variable vss-include-info28 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  do
  on error undo, return no-apply
  on stop  undo, return no-apply
  :
    if available parts
    then do:
      if p-doc-code = ""
      then do:
        message
          "Редактирование партий возможно только в интерфейсе документа"
          view-as alert-box .
        return no-apply .
      end.
      if v-reserv-pl-code = ?
      then do:
        message
          "Неизвестно место складирования товара. Редактирование партий невозможно."
          view-as alert-box .
        return no-apply .
      end.
      assign
        v-prt-rec = recid(parts)
      .
      run str/parts-f.w
        (input        parparentproc
        ,input        this-procedure
        ,input        'ИЗМЕНЕНИЕ':U
        ,input        p-doc-code
        ,input        p-gds-code
        ,input        v-pl-code
        ,input-output v-prt-rec
        ).
    end.
    else do:
      message
        "Неправильно выбрана строка"
        view-as alert-box .
      return no-apply.
    end.
  end.
  run reopen-query .
END.
ON CHOOSE OF b-contract IN FRAME Dialog-Frame
DO:
define variable vss-include-info29 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run show-contract-code in this-procedure .
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
define variable vss-include-info30 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable lok as logical no-undo .
  do
  on stop undo, return no-apply
  :
    if del-list = ""
    then do:
      if not available parts
      then do:
        message
          "Неправильный выбор партии."
          view-as alert-box .
        return no-apply.
      end.
      if parts.in-code = parts.out-code
        and v-is-petrol = yes
        and v-is-pieces = no
      then do:
        message
          "Во внешнем приходе топливо нельзя редактировать через партии" skip
        view-as alert-box information .
        return no-apply .
      end.
      lok = no.
      message
        "Удалить партию?" SKIP
        "Вы уверены?"
        view-as alert-box question
        buttons OK-Cancel
        update lok.
      if lok <> true
      then do:
        return no-apply.
      end.
      assign
        v-prt-rec = recid(parts)
        del-list  = string(recid(parts))
      .
      get next br-parts.
      if available parts
      then do:
        assign
          v-prt-rec = recid (parts)
        .
      end.
      else do:
        reposition br-parts to recid v-prt-rec no-error.
        get prev br-parts.
        assign
          v-prt-rec = recid(parts)
        .
      end.
    end.
    else do:
      lok = no.
      message
        "УДАЛИТЬ ВСЕ ОТМЕЧЕННЫЕ партии?" skip
        "Вы уверены?"
        view-as alert-box question
        buttons OK-Cancel
        update lok.
      if lok <> true
      then do:
        return no-apply.
      end.
      assign
        v-prt-rec = ?
      .
    end.
    define variable lns-cnt as integer no-undo .
    do lns-cnt = 1 to num-entries (del-list):
      run delete-parts in this-procedure
        (input integer (entry (lns-cnt, del-list))
        ) no-error .
    end.
    run reopen-query .
    if b-add:sensitive
    then do:
      apply "entry":u to b-add.
    end.
    else do:
      apply "entry":u to br-parts.
    end.
  end.
END.
ON CHOOSE OF b-doc IN FRAME Dialog-Frame
DO:
define variable vss-include-info31 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if p-call-point = 'документ':U
  then do:
    message
      "Для просмотра документа, к которому относится партия, нажмите Выход."
      view-as alert-box .
  end.
  else do:
    if available parts
    then do:
      if parts.out-code = 'free-zone':U
      then do:
        message
          "Партии свободной зоны не привязаны к документам"
          view-as alert-box .
        return .
      end.
      if parts.out-code = 'out-zone':U
      then do:
        message
          "Партии расходной зоны не привязаны к документам"
          view-as alert-box .
        return .
      end.
      run str/showdoc.p
        (input parparentproc
        ,input ub.parts.out-code
        ,input ub.parts.artic
        ,input ub.parts.prod-type
        ,input ub.parts.prod-code
        ,input ?
        ).
    end.
  end.
  apply "entry":u to br-parts in frame Dialog-Frame.
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
define variable vss-include-info32 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if v-ext-mode = "vsd_corr-parts"
  or v-ext-mode = "corr-parts"
  then do :
    define buffer buf_doc-line for ub.doc-line .
    define buffer buf_trn-doc for ub.trn-doc .
    define buffer buf_goods for ub.goods .
    define buffer doc_parts for ub.parts .
    find first buf_goods no-lock where buf_goods.gds-code = p-gds-code .
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code .
    find first buf_doc-line no-lock
      where buf_doc-line.doc-code  = p-doc-code
        and buf_doc-line.artic     = buf_goods.artic
        and buf_doc-line.prod-type = buf_goods.prod-type
        and buf_doc-line.prod-code = buf_goods.prod-code
    .
    v-sum-parts-qnty = 0 .
    for each doc_parts no-lock where doc_parts.out-code = buf_trn-doc.doc-code
                                 and doc_parts.obj-type = v-cntxt-obj-type
                                 and doc_parts.obj-code = v-cntxt-obj-code
                                 and doc_parts.artic = buf_goods.artic
                                 and doc_parts.prod-type = buf_goods.prod-type
                                 and doc_parts.prod-code = buf_goods.prod-code
    :
      v-sum-parts-qnty = v-sum-parts-qnty + doc_parts.fact-qnty .
    end .
    if buf_doc-line.fact-qnty <> v-sum-parts-qnty
    then do :
      message substitute("Сумма количеств по партиям документа &1 не равна фактическому количеству по строке &2 .", v-sum-parts-qnty, buf_doc-line.fact-qnty) skip
              "Скорректируйте количество по партиям."
      view-as alert-box .
      return no-apply .
    end .
  end .
END.
ON CHOOSE OF b-in IN FRAME Dialog-Frame
DO:
define variable vss-include-info33 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run show-in-code in this-procedure .
END.
ON CHOOSE OF b-income-in-code IN FRAME Dialog-Frame
DO:
define variable vss-include-info34 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  run show-income-in-code in this-procedure .
END.
ON CHOOSE OF b-lkp IN FRAME Dialog-Frame
DO:
  if available parts
  then do:
    do
    on error undo, return no-apply
    on stop undo, return no-apply
    :
      assign
        v-prt-rec = recid(parts)
      .
      if p-doc-code <> ""
      then do:
        if v-reserv-pl-code = ?
        then do:
          message
            "Неизвестно место складирования товара. Просмотр партий невозможен."
            view-as alert-box .
          return no-apply .
        end.
        run str/parts-f.w
          (input        parparentproc
          ,input        this-procedure
          ,input        'ПРОСМОТР':U
          ,input        p-doc-code
          ,input        p-gds-code
          ,input        v-pl-code
          ,input-output v-prt-rec
          ).
      end.
      else do:
        define buffer buf_trn-doc for ub.trn-doc .
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = parts.out-code
          no-error .
        if available buf_trn-doc
        then do:
          run str/parts-f.w
            (input        parparentproc
            ,input        this-procedure
            ,input        'ПРОСМОТР':U
            ,input        buf_trn-doc.doc-code
            ,input        p-gds-code
            ,input        v-pl-code
            ,input-output v-prt-rec
            ).
        end.
        else do:
          message
            "Можно просматривать только архивные партии и" skip
            "партии, зарезервированные за документами" skip
            view-as alert-box information .
        end.
      end.
    end.
  end.
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
define variable vss-include-info35 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if not available parts
  then do:
    message
      "Неправильный выбор партии."
      view-as alert-box .
    return no-apply.
  end.
  define variable v-parts-recid as character no-undo .
  assign
    v-parts-recid = string (recid (parts))
  .
  if lookup( v-parts-recid, del-list ) > 0
  then do:
    assign
      del-list = diff-list(del-list, v-parts-recid, "" )
    .
    disp "" @ mark with browse br-parts.
  end.
  else do:
    assign
      del-list = add-list(del-list, v-parts-recid, "" )
    .
    disp "*" @ mark with browse br-parts.
  end.
  define variable lok as logical no-undo .
  lok = br-parts:select-next-row ().
  apply "entry":u to br-parts in frame Dialog-Frame.
END.
ON CHOOSE OF b-marking IN FRAME Dialog-Frame
DO:
define variable vss-include-info36 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
define variable p-mode as char no-undo.
p-mode = 'ПРОСМОТР':U.
if not available parts then do:
    message
    "Нет партий по товару"
    view-as alert-box.
    return no-apply.
end.
define buffer buf_goods for ub.goods .
define buffer buf_marking-lines for ub.marking-lines .
define buffer buf_marking-lines-parent for ub.marking-lines .
define buffer buf_marking for ub.marking .
find first buf_goods no-lock where buf_goods.artic = parts.artic and buf_goods.prod-code = parts.prod-code and buf_goods.prod-type = parts.prod-type no-error .
if available (buf_goods) then do:
  empty temp-table tt-marking-lines .
    for each buf_marking-lines no-lock where buf_marking-lines.gds-code = buf_goods.gds-code and buf_marking-lines.in-code = parts.in-code and buf_marking-lines.out-code = parts.out-code
      and buf_marking-lines.part-code = parts.part-code and buf_marking-lines.obj-code = parts.obj-code and buf_marking-lines.obj-type = parts.obj-type:
      for each buf_marking no-lock where buf_marking.mark = buf_marking-lines.mark :
        create tt-marking-lines .
        assign
          tt-marking-lines.stts        = StatusTHName(buf_marking.sts)
          tt-marking-lines.gds-name    = buf_goods.gds-name
          tt-marking-lines.mark        = buf_marking.mark
          tt-marking-lines.mark-parent = buf_marking.mark-parent
          tt-marking-lines.gds-code    = buf_marking-lines.gds-code
          tt-marking-lines.sts         = buf_marking.sts
          tt-marking-lines.unit        = buf_marking.unit
          tt-marking-lines.unit-ext    = buf_marking.unit-ext
          tt-marking-lines.box-qnty    = buf_marking.box-qnty
          tt-marking-lines.doc-level   = buf_marking-lines.doc-level
          tt-marking-lines.in-code     = parts.in-code
          tt-marking-lines.out-code    = parts.out-code
          tt-marking-lines.obj-code    = parts.obj-code
          tt-marking-lines.obj-type    = parts.obj-type
          .
          if buf_marking.sts = 10
          then do:
            if buf_marking.mark-parent <> ""
            then do :
              find first buf_marking-lines-parent no-lock where buf_marking-lines-parent.mark = buf_marking.mark-parent
                                                            and buf_marking-lines-parent.gds-code = buf_marking-lines.gds-code
                                                            and buf_marking-lines-parent.obj-type = buf_marking-lines.obj-type
                                                            and buf_marking-lines-parent.obj-code = buf_marking-lines.obj-code
                                                            and buf_marking-lines-parent.in-code  = buf_marking-lines.in-code
                                                            and buf_marking-lines-parent.out-code = buf_marking-lines.out-code
                                                            and buf_marking-lines-parent.part-code = buf_marking-lines.part-code
                                                            and buf_marking-lines-parent.doc-level > 0
                                                            no-error .
              if available buf_marking-lines-parent
              then do :
                tt-marking-lines.doc-level = 2 .
              end .
              else do :
                tt-marking-lines.doc-level = 1 .
              end .
            end .
            else tt-marking-lines.doc-level = 1 .
          end.
      end.
    end.
end.
      run str/mark_browse.w (input parparentproc,
        input-output table tt-marking-lines,
        input "",
        input "Марки по: " + "По партии №" + string (parts.part-code) + " по товару - " + string(buf_goods.gds-code) + " " + string (buf_goods.gds-name),
        input 0,
        input ""
        ) no-error .
END.
ON CHOOSE OF b-pl IN FRAME Dialog-Frame
DO:
define variable vss-include-info37 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  if available parts
  then do:
    run str/pl-lkp.w
      (
       input parparentproc
      ,input recid(parts)
      ) .
    display parts.pl-code with browse br-parts .
  end.
END.
ON CHOOSE OF b-print IN FRAME Dialog-Frame
DO:
  do
  on error undo, return no-apply
  on stop undo,  return no-apply
  :
    apply "home":u to browse br-parts .
    run partsxls.
  end.
END.
ON CHOOSE OF b-quit IN FRAME Dialog-Frame
DO:
define variable vss-include-info38 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define variable v-ok as logical no-undo .
  assign
    v-ok = false
  .
  if v-data-changed = true
  then do:
    message
      "Данные были изменены" skip
      "Вы действительно хотите отказаться от ВСЕХ изменений" skip
      "с момента последнего открытия окна партий?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      return no-apply .
    end.
  end.
  if  v-need-check-diff-qnty = true
  and v-chg-qnty <> 0
  then do:
    message
      "Необходимо создать партии с общим количеством" v-chg-qnty skip
      "Отказ от редактирования партий приведет к тому," skip
      "что не будет зарезервировано необходимое количество товара" skip
      "Вы действительно хотите отказаться от редактирования партий?"
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      return no-apply .
    end.
  end.
END.
ON CHOOSE OF b-sch IN FRAME Dialog-Frame
DO:
define variable vss-include-info39 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  do on stop undo, leave:
    run init-flt in this-procedure .
    run gbl/filter.w (INPUT parparentproc, filter-point, tbl, join-tbl, fld, lab, spr, dim).
    run reopen-query .
  end.
END.
ON CHOOSE OF b-sel IN FRAME Dialog-Frame
DO:
define variable vss-include-info40 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
  define buffer buf_utd for ub.utd .
  define buffer buf_trn-doc for ub.trn-doc .
  if available parts
  then do:
    find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code no-error .
    if available buf_trn-doc
    and buf_trn-doc.reason-code = 25
    then do :
      if not can-find(first buf_utd no-lock where buf_utd.doc-code = parts.in-code)
      then do :
        message 'Для схемы возврата "Корректировка поступления" выбрать можно только партии, принятые по УПД!' view-as alert-box .
        return no-apply .
      end .
    end .
    assign
      part-recid = recid( parts )
    .
  end.
  else do:
    assign
      part-recid = ?
    .
    return no-apply .
  end.
END.
ON CHOOSE OF b-vsd IN FRAME Dialog-Frame
DO:
define variable vss-include-info41 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if lookup(self :type
         ,'BROWSE,FILL-IN,FRAME,BUTTON,RADIO-SET,COMBO-BOX,SELECTION-LIST,CONTROL-FRAME,SLIDER,DIALOG-BOX,TOGGLE-BOX,EDITOR,WINDOW'
         ) = 0
then do:
  message
    "$Workfile$"
    "Указанному интерфейсному элементу фокус не может быть передан" skip
    "Интерфейсный элемент" self :name  skip
    "Тип" self :type  skip
    "Процедура" this-procedure :file-name skip
    view-as alert-box .
end.
else do:
  apply "entry":u to self  .
  if focus :handle <> self :handle  then do:
    return no-apply .
  end.
end.
    define variable ii as integer no-undo.
    define variable isSave as logical no-undo.
    define variable keyrecObj as class keyrec no-undo.
    define variable keypart as character no-undo.
    if not available parts then
    do:
      message
        "Нет партий по товару"
        view-as alert-box.
      return no-apply.
    end.
    vsdStorageObj = new vsdtostorage ().
    vsdSts = new vsdstatustype ().
    keyrecObj = new keyrec ().
    keyrecObj:GenKeyRec('parts':U, buffer parts:handle, output keypart).
    vsdsubsObj = vsdStorageObj:getVSDsubs(input "part-key", input keypart).
    if vsdsubsObj:iCounter = 0
    then do:
      if p-edit-mode = 'ПРОСМОТР':U
      and not (v-vozvr-perem-no-fact and p-doc-code = ub.parts.out-code)
      and not (v-ext-mode = "vsd_corr-parts" or v-ext-mode = "vsd")
      then do:
        message "К партии отсутсвуют ВСД" view-as alert-box.
        return.
      end.
      vsdsubObj = new vsdsub ().
      vsdsubsObj:AddItem(vsdsubObj).
      vsdsubObj = vsdsubsObj:VsdObjCurr.
      vsdsubObj:VSDType = vsdSts:VSDIn.
      vsdsubObj:PartKey = keypart.
      vsdsubObj:GdsCode = p-gds-code.
      vsdsubObj:ObjType = v-obj-type.
      vsdsubObj:ObjCode = v-obj-code.
      find first buf_trn no-lock where buf_trn.doc-code = p-doc-code.
      if available (buf_trn)
      then do:
        vsdsubObj:CliCode = buf_trn.cli-code.
        vsdsubObj:CliType = buf_trn.cli-type.
      end.
    end.
    run str/vsd.w (input parparentproc, input 'ИЗМЕНЕНИЕ':U, input vsdsubsObj, output isSave).
    if isSave then do:
      do ii = 1 to vsdsubsObj:GetItem(ii):
        vsdsubObj = vsdsubsObj:VsdObjCurr.
        if vsdsubObj:Changed
        then do:
          case true:
            when vsdsubObj:ID > 0 then do:
              vsdStorageObj:updateDB(vsdsubObj).
            end.
            otherwise do:
              vsdStorageObj:insertDB(vsdsubObj).
            end.
          end.
        end.
      end.
    end.
    delete object keyrecObj no-error.
    delete object vsdsubsObj no-error.
    find current parts no-lock.
    br-parts:refresh() in frame Dialog-Frame.
    run display-parts-info in this-procedure .
    apply "entry":u to br-parts.
END.
ON MOUSE-SELECT-DBLCLICK OF br-parts IN FRAME Dialog-Frame
DO:
  if b-chg:sensitive then apply "choose" to b-chg in frame Dialog-Frame.
END.
ON RETURN OF br-parts IN FRAME Dialog-Frame
DO:
  if b-chg:sensitive then apply "choose" to b-chg in frame Dialog-Frame.
END.
ON ROW-DISPLAY OF br-parts IN FRAME Dialog-Frame
DO:
  define buffer buf_utd for ub.utd .
  define buffer buf_trn-doc for ub.trn-doc .
  define variable ic      as integer   no-undo.
  if parts.defect = logical('yes':U) then do:
     parts-part-code:bgcolor in browse br-parts = 12.
  end.
  else do:
     parts-part-code:bgcolor in browse br-parts = ? .
  end.
  find first buf_trn-doc no-lock where buf_trn-doc.doc-code = p-doc-code no-error .
  if available buf_trn-doc
  and buf_trn-doc.reason-code = 25
  then do :
    if not can-find(first buf_utd no-lock where buf_utd.doc-code = parts.in-code)
    then do :
      do ic = 1 to extent (bcol) :
        if valid-handle (bcol[ic])
        then
          bcol[ic]:bgcolor = 7
        .
      end.
    end .
  end .
END.
ON VALUE-CHANGED OF br-parts IN FRAME Dialog-Frame
DO:
  run display-parts-info .
END.
ON ENTRY OF ed-notes IN FRAME Dialog-Frame
DO:
  if not available parts
  then do:
    message
      "Неправильный выбор партии."
      view-as alert-box .
    return no-apply.
  end.
  assign
    v-prt-rec = recid (parts)
  .
END.
ON LEAVE OF ed-notes IN FRAME Dialog-Frame
DO:
  define buffer buf_parts for ub.parts .
  do on stop undo, return no-apply:
    find buf_parts where recid (buf_parts) = v-prt-rec exclusive-lock.
    buf_parts.PS = input frame Dialog-Frame ed-notes.
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF ed-notes IN FRAME Dialog-Frame
DO:
  apply "entry":u to br-parts in frame Dialog-Frame.
  return no-apply.
END.
ON RETURN OF ed-notes IN FRAME Dialog-Frame
DO:
  apply "entry":u to br-parts in frame Dialog-Frame.
  return no-apply.
END.
ON VALUE-CHANGED OF R-find IN FRAME Dialog-Frame
DO:
  ASSIGN r-find .
END.
ON VALUE-CHANGED OF rs-one-all IN FRAME Dialog-Frame
DO:
  if available parts
  then do:
    assign
      v-prt-rec = recid(parts)
    .
  end.
  assign rs-one-all .
  run reopen-query .
END.
ON VALUE-CHANGED OF rs-parts IN FRAME Dialog-Frame
DO:
  if available parts
  then do:
    assign
      v-prt-rec = recid(parts)
    .
  end.
  if input frame Dialog-Frame rs-parts = 'документ':U
  and p-call-point = 'справочник':U
  then do:
    message
      "Нет документа"
      view-as alert-box .
    display
      rs-parts
      with frame Dialog-Frame.
    return no-apply.
  end.
  assign
    rs-parts
  .
  run reopen-query .
END.
ON RETURN OF s-code IN FRAME Dialog-Frame
DO:
  define variable v-find-next as logical   no-undo .
  if s-code <> input frame Dialog-Frame s-code
  then do:
    assign
      v-find-next = false
    .
  end.
  else do:
    assign
      v-find-next = true
    .
  end.
  do with frame Dialog-Frame:
    assign
      s-code
    .
  end.
  define buffer buf_bar-code for ub.bar-code .
  define buffer buf_goods    for ub.goods    .
  define buffer buf_parts    for ub.parts    .
  if  r-find = 2 then do:
      find first buf_bar-code no-lock
        where buf_bar-code.b-code = int( s-code)
        no-error .
      if available buf_bar-code
      then do:
        find first buf_goods no-lock
          where buf_goods.gds-code = buf_bar-code.gds-code
          .
        if buf_bar-code.gds-code <> p-gds-code
        then do:
          message
            "Бар-код" buf_bar-code.b-code skip
            "Вы задали бар-код партии для другого товара" skip
            "Вы просматриваете партии товара с кодом" p-gds-code skip
            "Вы задали бар-код товара с кодом" buf_bar-code.gds-code skip
            "и артикулом" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
            view-as alert-box .
          return no-apply .
        end.
        run UI-on in this-procedure
          (input false
          ,input v-find-next
          ,input substitute("and parts.in-code = '&1' and parts.part-code = '&2'"
          , buf_bar-code.in-code
          , buf_bar-code.part-code)
          ).
        apply "entry":u to self .
        return no-apply .
      end.
      message
        "Бар-код не найден !"
        view-as alert-box .
   end.
   else do:
           run UI-on in this-procedure
          (input false
          ,input v-find-next
          ,input substitute("and parts.part-code = '&1'"
          , s-code )
          ).
        apply "entry":u to self .
   end.
   return no-apply .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame Dialog-Frame
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame Dialog-Frame
do:
  apply "help":u to frame Dialog-Frame .
end.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame Dialog-Frame:width - 0.3
                fh            = frame Dialog-Frame:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
define variable v-diasize-need-maximize        as logical   no-undo init true  .
define variable v-diasize-orig-frame-height    as decimal   no-undo .
define variable v-diasize-orig-frame-width     as decimal   no-undo .
define variable v-diasize-current-frame-width  as decimal   no-undo .
define variable v-diasize-current-frame-height as decimal   no-undo .
define variable v-diasize-change-size          as logical   no-undo .
define variable v-diasize-resize-button        as handle    no-undo .
define variable v-diasize-wndmax               as logical   no-undo .
define variable v-diasize-wndstore             as logical   no-undo .
define variable v-diasize-proc-name            as character no-undo .
define variable v-diasize-browse-handle        as handle    no-undo .
define variable v-diasize-browse-number        as integer   no-undo .
define variable v-diasize-need-full-display    as logical   no-undo init false .
define temp-table temp-diasize-handle no-undo
  field handle-value  as handle
  field save-position as decimal
  index xpk is primary unique handle-value
  .
define temp-table temp-browse-handle no-undo
  field browse-type   as character
  field browse-number as integer
  field browse-handle as handle
  field original-size as decimal
  index xpk is primary unique browse-type browse-number
  index xie browse-type browse-handle
.
procedure diasize_change-height :
  define input  parameter p-change-value  as decimal   no-undo .
  define input  parameter p-move-resize   as logical   no-undo .
  define variable v-field-group-handle    as handle    no-undo .
  define variable v-object-handle         as handle    no-undo .
  define variable v-frame-height          as decimal   no-undo .
  define variable v-frame-virtual-height  as decimal   no-undo .
  define variable v-browse-height         as decimal   no-undo .
  define variable v-window-height         as decimal   no-undo .
  define variable v-window-virtual-height as decimal   no-undo .
  define variable v-change-sign           as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame Dialog-Frame :height-chars)
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame Dialog-Frame :height-chars)
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, retry move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame Dialog-Frame :height = v-frame-height
          .
          assign
            v-diasize-browse-handle :height = v-browse-height
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'height':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :height = buf_temp-browse-handle.original-size
            .
          end.
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :row = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-height = frame Dialog-Frame :height
      v-frame-virtual-height = frame Dialog-Frame :virtual-height
      v-browse-height = v-diasize-browse-handle :height
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'height':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :height
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :row > v-diasize-browse-handle :row )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'height':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :row
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :row = v-object-handle :row + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      assign
        v-diasize-browse-handle :height = v-diasize-browse-handle :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'height':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :height
            = buf_temp-browse-handle.browse-handle :height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame Dialog-Frame :height = frame Dialog-Frame :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-height = frame Dialog-Frame :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
    end.
    if p-move-resize = true
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'height':u
          ,input  string(frame Dialog-Frame :height - v-diasize-orig-frame-height)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-height :
  define input  parameter p-new-height  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-height in this-procedure
      (input  (p-new-height - frame Dialog-Frame :height)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_change-width :
  define input  parameter p-change-value as decimal   no-undo .
  define input  parameter p-move-resize  as logical   no-undo .
  define variable v-field-group-handle   as handle    no-undo .
  define variable v-object-handle        as handle    no-undo .
  define variable v-frame-width          as decimal   no-undo .
  define variable v-frame-virtual-width  as decimal   no-undo .
  define variable v-browse-width         as decimal   no-undo .
  define variable v-window-width         as decimal   no-undo .
  define variable v-window-virtual-width as decimal   no-undo .
  define variable v-change-sign          as integer   no-undo .
  define buffer buf_temp-diasize-handle for temp-diasize-handle .
  define buffer buf_temp-browse-handle  for temp-browse-handle .
  if p-change-value > 0
  then do:
    if frame Dialog-Frame :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame Dialog-Frame :width
      .
      if p-change-value <= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value < 0
  then do:
    if frame Dialog-Frame :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame Dialog-Frame :width
      .
      if p-change-value >= 0
      then do:
        run diasize_position-resize-button in this-procedure .
        return .
      end.
    end.
  end.
  if p-change-value >= 0
  then do:
    assign
      v-change-sign = 1
    .
  end.
  else do:
    assign
      v-change-sign = -1
    .
  end.
  assign
    p-change-value = truncate(abs(p-change-value), 0) * v-change-sign
  .
  if p-change-value = 0
  then do:
    run diasize_position-resize-button in this-procedure .
    return .
  end.
  move_block:
  do
  on error undo move_block, leave move_block
  :
    if retry
    then do:
      do
      on error undo move_block, leave move_block
      :
        if p-change-value > 0
        then do:
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame Dialog-Frame :scrollable = true
          then do:
            assign
              frame Dialog-Frame :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame Dialog-Frame :width = v-frame-width
          .
          for each buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type = 'width':u
          on error undo, next
          :
            assign
              buf_temp-browse-handle.browse-handle :width = buf_temp-browse-handle.original-size
            .
          end.
          assign
            v-diasize-browse-handle :width = v-browse-width
          .
          for each buf_temp-diasize-handle
          on error undo, next
          :
            assign
              v-object-handle = buf_temp-diasize-handle.handle-value
            .
            if v-object-handle <> v-diasize-resize-button
            then do:
              assign
                v-object-handle :col = buf_temp-diasize-handle.save-position
              .
            end.
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        assign
          v-diasize-change-size = false
        .
        leave move_block .
      end.
    end.
    assign
      v-diasize-need-full-display = true
    .
    if v-diasize-change-size = false
    then do:
      assign
        v-diasize-change-size = true
      .
    end.
    else do:
      return .
    end.
    assign
      v-frame-width = frame Dialog-Frame :width
      v-frame-virtual-width = frame Dialog-Frame :virtual-width
      v-browse-width = v-diasize-browse-handle :width
    .
    for each buf_temp-browse-handle
      where buf_temp-browse-handle.browse-type = 'width':u
    :
      assign
        buf_temp-browse-handle.original-size = buf_temp-browse-handle.browse-handle :width
      .
    end.
    for each buf_temp-diasize-handle
    :
      delete buf_temp-diasize-handle .
    end.
    assign
      v-field-group-handle = frame Dialog-Frame :first-child
    .
    do while valid-handle(v-field-group-handle)
    :
      assign
        v-object-handle = v-field-group-handle :first-child
      .
      do while valid-handle(v-object-handle)
      :
        if  v-object-handle <> v-diasize-browse-handle :handle
        and v-object-handle <> v-diasize-resize-button
        and can-query(v-object-handle, "row")
        and can-query(v-object-handle, "height")
        and ( v-object-handle :col + v-object-handle :width
              > v-diasize-browse-handle :col + v-diasize-browse-handle :width
            )
        then do:
          find first buf_temp-browse-handle
            where buf_temp-browse-handle.browse-type   = 'width':u
              and buf_temp-browse-handle.browse-handle = v-object-handle
            no-error .
          if available buf_temp-browse-handle
          then do:
          end.
          else do:
            create buf_temp-diasize-handle .
            assign
              buf_temp-diasize-handle.handle-value  = v-object-handle
              buf_temp-diasize-handle.save-position = v-object-handle :col
            .
          end.
        end.
        assign
          v-object-handle = v-object-handle :next-sibling
        .
      end.
      assign
        v-field-group-handle = v-field-group-handle :next-sibling
      .
    end.
    do with frame Dialog-Frame
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame Dialog-Frame :width = v-frame-width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        v-diasize-browse-handle :width = v-browse-width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
    end.
    else do:
      for each buf_temp-diasize-handle
      on error undo move_block, retry move_block
      :
        assign
          v-object-handle = buf_temp-diasize-handle.handle-value
        .
        if v-object-handle <> v-diasize-resize-button
        then do:
          assign
            v-object-handle :col = v-object-handle :col + p-change-value
            no-error .
          if error-status :error
          or error-status :get-message(1) <> ""
          then do:
            undo move_block, retry move_block .
          end.
        end.
      end.
      for each buf_temp-browse-handle
        where buf_temp-browse-handle.browse-type = 'width':u
      on error undo move_block, retry move_block
      :
        assign
          buf_temp-browse-handle.browse-handle :width
            = buf_temp-browse-handle.browse-handle :width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        v-diasize-browse-handle :width = v-diasize-browse-handle :width + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      assign
        frame Dialog-Frame :width = frame Dialog-Frame :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame Dialog-Frame :scrollable = true
      then do:
        assign
          frame Dialog-Frame :virtual-width = frame Dialog-Frame :virtual-width + p-change-value
        no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
    end.
    if p-move-resize
    then do:
      run diasize_position-resize-button in this-procedure .
    end.
    if v-diasize-wndstore = true
    then do:
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndsizew.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  v-diasize-proc-name
          ,input  'width':u
          ,input  string(frame Dialog-Frame :width - v-diasize-orig-frame-width)
          ) .
      end.
    end.
  end.
  assign
    v-diasize-change-size = false
  .
end procedure.
procedure diasize_set-width :
  define input  parameter p-new-width  as decimal   no-undo .
  define input  parameter p-move-resize as logical   no-undo .
  do
  on error undo, return error return-value
  :
    run diasize_change-width in this-procedure
      (input  (p-new-width - frame Dialog-Frame :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame Dialog-Frame
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame Dialog-Frame :height - v-diasize-resize-button :height
                  - 1
                  - (frame Dialog-Frame :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame Dialog-Frame :width - v-diasize-resize-button :width
                  - 1
                  - (frame Dialog-Frame :border-right-pixels / session :pixels-per-column)
    .
    view v-diasize-resize-button .
  end.
end procedure.
on alt-right anywhere
do:
  run diasize_change-width in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-left anywhere
do:
  run diasize_change-width in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-down anywhere
do:
  run diasize_change-height in this-procedure
    (input 1
    ,input true
    ) .
  return no-apply .
end.
on alt-up anywhere
do:
  run diasize_change-height in this-procedure
    (input -1
    ,input true
    ) .
  return no-apply .
end.
on alt-enter of frame Dialog-Frame
do:
  run diasize_maximize in this-procedure
    (input  ?
    ).
  return no-apply .
end.
procedure diasize_end-move :
  do
  on error undo, return error return-value
  :
    define variable v-row-delta as decimal   no-undo .
    define variable v-col-delta as decimal   no-undo .
    define variable v-new-row as decimal   no-undo .
    define variable v-new-col as decimal   no-undo .
    assign
      v-new-row = decimal(last-event :y) / (session :pixels-per-row)
      v-new-col = decimal(last-event :x) / (session :pixels-per-column)
    .
    assign
      v-row-delta = v-new-row - frame Dialog-Frame :height
      v-col-delta = v-new-col - frame Dialog-Frame :width
    .
    run diasize_change-height in this-procedure
      (input v-row-delta
      ,input true
      ) .
    run diasize_change-width in this-procedure
      (input v-col-delta
      ,input true
      ) .
  end.
end procedure.
procedure diasize_maximize :
  define input  parameter p-action as logical   no-undo .
  do
  on error undo, return error return-value
  :
    if p-action = ?
    then do:
      if v-diasize-need-maximize = true
      then do:
        assign
          p-action = true
        .
      end.
      else do:
        assign
          p-action = false
        .
      end.
    end.
    if p-action = true
    then do:
      run diasize_change-height in this-procedure
        (input decimal(session :work-area-height-pixels) / session :pixels-per-row
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame Dialog-Frame :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame Dialog-Frame :height-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = true
      .
    end.
  end.
end procedure.
procedure diasize_restore-orig-size :
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-current-frame-width  = frame Dialog-Frame :width
      v-diasize-current-frame-height = frame Dialog-Frame :height
    .
    run diasize_set-height in this-procedure
      (input  v-diasize-orig-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-orig-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_restore-current-size :
  do
  on error undo, return error return-value
  :
    run diasize_set-height in this-procedure
      (input  v-diasize-current-frame-height
      ,input  true
      ) .
    run diasize_set-width in this-procedure
      (input  v-diasize-current-frame-width
      ,input  true
      ) .
  end.
end procedure.
procedure diasize_set-browse-handle :
  define input  parameter p-browse-handle as handle   no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-handle = p-browse-handle
    .
    for each buf_temp-browse-handle
    on error undo, return error return-value
    :
      delete buf_temp-browse-handle .
    end.
  end.
end procedure.
procedure diasize_add_browse :
  define input  parameter p-browse-type   as character no-undo .
  define input  parameter p-browse-handle as handle    no-undo .
  define buffer buf_temp-browse-handle for temp-browse-handle .
  do
  on error undo, return error return-value
  :
    assign
      v-diasize-browse-number = v-diasize-browse-number + 1
    .
    create buf_temp-browse-handle .
    assign
      buf_temp-browse-handle.browse-type   = p-browse-type
      buf_temp-browse-handle.browse-number = v-diasize-browse-number
      buf_temp-browse-handle.browse-handle = p-browse-handle
    .
  end.
end procedure.
procedure diasize_init :
  define variable v-default-value    as logical   no-undo .
  define variable v-restore-saved    as logical   no-undo .
  define variable v-resize-value-str as character no-undo .
  do
  on error undo, return error return-value
  :
    do with frame Dialog-Frame
    :
      assign
        v-diasize-orig-frame-height = frame Dialog-Frame :height
        v-diasize-orig-frame-width  = frame Dialog-Frame :width
        v-diasize-browse-handle     = browse br-parts :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame Dialog-Frame :first-child
        label         = "s"
        height-pixels = 16
        width-pixels  = 16
        visible       = true
        sensitive     = true
        movable       = true
        triggers:
          on end-move persistent run diasize_end-move in this-procedure .
        end triggers.
      v-diasize-resize-button :load-mouse-pointer("SIZE") .
      v-diasize-resize-button :load-image("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-down("exe/grip.bmp":U) .
      v-diasize-resize-button :load-image-insensitive("exe/grip.bmp":U) .
      assign
        v-diasize-wndmax = false
      .
      if connected("ub") = true
      then do:
        define variable v-cntxt-db-num        as integer   no-undo .
        define variable v-cntxt-userid        as character no-undo .
        RUN get-context in this-procedure ( OUTPUT v-cntxt-db-num
                                          , OUTPUT v-cntxt-userid
                                          ) .
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndmax':U
          ,output v-diasize-wndmax
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-wndstore = false
      .
      if connected("ub") = true
      then do:
        run gbl/wndpar_r.p
          (input  v-cntxt-db-num
          ,input  v-cntxt-userid
          ,input  'wndstore':U
          ,output v-diasize-wndstore
          ,output v-default-value
          ) .
      end.
      assign
        v-diasize-proc-name = entry(1, program-name(2), '.')
      .
      if v-diasize-wndstore = true
      then do:
        assign
          v-restore-saved = false
        .
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'height':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-height in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if connected("ub") = true
        then do:
          run gbl/wndsizer.p
            (input  v-cntxt-db-num
            ,input  v-cntxt-userid
            ,input  v-diasize-proc-name
            ,input  'width':u
            ,output v-resize-value-str
            ) .
          if v-resize-value-str <> '':U
          then do:
            run diasize_change-width in this-procedure
              (input  integer(v-resize-value-str)
              ,input  true
              ) .
            assign
              v-restore-saved = true
            .
          end.
        end.
        if v-restore-saved <> true
        then do:
          if v-diasize-wndmax = true
          then do:
            run diasize_maximize in this-procedure
              (input  true
              ) .
          end.
        end.
      end.
      else do:
        if v-diasize-wndmax = true
        then do:
          run diasize_maximize in this-procedure
            (input  true
            ) .
        end.
      end.
    end.
  end.
end procedure.
procedure diasize_need-full-display :
  define output parameter p-need-full-display as logical   no-undo .
  do
  on error undo, return error return-value
  :
    assign
      p-need-full-display = v-diasize-need-full-display
    .
    assign
      v-diasize-need-full-display = false
    .
  end.
end procedure.
procedure get-context :
   define output parameter p-db-num as integer          no-undo.
   define output parameter p-user-id as character        no-undo.
   define variable v-login               as character    no-undo.
   define buffer buf_sys-ctrl    for ub.sys-ctrl .
   define buffer buf_user-login  for ub.user-login .
   do
   on error undo, return error
   :
         FIND FIRST buf_sys-ctrl no-lock.
         ASSIGN
            v-login = USERID("ub")
            p-db-num = buf_sys-ctrl.db-num
         .
         FIND FIRST buf_user-login
              WHERE buf_user-login.db-num = p-db-num
                AND buf_user-login.user-login = v-login
              no-lock
              no-error
              .
         IF AVAILABLE buf_user-login
         THEN DO:
            assign
               p-user-id = buf_user-login.user-id
            .
         END.
   end.
end procedure.
    run diasize_init in this-procedure .
Marking = new mark() .
on f9 of frame Dialog-Frame anywhere
do:
  run str/showgds.p
    (input parparentproc
    ,input this-procedure
    ,input p-gds-code
    ,input 'ПРОСМОТР':U
    ) .
  return no-apply .
end.
define variable vss-include-info45 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on CTRL-N, CTRL-Т of frame Dialog-Frame anywhere do:
  if b-add :sensitive then DO: apply "CHOOSE":U to b-add in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F4 of frame Dialog-Frame anywhere do:
  if b-chg :sensitive then DO: apply "CHOOSE":U to b-chg in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info47 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F8 of frame Dialog-Frame anywhere do:
  if b-del :sensitive then DO: apply "CHOOSE":U to b-del in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info48 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  br-parts :SET-REPOSITIONED-ROW(6, "CONDITIONAL") .
end.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  run reopen-query in this-procedure .
    apply "VALUE-CHANGED" to br-parts.
end.
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = frame Dialog-Frame:title + "   ФИЛЬТР: " + p-filter-name.
      .
      assign
        b-sch :tooltip = "Установлен фильтр " + p-filter-name
      .
    end.
    else do:
      assign
        b-sch :tooltip = ""
      .
    end.
  end.
end procedure.
run check-input-parameters in this-procedure
  no-error .
if error-status :error
then do:
  if error-status :get-message(1) <> ""
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при проверке входных параметров" skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
  end.
  undo, return error return-value .
end.
define variable v-pharm  as logical   no-undo .
define variable v-attr-value as character no-undo .
define variable v-attr-type as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-pharm'
  ,input  ''
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-attr-value
  ,output v-attr-type
  ) no-error .
    if error-status :error
    then do:
      v-pharm = false .
    end.
    else do:
       if lookup(v-attr-value, "true,yes") > 0 then do:
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$workfile: $ $revision: $".
define variable v-o-pharm    as character no-undo .
define variable v-o-var-type as character no-undo .
  run clntattr-value in this-procedure
    ( input   v-cntxt-obj-type ,
      input   v-cntxt-obj-code ,
      input  'pharm':U,
      output v-o-pharm    ,
      output v-o-var-type )
     no-error .
  if v-o-pharm <> "yes":u or error-status :error then do:
     v-attr-value = "no"  .
  end.
       end.
      assign
        v-pharm = lookup(v-attr-value, "true,yes") > 0
      .
    end.
assign
  parts.qnty      :read-only in browse br-parts = true
  parts.fact-qnty :read-only in browse br-parts = true
  vprice-prod1 :visible   in browse br-parts = v-pharm
  vprice-prod2 :visible   in browse br-parts = v-pharm
.
ON alt-shift-F6 anywhere
do:
  if available parts
  then do:
    define variable v-parts-gds-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pargocod in g#library
  (input  recid(parts)
  ,output v-parts-gds-code
  )  .
    define buffer buf_parts-attr for ub.parts-attr .
    find first buf_parts-attr no-lock
      where buf_parts-attr.in-code   = parts.in-code
        and buf_parts-attr.gds-code  = v-parts-gds-code
        and buf_parts-attr.part-code = parts.part-code
      no-error .
    if available buf_parts-attr
    then do:
      run str/paratrsh.p
        (input recid(buf_parts-attr)
        ) .
    end.
  end.
end.
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
DEF VAR cur-clmn-numbr-parts as INT EXTENT 22 no-undo.
DEF VAR varmvibr-parts       as INT no-undo.
DEF VAR varmvjbr-parts       as INT no-undo.
DEF VAR varmvkbr-parts       as INT no-undo.
DEF VAR varmvlbr-parts       as INT no-undo.
DEF VAR move-elementbr-parts as INT no-undo.
def var jjbr-parts           as int no-undo.
do varmvibr-parts = 1 to EXTENT(cur-clmn-numbr-parts):
  ASSIGN cur-clmn-numbr-parts[varmvibr-parts] = varmvibr-parts.
END.
RUN start-mv-clmnbr-parts.
PROCEDURE start-mv-clmnbr-parts:
def var old-session as logical no-undo.
   old-session = SESSION:IMMEDIATE-DISPLAY.
   IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
   SESSION:IMMEDIATE-DISPLAY = old-session.
END.
ON ctrl-cursor-right OF BROWSE br-parts do:
  RUN re-move-clmnbr-parts ( 4, 22).
END.
ON ctrl-cursor-left OF BROWSE br-parts do:
  RUN re-move-clmnbr-parts (22, 4).
END.
PROCEDURE re-move-clmnbr-parts:
  DEFINE INPUT PARAMETER source-column as INTEGER NO-UNDO.
  DEFINE INPUT PARAMETER target-column as INTEGER NO-UNDO.
  DO varmvibr-parts = 1 TO EXTENT(cur-clmn-numbr-parts):
    if cur-clmn-numbr-parts[varmvibr-parts] = source-column THEN cur-clmn-numbr-parts[varmvibr-parts] = -1.
  END.
  if br-parts:MOVE-COLUMN(source-column, target-column) IN FRAME Dialog-Frame then.
  if source-column > target-column THEN
  DO varmvjbr-parts = source-column - 1 to target-column BY -1:
    DO varmvibr-parts = 1 TO EXTENT(cur-clmn-numbr-parts):
        if cur-clmn-numbr-parts[varmvibr-parts] = varmvjbr-parts THEN DO:
          cur-clmn-numbr-parts[varmvibr-parts] = cur-clmn-numbr-parts[varmvibr-parts] + 1.
        END.
    END.
  END.
  ELSE
  DO varmvjbr-parts = source-column + 1 to target-column:
    DO varmvibr-parts = 1 TO EXTENT(cur-clmn-numbr-parts):
      if cur-clmn-numbr-parts[varmvibr-parts] = varmvjbr-parts THEN DO:
        cur-clmn-numbr-parts[varmvibr-parts] = cur-clmn-numbr-parts[varmvibr-parts] - 1.
      END.
    END.
  END.
  DO varmvibr-parts = 1 TO EXTENT(cur-clmn-numbr-parts):
    if cur-clmn-numbr-parts[varmvibr-parts] = -1 THEN cur-clmn-numbr-parts[varmvibr-parts] = target-column.
  END.
END PROCEDURE.
PROCEDURE ch-clmnbr-parts:
  DEFINE INPUT PARAMETER cur-clmn-loc as INTEGER NO-UNDO.
  if cur-clmn-loc <= 4 then do:
    return .
  end.
  DO varmvibr-parts = 1 TO EXTENT(cur-clmn-numbr-parts):
    if cur-clmn-numbr-parts[varmvibr-parts] = cur-clmn-loc THEN move-elementbr-parts = varmvibr-parts.
  END.
  RUN re-move-clmnbr-parts (cur-clmn-loc, 4).
END PROCEDURE.
PROCEDURE mv-brw-defaultbr-parts:
def var old-session as logical no-undo.
  old-session = SESSION:IMMEDIATE-DISPLAY.
  IF old-session = YES THEN SESSION:IMMEDIATE-DISPLAY = NO.
  do varmvlbr-parts = 4 to EXTENT(cur-clmn-numbr-parts):
    RUN re-move-clmnbr-parts (cur-clmn-numbr-parts[varmvlbr-parts], varmvlbr-parts).
  END.
  RUN start-mv-clmnbr-parts.
  SESSION:IMMEDIATE-DISPLAY = old-session.
END PROCEDURE.
.
def var sort-labelbr-parts   as character no-undo .
def var sort-clmnbr-parts    as handle    no-undo .
def var cur-clmnbr-parts     as handle    no-undo .
def var cur-clmn-locbr-parts as integer   no-undo .
def var re-querybr-parts     as logical   initial no no-undo .
on start-search, ctrl-o of br-parts in frame Dialog-Frame do:
   run sort-brbr-parts
     (input (if available parts
             then recid(parts)
             else ?
            )
     ).
end.
PROCEDURE sort-brbr-parts :
  define input parameter p-recid as recid no-undo .
  if re-querybr-parts = no then do:
    assign
       cur-clmnbr-parts = br-parts:current-column in frame Dialog-Frame
    .
    if sort-clmnbr-parts <> ? then sort-clmnbr-parts:column-fgcolor = 0.
    if cur-clmnbr-parts = sort-clmnbr-parts then do:
      assign
         sort-labelbr-parts = ""
         sort-clmnbr-parts = ?
      .
     end.
     else do:
       assign
         sort-labelbr-parts = cur-clmnbr-parts:label
         sort-clmnbr-parts  = cur-clmnbr-parts
         sort-clmnbr-parts:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbr-parts = 1
  .
  def var column-handle as handle no-undo .
  column-handle = br-parts:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbr-parts then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbr-parts = cur-clmn-locbr-parts + 1
    .
  end.
  case sort-labelbr-parts:
        when parts-out-code:label in browse br-parts then DO:    assign       sort-column-name = "parts-out-code"     .     run reopen-query.   . END.
        when parts.qnty:label in browse br-parts then DO:    assign       sort-column-name = "parts.qnty"     .     run reopen-query.   . END.
        when parts.fact-qnty:label in browse br-parts then DO:    assign       sort-column-name = "parts.fact-qnty"     .     run reopen-query.   . END.
        when parts.price-base:label in browse br-parts then DO:    assign       sort-column-name = "parts.price-base"     .     run reopen-query.   . END.
        when parts.price-rubl:label in browse br-parts then DO:    assign       sort-column-name = "parts.price-rubl"     .     run reopen-query.   . END.
        when parts.transport-base:label in browse br-parts then DO:    assign       sort-column-name = "parts.transport-base"     .     run reopen-query.   . END.
        when parts.transport-rubl:label in browse br-parts then DO:    assign       sort-column-name = "parts.transport-rubl"     .     run reopen-query.   . END.
        when parts.road-tax-base:label in browse br-parts then DO:    assign       sort-column-name = "parts.road-tax-base"     .     run reopen-query.   . END.
        when parts.road-tax-rubl:label in browse br-parts then DO:    assign       sort-column-name = "parts.road-tax-rubl"     .     run reopen-query.   . END.
        when parts.other-base:label in browse br-parts then DO:    assign       sort-column-name = "parts.other-base"     .     run reopen-query.   . END.
        when parts.other-rubl:label in browse br-parts then DO:    assign       sort-column-name = "parts.other-rubl"     .     run reopen-query.   . END.
        when parts.cst-code:label in browse br-parts then DO:    assign       sort-column-name = "parts.cst-code"     .     run reopen-query.   . END.
        when parts.pl-code:label in browse br-parts then DO:    assign       sort-column-name = "parts.pl-code"     .     run reopen-query.   . END.
        when parts-object:label in browse br-parts then DO:    assign       sort-column-name = "parts-object"     .     run reopen-query.   . END.
        when parts-part-code:label in browse br-parts then DO:    assign       sort-column-name = "parts-part-code"     .     run reopen-query.   . END.
        when parts.in-code:label in browse br-parts then DO:    assign       sort-column-name = "parts.in-code"     .     run reopen-query.   . END.
        when 'Дата ист.'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1get-in-code-dates&1,(recid(parts)))',chr(34))     .     run reopen-query.   . END.
        when 'Договор'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1get-contract-prn-code&1,(recid(parts)))',chr(34))     .     run reopen-query.   . END.
        when 'Тек.прод.цена'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1get-price-sale&1,(recid(parts)))',chr(34))     .     run reopen-query.   . END.
        when 'Цена Произв.'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1get-price-prod1&1,(recid(parts)))',chr(34))     .     run reopen-query.   . END.
        when 'Цена Прзв_с_НДС'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1get-price-prod2&1,(recid(parts)))',chr(34))     .     run reopen-query.   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run reopen-query.
      if sort-labelbr-parts <> "" then do:
        assign
          cur-clmnbr-parts:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbr-parts = ?
      .
    end.
  end case.
    if cur-clmn-locbr-parts <> ? then do:
      if can-do( this-procedure:internal-entries, 'ch-clmnbr-parts') then do:
        run ch-clmnbr-parts in this-procedure (cur-clmn-locbr-parts).
      end.
    end.
  if p-recid <> ? then do:
    reposition br-parts to recid p-recid no-error.
    apply "value-changed" to br-parts in frame Dialog-Frame.
  end.
  apply "entry" to br-parts in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbr-parts:
if cur-clmnbr-parts = ? then do:
   run reopen-query.
end.
else do:
   assign re-querybr-parts = yes.
   run sort-brbr-parts
     (input (if available parts
             then recid(parts)
             else ?
            )
     ).
   assign re-querybr-parts = no.
end.
end.
if p-edit-mode = "vsd_corr-parts"
or p-edit-mode = "vsd"
or p-edit-mode = "corr-parts"
then do :
  v-ext-mode = p-edit-mode .
  p-edit-mode = 'ПРОСМОТР':U .
end .
assign
  v-mode-name = (if p-edit-mode = 'update-alc-attr':u
                 then "Корректировка алкогольных атрибутов"
                 else p-edit-mode
                )
.
if retry then do:
  message
    "Возникла ошибка при работе программы" skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error return-value .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  p-gds-code
  ,input  'twounit=request':u
  ,output v-goods-twounit
  ) no-error .
if error-status :error
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка при определении атрибута товара gdscdat.i" skip
    "Атрибут товара" 'twounit=request':u skip
    "Код товара" p-gds-code skip
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error .
  undo, return error return-value .
end.
  RUN gds-attr-value (
                        INPUT p-gds-code,
                        INPUT 'mark-type':U,
                        OUTPUT v-marking-value,
                        OUTPUT v-marking-type
                        ).
if not error-status:error and v-marking-value <> "" then
  v-marking = true .
    define variable v-alcohol-value as character no-undo .
    define variable v-alcohol-type  as character no-undo .
    define variable v-alcohol-prod as logical.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'alcohol':u
  ,input  0
  ,input  ''
  ,input  0
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output v-alcohol-value
  ,output v-alcohol-type
  ) no-error .
    if  not error-status :error
    and lookup(v-alcohol-value, 'true,yes':u) > 0
    then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  p-gds-code
  ,input  'alcohol-prod=request':u
  ,output v-alcohol-prod
  ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при определении атрибута товара" skip
          "Код товара" p-gds-code skip
          'alcohol-prod=request':u skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo, return error .
      end.
    end.
    else do:
      assign
        v-alcohol-prod = false
      .
    end.
    define variable v-mercury-value as character no-undo .
    define variable v-mercury-type  as character no-undo .
    define variable v-mercury-prod as logical init false.
    define buffer buf_trn-doc for ub.trn-doc .
    find first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = p-doc-code no-error
      .
    v-vozvr-perem-no-fact = false.
    if p-doc-code = ? or p-doc-code = "" or (buf_trn-doc.ext-doc-type = 'ie':U or  buf_trn-doc.ext-doc-type = 'iv':U  or  buf_trn-doc.ext-doc-type = 'rv':U)
    then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'mercuri':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-mercury-value
  ,output v-mercury-type
  ) no-error .
      if  not error-status :error
      and lookup(v-mercury-value, 'no':u) = 0
      then do:
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  p-gds-code
  ,input  'mercur_FGIS=request':u
  ,output v-mercury-prod
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при определении атрибута товара" skip
            "Код товара" p-gds-code skip
            'mercur_FGIS=request':u skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        if available (buf_trn-doc) and buf_trn-doc.ext-doc-type = 'rv':U and buf_trn-doc.status_ <> 'факт':U
        then
          v-vozvr-perem-no-fact = true.
      end.
      else do:
        assign
          v-mercury-prod = false
        .
      end.
    end.
if  p-call-point = 'документ':U
and (p-edit-mode = 'ИЗМЕНЕНИЕ':U
     or p-edit-mode = 'ДОБАВЛЕНИЕ':U
     or v-ext-mode = "vsd_corr-parts"
     or v-ext-mode = "corr-parts"
    )
then do:
  assign
    v-edit-parts = true
  .
  define variable v-rsrv-type as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rsrvtype in g#library
  (input  p-doc-code
  ,output v-rsrv-type
  ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении типа резервирования документа" skip
      "Документ" p-doc-code skip
      "Режим интерфейса" p-edit-mode skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  assign
    v-add-parts = false
  .
  case v-rsrv-type :
    when 'rsrv-pri-doc':U or
    when 'rsrv-pri-fact':U
    then do:
      assign
        v-add-parts = true
      .
    end.
    when 'rsrv-doc':U
    then do:
      assign
        v-add-parts = true
      .
      if v-goods-twounit = true
      then do:
        assign
          v-add-parts = false
        .
      end.
    end.
  end.
  if buf_trn-doc.ext-doc-type = 'ap':U
  then do:
    assign
      v-add-parts = false
    .
  end.
end.
else do:
  assign
    v-edit-parts = false
  .
end.
if v-edit-parts = true
then do:
  TRANSACTION-MAIN-BLOCK:
  DO TRANSACTION
  ON ERROR   UNDO TRANSACTION-MAIN-BLOCK, LEAVE TRANSACTION-MAIN-BLOCK
  ON END-KEY UNDO TRANSACTION-MAIN-BLOCK, LEAVE TRANSACTION-MAIN-BLOCK
  :
    run main-block-procedure no-error .
    if error-status :error
    then do:
      if v-need-rsrv-gds
      then do:
        undo transaction-main-block, leave transaction-main-block .
      end.
           else do:
        undo, return error .
      end.
    end.
  END.
end.
else do:
  MAIN-BLOCK:
  DO
  ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
  :
    run main-block-procedure no-error .
    if error-status :error
    then do:
      undo MAIN-BLOCK, LEAVE MAIN-BLOCK .
    end.
  END.
end.
RUN disable_UI.
PROCEDURE check-input-parameters :
  define buffer buf_clients for ub.clients .
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_goods for ub.goods .
  do
  on error undo, return error
  :
    find first buf_clients no-lock
      where buf_clients.obj-type = v-obj-type
        and buf_clients.obj-code = v-obj-code
      no-error .
    if (not available buf_clients)
    or (lookup(v-obj-type, 'скл':U + chr(44) + 'маг':U) = 0)
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Ошибка задания объекта" skip
        "Объект" v-obj-type v-obj-code skip
        "Документ" p-doc-code skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    if p-doc-code <> ""
    then do:
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
        no-error .
      if not available buf_trn-doc
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найден документ" skip
          "Объект" v-obj-type v-obj-code skip
          "Документ" p-doc-code skip
          "Код товара" p-gds-code skip
          view-as alert-box error .
        undo, return error return-value .
      end.
    end.
    find first buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Объект" v-obj-type v-obj-code skip
        "Документ" p-doc-code skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error return-value .
    end.
    define variable ind                     as integer no-undo .
    define variable v-num-entries-p-r-parts as integer no-undo .
    if p-r-parts = ""
    or p-r-parts = ?
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании параметров вызова резервирования" skip
        "Не задан параметр вызова p-r-parts." skip
        view-as alert-box error .
      undo, return error .
    end.
    assign
      v-need-reserv          = true
      v-need-check-diff-qnty = true
      v-chg-qnty             = 0
    .
    assign
      v-num-entries-p-r-parts = num-entries(p-r-parts)
    .
    do ind = 2 to v-num-entries-p-r-parts
    :
      define variable v-option       as character no-undo .
      define variable v-option-key   as character no-undo .
      define variable v-option-value as character no-undo .
      assign
        v-option = entry(ind, p-r-parts)
      .
      if v-option = ""
      or v-option = ?
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при задании параметров вызова" skip
          "В качестве параметров резервирования задана пустая или неопределенная опция" skip
          "v-option" v-option skip
          "p-r-parts" p-r-parts skip
          view-as alert-box error .
        undo, return error .
      end.
      assign
        v-option-key = entry(1, v-option, "=" )
      .
      case v-option-key :
        when 'без-резервирования':U
        then do:
          assign
            v-need-reserv = false
          .
        end.
        when 'no-diff-check':U
        then do:
          assign
            v-need-check-diff-qnty = false
          .
        end.
        when 'chg-qnty':U
        then do:
          if num-entries(v-option, "=") <> 2
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при задании параметров вызова резервирования" skip
              "Для указания количества по резервированию необходимо указать строку" skip
              "" 'chg-qnty':U + "=<plcode>" skip
              "v-option" v-option skip
              "p-r-parts" p-r-parts skip
              view-as alert-box error .
            undo, return error .
          end.
          assign
            v-chg-qnty = decimal(entry(2, v-option, "=" ))
          .
        end.
        otherwise do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при задании параметров вызова резервирования" skip
            "Неизвестная опция." v-option skip
            "p-r-parts" p-r-parts skip
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
    assign
      p-r-parts = entry(1, p-r-parts)
    .
    if lookup(p-r-parts
              , 'все':U
              + chr(44) + 'остатки':U
              + chr(44) + 'свободно':U
              + chr(44) + 'документ':U
             ) = 0
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при задании параметров вызова" skip
        "Недопустимый параметр вызова p-r-parts" skip
        "Значение p-r-parts:"  p-r-parts skip
        "Допустимые значения параметра"
              'все':U + chr(44) + 'остатки':U
              + chr(44) + 'свободно':U
              + chr(44) + 'документ':U skip
        view-as alert-box error .
      undo, return error .
    end.
  end.
END PROCEDURE.
PROCEDURE contract-code-to-str :
  define input  parameter p-contract-code     as integer   no-undo .
  define input  parameter p-obj-type          as character no-undo .
  define input  parameter p-obj-code          as integer   no-undo .
  define output parameter p-contract-code-str as character no-undo .
  define buffer buf_contract for ub.contract .
  define variable v-host-code as integer   no-undo .
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
  find first buf_contract no-lock
    where buf_contract.host-code     = v-host-code
      and buf_contract.contract-code = p-contract-code
    no-error .
  if available buf_contract
  then do:
    assign
      p-contract-code-str = substitute('&1 &2 Вн.н. &3':u
                              ,buf_contract.contract-prn-code
                              ,string(buf_contract.contract-date, '99/99/9999':u)
                              ,buf_contract.contract-code
                              )
    .
  end.
  else do:
    if p-contract-code = 0
    then do:
      assign
        p-contract-code-str = ""
      .
    end.
    else do:
      assign
        p-contract-code-str = "?"
      .
    end.
  end.
END PROCEDURE.
PROCEDURE create-bar-code-parts :
define input  parameter   p-gds-code   as integer   no-undo .
define input  parameter   p-part-code  as character no-undo .
define input  parameter   p-in-code    as character no-undo .
define input  parameter   p-unit-base  as character no-undo .
define variable v-bar-code-is-new as logical   no-undo .
define variable v-root-node as integer   no-undo .
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_goods for ub.goods  .
find first buf_goods no-lock where  buf_goods.gds-code = p-gds-code no-error .
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rootnode in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,output v-root-node
  ) no-error .
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run barcodcr in g#library
  (input  p-gds-code
  ,input  v-root-node
  ,input  p-part-code
  ,input  p-in-code
  ,input  p-unit-base
  ,input  ?
  ,output v-bar-code-is-new
  ,buffer buf_bar-code
  ) no-error .
END PROCEDURE.
PROCEDURE data-changed :
  assign
    v-data-changed = true
  .
END PROCEDURE.
PROCEDURE delete-parts :
  define input parameter p-parts-recid as recid no-undo .
  run trg/partdel.p
    (input p-doc-code
    ,input p-parts-recid
    ) .
  run data-changed in this-procedure .
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE display-doc-line-info :
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_goods   for ub.goods .
  define buffer buf_doc-line for ub.doc-line .
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
    .
  find first buf_trn-doc no-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  find first buf_doc-line no-lock
    where buf_doc-line.doc-code  = buf_trn-doc.doc-code
      and buf_doc-line.artic     = buf_goods.artic
      and buf_doc-line.prod-type = buf_goods.prod-type
      and buf_doc-line.prod-code = buf_goods.prod-code
    no-error .
  if  available buf_trn-doc
  and available buf_doc-line
  then do:
    if buf_trn-doc.status_ = 'накл':U
    and buf_trn-doc.flag_ = no
    then do:
      display
        (buf_doc-line.doc-qnty + v-chg-qnty) @ FI_doc-line_doc-qnty
        with frame Dialog-Frame.
    end.
    else do:
      display
        buf_doc-line.doc-qnty  @ FI_doc-line_doc-qnty
        buf_doc-line.fact-qnty @ FI_doc-line_fact-qnty
        with frame Dialog-Frame.
    end.
  end.
END PROCEDURE.
PROCEDURE display-parts-info :
  define buffer buf_goods    for ub.goods .
  define buffer buf_clients  for ub.clients .
  define buffer buf_pay-type for ub.pay-type .
  define buffer buf_currency for ub.currency .
  define buffer buf_parts    for ub.parts .
  do with frame Dialog-Frame:
    if available parts
    then do:
      find first buf_goods no-lock
        where buf_goods.artic     = parts.artic
          and buf_goods.prod-type = parts.prod-type
          and buf_goods.prod-code = parts.prod-code
        .
      find buf_clients no-lock
        where buf_clients.obj-type = parts.supp-type
          and buf_clients.obj-code = parts.supp-code
        no-error.
      if available buf_clients
      then do:
        display
          buf_clients.obj-name @ FI_obj-name
          buf_clients.obj-type @ FI_obj-type
          buf_clients.obj-code @ FI_obj-code
          with frame Dialog-Frame.
      end.
      else do:
        display
          "?" @ FI_obj-name
          ""  @ FI_obj-type
          ""  @ FI_obj-code
          with frame Dialog-Frame.
      end.
      display
        get-b-code(buffer parts) @ fi-b-code
        with frame Dialog-Frame .
      find buf_pay-type no-lock
        where buf_pay-type.obj-code = parts.pay-code
        no-error.
      if available buf_pay-type
      then do:
        assign
          FI_pay-name :screen-value = buf_pay-type.obj-name
        .
      end.
      else do:
        assign
          FI_pay-name :screen-value = ""
        .
      end.
      find buf_currency no-lock
        where buf_currency.curr-code = parts.exch-code
        no-error.
      if available buf_currency
      then do:
        assign
          FI_currency_curr-abbr :screen-value = buf_currency.curr-abbr
        .
      end.
      else do:
        assign
          FI_currency_curr-abbr :screen-value = ""
        .
      end.
      define variable v-free-qnty      as decimal no-undo .
      define variable v-free-rsrv-qnty as decimal no-undo .
      define variable v-out-qnty       as decimal no-undo .
      define variable v-out-rsrv-qnty  as decimal no-undo .
      define variable v-income-qnty    as decimal no-undo .
      define variable v-income-qnty-fact    as decimal no-undo .
      assign
        v-free-qnty      = 0
        v-free-rsrv-qnty = 0
        v-out-qnty       = 0
        v-out-rsrv-qnty  = 0
        v-income-qnty    = 0
        v-income-qnty-fact    = 0
      .
      for each buf_parts no-lock
        where buf_parts.obj-type  = parts.obj-type
          and buf_parts.obj-code  = parts.obj-code
          and buf_parts.artic     = parts.artic
          and buf_parts.prod-type = parts.prod-type
          and buf_parts.prod-code = parts.prod-code
          and buf_parts.in-code   = parts.in-code
          and buf_parts.part-code = parts.part-code
          and buf_parts.status_   = no
          and buf_parts.rsrv-free = yes
      :
        if buf_parts.out-code = 'free-zone':U
        then do:
          assign
            v-free-qnty      = v-free-qnty + buf_parts.qnty
          .
        end.
        else do:
          assign
            v-free-rsrv-qnty = v-free-rsrv-qnty  + abs(buf_parts.qnty)
          .
        end.
      end.
      for each buf_parts no-lock
        where buf_parts.obj-type  = parts.obj-type
          and buf_parts.obj-code  = parts.obj-code
          and buf_parts.artic     = parts.artic
          and buf_parts.prod-type = parts.prod-type
          and buf_parts.prod-code = parts.prod-code
          and buf_parts.in-code   = parts.in-code
          and buf_parts.part-code = parts.part-code
          and buf_parts.status_   = no
          and buf_parts.rsrv-free = no
      :
        if buf_parts.out-code = 'out-zone':U
        then do:
          assign
            v-out-qnty      = v-out-qnty + buf_parts.qnty
          .
        end.
        else do:
          assign
            v-out-rsrv-qnty = v-out-rsrv-qnty + buf_parts.qnty
          .
        end.
      end.
      for each buf_parts no-lock
        where buf_parts.obj-type  = parts.obj-type
          and buf_parts.obj-code  = parts.obj-code
          and buf_parts.artic     = parts.artic
          and buf_parts.prod-type = parts.prod-type
          and buf_parts.prod-code = parts.prod-code
          and buf_parts.in-code   = parts.in-code
          and buf_parts.part-code = parts.part-code
          and buf_parts.out-code  = parts.in-code
          and buf_parts.doc-type  = 'при':U
      :
        assign
          v-income-qnty    = v-income-qnty + buf_parts.qnty
          v-income-qnty-fact    = v-income-qnty-fact + buf_parts.fact-qnty
        .
      end.
      assign
        ed-notes          = parts.PS
        fi-free-qnty      = v-free-qnty
        fi-free-rsrv-qnty = v-free-rsrv-qnty
        fi-out-qnty       = v-out-qnty
        fi-out-rsrv-qnty  = v-out-rsrv-qnty
        fi-income-qnty    = v-income-qnty
        fi-income-qnty-fact = v-income-qnty-fact
      .
      define variable v-in-code-fact-date as date      no-undo .
      define buffer buf_trn-doc for ub.trn-doc .
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = ub.parts.in-code
        no-error .
      if available buf_trn-doc
      then do:
        assign
          v-in-code-fact-date = buf_trn-doc.fact-date
        .
      end.
      else do:
        assign
          v-in-code-fact-date = ub.parts.fact-date
        .
      end.
      define variable v-last-fact-date as character no-undo .
      if parts.last-date <> ?
      then do:
        assign
          v-last-fact-date = string(parts.last-date, '99/99/9999':u)
        .
      end.
      else do:
        assign
          v-last-fact-date = ""
        .
      end.
      assign
        FI_parts_orig-in-code   = ""
        FI_parts_orig-fact-date = ?
        FI_orig-purch-code      = ""
      .
      define variable v-gds-code       as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pargocod in g#library
  (input  recid(parts)
  ,output v-gds-code
  )  .
      define buffer buf_parts-attr for ub.parts-attr .
      find first buf_parts-attr no-lock
        where buf_parts-attr.in-code   = parts.in-code
          and buf_parts-attr.gds-code  = v-gds-code
          and buf_parts-attr.part-code = parts.part-code
        no-error .
      if available buf_parts-attr
      then do:
        assign
          FI_parts_orig-in-code   = buf_parts-attr.income-in-code
        .
        define buffer buf_income_parts-attr for ub.parts-attr .
        find first buf_income_parts-attr no-lock
          where buf_income_parts-attr.in-code   = buf_parts-attr.income-in-code
            and buf_income_parts-attr.gds-code  = buf_parts-attr.income-gds-code
            and buf_income_parts-attr.part-code = buf_parts-attr.income-part-code
          no-error .
        if available buf_income_parts-attr
        then do:
          assign
            FI_parts_orig-fact-date = buf_income_parts-attr.fact-date
          .
          run purch-code-to-str in this-procedure
            (input  buf_income_parts-attr.purch-code
            ,output FI_orig-purch-code
            ) .
        end.
        assign
          fi_unit_cli-abbr = buf_parts-attr.unit-cli
        .
      end.
      else do:
        assign
          FI_parts_orig-in-code   = '':u
          FI_parts_orig-fact-date = ?
          FI_orig-purch-code      = '':u
          fi_unit_cli-abbr        = buf_goods.unit-cli
        .
        if parts.in-code = parts.out-code
        then do:
          define buffer buf_doc-line for ub.doc-line .
          find first buf_doc-line no-lock
            where buf_doc-line.doc-code  = parts.out-code
              and buf_doc-line.artic     = parts.artic
              and buf_doc-line.prod-type = parts.prod-type
              and buf_doc-line.prod-code = parts.prod-code
            no-error .
          if available buf_doc-line
          then do:
            assign
              fi_unit_cli-abbr = buf_doc-line.unit-cli
            .
          end.
        end.
      end.
      display
        FI_parts_orig-in-code
        FI_parts_orig-fact-date
        FI_orig-purch-code
        fi_unit_cli-abbr
        parts.VAT-pc    @ FI_parts_VAT-pc
        parts.VAT-type  @ FI_parts_VAT-type
        parts.SLT-pc    @ FI_parts_SLT-pc
        parts.SLT-type  @ FI_parts_SLT-type
        parts.price-cli @ FI_parts_price-cli
        parts.cli-qnty  @ FI_parts_cli-qnty
        parts.cli-base-rate @ FI_parts_cli-base-rate
        get-purch-code(buffer parts) @ FI_purch-code
        get-contract-prn-code(recid(parts)) @ FI_contract-prn-code
        get-country-name(buffer parts) @ FI_country-name
        parts.in-code   @ FI_parts_in-code
        v-in-code-fact-date @ FI_parts_fact-date
        v-last-fact-date @ fi_last-date
        ed-notes
        fi-free-qnty
        fi-free-rsrv-qnty
        fi-out-qnty
        fi-out-rsrv-qnty
        fi-income-qnty
        fi-income-qnty-fact
        get-price-doc (recid(parts)) @ FI_price-doc
        with frame Dialog-Frame.
    end.
  end.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY rs-parts rs-one-all R-find s-code FI_doc-line_doc-qnty
          fi-label-filter-status FI_doc-line_fact-qnty FI_unit-base
          fi-label-filter-object fi-free-qnty fi-free-rsrv-qnty
          FI_orig-purch-code fi-income-qnty fi-income-qnty-fact fi-out-qnty
          fi-out-rsrv-qnty FI_last-date FI_price-doc FI_parts_cli-qnty
          FI_parts_cli-base-rate FI_parts_SLT-type FI_parts_SLT-pc
          FI_country-name FI_purch-code FI_contract-prn-code
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-quit b-mark b-sel b-lkp b-add b-chg b-del b-vsd b-sch b-print
         b-help RECT-4 RECT-7 b-doc b-b-alt b-pl rs-parts rs-one-all R-find
         s-code br-parts b-income-in-code b-in b-contract FI_price-doc
      WITH FRAME Dialog-Frame.
  run reopen-query in this-procedure .
END PROCEDURE.
PROCEDURE get-attr-chg-qnty :
  define output parameter p-chg-qnty as decimal   no-undo .
  assign
    p-chg-qnty = v-chg-qnty
  .
END PROCEDURE.
PROCEDURE get-sort-column-phrase :
  define input  parameter p-sort-column-name   as character no-undo .
  define output parameter p-sort-column-phrase as character no-undo .
  case p-sort-column-name :
    when ""
    then do:
      assign
        p-sort-column-phrase = ""
      .
    end.
    when "parts-out-code"
    then do:
      assign
        p-sort-column-phrase = "by parts.out-code"
      .
    end.
    when "parts-object"
    then do:
      assign
        p-sort-column-phrase = "by parts.obj-type by parts.obj-code"
      .
    end.
    when "parts-part-code"
    then do:
      assign
        p-sort-column-phrase = "by parts.part-code"
      .
    end.
    otherwise do:
      assign
        p-sort-column-phrase = "by " + p-sort-column-name
      .
    end.
  end case.
END PROCEDURE.
PROCEDURE init-flt :
  assign
    tbl = "parts"
    join-tbl = ""
  .
  run fltfield-clear in this-procedure(
  output fld, output lab, output spr, output dim)  no-error.
  run fltfield-add in this-procedure('in-code', 'Номер ПН', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('out-code', 'Статус', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('obj-type*obj-code', 'Объект', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('supp-type*supp-code', 'Поставщик', 'cli',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('part-code', '', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('status_', 'Закр', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('qnty', 'Кол.док.', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-qnty', 'Факт.кол.', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('fact-date', 'Дата', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pay-code', 'Код Оплаты', 'pay',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('doc-type', 'Тип Докум.', 'trn-type',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('price-base', 'Цена (вал)', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('price-rubl', 'Цена (руб)', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('price-cli', 'Цена пост. (вал)', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('exch-code', 'Валюта пост.', 'curr',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('is-supp', 'Поставка', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('cst-code', 'ГТД', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
  run fltfield-add in this-procedure('pl-code', 'Место', '',
  input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
END PROCEDURE.
PROCEDURE is-button-enabled :
  define input parameter  p-button-name as character no-undo .
  define output parameter p-enable      as logical no-undo .
  do with frame Dialog-Frame:
    case p-button-name :
      when "b-add":U
      then do:
        assign
          p-enable = b-add :sensitive
        .
      end.
      when "b-del":U
      then do:
        assign
          p-enable = b-del :sensitive
        .
      end.
    end case .
  end.
END PROCEDURE.
PROCEDURE main-block-procedure :
  do
  on error   undo , return error
  on end-key undo , return error
  :
    f-date-to = today .
    f-date-from = today - 92 .
    define variable v-road-tax-name as character no-undo .
    run tax-name in this-procedure
      (input  'rdt':U
      ,output v-road-tax-name
      ) .
    assign
      parts.road-tax-base :label in browse br-parts = v-road-tax-name + " (вал)"
      parts.road-tax-rubl :label in browse br-parts = v-road-tax-name + " (руб)"
      parts.price-rubl :label in browse br-parts = "Цена (руб)"
    .
    define buffer buf_goods for ub.goods .
    find buf_goods no-lock
      where buf_goods.gds-code = p-gds-code
      no-error .
    if not available buf_goods
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка задания входных параметров" skip
        "Не найден товар" skip
        "Код товара" p-gds-code skip
        view-as alert-box error .
      undo, return error .
    end.
    if buf_goods.gds-type <> 'т':U
    then do:
      message
        "Просмотр партий возможен только для товаров"
        view-as alert-box information .
      undo, return error .
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscdat in g#library
  (input  buf_goods.gds-code
  ,input  'alcohol-prod=request':u
  ,output v-goods-alcohol-prod
  ) no-error .
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно запросить признак товара" skip
        'alcohol-prod=request':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf_goods.artic
  ,  input buf_goods.prod-type
  ,  input buf_goods.prod-code
  , output v-is-petrol
  , output v-is-pieces
  ) no-error.
    if error-status :error
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно запросить признаки товара" skip
        'is-petrol и/или is-pieces':U skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo, return error .
    end.
    do with frame Dialog-Frame
    :
      define variable v-part-part-code-width as integer   no-undo .
      if v-goods-alcohol-prod = true
      then do:
        assign
          v-part-part-code-width = 25
        .
      end.
      else do:
        assign
          v-part-part-code-width = 14
        .
      end.
      assign
        parts-part-code :resizable in browse br-parts = true
        parts-part-code :width     in browse br-parts = v-part-part-code-width
      .
    end.
    do with frame Dialog-Frame
    :
      assign
        rs-one-all :radio-buttons = "Текущий объект" + chr(44) + 'текущий':U
            + chr(44) + "Все объекты" + chr(44) + 'все':U
      .
      assign
        rs-parts :radio-buttons = "Все"  + chr(44) + 'все':U
            + chr(44) + "Факт остатки"  + chr(44) + 'остатки':U
            + chr(44) + "Свободно"  + chr(44) + 'свободно':U
            + (if p-doc-code <> ""
              then chr(44) + "Документ" + chr(44) + 'документ':U
              else ""
              )
      .
    end.
    assign
      rs-parts   = p-r-parts
      rs-one-all = p-one-all
    .
    display
      rs-parts
      rs-one-all
      with frame Dialog-Frame.
    if p-r-parts = 'документ':U
    then do:
      define buffer buf_trn-doc  for ub.trn-doc .
      define buffer buf_doc-line for ub.doc-line .
      find buf_trn-doc
        where buf_trn-doc.doc-code = p-doc-code
        no-error.
      find buf_doc-line
        where buf_doc-line.doc-code  = p-doc-code
          and buf_doc-line.artic     = buf_goods.artic
          and buf_doc-line.prod-type = buf_goods.prod-type
          and buf_doc-line.prod-code = buf_goods.prod-code
        no-error.
      if  available buf_trn-doc
      and available buf_doc-line
      then do:
        if  buf_trn-doc.doc-type = 'при':U
        and buf_trn-doc.internal = false
        then do:
          assign
            v-reserv-pl-code = false
            v-pl-code        = 0
          .
        end.
        if v-edit-parts = true
        then do:
          define variable v-can-edit-inv-on as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run trnat in g#library
  (input  buf_trn-doc.doc-type
  ,input  buf_trn-doc.internal
  ,input  buf_trn-doc.discnt-type
  ,input  buf_trn-doc.status_
  ,input  buf_trn-doc.flag_
  ,input  buf_trn-doc.ext-doc-type
  ,input  'can-edit-inv-on=request':u
  ,output v-can-edit-inv-on
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Невозможно запросить признак складского документа" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error .
          end.
          if v-can-edit-inv-on <> "true":u
          then do:
            define variable v-inv-on as logical no-undo .
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  'inv-on=request':u
  ,output v-inv-on
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Невозможно запросить признаки товара на объекте" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
            if v-inv-on = true
            then do:
              message
                "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
                "сейчас находится в инвентаризации" skip
                "Редактирование резервов невозможно" skip
                view-as alert-box .
              undo, return error .
            end.
          end.
          if v-reserv-pl-code = ?
          then do:
            run plgdsfnd in this-procedure
              (input  true
              ,input  buf_doc-line.obj-type
              ,input  buf_doc-line.obj-code
              ,input  p-gds-code
              ,output v-reserv-pl-code
              ,output v-pl-code
              ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Невозможно определить место хранения для товара" skip
                "Объект"  buf_doc-line.obj-type buf_doc-line.obj-code skip
                "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
          end.
        end.
        else do:
          if v-reserv-pl-code = ?
          then do:
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  buf_doc-line.obj-type
  ,input  buf_doc-line.obj-code
  ,input  buf_doc-line.artic
  ,input  buf_doc-line.prod-type
  ,input  buf_doc-line.prod-code
  ,input  'place-rsrv=request'
  ,output v-reserv-pl-code
  ) no-error .
            if error-status :error
            then do:
              message
                vss-workfile vss-revision vss-description skip
                "Ошибка при определении атрибута товара на объекте" skip
                error-status :get-message(1) skip
                return-value skip
                view-as alert-box error .
              undo, return error .
            end.
          end.
          if v-reserv-pl-code = true
          then do:
            assign
              v-reserv-pl-code = ?
            .
          end.
        end.
        if  p-call-point <> 'справочник':U
        and buf_trn-doc.status_ <> 'запрос':U
        and buf_trn-doc.ext-doc-type <> 'wm':U
        and v-need-reserv = true
        and v-edit-parts = true
        then do:
          assign
            v-need-rsrv-gds = true
          .
        end.
        if v-reserv-pl-code = true
        then do:
          run trndocrs-pl-gds-request in this-procedure
            (input  buf_doc-line.doc-code
            ,input  buf_trn-doc.doc-type
            ,input  buf_doc-line.obj-type
            ,input  buf_doc-line.obj-code
            ,input  buf_doc-line.artic
            ,input  buf_doc-line.prod-type
            ,input  buf_doc-line.prod-code
            ,input  "before":u
            ) .
        end.
        run rsrgdsck in this-procedure
          (input  buf_doc-line.doc-code
          ,input  buf_trn-doc.doc-type
          ,input  buf_doc-line.obj-type
          ,input  buf_doc-line.obj-code
          ,input  buf_doc-line.artic
          ,input  buf_doc-line.prod-type
          ,input  buf_doc-line.prod-code
          ,output v-free-parts-qnty
          ,output v-free-parts-fact-qnty
          ,output v-free-parts-cli-qnty
          ,output v-free-parts-price-base
          ,output v-free-parts-price-rubl
          ,output v-out-parts-qnty
          ,output v-out-parts-fact-qnty
          ,output v-out-parts-cli-qnty
          ,output v-out-parts-price-base
          ,output v-out-parts-price-rubl
          ) .
        if v-need-rsrv-gds
        then do:
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscheck in g#library
  (input buf_doc-line.obj-type
  ,input buf_doc-line.obj-code
  ,input buf_doc-line.artic
  ,input buf_doc-line.prod-type
  ,input buf_doc-line.prod-code
  ,input ?
  ,input ''
  ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при проверке целостности товара" skip
              "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box .
            undo, return error .
          end.
        end.
        if  buf_trn-doc.status_ = 'накл':U
        and buf_trn-doc.flag_ = no
        then do:
          display
            buf_doc-line.doc-qnty @ FI_doc-line_doc-qnty
            buf_goods.unit-base   @ FI_unit-base
            with frame Dialog-Frame.
          hide
            FI_doc-line_fact-qnty
            in frame Dialog-Frame.
        end.
        else do:
          display
            buf_doc-line.doc-qnty  @ FI_doc-line_doc-qnty
            buf_doc-line.fact-qnty @ FI_doc-line_fact-qnty
            buf_goods.unit-base    @ FI_unit-base
            with frame Dialog-Frame.
        end.
        if buf_trn-doc.doc-type = 'инв':U
        then do:
          assign
            FI_doc-line_doc-qnty  :label = "Стало"
            FI_doc-line_fact-qnty :label = "Разница"
          .
        end.
      end.
    end.
    else do:
      hide
        FI_doc-line_doc-qnty
        FI_doc-line_fact-qnty
        in frame Dialog-Frame.
    end.
    if v-edit-parts <> true
    then do:
      assign
        b-exit :label in frame Dialog-Frame = "&Выход"
      .
    end.
    assign
    parts.transport-rubl:label in browse br-parts = "Трансп. ("
    parts.road-tax-rubl:label in browse br-parts = "Дор.налог (руб)"
    parts.other-rubl:label in browse br-parts = "Другое (руб)"
    .
    display
      fi-label-filter-status
      fi-label-filter-object
      with frame Dialog-Frame .
    ENABLE
      b-exit
      b-quit when v-edit-parts = true
      b-lkp
      b-mark
      b-income-in-code b-b-alt
      b-pl
      b-print
      b-help
      r-find
      s-code
      br-parts
      b-in b-contract
      b-doc
      b-sch rs-parts
      b-sel when p-call-point = 'выбор':U
      ed-notes
      rs-one-all
      b-alc-attr when v-alcohol-prod = yes
      b-marking when v-marking = yes
      b-vsd when v-mercury-prod = yes
      WITH FRAME Dialog-Frame.
    assign
      v-prt-rec = ?
    .
    run reopen-query .
    VIEW FRAME Dialog-Frame.
    hbrowse = browse br-parts:handle.
    extent (bcol) = hbrowse:num-columns.
    bcol[1] = hbrowse:first-column.
    do ic = 1 to extent (bcol).
      bcol[ic] = hbrowse:get-browse-column (ic).
    end.
    WAIT-FOR GO OF FRAME Dialog-Frame focus br-parts .
  end.
END PROCEDURE.
PROCEDURE parts-show-income-in-code :
  define input  parameter p-parts-recid as recid     no-undo .
  define buffer buf_parts for ub.parts .
  define buffer buf_goods for ub.goods .
  define variable v-gds-code as integer   no-undo .
  define variable v-income-in-code   as character no-undo .
  define variable v-income-gds-code  as integer   no-undo .
  define variable v-income-part-code as character no-undo .
  define variable v-income-artic     as character no-undo .
  define variable v-income-prod-type as character no-undo .
  define variable v-income-prod-code as integer   no-undo .
  do
  on error undo, return error return-value
  :
    find first buf_parts no-lock
      where recid(buf_parts) = p-parts-recid
      no-error .
    if not available buf_parts
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Неправильное задание входных параметров" skip
        "Не найдена партия" skip
        "Код партии" p-parts-recid skip
        view-as alert-box error .
      undo, return error return-value .
    end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pargocod in g#library
  (input  p-parts-recid
  ,output v-gds-code
  )  .
    define buffer buf_parts-attr for ub.parts-attr .
    find first buf_parts-attr no-lock
      where buf_parts-attr.in-code   = buf_parts.in-code
        and buf_parts-attr.gds-code  = v-gds-code
        and buf_parts-attr.part-code = buf_parts.part-code
      no-error .
    if available buf_parts-attr
    then do:
      assign
        v-income-in-code   = buf_parts-attr.income-in-code
        v-income-gds-code  = buf_parts-attr.income-gds-code
        v-income-part-code = buf_parts-attr.income-part-code
      .
      find first buf_goods no-lock
        where buf_goods.gds-code = v-income-gds-code
        no-error .
      if available buf_goods
      then do:
        assign
          v-income-artic     = buf_goods.artic
          v-income-prod-type = buf_goods.prod-type
          v-income-prod-code = buf_goods.prod-code
        .
      end.
      else do:
        assign
          v-income-artic     = ""
          v-income-prod-type = ""
          v-income-prod-code = 0
        .
      end.
      run str/showdoc.p
        (input parparentproc
        ,input v-income-in-code
        ,input v-income-artic
        ,input v-income-prod-type
        ,input v-income-prod-code
        ,input true
        ) .
    end.
    else do:
      message
        "Информация о внешней приходной накладной, создавшей данную партию, недоступна" skip
        view-as alert-box information .
    end.
  end.
END PROCEDURE.
PROCEDURE proc-get-country-name :
  define parameter buffer buf_parts      for ub.parts .
  define output parameter p-country-name as character no-undo .
  define buffer buf_parts-attr for ub.parts-attr .
  define buffer buf_country    for ub.country .
  do
  on error undo, return error return-value
  :
    if available buf_parts
    then do:
      find first buf_parts-attr no-lock
        where buf_parts-attr.in-code   = buf_parts.in-code
          and buf_parts-attr.gds-code  = p-gds-code
          and buf_parts-attr.part-code = buf_parts.part-code
        no-error .
      if available buf_parts-attr
      then do:
        find first buf_country no-lock
          where buf_country.num-code = buf_parts-attr.country-code
          no-error .
        if not available buf_country
        then do:
          assign
            p-country-name = "XX Неизвестна"
          .
        end.
        else do:
          assign
            p-country-name = buf_country.alpha1 + " " + buf_country.short-name
          .
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE purch-code-to-str :
  define input  parameter p-purch-code     as integer   no-undo .
  define output parameter p-purch-code-str as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run purchnam in g#library
  (input  p-purch-code
  ,output p-purch-code-str
  )  .
END PROCEDURE.
PROCEDURE reopen-query :
  run UI-on in this-procedure
    (input true
    ,input true
    ,input ""
    ).
END PROCEDURE.
PROCEDURE reposition-parts :
  define input  parameter p-direction   as character no-undo .
  define output parameter p-parts-recid as recid no-undo .
  if p-doc-code = ""
  then do:
    message
      "Перемещение по партиям доступно только из интерфейса документа"
      view-as alert-box information .
    return .
  end.
  case p-direction :
    when "first":U
    then do:
      get first br-parts.
    end.
    when "last":U
    then do:
      get last br-parts.
    end.
    when "prev":U
    then do:
      get prev br-parts.
    end.
    when "next":U
    then do:
      get next br-parts.
    end.
    otherwise do:
      reposition br-parts to recid integer(p-direction) no-error .
    end.
  end case .
  assign
    p-parts-recid = recid(parts)
  .
  run reposition-query in this-procedure
    (input p-parts-recid
    ).
END PROCEDURE.
PROCEDURE reposition-query :
  define input parameter p-recid as recid no-undo .
  if p-recid <> ?
  then do:
    reposition br-parts to recid p-recid no-error.
  end.
  do with frame Dialog-Frame:
    apply "entry":u to browse br-parts .
  end.
  run display-parts-info .
END PROCEDURE.
PROCEDURE save-changes :
  define variable v-need-rsrv      as logical   no-undo .
  define variable v-doc-qnty-cli   as decimal   no-undo .
  define variable v-doc-qnty-base  as decimal   no-undo .
  define variable v-fact-qnty-cli  as decimal   no-undo .
  define variable v-fact-qnty-base as decimal   no-undo .
  define variable v-doc-density    as decimal   no-undo .
  define variable v-fact-density   as decimal   no-undo .
  define variable v-inv-rec        as recid     no-undo .
  define buffer buf_trn-doc  for ub.trn-doc .
  define buffer buf_goods    for ub.goods .
  define buffer buf_doc-line for ub.doc-line .
  define buffer buf_parts    for ub.parts .
  define buffer buf_doc-pl   for ub.doc-pl .
  if v-edit-parts = true
  then do:
    do transaction
    on error undo, return error
    :
      find first buf_trn-doc no-lock
        where buf_trn-doc.doc-code = p-doc-code
        no-error .
      if not available buf_trn-doc
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найден документ" skip
          "Документ" p-doc-code skip
          "Код товара" p-gds-code skip
          view-as alert-box error .
        undo, return error .
      end.
      find first buf_goods no-lock
        where buf_goods.gds-code = p-gds-code
        no-error .
      if not available buf_trn-doc
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка задания входных параметров" skip
          "Не найден товар" skip
          "Документ" p-doc-code skip
          "Код товара" p-gds-code skip
          view-as alert-box error .
        undo, return error .
      end.
      find first buf_doc-line no-lock
        where buf_doc-line.doc-code  = buf_trn-doc.doc-code
          and buf_doc-line.artic     = buf_goods.artic
          and buf_doc-line.prod-type = buf_goods.prod-type
          and buf_doc-line.prod-code = buf_goods.prod-code
        no-error .
      if not available buf_doc-line
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Не найдена строка документа" skip
          "Документ" p-doc-code skip
          "Код товара" p-gds-code skip
          "Артикул" buf_goods.artic buf_goods.prod-type buf_goods.prod-code skip
          view-as alert-box error .
        undo, return error .
      end.
        for each buf_parts no-lock
          where buf_parts.out-code  = buf_trn-doc.doc-code
            and buf_parts.obj-type  = buf_doc-line.obj-type
            and buf_parts.obj-code  = buf_doc-line.obj-code
            and buf_parts.artic     = buf_doc-line.artic
            and buf_parts.prod-type = buf_doc-line.prod-type
            and buf_parts.prod-code = buf_doc-line.prod-code
        on error undo, return error return-value
        :
          if buf_parts.in-code = buf_parts.out-code then do:
             run create-bar-code-parts (
                  buf_goods.gds-code  ,
                  buf_parts.part-code ,
                  buf_parts.in-code   ,
                  buf_goods.unit-base ) no-error .
          end.
      end.
      if v-reserv-pl-code = true then do:
        run trndocrs-pl-gds-request in this-procedure
          (input  buf_doc-line.doc-code
          ,input  buf_trn-doc.doc-type
          ,input  buf_doc-line.obj-type
          ,input  buf_doc-line.obj-code
          ,input  buf_doc-line.artic
          ,input  buf_doc-line.prod-type
          ,input  buf_doc-line.prod-code
          ,input  "after":u
          ) .
        run trndocrs-pl-gds-calc-rsrv in this-procedure .
        assign
          v-doc-density  = buf_doc-line.doc-density
          v-fact-density = buf_doc-line.fact-density
        .
        for each buf_doc-pl exclusive-lock
          where buf_doc-pl.out-code = buf_trn-doc.doc-code
            and buf_doc-pl.gds-code = buf_goods.gds-code
            and buf_doc-pl.obj-type = buf_doc-line.obj-type
            and buf_doc-pl.obj-code = buf_doc-line.obj-code
        on error undo, return error return-value
        :
          run trndocrs-pl-gds-accum in this-procedure
            (input buf_doc-pl.pl-code
            ,input 0.0
            ,input ( if v-need-rsrv-gds = true then - buf_doc-pl.cli-doc-qnty else 0.0 )
            ,input 0.0
            ,input - buf_doc-pl.cli-fact-qnty
            ) no-error .
          if error-status :error
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при изменении разрезервированных количеств trndocrs-pl-gds-accum" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
          delete buf_doc-pl .
        end.
        for each buf_parts no-lock
          where buf_parts.out-code  = buf_trn-doc.doc-code
            and buf_parts.obj-type  = buf_doc-line.obj-type
            and buf_parts.obj-code  = buf_doc-line.obj-code
            and buf_parts.artic     = buf_doc-line.artic
            and buf_parts.prod-type = buf_doc-line.prod-type
            and buf_parts.prod-code = buf_doc-line.prod-code
        on error undo, return error return-value
        :
          if buf_trn-doc.ext-doc-type = 'ep':U
            and buf_trn-doc.status_ <> 'запрос':U
          then do:
            assign
              v-doc-density  = 1.0 / buf_parts.cli-base-rate
              v-fact-density = v-doc-density
            .
          end.
          find first buf_doc-pl exclusive-lock
            where buf_doc-pl.obj-type = buf_doc-line.obj-type
              and buf_doc-pl.obj-code = buf_doc-line.obj-code
              and buf_doc-pl.pl-code  = buf_parts.pl-code
              and buf_doc-pl.out-code = buf_trn-doc.doc-code
              and buf_doc-pl.gds-code = buf_goods.gds-code
            no-error .
          if not available buf_doc-pl then do:
            create buf_doc-pl.
            assign
              buf_doc-pl.obj-type     = buf_doc-line.obj-type
              buf_doc-pl.obj-code     = buf_doc-line.obj-code
              buf_doc-pl.pl-code      = buf_parts.pl-code
              buf_doc-pl.out-code     = buf_trn-doc.doc-code
              buf_doc-pl.gds-code     = buf_goods.gds-code
              buf_doc-pl.cli-qnty      = 0.0
              buf_doc-pl.doc-qnty      = 0.0
              buf_doc-pl.cli-doc-qnty  = 0.0
              buf_doc-pl.fact-qnty     = 0.0
              buf_doc-pl.cli-fact-qnty = 0.0
            .
          end.
          assign
            buf_doc-pl.cli-qnty      = buf_doc-pl.cli-qnty      + buf_parts.qnty / buf_parts.cli-base-rate
            buf_doc-pl.doc-qnty      = buf_doc-pl.doc-qnty      + buf_parts.qnty
            buf_doc-pl.cli-doc-qnty  = buf_doc-pl.cli-doc-qnty  + buf_parts.qnty * v-doc-density
            buf_doc-pl.fact-qnty     = buf_doc-pl.fact-qnty     + buf_parts.fact-qnty
            buf_doc-pl.cli-fact-qnty = buf_doc-pl.cli-fact-qnty + buf_parts.fact-qnty * v-fact-density
          .
        end.
        assign
          v-doc-qnty-cli   = 0.0
          v-doc-qnty-base  = 0.0
          v-fact-qnty-cli  = 0.0
          v-fact-qnty-base = 0.0
        .
        for each buf_doc-pl share-lock
          where buf_doc-pl.obj-type = buf_doc-line.obj-type
            and buf_doc-pl.obj-code = buf_doc-line.obj-code
            and buf_doc-pl.out-code = buf_trn-doc.doc-code
            and buf_doc-pl.gds-code = buf_goods.gds-code
        on error undo, return error return-value
        :
          assign
            v-doc-qnty-base  = v-doc-qnty-base  + buf_doc-pl.doc-qnty
            v-doc-qnty-cli   = v-doc-qnty-cli   + buf_doc-pl.cli-doc-qnty
            v-fact-qnty-base = v-fact-qnty-base + buf_doc-pl.fact-qnty
            v-fact-qnty-cli  = v-fact-qnty-cli  + buf_doc-pl.cli-fact-qnty
          .
          run trndocrs-pl-gds-accum in this-procedure
            (input buf_doc-pl.pl-code
            ,input 0.0
            ,input ( if v-need-rsrv-gds = true then buf_doc-pl.cli-doc-qnty else 0.0 )
            ,input 0.0
            ,input buf_doc-pl.cli-fact-qnty
            ) no-error .
          if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка при изменении зарезервированных количеств trndocrs-pl-gds-accum" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo, return error return-value .
          end.
        end.
        if v-is-petrol = true
          and v-is-pieces = false
        then do:
          assign
            buf_doc-line.cli-qnty     = v-doc-qnty-cli
            buf_doc-line.doc-density  = v-doc-qnty-cli  / v-doc-qnty-base
            buf_doc-line.fact-density = v-fact-qnty-cli / v-fact-qnty-base
          .
        end.
      end.
      run rsrgdsck in this-procedure
        (input  buf_doc-line.doc-code
        ,input  buf_trn-doc.doc-type
        ,input  buf_doc-line.obj-type
        ,input  buf_doc-line.obj-code
        ,input  buf_doc-line.artic
        ,input  buf_doc-line.prod-type
        ,input  buf_doc-line.prod-code
        ,output v-new-free-parts-qnty
        ,output v-new-free-parts-fact-qnty
        ,output v-new-free-parts-cli-qnty
        ,output v-new-free-parts-price-base
        ,output v-new-free-parts-price-rubl
        ,output v-new-out-parts-qnty
        ,output v-new-out-parts-fact-qnty
        ,output v-new-out-parts-cli-qnty
        ,output v-new-out-parts-price-base
        ,output v-new-out-parts-price-rubl
        ) no-error .
      if error-status :error
      then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка при просмотре зарезервированных партий" skip
          "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
          "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
          error-status :get-message(1)
          return-value skip
          view-as alert-box .
        undo, return error .
      end.
      define variable v-chg-free-qnty as decimal no-undo .
      define variable v-chg-out-qnty  as decimal no-undo .
      assign
        v-chg-free-qnty = v-new-free-parts-fact-qnty - v-free-parts-fact-qnty
        v-chg-out-qnty  = v-new-out-parts-fact-qnty  - v-out-parts-fact-qnty
      .
      if v-need-rsrv-gds
      then do:
        run trg/rsrv-gds.p
          (input parparentproc
          ,buffer buf_doc-line
          ,input  v-chg-free-qnty
          ,input  v-chg-out-qnty
          ,input table temp-trndocrs-gds-dtl-rsrv
          ,input table temp-trndocrs-pl-gds-rsrv
          ) no-error.
        if error-status :error
        then do:
          if error-status :get-message(1) <> ""
          then do:
            message
              vss-workfile vss-revision vss-description skip
              "Невозможно зарезервировать товар по признакам" skip
              "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
              "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box .
          end.
          undo, return error .
        end.
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdscheck in g#library
  (input buf_doc-line.obj-type
  ,input buf_doc-line.obj-code
  ,input buf_doc-line.artic
  ,input buf_doc-line.prod-type
  ,input buf_doc-line.prod-code
  ,input ?
  ,input ''
  ) no-error .
        if error-status :error
        then do:
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка при проверке целостности товара" skip
            "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo, return error .
        end.
        define variable v-check-cli-qnty as logical no-undo .
        assign
          v-check-cli-qnty = (buf_trn-doc.doc-type = 'при':U
                              and buf_trn-doc.internal = no
                              )
        .
        run trg/doclnchk.p
          (input buf_doc-line.doc-code
          ,input buf_doc-line.artic
          ,input buf_doc-line.prod-type
          ,input buf_doc-line.prod-code
          ,input v-check-cli-qnty
          ) no-error .
        if error-status :error
        then do:
          message
            "Проверка строки документа" skip
            "Объект" buf_doc-line.obj-type buf_doc-line.obj-code skip
            "Артикул" buf_doc-line.artic buf_doc-line.prod-type buf_doc-line.prod-code skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box .
          undo, return error .
        end.
      end.
      else do:
        if v-need-check-diff-qnty = true
        then do:
          define variable v-diff-qnty as decimal   no-undo .
          assign
            v-diff-qnty = v-chg-qnty - (v-chg-free-qnty + v-chg-out-qnty)
          .
          if v-diff-qnty <> 0
          then do:
            message
              "Нужно создать партии с общим количеством" v-chg-qnty skip
              "Недостающее количество" v-diff-qnty skip
              view-as alert-box information .
            undo, return error .
          end.
        end.
      end.
      if v-reserv-pl-code = true
        and v-is-petrol = true
        and v-is-pieces = false
      then do:
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_corinvln in g#lib-trn3
( input  buf_doc-line.doc-code
 ,input  buf_doc-line.artic
 ,input  buf_doc-line.prod-type
 ,input  buf_doc-line.prod-code
 ,input  0
 ,input  0
 ,input  buf_doc-line.price-rubl / buf_doc-line.fact-density
 ,input  buf_doc-line.price-base / buf_doc-line.fact-density
 ,input  v-fact-qnty-cli
 ,input  buf_doc-line.fact-density
 ,output v-inv-rec
 ) no-error.
        if error-status :error
          or v-inv-rec = ?
        then do:
          undo, return error return-value .
        end.
     end.
     end.
  end.
END PROCEDURE.
PROCEDURE show-contract-code :
  define buffer buf_contract for ub.contract .
  define variable v-host-code as integer   no-undo .
  if available parts
  then do:
    if parts.contract-code = 0
    then do:
      message
        "У партии не задан договор" skip
        view-as alert-box information .
    end.
    else do:
      define variable v-recid as recid no-undo .
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  parts.obj-type
  ,input  parts.obj-code
  ,output v-host-code
  )  .
      find first buf_contract no-lock
        where buf_contract.host-code     = v-host-code
          and buf_contract.contract-code = parts.contract-code
        no-error .
      if available buf_contract
      then do:
        assign
          v-recid = recid( buf_contract )
        .
        run str/sh-contr.p
          (input  parParentProc
          ,input v-recid
          ) .
      end.
      else do:
        message
          "Договор не найден" skip
          "Код фирмы" v-host-code skip
          "Код договора" parts.contract-code skip
          "Объект" parts.obj-type parts.obj-code skip
          "Артикул" parts.artic parts.prod-type parts.prod-code skip
          "Партия" parts.in-code parts.part-code skip
          "Резерв" parts.out-code skip
          view-as alert-box error .
      end.
    end.
  end.
  apply "entry":u to br-parts in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE show-in-code :
  if available parts
  then do:
    run str/showdoc.p
      (input parparentproc
      ,input ub.parts.in-code
      ,input ub.parts.artic
      ,input ub.parts.prod-type
      ,input ub.parts.prod-code
      ,input true
      ).
  end.
  apply "entry":u to br-parts in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE show-income-in-code :
  if available parts
  then do:
    run parts-show-income-in-code in this-procedure
      (input recid(parts)
      ) .
    apply "entry":u to br-parts in frame Dialog-Frame.
  end.
END PROCEDURE.
PROCEDURE UI-on :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define buffer buf_trn-doc for ub.trn-doc .
find first buf_trn-doc no-lock
  where buf_trn-doc.doc-code = p-doc-code
  no-error .
 define buffer buf_goods for ub.goods .
 find first buf_goods no-lock
   where buf_goods.gds-code = p-gds-code
   .
define variable v-query-was-opened as logical no-undo .
assign
  v-query-was-opened = false
.
define variable sort-column-phrase as character no-undo .
run get-sort-column-phrase in this-procedure
  (input  sort-column-name
  ,output sort-column-phrase
  ) .
assign
  del-list = ""
.
disable b-add b-chg b-del b-mark with frame Dialog-Frame.
define variable v-open-query as logical   no-undo .
if rs-one-all = 'все':U
then do:
  define variable lok as logical no-undo .
  define variable v-host-code as integer   no-undo .
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  v-obj-type
  ,input  v-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info64 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_parts_all':U
    ,input  'firm':U
    ,input  v-host-code
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output lok
    )  .
end.
  if not lok
  then do:
    assign
      rs-one-all = 'текущий':U
      rs-one-all :screen-value = rs-one-all
    .
    MESSAGE "Нет права просмотра партий для всех объектов"
    VIEW-AS ALERT-BOX.
  end.
end.
case rs-one-all :
  when 'все':U
  then do:
    run ui-on-01 in this-procedure
      (input  p-open-query
      ,input  p-find-next
      ,input  p-find-condition
      ,input  sort-column-phrase
      ,input-output v-query-was-opened
      ,buffer buf_goods
      ,buffer buf_trn-doc
      ) .
  end.
  when 'текущий':U
  then do:
    run ui-on-02 in this-procedure
      (input  p-open-query
      ,input  p-find-next
      ,input  p-find-condition
      ,input  sort-column-phrase
      ,input-output v-query-was-opened
      ,buffer buf_goods
      ,buffer buf_trn-doc
      ) .
  end.
end.
if v-query-was-opened = false
then do:
  assign
    frame Dialog-Frame:title
      = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
      + "   НЕДОПУСТИМОЕ СОЧЕТАНИЕ ПАРАМЕТОВ ОТБОРА ПАРТИЙ "
  .
  run UI-on-empty in this-procedure
    (input  p-open-query
    ,input  p-find-next
    ,input  p-find-condition
    ) .
end.
run display-doc-line-info .
run reposition-query in this-procedure
  (input v-prt-rec
  ).
END PROCEDURE.
PROCEDURE ui-on-01 :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define input  parameter sort-column-phrase as character no-undo .
  define input-output parameter v-query-was-opened as logical no-undo .
  define parameter buffer buf_goods for ub.goods .
  define parameter buffer buf_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    case rs-parts :
      when 'все':U
      then do:
        assign
          frame Dialog-Frame:title
            = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
            + "   ВСЕ ПАРТИИ"
        .
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-66  as logical   no-undo .
define variable  l-filter-open-66    as logical   .
define variable  flt-rec-66       as recid     no-undo .
define variable  filter-name-66      as character no-undo .
define variable  where-phrase-66     as character no-undo .
define variable  sort-phrase-66      as character no-undo .
define variable  where-phrase-rus-66 as character no-undo .
define variable  sort-phrase-rus-66  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-66
  ,output filter-name-66
  ,output where-phrase-66
  ,output sort-phrase-66
  ,output where-phrase-rus-66
  ,output sort-phrase-rus-66
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-66
      ) no-error .
  assign
    l-filter-open-66 = false
  .
  if flt-rec-66 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-66 as character no-undo .
    define variable  parameter-3-66 as character no-undo .
    define variable  parameter-4-66 as character no-undo .
    define variable  parameter-5-66 as character no-undo .
    define variable  parameter-6-66 as character no-undo .
    define variable  parameter-7-66 as character no-undo .
      assign
      parameter-3-66 =
                              "FOR EACH parts"
      parameter-4-66 =
        (
          if ("parts.artic = buf_goods.artic               and parts.prod-type = buf_goods.prod-type               and parts.prod-code = buf_goods.prod-code               and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )              " + " " + where-phrase-66) <> ""
          then                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code )                + " " + where-phrase-66
          else "true"
        )
      parameter-5-66 = (" " + "" + " " + "")
      parameter-6-66 = if sort-phrase-66 = ''
                           then
        (
        " " + "use-index artic" +
          " " + sort-column-phrase +
        " " + "by parts.status_ by parts.rsrv-free desc"
        )
                           else
        (
        " " + "use-index artic" +
          " " + sort-column-phrase +
        " " + sort-phrase-66
        )
      parameter-7-66 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-66 =
          ("parts.artic = buf_goods.artic               and parts.prod-type = buf_goods.prod-type               and parts.prod-code = buf_goods.prod-code               and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )              " + " " + where-phrase-66 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-parts:handle
                          ,input parameter-3-66
                          ,input parameter-4-66
                          ,input parameter-5-66
                          ,input parameter-6-66
                          ,input parameter-7-66
                          )
      .
      assign
        l-filter-open-66 = true
      .
    end.
    if l-filter-open-66 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          v-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-66 = false then do:
    open query br-parts for each parts no-lock
      where parts.artic = buf_goods.artic               and parts.prod-type = buf_goods.prod-type               and parts.prod-code = buf_goods.prod-code               and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )
      use-index artic
      by parts.status_ by parts.rsrv-free desc
      indexed-reposition
  .
      assign
        v-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-prt-rec = recid( parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-parts:handle:get-buffer-handle(1) = (buffer parts:handle) then do:
      assign
      parameter-2-66 = (if p-find-next then "true":u else "false":u )
      parameter-4-66 =
        "where ":u +                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code )                + " ":u + where-phrase-66 + " ":u + p-find-condition + " " + ""
      parameter-5-66 = "use-index artic"
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input rowid(parts)
                          ,input logical(parameter-2-66)
                          ,input no-lock
                          ,input (buffer parts:handle)
                          ,input parameter-4-66
                          ,input parameter-5-66
                          ) no-error.
      .
      assign
        v-prt-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-66 = (if p-find-next then "true":u else "false":u )
      parameter-3-66 =  "FOR EACH parts"
      parameter-4-66 =
        (
          if ("parts.artic = buf_goods.artic               and parts.prod-type = buf_goods.prod-type               and parts.prod-code = buf_goods.prod-code               and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )              " + " " + where-phrase-66) <> ""
          then                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code )                + " " + where-phrase-66
          else "true"
        )
      parameter-5-66 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-66 = if sort-phrase-66 = ''
                           then
        (
        " " + "use-index artic" +
          " " + sort-column-phrase +
        " " + "by parts.status_ by parts.rsrv-free desc"
        )
                           else
        (
        " " + "use-index artic" +
          " " + sort-column-phrase +
        " " + sort-phrase-66
        )
      parameter-7-66 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input logical(parameter-2-66)
                          ,input no-lock
                          ,input parameter-3-66
                          ,input parameter-4-66
                          ,input parameter-5-66
                          ,input parameter-6-66
                          ,input parameter-7-66
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-prt-rec = ?.
    end.
    assign
      v-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when 'остатки':U
      then do:
        assign
          frame Dialog-Frame:title
            = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
            + "   ФАКТ ОСТАТКИ"
        .
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-68  as logical   no-undo .
define variable  l-filter-open-68    as logical   .
define variable  flt-rec-68       as recid     no-undo .
define variable  filter-name-68      as character no-undo .
define variable  where-phrase-68     as character no-undo .
define variable  sort-phrase-68      as character no-undo .
define variable  where-phrase-rus-68 as character no-undo .
define variable  sort-phrase-rus-68  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-68
  ,output filter-name-68
  ,output where-phrase-68
  ,output sort-phrase-68
  ,output where-phrase-rus-68
  ,output sort-phrase-rus-68
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-68
      ) no-error .
  assign
    l-filter-open-68 = false
  .
  if flt-rec-68 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-68 as character no-undo .
    define variable  parameter-3-68 as character no-undo .
    define variable  parameter-4-68 as character no-undo .
    define variable  parameter-5-68 as character no-undo .
    define variable  parameter-6-68 as character no-undo .
    define variable  parameter-7-68 as character no-undo .
      assign
      parameter-3-68 =
                              "FOR EACH parts"
      parameter-4-68 =
        (
          if ("parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.rsrv-free = yes             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )             " + " " + where-phrase-68) <> ""
          then                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.rsrv-free = yes               and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code )                + " " + where-phrase-68
          else "true"
        )
      parameter-5-68 = (" " + "" + " " + "")
      parameter-6-68 = if sort-phrase-68 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-68
        )
      parameter-7-68 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-68 =
          ("parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.rsrv-free = yes             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )             " + " " + where-phrase-68 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-parts:handle
                          ,input parameter-3-68
                          ,input parameter-4-68
                          ,input parameter-5-68
                          ,input parameter-6-68
                          ,input parameter-7-68
                          )
      .
      assign
        l-filter-open-68 = true
      .
    end.
    if l-filter-open-68 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          v-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-68 = false then do:
    open query br-parts for each parts no-lock
      where parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.rsrv-free = yes             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )
      indexed-reposition
  .
      assign
        v-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-prt-rec = recid( parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-parts:handle:get-buffer-handle(1) = (buffer parts:handle) then do:
      assign
      parameter-2-68 = (if p-find-next then "true":u else "false":u )
      parameter-4-68 =
        "where ":u +                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.rsrv-free = yes               and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code )                + " ":u + where-phrase-68 + " ":u + p-find-condition + " " + ""
      parameter-5-68 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input rowid(parts)
                          ,input logical(parameter-2-68)
                          ,input no-lock
                          ,input (buffer parts:handle)
                          ,input parameter-4-68
                          ,input parameter-5-68
                          ) no-error.
      .
      assign
        v-prt-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-68 = (if p-find-next then "true":u else "false":u )
      parameter-3-68 =  "FOR EACH parts"
      parameter-4-68 =
        (
          if ("parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.rsrv-free = yes             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )             " + " " + where-phrase-68) <> ""
          then                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.rsrv-free = yes               and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code )                + " " + where-phrase-68
          else "true"
        )
      parameter-5-68 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-68 = if sort-phrase-68 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-68
        )
      parameter-7-68 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input logical(parameter-2-68)
                          ,input no-lock
                          ,input parameter-3-68
                          ,input parameter-4-68
                          ,input parameter-5-68
                          ,input parameter-6-68
                          ,input parameter-7-68
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-prt-rec = ?.
    end.
    assign
      v-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when 'свободно':U
      then do:
        assign
          frame Dialog-Frame:title
            = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
            + "   СВОБОДНО"
        .
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-70  as logical   no-undo .
define variable  l-filter-open-70    as logical   .
define variable  flt-rec-70       as recid     no-undo .
define variable  filter-name-70      as character no-undo .
define variable  where-phrase-70     as character no-undo .
define variable  sort-phrase-70      as character no-undo .
define variable  where-phrase-rus-70 as character no-undo .
define variable  sort-phrase-rus-70  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-70
  ,output filter-name-70
  ,output where-phrase-70
  ,output sort-phrase-70
  ,output where-phrase-rus-70
  ,output sort-phrase-rus-70
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-70
      ) no-error .
  assign
    l-filter-open-70 = false
  .
  if flt-rec-70 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-70 as character no-undo .
    define variable  parameter-3-70 as character no-undo .
    define variable  parameter-4-70 as character no-undo .
    define variable  parameter-5-70 as character no-undo .
    define variable  parameter-6-70 as character no-undo .
    define variable  parameter-7-70 as character no-undo .
      assign
      parameter-3-70 =
                              "FOR EACH parts"
      parameter-4-70 =
        (
          if ("parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.out-code = 'free-zone':U             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )             " + " " + where-phrase-70) <> ""
          then                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.out-code = &1&7&1                and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              '              , chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , 'free-zone':U)                + " " + where-phrase-70
          else "true"
        )
      parameter-5-70 = (" " + "" + " " + "")
      parameter-6-70 = if sort-phrase-70 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-70
        )
      parameter-7-70 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-70 =
          ("parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.out-code = 'free-zone':U             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )             " + " " + where-phrase-70 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-parts:handle
                          ,input parameter-3-70
                          ,input parameter-4-70
                          ,input parameter-5-70
                          ,input parameter-6-70
                          ,input parameter-7-70
                          )
      .
      assign
        l-filter-open-70 = true
      .
    end.
    if l-filter-open-70 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          v-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-70 = false then do:
    open query br-parts for each parts no-lock
      where parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.out-code = 'free-zone':U             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )
      indexed-reposition
  .
      assign
        v-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-prt-rec = recid( parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-parts:handle:get-buffer-handle(1) = (buffer parts:handle) then do:
      assign
      parameter-2-70 = (if p-find-next then "true":u else "false":u )
      parameter-4-70 =
        "where ":u +                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.out-code = &1&7&1                and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              '              , chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , 'free-zone':U)                + " ":u + where-phrase-70 + " ":u + p-find-condition + " " + ""
      parameter-5-70 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input rowid(parts)
                          ,input logical(parameter-2-70)
                          ,input no-lock
                          ,input (buffer parts:handle)
                          ,input parameter-4-70
                          ,input parameter-5-70
                          ) no-error.
      .
      assign
        v-prt-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-70 = (if p-find-next then "true":u else "false":u )
      parameter-3-70 =  "FOR EACH parts"
      parameter-4-70 =
        (
          if ("parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.out-code = 'free-zone':U             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )             " + " " + where-phrase-70) <> ""
          then                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.out-code = &1&7&1                and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              '              , chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , 'free-zone':U)                + " " + where-phrase-70
          else "true"
        )
      parameter-5-70 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-70 = if sort-phrase-70 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-70
        )
      parameter-7-70 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input logical(parameter-2-70)
                          ,input no-lock
                          ,input parameter-3-70
                          ,input parameter-4-70
                          ,input parameter-5-70
                          ,input parameter-6-70
                          ,input parameter-7-70
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-prt-rec = ?.
    end.
    assign
      v-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when 'документ':U
      then do:
        if available buf_trn-doc
        then do:
          assign
            frame Dialog-Frame:title
              = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
              + "   Партии по док-ту № : " + buf_trn-doc.doc-code
          .
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-72  as logical   no-undo .
define variable  l-filter-open-72    as logical   .
define variable  flt-rec-72       as recid     no-undo .
define variable  filter-name-72      as character no-undo .
define variable  where-phrase-72     as character no-undo .
define variable  sort-phrase-72      as character no-undo .
define variable  where-phrase-rus-72 as character no-undo .
define variable  sort-phrase-rus-72  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-72
  ,output filter-name-72
  ,output where-phrase-72
  ,output sort-phrase-72
  ,output where-phrase-rus-72
  ,output sort-phrase-rus-72
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-72
      ) no-error .
  assign
    l-filter-open-72 = false
  .
  if flt-rec-72 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-72 as character no-undo .
    define variable  parameter-3-72 as character no-undo .
    define variable  parameter-4-72 as character no-undo .
    define variable  parameter-5-72 as character no-undo .
    define variable  parameter-6-72 as character no-undo .
    define variable  parameter-7-72 as character no-undo .
      assign
      parameter-3-72 =
                              "FOR EACH parts"
      parameter-4-72 =
        (
          if ("parts.artic = buf_goods.artic               and parts.prod-type = buf_goods.prod-type               and parts.prod-code = buf_goods.prod-code               and parts.out-code = buf_trn-doc.doc-code               and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )               " + " " + where-phrase-72) <> ""
          then                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.out-code  = &1&7&1               and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , buf_trn-doc.doc-code )                + " " + where-phrase-72
          else "true"
        )
      parameter-5-72 = (" " + "" + " " + "")
      parameter-6-72 = if sort-phrase-72 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-72
        )
      parameter-7-72 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-72 =
          ("parts.artic = buf_goods.artic               and parts.prod-type = buf_goods.prod-type               and parts.prod-code = buf_goods.prod-code               and parts.out-code = buf_trn-doc.doc-code               and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )               " + " " + where-phrase-72 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-parts:handle
                          ,input parameter-3-72
                          ,input parameter-4-72
                          ,input parameter-5-72
                          ,input parameter-6-72
                          ,input parameter-7-72
                          )
      .
      assign
        l-filter-open-72 = true
      .
    end.
    if l-filter-open-72 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          v-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-72 = false then do:
    open query br-parts for each parts no-lock
      where parts.artic = buf_goods.artic               and parts.prod-type = buf_goods.prod-type               and parts.prod-code = buf_goods.prod-code               and parts.out-code = buf_trn-doc.doc-code               and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )
      indexed-reposition
  .
      assign
        v-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-prt-rec = recid( parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-parts:handle:get-buffer-handle(1) = (buffer parts:handle) then do:
      assign
      parameter-2-72 = (if p-find-next then "true":u else "false":u )
      parameter-4-72 =
        "where ":u +                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.out-code  = &1&7&1               and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , buf_trn-doc.doc-code )                + " ":u + where-phrase-72 + " ":u + p-find-condition + " " + ""
      parameter-5-72 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input rowid(parts)
                          ,input logical(parameter-2-72)
                          ,input no-lock
                          ,input (buffer parts:handle)
                          ,input parameter-4-72
                          ,input parameter-5-72
                          ) no-error.
      .
      assign
        v-prt-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-72 = (if p-find-next then "true":u else "false":u )
      parameter-3-72 =  "FOR EACH parts"
      parameter-4-72 =
        (
          if ("parts.artic = buf_goods.artic               and parts.prod-type = buf_goods.prod-type               and parts.prod-code = buf_goods.prod-code               and parts.out-code = buf_trn-doc.doc-code               and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )               " + " " + where-phrase-72) <> ""
          then                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.out-code  = &1&7&1               and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , buf_trn-doc.doc-code )                + " " + where-phrase-72
          else "true"
        )
      parameter-5-72 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-72 = if sort-phrase-72 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-72
        )
      parameter-7-72 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input logical(parameter-2-72)
                          ,input no-lock
                          ,input parameter-3-72
                          ,input parameter-4-72
                          ,input parameter-5-72
                          ,input parameter-6-72
                          ,input parameter-7-72
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-prt-rec = ?.
    end.
    assign
      v-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
        end.
        else do:
          message
            "Документ не доступен"
            view-as alert-box error .
          undo, return error .
        end.
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE ui-on-02 :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define input  parameter sort-column-phrase as character no-undo .
  define input-output parameter v-query-was-opened as logical no-undo .
  define parameter buffer buf_goods for ub.goods .
  define parameter buffer buf_trn-doc for ub.trn-doc .
  do
  on error undo, return error return-value
  :
    case rs-parts :
      when 'все':U
      then do:
        assign
          frame Dialog-Frame:title = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
                                    + "   Объект : " + v-obj-type + " " + string (v-obj-code)
                                    + "   ВСЕ ПАРТИИ"
        .
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-74  as logical   no-undo .
define variable  l-filter-open-74    as logical   .
define variable  flt-rec-74       as recid     no-undo .
define variable  filter-name-74      as character no-undo .
define variable  where-phrase-74     as character no-undo .
define variable  sort-phrase-74      as character no-undo .
define variable  where-phrase-rus-74 as character no-undo .
define variable  sort-phrase-rus-74  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-74
  ,output filter-name-74
  ,output where-phrase-74
  ,output sort-phrase-74
  ,output where-phrase-rus-74
  ,output sort-phrase-rus-74
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-74
      ) no-error .
  assign
    l-filter-open-74 = false
  .
  if flt-rec-74 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-74 as character no-undo .
    define variable  parameter-3-74 as character no-undo .
    define variable  parameter-4-74 as character no-undo .
    define variable  parameter-5-74 as character no-undo .
    define variable  parameter-6-74 as character no-undo .
    define variable  parameter-7-74 as character no-undo .
      assign
      parameter-3-74 =
                              "FOR EACH parts"
      parameter-4-74 =
        (
          if ("parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.obj-type = v-obj-type             and parts.obj-code = v-obj-code             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )             " + " " + where-phrase-74) <> ""
          then                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.obj-type  = &1&7&1               and parts.obj-code  = &8               and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code )                + " " + where-phrase-74
          else "true"
        )
      parameter-5-74 = (" " + "" + " " + "")
      parameter-6-74 = if sort-phrase-74 = ''
                           then
        (
        " " + "use-index fifo" +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "use-index fifo" +
          " " + sort-column-phrase +
        " " + sort-phrase-74
        )
      parameter-7-74 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-74 =
          ("parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.obj-type = v-obj-type             and parts.obj-code = v-obj-code             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )             " + " " + where-phrase-74 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-parts:handle
                          ,input parameter-3-74
                          ,input parameter-4-74
                          ,input parameter-5-74
                          ,input parameter-6-74
                          ,input parameter-7-74
                          )
      .
      assign
        l-filter-open-74 = true
      .
    end.
    if l-filter-open-74 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          v-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-74 = false then do:
    open query br-parts for each parts no-lock
      where parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.obj-type = v-obj-type             and parts.obj-code = v-obj-code             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )
      use-index fifo
      indexed-reposition
  .
      assign
        v-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-prt-rec = recid( parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-parts:handle:get-buffer-handle(1) = (buffer parts:handle) then do:
      assign
      parameter-2-74 = (if p-find-next then "true":u else "false":u )
      parameter-4-74 =
        "where ":u +                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.obj-type  = &1&7&1               and parts.obj-code  = &8               and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code )                + " ":u + where-phrase-74 + " ":u + p-find-condition + " " + ""
      parameter-5-74 = "use-index fifo"
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input rowid(parts)
                          ,input logical(parameter-2-74)
                          ,input no-lock
                          ,input (buffer parts:handle)
                          ,input parameter-4-74
                          ,input parameter-5-74
                          ) no-error.
      .
      assign
        v-prt-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-74 = (if p-find-next then "true":u else "false":u )
      parameter-3-74 =  "FOR EACH parts"
      parameter-4-74 =
        (
          if ("parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.obj-type = v-obj-type             and parts.obj-code = v-obj-code             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )             " + " " + where-phrase-74) <> ""
          then                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.obj-type  = &1&7&1               and parts.obj-code  = &8               and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code )                + " " + where-phrase-74
          else "true"
        )
      parameter-5-74 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-74 = if sort-phrase-74 = ''
                           then
        (
        " " + "use-index fifo" +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + "use-index fifo" +
          " " + sort-column-phrase +
        " " + sort-phrase-74
        )
      parameter-7-74 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input logical(parameter-2-74)
                          ,input no-lock
                          ,input parameter-3-74
                          ,input parameter-4-74
                          ,input parameter-5-74
                          ,input parameter-6-74
                          ,input parameter-7-74
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-prt-rec = ?.
    end.
    assign
      v-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when 'остатки':U
      then do:
        assign
          frame Dialog-Frame:title = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
                                    + "   Объект : " + v-obj-type + " " + string (v-obj-code)
                                    + "   ФАКТ ОСТАТКИ"
        .
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-76  as logical   no-undo .
define variable  l-filter-open-76    as logical   .
define variable  flt-rec-76       as recid     no-undo .
define variable  filter-name-76      as character no-undo .
define variable  where-phrase-76     as character no-undo .
define variable  sort-phrase-76      as character no-undo .
define variable  where-phrase-rus-76 as character no-undo .
define variable  sort-phrase-rus-76  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-76
  ,output filter-name-76
  ,output where-phrase-76
  ,output sort-phrase-76
  ,output where-phrase-rus-76
  ,output sort-phrase-rus-76
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-76
      ) no-error .
  assign
    l-filter-open-76 = false
  .
  if flt-rec-76 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-76 as character no-undo .
    define variable  parameter-3-76 as character no-undo .
    define variable  parameter-4-76 as character no-undo .
    define variable  parameter-5-76 as character no-undo .
    define variable  parameter-6-76 as character no-undo .
    define variable  parameter-7-76 as character no-undo .
      assign
      parameter-3-76 =
                              "FOR EACH parts"
      parameter-4-76 =
        (
          if ("parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.obj-type = v-obj-type             and parts.obj-code = v-obj-code             and parts.rsrv-free = yes             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )             " + " " + where-phrase-76) <> ""
          then                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.obj-type  = &1&7&1               and parts.obj-code  = &8               and parts.rsrv-free = yes               and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code )                + " " + where-phrase-76
          else "true"
        )
      parameter-5-76 = (" " + "" + " " + "")
      parameter-6-76 = if sort-phrase-76 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-76
        )
      parameter-7-76 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-76 =
          ("parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.obj-type = v-obj-type             and parts.obj-code = v-obj-code             and parts.rsrv-free = yes             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )             " + " " + where-phrase-76 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-parts:handle
                          ,input parameter-3-76
                          ,input parameter-4-76
                          ,input parameter-5-76
                          ,input parameter-6-76
                          ,input parameter-7-76
                          )
      .
      assign
        l-filter-open-76 = true
      .
    end.
    if l-filter-open-76 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          v-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-76 = false then do:
    open query br-parts for each parts no-lock
      where parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.obj-type = v-obj-type             and parts.obj-code = v-obj-code             and parts.rsrv-free = yes             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )
      indexed-reposition
  .
      assign
        v-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-prt-rec = recid( parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-parts:handle:get-buffer-handle(1) = (buffer parts:handle) then do:
      assign
      parameter-2-76 = (if p-find-next then "true":u else "false":u )
      parameter-4-76 =
        "where ":u +                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.obj-type  = &1&7&1               and parts.obj-code  = &8               and parts.rsrv-free = yes               and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code )                + " ":u + where-phrase-76 + " ":u + p-find-condition + " " + ""
      parameter-5-76 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input rowid(parts)
                          ,input logical(parameter-2-76)
                          ,input no-lock
                          ,input (buffer parts:handle)
                          ,input parameter-4-76
                          ,input parameter-5-76
                          ) no-error.
      .
      assign
        v-prt-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-76 = (if p-find-next then "true":u else "false":u )
      parameter-3-76 =  "FOR EACH parts"
      parameter-4-76 =
        (
          if ("parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.obj-type = v-obj-type             and parts.obj-code = v-obj-code             and parts.rsrv-free = yes             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )             " + " " + where-phrase-76) <> ""
          then                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.obj-type  = &1&7&1               and parts.obj-code  = &8               and parts.rsrv-free = yes               and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code )                + " " + where-phrase-76
          else "true"
        )
      parameter-5-76 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-76 = if sort-phrase-76 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-76
        )
      parameter-7-76 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input logical(parameter-2-76)
                          ,input no-lock
                          ,input parameter-3-76
                          ,input parameter-4-76
                          ,input parameter-5-76
                          ,input parameter-6-76
                          ,input parameter-7-76
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-prt-rec = ?.
    end.
    assign
      v-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when 'свободно':U
      then do:
        assign
          frame Dialog-Frame:title = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
                                    + "   Объект : " + v-obj-type + " " + string (v-obj-code)
                                    + "   СВОБОДНО"
        .
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-78  as logical   no-undo .
define variable  l-filter-open-78    as logical   .
define variable  flt-rec-78       as recid     no-undo .
define variable  filter-name-78      as character no-undo .
define variable  where-phrase-78     as character no-undo .
define variable  sort-phrase-78      as character no-undo .
define variable  where-phrase-rus-78 as character no-undo .
define variable  sort-phrase-rus-78  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-78
  ,output filter-name-78
  ,output where-phrase-78
  ,output sort-phrase-78
  ,output where-phrase-rus-78
  ,output sort-phrase-rus-78
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-78
      ) no-error .
  assign
    l-filter-open-78 = false
  .
  if flt-rec-78 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-78 as character no-undo .
    define variable  parameter-3-78 as character no-undo .
    define variable  parameter-4-78 as character no-undo .
    define variable  parameter-5-78 as character no-undo .
    define variable  parameter-6-78 as character no-undo .
    define variable  parameter-7-78 as character no-undo .
      assign
      parameter-3-78 =
                              "FOR EACH parts"
      parameter-4-78 =
        (
          if ("parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.obj-type = v-obj-type             and parts.obj-code = v-obj-code             and parts.out-code = 'free-zone':U             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )             " + " " + where-phrase-78) <> ""
          then                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.obj-type  = &1&7&1               and parts.obj-code  = &8               and parts.out-code = &1&9&1                 and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code , 'free-zone':U)                + " " + where-phrase-78
          else "true"
        )
      parameter-5-78 = (" " + "" + " " + "")
      parameter-6-78 = if sort-phrase-78 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-78
        )
      parameter-7-78 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-78 =
          ("parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.obj-type = v-obj-type             and parts.obj-code = v-obj-code             and parts.out-code = 'free-zone':U             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )             " + " " + where-phrase-78 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-parts:handle
                          ,input parameter-3-78
                          ,input parameter-4-78
                          ,input parameter-5-78
                          ,input parameter-6-78
                          ,input parameter-7-78
                          )
      .
      assign
        l-filter-open-78 = true
      .
    end.
    if l-filter-open-78 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          v-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-78 = false then do:
    open query br-parts for each parts no-lock
      where parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.obj-type = v-obj-type             and parts.obj-code = v-obj-code             and parts.out-code = 'free-zone':U             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )
      indexed-reposition
  .
      assign
        v-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-prt-rec = recid( parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-parts:handle:get-buffer-handle(1) = (buffer parts:handle) then do:
      assign
      parameter-2-78 = (if p-find-next then "true":u else "false":u )
      parameter-4-78 =
        "where ":u +                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.obj-type  = &1&7&1               and parts.obj-code  = &8               and parts.out-code = &1&9&1                 and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code , 'free-zone':U)                + " ":u + where-phrase-78 + " ":u + p-find-condition + " " + ""
      parameter-5-78 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input rowid(parts)
                          ,input logical(parameter-2-78)
                          ,input no-lock
                          ,input (buffer parts:handle)
                          ,input parameter-4-78
                          ,input parameter-5-78
                          ) no-error.
      .
      assign
        v-prt-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-78 = (if p-find-next then "true":u else "false":u )
      parameter-3-78 =  "FOR EACH parts"
      parameter-4-78 =
        (
          if ("parts.artic = buf_goods.artic             and parts.prod-type = buf_goods.prod-type             and parts.prod-code = buf_goods.prod-code             and parts.obj-type = v-obj-type             and parts.obj-code = v-obj-code             and parts.out-code = 'free-zone':U             and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )             " + " " + where-phrase-78) <> ""
          then                substitute (               ' parts.artic = &1&2&1                and parts.prod-type = &1&3&1               and parts.prod-code = &4               and parts.obj-type  = &1&7&1               and parts.obj-code  = &8               and parts.out-code = &1&9&1                 and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )              ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code , 'free-zone':U)                + " " + where-phrase-78
          else "true"
        )
      parameter-5-78 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-78 = if sort-phrase-78 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-78
        )
      parameter-7-78 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input logical(parameter-2-78)
                          ,input no-lock
                          ,input parameter-3-78
                          ,input parameter-4-78
                          ,input parameter-5-78
                          ,input parameter-6-78
                          ,input parameter-7-78
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-prt-rec = ?.
    end.
    assign
      v-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      end.
      when 'документ':U
      then do:
        run ui-on-03 in this-procedure
          (input  p-open-query
          ,input  p-find-next
          ,input  p-find-condition
          ,input  sort-column-phrase
          ,input-output v-query-was-opened
          ,buffer buf_goods
          ,buffer buf_trn-doc
          ) .
      end.
    end.
  end.
END PROCEDURE.
PROCEDURE ui-on-03 :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define input  parameter sort-column-phrase as character no-undo .
  define input-output parameter v-query-was-opened as logical no-undo .
  define parameter buffer buf_goods for ub.goods .
  define parameter buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_clients for ub.clients .
  define variable v-doc-type as character .
  v-doc-type = "при" .
  enable
    b-sel
    f-date-to
    f-date-from
  with frame Dialog-Frame.
  display
    f-date-to
    f-date-from
  with frame Dialog-Frame.
  hide
    fi-label-filter-status
    fi-label-filter-object
    rs-one-all
    rs-parts
  in frame Dialog-Frame.
  do
  on error undo, return error return-value
  :
    if available buf_trn-doc
    then do:
      find first buf_clients no-lock where buf_clients.obj-type = buf_trn-doc.cli-type
                                       and buf_clients.obj-code = buf_trn-doc.cli-code
                                       .
      assign
        frame Dialog-Frame:title
          = "Артикул : " + buf_goods.artic + "   " + buf_goods.gds-name
          + "  и  Поставщик : " + buf_clients.obj-name + "   -  " + v-mode-name
      .
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-80  as logical   no-undo .
define variable  l-filter-open-80    as logical   .
define variable  flt-rec-80       as recid     no-undo .
define variable  filter-name-80      as character no-undo .
define variable  where-phrase-80     as character no-undo .
define variable  sort-phrase-80      as character no-undo .
define variable  where-phrase-rus-80 as character no-undo .
define variable  sort-phrase-rus-80  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-80
  ,output filter-name-80
  ,output where-phrase-80
  ,output sort-phrase-80
  ,output where-phrase-rus-80
  ,output sort-phrase-rus-80
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-80
      ) no-error .
  assign
    l-filter-open-80 = false
  .
  if flt-rec-80 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-80 as character no-undo .
    define variable  parameter-3-80 as character no-undo .
    define variable  parameter-4-80 as character no-undo .
    define variable  parameter-5-80 as character no-undo .
    define variable  parameter-6-80 as character no-undo .
    define variable  parameter-7-80 as character no-undo .
      assign
      parameter-3-80 =
                              "FOR EACH parts"
      parameter-4-80 =
        (
          if ("parts.artic = buf_goods.artic           and parts.prod-type = buf_goods.prod-type           and parts.prod-code = buf_goods.prod-code           and parts.obj-type = v-obj-type           and parts.obj-code = v-obj-code           and parts.in-code  = parts.out-code           and parts.doc-type = v-doc-type           and (( parts.supp-type = buf_trn-doc.cli-type and parts.supp-code = buf_trn-doc.cli-code) or parts.is-supp = no)           and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )           and parts.contract-code = buf_trn-doc.contract-code           and parts.fact-date >= f-date-from and parts.fact-date <= f-date-to           " + " " + where-phrase-80) <> ""
          then        substitute (       ' parts.artic = &1&2&1        and parts.prod-type = &1&3&1       and parts.prod-code = &4       and parts.obj-type  = &1&7&1       and parts.obj-code  = &8       and parts.in-code   = parts.out-code       and parts.doc-type  = &1&9&1
      and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )     ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code, v-doc-type ) +       substitute ( '           and (( parts.supp-type = &1&2&1 and parts.supp-code = &3 ) or parts.is-supp = no )           and parts.contract-code = &4           and parts.fact-date >= &5 and parts.fact-date <= &6
              ', chr(34) , buf_trn-doc.cli-type , buf_trn-doc.cli-code , buf_trn-doc.contract-code, f-date-from , f-date-to )        + " " + where-phrase-80
          else "true"
        )
      parameter-5-80 = (" " + "" + " " + "")
      parameter-6-80 = if sort-phrase-80 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-80
        )
      parameter-7-80 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-80 =
          ("parts.artic = buf_goods.artic           and parts.prod-type = buf_goods.prod-type           and parts.prod-code = buf_goods.prod-code           and parts.obj-type = v-obj-type           and parts.obj-code = v-obj-code           and parts.in-code  = parts.out-code           and parts.doc-type = v-doc-type           and (( parts.supp-type = buf_trn-doc.cli-type and parts.supp-code = buf_trn-doc.cli-code) or parts.is-supp = no)           and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )           and parts.contract-code = buf_trn-doc.contract-code           and parts.fact-date >= f-date-from and parts.fact-date <= f-date-to           " + " " + where-phrase-80 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-parts:handle
                          ,input parameter-3-80
                          ,input parameter-4-80
                          ,input parameter-5-80
                          ,input parameter-6-80
                          ,input parameter-7-80
                          )
      .
      assign
        l-filter-open-80 = true
      .
    end.
    if l-filter-open-80 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          v-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-80 = false then do:
    open query br-parts for each parts no-lock
      where parts.artic = buf_goods.artic           and parts.prod-type = buf_goods.prod-type           and parts.prod-code = buf_goods.prod-code           and parts.obj-type = v-obj-type           and parts.obj-code = v-obj-code           and parts.in-code  = parts.out-code           and parts.doc-type = v-doc-type           and (( parts.supp-type = buf_trn-doc.cli-type and parts.supp-code = buf_trn-doc.cli-code) or parts.is-supp = no)           and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )           and parts.contract-code = buf_trn-doc.contract-code           and parts.fact-date >= f-date-from and parts.fact-date <= f-date-to
      indexed-reposition
  .
      assign
        v-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-prt-rec = recid( parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-parts:handle:get-buffer-handle(1) = (buffer parts:handle) then do:
      assign
      parameter-2-80 = (if p-find-next then "true":u else "false":u )
      parameter-4-80 =
        "where ":u +        substitute (       ' parts.artic = &1&2&1        and parts.prod-type = &1&3&1       and parts.prod-code = &4       and parts.obj-type  = &1&7&1       and parts.obj-code  = &8       and parts.in-code   = parts.out-code       and parts.doc-type  = &1&9&1
      and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )     ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code, v-doc-type ) +       substitute ( '           and (( parts.supp-type = &1&2&1 and parts.supp-code = &3 ) or parts.is-supp = no )           and parts.contract-code = &4           and parts.fact-date >= &5 and parts.fact-date <= &6
              ', chr(34) , buf_trn-doc.cli-type , buf_trn-doc.cli-code , buf_trn-doc.contract-code, f-date-from , f-date-to )        + " ":u + where-phrase-80 + " ":u + p-find-condition + " " + ""
      parameter-5-80 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input rowid(parts)
                          ,input logical(parameter-2-80)
                          ,input no-lock
                          ,input (buffer parts:handle)
                          ,input parameter-4-80
                          ,input parameter-5-80
                          ) no-error.
      .
      assign
        v-prt-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-80 = (if p-find-next then "true":u else "false":u )
      parameter-3-80 =  "FOR EACH parts"
      parameter-4-80 =
        (
          if ("parts.artic = buf_goods.artic           and parts.prod-type = buf_goods.prod-type           and parts.prod-code = buf_goods.prod-code           and parts.obj-type = v-obj-type           and parts.obj-code = v-obj-code           and parts.in-code  = parts.out-code           and parts.doc-type = v-doc-type           and (( parts.supp-type = buf_trn-doc.cli-type and parts.supp-code = buf_trn-doc.cli-code) or parts.is-supp = no)           and (v-reserv-pl-code <> true or (v-reserv-pl-code = true and parts.pl-code = v-pl-code ) )           and parts.contract-code = buf_trn-doc.contract-code           and parts.fact-date >= f-date-from and parts.fact-date <= f-date-to           " + " " + where-phrase-80) <> ""
          then        substitute (       ' parts.artic = &1&2&1        and parts.prod-type = &1&3&1       and parts.prod-code = &4       and parts.obj-type  = &1&7&1       and parts.obj-code  = &8       and parts.in-code   = parts.out-code       and parts.doc-type  = &1&9&1
      and ( &5 <> true or ( &5 = true and parts.pl-code = &6 ) )     ', chr(34) , buf_goods.artic , buf_goods.prod-type , buf_goods.prod-code , v-reserv-pl-code , v-pl-code , v-obj-type , v-obj-code, v-doc-type ) +       substitute ( '           and (( parts.supp-type = &1&2&1 and parts.supp-code = &3 ) or parts.is-supp = no )           and parts.contract-code = &4           and parts.fact-date >= &5 and parts.fact-date <= &6
              ', chr(34) , buf_trn-doc.cli-type , buf_trn-doc.cli-code , buf_trn-doc.contract-code, f-date-from , f-date-to )        + " " + where-phrase-80
          else "true"
        )
      parameter-5-80 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-80 = if sort-phrase-80 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-80
        )
      parameter-7-80 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input logical(parameter-2-80)
                          ,input no-lock
                          ,input parameter-3-80
                          ,input parameter-4-80
                          ,input parameter-5-80
                          ,input parameter-6-80
                          ,input parameter-7-80
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-prt-rec = ?.
    end.
    assign
      v-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
      run gbl/getobjsrvhndl.p (input-output ObjSrv).
      EDOParSec = ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_trn-doc.obj-type, buf_trn-doc.obj-code).
      RUN gds-attr-value (
                          INPUT buf_goods.gds-code,
                          INPUT 'mark-type':U,
                          OUTPUT varvalue,
                          OUTPUT vartype
                          ).
      if varvalue > ""
      and EDOParSec:GetIsMarkingForType(varvalue)
      then do :
        disable b-chg with frame Dialog-Frame .
      end .
    end.
    else do:
      message
        "Документ не доступен"
        view-as alert-box error .
      undo, return error .
    end.
  end.
END PROCEDURE.
procedure partsxls:
DEFINE VARIABLE chExcelApplication      AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorkbook              AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorksheet             AS COM-HANDLE no-undo .
def var v-ind   as integer   no-undo .
def var cRow as character no-undo .
def var cRange  as character no-undo .
CREATE "Excel.Application" chExcelApplication no-error.
    if error-status :error then do:
        message
        "Ошибка при запуске Excel" skip
        error-status :get-message(1) skip
        view-as alert-box error .
        undo, return error .
    end.
assign
  chExcelApplication:Visible = false
  chWorkbook = chExcelApplication:Workbooks:Add ()
.
assign
  chWorkSheet = chExcelApplication:Sheets:Item (1)
  chExcelApplication:Interactive = false
  chExcelApplication:ScreenUpdating = false
  chWorkSheet:Name = "Партии"
  chWorkSheet:Range ("A1"):Value           = "№ п/п"
  chWorkSheet:Columns ("A":U):ColumnWidth  = 7
  chWorkSheet:Columns ("A":U):NumberFormat = fill ("#", 5) + "0"
  chWorkSheet:Range ("B1"):Value           = "Тип объекта"
  chWorkSheet:Columns ("B":U):ColumnWidth  = 5
  chWorkSheet:Columns ("B":U):NumberFormat = "@"
  chWorkSheet:Range ("C1"):Value           = "Код объекта"
  chWorkSheet:Columns ("C":U):ColumnWidth  = 10
  chWorkSheet:Columns ("C":U):NumberFormat = fill ("0", 9)
  chWorkSheet:Range ("D1"):Value           = "Артикул"
  chWorkSheet:Columns ("D":U):ColumnWidth  = 20
  chWorkSheet:Columns ("D":U):NumberFormat = "@"
  chWorkSheet:Range ("E1"):Value           = "Тип производителя"
  chWorkSheet:Columns ("E":U):ColumnWidth  = 5
  chWorkSheet:Columns ("E":U):NumberFormat = "@"
  chWorkSheet:Range ("F1"):Value           = "Код производителя"
  chWorkSheet:Columns ("F":U):ColumnWidth  = 10
  chWorkSheet:Columns ("F":U):NumberFormat = fill ("0", 9)
  chWorkSheet:Range ("G1"):Value           = "Номер ПН"
  chWorkSheet:Columns ("G":U):ColumnWidth  = 10
  chWorkSheet:Columns ("G":U):NumberFormat = "@"
  chWorkSheet:Range ("H1"):Value           = "Документ"
  chWorkSheet:Columns ("H":U):ColumnWidth  = 10
  chWorkSheet:Columns ("H":U):NumberFormat = "@"
  chWorkSheet:Range ("I1"):Value           = "Код партии"
  chWorkSheet:Columns ("I":U):ColumnWidth  = 5
  chWorkSheet:Columns ("I":U):NumberFormat = "@"
  chWorkSheet:Range ("J1"):Value           = "По док."
  chWorkSheet:Columns ("J":U):ColumnWidth  = 10
  chWorkSheet:Range ("K1"):Value           = "Факт"
  chWorkSheet:Columns ("K":U):ColumnWidth  = 10
  chWorkSheet:Range ("L1"):Value           = "Цена (Б.В.)"
  chWorkSheet:Columns ("L":U):ColumnWidth  = 12
  chWorkSheet:Range ("M1"):Value           = "Цена (руб.)"
  chWorkSheet:Columns ("M":U):ColumnWidth  = 12
  chWorkSheet:Range ("N1"):Value           = "Поставка"
  chWorkSheet:Columns ("N":U):ColumnWidth  = 5
  chWorkSheet:Columns ("N":U):NumberFormat = "@"
  chWorkSheet:Range ("O1"):Value           = "Тип поставщика"
  chWorkSheet:Columns ("O":U):ColumnWidth  = 5
  chWorkSheet:Columns ("O":U):NumberFormat = "@"
  chWorkSheet:Range ("P1"):Value           = "Код поставщика"
  chWorkSheet:Columns ("P":U):ColumnWidth  = 10
  chWorkSheet:Columns ("P":U):NumberFormat = fill ("0", 9)
  chWorkSheet:Range ("Q1"):Value           = "ГТД"
  chWorkSheet:Columns ("Q":U):ColumnWidth  = 10
  chWorkSheet:Columns ("Q":U):NumberFormat = "@"
  chWorkSheet:Range ("R1"):Value           = "Тип приобретения"
  chWorkSheet:Columns ("R":U):ColumnWidth  = 20
  chWorkSheet:Columns ("R":U):NumberFormat = "@"
  chWorkSheet:Range ("S1"):Value           = "Договор"
  chWorkSheet:Columns ("S":U):ColumnWidth  = 20
  chWorkSheet:Columns ("S":U):NumberFormat = "@"
  chWorkSheet:Range ("T1"):Value           = "Годен до"
  chWorkSheet:Columns ("T":U):ColumnWidth  = 20
  chWorkSheet:Columns ("T":U):NumberFormat = "@"
  chWorkSheet:Range ("U1"):Value           = "Складское место"
  chWorkSheet:Columns ("U":U):ColumnWidth  = 20
  chWorkSheet:Columns ("U":U):NumberFormat = "@"
  chWorkSheet:Range ("V1"):Value           = "НДС"
  chWorkSheet:Columns ("V":U):ColumnWidth  = 10
  chWorkSheet:Columns ("V":U):NumberFormat = "@"
  chWorkSheet:Range ("A1:V1"):Font:Bold = TRUE
  chWorkSheet:Range ("A1:V1"):Interior:ColorIndex = 35
  .
run waitfram-show
  (input "Экспорт в EXCEL. Ждите ..."
  ).
def var v-rid as recid no-undo .
assign
  v-rid = recid(parts)
  v-ind = 0
.
reposition br-parts to row 1.
do while available parts
:
  assign
    v-ind = v-ind + 1
  .
  if (v-ind modulo 10) = 0 then do:
    run waitfram-show
      (input "Экспортировано в EXCEL строк : " + string (v-ind)
      ).
  end.
  assign
    cRow = string (v-ind + 1)
    cRange = "A":U + cRow
    chWorkSheet:Range (cRange):Value = v-ind
    cRange = "B":U + cRow
    chWorkSheet:Range (cRange):Value = parts.obj-type
    cRange = "C":U + cRow
    chWorkSheet:Range (cRange):Value = parts.obj-code
    cRange = "D":U + cRow
    chWorkSheet:Range (cRange):Value = parts.artic
    cRange = "E":U + cRow
    chWorkSheet:Range (cRange):Value = parts.prod-type
    cRange = "F":U + cRow
    chWorkSheet:Range (cRange):Value = parts.prod-code
    cRange = "G":U + cRow
    chWorkSheet:Range (cRange):Value = parts.in-code
    cRange = "H":U + cRow
    chWorkSheet:Range (cRange):Value = parts.out-code
    cRange = "I":U + cRow
    chWorkSheet:Range (cRange):Value = parts.part-code
    cRange = "J":U + cRow
    chWorkSheet:Range (cRange):Value = parts.qnty
    cRange = "K":U + cRow
    chWorkSheet:Range (cRange):Value = parts.fact-qnty
    cRange = "L":U + cRow
    chWorkSheet:Range (cRange):Value = parts.price-base
    cRange = "M":U + cRow
    chWorkSheet:Range (cRange):Value = parts.price-rubl
    cRange = "N":U + cRow
    chWorkSheet:Range (cRange):Value = string(parts.is-supp, "да/нет")
    cRange = "O":U + cRow
    chWorkSheet:Range (cRange):Value = parts.supp-type
    cRange = "P":U + cRow
    chWorkSheet:Range (cRange):Value = parts.supp-code
    cRange = "Q":U + cRow
    chWorkSheet:Range (cRange):Value = parts.cst-code
    cRange = "U":U + cRow
    chWorkSheet:Range (cRange):Value = parts.pl-code
    cRange = "V":U + cRow
    chWorkSheet:Range (cRange):Value = parts.vat-pc
  .
  define variable v-purch-str as character no-undo .
  if parts.last-date <> ?
  then do:
    assign
      cRange = "T":U + cRow
      chWorkSheet:Range (cRange):Value = string(parts.last-date, '99/99/9999':U)
    .
  end.
  get next br-parts .
end.
run waitfram-hide in this-procedure .
assign
  chExcelApplication:Interactive = true
  chExcelApplication:ScreenUpdating = true
  chExcelApplication:Visible = true
.
RELEASE OBJECT chWorksheet NO-ERROR.
RELEASE OBJECT chWorkbook NO-ERROR.
chExcelApplication :QUIT().
RELEASE OBJECT  chExcelApplication  NO-ERROR.
if v-rid <> ? then do:
  reposition br-parts to recid v-rid .
end.
end procedure .
PROCEDURE UI-on-empty :
  define input  parameter p-open-query     as logical   no-undo .
  define input  parameter p-find-next      as logical   no-undo .
  define input  parameter p-find-condition as character no-undo .
  define variable sort-column-phrase as character no-undo .
  define variable v-query-was-opened as logical no-undo .
  define buffer buf_goods for ub.goods .
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-82  as logical   no-undo .
define variable  l-filter-open-82    as logical   .
define variable  flt-rec-82       as recid     no-undo .
define variable  filter-name-82      as character no-undo .
define variable  where-phrase-82     as character no-undo .
define variable  sort-phrase-82      as character no-undo .
define variable  where-phrase-rus-82 as character no-undo .
define variable  sort-phrase-rus-82  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-82
  ,output filter-name-82
  ,output where-phrase-82
  ,output sort-phrase-82
  ,output where-phrase-rus-82
  ,output sort-phrase-rus-82
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-82
      ) no-error .
  assign
    l-filter-open-82 = false
  .
  if flt-rec-82 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-82 as character no-undo .
    define variable  parameter-3-82 as character no-undo .
    define variable  parameter-4-82 as character no-undo .
    define variable  parameter-5-82 as character no-undo .
    define variable  parameter-6-82 as character no-undo .
    define variable  parameter-7-82 as character no-undo .
      assign
      parameter-3-82 =
                              "FOR EACH parts"
      parameter-4-82 =
        (
          if ("parts.artic = ''                     and parts.prod-type = ''                     and parts.prod-code = 0                     and parts.obj-type = ''                     and parts.obj-code = 0" + " " + where-phrase-82) <> ""
          then                substitute (               ' parts.artic = &1&&1                and parts.prod-type = &1&&1               and parts.prod-code = 0               and parts.obj-type  = &1&&1               and parts.obj-code  = 0              ', chr(34)  )                 + " " + where-phrase-82
          else "true"
        )
      parameter-5-82 = (" " + "" + " " + "")
      parameter-6-82 = if sort-phrase-82 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-82
        )
      parameter-7-82 =
        " indexed-reposition  "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-82 =
          ("parts.artic = ''                     and parts.prod-type = ''                     and parts.prod-code = 0                     and parts.obj-type = ''                     and parts.obj-code = 0" + " " + where-phrase-82 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query br-parts:handle
                          ,input parameter-3-82
                          ,input parameter-4-82
                          ,input parameter-5-82
                          ,input parameter-6-82
                          ,input parameter-7-82
                          )
      .
      assign
        l-filter-open-82 = true
      .
    end.
    if l-filter-open-82 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          v-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-82 = false then do:
    open query br-parts for each parts no-lock
      where parts.artic = ''                     and parts.prod-type = ''                     and parts.prod-code = 0                     and parts.obj-type = ''                     and parts.obj-code = 0
      indexed-reposition
  .
      assign
        v-query-was-opened = true
      .
  end.
end.
else do:
  assign
    v-prt-rec = recid( parts )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query br-parts:handle:get-buffer-handle(1) = (buffer parts:handle) then do:
      assign
      parameter-2-82 = (if p-find-next then "true":u else "false":u )
      parameter-4-82 =
        "where ":u +                substitute (               ' parts.artic = &1&&1                and parts.prod-type = &1&&1               and parts.prod-code = 0               and parts.obj-type  = &1&&1               and parts.obj-code  = 0              ', chr(34)  )                 + " ":u + where-phrase-82 + " ":u + p-find-condition + " " + ""
      parameter-5-82 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input rowid(parts)
                          ,input logical(parameter-2-82)
                          ,input no-lock
                          ,input (buffer parts:handle)
                          ,input parameter-4-82
                          ,input parameter-5-82
                          ) no-error.
      .
      assign
        v-prt-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-82 = (if p-find-next then "true":u else "false":u )
      parameter-3-82 =  "FOR EACH parts"
      parameter-4-82 =
        (
          if ("parts.artic = ''                     and parts.prod-type = ''                     and parts.prod-code = 0                     and parts.obj-type = ''                     and parts.obj-code = 0" + " " + where-phrase-82) <> ""
          then                substitute (               ' parts.artic = &1&&1                and parts.prod-type = &1&&1               and parts.prod-code = 0               and parts.obj-type  = &1&&1               and parts.obj-code  = 0              ', chr(34)  )                 + " " + where-phrase-82
          else "true"
        )
      parameter-5-82 = (" " + "" + " " + "" + " " + p-find-condition)
      parameter-6-82 = if sort-phrase-82 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-82
        )
      parameter-7-82 =
        " indexed-reposition  "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query br-parts:handle
                          ,input logical(parameter-2-82)
                          ,input no-lock
                          ,input parameter-3-82
                          ,input parameter-4-82
                          ,input parameter-5-82
                          ,input parameter-6-82
                          ,input parameter-7-82
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      v-prt-rec = ?.
    end.
    assign
      v-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
END PROCEDURE.
FUNCTION get-contract-prn-code RETURNS CHARACTER
  ( input p-recid as recid  ) :
  define buffer buf_parts for ub.parts  .
  find first buf_parts no-lock where recid(buf_parts) = p-recid no-error .
  if error-status :error then return "".
  define variable v-contract-prn-code-str as character no-undo .
  run contract-code-to-str in this-procedure
    (input  buf_parts.contract-code
    ,input  buf_parts.obj-type
    ,input  buf_parts.obj-code
    ,output v-contract-prn-code-str
    ) .
  return v-contract-prn-code-str .
END FUNCTION.
FUNCTION get-country-name RETURNS CHARACTER
  ( BUFFER buf_parts FOR parts ) :
  define variable v-country-name as character no-undo .
  run proc-get-country-name in this-procedure
    (buffer buf_parts
    ,output v-country-name
    ) .
  return v-country-name .
END FUNCTION.
FUNCTION get-mark RETURNS CHARACTER
  ( BUFFER buf_parts FOR parts ) :
  if lookup(string (recid (buf_parts)), del-list) > 0
  then do:
    return "*".
  end.
  return "".
END FUNCTION.
FUNCTION get-purch-code RETURNS CHARACTER
  ( BUFFER buf_parts FOR parts ) :
  define variable v-purch-code-str as character no-undo .
  run purch-code-to-str in this-procedure
    (input  buf_parts.purch-code
    ,output v-purch-code-str
    ) .
  return v-purch-code-str .
END FUNCTION.
