block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle as handle no-undo .
define input parameter p-mode        as character no-undo .
define input parameter price-doc-num like ub.price-doc.doc-num no-undo .
define input parameter trn-doc-code  as character no-undo .
define input parameter p-ask-q       as logical   no-undo .
define input parameter p-do          as logical   no-undo .
define buffer buf-price-doc     for ub.price-doc .
define variable varfact-date  like buf-price-doc.fact-date  no-undo.
define variable varfact-time  like buf-price-doc.fact-time  no-undo.
define variable varshift-date like buf-price-doc.shift-date no-undo.
define variable varshift-num  like buf-price-doc.shift-num  no-undo.
define variable varshift-name like buf-price-doc.shift-name no-undo.
define variable p-par as logical no-undo .
define variable conf-par     as char no-undo.
define variable par-type     as char no-undo.
define variable l-ok as logical      no-undo .
define variable v-name-tax as character no-undo .
define buffer other_price-list for ub.price-list.
define variable p-new-status_ like ub.price-doc.status_ no-undo .
define variable vss-revision    as character no-undo init "$Revision: b896e8303830, 47, rls $":U .
define variable vss-author      as character no-undo init "$Author: ASMorozov $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jun 09 14:49:49 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: pr-stat.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/pr-stat.p $":U .
define variable vss-description as character no-undo init "Перевод статусов переоценки по графу".
define variable tt-price-sale as decimal no-undo.
define variable v-text-mess as character no-undo .
define variable tt-price-prodwihvat as decimal no-undo.
define variable tt-prod-vat         as decimal no-undo.
define variable v-str as character no-undo .
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
      p-vss-parameters = substitute('&1|&2',p-mode,price-doc-num)
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure grp-obj-write :
do
on error undo, return error
:
define input parameter p-node-code  like ub.gds-grp-obj.node-code      no-undo.
define input parameter p-host-code  as integer                          no-undo.
define input parameter p-obj-type   like ub.clients.obj-type            no-undo.
define input parameter p-obj-code   like ub.clients.obj-code            no-undo.
define input parameter p-min-increase like ub.gds-grp-obj.min-increase  no-undo.
define input parameter p-max-increase like ub.gds-grp-obj.max-increase  no-undo.
define input parameter p-increase-pc like ub.gds-grp-obj.increase-pc  no-undo.
define input parameter p-calc-method like ub.gds-grp-obj.calc-method no-undo .
define input parameter p-round-method like ub.gds-grp-obj.round-method no-undo .
define input parameter p-round-coef like ub.gds-grp-obj.round-coef no-undo .
define input parameter p-cli-type   like ub.clients.obj-type            no-undo.
define input parameter p-cli-code   like ub.clients.obj-code            no-undo.
define buffer buf_gds-grp-obj for ub.gds-grp-obj.
    find first buf_gds-grp-obj exclusive-lock
         where buf_gds-grp-obj.node-code  = p-node-code
           and buf_gds-grp-obj.host-code  = p-host-code
           and buf_gds-grp-obj.obj-type   = p-obj-type
           and buf_gds-grp-obj.obj-code   = p-obj-code
    no-error.
    if not available buf_gds-grp-obj
    then do:
        create buf_gds-grp-obj.
        assign
                buf_gds-grp-obj.node-code  = p-node-code
                buf_gds-grp-obj.host-code  = p-host-code
                buf_gds-grp-obj.obj-type   = p-obj-type
                buf_gds-grp-obj.obj-code   = p-obj-code
        .
    end.
    assign
    buf_gds-grp-obj.min-increase = p-min-increase
    buf_gds-grp-obj.max-increase = p-max-increase
    buf_gds-grp-obj.increase-pc = p-increase-pc
    buf_gds-grp-obj.calc-method = p-calc-method
    buf_gds-grp-obj.round-method = p-round-method
    buf_gds-grp-obj.round-coef = p-round-coef
    buf_gds-grp-obj.cli-type   = p-cli-type
    buf_gds-grp-obj.cli-code   = p-cli-code
    .
end.
end procedure.
procedure grp-obj-margin-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define output parameter p-min-value as decimal      no-undo init ?.
define output parameter p-max-value as decimal      no-undo init ?.
define output parameter p-increase-pc as decimal      no-undo init ?.
define output parameter p-round-method as character no-undo init "":U.
define output parameter p-base as decimal no-undo init ?.
define output parameter p-range-margin     as integer      no-undo.
define output parameter p-exists-margin    as logical      no-undo.
define output parameter p-range-increase     as integer      no-undo.
define output parameter p-exists-increase    as logical      no-undo.
define output parameter p-range-rmethod     as integer no-undo .
define output parameter p-exists-rmethod    as logical no-undo .
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-margin-found as logical no-undo .
DEFINE VARIABLE v-increase-found as logical no-undo .
DEFINE VARIABLE v-min-value as decimal      no-undo.
DEFINE VARIABLE v-max-value as decimal      no-undo.
DEFINE VARIABLE v-increase-pc as decimal      no-undo.
define variable v-round-method as character no-undo .
define variable v-base as decimal no-undo .
define variable v-print-code as character no-undo .
define buffer buf_gds-grp for ub.gds-grp.
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
if p-obj-type <> '' then do:
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
  if error-status :error
  then do:
      message
        vss-workfile vss-revision vss-description
        skip "Не удалось найти фирму объекта"
        skip p-obj-type p-obj-code
        skip return-value
        skip trim(error-status :get-message(1))
            trim(error-status :get-message(2))
            trim(error-status :get-message(3))
            trim(error-status :get-message(4))
            trim(error-status :get-message(5))
      view-as alert-box error.
      undo, return error .
  end.
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    assign
    v-min-value    = buf_gds-grp-obj.min-increase
    v-max-value    = buf_gds-grp-obj.max-increase
    v-increase-pc  = buf_gds-grp-obj.increase-pc
    v-round-method = buf_gds-grp-obj.round-method
    v-base         = buf_gds-grp-obj.round-coef
    .
    assign
    p-exists-margin = (if v-min-value <> ? and v-max-value <> ? and p-min-value = ?
                        then yes
                        else p-exists-margin)
    p-range-margin = if p-exists-margin and p-min-value = ?
                      then v-range
                      else p-range-margin
    p-min-value   =  if p-exists-margin and  p-min-value = ?
                      then v-min-value
                      else p-min-value
    p-max-value   =  if p-exists-margin and  p-max-value = ?
                      then v-max-value
                      else p-max-value
    p-exists-increase = (if v-increase-pc <> ? and p-increase-pc = ?
                        then yes
                        else p-exists-increase)
    p-range-increase = if p-exists-increase and p-increase-pc = ?
                      then v-range
                      else p-range-increase
    p-increase-pc = (if p-exists-increase and p-increase-pc = ?
                      then v-increase-pc
                      else p-increase-pc)
    p-exists-rmethod = if v-round-method <> "":U and p-round-method = "":U
                        then yes
                        else p-exists-rmethod
    p-range-rmethod = (if p-exists-rmethod and p-round-method = "":U
                        then v-range
                        else p-range-rmethod)
    p-round-method  = (if p-exists-rmethod and p-round-method = "":U
                        then v-round-method
                        else p-round-method)
    p-base          = (if p-exists-rmethod and p-base = ?
                        then v-base
                        else p-base)
    v-found =  (p-exists-margin and p-exists-increase and p-exists-rmethod) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-margin and p-exists-increase and p-exists-rmethod ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
