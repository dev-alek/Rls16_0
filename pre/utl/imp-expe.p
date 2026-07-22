block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: imp-expe.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/imp-expe.p $":U .
define variable vss-description as character no-undo init "ѕроцедура экспорта локальных таблиц ”Ѕƒ".
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
define variable p-rht as logical no-undo .
define variable p-gen as logical no-undo .
define variable p-flt as logical no-undo .
define variable p-pbc as logical no-undo .
define variable p-scl as logical no-undo .
define variable p-usr as logical no-undo .
define variable p-seq as logical no-undo .
define variable p-db-key as character no-undo .
define variable p-dir-name as character no-undo .
define variable p-glb as logical no-undo .
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
function corr-file-name returns character (
 input p-file-name as character)
 .
DEFINE variable v-corr-file-name as character no-undo.
DEFINE VARIABLE ii as integer no-undo .
DEFINE VARIABLE v-char-name-list as character no-undo .
assign
v-corr-file-name = p-file-name
.
do ii = 1 to length('\/:*?"<>|':U):
  assign
  v-corr-file-name = replace(
                                v-corr-file-name
                               , substr('\/:*?"<>|':U, ii, 1 )
                               , entry(ii, 'b-slash,slash,colon,star,question,d-quote,d-quote,less-t,great-t,pipe':U)
                           )
  .
end.
return v-corr-file-name.
end function.
define variable log-file-name as character no-undo init "imp-exp.log".
define variable v-view-log as logical no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-log-gap as logical no-undo .
define variable v-user-name    as character    no-undo.
define variable v-grp-name    as character    no-undo.
define variable v-arm-code    as character    no-undo.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
DEFINE VARIABLE v-is-global as logical no-undo .
DEFINE VARIABLE v-is-weight as logical no-undo .
DEFINE VARIABLE v-is-scaleable as logical no-undo .
DEFINE VARIABLE v-is-pgweight as logical no-undo .
DEFINE VARIABLE r-bar-code like ub.bar-code.b-code no-undo .
define buffer buf-sys-ctrl     for ub.sys-ctrl .
define buffer buf-config       for ub.config .
define buffer buf_goods        for ub.goods .
define buffer buf_units        for ub.units .
define buffer buf_cli_units    for ub.units .
define buffer buf_bar-code     for ub.bar-code .
define buffer buf-prod-bc      for ub.prod-bc .
define buffer buf_prod-bc      for ub.prod-bc .
define buffer buf_clients      for ub.clients .
define buffer buf-gds-obj-attr for ub.gds-obj-attr .
define buffer buf_gds-prt      for ub.gds-prt .
define buffer buf-scales       for ub.scales .
define buffer buf-scales-gds   for ub.scales-gds .
define buffer buf-scales-grp   for ub.scales-grp .
define buffer buf-filter       for ubflt.filter .
define buffer buf-cash-desk    for ub.cash-desk .
define buffer buf-curr-shop    for ub.curr-shop .
define buffer buf-usr-flt      for ubflt.usr-flt .
define buffer buf-user-account            for ub.user-account.
define buffer buf-user-login              for ub.user-login.
define buffer buf-user-obj                for ub.user-obj.
define buffer buf-user-host               for ub.user-host.
define buffer buf-user-menu-group         for ub.user-menu-group.
define buffer buf-user-login-action-role  for ub.user-login-action-role.
define buffer buf-action-role             for ub.action-role.
define buffer buf-action-role-item        for ub.action-role-item.
DEFINE VARIABLE v-seq-val as int64 no-undo .
assign
p-rht = logical(entry(1, p-parameter, chr(4)))
p-gen = logical(entry(2, p-parameter, chr(4)))
p-flt = logical(entry(3, p-parameter, chr(4)))
p-pbc = logical(entry(4, p-parameter, chr(4)))
p-scl = logical(entry(5, p-parameter, chr(4)))
p-usr = logical(entry(6, p-parameter, chr(4)))
p-seq = logical(entry(7, p-parameter, chr(4)))
p-db-key = entry(8, p-parameter, chr(4))
p-dir-name  = entry(9, p-parameter, chr(4))
p-glb       = logical(entry(10, p-parameter, chr(4)))
no-error
.
if error-status:error then return error substitute("&1 &2", error-status:get-message(1) , return-value ).
define stream Outstream.
run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", " Ёкспорт локальных таблиц" )) .
if p-gen then do:
  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Ёкспорт группы данных Ќј—“–ќ… » Ѕƒ" + " ‘айл: " + p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + "gen":U) )) .
  run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Ёкспорт группы данных Ќј—“–ќ… » Ѕƒ" ) ).
  output stream OUTstream to value(p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + "gen":U).
  FOR EACH buf-config No-LOCK:
    if lookup( buf-config.conf-type, 'к,п':U ) > 0 then NEXT.
    put stream outstream unformatted
    "config":U skip.
    export stream outstream
    buf-config.conf-type                                 buf-config.host-code                                 buf-config.obj-code                                 buf-config.obj-type                                 buf-config.param-code                                 buf-config.param-encoded                                 buf-config.param-type                                 buf-config.param-value
    .
  END.
   output stream OutStream close.
