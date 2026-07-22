block-level on error undo, throw.
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-recid as recid no-undo .
define output parameter loc-ord-num as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: ord-shoo.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cus/ord-shoo.p $":U .
define variable vss-description as character no-undo init "—оздание щепки заказа".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure proc-ord-code :
define input  parameter  p-type as character no-undo .
define input  parameter  v-cntxt-db-num   as integer   no-undo .
define input  parameter  v-cntxt-obj-type as character no-undo .
define input  parameter  v-cntxt-obj-code as integer   no-undo .
define input  parameter  p-i-doc    as character no-undo .
define output parameter  p-ord-doc  as character no-undo .
define variable          v-idop     as character no-undo .
  do
  on error undo, return error return-value
  :
case p-type :
    when "main-no-ver" then do:
      if  (v-cntxt-db-num <> 0) then
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
      else
        p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
    end.
    when "main" then do:
          do while true:
          if  (v-cntxt-db-num <> 0) then
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (v-cntxt-obj-code, ">>>>9")) + substring (v-cntxt-obj-type, (if g#language = "RUS" then 1 else 2), 1).
          else
            p-ord-doc = trim (string (next-value (s-ord-doc, ub), ">>>>>>>>>9")) + "-".
          if not can-find (ub.ord-doc where ub.ord-doc.doc-code = p-ord-doc no-lock) then leave.
          End.
    end.
    when "chip" then do:
      assign
        v-idop = p-i-doc .
      do while true :
        if index (v-idop , ".") = 0 then
          v-idop  = replace (v-idop , "-", "-1.").
        else
          v-idop  =
          substring (v-idop , 1, index (v-idop, "-")) +
          string (integer (substring (v-idop, index (v-idop, "-") + 1, index (v-idop, ".") - index (v-idop, "-") - 1)) + 1) +
          substring (v-idop, index (v-idop, ".")).
        if not can-find (ub.ord-doc where ub.ord-doc.doc-code = v-idop no-lock) then leave.
      end.
      assign
        p-ord-doc = v-idop.
    end.
end case.
  end.
end procedure.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define buffer buf_ord-doc for ub.ord-doc.
define buffer buf_ord-line for ub.ord-line.
define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
define buffer buf_ord-line-rcv for ub.ord-line-rcv.
define buffer   buf2-ord-doc-rcv  for ub.ord-doc-rcv .
define buffer   buf2-doc-line     for ub.doc-line     .
define temp-table temp-ord-line  no-undo like ub.ord-line.
find first  buf_ord-doc no-lock where recid (buf_ord-doc) = p-recid no-error .
if error-status :error then return .
define variable v-qnty as decimal no-undo .
define variable v-sum-qnty as decimal no-undo .
define variable kk as integer init 0 no-undo .
define variable k-q      as decimal init 0 no-undo .
define variable k-s-rubl as decimal init 0 no-undo .
define variable k-s-base as decimal init 0 no-undo .
define variable v-temp as character no-undo .
define buffer new_ord-doc for ub.ord-doc.
define buffer new_ord-line for ub.ord-line.
for each temp-ord-line
    on error undo, return error :
    delete temp-ord-line .
end.
for each buf_ord-line no-lock where
         buf_ord-line.doc-code = buf_ord-doc.doc-code
     :
        v-qnty = 0 .
        v-sum-qnty = 0 .
        for each buf_ord-line-rcv no-lock
            where buf_ord-line-rcv.doc-code = buf_ord-doc.doc-code and
                  buf_ord-line-rcv.artic     = buf_ord-line.artic and
                  buf_ord-line-rcv.prod-type = buf_ord-line.prod-type and
                  buf_ord-line-rcv.prod-code = buf_ord-line.prod-code,
                  first buf2-ord-doc-rcv no-lock where
                        buf2-ord-doc-rcv.rcv-code =  buf_ord-line-rcv.rcv-code and
                        buf2-ord-doc-rcv.doc-code =  buf_ord-line-rcv.doc-code    ,
                  each ub.ord-chain no-lock where
                            ub.ord-chain.doc-code = buf2-ord-doc-rcv.rcv-code and
                            ub.ord-chain.doc-type = 'rcv'                  and
                            ub.ord-chain.rel-doc-type = 'trn'              ,
                  first buf2-doc-line no-lock where
                        buf2-doc-line.doc-code     =  ub.ord-chain.rel-doc-code  and
                        buf2-doc-line.artic        =  buf_ord-line-rcv.artic    and
                        buf2-doc-line.prod-code    =  buf_ord-line-rcv.prod-code and
                        buf2-doc-line.prod-type    =  buf_ord-line-rcv.prod-type
                  :
                  v-sum-qnty = v-sum-qnty + buf2-doc-line.fact-qnty .
        end.
        if (v-sum-qnty < buf_ord-line.qnty) and
          (buf_ord-line.qnty - v-sum-qnty) <> ? then do:
          kk = kk + 1.
          create temp-ord-line .
          buffer-copy buf_ord-line to temp-ord-line
          assign
            temp-ord-line.qnty      = buf_ord-line.qnty - v-sum-qnty
            temp-ord-line.cli-qnty  = temp-ord-line.qnty / temp-ord-line.cli-base-rate
            temp-ord-line.sum-rubl  = temp-ord-line.qnty  * temp-ord-line.price-rubl
            temp-ord-line.sum-base  = temp-ord-line.qnty  * temp-ord-line.price-base
          .
          assign
            k-q      = k-q + temp-ord-line.qnty
            k-s-rubl = k-s-rubl + temp-ord-line.sum-rubl
            k-s-base = k-s-base + temp-ord-line.sum-base
          .
        end.
end.
if kk > 0 then do:
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
run proc-ord-code in this-procedure
 (input   'chip' ,
  input   v-cntxt-db-num ,
  input   buf_ord-doc.obj-type ,
  input   buf_ord-doc.obj-code ,
  input   buf_ord-doc.doc-code ,
  output  loc-ord-num
 ) .
  create new_ord-doc.
  BUFFER-COPY buf_ord-doc to new_ord-doc
  assign
    new_ord-doc.doc-code = loc-ord-num
    new_ord-doc.doc-date = today
    new_ord-doc.status_  = 'новый':U
    new_ord-doc.flag_    = true
    new_ord-doc.creid    = v-cntxt-userid
    new_ord-doc.qnty     = k-q
    new_ord-doc.sum-rubl = k-s-rubl
    new_ord-doc.sum-base = k-s-base
    new_ord-doc.tot-lines = kk
      .
  for each temp-ord-line
      on error undo, return error :
    create new_ord-line.
    BUFFER-COPY temp-ord-line to new_ord-line
    assign
     new_ord-line.doc-code = loc-ord-num
    .
  end.
  message "Ќе все количество товаров удалось распределить из заказа " buf_ord-doc.doc-code skip
           "ќстальное количество товара перенесено в новый заказ "  loc-ord-num
            view-as alert-box .
end.