procedure grp-obj-income-cli-value :
do
on error undo, return error
:
define input parameter p-node-code as integer      no-undo.
define input parameter p-obj-type  as character    no-undo.
define input parameter p-obj-code  as integer      no-undo.
define output parameter p-cli-type as character    no-undo init ?.
define output parameter p-cli-code as integer      no-undo init ?.
define output parameter p-range-income-cli     as integer      no-undo.
define output parameter p-exists-income-cli    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-income-cli-found as logical no-undo .
DEFINE VARIABLE v-cli-type-value as char      no-undo.
DEFINE VARIABLE v-cli-code-value as int      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
           trim(error-status :get-message(2))
           trim(error-status :get-message(3))
           trim(error-status :get-message(4))
           trim(error-status :get-message(5))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    assign
    v-cli-type-value    = buf_gds-grp-obj.cli-type
    v-cli-code-value    = buf_gds-grp-obj.cli-code
    .
    assign
    p-exists-income-cli = (if v-cli-type-value <> ? and v-cli-code-value <> ? and p-cli-type = ?
                        then yes
                        else p-exists-income-cli)
    p-range-income-cli = if p-exists-income-cli and p-cli-type = ?
                      then v-range
                      else p-range-income-cli
    p-cli-type   =  if p-exists-income-cli and  p-cli-type = ?
                      then v-cli-type-value
                      else p-cli-type
    p-cli-code   =  if p-exists-income-cli and  p-cli-code = ?
                      then v-cli-code-value
                      else p-cli-code
    v-found =  (p-exists-income-cli ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-income-cli  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
procedure create-price-list-attr :
 do
 on error undo, return error return-value
 :
define input parameter p-attr-code    like ub.price-list-attr.attr-code  no-undo .
define input parameter p-attr-value   like ub.price-list-attr.attr-value no-undo .
define input parameter p-b-code       like ub.price-list-attr.b-code     no-undo .
define input parameter p-doc-num      like ub.price-list-attr.doc-num    no-undo .
define input parameter p-price-type   like ub.price-list-attr.price-type no-undo .
define buffer buf_price-list-attr for ub.price-list-attr.
find first buf_price-list-attr  exclusive-lock  where
  buf_price-list-attr.attr-code    = p-attr-code    and
  buf_price-list-attr.b-code       = p-b-code       and
  buf_price-list-attr.doc-num      = p-doc-num      and
  buf_price-list-attr.price-type   = p-price-type  no-error .
  if not available  buf_price-list-attr then do:
      create buf_price-list-attr.
      assign
        buf_price-list-attr.attr-code    = p-attr-code
        buf_price-list-attr.attr-value   = p-attr-value
        buf_price-list-attr.b-code       = p-b-code
        buf_price-list-attr.doc-num      = p-doc-num
        buf_price-list-attr.price-type   = p-price-type
      .
  end.
  else do:
        buf_price-list-attr.attr-value   = p-attr-value .
  end.
 end.
end procedure.
procedure view-price-list-attr :
 do
 on error undo, return error return-value
 :
define input  parameter p-attr-code    like ub.price-list-attr.attr-code  no-undo .
define input  parameter p-b-code       like ub.price-list-attr.b-code     no-undo .
define input  parameter p-doc-num      like ub.price-list-attr.doc-num    no-undo .
define input  parameter p-price-type   like ub.price-list-attr.price-type no-undo .
define output parameter p-attr-value   like ub.price-list-attr.attr-value no-undo .
define buffer buf_price-list-attr for ub.price-list-attr.
find first buf_price-list-attr no-lock where
  buf_price-list-attr.attr-code    = p-attr-code    and
  buf_price-list-attr.b-code       = p-b-code       and
  buf_price-list-attr.doc-num      = p-doc-num      and
  buf_price-list-attr.price-type   = p-price-type  no-error .
  if available  buf_price-list-attr then do:
      assign
        p-attr-value = buf_price-list-attr.attr-value
      .
  end.
  else do:
        p-attr-value = ? .
  end.
 end.
end procedure.
procedure pdoc-forming-attr :
define input  parameter p-plt-id       as integer   no-undo .
define input  parameter p-plt-db-num   as integer   no-undo .
define input  parameter p-pdf-id       as integer   no-undo .
define input  parameter p-pdf-db       as integer   no-undo .
define input  parameter p-attr-code    as character no-undo .
define input  parameter p-val          as character no-undo .
  do
  on error undo, return error return-value
  :
  find first  ub.price-doc-forming-attr exclusive-lock where
              ub.price-doc-forming-attr.plt-id       = p-plt-id       and
              ub.price-doc-forming-attr.plt-db-num   = p-plt-db-num   and
              ub.price-doc-forming-attr.pdf-id       = p-pdf-id       and
              ub.price-doc-forming-attr.pdf-db       = p-pdf-db       and
              ub.price-doc-forming-attr.attr-code    = p-attr-code
              no-error .
    if not available  ub.price-doc-forming-attr then create ub.price-doc-forming-attr.
    assign
      ub.price-doc-forming-attr.plt-id       = p-plt-id
      ub.price-doc-forming-attr.plt-db-num   = p-plt-db-num
      ub.price-doc-forming-attr.pdf-id       = p-pdf-id
      ub.price-doc-forming-attr.pdf-db       = p-pdf-db
      ub.price-doc-forming-attr.attr-code    = p-attr-code
      ub.price-doc-forming-attr.attr-value   = p-val
    .
  end.
end procedure.
def var vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-use-bar-code :
  define input  parameter p-b-code    like ub.bar-code.b-code no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info6, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info6 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info6 )
  :
    define buffer buf_bar-code for ub.bar-code .
    find first buf_bar-code no-lock
      where buf_bar-code.b-code     = p-b-code
      no-error .
    if not available buf_bar-code then do:
      return error substitute( "&1 (check-use-bar-code). Не найден бар-код &2", vss-include-info6, p-b-code ) .
    end.
    if buf_bar-code.stts = integer('99':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Выполняется удаление бар-кода"
                              ,vss-include-info6
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    if buf_bar-code.stts = integer('79':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Бар-код выключен"
                              ,vss-include-info6
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    return .
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable var-pr-r-b as character no-undo .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-pr-r-b
  )  .
function fnc-cost-pc return decimal (buffer local-price-list for ub.price-list).
define variable f-cost     as decimal no-undo .
define variable f-cost-pc  as decimal no-undo .
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = local-price-list.obj-type and
     ub.gds-obj.obj-code = local-price-list.obj-code no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = 'т':U then
    assign
      f-cost = ( if var-pr-r-b = "rubl" then ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base)
      .
    else  f-cost = ?.
else f-cost = ?.
 f-cost-pc = (round(local-price-list.price-sale / f-cost , 2) - 1) * 100.
  if f-cost-pc > 9999 then
    f-cost-pc = ?.
  return (f-cost-pc).
end function.
function fnc-pr-pc return decimal (buffer local-price-list for ub.price-list).
define variable f-pr     as decimal no-undo .
define variable f-pr-pc  as decimal no-undo.
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = local-price-list.obj-type and
     ub.gds-obj.obj-code = local-price-list.obj-code  no-error .
if  available ub.gds-obj then do:
  if ub.goods.gds-type = 'т':U then
    assign
      f-pr = (if var-pr-r-b = "rubl" then ub.gds-obj.last-rubl else ub.gds-obj.last-base)
      .
    else f-pr = ?.
end.
else f-pr = ?.
  f-pr-pc = ( local-price-list.price-sale / f-pr - 1 ) * 100.
  if f-pr-pc > 9999 then
    f-pr-pc = ?.
  return (f-pr-pc).
end function.
function fnc-cost return decimal (buffer local-price-list for ub.price-list).
define variable f-cost   as decimal no-undo .
find first ub.goods where
           ub.goods.artic = local-price-list.artic and
           ub.goods.prod-type = local-price-list.prod-type and
           ub.goods.prod-code = local-price-list.prod-code no-lock
           no-error .
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = local-price-list.obj-type and
     ub.gds-obj.obj-code = local-price-list.obj-code no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = 'т':U then
    assign
      f-cost = if var-pr-r-b = "rubl" then ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base
      .
    else  f-cost = ?.
else f-cost = ?.
  return ( f-cost ).
end function.
function fnc-pr return decimal (buffer local-price-list for ub.price-list).
define variable f-pr   as decimal no-undo .
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = local-price-list.obj-type and
     ub.gds-obj.obj-code = local-price-list.obj-code no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = 'т':U then
    assign
      f-pr = if var-pr-r-b = "rubl" then ub.gds-obj.last-rubl  else ub.gds-obj.last-base
      .
    else  f-pr = ?.
else f-pr = ?.
   return ( f-pr ).
end function.
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION fnc-base-price RETURN decimal (local-bc      as integer,
                                        local-doc-num as char).
define buffer base-price        for ub.price-list.
define variable local-main-code like ub.bar-code.b-code no-undo.
define variable local-base-code like ub.bar-code.b-code no-undo.
  run prc-base-code (input local-bc, output local-base-code).
  find base-price no-lock where
       base-price.doc-num = local-doc-num and
       base-price.b-code  = local-base-code and
       base-price.price-type = "" no-error.
  if not available base-price then do:
    run prc-main-code (input local-bc, output local-main-code).
    find  base-price no-lock where
          base-price.doc-num = local-doc-num and
          base-price.b-code  = local-main-code and
          base-price.price-type = "" no-error.
  end.
  if available base-price then
    return (base-price.price-sale).
  else
    return (?).
END FUNCTION.
procedure prc-main-code:
define input  parameter local-bc        like ub.bar-code.b-code no-undo.
define output parameter local-main-code like ub.bar-code.b-code no-undo.
define buffer local-bar-code        for ub.bar-code.
define buffer local-goods           for ub.goods.
define buffer main-code             for ub.bar-code.
define buffer main-prt              for ub.gds-prt.
  local-main-code = ?.
  find local-bar-code no-lock where
       local-bar-code.b-code = local-bc no-error.
  if not available local-bar-code then
    return.
  find local-goods no-lock where
       local-goods.gds-code = local-bar-code.gds-code.
  find first  main-prt no-lock where
              main-prt.upper-code = local-goods.prt-root.
  find  main-code no-lock where
        main-code.gds-code  = local-bar-code.gds-code and
        main-code.in-code   = "" and
        main-code.part-code = "" and
        main-code.unit-cli  = local-goods.unit-base and
        main-code.node-code = main-prt.node-code.
  local-main-code = main-code.b-code.
end procedure.
procedure prc-base-code:
define input  parameter local-bc        like ub.bar-code.b-code no-undo.
define output parameter local-base-code like ub.bar-code.b-code no-undo.
define buffer local-bar-code for ub.bar-code.
define buffer local-goods    for ub.goods.
define buffer base-code      for ub.bar-code.
  local-base-code = ?.
  find local-bar-code no-lock where
       local-bar-code.b-code = local-bc no-error.
  if not available local-bar-code then
    return.
  find local-goods no-lock where
       local-goods.gds-code = local-bar-code.gds-code.
  find base-code no-lock where
       base-code.gds-code  = local-bar-code.gds-code and
       base-code.node-code = local-bar-code.node-code and
       base-code.in-code   = local-bar-code.in-code and
       base-code.part-code = local-bar-code.part-code and
       base-code.unit-cli  = local-goods.unit-base.
  local-base-code = base-code.b-code.
end procedure.
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable par-pr-incpc as character no-undo.
define variable par-pr-rndmt as character no-undo.
define variable par-pr-rndbs as character no-undo.
define variable par-pr-clt-q as character no-undo.
define variable par-pr-dpl-q as character no-undo.
define variable par-pr-rdc-q as character no-undo.
define variable par-pr-abs-d as character no-undo.
define variable par-pr-altex as character no-undo.
define variable par-pr-parex as character no-undo.
define variable par-pr-sclex as character no-undo.
define variable par-pr-notls as character no-undo.
define variable par-pr-equ-dq as integer  no-undo.
define variable par-pr-discm as character no-undo .
define variable par-pr-dscnt as character no-undo .
define variable par-pr-print as character no-undo .
define variable par-pr-sigma as character no-undo .
define variable par-pr-goods as character no-undo.
define variable par-pr-nogds as character no-undo.
define variable par-alcohol  as character no-undo.
define variable par-gen-mrgn-ie as character no-undo .
define variable par-gen-mrgn-iv as character no-undo .
define variable par-gen-mrgn-im as character no-undo .
define variable par-pr-nakl-ie  as logical   no-undo .
define variable par-pr-nakl-iv  as logical   no-undo .
define variable par-pr-nakl-im  as logical   no-undo .
define variable par-pr-nogds-long as longchar no-undo .
define temp-table tmp-proof-price no-undo
  field node-code like ub.gds-grp.node-code
  field proof as decimal
  field price as decimal
index pi node-code proof descending .
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ggoattr-code :
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
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-code in g#attr-lib
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
procedure ggoattr-tooltip :
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-tooltip in g#attr-lib
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
procedure ggoattr-value :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-value in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
      ,input  p-obj-type
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
procedure ggoattr-write :
  define input parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define input parameter p-value     like ub.gds-grp-obj-attr.attr-value no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-write in g#attr-lib
      (input p-node-code
      ,input  p-host-code
      ,input  p-obj-type
      ,input  p-obj-code
      ,input p-code
      ,input p-value
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-exist :
  define input  parameter p-node-code    like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code      like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-exist in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
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
end procedure.
procedure ggoattr-delete :
  define input  parameter p-node-code   like ub.gds-grp-obj-attr.node-code     no-undo .
  define input  parameter p-host-code    like ub.gds-grp-obj-attr.host-code     no-undo .
  define input  parameter p-obj-type     like ub.gds-grp-obj-attr.obj-type     no-undo .
  define input  parameter p-obj-code     like ub.gds-grp-obj-attr.obj-code     no-undo .
  define input  parameter p-code     like ub.gds-grp-obj-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-delete in g#attr-lib
      (input  p-node-code
      ,input  p-host-code
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
end procedure.
procedure ggoattr-news :
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-news in g#attr-lib
      (input  p-code
      ,output p-news
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-manual-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-manual-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure ggoattr-batch-edit :
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run ggoattr-batch-edit in g#attr-lib
      (input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure grp-obj-notcorr-value :
do
on error undo, return error
:
define input parameter p-node-code             as integer      no-undo.
define input parameter p-obj-type              as character    no-undo.
define input parameter p-obj-code              as integer      no-undo.
define output parameter p-notcorr              as character    no-undo init ?.
define output parameter p-range-notcorr     as integer      no-undo.
define output parameter p-exists-notcorr    as logical      no-undo.
define variable v-host-code as integer      no-undo.
DEFINE VARIABLE v-found as logical no-undo .
DEFINE VARIABLE v-exists as logical no-undo .
DEFINE VARIABLE v-range as integer no-undo .
DEFINE VARIABLE jj as integer no-undo .
DEFINE VARIABLE v-notcorr-found as logical no-undo .
DEFINE VARIABLE v-notcorr-value as char      no-undo.
define buffer buf_gds-grp for ub.gds-grp.
define buffer buf_gds-grp-obj-attr for ub.gds-grp-obj-attr  .
find first buf_gds-grp no-lock where
           buf_gds-grp.node-code = p-node-code no-error .
if not avail buf_gds-grp and p-node-code <> 0 then do:
  message
    vss-workfile vss-revision vss-description
    skip "Не удалось найти группу товаров с кодом" p-node-code
    view-as alert-box error .
  undo, return error .
end.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  ) no-error .
if error-status :error
then do:
    message
      vss-workfile vss-revision vss-description
      skip "Не удалось найти фирму объекта"
      skip p-obj-type p-obj-code
      skip return-value
      skip trim(error-status :get-message(1))
    view-as alert-box error.
    undo, return error .
end.
define buffer buf_gds-grp-obj      for ub.gds-grp-obj.
do while v-found = no and jj < 2:
  if v-range <> 3 then do:
    find first buf_gds-grp-obj no-lock
        where buf_gds-grp-obj.node-code = p-node-code
          and buf_gds-grp-obj.host-code = v-host-code
          and buf_gds-grp-obj.obj-type  = p-obj-type
          and buf_gds-grp-obj.obj-code  = p-obj-code
    no-error .
  end.
  if v-range = 3 or not available buf_gds-grp-obj
  then do:
     if v-range <> 2 then do:
        find first buf_gds-grp-obj no-lock
            where buf_gds-grp-obj.node-code = p-node-code
              and buf_gds-grp-obj.host-code = v-host-code
              and buf_gds-grp-obj.obj-type  = ""
              and buf_gds-grp-obj.obj-code  = 0
        no-error .
      end.
      if v-range = 2 or not available buf_gds-grp-obj
      then do:
          if v-range <> 1 then do:
            find first buf_gds-grp-obj no-lock
                where buf_gds-grp-obj.node-code = p-node-code
                and buf_gds-grp-obj.host-code = 0
                and buf_gds-grp-obj.obj-type  = ""
                and buf_gds-grp-obj.obj-code  = 0
            no-error .
          end.
          if v-range = 1 or not available buf_gds-grp-obj
          then do:
              assign
                  v-exists = no
              .
          end.
          else do:
              assign
                  v-exists = yes
                  v-range = 1
              .
          end.
      end.
      else do:
          assign
              v-exists = yes
              v-range  = 2
          .
      end.
  end.
  else do:
      assign
          v-exists = yes
          v-range  = 3
      .
  end.
  if available buf_gds-grp-obj
  then do:
    find first buf_gds-grp-obj-attr no-lock
      where buf_gds-grp-obj-attr.node-code   = p-node-code
        and buf_gds-grp-obj-attr.host-code   = buf_gds-grp-obj.host-code
        and buf_gds-grp-obj-attr.obj-type    = buf_gds-grp-obj.obj-type
        and buf_gds-grp-obj-attr.obj-code    = buf_gds-grp-obj.obj-code
        and buf_gds-grp-obj-attr.attr-code   = 'NotCorrOP':U
      no-error .
    if available buf_gds-grp-obj-attr then do:
      assign
        v-notcorr-value = (if buf_gds-grp-obj-attr.attr-value = '' then ? else buf_gds-grp-obj-attr.attr-value)
      .
    end.
    else do:
      assign
        v-notcorr-value = ?
      .
    end.
    assign
    p-exists-notcorr = (if v-notcorr-value <> ? and p-notcorr = ?
                        then yes
                        else p-exists-notcorr)
    p-range-notcorr = if p-exists-notcorr and p-notcorr = ?
                      then v-range
                      else p-range-notcorr
    p-notcorr   =  if p-exists-notcorr and  p-notcorr = ?
                      then v-notcorr-value
                      else p-notcorr
    v-found =  (p-exists-notcorr ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
  else do:
    assign
    v-found =  (p-exists-notcorr  ) or (v-range <= 1)
    jj = jj + 1
    .
  end.
end.
end.
end procedure.
define variable vss-include-info15 as character format "X(65)" no-undo
initial "@(#)$Workfile$ $Revision$".
procedure grplib-get-full-name :
   define input parameter p-node-code  as integer      no-undo.
   define output parameter p-full-name as character    no-undo.
   do
on error undo, return error
:
    define variable v-upper-code    as integer           no-undo.
    define buffer buf_gds-grp       for ub.gds-grp.
    define buffer buf_upper_gds-grp for ub.gds-grp.
    find first buf_gds-grp no-lock
         where buf_gds-grp.node-code = p-node-code
    no-error.
    if not available buf_gds-grp
    then do:
        undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом " + string( p-node-code ).
    end.
    assign
        p-full-name  = ""
        v-upper-code = 1
    .
    do while buf_gds-grp.upper-code <> 0
    on error undo, return error "grplib-get-full-name: Ошибка составления полного имени группы"
    :
        assign
            p-full-name  = buf_gds-grp.node-name
                         + (if p-full-name <> "" then chr(47) else "")
                         + p-full-name
            v-upper-code = buf_gds-grp.upper-code
        .
        find first buf_gds-grp no-lock
             where buf_gds-grp.node-code = v-upper-code
        no-error.
        if not available buf_gds-grp
        then do:
            undo, return error "grplib-get-full-name: Не найдена группа товаров с кодом "
                                + string( v-upper-code )
                                + ". Ошибка ссылки в дереве товаров для узла p-node-code".
        end.
    end.
    assign
    p-full-name = p-full-name + (if p-full-name = "":U then "":U else chr(47))
    .
end.
end .
procedure grplib-get-node-from-full-name :
define input parameter p-full-name as character no-undo .
define output parameter p-node-code as integer no-undo .
define variable v-ii as integer no-undo .
define variable v-upper-code as integer no-undo .
define variable v-root-code as integer no-undo .
define variable v-entry as character no-undo .
define buffer buf_gds-grp       for ub.gds-grp.
do
on error undo, return error
:
  find first buf_gds-grp no-lock
      where buf_gds-grp.upper-code = 0
  no-error .
  if not available buf_gds-grp
  then do:
      undo, return error substitute("Не найдена корневая группа товаров (upper-code = 0)").
  end.
  else do:
    assign
    v-root-code = buf_gds-grp.node-code
    .
  end.
  v-upper-code = v-root-code.
  do v-ii = 1 to num-entries(p-full-name, chr(47)):
    assign
    v-entry = entry(v-ii, p-full-name, chr(47)).
    if v-entry = '' then leave.
    find first buf_gds-grp no-lock where
              buf_gds-grp.node-name = v-entry
          and buf_gds-grp.upper-code = v-upper-code
          no-error.
    if not available buf_gds-grp then do:
      undo, return error substitute("Не найдена подгруппа &1 в группе с вн. кодом &2", v-entry, v-upper-code).
    end.
    else do:
      p-node-code = buf_gds-grp.node-code.
      v-upper-code = buf_gds-grp.node-code.
    end.
  end.
end.
end .
procedure  chec-par :
define output parameter l-par as logical no-undo .
define input parameter l-host like ub.clients.obj-code no-undo .
define input parameter l-type like ub.clients.obj-type no-undo .
define input parameter l-code like ub.clients.obj-code no-undo .
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'alcohol'
  ,input  l-host
  ,input  l-type
  ,input  l-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-alcohol
  ,output par-type
  ) no-error .
 .
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input l-type
  ,input l-code
  ,input 'overval':U
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
    if thbjattr_thbj-attr.prop-code = 'pr-clt-q':U then par-pr-clt-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-dpl-q':U then par-pr-dpl-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-rdc-q':U then par-pr-rdc-q = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-equ-dq':U then par-pr-equ-dq = thbjattr_thbj-attr.property-value-integer .
    if thbjattr_thbj-attr.prop-code = 'pr-abs-d':U then par-pr-abs-d = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-altex':U then par-pr-altex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-parex':U then par-pr-parex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-sclex':U then par-pr-sclex = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-discm':U then par-pr-discm =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'pr-dscnt':U then par-pr-dscnt  = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-print':U then par-pr-print  = string ( thbjattr_thbj-attr.property-value-logical) .
    if thbjattr_thbj-attr.prop-code = 'pr-sigma':U then par-pr-sigma  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-incpc':U then par-pr-incpc  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-rndmt':U then par-pr-rndmt  =  thbjattr_thbj-attr.property-value-character .
    if thbjattr_thbj-attr.prop-code = 'pr-rndbs':U then par-pr-rndbs  = string ( thbjattr_thbj-attr.property-value-decimal) .
    if thbjattr_thbj-attr.prop-code = 'pr-notls':U then par-pr-notls = string ( thbjattr_thbj-attr.property-value-logical) .
    if v-cntxt-db-num = 0 then do:
      if thbjattr_thbj-attr.prop-code = 'pr-nogds0':U then par-pr-nogds =  thbjattr_thbj-attr.property-value-character.
      if thbjattr_thbj-attr.prop-code = 'pr-goods0':U then par-pr-goods =  thbjattr_thbj-attr.property-value-character.
    end.
    else do:
      if thbjattr_thbj-attr.prop-code = 'pr-nogds':U then par-pr-nogds =  thbjattr_thbj-attr.property-value-character.
      if thbjattr_thbj-attr.prop-code = 'pr-goods':U then par-pr-goods =  thbjattr_thbj-attr.property-value-character.
    end.
end.
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplmrgn in g#library2
  (input  ?
  ,input  l-type
  ,input  l-code
  ,output par-gen-mrgn-ie
  ,output par-gen-mrgn-iv
  ,output par-gen-mrgn-im
  ) no-error .
   IF error-status :error THEN message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "gbl/gtplmrgn.i"
     view-as alert-box error
   .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplpnakl in g#library2
  (input  ?
  ,input  l-type
  ,input  l-code
  ,output par-pr-nakl-ie
  ,output par-pr-nakl-iv
  ,output par-pr-nakl-im
  ) no-error .
   define variable ii as integer   no-undo .
   define variable nn as integer   no-undo .
   define variable v-fullname as character no-undo .
   nn = num-entries ( par-pr-nogds ).
   par-pr-nogds-long = "".
   if par-pr-nogds <> "0" and par-pr-nogds <> ""  then do:
      repeat ii = 1 to nn :
        run grplib-get-full-name  ( input integer(entry(ii,par-pr-nogds)) , output v-fullname ) .
        par-pr-nogds-long = par-pr-nogds-long + v-fullname + chr(4) .
      end.
      par-pr-nogds-long = trim (par-pr-nogds-long,chr(4)) .
   end.
l-par = true .
end procedure.
PROCEDURE cre-pr-list:
define input  parameter bc      like ub.price-list.b-code no-undo.
define input  parameter new-num like ub.price-doc.doc-num no-undo.
define output parameter new-rec as recid             no-undo.
define buffer buf-price-list for ub.price-list.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer buf-gds-prt    for ub.gds-prt.
define buffer root-gds-prt   for ub.gds-prt.
define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable local_vat-pc like ub.price-list.vat-pc    no-undo.
define variable local_slt-pc like ub.price-list.slt-pc    no-undo.
define variable cur-rt-base as decimal no-undo .
define variable cur-rt-rubl as decimal no-undo .
define variable p-hostcode as int no-undo .
define variable v-line-num as integer no-undo .
define variable v-skip-del-gds as logical no-undo initial no .
cre-pr:
do on error undo cre-pr, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  run check-use-bar-code ( buf-bar-code.b-code ) no-error .
  if error-status :error then do:
    message
      return-value skip
      "Ошибка !"
      view-as alert-box error
    .
    undo cre-pr, return.
  end.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find first root-gds-prt no-lock where
            root-gds-prt.upper-code = buf-goods.prt-root.
  if root-gds-prt.node-name <> '_Пустая шкала':U and
    buf-bar-code.in-code <> "" then do:
    message
      "Не допускается создавать спец. цены на партии для товаров с непустой шкалой!" skip (2)
      "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
      view-as alert-box error.
    undo cre-pr, return.
  end.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  if buf-goods.stts <> 0 and not v-skip-del-gds then do:
    message
      "Не допускается создавать цены на удаленные товары!" skip (2)
      "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
      view-as alert-box error.
    undo cre-pr, return.
  end.
  find  buf-price-doc where
        buf-price-doc.doc-num = new-num.
define variable v-ret as logical no-undo .
   run ver-modificator-price-is-null (
          input    buf-goods.artic        ,
          input    buf-goods.prod-type    ,
          input    buf-goods.prod-code    ,
          input    buf-price-doc.obj-type   ,
          input    buf-price-doc.obj-code   ,
          output   v-ret ).
      if v-ret = false then dO:
          message
            "Не допускается создавать цены на модификаторы с нулевой ценой !" skip (2)
            "Артикул:" buf-goods.artic "Код:" buf-goods.gds-code buf-goods.gds-name
            view-as alert-box error.
          undo cre-pr, return.
        end.
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_slt-pc
  ) no-error .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,input  bc
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  ) no-error .
  find first buf-price-list where
            buf-price-list.b-code  = buf-bar-code.b-code and
            buf-price-list.doc-num = new-num  and
            buf-price-list.price-type = ""    no-error .
  if not available buf-price-list then do:
    run calc-price-line-num (input  new-num , output v-line-num) .
    create buf-price-list.
    assign
      buf-price-list.line-num  = v-line-num
      buf-price-list.b-code    = buf-bar-code.b-code
      buf-price-list.doc-num   = buf-price-doc.doc-num
      buf-price-list.prod-type = buf-goods.prod-type
      buf-price-list.prod-code = buf-goods.prod-code
      buf-price-list.artic     = buf-goods.artic
      buf-price-list.obj-type  = buf-price-doc.obj-type
      buf-price-list.obj-code  = buf-price-doc.obj-code
      buf-price-list.vat-pc    = local_vat-pc
      buf-price-list.slt-pc    = local_slt-pc
      buf-price-list.price-prev = cur-pr
      .
    if  buf-gds-prt.upper-code = buf-goods.prt-root and
        buf-bar-code.in-code   = "" and
        buf-bar-code.part-code = "" and
        buf-bar-code.unit-cli  = buf-goods.unit-base then do:
      buf-price-list.main-price = yes.
      if cur-pr <> ? then do:
        run exp-prt (input buf-goods.gds-code,
                    input cur-dn,
                    input new-num,
                    output new-rec) no-error.
        if error-status :error then do:
          message
            "Ошибка вызова процедуры разворота специальных и неосновных цен."
            view-as alert-box error.
          undo cre-pr, return error.
        end.
      end.
    end.
    else do:
      if buf-bar-code.unit-cli <> buf-goods.unit-base then do:
        buf-price-list.d-pcnt = ?.
      end.
      buf-price-list.main-price = no.
    end.
  end.
end.
new-rec = recid (buf-price-list).
END PROCEDURE.
procedure calc-price-line-num :
 do
 on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
 :
define input parameter p-doc-num as character no-undo .
define output parameter p-num  as integer no-undo .
define variable v-fact as integer no-undo .
define buffer buf_1_price-list for ub.price-list .
p-num = 1 .
find last  buf_1_price-list no-lock where
           buf_1_price-list.doc-num = p-doc-num use-index line-num no-error .
           if available buf_1_price-list then
                assign
                  v-fact = buf_1_price-list.line-num
                .
v-fact = v-fact + 1.
if v-fact <> ? then if p-num < v-fact then p-num = v-fact .
 end.
end procedure.
PROCEDURE del-pr-list:
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter round-method as character         no-undo.
define input parameter round-base   as decimal      no-undo.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define variable l-ov-on as logical no-undo .
del-pr:
do on error undo del-pr, return error:
  find first  buf-price-list no-lock where
              buf-price-list.doc-num    = d-num and
              buf-price-list.b-code     = bc and
              buf-price-list.price-type = "" no-error.
  if not available buf-price-list then
    undo del-pr, return error.
  find  buf-goods no-lock where
        buf-goods.prod-type = buf-price-list.prod-type and
        buf-goods.prod-code = buf-price-list.prod-code and
        buf-goods.artic     = buf-price-list.artic.
  if buf-price-list.main-price then do:
    for each  buf-price-list exclusive-lock where
              buf-price-list.doc-num   = d-num and
              buf-price-list.artic     = buf-goods.artic and
              buf-price-list.prod-type = buf-goods.prod-type and
              buf-price-list.prod-code = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code = buf-price-list.b-code
    on error undo del-pr, return error:
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.buf-price-list.obj-type
  ,input  ub.buf-price-list.obj-code
  ,input  ub.buf-price-list.artic
  ,input  ub.buf-price-list.prod-type
  ,input  ub.buf-price-list.prod-code
  ,input  'ov-on=request:exclusive'
  ,output l-ov-on
  ) no-error .
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка получения признака товара на объекте" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
      end.
      if l-ov-on then do:
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.buf-price-list.obj-type
  ,input  ub.buf-price-list.obj-code
  ,input  ub.buf-price-list.artic
  ,input  ub.buf-price-list.prod-type
  ,input  ub.buf-price-list.prod-code
  ,input  'ov-on=false'
  ,output l-ov-on
  ) no-error .
        if error-status :error then do:
        end.
       end.
      delete buf-price-list.
    end.
  end.
  else do:
    find  buf-bar-code no-lock where
          buf-bar-code.b-code = buf-price-list.b-code.
    if buf-bar-code.unit-cli <> buf-goods.unit-base then do:
      message
        "Нельзя удалить неосновную цену." skip
        "Неосновная цена (скидка) не может быть неопределенной." skip
        "Код:" bc skip
        "Переоценка:" d-num
        view-as alert-box error.
      undo del-pr, return error.
    end.
    find current buf-price-list exclusive-lock no-error .
    delete buf-price-list.
    run calc-base-upd (input buf-bar-code.b-code,
                      input d-num,
                      input round-method,
                      input round-base) no-error.
    if error-status :error then
      undo del-pr, return error.
  end.