end.
if p-flt then do:
  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Ёкспорт группы данных ‘»Ћ№“–џ" + " ‘айл: " + p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + "flt":U) )) .
  run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Ёкспорт группы данных ‘»Ћ№“–џ" ) ).
   output stream OUTstream to value(p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + "flt":U).
  FOR EACH buf-filter No-LOCK:
    put stream outstream unformatted
    "filter":U skip.
    export stream outstream
    buf-Filter.Fields-sort-rus                                 buf-Filter.Fields-sort                                 buf-Filter.Flds                                 buf-Filter.Naim                                 buf-Filter.Num-flt                                 buf-Filter.Tbl                                 buf-Filter.Where-ysl-rus                                 buf-Filter.Where-ysl                                 buf-Filter.call-point                                 buf-Filter.lst-cend
    .
  END.
  output stream OutStream close.
end.
if p-pbc then do:
  find first buf-sys-ctrl no-lock.
  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Ёкспорт группы данных ¬≈— » ¬«¬≈Ў  ќƒџ" + " ‘айл: " + p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + "pbc":U) )) .
  run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Ёкспорт группы данных ¬≈— » ¬«¬≈Ў  ќƒџ" ) ).
   output stream OUTstream to value(p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + "pbc":U).
  _goods:
  for each buf_goods no-lock,
      first buf_units no-lock where
            buf_units.type = 'вес':U
        AND buf_units.unit-name = buf_goods.unit-base
          :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output r-bar-code
  ) no-error .
    if error-status:error then dO:
      NEXT _goods.
    end.
    _pbc1:
    for each buf-prod-bc no-lock where
            buf-prod-bc.b-code = r-bar-code :
      assign
      v-is-global = no
      v-is-weight = no
      .
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf-prod-bc
  ,input  'global=request':U
  ,output v-is-global
  )  .
      if error-status:error
      or (v-is-global
         and
         p-glb = no)
      then do:
        next _pbc1.
      end.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf-prod-bc
  ,input  'weight=request':U
  ,output v-is-weight
  )  .
      if error-status:error or not v-is-weight then do:
        next _pbc1.
      end.
      put stream outstream unformatted
      "prod-bc":U skip.
      export stream outstream
      buf-prod-bc.b-code                                 buf-prod-bc.b-str                                 buf-prod-bc.bc-on
      .
    END.
    find first buf_gds-prt no-lock where
              buf_gds-prt.upper-code = buf_goods.prt-root no-error .
    if not avail buf_gds-prt then NEXT _goods.
    for each buf_bar-code no-lock where
            buf_bar-code.gds-code = buf_goods.gds-code
        AND buf_bar-code.in-code = "":U
        AND buf_bar-code.part-code = "":U
        AND buf_bar-code.node-code = buf_gds-prt.node-code
        AND buf_bar-code.unit-cli <> buf_goods.unit-base,
      first buf_clI_units no-lock where
            buf_cli_units.type = 'дро':U
         AND buf_cli_units.unit-name = buf_bar-code.unit-cli:
      _pbc2:
      for each Buf-prod-bc no-lock where
              buf-prod-bc.b-code = buf_bar-code.b-code:
        assign
        v-is-global = no
        v-is-scaleable = no
        .
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf-prod-bc
  ,input  'global=request':U
  ,output v-is-global
  ) no-error .
        if error-status:error or v-is-global then next _pbc2.
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf-prod-bc
  ,input  'scaleable=request':U
  ,output v-is-scaleable
  ) no-error .
        if error-status:error or not v-is-scaleable then next _pbc2.
        put stream outstream unformatted
        "prod-bc":U skip.
        export stream outstream
        buf-prod-bc.b-code                                 buf-prod-bc.b-str                                 buf-prod-bc.bc-on
        .
      end.
    end.
    for each buf_clients no-lock where
            buf_clients.db-num = buf-sys-ctrl.db-num,
        first buf-gds-obj-attr no-lock where
            buf-gds-obj-attr.gds-code = buf_goods.gds-code
        AND buf-gds-obj-attr.obj-type = buf_clients.obj-type
        AND buf-gds-obj-attr.obj-code = buf_clients.obj-code
        AND buf-gds-obj-attr.attr-code = 'scales-code':U
        :
        put stream outstream unformatted
        "gds-obj-attr":U skip.
        export stream outstream
        buf-gds-obj-attr.gds-code                                 buf-gds-obj-attr.obj-type                                 buf-gds-obj-attr.obj-code                                 buf-gds-obj-attr.attr-code                                 buf-gds-obj-attr.attr-value
        .
     end.
  end.
  _pbc2:
  for each buf-prod-bc no-lock where
                buf-prod-bc.b-str >= "00100"
            and buf-prod-bc.b-str <= "99999"
            and buf-prod-bc.bc-on-type = 'pglc':U
            and length(buf-prod-bc.b-str) = 5,
     first buf_bar-code no-lock  where
          buf_bar-code.b-code = buf-prod-bc.b-code,
     first buf_goods no-lock where
          buf_goods.gds-code = buf_bar-code.gds-code:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run prodbcat in g#library
  (buffer buf-prod-bc
  ,input  'pgweight=request':U
  ,output v-is-pgweight
  )  .
    if error-status:error or not v-is-pgweight then do:
      next _pbc2.
    end.
    put stream outstream unformatted
    "prod-bc":U skip.
    export stream outstream
    buf-prod-bc.b-code                                 buf-prod-bc.b-str                                 buf-prod-bc.bc-on
     .
    for each buf_clients no-lock where
            buf_clients.db-num = buf-sys-ctrl.db-num,
        first buf-gds-obj-attr no-lock where
            buf-gds-obj-attr.gds-code = buf_goods.gds-code
        AND buf-gds-obj-attr.obj-type = buf_clients.obj-type
        AND buf-gds-obj-attr.obj-code = buf_clients.obj-code
        AND buf-gds-obj-attr.attr-code = 'scales-code':U
        :
        put stream outstream unformatted
        "gds-obj-attr":U skip.
        export stream outstream
        buf-gds-obj-attr.gds-code                                 buf-gds-obj-attr.obj-type                                 buf-gds-obj-attr.obj-code                                 buf-gds-obj-attr.attr-code                                 buf-gds-obj-attr.attr-value
        .
     end.
  end.
  output stream OutStream close.
