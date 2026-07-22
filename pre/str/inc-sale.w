DEFINE TEMP-TABLE tt-trn-doc NO-UNDO LIKE ub.trn-doc.
DEFINE NEW SHARED BUFFER X_chk-doc FOR ub.chk-doc.
define input parameter parparentproc AS WIDGET-HANDLE no-undo.
define input parameter p-mode as character no-undo .
define input parameter p-host-code like ub.clients.host-code no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-augetres as logical no-undo .
define input parameter p-is-tpsi-obj as logical no-undo .
define parameter buffer ink-doc for ub.inkas.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":u .
define variable vss-author      as character no-undo init "$Author: expertek $":u .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":u .
define variable vss-workfile    as character no-undo init "$Workfile: inc-sale.w $":u .
define variable vss-archive     as character no-undo init "$Archive: str/inc-sale.w $":u .
define variable vss-description as character no-undo init "Закачка чеков в продажу" .
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table lib-trn_ret-doc       no-undo like ub.trn-doc.
define temp-table lib-trn_ret-line      no-undo like ub.doc-line
  field cst-code                like ub.trn-doc.cst-code
  field part-code               like ub.parts.part-code
  .
define temp-table lib-trn_ret-line-attr no-undo like ub.doc-line-attr.
define temp-table lib-trn_ret-dtl       no-undo like ub.gds-dtl.
define temp-table lib-trn_ret-parts     no-undo like ub.parts.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION set-inkas-PS returns character(    input p-ps as character,
                                            input p-chk-amount as integer,
                                            input p-gds-amount as integer,
                                            input p-line-out as integer,
                                            input p-dtl-out as integer,
                                            input p-line-ret as integer,
                                            input p-dtl-ret as integer,
                                            input p-nf-chk-amount as integer,
                                            input p-nf-gds-amount as integer,
                                            input p-ps-where-rus as character
                                            ):
define variable v-ps as character no-undo .
define variable v-other as character no-undo .
v-other = p-ps.
entry(1, v-other, "@") = ''.
v-other = trim(v-other, "@").
v-PS = substitute('Кол-во_чеков &2&1строк_чеков &3&1товаров_расход &4&1признаков_расход &5&1товаров_возврат &6&1признаков_возврат &7&1'
                    , chr(4)
                    , p-chk-amount
                    , p-gds-amount
                    , p-line-out
                    , p-dtl-out
                    , p-line-ret
                    , p-dtl-ret).
v-ps = v-ps +  substitute("без_докум_чеков &1&2без_докум_строк_чеков &3&2&4@&5"
                            , p-nf-chk-amount
                            , chr(4)
                            , p-nf-gds-amount
                            , p-ps-where-rus
                            , v-other)
                    .
return v-ps.
END FUNCTION.
FUNCTION set-inkas-PS-simple returns character(
                                            input p-chk-amount as integer,
                                            input p-gds-amount as integer,
                                            input p-line-out as integer,
                                            input p-dtl-out as integer,
                                            input p-line-ret as integer,
                                            input p-dtl-ret as integer,
                                            input p-nf-chk-amount as integer,
                                            input p-nf-gds-amount as integer
                                            ):