end.
END PROCEDURE.
PROCEDURE calc-base-upd:
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter round-method as character         no-undo.
define input parameter round-base   as decimal      no-undo.
define buffer alt-bar-code   for ub.bar-code.
define buffer alt-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
calc-base:
do on error undo calc-base, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  for each  alt-bar-code no-lock where
            alt-bar-code.gds-code  = buf-bar-code.gds-code and
            alt-bar-code.node-code = buf-bar-code.node-code and
            alt-bar-code.part-code = buf-bar-code.part-code and
            alt-bar-code.in-code   = buf-bar-code.in-code and
            alt-bar-code.unit-cli <> buf-goods.unit-base,
      each  alt-price-list where
            alt-price-list.doc-num    = d-num and
            alt-price-list.b-code     = alt-bar-code.b-code and
            alt-price-list.price-type = ""
      on error undo calc-base, return error:
    run calc-pr-alt (input d-num,
                    input alt-bar-code.b-code,
                    input round-method,
                    input round-base) no-error.
    if error-status:error then
      undo calc-base, return error.
  end.
end.
END PROCEDURE.
PROCEDURE calc-pr-alt:
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter bc    like ub.bar-code.b-code   no-undo.
define input parameter r-method as character             no-undo.
define input parameter r-base   as decimal              no-undo.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer old-price-list for ub.price-list.
define variable pr-rec   as   recid                  no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.
pr-alt:
do on error undo pr-alt, return error:
  if r-method = ? or
     r-base = ? then do:
    message
      "Нельзя удалить основную цену." skip
      "Не задан способ округления для расчета зависящих от нее неосновных цен." skip
      "Код:" bc skip
      "Переоценка:" d-num
      view-as alert-box error.
    undo pr-alt, return error.
  end.
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-list where
        buf-price-list.doc-num = buf-price-doc.doc-num and
        buf-price-list.b-code  = bc.
  if buf-price-list.d-pcnt = ? then do:
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodepls in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,input  bc
  ,input  0
  ,input  0
  ,output pr-rec
  ,output pr-c-b-r
  )  .
    find old-price-list no-lock where
        recid (old-price-list) = pr-rec no-error.
    if available old-price-list and
      old-price-list.b-code = bc then
      buf-price-list.d-pcnt = old-price-list.d-pcnt.
    else
      buf-price-list.d-pcnt = 0.
  end.
   if buf-price-list.d-pcnt = ? then do:
      assign
        buf-price-list.price-sale =   if available old-price-list then old-price-list.price-sale else 0
        buf-price-list.calc-method =  'Не-считать':U + 'Основная':U
        .
  end.
  else do:
      assign
        buf-price-list.price-sale =   fnc-base-price (buf-bar-code.b-code, buf-price-list.doc-num) *
                                      buf-bar-code.cli-base-rate *
                                      (1 - buf-price-list.d-pcnt / 100)
        buf-price-list.calc-method =  'Основная':U
        .