end.
if p-scl then do:
  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Ёкспорт группы данных ¬≈—џ" + " ‘айл: " + p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + "scl":U) )) .
  run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Ёкспорт группы данных ¬≈—џ" ) ).
   output stream OUTstream to value(p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + "scl":U).
  FOR EACH buf-scales No-LOCK:
    put stream outstream unformatted
    "scales":U skip.
    export stream outstream
    buf-scales.address                                 buf-scales.db-num                                 buf-scales.master                                 buf-scales.max-gds                                 buf-scales.max-plu                                 buf-scales.scales-name                                 buf-scales.scales-num                                 buf-scales.scales-type                                 buf-scales.to-send                                 buf-scales.tot-gds                                 buf-scales.unit-base                                 buf-scales.wt-cart                                  buf-scales.remote
    .
  END.
  FOR EACH buf-scales-gds No-LOCK:
    put stream outstream unformatted
    "scales-gds":U skip.
    export stream outstream
    buf-scales-gds.PLU-code                                 buf-scales-gds.b-code                                 buf-scales-gds.db-num                                 buf-scales-gds.deadline                                 buf-scales-gds.obj-code                                 buf-scales-gds.obj-type                                 buf-scales-gds.scales-num                                 buf-scales-gds.to-del                                 buf-scales-gds.to-send                                 buf-scales-gds.wt-cart                                 buf-scales-gds.deaddate                                 buf-scales-gds.deadflag                                 buf-scales-gds.deadtime
    .
  END.
  FOR EACH buf-scales-grp No-LOCK:
    put stream outstream unformatted
    "scales-grp":U skip.
    export stream outstream
    buf-scales-grp.node-code                                 buf-scales-grp.scales-num
    .
  END.
  output stream OutStream close.
end.
if p-usr then do:
  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Ёкспорт группы данных ѕ–ј¬ј" + " ‘айл: " + p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + "rht":U) )) .
  run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Ёкспорт группы данных ѕ–ј¬ј" ) ).
  output stream OUTstream to value(p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + "rht":U).
  FOR EACH buf-action-role No-LOCK:
    put stream outstream unformatted
    "action-role":U skip.
    export stream outstream
    buf-action-role.db-num                                  buf-action-role.action-head-code                                  buf-action-role.action-role-code                                  buf-action-role.action-role-context                                  buf-action-role.action-role-name                                  buf-action-role.action-role-description                                  buf-action-role.whole-send-news
    .
  END.
  FOR EACH buf-action-role-item No-LOCK:
    put stream outstream unformatted
    "action-role-item":U skip.
    export stream outstream
    buf-action-role-item.db-num                                  buf-action-role-item.action-head-code                                  buf-action-role-item.action-role-code                                  buf-action-role-item.action-role-item-code                                  buf-action-role-item.action-item-code                                  buf-action-role-item.action-item-id                                  buf-action-role-item.whole-send-news
    .
  END.
  output stream OutStream close.
