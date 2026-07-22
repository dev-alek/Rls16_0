block-level on error undo, throw.
define variable vss-revision    as character no-undo initial "$Revision: 3950c9e6675a, 2392, rls $":U .
define variable vss-author      as character no-undo initial "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo initial "$Date: Ср июн 10 21:13:44 2020 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: clearlib.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: gbl/clearlib.p $":U .
define variable vss-description as character no-undo initial "Удаление всех библиотек":U .
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
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define new global shared variable g#lib-farh as handle no-undo .
define new global shared variable g#libtfarh as handle no-undo .
define new global shared variable g#libofarh as handle no-undo .
define new global shared variable g#libfarhp as handle no-undo .
define new global shared variable g#libfarpo as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-calc as handle no-undo .
define new global shared variable g#libbcrcn as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#trdcalib as handle no-undo.
  define new global shared variable g#lib-rvs as handle no-undo.
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#lib-nws as handle no-undo .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#libthpos as handle no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#libchkvl as handle no-undo .
function libchkvl_right-netto-sign returns integer ( input p-chk-type as integer) in G#libchkvl.
define variable vss-include-info5 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#fr-lib as handle no-undo.
define variable vss-include-info6 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#sb-lib as handle no-undo.
define variable vss-include-info7 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#disp-lib as handle no-undo.
define variable vss-include-info8 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#eventlib as handle no-undo.
define new global shared variable g#lib-Matrix  as handle no-undo .
define new global shared variable g#lib-gate as handle no-undo .
define new global shared variable g#lib-log as handle no-undo .
define new global shared variable g#libobj  as handle no-undo .
do
on error undo, return error return-value
:
  run delete-procedure in this-procedure
    (input g#library
    ) .
  run delete-procedure in this-procedure
    (input g#library2
    ) .
  run delete-procedure in this-procedure
    (input g#lib-trn
    ) .
  run delete-procedure in this-procedure
    (input g#lib-trn2
    ) .
  run delete-procedure in this-procedure
    (input g#lib-trn3
    ) .
  run delete-procedure in this-procedure
    (input g#lib-trn4
    ) .
  run delete-procedure in this-procedure
    (input g#lib-farh
    ) .
  run delete-procedure in this-procedure
    (input g#libtfarh
    ) .
  run delete-procedure in this-procedure
    (input g#libofarh
    ) .
  run delete-procedure in this-procedure
    (input g#libfarhp
    ) .
  run delete-procedure in this-procedure
    (input g#libfarpo
    ) .
  run delete-procedure in this-procedure
    (input g#lib-calc
    ) .
  run delete-procedure in this-procedure
    (input g#libbcrcn
    ) .
  run delete-procedure in this-procedure
    (input g#trdcalib
    ) .
  run delete-procedure in this-procedure
    (input g#lib-rvs
    ) .
  run delete-procedure in this-procedure
    (input g#lib-rwds
    ) .
  run delete-procedure in this-procedure
    (input g#lib-nws
    ) .
  run delete-procedure in this-procedure
    (input g#attr-lib
    ) .
  run delete-procedure in this-procedure
    (input g#libthpos
    ) .
  run delete-procedure in this-procedure
    (input g#libchkvl
    ) .
  run delete-procedure in this-procedure
    (input g#fr-lib
    ) .
  run delete-procedure in this-procedure
    (input g#sb-lib
    ) .
  run delete-procedure in this-procedure
    (input g#disp-lib
    ) .
  run delete-procedure in this-procedure
    (input g#eventlib
    ) .
run delete-procedure in this-procedure
    (input g#lib-Matrix
    ) .
  run delete-procedure in this-procedure
    (input g#lib-gate
    ) .
  run delete-procedure in this-procedure
    (input g#lib-log
    ) .
  run delete-procedure in this-procedure
    (input g#libobj
    ) .
end.
procedure delete-procedure :
  define input  parameter p-proc-handle as handle    no-undo .
  do
  on error undo, return error return-value
  :
    if valid-handle(p-proc-handle) then do:
      apply 'delete':u to p-proc-handle .
      delete procedure p-proc-handle .
    end.
  end.
end procedure.