case r-method :
  when '9-окончание':U then do:
    if buf-price-list.price-sale < 29 then do:
      if (buf-price-list.price-sale - truncate (buf-price-list.price-sale, 0)) <> 0 then do:
        assign
          buf-price-list.price-sale = truncate (buf-price-list.price-sale, 0) + 1
        .
      end.
    end.
    else do:
      if (buf-price-list.price-sale modulo 10) < 3 then do:
        assign
          buf-price-list.price-sale = (buf-price-list.price-sale - (buf-price-list.price-sale modulo 100))
              + ( truncate (((buf-price-list.price-sale modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          buf-price-list.price-sale = (buf-price-list.price-sale - (buf-price-list.price-sale modulo 100))
              + ( truncate (((buf-price-list.price-sale modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        buf-price-list.price-sale = round (buf-price-list.price-sale, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if buf-price-list.price-sale < r-base then do:
      assign
        buf-price-list.price-sale = truncate (buf-price-list.price-sale, 0) + 0.99
      .
    end.
    else do:
      assign
        buf-price-list.price-sale = truncate (buf-price-list.price-sale / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      buf-price-list.price-sale = round (buf-price-list.price-sale, 0)
    .
  end.
  when 'Произвольно':U then do:
    if r-base <> 0 then do:
      assign
        buf-price-list.price-sale = round (buf-price-list.price-sale / r-base, 0) * r-base
      .
      if buf-price-list.price-sale = 0 then do:
        assign
          buf-price-list.price-sale = r-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if r-base <> 0 then do:
      if truncate ( buf-price-list.price-sale / r-base, 0 ) <> (buf-price-list.price-sale / r-base) then do:
        assign
          buf-price-list.price-sale = truncate (buf-price-list.price-sale / r-base, 0) * r-base + r-base
        .
      end.
    end.
    if buf-price-list.price-sale = 0 then do:
      assign
        buf-price-list.price-sale = r-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if r-base <> 0 then do:
      assign
        buf-price-list.price-sale = buf-price-list.price-sale * r-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" r-method skip
      "round-base"   r-base   skip
      "price"        buf-price-list.price-sale             skip
      view-as alert-box error .
  end.
end.
  end.
end.
END PROCEDURE.
PROCEDURE calc-pr-discnt:
define input parameter d-num like ub.price-doc.doc-num no-undo.
define input parameter bc    like ub.bar-code.b-code   no-undo.
define buffer buf-price-doc  for ub.price-doc.
define buffer buf-price-list for ub.price-list.
define buffer buf-bar-code   for ub.bar-code.
define buffer buf-goods      for ub.goods.
define buffer old-price-list for ub.price-list.
define variable pr-rec   as   recid                  no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.
pr-discnt:
do on error undo pr-discnt, return error:
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-list where
        buf-price-list.doc-num = buf-price-doc.doc-num and
        buf-price-list.b-code  = bc.
  buf-price-list.d-pcnt = (1 -
                           buf-price-list.price-sale /
                           fnc-base-price (buf-bar-code.b-code, buf-price-list.doc-num) /
                           buf-bar-code.cli-base-rate) *
                           100
                           .
end.
END PROCEDURE.
PROCEDURE calc-pr-sub :
define  input  parameter bc             like ub.price-list.b-code no-undo.
define  input  parameter d-num          like ub.price-doc.doc-num no-undo.
define  input  parameter calc-method  as character    no-undo.
define  input  parameter increase-pc  as decimal      no-undo.
define  input  parameter round-method as character    no-undo.
define  input  parameter round-base   as decimal      no-undo.
define  output parameter calc-rec     as recid        no-undo.
define  buffer buf-price-list for ub.price-list.
define  buffer buf-bar-code   for ub.bar-code.
define  buffer buf-goods      for ub.goods.
define  buffer buf-gds-prt    for ub.gds-prt.
define  buffer buf-gds-grp    for ub.gds-grp.
define  buffer buf-price-doc  for ub.price-doc.
calc-sub:
do on error undo calc-sub, return error:
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find  buf-price-list where
        buf-price-list.doc-num    = d-num and
        buf-price-list.b-code     = bc and
        buf-price-list.price-type = "".
  find  buf-price-doc where
        buf-price-doc.doc-num = d-num.
  calc-rec = recid (buf-price-list).
  if buf-price-list.main-price then do:
    for each  buf-price-list where
              buf-price-list.doc-num    = buf-price-doc.doc-num and
              buf-price-list.main-price = no and
              buf-price-list.artic      = buf-goods.artic and
              buf-price-list.prod-type  = buf-goods.prod-type and
              buf-price-list.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code   = buf-price-list.b-code and
              buf-bar-code.unit-cli = buf-goods.unit-base
        on error undo calc-sub, return error:
      run calc-pr-list (input  buf-bar-code.b-code,
                        input  buf-price-list.doc-num,
                        input  calc-method,
                        input  increase-pc,
                        input  round-method,
                        input  round-base,
                        input ? ,
                        input ? ,
                        input ? ,
                        input ? ,
                        output calc-rec) no-error.
      if error-status :error then
        undo calc-sub, return error.
      calc-rec = recid (buf-price-list).
    end.
    for each  buf-price-list where
              buf-price-list.doc-num    = buf-price-doc.doc-num and
              buf-price-list.main-price = no and
              buf-price-list.artic      = buf-goods.artic and
              buf-price-list.prod-type  = buf-goods.prod-type and
              buf-price-list.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code    = buf-price-list.b-code and
              buf-bar-code.unit-cli <> buf-goods.unit-base
        on error undo calc-sub, return error:
      run calc-pr-alt (input buf-price-doc.doc-num,
                      input buf-bar-code.b-code,
                      input round-method,
                      input round-base) no-error.
      if error-status :error then
        undo calc-sub, return error.
    end.
  end.
  else do:
    run calc-base-upd (input buf-bar-code.b-code,
                      input buf-price-doc.doc-num,
                      input round-method,
                      input round-base) no-error.
    if error-status :error then
      undo calc-sub, return error.
  end.
end.
END PROCEDURE.
procedure ver-pr-nogds :
define input  parameter p-gds-code      as integer   no-undo .
define input  parameter p-par-pr-nogds  as character no-undo .
define output parameter p-not           as logical   no-undo .
define output parameter p-str           as character no-undo .
define buffer buf_goods for ub.goods  .
define variable nn as integer   no-undo .
define variable ii as integer   no-undo .
define variable v-namegrp as character no-undo .
  do
  on error undo, return error return-value
  :
  if p-par-pr-nogds = "1" then do:
     assign
      p-not = true
      p-str = ""
     .
     return .
  end.
  assign
    p-not = false
    p-str = ""
  .
  find first buf_goods no-lock where
             buf_goods.gds-code = p-gds-code no-error .
  nn = num-entries(par-pr-nogds-long,chr(4)) .
  repeat ii = 1 to nn:
     v-namegrp = entry(ii , par-pr-nogds-long , chr(4) ) no-error .
     if buf_goods.grp-name  begins v-namegrp  then do:
        assign
          p-not = true
          p-str = substitute ( "Товар &1 &2 &3  может быть включен в ДНЦ из-за исключения запрета по группе : &4"  , buf_goods.artic, buf_goods.gds-name , buf_goods.grp-name , v-namegrp )
        .
        leave .
     end.
  end.
  end.
end procedure.
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
PROCEDURE write-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-bonus as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
               ub.contract-specif-attr.contract-num = p-contract-num  and
               ub.contract-specif-attr.host-code    = p-host-code     and
               ub.contract-specif-attr.gds-code     = p-gds-code      and
               ub.contract-specif-attr.attr-code    = 'bonus':U
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = 'bonus':U
         .
      end.
      ub.contract-specif-attr.attr-value  = string (v-bonus) .
end.
END PROCEDURE.
PROCEDURE read-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-bonus as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = 'bonus':U
           no-error .
   if available ub.contract-specif-attr then  v-bonus = decimal (ub.contract-specif-attr.attr-value ) .
                                        else  v-bonus = 0 .
end.
END PROCEDURE.
PROCEDURE write-prc-min :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-prc-min        as decimal   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = p-contract-num  and
              ub.contract-specif-attr.host-code    = p-host-code     and
              ub.contract-specif-attr.gds-code     = p-gds-code      and
              ub.contract-specif-attr.attr-code    = 'prc-min':U
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = 'prc-min':U
              ub.contract-specif-attr.attr-value  = string (v-prc-min)
         .
      end.
      else do:
         ub.contract-specif-attr.attr-value  = string (v-prc-min) .
      end.
    find first ub.contract-specif exclusive-lock where
        ub.contract-specif.contract-num = p-contract-num and
        ub.contract-specif.host-code    = p-host-code    and
        ub.contract-specif.gds-code     = p-gds-code.
        ub.contract-specif.whole-send-news  = ub.contract-specif.whole-send-news + 1.
end.
END PROCEDURE.
PROCEDURE read-prc-min :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-prc-min as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = 'prc-min':U
           no-error .
   if available ub.contract-specif-attr then  v-prc-min = decimal (ub.contract-specif-attr.attr-value ) .
                                        else  v-prc-min = 0 .
end.
END PROCEDURE.
PROCEDURE write-retro-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define input  parameter v-retro-bonus as character   no-undo .
  do
  on error undo, return error return-value
  :
    find first ub.contract-specif-attr exclusive-lock  where
              ub.contract-specif-attr.contract-num = p-contract-num  and
              ub.contract-specif-attr.host-code    = p-host-code     and
              ub.contract-specif-attr.gds-code     = p-gds-code      and
              ub.contract-specif-attr.attr-code    = "retro-bonus"
              no-error .
      if not available ub.contract-specif-attr then do:
         create ub.contract-specif-attr .
         assign
              ub.contract-specif-attr.contract-num = p-contract-num
              ub.contract-specif-attr.host-code    = p-host-code
              ub.contract-specif-attr.gds-code     = p-gds-code
              ub.contract-specif-attr.attr-code    = "retro-bonus"
         .
         ub.contract-specif-attr.attr-value  = v-retro-bonus no-error.
         if error-status:error then
            message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
      end.
      else do:
         ub.contract-specif-attr.attr-value  = v-retro-bonus no-error.
         if error-status:error then
            message "Превышен допустимый объем информации о ретро-бонусах. Удалите исторические или неактуальны периоды" view-as alert-box error.
      end.
    find first ub.contract-specif exclusive-lock where
        ub.contract-specif.contract-num = p-contract-num and
        ub.contract-specif.host-code    = p-host-code    and
        ub.contract-specif.gds-code     = p-gds-code.
        ub.contract-specif.whole-send-news  = ub.contract-specif.whole-send-news + 1.
end.
END PROCEDURE.
PROCEDURE read-retro-bonus :
define input  parameter p-contract-num   like ub.contract-specif.contract-num  no-undo .
define input  parameter p-host-code      like ub.contract-specif.host-code     no-undo .
define input  parameter p-gds-code       like ub.contract-specif.gds-code      no-undo .
define output parameter v-retro-bonus as character   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.contract-specif-attr no-lock  where
           ub.contract-specif-attr.contract-num = p-contract-num  and
           ub.contract-specif-attr.host-code    = p-host-code     and
           ub.contract-specif-attr.gds-code     = p-gds-code      and
           ub.contract-specif-attr.attr-code    = "retro-bonus"
           no-error .
   if available ub.contract-specif-attr then  v-retro-bonus = ub.contract-specif-attr.attr-value  .
                                        else  v-retro-bonus = "" .
end.
END PROCEDURE.
procedure ver-pr-discn :
define input parameter   p-mode as character no-undo .
define input parameter   p-doc like ub.price-doc.doc-num no-undo.
define input parameter   trn-doc-code like ub.trn-doc.doc-code no-undo .
define output parameter  p-err as logical no-undo .
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
define buffer buf_bar-code for ub.bar-code  .
define buffer b_price-doc  for ub.price-doc .
define buffer b_price-list for ub.price-list .
define buffer b_trn-doc    for ub.trn-doc .
define buffer b_doc-line   for ub.doc-line .
define buffer bl_goods           for ub.goods .
define buffer bl_gds-grp         for ub.gds-grp .
define variable t-prc            as decimal   no-undo .
define variable p-prc-min        as decimal   no-undo .
define variable p-prc-max        as decimal   no-undo .
define variable p-increase-pc    as decimal   no-undo .
define variable p-round-method   as character no-undo .
define variable p-base           as decimal   no-undo .
define variable v-koff           as decimal   no-undo .
define variable p-node-code      as integer   no-undo .
define variable p-host-code      as integer   no-undo .
define variable p-obj-type       as character no-undo .
define variable p-obj-code       as integer   no-undo .
define variable p-value-margin   as integer   no-undo .
define variable p-type-margin    as logical   no-undo .
define variable p-value-increase as integer   no-undo .
define variable p-type-increase  as logical   no-undo .
define variable p-value-rmethod  as integer   no-undo .
define variable p-type-rmethod   as logical   no-undo .
define variable l_price           as decimal   no-undo .
define variable l_pricewithvat    as decimal   no-undo .
define variable l_pricewithoutvat as decimal   no-undo .
define variable l_prod-vat        as decimal   no-undo .
define variable pr-discm          as character no-undo .
define variable pr-gen-margin     as character no-undo .
p-err = false .
define variable cost-base     as decimal  no-undo .
define variable cost-rubl     as decimal  no-undo .
define variable v-price-base  as decimal  no-undo .
define variable v-price-rubl  as decimal  no-undo .
define variable cur-rt-base   as decimal  no-undo .
define variable cur-rt-rubl   as decimal  no-undo .
define variable f-cost as decimal no-undo .
define variable s-cost as decimal no-undo .
define variable f-qnty as decimal no-undo .
define variable s-qnty as decimal no-undo .
define variable p-attr-code    like UB.price-list-attr.attr-code  no-undo .
define variable p-b-code       like ub.price-list-attr.b-code     no-undo .
define variable p-doc-num      like ub.price-list-attr.doc-num    no-undo .
define variable p-price-type   like ub.price-list-attr.price-type no-undo .
define variable p-attr-value   like ub.price-list-attr.attr-value no-undo .
define variable v-bonus as decimal   no-undo .
define variable l_price0 as decimal   no-undo .
define buffer   buf_contract-specif for ub.contract-specif  .
find first b_price-doc where b_price-doc.doc-num    = p-doc no-lock  no-error .
assign
    p-host-code  = b_price-doc.host-code
    p-obj-type   = b_price-doc.obj-type
    p-obj-code   = b_price-doc.obj-code
.
define variable v-ok as logical   no-undo .
define variable vss-include-info27 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_discount':U
    ,input  'object':U
    ,input  p-host-code
    ,input  p-obj-type
    ,input  p-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-ok
    )  .
end.
if v-ok = true then return .
pr-discm      = par-pr-discm .
if trim(pr-discm) = "" then return .
if pr-discm = 'sale-' then pr-discm = 'sale' .
for each  b_price-list where b_price-list.doc-num    = p-doc no-lock :
    find first bl_goods   where b_price-list.artic     = bl_goods.artic     and
                                b_price-list.prod-code = bl_goods.prod-code and
                                b_price-list.prod-type = bl_goods.prod-type no-lock no-error .
    if error-status :error then return error.
    find first buf_bar-code no-lock where
               buf_bar-code.b-code  = b_price-list.b-code
               no-error .
    if available buf_bar-code then v-koff = buf_bar-code.cli-base-rate .
    else v-koff = 1.
    if v-koff = ? or v-koff = 0 then v-koff = 1.
    assign
    p-node-code  = bl_goods.grp-code
    .
    run gds-attr-margin-value
    (
      input   bl_goods.gds-code,
      input   p-obj-type ,
      input   p-obj-code ,
      output  p-prc-min  ,
      output  p-prc-max  ,
      output  p-increase-pc,
      output  p-round-method,
      output  p-base        ,
      output  p-value-margin    ,
      output  p-type-margin     ,
      output  p-value-increase   ,
      output  p-type-increase   ,
      output  p-value-rmethod   ,
      output  p-type-rmethod
      ) no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "123"
        view-as alert-box error
      .
    if p-type-margin = false  then next.
 if  trn-doc-code = ? or trn-doc-code = "" then do:
        if b_price-list.main-price = true then do :
          case  pr-discm :
              when "prod":u then do:
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-list.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_pricewithoutvat
 , output l_price
 , output l_prod-vat
 , output v-str
 , output v-str
        )  .
                  t-prc  =  (b_price-list.price-sale  / l_price - 1) * 100  .
              end.
              when "prod-vat":u then do:
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-list.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_price
 , output l_pricewithvat
 , output l_prod-vat
 , output v-str
 , output v-str
        )  .
                  t-prc  =  (b_price-list.price-sale  / l_price - 1) * 100  .
              end.
              when "cost-vat":u then do:
                  run str/gdsnovat.p ('Учет-безНДС':U,
                          b_price-list.obj-type,
                          b_price-list.obj-code,
                          p-host-code,
                          b_price-list.artic,
                          b_price-list.prod-type,
                          b_price-list.prod-code,
                          0 ,
                          ? ,
                          ? ,
                          ? ,
                          output cost-base   ,
                          output cost-rubl   ,
                          output v-price-base  ,
                          output v-price-rubl  ,
                          output cur-rt-base ,
                          output cur-rt-rubl ).
                          l_price =  if var-pr-r-b = "rubl" then v-price-rubl else v-price-base .
                          t-prc = (b_price-list.price-sale / l_price - 1) * 100.
              end.
            when "cost":u       then do:
              t-prc =  fnc-cost-pc (buffer b_price-list) .
            end.
            when "sale":u then do:
              t-prc =  fnc-pr-pc   (buffer b_price-list) .
            end.
          end case.
        end.
        else do:
          case  pr-discm :
              when "prod":u then do:
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-list.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_pricewithoutvat
 , output l_price
 , output l_prod-vat
 , output v-str
 , output v-str
        )  .
              end.
              when "prod-vat":u then do:
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-list.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_price
 , output l_pricewithvat
 , output l_prod-vat
 , output v-str
 , output v-str
        )  .
            end.
            when "cost":u
            or when "cost-vat":u
            then do:
              l_price =  fnc-cost (buffer b_price-list) .
            end.
            when "sale":u then do:
              l_price =  fnc-pr   (buffer b_price-list) .
            end.
          end case.
          t-prc = (b_price-list.price-sale / (l_price * v-koff) - 1) * 100.
        end.
end.
else do:
    find first b_trn-doc where b_trn-doc.doc-code = trn-doc-code no-lock no-error .
    if available b_trn-doc then do:
     find first b_doc-line where
        b_doc-line.doc-code  = b_trn-doc.doc-code and
        b_doc-line.artic     = bl_goods.artic     and
        b_doc-line.prod-code = bl_goods.prod-code and
        b_doc-line.prod-type = bl_goods.prod-type no-lock no-error .
     end.
     else do:
       return error return-value + "Не найден документ с номером " + trn-doc-code.
     end.
define variable vss-include-info32 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  b_trn-doc.host-code,
    INPUT  b_trn-doc.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = b_trn-doc.host-code
      i-gl-Contract-Code  = b_trn-doc.contract-code
      .
END.
    FIND FIRST buf_contract-specif
           NO-LOCK
           WHERE
               buf_contract-specif.Host-code    = i-gl-Host-Code
           AND buf_contract-specif.Contract-num = i-gl-Contract-Code
           AND buf_contract-specif.Gds-code     = bl_goods.gds-code
           NO-ERROR
           .
    if available buf_contract-specif then do:
        run read-bonus (
            input  buf_contract-specif.contract-num  ,
            input  buf_contract-specif.host-code     ,
            input  buf_contract-specif.gds-code      ,
            output v-bonus  ) .
    end.
    else do:
        v-bonus  = 0 .
    end.
      if b_trn-doc.ext-doc-type = 'ie':U then   pr-gen-margin = par-gen-mrgn-ie.
      if b_trn-doc.ext-doc-type = 'iv':U then   pr-gen-margin = par-gen-mrgn-iv.
      if b_trn-doc.ext-doc-type = 'im':U  then   pr-gen-margin = par-gen-mrgn-im.
      pr-gen-margin = lc(pr-gen-margin).
      if available b_doc-line then do:
      case  pr-discm :
        when "cost":u then do:
                f-qnty = 0.
                find ub.gds-obj no-lock where
                    ub.gds-obj.gds-code = bl_goods.gds-code and
                    ub.gds-obj.obj-type = b_trn-doc.obj-type and
                    ub.gds-obj.obj-code = b_trn-doc.obj-code no-error.
                if  available ub.gds-obj then
                  if bl_goods.gds-type = 'т':U then do:
                          if var-pr-r-b = "rubl" then
                              assign
                                f-cost = if  ub.gds-obj.avrg-rubl = ? then 0 else ub.gds-obj.avrg-rubl
                                f-qnty = ub.gds-obj.avrg-qnty
                                .
                          else
                              assign
                                f-cost = if  ub.gds-obj.avrg-base = ? then 0 else ub.gds-obj.avrg-base
                                f-qnty = ub.gds-obj.avrg-qnty
                                .
                      end.
                    else  f-cost = ?.
                else f-cost = ?.
           if pr-gen-margin = 'before-margin':U then do:
assign
  price-rubl-with-tax-loc = b_doc-line.price-rubl
  price-base-with-tax-loc = b_doc-line.price-base
.
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = b_trn-doc.doc-code
      and in-vatp_doc-attr.attr-code = 'envd':U
    no-error .
    if available in-vatp_doc-attr
       then do:
       assign
         in-vatp-have-vat-slt = no.
   end.
   else do:
     assign
       in-vatp-have-vat-slt = yes.
   end.
   find first in-vatp-goods where in-vatp-goods.artic     = b_doc-line.artic     and
                                     in-vatp-goods.prod-type = b_doc-line.prod-type and
                                     in-vatp-goods.prod-code = b_doc-line.prod-code no-lock.
   if (not b_trn-doc.internal and
           b_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = b_doc-line.road-tax
          road-tax-rubl-loc = b_doc-line.road-tax * b_trn-doc.base-rate / b_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = b_doc-line.road-tax
          road-tax-base-loc = b_doc-line.road-tax / b_trn-doc.base-rate * b_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if b_doc-line.transport-base = ? then 0 else b_doc-line.transport-base)
        transport-rubl-loc = (if b_doc-line.transport-rubl = ? then 0 else b_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if b_doc-line.other-base     = ? then 0 else b_doc-line.other-base)
        other-rubl-loc     = (if b_doc-line.other-rubl     = ? then 0 else b_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if b_doc-line.vat-pc         = ? then 0 else b_doc-line.vat-pc)
        slt-pc-loc         = (if b_doc-line.slt-pc         = ? then 0 else b_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = b_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = b_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = b_doc-line.obj-code  and
                                      in-vatp-parts.artic     = b_doc-line.artic     and
                                      in-vatp-parts.prod-type = b_doc-line.prod-type and
                                      in-vatp-parts.prod-code = b_doc-line.prod-code
                         use-index out-code no-lock:
          accumulate  in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-base * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-base     * in-vatp-parts.fact-qnty (total)
                      in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty (total)
                                                                                                              (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                                            (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))  (total)
                      (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc))  (total)
                      .
      end.
      ASSIGN
        road-tax-base-loc   = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        transport-base-loc  = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        other-base-loc      = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
        other-rubl-loc      = if b_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / b_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if b_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b_doc-line.fact-qnty   else 0
        slt-base-loc        = if b_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if b_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / b_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if b_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / b_doc-line.fact-qnty   else 0
        vat-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))  / (100 + in-vatp-parts.vat-pc)))
        slt-pc-loc          = (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                      / (100 + in-vatp-parts.slt-pc))).
      if road-tax-base-loc  = ? then road-tax-base-loc  = 0.
      if road-tax-rubl-loc  = ? then road-tax-rubl-loc  = 0.
      if transport-base-loc = ? then transport-base-loc = 0.
      if transport-rubl-loc = ? then transport-rubl-loc = 0.
      if other-base-loc     = ? then other-base-loc     = 0.
      if other-rubl-loc     = ? then other-rubl-loc     = 0.
      assign
        transport-cli-loc      = 0
        other-cli-loc          = 0
        road-tax-cli-loc       = ?
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
ASSIGN
          price-base-without-tax-loc = price-base-with-tax-loc - vat-base-loc - slt-base-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))
    price-rubl-without-tax-loc = price-rubl-with-tax-loc - vat-rubl-loc - slt-rubl-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))
.
             if var-pr-r-b = "rubl" then
                 s-cost = price-rubl-with-tax-loc.
               else
                 s-cost = price-base-with-tax-loc.
             s-qnty = b_doc-line.fact-qnty .
           end.
           else do:
             assign
              s-cost = 0
              s-qnty = 0
             .
           end.
           l_price  =  (f-cost * f-qnty + s-cost * s-qnty ) / (f-qnty + s-qnty)  .
        end.
        when "cost-vat":u then do:
             run str/gdsnovat.p ('Уч+накл-НДС':U,
                     b_trn-doc.obj-type,
                     b_trn-doc.obj-code,
                     b_trn-doc.host-code,
                     b_doc-line.artic,
                     b_doc-line.prod-type,
                     b_doc-line.prod-code,
                     0 ,
                     b_doc-line.doc-code,
                     ?,
                     ?,
                     output cost-base   ,
                     output cost-rubl   ,
                     output v-price-base  ,
                     output v-price-rubl  ,
                     output cur-rt-base ,
                     output cur-rt-rubl ).
                     if var-pr-r-b = "rubl"
                        then l_price = v-price-rubl.
                        else l_price = v-price-base.
        end.
        when "sale":u then do:
              l_price = ( if var-pr-r-b = "rubl"
                             then b_doc-line.price-rubl
                             else b_doc-line.price-base ).
        end.
        when "prod":u then do:
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-list.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_pricewithoutvat
 , output l_price
 , output l_prod-vat
 , output v-str
 , output v-str
        )  .
        end.
        when "prod-vat":u then do:
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-list.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_price
 , output l_pricewithvat
 , output l_prod-vat
 , output v-str
 , output v-str
        )  .
        end.
      end case.
       run view-price-list-attr (
            input   'full-price-sale':U   ,
            input   b_price-list.b-code       ,
            input   b_price-list.doc-num      ,
            input   b_price-list.price-type   ,
            output  p-attr-value   ).
           if not ( p-attr-value = ? or p-attr-value = "")  then
                   tt-price-sale = decimal(p-attr-value).
              else  tt-price-sale = b_price-list.price-sale .
        if v-bonus <> ? and v-bonus <> 0 then do:
            l_price0 = l_price .
            l_price = l_price + ( l_price * v-bonus / 100 ) .
        end.
        t-prc = ( (tt-price-sale / v-koff)   / l_price - 1) * 100 .
   end.