end.
if p-usr then do:
  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Ёкспорт группы данных ѕќЋ№«ќ¬ј“≈Ћ»" + " ‘айл: " + p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + "usr":U) )) .
  run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Ёкспорт группы данных ѕќЋ№«ќ¬ј“≈Ћ»" ) ).
   output stream OUTstream to value(p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + "usr":U).
    FOR EACH buf-user-account No-LOCK:
    put stream outstream unformatted
    "user-account":U skip.
    export stream outstream
    buf-user-account.user-id                                  buf-user-account.status_                                  buf-user-account.first-name                                  buf-user-account.second-name                                  buf-user-account.last-name                                  buf-user-account.company                                  buf-user-account.department                                  buf-user-account.e-mail                                  buf-user-account.internal-phone-number                                  buf-user-account.mobile-phone-number                                  buf-user-account.phone-number                                  buf-user-account.position                                  buf-user-account.PS                                  buf-user-account.room                                  buf-user-account.parent-user-id                                  buf-user-account.check-parent                                  buf-user-account.nik
    .
  END.
  FOR EACH buf-user-login No-LOCK:
    put stream outstream unformatted
    "user-login":U skip.
    export stream outstream
    buf-user-login.db-num                                  buf-user-login.user-id                                  buf-user-login.user-login                                  buf-user-login.user-administrator                                  buf-user-login.max-discnt                                  buf-user-login.quest-print                                  buf-user-login.status_
    .
  END.
  FOR EACH buf-user-obj No-LOCK:
    put stream outstream unformatted
    "user-obj":U skip.
    export stream outstream
    buf-user-obj.db-num                                  buf-user-obj.user-id                                  buf-user-obj.obj-type                                  buf-user-obj.obj-code                                  buf-user-obj.host-code
    .
  END.
  FOR EACH buf-user-host No-LOCK:
    put stream outstream unformatted
    "user-host":U skip.
    export stream outstream
    buf-user-host.db-num                                  buf-user-host.user-id                                  buf-user-host.host-code
    .
  END.
  FOR EACH buf-user-menu-group No-LOCK:
    put stream outstream unformatted
    "user-menu-group":U skip.
    export stream outstream
    buf-user-menu-group.db-num                                  buf-user-menu-group.user-id                                  buf-user-menu-group.user-menu-group-code                                  buf-user-menu-group.menu-code                                  buf-user-menu-group.menu-group-code                                  buf-user-menu-group.menu-group-id                                  buf-user-menu-group.menu-group-context                                  buf-user-menu-group.host-code                                  buf-user-menu-group.obj-type                                  buf-user-menu-group.obj-code
    .
  END.
  FOR EACH buf-user-login-action-role No-LOCK:
    put stream outstream unformatted
    "user-login-action-role":U skip.
    export stream outstream
    buf-user-login-action-role.db-num                                  buf-user-login-action-role.action-head-code                                  buf-user-login-action-role.user-login-role-code                                  buf-user-login-action-role.user-id                                  buf-user-login-action-role.action-role-code                                  buf-user-login-action-role.action-role-context                                  buf-user-login-action-role.host-code                                  buf-user-login-action-role.obj-type                                  buf-user-login-action-role.obj-code                                  buf-user-login-action-role.gds-grp-code                                  buf-user-login-action-role.gds-code                                  buf-user-login-action-role.cli-grp-code
    .
  END.
  FOR EACH buf-usr-flt No-LOCK:
    put stream outstream unformatted
    "usr-flt":U skip.
    export stream outstream
    buf-usr-flt.Naim                                 buf-usr-flt.call-point                                 buf-usr-flt.user-name
    .
  END.
  output stream OutStream close.
end.
if p-seq then do:
  run write-log-and-file in p-log-handle (                              input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "&1 .......", ("Ёкспорт группы данных —„≈“„» »" + " ‘айл: " + p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + "seq":U) )) .
  run write-log-and-file in p-log-handle (                          input 1                                                              , input log-file-name                                                  , input 1                                                              , input substitute( "!!!&1",  "Ёкспорт группы данных —„≈“„» »" ) ).
   output stream OUTstream to value(p-dir-name + "\":U + corr-file-name(p-db-key) + ".":U + "seq":U).
   _seq:
   FOR EACH ub._sequence No-LOCK :
    assign
      v-seq-val = dynamic-current-value( ub._sequence._seq-name, "ub":U )
    .
    put stream outstream unformatted
    "sequence":U skip.
    export stream outstream
    ub._sequence._seq-name
    v-seq-val
    .
  END.
END.
