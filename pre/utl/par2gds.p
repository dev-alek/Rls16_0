block-level on error undo, throw.
define input  parameter p-artic       as character no-undo .
define input  parameter p-prod-type   as character no-undo .
define input  parameter p-prod-code   as integer   no-undo .
define input  parameter p-obj-type    as character no-undo .
define input  parameter p-obj-code    as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: par2gds.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/par2gds.p $":U .
define variable vss-description as character no-undo init "Выравнивание остатков по партиям св зоны".
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
define buffer buf_parts   for ub.parts  .
define buffer buf_gds-obj for ub.gds-obj  .
define variable v-parts-fact-qnty     as decimal no-undo .
define variable v-parts-free-qnty     as decimal no-undo .
define variable v-parts-cli-qnty      as decimal no-undo .
define variable v-parts-add-fact-qnty as decimal no-undo .
define variable v-parts-add-free-qnty as decimal no-undo .
define variable ppr as integer   no-undo .
for each buf_gds-obj  exclusive-lock  where
         buf_gds-obj.artic     = p-artic          and
         buf_gds-obj.prod-type = p-prod-type and
         buf_gds-obj.prod-code = p-prod-code and
         buf_gds-obj.obj-type  = p-obj-type  and
         buf_gds-obj.obj-code  = p-obj-code
         :
    assign
      v-parts-fact-qnty = 0
      v-parts-free-qnty = 0
      v-parts-cli-qnty  = 0
    .
    for each buf_parts share-lock
      where buf_parts.obj-type  = buf_gds-obj.obj-type
        and buf_parts.obj-code  = buf_gds-obj.obj-code
        and buf_parts.artic     = buf_gds-obj.artic
        and buf_parts.prod-type = buf_gds-obj.prod-type
        and buf_parts.prod-code = buf_gds-obj.prod-code
        and buf_parts.status_   = no
        and buf_parts.rsrv-free = yes
    on error undo , leave
    :
      assign
        v-parts-add-fact-qnty = 0
        v-parts-add-free-qnty = 0
      .
      if buf_parts.out-code = 'out-zone':U
      then do:
        leave .
      end.
      if buf_parts.out-code = 'free-zone':U
      then do:
        assign
          v-parts-add-fact-qnty = v-parts-add-fact-qnty + buf_parts.fact-qnty
          v-parts-add-free-qnty = v-parts-add-free-qnty + buf_parts.qnty
        .
      end.
      else do:
        define buffer buf_trn-doc for ub.trn-doc .
        find first buf_trn-doc no-lock
          where buf_trn-doc.doc-code = buf_parts.out-code
          no-error .
        if not available buf_trn-doc
        then do:
          leave .
        end.
        if buf_parts.in-code <> buf_parts.out-code
        then do:
          assign
            v-parts-add-fact-qnty = v-parts-add-fact-qnty + abs(buf_parts.fact-qnty)
          .
        end.
        if buf_trn-doc.doc-type = 'инв':U
        then do:
          if buf_parts.qnty > 0
          then do:
            leave .
          end.
          if buf_parts.in-code <> buf_parts.out-code
          then do:
            assign
              v-parts-add-free-qnty = v-parts-add-free-qnty + abs(buf_parts.qnty)
            .
          end.
        end.
        else do:
          if buf_parts.qnty < 0
          then do:
            leave .
          end.
          if buf_parts.in-code = buf_parts.out-code
          then do:
            assign
              v-parts-add-free-qnty = v-parts-add-free-qnty - abs(buf_parts.qnty)
            .
          end.
        end.
      end.
      assign
        v-parts-fact-qnty = v-parts-fact-qnty + v-parts-add-fact-qnty
        v-parts-free-qnty = v-parts-free-qnty + v-parts-add-free-qnty
      .
      end.
    assign
      buf_gds-obj.fact-qnty = v-parts-fact-qnty
      buf_gds-obj.free-qnty = v-parts-free-qnty
    .
    find first ub.prt-obj  exclusive-lock
         where ub.prt-obj.artic     = buf_gds-obj.artic and
               ub.prt-obj.prod-type = buf_gds-obj.prod-type and
               ub.prt-obj.prod-code = buf_gds-obj.prod-code and
               ub.prt-obj.obj-type  = buf_gds-obj.obj-type and
               ub.prt-obj.obj-code  = buf_gds-obj.obj-code
               no-error .
    if available ub.prt-obj then do:
    assign
      ub.prt-obj.fact-qnty = v-parts-fact-qnty
      ub.prt-obj.free-qnty = v-parts-free-qnty
    .
    end.
end.