end.
  if  p-prc-max <> ? then do:
    if  t-prc <> ? and ( p-prc-max < t-prc  or p-prc-min > t-prc)
    then do:
      message (if b_price-list.main-price = true then "По товару :"
          else "По признаку"  )
          b_price-list.artic
          b_price-list.prod-type
          b_price-list.prod-code skip
          "бар-код: " b_price-list.b-code skip
                          skip
               fnc-pr  (buffer b_price-list)
          skip
        "Процент торговой наценки вышел за интервал возможных значений !!! " skip
        "Процент не менее :" p-prc-min "%" skip
        "Процент не более :" p-prc-max "%" skip
        "Процент фактический :" t-prc  "%"  skip
        "переоценка " b_price-list.doc-num
            view-as alert-box error .
              p-err = true .
              undo , return error .
    end.
    else do:
       if  t-prc = ? then  do:
          if pr-discm = "sale"  then do:
          end.
          else do:
            message (if b_price-list.main-price = true then "По товару :"
            else "По признаку"  )
            b_price-list.artic
            b_price-list.prod-type
            b_price-list.prod-code skip
            "бар-код: " b_price-list.b-code skip
            fnc-pr  (buffer b_price-list) skip
            "Нет базовой цены для расчета процента наценки !" skip
            "Процент торговой наценки вышел за интервал возможных значений !!! " skip
            "Процент не менее :" p-prc-min "%" skip
            "Процент не более :" p-prc-max "%" skip
            "Процент фактический :" t-prc  "%"  skip
            "переоценка " b_price-list.doc-num
            view-as alert-box error .
            p-err = true .
            undo , return error .
        end.
       end.
    end.
  end.
end.
end procedure.
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-alc-min-price :
 do
 on error undo, return error return-value
 :
  define input parameter   p-doc        like ub.price-doc.doc-num no-undo.
  define output parameter  p-err        as logical no-undo .
  define variable v-alcohol-prod  as logical   no-undo.
  define variable v-alc-min-price as character no-undo.
  define variable v-type          as character no-undo.
  define variable i               as integer   no-undo.
  define variable proof-price     as character no-undo.
  define variable v-base-code     as integer   no-undo.
  define variable v-curr-r-b      as character no-undo.
  define variable v-price-sale    as decimal   no-undo.
  define variable v-abbr          as character no-undo.
  define buffer buf_goods       for ub.goods .
  define buffer buf_gds-obj     for ub.gds-obj .
  define buffer buf_gds-grp-obj for ub.gds-grp-obj .
  define buffer b_price-doc     for ub.price-doc .
  define buffer b_price-list    for ub.price-list .
  define buffer buf_currency    for ub.currency .
  find first b_price-doc no-lock
       where b_price-doc.doc-num = p-doc no-error .
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  b_price-doc.host-code
  ,output v-base-code
  )  .
  find first buf_currency no-lock
       where buf_currency.curr-code = v-base-code no-error .
  if available buf_currency then do:
    assign v-abbr = buf_currency.curr-abbr .
  end.
  for each b_price-list no-lock
     where b_price-list.doc-num = p-doc :
    find first buf_goods no-lock
         where buf_goods.artic     = b_price-list.artic
           and buf_goods.prod-code = b_price-list.prod-code
           and buf_goods.prod-type = b_price-list.prod-type
           no-error .
    if error-status :error then return error.
    find first buf_gds-obj no-lock
         where buf_gds-obj.gds-code = buf_goods.gds-code
           and buf_gds-obj.obj-code = b_price-doc.obj-code
           and buf_gds-obj.obj-type = b_price-doc.obj-type
    no-error.
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsat in g#library
  (input  buf_goods.artic
  ,input  buf_goods.prod-type
  ,input  buf_goods.prod-code
  ,input  'alcohol-prod=request':u
  ,output v-alcohol-prod
  )  .
    if v-alcohol-prod
    and buf_goods.ms-base > 0
    and buf_goods.proof > decimal('28':U)
    then do:
        run ggoattr-value (
           input   buf_goods.grp-code
          ,input   b_price-doc.host-code
          ,input   b_price-doc.obj-type
          ,input   b_price-doc.obj-code
          ,input   'alc-min-price':U
          ,output  v-alc-min-price
          ,output  v-type ) no-error .
        if v-alc-min-price <> "" then do:
          if not can-find (first tmp-proof-price
          where tmp-proof-price.node-code = buf_goods.grp-code
          )
          then do:
              do i = 1 to num-entries(v-alc-min-price, ";":u ) :
                  assign proof-price = entry(i, v-alc-min-price, ";":u).
                  create tmp-proof-price.
                  assign
                      tmp-proof-price.node-code = buf_goods.grp-code
                      tmp-proof-price.proof = decimal(entry(1, proof-price))
                      tmp-proof-price.price = decimal(entry(2, proof-price))
                      .
              end.
          end.
          find first tmp-proof-price no-lock
              where tmp-proof-price.node-code = buf_goods.grp-code
                and tmp-proof-price.proof     < buf_goods.proof
              no-error.
          if available tmp-proof-price then do:
              if b_price-list.price-sale / buf_goods.ms-base < tmp-proof-price.price / 0.5  then do:
                p-err = true.
                return error
                substitute ("Для товара &1 - &9,&7объемом = &2л и с содержанием спирта = &3%, &7новая продажная цена = &4&8. &7Алкоголь крепостью свыше &5% должен иметь цену не менее &6&8 за 0,5л"
                    , string(buf_goods.artic) + " "
                    + string(buf_goods.prod-type) + " "
                    + string(buf_goods.prod-code)
                    , string(buf_goods.ms-base, ">9.999")
                    , buf_goods.proof
                    , b_price-list.price-sale
                    , tmp-proof-price.proof
                    , tmp-proof-price.price
                    , chr(10)
                    , v-abbr
                    , buf_goods.gds-name
                    )
                .
              end.
          end.
          else do:
            p-err = true.
            return error
              substitute ("Для товара &1 - &5 &4 установлено содержание спирта = &2%, &4 В параметрах группы не найдены цены &3!!!"
                , string(buf_goods.artic) + " "
                + string(buf_goods.prod-type) + " "
                + string(buf_goods.prod-code)
                , buf_goods.proof
                , v-alc-min-price
                , chr(10)
                , buf_goods.gds-name
                )
            .
          end.
        end.
    end.
  end.
end.
end procedure.
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure doc-code:
define input  parameter parmode          as   character           no-undo.
define input  parameter parobj-type      like ub.clients.obj-type no-undo.
define input  parameter parobj-code      like ub.clients.obj-code no-undo.
define input  parameter parroot-doc-code like ub.trn-doc.doc-code no-undo.
define output parameter pardoc-code      like ub.trn-doc.doc-code no-undo.
define buffer buf_sys-ctrl for ub.sys-ctrl  .
define variable vardb-remote     as   logical             no-undo.
define variable vartemp-doc-code like ub.trn-doc.doc-code no-undo.
define variable v-delimiter as character no-undo .
do
on error undo, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( 1 ) )
:
find first buf_sys-ctrl no-lock .
vardb-remote = buf_sys-ctrl.db-num <> 0 .
  CASE parmode:
    when "main":u then do:
      if vardb-remote then do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-" + trim (string (parobj-code, ">>>>9")) + substring (parobj-type, (if g#language = "RUS" then 1 else 2), 1).
      end.
      else do:
        assign
          pardoc-code = trim (string (next-value (s-trn-doc, ub), ">>>>>>>>>9")) + "-".
      end.
    end.
    when "trio" then do:
      assign
        pardoc-code = replace (parroot-doc-code, "=", "*").
    end.
    otherwise do:
      assign
      v-delimiter = entry(lookup(entry(1, parmode), "main,chip,pair,flora,trio-m,quadro,stock-up,stock-down,stock-fix," +                          "main_s,chip_s,pair_s,trio-m_s,quadro_s,stock-up_s,stock-down_s,stock-fix_s":U), ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)))
      no-error
      .
      if error-status:error  then do:
        undo, return error substitute("Ошибка при генерации номера документа&1Неверное значение параметра parmode &2"
                                      ,chr(10)
                                      ,parmode
                                      ).
      end.
      if num-entries(parmode) = 1
      and parmode <> "chip":U
      and parmode <> "chip_s":U
      then do:
        assign
        pardoc-code = replace (parroot-doc-code, "-", v-delimiter).
      end.
      else if (lookup("chip":U, parmode) > 0
               or
               lookup("chip_s":U, parmode) > 0) then do:
        assign
          vartemp-doc-code = parroot-doc-code.
        do while true:
          if index (vartemp-doc-code , ".") = 0 then
            vartemp-doc-code  = replace (vartemp-doc-code , v-delimiter, v-delimiter + "1.").
          else
            vartemp-doc-code  =
            substring (vartemp-doc-code , 1, index (vartemp-doc-code, v-delimiter)) +
            string (integer (substring (vartemp-doc-code, index (vartemp-doc-code, v-delimiter) + 1, index (vartemp-doc-code, ".") - index (vartemp-doc-code, v-delimiter) - 1)) + 1) +
            substring (vartemp-doc-code, index (vartemp-doc-code, ".")).
          if not can-find (ub.trn-doc where ub.trn-doc.doc-code = vartemp-doc-code no-lock) then leave.
        end.
        assign
          pardoc-code = vartemp-doc-code.
      end.
    end.
  end CASE.
  if pardoc-code = '':U
  or (parroot-doc-code <> '':U
  and pardoc-code = parroot-doc-code) then do:
    undo, return error substitute("Ошибка при генерации номера документа&1"
                                  ,chr(10)).
  end.
end.
end. // procedure/method
function get-doc-code-int64 returns int64
  ( input p-doc-code as character ) :
  define variable v-ind              as integer   no-undo .
  define variable v-num-entries      as integer   no-undo .
  define variable v-doc-code-int64   as int64     no-undo .
  define variable v-canonic-doc-code as character no-undo .
  assign
    v-num-entries      = num-entries( ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) )
    v-canonic-doc-code = p-doc-code
  .
  do v-ind = 1 to v-num-entries
  :
    assign
      v-canonic-doc-code = entry(1, v-canonic-doc-code, entry( v-ind, ("-,-,=,#,*,^,+,`,":U + chr(126) + ",у-,у-,у=,у*,у^,у+,у`,у" + chr(126)) ) )
    .
  end.
  assign
    v-doc-code-int64 = int64(v-canonic-doc-code) no-error
  .
  return v-doc-code-int64 .
end. // function/method
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure gen-key-rec :
  define input  parameter p-tbl-name    as character no-undo.
  define input  parameter p-bh_tbl-name as handle    no-undo.
  define output parameter p-key-rec     as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-rec). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-rec). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-rec). endkey", vss-workfile )
  :
    define variable fh               as handle    no-undo .
    define variable v-ok             as logical   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    if p-tbl-name = ?
      or p-tbl-name = "":U
    then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Не задано имя таблицы.", vss-include-info41 ).
    end.
    if not p-bh_tbl-name:available then do:
      return error substitute( "&1 (gen-key-rec). Ошибка задания входных параметров. Переданый буфер таблицы &2 не доступен", vss-include-info41, p-tbl-name ).
    end.
    assign
      p-key-rec = p-tbl-name
      v-inform  = p-bh_tbl-name:index-information(1)
      v-ind     = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = p-bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info41, p-tbl-name ).
    end.
    else do:
      assign
        v-idx-field-qnty = num-entries( v-inform ) - 4
      .
      if v-idx-field-qnty < 2 then do:
        return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info41, v-inform, p-tbl-name ).
      end.
      do v-ind = 1 to v-idx-field-qnty by 2
      on error undo, return error
      :
        assign
          fh = p-bh_tbl-name:buffer-field( entry( 4 + v-ind, v-inform, ",":U ) ).
          p-key-rec = p-key-rec + chr(3) + substitute("&1", replace(fh:buffer-value(),chr(3),chr(2) + chr(9) + chr (2)))
        .
      end.
    end.
    if p-key-rec = ? then do:
      assign
        p-key-rec = "":U
      .
      return error substitute( "&1. Поле(поля) первичного ключа таблицы &2 имеет(ют) неопределенное значение", vss-include-info41, p-tbl-name ).
    end.
  end.
  return.
end procedure.
procedure gen-where-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character  no-undo.
  define input  parameter p-key-rec    as character  no-undo.
  define input  parameter p-key-handle as handle     no-undo .
  define input  parameter p-db-name    as character  no-undo .
  define input  parameter p-tt-handle  as handle     no-undo .
  define output parameter o-Where      as character  no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable fh_key           as handle    no-undo .
    define variable fh_search        as handle    no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-field-name     as character no-undo .
    define variable v-field-val      as character no-undo .
    define variable v-word-link      as character no-undo .
    define variable vTable           as character no-undo.
    define variable bh_tbl-key       as handle    no-undo .
    assign
      p-key-rec = trim( p-key-rec )
    .
    if p-key-handle <> ? then do:
      if not valid-handle(p-key-handle)
         or p-key-handle:type <> "buffer"
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Задан невалидный буфер для поиска.", vss-include-info41 ).
      end.
      if num-entries( p-key-rec, chr(3) ) > 1
        or p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. При поиске по буферу вместо ключа (&2) должено быть 'имя таблицы'.", vss-include-info41, p-key-rec ).
      end.
    end.
    else do:
      if p-key-rec = ?
        or p-key-rec = "":U
      then do:
        return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info41 ).
      end.
    end.
    assign
      vTable = entry( 1 , p-key-rec, chr(3) )
    .
    if p-tt-handle <> ?
      and ( not valid-handle(p-tt-handle)
            or p-tt-handle:type <> "buffer"
          )
    then do:
      return error substitute( "&1 (gen-row-keyr). Ошибка задания входных параметров. &2&3Передан невалидный handle для поиска или handle не типа BUFFER", vss-include-info41, vTable, chr(10) ).
    end.
    if p-tt-handle = ? then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    else do:
      create buffer bh_tbl-name for table p-tt-handle:table-handle .
    end.
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа", vss-include-info41, vTable ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info41, v-inform, vTable ).
    end.
    assign
      o-where     = "where":U
      v-word-link = "":U
      v-field-num = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld = 0
    .
    if i-tablekey ne "" and i-tablekey ne ?
    then do:
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tablekey )
      .
      create buffer bh_tbl-key for table v-full-tbl-name .
    end.
    if i-tableSerach ne "" and i-tableSerach ne ?
    then do:
      delete object bh_tbl-name no-error.
      assign
        v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach )
      .
      create buffer bh_tbl-name for table v-full-tbl-name .
    end.
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if p-key-handle = ?
        and v-count-fld > v-field-num
      then do:
        leave block_where.
      end.
      define variable VfieldKeyTable as handle no-undo.
      assign
        v-field-name = entry( 4 + v-ind, v-inform, ",":U )
        fh_search    = bh_tbl-name:buffer-field( v-field-name )
      .
      if     bh_tbl-key ne ?
      then do:
         VfieldKeyTable = bh_tbl-key:buffer-field( v-field-name ) no-error.
         if VfieldKeyTable eq ?
         then next block_where.
      end.
      if v-full-tbl-name ne "" and v-full-tbl-name ne ?
      then
         o-where = substitute( "&1 &2 &3.&4 =", o-where, v-word-link,v-full-tbl-name, v-field-name ).
      else
         o-where = substitute( "&1 &2 &3 =", o-where, v-word-link, v-field-name ).
      if p-key-handle = ? then do:
        assign
          v-field-val = replace (entry( v-count-fld + 1 , p-key-rec, chr(3) ),chr(2) + chr(9) + chr (2),chr(3))
        .
      end.
      else do:
        assign
          fh_key = p-key-handle:buffer-field( v-field-name )
        .
        if fh_key = ?
          or not valid-handle( fh_key )
        then do:
          delete object bh_tbl-name.
          if     bh_tbl-key ne ?
          then
             delete object bh_tbl-key.
          return error substitute( "&1. Буфер &2 не содержит поля &3 необходимого для поиска.", vss-include-info41, p-key-handle:name, v-field-name ).
        end.
        assign
          v-field-val = fh_key:buffer-value
        .
      end.
      if fh_search:data-type ="character":U then do:
        assign
          v-field-val = replace( v-field-val, '~~':U, '~~~~':U )
          v-field-val = replace( v-field-val, '"':U, '~~"':U )
          v-field-val = replace( v-field-val, "'":U, "~~'":U )
          v-field-val = replace( v-field-val, '~{':U, '~~~{':U )
          v-field-val = replace( v-field-val, '~}':U, '~~~}':U )
          v-field-val = replace( v-field-val, '~\':U, '~~~\':U )
          v-field-val = replace( v-field-val, chr(10), '~~n':U )
          v-field-val = replace( v-field-val, chr(9), '~~t':U )
          v-field-val = replace( v-field-val, chr(13), '~~r':U )
          v-field-val = replace( v-field-val, chr(27), '~~E':U )
          v-field-val = replace( v-field-val, chr(8), '~~b':U )
          v-field-val = replace( v-field-val, chr(12), '~~f':U )
          v-field-val = substitute( '"&1"', v-field-val )
        .
      end.
      assign
        o-where = substitute( "&1 &2", o-where, v-field-val )
      .
      if v-word-link = "":U then do:
        assign
          v-word-link = "and":U
        .
      end.
    end.
    delete object bh_tbl-name.
    if     bh_tbl-key ne ?
    then
       delete object bh_tbl-key.
    if p-key-handle = ?
      and v-count-fld <> v-field-num
    then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2", vss-include-info41, vTable ).
    end.
  end.
end procedure.
procedure gen-hn-keyr-tab :
  define input  parameter i-tableSerach as character no-undo.
  define input  parameter i-tablekey   as character no-undo.
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  define variable v-full-tbl-name as character no-undo.
  define variable v-where         as character no-undo.
  define variable bh_tbl-name     as handle    no-undo.
  define variable vTable          as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-row-keyr). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-row-keyr). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-row-keyr). endkey", vss-workfile ):
      run gen-where-keyr-tab(i-tableSerach,
                             i-tablekey,
                             p-key-rec,
                             p-key-handle,
                             p-db-name,
                             p-tt-handle,
                             output v-where).
      if i-tableSerach ne "" and i-tableSerach ne ?
      then do:
         v-full-tbl-name = substitute( "&1.&2":U, p-db-name, i-tableSerach ).
         create buffer bh_tbl-name for table v-full-tbl-name .
      end.
      else do:
         if p-tt-handle = ? then do:
            assign
               vTable = entry( 1 , p-key-rec, chr(3) )
            .
            v-full-tbl-name = substitute( "&1.&2":U, p-db-name, vTable ).
            create buffer bh_tbl-name for table v-full-tbl-name .
         end.
         else do:
            create buffer bh_tbl-name for table p-tt-handle:table-handle .
         end.
      end.
      if p-tt-handle = ? then do:
         bh_tbl-name:find-first( v-where, p-stts-lock ) no-error .
      end.
      else do:
         bh_tbl-name:find-first( v-where ) no-error .
      end.
      o-hn = bh_tbl-name.
   end.