define variable v-ps as character no-undo .
define variable v-str1 as character no-undo .
assign
  v-ps = fill( chr(32) +  chr(4), 9).
  v-str1 = ENTRY(1, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-chk-amount).
  ENTRY(1, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(2, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-gds-amount).
  ENTRY(2, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(3, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-line-out).
  ENTRY(3, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(4, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-dtl-out).
  ENTRY(4, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(5, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-line-ret).
  ENTRY(5, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(6, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-dtl-ret).
  ENTRY(5, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(7, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-nf-chk-amount).
  ENTRY(5, v-PS, chr(4)) = v-str1.
  v-str1 = ENTRY(8, v-PS, chr(4)).
  entry(2, v-str1, chr(32))  = string(p-nf-gds-amount).
  ENTRY(5, v-PS, chr(4)) = v-str1.
return v-ps.
END FUNCTION.
FUNCTION get-inkas-nf-PS-simple returns logical (
                                             input p-ps as character
                                            ,output p-gds-amount as integer
                                            ,output p-nf-gds-amount as integer
                                            ):
if num-entries(p-ps, chr(4)) >= 8 then do:
  assign
  p-gds-amount = integer(entry(2, ENTRY(2, p-PS, chr(4)), chr(32)))
  p-nf-gds-amount = integer(entry(2, ENTRY(8, p-PS, chr(4)), chr(32)))
  no-error .
end.
return not error-status:error .
END FUNCTION.
PROCEDURE get-inkas-PS:
define parameter buffer buf_inkas for ub.inkas.
define output parameter p-chk-amount as integer no-undo .
define output parameter p-gds-amount as integer no-undo .
define output parameter p-line-out as integer no-undo .
define output parameter p-dtl-out as integer no-undo .
define output parameter p-line-ret as integer no-undo .
define output parameter p-dtl-ret as integer no-undo .
define output parameter p-nf-chk-amount as integer no-undo .
define output parameter p-nf-gds-amount as integer no-undo .
define output parameter p-ps-where-rus as character no-undo .
define variable v-gds-amount as integer no-undo .
define variable v-nf-gds-amount as integer no-undo .
define buffer buf_sale-doc for ub.sale-doc.
for each buf_sale-doc no-lock where
        buf_sale-doc.inkas-code = buf_inkas.inkas-code
    and buf_sale-doc.order > 0:
  assign
  p-gds-amount = p-gds-amount + (if buf_sale-doc.in-inkas = yes
                                 or buf_sale-doc.doc-kind = 'trf':U
                                 then buf_sale-doc.gds-amount
                                 else 0)
  p-line-out = p-line-out  + (if buf_sale-doc.in-inkas = yes
                              and buf_sale-doc.dir = 1
                              then buf_sale-doc.tot-lines
                              else 0)
  p-dtl-out = p-dtl-out + (if buf_sale-doc.in-inkas = yes
                          and buf_sale-doc.dir = 1
                          then buf_sale-doc.tot-dtl
                          else 0)
  p-line-ret = p-line-ret  + (if buf_sale-doc.in-inkas = yes
                              and buf_sale-doc.dir = -1
                              then buf_sale-doc.tot-lines
                              else 0)
  p-dtl-ret = p-dtl-ret + (if buf_sale-doc.in-inkas = yes
                           and buf_sale-doc.dir = -1
                          then buf_sale-doc.tot-dtl
                          else 0)
  .
end.
if get-inkas-nf-PS-simple( input buf_inkas.ps
                          ,output v-gds-amount
                          ,output v-nf-gds-amount) then do:
  assign
  p-gds-amount = v-gds-amount
  p-nf-gds-amount = v-nf-gds-amount
  .
end.
assign
p-ps-where-rus = buf_inkas.sale-filter-rus
p-nf-chk-amount = buf_inkas.num-chk-nf
p-chk-amount = buf_inkas.num-chk
.
END PROCEDURE.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define SHARED temp-table tt0-info no-undo
field doc-code   like ub.trn-doc.doc-code
field artic      like ub.doc-line.artic
field prod-type  like ub.doc-line.prod-type
field prod-code  like ub.doc-line.prod-code
field prt-code  like ub.gds-dtl.prt-code
field obj-type   like ub.doc-line.obj-type
field obj-code   like ub.doc-line.obj-code
field error-message as character
field a-to-res as decimal
field was-res as decimal
field to-res as decimal
field is-res as decimal
field o-was-res as decimal
field o-to-res as decimal
field o-is-res as decimal
index pi is unique primary
obj-type
obj-code
artic
prod-type
prod-code
index iartic
artic
prod-type
prod-code
.
define SHARED temp-table tt0-doc-line no-undo like lib-trn_ret-line.
define SHARED temp-table tt0-gds-dtl  no-undo like ub.gds-dtl.
define SHARED temp-table tt0-parts    no-undo like ub.parts.
define SHARED temp-table temp-tpsi-clients  no-undo like ub.clients.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define buffer buf_sysconf for ub.sysconf.
DEFINE                BUFFER ret-doc    FOR ub.trn-doc.
DEFINE                BUFFER r-doc      FOR ub.chk-doc.
DEFINE                BUFFER r-gds      FOR ub.chk-gds.
define variable v-ref-rec  as recid no-undo .
define variable v-base-code  like ub.sysconf.base-code no-undo .
define variable v-cash-pay   like ub.sysconf.cash-pay  no-undo .
define variable temp-qnty like ub.gds-dtl.fact-qnty no-undo .
define variable temp-qnty-prts like ub.gds-dtl.fact-qnty no-undo .
define variable prev-code like ub.chk-gds.doc-code no-undo .
define variable for-shift-name AS character.
define variable for-shift-num like ub.chk-doc.shift-num.
define variable for-shift-date like ub.chk-doc.shift-date.
define variable cas-shft as logical no-undo init no.
define variable one-sale-per-day as logical no-undo .
define variable l-shift-on as logical no-undo init no.
define variable one-curs as logical no-undo init no.
define variable cas-curs as logical no-undo init no.
define variable prcl-spl as logical no-undo init no.
define variable pay-gds-algo as character no-undo .
define variable rdtaxcd  as INTEGER                  no-undo.
define variable exctaxcd  as INTEGER                  no-undo.
define variable factorrt as decimal no-undo.
define variable btltaxcd  as INTEGER                  no-undo.
define variable conf-attr as char no-undo.
define variable conf-par as char no-undo.
define variable par-type as char no-undo.
define variable cursh like ub.curr-shop.exch-rate init 0.
define variable cursh-scale like ub.curr-shop.exch-rate.
define variable cursh-date1 like ub.curr-shop.exch-date.
define variable cursh-date2 like ub.curr-shop.exch-date.
define variable cursh-time1 like ub.curr-shop.exch-time.
define variable cursh-time2 like ub.curr-shop.exch-time.
define variable v-curr-r-b as character no-undo .
define variable is-wth as logical   no-undo .
define variable glog as logical no-undo .
define variable old-doc-date   like ub.inkas.doc-date no-undo .
define variable old-shift-name AS character  no-undo .
define variable old-shift-date like ub.inkas.shift-date no-undo .
define variable old-shift-num  like ub.inkas.shift-num  no-undo .
define variable new-shift-name as character  no-undo .
define variable new-doc-date   like ub.inkas.doc-date no-undo .
define variable new-shift-date like ub.inkas.shift-date no-undo .
define variable new-shift-num  like ub.inkas.shift-num  no-undo .
define variable filter-point as character no-undo init "inc-sale":U .
define variable filter-point0 as character no-undo init "inc-sale":U .
define variable filter-label as character no-undo init "Закачка чеков в продажу":U .
define variable filter-label0 as character no-undo init "Закачка чеков в продажу":U .
define variable sort-column-name as character no-undo .
define variable v-filter-rec    as character no-undo .
define variable v-filter-name   as character no-undo .
define variable v-where-phrase  as character no-undo .
define variable v-sort-phrase   as character no-undo .
define variable v-where-phrase-rus  as character no-undo .
define variable v-sort-phrase-rus   as character no-undo .
define variable title0 as character no-undo init "Формирование  ОТЧЕТА  О  ПРОДАЖЕ".
define variable v-rid-list as character no-undo .
define variable v-can-edit-header as logical no-undo .
define variable v-attr-value as character no-undo .
define variable v-attr-type as character no-undo .
define variable ps-where-rus as character no-undo .
define variable ind as integer no-undo .
define variable v-shift-name               as character no-undo.
define variable v-shift-name-num           as character no-undo.
define variable v-param-type as character no-undo .
define variable v-value-character as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
assign
v-tth = buffer thbjattr_thbj-attr:table-handle .
define buffer lock-batchprocess for ub.batchprocess .
define buffer buf_sale-doc for ub.sale-doc.
DEFINE BUFFER cli-buf FOR ub.clients .
DEFINE BUTTON b-doc
     LABEL "&Документ"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод "
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-sch
     LABEL "&Фильтр"
     SIZE 11 BY 1.
DEFINE BUTTON r-agnt
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .87.
DEFINE BUTTON r-boss
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .87.
DEFINE BUTTON r-wrkr
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-acc"
     SIZE 3 BY .87.
DEFINE VARIABLE agnt-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE boss-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE chk-amount AS INTEGER FORMAT "->>>9":U INITIAL 0
     LABEL "ВСЕГО Чеков по продаже"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.
DEFINE VARIABLE curs-mes AS CHARACTER FORMAT "X(70)":U
      VIEW-AS TEXT
     SIZE 50 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE dtl-out AS INTEGER FORMAT "->>9":U INITIAL 0
     LABEL "Признаков"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.
DEFINE VARIABLE dtl-ret AS INTEGER FORMAT "->>9":U INITIAL 0
     LABEL "Признаков"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.
DEFINE VARIABLE f-chk-type AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 26 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-shift-name AS CHARACTER FORMAT "X(3)":U
     LABEL "№ смены"
     VIEW-AS FILL-IN
     SIZE 3 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE f-shift-num AS INTEGER FORMAT ">9":U INITIAL 1
     LABEL "Пор. смены"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE gds-amount AS INTEGER FORMAT "->>>>9":U INITIAL 0
     LABEL "строк чеков"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.
DEFINE VARIABLE line-out AS INTEGER FORMAT "->>9":U INITIAL 0
     LABEL "Товаров"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.
DEFINE VARIABLE line-ret AS INTEGER FORMAT "->>9":U INITIAL 0
     LABEL "Товаров"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.
DEFINE VARIABLE nf-chk-amount AS INTEGER FORMAT "->>>9":U INITIAL 0
     LABEL "невключенных в документы"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.
DEFINE VARIABLE nf-gds-amount AS INTEGER FORMAT "->>>>9":U INITIAL 0
     LABEL "строк чеков"
     VIEW-AS FILL-IN
     SIZE 5 BY 1
     BGCOLOR 3 FGCOLOR 14  NO-UNDO.
DEFINE VARIABLE time_ AS CHARACTER FORMAT "x(8)"
     LABEL "Время"
     VIEW-AS FILL-IN
     SIZE 10.3 BY 1
     BGCOLOR 8 FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE wrkr-name AS CHARACTER FORMAT "x(256)":U
      VIEW-AS TEXT
     SIZE 12 BY 1
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE RS-get-method AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Все свободные чеки по объекту с заданными условиями", "inc-salr",
"Чеки выборочно", "chk-docs"
     SIZE 70.5 BY 1.77 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 2 GRAPHIC-EDGE
     SIZE 96 BY 3.77
     BGCOLOR 8 FGCOLOR 0 .
DEFINE QUERY br-saledoc FOR
      buf_sale-doc SCROLLING.
DEFINE QUERY d-chk FOR
      tt-trn-doc SCROLLING.
DEFINE NEW SHARED QUERY QUERY-chk-doc FOR
                X_chk-doc SCROLLING.
DEFINE BROWSE br-saledoc
  QUERY br-saledoc DISPLAY
      buf_sale-doc.doc-code COLUMN-LABEL "№ док-та"
entry (lookup (buf_sale-doc.doc-kind, 'es,rs,rwo,trf,swo,ngs,rgs,vir':U + ',' + 'itr':U) + 1, ',' + 'касса продажа,касса возврат,Списание-по-Возврату,ТехПролив,Списание,Приход-Природный-Газ,Возврат-Природный-Газ,Перемещение-Вирт-Рез':U + ',' + 'ПриТехПрол':U ) COLUMN-LABEL "Операция"  format "X(45)" WIDTH 20
Buf_sale-doc.chr-office COLUMN-LABEL "Т/y" FORMAT "X(1)"
ENTRY(lookup(buf_sale-doc.ext-doc-type
             , chr(44) + 'ie,ee,ep,es,re,rs,we,vt,vp,iv,ev,rv,em,wm,im,ot,ap,mp,pc,io,eo':U + chr(44) + 'производство':U)
      , chr(44) + 'приход внешний,расход внешний,возврат пост.,касса продажа,возврат внешний,касса возврат,списание,инвентаризация,пересортица,приход внутренний,расход внутренний,возврат внутренний,расход  произв.,списан. произв.,приход  произв.,переоценка,коррекция учетных цен,корректировка отрицательных партий,смена типа приобретения,приход внутриобъектный,расход внутриобъектный':U  + chr(44) + 'производство':U) COLUMN-LABEL "Тип док-та"   format "X(20)"
(buf_sale-doc.cli-type + string(buf_sale-doc.cli-code)) COLUMN-LABEL "Тип/код контрагента" FORMAT "X(12)"
buf_sale-doc.cli-name COLUMN-LABEL "Контрагент" FORMAT "X(25)"
buf_sale-doc.chk-amount COLUMN-LABEL "Чеков"
buf_sale-doc.gds-amount COLUMN-LABEL "Строк чеков"
buf_sale-doc.fact-qnty  COLUMN-LABEL "Кол-во по включ.чекам!/факт. кол-во"
buf_sale-doc.doc-qnty   COLUMN-LABEL "Кол-во зарезервир.!/док. кол-во"
buf_sale-doc.tot-lines  COLUMN-LABEL "Товаров"
buf_sale-doc.tot-dtl    COLUMN-LABEL "Признаков"
    WITH NO-ROW-MARKERS SEPARATORS SIZE 98 BY 5.5
         FONT 4 ROW-HEIGHT-CHARS .58 FIT-LAST-COLUMN.
DEFINE FRAME d-chk
     b-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-sch AT ROW 1 COL 41
     b-doc AT ROW 1 COL 61
     b-help AT ROW 1 COL 95
     RS-get-method AT ROW 2.27 COL 7 NO-LABEL
     br-saledoc AT ROW 4.27 COL 1
     chk-amount AT ROW 10.5 COL 26.5 COLON-ALIGNED
     gds-amount AT ROW 10.5 COL 45.3 COLON-ALIGNED
     line-out AT ROW 10.5 COL 72 COLON-ALIGNED
     dtl-out AT ROW 10.5 COL 89 COLON-ALIGNED
     nf-chk-amount AT ROW 12.5 COL 26.5 COLON-ALIGNED
     nf-gds-amount AT ROW 12.5 COL 45.3 COLON-ALIGNED
     line-ret AT ROW 12.5 COL 72 COLON-ALIGNED
     dtl-ret AT ROW 12.5 COL 89 COLON-ALIGNED
     ub.chk-doc.shift-date AT ROW 14 COL 44 COLON-ALIGNED
          LABEL "&Дата смены (учета)" FORMAT "99/99/9999"
          VIEW-AS FILL-IN
          SIZE 11 BY 1
          BGCOLOR 8 FGCOLOR 4
     f-shift-name AT ROW 14 COL 67 COLON-ALIGNED
     f-shift-num AT ROW 14 COL 84.5 COLON-ALIGNED
     ub.chk-doc.chk-num AT ROW 15.13 COL 7 COLON-ALIGNED FORMAT "->>>>>>>9"
          VIEW-AS FILL-IN
          SIZE 7.3 BY 1
          BGCOLOR 8 FGCOLOR 4
     time_ AT ROW 15.13 COL 37.5 COLON-ALIGNED
     ub.chk-doc.office AT ROW 15.2 COL 60.3 COLON-ALIGNED FORMAT "X(8)"
          VIEW-AS FILL-IN
          SIZE 10.3 BY 1
          BGCOLOR 8 FGCOLOR 4
     f-chk-type AT ROW 15.2 COL 71 COLON-ALIGNED NO-LABEL
     ub.chk-doc.pay-desk AT ROW 16.37 COL 7 COLON-ALIGNED FORMAT ">>>9"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.chk-doc.cashier AT ROW 16.37 COL 21 COLON-ALIGNED FORMAT ">>>>9"
          VIEW-AS FILL-IN
          SIZE 6.3 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.chk-doc.sales-man AT ROW 16.37 COL 37.5 COLON-ALIGNED FORMAT ">>>>9"
          VIEW-AS FILL-IN
          SIZE 6.3 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.chk-doc.doc-code AT ROW 16.47 COL 50.5 COLON-ALIGNED
          LABEL "Номер" FORMAT "X(20)"
          VIEW-AS FILL-IN
          SIZE 15 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.chk-doc.netto AT ROW 17.5 COL 15.8 COLON-ALIGNED
          VIEW-AS FILL-IN
          SIZE 19 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.chk-doc.sub-discnt AT ROW 17.57 COL 50.6 COLON-ALIGNED
          LABEL "Сумма списания" FORMAT "->>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 14.9 BY 1
          BGCOLOR 8 FGCOLOR 4
     tt-trn-doc.wrkr AT ROW 18.13 COL 71.5 COLON-ALIGNED WIDGET-ID 18
          LABEL "К&л-к"
          VIEW-AS FILL-IN
          SIZE 9.8 BY 1
     r-wrkr AT ROW 18.27 COL 96.1 WIDGET-ID 14
     ub.chk-doc.tot-doc AT ROW 18.77 COL 15.8 COLON-ALIGNED
          LABEL "Сумма товарная" FORMAT "->>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 19.3 BY 1
          BGCOLOR 8 FGCOLOR 4
     ub.chk-doc.discnt AT ROW 18.83 COL 50.6 COLON-ALIGNED FORMAT "->>,>>>,>>>,>>9.99"
          VIEW-AS FILL-IN
          SIZE 14.9 BY 1
          BGCOLOR 8 FGCOLOR 4
     tt-trn-doc.agnt AT ROW 19.13 COL 71.5 COLON-ALIGNED WIDGET-ID 2
          LABEL "И&сп."
          VIEW-AS FILL-IN
          SIZE 9.8 BY 1
     r-agnt AT ROW 19.27 COL 96 WIDGET-ID 10
     tt-trn-doc.boss AT ROW 20.13 COL 71.5 COLON-ALIGNED WIDGET-ID 6
          LABEL "&М-р"
          VIEW-AS FILL-IN
          SIZE 9.8 BY 1
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .
DEFINE FRAME d-chk
     r-boss AT ROW 20.27 COL 96 WIDGET-ID 12
     wrkr-name AT ROW 18.13 COL 82 COLON-ALIGNED NO-LABEL WIDGET-ID 20
     agnt-name AT ROW 19.13 COL 82 COLON-ALIGNED NO-LABEL WIDGET-ID 4
     curs-mes AT ROW 20 COL 2 COLON-ALIGNED NO-LABEL
     boss-name AT ROW 20.13 COL 82 COLON-ALIGNED NO-LABEL WIDGET-ID 8
     "ВОЗВРАТ" VIEW-AS TEXT
          SIZE 8 BY 1 AT ROW 12.5 COL 56.5
          BGCOLOR 3 FGCOLOR 15
     "РАСХОД" VIEW-AS TEXT
          SIZE 8 BY 1 AT ROW 10.5 COL 56.5
          BGCOLOR 3 FGCOLOR 15
     "Проставлять в док-ты:" VIEW-AS TEXT
          SIZE 22 BY 1 AT ROW 17 COL 77 WIDGET-ID 16
          FGCOLOR 4
     RECT-1 AT ROW 10 COL 1.5
     SPACE(1.74) SKIP(7.47)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Формирование  ОТЧЕТА  О  ПРОДАЖЕ":L.
ASSIGN
       FRAME d-chk:SCROLLABLE       = FALSE.
ASSIGN
       f-shift-name:HIDDEN IN FRAME d-chk           = TRUE.
ASSIGN
       f-shift-num:HIDDEN IN FRAME d-chk           = TRUE.
ON END-ERROR OF FRAME d-chk
DO:
    apply "choose" to b-quit .
END.
ON LEAVE OF tt-trn-doc.agnt IN FRAME d-chk
DO:
  if input frame d-chk tt-trn-doc.agnt <> tt-trn-doc.agnt then do:
    run local-psn-chk in this-procedure ("agnt", "leave").
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-trn-doc.agnt IN FRAME d-chk
OR RETURN OF tt-trn-doc.agnt IN FRAME d-chk DO:
  run local-psn-chk in this-procedure ("agnt", "ret-mouse").
  apply "entry" to tt-trn-doc.boss in frame d-chk.
  return no-apply.
END.
ON CHOOSE OF b-doc IN FRAME d-chk
DO:
define variable v-doc-type as character no-undo .
define variable v-doc-code as character no-undo .
define variable glog as logical no-undo .
define buffer buf_fbr-doc for ub.fbr-doc.
  assign
  v-doc-type = buf_sale-doc.doc-type
  v-doc-code = buf_sale-doc.doc-code
 .
  if v-doc-type = 'производство':U then do:
    find first buf_fbr-doc no-lock where
              buf_fbr-doc.doc-code = v-doc-code  no-error .
    if not available buf_fbr-doc then do:
      message
      substitute("Не найден документ производства с № &1", v-doc-code)
      view-as alert-box error .
      return no-apply.
    end.
    run str/fbr-lkp.p (
                  input parparentproc
                , input recid(buf_fbr-doc)).
  end.
  else do:
    run str/showdoc.p
            (input parparentproc
            ,input v-doc-code
            ,input ""
            ,input ""
            ,input 0
            ,input ?
            ).
 end.
  APPLY "ENTRY" TO  br-saledoc.
end.
ON CHOOSE OF b-exit IN FRAME d-chk
DO:
    DO  on ERROR undo, return no-apply
                                  on STOP undo, return no-apply  :
        RUN IncProcStart in this-procedure ( input yes) .
    END.
END.
ON CHOOSE OF b-quit IN FRAME d-chk
DO:
  if p-mode = 'ИЗМЕНЕНИЕ':U then return "cancell":U .
  else return '':U.
END.
ON CHOOSE OF B-sch IN FRAME d-chk
DO:
  RUN proc-b-sch IN THIS-PROCEDURE NO-ERROR.
  IF ERROR-STATUS:ERROR  THEN RETURN NO-APPLY.
END.
ON LEAVE OF tt-trn-doc.boss IN FRAME d-chk
DO:
  if input frame d-chk tt-trn-doc.boss <> tt-trn-doc.boss then do:
    run local-psn-chk in this-procedure ("boss", "leave").
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-trn-doc.boss IN FRAME d-chk
OR RETURN OF tt-trn-doc.boss IN FRAME d-chk DO:
  run local-psn-chk in this-procedure ("boss", "ret-mouse").
  apply "entry" to tt-trn-doc.boss in frame d-chk.
  return no-apply.
END.
ON LEAVE OF f-shift-name IN FRAME d-chk
DO:
  run proc-shift-name in this-procedure no-error .
  if error-status:error then do:
    return no-apply.
  end.
  display
  integer(f-shift-name) @ f-shift-num
  with frame d-chk .
END.
ON VALUE-CHANGED OF f-shift-name IN FRAME d-chk
DO:
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf_trn-doc for ub.trn-doc.
  assign f-shift-name .
  assign
  v-shift-name  = f-shift-name
  f-shift-num  = integer(f-shift-name)
  ink-doc.shift-num = f-shift-num
  ink-doc.shift-date = ink-doc.doc-date
  ink-doc.shift-name = f-shift-name
  .
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = ink-doc.inkas-code
     and  buf_sale-doc.order > 0,
          first buf_trn-doc exclusive-lock where buf_trn-doc.doc-code = buf_sale-doc.doc-code:
    assign
    buf_trn-doc.shift-num = f-shift-num
    buf_trn-doc.shift-date = ink-doc.doc-date
    buf_trn-doc.shift-name = f-shift-name
    .
  end.
END.
ON CHOOSE OF r-agnt IN FRAME d-chk
DO:
  RUN local-psn-chk in this-procedure ("agnt", "button").
  apply "entry" to tt-trn-doc.agnt in FRAME d-chk.
  return no-apply.
END.
ON CHOOSE OF r-boss IN FRAME d-chk
DO:
    RUN local-psn-chk in this-procedure ("boss", "button").
  apply "entry" to tt-trn-doc.boss in FRAME d-chk.
  return no-apply.
END.
ON CHOOSE OF r-wrkr IN FRAME d-chk
DO:
  RUN local-psn-chk in this-procedure ("wrkr", "button").
  apply "entry" to tt-trn-doc.wrkr in FRAME d-chk.
  return no-apply.
END.
ON VALUE-CHANGED OF RS-get-method IN FRAME d-chk
DO:
   RUN IncProcStart in this-procedure ( input no).
   ASSIGN
   rs-get-method.
   CASE rs-get-method:
     WHEN "chk-docs" THEN DO:
        if not ink-doc.is-mand-sale-filter then
        DISABLE
        b-sch
        with FRAME d-chk.
        ASSIGN
        v-rid-list = "":U.
        run str/chk-docs.w (
                         input parparentproc
                        ,input ('b-sel,b-mark':U )
                        ,input "to-sale"
                        ,input ?
                        ,input ink-doc.obj-type
                        ,input ink-doc.obj-code
                        ,input ink-doc.inkas-code
                        ,input '':U
                        ,input 0
                        ,input  ?
                        ,input  ?
                        ,input 0
                        ,output v-rid-list) no-error.
         IF v-rid-list = "":U  THEN DO:
             ASSIGN
             rs-get-method = "inc-salr".
             ENABLE
             b-sch when (not ink-doc.is-mand-sale-filter or NOT can-find( FIRST ub.chk-doc WHERE ub.chk-doc.out-code = ink-doc.inkas-code ))
             with frame d-chk .
             DISPLAY rs-get-method
             with frame d-chk
             .
             RETURN NO-APPLY.
         END.
       END.
       WHEN "inc-salr":U THEN DO:
           v-rid-list = "":U.
           ENABLE
           b-sch when (NOT ink-doc.is-mand-sale-filter or can-find( FIRST ub.chk-doc WHERE ub.chk-doc.out-code = ink-doc.inkas-code ))
           with FRAME d-chk.
      END.
   END CASE.
END.
ON RETURN OF ub.chk-doc.shift-date IN FRAME d-chk
DO:
    apply "choose" to b-exit in frame d-chk .
END.
ON LEAVE OF tt-trn-doc.wrkr IN FRAME d-chk
DO:
  if input frame d-chk tt-trn-doc.wrkr <> tt-trn-doc.wrkr then do:
    run local-psn-chk in this-procedure ("wrkr", "leave").
  end.
END.
ON MOUSE-SELECT-DBLCLICK OF tt-trn-doc.wrkr IN FRAME d-chk
OR RETURN OF tt-trn-doc.wrkr IN FRAME d-chk DO:
  run local-psn-chk in this-procedure ("wrkr", "ret-mouse").
  apply "entry" to tt-trn-doc.agnt in frame d-chk.
  return no-apply.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-chk:PARENT eq ?
THEN FRAME d-chk:PARENT = ACTIVE-WINDOW.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-chk
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
on choose of b-help in frame d-chk
do:
  apply "help":u to frame d-chk .
end.
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-chk:width - 0.3
                fh            = frame d-chk:first-child
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
    if frame d-chk :height + p-change-value
        > decimal(session :work-area-height-pixels) / session :pixels-per-row
    then do:
      assign
        p-change-value = decimal(session :work-area-height-pixels) / session :pixels-per-row
                        - (frame d-chk :height-chars)
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
    if frame d-chk :height + p-change-value < v-diasize-orig-frame-height
    then do:
      assign
        p-change-value = v-diasize-orig-frame-height
                       - (frame d-chk :height-chars)
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
            frame d-chk :height = v-frame-height
          .
          if frame d-chk :scrollable = true
          then do:
            assign
              frame d-chk :virtual-height = v-frame-virtual-height
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-chk :scrollable = true
          then do:
            assign
              frame d-chk :virtual-height = v-frame-virtual-height
            .
          end.
          assign
            frame d-chk :height = v-frame-height
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
      v-frame-height = frame d-chk :height
      v-frame-virtual-height = frame d-chk :virtual-height
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
      v-field-group-handle = frame d-chk :first-child
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
    do with frame d-chk
    :
      hide v-diasize-resize-button .
      assign
        v-diasize-resize-button :row    = 1
        v-diasize-resize-button :column = 1
      .
    end.
    if p-change-value > 0
    then do:
      if frame d-chk :scrollable = true
      then do:
        assign
          frame d-chk :virtual-height = frame d-chk :virtual-height + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block .
        end.
      end.
      assign
        frame d-chk :height = frame d-chk :height + p-change-value
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
        frame d-chk :height = frame d-chk :height + p-change-value
        no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block .
      end.
      if frame d-chk :scrollable = true
      then do:
        assign
          frame d-chk :virtual-height = frame d-chk :virtual-height + p-change-value
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
          ,input  string(frame d-chk :height - v-diasize-orig-frame-height)
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
      (input  (p-new-height - frame d-chk :height)
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
    if frame d-chk :width + p-change-value >
        session :width-chars
    then do:
      assign
        p-change-value = session :width-chars - frame d-chk :width
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
    if frame d-chk :width + p-change-value < v-diasize-orig-frame-width
    then do:
      assign
        p-change-value = v-diasize-orig-frame-width
                       - frame d-chk :width
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
            frame d-chk :width = v-frame-width
          .
          if frame d-chk :scrollable = true
          then do:
            assign
              frame d-chk :virtual-width = v-frame-virtual-width
            .
          end.
          run diasize_position-resize-button in this-procedure .
        end.
        else do:
          if frame d-chk :scrollable = true
          then do:
            assign
              frame d-chk :virtual-width = v-frame-virtual-width
            .
          end.
          assign
            frame d-chk :width = v-frame-width
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
      v-frame-width = frame d-chk :width
      v-frame-virtual-width = frame d-chk :virtual-width
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
      v-field-group-handle = frame d-chk :first-child
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
    do with frame d-chk
    :
      hide v-diasize-resize-button .
      v-diasize-resize-button :row = 1.
      v-diasize-resize-button :column = 1.
    end.
    if p-change-value > 0
    then do:
      if frame d-chk :scrollable = true
      then do:
        assign
          frame d-chk :virtual-width = frame d-chk :virtual-width + p-change-value
          no-error .
        if error-status :error
        or error-status :get-message(1) <> ""
        then do:
          undo move_block, retry move_block.
        end.
      end.
      assign
        frame d-chk :width = v-frame-width + p-change-value
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
        frame d-chk :width = frame d-chk :width + p-change-value
      no-error .
      if error-status :error
      or error-status :get-message(1) <> ""
      then do:
        undo move_block, retry move_block.
      end.
      if frame d-chk :scrollable = true
      then do:
        assign
          frame d-chk :virtual-width = frame d-chk :virtual-width + p-change-value
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
          ,input  string(frame d-chk :width - v-diasize-orig-frame-width)
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
      (input  (p-new-width - frame d-chk :width)
      ,input  p-move-resize
      ) .
  end.
end procedure.
procedure diasize_position-resize-button :
  do with frame d-chk
  :
    hide v-diasize-resize-button .
    assign
      v-diasize-resize-button :row = frame d-chk :height - v-diasize-resize-button :height
                  - 1
                  - (frame d-chk :border-bottom-pixels / session :pixels-per-row)
      v-diasize-resize-button :col = frame d-chk :width - v-diasize-resize-button :width
                  - 1
                  - (frame d-chk :border-right-pixels / session :pixels-per-column)
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
on alt-enter of frame d-chk
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
      v-row-delta = v-new-row - frame d-chk :height
      v-col-delta = v-new-col - frame d-chk :width
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
            - frame d-chk :height-chars
        ,input true
        ) .
      run diasize_change-width in this-procedure
        (input session :width-chars
            - frame d-chk :width-chars
        ,input true
        ) .
      assign
        v-diasize-need-maximize = false
      .
    end.
    else do:
      run diasize_change-width in this-procedure
        (input v-diasize-orig-frame-width
            - frame d-chk :width-chars
        ,input true
        ) .
      run diasize_change-height in this-procedure
        (input v-diasize-orig-frame-height
            - frame d-chk :height-chars
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
      v-diasize-current-frame-width  = frame d-chk :width
      v-diasize-current-frame-height = frame d-chk :height
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
    do with frame d-chk
    :
      assign
        v-diasize-orig-frame-height = frame d-chk :height
        v-diasize-orig-frame-width  = frame d-chk :width
        v-diasize-browse-handle     = browse br-saledoc :handle
      .
      create button v-diasize-resize-button
      assign
        parent        = frame d-chk :first-child
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame d-chk:
    if p-filter-name > "" then do:
      assign
        frame d-chk:title
          = frame d-chk:title + "   ФИЛЬТР: " + p-filter-name.
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
ON WINDOW-CLOSE OF FRAME d-chk APPLY "END-ERROR":U TO SELF.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
  assign
  rdtaxcd  = integer('3':U)
  exctaxcd = integer('4':U)
  btltaxcd = integer('3':U).
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output v-curr-r-b
  )  .
  define variable v-is-wth as character no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-wth':u
  ,input  '':u
  ,input  '':u
  ,input  0
  ,input  '':u
  ,input  '':u
  ,input  '':u
  ,input  no
  ,output v-is-wth
  ,output par-type
  ) no-error .
  if error-status :error
  or par-type <> 'L':U
  or v-is-wth <> 'yes':u
  then do:
    assign
    is-wth = no
    .
  end.
  else do:
    is-wth = yes.
  end.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input ''
  ,input 0
  ,input 'nakl_par':U
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
      if thbjattr_thbj-attr.prop-code = 'factorrt' then factorrt = thbjattr_thbj-attr.property-value-integer .
  end.
  empty temp-table thbjattr_thbj-attr.
  if rdtaxcd > 0 then do:
      FIND FIRST ub.tax No-LOCK WHERE ub.tax.tax-code = rdtaxcd No-ERROR.
      if not avail ub.tax then do:
          message "Не найден дорожный налог!" view-as alert-box ERROR.
          return error.
      end.
  end.
  if exctaxcd > 0 then do:
      FIND FIRST tax No-LOCK WHERE tax.tax-code = exctaxcd No-ERROR.
      if not avail tax then do:
          message "Не найден акциз!" view-as alert-box ERROR.
          return error.
      end.
  end.
  if btltaxcd > 0 then do:
      FIND FIRST tax No-LOCK WHERE tax.tax-code = btltaxcd No-ERROR.
      if not avail tax then do:
          message "Не найден налог (доп.компонента для цены) стеклопосуды!" view-as alert-box ERROR.
          return error.
      end.
  end.
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  run adm/shattri.p (
      input "get":U
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  'get-chk':U
      ,input  "":U
      , output v-value-character
      , output v-value-date
      , output v-value-decimal
      , output v-value-integer
      , output v-value-logical
      , output v-param-type
      , INPUT-OUTPUT table-handle v-tth
      ) no-error .
  IF error-status:error then do:
     message
     substitute("Ошибка при получении опций закачки чеков НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , p-obj-type
              , p-obj-code
              , chr(10)
              , error-status:get-message(1)
              , return-value )
     view-as alert-box error .
     undo, return error .
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-obj-type
        and thbjattr_thbj-attr.obj-code = p-obj-code
        and thbjattr_thbj-attr.upper-prop-code = 'get-chk':U
        and thbjattr_thbj-attr.prop-code = 'cas-shft':U no-error.
  if available thbjattr_thbj-attr then do:
    cas-shft = thbjattr_thbj-attr.property-value-logical.
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-obj-type
        and thbjattr_thbj-attr.obj-code = p-obj-code
        and thbjattr_thbj-attr.upper-prop-code = 'get-chk':U
        and thbjattr_thbj-attr.prop-code = 'cas-curs':U no-error.
  if available thbjattr_thbj-attr then do:
    cas-curs = thbjattr_thbj-attr.property-value-logical.
  end.
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output l-shift-on
  )  .
  if l-shift-on and not cas-shft then do:
          message "Внимание! На текущем объекте требуется использование смен" skip
              "а настройка СМЕНЫ НА КАССЕ ( cas-shft ) выключена - это недопустимо." skip (2)
              view-as alert-box ERROR.
      return ERROR.
  end.
  run adm/shattri.p (
      input "get":U
      ,input  p-obj-type
      ,input  p-obj-code
      ,input  'autosale':U
      ,input  "":U
      ,output v-value-character
      ,output v-value-date
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-param-type
      ,INPUT-OUTPUT table-handle v-tth
      ) no-error .
  IF error-status:error then do:
     message
     substitute("Ошибка при получении опций работы с продажей НА ОБЪЕКТЕ &1&2:&3&4 &5"
              , p-obj-type
              , p-obj-code
              , chr(10)
              , error-status:get-message(1)
              , return-value )
     view-as alert-box error .
     undo, return error .
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-obj-type
        and thbjattr_thbj-attr.obj-code = p-obj-code
        and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
        and thbjattr_thbj-attr.prop-code = 'prcl-spl':U no-error.
  if available thbjattr_thbj-attr then do:
    prcl-spl = thbjattr_thbj-attr.property-value-logical.
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-obj-type
        and thbjattr_thbj-attr.obj-code = p-obj-code
        and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
        and thbjattr_thbj-attr.prop-code = 'one-curs':U no-error.
  if available thbjattr_thbj-attr then do:
    one-curs = thbjattr_thbj-attr.property-value-logical.
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-obj-type
        and thbjattr_thbj-attr.obj-code = p-obj-code
        and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
        and thbjattr_thbj-attr.prop-code = 'one-sale-per-day':U no-error.
  if available thbjattr_thbj-attr then do:
    assign
    one-sale-per-day = thbjattr_thbj-attr.property-value-logical
    .
  end.
  find first thbjattr_thbj-attr where
            thbjattr_thbj-attr.obj-type = p-obj-type
        and thbjattr_thbj-attr.obj-code = p-obj-code
        and thbjattr_thbj-attr.upper-prop-code = 'autosale':U
        and thbjattr_thbj-attr.prop-code = 'pay-gds-algo':U no-error.
  if available thbjattr_thbj-attr then do:
    assign
    pay-gds-algo = thbjattr_thbj-attr.property-value-character
    .
  end.
end.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
      ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  for each tt-trn-doc:
    delete tt-trn-doc.
  end.
  create tt-trn-doc.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
   if ink-doc.status_ = 'факт':U then do:
      message
      "Продажа уже закрыта !!"
      view-as alert-box error .
      undo main-block, return error .
    end.
    if ink-doc.is-mand-sale-filter then do:
      _lock-inc-sale:
      DO while ind < 100 :
        run gbl/lock-prc.p
          (input 'inkr':U
          ,input p-obj-code
          ,input 0
          ,input 0
          ,input p-obj-type
          ,input ""
          ,input ""
          ,input (
                  "Код объекта" + ",,," +
                  "Тип объекта" +  ",,,Закачка чеков в продажу"
                )
          ,input no
          ,buffer lock-batchprocess
          ) no-error .
        if not error-status:error then do:
          leave _lock-inc-sale.
        end.
        message
        substitute("Для объекта &1&2 включена настройка <В продажу чеки только по фильтру (если задан)>,&3" +
                  "поэтому одновременно на одном магазине можно работать только с одной продажей&3" +
                  "В настоящий момент ресурс закачки чеков в продажу занят&3" +
                  "Попробуйте позже"
                  , p-obj-type
                  , p-obj-code
                  , chr(10))
        view-as alert-box WARNING.
        undo main-block, return error .
      end.
    end.
    find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-code.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output v-base-code
  )  .
    FIND FIRST ub.shop WHERE ub.shop.obj-code = p-obj-code NO-LOCK .
    FIND FIRST ub.trn-doc WHERE ub.trn-doc.doc-code = ink-doc.inkas-code exclusive.
    FIND FIRST ret-doc WHERE ret-doc.doc-code = ub.trn-doc.out-code exclusive no-error .
    assign
    chk-amount = ink-doc.num-chk
    line-out = 0
    dtl-out = 0
    line-ret = 0
    dtl-ret = 0
    gds-amount = 0
    nf-chk-amount = 0
    nf-gds-amount = 0
    .
    ASSIGN
    tt-trn-doc.wrkr = trn-doc.wrkr
    tt-trn-doc.agnt = trn-doc.agnt
    tt-trn-doc.boss = trn-doc.boss
    .
  end.
  if p-mode = 'ПРОСМОТР':U then do:
    find first buf_sysconf no-lock where buf_sysconf.host-code = p-host-code.
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  p-host-code
  ,output v-base-code
  )  .
    FIND FIRST shop WHERE shop.obj-code = p-obj-code NO-LOCK .
    FIND FIRST trn-doc no-lock WHERE trn-doc.doc-code = ink-doc.inkas-code.
    FIND FIRST ret-doc no-lock WHERE ret-doc.doc-code = trn-doc.out-code no-error .
    ASSIGN
    tt-trn-doc.wrkr = trn-doc.wrkr
    tt-trn-doc.agnt = trn-doc.agnt
    tt-trn-doc.boss = trn-doc.boss
    .
  end.
  if ink-doc.is-mand-sale-filter then do:
    assign
    v-filter-name = ink-doc.sale-filter-name
    v-where-phrase = ink-doc.sale-filter
    v-where-phrase-rus = ink-doc.sale-filter-rus
    .
  end.
  if can-find( FIRST ub.chk-doc WHERE ub.chk-doc.out-code = ink-doc.inkas-code ) then do:
    FIND FIRST ub.chk-doc WHERE ub.chk-doc.out-code = ink-doc.inkas-code use-index sale
    NO-LOCK .
    assign
    time_ = string( ub.chk-doc.chk-time, "HH:MM" )
    cursh = ub.trn-doc.exch-rate
    cursh-scale = ub.trn-doc.exch-scale
    cursh-date1 = ub.chk-doc.chk-date
    cursh-time1 = ub.chk-doc.chk-time
    curs-mes = "В продажу чеки с курсом баз.вал. = " +
                        string(ub.trn-doc.exch-rate / ub.trn-doc.exch-scale, ">>,>>9.9999").
    run get-inkas-ps in this-procedure (
                                        buffer ink-doc
                                      , output chk-amount
                                      , output gds-amount
                                      , output line-out
                                      , output dtl-out
                                      , output line-ret
                                      , output dtl-ret
                                      , output nf-chk-amount
                                      , output nf-gds-amount
                                      , output ps-where-rus
                                      ).
  end.
  assign
  old-doc-date   =  ink-doc.doc-date
  old-shift-date =  ink-doc.shift-date
  old-shift-num  =  ink-doc.shift-num
  old-shift-nAME  =  ink-doc.shift-nAME
  .
  RUN Myenable in this-procedure .
  WAIT-FOR GO OF FRAME d-chk focus chk-doc.shift-date .
END.
RUN disable_UI.
PROCEDURE check-filter :
define variable v-dup as logical no-undo .
define buffer buf_inkas for ub.inkas.
do
on error undo, return error
:
  for each buf_Inkas no-lock where
          buf_inkas.obj-type = ink-doc.obj-type
      AND buf_inkas.obj-code = ink-doc.obj-code
      AND buf_inkas.status_  = 'новый':U
      and recid(buf_inkas) <> recid(ink-doc)
      :
    if buf_inkas.sale-filter = v-where-phrase then do:
      if cas-shft then do:
        if buf_inkas.shift-date = ink-doc.shift-date
        and buf_inkas.shift-nAME = ink-doc.shift-nAME then do:
          assign
          v-dup = yes.
        end.
      end.
      else do:
        if ub.shop.day-only then do:
          if buf_inkas.shift-date = ink-doc.shift-date then do:
            assign
            v-dup = yes.
          end.
        end.
        else do:
          assign
          v-dup = yes.
        end.
      end.
      if v-dup then do:
        message
        substitute("Для объекта &1&2 включена настройка <В продажу чеки только по фильтру (если задан)>,&3" +
                  "и найден отчет о продаже с №&4, полученный по фильтру&3<&5>&3" +
                  "поэтому ВЫ НЕ МОЖЕТЕ УСТАНОВИТЬ ФИЛЬТР &3<&5>&3 для продажи &6&3"
                  , ink-doc.obj-type
                  , ink-doc.obj-code
                  , chr(10)
                  , buf_inkas.inkas-code
                  , v-where-phrase-rus
                  , ink-doc.inkas-code
                  )
        view-as alert-box ERROR.
        undo, return error.
      end.
    end.
  end.
end.
end procedure.
PROCEDURE disable_UI :
  HIDE FRAME d-chk.
END PROCEDURE.
PROCEDURE display-chk :
DEFINE INPUT PARAMETER p-chk-amount AS INTEGER NO-UNDO.
define input parameter p-nf-chk-amount as integer no-undo .
DISPLAY
p-chk-amount @ chk-amount
p-nf-chk-amount @ nf-chk-amount
with frame d-chk.
if available X_chk-doc then
DISPLAY
X_chk-doc.cashier @ ub.chk-doc.cashier
X_chk-doc.shift-date @ ub.chk-doc.shift-date
X_chk-doc.chk-num    @ ub.chk-doc.chk-num
string( X_chk-doc.chk-time, "HH:MM" ) @ time_
X_chk-doc.office  @ ub.chk-doc.office
X_chk-doc.discnt @ ub.chk-doc.discnt
X_chk-doc.netto  @ ub.chk-doc.netto
X_chk-doc.doc-code  @ ub.chk-doc.doc-code
X_chk-doc.sub-discnt  @ ub.chk-doc.sub-discnt
X_chk-doc.pay-desk  @ ub.chk-doc.pay-desk
X_chk-doc.sales-man @ ub.chk-doc.sales-man
X_chk-doc.tot-doc   @ ub.chk-doc.tot-doc
entry (lookup (string(X_chk-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U)  @ f-chk-type
with frame d-chk.
END PROCEDURE.
PROCEDURE display-ink-doc :
define input parameter p-gds-amount  as integer no-undo .
define input parameter p-nf-gds-amount  as integer no-undo .
define input parameter p-line-out    as integer no-undo .
define input parameter p-line-ret    as integer no-undo .
define input parameter p-dtl-out     as integer no-undo .
define input parameter p-dtl-ret     as integer no-undo .
DISPLAY
p-dtl-out @ dtl-out
p-dtl-ret @ dtl-ret
p-line-out @ line-out
p-line-ret @ line-ret
p-gds-amount @ gds-amount
p-nf-gds-amount @ nf-gds-amount
with frame d-chk.
END PROCEDURE.
PROCEDURE Enable_UI :
  DISPLAY RS-get-method chk-amount gds-amount line-out dtl-out nf-chk-amount
          nf-gds-amount line-ret dtl-ret f-shift-name f-shift-num time_
          f-chk-type wrkr-name agnt-name curs-mes boss-name
      WITH FRAME d-chk.
  IF AVAILABLE tt-trn-doc THEN
    DISPLAY tt-trn-doc.wrkr tt-trn-doc.agnt tt-trn-doc.boss
      WITH FRAME d-chk.
  IF AVAILABLE ub.chk-doc THEN
    DISPLAY ub.chk-doc.shift-date ub.chk-doc.chk-num ub.chk-doc.office
          ub.chk-doc.pay-desk ub.chk-doc.cashier ub.chk-doc.sales-man
          ub.chk-doc.doc-code ub.chk-doc.netto ub.chk-doc.sub-discnt
          ub.chk-doc.tot-doc ub.chk-doc.discnt
      WITH FRAME d-chk.
  ENABLE b-exit RECT-1 b-quit B-sch b-doc b-help RS-get-method br-saledoc
         chk-amount gds-amount line-out dtl-out nf-chk-amount nf-gds-amount
         line-ret dtl-ret ub.chk-doc.shift-date f-shift-name f-shift-num
         ub.chk-doc.chk-num time_ ub.chk-doc.office f-chk-type
         ub.chk-doc.pay-desk ub.chk-doc.cashier ub.chk-doc.sales-man
         ub.chk-doc.doc-code ub.chk-doc.netto ub.chk-doc.sub-discnt
         tt-trn-doc.wrkr r-wrkr ub.chk-doc.tot-doc ub.chk-doc.discnt
         tt-trn-doc.agnt r-agnt tt-trn-doc.boss r-boss wrkr-name agnt-name
         curs-mes boss-name
      WITH FRAME d-chk.
  OPEN QUERY br-saledoc FOR EACH buf_sale-doc WHERE buf_sale-doc.inkas-code = ink-doc.inkas-code.
END PROCEDURE.
PROCEDURE IncProc :
define variable v-ii     as integer no-undo .
define variable v-ii-ok  as integer no-undo .
define variable v-rc-ii as integer no-undo .
define variable v-rc-max as integer no-undo .
DEFINE VARIABLE v-query-prepare AS CHARACTER NO-UNDO.
define variable v-error-status as logical no-undo .
define variable v-error-status-message as character no-undo .
if rs-get-method = "inc-salr":U
or ink-doc.is-mand-sale-filter
then do:
  ASSIGN
  v-query-prepare = substitute("for each X_chk-doc no-lock where ":U +
                            "X_chk-doc.obj-type = '&1'":U +
                            " AND X_chk-doc.obj-code = &2":U +
                            " AND X_chk-doc.out-code = ? ", p-obj-type, p-obj-code).
  if cas-shft then do:
    ASSIGN
    v-query-prepare = v-query-prepare +
                    substitute(" AND X_chk-doc.shift-date = &1 AND X_chk-doc.shift-num = &2"
                              , string(ink-doc.shift-date, "99/99/9999")
                              , ink-doc.shift-num).
  end.
  else do:
      if ub.shop.day-only then do:
          ASSIGN
          v-query-prepare = v-query-prepare +
                          substitute(" AND X_chk-doc.shift-date = &1", string(ink-doc.shift-date, "99/99/9999")).
                          .
      end.
      else do:
          ASSIGN
          v-query-prepare = v-query-prepare +
                          substitute(" AND X_chk-doc.shift-date <= &1", string(ink-doc.shift-date, "99/99/9999")).
      end.
  end.
  if rs-get-method = "chk-docs":U then do:
    assign
    v-query-prepare = v-query-prepare + substitute(" AND lookup(string(recid(X_chk-doc)), '&1') > 0 ", v-rid-list)
    .
  end.
  assign
  glog =
  QUERY query-chk-doc:QUERY-PREPARE(v-query-prepare + v-where-phrase) No-error.
  IF not glog
  THEN DO:
      MESSAGE
      "Ошибка - неверно выбран или построен ФИЛЬТР" skip
      error-status:get-message(1) skip
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  assign
  glog = QUERY query-chk-doc:query-OPEN() NO-ERROR.
  IF not glog
  THEN DO:
      MESSAGE
      "Неверно выбран или построен ФИЛЬТР"
      VIEW-AS ALERT-BOX ERROR.
      UNDO, RETURN ERROR.
  END.
  ASSIGN
  glog = QUERY query-chk-doc:GET-FIRST(no-LOCK) NO-ERROR.
  IF not glog THEN DO:
    message
    "Нет чеков, удовлетворяющих условиям закачки в продажу" skip
    view-as alert-box WARNING .
    RETURN.
  END.
  ASSIGN
  glog = QUERY query-chk-doc:GET-FIRST(exclusive-LOCK, no-wait) NO-ERROR.
  do while locked (X_chk-doc ) and available X_chk-doc:
     glog = QUERY query-chk-doc:GET-NEXT(exclusive-LOCK, no-wait) NO-ERROR.
  end.
end.
else do:
  assign
  v-rc-max = num-entries(v-rid-list).
  _v-rc:
  do while v-rc-ii < v-rc-max:
    assign
    v-rc-ii = v-rc-ii + 1
    .
    find first X_chk-doc exclusive-lock where
              recid(X_chk-doc) = integer(entry(v-rc-ii, v-rid-list))  no-wait no-error.
    if locked X_chk-doc or not available X_chk-doc then do:
       next _v-rc.
    end.
    else leave _v-rc.
  end.
  if not available X_chk-doc
  or locked(X_chk-doc) then do:
    message
    "Ни один из выбранных Вами чеков не может быть сейчас закачан в продажу" skip
    "Возможно они заняты другим пользователем"
    view-as alert-box Warning.
    return.
  end.
end.
run str/inc-salr.p (
                 input  parparentproc
                ,input  this-procedure
                ,input-output v-ii
                ,input-output v-ii-ok
                ,input (IF rs-get-method = "chk-docs":U and ink-doc.is-mand-sale-filter THEN no ELSE (if ink-doc.sale-filter = "":U then no else yes))
                ,input v-where-phrase-rus
                ,INPUT (IF rs-get-method = "chk-docs":U and not ink-doc.is-mand-sale-filter THEN v-rid-list ELSE "":U)
                ,input  p-obj-type
                ,input  p-obj-code
                ,input  v-curr-r-b
                ,input  is-wth
                ,input  cas-shft
                ,input  one-curs
                ,input  cas-curs
                ,input  cursh
                ,input  cursh-scale
                ,input  prcl-spl
                ,input  pay-gds-algo
                ,input  rdtaxcd
                ,input  exctaxcd
                ,input  factorrt
                ,input  btltaxcd
                ,input  gds-amount
                ,input  chk-amount
                ,input  line-out
                ,input  line-ret
                ,input  dtl-out
                ,input  dtl-ret
                ,input  nf-chk-amount
                ,input  nf-gds-amount
                ,input  shop.day-only
                ,input  old-doc-date
                ,input  old-shift-date
                ,input  old-shift-num
                ,input  new-doc-date
                ,input  new-shift-date
                ,input  new-shift-num
                ,buffer ink-doc
                ,buffer ub.trn-doc
                ,buffer ret-doc
                ,buffer buf_sysconf
    ) NO-ERROR.
assign
v-error-status = error-status:error
v-error-status-message = error-status:get-message(1)
.
enable
br-saledoc
with frame d-chk .
OPEN QUERY br-saledoc FOR EACH buf_sale-doc WHERE buf_sale-doc.inkas-code = ink-doc.inkas-code.
if not p-augetres then do:
  if v-ii = 0 then do:
    if v-error-status then
    message
    "Произошла ошибка при закачке чеков в продажу" skip
    v-error-status-message skip
    return-value
    view-as alert-box .
    else
    message
    "Нет чеков, удовлетворяющих условиям закачки в продажу" skip
    view-as alert-box WARNING .
  end.
  else do:
    message
    substitute("Просмотрено &1 чеков, успешно закачано в продажу &2", v-ii, v-ii-ok)
    view-as alert-box WARNING .
  end.
end.
END PROCEDURE.
PROCEDURE IncProcStart :
define input parameter p-run as logical no-undo .
if p-mode <> 'ИЗМЕНЕНИЕ':U then return.
define variable v-deleted as logical no-undo .
DEFINE VARIABLE screen-shift-num AS INTEGER NO-UNDO.
DEFINE VARIABLE screen-shift-name AS character NO-UNDO.
DEFINE VARIABLE screen-shift-date AS date NO-UNDO.
define variable v-dopi as integer no-undo .
define buffer buf_sale-doc for ub.sale-doc.
define buffer buf_trn-doc for ub.trn-doc.
ASSIGN
screen-shift-num = input frame d-chk f-shift-num
screen-shift-name = input frame d-chk f-shift-name
screen-shift-date = input frame d-chk ub.chk-doc.shift-date
.
if screen-shift-date <> ink-doc.doc-date OR
(cas-shft AND screen-shift-name <> ink-doc.shift-name) then do:
  glog = yes.
  message substitute("Вы поменяли предложенную дату отчета о продаже&1&2" +
                     "Вы хотите, чтобы в отчет попали чеки &3 &4 &5?"
                      ,(if cas-shft then "  И/ИЛИ № смены отчета о продаже"  else "" )
                      ,chr(10)
                      ,(if ub.shop.day-only then "ЗА " else "ПО ")
                      ,string(screen-shift-date, "99/99/9999")
                      ,(if cas-shft
                        then SUBSTITUTE(" за смену № &1 &2"
                                          ,screen-shift-name
                                          ,(if screen-shift-num = integer(screen-shift-name)
                                            then screen-shift-name
                                            else (screen-shift-name + "(" +
                                                  string(screen-shift-num) + ")"
                                                 )
                                           )
                                        )
                          else "")
                       )
  view-as alert-box question buttons YES-NO update glog.
  if NOT glog then return error .
  if one-sale-per-day then do:
    define variable v-shift-date as date no-undo .
    define variable v-shift-num as integer no-undo .
    define variable v-mes as character no-undo .
    define buffer buf_inkas for ub.inkas.
    v-shift-date = input frame d-chk chk-doc.shift-date.
    v-shift-num = ink-doc.shift-num.
    if l-shift-on
    or cas-shft
    then do:
      find first buf_inkas no-lock where
                buf_inkas.obj-type =  ink-doc.obj-type
            and buf_inkas.obj-code =  ink-doc.obj-code
            and buf_inkas.shift-date = v-shift-date
            and buf_inkas.shift-num = v-shift-num
            no-error.
      if available buf_inkas then do:
        v-mes = substitute("Нельзя создать вторую продажу за смену &1 П. &2 - запрещено параметрами"
                          , string(v-shift-date, "99/99/9999")
                          , v-shift-num
                            ).
      end.
    end.
    else do:
      find first buf_inkas no-lock where
                buf_inkas.obj-type =  ink-doc.obj-type
            and buf_inkas.obj-code =  ink-doc.obj-code
            and buf_inkas.doc-date = v-shift-date no-error.
      if available buf_inkas then do:
        v-mes = substitute("Нельзя создать вторую продажу за день &1 - запрещено параметрами"
                          , string(v-shift-date, "99/99/9999")
                          ).
      end.
    end.
  end.
  if available buf_inkas then do:
    message v-mes view-as alert-box error .
    return error .
  end.
  assign
  ink-doc.doc-date = input frame d-chk chk-doc.shift-date
  ink-doc.shift-date = ink-doc.doc-date
  ink-doc.shift-name = input frame d-chk f-shift-name
  .
end.
for each buf_sale-doc where
        buf_sale-doc.inkas-code = ink-doc.inkas-code
    and buf_sale-doc.order > 0,
    first buf_trn-doc exclusive-lock where
        buf_trn-doc.doc-code = buf_sale-doc.doc-code
ON ERROR UNDO, RETURN ERROR:
  assign
  buf_trn-doc.wrkr = tt-trn-doc.wrkr
  buf_trn-doc.agnt = tt-trn-doc.agnt
  buf_trn-doc.boss = tt-trn-doc.boss
  .
end.
if cas-shft then do:
  assign
  v-dopi = integer(f-shift-name)
  no-error .
  if error-status:error
  or v-dopi <= 0
  or v-dopi > 99
  then do:
    message
    "Номер смены должен быть числом >0!" view-as alert-box ERROR.
    return error.
  end.
  ASSIGN f-shift-name.
  assign
  f-shift-num = (if not l-shift-on then integer(f-shift-name) else f-shift-num)
  ink-doc.shift-num = f-shift-num
  ink-doc.shift-nAME = F-shift-nAME
  ink-doc.shift-date = ink-doc.doc-date
  new-doc-date      = ink-doc.doc-date
  new-shift-date      = ink-doc.shift-date
  new-shift-num       = ink-doc.shift-num
  new-shift-name       = ink-doc.shift-name
  .
  for each buf_sale-doc where
          buf_sale-doc.inkas-code = ink-doc.inkas-code
      and buf_sale-doc.order > 0,
      first buf_trn-doc exclusive-lock where
          buf_trn-doc.doc-code = buf_sale-doc.doc-code:
    assign
    buf_Trn-doc.shift-num = f-shift-num
    buf_Trn-doc.shift-name = f-shift-name
    buf_trn-doc.shift-date = ink-doc.doc-date
    .
  end.
end.
else do:
  assign
  ink-doc.shift-num = 0
  ink-doc.shift-date = ink-doc.doc-date
  new-doc-date      = ink-doc.doc-date
  new-shift-date      = ink-doc.shift-date
  new-shift-num       = 0
  new-shift-name      = '':U
  .
end.
 if shop.day-only then do:
   if can-find( first chk-doc where chk-doc.obj-type = p-obj-type and
                                   chk-doc.obj-code = p-obj-code and
                                   chk-doc.out-code = ? and
                                    chk-doc.shift-date < ink-doc.doc-date ) then  do:
      glog = yes.
      message substitute("Имеются чеки за более раннюю дату,&1" +
                         "не включенные ни в один отчет о продаже.&1" +
                         "Не забудьте создать отчет о продаже&1" +
                         "и включить в него эти чеки.&1&1" +
                         "Продолжать ?"
                         ,chr(10))
      view-as alert-box question buttons YES-NO update glog.
      if NOT glog then return error .
    end.
  end.
  else do:
    if can-find( first ub.inkas where ub.inkas.obj-type = p-obj-type and
                                 ub.inkas.obj-code = p-obj-code and
                                 ub.inkas.status_ = 'факт':U and
                                 ub.inkas.doc-date > ink-doc.doc-date ) then do:
      glog = yes.
      message substitute("Уже имеется отчет о продаже, содержащий чеки,&1"  +
                         "дата которых БОЛЬШЕ указанной Вами.&1"  +
                         "Вы уверены, что в базе появились новые чеки ?&1"
                        , chr(10))
      view-as alert-box question buttons YES-NO update glog.
      if NOT glog then  return error .
    end.
  end.
if NOT can-find( FIRST ub.chk-doc WHERE ub.chk-doc.out-code = ink-doc.inkas-code )  then  do:
  FIND LAST ub.curr-shop WHERE ub.curr-shop.obj-type = p-obj-type and
                            ub.curr-shop.obj-code = p-obj-code and
                            ub.curr-shop.curr-code = v-base-code and
                            ub.curr-shop.exch-date <= ink-doc.doc-date NO-LOCK no-error.
  if available ub.curr-shop then do:
    for each buf_sale-doc where
            buf_sale-doc.inkas-code = ink-doc.inkas-code
        and buf_sale-doc.order > 0,
      first buf_trn-doc exclusive-lock where
            buf_trn-doc.doc-code = buf_sale-doc.doc-code:
      assign
      buf_trn-doc.base-rate = curr-shop.exch-rate
      buf_trn-doc.base-scale = curr-shop.exch-scale
      .
      if v-curr-r-b = 'base':U then do:
        assign
        buf_trn-doc.exch-rate = buf_trn-doc.base-rate
        buf_trn-doc.exch-scale = buf_trn-doc.base-scale
        .
      end.
    end.
  end.
  else do:
    for each buf_sale-doc where
            buf_sale-doc.inkas-code = ink-doc.inkas-code
        and buf_sale-doc.order > 0,
      first buf_trn-doc exclusive-lock where
            buf_trn-doc.doc-code = buf_sale-doc.doc-code:
      assign
      buf_trn-doc.base-rate   = 1
      buf_trn-doc.base-scale = 1
      .
      if v-curr-r-b = 'base':U then do:
        assign
        buf_trn-doc.exch-rate = buf_trn-doc.base-rate
        buf_trn-doc.exch-scale = buf_trn-doc.base-scale
        .
      end.
    end.
    message substitute("Нет магазинного курса базовой валюты&1"  +
                      "на дату &2!&1" +
                      "Курс в накладных устанавливается равным 1."
                      ,chr(10)
                      ,string(ink-doc.doc-date, "99/99/9999"))
    view-as alert-box error .
  end.
  if ink-doc.is-mand-sale-filter and p-run then do:
    message
    substitute("Для объекта &1&2 включена настройка <В продажу чеки только по фильтру (если задан)>,&3" +
               "поэтому ТОЛЬКО СЕЙЧАС - пока продажа ПУСТА - ВЫ МОЖЕТЕ УСТАНОВИТЬ ИЛИ ИЗМЕНИТЬ ФИЛЬТР&3&3" +
               "УСТАНОВИТЬ или ИЗМЕНИТЬ ФИЛЬТР ?"
              , ink-doc.obj-type
              , ink-doc.obj-code
              , chr(10)
               )
    view-as alert-box QUESTION buttons YES-NO update glog.
    if glog then do:
      run proc-b-sch in this-procedure.
    end.
    else do:
    end.
    if v-where-phrase = "":U then do:
      message
      substitute("Фильтр НЕ УСТАНОВЛЕН&1" +
                "Закачка чеков в продажу НЕВОЗМОЖНА"
                 ,chr(10))
      view-as alert-box error .
      return error .
    end.
    run check-filter in this-procedure no-error .
    if error-status:error then undo, return error .
  end.
  if one-curs then do:
      run str/selcursh.w (
                     input parparentproc,
                     input ink-doc.obj-type,
                     input ink-doc.obj-code,
                     input v-base-code,
                     input ink-doc.doc-date,
                    input shop.day-only,
                    input-output cursh,
                    output cursh-scale,
                    input-output cursh-date1,
                    output cursh-date2,
                    input-output cursh-time1,
                    output cursh-time2) no-error.
    if error-status:error or cursh = 0 then return error.
      message
      substitute("В продажу попадут чеки с курсом базовой валюты &1 (масштаб &2)"
                , cursh
                , cursh-scale)
      view-as alert-box .
  end.
  assign
  ink-doc.shift-num = (if cas-shft then f-shift-num else 0)
  ink-doc.shift-name = (if cas-shft then f-shift-name else '')
  .
  for each buf_sale-doc where
           buf_sale-doc.inkas-code = ink-doc.inkas-code
      and  buf_sale-doc.order > 0,
      first buf_trn-doc exclusive-lock where
          buf_trn-doc.doc-code = buf_sale-doc.doc-code:
    assign
    buf_trn-doc.doc-date = ink-doc.doc-date
    buf_trn-doc.shift-num = (if cas-shft then f-shift-num else 0)
    buf_trn-doc.shift-name = (if cas-shft then f-shift-name else '')
    .
    If one-curs then do:
      assign
      buf_trn-doc.base-rate = cursh
      buf_trn-doc.base-scale = cursh-scale
      .
      if v-curr-r-b = 'base':U then do:
        assign
        buf_trn-doc.exch-rate = buf_trn-doc.base-rate
        buf_trn-doc.exch-scale = buf_trn-doc.base-scale
        .
      end.
    end.
  end.
end.
else do:
  FIND LAST curr-shop WHERE curr-shop.obj-type = p-obj-type and
                            curr-shop.obj-code = p-obj-code and
                            curr-shop.curr-code = v-base-code and
                            curr-shop.exch-date <= ink-doc.doc-date NO-LOCK no-error.
  if available curr-shop then do:
    for each buf_sale-doc where
            buf_sale-doc.inkas-code = ink-doc.inkas-code
         and buf_sale-doc.order > 0,
      first buf_trn-doc exclusive-lock where
            buf_trn-doc.doc-code = buf_sale-doc.doc-code:
      assign
      buf_trn-doc.base-rate = curr-shop.exch-rate
      buf_trn-doc.base-scale = curr-shop.exch-scale
      .
      if v-curr-r-b = 'base':U then do:
        assign
        buf_trn-doc.exch-rate = buf_trn-doc.base-rate
        buf_trn-doc.exch-scale = buf_trn-doc.base-scale
        .
      end.
    end.
  end.
  else do:
    for each buf_sale-doc where
            buf_Sale-doc.inkas-code = ink-doc.inkas-code
        and buf_sale-doc.order > 0,
      first buf_trn-doc exclusive-lock where
            buf_trn-doc.doc-code = buf_sale-doc.doc-code:
      assign
      buf_trn-doc.base-rate   = 1
      buf_trn-doc.base-scale = 1
      .
      if v-curr-r-b = 'base':U then do:
        assign
        buf_trn-doc.exch-rate = buf_trn-doc.base-rate
        buf_trn-doc.exch-scale = buf_trn-doc.base-scale
        .
      end.
    end.
    message "Нет магазинного курса базовой валюты" skip
            "на дату " ink-doc.doc-date " !" skip
            "Курс в накладных устанавливается равным 1."
    view-as alert-box error .
  end.
end.
if p-run then
run IncProc in this-procedure .
END PROCEDURE.
PROCEDURE local-psn-chk :
define input parameter p-man    as character no-undo.
define input parameter p-action as character no-undo.
DEFINE VARIABLE ref-list AS CHARACTER NO-UNDO.
if p-man = "wrkr" and p-action = "ret-mouse" then do:
  define variable v-ref-rec16   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-chk tt-trn-doc.wrkr <> ""
       and input frame d-chk tt-trn-doc.wrkr <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec16 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.wrkr
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-trn-doc.wrkr
            cli-buf.obj-name @ wrkr-name with frame d-chk.
    assign frame d-chk tt-trn-doc.wrkr.
  end.
  else display ? @ tt-trn-doc.wrkr
               ? @ wrkr-name with frame d-chk.
  apply "entry" to tt-trn-doc.agnt in frame d-chk.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-trn-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-chk.
  end.
  else display ? @ tt-trn-doc.wrkr ? @ wrkr-name with frame d-chk.
      return no-apply.
end.
if p-man = "wrkr" and p-action = "button" then do:
  define variable v-ref-rec17   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec17 = ( if available cli-buf then recid( cli-buf ) else ? ).
  v-ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec17 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.wrkr
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-trn-doc.wrkr
            cli-buf.obj-name @ wrkr-name with frame d-chk.
    assign frame d-chk tt-trn-doc.wrkr.
  end.
  else display ? @ tt-trn-doc.wrkr
               ? @ wrkr-name with frame d-chk.
  apply "entry" to tt-trn-doc.agnt in frame d-chk.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-trn-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-chk.
  end.
  else display ? @ tt-trn-doc.wrkr ? @ wrkr-name with frame d-chk.
      return no-apply.
end.
if p-man = "wrkr" and p-action = "leave" then do:
  define variable v-ref-rec18   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-trn-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-chk.
          assign frame d-chk tt-trn-doc.wrkr.
  end.
  else display ? @ tt-trn-doc.wrkr ? @ wrkr-name with frame d-chk.
end.
if p-man = "agnt" and p-action = "ret-mouse" then do:
  define variable v-ref-rec19   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-chk tt-trn-doc.agnt <> ""
       and input frame d-chk tt-trn-doc.agnt <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec19 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.agnt
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-trn-doc.agnt
            cli-buf.obj-name @ agnt-name with frame d-chk.
    assign frame d-chk tt-trn-doc.agnt.
  end.
  else display ? @ tt-trn-doc.agnt
               ? @ agnt-name with frame d-chk.
  apply "entry" to tt-trn-doc.boss
                            in frame d-chk.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-trn-doc.agnt cli-buf.obj-name @ agnt-name with frame d-chk.
  end.
  else display ? @ tt-trn-doc.agnt ? @ agnt-name with frame d-chk.
      return no-apply.
end.
if p-man = "agnt" and p-action = "button" then do:
  define variable v-ref-rec20   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec20 = ( if available cli-buf then recid( cli-buf ) else ? ).
  v-ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec20 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.agnt
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-trn-doc.agnt
            cli-buf.obj-name @ agnt-name with frame d-chk.
    assign frame d-chk tt-trn-doc.agnt.
  end.
  else display ? @ tt-trn-doc.agnt
               ? @ agnt-name with frame d-chk.
  apply "entry" to tt-trn-doc.boss
                            in frame d-chk.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-trn-doc.agnt cli-buf.obj-name @ agnt-name with frame d-chk.
  end.
  else display ? @ tt-trn-doc.agnt ? @ agnt-name with frame d-chk.
      return no-apply.
end.
if p-man = "agnt" and p-action = "leave" then do:
  define variable v-ref-rec21   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-trn-doc.agnt cli-buf.obj-name @ agnt-name with frame d-chk.
          assign frame d-chk tt-trn-doc.agnt.
  end.
  else display ? @ tt-trn-doc.agnt ? @ agnt-name with frame d-chk.
end.
if p-man = "boss" and p-action = "ret-mouse" then do:
  define variable v-ref-rec22   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    if input frame d-chk tt-trn-doc.boss <> ""
       and input frame d-chk tt-trn-doc.boss <> ? then
      message "Из справочника клиентов Вы должны выбрать человека.".
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec22 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.boss
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-trn-doc.boss
            cli-buf.obj-name @ boss-name with frame d-chk.
    assign frame d-chk tt-trn-doc.boss.
  end.
  else display ? @ tt-trn-doc.boss
               ? @ boss-name with frame d-chk.
  apply "entry" to  b-exit in frame d-chk.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-trn-doc.boss cli-buf.obj-name @ boss-name with frame d-chk.
  end.
  else display ? @ tt-trn-doc.boss ? @ boss-name with frame d-chk.
      return no-apply.
end.
if p-man = "boss" and p-action = "button" then do:
  define variable v-ref-rec23   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
  assign v-ref-rec23 = ( if available cli-buf then recid( cli-buf ) else ? ).
  v-ref-rec = ( if available cli-buf then recid( cli-buf ) else ? ).
  release cli-buf.
  if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then do:
    run ref/cli-all.w (  input parparentproc
                  ,  input "b-sel"
                  ,  input 'чел':U
                  ,  input ?
                  ,  input ?
                  ,  input v-ref-rec
                  ,  input ",,,,,,NO"
                  ,  input "lock-cli-type"
                  , output ref-list ) .
    assign v-ref-rec23 = integer( ref-list ).
    v-ref-rec = integer( ref-list ) .
    find cli-buf where recid (cli-buf) =
       v-ref-rec
       no-lock no-error.
    if not available cli-buf or ( NOT can-do( 'чел':U, cli-buf.obj-type ) ) then
      find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.boss
                           and cli-buf.obj-type = 'чел':U no-lock no-error.
  end.
  if available cli-buf and can-do( 'чел':U, cli-buf.obj-type ) then do:
    display cli-buf.obj-code @ tt-trn-doc.boss
            cli-buf.obj-name @ boss-name with frame d-chk.
    assign frame d-chk tt-trn-doc.boss.
  end.
  else display ? @ tt-trn-doc.boss
               ? @ boss-name with frame d-chk.
  apply "entry" to  b-exit in frame d-chk.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-trn-doc.boss cli-buf.obj-name @ boss-name with frame d-chk.
  end.
  else display ? @ tt-trn-doc.boss ? @ boss-name with frame d-chk.
      return no-apply.
end.
if p-man = "boss" and p-action = "leave" then do:
  define variable v-ref-rec24   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-trn-doc.boss cli-buf.obj-name @ boss-name with frame d-chk.
          assign frame d-chk tt-trn-doc.boss.
  end.
  else display ? @ tt-trn-doc.boss ? @ boss-name with frame d-chk.
end.
END PROCEDURE.
PROCEDURE MyEnable :
ASSIGN
rs-get-method = "inc-salr".
find first tt-trn-doc.
  define variable v-ref-rec25   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.wrkr
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display tt-trn-doc.wrkr with frame d-chk.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-chk tt-trn-doc.wrkr
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-trn-doc.wrkr cli-buf.obj-name @ wrkr-name with frame d-chk.
  end.
  else display ? @ tt-trn-doc.wrkr ? @ wrkr-name with frame d-chk.
  define variable v-ref-rec26   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.agnt
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display tt-trn-doc.agnt with frame d-chk.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-chk tt-trn-doc.agnt
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-trn-doc.agnt cli-buf.obj-name @ agnt-name with frame d-chk.
  end.
  else display ? @ tt-trn-doc.agnt ? @ agnt-name with frame d-chk.
  define variable v-ref-rec27   as recid no-undo .
  find cli-buf where cli-buf.obj-code = input frame d-chk tt-trn-doc.boss
                 and cli-buf.obj-type = 'чел':U no-lock no-error.
if not available cli-buf then do:
  display tt-trn-doc.boss with frame d-chk.
  find cli-buf no-lock where cli-buf.obj-code = input frame d-chk tt-trn-doc.boss
                         and cli-buf.obj-type = 'чел':U no-error.
end.
if available cli-buf then do:
      display cli-buf.obj-code @ tt-trn-doc.boss cli-buf.obj-name @ boss-name with frame d-chk.
  end.
  else display ? @ tt-trn-doc.boss ? @ boss-name with frame d-chk.
IF ink-doc.is-mand-sale-filter THEN DO:
    ASSIGN
    rs-get-method:radio-buttons IN FRAME d-chk =
    "Все свободные чеки по объекту с заданными условиями" +  chr(44) +
    "inc-salr":U + chr(44) +
    "Чеки выборочно - удовлетворяющие заданным условиям" + chr(44) +
    "chk-docs".
END.
DISPLAY
chk-amount
nf-chk-amount
dtl-ret
gds-amount
nf-gds-amount
time_
line-out
dtl-out
line-ret
curs-mes
rs-get-method
tt-trn-doc.wrkr
tt-trn-doc.agnt
tt-trn-doc.boss
WITH FRAME d-chk .
IF AVAILABLE ub.chk-doc and p-mode <> 'ПРОСМОТР':U THEN
DISPLAY
ub.chk-doc.shift-date
ub.chk-doc.discnt
ub.chk-doc.netto
ub.chk-doc.office
entry (lookup (string(chk-doc.chk-type), '1,6,8,69,96,14,15,16,36,17,11,12,13,40,101,106,108,169,196,114,115,116,117,111,112,136,113,201,206,208,301,306,2,3,4,5,7,43,44':U) + 1, ',' + 'Продажа,Возврат,Аннуляция,Списание,ВзврСпис,СбросТрнзкц,Перелив,ПеревТрнзкц,РазблТрнзкц,ТехПролив,Инвентаризация,Z-отчет,Закрытие_смены,Открытие_смены,_Продажа,_Возврат,_Аннуляция,_Списание,_ВзврСпис,_СбросТрнзкц,_Перелив,_ПеревТрнзкц,_ТехПролив,_Инвентаризация,_Z-отчет,_РазблТрнзкц,_Закрытие_смены,>Продажа,>Возврат,>Аннуляция,>>Продажа,>>Возврат,Инкассация,Касс_фонд,Перевод_опл,Расход_кассы,Декл_ден_ящ,Приход_Корр,Расход_Корр':U) @ f-chk-type
ub.chk-doc.sub-discnt
ub.chk-doc.tot-doc
ub.chk-doc.pay-desk
ub.chk-doc.cashier
ub.chk-doc.chk-num
ub.chk-doc.doc-code
ub.chk-doc.sales-man
WITH FRAME d-chk.
if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  assign
  b-quit:label = "&Выход"
  b-quit:column = 1
  .
end.
ENABLE
RECT-1
f-shift-name  when p-mode = 'ИЗМЕНЕНИЕ':U
b-help
b-doc WHEN p-mode = 'ПРОСМОТР':U
ub.chk-doc.shift-date  when p-mode = 'ИЗМЕНЕНИЕ':U
ub.chk-doc.discnt
chk-amount
nf-chk-amount
B-sch when (p-mode= 'ИЗМЕНЕНИЕ':U and not ink-doc.is-mand-sale-filter or NOT can-find( FIRST ub.chk-doc WHERE ub.chk-doc.out-code = ink-doc.inkas-code ))
dtl-ret
gds-amount
nf-gds-amount
time_
chk-doc.netto
chk-doc.office
f-chk-type
ub.chk-doc.sub-discnt
ub.chk-doc.tot-doc
line-out
ub.chk-doc.pay-desk
dtl-out
ub.chk-doc.cashier
line-ret
chk-doc.chk-num
b-exit when p-mode = 'ИЗМЕНЕНИЕ':U
b-quit
chk-doc.doc-code
chk-doc.sales-man
curs-mes
rs-get-method when (p-mode= 'ИЗМЕНЕНИЕ':U  and (ink-doc.is-mand-sale-filter = no  or not can-find(first ub.chk-doc no-lock where ub.chk-doc.out-code = ink-doc.inkas-code)))
br-saledoc
tt-trn-doc.wrkr WHEN p-mode = 'ИЗМЕНЕНИЕ':U
tt-trn-doc.agnt WHEN p-mode = 'ИЗМЕНЕНИЕ':U
tt-trn-doc.boss WHEN p-mode = 'ИЗМЕНЕНИЕ':U
r-wrkr WHEN p-mode = 'ИЗМЕНЕНИЕ':U
r-agnt WHEN p-mode = 'ИЗМЕНЕНИЕ':U
r-boss WHEN p-mode = 'ИЗМЕНЕНИЕ':U
WITH FRAME d-chk .
if p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  hide
  b-exit in frame d-chk .
end.
OPEN QUERY br-saledoc FOR EACH buf_sale-doc WHERE buf_sale-doc.inkas-code = ink-doc.inkas-code.
OPEN QUERY br-saledoc FOR EACH buf_sale-doc WHERE buf_sale-doc.inkas-code = ink-doc.inkas-code.
assign
f-Shift-name = if cas-shft or p-mode = 'ПРОСМОТР':U then ink-doc.shift-name else '':U
f-Shift-num = if cas-shft or p-mode = 'ПРОСМОТР':U then ink-doc.shift-num else 0
.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
  if ink-doc.is-mand-sale-filter
  and (ink-doc.sale-filter  <> '':U
      or
      ink-doc.sale-filter  <> ?)
      then do:
    RUN Set-filter-name IN THIS-PROCEDURE ( input v-filter-name).
  end.
  else if not can-find(first chk-doc no-lock where chk-doc.out-code = ink-doc.inkas-code) and not ink-doc.is-mand-sale-filter then do:
    run gbl/flt-get.p (
    input filter-point
    ,output v-filter-rec
    ,output v-filter-name
    ,output v-where-phrase
    ,output v-sort-phrase
    ,output v-where-phrase-rus
    ,output v-sort-phrase-rus
    ).
    RUN Set-filter-name IN THIS-PROCEDURE ( input v-filter-name).
  end.
  if l-shift-on OR can-find( FIRST chk-doc WHERE chk-doc.out-code = ink-doc.inkas-code )  then  do:
    DISABLE
    chk-doc.shift-date
    f-shift-num
    f-shift-name
    with frame d-chk.
  end.
end.
DISPLAY
f-shift-num when (cas-shft or (p-mode = 'ПРОСМОТР':U and ink-doc.shift-num <> 0))
f-shift-name when (cas-shft or (p-mode = 'ПРОСМОТР':U and ink-doc.shift-name <> ''))
ink-doc.doc-date @ chk-doc.shift-date
with frame d-chk.
DISABLE
chk-amount
nf-chk-amount
gds-amount
nf-gds-amount
line-out
dtl-out
line-ret
dtl-ret
WITH frame d-chk.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
  DISABLE
  chk-doc.cashier
  chk-doc.chk-num
  chk-doc.sales-man
  chk-doc.netto
  chk-doc.doc-code
  chk-doc.discnt
  time_
  chk-doc.sub-discnt
  chk-doc.office
  f-chk-type
  chk-doc.tot-doc
  chk-doc.pay-desk
  WITH frame d-chk.
  if  not cas-shft
  then
  HIDE
  f-shift-num
  f-shift-name
  in frame d-chk.
  HIDE b-doc
  in frame d-chk.
end.
else do:
  HIDE
  rs-get-method
  chk-doc.cashier
  chk-doc.chk-num
  chk-doc.sales-man
  chk-doc.netto
  chk-doc.doc-code
  chk-doc.discnt
  time_
  chk-doc.sub-discnt
  chk-doc.office
  f-chk-type
  chk-doc.tot-doc
  chk-doc.pay-desk
  in frame d-chk.
end.
END PROCEDURE.
PROCEDURE proc-b-sch :
assign
  tbl = 'chk-doc'
  join-tbl = 'X_chk-doc'
  fld = ""
  lab = ""
  spr = ""
  dim = '0'
  .
run fltfield-add in this-procedure('doc-code', 'Номер в базе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-date', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-time', '', 'time',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-type', 'Тип чека', 'receipt-code',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('office', 'Т или у', 'gds-type',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-date', 'Смена от', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-num', 'Порядок смен', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('shift-name', '№ смены', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('chk-num', 'Номер по кассе', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('pay-desk', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('cashier', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sales-man', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('tot-doc', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('discnt', '', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('sub-discnt', 'Списания', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('netto', 'Нетто сумма (выручка)', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
run fltfield-add in this-procedure('d-card', 'N дис.карты', '',
input-output fld, input-output lab, input-output spr, input-output dim)  no-error.
Filter-Block:
DO ON STOP    UNDO Filter-Block, LEAVE Filter-Block
    ON ERROR   UNDO Filter-Block, LEAVE Filter-Block
    ON END-KEY UNDO Filter-Block, LEAVE Filter-Block :
  run gbl/filter.w ( input parparentproc
                   , INPUT (filter-point + chr(4) + filter-label)
                   , INPUT tbl
                   , INPUT join-tbl
                   , INPUT fld
                   , INPUT lab
                   , INPUT spr
                   , INPUT dim ).
  RUN set-filter IN THIS-PROCEDURE ( input YES) no-error.
  if error-status:error then do:
    undo filter-block, return error .
  end.
END.
END PROCEDURE.
PROCEDURE proc-shift-name :
define variable v-dopi as integer no-undo .
assign
v-dopi = integer(f-shift-name:screen-value in frame d-chk )
no-error .
if error-status:error
or v-dopi <= 0
or v-dopi > 99 then do:
  message "Неверный номер смены!" view-as alert-box ERROR.
  return no-apply.
end.
END PROCEDURE.
PROCEDURE set-filter :
DEFINE INPUT PARAMETER p-on-off AS LOGICAL NO-UNDO.
define variable v-attr-value as character no-undo .
define variable v-deleted    as logical no-undo .
CASE p-on-off :
    WHEN yes THEN DO:
         run gbl/flt-get.p (
           input filter-point
          ,output v-filter-rec
          ,output v-filter-name
          ,output v-where-phrase
          ,output v-sort-phrase
          ,output v-where-phrase-rus
          ,output v-sort-phrase-rus
          ).
      if v-filter-rec <> ? then do:
        assign
        ink-doc.sale-filter = v-where-phrase
        ink-doc.sale-filter-name = v-filter-name
        ink-doc.sale-filter-rus  = v-where-phrase-rus
        .
      end.
      if ink-doc.is-mand-sale-filter then do:
        run check-filter in this-procedure no-error .
        if error-status:error then undo, return error .
        if v-filter-rec <> ? then do:
          assign
          ink-doc.sale-filter = v-where-phrase
          ink-doc.sale-filter-name = v-filter-name
          ink-doc.sale-filter-rus = v-where-phrase-rus
          .
        end.
        else do:
          assign
          ink-doc.sale-filter = ?
          ink-doc.sale-filter-name = ?
          ink-doc.sale-filter-rus = ?
          .
          assign
          v-where-phrase = "":U
          .
        end.
      end.
    END.
    WHEN no THEN DO:
      ASSIGN
      v-filter-rec = ?
      v-filter-name = "":U
      v-where-phrase = "":U
      v-sort-phrase = "":U
      v-where-phrase-rus = "":U
      v-sort-phrase-rus = "":U
      .
      if ink-doc.is-mand-sale-filter then do:
        assign
        ink-doc.sale-filter = ?
        ink-doc.sale-filter-name = ?
        ink-doc.sale-filter-rus = ?
        .
      end.
    END.
END CASE.
  assign
  frame d-chk:title = title0.
  if v-filter-rec <> ? then
  RUN Set-filter-name IN THIS-PROCEDURE ( input v-filter-name).
  else do:
    RUN Set-filter-name IN THIS-PROCEDURE ( input "":U).
  end.
END PROCEDURE.
