BLOCK-LEVEL ON ERROR UNDO, THROW.
define output parameter this-proc-hndl as handle no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Метод возвращает можно ли добавить данный товар в спецификацию".
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
do:
  this-proc-hndl = this-procedure.
end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure SpecGr-gds-code-yes :
define input  parameter p-gds-code   as integer   no-undo .
define input  parameter p-node-code  as integer   no-undo .
define input  parameter p-contract-num         as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define output parameter p-ask        as logical   no-undo .
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
define buffer buf_goods   for ub.goods  .
define buffer buf_gds-grp for ub.gds-grp  .
define variable v-grp-qnty as integer   no-undo .
define variable v-grp-lim as integer   no-undo .
  do
  on error undo, return error return-value
  :
p-ask = ? .
find first buf_goods no-lock where buf_goods.gds-code = p-gds-code .
find first buf_gds-grp-obj-attr no-lock where
           buf_gds-grp-obj-attr.attr-code = 'LimSpecGr':U and
           buf_gds-grp-obj-attr.obj-type  = string(p-contract-num) and
           buf_gds-grp-obj-attr.obj-code  = p-host-code and
           buf_gds-grp-obj-attr.host-code = 0 and
           buf_gds-grp-obj-attr.node-code = p-node-code no-error .
if error-status :error then do:
  p-ask = true .
  return .
end.
if buf_gds-grp-obj-attr.attr-value  = "0" then do:
  p-ask = false  .
  return .
end.
  if buf_gds-grp-obj-attr.attr-value  = "" or
    buf_gds-grp-obj-attr.attr-value  = ?  or
    buf_gds-grp-obj-attr.attr-value  = "?" then do:
    find first buf_gds-grp no-lock where
                buf_gds-grp.node-code = p-node-code no-error .
      if available buf_gds-grp  then do:
          if buf_gds-grp.upper-code = 0 then do:
              p-ask = true .
              return .
          end.
          else do:
              run SpecGr-gds-code-yes (
                 input   p-gds-code
                ,input   buf_gds-grp.upper-code
                ,input   p-contract-num
                ,input   p-host-code
                ,output  p-ask
                ).
              if p-ask <> ? then return .
        end.
      end.
  end.
  else do:
    v-grp-lim = int (buf_gds-grp-obj-attr.attr-value) no-error  .
    if v-grp-lim > 0 then do:
        v-grp-qnty = 0 .
        find first buf1_gds-grp-obj-attr no-lock where
                   buf1_gds-grp-obj-attr.attr-code = 'QntySpecGr':U and
                   buf1_gds-grp-obj-attr.obj-type  = string(p-contract-num) and
                   buf1_gds-grp-obj-attr.obj-code  = p-host-code and
                   buf1_gds-grp-obj-attr.host-code = 0 and
                   buf1_gds-grp-obj-attr.node-code = p-node-code no-error .
        if available buf1_gds-grp-obj-attr then do:
          v-grp-qnty = int(buf1_gds-grp-obj-attr.attr-value) .
        end.
        if v-grp-lim >= v-grp-qnty + 1 then p-ask = true .
        else p-ask = false .
        return .
    end.
  end.
  end.
end procedure.
procedure recalc-gds-SpecGr :
define input  parameter p-action     as character no-undo .
define input  parameter p-node-code  as integer   no-undo .
define input  parameter p-contract-num         as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define buffer buf_gds-grp for ub.gds-grp  .
define buffer curr_gds-grp for ub.gds-grp  .
define buffer buf1_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
define variable kk as character no-undo .
  do
  on error undo, return error return-value
  :
    find first buf1_gds-grp-obj-attr exclusive-lock where
               buf1_gds-grp-obj-attr.attr-code = 'QntySpecGr':U and
               buf1_gds-grp-obj-attr.obj-type  = string(p-contract-num) and
               buf1_gds-grp-obj-attr.obj-code  = p-host-code and
               buf1_gds-grp-obj-attr.host-code = 0 and
               buf1_gds-grp-obj-attr.node-code = p-node-code
               no-error .
    if available buf1_gds-grp-obj-attr then do:
       if p-action = '+' then  do:
          kk = string( int( buf1_gds-grp-obj-attr.attr-value ) + 1 ).
       end.
       else do:
          kk = string( int( buf1_gds-grp-obj-attr.attr-value ) - 1 ).
       end.
       buf1_gds-grp-obj-attr.attr-value = kk .
    end.
    else do:
        if p-action = '+' then  do:
            create buf1_gds-grp-obj-attr .
              assign
                buf1_gds-grp-obj-attr.attr-code  = 'QntySpecGr':U
                buf1_gds-grp-obj-attr.obj-type   = string(p-contract-num)
                buf1_gds-grp-obj-attr.obj-code   = p-host-code
                buf1_gds-grp-obj-attr.host-code  = 0
                buf1_gds-grp-obj-attr.node-code  = p-node-code
                buf1_gds-grp-obj-attr.attr-value = "1"
              .
        end.
    end.
   FIND FIRST curr_gds-grp WHERE
              curr_gds-grp.node-code = p-node-code
        NO-LOCK NO-ERROR.
   if AVAILABLE curr_gds-grp AND curr_gds-grp.upper-code > 0 then do:
      run recalc-gds-SpecGr (p-action ,curr_gds-grp.upper-code,p-contract-num,p-host-code ) .
   end.
  end.
end procedure.