end procedure.
procedure gen-hn-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter o-hn         as handle    no-undo.
  run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output o-hn).
end.
procedure gen-row-keyr :
  define input  parameter p-key-rec    as character no-undo.
  define input  parameter p-key-handle as handle    no-undo .
  define input  parameter p-db-name    as character no-undo .
  define input  parameter p-tt-handle  as handle    no-undo .
  define input  parameter p-stts-lock  as integer   no-undo .
  define output parameter p-tbl-row    as rowid     no-undo.
  define output parameter p-tbl-name   as character no-undo.
  define variable vHn as handle no-undo.
    run gen-hn-keyr-tab(?,?,p-key-rec,p-key-handle,p-db-name,p-tt-handle,p-stts-lock,output vHn).
    p-tbl-row = if vHn:available then vHn:rowid else ?.
    p-tbl-name =  vHn:table.
    delete object vHn no-error.
  if p-tbl-row = ? then do:
    return substitute( "Не найдена запись таблицы &2 по ключу &3", vss-include-info41, p-tbl-name, p-key-rec ).
  end.
  else do:
    return.
  end.
end procedure.
procedure gen-key-fv :
  define input  parameter p-key-rec    as character no-undo .
  define output parameter p-field-list as character no-undo .
  define output parameter p-value-list as character no-undo.
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-key-rec = ?
      or p-key-rec = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан уникальный ключ.", vss-include-info41 ).
    end.
    assign
      v-tbl-name      = entry( 1 , p-key-rec, chr(3) )
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверный уникальный ключ.", vss-include-info41 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info41, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      delete object bh_tbl-name no-error.
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info41, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      p-value-list = "":U
      v-delim-key  = "":U
      v-field-num  = num-entries( p-key-rec, chr(3) ) - 1
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      if v-count-fld > v-field-num then do:
        leave block_where.
      end.
      assign
        p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U )
        p-value-list = p-value-list + v-delim-key + entry( v-count-fld + 1 , p-key-rec, chr(3) )
      .
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
    if v-count-fld <> v-field-num then do:
      return error substitute( "&1. Не совпадает количество полей первичного ключа для таблицы &2 в БД", vss-include-info41, v-tbl-name ).
    end.
  end.
end procedure.
procedure gen-key-field :
  define input  parameter p-table      as character no-undo .
  define output parameter p-field-list as character no-undo .
  do
  on error  undo, return error substitute( "&1 (gen-key-fv). &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1 (gen-key-fv). stop", vss-workfile )
  on endkey undo, return error substitute( "&1 (gen-key-fv). endkey", vss-workfile )
  :
    define variable v-full-tbl-name  as character no-undo .
    define variable bh_tbl-name      as handle    no-undo .
    define variable v-tbl-name       as character no-undo .
    define variable v-field-num      as integer   no-undo .
    define variable v-count-fld      as integer   no-undo .
    define variable v-inform         as character no-undo .
    define variable v-ind            as integer   no-undo .
    define variable v-idx-field-qnty as integer   no-undo .
    define variable v-delim-key      as character no-undo .
    if p-table = ?
      or p-table = "":U
    then do:
      return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Не задан таблица.", vss-include-info41 ).
    end.
    assign
      v-tbl-name      = p-table
      v-full-tbl-name = substitute( "ub.&1":U, v-tbl-name )
    .
    create buffer bh_tbl-name for table v-full-tbl-name no-error .
    if error-status:error then return error substitute( "&1 (gen-key-fv). Ошибка задания входных параметров. Неверная таблица.", vss-include-info41 ).
    assign
      v-inform = bh_tbl-name:index-information(1)
      v-ind    = 2
    .
    do while v-inform <> ? and entry( 3, v-inform, ",":U ) <> "1":U
    on error undo, return error
    :
      assign
        v-inform = bh_tbl-name:index-information( v-ind )
        v-ind    = v-ind + 1
      .
    end.
    if v-inform = ?
      or LC( entry( 1, v-inform, ",":U ) ) = "default":U
      or entry( 3, v-inform, ",":U ) <> "1":U
    then do:
      return error substitute( "&1. Таблица &2 не имеет первичного ключа в БД", vss-include-info41, v-tbl-name ).
    end.
    assign
      v-idx-field-qnty = num-entries( v-inform ) - 4
    .
    if v-idx-field-qnty < 2 then do:
      return error substitute( "&1. Определенный первичный индекс (&2) не содержит списка полей для таблицы &3", vss-include-info41, v-inform, v-tbl-name ).
    end.
    assign
      p-field-list = "":U
      v-delim-key  = "":U
      v-count-fld  = 0
    .
    block_where:
    do v-ind = 1 to v-idx-field-qnty by 2
    on error undo, return error
    :
      assign
        v-count-fld = v-count-fld + 1
      .
      p-field-list = p-field-list + v-delim-key + entry( 4 + v-ind, v-inform, ",":U ).
      if v-ind = 1 then do:
        assign
          v-delim-key = chr(3)
        .
      end.
    end.
    delete object bh_tbl-name.
  end.
end procedure.
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure thbjattr_code :
   define input  parameter p-upper-code     as character no-undo .
   define input  parameter p-code           as character no-undo .
   define output parameter p-label          as character no-undo .
   define output parameter p-user-can-edit  as logical   no-undo .
   define output parameter p-output-display as logical   no-undo .
   define output parameter p-other          as character no-undo .
   define output parameter p-prop-list      as character no-undo .
   define output parameter p-prop-type-list as character no-undo .
   define output parameter p-prop-label-list as character no-undo .
   define output parameter p-global          as logical no-undo .
   define output parameter p-host           as logical no-undo .
   define output parameter p-shop           as logical no-undo .
   define output parameter p-store          as logical no-undo .
   define output parameter p-db             as logical no-undo .
   define variable p-region as logical no-undo.
   run thbjattr_code_reg in this-procedure (
                                            p-upper-code,
                                            p-code,
                                            output p-label,
                                            output p-user-can-edit,
                                            output p-output-display,
                                            output p-other,
                                            output p-prop-list,
                                            output p-prop-type-list,
                                            output p-prop-label-list,
                                            output p-global,
                                            output p-host,
                                            output p-shop,
                                            output p-store,
                                            output p-db,
                                            output p-region
                                            ).
end procedure.
procedure thbjattr_code_reg :
define input  parameter p-upper-code     as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-label          as character no-undo .
define output parameter p-user-can-edit  as logical   no-undo .
define output parameter p-output-display as logical   no-undo .
define output parameter p-other          as character no-undo .
define output parameter p-prop-list      as character no-undo .
define output parameter p-prop-type-list as character no-undo .
define output parameter p-prop-label-list as character no-undo .
define output parameter p-global          as logical no-undo .
define output parameter p-host           as logical no-undo .
define output parameter p-shop           as logical no-undo .
define output parameter p-store          as logical no-undo .
define output parameter p-db             as logical no-undo .
define output parameter p-region         as logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_code in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-label
    ,output p-user-can-edit
    ,output p-output-display
    ,output p-other
    ,output p-prop-list
    ,output p-prop-type-list
    ,output p-prop-label-list
    ,output p-global
    ,output p-host
    ,output p-shop
    ,output p-store
    ,output p-db
    ,output p-region
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info42, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_tooltip :
define input  parameter p-upper-code  as character no-undo .
define input  parameter p-code      as character no-undo .
define output parameter p-tooltip   as character no-undo .
define output parameter p-label     as character no-undo .
define output parameter p-tooltip-code as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_tooltip in g#attr-lib
    (input  p-upper-code
    ,input  p-code
    ,output p-tooltip
    ,output p-label
    ,output p-tooltip-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_legacy :
define input  parameter p-upper-code     as character no-undo .
define output parameter p-level-way      as character no-undo .
define output parameter p-up-way         as character no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_legacy in g#attr-lib
    (input  p-upper-code
    ,output p-level-way
    ,output p-up-way
    ) no-error .
  if error-status :error
  then do:
    undo, return error substitute( "&1. &2&3&4", vss-include-info42, return-value, chr(10), error-status :get-message (1)).
  end.
end.
end procedure.
procedure thbjattr_value :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define output parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define output parameter p-value-date    like ub.thbj-attr.property-value-date no-undo .
define output parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define output parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define output parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
define output parameter p-type     as character no-undo .
define output parameter p-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_value in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-value-character
    ,output p-value-date
    ,output p-value-decimal
    ,output p-value-integer
    ,output p-value-logical
    ,output p-type
    ,output p-found
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_get-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-param-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-mode as character no-undo .
define input-output parameter table-handle p-tth.
define output parameter p-all-found as decimal no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_get-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-param-code
    ,input  p-mode
    ,input-output table-handle p-tth
    ,output p-all-found
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_write :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code     like ub.thbj-attr.prop-code  no-undo .
define input  parameter p-value-character like ub.thbj-attr.property-value-character no-undo .
define input  parameter p-value-date like ub.thbj-attr.property-value-date no-undo .
define input  parameter p-value-decimal like ub.thbj-attr.property-value-decimal no-undo .
define input  parameter p-value-integer like ub.thbj-attr.property-value-integer no-undo .
define input  parameter p-value-logical like ub.thbj-attr.property-value-logical no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_write in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,input  p-value-character
    ,input  p-value-date
    ,input  p-value-decimal
    ,input  p-value-integer
    ,input  p-value-logical
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_set-section :
define input  parameter p-obj-type like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code  like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter table-handle p-tth.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_set-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  table-handle p-tth
    ) no-error .
  if error-status :error
  then do:
    delete object p-tth.
    undo, return error return-value .
  end.
  delete object p-tth.
end.
end procedure.
procedure thbjattr_delete :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
define input  parameter p-code       like ub.thbj-attr.prop-code  no-undo .
define output parameter p-deleted  as logical no-undo.
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ,input  p-code
    ,output p-deleted
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_delete-section :
define input  parameter p-obj-type   like ub.thbj-attr.obj-type   no-undo .
define input  parameter p-obj-code   like ub.thbj-attr.obj-code   no-undo .
define input  parameter p-upper-code like ub.thbj-attr.upper-prop-code  no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_delete-section in g#attr-lib
    (input  p-obj-type
    ,input  p-obj-code
    ,input  p-upper-code
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
procedure thbjattr_manual-edit :
define input  parameter p-ucode          as character no-undo .
define input  parameter p-code           as character no-undo .
define output parameter p-section-num    as integer no-undo .
do
on error undo, return error return-value
:
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run thbjattr_manual-edit in g#attr-lib
    (input  p-ucode
    ,input  p-code
    ,output  p-section-num
    ) no-error .
  if error-status :error
  then do:
    undo, return error return-value .
  end.
end.
end procedure.
do
on error undo, return error return-value
:
define variable curr-db-num as integer   no-undo .
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output curr-db-num
  )  .
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  find first buf-price-doc no-lock
    where buf-price-doc.doc-num = price-doc-num
    no-error .
  if not available buf-price-doc
  then do:
    v-text-mess = substitute ( "Невозможно найти переоценку с номером &1 " , price-doc-num ) .
    if p-ask-q = false then
    message
      vss-workfile vss-revision vss-description skip
      v-text-mess
      view-as alert-box error .
    undo, return error v-text-mess .
  end.
  ASSIGN
    varfact-date  = buf-price-doc.fact-date
    varfact-time  = buf-price-doc.fact-time
    varshift-date = buf-price-doc.shift-date
    varshift-num  = buf-price-doc.shift-num
    varshift-name = buf-price-doc.shift-name
    .
  if  buf-price-doc.status_ <> 'новый':U
  and buf-price-doc.status_ <> 'приказ':U
  and buf-price-doc.status_ <> 'разрешен':U
  and buf-price-doc.status_ <> 'акт':U
  then do:
    v-text-mess  = substitute("Недопустимый исходный статус документа переоценки  &1  Статус &2 " ,  buf-price-doc.doc-num ,    buf-price-doc.status_     ) .
    if p-ask-q = false then
    message
      vss-workfile vss-revision vss-description skip
      v-text-mess
      view-as alert-box .
    undo, return error v-text-mess.
  end.
  if p-mode = "act"
  then do:
      do transaction :
        run str/pr-tot.p (input buf-price-doc.doc-num) no-error.
            run gbl/chk-date.p
              (input buf-price-doc.obj-type
              ,input buf-price-doc.obj-code
              ,input varfact-date
              ,input varfact-time
              ,input varshift-date
              ,input varshift-num
              ,input no
              ) no-error.
            if error-status :error
            then do:
              run gbl/factdate.p
                 (input        buf-price-doc.obj-type,
                  input        buf-price-doc.obj-code,
                  input-output varfact-date,
                  input-output varfact-time,
                  input-output varshift-date,
                  input-output varshift-num,
                  input-output varshift-name,
                  input        no) no-error.
              if error-status :error
              then do:
                  if p-ask-q = false then
                    message substitute(" Ошибка при установке фактической даты переоценки.111 &1 &2" , return-value , error-status :get-message(1) )
                    view-as alert-box.
                  undo, return error substitute(" Ошибка при установке фактической даты переоценки.134 &1 &2" , return-value , error-status :get-message(1) ).
              end.
              run ver-date-period
               ( input varfact-date
                ) no-error .
                if error-status :error then do:
                    if p-ask-q = false then
                    message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      ""
                      view-as alert-box error
                    .
                    undo, return error return-value .
                end.
            end.
        assign
          buf-price-doc.fact-date  = varfact-date
          buf-price-doc.fact-time  = varfact-time
          buf-price-doc.shift-date = varshift-date
          buf-price-doc.shift-num  = varshift-num
          buf-price-doc.shift-name = varshift-name
          buf-price-doc.status_    = 'акт':U
          buf-price-doc.out-code   = trn-doc-code
          .
        run update-den-price-all in this-procedure .
      end.
      return.
  end.
  if p-mode = "close"
  then do:
    case buf-price-doc.status_ :
      when 'новый':U
      then do:
define variable vss-include-info46 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  curr-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_order':U
    ,input  'object':U
    ,input  buf-price-doc.host-code
    ,input  buf-price-doc.obj-type
    ,input  buf-price-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output l-ok
    )  .
end.
        if l-ok <> true
        then do:
          undo, return error return-value .
        end.
      run chec-par in this-procedure (output p-par , input buf-price-doc.host-code, input buf-price-doc.obj-type,input buf-price-doc.obj-code ) no-error .
      If p-par <> true
      then do:
         undo,return error return-value .
      end.
      run str/pr-notls.p (buf-price-doc.doc-num).
define variable vss-include-info47 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  curr-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_preparation':U
    ,input  'object':U
    ,input  buf-price-doc.host-code
    ,input  buf-price-doc.obj-type
    ,input  buf-price-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output l-ok
    )  .
end.
        if l-ok <> true
        then do:
          undo, return error return-value .
        end.
        run proc-d-pcnt in this-procedure (input price-doc-num , output l-ok ) .
        if l-ok = true  then do:
        end.
        assign
          l-ok = false
        .
        assign
          p-new-status_ = 'приказ':U
        .
      end.
      when 'приказ':U
      then do:
        run check-the-same-object in this-procedure
          (output l-ok
          ).
        if l-ok <> true
        then do:
          if p-ask-q = false then
          message
            "Начать переоценку можно только в базе данных, которая содержит объект переоценки." skip
            view-as alert-box .
          undo, return error "Начать переоценку можно только в базе данных, которая содержит объект переоценки.".
        end.
define variable vss-include-info48 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  curr-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_permission':U
    ,input  'object':U
    ,input  buf-price-doc.host-code
    ,input  buf-price-doc.obj-type
    ,input  buf-price-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output l-ok
    )  .
end.
        if l-ok <> true
        then do:
          undo, return error return-value .
        end.
        assign
          l-ok = false
        .
        if p-ask-q = false
        then do:
            message
              "Начать переоценку на" buf-price-doc.obj-type buf-price-doc.obj-code skip
              "по приказу №" buf-price-doc.doc-num  "и заблокировать продажу ?" skip
              "Вы уверены ?" skip
              view-as alert-box question buttons OK-Cancel update l-ok.
            if l-ok <> true
            then do:
              undo, return error return-value .
            end.
        end.
        assign
          p-new-status_ = 'разрешен':U
        .
      end.
      when 'разрешен':U
      then do:
        run check-the-same-object in this-procedure
          (output l-ok
          ).
        if l-ok <> true
        then do:
          if p-ask-q = false then
          message
            "Закрыть акт переоценки можно только в базе данных," skip
            "которая содержит объект переоценки." skip
            view-as alert-box .
          undo, return error "Закрыть акт переоценки можно только в базе данных, которая содержит объект переоценки." .
        end.
define variable vss-include-info49 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  curr-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_fact':U
    ,input  'object':U
    ,input  buf-price-doc.host-code
    ,input  buf-price-doc.obj-type
    ,input  buf-price-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output l-ok
    )  .
end.
        if l-ok <> true
        then do:
          undo, return error return-value .
        end.
        assign
          l-ok = false
        .
        if p-ask-q = false
        then do:
            message
              "Закрыть акт переоценки №" buf-price-doc.doc-num skip (2)
              "Вы уверены ?" skip (2)
              "Акт переоценки означает,"
              "что с этого момента действуют новые продажные цены."
              view-as alert-box question buttons OK-Cancel update l-ok.
            if l-ok <> true
            then do:
              undo, return error return-value .
            end.
        end.
        run chec-par in this-procedure (output p-par,
                        input buf-price-doc.host-code ,
                        input buf-price-doc.obj-type ,
                        input buf-price-doc.obj-code  ) no-error .
        If p-par <> true
        then do:
          undo, return error return-value .
        end.
        run gbl/chk-date.p
          (input buf-price-doc.obj-type
          ,input buf-price-doc.obj-code
          ,input varfact-date
          ,input varfact-time
          ,input varshift-date
          ,input varshift-num
          ,input no
          ) no-error.
        if error-status :error
        then do:
          run gbl/factdate.p (input    buf-price-doc.obj-type,
                          input        buf-price-doc.obj-code,
                          input-output varfact-date,
                          input-output varfact-time,
                          input-output varshift-date,
                          input-output varshift-num,
                          input-output varshift-name,
                          input        no) no-error.
          if error-status :error
          then do:
              if p-ask-q = false then
                message substitute(" Ошибка при установке фактической даты переоценки.2 &1 &2 " , return-value , error-status :get-message(1) )
                view-as alert-box.
              undo, return error substitute(" Ошибка при установке фактической даты переоценки.3 &1 &2" , return-value , error-status :get-message(1) ).
          end.
          run ver-date-period
            ( input varfact-date
            ) no-error .
            if error-status :error then do:
                if p-ask-q = false then
                message
                  vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value skip
                  ""
                  view-as alert-box error
                .
                undo, return error return-value .
            end.
        end.
        run proc-cost-price-fact in this-procedure no-error .
          if error-status :error
          then do:
              if p-ask-q = false then
                  message "Ошибка при установке текущей учетной цены."
                  view-as alert-box.
              undo, return error "Ошибка при установке текущей учетной цены.".
          end.
        assign
          p-new-status_ = 'акт':U
        .
      end.
      when 'акт':U
      then do:
        if p-ask-q = false then
        message
          "Акт переоценки уже закрыт. Закрытие невозможно."
          view-as alert-box error .
        undo, return error "Акт переоценки уже закрыт. Закрытие невозможно." .
      end.
    end.
  end.
  if p-mode = "close-act"
  then do:
    run check-the-same-object in this-procedure
      (output l-ok
      ).
    if l-ok <> true
    then do:
      if p-ask-q = false then
          message
            "Начать переоценку можно только в базе данных," skip
            "которая содержит объект переоценки." skip
            view-as alert-box .
      undo, return error  "Начать переоценку можно только в базе данных, которая содержит объект переоценки." .
    end.
define variable vss-include-info50 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run chk-actg in g#library2
    (input  curr-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_overvalue_fact':U
    ,input  'object':U
    ,input  buf-price-doc.host-code
    ,input  buf-price-doc.obj-type
    ,input  buf-price-doc.obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  true
    ,output l-ok
    )  .
end.
    if l-ok <> true
    then do:
      undo, return error return-value .
    end.
    if buf-price-doc.status_ = 'новый':U
    then do:
      run chec-par in this-procedure
         ( output p-par, input buf-price-doc.host-code, input buf-price-doc.obj-type,input buf-price-doc.obj-code ) no-error .
      If p-par <> true
      then do:
       undo,return error return-value .
      end.
      do transaction
      on error undo, return error return-value
      :
        for each ub.price-list where
                ub.price-list.doc-num = buf-price-doc.doc-num
        on error undo, return error return-value
        :
          if ub.price-list.price-sale = ? or
            ( ub.price-list.d-pcnt = ?  and ub.price-list.main-price = true )
          then do:
            run del-pr-list in this-procedure
                             (input ub.price-list.b-code,
                              input ub.price-list.doc-num,
                              input ?,
                              input ?    ) no-error.
            if error-status :error
            then do:
              undo, return error return-value .
            end.
          end.
        end.
        run str/pr-notls.p (buf-price-doc.doc-num).
      end.
    end.
    if buf-price-doc.status_ = 'акт':U
    then do:
      if p-ask-q = false then
      message
        "Акт переоценки уже закрыт. Закрытие невозможно."
        view-as alert-box error .
      undo, return error "Акт переоценки уже закрыт. Закрытие невозможно.".
    end.
    run gbl/chk-date.p
      (input buf-price-doc.obj-type
      ,input buf-price-doc.obj-code
      ,input varfact-date
      ,input varfact-time
      ,input varshift-date
      ,input varshift-num
      ,input no
      ) no-error .
    if error-status :error
    then do:
      run gbl/factdate.p (input        buf-price-doc.obj-type,
                      input        buf-price-doc.obj-code,
                      input-output varfact-date,
                      input-output varfact-time,
                      input-output varshift-date,
                      input-output varshift-num,
                      input-output varshift-name,
                      input no ) no-error.
      if error-status :error
      then do:
          if p-ask-q = false then
          message substitute(" Ошибка при установке фактической даты переоценки.4 &1 &2" , return-value , error-status :get-message(1) )
          view-as alert-box.
          undo, return error substitute(" Ошибка при установке фактической даты переоценки.5 &1 &2" , return-value , error-status :get-message(1) ) .
      end.
      run ver-date-period
        ( input varfact-date
        ) no-error .
        if error-status :error then do:
            if p-ask-q = false then
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              ""
              view-as alert-box error
            .
            undo, return error return-value .
        end.
    end.
    run proc-cost-price-fact in this-procedure no-error .
      if error-status :error
      then do:
          if p-ask-q = false then
          message "Ошибка при установке средней учетной цены"
          view-as alert-box.
          undo, return error "Ошибка при установке средней учетной цены".
      end.
    if can-find (first ub.price-list where
                      ub.price-list.doc-num = buf-price-doc.doc-num)
    then do:
      assign
        p-new-status_ = 'акт':U
        .
    end.
  end.
  if (p-mode = "close" and p-new-status_ = 'акт':U)
  or (p-mode = "close-act" )
  then do:
    run str/pr-cash.p
      (input parparentproc
      ,input p-new-status_
      ,input buf-price-doc.doc-num
      ,input buf-price-doc.obj-type
      ,input buf-price-doc.obj-code
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
  run waitfram-show in this-procedure ("Ждите...").
  main-block :
  do transaction
  on error undo main-block, return error return-value
  :
    find current buf-price-doc exclusive-lock .
    if (p-mode = "close"     and buf-price-doc.status_ = 'новый':U )
    or (p-mode = "close-act" and buf-price-doc.status_ = 'новый':U )
    then do:
      run chec-par in this-procedure (output p-par, input buf-price-doc.host-code, input buf-price-doc.obj-type,input buf-price-doc.obj-code ) no-error .
      If p-par <> true
      then do:
         undo,return error return-value .
      end.
      run ver-pr-discn in this-procedure
         ( input  p-mode ,
           input  buf-price-doc.doc-num ,
           input  trn-doc-code ,
           output l-ok ) no-error .
      if error-status :error
      then do:
          if p-ask-q = false then
             message "Ошибка при проверке процента наценки!" skip
                      return-value
                      view-as alert-box error .
          undo main-block, return error substitute("Ошибка при проверке процента наценки! &1 &2" , error-status :get-message(1) , return-value  ) .
      end.
      if l-ok <> false
      then do:
        undo, return error return-value .
      end.
    if par-alcohol <> "" and logical(par-alcohol) = true then do:
      run check-alc-min-price in this-procedure
         ( input  buf-price-doc.doc-num ,
           output l-ok ) no-error .
      if error-status :error
      then do:
          if p-ask-q = false then
             message "Ошибка при проверке цены алкогольной продукции!" skip
                      return-value
                      view-as alert-box error .
          undo main-block, return error substitute("Ошибка при проверке цены алкогольной продукции! &1 &2" , error-status :get-message(1) , return-value  ) .
      end.
      if l-ok <> false
      then do:
        undo, return error return-value .
      end.
    end.
      for each ub.price-list
        where ub.price-list.doc-num = buf-price-doc.doc-num
      on error undo main-block, return error return-value
      :
        find first ub.goods no-lock
          where ub.goods.artic     = ub.price-list.artic
            and ub.goods.prod-type = ub.price-list.prod-type
            and ub.goods.prod-code = ub.price-list.prod-code
          no-error .
        if not available ub.goods
        then do:
          v-text-mess = substitute(" Не найден товар Переоценка  &1 Артикул &2 &3 &4 " , ub.price-list.doc-num , ub.price-list.artic, ub.price-list.prod-type, ub.price-list.prod-code ) .
          if p-ask-q = false then
          message
            vss-workfile vss-revision vss-description skip
            "Не найден товар" skip
            "Переоценка" ub.price-list.doc-num skip
            "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
            view-as alert-box error .
          undo, return error v-text-mess.
        end.
        if ub.price-list.price-sale = ?
        then do:
          if p-ask-q = false then
          message
            "В приказе переоценки есть строки с незаполненной ценой."
            "Закрытие невозможно."
            view-as alert-box error .
          undo main-block, return error "В приказе переоценки есть строки с незаполненной ценой.".
        end.
        if par-pr-rdc-q = "yes"
        then do:
          define variable v-price-base like ub.gds-obj.price-base no-undo .
          define variable v-price-rubl like ub.gds-obj.price-rubl no-undo .
          define variable v-tax-road-base like ub.gds-obj.price-base no-undo .
          define variable v-tax-road-rubl like ub.gds-obj.price-rubl no-undo .
          run trg/gdsavrg.p
            (input  'Учет-объект':U
            ,input  ub.price-list.obj-type
            ,input  ub.price-list.obj-code
            ,input  0
            ,input  ub.price-list.artic
            ,input  ub.price-list.prod-type
            ,input  ub.price-list.prod-code
            ,output v-price-base
            ,output v-price-rubl
            ,output v-tax-road-base
            ,output v-tax-road-rubl
            ).
          if
          (    var-pr-r-b = "rubl"
          and v-price-rubl <> ?
          and v-price-rubl > ub.price-list.price-sale
          )
          or
          (   var-pr-r-b = "base"
          and v-price-base <> ?
          and v-price-base > ub.price-list.price-sale
          )
          then do:
            assign
              l-ok = true
            .
            v-text-mess = substitute( "УЧЕТНАЯ цена для : &1 &2 БОЛЬШЕ, чем цена ПРОДАЖИ по закрываемому документу - &3 ", ub.price-list.artic , ub.goods.gds-name , ub.price-list.price-sale) .
            if p-ask-q = false
            then do:
                message
                  "УЧЕТНАЯ цена для :" ub.price-list.artic ub.goods.gds-name
                  "БОЛЬШЕ, чем цена ПРОДАЖИ по закрываемому документу -" ub.price-list.price-sale
                  view-as alert-box question buttons OK-Cancel update l-ok.
                if l-ok <> true
                then do:
                  undo main-block, return error v-text-mess .
                end.
            end.
            else do:
              if p-do = false
              then do:
                undo main-block, return error v-text-mess .
              end.
            end.
          end.
        end.
            if ub.price-list.price-sale < ub.price-list.road-tax
            then do:
              run tax-name in this-procedure (input 'rdt':U ,output v-name-tax ).
              if p-ask-q = false then
              message
                "Значение компоненты цены '" v-name-tax "' БОЛЬШЕ, чем цена по закрываемому документу" skip
                "Объект" ub.price-list.obj-type ub.price-list.obj-code skip
                "Артикул" ub.price-list.artic ub.goods.gds-name skip
                "Бар-код" ub.price-list.b-code skip
                v-name-tax ub.price-list.road-tax skip
                "Новая продажная цена:" ub.price-list.price-sale skip (2)
                view-as alert-box error.
                undo main-block, return error substitute(" Значение компоненты цены  &1  БОЛЬШЕ, чем цена по закрываемому документу ( Объект &2&3 Артикул &4 &5  Бар-код &6 ДОП.КОМП=&7 Новая продажная цена=&8 )" ,
                  v-name-tax ,
                  ub.price-list.obj-type ,
                  ub.price-list.obj-code ,
                  ub.price-list.artic    ,
                  ub.goods.gds-name      ,
                  ub.price-list.b-code   ,
                  ub.price-list.road-tax ,
                  ub.price-list.price-sale ) .
              end.
        define variable v-doc-num    like ub.price-list.doc-num    no-undo .
        define variable v-price-sale like ub.price-list.price-sale no-undo .
        define variable v-road-tax   like ub.price-list.road-tax   no-undo .
        define variable v-excise     like ub.price-list.excise     no-undo .
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  ub.price-list.obj-type
  ,input  ub.price-list.obj-code
  ,input  ub.price-list.b-code
  ,input  0
  ,input  0
  ,output v-doc-num
  ,output v-price-sale
  ,output v-road-tax
  ,output v-excise
  )  .
        if v-doc-num <> ?
        then do:
          if v-price-sale > ub.price-list.price-sale
          then do:
            if par-pr-rdc-q = "yes"
            then do:
              assign
                l-ok = true
              .
              if p-ask-q = false
              then do:
                  message
                    "Предыдущая цена БОЛЬШЕ, чем по закрываемому документу" skip
                    "Объект" ub.price-list.obj-type ub.price-list.obj-code skip
                    "Артикул" ub.price-list.artic ub.goods.gds-name skip
                    "Бар-код" ub.price-list.b-code skip
                    "Цена по предыдущему документу №" v-doc-num skip
                    v-price-sale skip
                    "Новая цена:" skip
                    ub.price-list.price-sale skip (2)
                    "ЦЕНА СНИЖЕНА ?" skip
                    view-as alert-box question buttons OK-Cancel update l-ok.
                  if l-ok <> true
                  then do:
                    undo main-block, return error return-value .
                  end.
              end.
              else do:
                if p-do = false
                then do:
                   undo main-block, return error "Предыдущая цена БОЛЬШЕ, чем по закрываемому документу".
                end.
              end.
            end.
          end.
        end.
        if available ub.price-list
        then do:
          accumulate ub.price-list.artic (count).
        end.
      end.
      run str/pr-tot.p (input buf-price-doc.doc-num) no-error.
      if error-status :error
      then do:
        undo main-block, return error return-value .
      end.
      if (accum count ub.price-list.artic) = 0
      then do:
        if p-mode <> "close-act"  and buf-price-doc.status_ <> 'разрешен':U
        then do:
          if p-ask-q = false then
          message
            "В документе нет ни одной строки. Удаляем документ."
            view-as alert-box .
        end.
        if  p-mode = "close"  and buf-price-doc.status_ <> 'разрешен':U
        then do:
            delete buf-price-doc.
            return .
        end.
        if  p-mode = "close-act"  and buf-price-doc.status_ <> 'разрешен':U
        then do:
            return .
        end.
      end.
    end.
    if (p-mode = "close"     and buf-price-doc.status_ = 'приказ':U )
    or (p-mode = "close-act" and
        (buf-price-doc.status_ = 'новый':U
          or buf-price-doc.status_ = 'приказ':U
        )
      )
    then do:
      for each ub.price-list no-lock
        where ub.price-list.doc-num    = buf-price-doc.doc-num
          and ub.price-list.main-price = true
      on error undo main-block, return error return-value
      :
        define variable l-ov-on as logical no-undo .
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.price-list.obj-type
  ,input  ub.price-list.obj-code
  ,input  ub.price-list.artic
  ,input  ub.price-list.prod-type
  ,input  ub.price-list.prod-code
  ,input  'ov-on=request:exclusive'
  ,output l-ov-on
  ) no-error .
        if error-status :error
        then do:
          if p-ask-q = false then
          message
            vss-workfile vss-revision vss-description skip
            "Ошибка получения признака товара на объекте" skip
            error-status :get-message(1) skip
            return-value skip
            view-as alert-box error .
          undo main-block, return error "Ошибка получения признака товара на объекте".
        end.
        if l-ov-on
        then do:
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsobjat in g#library
  (input  ub.price-list.obj-type
  ,input  ub.price-list.obj-code
  ,input  ub.price-list.artic
  ,input  ub.price-list.prod-type
  ,input  ub.price-list.prod-code
  ,input  'ov-on=message'
  ,output l-ov-on
  ) no-error .
          if error-status :error
          then do:
            if p-ask-q = false then
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка поиска включенной переоценки" skip
              "Объект" ub.price-list.obj-type ub.price-list.obj-code skip
              "Артикул" ub.price-list.artic ub.price-list.prod-type ub.price-list.prod-code skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo main-block, return error "Ошибка поиска включенной переоценки" .
          end.
          undo main-block, return error return-value .
        end.
      end.
      if buf-price-doc.obj-type = 'маг':U
      then do:
        find ub.shop no-lock
          where ub.shop.obj-code = buf-price-doc.obj-code
          .
        if ub.shop.pr-cash = false
        then do:
          run str/diallog.w
                      ( parparentproc
                      , this-procedure
                      , 'str/send-prl.p':U
                      , ("D":U + chr(4) + buf-price-doc.doc-num + chr(4)  + string(buf-price-doc.obj-code))
                      , yes
                      , '':U
                      , 'Блокировка товаров переоценки на кассах') no-error .
          if error-status :error
          then do:
            if p-ask-q = false then
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка удаления товаров с кассы" skip
              error-status :get-message(1) skip
              return-value  skip
              "При выполнении send-prl.p "
              view-as alert-box error .
            undo main-block, return error "Ошибка удаления товаров с кассы".
          end.
        end.
      end.
    end.
    if (p-mode = "close"     and buf-price-doc.status_ = 'разрешен':U  )
    or (p-mode = "close-act" and
        (buf-price-doc.status_ = 'новый':U
          or buf-price-doc.status_ = 'приказ':U
          or buf-price-doc.status_ = 'разрешен':U
        )
      )
    then do:
      run trg/lockprdc.p (buf-price-doc.doc-num).
      run str/pr-tot.p ( input buf-price-doc.doc-num) no-error.
      if error-status :error
      then do:
        undo main-block, return error return-value .
      end.
      for each ub.price-list
        where ub.price-list.doc-num = buf-price-doc.doc-num
      on error undo main-block, return error return-value
      :
        find ub.goods no-lock
          where ub.goods.artic     = ub.price-list.artic
            and ub.goods.prod-type = ub.price-list.prod-type
            and ub.goods.prod-code = ub.price-list.prod-code
          .
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  buf-price-doc.host-code
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output ub.price-list.vat-pc
  ) no-error .
                if error-status :error or ub.price-list.vat-pc = ?
                then do:
                    if p-mode = "close" and  p-ask-q = false
                    then do:
                      message
                        "Проверьте налоги  у товара  - код: " ub.goods.gds-code skip
                         error-status :get-message(1) skip
                         return-value
                         view-as alert-box .
                    end.
                  undo main-block, return error substitute(" Ошибка НДС - код: &1 &2 &3" , ub.goods.gds-code , error-status :get-message(1), return-value   ) .
                end.
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  ub.goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  buf-price-doc.host-code
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output ub.price-list.slt-pc
  ) no-error .
        if error-status :error or ub.price-list.slt-pc = ?
        then do:
            if p-mode = "close" and  p-ask-q = false
            then do:
              message
                "Проверьте налог НСП у товара  - код: " ub.goods.gds-code   view-as alert-box .
            end.
           undo main-block, return error "Ошибка НСП".
        end.
        if  ub.price-list.doc-qnty = 0
        and ub.price-list.main-price = true
        and ub.goods.gds-type = 'т':U
        then do:
          if par-pr-abs-d = "yes"
          and ( trn-doc-code = "" or trn-doc-code = ? )
          then do:
          if can-find( first other_price-list no-lock where
                        other_price-list.doc-num    = ub.price-list.doc-num   and
                        other_price-list.artic      = ub.price-list.artic     and
                        other_price-list.prod-code  = ub.price-list.prod-code and
                        other_price-list.prod-type  = ub.price-list.prod-type and
                        other_price-list.main-price = false ) then next.
            run del-pr-list in this-procedure
                           (input ub.price-list.b-code,
                            input ub.price-list.doc-num,
                            input ? ,
                            input ?) no-error.
            if error-status :error
            then do:
              undo main-block, return error return-value .
            end.
          end.
        end.
        if available ub.price-list
        then do:
          accumulate ub.price-list.artic (count).
        end.
      end.
      run update-den-price-all in this-procedure .
      if (accum count ub.price-list.artic) = 0
      then do:
        if p-mode = "close" and buf-price-doc.status_ <> 'разрешен':U
        then do:
          if p-ask-q = false then
          message
            "В документе нет ни одной строки. Удаляем документ."  buf-price-doc.status_
            view-as alert-box .
        end.
        if  p-mode = "close"  and buf-price-doc.status_ <> 'разрешен':U
        then do:
            delete buf-price-doc.
            return .
        end.
        if  p-mode = "close-act"  and buf-price-doc.status_ <> 'разрешен':U
        then do:
            return .
        end.
      end.
      else do:
        if buf-price-doc.obj-type = 'маг':U
        then do:
          run str/diallog.w
                      (parparentproc
                      , this-procedure
                      , 'str/send-prl.p':U
                      , ("U":U + chr(4) + buf-price-doc.doc-num + chr(4)  + string(buf-price-doc.obj-code))
                      , yes
                      , '':U
                      , 'Пересылка новых цен товаров переоценки на кассы') no-error .
          if error-status :error
          then do:
            if p-ask-q = false then
            message
              vss-workfile vss-revision vss-description skip
              "Ошибка отправки товаров на кассу" skip
              error-status :get-message(1) skip
              return-value skip
              view-as alert-box error .
            undo main-block, return error "Ошибка отправки товаров на кассу".
          end.
        end.
        if substring (buf-price-doc.PS, 1, 1) = "@"
        then do:
          assign
            buf-price-doc.PS = buf-price-doc.PS + chr(10)
                    + "Строк в акте : " + string ((accum count ub.price-list.artic), ">>>>>9")
          .
        end.
      end.
    end.
    assign
      buf-price-doc.fact-date  = varfact-date
      buf-price-doc.fact-time  = varfact-time
      buf-price-doc.shift-date = varshift-date
      buf-price-doc.shift-num  = varshift-num
      buf-price-doc.shift-name = varshift-name
      buf-price-doc.status_    = p-new-status_
    .
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  buf-price-doc.host-code
  ,input  buf-price-doc.fact-date
  ,output buf-price-doc.base-rate
  ,output buf-price-doc.base-scale
  ) no-error .
    if error-status :error
    then do:
      if p-ask-q = false then
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при определении текущего курса в переоценке " skip
        "Код фирмы" buf-price-doc.host-code skip
        "Дата" buf-price-doc.fact-date skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error "Ошибка при определении текущего курса в переоценке " .
    end.
  release buf-price-doc no-error .
  if error-status :error then do:
     undo main-block, return error return-value .
  end.
  find first buf-price-doc no-lock
    where buf-price-doc.doc-num = price-doc-num
    no-error .
    if buf-price-doc.status_ = 'акт':U then do:
        run str/pdfdiscl.p ( Parparentproc , price-doc-num ) no-error .
        if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              "из pdfdiscl"
              view-as alert-box error
            .
            undo main-block, return error substitute("Ошибка при закрытии порожденных ДНЦ &1 по переоценке &2 ." ,return-value , price-doc-num) .
        end.
    end.
    if p-mode = "close"
    then do:
      case buf-price-doc.status_ :
        when 'разрешен':U
        then do:
          if p-ask-q = false then
          message "Переоценка включена.".
          if buf-price-doc.obj-type = 'маг':U
          then do:
            if p-ask-q = false then
            message
              "Рекомендуется принять чеки," skip
              "закрыть отчеты о продажах" skip
              "и после этого закрывать переоценку." skip
              view-as alert-box information .
          end.
        end.
      end.
    end.
    define buffer buf_thbj-attr for ub.thbj-attr.
    define variable v-uniq-key-rec as character no-undo .
    find first buf_thbj-attr no-lock where
              buf_thbj-attr.upper-prop-code = 'rum':U
          and buf_thbj-attr.prop-code = 'edoc':U
          and buf_thbj-attr.obj-type = ''
          and buf_thbj-attr.obj-code = 0
          and buf_thbj-attr.property-value-logical = yes
          no-error.
    if available buf_thbj-attr then do:
      run gen-key-rec in this-procedure (
                                        input  'thbj-attr':U
                                      ,input (buffer buf_thbj-attr:handle)
                                      ,output v-uniq-key-rec).
      run str/edocrum.p
        (
        input parparentproc
        ,input this-procedure:handle
        ,input p-log-handle
        ,input 'batchwork-routing_price-doc':U
        ,input 0
        ,input 18
        ,input 10
        ,input curr-db-num
        ,input v-uniq-key-rec
        ,input ( buf-price-doc.doc-num + chr(4) + '')
        ,input yes
        ) no-error .
      if error-status:error then do:
        undo main-block, return error substitute("Ошибка при маршрутизации переоценки во внешнюю систему:&1&2&1&3"
                                                 , chr(10)
                                                 , error-status:get-message(1)
                                                 , return-value) .
      end.
    end.
    define variable varok as logical no-undo.
    run check-the-same-object (output varok).
    if buf-price-doc.obj-type = 'маг':U and
        can-find (first ub.scales no-lock where ub.scales.db-num = curr-db-num ) and  varok
    then do:
      run send-to-scales(INPUT int(recid(buf-price-doc))) no-error.
      if error-status:error then
        undo main-block, return error subst("Ошибка при отправке на весы - &1", return-value).
    end.
  end.
  run waitfram-hide in this-procedure .
end.
procedure check-the-same-object :
  define output parameter p-ok as logical no-undo .
  find first ub.clients no-lock
    where ub.clients.obj-type = buf-price-doc.obj-type
      and ub.clients.obj-code = buf-price-doc.obj-code
    .
  assign
    p-ok = (ub.clients.db-num = curr-db-num )
  .
end procedure.
procedure proc-cost-price-fact :
 do
 on error undo, return error return-value
 :
define variable v-total-avrg-base  as decimal no-undo .
define variable v-total-avrg-rubl  as decimal no-undo .
define variable v-total-avrg-qnty  as decimal no-undo .
define buffer buf_parts for ub.parts.
define buffer buf_price-list for ub.price-list.
define variable p-price-base as decimal no-undo .
define variable p-price-rubl as decimal no-undo .
for each buf_price-list no-lock
    where buf_price-list.doc-num = buf-price-doc.doc-num
on error undo, return error return-value
:
      for each buf_parts no-lock
        where  buf_parts.obj-type  = buf-price-doc.obj-type
          and buf_parts.obj-code   = buf-price-doc.obj-code
          and buf_parts.artic      = buf_price-list.artic
          and buf_parts.prod-type  = buf_price-list.prod-type
          and buf_parts.prod-code  = buf_price-list.prod-code
          and ( buf_parts.out-code  = 'free-zone':U  or
                buf_parts.out-code  = buf-price-doc.doc-num
          )
      on error undo, return error return-value
      :
        assign
          v-total-avrg-base = v-total-avrg-base
                            + (buf_parts.price-base * buf_parts.qnty)
          v-total-avrg-rubl = v-total-avrg-rubl
                            + (buf_parts.price-rubl * buf_parts.qnty)
          v-total-avrg-qnty = v-total-avrg-qnty
                            + buf_parts.qnty
        .
      end.
      if v-total-avrg-qnty > 0
      then do:
        assign
          p-price-base = ( v-total-avrg-base / v-total-avrg-qnty )
          p-price-rubl = ( v-total-avrg-rubl / v-total-avrg-qnty )
        .
      end.
      else do:
        assign
          p-price-base = ?
          p-price-rubl = ?
        .
      end.
 define variable p-attr-value as character no-undo .
 if var-pr-r-b = "rubl" then
    p-attr-value = string ( p-price-rubl ) .
    else
    p-attr-value = string ( p-price-base ) .
  run create-price-list-attr in this-procedure (
    'cost-price-fact':U    ,
    p-attr-value          ,
    buf_price-list.b-code ,
    buf-price-doc.doc-num ,
    ""
    ) .
end.
 end.
end procedure.
procedure proc-d-pcnt :
define input  parameter p-doc-code as character no-undo .
define output parameter v-rez as logical   no-undo  .
  do
  on error undo, return error return-value
  :
define buffer bb_price-list for ub.price-list  .
v-rez = false .
  end.
end procedure.
procedure update-den-price-all :
define buffer buf_price-all for ub.price-all  .
  do
  on error undo, return error return-value
  :
  for each ub.price-list  where ub.price-list.doc-num = buf-price-doc.doc-num
  on error undo , return error return-value
  :
    find ub.goods no-lock
      where ub.goods.artic     = ub.price-list.artic
        and ub.goods.prod-type = ub.price-list.prod-type
        and ub.goods.prod-code = ub.price-list.prod-code
      .
        find first buf_price-all exclusive-lock where
                  buf_price-all.obj-type = buf-price-doc.obj-type and
                  buf_price-all.obj-code = buf-price-doc.obj-code and
                  buf_price-all.main-indication = 0 and
                  buf_price-all.plt-id       = buf-price-doc.plt-id   and
                  buf_price-all.plt-db-num   = buf-price-doc.plt-db-num and
                  buf_price-all.pdf-id       = buf-price-doc.pdf-id     and
                  buf_price-all.pdf-db       = buf-price-doc.pdf-db     and
                  buf_price-all.gds-code     = ub.goods.gds-code and
                  buf_price-all.b-code       = ub.price-list.b-code no-error .
                  if available buf_price-all
                  then do:
                    assign
                      buf_price-all.out-code    = buf-price-doc.doc-num
                      buf_price-all.last-pr     = true
                      buf_price-all.status_     = 'акт':U
                    .
                  end.
       end.
  end.
end procedure.
procedure ver-date-period :
define input  parameter  p-fact-date as date   no-undo .
define variable v-value-character   as character no-undo .
define variable v-date-close-period as date      no-undo .
define variable v-value-decimal     as decimal   no-undo .
define variable v-value-integer     as integer   no-undo .
define variable v-value-logical     as logical   no-undo .
define variable v-value-type        as character no-undo .
  do
  on error undo, return error return-value
  :
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.
  run adm/shattri.p (
      input "get":U
      ,input buf-price-doc.obj-type
      ,input buf-price-doc.obj-code
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
          if  p-fact-date < v-date-close-period
          then do:
            return error substitute(
              "Дата закрытия документа &1 более ранняя, чем дата закрытия периода &2
              Дата закрытия документа &3 &2
              Дата закрытия периода &4
              Объект &5 &6     " ,
              buf-price-doc.doc-num  ,
              chr(10)  ,
              string ( p-fact-date        , "99/99/9999") ,
              string ( v-date-close-period, "99/99/9999") ,
              buf-price-doc.obj-type ,
              buf-price-doc.obj-code
              ) .
          end.
      end.
  end.
end procedure.
procedure send-to-scales:
    define input parameter p-price-doc-recid as integer no-undo.
    define variable v-param-type as character no-undo .
    define variable v-value-character as character no-undo .
    define variable v-value-date as date no-undo .
    define variable v-value-decimal as decimal no-undo .
    define variable v-value-integer as INTEGER no-undo .
    define variable v-value-logical AS LOGICAL no-undo .
    define variable v-tth as handle no-undo .
    define buffer buf_price-doc for ub.price-doc.
    define buffer buf_price-list for ub.price-list.
    define buffer buf_bar-code for ub.bar-code.
    define buffer buf_goods for ub.goods.
    v-tth = buffer thbjattr_thbj-attr:table-handle .
    for each thbjattr_thbj-attr:
      delete thbjattr_thbj-attr.
    end.
    run adm/shattri.p (
       input "get":U
      ,input  v-cntxt-obj-type
      ,input  v-cntxt-obj-code
      ,input  'scale-inf':U
      ,input  'noauto-scls':U
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
        substitute("Ошибка при получении настроек, необъодимых для работы весов НА ОБЪЕКТЕ &1&2:&3&4 &5"
                , v-cntxt-obj-type
                , v-cntxt-obj-code
                , chr(10)
                , error-status:get-message(1)
                , return-value )
        view-as alert-box error .
        undo, return error .
    end.
    find first buf_price-doc no-lock
      where recid(buf_price-doc) = p-price-doc-recid.
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_add-scal in g#lib-trn3
(input parparentproc
,input buf_price-doc.obj-type
,input buf_price-doc.obj-code
,input buf_price-doc.doc-num
,input 'переоценка':U
,input this-procedure
) no-error.
    if error-status :error
    then do:
      return error "Ошибка при обновлении информации на весах " + return-value .
    end.
    if v-value-logical OR p-mode = 'close' then return.
    run str/diallog.w
      ( input parparentproc
      , input this-procedure
      , input "ref/sendscal.p":U
      , input (buf_price-doc.obj-type + chr(4) + string(buf_price-doc.obj-code) + chr(4) + chr(63) + chr(4) +
               "changed":U + chr(4) + '' + chr(4) + "current":U + chr(4) + string(0))
      , input no
      , input "":U
      , input substitute("Отсылка изменений на весы")
      ) no-error.
end procedure.
