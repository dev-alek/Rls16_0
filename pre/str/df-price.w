DEFINE NEW SHARED BUFFER buf_bar-code FOR bar-code.
DEFINE NEW SHARED BUFFER buf_goods FOR goods.
DEFINE NEW SHARED BUFFER buf_price-doc-forming FOR price-doc-forming.
DEFINE NEW SHARED BUFFER buf_price-doc-forming-gds FOR price-doc-forming-gds.
define input  parameter parParentProc     as handle    no-undo .
define input  parameter p-mode            as character no-undo .
define input  parameter p-plt-id          as integer   no-undo .
define input  parameter p-plt-db-num      as integer   no-undo .
define input  parameter p-recid-gds       as recid     no-undo .
define output parameter p-rec-list        as character no-undo .
define input-output parameter p-doc-rec   as recid     no-undo.
define input-output parameter p-br-handle as handle    no-undo .
define input-output parameter p-buffer-handle as handle    no-undo .
define input-output parameter p-next-prev as logical   no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Документ назначения цены".
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
define new global shared variable g#lib-trn  as handle no-undo .
define new global shared variable g#lib-trn2 as handle no-undo .
define new global shared variable g#lib-trn3 as handle no-undo .
define new global shared variable g#lib-trn4 as handle no-undo .
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
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new shared temp-table gds-list no-undo like ub.goods
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  new shared  temp-table gds-list-hist no-undo
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
define variable v-str as character no-undo .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table x_obj-group no-undo like ub.clients  .
define temp-table x_grp-obj-price no-undo like ub.grp-obj-price .
procedure metod-gop-obj :
  do
  on error undo, return error return-value
  :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-gop-id       as integer   no-undo .
define input  parameter p-gop-db-num   as integer   no-undo .
define buffer buf1_clients for ub.clients  .
define buffer buf_db-grp-obj-price   for ub.db-grp-obj-price  .
define buffer buf_host-grp-obj-price for ub.host-grp-obj-price  .
define buffer buf_obj-grp-obj-price  for ub.obj-grp-obj-price  .
for each  x_obj-group : delete x_obj-group. end.
if p-gop-id = 0 or p-gop-id = ?  then do:
   if p-cntxt-db-num = 0  then do:
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = 'маг':U  or
                 buf1_clients.obj-type = 'скл':U  )
                and
                buf1_clients.db-num >= 0  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
   else do:
        for each buf1_clients no-lock where
                (buf1_clients.obj-type = 'маг':U  or
                 buf1_clients.obj-type = 'скл':U  ) and
                 buf1_clients.db-num = p-cntxt-db-num  and
                 buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
   end.
end.
else do:
      for each buf_db-grp-obj-price  where
              buf_db-grp-obj-price.gop-id     = p-gop-id and
              buf_db-grp-obj-price.gop-db-num = p-gop-db-num and
              buf_db-grp-obj-price.stts = 0  no-lock :
        for each buf1_clients no-lock where
               (buf1_clients.obj-type = 'маг':U  or
                buf1_clients.obj-type = 'скл':U  ) and
                buf1_clients.db-num = buf_db-grp-obj-price.dgo-db-num  and
                buf1_clients.stts = 0
                :
          create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
        end.
      end.
    for each buf_host-grp-obj-price where
            buf_host-grp-obj-price.gop-id     = p-gop-id and
            buf_host-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_host-grp-obj-price.stts = 0
            no-lock :
      for each buf1_clients no-lock where
             (buf1_clients.obj-type = 'маг':U  or
              buf1_clients.obj-type = 'скл':U  ) and
              buf1_clients.host-code = buf_host-grp-obj-price.host-code and
              buf1_clients.stts = 0
              :
          find first x_obj-group no-lock  where
                    x_obj-group.obj-code   = buf1_clients.obj-code and
                    x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
    for each buf_obj-grp-obj-price where
            buf_obj-grp-obj-price.gop-id     = p-gop-id and
            buf_obj-grp-obj-price.gop-db-num = p-gop-db-num and
            buf_obj-grp-obj-price.stts = 0
            no-lock :
      for each buf1_clients no-lock where
                buf1_clients.obj-type = buf_obj-grp-obj-price.obj-type and
                buf1_clients.obj-code = buf_obj-grp-obj-price.obj-code and
                buf1_clients.stts     = 0
                :
          find first  x_obj-group no-lock  where
                      x_obj-group.obj-code   = buf1_clients.obj-code and
                      x_obj-group.obj-type   = buf1_clients.obj-type no-error .
          if not available  x_obj-group then   create x_obj-group .
          assign
            x_obj-group.obj-code   = buf1_clients.obj-code
            x_obj-group.obj-type   = buf1_clients.obj-type
            x_obj-group.obj-name   = buf1_clients.obj-name
            x_obj-group.db-num     = buf1_clients.db-num
          .
      end.
    end.
end.
end.
end procedure.
procedure metod-obj-in-gop :
define input  parameter p-curr-db-num as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define buffer buf_grp-obj-price for ub.grp-obj-price  .
  do
  on error undo, return error return-value
  :
    empty temp-table x_grp-obj-price.
    for each buf_grp-obj-price where
             buf_grp-obj-price.stts = 0
             no-lock :
               run metod-gop-obj (p-curr-db-num , buf_grp-obj-price.gop-id ,buf_grp-obj-price.gop-db-num) .
               for each x_obj-group where
                        x_obj-group.obj-type = p-obj-type and
                        x_obj-group.obj-code = p-obj-code :
                    create  x_grp-obj-price.
                    buffer-copy buf_grp-obj-price to x_grp-obj-price .
               end.
    end.
  end.
end procedure.
procedure metod-delobj-usr :
define input  parameter p-pdf-id  as integer   no-undo .
define input  parameter p-pdf-db  as integer   no-undo .
define input  parameter p-plt-id  as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
for each buf_price-doc-forming-attr no-lock  where
         buf_price-doc-forming-attr.pdf-id =     p-pdf-id and
         buf_price-doc-forming-attr.pdf-db =     p-pdf-db and
         buf_price-doc-forming-attr.plt-id =     p-plt-id and
         buf_price-doc-forming-attr.plt-db-num = p-plt-db-num and
         buf_price-doc-forming-attr.attr-code begins "obj" :
   for each x_obj-group  where
            x_obj-group.obj-type = substring(buf_price-doc-forming-attr.attr-code,4,3) and
            x_obj-group.obj-code = int(substring(buf_price-doc-forming-attr.attr-code,7,20)) :
     delete x_obj-group.
   end.
end.
  if not can-find (first x_obj-group) then do:
     return "nullobj" .
  end.
end.
end procedure.
procedure metod-obj-pdf :
define input  parameter p-cntxt-db-num as integer   no-undo .
define input  parameter p-pdf-id     like ub.price-doc-forming.pdf-id   no-undo .
define input  parameter p-pdf-db-num like ub.price-doc-forming.pdf-db   no-undo .
define input  parameter p-plt-id     like ub.price-doc-forming.plt-id   no-undo .
define input  parameter p-plt-db-num like ub.price-doc-forming.plt-db-num  no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
  do
  on error undo, return error return-value
  :
 for each  x_obj-group : delete x_obj-group. end.
 find first buf_price-list-type no-lock where
            buf_price-list-type.plt-id = p-plt-id and
            buf_price-list-type.plt-db-num = p-plt-db-num no-error .
if error-status :error then return error return-value .
 find first buf_price-doc-forming no-lock where
            buf_price-doc-forming.plt-id     = p-plt-id and
            buf_price-doc-forming.plt-db-num = p-plt-db-num and
            buf_price-doc-forming.pdf-id     = p-pdf-id and
            buf_price-doc-forming.pdf-db     = p-pdf-db-num
            no-error .
if error-status :error then return error return-value .
  run metod-gop-obj in this-procedure (
      p-cntxt-db-num,
      buf_price-list-type.gop-id ,
      buf_price-list-type.gop-db-num
      ) no-error .
  run metod-delobj-usr in this-procedure (
    buf_price-doc-forming.pdf-id ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id ,
    buf_price-doc-forming.plt-db-num
    ) no-error .
  end.
end procedure.
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
function hvrdtax return logical (input parrecid as recid):
define variable varresult as logical no-undo.
run hvrdtax-proc (input parrecid, output varresult).
return varresult.
end function.
procedure hvrdtax-proc:
define input  parameter parrecid  as recid   no-undo.
define output parameter parresult as logical no-undo.
define buffer bf_goods for ub.goods.
define buffer bf_units for ub.units.
define buffer rt_tax   for ub.tax.
find first rt_tax   where rt_tax.tax-code    = integer('3':U) no-lock no-error.
find first bf_goods where recid(bf_goods)    = parrecid              no-lock.
find first bf_units where bf_units.unit-name = bf_goods.unit-base    no-lock.
if available rt_tax and
    can-find(first ub.tax-units No-LOCK WHERE
                   ub.tax-units.tax-code = rt_tax.tax-code AND
                   LOOKUP(ub.tax-units.type, bf_units.type) > 0) then assign parresult = yes.
                                                    else assign parresult = no.
end procedure.
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure prcreate-new-price-doc :
do
on error undo, return error return-value
:
define input  parameter p-curr-db-num  as integer   no-undo .
define input  parameter p-obj-type     like ub.price-doc.obj-type no-undo.
define input  parameter p-obj-code     like ub.price-doc.obj-code no-undo.
define input  parameter p-plt-id       as integer   no-undo .
define input  parameter p-plt-db-num   as integer   no-undo .
define input  parameter p-pdf-id       as integer   no-undo .
define input  parameter p-pdf-db-num   as integer   no-undo .
define output parameter p-price-doc-recid  as recid                no-undo.
define variable v-host-code         like ub.sysconf.host-code        no-undo.
define variable v-obj-current-date  like ub.price-doc.doc-date      no-undo.
define variable v-base-rate    like ub.price-doc-forming.base-rate   no-undo .
define variable v-base-scale   like ub.price-doc-forming.base-scale  no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming.
define buffer buf_price-doc         for ub.price-doc.
find first buf_price-doc-forming no-lock where
           buf_price-doc-forming.pdf-db     = p-pdf-db-num and
           buf_price-doc-forming.pdf-id     = p-pdf-id     and
           buf_price-doc-forming.plt-db-num = p-plt-db-num and
           buf_price-doc-forming.plt-id     = p-plt-id
           no-error .
if not available buf_price-doc-forming and p-plt-id = ? then do:
   run create_new_price-doc-forming
        ( input p-obj-type ,
          input p-obj-code ,
          output p-pdf-db-num ,
          output p-pdf-id ,
          output p-plt-db-num ,
          output p-plt-id
          ).
    find first buf_price-doc-forming no-lock where
              buf_price-doc-forming.pdf-db     = p-pdf-db-num and
              buf_price-doc-forming.pdf-id     = p-pdf-id     and
              buf_price-doc-forming.plt-db-num = p-plt-db-num and
              buf_price-doc-forming.plt-id     = p-plt-id
              no-error .
end.
    create buf_price-doc .
    run doc-code in this-procedure
    (input  "main",
     input  p-obj-type  ,
     input  p-obj-code  ,
     input  ?,
     output buf_price-doc.doc-num) no-error.
    if error-status:error then do:
      message vss-workfile vss-revision vss-description skip
             error-status :get-message(1)
            "Ошибка при генерации номера документа." return-value view-as alert-box error.
      return error.
    end.
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
    v-obj-current-date  = today .
    if not (buf_price-doc-forming.base-rate = 0 or buf_price-doc-forming.base-rate = ?) then do:
        v-base-rate   =  buf_price-doc-forming.base-rate  .
        v-base-scale  =  buf_price-doc-forming.base-scale .
    end.
    else do:
define variable vss-include-info18 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  v-obj-current-date
  ,output v-base-rate
  ,output v-base-scale
  )  .
    end.
   assign
    buf_price-doc.base-rate      = v-base-rate
    buf_price-doc.base-scale     = v-base-scale
    buf_price-doc.cr-db-num      = p-curr-db-num
    buf_price-doc.doc-date       = v-obj-current-date
    buf_price-doc.fact-num       = 0
    buf_price-doc.host-code      = v-host-code
    buf_price-doc.is-corr        = false
    buf_price-doc.is-del         = false
    buf_price-doc.obj-code       = p-obj-code
    buf_price-doc.obj-type       = p-obj-type
    buf_price-doc.out-code       = ""
    buf_price-doc.pdf-db         = p-pdf-db-num
    buf_price-doc.pdf-id         = p-pdf-id
    buf_price-doc.plt-db-num     = p-plt-db-num
    buf_price-doc.plt-id         = p-plt-id
    buf_price-doc.PS             = "@ "
    buf_price-doc.rest-base      = 0
    buf_price-doc.rest-last      = 0
    buf_price-doc.rest-qnty      = 0
    buf_price-doc.rest-sale      = 0
    buf_price-doc.sale-base      = 0
    buf_price-doc.status_        = 'новый':U
    .
    buf_price-doc.doc-num-es     = entry(1, buf_price-doc-forming.des, chr(4)) no-error.
    buf_price-doc.uid-es         = entry(2, buf_price-doc-forming.des, chr(4)) no-error.
    buf_price-doc.doc-date       = date(entry(3, buf_price-doc-forming.des, chr(4))) no-error.
    if buf_price-doc.uid-es = "_" then buf_price-doc.uid-es = "" .
    assign
        p-price-doc-recid = recid ( buf_price-doc )
    .
end.
end procedure.
procedure prcreate-new-price-list :
do
on error undo, return error return-value
:
define input parameter p-price-doc-recid   as recid                    no-undo.
define input parameter p-gds-code          like ub.goods.gds-code         no-undo.
define input parameter p-price-sale        like ub.price-list.price-sale  no-undo.
define output parameter p-update           as logical                  no-undo.
define variable kk as integer no-undo .
define var v-b-code    like ub.bar-code.b-code     no-undo.
define variable p-hostcode as int no-undo .
define variable local_vat-pc like ub.price-list.vat-pc    no-undo.
define variable local_slt-pc like ub.price-list.slt-pc    no-undo.
define buffer buf_price-doc        for ub.price-doc.
define buffer buf_price-list       for ub.price-list.
define buffer buf_bar-code         for ub.bar-code.
define buffer buf_goods            for ub.goods.
define buffer buf_root_gds-prt     for ub.gds-prt.
define buffer buf_gds-prt          for ub.gds-prt.
find first buf_price-doc no-lock
     where recid( buf_price-doc ) = p-price-doc-recid
.
find first buf_goods no-lock
     where buf_goods.gds-code = p-gds-code
.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  p-gds-code
  ,input  ?
  ,output v-b-code
  ) no-error .
if error-status :error
then do:
    message
        "Не найден основной бар-код"
        skip "для товара "
        skip string(buf_goods.artic)
        skip buf_goods.gds-name
    view-as alert-box
    title "Ошибка при выполнении prcreate.i".
    undo, return error .
end.
find first buf_bar-code no-lock
     where buf_bar-code.b-code = v-b-code
no-error.
if error-status :error
then do:
    message
        "Не найдена запись bar-code"
        skip "для товара "
        skip string(buf_goods.artic)
        skip buf_goods.gds-name
        skip "С основным бар-кодом"
        skip string(v-b-code)
    view-as alert-box
    title "Ошибка при выполнении prcreate.i".
    undo, return error .
end.
find first buf_root_gds-prt no-lock
     where buf_root_gds-prt.upper-code = buf_goods.prt-root
.
if buf_root_gds-prt.node-name <> '_Пустая шкала':U
  and buf_bar-code.in-code <> ""
then do:
    message
        "Не допускается создавать спец. цены на партии для товаров с непустой шкалой!" skip (2)
        "Артикул:" buf_goods.artic "Код:" buf_goods.gds-code buf_goods.gds-name
        view-as alert-box error.
    undo, return error.
end.
find first buf_gds-prt no-lock
     where buf_gds-prt.node-code = buf_bar-code.node-code
.
find first buf_price-list
     where buf_price-list.doc-num = buf_price-doc.doc-num
       and buf_price-list.b-code  = v-b-code
no-error.
if available buf_price-list
then do:
    message "Строка с товаром арт." buf_price-list.artic " уже есть в данной переоценке."
       skip "  Цена:   " buf_price-list.price-sale
       skip "Цена будет изменена"
    view-as alert-box warning.
    assign
        p-update = yes
    .
end.
else do:
define variable vss-include-info19 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info20 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info21 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf_goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf_price-doc.obj-type
  ,input  buf_price-doc.obj-code
  ,output local_slt-pc
  ) no-error .
    kk = kk + 1.
define variable v-main-bar-code as integer   no-undo .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output v-main-bar-code
  )  .
    create buf_price-list.
    assign
        buf_price-list.line-num    = kk
        buf_price-list.doc-num     = buf_price-doc.doc-num
        buf_price-list.b-code      = buf_bar-code.b-code
        buf_price-list.artic       = buf_goods.artic
        buf_price-list.prod-type   = buf_goods.prod-type
        buf_price-list.prod-code   = buf_goods.prod-code
        buf_price-list.main-price  = (buf_bar-code.b-code = v-main-bar-code )
        buf_price-list.calc-method = 'Отсутствует':U
        buf_price-list.obj-type    = buf_price-doc.obj-type
        buf_price-list.obj-code    = buf_price-doc.obj-code
        buf_price-list.price-sale  = p-price-sale
        buf_price-list.vat-pc      = local_vat-pc
        buf_price-list.slt-pc      = local_slt-pc
        p-update                   = no
    .
end.
end.
end procedure.
procedure create_new_price-doc-forming :
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-pdf-db-num as integer   no-undo .
define output parameter p-pdf-id     as integer   no-undo .
define output parameter p-plt-db-num as integer   no-undo .
define output parameter p-plt-id     as integer   no-undo .
define buffer buf_price-list-type for ub.price-list-type  .
define variable v-host-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as integer   no-undo .
define variable v-base as logical   no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info22 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
define variable vss-include-info23 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,output v-host-code
  )  .
define variable vss-include-info24 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-host-code
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  )  .
define variable vss-include-info25 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplobj in g#library2
  (input  ?
  ,input  p-obj-type
  ,input  p-obj-code
  ,input  yes
  ,output p-plt-id
  ,output p-plt-db-num
  )  .
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id       = p-plt-id
      ub.price-doc-forming.plt-db-num   = p-plt-db-num
      ub.price-doc-forming.pdf-id       = next-value ( s-pdf , ub)
      ub.price-doc-forming.pdf-db       = v-cntxt-db-num
      ub.price-doc-forming.base-rate    = v-base-rate
      ub.price-doc-forming.base-scale   = v-base-scale
      ub.price-doc-forming.db-num-chg   = v-cntxt-db-num
      ub.price-doc-forming.exch-rate    = if v-base then v-base-rate else 1
      ub.price-doc-forming.exch-scale   = if v-base then v-base-scale else 1
      ub.price-doc-forming.stts         = 0
      ub.price-doc-forming.sys-date     = today
      ub.price-doc-forming.sys-time     = time
      ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who          = v-cntxt-userid
      ub.price-doc-forming.name         = "автосоздание"
   .
   assign
    p-pdf-db-num  = ub.price-doc-forming.pdf-db
    p-pdf-id      = ub.price-doc-forming.pdf-id
    p-plt-db-num  = ub.price-doc-forming.plt-db-num
    p-plt-id      = ub.price-doc-forming.plt-id
   .
  end.
end procedure.
procedure prcreate-new-price-doc-forming-gds :
define input  parameter p-price-doc-forming-recid as recid  no-undo.
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define input  parameter par-pr-notls as character no-undo .
define input  parameter par-pr-altex as character no-undo .
define input  parameter par-pr-sclex as character no-undo .
define input  parameter p-line-num    as integer   no-undo .
define input  parameter p-gds-code    as integer   no-undo .
define input  parameter p-price-sale  as decimal   no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
define buffer main_bar-code for ub.bar-code  .
define variable main-b-code as integer   no-undo .
define variable v-sec as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal   no-undo .
define variable v-cur-rt as decimal   no-undo .
define variable v-cur-ex as decimal   no-undo .
find first buf_price-doc-forming no-lock where
           recid(buf_price-doc-forming) = p-price-doc-forming-recid  no-error .
           if error-status :error then return error .
find first buf_goods no-lock where
           buf_goods.gds-code  = p-gds-code no-error .
           if error-status :error then return error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output main-b-code
  ) no-error .
run check-use-bar-code (main-b-code) no-error .
if error-status :error then return .
run create-line-pdf-mpl-lib (
     input buf_price-doc-forming.plt-db-num
    ,input buf_price-doc-forming.plt-id
    ,input buf_price-doc-forming.pdf-db
    ,input buf_price-doc-forming.pdf-id
    ,input p-line-num
    ,input main-b-code
    ,input buf_goods.artic
    ,input buf_goods.prod-type
    ,input buf_goods.prod-code
    ,input ""
    ,input 0
    ,input p-price-sale
    ,input ""
    ,input 0
   ,input-output v-sec ) no-error .
   if error-status :error  then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "2"
       view-as alert-box error
     .
   end.
define buffer old_price-list for ub.price-list  .
if par-pr-notls = "yes" then do:
define variable vss-include-info26 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  main-b-code
  ,input  0
  ,input  0
  ,output v-cur-dn
  ,output v-cur-pr
  ,output v-cur-rt
  ,output v-cur-ex
  )  .
end.
if par-pr-altex = "yes" and
   par-pr-notls = "yes" then do:
    if v-cur-dn <> "" then do:
        for each old_price-list no-lock where
                 old_price-list.doc-num = v-cur-dn and
                 old_price-list.artic      = buf_goods.artic and
                 old_price-list.prod-type  = buf_goods.prod-type and
                 old_price-list.prod-code  = buf_goods.prod-code and
                 old_price-list.main-price = no,
                first buf_bar-code no-lock where
                      buf_bar-code.b-code   = old_price-list.b-code and
                      buf_bar-code.unit-cli <> buf_goods.unit-base
                      :
                       run check-use-bar-code (buf_bar-code.b-code) no-error .
                       if error-status :error then next.
                 run create-line-pdf-mpl-lib (
                       input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input p-line-num
                      ,input old_price-list.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input old_price-list.price-sale
                      ,input ""
                      ,input 0
                     ,input-output v-sec ) no-error .
        end.
    end.
end.
if par-pr-sclex = "yes" and
   par-pr-notls = "yes" then do:
    if v-cur-dn <> "" then do:
        for each old_price-list no-lock where
                 old_price-list.doc-num    = v-cur-dn and
                 old_price-list.artic      = buf_goods.artic and
                 old_price-list.prod-type  = buf_goods.prod-type and
                 old_price-list.prod-code  = buf_goods.prod-code and
                 old_price-list.main-price = no,
                first buf_bar-code no-lock where
                      buf_bar-code.b-code   = old_price-list.b-code and
                      buf_bar-code.in-code  = "" and
                      buf_bar-code.unit-cli = buf_goods.unit-base
                      :
                       run check-use-bar-code (buf_bar-code.b-code) no-error .
                       if error-status :error then next.
                 run create-line-pdf-mpl-lib (
                       input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input p-line-num
                      ,input old_price-list.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input old_price-list.price-sale
                      ,input ""
                      ,input 0
                    ,input-output v-sec ) no-error .
        end.
    end.
end.
end.
end procedure.
procedure copy_new_price-doc-forming :
define input  parameter       p-recid      as recid no-undo .
define input-output parameter p-plt-db-num as integer   no-undo .
define input-output parameter p-plt-id     as integer   no-undo .
define output parameter       p-pdf-db-num as integer   no-undo .
define output parameter       p-pdf-id     as integer   no-undo .
define buffer buf_price-list-type        for ub.price-list-type  .
define buffer buf_price-doc-forming      for ub.price-doc-forming .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr .
define buffer buf_price-doc-forming-gds  for ub.price-doc-forming-gds .
define buffer buf_pd-forming-gds-attr    for ub.price-doc-forming-gdsattr .
define variable v-host-code  as integer   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as integer   no-undo .
define variable v-base as logical   no-undo .
define variable v-name as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info27 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
find first buf_price-list-type no-lock where
           buf_price-list-type.plt-db-num = p-plt-db-num and
           buf_price-list-type.plt-id     = p-plt-id no-error .
if error-status :error then return error "Не найден ТПЛ".
if buf_price-list-type.stts <> 0 then return error "ТПЛ удален" .
find first buf_price-doc-forming  no-lock where recid(buf_price-doc-forming )  = p-recid no-error .
    if available buf_price-doc-forming then do :
        assign
          v-base-rate  = buf_price-doc-forming.base-rate
          v-base-scale = buf_price-doc-forming.base-scale
          v-name       =  substitute("Скопировано с ДНЦ &1 &2",  buf_price-doc-forming.pdf-id , trim(buf_price-doc-forming.name)  )
        .
    end.
    else do:
        assign
          v-base-rate  = 1
          v-base-scale = 1
          v-name       = "Автосоздание"
        .
    end.
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id       = p-plt-id
      ub.price-doc-forming.plt-db-num   = p-plt-db-num
      ub.price-doc-forming.pdf-id       = next-value ( s-pdf , ub)
      ub.price-doc-forming.pdf-db       = v-cntxt-db-num
      ub.price-doc-forming.base-rate    = v-base-rate
      ub.price-doc-forming.base-scale   = v-base-scale
      ub.price-doc-forming.db-num-chg   = v-cntxt-db-num
      ub.price-doc-forming.exch-rate    = if v-base then v-base-rate else 1
      ub.price-doc-forming.exch-scale   = if v-base then v-base-scale else 1
      ub.price-doc-forming.stts         = 0
      ub.price-doc-forming.sys-date     = today
      ub.price-doc-forming.sys-time     = time
      ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who          = v-cntxt-userid
      ub.price-doc-forming.name         = v-name
   .
   assign
    p-pdf-db-num  = ub.price-doc-forming.pdf-db
    p-pdf-id      = ub.price-doc-forming.pdf-id
    p-plt-db-num  = ub.price-doc-forming.plt-db-num
    p-plt-id      = ub.price-doc-forming.plt-id
   .
  end.
  if not available buf_price-doc-forming then return .
for each buf_price-doc-forming-attr no-lock where
         buf_price-doc-forming-attr.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_price-doc-forming-attr.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_price-doc-forming-attr.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_price-doc-forming-attr.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-attr.
    buffer-copy buf_price-doc-forming-attr to ub.price-doc-forming-attr
    assign
      ub.price-doc-forming-attr.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-attr.plt-id      = p-plt-id
      ub.price-doc-forming-attr.pdf-db     = p-pdf-db-num
      ub.price-doc-forming-attr.pdf-id      = p-pdf-id
      .
end.
for each buf_price-doc-forming-gds no-lock where
         buf_price-doc-forming-gds.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_price-doc-forming-gds.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_price-doc-forming-gds.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_price-doc-forming-gds.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-gds.
    buffer-copy buf_price-doc-forming-gds to ub.price-doc-forming-gds
    assign
      ub.price-doc-forming-gds.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-gds.plt-id      = p-plt-id
      ub.price-doc-forming-gds.pdf-db      = p-pdf-db-num
      ub.price-doc-forming-gds.pdf-id      = p-pdf-id
    .
end.
for each buf_pd-forming-gds-attr no-lock where
         buf_pd-forming-gds-attr.pdf-db      = buf_price-doc-forming.pdf-db       and
         buf_pd-forming-gds-attr.pdf-id      = buf_price-doc-forming.pdf-id       and
         buf_pd-forming-gds-attr.plt-db-num  = buf_price-doc-forming.plt-db-num   and
         buf_pd-forming-gds-attr.plt-id      = buf_price-doc-forming.plt-id       :
    create ub.price-doc-forming-gdsattr.
    buffer-copy buf_pd-forming-gds-attr to ub.price-doc-forming-gdsattr
    assign
      ub.price-doc-forming-gdsattr.plt-db-num  = p-plt-db-num
      ub.price-doc-forming-gdsattr.plt-id      = p-plt-id
      ub.price-doc-forming-gdsattr.pdf-db      = p-pdf-db-num
      ub.price-doc-forming-gdsattr.pdf-id      = p-pdf-id
    .
end.
end procedure.
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
define variable vss-include-info28 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info29 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info30 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info31 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info32 as character format "X(65)" no-undo
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
define variable vss-include-info33 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info34 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info35 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output p-hostcode
  ) no-error .
define variable vss-include-info36 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_vat-pc
  ) no-error .
define variable vss-include-info37 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  buf-goods.gds-code
  ,input  '2':U
  ,input  ?
  ,input  p-hostcode
  ,input  buf-price-doc.obj-type
  ,input  buf-price-doc.obj-code
  ,output local_slt-pc
  ) no-error .
define variable vss-include-info38 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info39 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info40 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info41 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info42 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure ver-modificator-price-is-null :
 do
 on error undo, return error return-value
 :
define input parameter p-artic     like ub.goods.artic no-undo.
define input parameter p-prod-type like ub.goods.prod-type no-undo.
define input parameter p-prod-code like ub.goods.prod-code no-undo.
define input parameter p-obj-type  like ub.clients.obj-type no-undo.
define input parameter p-obj-code  like ub.clients.obj-code no-undo.
define output parameter p-ret as logical no-undo .
define variable v-gds-code  like ub.goods.gds-code no-undo .
define buffer buf_fbr-gds-obj for ub.fbr-gds-obj.
define variable vss-include-info43 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gds-code in g#library
  (input  p-artic
  ,input  p-prod-type
  ,input  p-prod-code
  ,output v-gds-code
  )  .
p-ret = true .
find first buf_fbr-gds-obj no-lock where
            buf_fbr-gds-obj.gds-code = v-gds-code and
            buf_fbr-gds-obj.obj-code = p-obj-code and
            buf_fbr-gds-obj.obj-type = p-obj-type use-index pi no-error .
 if available buf_fbr-gds-obj then
              if buf_fbr-gds-obj.is-modificator = true and
                 buf_fbr-gds-obj.is-null-price = true
                 then  p-ret = false .
 end.
end procedure.
define variable vss-include-info44 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info45 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table tt-level-dis-attr no-undo
      field attr-code   like global-state-attr.attr-code
      field attr-value  like global-state-attr.attr-value
      index pi   attr-value descending
      index pi1 is unique attr-value
            attr-code .
procedure lvldsc-byattr :
define input  parameter p-attr-code  as character no-undo .
define input  parameter p-attr-value as character no-undo .
define output parameter p-val1       as decimal   no-undo .
define output parameter p-val2       as decimal   no-undo .
define output parameter p-prc        as decimal   no-undo .
  do
  on error undo, return error return-value
  :
  define variable v-str1 as character no-undo .
  v-str1 = trim ( p-attr-code , 'level-discnt':U ) .
  v-str1 = trim ( v-str1 , chr(4) ) .
 run lvldsc-bytt (
      input   v-str1
    , input   p-attr-value
    , output  p-val1
    , output  p-val2
    , output  p-prc )
      no-error .
  end.
end procedure.
procedure lvldsc-bytt :
define input  parameter p-attr-code as character no-undo .
define input  parameter p-attr-value as character no-undo .
define output parameter p-val1 as decimal   no-undo .
define output parameter p-val2 as decimal   no-undo .
define output parameter p-prc  as decimal   no-undo .
define variable v-str1 as character no-undo .
  do
  on error undo, return error return-value
  :
  assign
     v-str1 = trim ( p-attr-code , "[]()" )
     p-val1 = decimal(entry(1,v-str1, ";"))
     p-val2 = decimal(entry(2,v-str1, ";"))
     p-prc  = decimal(p-attr-value)
     no-error
  .
  end.
end procedure.
procedure level-dis-value :
define input  parameter p-price-prod as decimal   no-undo .
define input  parameter p-b-code     as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-prc as decimal   no-undo .
define variable v-level-dis-attr as character no-undo .
define variable v-type as character no-undo .
define variable v-val1 as decimal   no-undo .
define variable v-val2 as decimal   no-undo .
define variable v-prc  as decimal   no-undo .
define variable ix     as integer   no-undo .
do
 on error undo, return error return-value
 :
define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .
run ggoattr-value (
   input   buf_goods.grp-code
  ,input   v-cntxt-host-code-obj
  ,input   p-obj-type
  ,input   p-obj-code
  ,input   'level-dis':U
  ,output  v-level-dis-attr
  ,output  v-type ) no-error .
repeat ix = 1 to num-entries (v-level-dis-attr, chr(4)) - 1 :
  create
    tt-level-dis-attr
  .
  tt-level-dis-attr.attr-code = entry (1, entry (ix, v-level-dis-attr, chr(4)), chr(44)) .
  tt-level-dis-attr.attr-value = entry (2, entry (ix, v-level-dis-attr, chr(4)), chr(44)) .
end.
p-prc = 0 .
  if p-price-prod = 0 then do:
      for each tt-level-dis-attr no-lock
              :
            run lvldsc-bytt (
              input   tt-level-dis-attr.attr-code
            , input   tt-level-dis-attr.attr-value
            , output  v-val1
            , output  v-val2
            , output  v-prc  )
            .
            if v-val1  = 0  then do:
               p-prc = v-prc .
              leave.
            end.
      end.
  end.
  else do:
      for each tt-level-dis-attr no-lock
              :
            run lvldsc-bytt (
              input   tt-level-dis-attr.attr-code
            , input   tt-level-dis-attr.attr-value
            , output  v-val1
            , output  v-val2
            , output  v-prc  )
            .
            if p-price-prod   > v-val1 and
               p-price-prod  <= v-val2 then do:
               p-prc = v-prc .
              leave.
            end.
      end.
  end.
for each tt-level-dis-attr no-lock. delete tt-level-dis-attr. end.
 end.
end procedure.
procedure calc-price-levelprod :
define input  parameter p-mode     as integer   no-undo .
define input  parameter p-rb       as character no-undo .
define input  parameter p-b-code   as integer   no-undo .
define input  parameter p-obj-type as character no-undo .
define input  parameter p-obj-code as integer   no-undo .
define output parameter p-price-sale as decimal   no-undo .
define output parameter p-descript-calc as character no-undo .
define variable  v-PriceWithoutVat as decimal   no-undo init 0.
define variable  v-PriceWithVat    as decimal   no-undo init 0.
define variable  v-prod-vat        as decimal   no-undo init 0.
define variable  v-discnt          as decimal   no-undo init 0.
define buffer buf_goods for ub.goods  .
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_parts for ub.parts  .
define variable v-part-code as character no-undo .
define variable v-in-code   as character no-undo .
  do
  on error undo, return error return-value
  :
define variable vss-include-info46 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  p-b-code
 , input  p-obj-type
 , input  p-obj-code
 , output v-PriceWithoutVat
 , output v-PriceWithVat
 , output v-prod-vat
 , output v-part-code
 , output v-in-code
        ) no-error .
      if error-status :error then do:
        return error "Нет цены производителя!".
      end.
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code
           no-error .
find first buf_goods no-lock where
           buf_goods.gds-code = buf_bar-code.gds-code
           no-error .
find first buf_parts no-lock where
           buf_parts.artic      = buf_goods.artic        and
           buf_parts.prod-type  = buf_goods.prod-type    and
           buf_parts.prod-code  = buf_goods.prod-code    and
           buf_parts.in-code    = buf_bar-code.in-code   and
           buf_parts.out-code   = buf_bar-code.in-code   and
           buf_parts.part-code  = buf_bar-code.part-code
           no-error .
            if error-status :error then do:
                find first buf_parts no-lock where
                          buf_parts.artic      = buf_goods.artic        and
                          buf_parts.prod-type  = buf_goods.prod-type    and
                          buf_parts.prod-code  = buf_goods.prod-code    and
                          buf_parts.in-code    = v-in-code              and
                          buf_parts.out-code   = v-in-code              and
                          buf_parts.part-code  = v-part-code
                          no-error .
                if error-status :error then do:
                   message
                    substitute("Нет цены производителя !  &1 &2&3&4&5"  ,
                                v-in-code,
                                v-part-code ,
                                buf_goods.artic   ,
                                buf_goods.prod-type,
                                buf_goods.prod-code ) .
                   return error "Нет цены производителя !!!".
                end.
            end.
run level-dis-value ( input (if p-mode = 2 then v-PriceWithoutVat else v-PriceWithVat) , input p-b-code, input p-obj-type, input p-obj-code, output v-discnt ) no-error .
define variable v-postWithoutVat-rubl as decimal   no-undo .
define variable v-postWithoutVat-base as decimal   no-undo .
   case p-mode :
    when 1 then do:
       if p-rb = "rubl" then do:
          p-price-sale = buf_parts.price-rubl + ( MINIMUM ( buf_parts.price-rubl , v-PriceWithVat ) * v-discnt / 100 ).
       end.
       else do:
          p-price-sale = buf_parts.price-base + ( MINIMUM ( v-PriceWithVat , buf_parts.price-base ) * v-discnt / 100 ).
       end.
    end.
    when 2 then do:
      if p-rb = "rubl" then do:
        v-postWithoutVat-rubl =  buf_parts.price-rubl - (buf_parts.price-rubl * buf_parts.vat-pc / (100 + buf_parts.vat-pc) ).
        p-price-sale = v-postWithoutVat-rubl + ( MINIMUM ( v-PriceWithoutVat , v-postWithoutVat-rubl ) * v-discnt / 100 ) .
      end.
      else do:
        v-postWithoutVat-base = buf_parts.price-base - (buf_parts.price-base * buf_parts.vat-pc / ( 100 + buf_parts.vat-pc) ) .
        p-price-sale = v-postWithoutVat-base + ( MINIMUM ( v-PriceWithoutVat, v-postWithoutVat-base) * v-discnt / 100 ) .
      end.
    end.
   end case.
p-descript-calc =
  string(p-mode) + '_Элементы расчета: ' +  chr(10)  +
  buf_goods.gds-name                  +  chr(10) +
  buf_goods.artic +
  buf_goods.prod-type +
  string(buf_goods.prod-code)         + chr(10) +
  "бар-код " +  string(p-b-code)      + chr(10)  +
  'ПН    ' + v-in-code  +
  ' серия ' + v-part-code             +  chr(10)  + chr(10) +
  'Цена поставщика без ндс    '  + string((buf_parts.price-rubl - (buf_parts.price-rubl * buf_parts.vat-pc / (100 + buf_parts.vat-pc) ) ))  + chr(10) +
  'Цена поставщика   c ндс    '  + string ( buf_parts.price-rubl )  + chr(10) +
  'Цена производителя без ндс ' +  string( v-PriceWithoutVat)       + chr(10) +
  'Цена производителя   c ндс ' +  string( v-PriceWithVat  )        + chr(10) +
  chr(10) +
  "% пороговой наценки        "  + string(v-discnt)                 + chr(10) +
  chr(10) +
  "сумма наценки от произв без ндс "  + string( v-PriceWithoutVat * v-discnt / 100 ) +  chr(10) +
  "сумма наценки от произв   с ндс "  + string( v-PriceWithVat * v-discnt / 100 )    +  chr(10)  +
  chr(10) +
  string(p-price-sale)                                                               +  chr(10) +
  (if p-mode = 1 then substitute("ПорогПр+НДС  &1 + ( min(&2или &1) * &3 / 100 )  = &4 " , buf_parts.price-rubl , v-PriceWithVat , v-discnt , p-price-sale)
  else                substitute("ПорогПр-НДС  &1 - ( &1 * &2 / 100 ) + ( min(&3 или &6 ) * &4 / 100 ) = &5 и еще накручивается НДС " , buf_parts.price-rubl , buf_parts.vat-pc , v-PriceWithoutVat , v-discnt , p-price-sale , v-postWithoutVat-rubl))
.
  end.
end procedure.
define variable vss-include-info47 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable v-str1 as character no-undo .
FUNCTION fnc-base-price-doc RETURN decimal
  ( local-bc as integer, p-recid as recid ).
define buffer   base-price       for ub.price-doc-forming-gds .
define variable local-main-code like ub.bar-code.b-code no-undo.
define variable local-base-code like ub.bar-code.b-code no-undo.
define buffer   buf_main-pdf     for ub.price-doc-forming .
find first buf_main-pdf no-lock where recid (buf_main-pdf) = p-recid .
  run prc-base-code in this-procedure (input local-bc, output local-base-code).
  find base-price no-lock where
       base-price.pdf-id = buf_main-pdf.pdf-id and
       base-price.pdf-db = buf_main-pdf.pdf-db and
       base-price.plt-id = buf_main-pdf.plt-id and
       base-price.plt-db-num = buf_main-pdf.plt-db-num and
       base-price.b-code  = local-base-code
       no-error.
  if not available base-price then do:
    run prc-main-code in this-procedure
       ( input local-bc, output local-main-code ).
    find  base-price no-lock where
          base-price.pdf-id = buf_main-pdf.pdf-id and
          base-price.pdf-db = buf_main-pdf.pdf-db and
          base-price.plt-id = buf_main-pdf.plt-id and
          base-price.plt-db-num = buf_main-pdf.plt-db-num and
          base-price.b-code  = local-main-code
          no-error.
  end.
  if available base-price then
    return (base-price.price-sale-doc).
  else
    return (?).
END FUNCTION.
procedure set-price-line :
  do
  on error undo, return error return-value
  :
define input  parameter p-plt-id as integer   no-undo .
define input  parameter p-plt-db as integer   no-undo .
define input  parameter  p-calc-method      as character no-undo .
define input  parameter  p-increase-pc      as decimal   no-undo .
define input  parameter  p-round-method     as character no-undo .
define input  parameter  p-round-base       as decimal   no-undo .
define input  parameter  p-b-code           as integer   no-undo .
define input  parameter  p-gds-code         as integer   no-undo .
define input  parameter  p-artic            as character no-undo .
define input  parameter  p-prod-type        as character no-undo .
define input  parameter  p-prod-code        as integer   no-undo .
define input  parameter  p-base-rate        as decimal   no-undo .
define input  parameter  p-base-scale       as decimal   no-undo .
define input  parameter  p-exch-scale       as decimal   no-undo .
define input  parameter  p-exch-rate        as decimal   no-undo .
define input  parameter  v-doc-code         as character no-undo .
define input  parameter  common-price       as decimal   no-undo .
define input  parameter  v-copy-type        as character no-undo .
define input  parameter  v-copy-code        as integer   no-undo .
define output parameter  p-new-calc-method  as character no-undo .
define output parameter  p-price-calc-base  as decimal   no-undo .
define output parameter  p-price-calc-doc   as decimal   no-undo .
define output parameter  p-price-calc-rubl  as decimal   no-undo .
define output parameter  p-price-prev-base  as decimal   no-undo .
define output parameter  p-price-prev-doc   as decimal   no-undo .
define output parameter  p-price-prev-rubl  as decimal   no-undo .
define output parameter  p-price-sale-base  as decimal   no-undo .
define output parameter  p-price-sale-doc   as decimal   no-undo .
define output parameter  p-price-sale-rubl  as decimal   no-undo .
define output parameter  p-road-tax-base    as decimal   no-undo .
define output parameter  p-road-tax-doc     as decimal   no-undo .
define output parameter  p-road-tax-rubl    as decimal   no-undo .
define output parameter  p-excise-base      as decimal   no-undo .
define output parameter  p-excise-doc       as decimal   no-undo .
define output parameter  p-excise-rubl      as decimal   no-undo .
define output parameter  p-vat-pc           as decimal   no-undo .
define output parameter  p-slt-pc           as decimal   no-undo .
define output parameter  p-prev-doc-code    as character no-undo .
define output parameter  p-d-pcnt           as decimal   no-undo .
define variable cost-base    as decimal   no-undo .
define variable cost-rubl    as decimal   no-undo .
define variable cur-rt-base  as decimal   no-undo .
define variable cur-rt-rubl  as decimal   no-undo .
define variable local_vat-pc as decimal   no-undo .
define variable local_slt-pc as decimal   no-undo .
define variable new_vat-pc   as character no-undo  init "".
define variable new_slt-pc   as character no-undo  init "".
define variable new_round    as character no-undo  init "".
define variable loc_round    as character no-undo  init "".
define variable v-hostcode   as integer   no-undo .
define variable v-plt-id       as integer   no-undo .
define variable v-plt-db-num   as integer   no-undo .
define variable v-pdf-id       as integer   no-undo .
define variable v-pdf-db-num   as integer   no-undo .
define variable v-plt-id2      as integer   no-undo .
define variable v-plt-db-num2  as integer   no-undo .
define variable v1-recid       as recid no-undo .
define variable v1-cur-rt      as decimal   no-undo .
define variable v1-cur-ex      as decimal   no-undo .
define variable v1 as integer   no-undo .
define variable v2 as integer   no-undo .
define variable v3 as integer   no-undo .
define variable v4 as integer   no-undo .
define variable vd as decimal   no-undo .
define variable v-PriceWithVat as decimal   no-undo .
define variable v-PriceWithoutVat as decimal   no-undo .
define variable v-prod-vat     as decimal   no-undo .
define variable v-descript as character no-undo .
define buffer prev-list                     for ub.price-list  .
define buffer buf_price-list-type           for ub.price-list-type  .
define buffer buf_buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer b_price-doc-forming-gds       for ub.price-doc-forming-gds  .
define buffer b_price-doc-forming           for ub.price-doc-forming  .
define buffer buf_gds-obj                   for ub.gds-obj  .
define buffer buf_trn-doc                   for ub.trn-doc  .
define buffer buf_doc-line                  for ub.doc-line  .
define buffer buf_bar-code                  for ub.bar-code  .
define buffer buf_gds-dtl                   for ub.gds-dtl  .
define buffer buf-goods                     for ub.goods  .
define buffer buf-gds-grp                   for ub.gds-grp  .
define variable loc-increase-pc       as decimal   no-undo .
define variable loc-grp-increase-pc   as decimal   no-undo .
define variable loc-grp-round-method  as character no-undo .
define variable loc-grp-round-base    as decimal   no-undo .
define variable p-prc-min             as decimal   no-undo .
define variable p-prc-max             as decimal   no-undo .
define variable p-value-margin        as integer   no-undo.
define variable p-type-margin         as logical   no-undo .
define variable p-value-increase      as integer   no-undo.
define variable p-type-increase       as logical   no-undo .
define variable p-value-rmethod       as integer   no-undo.
define variable p-type-rmethod        as logical   no-undo .
define variable loc-rez               as character no-undo .
define variable t-type                as character no-undo .
define variable g-g                   as logical   no-undo .
define variable var-pr-r-b as character no-undo .
define variable v-base as logical   no-undo .
define variable vss-include-info48 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  ) no-error .
if error-status :error then do:
   message
     error-status :get-message(1) skip
     return-value skip
     "rbisbase"
     view-as alert-box error
   .
end.
for each  x_obj-group :
define variable vss-include-info49 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-increase-pc in g#library
  (input  p-gds-code
  ,input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output  loc-increase-pc
  ) no-error .
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка метода поиска наценки товара на объекте" skip
     error-status :get-message(1) .
  end.
run gds-attr-margin-value
( input   p-gds-code           ,
  input   x_obj-group.obj-type ,
  input   x_obj-group.obj-code ,
  output  p-prc-min            ,
  output  p-prc-max            ,
  output  loc-grp-increase-pc  ,
  output  loc-grp-round-method ,
  output  loc-grp-round-base   ,
  output  p-value-margin       ,
  output  p-type-margin        ,
  output  p-value-increase     ,
  output  p-type-increase      ,
  output  p-value-rmethod      ,
  output  p-type-rmethod
  ) no-error .
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка процедуры поиска наценки по группе товара на объекте" skip
     error-status :get-message(1) .
  end.
  g-g = false .
  find first buf-goods no-lock where buf-goods.gds-code =  p-gds-code no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  case p-calc-method:
    when 'Единая':U or
    when 'Отсутствует':U or
    when 'Не-считать':U or
    when 'Откат_цен':U
    then do:
       p-increase-pc  = 0  .
       p-round-method = 'Отключено':U .
    end.
    when 'Товар':U then do:
      case buf-goods.calc-method:
        when 'Группа':U then do:
          find buf-gds-grp no-lock where
               buf-gds-grp.node-code = buf-goods.grp-code.
           assign
            p-increase-pc  = loc-grp-increase-pc
            p-round-method = loc-grp-round-method
            p-round-base   = loc-grp-round-base
            g-g = true
           .
        end.
        otherwise do:
           p-increase-pc  =  loc-increase-pc .
        end.
      end case.
      if g-g = false then do:
          run gdsoattr-value
             ( input 'round-method':U ,
               input p-gds-code ,
               input x_obj-group.obj-type ,
               input x_obj-group.obj-code ,
               output loc-rez ,
               output t-type
               ) no-error  .
              if error-status :error then message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                "gdsoattr-value"
                view-as alert-box error .
          case NUM-ENTRIES (loc-rez," ") :
              when 0 then do:
              end.
              when 1 then do:
                p-round-method = loc-rez .
                p-round-base   = 0 .
              end.
              when 2 then do:
                p-round-method = entry(1 , loc-rez, " " ).
                p-round-base   = decimal(entry(2 , loc-rez, " " )) .
              end.
              otherwise do:
                p-round-method = entry(1 , loc-rez, " " ).
                p-round-base   = decimal(entry(NUM-ENTRIES (loc-rez," ") , loc-rez, " " )) .
              end.
          end case.
      end.
    end.
  end case.
define variable vss-include-info50 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output v-hostcode
  ) no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "hostcode"
        view-as alert-box error
      .
define variable vss-include-info51 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  p-gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-hostcode
  ,input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output local_vat-pc
  ) no-error .
     if error-status :error then message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "НДС"
       view-as alert-box error
     .
define variable vss-include-info52 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  p-gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-hostcode
  ,input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output local_slt-pc
  ) no-error .
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "НсП"
      view-as alert-box error
    .
    new_slt-pc = new_slt-pc + string(local_slt-pc) + chr(4) .
    new_vat-pc = new_vat-pc + string(local_vat-pc) + chr(4) .
    new_round  = new_round  + string(p-increase-pc) + "% " +  string(p-round-method) + "^" +  string(p-round-base)   + chr(4) .
    loc_round  = string(p-increase-pc) + "% " +  string(p-round-method) + "^" +  string(p-round-base)  .
    find current buf_price-doc-forming no-lock no-error .
    if not available buf_price-doc-forming then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "qqqqqqqq"
       view-as alert-box error
     .
    end.
end.
assign
  v-plt-id     = p-plt-id
  v-plt-db-num = p-plt-db
  p-new-calc-method = p-calc-method
.
run re-define in this-procedure (
    input-output p-calc-method
  , input p-gds-code
  ) no-error .
  if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "re-define"
       view-as alert-box error
     .
  end.
  define variable v-sps as character no-undo .
v-sps =
 "Товар,
Группа,
Учетная,
Учет-объект,
Учет-резерв,
Приходная,
Прих-объект,
Начальная,
Старая,
Новая,
Объект,
Накладная,
Накл-безНДС,
Учет-безНДС,
Стар-безНДС,
Переоценка,
ДокФормЦены,
Отсутствует,
Признак,
Специальная,
Не-считать,
Основная,
Единая,
Учет+накл,
Уч+накл-НДС,
НсП,
НсП+накл,
УчетнаяS,
Учет-рзрвS,
ПриходнаяS,
Учет-НДСS,
Производит,
Произв-НДС,
ПорогПр-НДС,
ПорогПр+НДС,
Откат_цен"
  .
if lookup ( p-calc-method , v-sps )  = 0 then  do:
    p-calc-method = entry (1,p-calc-method, " ") no-error .
    if error-status :error then message p-calc-method.
end.
define variable v-i as integer   no-undo init 0.
  for each  x_obj-group :
      v-i = v-i + 1.
      if entry( v-i, new_round , chr(4) ) <> string ( loc_round ) then do:
          message "На выбранных объектах используются разные параметры Наценки и округления ! Для расчета выбран" string ( loc_round ) skip "для товара  "
          skip
          "код     :" p-gds-code  skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic     skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.
      if entry( v-i, new_vat-pc , chr(4) ) <> string ( local_vat-pc ) then do:
          message "На выбранных объектах используются разные НДС ! Для расчета выбран" string ( local_vat-pc ) "%" skip "для товара  "
          skip
          "код     :" p-gds-code  skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic     skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.
      if entry( v-i, new_slt-pc , chr(4) ) <> string ( local_slt-pc ) then do:
          message "На выбранных объектах используются разные НсП ! Для расчета выбран" string ( local_slt-pc )
          skip
          "код     :" p-gds-code   skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic             skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.
  end.
assign
  p-vat-pc  = local_vat-pc
  p-slt-pc  = local_slt-pc
.
find first buf_price-list-type no-lock where
           buf_price-list-type.plt-id     = v-plt-id    and
           buf_price-list-type.plt-db-num = v-plt-db-num
           no-error .
   if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "q5"
      view-as alert-box error
    .
   return error return-value .
   end.
define variable vss-include-info53 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-mpl in g#library2
  (input  buf_price-list-type.gop-id
  ,input  buf_price-list-type.gop-db-num
  ,input  p-b-code
  ,input  0
  ,input  0
  ,output v1-recid
  ,output p-price-prev-doc
  ,output v1-cur-rt
  ,output v1-cur-ex
  ) no-error .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "bc-mpl"
      view-as alert-box error
    .
define buffer old1_price-doc-forming     for ub.price-doc-forming  .
define buffer old1_price-doc-forming-gds for ub.price-doc-forming-gds  .
find first old1_price-doc-forming no-lock where
           recid(old1_price-doc-forming) = v1-recid no-error .
find first old1_price-doc-forming-gds no-lock where
           old1_price-doc-forming-gds.pdf-db      = old1_price-doc-forming.pdf-db      and
           old1_price-doc-forming-gds.pdf-id      = old1_price-doc-forming.pdf-id      and
           old1_price-doc-forming-gds.plt-db-num  = old1_price-doc-forming.plt-db-num  and
           old1_price-doc-forming-gds.plt-id      = old1_price-doc-forming.plt-id      and
           old1_price-doc-forming-gds.b-code      = p-b-code
           no-error .
if available old1_price-doc-forming-gds then do:
   p-d-pcnt = old1_price-doc-forming-gds.d-pcnt .
end.
else do:
  p-d-pcnt = 0 .
end.
case p-calc-method :
   when 'Новая':U or
   when 'Не-считать':U then do:
    assign
      p-new-calc-method = p-calc-method
      cost-rubl = ?
      cost-base = ?
    .
      if available buf_price-doc-forming then do:
        assign
          v-pdf-id      = buf_price-doc-forming.pdf-id
          v-pdf-db-num  = buf_price-doc-forming.pdf-db
          v-plt-id2     = buf_price-doc-forming.plt-id
          v-plt-db-num2 = buf_price-doc-forming.plt-db-num
        .
        find first buf_buf_price-doc-forming-gds no-lock where
              buf_buf_price-doc-forming-gds.pdf-id =  v-pdf-id and
              buf_buf_price-doc-forming-gds.pdf-db =  v-pdf-db-num and
              buf_buf_price-doc-forming-gds.plt-id =  v-plt-id2     and
              buf_buf_price-doc-forming-gds.plt-db-num =  v-plt-db-num2 and
              buf_buf_price-doc-forming-gds.b-code =  p-b-code
              no-error .
            if available buf_buf_price-doc-forming-gds then do:
                assign
                  cost-rubl = buf_buf_price-doc-forming-gds.price-sale-rubl
                  cost-base = buf_buf_price-doc-forming-gds.price-sale-base
                .
            end.
      end.
   end.
   when 'УчетнаяS':U  or
   when 'Учет-рзрвS':U  or
   when 'ПриходнаяS':U
   then do:
      run str/sgdsavrg.p
      (   input  p-calc-method    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
   end.
   when 'Учет-НДСS':U or
   when 'Накл-безНДС':U or
   when 'Стар-безНДС':U or
   when 'Старая':U or
   when 'Учет+накл':U or
   when 'Уч+накл-НДС':U or
   when 'Откат_цен':U then do:
      run str/mplnovat.p
        ( input  p-calc-method    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          input  0 ,
          input  v-doc-code ,
          input  p-vat-pc      ,
          input  p-slt-pc      ,
          output vd  ,
          output vd  ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
   end.
   when 'Накладная':U then do:
        find first buf_trn-doc no-lock where buf_trn-doc.doc-code = v-doc-code no-error .
        find first buf_doc-line  no-lock where
                  buf_doc-line.doc-code = v-doc-code      and
                  buf_doc-line.artic    = p-artic         and
                  buf_doc-line.prod-type   = p-prod-type  and
                  buf_doc-line.prod-code   = p-prod-code no-error .
        find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
        find first buf_gds-dtl no-lock where
                   buf_gds-dtl.doc-code  = v-doc-code   and
                   buf_gds-dtl.artic     = p-artic      and
                   buf_gds-dtl.prod-type = p-prod-type  and
                   buf_gds-dtl.prod-code = p-prod-code  and
                   buf_gds-dtl.prt-code  = buf_bar-code.node-code no-error .
        assign
          v1 = recid (buf_trn-doc)
          v2 = recid (buf_doc-line)
          v3 = recid (buf_gds-dtl)
          v4  = buf_gds-dtl.prt-code
          no-error .
          if not v-base then do:
            run str/pr-wbil.p
            ( input "pr-doc"            ,
              input 'Накладная':U ,
              input v1               ,
              input v2               ,
              input v3               ,
              input v-doc-code       ,
              input ""               ,
              input p-gds-code       ,
              input p-artic          ,
              input p-prod-type      ,
              input p-prod-code      ,
              input v4               ,
              input 0                ,
              input (if buf_trn-doc.ext-doc-type = 'ie':U then buf_doc-line.price-rubl else buf_gds-dtl.price-rubl ) ,
              input (if buf_trn-doc.ext-doc-type = 'ie':U then buf_doc-line.price-base else buf_gds-dtl.price-base ) ,
              output cost-rubl       ,
              output v4
              ) no-error .
          end.
          else do:
            run str/pr-wbil.p
            ( input "pr-doc"            ,
              input 'Накладная':U ,
              input v1               ,
              input v2               ,
              input v3               ,
              input v-doc-code       ,
              input ""               ,
              input p-gds-code       ,
              input p-artic          ,
              input p-prod-type      ,
              input p-prod-code      ,
              input v4               ,
              input 0                ,
              input (if buf_trn-doc.ext-doc-type = 'ie':U then buf_doc-line.price-rubl else buf_gds-dtl.price-rubl ) ,
              input (if buf_trn-doc.ext-doc-type = 'ie':U then buf_doc-line.price-base else buf_gds-dtl.price-base ) ,
              output cost-base       ,
              output v4
              ) no-error .
          end.
          if not error-status :error then
              assign
                p-new-calc-method = 'Накладная':U + " " + v-doc-code
             .
    end.
    when 'Переоценка':U then do:
      find prev-list where
           prev-list.b-code     = p-b-code and
           prev-list.price-type = "" and
           prev-list.doc-num    = v-doc-code no-lock no-error.
      if available prev-list then
        assign
          p-new-calc-method = 'Переоценка':U + " " + v-doc-code
          cur-rt-base = prev-list.road-tax
          cur-rt-rubl = prev-list.road-tax
          cost-rubl = prev-list.price-sale
          cost-base = prev-list.price-sale
          .
      else
        message "Нет строки в переоценке :" v-doc-code "для товара :" p-artic
                "- расчет невозможен."
                view-as alert-box information .
    end.
    when 'ДокФормЦены':U then do:
    find first b_price-doc-forming no-lock where
               b_price-doc-forming.pdf-id     = integer(entry(1,v-doc-code,"|")) and
               b_price-doc-forming.pdf-db     = integer(entry(2,v-doc-code,"|"))
               no-error .
      find b_price-doc-forming-gds no-lock where
           b_price-doc-forming-gds.b-code     = p-b-code and
           b_price-doc-forming-gds.plt-db-num = b_price-doc-forming.plt-db-num and
           b_price-doc-forming-gds.plt-id     = b_price-doc-forming.plt-id and
           b_price-doc-forming-gds.pdf-id     = b_price-doc-forming.pdf-id and
           b_price-doc-forming-gds.pdf-db     = b_price-doc-forming.pdf-db
           no-error.
      if available b_price-doc-forming-gds then
        assign
          p-new-calc-method = 'ДокФормЦены':U + " " + v-doc-code
          cur-rt-base = b_price-doc-forming-gds.road-tax-base
          cur-rt-rubl = b_price-doc-forming-gds.road-tax-rubl
          cost-rubl   = b_price-doc-forming-gds.price-sale-rubl
          cost-base   = b_price-doc-forming-gds.price-sale-base
          .
      else
        message "Нет строки в ДНЦ :" integer(entry(1,v-doc-code,"|")) integer(entry(2,v-doc-code,"|")) skip
                "для товара :" skip
                 "Бар-код" p-b-code     skip
                 "Артикул" p-artic      skip
                  p-prod-type  skip
                  p-prod-code  skip
                "- расчет невозможен."
                view-as alert-box information .
    end.
    when 'Единая':U then do:
        assign
          p-new-calc-method = 'Единая':U + " " + string(common-price)
          cost-rubl = common-price
          cost-base = common-price
          .
    end.
    when 'Объект':U then do:
    find first buf_gds-obj no-lock where
               buf_gds-obj.gds-code = p-gds-code and
               buf_gds-obj.obj-type = v-copy-type and
               buf_gds-obj.obj-code = v-copy-code no-error .
        if available buf_gds-obj then do:
        assign
          p-new-calc-method = 'Объект':U + " " + v-copy-type + string(v-copy-code)
          cost-rubl = buf_gds-obj.price-sale
          cost-base = buf_gds-obj.price-sale
          .
        end.
        else do:
            message "Нет товара на объекте :" v-copy-type v-copy-code skip
                    "для товара :" p-artic  "- расчет невозможен."
                    view-as alert-box information .
        end.
    end.
   when 'Отсутствует':U or
   when "" then do:
      run str/mplnovat.p
        ( input  'Отсутствует':U    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          input  0 ,
          input  v-doc-code ,
          input  p-vat-pc      ,
          input  p-slt-pc      ,
          output vd  ,
          output vd  ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
          cost-rubl = vd * p-exch-rate / p-exch-scale .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = 'Отсутствует':U .
   end.
   when 'Основная':U then do:
   end.
  when 'ПорогПр-НДС':U then do:
    message 1.
  end.
  when 'ПорогПр+НДС':U then do:
    message 2.
  end.
  when 'Производит':U
     then do:
      find first x_obj-group .
define variable vss-include-info54 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  p-b-code
 , input  x_obj-group.obj-type
 , input  x_obj-group.obj-code
 , output v-PriceWithVat
 , output vd
 , output v-prod-vat
 , output v-str1
 , output v-str1
        ) no-error .
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара :" p-artic  p-b-code
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#2" update g#log as logical .
      end.
      else do:
          cost-rubl = vd * p-exch-rate / p-exch-scale .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
      end.
  end.
  when 'Произв-НДС':U
    then do:
      find first x_obj-group .
define variable vss-include-info55 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  p-b-code
 , input  x_obj-group.obj-type
 , input  x_obj-group.obj-code
 , output vd
 , output v-PriceWithVat
 , output v-prod-vat
 , output v-str1
 , output v-str1
        ) no-error .
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара :" p-artic  p-b-code
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box .
      end.
      else do:
          cost-rubl = vd * p-exch-rate / p-exch-scale .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
      end.
    end.
   otherwise do:
     message  "Не просчитывается метод p-calc-method = " p-calc-method  skip
               p-new-calc-method  skip
              "p-price-prev-doc " p-price-prev-doc  skip
              "mpl-lib ERR !!! " skip
              'артикул ' p-artic skip
              view-as alert-box information .
   end.
 end case.
run main-road-taxs in this-procedure
  ( input p-artic     ,
    input p-prod-type ,
    input p-prod-code ,
    input-output cur-rt-base ,
    input-output cur-rt-rubl )
    no-error .
    if error-status :error then do:
       message
         error-status :get-message(1) skip
         return-value skip
         "main-road-taxs"
         view-as alert-box error
       .
    end.
  if p-exch-scale = 0  or  p-exch-scale = ?  then do:
    return error "Не определен курс валюты документа" .
  end.
  if p-base-scale = 0  or  p-base-scale = ?  then do:
     return error "Не определен курс базовой валюты " .
  end.
if v-base = false then var-pr-r-b = "rubl":U .
                  else var-pr-r-b =  "base":U .
    if var-pr-r-b = "rubl":U then do:
        case p-calc-method :
         when 'ПорогПр-НДС':U then do:
            message 3.
         end.
         when 'ПорогПр+НДС':U then do:
             message 4.
         end.
         when 'Производит':U then do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100)   .
         end.
         when 'Произв-НДС':U then do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100) * (1 +  p-vat-pc / 100)  .
         end.
         otherwise do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100) .
         end.
        end case.
        assign
          p-price-calc-rubl  =  cost-rubl
          p-road-tax-rubl    =  cur-rt-rubl
          p-price-calc-doc   =  p-price-calc-rubl / p-exch-rate * p-exch-scale
          p-price-sale-doc   =  p-price-sale-rubl / p-exch-rate * p-exch-scale
          p-road-tax-doc     =  p-road-tax-rubl   / p-exch-rate * p-exch-scale
        .
    end.
    else dO:
         case p-calc-method :
         when 'ПорогПр-НДС':U then do:
            message 5.
         end.
         when 'ПорогПр+НДС':U then do:
             message 6.
         end.
         when 'Производит':U then do:
            p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100) .
         end.
         when 'Произв-НДС':U then do:
            p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100) * (1 + p-vat-pc / 100)  .
         end.
         otherwise do:
            p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100) .
         end.
         end case.
        assign
          p-price-calc-base  =  cost-base
          p-road-tax-base    =  cur-rt-base
          p-price-calc-rubl  =  p-price-calc-base * p-base-rate / p-base-scale
          p-price-sale-rubl  =  p-price-sale-base * p-base-rate / p-base-scale
          p-road-tax-rubl    =  p-road-tax-base   * p-base-rate / p-base-scale
          p-price-calc-doc   =  p-price-calc-rubl / p-exch-rate * p-exch-scale
          p-price-sale-doc   =  p-price-sale-rubl / p-exch-rate * p-exch-scale
          p-road-tax-doc     =  p-road-tax-rubl   / p-exch-rate * p-exch-scale
        .
    end.
case p-round-method :
  when '9-окончание':U then do:
    if p-price-sale-doc < 29 then do:
      if (p-price-sale-doc - truncate (p-price-sale-doc, 0)) <> 0 then do:
        assign
          p-price-sale-doc = truncate (p-price-sale-doc, 0) + 1
        .
      end.
    end.
    else do:
      if (p-price-sale-doc modulo 10) < 3 then do:
        assign
          p-price-sale-doc = (p-price-sale-doc - (p-price-sale-doc modulo 100))
              + ( truncate (((p-price-sale-doc modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          p-price-sale-doc = (p-price-sale-doc - (p-price-sale-doc modulo 100))
              + ( truncate (((p-price-sale-doc modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        p-price-sale-doc = round (p-price-sale-doc, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if p-price-sale-doc < p-round-base then do:
      assign
        p-price-sale-doc = truncate (p-price-sale-doc, 0) + 0.99
      .
    end.
    else do:
      assign
        p-price-sale-doc = truncate (p-price-sale-doc / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      p-price-sale-doc = round (p-price-sale-doc, 0)
    .
  end.
  when 'Произвольно':U then do:
    if p-round-base <> 0 then do:
      assign
        p-price-sale-doc = round (p-price-sale-doc / p-round-base, 0) * p-round-base
      .
      if p-price-sale-doc = 0 then do:
        assign
          p-price-sale-doc = p-round-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if p-round-base <> 0 then do:
      if truncate ( p-price-sale-doc / p-round-base, 0 ) <> (p-price-sale-doc / p-round-base) then do:
        assign
          p-price-sale-doc = truncate (p-price-sale-doc / p-round-base, 0) * p-round-base + p-round-base
        .
      end.
    end.
    if p-price-sale-doc = 0 then do:
      assign
        p-price-sale-doc = p-round-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if p-round-base <> 0 then do:
      assign
        p-price-sale-doc = p-price-sale-doc * p-round-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" p-round-method skip
      "round-base"   p-round-base   skip
      "price"        p-price-sale-doc             skip
      view-as alert-box error .
  end.
end.
    if error-status :error then do:
    message
      error-status :get-message(1) skip
      return-value skip
      "pr-99"
      view-as alert-box error
    .
    end.
  p-price-calc-rubl = p-price-calc-doc * p-exch-rate / p-exch-scale .
  p-price-sale-rubl = p-price-sale-doc * p-exch-rate / p-exch-scale .
  p-road-tax-rubl   = p-road-tax-doc   * p-exch-rate / p-exch-scale .
  p-price-prev-rubl = p-price-prev-doc * p-exch-rate / p-exch-scale .
  p-price-calc-base = p-price-calc-rubl / p-base-rate * p-base-scale .
  p-price-sale-base = p-price-sale-rubl / p-base-rate * p-base-scale .
  p-road-tax-base   = p-road-tax-rubl   / p-base-rate * p-base-scale .
  p-price-prev-base = p-price-prev-rubl / p-base-rate * p-base-scale .
  define buffer bufold_price-doc-forming for ub.price-doc-forming  .
  find first bufold_price-doc-forming where  recid(bufold_price-doc-forming) = v1-recid no-lock no-error .
  p-prev-doc-code = if available bufold_price-doc-forming
                       then (string(bufold_price-doc-forming.pdf-id) + " БД" + string(bufold_price-doc-forming.pdf-db))
                       else "" .
  end.
end procedure.
PROCEDURE calc-price-line :
define input  parameter  p-calc-method      as character no-undo .
define input  parameter  p-increase-pc      as decimal   no-undo .
define input  parameter  p-round-method     as character no-undo .
define input  parameter  p-round-base       as decimal   no-undo .
define input  parameter  p-b-code           as integer   no-undo .
define input  parameter  p-gds-code         as integer   no-undo .
define input  parameter  p-artic            as character no-undo .
define input  parameter  p-prod-type        as character no-undo .
define input  parameter  p-prod-code        as integer   no-undo .
define input  parameter  p-base-rate        as decimal   no-undo .
define input  parameter  p-base-scale       as decimal   no-undo .
define input  parameter  p-exch-scale       as decimal   no-undo .
define input  parameter  p-exch-rate        as decimal   no-undo .
define input  parameter  v-doc-code         as character no-undo .
define input  parameter  common-price       as decimal   no-undo .
define input  parameter  v-copy-type        as character no-undo .
define input  parameter  v-copy-code        as integer   no-undo .
define output parameter  p-new-calc-method  as character no-undo .
define output parameter  p-price-calc-base  as decimal   no-undo .
define output parameter  p-price-calc-doc   as decimal   no-undo .
define output parameter  p-price-calc-rubl  as decimal   no-undo .
define output parameter  p-price-prev-base  as decimal   no-undo .
define output parameter  p-price-prev-doc   as decimal   no-undo .
define output parameter  p-price-prev-rubl  as decimal   no-undo .
define output parameter  p-price-sale-base  as decimal   no-undo .
define output parameter  p-price-sale-doc   as decimal   no-undo .
define output parameter  p-price-sale-rubl  as decimal   no-undo .
define output parameter  p-road-tax-base    as decimal   no-undo .
define output parameter  p-road-tax-doc     as decimal   no-undo .
define output parameter  p-road-tax-rubl    as decimal   no-undo .
define output parameter  p-excise-base      as decimal   no-undo .
define output parameter  p-excise-doc       as decimal   no-undo .
define output parameter  p-excise-rubl      as decimal   no-undo .
define output parameter  p-vat-pc           as decimal   no-undo .
define output parameter  p-slt-pc           as decimal   no-undo .
define output parameter  p-prev-doc-code    as character no-undo .
define output parameter  p-d-pcnt           as decimal   no-undo .
define variable cost-base    as decimal   no-undo .
define variable cost-rubl    as decimal   no-undo .
define variable cur-rt-base  as decimal   no-undo .
define variable cur-rt-rubl  as decimal   no-undo .
define variable local_vat-pc as decimal   no-undo .
define variable local_slt-pc as decimal   no-undo .
define variable new_vat-pc   as character no-undo  init "".
define variable new_slt-pc   as character no-undo  init "".
define variable new_round    as character no-undo  init "".
define variable loc_round    as character no-undo  init "".
define variable v-hostcode   as integer   no-undo .
define variable v-plt-id       as integer   no-undo .
define variable v-plt-db-num   as integer   no-undo .
define variable v-pdf-id       as integer   no-undo .
define variable v-pdf-db-num   as integer   no-undo .
define variable v-plt-id2      as integer   no-undo .
define variable v-plt-db-num2  as integer   no-undo .
define variable v1-recid       as recid no-undo .
define variable v1-cur-rt      as decimal   no-undo .
define variable v1-cur-ex      as decimal   no-undo .
define variable v1 as integer   no-undo .
define variable v2 as integer   no-undo .
define variable v3 as integer   no-undo .
define variable v4 as integer   no-undo .
define variable vd as decimal   no-undo .
define variable v-descript as character no-undo .
define buffer prev-list                     for ub.price-list  .
define buffer buf_price-list-type           for ub.price-list-type  .
define buffer buf_buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer b_price-doc-forming-gds       for ub.price-doc-forming-gds  .
define buffer b_price-doc-forming           for ub.price-doc-forming  .
define buffer buf_gds-obj                   for ub.gds-obj  .
define buffer buf_trn-doc                   for ub.trn-doc  .
define buffer buf_doc-line                  for ub.doc-line  .
define buffer buf_bar-code                  for ub.bar-code  .
define buffer buf_gds-dtl                   for ub.gds-dtl  .
define buffer buf-goods                     for ub.goods  .
define buffer buf-gds-grp                   for ub.gds-grp  .
define buffer buf_contract-specif           for ub.contract-specif .
define buffer buf_contract                  for ub.contract .
define variable loc-increase-pc       as decimal   no-undo .
define variable loc-grp-increase-pc   as decimal   no-undo .
define variable loc-grp-round-method  as character no-undo .
define variable loc-grp-round-base    as decimal   no-undo .
define variable p-prc-min             as decimal   no-undo .
define variable p-prc-max             as decimal   no-undo .
define variable p-value-margin        as integer   no-undo.
define variable p-type-margin         as logical   no-undo .
define variable p-value-increase      as integer   no-undo.
define variable p-type-increase       as logical   no-undo .
define variable p-value-rmethod       as integer   no-undo.
define variable p-type-rmethod        as logical   no-undo .
define variable loc-rez               as character no-undo .
define variable t-type                as character no-undo .
define variable g-g                   as logical   no-undo .
define variable v-PriceWithVat as decimal   no-undo .
define variable v-prod-vat     as decimal   no-undo .
define variable var-pr-r-b as character no-undo .
define variable v-base as logical   no-undo .
define variable v-num-specif          as integer   no-undo .
define variable v-spis                as character no-undo .
define variable v-contract-code       as integer   no-undo .
define variable v-bonus               as decimal   no-undo .
define variable vss-include-info56 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run rbisbase in g#library
  (output v-base
  )  .
if v-base = false then var-pr-r-b = "rubl":U .
                  else var-pr-r-b =  "base":U .
for each  x_obj-group :
define variable vss-include-info57 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsoattr-increase-pc in g#library
  (input  p-gds-code
  ,input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output  loc-increase-pc
  ) no-error .
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка метода поиска наценки товара на объекте" skip
     error-status :get-message(1) .
  end.
run gds-attr-margin-value
( input   p-gds-code           ,
  input   x_obj-group.obj-type ,
  input   x_obj-group.obj-code ,
  output  p-prc-min            ,
  output  p-prc-max            ,
  output  loc-grp-increase-pc  ,
  output  loc-grp-round-method ,
  output  loc-grp-round-base   ,
  output  p-value-margin       ,
  output  p-type-margin        ,
  output  p-value-increase     ,
  output  p-type-increase      ,
  output  p-value-rmethod      ,
  output  p-type-rmethod
  ) no-error .
  if error-status :error then do:
     message vss-workfile vss-revision vss-description skip
     "Ошибка процедуры поиска наценки по группе товара на объекте" skip
     error-status :get-message(1) .
  end.
  g-g = false .
  find first buf-goods no-lock where buf-goods.gds-code =  p-gds-code no-error .
  if error-status :error then message
    vss-workfile vss-revision vss-description skip
    error-status :get-message(1) skip
    return-value skip
    ""
    view-as alert-box error
  .
  case p-calc-method:
    when 'Единая':U or
    when 'Отсутствует':U or
    when 'Не-считать':U or
    when 'Откат_цен':U
    then do:
       p-increase-pc  = 0  .
       p-round-method = 'Отключено':U .
    end.
    when 'Товар':U then do:
      case buf-goods.calc-method:
        when 'Группа':U then do:
          find buf-gds-grp no-lock where
               buf-gds-grp.node-code = buf-goods.grp-code.
           p-increase-pc  = loc-grp-increase-pc .
           p-round-method = loc-grp-round-method .
           p-round-base   = loc-grp-round-base .
           g-g = true  .
        end.
        otherwise do:
           p-increase-pc  =  loc-increase-pc .
        end.
      end case.
      if g-g = false then do:
          run gdsoattr-value
             ( input 'round-method':U ,
               input p-gds-code ,
               input x_obj-group.obj-type ,
               input x_obj-group.obj-code ,
               output loc-rez ,
               output t-type
               ) no-error  .
              if error-status :error then message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                "gdsoattr-value"
                view-as alert-box error .
          case NUM-ENTRIES (loc-rez," ") :
              when 0 then do:
              end.
              when 1 then do:
                p-round-method = loc-rez .
                p-round-base   = 0 .
              end.
              when 2 then do:
                p-round-method = entry(1 , loc-rez, " " ).
                p-round-base   = decimal(entry(2 , loc-rez, " " )) .
              end.
              otherwise do:
                p-round-method = entry(1 , loc-rez, " " ).
                p-round-base   = decimal(entry(NUM-ENTRIES (loc-rez," ") , loc-rez, " " )) .
              end.
          end case.
      end.
    end.
  end case.
define variable vss-include-info58 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output v-hostcode
  ) no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "hostcode"
        view-as alert-box error
      .
define variable vss-include-info59 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  p-gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-hostcode
  ,input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output local_vat-pc
  ) no-error .
     if error-status :error then message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "НДС"
       view-as alert-box error
     .
define variable vss-include-info60 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  p-gds-code
  ,input  '2':U
  ,input  ?
  ,input  v-hostcode
  ,input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output local_slt-pc
  ) no-error .
    if error-status :error then message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "НсП"
      view-as alert-box error
    .
    new_slt-pc = new_slt-pc + string(local_slt-pc) + chr(4) .
    new_vat-pc = new_vat-pc + string(local_vat-pc) + chr(4) .
    new_round  = new_round  + string(p-increase-pc) + "% " +  string(p-round-method) + "^" +  string(p-round-base)   + chr(4) .
    loc_round  = string(p-increase-pc) + "% " +  string(p-round-method) + "^" +  string(p-round-base)  .
    find current buf_price-doc-forming no-lock no-error .
    if not available buf_price-doc-forming then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "qqqqqqqq"
       view-as alert-box error
     .
define variable vss-include-info61 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gtplobj in g#library2
  (input  ?
  ,input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,input  no
  ,output v-plt-id
  ,output v-plt-db-num
  ) no-error .
      if error-status :error then return error return-value .
    end.
end.
p-new-calc-method = p-calc-method .
run re-define in this-procedure (
    input-output p-calc-method
  , input p-gds-code
  ) .
  define variable v-sps as character no-undo .
v-sps =
 "Товар,
Группа,
Учетная,
Учет-объект,
Учет-резерв,
Приходная,
Прих-объект,
Начальная,
Старая,
Новая,
Объект,
Накладная,
Накл-безНДС,
Учет-безНДС,
Стар-безНДС,
Переоценка,
ДокФормЦены,
Отсутствует,
Признак,
Специальная,
Не-считать,
Основная,
Единая,
Учет+накл,
Уч+накл-НДС,
НсП,
НсП+накл,
УчетнаяS,
Учет-рзрвS,
ПриходнаяS,
Учет-НДСS,
Откат_цен,
Спецификация
"
  .
if lookup ( p-calc-method , v-sps )  = 0 then  do:
    p-calc-method = entry (1,p-calc-method, " ") no-error .
    if error-status :error then message p-calc-method.
end.
define variable v-i as integer   no-undo init 0.
  for each  x_obj-group :
      v-i = v-i + 1.
      if entry( v-i, new_round , chr(4) ) <> string ( loc_round ) then do:
          message "На выбранных объектах используются разные параметры Наценки и округления ! Для расчета выбран" string ( loc_round ) skip "для товара  "
          skip
          "код     :" p-gds-code  skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic     skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.
      if entry( v-i, new_vat-pc , chr(4) ) <> string ( local_vat-pc ) then do:
          message "На выбранных объектах используются разные НДС ! Для расчета выбран" string ( local_vat-pc ) "%" skip "для товара  "
          skip
          "код     :" p-gds-code  skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic     skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.
      if entry( v-i, new_slt-pc , chr(4) ) <> string ( local_slt-pc ) then do:
          message "На выбранных объектах используются разные НсП ! Для расчета выбран" string ( local_slt-pc )
          skip
          "код     :" p-gds-code   skip
          "бар-код :" p-b-code    skip
          "артикул :" p-artic             skip
          "производитель :" p-prod-type        p-prod-code
          view-as alert-box information .
          leave.
      end.
  end.
p-vat-pc  = local_vat-pc .
p-slt-pc  = local_slt-pc .
  if available buf_price-doc-forming then do:
     find first buf_price-list-type no-lock where
                buf_price-list-type.plt-id     = buf_price-doc-forming.plt-id    and
                buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num
                no-error .
     if error-status :error then return error return-value .
  end.
  else do:
find first buf_price-list-type no-lock where
           buf_price-list-type.plt-id     = v-plt-id    and
           buf_price-list-type.plt-db-num = v-plt-db-num
           no-error .
   if error-status :error then return error return-value .
  end.
define variable vss-include-info62 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-mpl in g#library2
  (input  buf_price-list-type.gop-id
  ,input  buf_price-list-type.gop-db-num
  ,input  p-b-code
  ,input  0
  ,input  0
  ,output v1-recid
  ,output p-price-prev-doc
  ,output v1-cur-rt
  ,output v1-cur-ex
  ) no-error .
    if error-status :error then
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "bc-mpl"
      view-as alert-box error
    .
define buffer old1_price-doc-forming     for ub.price-doc-forming  .
define buffer old1_price-doc-forming-gds for ub.price-doc-forming-gds  .
find first old1_price-doc-forming no-lock where
           recid(old1_price-doc-forming) = v1-recid no-error .
find first old1_price-doc-forming-gds no-lock where
           old1_price-doc-forming-gds.pdf-db      = old1_price-doc-forming.pdf-db      and
           old1_price-doc-forming-gds.pdf-id      = old1_price-doc-forming.pdf-id      and
           old1_price-doc-forming-gds.plt-db-num  = old1_price-doc-forming.plt-db-num  and
           old1_price-doc-forming-gds.plt-id      = old1_price-doc-forming.plt-id      and
           old1_price-doc-forming-gds.b-code      = p-b-code
           no-error .
if available old1_price-doc-forming-gds then do:
   p-d-pcnt = old1_price-doc-forming-gds.d-pcnt .
end.
else do:
  p-d-pcnt = 0 .
end.
case p-calc-method :
   when 'Новая':U or
   when 'Не-считать':U then do:
    assign
      p-new-calc-method = p-calc-method
      cost-rubl = ?
      cost-base = ?
    .
      if available buf_price-doc-forming then do:
        assign
          v-pdf-id      = buf_price-doc-forming.pdf-id
          v-pdf-db-num  = buf_price-doc-forming.pdf-db
          v-plt-id2     = buf_price-doc-forming.plt-id
          v-plt-db-num2 = buf_price-doc-forming.plt-db-num
        .
        find first buf_buf_price-doc-forming-gds no-lock where
              buf_buf_price-doc-forming-gds.pdf-id =  v-pdf-id and
              buf_buf_price-doc-forming-gds.pdf-db =  v-pdf-db-num and
              buf_buf_price-doc-forming-gds.plt-id =  v-plt-id2     and
              buf_buf_price-doc-forming-gds.plt-db-num =  v-plt-db-num2 and
              buf_buf_price-doc-forming-gds.b-code =  p-b-code
              no-error .
            if available buf_buf_price-doc-forming-gds then do:
                assign
                  cost-rubl = buf_buf_price-doc-forming-gds.price-sale-rubl
                  cost-base = buf_buf_price-doc-forming-gds.price-sale-base
                .
            end.
      end.
   end.
   when 'УчетнаяS':U  or
   when 'Учет-рзрвS':U  or
   when 'ПриходнаяS':U
   then do:
      run str/sgdsavrg.p
      (   input  p-calc-method    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
   end.
   when 'Учет-НДСS':U or
   when 'Накл-безНДС':U or
   when 'Стар-безНДС':U or
   when 'Старая':U or
   when 'Учет+накл':U or
   when 'Уч+накл-НДС':U or
   when 'Откат_цен':U then do:
      run str/mplnovat.p
        ( input  p-calc-method    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          input  0 ,
          input  v-doc-code ,
          input  p-vat-pc      ,
          input  p-slt-pc      ,
          output vd  ,
          output vd  ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
   end.
   when 'Накладная':U then do:
        find first buf_trn-doc no-lock where buf_trn-doc.doc-code = v-doc-code no-error .
        find first buf_doc-line  no-lock where
                  buf_doc-line.doc-code = v-doc-code      and
                  buf_doc-line.artic    = p-artic         and
                  buf_doc-line.prod-type   = p-prod-type  and
                  buf_doc-line.prod-code   = p-prod-code no-error .
        find first buf_bar-code no-lock where buf_bar-code.b-code = p-b-code no-error .
        find first buf_gds-dtl no-lock where
                   buf_gds-dtl.doc-code  = v-doc-code   and
                   buf_gds-dtl.artic     = p-artic      and
                   buf_gds-dtl.prod-type = p-prod-type  and
                   buf_gds-dtl.prod-code = p-prod-code  and
                   buf_gds-dtl.prt-code  = buf_bar-code.node-code no-error .
        assign
          v1 = recid (buf_trn-doc)
          v2 = recid (buf_doc-line)
          v3 = recid (buf_gds-dtl)
          v4  = buf_gds-dtl.prt-code
          no-error .
          if not v-base then do:
            run str/pr-wbil.p
            ( input "pr-doc"            ,
              input 'Накладная':U ,
              input v1               ,
              input v2               ,
              input v3               ,
              input v-doc-code       ,
              input ""               ,
              input p-gds-code       ,
              input p-artic          ,
              input p-prod-type      ,
              input p-prod-code      ,
              input v4               ,
              input 0                ,
              input (if buf_trn-doc.ext-doc-type = 'ie':U then buf_doc-line.price-rubl else buf_gds-dtl.price-rubl ) ,
              input (if buf_trn-doc.ext-doc-type = 'ie':U then buf_doc-line.price-base else buf_gds-dtl.price-base ) ,
              output cost-rubl       ,
              output v4
              ) no-error .
          end.
          else do:
            run str/pr-wbil.p
            ( input "pr-doc"            ,
              input 'Накладная':U ,
              input v1               ,
              input v2               ,
              input v3               ,
              input v-doc-code       ,
              input ""               ,
              input p-gds-code       ,
              input p-artic          ,
              input p-prod-type      ,
              input p-prod-code      ,
              input v4               ,
              input 0                ,
              input (if buf_trn-doc.ext-doc-type = 'ie':U then buf_doc-line.price-rubl else buf_gds-dtl.price-rubl ) ,
              input (if buf_trn-doc.ext-doc-type = 'ie':U then buf_doc-line.price-base else buf_gds-dtl.price-base ) ,
              output cost-base       ,
              output v4
              ) no-error .
          end.
          if not error-status :error then
              assign
                p-new-calc-method = 'Накладная':U + " " + v-doc-code
             .
    end.
    when 'Переоценка':U then do:
      find prev-list where
           prev-list.b-code     = p-b-code and
           prev-list.price-type = "" and
           prev-list.doc-num    = v-doc-code no-lock no-error.
      if available prev-list then
        assign
          p-new-calc-method = 'Переоценка':U + " " + v-doc-code
          cur-rt-base = prev-list.road-tax
          cur-rt-rubl = prev-list.road-tax
          cost-rubl = prev-list.price-sale
          cost-base = prev-list.price-sale
          .
      else
        message "Нет строки в переоценке :" v-doc-code "для товара :" p-artic
                "- расчет невозможен."
                view-as alert-box information .
    end.
    when 'ДокФормЦены':U then do:
    find first b_price-doc-forming no-lock where
               b_price-doc-forming.pdf-id     = integer(entry(1,v-doc-code,"|")) and
               b_price-doc-forming.pdf-db     = integer(entry(2,v-doc-code,"|"))
               no-error .
      find b_price-doc-forming-gds no-lock where
           b_price-doc-forming-gds.b-code     = p-b-code and
           b_price-doc-forming-gds.plt-db-num = b_price-doc-forming.plt-db-num and
           b_price-doc-forming-gds.plt-id     = b_price-doc-forming.plt-id and
           b_price-doc-forming-gds.pdf-id     = b_price-doc-forming.pdf-id and
           b_price-doc-forming-gds.pdf-db     = b_price-doc-forming.pdf-db
           no-error.
      if available b_price-doc-forming-gds then
        assign
          p-new-calc-method = 'ДокФормЦены':U + " " + v-doc-code
          cur-rt-base = b_price-doc-forming-gds.road-tax-base
          cur-rt-rubl = b_price-doc-forming-gds.road-tax-rubl
          cost-rubl   = b_price-doc-forming-gds.price-sale-rubl
          cost-base   = b_price-doc-forming-gds.price-sale-base
          .
      else
        message "Нет строки в ДНЦ :" integer(entry(1,v-doc-code,"|")) integer(entry(2,v-doc-code,"|")) skip
                "для товара :" skip
                 "Бар-код" p-b-code     skip
                 "Артикул" p-artic      skip
                  p-prod-type  skip
                  p-prod-code  skip
                "- расчет невозможен."
                view-as alert-box information .
    end.
    when 'Единая':U then do:
        assign
          p-new-calc-method = 'Единая':U + " " + string(common-price)
          cost-rubl = common-price
          cost-base = common-price
          .
    end.
    when 'Объект':U then do:
    find first buf_gds-obj no-lock where
               buf_gds-obj.gds-code = p-gds-code and
               buf_gds-obj.obj-type = v-copy-type and
               buf_gds-obj.obj-code = v-copy-code no-error .
        if available buf_gds-obj then do:
        assign
          p-new-calc-method = 'Объект':U + " " + v-copy-type + string(v-copy-code)
          cost-rubl = buf_gds-obj.price-sale
          cost-base = buf_gds-obj.price-sale
          .
        end.
        else do:
            message "Нет товара на объекте :" v-copy-type v-copy-code skip
                    "для товара :" p-artic  "- расчет невозможен."
                    view-as alert-box information .
        end.
    end.
   when 'Отсутствует':U or
   when "" then do:
      run str/mplnovat.p
        ( input  'Отсутствует':U    ,
          input  table x_obj-group ,
          input  p-b-code    ,
          input  p-artic     ,
          input  p-prod-type ,
          input  p-prod-code ,
          input  0 ,
          input  v-doc-code ,
          input  p-vat-pc      ,
          input  p-slt-pc      ,
          output vd  ,
          output vd  ,
          output cost-base   ,
          output cost-rubl   ,
          output cur-rt-base ,
          output cur-rt-rubl
          ).
          cost-rubl = vd * p-exch-rate / p-exch-scale .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = 'Отсутствует':U .
   end.
   when 'Основная':U then do:
   end.
    when 'ПорогПр-НДС':U then do:
      find first x_obj-group.
          run calc-price-levelprod (
            input 2          ,
            input var-pr-r-b ,
            input p-b-code   ,
            input x_obj-group.obj-type ,
            input x_obj-group.obj-code ,
            output vd,
            output v-descript
          ) no-error.
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара или цена = 0 :" p-artic  p-b-code skip
                "На объекте" x_obj-group.obj-type x_obj-group.obj-code skip
                "- расчет по производителю от последней приходной накладной c пороговой наценкой невозможен."
                view-as alert-box question buttons OK-Cancel title "#4" update g#log1 as logical .
      end.
      else do:
          cost-rubl = vd .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = substitute("&1&2&3" ,p-calc-method, chr(4),v-descript ) .
      end.
    end.
    when 'ПорогПр+НДС':U then do:
      find first x_obj-group.
          run calc-price-levelprod (
            input 1          ,
            input var-pr-r-b ,
            input p-b-code   ,
            input x_obj-group.obj-type ,
            input x_obj-group.obj-code ,
            output vd ,
            output v-descript
          ) no-error.
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара или цена = 0 :" p-artic  p-b-code skip
                "На объекте" x_obj-group.obj-type x_obj-group.obj-code skip
                "- расчет по производителю от последней приходной накладной c пороговой наценкой невозможен."
                view-as alert-box information .
      end.
      else do:
          cost-rubl = vd .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = substitute("&1&2&3" ,p-calc-method, chr(4),v-descript ) .
      end.
    end.
    when 'Производит':U
    then do:
      find first x_obj-group.
define variable vss-include-info63 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  p-b-code
 , input  x_obj-group.obj-type
 , input  x_obj-group.obj-code
 , output v-PriceWithVat
 , output vd
 , output v-prod-vat
 , output v-str1
 , output v-str1
        ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "proprice.i"
        view-as alert-box error
      .
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара или цена = 0 :" p-artic  p-b-code skip
                "На объекте" x_obj-group.obj-type x_obj-group.obj-code skip
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box question buttons OK-Cancel title "#3" update g#log as logical .
      end.
      else do:
          cost-rubl = vd .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = p-calc-method .
      end.
    end.
    when 'Произв-НДС':U
    then do:
      find first x_obj-group.
define variable vss-include-info64 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  p-b-code
 , input  x_obj-group.obj-type
 , input  x_obj-group.obj-code
 , output vd
 , output v-PriceWithVat
 , output v-prod-vat
 , output v-str1
 , output v-str1
        ) no-error .
      if error-status :error then
      message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "proprice.i"
        view-as alert-box error
      .
      if vd = 0 or vd = ?  then do:
        message "Нет ПН для товара или цена = 0 :" p-artic  p-b-code skip
                "На объекте" x_obj-group.obj-type x_obj-group.obj-code skip
                "- расчет по производителю от последней приходной накладной невозможен."
                view-as alert-box  .
      end.
      else do:
          cost-rubl = vd .
          cost-base = cost-rubl / p-base-rate * p-base-scale .
          p-new-calc-method = p-calc-method .
      end.
    end.
   when 'Спецификация':U
   then do:
      find first x_obj-group.
      assign
        v-num-specif    = 0
        v-contract-code = 0
      .
      for each buf_contract no-lock
      where buf_contract.host-code = v-cntxt-host-code-obj
      :
define variable vss-include-info65 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  buf_contract.contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = buf_contract.contract-code
      .
END.
FOR EACH
    buf_contract-specif
     NO-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
           :
            if buf_contract-specif.gds-code = p-gds-code then do:
              assign
                v-num-specif = v-num-specif + 1
                v-contract-code = buf_contract.contract-code
              .
            end.
        end.
      end.
      if v-num-specif > 1 then do:
         run str/gds-cnts.w
            (input parparentproc
            ,input p-gds-code
            , "b-sel":U
            ,output v-spis
          ) no-error.
        find first buf_contract-specif no-lock
        where recid(buf_contract-specif) = integer(v-spis)
          no-error.
          if available buf_contract-specif then do:
              run read-bonus (
                  input  buf_contract-specif.contract-num  ,
                  input  buf_contract-specif.host-code     ,
                  input  buf_contract-specif.gds-code      ,
                  output v-bonus  ) .
              assign
                cost-rubl = buf_contract-specif.price-cli
                cost-base = buf_contract-specif.price-cli / p-base-rate * p-base-scale
                p-new-calc-method = 'Спецификация':U
              .
              if v-bonus <> ? and v-bonus <> 0 then do:
                 assign
                 cost-rubl = cost-rubl + ( cost-rubl * v-bonus / 100 )
                 cost-base = cost-base + ( cost-base * v-bonus / 100 )
                 .
              end.
          end.
          else do:
            message "Не найдена спецификация с recid " v-spis skip
                    "для товара с артикулом " p-artic skip
                    "на объекте " x_obj-group.obj-type x_obj-group.obj-code skip
                    view-as alert-box information .
          end.
      end.
      if v-num-specif = 0 then do:
          message "Не найдена ни одна спецификация" skip
                  "для товара с артикулом " p-artic skip
                  "на объекте " x_obj-group.obj-type x_obj-group.obj-code skip
                  view-as alert-box information .
      end.
      if v-num-specif = 1 then do:
define variable vss-include-info66 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
ASSIGN
   i-gl-Host-Code      = 0
   i-gl-Contract-Code  = 0
   i-gl-Extent3        = 0
   .
RUN MS-Contract-EXTENT-3 IN THIS-PROCEDURE(
    INPUT  v-cntxt-host-code-obj,
    INPUT  v-contract-code,
    OUTPUT i-gl-Extent3
   ).
IF i-gl-Extent3[1] = 2 THEN DO:
   ASSIGN
      i-gl-Host-Code      = i-gl-Extent3[2]
      i-gl-Contract-Code  = i-gl-Extent3[3]
      .
END. ELSE DO:
   ASSIGN
      i-gl-Host-Code      = v-cntxt-host-code-obj
      i-gl-Contract-Code  = v-contract-code
      .
END.
FOR EACH
    buf_contract-specif
     NO-LOCK
     WHERE
         buf_contract-specif.Host-code    = i-gl-Host-Code
     AND buf_contract-specif.Contract-num = i-gl-Contract-Code
            :
            if buf_contract-specif.gds-code = p-gds-code then do:
              run read-bonus (
                  input  buf_contract-specif.contract-num  ,
                  input  buf_contract-specif.host-code     ,
                  input  buf_contract-specif.gds-code      ,
                  output v-bonus  ) .
              assign
                cost-rubl = buf_contract-specif.price-cli
                cost-base = buf_contract-specif.price-cli / p-base-rate * p-base-scale
                p-new-calc-method = 'Спецификация':U
              .
              if v-bonus <> ? and v-bonus <> 0 then do:
                 assign
                 cost-rubl = cost-rubl + ( cost-rubl * v-bonus / 100 )
                 cost-base = cost-base + ( cost-base * v-bonus / 100 )
                 .
              end.
            end.
          end.
      end.
   end.
   otherwise do:
     message  "Не просчитывается метод p-calc-method = " p-calc-method  skip
               p-new-calc-method  skip
              "p-price-prev-doc " p-price-prev-doc  skip
              "mpl-lib ERR !!! " skip
              'артикул ' p-artic skip
              view-as alert-box information .
   end.
 end case.
run main-road-taxs in this-procedure
  ( input p-artic     ,
    input p-prod-type ,
    input p-prod-code ,
    input-output cur-rt-base ,
    input-output cur-rt-rubl )
    .
  if p-exch-scale = 0  or  p-exch-scale = ?  then do:
    return error "Не определен курс валюты документа" .
  end.
  if p-base-scale = 0  or  p-base-scale = ?  then do:
     return error "Не определен курс базовой валюты " .
  end.
if v-base = false then var-pr-r-b = "rubl":U .
                  else var-pr-r-b =  "base":U .
    if var-pr-r-b = "rubl":U then do:
         case p-calc-method :
         when 'ПорогПр-НДС':U then do:
            p-price-sale-rubl  =  cost-rubl + (cost-rubl * p-vat-pc / 100)  .
         end.
         when 'ПорогПр+НДС':U then do:
            p-price-sale-rubl  =  cost-rubl .
         end.
         when  'Производит':U then do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100)  .
         end.
         when  'Произв-НДС':U then do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100) * (1 + p-vat-pc / 100)   .
         end.
         otherwise do:
            p-price-sale-rubl  =  cost-rubl * (1 + p-increase-pc / 100) .
         end.
        end case.
        assign
          p-price-calc-rubl  =  cost-rubl
          p-road-tax-rubl    =  cur-rt-rubl
          p-price-calc-doc   =  p-price-calc-rubl / p-exch-rate * p-exch-scale
          p-price-sale-doc   =  p-price-sale-rubl / p-exch-rate * p-exch-scale
          p-road-tax-doc     =  p-road-tax-rubl   / p-exch-rate * p-exch-scale
        .
    end.
    else do:
         case p-calc-method:
            when 'ПорогПр-НДС':U then do:
                p-price-sale-base  =  cost-base + (cost-base * p-vat-pc / 100)  .
            end.
            when 'ПорогПр+НДС':U then do:
                p-price-sale-base  =  cost-base .
            end.
            when 'Производит':U then do:
                p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100)  .
            end.
            when 'Произв-НДС':U then do:
                p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100) * (1 + p-vat-pc / 100)  .
            end.
            otherwise do:
                p-price-sale-base  =  cost-base * (1 + p-increase-pc / 100) .
            end.
         end case.
        assign
          p-price-calc-base  =  cost-base
          p-road-tax-base    =  cur-rt-base
          p-price-calc-rubl  =  p-price-calc-base * p-base-rate / p-base-scale
          p-price-sale-rubl  =  p-price-sale-base * p-base-rate / p-base-scale
          p-road-tax-rubl    =  p-road-tax-base   * p-base-rate / p-base-scale
          p-price-calc-doc   =  p-price-calc-rubl / p-exch-rate * p-exch-scale
          p-price-sale-doc   =  p-price-sale-rubl / p-exch-rate * p-exch-scale
          p-road-tax-doc     =  p-road-tax-rubl   / p-exch-rate * p-exch-scale
        .
    end.
   if p-price-sale-doc <> 0 then do:
case p-round-method :
  when '9-окончание':U then do:
    if p-price-sale-doc < 29 then do:
      if (p-price-sale-doc - truncate (p-price-sale-doc, 0)) <> 0 then do:
        assign
          p-price-sale-doc = truncate (p-price-sale-doc, 0) + 1
        .
      end.
    end.
    else do:
      if (p-price-sale-doc modulo 10) < 3 then do:
        assign
          p-price-sale-doc = (p-price-sale-doc - (p-price-sale-doc modulo 100))
              + ( truncate (((p-price-sale-doc modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          p-price-sale-doc = (p-price-sale-doc - (p-price-sale-doc modulo 100))
              + ( truncate (((p-price-sale-doc modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        p-price-sale-doc = round (p-price-sale-doc, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if p-price-sale-doc < p-round-base then do:
      assign
        p-price-sale-doc = truncate (p-price-sale-doc, 0) + 0.99
      .
    end.
    else do:
      assign
        p-price-sale-doc = truncate (p-price-sale-doc / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      p-price-sale-doc = round (p-price-sale-doc, 0)
    .
  end.
  when 'Произвольно':U then do:
    if p-round-base <> 0 then do:
      assign
        p-price-sale-doc = round (p-price-sale-doc / p-round-base, 0) * p-round-base
      .
      if p-price-sale-doc = 0 then do:
        assign
          p-price-sale-doc = p-round-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if p-round-base <> 0 then do:
      if truncate ( p-price-sale-doc / p-round-base, 0 ) <> (p-price-sale-doc / p-round-base) then do:
        assign
          p-price-sale-doc = truncate (p-price-sale-doc / p-round-base, 0) * p-round-base + p-round-base
        .
      end.
    end.
    if p-price-sale-doc = 0 then do:
      assign
        p-price-sale-doc = p-round-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if p-round-base <> 0 then do:
      assign
        p-price-sale-doc = p-price-sale-doc * p-round-base
      .
    end.
  end.
  when 'Отключено':U then do:
  end.
  otherwise do:
    message
      vss-workfile vss-revision vss-description skip
      "Неизвестный метод округления продажной цены" skip
      "round-method" p-round-method skip
      "round-base"   p-round-base   skip
      "price"        p-price-sale-doc             skip
      view-as alert-box error .
  end.
end.
  end.
  assign
    p-price-calc-rubl = p-price-calc-doc * p-exch-rate / p-exch-scale
    p-price-sale-rubl = p-price-sale-doc * p-exch-rate / p-exch-scale
    p-road-tax-rubl   = p-road-tax-doc   * p-exch-rate / p-exch-scale
    p-price-prev-rubl = p-price-prev-doc * p-exch-rate / p-exch-scale
   .
  assign
    p-price-calc-base = p-price-calc-rubl / p-base-rate * p-base-scale
    p-price-sale-base = p-price-sale-rubl / p-base-rate * p-base-scale
    p-road-tax-base   = p-road-tax-rubl   / p-base-rate * p-base-scale
    p-price-prev-base = p-price-prev-rubl / p-base-rate * p-base-scale
  .
  define buffer bufold_price-doc-forming for ub.price-doc-forming  .
  find first bufold_price-doc-forming where  recid(bufold_price-doc-forming) = v1-recid no-lock no-error .
  p-prev-doc-code = if available bufold_price-doc-forming
                       then (string(bufold_price-doc-forming.pdf-id) + " БД" + string(bufold_price-doc-forming.pdf-db))
                       else "" .
END PROCEDURE.
PROCEDURE create-line :
define input  parameter p-plt-db-num        like ub.price-doc-forming-gds.plt-db-num  no-undo .
define input  parameter p-plt-id            like ub.price-doc-forming-gds.plt-id      no-undo .
define input  parameter p-pdf-db            like ub.price-doc-forming-gds.pdf-db      no-undo .
define input  parameter p-pdf-id            like ub.price-doc-forming-gds.pdf-id  no-undo .
define input  parameter p-line-num          like ub.price-doc-forming-gds.line-num no-undo .
define input  parameter p-b-code            like ub.price-doc-forming-gds.b-code   no-undo .
define input  parameter p-artic             like ub.price-doc-forming-gds.artic    no-undo .
define input  parameter p-prod-type         like ub.price-doc-forming-gds.prod-type no-undo .
define input  parameter p-prod-code         like ub.price-doc-forming-gds.prod-code no-undo .
define input  parameter p-calc-method       like ub.price-doc-forming-gds.calc-method  no-undo .
define input  parameter p-d-pcnt            like ub.price-doc-forming-gds.d-pcnt       no-undo .
define input  parameter p-have-start-period like ub.price-doc-forming-gds.have-start-period no-undo .
define input  parameter p-start-date        like ub.price-doc-forming-gds.start-date        no-undo .
define input  parameter p-start-shift-date  like ub.price-doc-forming-gds.start-shift-date  no-undo .
define input  parameter p-start-shift-name  like ub.price-doc-forming-gds.start-shift-name  no-undo .
define input  parameter p-start-shift-num   like ub.price-doc-forming-gds.start-shift-num   no-undo .
define input  parameter p-start-sys-date    like ub.price-doc-forming-gds.start-sys-date    no-undo .
define input  parameter p-start-sys-time    like ub.price-doc-forming-gds.start-sys-time    no-undo .
define input  parameter p-have-end-period   like ub.price-doc-forming-gds.have-end-period   no-undo .
define input  parameter p-end-date          like ub.price-doc-forming-gds.end-date          no-undo .
define input  parameter p-end-shift-date    like ub.price-doc-forming-gds.end-shift-date    no-undo .
define input  parameter p-end-shift-name    like ub.price-doc-forming-gds.end-shift-name    no-undo .
define input  parameter p-end-shift-num     like ub.price-doc-forming-gds.end-shift-num     no-undo .
define input  parameter p-end-sys-date      like ub.price-doc-forming-gds.end-sys-date      no-undo .
define input  parameter p-end-sys-time      like ub.price-doc-forming-gds.end-sys-time      no-undo .
define input  parameter p-price-calc-base   like ub.price-doc-forming-gds.price-calc-base   no-undo .
define input  parameter p-price-calc-doc    like ub.price-doc-forming-gds.price-calc-doc    no-undo .
define input  parameter p-price-calc-rubl   like ub.price-doc-forming-gds.price-calc-rubl   no-undo .
define input  parameter p-price-prev-base   like ub.price-doc-forming-gds.price-prev-base   no-undo .
define input  parameter p-price-prev-doc    like ub.price-doc-forming-gds.price-prev-doc    no-undo .
define input  parameter p-price-prev-rubl   like ub.price-doc-forming-gds.price-prev-rubl   no-undo .
define input  parameter p-price-sale-base   like ub.price-doc-forming-gds.price-sale-base   no-undo .
define input  parameter p-price-sale-doc    like ub.price-doc-forming-gds.price-sale-doc    no-undo .
define input  parameter p-price-sale-rubl   like ub.price-doc-forming-gds.price-sale-rubl   no-undo .
define input  parameter p-road-tax-base     like ub.price-doc-forming-gds.road-tax-base     no-undo .
define input  parameter p-road-tax-doc      like ub.price-doc-forming-gds.road-tax-doc      no-undo .
define input  parameter p-road-tax-rubl     like ub.price-doc-forming-gds.road-tax-rubl     no-undo .
define input  parameter p-excise-base       like ub.price-doc-forming-gds.excise-base       no-undo .
define input  parameter p-excise-doc        like ub.price-doc-forming-gds.excise-doc        no-undo .
define input  parameter p-excise-rubl       like ub.price-doc-forming-gds.excise-rubl       no-undo .
define input  parameter p-vat-pc            like ub.price-doc-forming-gds.vat-pc            no-undo .
define input  parameter p-slt-pc            like ub.price-doc-forming-gds.slt-pc            no-undo .
define input  parameter p-prev-doc-code     as character no-undo .
define input  parameter p-stts              like ub.price-doc-forming-gds.stts              no-undo .
define input-output parameter  v-sec        as integer   no-undo .
  run check-use-bar-code ( p-b-code ) no-error .
  if error-status :error then do:
    message
      return-value skip
      "Ошибка !"
      view-as alert-box error
    .
    undo, return error return-value.
  end.
find first ub.price-doc-forming-gds exclusive-lock where
           ub.price-doc-forming-gds.plt-db-num  =  p-plt-db-num and
           ub.price-doc-forming-gds.plt-id      =  p-plt-id     and
           ub.price-doc-forming-gds.pdf-db      =  p-pdf-db     and
           ub.price-doc-forming-gds.pdf-id      =  p-pdf-id     and
           ub.price-doc-forming-gds.b-code      =  p-b-code     no-error .
    if not available ub.price-doc-forming-gds then
    do:
      create ub.price-doc-forming-gds .
       assign
        ub.price-doc-forming-gds.plt-db-num = p-plt-db-num
        ub.price-doc-forming-gds.plt-id     = p-plt-id
        ub.price-doc-forming-gds.pdf-db     = p-pdf-db
        ub.price-doc-forming-gds.pdf-id     = p-pdf-id
        ub.price-doc-forming-gds.b-code     = p-b-code
        ub.price-doc-forming-gds.line-num   = p-line-num
       .
    end.
  assign
    ub.price-doc-forming-gds.artic            = p-artic
    ub.price-doc-forming-gds.prod-type        = p-prod-type
    ub.price-doc-forming-gds.prod-code        = p-prod-code
    ub.price-doc-forming-gds.calc-method      = p-calc-method
    ub.price-doc-forming-gds.d-pcnt            = p-d-pcnt
    ub.price-doc-forming-gds.have-start-period = p-have-start-period
    ub.price-doc-forming-gds.start-date       = p-start-date
    ub.price-doc-forming-gds.start-shift-date = p-start-shift-date
    ub.price-doc-forming-gds.start-shift-name = p-start-shift-name
    ub.price-doc-forming-gds.start-shift-num  = p-start-shift-num
    ub.price-doc-forming-gds.start-sys-date   = p-start-sys-date
    ub.price-doc-forming-gds.start-sys-time   = p-start-sys-time
    ub.price-doc-forming-gds.have-end-period  = p-have-end-period
    ub.price-doc-forming-gds.end-date         = p-end-date
    ub.price-doc-forming-gds.end-shift-date   = p-end-shift-date
    ub.price-doc-forming-gds.end-shift-name   = p-end-shift-name
    ub.price-doc-forming-gds.end-shift-num    = p-end-shift-num
    ub.price-doc-forming-gds.end-sys-date     = p-end-sys-date
    ub.price-doc-forming-gds.end-sys-time     = p-end-sys-time
    ub.price-doc-forming-gds.price-calc-base  = p-price-calc-base
    ub.price-doc-forming-gds.price-calc-doc   = p-price-calc-doc
    ub.price-doc-forming-gds.price-calc-rubl  = p-price-calc-rubl
    ub.price-doc-forming-gds.price-prev-base  = p-price-prev-base
    ub.price-doc-forming-gds.price-prev-doc   = p-price-prev-doc
    ub.price-doc-forming-gds.price-prev-rubl  = p-price-prev-rubl
    ub.price-doc-forming-gds.road-tax-base    = p-road-tax-base
    ub.price-doc-forming-gds.road-tax-doc     = p-road-tax-doc
    ub.price-doc-forming-gds.road-tax-rubl    = p-road-tax-rubl
    ub.price-doc-forming-gds.excise-base      = p-excise-base
    ub.price-doc-forming-gds.excise-doc       = p-excise-doc
    ub.price-doc-forming-gds.excise-rubl      = p-excise-rubl
    ub.price-doc-forming-gds.vat-pc           = p-vat-pc
    ub.price-doc-forming-gds.slt-pc           = p-slt-pc
    ub.price-doc-forming-gds.prev-doc-code    = p-prev-doc-code
    ub.price-doc-forming-gds.stts             = p-stts
    ub.price-doc-forming-gds.price-sale-base  = p-price-sale-base
    ub.price-doc-forming-gds.price-sale-doc   = p-price-sale-doc
    ub.price-doc-forming-gds.price-sale-rubl  = p-price-sale-rubl
    .
  run ref/h-pdfgds.p
    ( buffer ub.price-doc-forming-gds ,
      input p-price-sale-doc ,
      input-output v-sec
      ) .
END PROCEDURE.
PROCEDURE last-num :
define input  parameter p-recid as recid no-undo .
define output parameter p-last-id as integer   no-undo .
define buffer buf2_price-doc-forming     for ub.price-doc-forming  .
define buffer buf2_price-doc-forming-gds for ub.price-doc-forming-gds  .
find first buf2_price-doc-forming no-lock where recid(buf2_price-doc-forming) = p-recid no-error .
      if error-status :error then do:
        p-last-id = ? .
        return .
      end.
    for each buf2_price-doc-forming-gds no-lock  where
            buf2_price-doc-forming-gds.plt-id     = buf2_price-doc-forming.plt-id     and
            buf2_price-doc-forming-gds.plt-db-num = buf2_price-doc-forming.plt-db-num and
            buf2_price-doc-forming-gds.pdf-id     = buf2_price-doc-forming.pdf-id     and
            buf2_price-doc-forming-gds.pdf-db     = buf2_price-doc-forming.pdf-db
            by buf2_price-doc-forming-gds.line-num
            :
            p-last-id = buf2_price-doc-forming-gds.line-num .
    end.
END PROCEDURE.
PROCEDURE calc-price-alt :
define input parameter bc         like ub.bar-code.b-code   no-undo.
define input parameter p-recid as recid no-undo .
define input parameter d-pcnt as decimal   no-undo .
define input parameter r-method   as character no-undo .
define input parameter r-base     as decimal   no-undo .
define output parameter pa-price-sale-base  as decimal   no-undo .
define output parameter pa-price-sale-doc   as decimal   no-undo .
define output parameter pa-price-sale-rubl  as decimal   no-undo .
pr-alt:
do on error undo pr-alt, return error:
  if r-method = ? or
     r-base = ? then do:
    message
      "Не задан способ округления для расчета зависящих от нее неосновных цен." skip
      "Код:" bc skip
      view-as alert-box error.
    undo pr-alt, return error.
  end.
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_main_bar-code for ub.bar-code  .
define buffer buf_main_price-doc-forming for ub.price-doc-forming  .
define buffer buf_main_price-doc-forming-gds for ub.price-doc-forming-gds  .
find first buf_main_price-doc-forming no-lock where recid(buf_main_price-doc-forming) = p-recid  no-error .
if error-status :error then
message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка "
  view-as alert-box error
.
find first buf_bar-code no-lock where
           buf_bar-code.b-code = bc no-error .
if error-status :error then
message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "3"
  view-as alert-box error
.
      assign
        pa-price-sale-doc = fnc-base-price-doc ( input bc , input p-recid ) *
                            buf_bar-code.cli-base-rate *
                            (1 - d-pcnt / 100)
                              .
  if pa-price-sale-doc <> 0 then do:
case r-method :
  when '9-окончание':U then do:
    if pa-price-sale-doc < 29 then do:
      if (pa-price-sale-doc - truncate (pa-price-sale-doc, 0)) <> 0 then do:
        assign
          pa-price-sale-doc = truncate (pa-price-sale-doc, 0) + 1
        .
      end.
    end.
    else do:
      if (pa-price-sale-doc modulo 10) < 3 then do:
        assign
          pa-price-sale-doc = (pa-price-sale-doc - (pa-price-sale-doc modulo 100))
              + ( truncate (((pa-price-sale-doc modulo 100) / 10), 0)
                - 1 ) * 10
              + 9
        .
      end.
      else do:
        assign
          pa-price-sale-doc = (pa-price-sale-doc - (pa-price-sale-doc modulo 100))
              + ( truncate (((pa-price-sale-doc modulo 100) / 10), 0)
                ) * 10
              + 9
        .
      end.
      assign
        pa-price-sale-doc = round (pa-price-sale-doc, 0)
      .
    end.
  end.
  when '9-99окончание':U then do:
    if pa-price-sale-doc < r-base then do:
      assign
        pa-price-sale-doc = truncate (pa-price-sale-doc, 0) + 0.99
      .
    end.
    else do:
      assign
        pa-price-sale-doc = truncate (pa-price-sale-doc / 10 , 0) * 10 + 9.99
      .
    end.
  end.
  when 'Без-дробных':U then do:
    assign
      pa-price-sale-doc = round (pa-price-sale-doc, 0)
    .
  end.
  when 'Произвольно':U then do:
    if r-base <> 0 then do:
      assign
        pa-price-sale-doc = round (pa-price-sale-doc / r-base, 0) * r-base
      .
      if pa-price-sale-doc = 0 then do:
        assign
          pa-price-sale-doc = r-base
        .
      end.
    end.
  end.
  when 'Вверх':U then do:
    if r-base <> 0 then do:
      if truncate ( pa-price-sale-doc / r-base, 0 ) <> (pa-price-sale-doc / r-base) then do:
        assign
          pa-price-sale-doc = truncate (pa-price-sale-doc / r-base, 0) * r-base + r-base
        .
      end.
    end.
    if pa-price-sale-doc = 0 then do:
      assign
        pa-price-sale-doc = r-base
      .
    end.
  end.
  when 'Коэффициент':U then do:
    if r-base <> 0 then do:
      assign
        pa-price-sale-doc = pa-price-sale-doc * r-base
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
      "price"        pa-price-sale-doc             skip
      view-as alert-box error .
  end.
end.
  end.
  pa-price-sale-rubl = pa-price-sale-doc * buf_main_price-doc-forming.exch-rate / buf_main_price-doc-forming.exch-scale .
  pa-price-sale-base = pa-price-sale-rubl / buf_main_price-doc-forming.base-rate * buf_main_price-doc-forming.base-scale .
end.
END PROCEDURE.
procedure calc-price-discnt :
  do
  on error undo, return error return-value
  :
define input parameter p-recid as recid no-undo .
define input parameter bc    like ub.bar-code.b-code   no-undo.
define buffer buf-price-doc-forming             for ub.price-doc-forming.
define buffer buf-price-doc-forming-gds for ub.price-doc-forming-gds.
define buffer buf-bar-code                      for ub.bar-code.
define buffer buf-goods                         for ub.goods.
define buffer old-price-doc-forming-gds         for ub.price-doc-forming-gds.
define variable pr-rec   as   recid                     no-undo.
define variable pr-c-b-r like ub.bar-code.cli-base-rate no-undo.
pr-discnt:
do on error undo pr-discnt, return error:
  find  buf-price-doc-forming no-lock where
        recid(buf-price-doc-forming) = p-recid .
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-doc-forming-gds exclusive-lock where
        buf-price-doc-forming-gds.pdf-id = buf-price-doc-forming.pdf-id and
        buf-price-doc-forming-gds.plt-id = buf-price-doc-forming.plt-id and
        buf-price-doc-forming-gds.pdf-db     = buf-price-doc-forming.pdf-db and
        buf-price-doc-forming-gds.plt-db-num = buf-price-doc-forming.plt-db-num and
        buf-price-doc-forming-gds.b-code  = bc.
   if available buf-price-doc-forming-gds then do:
      buf-price-doc-forming-gds.d-pcnt =
      (1 - buf-price-doc-forming-gds.price-sale-doc /
            fnc-base-price-doc ( buf-bar-code.b-code, p-recid ) /
            buf-bar-code.cli-base-rate) * 100 .
   end.
end.
  end.
end procedure.
procedure calc-price-sub :
define  input  parameter bc           like ub.price-doc-forming-gds.b-code no-undo.
define  input  parameter p-recid      as recid no-undo .
define  input  parameter calc-method  as character         no-undo.
define  input  parameter increase-pc  as decimal           no-undo.
define  input  parameter round-method as character         no-undo.
define  input  parameter round-base   as decimal           no-undo.
define  input  parameter doc-code     as character no-undo .
define  input  parameter common-price as decimal   no-undo .
define  input  parameter copy-type    as character no-undo .
define  input  parameter copy-code    as integer   no-undo .
define  output parameter calc-rec     as recid             no-undo.
define  buffer buf-price-doc-forming-gds for ub.price-doc-forming-gds.
define  buffer buf-bar-code              for ub.bar-code.
define  buffer buf-goods                 for ub.goods.
define  buffer buf-gds-prt               for ub.gds-prt.
define  buffer buf-gds-grp               for ub.gds-grp.
define  buffer buf-price-doc-forming     for ub.price-doc-forming.
calc-sub:
do on error undo calc-sub, return error:
  find  buf-price-doc-forming no-lock where
        recid (buf-price-doc-forming) =  p-recid .
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = bc.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find  buf-price-doc-forming-gds where
        buf-price-doc-forming-gds.pdf-id    = buf-price-doc-forming.pdf-id and
        buf-price-doc-forming-gds.plt-id    = buf-price-doc-forming.plt-id and
        buf-price-doc-forming-gds.pdf-db    = buf-price-doc-forming.pdf-db and
        buf-price-doc-forming-gds.plt-db-num  = buf-price-doc-forming.plt-db-num and
        buf-price-doc-forming-gds.b-code      = bc no-error .
  calc-rec = recid (buf-price-doc-forming-gds).
  if buf-gds-prt.upper-code = buf-goods.prt-root and  buf-goods.unit-base = buf-bar-code.unit-cli  then do:
    for each  buf-price-doc-forming-gds exclusive-lock where
              buf-price-doc-forming-gds.pdf-id    = buf-price-doc-forming.pdf-id and
              buf-price-doc-forming-gds.plt-id    = buf-price-doc-forming.plt-id and
              buf-price-doc-forming-gds.pdf-db    = buf-price-doc-forming.pdf-db and
              buf-price-doc-forming-gds.plt-db-num    = buf-price-doc-forming.plt-db-num and
              buf-price-doc-forming-gds.artic      = buf-goods.artic and
              buf-price-doc-forming-gds.prod-type  = buf-goods.prod-type and
              buf-price-doc-forming-gds.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code   = buf-price-doc-forming-gds.b-code and
              buf-bar-code.unit-cli = buf-goods.unit-base ,
        first buf-gds-prt no-lock where
              buf-gds-prt.node-code = buf-bar-code.node-code and
              buf-gds-prt.upper-code <> buf-goods.prt-root
        on error undo calc-sub, return error:
          run calc-price-line  in this-procedure
            ( input  calc-method
            , input  increase-pc
            , input  round-method
            , input  round-base
            , input  buf-bar-code.b-code
            , input  buf-goods.gds-code
            , input  buf-goods.artic
            , input  buf-goods.prod-type
            , input  buf-goods.prod-code
            , input  buf-price-doc-forming.base-rate
            , input  buf-price-doc-forming.base-scale
            , input  buf-price-doc-forming.exch-scale
            , input  buf-price-doc-forming.exch-rate
            , input  doc-code
            , input  common-price
            , input  copy-type
            , input  copy-code
            , output buf-price-doc-forming-gds.calc-method
            , output buf-price-doc-forming-gds.price-calc-base
            , output buf-price-doc-forming-gds.price-calc-doc
            , output buf-price-doc-forming-gds.price-calc-rubl
            , output buf-price-doc-forming-gds.price-prev-base
            , output buf-price-doc-forming-gds.price-prev-doc
            , output buf-price-doc-forming-gds.price-prev-rubl
            , output buf-price-doc-forming-gds.price-sale-base
            , output buf-price-doc-forming-gds.price-sale-doc
            , output buf-price-doc-forming-gds.price-sale-rubl
            , output buf-price-doc-forming-gds.road-tax-base
            , output buf-price-doc-forming-gds.road-tax-doc
            , output buf-price-doc-forming-gds.road-tax-rubl
            , output buf-price-doc-forming-gds.excise-base
            , output buf-price-doc-forming-gds.excise-doc
            , output buf-price-doc-forming-gds.excise-rubl
            , output buf-price-doc-forming-gds.vat-pc
            , output buf-price-doc-forming-gds.slt-pc
            , output buf-price-doc-forming-gds.prev-doc-code
            , output buf-price-doc-forming-gds.d-pcnt
            ) no-error .
          if error-status :error then do :
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              "calc-price-line"
              view-as alert-box error
            .
            undo calc-sub, return error.
            end.
      calc-rec = recid (buf-price-doc-forming-gds).
    end.
    for each  buf-price-doc-forming-gds exclusive-lock where
              buf-price-doc-forming-gds.pdf-id    = buf-price-doc-forming.pdf-id and
              buf-price-doc-forming-gds.plt-id    = buf-price-doc-forming.plt-id and
              buf-price-doc-forming-gds.pdf-db    = buf-price-doc-forming.pdf-db and
              buf-price-doc-forming-gds.plt-db-num    = buf-price-doc-forming.plt-db-num and
              buf-price-doc-forming-gds.artic      = buf-goods.artic and
              buf-price-doc-forming-gds.prod-type  = buf-goods.prod-type and
              buf-price-doc-forming-gds.prod-code  = buf-goods.prod-code,
        first buf-bar-code no-lock where
              buf-bar-code.b-code    = buf-price-doc-forming-gds.b-code and
              buf-bar-code.unit-cli <> buf-goods.unit-base ,
        first buf-gds-prt no-lock where
              buf-gds-prt.node-code = buf-bar-code.node-code
        on error undo calc-sub, return error:
    end.
  end.
  else do:
  end.
end.
end procedure.
procedure calc-base-update :
define input parameter bc           like ub.bar-code.b-code   no-undo.
define input parameter p-recid      as recid no-undo .
define input parameter round-method as character    no-undo.
define input parameter round-base   as decimal      no-undo.
define buffer alt-bar-code              for ub.bar-code.
define buffer alt-price-doc-forming-gds for ub.price-doc-forming-gds.
define buffer buf-bar-code              for ub.bar-code.
define buffer buf-goods                 for ub.goods.
define buffer buf-price-doc-forming     for ub.price-doc-forming  .
calc-base:
do on error undo calc-base, return error :
  find  buf-price-doc-forming no-lock where
        recid (buf-price-doc-forming) =  p-recid .
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
      each  alt-price-doc-forming-gds exclusive-lock where
            alt-price-doc-forming-gds.pdf-id      = buf-price-doc-forming.pdf-id and
            alt-price-doc-forming-gds.plt-id      = buf-price-doc-forming.plt-id and
            alt-price-doc-forming-gds.pdf-db      = buf-price-doc-forming.pdf-db and
            alt-price-doc-forming-gds.plt-db-num  = buf-price-doc-forming.plt-db-num and
            alt-price-doc-forming-gds.b-code      = alt-bar-code.b-code
      on error undo calc-base, return error:
  run calc-price-alt in this-procedure
      ( input  alt-price-doc-forming-gds.b-code
      , input  p-recid
      , input  alt-price-doc-forming-gds.d-pcnt
      , input  round-method
      , input  round-base
      , output alt-price-doc-forming-gds.price-sale-base
      , output alt-price-doc-forming-gds.price-sale-doc
      , output alt-price-doc-forming-gds.price-sale-rubl
      ) no-error .
    if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "calc-price-alt"
      view-as alert-box error
    .
      undo calc-base, return error.
    end.
  end.
end.
end procedure.
define temp-table temp-exp-partbc no-undo
field b-code  as integer
index pi b-code
.
procedure expose-prt :
define input  parameter p-calc-method  as character no-undo .
define input  parameter p-increase-pc as decimal   no-undo .
define input  parameter p-main-code    like ub.goods.gds-code    no-undo.
define input  parameter old-recid      as recid no-undo .
define input  parameter new-recid      as recid no-undo .
define input  parameter p-round-method as character no-undo .
define input  parameter p-round-base   as decimal   no-undo .
define input  parameter v-doc-code     as character no-undo .
define input  parameter v-common-price as decimal   no-undo .
define input  parameter v-copy-type    as character no-undo .
define input  parameter v-copy-code    as integer   no-undo .
define input-output parameter v-line-num as integer   no-undo .
define input-output parameter v-sec      as integer   no-undo .
define output parameter new-rec-str      as recid   no-undo.
define buffer buf-bar-code              for ub.bar-code.
define buffer buf-goods                 for ub.goods.
define buffer buf-price-doc-forming-gds for ub.price-doc-forming-gds.
define buffer buf-price-list            for ub.price-doc-forming-gds.
define buffer buf-price-doc-forming     for ub.price-doc-forming.
define buffer new-price-doc-forming     for ub.price-doc-forming.
define buffer new-price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf-gds-prt               for ub.gds-prt  .
define buffer buf_parts for ub.parts  .
define buffer buf_goods for ub.goods  .
  do
  on error undo, return error return-value
  :
  find  buf-price-doc-forming no-lock where
        recid(buf-price-doc-forming) = old-recid .
  find  new-price-doc-forming no-lock where
        recid(new-price-doc-forming) = new-recid .
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = p-main-code.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-price-doc-forming-gds no-lock  where
        buf-price-doc-forming-gds.pdf-id = buf-price-doc-forming.pdf-id and
        buf-price-doc-forming-gds.plt-id = buf-price-doc-forming.plt-id and
        buf-price-doc-forming-gds.pdf-db     = buf-price-doc-forming.pdf-db and
        buf-price-doc-forming-gds.plt-db-num = buf-price-doc-forming.plt-db-num and
        buf-price-doc-forming-gds.b-code  = p-main-code no-error .
  if error-status :error then return .
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
if par-pr-altex = "yes" and
   par-pr-notls = "yes" then do:
for each  buf-price-list where
          buf-price-list.pdf-id = buf-price-doc-forming.pdf-id and
          buf-price-list.plt-id = buf-price-doc-forming.plt-id and
          buf-price-list.pdf-db     = buf-price-doc-forming.pdf-db and
          buf-price-list.plt-db-num = buf-price-doc-forming.plt-db-num and
          buf-price-list.b-code     <> p-main-code and
          buf-price-list.artic       = buf-goods.artic  and
          buf-price-list.prod-type   = buf-goods.prod-type and
          buf-price-list.prod-code   = buf-goods.prod-code
          ,
    first buf-bar-code no-lock where
          buf-bar-code.b-code   = buf-price-list.b-code and
          buf-bar-code.unit-cli <> buf-goods.unit-base:
   run create-calc-bc in this-procedure
       ( input  recid( new-price-doc-forming )
        ,input  p-calc-method
        ,input  p-increase-pc
        ,input  p-round-method
        ,input  p-round-base
        ,input  buf-bar-code.b-code
        ,input  buf-goods.gds-code
        ,input  buf-goods.artic
        ,input  buf-goods.prod-type
        ,input  buf-goods.prod-code
        ,input  new-price-doc-forming.base-rate
        ,input  new-price-doc-forming.base-scale
        ,input  new-price-doc-forming.exch-scale
        ,input  new-price-doc-forming.exch-rate
        ,input  v-doc-code
        ,input  v-common-price
        ,input  v-copy-type
        ,input  v-copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .
  if error-status:error then do:
    message
      "Ошибка cre-pr-list."                skip
      "Код:" buf-bar-code.b-code           skip
      error-status :get-message(1)         skip
      return-value                         skip
       "pdf" new-price-doc-forming.pdf-id  skip
      view-as alert-box.
    next.
  end.
end.
end.
if par-pr-sclex = "yes" and
   par-pr-notls = "yes" then do:
for each  buf-price-list where
          buf-price-list.pdf-id = buf-price-doc-forming.pdf-id and
          buf-price-list.plt-id = buf-price-doc-forming.plt-id and
          buf-price-list.pdf-db     = buf-price-doc-forming.pdf-db and
          buf-price-list.plt-db-num = buf-price-doc-forming.plt-db-num and
          buf-price-list.b-code     <> p-main-code and
          buf-price-list.artic       = buf-goods.artic  and
          buf-price-list.prod-type   = buf-goods.prod-type and
          buf-price-list.prod-code   = buf-goods.prod-code  ,
    first buf-bar-code no-lock where
          buf-bar-code.b-code   = buf-price-list.b-code and
          buf-bar-code.unit-cli = buf-goods.unit-base and
          buf-bar-code.in-code = ""
          :
   run create-calc-bc in this-procedure
       ( input  recid( new-price-doc-forming )
        ,input  p-calc-method
        ,input  p-increase-pc
        ,input  p-round-method
        ,input  p-round-base
        ,input  buf-bar-code.b-code
        ,input  buf-goods.gds-code
        ,input  buf-goods.artic
        ,input  buf-goods.prod-type
        ,input  buf-goods.prod-code
        ,input  new-price-doc-forming.base-rate
        ,input  new-price-doc-forming.base-scale
        ,input  new-price-doc-forming.exch-scale
        ,input  new-price-doc-forming.exch-rate
        ,input v-doc-code
        ,input v-common-price
        ,input v-copy-type
        ,input v-copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .
      if error-status:error then do:
        message
          "Ошибка cre-pr-list.2" skip
          "Код:" buf-bar-code.b-code
          view-as alert-box.
        next.
      end.
    end.
end.
if par-pr-parex = "yes" and
   par-pr-notls = "yes" then do:
define buffer bt_trn-doc  for ub.trn-doc  .
define buffer bf_parts    for ub.parts  .
define buffer free_parts  for ub.parts  .
define buffer buf_gds-obj for ub.gds-obj  .
find first buf_gds-obj no-lock where
           buf_gds-obj.gds-code = buf-goods.gds-code and
           buf_gds-obj.obj-type = v-cntxt-obj-type   and
           buf_gds-obj.obj-code = v-cntxt-obj-code   and
           buf_gds-obj.cash-parts = true
           no-error .
if not available buf_gds-obj then return .
 find first bt_trn-doc no-lock where
            bt_trn-doc.doc-code = v-doc-code no-error .
 if v-doc-code <> "" and available bt_trn-doc then do:
 for each temp-exp-partbc :
     delete temp-exp-partbc.
 end.
 for each bf_parts no-lock where
          bf_parts.out-code   = bt_trn-doc.doc-code and
          bf_parts.obj-type   = bt_trn-doc.obj-type and
          bf_parts.obj-code   = bt_trn-doc.obj-code and
          bf_parts.artic      = buf-goods.artic     and
          bf_parts.prod-type  = buf-goods.prod-type and
          bf_parts.prod-code  = buf-goods.prod-code  ,
        first free_parts no-lock where
              free_parts.in-code   = bf_parts.in-code   and
              free_parts.part-code = bf_parts.part-code and
              free_parts.out-code  = 'free-zone':U       and
              free_parts.rsrv-free = true               and
              free_parts.status_   = false              and
              free_parts.obj-type  = bf_parts.obj-type  and
              free_parts.obj-code  = bf_parts.obj-code  and
              free_parts.artic     = bf_parts.artic     and
              free_parts.prod-type = bf_parts.prod-type and
              free_parts.prod-code = bf_parts.prod-code ,
        first buf-bar-code no-lock where
              buf-bar-code.gds-code  = buf-goods.gds-code and
              buf-bar-code.unit-cli  = buf-goods.unit-base and
              buf-bar-code.in-code   = bf_parts.in-code and
              buf-bar-code.part-code = bf_parts.part-code
              :
   run create-calc-bc in this-procedure
       ( input  recid( new-price-doc-forming )
        ,input  p-calc-method
        ,input  p-increase-pc
        ,input  p-round-method
        ,input  p-round-base
        ,input  buf-bar-code.b-code
        ,input  buf-goods.gds-code
        ,input  buf-goods.artic
        ,input  buf-goods.prod-type
        ,input  buf-goods.prod-code
        ,input  new-price-doc-forming.base-rate
        ,input  new-price-doc-forming.base-scale
        ,input  new-price-doc-forming.exch-scale
        ,input  new-price-doc-forming.exch-rate
        ,input v-doc-code
        ,input v-common-price
        ,input v-copy-type
        ,input v-copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .
      if error-status:error then do:
        message
          "Ошибка cre-pr-list.3-" skip
          "Код:" buf-bar-code.b-code
          view-as alert-box.
        next.
      end.
      create temp-exp-partbc.
      assign
         temp-exp-partbc.b-code = buf-bar-code.b-code
      .
 end.
end.
for each  buf-price-list where
          buf-price-list.pdf-id     = buf-price-doc-forming.pdf-id and
          buf-price-list.plt-id     = buf-price-doc-forming.plt-id and
          buf-price-list.pdf-db     = buf-price-doc-forming.pdf-db and
          buf-price-list.plt-db-num = buf-price-doc-forming.plt-db-num and
          buf-price-list.b-code     <> p-main-code         and
          buf-price-list.artic       = buf-goods.artic     and
          buf-price-list.prod-type   = buf-goods.prod-type and
          buf-price-list.prod-code   = buf-goods.prod-code ,
    first buf-bar-code no-lock where
          buf-bar-code.b-code   = buf-price-list.b-code and
          buf-bar-code.unit-cli = buf-goods.unit-base and
          buf-bar-code.in-code <> "" ,
    first buf_parts no-lock where
          buf_parts.out-code    = 'free-zone':U and
          buf_parts.rsrv-free   = true  and
          buf_parts.status_     = false and
          buf_parts.artic       = buf-goods.artic and
          buf_parts.prod-type   = buf-goods.prod-type and
          buf_parts.prod-code   = buf-goods.prod-code and
          buf_parts.obj-type   = v-cntxt-obj-type and
          buf_parts.obj-code   = v-cntxt-obj-code and
          buf_parts.part-code   = buf-bar-code.part-code and
          buf_parts.in-code     = buf-bar-code.in-code
          :
          find first temp-exp-partbc where
                     temp-exp-partbc.b-code = buf-bar-code.b-code no-error .
        if available temp-exp-partbc then next.
   run create-calc-bc in this-procedure
       ( input  recid( new-price-doc-forming )
        ,input  'Старая':U
        ,input  0
        ,input  'Отключено':U
        ,input  0
        ,input  buf-bar-code.b-code
        ,input  buf-goods.gds-code
        ,input  buf-goods.artic
        ,input  buf-goods.prod-type
        ,input  buf-goods.prod-code
        ,input  new-price-doc-forming.base-rate
        ,input  new-price-doc-forming.base-scale
        ,input  new-price-doc-forming.exch-scale
        ,input  new-price-doc-forming.exch-rate
        ,input v-doc-code
        ,input v-common-price
        ,input v-copy-type
        ,input v-copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .
      if error-status:error then do:
        message
          "Ошибка cre-pr-list.3" skip
          "Код:" buf-bar-code.b-code
          view-as alert-box.
        next.
      end.
    end.
  for each buf_parts no-lock where
          buf_parts.out-code    = 'free-zone':U and
          buf_parts.rsrv-free   = true  and
          buf_parts.status_     = false and
          buf_parts.artic       = buf-goods.artic and
          buf_parts.prod-type   = buf-goods.prod-type and
          buf_parts.prod-code   = buf-goods.prod-code and
          buf_parts.obj-type    = v-cntxt-obj-type and
          buf_parts.obj-code    = v-cntxt-obj-code and
          buf_parts.part-code   = buf-bar-code.part-code and
          buf_parts.in-code     = buf-bar-code.in-code,
        first buf-bar-code no-lock where
              buf-bar-code.gds-code  = buf-goods.gds-code and
              buf-bar-code.unit-cli  = buf-goods.unit-base and
              buf-bar-code.in-code   = buf_parts.in-code and
              buf-bar-code.part-code = buf_parts.part-code
          :
          find first temp-exp-partbc where
                     temp-exp-partbc.b-code = buf-bar-code.b-code no-error .
        if available temp-exp-partbc then next.
          find first new-price-doc-forming-gds where
                     new-price-doc-forming-gds.pdf-id     = new-price-doc-forming.pdf-id and
                     new-price-doc-forming-gds.pdf-db     = new-price-doc-forming.pdf-db and
                     new-price-doc-forming-gds.plt-id     = new-price-doc-forming.plt-id and
                     new-price-doc-forming-gds.plt-db-num = new-price-doc-forming.plt-db-num  and
                     new-price-doc-forming-gds.b-code = buf-bar-code.b-code
                     no-error .
        if available new-price-doc-forming-gds then next.
   run create-calc-bc in this-procedure
       ( input recid( new-price-doc-forming )
        ,input 'Старая':U
        ,input 0
        ,input 'Отключено':U
        ,input 0
        ,input buf-bar-code.b-code
        ,input buf-goods.gds-code
        ,input buf-goods.artic
        ,input buf-goods.prod-type
        ,input buf-goods.prod-code
        ,input new-price-doc-forming.base-rate
        ,input new-price-doc-forming.base-scale
        ,input new-price-doc-forming.exch-scale
        ,input new-price-doc-forming.exch-rate
        ,input v-doc-code
        ,input v-common-price
        ,input v-copy-type
        ,input v-copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .
      if error-status:error then do:
        message
          "Ошибка cre-pr-list.4" skip
          "Код:" buf-bar-code.b-code
          view-as alert-box.
        next.
      end.
    end.
end.
  end.
end procedure.
procedure create-calc-bc :
define input parameter  v-new-recid as recid no-undo .
define input parameter  p-calc-method  as character no-undo .
define input parameter  p-increase-pc  as decimal   no-undo .
define input parameter  round-method as character no-undo .
define input parameter  round-base   as decimal   no-undo .
define input parameter  p-b-code     as integer   no-undo .
define input parameter  p-gds-code   as integer   no-undo .
define input parameter  p-artic      as character no-undo .
define input parameter  p-prod-type  as character no-undo .
define input parameter  p-prod-code  as integer   no-undo .
define input parameter  v-base-rate  as decimal   no-undo .
define input parameter  v-base-scale as decimal   no-undo .
define input parameter  v-exch-scale as decimal   no-undo .
define input parameter  v-exch-rate  as decimal   no-undo .
define input parameter  v-doc-code   as character no-undo .
define input parameter  v-common-price as decimal   no-undo .
define input parameter  v-copy-type as character no-undo .
define input parameter  v-copy-code as integer   no-undo .
define input-output parameter v-line-num as integer   no-undo .
define input-output parameter v-sec     as integer   no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define variable v-price-calc-base as decimal   no-undo .
define variable v-price-calc-doc  as decimal   no-undo .
define variable v-price-calc-rubl as decimal   no-undo .
define variable v-price-prev-base as decimal   no-undo .
define variable v-price-prev-doc  as decimal   no-undo .
define variable v-price-prev-rubl as decimal   no-undo .
define variable v-price-sale-base as decimal   no-undo .
define variable v-price-sale-doc  as decimal   no-undo .
define variable v-price-sale-rubl as decimal   no-undo .
define variable v-road-tax-base   as decimal   no-undo .
define variable v-road-tax-doc    as decimal   no-undo .
define variable v-road-tax-rubl   as decimal   no-undo .
define variable v-excise-base     as decimal   no-undo .
define variable v-excise-doc      as decimal   no-undo .
define variable v-excise-rubl     as decimal   no-undo .
define variable v-vat-pc          as decimal   no-undo .
define variable v-slt-pc          as decimal   no-undo .
define variable v-prev-doc-code   as character no-undo .
define variable v-d-pcnt as decimal   no-undo .
  do
  on error undo, return error return-value
  :
  find  buf_price-doc-forming no-lock where
        recid(buf_price-doc-forming) = v-new-recid no-error .
   if error-status :error then return error error-status :get-message(1) .
   v-line-num = v-line-num + 1.
   run calc-price-line  in this-procedure (
     input  p-calc-method
   , input  p-increase-pc
   , input  round-method
   , input  round-base
   , input  p-b-code
   , input  p-gds-code
   , input  p-artic
   , input  p-prod-type
   , input  p-prod-code
   , input  v-base-rate
   , input  v-base-scale
   , input  v-exch-scale
   , input  v-exch-rate
   , input  v-doc-code
   , input  v-common-price
   , input  v-copy-type
   , input  v-copy-code
   , output p-calc-method
   , output v-price-calc-base
   , output v-price-calc-doc
   , output v-price-calc-rubl
   , output v-price-prev-base
   , output v-price-prev-doc
   , output v-price-prev-rubl
   , output v-price-sale-base
   , output v-price-sale-doc
   , output v-price-sale-rubl
   , output v-road-tax-base
   , output v-road-tax-doc
   , output v-road-tax-rubl
   , output v-excise-base
   , output v-excise-doc
   , output v-excise-rubl
   , output v-vat-pc
   , output v-slt-pc
   , output v-prev-doc-code
   , output v-d-pcnt
   ) no-error .
   if error-status :error then
   message
     vss-workfile vss-revision vss-description skip
     error-status :get-message(1) skip
     return-value skip
     "123calc-price-line"
     "p-calc-method     "  p-calc-method     skip
     "p-increase-pc     "  p-increase-pc     skip
     "round-method      "    round-method    skip
     "round-base        "    round-base      skip
     "p-b-code          "    p-b-code        skip
     "p-gds-code        "    p-gds-code      skip
     "p-artic           "    p-artic         skip
     "p-prod-type       "    p-prod-type     skip
     "p-prod-code       "    p-prod-code     skip
     "v-base-rate       "   v-base-rate     skip
     "v-base-scale      "  v-base-scale    skip
     "v-exch-scale      "  v-exch-scale    skip
     "v-exch-rate       "  v-exch-rate     skip
     "v-doc-code        "  v-doc-code      skip
     "v-common-price    "  v-common-price  skip
     "v-copy-type       "  v-copy-type     skip
     "v-copy-code       "  v-copy-code     skip
     "v-d-pcnt          "  v-d-pcnt
     view-as alert-box error
   .
   run create-line  in this-procedure (
     buf_price-doc-forming.plt-db-num
    ,buf_price-doc-forming.plt-id
    ,buf_price-doc-forming.pdf-db
    ,buf_price-doc-forming.pdf-id
    ,v-line-num
    ,p-b-code
    ,p-artic
    ,p-prod-type
    ,p-prod-code
    ,p-calc-method
    ,v-d-pcnt
    ,buf_price-doc-forming.have-start-period
    ,buf_price-doc-forming.start-date
    ,buf_price-doc-forming.start-shift-date
    ,buf_price-doc-forming.start-shift-name
    ,buf_price-doc-forming.start-shift-num
    ,buf_price-doc-forming.start-sys-date
    ,buf_price-doc-forming.start-sys-time
    ,buf_price-doc-forming.have-end-period
    ,buf_price-doc-forming.end-date
    ,buf_price-doc-forming.end-shift-date
    ,buf_price-doc-forming.end-shift-name
    ,buf_price-doc-forming.end-shift-num
    ,buf_price-doc-forming.end-sys-date
    ,buf_price-doc-forming.end-sys-time
    ,v-price-calc-base
    ,v-price-calc-doc
    ,v-price-calc-rubl
    ,v-price-prev-base
    ,v-price-prev-doc
    ,v-price-prev-rubl
    ,v-price-sale-base
    ,v-price-sale-doc
    ,v-price-sale-rubl
    ,v-road-tax-base
    ,v-road-tax-doc
    ,v-road-tax-rubl
    ,v-excise-base
    ,v-excise-doc
    ,v-excise-rubl
    ,v-vat-pc
    ,v-slt-pc
    ,v-prev-doc-code
    ,0
    ,input-output v-sec
     ) no-error  .
     if error-status :error then
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       "4567"
       view-as alert-box error
     .
  end.
end procedure.
procedure re-define :
define input-output parameter p-calc-method      as character no-undo .
define input        parameter p-gds-code         as integer   no-undo .
  do
  on error undo, return error return-value
  :
define buffer buf_goods for ub.goods  .
define buffer buf_gds-grp for ub.gds-grp  .
    case p-calc-method :
      when 'Товар':U then do:
           find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
                case buf_goods.calc-method:
                  when 'Группа':U then do:
                    find first buf_gds-grp no-lock where
                               buf_gds-grp.node-code = buf_goods.grp-code no-error .
                    p-calc-method  = buf_gds-grp.calc-method.
                  end.
                otherwise do:
                    p-calc-method  =  buf_goods.calc-method .
                end.
                end case.
           run  re-define in this-procedure (
                      input-output  p-calc-method ,
                      input p-gds-code )  .
      end.
      when 'Группа':U then do:
           find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
           find first buf_gds-grp no-lock where
                      buf_gds-grp.node-code = buf_goods.grp-code no-error .
           run re-define in this-procedure (
                      input-output buf_gds-grp.calc-method ,
                      input p-gds-code )  .
      end.
      when 'Учетная':U or
      when 'Учет-объект':U then do:
           p-calc-method = 'УчетнаяS':U .
      end.
      when 'Учет-резерв':U then do:
           p-calc-method = 'Учет-рзрвS':U.
      end.
      when 'Приходная':U or
      when 'Прих-объект':U then do:
           p-calc-method = 'ПриходнаяS':U.
      end.
      when 'Учет-безНДС':U then do:
           p-calc-method = 'Учет-НДСS':U .
      end.
    end case.
  end.
end procedure.
procedure create-line-pdf-mpl-lib :
define input  parameter  p-plt-db-num as integer   no-undo .
define input  parameter  p-plt-id     as integer   no-undo .
define input  parameter  p-pdf-db     as integer   no-undo .
define input  parameter  p-pdf-id     as integer   no-undo .
define input  parameter  p-line-num   as integer   no-undo .
define input  parameter  p-b-code     as integer   no-undo .
define input  parameter  p-artic      as character no-undo .
define input  parameter  p-prod-type  as character no-undo .
define input  parameter  p-prod-code  as integer   no-undo .
define input  parameter  p-met    as character no-undo .
define input  parameter  p-d-pcnt as decimal   no-undo .
define input  parameter  p-price  as decimal   no-undo .
define input  parameter  p-out-code as character no-undo .
define input  parameter  p-stts as integer   no-undo .
define input-output  parameter v-sec   as integer   no-undo .
define variable v-price-calc-base  as decimal   no-undo .
define variable v-price-calc-doc   as decimal   no-undo .
define variable v-price-calc-rubl  as decimal   no-undo .
define variable v-price-prev-base  as decimal   no-undo .
define variable v-price-prev-doc   as decimal   no-undo .
define variable v-price-prev-rubl  as decimal   no-undo .
define variable v-price-sale-base  as decimal   no-undo .
define variable v-price-sale-doc   as decimal   no-undo .
define variable v-price-sale-rubl  as decimal   no-undo .
define variable v-road-tax-base    as decimal   no-undo .
define variable v-road-tax-doc     as decimal   no-undo .
define variable v-road-tax-rubl    as decimal   no-undo .
define variable v-excise-base      as decimal   no-undo .
define variable v-excise-doc       as decimal   no-undo .
define variable v-excise-rubl      as decimal   no-undo .
define variable V-base-rate       as decimal   no-undo .
define variable V-base-scale      as decimal   no-undo .
define variable V-exch-scale      as decimal   no-undo .
define variable V-exch-rate       as decimal   no-undo .
define variable v-curr-abbr as character no-undo .
define variable p-vat-pc as decimal   no-undo .
define variable p-slt-pc as decimal   no-undo .
  do
  on error undo, return error return-value
  :
find first ub.price-list-type  no-lock  where
           ub.price-list-type.plt-db-num = p-plt-db-num  and
           ub.price-list-type.plt-id     = p-plt-id
           no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка!"
  view-as alert-box error
.
find first ub.price-doc-forming no-lock  where
           ub.price-doc-forming.plt-db-num = p-plt-db-num and
           ub.price-doc-forming.plt-id     = p-plt-id     and
           ub.price-doc-forming.pdf-db     = p-pdf-db     and
           ub.price-doc-forming.pdf-id     = p-pdf-id
            no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка!"
  view-as alert-box error
.
find first ub.goods no-lock where
 ub.goods.artic = p-artic and
 ub.goods.prod-type = p-prod-type and
 ub.goods.prod-code = p-prod-code no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  "Ошибка!"
  view-as alert-box error
.
if ub.price-list-type.fix-cource-crc-base = true then do:
    assign
      V-base-rate  = ub.price-doc-forming.base-rate
      V-base-scale = ub.price-doc-forming.base-scale
    .
end.
else do:
define variable vss-include-info67 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run baserate in g#library
  (input  v-cntxt-host-code-obj
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  )  .
end.
if ub.price-list-type.fix-cource-crc-doc = true then do:
    assign
      V-exch-rate  = ub.price-doc-forming.exch-rate
      V-exch-scale = ub.price-doc-forming.exch-scale
    .
end.
else do:
define variable vss-include-info68 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  ub.price-list-type.curr-code
  ,input  today
  ,output v-exch-rate
  ,output v-exch-scale
  ,output v-curr-abbr
  )  .
end.
define variable p-new-calc-method as character no-undo .
define variable v-prev-doc-code as character no-undo .
define variable v-d-pcnt as decimal   no-undo .
if ub.price-list-type.main then do:
run calc-price-line in this-procedure (
 input  'Единая':U
,input  0
,input  'Отключено':U
,input  0
,input  p-b-code
,input  ub.goods.gds-code
,input  p-artic
,input  p-prod-type
,input  p-prod-code
,input  V-base-rate
,input  V-base-scale
,input  V-exch-scale
,input  V-exch-rate
,input  ""
,input  p-price
,input  ""
,input  ?
,output p-new-calc-method
,output v-price-calc-base
,output v-price-calc-doc
,output v-price-calc-rubl
,output v-price-prev-base
,output v-price-prev-doc
,output v-price-prev-rubl
,output v-price-sale-base
,output v-price-sale-doc
,output v-price-sale-rubl
,output v-road-tax-base
,output v-road-tax-doc
,output v-road-tax-rubl
,output v-excise-base
,output v-excise-doc
,output v-excise-rubl
,output p-vat-pc
,output p-slt-pc
,output v-prev-doc-code
,output v-d-pcnt
).
end.
else do:
run set-price-line in this-procedure (
 input p-plt-id
,input p-plt-db-num
,input  'Единая':U
,input  0
,input  'Отключено':U
,input  0
,input  p-b-code
,input  ub.goods.gds-code
,input  p-artic
,input  p-prod-type
,input  p-prod-code
,input  V-base-rate
,input  V-base-scale
,input  V-exch-scale
,input  V-exch-rate
,input  ""
,input  p-price
,input  ""
,input  ?
,output p-new-calc-method
,output v-price-calc-base
,output v-price-calc-doc
,output v-price-calc-rubl
,output v-price-prev-base
,output v-price-prev-doc
,output v-price-prev-rubl
,output v-price-sale-base
,output v-price-sale-doc
,output v-price-sale-rubl
,output v-road-tax-base
,output v-road-tax-doc
,output v-road-tax-rubl
,output v-excise-base
,output v-excise-doc
,output v-excise-rubl
,output p-vat-pc
,output p-slt-pc
,output v-prev-doc-code
,output v-d-pcnt
) no-error .
if error-status :error then do:
   message
     error-status :get-message(1) skip
     return-value skip
     ""
     view-as alert-box error
   .
end.
end.
run create-line (
 input  p-plt-db-num
,input  p-plt-id
,input  p-pdf-db
,input  p-pdf-id
,input  p-line-num
,input  p-b-code
,input  p-artic
,input  p-prod-type
,input  p-prod-code
,input  p-met
,input  p-d-pcnt
,input  price-doc-forming.have-start-period
,input  price-doc-forming.start-date
,input  price-doc-forming.start-shift-date
,input  price-doc-forming.start-shift-name
,input  price-doc-forming.start-shift-num
,input  price-doc-forming.start-sys-date
,input  price-doc-forming.start-sys-time
,input  price-doc-forming.have-end-period
,input  price-doc-forming.end-date
,input  price-doc-forming.end-shift-date
,input  price-doc-forming.end-shift-name
,input  price-doc-forming.end-shift-num
,input  price-doc-forming.end-sys-date
,input  price-doc-forming.end-sys-time
,input  v-price-calc-base
,input  v-price-calc-doc
,input  v-price-calc-rubl
,input  v-price-prev-base
,input  v-price-prev-doc
,input  v-price-prev-rubl
,input  v-price-sale-base
,input  v-price-sale-doc
,input  v-price-sale-rubl
,input  v-road-tax-base
,input  v-road-tax-doc
,input  v-road-tax-rubl
,input  v-excise-base
,input  v-excise-doc
,input  v-excise-rubl
,input  p-vat-pc
,input  p-slt-pc
,input  p-out-code
,input  p-stts
,input-output v-sec   ).
  end.
end procedure.
procedure main-road-taxs :
define input param p-artic     like ub.gds-obj.artic     no-undo .
define input param p-prod-type like ub.gds-obj.prod-type no-undo .
define input param p-prod-code like ub.gds-obj.prod-code no-undo .
define input-output param p-road-tax-base as decimal no-undo .
define input-output param p-road-tax-rubl as decimal no-undo .
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
  do
  on error undo, return error return-value
  :
define buffer buff-goods   for ub.goods    .
define buffer buf_gds-obj  for ub.gds-obj  .
define buffer buf_parts    for ub.parts    .
define buffer buf_trn-doc  for ub.trn-doc  .
define buffer buf_doc-line for ub.doc-line .
define variable is-petrolium as logical   no-undo .
define variable is-pieces   as  logical   no-undo .
define variable p-in-code   as  character no-undo .
define variable p-obj-type  as  character no-undo .
define variable p-obj-code  as  integer   no-undo .
define variable v-rec as recid no-undo .
define variable t-ret as logical no-undo .
define variable v-total-avrg-base as decimal no-undo .
define variable v-total-avrg-rubl as decimal no-undo .
define variable v-total-avrg-qnty as decimal no-undo .
define variable v-total-road-tax-base     as decimal no-undo .
define variable v-total-road-tax-rubl     as decimal no-undo .
define variable v-all-total-road-tax-base as decimal no-undo .
define variable v-all-total-road-tax-rubl as decimal no-undo .
assign
  p-road-tax-base = 0
  p-road-tax-rubl = 0
  .
  Find first buff-goods no-lock where
             buff-goods.artic     = p-artic and
             buff-goods.prod-type = p-prod-type and
             buff-goods.prod-code = p-prod-code
      no-error .
      if available buff-goods then do:
         v-rec = recid (buff-goods).
         t-ret =  session:SET-WAIT-STATE("GENERAL") .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input p-artic
  ,  input p-prod-type
  ,  input p-prod-code
  , output is-petrolium
  , output is-pieces
  ) .
           t-ret =  session:SET-WAIT-STATE("") .
           if not ( hvrdtax( v-rec ) = true and  is-petrolium = false  )   then  do:
              assign
                p-road-tax-base = 0
                p-road-tax-rubl = 0
                .
               return.
           end.
      end.
      assign
          v-total-avrg-qnty = 0
          v-total-road-tax-base =  0
          v-total-road-tax-rubl =  0
          v-all-total-road-tax-base =  0
          v-all-total-road-tax-rubl =  0
          .
    for each  x_obj-group ,
        each buf_parts no-lock
        where buf_parts.obj-type  = x_obj-group.obj-type
          and buf_parts.obj-code  = x_obj-group.obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.status_   = no
          and buf_parts.out-code  = 'free-zone':U
          and buf_parts.qnty      > 0
      on error undo, return error
      :
         v-total-avrg-qnty = v-total-avrg-qnty + buf_parts.fact-qnty.
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info69 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
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
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
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
          v-all-total-road-tax-base =  v-all-total-road-tax-base + (road-tax-base-loc * buf_parts.fact-qnty)
          v-all-total-road-tax-rubl =  v-all-total-road-tax-rubl + (road-tax-rubl-loc * buf_parts.fact-qnty)
         .
     end.
      if v-total-avrg-qnty > 0 then  do :
      assign
          p-road-tax-base =  v-all-total-road-tax-base  / v-total-avrg-qnty
          p-road-tax-rubl =  v-all-total-road-tax-rubl  / v-total-avrg-qnty
          .
      end.
      if v-total-avrg-qnty <= 0 then do :
          run last-incom-S in this-procedure
             ( input p-artic
              ,input p-prod-type
              ,input p-prod-code
              ,output p-in-code
              ,output p-obj-type
              ,output p-obj-code ).
            find first  buf_trn-doc no-lock  where buf_trn-doc.doc-code  = p-in-code no-error .
            find first  buf_doc-line no-lock where  buf_doc-line.doc-code = p-in-code
                    and buf_doc-line.artic     = p-artic
                    and buf_doc-line.prod-type = p-prod-type
                    and buf_doc-line.prod-code = p-prod-code
            no-error.
            if available buf_doc-line then do :
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info70 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
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
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
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
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
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
              assign
                p-road-tax-rubl =  road-tax-rubl-loc
                p-road-tax-base =  road-tax-base-loc
                .
            end.
      end.
  end.
end procedure.
procedure calc-sigma :
 do
 on error undo, return error return-value
 :
define input parameter l-bcode like ub.price-list.b-code no-undo .
define input-output parameter new-price as decimal no-undo .
define input parameter l-host as integer no-undo .
define input parameter l-code as integer no-undo .
define input parameter l-type as character no-undo .
define output parameter p-ret as logical no-undo .
define variable conf-par     as character no-undo.
define variable par-type     as character no-undo.
define variable i-sigma as decimal no-undo .
define variable cur-pr like ub.price-list.price-sale no-undo.
define variable cur-rt like ub.price-list.road-tax   no-undo.
define variable cur-ex like ub.price-list.excise     no-undo.
define variable cur-dn like ub.price-list.doc-num    no-undo.
define variable old-price as decimal no-undo .
p-ret = true  .
if par-pr-sigma <> ? and par-pr-sigma <> "" and par-pr-sigma <> "0" then do:
define variable vss-include-info71 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  l-type
  ,input  l-code
  ,input  l-bcode
  ,input  0
  ,input  0
  ,output cur-dn
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  )  .
old-price = cur-pr .
if old-price =  new-price then do:
   p-ret = true .
   return.
end.
   i-sigma = decimal(par-pr-sigma) .
   if ( 100 * ABSOLUTE( old-price - new-price ) / old-price ) <= i-sigma then do:
       p-ret = false .
       new-price = old-price.
       end.
   else p-ret = true .
end.
 end.
end procedure.
define variable vss-include-info72 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable var-pr-r-b as character no-undo .
define variable v-str2 as character no-undo .
define variable vss-include-info73 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-pr-r-b
  )  .
function f-base-code return integer ( p-b-code as integer ).
  define variable main-b-code as integer   no-undo .
  define buffer buf_bar-code for ub.bar-code  .
  find first buf_bar-code no-lock where
            buf_bar-code.b-code = p-b-code no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_bar-code.gds-code
  ,input  ?
  ,output main-b-code
  )  .
  return (main-b-code).
end function.
function fnc-cost-pc return decimal (buffer local-price-list for ub.price-doc-forming-gds ).
  define variable f-cost     as decimal no-undo .
  define variable f-cost-pc  as decimal no-undo .
  define variable v-qnty     as decimal no-undo .
  define variable v-sum      as decimal no-undo .
  define variable fact_price as decimal no-undo .
  find first ub.goods where ub.goods.artic     = local-price-list.artic and
                            ub.goods.prod-type = local-price-list.prod-type and
                            ub.goods.prod-code = local-price-list.prod-code no-lock
                            no-error .
  assign
    v-sum  =  0
    v-qnty =  0
    .
  for each x_obj-group :
      find ub.gds-obj no-lock where
          ub.gds-obj.gds-code = ub.goods.gds-code and
          ub.gds-obj.obj-type = x_obj-group.obj-type and
          ub.gds-obj.obj-code = x_obj-group.obj-code no-error.
      if  available ub.gds-obj then
        if ub.goods.gds-type = 'т':U then
          assign
            v-sum  = v-sum  + ( if var-pr-r-b = "rubl" then ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base) * ub.gds-obj.avrg-qnty
            v-qnty =  v-qnty + ub.gds-obj.avrg-qnty
            .
          else  v-sum = ?.
      else v-sum = ?.
  end.
  f-cost = v-sum / v-qnty .
  fact_price = if var-pr-r-b = "rubl" then local-price-list.price-sale-rubl else local-price-list.price-sale-base .
  f-cost-pc = ( round ( fact_price / f-cost , 2 ) -  1 ) * 100.
  return (f-cost-pc).
end function.
function fnc-pr-pc return decimal (buffer local-price-list for ub.price-doc-forming-gds ).
define variable f-pr     as decimal no-undo .
define variable f-pr-pc  as decimal no-undo.
define variable v-qnty as decimal   no-undo .
define variable v-sum as decimal   no-undo .
define variable fact_price as decimal   no-undo .
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .
 assign
   v-sum  =  0
   v-qnty =  0
   .
for each x_obj-group :
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = x_obj-group.obj-type and
     ub.gds-obj.obj-code = x_obj-group.obj-code  no-error .
if  available ub.gds-obj then do:
  if ub.goods.gds-type = 'т':U then
    assign
      f-pr = (if var-pr-r-b = "rubl" then ub.gds-obj.last-rubl else ub.gds-obj.last-base)
      .
    else f-pr = ?.
end.
else f-pr = ?.
end.
  fact_price = if var-pr-r-b = "rubl" then local-price-list.price-sale-rubl else local-price-list.price-sale-base .
  f-pr-pc = ( round( fact_price / f-pr , 2 ) - 1 ) * 100 .
  return (f-pr-pc).
end function.
function fnc-cost return decimal (buffer local-price-list for ub.price-doc-forming-gds).
define variable f-cost   as decimal no-undo .
find first  x_obj-group.
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code  and
     ub.gds-obj.obj-type = x_obj-group.obj-type and
     ub.gds-obj.obj-code = x_obj-group.obj-code
     no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = 'т':U then
    assign
      f-cost = if var-pr-r-b = "rubl" then ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base
      .
    else  f-cost = ?.
else f-cost = ?.
  return ( f-cost ).
end function.
function fnc-pr return decimal (buffer local-price-list for ub.price-doc-forming-gds).
define variable f-pr   as decimal no-undo .
find first x_obj-group .
find first ub.goods where ub.goods.artic = local-price-list.artic and
                       ub.goods.prod-type = local-price-list.prod-type and
                       ub.goods.prod-code = local-price-list.prod-code no-lock  no-error .
find ub.gds-obj no-lock where
     ub.gds-obj.gds-code = ub.goods.gds-code and
     ub.gds-obj.obj-type = x_obj-group.obj-type and
     ub.gds-obj.obj-code = x_obj-group.obj-code
     no-error.
if  available ub.gds-obj then
  if ub.goods.gds-type = 'т':U then
    assign
      f-pr = if var-pr-r-b = "rubl" then ub.gds-obj.last-rubl  else ub.gds-obj.last-base
      .
    else  f-pr = ?.
else f-pr = ?.
   return ( f-pr ).
end function.
procedure make-fact-order-lib3 :
define input  parameter p-recid as recid no-undo .
define output parameter p-fact-order-sys-from as decimal   no-undo .
define output parameter p-fact-order-sys-to   as decimal   no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-list-type for ub.price-list-type  .
define variable v-shift-end-fact-order as decimal no-undo .
define variable v-day-end-fact-order   as decimal no-undo .
define variable v-fact-order           as decimal no-undo .
  do
  on error undo, return error return-value
  :
find first buf_price-doc-forming  no-lock where recid(buf_price-doc-forming ) = p-recid no-error .
  if error-status :error then return error error-status :get-message(1) .
find first buf_price-list-type  no-lock where
           buf_price-list-type.plt-id = buf_price-doc-forming.plt-id and
           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
  if error-status :error then return error error-status :get-message(1) .
 if buf_price-doc-forming.have-start-period = 1 then do:
    case buf_price-list-type.work-date :
      when int('1':U)  then
        do :
           run day-begin-fact-order
                ( buf_price-doc-forming.start-date ,
                 output p-fact-order-sys-from ) no-error .
                 if error-status :error then
                 return error substitute ( "Ошибка из day-begin-fact-order &1 &2" ,
                                            error-status :get-message(1) ,
                                            return-value ).
        end.
      when int('2':U)   then
        do :
          run factord (
             input   buf_price-doc-forming.start-shift-date
            ,input   buf_price-doc-forming.sys-time
            ,input   1
            ,input   buf_price-doc-forming.start-shift-date
            ,input   buf_price-doc-forming.start-shift-num
            ,input   true
            ,output  p-fact-order-sys-from
            ,output  v-shift-end-fact-order
            ,output  v-day-end-fact-order
            ) no-error  .
            if error-status :error then
                 return error substitute ( "Ошибка из factord &1 &2" ,
                                            error-status :get-message(1) ,
                                            return-value ).
        end.
      when int('3':U)   then
        do :
          run factord (
            input    buf_price-doc-forming.start-sys-date
            ,input   buf_price-doc-forming.start-sys-time
            ,input   (if buf_price-doc-forming.start-sys-time = 0 or buf_price-doc-forming.start-sys-time = ? then 1 else buf_price-doc-forming.start-sys-time )
            ,input   ?
            ,input   ?
            ,input   false
            ,output  p-fact-order-sys-from
            ,output  v-shift-end-fact-order
            ,output  v-day-end-fact-order
            ) no-error .
            if error-status :error then
                 return error substitute ( "Ошибка из factord  - дата сервера &1 &2" ,
                                            error-status :get-message(1) ,
                                            return-value ).
        end.
    end case.
  end.
 if buf_price-doc-forming.have-end-period = 1 then do:
    case buf_price-list-type.work-date :
      when int('1':U)   then
        do :
           run factord-end-day
              ( buf_price-doc-forming.end-date ,
                output p-fact-order-sys-to ) no-error .
                if error-status :error then
                 return error substitute ( "Ошибка из factord-end-day дата на объекте на конец периода &1 &2" ,
                                            error-status :get-message(1) ,
                                            return-value ).
        end.
      when int('2':U)   then
        do :
          run factord (
             input   buf_price-doc-forming.end-shift-date
            ,input   buf_price-doc-forming.sys-time
            ,input   1
            ,input   buf_price-doc-forming.end-shift-date
            ,input   buf_price-doc-forming.end-shift-num
            ,input   true
            ,output  v-fact-order
            ,output  p-fact-order-sys-to
            ,output  v-day-end-fact-order
            ) no-error .
            if error-status :error then
              return error substitute ( "Ошибка из factord сменная дата на конец &1 &2" ,
                                        error-status :get-message(1) ,
                                        return-value ).
        end.
      when int('3':U)   then
        do :
          run factord (
             input   buf_price-doc-forming.end-sys-date
            ,input   buf_price-doc-forming.end-sys-time
            ,input   (if buf_price-doc-forming.end-sys-time  = 0 or buf_price-doc-forming.end-sys-time = ? then 1 else buf_price-doc-forming.end-sys-time )
            ,input   ?
            ,input   ?
            ,input   false
            ,output  p-fact-order-sys-to
            ,output  v-shift-end-fact-order
            ,output  v-day-end-fact-order
            ) no-error .
            if error-status :error then
              return error substitute ( "Ошибка из factord  - дата сервера &1 &2" ,
                                        error-status :get-message(1) ,
                                        return-value ).
        end.
    end case.
  end.
  end.
end procedure.
procedure ver-dfc-mpl-lib3 :
define input  parameter p-recid as recid no-undo .
define buffer buf_price-doc-forming for ub.price-doc-forming  .
define buffer buf_price-list-type for ub.price-list-type  .
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf_price-doc-forming-gds-qnty for ub.price-doc-forming-gds-qnty  .
define buffer buf_price-doc-sum  for ub.price-doc-forming-gds-sum  .
define buffer buf_price-doc-forming-gds-tnv  for ub.price-doc-forming-gds-tnv  .
define variable v-fact-order-sys-from   as decimal   no-undo .
define variable v-fact-order-sys-to     as decimal   no-undo .
  do
  on error undo, return error return-value
 :
find first buf_price-doc-forming  no-lock where recid(buf_price-doc-forming ) = p-recid no-error .
  if error-status :error then return error error-status :get-message(1) .
find first buf_price-list-type  no-lock where
           buf_price-list-type.plt-id = buf_price-doc-forming.plt-id and
           buf_price-list-type.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
  if error-status :error then return error error-status :get-message(1) .
  if buf_price-list-type.stts = integer('1':U) then do:
     return error substitute(" ТПЛ &1 в статусе УДАЛЕН ! Закрывать с ним новые ДНЦ нельзя !" , buf_price-list-type.name )  .
  end.
  if buf_price-list-type.bgr-id > 0 then do:
      find ub.buyer-group where
            ub.buyer-group.stts       = 0  and
            ub.buyer-group.bgr-db-num = buf_price-list-type.bgr-db-num and
            ub.buyer-group.bgr-id     = buf_price-list-type.bgr-id
            no-lock no-error .
      if not available ub.buyer-group then
      return error substitute(" ТПЛ &1 содержит некорректную группу по покупателям &2(&3) !" , buf_price-list-type.name,buf_price-list-type.bgr-id,buf_price-list-type.bgr-db-num )  .
  end.
  if buf_price-list-type.sgr-id > 0 then do:
      find ub.sum-group where
            ub.sum-group.stts       = 0  and
            ub.sum-group.sgr-db-num = buf_price-list-type.sgr-db-num and
            ub.sum-group.sgr-id     = buf_price-list-type.sgr-id
            no-lock no-error .
      if not available ub.sum-group then
      return error substitute(" ТПЛ &1 содержит некорректную суммовую группу &2(&3) !" , buf_price-list-type.name,buf_price-list-type.sgr-id,buf_price-list-type.sgr-db-num )  .
  end.
  if buf_price-list-type.qgr-id > 0 then do:
      find ub.qnty-group where
           ub.qnty-group.stts       = 0  and
           ub.qnty-group.qgr-db-num = buf_price-list-type.qgr-db-num and
           ub.qnty-group.qgr-id     = buf_price-list-type.qgr-id
           no-lock no-error .
      if not available ub.qnty-group then
      return error substitute(" ТПЛ &1 содержит некорректную количественную группу &2(&3) !" , buf_price-list-type.name,buf_price-list-type.qgr-id,buf_price-list-type.qgr-db-num )  .
  end.
  if buf_price-list-type.tog-id > 0 then do:
      find ub.turnover-group where
           ub.turnover-group.stts       = 0  and
           ub.turnover-group.tog-db-num = buf_price-list-type.tog-db-num and
           ub.turnover-group.tog-id     = buf_price-list-type.tog-id
          no-lock no-error .
      if not available ub.turnover-group then
      return error substitute(" ТПЛ &1 содержит некорректную группу по оборотам &2(&3) !" , buf_price-list-type.name , buf_price-list-type.tog-id , buf_price-list-type.tog-db-num )  .
  end.
  if buf_price-list-type.gop-id > 0 then do:
      find ub.grp-obj-price where
            ub.grp-obj-price.stts       = 0  and
            ub.grp-obj-price.gop-db-num = buf_price-list-type.gop-db-num and
            ub.grp-obj-price.gop-id     = buf_price-list-type.gop-id
            no-lock no-error .
      if not available ub.grp-obj-price then
      return error substitute(" ТПЛ &1 содержит некорректную группу по объектам &2(&3) !" , buf_price-list-type.name,buf_price-list-type.gop-id,buf_price-list-type.gop-db-num )  .
  end.
  if buf_price-list-type.gop-id-for-calc-turnover > 0 then do:
      find ub.grp-obj-price where
            ub.grp-obj-price.stts       = 0  and
            ub.grp-obj-price.gop-db-num = buf_price-list-type.gop-db-num-for-calc-turnover and
            ub.grp-obj-price.gop-id     = buf_price-list-type.gop-id-for-calc-turnover
            no-lock no-error .
      if not available ub.grp-obj-price then
      return error substitute(" ТПЛ &1 содержит некорректную группу по объектам &2(&3) !" , buf_price-list-type.name,buf_price-list-type.gop-id-for-calc-turnover,buf_price-list-type.gop-db-num-for-calc-turnover )  .
  end.
   if buf_price-doc-forming.have-start-period = integer(true) then do:
      case buf_price-list-type.work-date :
          when int('1':U)     then
            do :
               if buf_price-doc-forming.start-date = ? then return error "Не задана дата начала действия цен !" .
            end.
          when int('2':U)   then
            do :
                if buf_price-doc-forming.start-shift-date = ? then return error "Не задана сменная дата начала действия цен !" .
                if buf_price-doc-forming.start-shift-num  = ? or
                   buf_price-doc-forming.start-shift-num = 0  then return error "Не задан порядок смены начала действия цен !" .
            end.
          when int('3':U)     then
            do :
                if buf_price-doc-forming.start-sys-date = ? then return error "Не задана дата начала действия цен !" .
                if buf_price-doc-forming.start-sys-time = ? then return error "Не задано время начала действия цен !" .
            end.
      end case.
   end.
   if buf_price-doc-forming.have-end-period = integer(true) then do:
      case buf_price-list-type.work-date :
          when int('1':U)     then
            do :
               if buf_price-doc-forming.end-date = ? then return error "Не задана дата окончания действия цен !" .
            end.
          when int('2':U)   then
            do :
                if buf_price-doc-forming.end-shift-date = ? then return error "Не задана сменная дата окончания действия цен !" .
                if buf_price-doc-forming.end-shift-num  = ? or
                   buf_price-doc-forming.end-shift-num = 0  then return error "Не задан порядок смены окончания  действия цен !" .
            end.
          when int('3':U)     then
            do :
                if buf_price-doc-forming.end-sys-date = ? then return error "Не задана дата окончания действия цен !" .
                if buf_price-doc-forming.end-sys-time = ? then return error "Не задано время окончания действия цен !" .
            end.
      end case.
   end.
   if buf_price-doc-forming.have-start-period = integer(true) and
      buf_price-doc-forming.have-end-period = integer(true) then do:
      case buf_price-list-type.work-date :
          when int('1':U)     then
            do :
               if buf_price-doc-forming.end-date < buf_price-doc-forming.start-date then return error "Не верно задан интервал дат !" .
            end.
          when int('2':U)   then
            do :
                if buf_price-doc-forming.end-shift-date < buf_price-doc-forming.start-shift-date then return error "Не верно задан интервал дат !" .
                if buf_price-doc-forming.end-shift-date = buf_price-doc-forming.start-shift-date then do:
                   if buf_price-doc-forming.end-shift-num < buf_price-doc-forming.start-shift-num then return error "Не верно задан интервал смен !" .
                end.
            end.
          when int('3':U)     then
            do :
                if buf_price-doc-forming.end-sys-date < buf_price-doc-forming.start-sys-date then return error "Не верно задан интервал дат !" .
                if buf_price-doc-forming.end-sys-date = buf_price-doc-forming.start-sys-date then do:
                   if buf_price-doc-forming.end-sys-time < buf_price-doc-forming.start-sys-time then return error "Не верно задан интервал времени !" .
                end.
            end.
      end case.
   end.
if buf_price-doc-forming.name = "" then return error "Не задано название ДНЦ !" .
if buf_price-list-type.main = false then do:
    run make-fact-order-lib3 in this-procedure
        ( input  p-recid ,
          output v-fact-order-sys-from ,
          output v-fact-order-sys-to   ) .
end.
define variable old-price as decimal   no-undo .
define variable v-kol-rec as integer   no-undo .
define variable v-gds-null-price as character no-undo initial "" .
define variable v-type as character no-undo .
v-kol-rec = 0.
for each buf_price-doc-forming-gds no-lock where
         buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
         buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
         buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
         buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      :
    find first ub.bar-code no-lock where
               ub.bar-code.b-code = buf_price-doc-forming-gds.b-code no-error .
               if error-status :error then return error substitute ("Не найден бар-код &1" ,  buf_price-doc-forming-gds.b-code ) .
    find first ub.goods no-lock where
               ub.goods.artic = buf_price-doc-forming-gds.artic         and
               ub.goods.prod-type = buf_price-doc-forming-gds.prod-type and
               ub.goods.prod-code = buf_price-doc-forming-gds.prod-code no-error .
               if error-status :error then return error substitute ("Не найден товар &1 &2 &3" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code) .
    if ub.bar-code.gds-code <> ub.goods.gds-code then return error substitute ("Бар-код &4 не соответствует товару &1 &2 &3" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds.b-code ) .
    run gds-attr-value in this-procedure (input ub.goods.gds-code
                                         ,input 'null-price':U
                                         ,output v-gds-null-price
                                         ,output v-type ) no-error .
    if buf_price-doc-forming-gds.price-sale-doc   = ? or (buf_price-doc-forming-gds.price-sale-doc   = 0 and not logical(v-gds-null-price) )
                then return error substitute ("Продажная цена по товару &1 &2 &3 = &4" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds.price-sale-doc  ) .
    if buf_price-doc-forming-gds.price-sale-rubl  = ? or (buf_price-doc-forming-gds.price-sale-rubl  = 0 and not logical(v-gds-null-price) )
                then return error substitute ("Продажная цена по товару &1 &2 &3 = &4" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds.price-sale-rubl ) .
    if buf_price-doc-forming-gds.price-sale-base  = ? or (buf_price-doc-forming-gds.price-sale-base  = 0 and not logical(v-gds-null-price) )
                then return error substitute ("Продажная цена по товару &1 &2 &3 = &4" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds.price-sale-base ) .
    if buf_price-doc-forming-gds.slt-pc = ? then return error substitute ("НсП по товару &1 &2 &3 не определен" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code) .
    if buf_price-doc-forming-gds.vat-pc = ? then return error substitute ("НДС по товару &1 &2 &3 не определен" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code) .
old-price = ? .
  for each buf_price-doc-forming-gds-qnty no-lock where
           buf_price-doc-forming-gds-qnty.plt-id = buf_price-doc-forming-gds.plt-id and
           buf_price-doc-forming-gds-qnty.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
           buf_price-doc-forming-gds-qnty.pdf-id = buf_price-doc-forming-gds.pdf-id and
           buf_price-doc-forming-gds-qnty.pdf-db = buf_price-doc-forming-gds.pdf-db and
           buf_price-doc-forming-gds-qnty.b-code = buf_price-doc-forming-gds.b-code
           by buf_price-doc-forming-gds-qnty.ggr-qnty :
           if old-price < buf_price-doc-forming-gds-qnty.price-sale-doc and old-price <> ? then do:
              return error substitute ("Цена по товару &1 &2 &3 по категории количество покупки >= &4  больше предыдущей категории (&5 и  &6)" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds-qnty.ggr-qnty ,old-price , buf_price-doc-forming-gds-qnty.price-sale-doc) .
           end.
           old-price = buf_price-doc-forming-gds-qnty.price-sale-doc .
  end.
old-price = ? .
  for each buf_price-doc-sum no-lock where
           buf_price-doc-sum.plt-id     = buf_price-doc-forming-gds.plt-id and
           buf_price-doc-sum.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
           buf_price-doc-sum.pdf-id     = buf_price-doc-forming-gds.pdf-id and
           buf_price-doc-sum.pdf-db     = buf_price-doc-forming-gds.pdf-db and
           buf_price-doc-sum.b-code     = buf_price-doc-forming-gds.b-code
           by buf_price-doc-sum.ssg-summa
           :
           if old-price < buf_price-doc-sum.price-sale-doc and old-price <> ? then do:
              return error substitute ("Цена по товару &1 &2 &3 по категории сумма покупки >= &4  больше предыдущей категории (&5 и  &6)" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-sum.ssg-summa , old-price , buf_price-doc-sum.price-sale-doc) .
           end.
           old-price = buf_price-doc-sum.price-sale-doc .
  end.
old-price = ? .
  for each buf_price-doc-forming-gds-tnv no-lock where
           buf_price-doc-forming-gds-tnv.plt-id     = buf_price-doc-forming-gds.plt-id and
           buf_price-doc-forming-gds-tnv.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
           buf_price-doc-forming-gds-tnv.pdf-id     = buf_price-doc-forming-gds.pdf-id and
           buf_price-doc-forming-gds-tnv.pdf-db     = buf_price-doc-forming-gds.pdf-db and
           buf_price-doc-forming-gds-tnv.b-code     = buf_price-doc-forming-gds.b-code
           by buf_price-doc-forming-gds-tnv.ttg-summa :
           if old-price < buf_price-doc-forming-gds-tnv.price-sale-doc and old-price <> ? then do:
              return error substitute ("Цена по товару &1 &2 &3 по категории сумма оборота покупателя >= &4  больше предыдущей категории (&5 и  &6)" ,  buf_price-doc-forming-gds.artic , buf_price-doc-forming-gds.prod-type ,buf_price-doc-forming-gds.prod-code, buf_price-doc-forming-gds-tnv.ttg-summa ,old-price , buf_price-doc-forming-gds-tnv.price-sale-doc) .
           end.
           old-price = buf_price-doc-forming-gds-tnv.price-sale-doc .
  end.
  define buffer old_price-doc-forming for ub.price-doc-forming  .
  define buffer old_price-doc-forming-gds for ub.price-doc-forming-gds  .
  define buffer old_price-all for ub.price-all.
  if buf_price-list-type.main = false then do:
     for each old_price-doc-forming no-lock where
              old_price-doc-forming.plt-id     = buf_price-list-type.plt-id     and
              old_price-doc-forming.plt-db-num = buf_price-list-type.plt-db-num and
              old_price-doc-forming.stts       = integer('3':U)  ,
              each old_price-doc-forming-gds no-lock where
                    old_price-doc-forming-gds.plt-id     = buf_price-list-type.plt-id      and
                    old_price-doc-forming-gds.plt-db-num = buf_price-list-type.plt-db-num  and
                    old_price-doc-forming-gds.pdf-id     = old_price-doc-forming.pdf-id    and
                    old_price-doc-forming-gds.pdf-db     = old_price-doc-forming.pdf-db    and
                    old_price-doc-forming-gds.b-code     = buf_price-doc-forming-gds.b-code :
             for each old_price-all no-lock where
                      old_price-all.plt-id     = old_price-doc-forming-gds.plt-id      and
                      old_price-all.plt-db-num = old_price-doc-forming-gds.plt-db-num  and
                      old_price-all.pdf-id     = old_price-doc-forming-gds.pdf-id      and
                      old_price-all.pdf-db     = old_price-doc-forming-gds.pdf-db      and
                      old_price-all.b-code     = old_price-doc-forming-gds.b-code      and
                      old_price-all.fact-order-sys-to   >= v-fact-order-sys-from       and
                      old_price-all.fact-order-sys-from <= v-fact-order-sys-to         :
                     return error substitute ("По товару &1 &2 &3 есть цена &6 в пересекающийся период с таким же приоритетом &7 (ДНЦ &4 &5) " ,
                                               buf_price-doc-forming-gds.artic ,
                                               buf_price-doc-forming-gds.prod-type ,
                                               buf_price-doc-forming-gds.prod-code,
                                               old_price-all.pdf-id ,
                                               old_price-all.pdf-db ,
                                               old_price-doc-forming-gds.price-sale-doc ,
                                               old_price-all.plt-priority
                                               ) .
             end.
     end.
     end.
    assign v-kol-rec = v-kol-rec + 1 .
end.
  run ver-pr-equ-qS in this-procedure
    ( input buf_price-doc-forming.plt-id ,
      input buf_price-doc-forming.plt-db-num,
      input buf_price-doc-forming.pdf-id ,
      input buf_price-doc-forming.pdf-db
      ) no-error .
  if error-status :error then  return error  "Ошибка при удалении строки ДНЦ "   .
if v-kol-rec = 0 then return error "no-records":U.
end.
end procedure.
procedure ver-pr-equ-qS :
define input parameter  p-plt-id      as integer   no-undo .
define input parameter  p-plt-db-num  as integer   no-undo .
define input parameter  p-pdf-id      as integer   no-undo .
define input parameter  p-pdf-db      as integer   no-undo .
  do
  on error undo, return error return-value
  :
define variable  l-doc-num2   like ub.price-list.doc-num    no-undo .
define buffer pdf_price-list  for ub.price-doc-forming-gds .
define buffer pp_price-list   for ub.price-doc-forming-gds .
define buffer main_price-list for ub.price-doc-forming-gds .
define buffer alt_price-list  for ub.price-doc-forming-gds .
define buffer buf1-bar-code   for ub.bar-code .
define buffer buf2-bar-code   for ub.bar-code .
define buffer buf_goods for ub.goods  .
define buffer buf2_goods for ub.goods  .
define variable v-num as integer init 0 no-undo .
define variable bbb   as logical no-undo .
define variable l-price-sale like ub.price-list.price-sale no-undo .
define variable l-road-tax   like ub.price-list.road-tax   no-undo .
define variable l-excise     like ub.price-list.excise     no-undo .
define variable l-ok          as logical no-undo .
define variable check-par     as logical no-undo .
define variable main-b-code   as integer no-undo .
define variable par-pr-equ-dq as integer no-undo .
define variable v-price-sale  as decimal no-undo .
define variable vss-include-info74 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
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
    if thbjattr_thbj-attr.prop-code = 'pr-equ-dq':U then par-pr-equ-dq = thbjattr_thbj-attr.property-value-integer .
end.
if par-pr-equ-dq = 1 then return .
for each pdf_price-list exclusive-lock where
         pdf_price-list.plt-id     = p-plt-id     and
         pdf_price-list.plt-db-num = p-plt-db-num and
         pdf_price-list.pdf-id     = p-pdf-id     and
         pdf_price-list.pdf-db     = p-pdf-db     by pdf_price-list.line-num
        :
    if not (pdf_price-list.b-code     = f-base-code (pdf_price-list.b-code) ) then next .
    check-par = false .
   find first x_obj-group no-error .
define variable vss-include-info75 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,input  pdf_price-list.b-code
  ,input  0
  ,input  0
  ,output l-doc-num2
  ,output l-price-sale
  ,output l-road-tax
  ,output l-excise
  ) no-error .
    v-price-sale = l-price-sale .
   for each x_obj-group :
define variable vss-include-info76 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,input  pdf_price-list.b-code
  ,input  0
  ,input  0
  ,output l-doc-num2
  ,output l-price-sale
  ,output l-road-tax
  ,output l-excise
  ) no-error .
    if v-price-sale <> l-price-sale  then do :
      v-price-sale = l-price-sale.
      leave .
    end.
   end.
   find first x_obj-group no-error .
define variable vss-include-info77 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,input  pdf_price-list.b-code
  ,input  0
  ,input  0
  ,output l-doc-num2
  ,output l-price-sale
  ,output l-road-tax
  ,output l-excise
  ) no-error .
      if l-doc-num2 <> ? then do :
        if l-price-sale = pdf_price-list.price-sale-doc
        and v-price-sale = pdf_price-list.price-sale-doc
        then do:
             find first buf_goods no-lock where
                        buf_goods.artic     =  pdf_price-list.artic and
                        buf_goods.prod-type =  pdf_price-list.prod-type and
                        buf_goods.prod-code =  pdf_price-list.prod-code no-error .
            check-par = false .
               for each pp_price-list no-lock where
                        pp_price-list.plt-id     = p-plt-id     and
                        pp_price-list.plt-db-num = p-plt-db-num and
                        pp_price-list.pdf-id     = p-pdf-id     and
                        pp_price-list.pdf-db     = p-pdf-db     and
                        pp_price-list.artic      = pdf_price-list.artic and
                        pp_price-list.prod-type  = pdf_price-list.prod-type  and
                        pp_price-list.prod-code  = pdf_price-list.prod-code ,
                     first buf1-bar-code no-lock where
                          buf1-bar-code.b-code   = pp_price-list.b-code and
                          buf1-bar-code.unit-cli <> buf_goods.unit-base
                    :
                    if  pp_price-list.b-code = f-base-code (pp_price-list.b-code) then next .
                    check-par = true  .
                    leave.
                end.
               for each pp_price-list no-lock where
                        pp_price-list.plt-id     = p-plt-id     and
                        pp_price-list.plt-db-num = p-plt-db-num and
                        pp_price-list.pdf-id     = p-pdf-id     and
                        pp_price-list.pdf-db     = p-pdf-db     and
                        pp_price-list.artic      = pdf_price-list.artic and
                        pp_price-list.prod-type  = pdf_price-list.prod-type  and
                        pp_price-list.prod-code  = pdf_price-list.prod-code and
                        pp_price-list.price-sale-doc <> pdf_price-list.price-sale-doc  ,
                     first buf1-bar-code no-lock where
                          buf1-bar-code.b-code   = pp_price-list.b-code and
                          buf1-bar-code.unit-cli = buf_goods.unit-base
                    :
                    if  pp_price-list.b-code = f-base-code (pp_price-list.b-code) then next .
                    check-par = true  .
                    leave.
                end.
            if check-par = true then next.
            if par-pr-equ-dq = 2 then do:
                  if  ( v-num <= 2  and check-par = false ) then
                      run gbl/d-askw.w
                        (input "Удалить строку?"
                        ,input      "Предыдущая цена РАВНА цене по закрываемому документу " + chr(10)
                                    + " Объект "  + v-cntxt-obj-type + String(v-cntxt-obj-code)
                                    + " Артикул " + pdf_price-list.artic + " " +  buf_goods.gds-name + chr(10)
                                    + " Бар-код " + string(pdf_price-list.b-code)
                                    + " Цена по предыдущему документу переоценки № " + l-doc-num2 + " = "
                                    + string(pdf_price-list.price-sale-doc) + chr(10)
                                    + " Удалить строку? "
                        ,input "|^"
                        ,input "Да|Нет|Да для всех^confirm|Нет для всех^confirm"
                        ,input "Удалить строку|"
                            + "Не удалять строку|"
                            + "Удалять у всех товаров, цена на которые не изменилась|"
                            + "Не удалять у всех товаров, цена на которые не изменилась"
                        ,input 1
                        ,input 2
                        ,output v-num
                        ).
              end.
              else do:
                v-num = 3 .
              end.
                if v-num = 1 then do:
                  run del-doc-line ( input recid(pdf_price-list)) no-error  .
                                  if error-status :error then do:
                                          message  vss-workfile vss-revision vss-description skip
                                          "Ошибка при удаление строки ДНЦ"
                                          pdf_price-list.b-code skip
                                          error-status :get-message(1) .
                                          return error.
                                  end.
                end.
                if v-num = 3  then do:
                   run del-doc-line ( input recid(pdf_price-list)) no-error  .
                end.
        end.
       end.
end.
  for each main_price-list no-lock where
              main_price-list.plt-id      = p-plt-id and
              main_price-list.plt-db-num  = p-plt-db-num and
              main_price-list.pdf-id      = p-pdf-id and
              main_price-list.pdf-db      = p-pdf-db
              :
              if main_price-list.b-code <> f-base-code (main_price-list.b-code) then next.
                for each pp_price-list no-lock where
                          pp_price-list.plt-id       = main_price-list.plt-id     and
                          pp_price-list.plt-db-num   = main_price-list.plt-db-num and
                          pp_price-list.pdf-id       = main_price-list.pdf-id     and
                          pp_price-list.pdf-db       = main_price-list.pdf-db     and
                          pp_price-list.artic        = main_price-list.artic      and
                          pp_price-list.prod-type    = main_price-list.prod-type  and
                          pp_price-list.prod-code    = main_price-list.prod-code  and
                          pp_price-list.b-code      <> main_price-list.b-code     and
                          pp_price-list.price-sale-doc = main_price-list.price-sale-doc  ,
                    first buf_goods no-lock where
                          buf_goods.artic     =  pp_price-list.artic and
                          buf_goods.prod-type =  pp_price-list.prod-type and
                          buf_goods.prod-code =  pp_price-list.prod-code ,
                    first buf1-bar-code no-lock where
                          buf1-bar-code.b-code   = pp_price-list.b-code and
                          buf1-bar-code.unit-cli = buf_goods.unit-base
                          :
                          bbb = true .
                          for each alt_price-list no-lock where
                                  alt_price-list.plt-id     = pp_price-list.plt-id     and
                                  alt_price-list.plt-db-num = pp_price-list.plt-db-num and
                                  alt_price-list.pdf-id     = pp_price-list.pdf-id     and
                                  alt_price-list.pdf-db     = pp_price-list.pdf-db     and
                                  alt_price-list.artic      = pp_price-list.artic      and
                                  alt_price-list.prod-type  = pp_price-list.prod-type  and
                                  alt_price-list.b-code     <> main_price-list.b-code  and
                                  alt_price-list.b-code     <> pp_price-list.b-code    and
                                  alt_price-list.prod-code  = pp_price-list.prod-code ,
                            first buf2_goods no-lock where
                                  buf2_goods.artic     =  pp_price-list.artic     and
                                  buf2_goods.prod-type =  pp_price-list.prod-type and
                                  buf2_goods.prod-code =  pp_price-list.prod-code ,
                            first buf2-bar-code no-lock where
                                  buf2-bar-code.b-code   = alt_price-list.b-code and
                                  buf2-bar-code.unit-cli <> buf2_goods.unit-base and
                                  buf2-bar-code.node-code = buf1-bar-code.node-code
                                :
                                bbb = false.
                                leave.
                          end.
                          if bbb = true  then do:
                              run del-doc-line ( input recid (pp_price-list)) no-error  .
                              if error-status :error then do:
                                  message  vss-workfile vss-revision vss-description skip
                                  " Нельзя удалить " pp_price-list.b-code skip
                                  error-status :get-message(1) .
                              end.
                          end.
                end.
  end.
end.
end procedure.
procedure ver-pr-discnS :
define input  parameter p-plt-id        as integer   no-undo .
define input  parameter p-plt-db-num    as integer   no-undo .
define input  parameter p-pdf-id        as integer   no-undo .
define input  parameter p-pdf-db        as integer   no-undo .
define input  parameter p-mode        as character no-undo .
define input  parameter trn-doc-code  like ub.trn-doc.doc-code no-undo .
define output parameter p-err         as logical no-undo .
  do
  on error undo, return error return-value
  :
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
define buffer b_price-doc-forming-gds for ub.price-doc-forming-gds .
define buffer b_trn-doc    for ub.trn-doc .
define buffer b_doc-line   for ub.doc-line .
define buffer bl_goods     for ub.goods .
define buffer bl_gds-grp   for ub.gds-grp .
define buffer bl_bar-code  for ub.bar-code  .
define buffer buf_bar-code for ub.bar-code  .
define variable v-koff            as decimal   no-undo .
define variable t-prc             as decimal   no-undo .
define variable p-prc-min         as decimal   no-undo .
define variable p-prc-max         as decimal   no-undo .
define variable p-increase-pc     as decimal   no-undo .
define variable p-round-method    as character no-undo .
define variable p-base            as decimal   no-undo .
define variable var-pr-r-b        as character no-undo .
define variable tt-price-sale     as decimal   no-undo .
define variable p-node-code       as integer   no-undo .
define variable p-host-code       as integer   no-undo .
define variable p-obj-type        as character no-undo .
define variable p-obj-code        as integer   no-undo .
define variable p-value-margin    as integer   no-undo .
define variable p-type-margin     as logical   no-undo .
define variable p-value-increase  as integer   no-undo .
define variable p-type-increase   as logical   no-undo .
define variable p-value-rmethod   as integer   no-undo .
define variable p-type-rmethod    as logical   no-undo .
define variable l_price           as decimal   no-undo .
define variable l_pricewithvat    as decimal   no-undo .
define variable l_pricewithoutvat as decimal   no-undo .
define variable l_prod-vat        as decimal   no-undo .
define variable fact_price        as decimal   no-undo .
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
define variable p-attr-code    as character no-undo .
define variable p-b-code       as integer   no-undo .
define variable p-attr-value   as character no-undo .
define variable v-ok           as logical   no-undo .
define variable par-type       as character no-undo.
define variable v-main-b-code  as integer   no-undo .
define variable v-vat-pc       as decimal   no-undo .
define variable vss-include-info78 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-pr-r-b
  )  .
find first x_obj-group .
define variable vss-include-info79 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output p-host-code
  )  .
assign
  p-obj-type   = x_obj-group.obj-type
  p-obj-code   = x_obj-group.obj-code
.
define variable vss-include-info80 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
if trim(par-pr-discm) = "" then return .
if par-pr-discm = 'sale-' then par-pr-discm = 'sale' .
for each  b_price-doc-forming-gds no-lock where
          b_price-doc-forming-gds.plt-id     = p-plt-id      and
          b_price-doc-forming-gds.plt-db-num = p-plt-db-num  and
          b_price-doc-forming-gds.pdf-id     = p-pdf-id      and
          b_price-doc-forming-gds.pdf-db     = p-pdf-db
          :
    find first buf_bar-code no-lock where
               buf_bar-code.b-code  = b_price-doc-forming-gds.b-code
               no-error .
    if available buf_bar-code then v-koff = buf_bar-code.cli-base-rate .
    else v-koff = 1.
    if v-koff = ? or v-koff = 0 then v-koff = 1.
   find first bl_goods no-lock   where
              bl_goods.artic     = b_price-doc-forming-gds.artic     and
              bl_goods.prod-code = b_price-doc-forming-gds.prod-code and
              bl_goods.prod-type = b_price-doc-forming-gds.prod-type
              .
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
      ) .
    if p-type-margin = false  then next.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  bl_goods.gds-code
  ,input  ?
  ,output v-main-b-code
  )  .
    if  trn-doc-code = ? or trn-doc-code = "" then do:
        if v-main-b-code = b_price-doc-forming-gds.b-code then do :
          case  par-pr-discm :
             when "prod":u then do:
define variable vss-include-info81 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_pricewithoutvat
 , output l_price
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
                  fact_price =  if var-pr-r-b = "rubl"
                                then  b_price-doc-forming-gds.price-sale-rubl
                                else  b_price-doc-forming-gds.price-sale-base
                               .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
              when "prod-vat":u then do:
define variable vss-include-info82 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_price
 , output l_pricewithvat
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
                  fact_price =  if var-pr-r-b = "rubl"
                                then  b_price-doc-forming-gds.price-sale-rubl
                                else  b_price-doc-forming-gds.price-sale-base
                               .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
              when "cost-vat":u then do:
                  run str/mplnovat.p
                     (input 'Учет-НДСS':U,
                      input table x_obj-group ,
                      input b_price-doc-forming-gds.b-code,
                      input b_price-doc-forming-gds.artic,
                      input b_price-doc-forming-gds.prod-type,
                      input b_price-doc-forming-gds.prod-code,
                      input 0 ,
                      input ? ,
                      input b_price-doc-forming-gds.vat-pc ,
                      input b_price-doc-forming-gds.slt-pc ,
                      output cost-base   ,
                      output cost-rubl   ,
                      output v-price-base  ,
                      output v-price-rubl  ,
                      output cur-rt-base ,
                      output cur-rt-rubl
                      ).
                  assign
                    l_price    =  if var-pr-r-b = "rubl" then v-price-rubl else v-price-base
                    fact_price =  if var-pr-r-b = "rubl" then b_price-doc-forming-gds.price-sale-rubl else b_price-doc-forming-gds.price-sale-base
                  .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
            when "cost":u       then do:
              t-prc =  fnc-cost-pc (buffer b_price-doc-forming-gds) .
            end.
            when "sale":u then do:
              t-prc =  fnc-pr-pc   (buffer b_price-doc-forming-gds) .
            end.
          end case.
        end.
        else do:
 case  par-pr-discm :
            when "cost":u
            or when "cost-vat":u
            then do:
              l_price =  fnc-cost (buffer b_price-doc-forming-gds) .
              t-prc = ((b_price-doc-forming-gds.price-sale-rubl / v-koff)  / l_price - 1) * 100.
            end.
            when "sale":u then do:
              l_price =  fnc-pr   (buffer b_price-doc-forming-gds) .
              t-prc = (( b_price-doc-forming-gds.price-sale-rubl / v-koff) /  l_price - 1) * 100.
            end.
              when "prod":u then do:
define variable vss-include-info83 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_pricewithoutvat
 , output l_price
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
                  fact_price =  if var-pr-r-b = "rubl"
                                then
                                   b_price-doc-forming-gds.price-sale-rubl  / v-koff
                                else
                                   b_price-doc-forming-gds.price-sale-base  / v-koff
                               .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
              when "prod-vat":u then do:
define variable vss-include-info84 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_price
 , output l_pricewithvat
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
                  fact_price =  if var-pr-r-b = "rubl"
                                then
                                   b_price-doc-forming-gds.price-sale-rubl  / v-koff
                                else
                                   b_price-doc-forming-gds.price-sale-base  / v-koff
                               .
                  t-prc      =  (fact_price / l_price - 1) * 100  .
              end.
          end case.
        end.
    end.
if  trn-doc-code <> ? and trn-doc-code <> "" then do:
    find first b_trn-doc where b_trn-doc.doc-code = trn-doc-code no-lock no-error .
    if available b_trn-doc then find first b_doc-line where
    b_doc-line.doc-code  = b_trn-doc.doc-code and
    b_doc-line.artic     = bl_goods.artic     and
    b_doc-line.prod-code = bl_goods.prod-code and
    b_doc-line.prod-type = bl_goods.prod-type no-lock no-error .
    if b_trn-doc.ext-doc-type = 'ie':U then   pr-gen-margin = par-gen-mrgn-ie.
    if b_trn-doc.ext-doc-type = 'iv':U then   pr-gen-margin = par-gen-mrgn-iv.
    if b_trn-doc.ext-doc-type = 'im':U  then   pr-gen-margin = par-gen-mrgn-im.
    pr-gen-margin = lc(pr-gen-margin).
      if available b_doc-line then do:
      case  par-pr-discm :
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
define variable vss-include-info85 as character format "x(65)" no-undo initial "@(#)$Workfile$".
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
define variable vss-include-info86 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_pricewithoutvat
 , output l_price
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
    end.
   when "prod-vat":u then do:
define variable vss-include-info87 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  b_price-doc-forming-gds.b-code
 , input  p-obj-type
 , input  p-obj-code
 , output l_price
 , output l_pricewithvat
 , output l_prod-vat
 , output v-str2
 , output v-str2
        )  .
    end.
      end case.
        tt-price-sale = b_price-doc-forming-gds.price-sale-rubl .
        t-prc = (( tt-price-sale /  v-koff ) / l_price - 1) * 100.
   end.
end.
  if  p-prc-max <> ? then do:
    if  t-prc <> ? and ( p-prc-max < t-prc  or p-prc-min > t-prc)
    then do:
      message (if v-main-b-code = b_price-doc-forming-gds.b-code then "По товару :"
          else "По признаку"  )
          b_price-doc-forming-gds.artic
          b_price-doc-forming-gds.prod-type
          b_price-doc-forming-gds.prod-code skip
          "бар-код: " b_price-doc-forming-gds.b-code
           ( if v-koff > 1 then substitute("Упаковка на: &1" , v-koff)
             else "" ) skip
          fnc-pr  (buffer b_price-doc-forming-gds)
          skip
        "Процент торговой наценки вышел за интервал возможных значений !!! " skip
        "Процент не менее :" p-prc-min "%" skip
        "Процент не более :" p-prc-max "%" skip
        "Процент фактический :" t-prc  "%"  skip
        "ДНЦ №: " b_price-doc-forming-gds.pdf-id         skip
        "БД" b_price-doc-forming-gds.pdf-db
          view-as alert-box error .
              p-err = true .
              undo , return error .
    end.
    else do:
       if  t-prc = ? then  do:
          message (if v-main-b-code = b_price-doc-forming-gds.b-code then "По товару :"
          else "По признаку"  )
          b_price-doc-forming-gds.artic
          b_price-doc-forming-gds.prod-type
          b_price-doc-forming-gds.prod-code skip
          "бар-код: " b_price-doc-forming-gds.b-code
           ( if v-koff > 1 then substitute("Упаковка на: &1" , v-koff)
             else "" ) skip
          fnc-pr  (buffer b_price-doc-forming-gds)
          skip
          "Нет базовой цены для расчета процента наценки !" skip
          "Процент торговой наценки вышел за интервал возможных значений !!! " skip
          "Процент не менее :" p-prc-min "%" skip
          "Процент не более :" p-prc-max "%" skip
          "Процент фактический :" t-prc  "%"  skip
          "ДНЦ №_: " b_price-doc-forming-gds.pdf-id         skip
          "БД" b_price-doc-forming-gds.pdf-db
          view-as alert-box error .
          p-err = true .
          undo , return error .
       end.
    end.
  end.
end.
  end.
end procedure.
procedure del-doc-line :
define input  parameter p-recid as recid no-undo .
  do
  on error undo, return error return-value
  :
  find first ub.price-doc-forming-gds exclusive-lock where
       recid ( ub.price-doc-forming-gds ) = p-recid  no-error .
   if available ub.price-doc-forming-gds then do:
      delete ub.price-doc-forming-gds no-error .
   end.
  end.
end procedure.
define variable vss-include-info88 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info89 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info90 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
def var vss-include-info91 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info92 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure last-incom-S :
define input parameter  p-artic      like ub.gds-obj.artic      no-undo .
define input parameter  p-prod-type  like ub.gds-obj.prod-type  no-undo .
define input parameter  p-prod-code  like ub.gds-obj.prod-code  no-undo .
define output parameter p-in-code   as character no-undo .
define output parameter p-obj-type  as character no-undo .
define output parameter p-obj-code  as integer   no-undo .
  do
  on error undo, return error return-value
  :
  define buffer buf_trn-doc for ub.trn-doc .
  define buffer buf_gds-obj for ub.gds-obj  .
  do
  on error undo, return error
  :
    assign
      p-in-code  = ""
      p-obj-type = ""
      p-obj-code = 0
    .
     for each x_obj-group ,
      each buf_gds-obj no-lock
      where buf_gds-obj.obj-type  = x_obj-group.obj-type
        and buf_gds-obj.obj-code  = x_obj-group.obj-code
        and buf_gds-obj.artic     = p-artic
        and buf_gds-obj.prod-type = p-prod-type
        and buf_gds-obj.prod-code = p-prod-code
    , first buf_trn-doc no-lock
      where buf_trn-doc.doc-code = buf_gds-obj.in-code
        and buf_trn-doc.status_  = 'факт':U
    on error undo, return error
    by buf_trn-doc.fact-order descending
    :
      assign
        p-in-code  = buf_gds-obj.in-code
        p-obj-type = buf_gds-obj.obj-type
        p-obj-code = buf_gds-obj.obj-code
      .
      leave .
    end.
  end.
  end.
end procedure.
procedure main-road-tax :
def input param p-obj-type  like ub.gds-obj.obj-type  no-undo .
def input param p-obj-code  like ub.gds-obj.obj-code  no-undo .
def input param p-artic     like ub.gds-obj.artic     no-undo .
def input param p-prod-type like ub.gds-obj.prod-type no-undo .
def input param p-prod-code like ub.gds-obj.prod-code no-undo .
def input-output param p-road-tax-base as decimal no-undo .
def input-output param p-road-tax-rubl as decimal no-undo .
define buffer     buff-goods    for ub.goods   .
define buffer     buf_gds-obj   for ub.gds-obj .
define buffer     buf_parts     for ub.parts   .
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
define buffer buf_trn-doc for ub.trn-doc  .
define buffer buf_doc-line for ub.doc-line .
define variable   is-petrolium  as logical             no-undo.
define variable   is-pieces     as logical             no-undo.
define variable v-last-in-code  like ub.gds-obj.in-code  no-undo .
define variable v-last-obj-type like ub.gds-obj.obj-type no-undo .
define variable v-last-obj-code like ub.gds-obj.obj-code no-undo .
def var v-rec as recid no-undo.
def var t-ret as logical no-undo .
def var v-total-avrg-base as decimal no-undo .
def var v-total-avrg-rubl as decimal no-undo .
def var v-total-avrg-qnty as decimal no-undo .
def var v-total-road-tax-base     as decimal no-undo .
def var v-total-road-tax-rubl     as decimal no-undo .
def var v-all-total-road-tax-base as decimal no-undo .
def var v-all-total-road-tax-rubl as decimal no-undo .
assign
  p-road-tax-base = ?
  p-road-tax-rubl = ?
  .
  Find first buff-goods no-lock where
        buff-goods.artic     = p-artic and
        buff-goods.prod-type = p-prod-type and
        buff-goods.prod-code = p-prod-code
        no-error .
      if available buff-goods then do:
           v-rec = recid (buff-goods).
           t-ret =  session:SET-WAIT-STATE("GENERAL") .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input p-artic
  ,  input p-prod-type
  ,  input p-prod-code
  , output is-petrolium
  , output is-pieces
  ) .
           t-ret =  session:SET-WAIT-STATE("") .
           if not ( hvrdtax( v-rec ) = true and  is-petrolium = false  )   then  do:
              assign
                p-road-tax-base = ?
                p-road-tax-rubl = ?
                .
              return.
           end.
      end.
      assign
          v-total-avrg-qnty = 0
          v-total-road-tax-base =  0
          v-total-road-tax-rubl =  0
          v-all-total-road-tax-base =  0
          v-all-total-road-tax-rubl =  0
          .
      for each x_obj-group,
         each buf_parts no-lock
        where buf_parts.obj-type  = x_obj-group.obj-type
          and buf_parts.obj-code  = x_obj-group.obj-code
          and buf_parts.artic     = p-artic
          and buf_parts.prod-type = p-prod-type
          and buf_parts.prod-code = p-prod-code
          and buf_parts.status_   = no
          and buf_parts.out-code  = 'free-zone':U
          and buf_parts.qnty      > 0
      on error undo, return error
      :
         v-total-avrg-qnty = v-total-avrg-qnty + buf_parts.fact-qnty.
assign
  price-rubl-with-tax-loc = buf_parts.price-rubl
  price-base-with-tax-loc = buf_parts.price-base
.
define variable vss-include-info93 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
  if buf_parts.out-code = 'free-zone':U     or
     buf_parts.out-code = 'out-zone':U   or
     buf_parts.doc-type = 'акт':U then do:
    assign
      in-vatp-have-vat-slt = yes.
  end.
  else do:
    find first in-vatp_doc-attr no-lock
      where in-vatp_doc-attr.doc-code  = buf_parts.out-code
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
   price-cli-with-tax-loc = buf_parts.price-cli
   cli-base-rate          = buf_parts.cli-base-rate.
  ASSIGN   road-tax-base-loc  = (if buf_parts.road-tax-base  = ? then 0 else buf_parts.road-tax-base)
           road-tax-rubl-loc  = (if buf_parts.road-tax-rubl  = ? then 0 else buf_parts.road-tax-rubl).
  ASSIGN  transport-base-loc = (if buf_parts.transport-base = ? then 0 else buf_parts.transport-base)
          transport-rubl-loc = (if buf_parts.transport-rubl = ? then 0 else buf_parts.transport-rubl)
          other-base-loc     = (if buf_parts.other-base     = ? then 0 else buf_parts.other-base)
          other-rubl-loc     = (if buf_parts.other-rubl     = ? then 0 else buf_parts.other-rubl)
          vat-pc-loc         = (if buf_parts.vat-pc         = ? then 0 else buf_parts.vat-pc)
          slt-pc-loc         = (if buf_parts.slt-pc         = ? then 0 else buf_parts.slt-pc).
          ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
    ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
  assign
    exch-rate-cli-loc = (buf_parts.price-rubl - transport-rubl-loc - other-rubl-loc - road-tax-rubl-loc - (if buf_parts.vat-type <> 'в т. ч.':U then vat-rubl-loc else 0) - (if buf_parts.slt-type <> 'в т. ч.':U then slt-rubl-loc else 0)) / buf_parts.price-cli .
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
          v-all-total-road-tax-base =  v-all-total-road-tax-base + (road-tax-base-loc * buf_parts.fact-qnty)
          v-all-total-road-tax-rubl =  v-all-total-road-tax-rubl + (road-tax-rubl-loc * buf_parts.fact-qnty)
         .
      end.
          if v-total-avrg-qnty > 0 then  DO :
              assign
                p-road-tax-base =  v-all-total-road-tax-base  / v-total-avrg-qnty
                p-road-tax-rubl =  v-all-total-road-tax-rubl  / v-total-avrg-qnty
                .
          end.
            if v-total-avrg-qnty <= 0 then do :
                run last-incom-S in this-procedure
                ( input   p-artic ,
                  input   p-prod-type,
                  input   p-prod-code ,
                  output  v-last-in-code,
                  output  v-last-obj-type,
                  output  v-last-obj-code ).
                      find buf_trn-doc where buf_trn-doc.doc-code  = v-last-in-code no-lock no-error .
                      find buf_doc-line where     buf_doc-line.doc-code  = v-last-in-code
                                      and buf_doc-line.artic     = p-artic
                                      and buf_doc-line.prod-type = p-prod-type
                                      and buf_doc-line.prod-code = p-prod-code no-lock no-error.
                      if avail buf_doc-line then do :
assign
  price-rubl-with-tax-loc = buf_doc-line.price-rubl
  price-base-with-tax-loc = buf_doc-line.price-base
.
define variable vss-include-info94 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output varinvprb
  )  .
   find first in-vatp_doc-attr no-lock
    where in-vatp_doc-attr.doc-code  = buf_trn-doc.doc-code
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
   find first in-vatp-goods where in-vatp-goods.artic     = buf_doc-line.artic     and
                                     in-vatp-goods.prod-type = buf_doc-line.prod-type and
                                     in-vatp-goods.prod-code = buf_doc-line.prod-code no-lock.
   if (not buf_trn-doc.internal and
           buf_trn-doc.doc-type = 'при':U) or
      in-vatp-goods.gds-type = 'у':U then do:
      if varinvprb = "base":u then do:
        assign
          road-tax-base-loc = buf_doc-line.road-tax
          road-tax-rubl-loc = buf_doc-line.road-tax * buf_trn-doc.base-rate / buf_trn-doc.base-scale.
      end.
      else do:
        ASSIGN
          road-tax-rubl-loc = buf_doc-line.road-tax
          road-tax-base-loc = buf_doc-line.road-tax / buf_trn-doc.base-rate * buf_trn-doc.base-scale.
      end.
      if road-tax-base-loc = ? then road-tax-base-loc = 0.
      if road-tax-rubl-loc = ? then road-tax-rubl-loc = 0.
      assign
        road-tax-cli-loc = ?.
      ASSIGN
        transport-base-loc = (if buf_doc-line.transport-base = ? then 0 else buf_doc-line.transport-base)
        transport-rubl-loc = (if buf_doc-line.transport-rubl = ? then 0 else buf_doc-line.transport-rubl)
        transport-cli-loc  = 0
        other-base-loc     = (if buf_doc-line.other-base     = ? then 0 else buf_doc-line.other-base)
        other-rubl-loc     = (if buf_doc-line.other-rubl     = ? then 0 else buf_doc-line.other-rubl)
        other-cli-loc      = 0
        vat-pc-loc         = (if buf_doc-line.vat-pc         = ? then 0 else buf_doc-line.vat-pc)
        slt-pc-loc         = (if buf_doc-line.slt-pc         = ? then 0 else buf_doc-line.slt-pc).
                              ASSIGN   slt-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-base-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-base-with-tax-loc - ((if road-tax-base-loc  = ? then 0 else road-tax-base-loc) + (if transport-base-loc = ? then 0 else transport-base-loc) + (if other-base-loc = ? then 0 else other-base-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
            ASSIGN   slt-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc)))                           * slt-pc-loc / (100 + slt-pc-loc))                        vat-rubl-loc    = (if in-vatp-have-vat-slt = no then 0 else (price-rubl-with-tax-loc - ((if road-tax-rubl-loc  = ? then 0 else road-tax-rubl-loc) + (if transport-rubl-loc = ? then 0 else transport-rubl-loc) + (if other-rubl-loc = ? then 0 else other-rubl-loc))) * (1 - slt-pc-loc / (100 + slt-pc-loc)) * vat-pc-loc / (100 + vat-pc-loc)).
      assign
        vat-cli-loc            = ?
        slt-cli-loc            = ?
        price-cli-with-tax-loc = ?.
   end.
   else do:
                                                for each in-vatp-parts where in-vatp-parts.out-code  = buf_doc-line.doc-code  and
                                      in-vatp-parts.obj-type  = buf_doc-line.obj-type  and
                                      in-vatp-parts.obj-code  = buf_doc-line.obj-code  and
                                      in-vatp-parts.artic     = buf_doc-line.artic     and
                                      in-vatp-parts.prod-type = buf_doc-line.prod-type and
                                      in-vatp-parts.prod-code = buf_doc-line.prod-code
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
        road-tax-base-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-base  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        road-tax-rubl-loc   = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.road-tax-rubl  * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-base-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-base * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        transport-rubl-loc  = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.transport-rubl * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-base-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-base     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
        other-rubl-loc      = if buf_doc-line.fact-qnty <> 0 then (accum total in-vatp-parts.other-rubl     * in-vatp-parts.fact-qnty) / buf_doc-line.fact-qnty  else 0
                                        vat-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-base-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-base - ((if in-vatp-parts.road-tax-base  = ? then 0 else in-vatp-parts.road-tax-base) + (if in-vatp-parts.transport-base = ? then 0 else in-vatp-parts.transport-base) + (if in-vatp-parts.other-base = ? then 0 else in-vatp-parts.other-base)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
                vat-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty * (1 - in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc)) * in-vatp-parts.vat-pc / (100 + in-vatp-parts.vat-pc))) / buf_doc-line.fact-qnty   else 0
        slt-rubl-loc        = if buf_doc-line.fact-qnty <> 0 then (accum total (if in-vatp-have-vat-slt = no then 0 else (in-vatp-parts.price-rubl - ((if in-vatp-parts.road-tax-rubl  = ? then 0 else in-vatp-parts.road-tax-rubl) + (if in-vatp-parts.transport-rubl = ? then 0 else in-vatp-parts.transport-rubl) + (if in-vatp-parts.other-rubl = ? then 0 else in-vatp-parts.other-rubl)))   * in-vatp-parts.fact-qnty                     * in-vatp-parts.slt-pc / (100 + in-vatp-parts.slt-pc))) / buf_doc-line.fact-qnty   else 0
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
                      Assign
                          p-road-tax-rubl =  road-tax-rubl-loc
                          p-road-tax-base =  road-tax-base-loc
                          .
                      end.
    end.
end procedure.
def var vss-include-info95 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure check-use-bar-code :
  define input  parameter p-b-code    like ub.bar-code.b-code no-undo .
  do
  on error  undo, return error substitute( "&1. &2&3&4", vss-include-info95, return-value, chr(10), error-status :get-message ( error-status :num-messages ) )
  on stop   undo, return error substitute( "&1. stop", vss-include-info95 )
  on endkey undo, return error substitute( "&1. endkey", vss-include-info95 )
  :
    define buffer buf_bar-code for ub.bar-code .
    find first buf_bar-code no-lock
      where buf_bar-code.b-code     = p-b-code
      no-error .
    if not available buf_bar-code then do:
      return error substitute( "&1 (check-use-bar-code). Не найден бар-код &2", vss-include-info95, p-b-code ) .
    end.
    if buf_bar-code.stts = integer('99':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Выполняется удаление бар-кода"
                              ,vss-include-info95
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    if buf_bar-code.stts = integer('79':U) then do:
      return error substitute( "&1 (check-use-bar-code). Нельзя использовать бар-код &2&3"
                              + "Бар-код выключен"
                              ,vss-include-info95
                              ,p-b-code
                              ,chr(10)
                            ) .
    end.
    return .
  end.
end procedure.
define variable vss-include-info96 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info98 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
FUNCTION mark-string RETURNS CHARACTER
  ( input p-recid as recid, input mark-list as character  ) :
  RETURN ( IF LOOKUP( STRING( p-recid), mark-list ) > 0 THEN '*' ELSE '':U ).
END FUNCTION.
define variable vss-include-info99 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure del-pdf-attr-objdel :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = "obj" + p-obj-type + string(p-obj-code)
             no-error .
      if available buf_price-doc-forming-attr then do:
         delete buf_price-doc-forming-attr .
      end.
  end.
end procedure.
procedure ins-pdf-attr-objdel :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = "obj" + p-obj-type + string(p-obj-code)
             no-error .
      if not available  buf_price-doc-forming-attr then do:
         create buf_price-doc-forming-attr.
         assign
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num
             buf_price-doc-forming-attr.plt-id     = p-plt-id
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num
             buf_price-doc-forming-attr.attr-code  = "obj" + p-obj-type + string(p-obj-code)
             buf_price-doc-forming-attr.attr-value = ""
         .
      end.
  end.
end procedure.
procedure ex-pdf-attr-objdel :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-obj-type   as character no-undo .
define input  parameter p-obj-code   as integer   no-undo .
define output parameter p-exist      as logical   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
  p-exist = false .
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = "obj" + p-obj-type + string(p-obj-code)
             no-error .
      if available buf_price-doc-forming-attr then do:
         p-exist = true .
      end.
  end.
end procedure.
procedure pdf-exist :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-attr-code as character no-undo .
define output parameter p-exist      as logical   no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
  p-exist = false .
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = p-attr-code
             no-error .
      if available buf_price-doc-forming-attr then do:
         p-exist = true .
      end.
  end.
end procedure.
procedure pdf-write :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-attr-code as character no-undo .
define input  parameter p-attr-value as character no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = p-attr-code
             no-error .
      if not available buf_price-doc-forming-attr then do:
         create buf_price-doc-forming-attr.
         assign
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num
             buf_price-doc-forming-attr.plt-id     = p-plt-id
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num
             buf_price-doc-forming-attr.attr-code  = p-attr-code
         .
      end.
      buf_price-doc-forming-attr.attr-value = p-attr-value .
  end.
end procedure.
procedure pdf-value :
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-pdf-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-attr-code  as character no-undo .
define output parameter p-attr-value as character no-undo .
define buffer buf_price-doc-forming-attr for ub.price-doc-forming-attr  .
  do
  on error undo, return error return-value
  :
  p-attr-value = "" .
  find first buf_price-doc-forming-attr exclusive-lock where
             buf_price-doc-forming-attr.pdf-id     = p-pdf-id      and
             buf_price-doc-forming-attr.pdf-db     = p-pdf-db-num  and
             buf_price-doc-forming-attr.plt-id     = p-plt-id      and
             buf_price-doc-forming-attr.plt-db-num = p-plt-db-num  and
             buf_price-doc-forming-attr.attr-code  = p-attr-code
             no-error .
      if available buf_price-doc-forming-attr then do:
         p-attr-value = buf_price-doc-forming-attr.attr-value .
      end.
  end.
end procedure.
def var vss-include-info100 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info101 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable gds-rec as integer   no-undo .
define variable g#log   as logical   no-undo .
define variable par-is-pharm   as character no-undo .
define variable v-pricewithvat as decimal   no-undo .
define variable v-prod-vat     as decimal   no-undo .
define buffer buf-price-list-type    for ub.price-list-type  .
define buffer buf_qnty-in-qnty-group for ub.qnty-in-qnty-group  .
define buffer buf_sum-in-sum-group   for ub.sum-in-sum-group  .
define buffer buf_tnv-in-tnv-group   for ub.tnv-in-turnover-group  .
define buffer buf_global-state       for ub.global-state  .
define buffer buf_doc-line           for ub.doc-line .
define stream imp.
define variable v-base-code  as integer   no-undo .
define variable v-line-num   as integer   no-undo .
define variable v-sec        as integer   no-undo .
define variable v-exch-rate  as decimal   no-undo .
define variable v-exch-scale as decimal   no-undo .
define variable v-base-rate  as decimal   no-undo .
define variable v-base-scale as decimal   no-undo .
define variable FILL-IN_start-shift-name as character no-undo .
define variable FILL-IN_end-shift-name   as character no-undo .
define variable v-bgr-name               as character no-undo .
define variable v-last-obj-type  as character no-undo .
define variable v-last-obj-code  as integer   no-undo .
define variable p-new-calc-method as character no-undo .
define variable calc-rec as recid no-undo.
define variable del-list as character no-undo.
define variable var-vat-pc as decimal   no-undo .
define variable vss-include-info102 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run basecode in g#library
  (input  v-cntxt-host-code-obj
  ,output v-base-code
  )  .
define temp-table tt_price-doc-forming-gds-xxx no-undo like ub.price-doc-forming-gds-qnty .
define temp-table tt-gds-list no-undo like ub.goods
field nn as integer
index by-nn nn
index by_gds-code gds-code
.
function f-ost-part return decimal
( input p-b-code as integer     ,
  input p-obj-type as character ,
  input p-obj-code as integer   )
  :
define variable v-qnty as decimal   no-undo .
define buffer buf_bar-code for ub.bar-code  .
define buffer buf_parts for ub.parts  .
define buffer buf_gds-obj for ub.gds-obj  .
v-qnty = ? .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = p-b-code no-error .
  find first buf_gds-obj no-lock where
              buf_gds-obj.gds-code  = buf_bar-code.gds-code and
              buf_gds-obj.obj-type  = p-obj-type  and
              buf_gds-obj.obj-code = p-obj-code  no-error .
if buf_bar-code.in-code = "" then do:
   if available buf_gds-obj then  v-qnty =  buf_gds-obj.fact-qnty.
end.
else do:
    find first buf_parts no-lock where
               buf_parts.artic     = buf_gds-obj.artic and
               buf_parts.prod-type = buf_gds-obj.prod-type  and
               buf_parts.prod-code = buf_gds-obj.prod-code  and
               buf_parts.obj-type  = buf_gds-obj.obj-type  and
               buf_parts.obj-code  = buf_gds-obj.obj-code  and
               buf_parts.in-code   = buf_bar-code.in-code    and
               buf_parts.part-code = buf_bar-code.part-code  and
               buf_parts.out-code   = 'free-zone':U and
               buf_parts.rsrv-free  = true and
               buf_parts.status_    = false  no-error .
     if available buf_parts then v-qnty = buf_parts.fact-qnty .
end.
  return v-qnty .
end function.
function func-part-code return character
( input p-rec as recid ) :
define  BUFFER local-pdf FOR ub.price-doc-forming-gds .
define buffer buf_bar-code for ub.bar-code  .
find first local-pdf no-lock where recid (local-pdf) = p-rec no-error .
if error-status :error then return "" .
find first buf_bar-code no-lock where
           buf_bar-code.b-code = local-pdf.b-code no-error .
if error-status :error then return "" .
   return buf_bar-code.part-code .
end function.
function func-old-pc return decimal
( input p-rec as recid ) :
define  BUFFER local-pdf FOR ub.price-doc-forming-gds .
find first local-pdf no-lock where recid (local-pdf) = p-rec no-error .
if error-status :error then return ? .
define variable old-pc as decimal no-undo.
  old-pc = (local-pdf.price-sale-doc / local-pdf.price-prev-doc - 1) * 100.
  if old-pc > 9999 then
    old-pc = ?.
  return (old-pc).
end function.
function func-calc-pc return decimal
( input p-rec as recid ) :
define  BUFFER local-pdf FOR ub.price-doc-forming-gds .
find first local-pdf no-lock where recid (local-pdf) = p-rec no-error .
if error-status :error then return ? .
define variable old-pc as decimal no-undo.
  old-pc = (local-pdf.price-sale-doc / local-pdf.price-calc-doc - 1) * 100.
  if old-pc > 9999 then
    old-pc = ?.
  return (old-pc).
end function.
FUNCTION get-mark RETURNS CHARACTER
(buffer local-doc-line for buf_price-doc-forming-gds ):
if lookup (string (recid (local-doc-line)), del-list) > 0  then return "*".
                                                           else return "".
end function.
function name-grp returns character
 ( buffer loc-table for tt_price-doc-forming-gds-xxx   ) :
   return "" .
end function.
define temp-table tt-table1 no-undo
field f1 as character
field f2 as character
field f3 as character
field f4 as character
.
define temp-table tt-table2 no-undo
field f1 as character
field f2 as character
field f3 as character
field f4 as character
.
define temp-table tt-table3 no-undo
field f1 as character
field f2 as character
field f3 as character
field f4 as character
.
define variable v-name as character no-undo .
define variable sort-column-name as character no-undo .
define variable filter-point as character no-undo init "Документ назначения цены" .
define variable doc-rec as recid no-undo .
FUNCTION fnc-color RETURNS integer
  ( buffer b-goods for ub.goods , buffer b-bar-code for ub.bar-code )  FORWARD.
FUNCTION fnc-gds-name RETURNS CHARACTER
( input p-rec1 as recid , input p-rec2 as recid )  FORWARD.
DEFINE MENU m-chg
       MENU-ITEM m-one-chg      LABEL "Текущая строка -<<ctrl-o>>"
       MENU-ITEM m-all-chg      LABEL "Выбранные строки".
DEFINE MENU m-import
       MENU-ITEM m-import-txt   LABEL "Импорт из txt"
       MENU-ITEM m-import-bb    LABEL "Импорт из списка кодов".
DEFINE BUTTON b-add
     LABEL "&Добав":L
     SIZE 7 BY 1 TOOLTIP "Добавление в переоценку цен на главные коды".
DEFINE BUTTON b-alt
     LABEL "Н&еосн":L
     SIZE 8 BY 1 TOOLTIP "Добавление скидок и цен на неосновные коды".
DEFINE BUTTON b-chg
     LABEL "Рас&чет":L
     SIZE 7 BY 1 TOOLTIP "Пересчет цен в строке (строках)".
DEFINE BUTTON b-cust
     LABEL "Клиенты":L
     SIZE 7.88 BY 1 TOOLTIP "Группа покупателей".
DEFINE BUTTON b-del
     LABEL "&Удал":L
     SIZE 7 BY 1 TOOLTIP "Удаление строк из переоценки".
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Выход":L
     SIZE 6 BY 1 TOOLTIP "Выход из документа с сохранением состояния".
DEFINE BUTTON b-grp
     LABEL "Группы":L
     SIZE 8 BY 1 TOOLTIP "Группы товаров".
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1 TOOLTIP "Помощь".
DEFINE BUTTON B-history
     LABEL "И":L
     SIZE 3.5 BY 1 TOOLTIP "История строки".
DEFINE BUTTON B-import
     IMAGE-UP FILE "cmp/imp-txt.bmp":U
     LABEL "И":L
     SIZE 3.5 BY 1 TOOLTIP "Импорт".
DEFINE BUTTON b-log
     LABEL "п/п":L
     SIZE 4 BY 1 TOOLTIP "Перенумеровать строки".
DEFINE BUTTON b-log-2
     LABEL "п/п":L
     SIZE 4 BY 1 TOOLTIP "Перенумеровать строки".
DEFINE BUTTON b-mark
     LABEL "&*":L
     SIZE 3 BY 1 TOOLTIP "Отметить строки ДНЦ".
DEFINE BUTTON b-next AUTO-GO
     LABEL "&>>":L
     SIZE 3 BY 1 TOOLTIP "Переход к просмотру следующему документу списка".
DEFINE BUTTON b-notes
     LABEL "П&рим":L
     SIZE 8 BY 1 TOOLTIP "Просмотр примечания к ДНЦ".
DEFINE BUTTON b-obj
     LABEL "Объекты":L
     SIZE 8 BY 1 TOOLTIP "Список объектов ценообразования".
DEFINE BUTTON b-prev AUTO-GO
     LABEL "&<<":L
     SIZE 3 BY 1 TOOLTIP "Переход к просмотру предыдущего ДНЦ списка".
DEFINE BUTTON b-sel-all
     LABEL "&+":L
     SIZE 3 BY 1 TOOLTIP "Отметить строки ДНЦ".
DEFINE BUTTON b-special
     LABEL "&Осн":L
     SIZE 7 BY 1 TOOLTIP "Добавление в ДНЦ спеццен на основные коды (шкала)".
DEFINE BUTTON b-type-price
     LABEL "&Т":L
     SIZE 3 BY 1 TOOLTIP "Тип прайс-листа".
DEFINE BUTTON b-unmark
     LABEL "&-":L
     SIZE 3 BY 1 TOOLTIP "Отметить строки ДНЦ".
DEFINE BUTTON r-copy
     IMAGE-UP FILE "btn-down-arrow":U
     IMAGE-DOWN FILE "btn-down-arrow":U
     IMAGE-INSENSITIVE FILE "btn-down-arrow":U
     LABEL "r-copy"
     SIZE 3 BY .88.
DEFINE VARIABLE calc-method AS CHARACTER FORMAT "x(12)"
     LABEL "Исходная"
     VIEW-AS COMBO-BOX INNER-LINES 20
     LIST-ITEMS "Товар","Учетная","Учет-объект","Учет-резерв","Приходная","Прих-объект","Старая","Новая","Объект","Накладная","Переоценка","Накл-безНДС","Учет-безНДС","Стар-безНДС","Единая","НсП","НсП+накл","Отсутствует","Не-считать","Спецификация"
     DROP-DOWN-LIST
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE round-method AS CHARACTER FORMAT "x(15)"
     LABEL "Окру&гление"
     VIEW-AS COMBO-BOX INNER-LINES 7
      LIST-ITEMS
      '9-окончание':U,
      '9-99окончание':U,
      'Без-дробных':U,
      'Произвольно':U,
      'Вверх':U,
      'Коэффициент':U,
      'Отключено':U
     DROP-DOWN-LIST
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN_name AS CHARACTER
     VIEW-AS EDITOR SCROLLBAR-VERTICAL
     SIZE 39.5 BY 1.42 TOOLTIP "Название ДНЦ"
     FONT 4 NO-UNDO.
DEFINE VARIABLE common-price AS DECIMAL FORMAT "->>>,>>>,>>9.99" INITIAL ?
     VIEW-AS FILL-IN
     SIZE 14.5 BY 1 NO-UNDO.
DEFINE VARIABLE copy-code AS INTEGER FORMAT "->,>>>,>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE copy-type AS CHARACTER FORMAT "x(8)"
     VIEW-AS FILL-IN
     SIZE 7 BY 1 NO-UNDO.
DEFINE VARIABLE doc-code AS CHARACTER FORMAT "X(20)"
     VIEW-AS FILL-IN
     SIZE 15 BY 1 NO-UNDO.
DEFINE VARIABLE FILL-IN_base-rate AS DECIMAL FORMAT ">>,>>9.9999" INITIAL 0
     LABEL "Баз.вал."
     VIEW-AS FILL-IN
     SIZE 12 BY .79
     FGCOLOR 1 .
DEFINE VARIABLE FILL-IN_base-scale AS INTEGER FORMAT ">>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY .79
     FGCOLOR 1  NO-UNDO.
DEFINE VARIABLE FILL-IN_end-date AS DATE FORMAT "99/99/99"
     VIEW-AS FILL-IN
     SIZE 9 BY .83 TOOLTIP "Дата объекта".
DEFINE VARIABLE FILL-IN_end-shift-date AS DATE FORMAT "99/99/99"
     VIEW-AS FILL-IN
     SIZE 9 BY .83 TOOLTIP "Сменная дата".
DEFINE VARIABLE FILL-IN_end-shift-num AS INTEGER FORMAT ">>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4 BY .83.
DEFINE VARIABLE FILL-IN_end-sys-date AS DATE FORMAT "99/99/99"
     VIEW-AS FILL-IN
     SIZE 9 BY .83 TOOLTIP "Дата сервера".
DEFINE VARIABLE FILL-IN_exch-rate AS DECIMAL FORMAT ">>,>>9.9999" INITIAL 0
     LABEL "Вал.док."
     VIEW-AS FILL-IN
     SIZE 12 BY .79
     FGCOLOR 1 .
DEFINE VARIABLE FILL-IN_exch-scale AS INTEGER FORMAT ">>>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 5 BY .79
     FGCOLOR 1 .
DEFINE VARIABLE FILL-IN_start-date AS DATE FORMAT "99/99/99"
     VIEW-AS FILL-IN
     SIZE 9 BY .83 TOOLTIP "Дата объекта".
DEFINE VARIABLE FILL-IN_start-shift-date AS DATE FORMAT "99/99/99"
     VIEW-AS FILL-IN
     SIZE 9 BY .83 TOOLTIP "Сменная дата".
DEFINE VARIABLE FILL-IN_start-shift-num AS INTEGER FORMAT ">>9" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 4 BY .83.
DEFINE VARIABLE FILL-IN_start-sys-date AS DATE FORMAT "99/99/99"
     VIEW-AS FILL-IN
     SIZE 9 BY .83 TOOLTIP "Дата сервера".
DEFINE VARIABLE increase-pc AS DECIMAL FORMAT "->>>>>9.<<<<<%" INITIAL 0
     LABEL "На&ценка"
     VIEW-AS FILL-IN
     SIZE 10.25 BY 1 NO-UNDO.
DEFINE VARIABLE l-loc-hour AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время"
     VIEW-AS FILL-IN
     SIZE 3 BY .83 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.
DEFINE VARIABLE l-loc-hour-2 AS INTEGER FORMAT "99":U INITIAL 0
     LABEL "Время"
     VIEW-AS FILL-IN
     SIZE 3 BY .83 TOOLTIP "Стрелка вверх, вниз изменение часа" NO-UNDO.
DEFINE VARIABLE l-loc-min AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY .83 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.
DEFINE VARIABLE l-loc-min-2 AS INTEGER FORMAT "99":U INITIAL 0
     VIEW-AS FILL-IN
     SIZE 3 BY .83 TOOLTIP "Стрелка вверх, вниз изменение минут" NO-UNDO.
DEFINE VARIABLE loc-art AS CHARACTER FORMAT "x(16)"
     LABEL "Артикул"
     VIEW-AS FILL-IN
     SIZE 14 BY .79 TOOLTIP "Поиск по артикулу" NO-UNDO.
DEFINE VARIABLE loc-code AS CHARACTER FORMAT "x(16)"
     LABEL "Бар-код"
     VIEW-AS FILL-IN
     SIZE 14 BY .79 TOOLTIP "Поиск" NO-UNDO.
DEFINE VARIABLE loc-name AS CHARACTER FORMAT "x(20)"
     LABEL "Нач.назв"
     VIEW-AS FILL-IN
     SIZE 14 BY .79 NO-UNDO.
DEFINE VARIABLE obj-in-code AS CHARACTER FORMAT "X(16)"
     LABEL "ПН"
      VIEW-AS TEXT
     SIZE 16.5 BY .67 NO-UNDO.
DEFINE VARIABLE obj-in-date AS DATE FORMAT "99/99/99"
     LABEL "Дата ПН"
      VIEW-AS TEXT
     SIZE 8.63 BY .67 NO-UNDO.
DEFINE VARIABLE p-avrg AS DECIMAL FORMAT "->>>>>>>>>>9.99" INITIAL 0
     LABEL "Цена учет."
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Текущая средняя учетная цена по группе объектов" NO-UNDO.
DEFINE VARIABLE v-free-qnty AS DECIMAL FORMAT "->>>>>>>9.<<" INITIAL ?
     LABEL "Свободно"
      VIEW-AS TEXT
     SIZE 12 BY .67 NO-UNDO.
DEFINE VARIABLE v-fact-qnty AS DECIMAL FORMAT "->>>>>>>9.<<" INITIAL ?
     LABEL "Факт"
      VIEW-AS TEXT
     SIZE 12 BY .67 NO-UNDO.
DEFINE VARIABLE v-in-doc-qnty AS DECIMAL FORMAT "->>>>>>>9.<<" INITIAL ?
     LABEL "Приход"
      VIEW-AS TEXT
     SIZE 12 BY .67 NO-UNDO.
DEFINE VARIABLE p-calc-metod AS CHARACTER FORMAT "x(17)"
      VIEW-AS TEXT
     SIZE 22 BY .67 TOOLTIP "Метод расчета новой продажной цены товара" NO-UNDO.
DEFINE VARIABLE p-last AS DECIMAL FORMAT "->>>>>>>>>>9.99" INITIAL 0
     LABEL "Цена прих."
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Цена последней внешней ПН " NO-UNDO.
DEFINE VARIABLE p-new AS DECIMAL FORMAT "->>>>>>>>>>9.99" INITIAL 0
     LABEL "Цена нов."
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Цена после закрытия ДНЦ"
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE p-old AS DECIMAL FORMAT "->>>>>>>>>>9.99" INITIAL 0
     LABEL "Цена старая"
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Цена предыдущего ДНЦ" NO-UNDO.
DEFINE VARIABLE p-op-avrg AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Старая/Учет"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Старая цена по отношению к учетной цене в процентах" NO-UNDO.
DEFINE VARIABLE p-op-last AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Старая/Прих"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Старая цена по отношению к цене последнего прихода в процентах" NO-UNDO.
DEFINE VARIABLE p-op-pr-doc-old AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Стар/Переоц"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Старая цена по отношению к переоценке в процентах"
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE p-pc-avrg AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Новая/Учет"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Новая цена по отношению к учетной цене в процентах" NO-UNDO.
DEFINE VARIABLE p-pc-last AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Новая/Прих"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Новая цена по отношению к цене последнего прихода в процентах" NO-UNDO.
DEFINE VARIABLE p-pc-op-avrg AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Разница"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Разница процентов (по отношению к учетной цене)" NO-UNDO.
DEFINE VARIABLE p-pc-op-last AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Разница"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Разница процентов (по отношению к цене последнего прихода)" NO-UNDO.
DEFINE VARIABLE p-pc-op-pr-doc-old AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Разница"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Разница процентов (по отношению к учетной цене(факт))"
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE p-pc-pr-doc-old AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Нов/Переоц"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "Новая цена по отношению к переоценке в процентах"
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE p-pc-prev AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Разница"
      VIEW-AS TEXT
     SIZE 10 BY .67 TOOLTIP "На сколько изменилась цена после переоценки в процентах" NO-UNDO.
DEFINE VARIABLE p-pr-doc-old AS DECIMAL FORMAT "->>>>>>>>>>9.99" INITIAL 0
     LABEL "Цена переоц"
      VIEW-AS TEXT
     SIZE 15 BY .67 TOOLTIP "Цена последней переоценки"
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE prev-price_doc-num AS CHARACTER FORMAT "X(16)"
     LABEL "Переоценка"
      VIEW-AS TEXT
     SIZE 16.5 BY .67 TOOLTIP "Номер Переоценки с первого объекта группы".
DEFINE VARIABLE round-base AS DECIMAL FORMAT "->>,>>9.99" INITIAL 0
     VIEW-AS FILL-IN
     SIZE 11 BY 1 NO-UNDO.
DEFINE VARIABLE v-curr-abbr-bv AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-curr-abbr-vd AS CHARACTER FORMAT "X(3)":U
      VIEW-AS TEXT
     SIZE 4 BY .67
     FGCOLOR 4  NO-UNDO.
DEFINE VARIABLE v-new-price-vat AS DECIMAL FORMAT ">>>>>>>>>>9.99":U INITIAL 0
     LABEL "Новая без НДС"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Новая прадажная цена без НДС" NO-UNDO.
DEFINE VARIABLE v-ost AS DECIMAL FORMAT "->>>>>>>>>>9.99":U INITIAL 0
     LABEL "Остаток"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Текущий остаток по партии"
     FGCOLOR 2  NO-UNDO.
DEFINE VARIABLE v-priceprodwithvat-2 AS DECIMAL FORMAT ">>>>>>>>>>9.99":U INITIAL 0
     LABEL "Цена Произ С НДС"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Цена производителя с НДС"
     FGCOLOR 2  NO-UNDO.
DEFINE VARIABLE v-prod-price AS DECIMAL FORMAT ">>>>>>>>>>9.99":U INITIAL 0
     LABEL "Цена Произв без НДС"
      VIEW-AS TEXT
     SIZE 14 BY .67 TOOLTIP "Текущая Цена производителя без НДС"
     FGCOLOR 2  NO-UNDO.
DEFINE VARIABLE v-prod-price-prc AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Нов с НДС/ЦПроизв безНДС"
      VIEW-AS TEXT
     SIZE 8 BY .67 TOOLTIP "Новая цена С НДС по отношению к текущей цене ПРОИЗВОДИТЕЛЯ без НДС в процентах"
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE v-prod-price-prc-2 AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Нов безНДС/ЦПроизв сНДС"
      VIEW-AS TEXT
     SIZE 9 BY .67 TOOLTIP "Новая цена без НДС по отношению к текущей цене ПРОИЗВОДИТЕЛЯ с НДС в процентах"
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE v-prod-price-prc-3 AS DECIMAL FORMAT "->>>>>>9.<<<%":U INITIAL 0
     LABEL "Нов сНДС/ЦПроизв сНДС"
      VIEW-AS TEXT
     SIZE 9 BY .67 TOOLTIP "Новая цена с НДС по отношению к текущей цене ПРОИЗВОДИТЕЛЯ с НДС в процентах"
     FGCOLOR 3  NO-UNDO.
DEFINE VARIABLE a-n-c AS CHARACTER
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "&А", "art",
"&Н", "name",
"&К", "code"
     SIZE 11.5 BY .71 TOOLTIP "Поиск" NO-UNDO.
DEFINE VARIABLE R-mode-code AS INTEGER INITIAL 1
     VIEW-AS RADIO-SET HORIZONTAL
     RADIO-BUTTONS
          "все", 1,
"осн", 2
     SIZE 12 BY 1 TOOLTIP "Все коды или основные" NO-UNDO.
DEFINE VARIABLE FILL-IN_have-end-period AS LOGICAL INITIAL no
     LABEL "Есть конец"
     VIEW-AS TOGGLE-BOX
     SIZE 13.5 BY .83 TOOLTIP "Есть ограничение на период действия" NO-UNDO.
DEFINE VARIABLE FILL-IN_have-start-period AS LOGICAL INITIAL no
     LABEL "Есть начало"
     VIEW-AS TOGGLE-BOX
     SIZE 13.38 BY .83 NO-UNDO.
DEFINE new shared QUERY BROWSE-1 FOR
 buf_price-doc-forming-gds,
 buf_goods,
 buf_bar-code SCROLLING.
DEFINE QUERY BROWSE-2 FOR
      tt_price-doc-forming-gds-xxx SCROLLING.
DEFINE QUERY Dialog-Frame FOR
      buf_price-doc-forming SCROLLING.
DEFINE BROWSE BROWSE-1
  QUERY BROWSE-1 NO-LOCK DISPLAY
      get-mark  (BUFFER buf_price-doc-forming-gds)  COLUMN-LABEL '*'  FORMAT "X(1)":U
    buf_price-doc-forming-gds.line-num  COLUMN-LABEL '№'  FORMAT ">>>>>>9":U
    buf_price-doc-forming-gds.b-code  COLUMN-LABEL 'Бар-код'  FORMAT "99999999999":U
    buf_price-doc-forming-gds.artic  COLUMN-LABEL 'Артикул'  FORMAT "X(16)":U
    buf_bar-code.unit-cli  COLUMN-LABEL 'Ед.'  FORMAT "X(3)":U
    fnc-gds-name ( recid( buf_goods ) , recid( buf_bar-code)) @ v-name  COLUMN-LABEL 'Наименование'  FORMAT "X(60)":U WIDTH 20
    buf_price-doc-forming-gds.vat-pc  COLUMN-LABEL 'НДС%'  FORMAT ">9.9<%":U
    buf_price-doc-forming-gds.price-sale-doc  COLUMN-LABEL 'Новая (вал.док)'  FORMAT "->>>,>>>,>>9.99":U
    buf_price-doc-forming-gds.price-prev-doc  COLUMN-LABEL 'Последняя (вал.док)'  FORMAT "->>>,>>>,>>9.99":U
    func-old-pc(recid(buf_price-doc-forming-gds))  COLUMN-LABEL '%Н/П'  FORMAT "->>>9.99":U
    buf_price-doc-forming-gds.price-calc-doc COLUMN-LABEL 'Исходная  (вал.док)' FORMAT "->>>,>>>,>>9.99":U
    func-calc-pc(recid(buf_price-doc-forming-gds)) COLUMN-LABEL '%Н/И' FORMAT "->>>9.99":U
    buf_price-doc-forming-gds.road-tax-doc COLUMN-LABEL 'Комп.цены (вал.док)' FORMAT "->>>,>>>,>>9.99":U
    buf_price-doc-forming-gds.excise-doc COLUMN-LABEL 'Акциз (вал.док)' FORMAT "->>>,>>>,>>9.99":U
    buf_price-doc-forming-gds.stts COLUMN-LABEL 'Статус' FORMAT "->>>,>>>,>>9.99":U
    buf_price-doc-forming-gds.price-sale-rubl COLUMN-LABEL 'Новая (нац.вал)' FORMAT "->>>,>>>,>>9.99":U
    buf_price-doc-forming-gds.price-prev-rubl COLUMN-LABEL 'Последняя (нац.вал)' FORMAT "->>>,>>>,>>9.99":U
    buf_price-doc-forming-gds.price-calc-rubl COLUMN-LABEL 'Исходная  (нац.вал)' FORMAT "->>>,>>>,>>9.99":U
    buf_price-doc-forming-gds.road-tax-rubl COLUMN-LABEL 'Комп.цены (нац.вал)' FORMAT "->>>,>>>,>>9.99":U
    buf_price-doc-forming-gds.excise-rubl COLUMN-LABEL 'Акциз (нац.вал)' FORMAT "->>>,>>>,>>9.99":U
    buf_price-doc-forming-gds.price-sale-base COLUMN-LABEL 'Новая (баз.вал)' FORMAT "->>>,>>>,>>9.99":U
    buf_price-doc-forming-gds.price-prev-base COLUMN-LABEL 'Последняя (баз.вал)' FORMAT "->>>,>>>,>>9.99":U
    buf_price-doc-forming-gds.price-calc-base COLUMN-LABEL 'Исходная  (баз.вал)' FORMAT "->>>,>>>,>>9.99":U
    buf_price-doc-forming-gds.road-tax-base COLUMN-LABEL 'Комп.цены (баз.вал)' FORMAT "->>>,>>>,>>9.99":U
    buf_price-doc-forming-gds.excise-base COLUMN-LABEL 'Акциз (баз.вал)' FORMAT "->>>,>>>,>>9.99":U
    buf_price-doc-forming-gds.prev-doc-code COLUMN-LABEL 'Посл.ДНЦ' FORMAT "x(20)":U
    func-part-code(recid(buf_price-doc-forming-gds)) COLUMN-LABEL '№ Партии' FORMAT "x(20)":U
    enable
    buf_price-doc-forming-gds.price-sale-doc
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99.75 BY 7.75 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN.
DEFINE BROWSE BROWSE-2
  QUERY BROWSE-2 NO-LOCK DISPLAY
      tt_price-doc-forming-gds-xxx.ggr-qnty COLUMN-LABEL "Количество" FORMAT "->>>,>>>,>>>,>>9.999":U
            WIDTH 16
      tt_price-doc-forming-gds-xxx.price-sale-doc COLUMN-LABEL "Цена (док-та)" FORMAT "->>>,>>>,>>9.99":U
            WIDTH 19
      tt_price-doc-forming-gds-xxx.price-sale-rubl COLUMN-LABEL "Цена (нац.вал)" FORMAT "->>>,>>>,>>9.99":U
            WIDTH 19
      tt_price-doc-forming-gds-xxx.price-sale-base COLUMN-LABEL "Цена (б.в.)" FORMAT "->>>,>>>,>>9.99":U
        WIDTH 19
      tt_price-doc-forming-gds-xxx.d-pcnt COLUMN-LABEL "Скидка %" FORMAT "->>>,>>9.999":U
      ENABLE
          tt_price-doc-forming-gds-xxx.price-sale-doc
    WITH NO-ROW-MARKERS SEPARATORS SIZE 99.75 BY 4.71 ROW-HEIGHT-CHARS .6 FIT-LAST-COLUMN TOOLTIP "Цена продажи по группам".
DEFINE FRAME Dialog-Frame
     b-exit AT ROW 1 COL 1
     b-prev AT ROW 1 COL 7
     b-next AT ROW 1 COL 10
     b-mark AT ROW 1 COL 13 WIDGET-ID 6
     b-sel-all AT ROW 1 COL 16 WIDGET-ID 24
     b-unmark AT ROW 1 COL 19 WIDGET-ID 26
     b-add AT ROW 1 COL 22
     b-del AT ROW 1 COL 29
     b-chg AT ROW 1 COL 36
     b-special AT ROW 1 COL 43
     b-alt AT ROW 1 COL 50
     b-obj AT ROW 1 COL 58
     b-grp AT ROW 1 COL 66
     b-cust AT ROW 1 COL 74
     b-notes AT ROW 1 COL 82
     B-import AT ROW 1 COL 90 WIDGET-ID 4
     B-history AT ROW 1 COL 94 WIDGET-ID 2
     b-help AT ROW 1 COL 97.63
     doc-code AT ROW 1.96 COL 23 COLON-ALIGNED NO-LABEL
     calc-method AT ROW 2 COL 10 COLON-ALIGNED
     common-price AT ROW 2 COL 23 COLON-ALIGNED NO-LABEL
     copy-type AT ROW 2 COL 23 COLON-ALIGNED NO-LABEL
     copy-code AT ROW 2 COL 30 COLON-ALIGNED NO-LABEL
     r-copy AT ROW 2 COL 39.63
     increase-pc AT ROW 2 COL 50 COLON-ALIGNED
     round-method AT ROW 2 COL 73 COLON-ALIGNED
     round-base AT ROW 2 COL 87.63 COLON-ALIGNED NO-LABEL
     FILL-IN_base-rate AT ROW 3 COL 9.5 COLON-ALIGNED
     FILL-IN_base-scale AT ROW 3 COL 21.5 COLON-ALIGNED NO-LABEL
     FILL-IN_have-start-period AT ROW 3 COL 33.63
     FILL-IN_start-date AT ROW 3 COL 45.5 COLON-ALIGNED NO-LABEL
     FILL-IN_start-shift-date AT ROW 3 COL 45.5 COLON-ALIGNED NO-LABEL
     FILL-IN_start-sys-date AT ROW 3 COL 45.75 COLON-ALIGNED NO-LABEL
     FILL-IN_start-shift-num AT ROW 3 COL 54.88 COLON-ALIGNED NO-LABEL
     l-loc-hour AT ROW 3 COL 62 COLON-ALIGNED
     l-loc-min AT ROW 3 COL 65 COLON-ALIGNED NO-LABEL
     R-mode-code AT ROW 3.75 COL 81.13 NO-LABEL
     b-log-2 AT ROW 3.75 COL 93.38
     b-log AT ROW 3.75 COL 93.63
     b-type-price AT ROW 3.75 COL 97.63
     FILL-IN_exch-rate AT ROW 3.83 COL 9.5 COLON-ALIGNED
     FILL-IN_exch-scale AT ROW 3.83 COL 21.5 COLON-ALIGNED NO-LABEL
     FILL-IN_have-end-period AT ROW 3.83 COL 33.63
     FILL-IN_end-shift-date AT ROW 3.83 COL 45.5 COLON-ALIGNED NO-LABEL
     FILL-IN_end-sys-date AT ROW 3.83 COL 45.5 COLON-ALIGNED NO-LABEL
     FILL-IN_end-date AT ROW 3.83 COL 45.5 COLON-ALIGNED NO-LABEL
     FILL-IN_end-shift-num AT ROW 3.83 COL 54.75 COLON-ALIGNED NO-LABEL
     l-loc-hour-2 AT ROW 3.83 COL 62 COLON-ALIGNED
     l-loc-min-2 AT ROW 3.83 COL 65 COLON-ALIGNED NO-LABEL
     BROWSE-1 AT ROW 4.75 COL 1
     BROWSE-2 AT ROW 12.46 COL 1.13
     a-n-c AT ROW 17.33 COL 1 NO-LABEL
     loc-name AT ROW 17.92 COL 11 COLON-ALIGNED
     loc-code AT ROW 17.92 COL 11 COLON-ALIGNED
     loc-art AT ROW 17.92 COL 11 COLON-ALIGNED
     FILL-IN_name AT ROW 21 COL 61.5 NO-LABEL
     v-curr-abbr-bv AT ROW 3.04 COL 27 COLON-ALIGNED NO-LABEL
     v-curr-abbr-vd AT ROW 3.88 COL 27 COLON-ALIGNED NO-LABEL
     p-calc-metod AT ROW 17.33 COL 77 COLON-ALIGNED NO-LABEL
     p-old AT ROW 18 COL 39.13 COLON-ALIGNED
     p-new AT ROW 18 COL 65 COLON-ALIGNED
     p-pc-prev AT ROW 18 COL 89 COLON-ALIGNED
     p-pr-doc-old AT ROW 18.75 COL 12.21 COLON-ALIGNED
     p-op-pr-doc-old AT ROW 18.79 COL 40.5 COLON-ALIGNED
     p-pc-pr-doc-old AT ROW 18.79 COL 66.63 COLON-ALIGNED
     p-pc-op-pr-doc-old AT ROW 18.79 COL 89 COLON-ALIGNED
     p-avrg AT ROW 19.42 COL 11 COLON-ALIGNED
     p-op-avrg AT ROW 19.46 COL 40.5 COLON-ALIGNED
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE .
DEFINE FRAME Dialog-Frame
     p-pc-avrg AT ROW 19.46 COL 66.63 COLON-ALIGNED
     p-pc-op-avrg AT ROW 19.46 COL 89 COLON-ALIGNED
     p-last AT ROW 20.13 COL 11 COLON-ALIGNED
     p-op-last AT ROW 20.17 COL 40.5 COLON-ALIGNED
     p-pc-last AT ROW 20.17 COL 66.63 COLON-ALIGNED
     p-pc-op-last AT ROW 20.17 COL 89 COLON-ALIGNED
     prev-price_doc-num AT ROW 20.92 COL 12 COLON-ALIGNED
     v-free-qnty AT ROW 20.92 COL 40.5 COLON-ALIGNED
     v-ost AT ROW 21.13 COL 44.25 COLON-ALIGNED WIDGET-ID 8
     obj-in-code AT ROW 21.67 COL 11 COLON-ALIGNED
     v-fact-qnty AT ROW 21.67 COL 40.5 COLON-ALIGNED
     v-new-price-vat AT ROW 21.75 COL 44.25 COLON-ALIGNED WIDGET-ID 16
     obj-in-date AT ROW 22.38 COL 11 COLON-ALIGNED
     v-in-doc-qnty AT ROW 22.38 COL 40.5 COLON-ALIGNED
     v-prod-price-prc AT ROW 22.42 COL 89 COLON-ALIGNED WIDGET-ID 14
     v-prod-price AT ROW 22.5 COL 44.25 COLON-ALIGNED WIDGET-ID 12
     v-prod-price-prc-2 AT ROW 23 COL 89 COLON-ALIGNED WIDGET-ID 20
     v-priceprodwithvat-2 AT ROW 23.25 COL 44.25 COLON-ALIGNED WIDGET-ID 18
     v-prod-price-prc-3 AT ROW 23.58 COL 89 COLON-ALIGNED WIDGET-ID 22
     " Информация по строке" VIEW-AS TEXT
          SIZE 22 BY .67 AT ROW 17.25 COL 40
          FGCOLOR 4
     SPACE(39.24) SKIP(6.36)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Документ назначения цены".
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       b-chg:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-chg:HANDLE.
ASSIGN
       B-import:POPUP-MENU IN FRAME Dialog-Frame       = MENU m-import:HANDLE.
ASSIGN
       common-price:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       copy-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       copy-type:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       doc-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       loc-code:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       loc-name:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       r-copy:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON GO OF FRAME Dialog-Frame
DO:
 if p-mode = 'ПРОСМОТР':U then return.
  run save-proc in this-procedure no-error.
  if error-status :error  then do:
  message
    "Ошибка сохранения ! "
    error-status :get-message(1) skip
    return-value skip
    view-as alert-box error
    .
    return no-apply .
  end.
END.
on end-error, stop of frame Dialog-Frame  do:
  apply "choose" to b-exit in frame Dialog-Frame .
  return no-apply.
end.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  p-next-prev = no.
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF a-n-c IN FRAME Dialog-Frame
DO:
  assign a-n-c .
   case a-n-c :
      when "art"
      then do:
         hide loc-name loc-code in frame Dialog-Frame .
         display loc-art with frame Dialog-Frame .
         apply "ENTRY":U to loc-art in frame Dialog-Frame.
      end.
      when "name"
      then do:
         hide loc-art loc-code in frame Dialog-Frame .
         display loc-name with frame Dialog-Frame .
         apply "ENTRY":U to loc-name in frame Dialog-Frame.
      end.
      when "code"
      then do:
         hide loc-name loc-art in frame Dialog-Frame .
         display loc-code with frame Dialog-Frame .
         apply "ENTRY":U to loc-code in frame Dialog-Frame.
      end.
   end case.
END.
ON CHOOSE OF b-add IN FRAME Dialog-Frame
DO:
  empty temp-table tt-gds-list.
  run proc-add-gds in this-procedure  ( input 1 , ?).
  run OpenBr in this-procedure (yes, no, '':U).
  find first buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.line-num   = v-line-num no-error .
   reposition browse-1 to rowid rowid(buf_price-doc-forming-gds) no-error .
   apply "value-changed" to browse-1 in frame Dialog-Frame.
END.
ON CHOOSE OF b-alt IN FRAME Dialog-Frame
DO:
if not available buf_price-doc-forming then return.
if not available buf_bar-code then return.
  run str/mpl-alt.w
  (  input         parParentProc
    ,input         v-last-obj-type
    ,input         v-last-obj-code
    ,input         recid (buf_price-doc-forming)
    ,input         p-mode
    ,input         "code"
    ,input         buf_bar-code.b-code
    ,input-output  round-method
    ,input-output  round-base
    ,input-output  v-sec
    ).
  run OpenBr in this-procedure (yes, no, '':U).
  reposition browse-1 to rowid rowid(buf_price-doc-forming-gds) no-error .
  apply "value-changed" to browse-1 in frame Dialog-Frame.
END.
ON CHOOSE OF b-chg IN FRAME Dialog-Frame
DO:
  run OpenBr in this-procedure (yes, no, '':U).
  apply "value-changed" to browse-1 in frame Dialog-Frame.
END.
ON CHOOSE OF b-cust IN FRAME Dialog-Frame
DO:
  run str/vi-tt.w
    ( table tt-table3 ,
      v-bgr-name + chr(4) + "Код"  + chr(4) + "Покупатели"
    ) .
END.
ON CHOOSE OF b-del IN FRAME Dialog-Frame
DO:
define variable varlog as logical   no-undo .
define variable line-rec as recid no-undo .
define variable rep-rec as recid no-undo .
define variable  varlns-cnt  as integer   no-undo .
define variable rr as recid no-undo .
if del-list = "" then do:
  if not available buf_price-doc-forming-gds then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
  varlog = no.
  message "Удалить строку ДНЦ ?   Вы уверены ?"
                view-as alert-box question buttons OK-Cancel update varlog.
  if NOT varlog then return no-apply.
  line-rec = recid (buf_price-doc-forming-gds).
  g#log = BROWSE-1:select-next-row () in frame Dialog-Frame no-error .
  rep-rec =  recid (buf_price-doc-forming-gds) no-error .
  del-list = "".
  run del-doc-line1 ( line-rec ) .
  run OpenBr in this-procedure (yes, no, '':U).
  reposition BROWSE-1 to recid rep-rec no-error.
  run vc-pdf in this-procedure .
end.
else do:
  varlog = ?.
  message "Удалить строки ДНЦ ?" skip (2)
          "ДА - удалить все отмеченные строки" skip
          "НЕТ - оставить только отмеченные строки и удалить все остальные"
  view-as alert-box question buttons yes-no-cancel update varlog.
  if varlog = ? then return no-apply.
end.
if varlog then do:
  assign
    varlns-cnt = 1.
  do while varlns-cnt <= num-entries (del-list):
    assign
      line-rec   = integer (entry (varlns-cnt, del-list))
      varlns-cnt = varlns-cnt + 1.
      reposition BROWSE-1 to recid line-rec no-error.
      g#log = BROWSE-1:select-next-row () in frame Dialog-Frame no-error .
      rep-rec =  recid (buf_price-doc-forming-gds) no-error .
      run del-doc-line1 ( line-rec ) .
  end.
end.
else do:
  for each buf_price-doc-forming-gds where
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db :
    if can-do (del-list, string (recid (buf_price-doc-forming-gds))) then next.
       line-rec = recid (buf_price-doc-forming-gds) .
        reposition BROWSE-1 to recid line-rec no-error.
        g#log = BROWSE-1:select-next-row () in frame Dialog-Frame no-error .
        rep-rec =  recid (buf_price-doc-forming-gds) no-error .
        run del-doc-line1 ( line-rec ) .
    end.
 end.
del-list = "" .
run OpenBr in this-procedure (yes, no, '':U).
reposition BROWSE-1 to recid rep-rec no-error.
run vc-pdf in this-procedure .
END.
ON CHOOSE OF b-exit IN FRAME Dialog-Frame
DO:
  p-next-prev = NO.
END.
ON CHOOSE OF b-grp IN FRAME Dialog-Frame
DO:
  run str/vi-tt.w
    ( TABLE tt-table2 ,
    "Список групп товаров по документу назначения цены" + chr(4) + " " + chr(4) + "Наименование группы"
    ) .
END.
ON CHOOSE OF B-history IN FRAME Dialog-Frame
DO:
define variable vss-include-info103 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  if not available buf_price-doc-forming-gds then return .
  run ref/cpr-form.w
      ( parParentProc ,
        buf_price-doc-forming-gds.plt-id     ,
        buf_price-doc-forming-gds.plt-db-num ,
        buf_price-doc-forming-gds.pdf-id     ,
        buf_price-doc-forming-gds.pdf-db
        ) .
END.
ON CHOOSE OF b-log IN FRAME Dialog-Frame
DO:
define variable row-i as integer   no-undo .
define variable g-log as logical   no-undo .
  row-i = 0 .
  reposition browse-1 to  row 1 no-error .
  get first  browse-1 exclusive-lock .
  do while available buf_price-doc-forming-gds :
      assign
        row-i = row-i + 1
        buf_price-doc-forming-gds.line-num = row-i
      .
      get next  browse-1 exclusive-lock.
  end.
  release buf_price-doc-forming-gds.
  run OpenBr in this-procedure (yes, no, '':U) .
END.
ON CHOOSE OF b-log-2 IN FRAME Dialog-Frame
DO:
define variable row-i as integer   no-undo .
define variable g-log as logical   no-undo .
  row-i = 0 .
  reposition browse-1 to  row 1 no-error .
  get first  browse-1 exclusive-lock .
  do while available buf_price-doc-forming-gds :
      assign
        row-i = row-i + 1
        buf_price-doc-forming-gds.line-num = row-i
      .
      get next  browse-1 exclusive-lock.
  end.
  release buf_price-doc-forming-gds.
  run OpenBr in this-procedure (yes, no, '':U) .
END.
ON CHOOSE OF b-mark IN FRAME Dialog-Frame
DO:
  run proc-b-mark in this-procedure no-error.
  run vc-pdf in this-procedure .
END.
ON CHOOSE OF b-next IN FRAME Dialog-Frame
DO:
    run proc-b-move(input self:name) no-error.
    if error-status:error then return no-apply.
END.
ON CHOOSE OF b-notes IN FRAME Dialog-Frame
DO:
define variable vss-include-info104 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable notes as character no-undo .
notes = buf_price-doc-forming.des.
if p-mode = 'ПРОСМОТР':U then do:
  run gbl/d-prompt.w (
      'title=Примечание\'
    + 'type=editor\'
    + 'fillin_width=96\'
    + 'fillin_height=15\'
    + 'readonly=yes\'
    , input-output notes).
end.
else do:
   run gbl/d-prompt.w (
      'title=примечание\'
    + 'type=editor\'
    + 'fillin_width=96\'
    + 'fillin_height=15\'
    , input-output notes).
  if return-value = 'false':u
  then do:
    return .
  end.
  if buf_price-doc-forming.des <> notes then do:
    do transaction on error undo, return no-apply :
      find current buf_price-doc-forming exclusive-lock .
      assign
        buf_price-doc-forming.des = notes.
    end.
  end.
end.
END.
ON CHOOSE OF b-obj IN FRAME Dialog-Frame
DO:
  run str/vi-ttpdf.w
  ( TABLE tt-table1 ,
    "Список объектов по документу назначения цены" + chr(4) + "Код" + chr(4) + "Наименование объекта" + chr(4) + "*" ,
    p-mode ,
    buf_price-doc-forming.pdf-id  ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id    ,
    buf_price-doc-forming.plt-db-num
   ) .
   run metod-gop-obj in this-procedure ( v-cntxt-db-num,  buf-price-list-type.gop-id , buf-price-list-type.gop-db-num) .
   run metod-delobj-usr (
    buf_price-doc-forming.pdf-id  ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id    ,
    buf_price-doc-forming.plt-db-num
   ).
   if return-value = "nullobj"  then
   do:
    message
      "Внимание !!! Нет ни одного объекта для ДНЦ !!!"
      view-as alert-box error
      .
     return no-apply .
   end.
END.
ON CHOOSE OF b-prev IN FRAME Dialog-Frame
DO:
define variable vss-include-info105 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    run proc-b-move(input self:name) no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF b-sel-all IN FRAME Dialog-Frame
DO:
  assign del-list = "".
  if not available buf_price-doc-forming-gds then return.
  for each buf_price-doc-forming-gds
     where buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id
       and buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num
       and buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id
       and buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db no-lock :
define variable vss-include-info106 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid107 as character no-undo .
define variable v-num-entry107 as integer   no-undo .
assign
  v-str-recid107 = trim( string( recid( buf_price-doc-forming-gds ) , "->>>>>>>>>>>9":U ) )
  v-num-entry107 = lookup( v-str-recid107 , del-list )
.
if v-num-entry107 > 0 then do:
  assign
    entry( v-num-entry107, del-list ) = "":U
    del-list = trim( replace( del-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    del-list = del-list + ( if del-list = "":U then "":U else chr(44) ) + v-str-recid107
  .
end.
  end.
  BROWSE-1:refresh() in frame Dialog-Frame .
END.
ON CHOOSE OF b-special IN FRAME Dialog-Frame
DO:
 define variable v-rec-id  as recid no-undo .
 if not available buf_price-doc-forming then return.
 if not available buf_bar-code then return.
 v-rec-id = recid(buf_price-doc-forming-gds).
  run add-spec in this-procedure .
  run OpenBr in this-procedure (yes, no, '':U).
  reposition browse-1 to recid v-rec-id no-error.
  apply "value-changed" to browse-1 in frame Dialog-Frame.
END.
ON CHOOSE OF b-type-price IN FRAME Dialog-Frame
DO:
  define variable v-rec-1 as recid no-undo .
  v-rec-1 = recid(buf-price-list-type) .
  run ref/tp-price.w (input parparentproc ,buf-price-list-type.main , input 'ПРОСМОТР':U , input-output v-rec-1) .
END.
ON CHOOSE OF b-unmark IN FRAME Dialog-Frame
DO:
  if not available buf_price-doc-forming-gds then return.
  del-list  = "".
  BROWSE-1:refresh() in frame Dialog-Frame .
  run vc-pdf in this-procedure .
END.
ON LEAVE OF BROWSE-1 IN FRAME Dialog-Frame
DO:
END.
on end-error of buf_price-doc-forming-gds.price-sale-doc in browse browse-1
DO:
   run OpenBr in this-procedure (yes, no, '':U).
end.
on leave of buf_price-doc-forming-gds.price-sale-doc in browse browse-1
DO:
define variable v-rec-id as recid no-undo .
define variable g#log as logical   no-undo .
define variable loc#log as logical   no-undo .
  if not available buf_price-doc-forming-gds then return.
  if decimal (buf_price-doc-forming-gds.price-sale-doc :screen-value in browse browse-1) <> round (buf_price-doc-forming-gds.price-sale-doc,2)
     and buf_bar-code.unit-cli <> buf_goods.unit-base
     then do:
          message "Изменение в режиме НЕОСНОВНЫЕ ЦЕНЫ !" view-as alert-box information .
          display  buf_price-doc-forming-gds.price-sale-doc  with browse browse-1.
          apply "value-changed" to browse-1 in frame Dialog-Frame.
  end.
  if decimal (buf_price-doc-forming-gds.price-sale-doc :screen-value in browse browse-1) <> round (buf_price-doc-forming-gds.price-sale-doc,2)
  and   buf_bar-code.unit-cli = buf_goods.unit-base
    then do:
    g#log = yes.
    message "Строка изменена. Записать это изменение?"
            view-as alert-box question buttons yes-no update g#log.
          if g#log then do:
            find current buf_price-doc-forming-gds exclusive-lock no-error .
            assign  buf_price-doc-forming-gds.price-calc-doc = buf_price-doc-forming-gds.price-sale-doc
                    buf_price-doc-forming-gds.price-sale-doc
                    buf_price-doc-forming-gds.price-sale-rubl = buf_price-doc-forming-gds.price-sale-doc * v-exch-rate / v-exch-scale
                    buf_price-doc-forming-gds.price-sale-base = buf_price-doc-forming-gds.price-sale-rubl / v-base-rate * v-base-scale
                    buf_price-doc-forming-gds.calc-method = 'Отсутствует':U
                    .
                run calc-price-sub in this-procedure
                                 (input  buf_price-doc-forming-gds.b-code,
                                  input  recid (buf_price-doc-forming),
                                  input  calc-method,
                                  input  increase-pc,
                                  input  round-method,
                                  input  round-base,
                                  input  doc-code,
                                  input  common-price,
                                  input  copy-type,
                                  input  copy-code,
                                  output calc-rec ) no-error.
                    run recalc-neos (
                        buf_price-doc-forming-gds.b-code,
                        buf_price-doc-forming-gds.artic,
                        buf_price-doc-forming-gds.prod-type,
                        buf_price-doc-forming-gds.prod-code
                        ) no-error .
                        if error-status :error then do:
                          message
                            vss-workfile vss-revision vss-description skip
                            error-status :get-message(1) skip
                            return-value skip
                            "ошибка пересчета 2"
                            view-as alert-box error
                          .
                        end.
                if error-status :error then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      "calc-price-sub"
                      view-as alert-box error
                    .
                      display  buf_price-doc-forming-gds.price-sale-doc  with browse browse-1.
                      apply "value-changed" to browse-1 in frame Dialog-Frame.
                      undo, return.
                  end.
                run OpenBr in this-procedure (yes, no, '':U).
                reposition browse-1 to recid calc-rec no-error .
            run upd-br-field in this-procedure .
            run make-xxx-line in this-procedure .
            v-rec-id = recid(buf_price-doc-forming-gds).
            run OpenBr in this-procedure (yes, no, '':U).
            reposition browse-1 to recid v-rec-id no-error.
            apply "value-changed" to browse-1 in frame Dialog-Frame.
          end.
    display  buf_price-doc-forming-gds.price-sale-doc  with browse browse-1.
    g#log = browse-1:select-next-row ().
    apply "value-changed" to browse-1 in frame Dialog-Frame.
  end.
END.
ON RETURN OF BROWSE-1 IN FRAME Dialog-Frame
DO:
END.
on return of buf_price-doc-forming-gds.price-sale-doc in browse browse-1
DO:
define variable v-rec-id as recid no-undo .
define variable g#log as logical   no-undo .
define variable loc#log as logical   no-undo .
  if not available buf_price-doc-forming-gds then return.
  if decimal (buf_price-doc-forming-gds.price-sale-doc :screen-value in browse browse-1) <> round (buf_price-doc-forming-gds.price-sale-doc,2)
     and buf_bar-code.unit-cli <> buf_goods.unit-base
     then do:
          message "Изменение в режиме НЕОСНОВНЫЕ ЦЕНЫ !" view-as alert-box information .
          display  buf_price-doc-forming-gds.price-sale-doc  with browse browse-1.
          apply "value-changed" to browse-1 in frame Dialog-Frame.
  end.
  if decimal (buf_price-doc-forming-gds.price-sale-doc :screen-value in browse browse-1) <> round (buf_price-doc-forming-gds.price-sale-doc,2)
  and   buf_bar-code.unit-cli = buf_goods.unit-base
    then do:
            find current buf_price-doc-forming-gds exclusive-lock no-error .
            assign  buf_price-doc-forming-gds.price-calc-doc = buf_price-doc-forming-gds.price-sale-doc
                    buf_price-doc-forming-gds.price-sale-doc
                    buf_price-doc-forming-gds.price-sale-rubl = buf_price-doc-forming-gds.price-sale-doc * v-exch-rate / v-exch-scale
                    buf_price-doc-forming-gds.price-sale-base = buf_price-doc-forming-gds.price-sale-rubl / v-base-rate * v-base-scale
                    buf_price-doc-forming-gds.calc-method = 'Отсутствует':U
                    .
                run calc-price-sub in this-procedure
                                 (input  buf_price-doc-forming-gds.b-code,
                                  input  recid (buf_price-doc-forming),
                                  input  calc-method,
                                  input  increase-pc,
                                  input  round-method,
                                  input  round-base,
                                  input  doc-code,
                                  input  common-price,
                                  input  copy-type,
                                  input  copy-code,
                                  output calc-rec ) no-error.
                    run recalc-neos (
                        buf_price-doc-forming-gds.b-code,
                        buf_price-doc-forming-gds.artic,
                        buf_price-doc-forming-gds.prod-type,
                        buf_price-doc-forming-gds.prod-code
                        ) no-error .
                        if error-status :error then do:
                          message
                            vss-workfile vss-revision vss-description skip
                            error-status :get-message(1) skip
                            return-value skip
                            "ошибка пересчета 2"
                            view-as alert-box error
                          .
                        end.
                if error-status :error then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      "calc-price-sub"
                      view-as alert-box error
                    .
                  end.
            run upd-br-field in this-procedure .
            apply "value-changed" to browse-1 in frame Dialog-Frame.
    display  buf_price-doc-forming-gds.price-sale-doc  with browse browse-1.
  end.
END.
ON row-display OF BROWSE-1 IN FRAME Dialog-Frame
DO:
define variable v-color as integer   no-undo .
v-color =  fnc-color( BUFFER buf_goods, BUFFER buf_bar-code) .
    v-name:fgcolor in browse BROWSE-1 = v-color .
    buf_bar-code.unit-cli:fgcolor in browse BROWSE-1 = v-color .
    buf_price-doc-forming-gds.artic:fgcolor in browse BROWSE-1 = v-color .
    buf_price-doc-forming-gds.b-code:fgcolor in browse BROWSE-1 = v-color .
    buf_price-doc-forming-gds.line-num:fgcolor in browse BROWSE-1 = v-color .
END.
on mouse-select-dblclick of browse-1 in frame Dialog-Frame
do:
define variable stp-cycl as logical no-undo .
define variable t-r as recid no-undo .
define variable g#log  as logical   no-undo .
  if available buf_price-doc-forming-gds then do:
     t-r = recid(buf_price-doc-forming-gds).
     if calc-method =  'Отсутствует':U then do:
        g#log =  session:set-wait-state("") .
        run str/mplform.w (
            input parParentProc ,
            input (if p-mode = 'ПРОСМОТР':U then p-mode else 'ИЗМЕНЕНИЕ':U)   ,
            input recid (buf_price-doc-forming)    ,
            input recid (buf_price-doc-forming-gds) ,
            input increase-pc ,
            input round-method,
            input round-base,
            input calc-method,
            input v-exch-rate,
            input v-exch-scale,
            input v-base-rate ,
            input v-base-scale,
            output stp-cycl ) no-error .
            if error-status :error then message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              "Ошибка"
              view-as alert-box error
            .
            g#log = browse-1:refresh( )  in frame Dialog-Frame.
            apply "value-changed" to browse-1 in frame Dialog-Frame.
            run recalc-neos (
                buf_price-doc-forming-gds.b-code,
                buf_price-doc-forming-gds.artic,
                buf_price-doc-forming-gds.prod-type,
                buf_price-doc-forming-gds.prod-code
                ) no-error .
                if error-status :error then do:
                  message
                    vss-workfile vss-revision vss-description skip
                    error-status :get-message(1) skip
                    return-value skip
                    "ошибка пересчета 2"
                    view-as alert-box error
                  .
                end.
         if p-mode <> 'ПРОСМОТР':U then do:
            run make-xxx-line in this-procedure .
            run OpenBr in this-procedure (yes, no, '':U).
            reposition browse-1 to recid t-r no-error.
            apply "value-changed" to browse-1 in frame Dialog-Frame.
            g#log = browse-1:refresh( )  in frame Dialog-Frame.
         end.
     end.
  end.
end.
ON VALUE-CHANGED OF BROWSE-1 IN FRAME Dialog-Frame
DO:
    IF AVAILABLE buf_price-doc-forming-gds THEN DO:
      OPEN QUERY BROWSE-2 FOR EACH tt_price-doc-forming-gds-xxx OF                                  buf_price-doc-forming-gds NO-LOCK INDEXED-REPOSITION.
      run vc-pdf in this-procedure .
    END.
END.
ON VALUE-CHANGED OF calc-method IN FRAME Dialog-Frame
DO:
  ASSIGN calc-method
  doc-code = ""
  .
  hide copy-type copy-code doc-code common-price r-copy in frame Dialog-Frame.
  run proc-value-1 in this-procedure .
END.
ON VALUE-CHANGED OF FILL-IN_have-end-period IN FRAME Dialog-Frame
DO:
   ASSIGN FILL-IN_have-end-period .
   run proc-end-o in this-procedure  .
END.
ON VALUE-CHANGED OF FILL-IN_have-start-period IN FRAME Dialog-Frame
DO:
    ASSIGN FILL-IN_have-start-period .
    run proc-start-o in this-procedure  .
END.
ON CURSOR-DOWN OF l-loc-hour IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-hour .
  l-loc-hour = l-loc-hour -  1.
  if l-loc-hour < 0 then return no-apply.
  display l-loc-hour with frame Dialog-Frame.
END.
ON CURSOR-UP OF l-loc-hour IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-hour .
  l-loc-hour = l-loc-hour +  1.
  if l-loc-hour > 24 then return no-apply.
  display l-loc-hour with frame Dialog-Frame.
END.
ON LEAVE OF l-loc-hour IN FRAME Dialog-Frame
DO:
    assign frame Dialog-Frame l-loc-hour .
   if l-loc-hour > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if l-loc-hour < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.
   end.
END.
ON CURSOR-DOWN OF l-loc-hour-2 IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-hour-2 .
  l-loc-hour-2 = l-loc-hour-2 -  1.
  if l-loc-hour-2 < 0 then return no-apply.
  display l-loc-hour-2 with frame Dialog-Frame.
END.
ON CURSOR-UP OF l-loc-hour-2 IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-hour-2 .
  l-loc-hour-2 = l-loc-hour-2 +  1.
  if l-loc-hour-2 > 24 then return no-apply.
  display l-loc-hour-2 with frame Dialog-Frame.
END.
ON LEAVE OF l-loc-hour-2 IN FRAME Dialog-Frame
DO:
    assign frame Dialog-Frame l-loc-hour-2 .
   if l-loc-hour-2 > 24 then do:
   message "Часы должны быть   до 24 ! " .
   return no-apply.
   end.
    if l-loc-hour-2 < 0 then do:
   message "Часы должны быть  от 0 до 24 ! " .
   return no-apply.
   end.
END.
ON CURSOR-DOWN OF l-loc-min IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-min .
  l-loc-min = l-loc-min -  1.
  if l-loc-min < 0 then return no-apply.
  display l-loc-min with frame Dialog-Frame.
END.
ON CURSOR-UP OF l-loc-min IN FRAME Dialog-Frame
DO:
   assign  frame Dialog-Frame l-loc-min .
  l-loc-min = l-loc-min +  1.
  if l-loc-min > 59 then return no-apply.
  display l-loc-min with frame Dialog-Frame.
END.
ON LEAVE OF l-loc-min IN FRAME Dialog-Frame
DO:
   assign frame Dialog-Frame l-loc-min .
   if l-loc-min > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.
END.
ON CURSOR-DOWN OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
  assign  frame Dialog-Frame l-loc-min-2 .
  l-loc-min-2 = l-loc-min-2 -  1.
  if l-loc-min-2 < 0 then return no-apply.
  display l-loc-min-2 with frame Dialog-Frame.
END.
ON CURSOR-UP OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
   assign  frame Dialog-Frame l-loc-min-2 .
  l-loc-min-2 = l-loc-min-2 +  1.
  if l-loc-min-2 > 59 then return no-apply.
  display l-loc-min-2 with frame Dialog-Frame.
END.
ON LEAVE OF l-loc-min-2 IN FRAME Dialog-Frame
DO:
   assign frame Dialog-Frame l-loc-min-2 .
   if l-loc-min-2 > 59 then do:
   message "Минуты должны быть  от 0 до 59 ! " .
   return no-apply.
   end.
END.
ON LEAVE OF loc-art IN FRAME Dialog-Frame
DO:
END.
ON CTRL-J OF loc-art IN FRAME Dialog-Frame
do:
  assign loc-art .
  run seach-artic in this-procedure ( loc-art , true  ) no-error .
  if error-status:error then return no-apply.
END.
ON RETURN OF loc-art IN FRAME Dialog-Frame
DO:
assign loc-art no-error .
  if error-status:error then return no-apply.
  run seach-artic in this-procedure ( loc-art , false  ) no-error .
  return no-apply.
END.
ON LEAVE OF loc-code IN FRAME Dialog-Frame
DO:
END.
ON CTRL-J OF loc-code IN FRAME Dialog-Frame
do:
  assign loc-code .
  run seach-code in this-procedure ( loc-code , true  ) no-error .
  if error-status:error then return no-apply.
END.
ON RETURN OF loc-code IN FRAME Dialog-Frame
DO:
assign loc-code no-error .
  if error-status:error then return no-apply.
  run seach-code in this-procedure ( loc-code , false  ) no-error .
  return no-apply.
END.
ON LEAVE OF loc-name IN FRAME Dialog-Frame
DO:
END.
ON CTRL-J OF loc-name IN FRAME Dialog-Frame
do:
  assign loc-name .
  run seach-name in this-procedure ( loc-name , true  ) no-error .
  if error-status:error then return no-apply.
END.
ON RETURN OF loc-name IN FRAME Dialog-Frame
DO:
assign loc-name no-error .
  if error-status:error then return no-apply.
  run seach-name in this-procedure ( loc-name , false  ) no-error .
  return no-apply.
END.
ON CHOOSE OF MENU-ITEM m-all-chg
DO:
define variable v-prt as logical   no-undo .
define variable vrec as recid no-undo .
message
"Рассчитать продажные цены для выбранных товаров ?"
  view-as alert-box question
  BUTTONS yes-no
  UPDATE v-ok as logical .
if not v-ok then return.
if input frame Dialog-Frame increase-pc < - 100 then do:
  message "Наценка не может быть меньше - 100 % !"
          view-as alert-box error.
  apply "entry" to BROWSE-1 in frame Dialog-Frame.
  return no-apply.
end.
if not available buf_price-doc-forming-gds then do:
  message "Задайте товары клавишей 'ДОБАВИТЬ' ! "
          view-as alert-box error.
  return no-apply.
end.
  for each buf_price-doc-forming-gds
     where buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id
       and buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num
       and buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id
       and buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db no-lock :
          assign vrec = recid(buf_price-doc-forming-gds) no-error .
          if lookup(string(vrec), del-list) = 0 then next.
          find first buf_goods
               where buf_goods.artic     = buf_price-doc-forming-gds.artic
                 and buf_goods.prod-type = buf_price-doc-forming-gds.prod-type
                 and buf_goods.prod-code = buf_price-doc-forming-gds.prod-code no-lock no-error .
          empty temp-table  tt-gds-list .
          create tt-gds-list.
          buffer-copy buf_goods to tt-gds-list .
          run ver-bar-code-prt (input buf_price-doc-forming-gds.b-code , output v-prt ) .
          if v-prt then do:
            run proc-add-gds in this-procedure ( 3 , buf_price-doc-forming-gds.b-code ) .
          end.
          else do:
            run proc-add-gds in this-procedure ( 2 , ? ) .
          end.
  end.
reposition browse-1 to recid vrec no-error .
run vc-pdf in this-procedure .
END.
ON CHOOSE OF MENU-ITEM m-import-bb
DO:
  run import-proc in this-procedure  ("bb").
  run OpenBr in this-procedure (yes, no, '':U).
  find first buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.line-num   = v-line-num no-error .
   reposition browse-1 to rowid rowid(buf_price-doc-forming-gds) no-error .
   apply "value-changed" to browse-1 in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-import-txt
DO:
  run import-proc in this-procedure  ("txt").
  run OpenBr in this-procedure (yes, no, '':U).
  find first buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.line-num   = v-line-num no-error .
   reposition browse-1 to rowid rowid(buf_price-doc-forming-gds) no-error .
   apply "value-changed" to browse-1 in frame Dialog-Frame.
END.
ON CHOOSE OF MENU-ITEM m-one-chg
DO:
define variable v-prt as logical   no-undo .
define variable vrec as recid no-undo .
if input frame Dialog-Frame increase-pc < - 100 then do:
  message "Наценка не может быть меньше - 100 % !"
          view-as alert-box error.
  apply "entry" to BROWSE-1 in frame Dialog-Frame.
  return no-apply.
end.
if not available buf_price-doc-forming-gds then do:
  message "Задайте товары клавишей 'ДОБАВИТЬ' ! "
          view-as alert-box error.
  return no-apply.
end.
find first buf_goods no-lock where
           buf_goods.artic     = buf_price-doc-forming-gds.artic          and
           buf_goods.prod-type = buf_price-doc-forming-gds.prod-type  and
           buf_goods.prod-code = buf_price-doc-forming-gds.prod-code  no-error .
empty temp-table  tt-gds-list .
create tt-gds-list.
buffer-copy buf_goods to tt-gds-list .
vrec = recid(buf_price-doc-forming-gds) no-error .
run ver-bar-code-prt (input buf_price-doc-forming-gds.b-code , output v-prt ) .
if v-prt then do:
   run proc-add-gds in this-procedure ( 3 , buf_price-doc-forming-gds.b-code ) .
end.
else do:
   run proc-add-gds in this-procedure ( 2 , ? ) .
   end.
reposition browse-1 to recid vrec no-error .
run vc-pdf in this-procedure .
END.
ON CHOOSE OF r-copy IN FRAME Dialog-Frame
DO:
define variable vss-include-info108 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable loc-ref-list as character no-undo .
define variable ref-list as character no-undo .
define variable ref-rec as recid no-undo .
case calc-method:
  when 'Объект':U then do:
    run ref/cli-all.w
      ( parParentProc
        , "b-sel"
        , ?
        , ?
        , ?
        , ?
        , ?
        , ?
        , output ref-list) .
    apply "entry" to copy-type in frame Dialog-Frame.
    if ref-list = "" then
      return no-apply.
    ref-rec = integer (ref-list).
    find ub.clients where recid (ub.clients) = ref-rec no-lock.
    if not ( ub.clients.obj-type = 'скл':U or
             ub.clients.obj-type = 'маг':U ) then do:
      message "Объектом для копирования цены может быть только склад или магазин."
              view-as alert-box error.
      return no-apply.
    end.
    assign
      copy-code = ub.clients.obj-code
      copy-type = ub.clients.obj-type
      .
    display copy-type copy-code with frame Dialog-Frame.
  end.
  when 'Накладная':U  or
  when 'НсП+накл':U or
  when 'Накл-безНДС':U then do:
    assign
      doc-rec = ?  .
    run str/all-docs.w (input parparentproc, input v-cntxt-host-code-obj, input v-cntxt-obj-type, input v-cntxt-obj-code, input 'объект':U, input ?, input ?, input ?, input ?, input "b-sel":u, input ?, input ?, input ?, output loc-ref-list).
    find ub.trn-doc where recid (ub.trn-doc) = int (loc-ref-list) no-lock no-error .
    if not available ub.trn-doc then do:
      message "Накладная не выбрана."
              view-as alert-box error.
      return no-apply.
    end.
    doc-code = ub.trn-doc.doc-code.
    display doc-code with frame Dialog-Frame.
  end.
  when 'Единая':U then do:
    display common-price with frame Dialog-Frame.
  end.
  when 'ДокФормЦены':U then do:
    run str/docsprls.w ( parparentproc , "all" , ? , ? , "b-sel" , input-output loc-ref-list) .
    find first ub.price-doc-forming no-lock where recid ( ub.price-doc-forming ) = integer ( loc-ref-list ) no-error.
    if not available ub.price-doc-forming then do:
       message "ДНЦ не выбран." error-status :get-message(1)  view-as alert-box error.
       return no-apply.
    end.
    doc-code = string(ub.price-doc-forming.pdf-id) + "|" +  string(ub.price-doc-forming.pdf-db)  .
    display doc-code with frame Dialog-Frame.
  end.
  when 'Переоценка':U then do:
    run str/pr-docs.w (
        input parParentProc ,
        input "b-sel":U ,
        input 'работа':U ,
        input "" ,
        input v-cntxt-obj-type ,
        input v-cntxt-obj-code ,
        input "" ,
        output loc-ref-list ).
    doc-rec = integer ( loc-ref-list ) .
    find ub.price-doc where recid (ub.price-doc) = doc-rec no-lock no-error.
    if not available ub.price-doc then do:
      message "Переоценка не выбрана."
              view-as alert-box error.
      return no-apply.
    end.
    doc-code = ub.price-doc.doc-num.
    display doc-code with frame Dialog-Frame.
  end.
  otherwise do:
         assign
              doc-rec = ?  .
            run str/all-docs.w
               (input parparentproc,
                input v-cntxt-host-code-obj,
                input v-cntxt-obj-type,
                input v-cntxt-obj-code,
                input  'ТИП':U,
                input  ?   ,
                input  'при':U ,
                input  ?         ,
                input  no        ,
                input  "b-sel":U ,
                input  'ie':U,
                input  false          ,
                input  ?              ,
                output loc-ref-list).
            find ub.trn-doc where recid (ub.trn-doc) = int (loc-ref-list) no-lock no-error .
            if not available ub.trn-doc then do:
              message "Накладная не выбрана."
                      view-as alert-box error.
              return no-apply.
            end.
            doc-code = ub.trn-doc.doc-code.
            display doc-code with frame Dialog-Frame.
    end.
end case.
  if par-is-pharm = "yes" then do:
    find first ub.trn-doc no-lock  where ub.trn-doc.doc-code = doc-code no-error .
    if available ub.trn-doc then do:
        message
        "Добавить товары и партии из накладной"
          doc-code "в ДНЦ ?"
          view-as alert-box question
          BUTTONS yes-no
          UPDATE v-ok as logical .
            if v-ok then do:
               empty temp-table tt-gds-list.
               run proc-add-gds in this-procedure  ( input 4 , ? ).
               run OpenBr in this-procedure (yes, no, '':U).
            end.
    end.
  end.
END.
ON VALUE-CHANGED OF R-mode-code IN FRAME Dialog-Frame
DO:
  ASSIGN R-mode-code.
  RUN OpenBr in this-procedure (yes, no, '':U).
END.
ON VALUE-CHANGED OF round-method IN FRAME Dialog-Frame
DO:
 assign round-method .
 run proc-value-2 in this-procedure .
END.
assign
  b-chg     :popup-menu in frame Dialog-Frame         = menu m-chg  :handle
  b-chg     :menu-mouse                                = 1
  b-import  :popup-menu in frame Dialog-Frame         = menu m-import :handle
  b-import  :menu-mouse                                = 1
.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info109 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info110 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info111 as character format "x(65)" no-undo initial "@(#)$Workfile$ Библиотека изменения размеров окна".
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
        v-diasize-browse-handle     = browse BROWSE-1 :handle
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
define variable vss-include-info112 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of FILL-IN_start-shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of FILL-IN_start-shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of FILL-IN_start-shift-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of FILL-IN_start-shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of FILL-IN_start-shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of FILL-IN_start-shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date113
    MENU-ITEM m-ed-date113-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date113-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date113-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date113-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if FILL-IN_start-shift-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      FILL-IN_start-shift-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date113 :HANDLE
      FILL-IN_start-shift-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle113 as handle no-undo .
  assign
    v-label-handle113 = FILL-IN_start-shift-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle113)
  then do:
    if v-label-handle113 :tooltip = ""
    or v-label-handle113 :tooltip = ?
    then do:
      assign
        v-label-handle113 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date113-1 in menu m-ed-date113 DO:
    apply "ctrl-b":U to FILL-IN_start-shift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date113-2 in menu m-ed-date113 DO:
    apply "ctrl-d":U to FILL-IN_start-shift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date113-3 in menu m-ed-date113 DO:
    apply "ctrl-e":U to FILL-IN_start-shift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date113-4 in menu m-ed-date113 DO:
    apply "ctrl-f":U to FILL-IN_start-shift-date in frame Dialog-Frame .
  END.
define variable vss-include-info114 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of FILL-IN_start-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of FILL-IN_start-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of FILL-IN_start-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of FILL-IN_start-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of FILL-IN_start-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of FILL-IN_start-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date115
    MENU-ITEM m-ed-date115-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date115-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date115-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date115-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if FILL-IN_start-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      FILL-IN_start-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date115 :HANDLE
      FILL-IN_start-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle115 as handle no-undo .
  assign
    v-label-handle115 = FILL-IN_start-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle115)
  then do:
    if v-label-handle115 :tooltip = ""
    or v-label-handle115 :tooltip = ?
    then do:
      assign
        v-label-handle115 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date115-1 in menu m-ed-date115 DO:
    apply "ctrl-b":U to FILL-IN_start-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date115-2 in menu m-ed-date115 DO:
    apply "ctrl-d":U to FILL-IN_start-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date115-3 in menu m-ed-date115 DO:
    apply "ctrl-e":U to FILL-IN_start-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date115-4 in menu m-ed-date115 DO:
    apply "ctrl-f":U to FILL-IN_start-date in frame Dialog-Frame .
  END.
define variable vss-include-info116 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of FILL-IN_start-sys-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of FILL-IN_start-sys-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of FILL-IN_start-sys-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of FILL-IN_start-sys-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of FILL-IN_start-sys-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of FILL-IN_start-sys-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date117
    MENU-ITEM m-ed-date117-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date117-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date117-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date117-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if FILL-IN_start-sys-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      FILL-IN_start-sys-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date117 :HANDLE
      FILL-IN_start-sys-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle117 as handle no-undo .
  assign
    v-label-handle117 = FILL-IN_start-sys-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle117)
  then do:
    if v-label-handle117 :tooltip = ""
    or v-label-handle117 :tooltip = ?
    then do:
      assign
        v-label-handle117 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date117-1 in menu m-ed-date117 DO:
    apply "ctrl-b":U to FILL-IN_start-sys-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date117-2 in menu m-ed-date117 DO:
    apply "ctrl-d":U to FILL-IN_start-sys-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date117-3 in menu m-ed-date117 DO:
    apply "ctrl-e":U to FILL-IN_start-sys-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date117-4 in menu m-ed-date117 DO:
    apply "ctrl-f":U to FILL-IN_start-sys-date in frame Dialog-Frame .
  END.
define variable vss-include-info118 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of FILL-IN_end-shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of FILL-IN_end-shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of FILL-IN_end-shift-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of FILL-IN_end-shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of FILL-IN_end-shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of FILL-IN_end-shift-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date119
    MENU-ITEM m-ed-date119-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date119-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date119-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date119-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if FILL-IN_end-shift-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      FILL-IN_end-shift-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date119 :HANDLE
      FILL-IN_end-shift-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle119 as handle no-undo .
  assign
    v-label-handle119 = FILL-IN_end-shift-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle119)
  then do:
    if v-label-handle119 :tooltip = ""
    or v-label-handle119 :tooltip = ?
    then do:
      assign
        v-label-handle119 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date119-1 in menu m-ed-date119 DO:
    apply "ctrl-b":U to FILL-IN_end-shift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date119-2 in menu m-ed-date119 DO:
    apply "ctrl-d":U to FILL-IN_end-shift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date119-3 in menu m-ed-date119 DO:
    apply "ctrl-e":U to FILL-IN_end-shift-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date119-4 in menu m-ed-date119 DO:
    apply "ctrl-f":U to FILL-IN_end-shift-date in frame Dialog-Frame .
  END.
define variable vss-include-info120 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of FILL-IN_end-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of FILL-IN_end-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of FILL-IN_end-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of FILL-IN_end-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of FILL-IN_end-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of FILL-IN_end-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date121
    MENU-ITEM m-ed-date121-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date121-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date121-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date121-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if FILL-IN_end-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      FILL-IN_end-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date121 :HANDLE
      FILL-IN_end-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle121 as handle no-undo .
  assign
    v-label-handle121 = FILL-IN_end-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle121)
  then do:
    if v-label-handle121 :tooltip = ""
    or v-label-handle121 :tooltip = ?
    then do:
      assign
        v-label-handle121 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date121-1 in menu m-ed-date121 DO:
    apply "ctrl-b":U to FILL-IN_end-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date121-2 in menu m-ed-date121 DO:
    apply "ctrl-d":U to FILL-IN_end-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date121-3 in menu m-ed-date121 DO:
    apply "ctrl-e":U to FILL-IN_end-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date121-4 in menu m-ed-date121 DO:
    apply "ctrl-f":U to FILL-IN_end-date in frame Dialog-Frame .
  END.
define variable vss-include-info122 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on ' ' of FILL-IN_end-sys-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on delete-character of FILL-IN_end-sys-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    assign
      self :screen-value = ?
    .
  end.
  return no-apply.
end.
on ctrl-d of FILL-IN_end-sys-date in frame Dialog-Frame
do:
  define variable v-curr-sv-date as date no-undo .
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    run gbl/getcurdt.p
      (output v-curr-sv-date
      ) .
    assign
      self :screen-value = string(v-curr-sv-date) .
    .
  end.
  return no-apply.
end.
on ctrl-b of FILL-IN_end-sys-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      assign
        v-new-sv-date = date( month(v-curr-sv-date), 1, year(v-curr-sv-date))
      .
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-e of FILL-IN_end-sys-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-curr-sv-date as date no-undo .
    define variable v-new-sv-date  as date no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/lastdate.p
        (input  v-curr-sv-date
        ,output v-new-sv-date
        ).
      assign
        self :screen-value = string(v-new-sv-date) .
      .
    end.
  end.
  return no-apply .
end.
on ctrl-f of FILL-IN_end-sys-date in frame Dialog-Frame
do:
  if (can-query (self, "sensitive")
     and
     self :sensitive = true
     )
  or (can-query (self, "read-only")
     and
     self :read-only = false
     )
  then do:
    if self :handle <> focus :handle
    then do:
      apply "entry":u to self .
    end.
    define variable v-ok            as logical   no-undo .
    define variable v-curr-sv-date  as date      no-undo .
    define variable v-description   as character no-undo .
    assign
      v-curr-sv-date = date(self :screen-value) no-error
    .
    if v-curr-sv-date = ?
    then do:
      run gbl/getcurdt.p
        (output v-curr-sv-date
        ) .
    end.
    if v-curr-sv-date <> ?
    then do:
      run gbl/d-inpday.w
        (input ?
        ,input "Выбор даты"
        ,input v-description
        ,input ""
        ,input-output v-curr-sv-date
        ,output v-ok
        ).
      if v-ok = true
      then do:
        assign
          self :screen-value = string(v-curr-sv-date) .
        .
      end.
    end.
  end.
  return no-apply .
end.
  define MENU m-ed-date123
    MENU-ITEM m-ed-date123-1 LABEL "Начало месяца" ACCELERATOR "ALT-1"
    MENU-ITEM m-ed-date123-2 LABEL "Сегодня"       ACCELERATOR "ALT-2"
    MENU-ITEM m-ed-date123-3 LABEL "Конец месяца"  ACCELERATOR "ALT-3"
    MENU-ITEM m-ed-date123-4 LABEL "Календарь"     ACCELERATOR "ALT-4"
    .
  if FILL-IN_end-sys-date :POPUP-MENU in frame Dialog-Frame = ?
  then do:
    ASSIGN
      FILL-IN_end-sys-date :POPUP-MENU in frame Dialog-Frame = MENU m-ed-date123 :HANDLE
      FILL-IN_end-sys-date :MENU-MOUSE in frame Dialog-Frame = 3
    .
  end.
  define variable v-label-handle123 as handle no-undo .
  assign
    v-label-handle123 = FILL-IN_end-sys-date :side-label-handle in frame Dialog-Frame
  .
  if valid-handle (v-label-handle123)
  then do:
    if v-label-handle123 :tooltip = ""
    or v-label-handle123 :tooltip = ?
    then do:
      assign
        v-label-handle123 :tooltip = "Ctrl-D - текущая, Ctrl-B - начало, Ctrl-E - конец, Ctrl-F - календарь, Прав.Клавиша Мыши - Popup Menu"
      .
    end.
  end.
  ON CHOOSE OF MENU-ITEM m-ed-date123-1 in menu m-ed-date123 DO:
    apply "ctrl-b":U to FILL-IN_end-sys-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date123-2 in menu m-ed-date123 DO:
    apply "ctrl-d":U to FILL-IN_end-sys-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date123-3 in menu m-ed-date123 DO:
    apply "ctrl-e":U to FILL-IN_end-sys-date in frame Dialog-Frame .
  END.
  ON CHOOSE OF MENU-ITEM m-ed-date123-4 in menu m-ed-date123 DO:
    apply "ctrl-f":U to FILL-IN_end-sys-date in frame Dialog-Frame .
  END.
define variable vss-include-info124 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on INS of frame Dialog-Frame anywhere do:
  if b-mark :sensitive then DO: apply "CHOOSE":U to b-mark in frame Dialog-Frame. END.
  return no-apply.
end.
define variable vss-include-info125 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure set-filter-name :
define input parameter p-filter-name as character no-undo .
  do with frame Dialog-Frame:
    if p-filter-name > "" then do:
      assign
        frame Dialog-Frame:title
          = frame Dialog-Frame:title + "   ФИЛЬТР: " + p-filter-name.
      .
    end.
    else do:
    end.
  end.
end procedure.
define variable vss-include-info126 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on f5 of frame Dialog-Frame anywhere
do:
  run OpenBr in this-procedure (yes, no, '':U).
    apply "VALUE-CHANGED" to BROWSE-1.
end.
def var sort-labelbrowse-1   as character no-undo .
def var sort-clmnbrowse-1    as handle    no-undo .
def var cur-clmnbrowse-1     as handle    no-undo .
def var cur-clmn-locbrowse-1 as integer   no-undo .
def var re-querybrowse-1     as logical   initial no no-undo .
on start-search, ctrl-o of browse-1 in frame Dialog-Frame do:
   run sort-brbrowse-1
     (input (if available buf_price-doc-forming-gds
             then recid(buf_price-doc-forming-gds)
             else ?
            )
     ).
end.
PROCEDURE sort-brbrowse-1 :
  define input parameter p-recid as recid no-undo .
  if re-querybrowse-1 = no then do:
    assign
       cur-clmnbrowse-1 = browse-1:current-column in frame Dialog-Frame
    .
    if sort-clmnbrowse-1 <> ? then sort-clmnbrowse-1:column-fgcolor = 0.
    if cur-clmnbrowse-1 = sort-clmnbrowse-1 then do:
      assign
         sort-labelbrowse-1 = ""
         sort-clmnbrowse-1 = ?
      .
     end.
     else do:
       assign
         sort-labelbrowse-1 = cur-clmnbrowse-1:label
         sort-clmnbrowse-1  = cur-clmnbrowse-1
         sort-clmnbrowse-1:column-fgcolor = 4
       .
     end.
   end.
  assign
    cur-clmn-locbrowse-1 = 1
  .
  def var column-handle as handle no-undo .
  column-handle = browse-1:first-column.
  do while valid-handle(column-handle) :
    if column-handle = cur-clmnbrowse-1 then do:
      leave .
    end.
    column-handle = column-handle:NEXT-COLUMN.
    assign
      cur-clmn-locbrowse-1 = cur-clmn-locbrowse-1 + 1
    .
  end.
  case sort-labelbrowse-1:
        when '№'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.line-num"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Бар-код'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.b-code"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Артикул'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.artic"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Ед.'  then DO:    assign       sort-column-name = "buf_bar-code.unit-cli"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Наименование'  then DO:    assign       sort-column-name = "v-name"     .     run OpenBr (yes, no, '':U).   . END.
        when 'НДС%'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.vat-pc"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Новая (вал.док)'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.price-sale-doc"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Последняя (вал.док)'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.price-prev-doc"     .     run OpenBr (yes, no, '':U).   . END.
        when '%Н/П'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1func-old-pc&1,recid(buf_price-doc-forming-gds))', chr(34))     .     run OpenBr (yes, no, '':U).   . END.
        when 'Исходная  (вал.док)'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.price-calc-doc"     .     run OpenBr (yes, no, '':U).   . END.
        when '%Н/И'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1func-calc-pc&1,recid(buf_price-doc-forming-gds))', chr(34))     .     run OpenBr (yes, no, '':U).   . END.
        when 'Комп.цены (вал.док)'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.road-tax-doc"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Акциз (вал.док)'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.excise-doc"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Статус'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.stts"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Новая (нац.вал)'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.price-sale-rubl"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Последняя (нац.вал)'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.price-prev-rubl"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Исходная  (нац.вал)'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.price-calc-rubl"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Комп.цены (нац.вал)'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.road-tax-rubl"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Акциз (нац.вал)'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.excise-rubl"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Новая (баз.вал)'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.price-sale-base"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Последняя (баз.вал)'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.price-prev-base"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Исходная  (баз.вал)'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.price-calc-base"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Комп.цены (баз.вал)'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.road-tax-base"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Акциз (баз.вал)'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.excise-base"     .     run OpenBr (yes, no, '':U).   . END.
        when 'Посл.ДНЦ'  then DO:    assign       sort-column-name = "buf_price-doc-forming-gds.prev-doc-code"     .     run OpenBr (yes, no, '':U).   . END.
        when '*'  then DO:    assign       sort-column-name = "get-mark  (BUFFER buf_price-doc-forming-gds)"     .     run OpenBr (yes, no, '':U).   . END.
        when '№ Партии'  then DO:   assign       sort-column-name = substitute('dynamic-function(&1func-part-code&1,recid(buf_price-doc-forming-gds))', chr(34))     .     run OpenBr (yes, no, '':U).   . END.
    otherwise do:
      assign
        sort-column-name = ""
      .
      run Open1 .
      if sort-labelbrowse-1 <> "" then do:
        assign
          cur-clmnbrowse-1:column-fgcolor = 0
        .
      end.
      assign
        cur-clmn-locbrowse-1 = ?
      .
    end.
  end case.
  if p-recid <> ? then do:
    reposition browse-1 to recid p-recid no-error.
    apply "value-changed" to browse-1 in frame Dialog-Frame.
  end.
  apply "entry" to browse-1 in frame Dialog-Frame.
END PROCEDURE.
procedure re-open-query-srt-clmnbrowse-1:
if cur-clmnbrowse-1 = ? then do:
   run Open1 .
end.
else do:
   assign re-querybrowse-1 = yes.
   run sort-brbrowse-1
     (input (if available buf_price-doc-forming-gds
             then recid(buf_price-doc-forming-gds)
             else ?
            )
     ).
   assign re-querybrowse-1 = no.
end.
end.
define variable vss-include-info127 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on F9 of frame Dialog-Frame anywhere do:
  run get-gds-rec.
  if gds-rec = ? then
    return no-apply.
  run ref/gds-form.w ( input parParentProc
                      ,input 'ПРОСМОТР':U
                      ,input ?
                      ,input ?
                      ,input ?
                      ,input-output gds-rec).
  apply "entry" to BROWSE-1 in frame Dialog-Frame.
  return no-apply.
end.
buf_price-doc-forming-gds.price-sale-doc:label-fgcolor in browse browse-1 = blue_color .
buf_price-doc-forming-gds.excise-doc:label-fgcolor in browse browse-1 = blue_color .
buf_price-doc-forming-gds.road-tax-rubl:label-fgcolor in browse browse-1 = blue_color .
define variable dor-nal as character no-undo .
 run tax-name in this-procedure ( input 'rdt':U, output  dor-nal) .
 assign
   buf_price-doc-forming-gds.road-tax-doc :label  = dor-nal + " в.д."
   buf_price-doc-forming-gds.road-tax-rubl :label = dor-nal + " руб"
   buf_price-doc-forming-gds.road-tax-base :label = dor-nal + " б.в."
   .
p-next-prev = yes.
n-p: do while p-next-prev :
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  run init-proc in this-procedure .
  run enable_ui in this-procedure .
  if p-mode = 'ПРОСМОТР':U then do:
      run my_lookup in this-procedure .
      run OpenBr in this-procedure (yes, no, '':U).
      if  p-recid-gds <> ? then do:
          reposition BROWSE-1 to recid p-recid-gds no-error .
      end.
  end.
  else do:
    run my_enable in this-procedure .
    run Open1 .
  end.
  if par-is-pharm = "yes" then do:
      display
        v-ost
        v-prod-price
        v-new-price-vat
        v-prod-price-prc
        v-priceprodwithvat-2
        v-prod-price-prc-2
        v-prod-price-prc-3
        doc-code
      with frame Dialog-Frame no-error .
      enable doc-code with frame Dialog-Frame .
  end.
  else do :
    hide
        v-ost
        v-prod-price
        v-new-price-vat
        v-prod-price-prc
        v-priceprodwithvat-2
        v-prod-price-prc-2
        v-prod-price-prc-3
      in frame Dialog-Frame  .
    display
      v-free-qnty
      v-fact-qnty
      v-in-doc-qnty
    with frame Dialog-Frame no-error .
  end.
  a-n-c = "art" .
  apply "value-change" to a-n-c in frame Dialog-Frame .
  display a-n-c with frame Dialog-Frame .
  if p-mode <> 'ПРОСМОТР':U then do:
    run select-header .
    display calc-method with frame Dialog-Frame.
  end.
  wait-for go of frame Dialog-Frame focus BROWSE-1  .
end.
end.
run disable_UI in this-procedure .
PROCEDURE add-spec :
define variable num-rec as integer   no-undo .
define variable recid-list as character no-undo .
define variable v-price-calc-base as decimal   no-undo .
define variable v-price-calc-doc  as decimal   no-undo .
define variable v-price-calc-rubl as decimal   no-undo .
define variable v-price-prev-base as decimal   no-undo .
define variable v-price-prev-doc  as decimal   no-undo .
define variable v-price-prev-rubl as decimal   no-undo .
define variable v-price-sale-base as decimal   no-undo .
define variable v-price-sale-doc  as decimal   no-undo .
define variable v-price-sale-rubl as decimal   no-undo .
define variable v-road-tax-base   as decimal   no-undo .
define variable v-road-tax-doc    as decimal   no-undo .
define variable v-road-tax-rubl   as decimal   no-undo .
define variable v-excise-base     as decimal   no-undo .
define variable v-excise-doc      as decimal   no-undo .
define variable v-excise-rubl     as decimal   no-undo .
define variable v-vat-pc          as decimal   no-undo .
define variable v-slt-pc          as decimal   no-undo .
define variable v-prev-doc-code   as character no-undo .
define buffer buf_scl_bar-code for ub.bar-code  .
 if par-is-pharm = "yes" then do:
  run ref/bas-cds.w
     ( parParentProc,
       v-last-obj-type,
       v-last-obj-code,
       "par-gds-free",
       buf_bar-code.gds-code,
       output recid-list
       ) .
 end.
 else do:
  run ref/bas-cds.w
     ( parParentProc,
       v-last-obj-type,
       v-last-obj-code,
       "scl-gds-all",
       buf_bar-code.gds-code,
       output recid-list
       ) .
 end.
  run last-num in this-procedure (input recid(buf_price-doc-forming) , output v-line-num ) .
  define variable v-nn as integer   no-undo .
  define variable v-d-pcnt as decimal   no-undo .
  v-nn = num-entries (recid-list).
  do num-rec = 1 to v-nn:
    find first buf_scl_bar-code no-lock where
        recid (buf_scl_bar-code) = integer (entry (num-rec, recid-list)) no-error .
    if available buf_scl_bar-code  and
       ( par-is-pharm = "yes"  or  ( buf_scl_bar-code.part-code = "" and  buf_scl_bar-code.in-code = "" ))
    then do:
        v-line-num = v-line-num + 1.
        run calc-price-line  in this-procedure (
          input  calc-method
        , input  increase-pc
        , input  round-method
        , input  round-base
        , input  buf_scl_bar-code.b-code
        , input  buf_goods.gds-code
        , input  buf_goods.artic
        , input  buf_goods.prod-type
        , input  buf_goods.prod-code
        , input  v-base-rate
        , input  v-base-scale
        , input  v-exch-scale
        , input  v-exch-rate
        , input  doc-code
        , input  common-price
        , input  copy-type
        , input  copy-code
        , output p-new-calc-method
        , output v-price-calc-base
        , output v-price-calc-doc
        , output v-price-calc-rubl
        , output v-price-prev-base
        , output v-price-prev-doc
        , output v-price-prev-rubl
        , output v-price-sale-base
        , output v-price-sale-doc
        , output v-price-sale-rubl
        , output v-road-tax-base
        , output v-road-tax-doc
        , output v-road-tax-rubl
        , output v-excise-base
        , output v-excise-doc
        , output v-excise-rubl
        , output v-vat-pc
        , output v-slt-pc
        , output v-prev-doc-code
        , output v-d-pcnt
        ).
        run create-line  in this-procedure (
           buf_price-doc-forming.plt-db-num
          ,buf_price-doc-forming.plt-id
          ,buf_price-doc-forming.pdf-db
          ,buf_price-doc-forming.pdf-id
          ,v-line-num
          ,buf_scl_bar-code.b-code
          ,buf_goods.artic
          ,buf_goods.prod-type
          ,buf_goods.prod-code
          ,p-new-calc-method
          ,v-d-pcnt
          ,FILL-IN_have-start-period
          ,FILL-IN_start-date
          ,FILL-IN_start-shift-date
          ,FILL-IN_start-shift-name
          ,FILL-IN_start-shift-num
          ,FILL-IN_start-sys-date
          ,( l-loc-hour * 60 * 60 )  + ( l-loc-min * 60 )
          ,FILL-IN_have-end-period
          ,FILL-IN_end-date
          ,FILL-IN_end-shift-date
          ,FILL-IN_end-shift-name
          ,FILL-IN_end-shift-num
          ,FILL-IN_end-sys-date
          , ( l-loc-hour-2 * 60 * 60 )  + ( l-loc-min-2 * 60 )
          ,v-price-calc-base
          ,v-price-calc-doc
          ,v-price-calc-rubl
          ,v-price-prev-base
          ,v-price-prev-doc
          ,v-price-prev-rubl
          ,v-price-sale-base
          ,v-price-sale-doc
          ,v-price-sale-rubl
          ,v-road-tax-base
          ,v-road-tax-doc
          ,v-road-tax-rubl
          ,v-excise-base
          ,v-excise-doc
          ,v-excise-rubl
          ,v-vat-pc
          ,v-slt-pc
          ,v-prev-doc-code
          ,0
          ,input-output v-sec
          ) no-error .
          if error-status :error then
          message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            "bbbb"
            view-as alert-box error
          .
          find first buf_price-doc-forming-gds no-lock  where
                    buf_price-doc-forming-gds.plt-db-num  =  buf_price-doc-forming.plt-db-num and
                    buf_price-doc-forming-gds.plt-id      =  buf_price-doc-forming.plt-id     and
                    buf_price-doc-forming-gds.pdf-db      =  buf_price-doc-forming.pdf-db     and
                    buf_price-doc-forming-gds.pdf-id      =  buf_price-doc-forming.pdf-id     and
                    buf_price-doc-forming-gds.b-code      =  buf_scl_bar-code.b-code
                    no-error .
          run make-xxx-line in this-procedure .
          run calc-price-sub in this-procedure
              (input  buf_scl_bar-code.b-code ,
              input  recid ( buf_price-doc-forming ) ,
              input  calc-method,
              input  increase-pc,
              input  round-method,
              input  round-base,
              input  doc-code,
              input  common-price,
              input  copy-type,
              input  copy-code,
              output calc-rec) no-error.
           if error-status :error then
           message
             vss-workfile vss-revision vss-description skip
             error-status :get-message(1) skip
             return-value skip
             "calc-price-sub"
             view-as alert-box error
           .
      end.
  end.
END PROCEDURE.
PROCEDURE del-doc-line1 :
define input  parameter p-recid  as recid no-undo .
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf2_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer b-gds-prt for ub.gds-prt.
define buffer buf_bar-code for ub.bar-code  .
define variable v-artic     as character no-undo .
define variable v-prod-type as character no-undo .
define variable v-prod-code as integer   no-undo .
find first buf_price-doc-forming-gds exclusive-lock where
           recid(buf_price-doc-forming-gds)  = p-recid no-error .
find first buf_bar-code no-lock  where
           buf_bar-code.b-code  = buf_price-doc-forming-gds.b-code no-error .
find first buf_goods no-lock  where
           buf_goods.gds-code = buf_bar-code.gds-code no-error .
if not available buf_price-doc-forming-gds then return.
  assign
    v-artic      = buf_price-doc-forming-gds.artic
    v-prod-type  = buf_price-doc-forming-gds.prod-type
    v-prod-code  = buf_price-doc-forming-gds.prod-code
  .
find first b-gds-prt no-lock where b-gds-prt.node-code = buf_bar-code.node-code no-error .
    if b-gds-prt.upper-code = buf_goods.prt-root and
       buf_goods.unit-base = buf_bar-code.unit-cli and
       buf_bar-code.in-code = ""     then  do:
        for each buf2_price-doc-forming-gds exclusive-lock  where
              buf2_price-doc-forming-gds.pdf-db     = buf_price-doc-forming-gds.pdf-db  and
              buf2_price-doc-forming-gds.pdf-id     = buf_price-doc-forming-gds.pdf-id  and
              buf2_price-doc-forming-gds.plt-db-num = buf_price-doc-forming-gds.plt-db-num and
              buf2_price-doc-forming-gds.plt-id     = buf_price-doc-forming-gds.plt-id and
              buf2_price-doc-forming-gds.artic      =  v-artic     and
              buf2_price-doc-forming-gds.prod-type  =  v-prod-type and
              buf2_price-doc-forming-gds.prod-code  =  v-prod-code  :
          for each tt_price-doc-forming-gds-xxx  where
                tt_price-doc-forming-gds-xxx.b-code      = buf2_price-doc-forming-gds.b-code     and
                tt_price-doc-forming-gds-xxx.pdf-db      = buf2_price-doc-forming-gds.pdf-db     and
                tt_price-doc-forming-gds-xxx.pdf-id      = buf2_price-doc-forming-gds.pdf-id     and
                tt_price-doc-forming-gds-xxx.plt-db-num  = buf2_price-doc-forming-gds.plt-db-num and
                tt_price-doc-forming-gds-xxx.plt-id      = buf2_price-doc-forming-gds.plt-id
                :
                delete tt_price-doc-forming-gds-xxx .
          end.
          delete buf2_price-doc-forming-gds .
       end.
    end.
    else do:
       for each buf2_price-doc-forming-gds exclusive-lock  where
           recid(buf2_price-doc-forming-gds) = recid (buf_price-doc-forming-gds) :
                for each tt_price-doc-forming-gds-xxx  where
                      tt_price-doc-forming-gds-xxx.b-code      = buf2_price-doc-forming-gds.b-code     and
                      tt_price-doc-forming-gds-xxx.pdf-db      = buf2_price-doc-forming-gds.pdf-db     and
                      tt_price-doc-forming-gds-xxx.pdf-id      = buf2_price-doc-forming-gds.pdf-id     and
                      tt_price-doc-forming-gds-xxx.plt-db-num  = buf2_price-doc-forming-gds.plt-db-num and
                      tt_price-doc-forming-gds-xxx.plt-id      = buf2_price-doc-forming-gds.plt-id
                      :
                      delete tt_price-doc-forming-gds-xxx .
                end.
           delete buf2_price-doc-forming-gds .
       end.
    end.
END PROCEDURE.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY calc-method increase-pc round-method round-base FILL-IN_base-rate
          FILL-IN_base-scale FILL-IN_have-start-period l-loc-hour l-loc-min
          R-mode-code FILL-IN_exch-rate FILL-IN_exch-scale
          FILL-IN_have-end-period l-loc-hour-2 l-loc-min-2 a-n-c loc-art
          FILL-IN_name v-curr-abbr-bv v-curr-abbr-vd p-calc-metod p-old p-new
          p-pc-prev p-pr-doc-old p-op-pr-doc-old p-pc-pr-doc-old
          p-pc-op-pr-doc-old p-avrg p-op-avrg p-pc-avrg p-pc-op-avrg p-last
          p-op-last p-pc-last p-pc-op-last prev-price_doc-num v-ost obj-in-code
          v-new-price-vat obj-in-date v-prod-price-prc v-prod-price
          v-prod-price-prc-2 v-priceprodwithvat-2 v-prod-price-prc-3
      WITH FRAME Dialog-Frame.
  ENABLE b-exit b-prev b-next b-mark b-sel-all b-unmark b-add b-del b-chg
         b-special b-obj b-grp b-cust b-notes B-import B-history b-help
         calc-method increase-pc round-method round-base FILL-IN_base-rate
         FILL-IN_base-scale FILL-IN_have-start-period l-loc-hour l-loc-min
         R-mode-code b-log-2 b-log b-type-price FILL-IN_exch-rate
         FILL-IN_exch-scale FILL-IN_have-end-period l-loc-hour-2 l-loc-min-2
         BROWSE-1 BROWSE-2 a-n-c loc-art loc-name loc-code FILL-IN_name
         v-curr-abbr-bv v-curr-abbr-vd p-calc-metod p-old p-new p-pc-prev
         p-pr-doc-old p-op-pr-doc-old p-pc-pr-doc-old p-pc-op-pr-doc-old p-avrg
         p-op-avrg p-pc-avrg p-pc-op-avrg p-last p-op-last p-pc-last
         p-pc-op-last prev-price_doc-num v-ost obj-in-code v-new-price-vat
         obj-in-date v-prod-price-prc v-prod-price v-prod-price-prc-2
         v-priceprodwithvat-2 v-prod-price-prc-3
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
  OPEN QUERY BROWSE-1 FOR EACH buf_price-doc-forming-gds OF buf_price-doc-forming NO-LOCK,              EACH buf_goods OF buf_price-doc-forming-gds NO-LOCK,              EACH buf_bar-code OF buf_price-doc-forming-gds NO-LOCK INDEXED-REPOSITION.    OPEN QUERY BROWSE-2 FOR EACH tt_price-doc-forming-gds-xxx OF                                  buf_price-doc-forming-gds NO-LOCK INDEXED-REPOSITION.
END PROCEDURE.
PROCEDURE get-gds-rec :
define buffer buf_goods for ub.goods  .
  do
  on error undo, return error return-value
  :
   gds-rec = ? .
   if not available buf_price-doc-forming-gds then return.
      find first buf_goods no-lock where
                 buf_goods.artic     = buf_price-doc-forming-gds.artic     and
                 buf_goods.prod-type = buf_price-doc-forming-gds.prod-type and
                 buf_goods.prod-code = buf_price-doc-forming-gds.prod-code no-error .
      if available buf_goods then gds-rec = recid(buf_goods).
  end.
end procedure.
PROCEDURE import-proc :
define input  parameter p-mode as character no-undo .
define variable l-ok     as logical   no-undo .
define variable imp-save as integer   no-undo .
define variable v-file-name as char no-undo.
define variable i1 as integer no-undo.
define variable impc as integer   no-undo .
define variable s  as character no-undo.
define variable owner   as character no-undo INITIAL "".
define variable v-price like ub.price-list.price-sale no-undo.
define variable v-bar-code as integer no-undo.
define variable main-b-code  as integer   no-undo .
define variable v-doc-num    like ub.price-list.doc-num    no-undo .
define variable v-price-sale like ub.price-list.price-sale no-undo .
define variable v-road-tax   like ub.price-list.road-tax   no-undo .
define variable v-excise     like ub.price-list.excise     no-undo .
define buffer main_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf_gds-obj for ub.gds-obj  .
define buffer bf_bar-code for ub.bar-code  .
if p-mode = "txt"
    then do:
      v-str = "Проводить импорт из текстового файла  формата:     бар-код;цена    ? ".
    end.
    else do:
      v-str = "Проводить импорт из списка кодов ?".
    end.
  l-ok = true .
  message v-str
    view-as alert-box question
    buttons yes-no
    update l-ok .
  if l-ok = false then return.
  system-dialog get-file v-file-name
  title "Выберите файл для заполнения переоценки"
  filters "Текстовый файл (*.csv)"   "*.csv" ,
          "Текстовый файл (*.txt)"   "*.txt" ,
          "Список кодов   (*.bb)"    "*.bb" ,
          "Все файлы" "*.*"
           update l-ok.
  if not l-ok then return.
  input stream imp from value ( v-file-name ) .
 repeat :
     s = "".
     import stream imp unformatted s NO-ERROR.
     if error-status :error then do:
     message
       vss-workfile vss-revision vss-description skip
       error-status :get-message(1) skip
       return-value skip
       ""
       view-as alert-box error
     .
     end.
     assign
      impc   = impc + 1
      i1 = i1 + 1
      s = trim (s)
     .
     if s = "" then leave.
 if p-mode = "txt" then do:
     assign
      v-price = decimal ( replace (entry (2, s, ";") ,"," , ".") )
      v-bar-code = integer(entry (1, s, ";"))
     no-error.
 end.
 if p-mode = "bb" then do:
    v-bar-code = integer(entry (1, s, " ")) no-error.
define variable vss-include-info128 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  v-bar-code
  ,input  0
  ,input  0
  ,output v-doc-num
  ,output v-price
  ,output v-road-tax
  ,output v-excise
  ) no-error .
 end.
     if v-price <= 0 or v-price = ? then next.
     if v-bar-code <= 0 or v-bar-code = ? then next.
  display
  impc  label "Прочитано"
  i1    label "Сохранено"
  v-bar-code format ">>>>>>>>>9" label "Bar-code"
  with frame ff view-as dialog-box
  title substitute(": Импорт товаров из файла в ДНЦ"  ) .
  pause 0.
     find first bf_bar-code where bf_bar-code.b-code = v-bar-code
     no-lock no-error.
     if not available bf_bar-code then do:
            message "Отсутствует БК для товара с bar-code:" v-bar-code .
            next.
     end.
     find first buf_goods where buf_goods.gds-code = bf_bar-code.gds-code  no-lock no-error.
     if not available buf_goods then do:
            message "Отсутствует товар с gds-code:" bf_bar-code.gds-code .
            next.
     end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf_goods.gds-code
  ,input  ?
  ,output main-b-code
  )  .
      find first buf_price-doc-forming-gds exclusive-lock where
                 buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id
            and  buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num
            and  buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id
            and  buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db
            and  buf_price-doc-forming-gds.b-code     = bf_bar-code.b-code no-error .
      if available buf_price-doc-forming-gds then do:
        delete buf_price-doc-forming-gds.
      end.
      imp-save = imp-save + 1 .
      if buf_goods.unit-base = bf_bar-code.unit-cli then do:
          find first buf_price-doc-forming-gds exclusive-lock where
                     buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id
                and  buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num
                and  buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id
                and  buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db
                and  buf_price-doc-forming-gds.b-code     = main-b-code no-error .
          if not available buf_price-doc-forming-gds then do:
          run prcreate-new-price-doc-forming-gds in this-procedure (
              input recid ( buf_price-doc-forming )
            , input v-cntxt-obj-type
            , input v-cntxt-obj-code
            , input par-pr-notls
            , input par-pr-altex
            , input par-pr-sclex
            , input imp-save
            , input buf_goods.gds-code
            , input v-price
            ) no-error.
            if error-status :error then do:
            message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              ""
              view-as alert-box error
            .
            end.
            end.
            if main-b-code  <>  bf_bar-code.b-code then do:
                find first buf_price-doc-forming-gds exclusive-lock where
                          buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                          buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                          buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                          buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                          buf_price-doc-forming-gds.b-code     = bf_bar-code.b-code no-error .
                if available buf_price-doc-forming-gds then do:
                  delete buf_price-doc-forming-gds .
                end.
                assign
                  imp-save = imp-save + 1
                  v-sec =  v-sec + 1
                .
                  run create-line-pdf-mpl-lib (
                      input buf_price-doc-forming.plt-db-num
                      ,input buf_price-doc-forming.plt-id
                      ,input buf_price-doc-forming.pdf-db
                      ,input buf_price-doc-forming.pdf-id
                      ,input imp-save
                      ,input bf_bar-code.b-code
                      ,input buf_goods.artic
                      ,input buf_goods.prod-type
                      ,input buf_goods.prod-code
                      ,input ""
                      ,input 0
                      ,input v-price
                      ,input ""
                      ,input 0
                      ,input-output v-sec ) no-error .
            end.
        end.
        else do:
        find first main_price-doc-forming-gds no-lock where
                   main_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                   main_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                   main_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                   main_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                   main_price-doc-forming-gds.b-code     = main-b-code no-error .
        if not available main_price-doc-forming-gds then do:
        find first buf_gds-obj no-lock where
                   buf_gds-obj.obj-type = v-cntxt-obj-type  and
                   buf_gds-obj.obj-code = v-cntxt-obj-code  and
                   buf_gds-obj.gds-code = buf_goods.gds-code     no-error .
        run prcreate-new-price-doc-forming-gds in this-procedure (
            input recid ( buf_price-doc-forming )
          , input v-cntxt-obj-type
          , input v-cntxt-obj-code
          , input par-pr-notls
          , input par-pr-altex
          , input par-pr-sclex
          , input imp-save
          , input buf_goods.gds-code
          , input ( if available buf_gds-obj and buf_gds-obj.price-sale <> 0 then buf_gds-obj.price-sale else v-price / bf_bar-code.cli-base-rate )
          ) no-error.
          if error-status :error then do:
             message
               vss-workfile vss-revision vss-description skip
               error-status :get-message(1) skip
               return-value skip
               "Создание основного кода для неосновного"
               view-as alert-box error
             .
          end.
        end.
        find first buf_price-doc-forming-gds exclusive-lock where
                   buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                   buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                   buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                   buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                   buf_price-doc-forming-gds.b-code     = bf_bar-code.b-code no-error .
        if available buf_price-doc-forming-gds then do:
           delete buf_price-doc-forming-gds .
        end.
        assign
          imp-save = imp-save + 1
          v-sec =  v-sec + 1
        .
        run create-line-pdf-mpl-lib (
             input buf_price-doc-forming.plt-db-num
            ,input buf_price-doc-forming.plt-id
            ,input buf_price-doc-forming.pdf-db
            ,input buf_price-doc-forming.pdf-id
            ,input imp-save
            ,input bf_bar-code.b-code
            ,input buf_goods.artic
            ,input buf_goods.prod-type
            ,input buf_goods.prod-code
            ,input ""
            ,input 0
            ,input v-price
            ,input ""
            ,input 0
            ,input-output v-sec ) no-error .
            if error-status :error then do:
               message
                 vss-workfile vss-revision vss-description skip
                 error-status :get-message(1) skip
                 return-value skip
                 "неосновной код"
                 view-as alert-box error
               .
            end.
        find first buf_price-doc-forming-gds exclusive-lock where
                   buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                   buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                   buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                   buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                   buf_price-doc-forming-gds.b-code     = bf_bar-code.b-code
                   no-error .
        find first main_price-doc-forming-gds no-lock where
                   main_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id      and
                   main_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num  and
                   main_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id      and
                   main_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db      and
                   main_price-doc-forming-gds.b-code     = main-b-code
                   no-error .
        if available buf_price-doc-forming-gds then do:
           buf_price-doc-forming-gds.d-pcnt =
           (( (main_price-doc-forming-gds.price-sale-doc * bf_bar-code.cli-base-rate) - v-price  ) * 100) /
             ( main_price-doc-forming-gds.price-sale-doc * bf_bar-code.cli-base-rate) no-error .
        end.
        end.
  end.
  input stream imp close.
END PROCEDURE.
PROCEDURE init-proc :
empty temp-table tt_price-doc-forming-gds-xxx .
empty temp-table tt-gds-list .
empty temp-table tt-table1 .
empty temp-table tt-table2 .
empty temp-table tt-table3 .
if p-mode <> 'ПРОСМОТР':U then do:
   p-next-prev = no.
end.
find first buf_global-state no-lock no-error .
if not available buf_global-state then do:
   message
     "Не заданы параметры ценообразования!"
     view-as alert-box error
   .
   return error return-value .
end.
define variable l-par as logical   no-undo .
   run chec-par in this-procedure (
         output l-par
        ,input  v-cntxt-host-code-obj
        ,input  v-cntxt-obj-type
        ,input  v-cntxt-obj-code
      ) no-error .
if p-mode = 'ПРОСМОТР':U then do:
   find first ub.price-doc-forming no-lock where recid(ub.price-doc-forming) = p-doc-rec no-error .
    find first  buf-price-list-type no-lock where
                buf-price-list-type.plt-id     = ub.price-doc-forming.plt-id and
                buf-price-list-type.plt-db-num = ub.price-doc-forming.plt-db-num no-error .
end.
else do:
    find first  buf-price-list-type no-lock where
                buf-price-list-type.plt-id     = p-plt-id and
                buf-price-list-type.plt-db-num = p-plt-db-num no-error .
end.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-pharm'
  ,input  v-cntxt-host-code-obj
  ,input  v-cntxt-obj-type
  ,input  v-cntxt-obj-code
  ,input  ''
  ,input  ''
  ,input  ''
  ,input  no
  ,output par-is-pharm
  ,output par-type
  ) no-error .
 .
  if par-is-pharm <> "yes" then par-is-pharm = "no" .
  else do:
define variable vss-include-info129 as character format "x(65)" no-undo initial "@(#)$workfile: $ $revision: $".
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
     par-is-pharm = "no"  .
  end.
  end.
define variable p-list as character no-undo .
run str/pr-listv.p
    (input 'Товар,УчетнаяS,Учет-рзрвS,ПриходнаяS,Старая,Новая,Объект,Накладная,Переоценка,ДокФормЦены,Накл-безНДС,Учет-НДСS,Стар-безНДС,Единая,Отсутствует,Откат_цен,Не-считать,Производит,Произв-НДС,ПорогПр-НДС,ПорогПр+НДС,Спецификация':U  ,
     input 'Не-считать':U,
     output p-list
     ) .
calc-method:list-items in frame Dialog-Frame  = p-list .
  round-method:list-items in frame Dialog-Frame  =
  '9-окончание':U + "," + '9-99окончание':U + "," + 'Без-дробных':U + "," + 'Произвольно':U + "," + 'Вверх':U + "," + 'Коэффициент':U + "," + 'Отключено':U .
assign
  calc-method  = buf-price-list-type.calc-method
  increase-pc  = buf-price-list-type.calc-increase-pc
  round-method = buf-price-list-type.calc-round-method
  round-base   = buf-price-list-type.calc-round-base
.
if  true = true then do:
define variable vss-include-info130 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  v-base-code
  ,input  TODAY
  ,output FILL-IN_base-rate
  ,output FILL-IN_base-scale
  ,output v-curr-abbr-bv
  )  .
    v-base-rate  = FILL-IN_base-rate .
    v-base-scale = FILL-IN_base-scale .
end.
if  true = true    then do:
define variable vss-include-info131 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  buf-price-list-type.curr-code
  ,input  TODAY
  ,output FILL-IN_exch-rate
  ,output FILL-IN_exch-scale
  ,output v-curr-abbr-vd
  )  .
    v-exch-rate  = FILL-IN_exch-rate  .
    v-exch-scale = FILL-IN_exch-scale .
end.
if p-mode = 'ДОБАВЛЕНИЕ':U then do:
   create ub.price-doc-forming.
   assign
      ub.price-doc-forming.plt-id       = buf-price-list-type.plt-id
      ub.price-doc-forming.plt-db-num   = buf-price-list-type.plt-db-num
      ub.price-doc-forming.pdf-id       = next-value ( s-pdf , ub)
      ub.price-doc-forming.pdf-db       = v-cntxt-db-num
      ub.price-doc-forming.base-rate    = FILL-IN_base-rate
      ub.price-doc-forming.base-scale   = FILL-IN_base-scale
      ub.price-doc-forming.db-num-chg   = v-cntxt-db-num
      ub.price-doc-forming.exch-rate    = FILL-IN_exch-rate
      ub.price-doc-forming.exch-scale   = FILL-IN_exch-scale
      ub.price-doc-forming.stts         = integer('0':U)
      ub.price-doc-forming.sys-date     = today
      ub.price-doc-forming.sys-time     = time
      ub.price-doc-forming.sys-time-chr = string ( ub.price-doc-forming.sys-time , "hh:mm" )
      ub.price-doc-forming.who          = v-cntxt-userid
      ub.price-doc-forming.name         = "@"
      p-rec-list   = string(recid(ub.price-doc-forming))
      p-doc-rec    = recid(ub.price-doc-forming)
      FILL-IN_name = ( if buf-price-list-type.ban-discnt > 0 then "Скидочное ДНЦ:" + string(buf-price-list-type.ban-discnt) else "@" )
   .
   find first buf_price-doc-forming  exclusive-lock where
        buf_price-doc-forming.plt-id     =  ub.price-doc-forming.plt-id        and
        buf_price-doc-forming.plt-db-num =  ub.price-doc-forming.plt-db-num    and
        buf_price-doc-forming.pdf-id     =  ub.price-doc-forming.pdf-id        and
        buf_price-doc-forming.pdf-db     =  ub.price-doc-forming.pdf-db       no-error .
        if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "Поиск"
          view-as alert-box error
        .
end.
if p-mode = 'ИЗМЕНЕНИЕ':U then do:
   find first ub.price-doc-forming no-lock where recid(ub.price-doc-forming) = p-doc-rec no-error .
   find first buf_price-doc-forming  exclusive-lock where
        buf_price-doc-forming.plt-id     =  ub.price-doc-forming.plt-id        and
        buf_price-doc-forming.plt-db-num =  ub.price-doc-forming.plt-db-num    and
        buf_price-doc-forming.pdf-id     =  ub.price-doc-forming.pdf-id        and
        buf_price-doc-forming.pdf-db     =  ub.price-doc-forming.pdf-db        no-error .
        if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "корректировка"
          view-as alert-box error
        .
end.
if p-mode = 'ПРОСМОТР':U then do:
   find first ub.price-doc-forming no-lock where recid(ub.price-doc-forming) = p-doc-rec no-error .
   find first buf_price-doc-forming  no-lock  where
        buf_price-doc-forming.plt-id     =  ub.price-doc-forming.plt-id        and
        buf_price-doc-forming.plt-db-num =  ub.price-doc-forming.plt-db-num    and
        buf_price-doc-forming.pdf-id     =  ub.price-doc-forming.pdf-id        and
        buf_price-doc-forming.pdf-db     =  ub.price-doc-forming.pdf-db        no-error .
        if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "просмотр"
          view-as alert-box error
        .
end.
if p-mode = 'ПРОСМОТР':U  or
   p-mode = 'ИЗМЕНЕНИЕ':U   then do:
   assign
      FILL-IN_name              =   buf_price-doc-forming.name
      FILL-IN_have-start-period =   logical ( buf_price-doc-forming.have-start-period )
      FILL-IN_start-sys-date    =   buf_price-doc-forming.start-sys-date
      FILL-IN_start-shift-num   =   buf_price-doc-forming.start-shift-num
      FILL-IN_start-shift-name  =   buf_price-doc-forming.start-shift-name
      FILL-IN_start-date        =   buf_price-doc-forming.start-date
      FILL-IN_start-shift-date  =   buf_price-doc-forming.start-shift-date
      FILL-IN_have-end-period   =   logical ( buf_price-doc-forming.have-end-period  )
      FILL-IN_end-sys-date      =   buf_price-doc-forming.end-sys-date
      FILL-IN_end-shift-num     =   buf_price-doc-forming.end-shift-num
      FILL-IN_end-date          =   buf_price-doc-forming.end-date
      FILL-IN_end-shift-date    =   buf_price-doc-forming.end-shift-date
      FILL-IN_base-rate         =   buf_price-doc-forming.base-rate
      FILL-IN_base-scale        =   buf_price-doc-forming.base-scale
      FILL-IN_exch-rate         =   buf_price-doc-forming.exch-rate
      FILL-IN_exch-scale        =   buf_price-doc-forming.exch-scale .
      l-loc-hour                =   integer(entry(1, string (buf_price-doc-forming.start-sys-time, "HH:MM"), ":")) no-error.
      l-loc-hour-2              =   integer(entry(1, string (buf_price-doc-forming.end-sys-time,   "HH:MM"), ":")) no-error.
      l-loc-min                 =   integer(entry(2, string (buf_price-doc-forming.start-sys-time, "HH:MM"), ":")) no-error.
      l-loc-min-2               =   integer(entry(2, string (buf_price-doc-forming.end-sys-time,   "HH:MM"), ":")) no-error.
  run select-xxx-line in this-procedure .
 end.
 if v-exch-scale = 0  or v-exch-scale = ? then do:
define variable vss-include-info132 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  buf-price-list-type.curr-code
  ,input  today
  ,output v-exch-rate
  ,output v-exch-scale
  ,output v-curr-abbr-vd
  )  .
 end.
 if v-base-scale = 0 and v-base-scale = ? then do:
define variable vss-include-info133 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  v-base-code
  ,input  today
  ,output v-base-rate
  ,output v-base-scale
  ,output v-curr-abbr-bv
  )  .
  end.
 frame Dialog-Frame:TITLE = "Документ назначения цены № "
                            + string(buf_price-doc-forming.pdf-id)
                            + " БД:"
                            + string(buf_price-doc-forming.pdf-db)
                            + " -- "
                            + caps(p-mode)    .
    if buf-price-list-type.gop-id <> 0 then do:
        run metod-gop-obj in this-procedure ( v-cntxt-db-num,  buf-price-list-type.gop-id , buf-price-list-type.gop-db-num) .
        for each x_obj-group :
          create tt-table1.
          assign
            tt-table1.f1    = x_obj-group.obj-type + " " + string(x_obj-group.obj-code)
            tt-table1.f2    = x_obj-group.obj-name
            tt-table1.f3    = ""
            tt-table1.f4    = ""
            v-last-obj-type = x_obj-group.obj-type
            v-last-obj-code = x_obj-group.obj-code
          .
        end.
    end.
    else do:
       run metod-gop-obj in this-procedure ( v-cntxt-db-num, buf-price-list-type.gop-id , buf-price-list-type.gop-db-num ) .
       disable b-obj with frame Dialog-Frame .
       assign
        v-last-obj-type = v-cntxt-obj-type
        v-last-obj-code = v-cntxt-obj-code
       .
    end.
    define buffer buf_gds-grp for ub.gds-grp  .
    define buffer buf_price-list-type-gds-grp for ub.price-list-type-gds-grp  .
    define variable v-name as character no-undo .
    if buf-price-list-type.use-gds-group <> 0 then do:
          for each  buf_price-list-type-gds-grp no-lock where
                    buf_price-list-type-gds-grp.plt-id      = buf-price-list-type.plt-id and
                    buf_price-list-type-gds-grp.plt-db-num  = buf-price-list-type.plt-db-num
                    :
            find first buf_gds-grp no-lock where  buf_gds-grp.node-code = buf_price-list-type-gds-grp.node-code no-error .
            if available buf_gds-grp then do:
                create tt-table2.
                assign
                  tt-table2.f3 = ""
                  tt-table2.f4 = ""
                .
define variable vss-include-info134 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run grpgdsnm in g#library
  (input  buf_gds-grp.node-code
  ,output v-name
  )  .
                assign
                  tt-table2.f1 = ""
                  tt-table2.f2 = v-name
                .
            end.
          end.
    end.
    else disable b-grp with frame Dialog-Frame .
define buffer buf_buyer-group for ub.buyer-group  .
define buffer buf_buyer-in-buyer-group for ub.buyer-in-buyer-group  .
define buffer buf_clients for ub.clients  .
    if buf-price-list-type.bgr-id <> 0 then do:
          for each  buf_buyer-group no-lock where
                    buf_buyer-group.bgr-id      = buf-price-list-type.bgr-id and
                    buf_buyer-group.bgr-db-num  = buf-price-list-type.bgr-db-num
                    :
                for each buf_buyer-in-buyer-group no-lock where
                         buf_buyer-in-buyer-group.bgr-id      = buf_buyer-group.bgr-id     and
                         buf_buyer-in-buyer-group.bgr-db-num  = buf_buyer-group.bgr-db-num
                         :
                    v-bgr-name = buf_buyer-group.name .
                    find first buf_clients no-lock where
                               buf_clients.obj-type = buf_buyer-in-buyer-group.bbg-obj-type and
                               buf_clients.obj-code = buf_buyer-in-buyer-group.bbg-obj-code no-error .
                    if available buf_clients then do:
                        create tt-table3.
                        assign
                          tt-table3.f1 = buf_clients.obj-type + string(buf_clients.obj-code)
                          tt-table3.f2 = buf_clients.obj-name
                          tt-table3.f3 = ""
                          tt-table3.f4 = ""
                        .
                          end.
                end.
          end.
    end.
    else disable b-cust with frame Dialog-Frame .
    if buf_global-state.pl-use-add-code = false then do:
       hide b-alt in frame Dialog-Frame .
    end.
    else do:
        if logical(buf-price-list-type.have-rs-qnty-group) = true  or
                   buf-price-list-type.have-rs-sum-group   = true  or
           logical(buf-price-list-type.have-rs-turn-group) = true then do:
              disable b-alt with frame Dialog-Frame .
           end.
           else do:
              enable b-alt with frame Dialog-Frame .
           end.
    end.
END PROCEDURE.
PROCEDURE local-mark :
if not available buf_price-doc-forming-gds then do:
    message "Неправильный выбор строки.".
    return no-apply.
  end.
define variable vss-include-info135 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-str-recid136 as character no-undo .
define variable v-num-entry136 as integer   no-undo .
assign
  v-str-recid136 = trim( string( recid( buf_price-doc-forming-gds ) , "->>>>>>>>>>>9":U ) )
  v-num-entry136 = lookup( v-str-recid136 , del-list )
.
if v-num-entry136 > 0 then do:
  assign
    entry( v-num-entry136, del-list ) = "":U
    del-list = trim( replace( del-list , chr(44) + chr(44) , chr(44) ) , chr(44) )
  .
end.
else do:
  assign
    del-list = del-list + ( if del-list = "":U then "":U else chr(44) ) + v-str-recid136
  .
end.
  BROWSE-1:refresh() in frame Dialog-Frame .
  run vc-pdf in this-procedure .
END PROCEDURE.
PROCEDURE make-xxx-line :
if not available buf_price-doc-forming-gds then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      "234"
      view-as alert-box error
    .
    return .
end.
if logical(buf-price-list-type.have-rs-qnty-group) = true then do:
for each  buf_qnty-in-qnty-group   no-lock where
          buf_qnty-in-qnty-group.qgr-id      = buf-price-list-type.qgr-id and
          buf_qnty-in-qnty-group.qgr-db-num  = buf-price-list-type.qgr-db-num and
          buf_qnty-in-qnty-group.stts        = integer('0':U) :
  find first tt_price-doc-forming-gds-xxx where
      tt_price-doc-forming-gds-xxx.plt-db-num  = buf_price-doc-forming-gds.plt-db-num and
      tt_price-doc-forming-gds-xxx.plt-id      = buf_price-doc-forming-gds.plt-id     and
      tt_price-doc-forming-gds-xxx.pdf-db      = buf_price-doc-forming-gds.pdf-db     and
      tt_price-doc-forming-gds-xxx.pdf-id      = buf_price-doc-forming-gds.pdf-id     and
      tt_price-doc-forming-gds-xxx.b-code      = buf_price-doc-forming-gds.b-code     and
      tt_price-doc-forming-gds-xxx.qgr-id      = buf_qnty-in-qnty-group.qgr-id       and
      tt_price-doc-forming-gds-xxx.qgr-db-num  = buf_qnty-in-qnty-group.qgr-db-num   and
      tt_price-doc-forming-gds-xxx.ggr-qnty    = buf_qnty-in-qnty-group.ggr-qnty
      no-error .
       if not available tt_price-doc-forming-gds-xxx  then do:
          create tt_price-doc-forming-gds-xxx .
          BUFFER-COPY buf_price-doc-forming-gds TO tt_price-doc-forming-gds-xxx
          assign
              tt_price-doc-forming-gds-xxx.plt-db-num  = buf_price-doc-forming-gds.plt-db-num
              tt_price-doc-forming-gds-xxx.plt-id      = buf_price-doc-forming-gds.plt-id
              tt_price-doc-forming-gds-xxx.pdf-db      = buf_price-doc-forming-gds.pdf-db
              tt_price-doc-forming-gds-xxx.pdf-id      = buf_price-doc-forming-gds.pdf-id
              tt_price-doc-forming-gds-xxx.b-code      = buf_price-doc-forming-gds.b-code
              tt_price-doc-forming-gds-xxx.qgr-id      = buf_qnty-in-qnty-group.qgr-id
              tt_price-doc-forming-gds-xxx.qgr-db-num  = buf_qnty-in-qnty-group.qgr-db-num
              tt_price-doc-forming-gds-xxx.ggr-qnty    = buf_qnty-in-qnty-group.ggr-qnty
          .
       end.
        if buf_qnty-in-qnty-group.use-discnt or buf_qnty-in-qnty-group.discnt-pc <> ? then do :
           tt_price-doc-forming-gds-xxx.d-pcnt   = buf_qnty-in-qnty-group.discnt-pc .
        end.
        else do:
           tt_price-doc-forming-gds-xxx.d-pcnt   =  0 .
        end.
        assign
          tt_price-doc-forming-gds-xxx.price-sale-doc   = buf_price-doc-forming-gds.price-sale-doc * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
          tt_price-doc-forming-gds-xxx.price-calc-doc   = buf_price-doc-forming-gds.price-calc-doc * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
          tt_price-doc-forming-gds-xxx.road-tax-doc     = buf_price-doc-forming-gds.road-tax-doc   * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
        .
  assign
    tt_price-doc-forming-gds-xxx.price-calc-rubl = tt_price-doc-forming-gds-xxx.price-calc-doc * v-exch-rate / v-exch-scale
    tt_price-doc-forming-gds-xxx.price-sale-rubl = tt_price-doc-forming-gds-xxx.price-sale-doc * v-exch-rate / v-exch-scale
    tt_price-doc-forming-gds-xxx.road-tax-rubl   = tt_price-doc-forming-gds-xxx.road-tax-doc   * v-exch-rate / v-exch-scale
    tt_price-doc-forming-gds-xxx.price-calc-base = tt_price-doc-forming-gds-xxx.price-calc-rubl / v-base-rate * v-base-scale
    tt_price-doc-forming-gds-xxx.price-sale-base = tt_price-doc-forming-gds-xxx.price-sale-rubl / v-base-rate * v-base-scale
    tt_price-doc-forming-gds-xxx.road-tax-base   = tt_price-doc-forming-gds-xxx.road-tax-rubl   / v-base-rate * v-base-scale
  .
end.
end.
if buf-price-list-type.have-rs-sum-group = true then do:
for each  buf_sum-in-sum-group   no-lock where
          buf_sum-in-sum-group.sgr-id      = buf-price-list-type.sgr-id     and
          buf_sum-in-sum-group.sgr-db-num  = buf-price-list-type.sgr-db-num and
          buf_sum-in-sum-group.stts        = integer('0':U) :
  find first tt_price-doc-forming-gds-xxx where
      tt_price-doc-forming-gds-xxx.plt-db-num  = buf_price-doc-forming-gds.plt-db-num and
      tt_price-doc-forming-gds-xxx.plt-id      = buf_price-doc-forming-gds.plt-id     and
      tt_price-doc-forming-gds-xxx.pdf-db      = buf_price-doc-forming-gds.pdf-db     and
      tt_price-doc-forming-gds-xxx.pdf-id      = buf_price-doc-forming-gds.pdf-id     and
      tt_price-doc-forming-gds-xxx.b-code      = buf_price-doc-forming-gds.b-code     and
      tt_price-doc-forming-gds-xxx.qgr-id      = buf_sum-in-sum-group.sgr-id       and
      tt_price-doc-forming-gds-xxx.qgr-db-num  = buf_sum-in-sum-group.sgr-db-num   and
      tt_price-doc-forming-gds-xxx.ggr-qnty    = buf_sum-in-sum-group.ssg-summa
      no-error .
       if not available tt_price-doc-forming-gds-xxx  then do:
          create tt_price-doc-forming-gds-xxx .
          BUFFER-COPY buf_price-doc-forming-gds TO tt_price-doc-forming-gds-xxx
          assign
              tt_price-doc-forming-gds-xxx.plt-db-num  = buf_price-doc-forming-gds.plt-db-num
              tt_price-doc-forming-gds-xxx.plt-id      = buf_price-doc-forming-gds.plt-id
              tt_price-doc-forming-gds-xxx.pdf-db      = buf_price-doc-forming-gds.pdf-db
              tt_price-doc-forming-gds-xxx.pdf-id      = buf_price-doc-forming-gds.pdf-id
              tt_price-doc-forming-gds-xxx.b-code      = buf_price-doc-forming-gds.b-code
              tt_price-doc-forming-gds-xxx.qgr-id      = buf_sum-in-sum-group.sgr-id
              tt_price-doc-forming-gds-xxx.qgr-db-num  = buf_sum-in-sum-group.sgr-db-num
              tt_price-doc-forming-gds-xxx.ggr-qnty    = buf_sum-in-sum-group.ssg-summa
          .
       end.
        if buf_sum-in-sum-group.use-discnt or buf_sum-in-sum-group.discnt-pc <> ? then do :
           tt_price-doc-forming-gds-xxx.d-pcnt   = buf_sum-in-sum-group.discnt-pc .
        end.
        else do:
           tt_price-doc-forming-gds-xxx.d-pcnt   =  0 .
        end.
        assign
          tt_price-doc-forming-gds-xxx.price-sale-doc = buf_price-doc-forming-gds.price-sale-doc * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
          tt_price-doc-forming-gds-xxx.price-calc-doc = buf_price-doc-forming-gds.price-calc-doc * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
          tt_price-doc-forming-gds-xxx.road-tax-doc   = buf_price-doc-forming-gds.road-tax-doc   * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
        .
  assign
    tt_price-doc-forming-gds-xxx.price-calc-rubl = tt_price-doc-forming-gds-xxx.price-calc-doc * v-exch-rate / v-exch-scale
    tt_price-doc-forming-gds-xxx.price-sale-rubl = tt_price-doc-forming-gds-xxx.price-sale-doc * v-exch-rate / v-exch-scale
    tt_price-doc-forming-gds-xxx.road-tax-rubl   = tt_price-doc-forming-gds-xxx.road-tax-doc   * v-exch-rate / v-exch-scale
    tt_price-doc-forming-gds-xxx.price-calc-base = tt_price-doc-forming-gds-xxx.price-calc-rubl / v-base-rate * v-base-scale
    tt_price-doc-forming-gds-xxx.price-sale-base = tt_price-doc-forming-gds-xxx.price-sale-rubl / v-base-rate * v-base-scale
    tt_price-doc-forming-gds-xxx.road-tax-base   = tt_price-doc-forming-gds-xxx.road-tax-rubl   / v-base-rate * v-base-scale
  .
end.
end.
if logical(buf-price-list-type.have-rs-turn-group) = true then do:
for each  buf_tnv-in-tnv-group   no-lock where
          buf_tnv-in-tnv-group.tog-id      = buf-price-list-type.have-tog-id     and
          buf_tnv-in-tnv-group.tog-db-num  = buf-price-list-type.have-tog-db-num and
          buf_tnv-in-tnv-group.stts        = integer('0':U) :
  find first tt_price-doc-forming-gds-xxx where
      tt_price-doc-forming-gds-xxx.plt-db-num  = buf_price-doc-forming-gds.plt-db-num and
      tt_price-doc-forming-gds-xxx.plt-id      = buf_price-doc-forming-gds.plt-id     and
      tt_price-doc-forming-gds-xxx.pdf-db      = buf_price-doc-forming-gds.pdf-db     and
      tt_price-doc-forming-gds-xxx.pdf-id      = buf_price-doc-forming-gds.pdf-id     and
      tt_price-doc-forming-gds-xxx.b-code      = buf_price-doc-forming-gds.b-code     and
      tt_price-doc-forming-gds-xxx.qgr-id      = buf_tnv-in-tnv-group.tog-id       and
      tt_price-doc-forming-gds-xxx.qgr-db-num  = buf_tnv-in-tnv-group.tog-db-num   and
      tt_price-doc-forming-gds-xxx.ggr-qnty    = buf_tnv-in-tnv-group.ttg-summa
      no-error .
       if not available tt_price-doc-forming-gds-xxx  then do:
          create tt_price-doc-forming-gds-xxx .
          BUFFER-COPY buf_price-doc-forming-gds TO tt_price-doc-forming-gds-xxx
          assign
              tt_price-doc-forming-gds-xxx.plt-db-num  = buf_price-doc-forming-gds.plt-db-num
              tt_price-doc-forming-gds-xxx.plt-id      = buf_price-doc-forming-gds.plt-id
              tt_price-doc-forming-gds-xxx.pdf-db      = buf_price-doc-forming-gds.pdf-db
              tt_price-doc-forming-gds-xxx.pdf-id      = buf_price-doc-forming-gds.pdf-id
              tt_price-doc-forming-gds-xxx.b-code      = buf_price-doc-forming-gds.b-code
              tt_price-doc-forming-gds-xxx.qgr-id      = buf_tnv-in-tnv-group.tog-id
              tt_price-doc-forming-gds-xxx.qgr-db-num  = buf_tnv-in-tnv-group.tog-db-num
              tt_price-doc-forming-gds-xxx.ggr-qnty    = buf_tnv-in-tnv-group.ttg-summa
          .
       end.
        if buf_tnv-in-tnv-group.use-discnt or buf_tnv-in-tnv-group.discnt-pc <> ? then do :
           tt_price-doc-forming-gds-xxx.d-pcnt   = buf_tnv-in-tnv-group.discnt-pc .
        end.
        else do:
           tt_price-doc-forming-gds-xxx.d-pcnt   =  0 .
        end.
        assign
          tt_price-doc-forming-gds-xxx.price-sale-doc = buf_price-doc-forming-gds.price-sale-doc * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
          tt_price-doc-forming-gds-xxx.price-calc-doc = buf_price-doc-forming-gds.price-calc-doc * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
          tt_price-doc-forming-gds-xxx.road-tax-doc   = buf_price-doc-forming-gds.road-tax-doc   * (1 - tt_price-doc-forming-gds-xxx.d-pcnt / 100)
        .
  assign
    tt_price-doc-forming-gds-xxx.price-calc-rubl = tt_price-doc-forming-gds-xxx.price-calc-doc * v-exch-rate / v-exch-scale
    tt_price-doc-forming-gds-xxx.price-sale-rubl = tt_price-doc-forming-gds-xxx.price-sale-doc * v-exch-rate / v-exch-scale
    tt_price-doc-forming-gds-xxx.road-tax-rubl   = tt_price-doc-forming-gds-xxx.road-tax-doc   * v-exch-rate / v-exch-scale
    tt_price-doc-forming-gds-xxx.price-calc-base = tt_price-doc-forming-gds-xxx.price-calc-rubl / v-base-rate * v-base-scale
    tt_price-doc-forming-gds-xxx.price-sale-base = tt_price-doc-forming-gds-xxx.price-sale-rubl / v-base-rate * v-base-scale
    tt_price-doc-forming-gds-xxx.road-tax-base   = tt_price-doc-forming-gds-xxx.road-tax-rubl   / v-base-rate * v-base-scale
  .
end.
end.
END PROCEDURE.
PROCEDURE my_enable :
v-sec = 0 .
hide b-prev in frame Dialog-Frame
     b-next in frame Dialog-Frame
     loc-name
     loc-code
.
if v-base-code <> 0 and buf-price-list-type.fix-cource-crc-base = true  then do:
  enable FILL-IN_base-rate  FILL-IN_base-scale with frame Dialog-Frame   .
end.
else do:
   hide FILL-IN_base-rate FILL-IN_base-scale v-curr-abbr-bv in frame Dialog-Frame .
end.
if buf-price-list-type.curr-code <> 0 and buf-price-list-type.fix-cource-crc-doc = true  then do:
  enable FILL-IN_exch-rate  FILL-IN_exch-scale with frame Dialog-Frame    .
end.
else do:
   hide FILL-IN_exch-rate FILL-IN_exch-scale v-curr-abbr-vd in frame Dialog-Frame .
end.
run proc-value-2 in this-procedure .
run proc-value-1 in this-procedure .
run proc-start-o in this-procedure .
run proc-end-o   in this-procedure .
if logical ( buf-price-list-type.have-rs-qnty-group ) = true  or
             buf-price-list-type.have-rs-sum-group    = true  or
  logical  ( buf-price-list-type.have-rs-turn-group ) = true  then do:
     enable browse-2 with frame Dialog-Frame .
     if buf-price-list-type.under-hand-corr = 0 then
        tt_price-doc-forming-gds-xxx.price-sale-doc:read-only in browse browse-2 = true .
       if           buf-price-list-type.have-rs-sum-group    = true then
          tt_price-doc-forming-gds-xxx.ggr-qnty:LABEL in browse browse-2 = "Суммы" .
       if logical  ( buf-price-list-type.have-rs-turn-group ) = true then
          tt_price-doc-forming-gds-xxx.ggr-qnty:LABEL in browse browse-2 = "Обороты" .
     browse-1:HEIGHT-CHARS in frame Dialog-Frame  = 7.75.
   end.
   else do:
     browse-1:HEIGHT-CHARS in frame Dialog-Frame  = 12.5.
     hide browse-2 in frame Dialog-Frame .
   end.
    if buf-price-list-type.gop-id <> 0 then do:
    end.
    else disable b-obj with frame Dialog-Frame .
    if buf-price-list-type.use-gds-group <> 0 then do:
    end.
    else disable b-grp with frame Dialog-Frame .
    if buf-price-list-type.bgr-id <> 0 then do:
    end.
    else disable b-cust with frame Dialog-Frame .
  buf_price-doc-forming-gds.artic:RESIZABLE  in browse browse-1  = true .
  v-name :RESIZABLE                       in browse browse-1  = true .
  buf_bar-code.unit-cli:RESIZABLE            in browse browse-1  = true .
END PROCEDURE.
PROCEDURE my_lookup :
if  p-recid-gds <> ? then do:
    reposition BROWSE-1 to recid p-recid-gds no-error .
end.
hide calc-method  in  frame Dialog-Frame
     b-add b-del b-special b-chg b-log b-import b-mark b-sel-all b-unmark
     loc-name
     loc-code
     increase-pc round-method round-base in  frame Dialog-Frame .
if FILL-IN_have-start-period:visible then disable FILL-IN_have-start-period with frame Dialog-Frame .
if FILL-IN_have-end-period:visible then disable FILL-IN_have-end-period with frame Dialog-Frame .
disable FILL-IN_name FILL-IN_base-rate FILL-IN_base-scale FILL-IN_exch-rate FILL-IN_exch-scale  with frame Dialog-Frame .
run proc-start-o in this-procedure .
run proc-end-o   in this-procedure .
if logical(buf-price-list-type.have-rs-qnty-group) = true  or
           buf-price-list-type.have-rs-sum-group   = true  or
   logical(buf-price-list-type.have-rs-turn-group) = true
   then do:
     display browse-2 with frame Dialog-Frame .
     tt_price-doc-forming-gds-xxx.price-sale-doc:read-only in browse browse-2 = true .
     browse-1:HEIGHT-CHARS in frame Dialog-Frame  = 7.75.
   end.
   else do:
     browse-1:HEIGHT-CHARS in frame Dialog-Frame  = 12.5.
     hide browse-2 in frame Dialog-Frame .
   end.
    if buf-price-list-type.gop-id <> 0 then do:
    end.
    else disable b-obj with frame Dialog-Frame .
    if buf-price-list-type.use-gds-group <> 0 then do:
    end.
    else disable b-grp with frame Dialog-Frame .
   buf_price-doc-forming-gds.price-sale-doc:read-only in browse browse-1 = true .
    if buf-price-list-type.bgr-id <> 0 then do:
    end.
    else disable b-cust with frame Dialog-Frame .
  buf_price-doc-forming-gds.artic:RESIZABLE  in browse browse-1  = true .
  v-name :RESIZABLE                       in browse browse-1  = true .
  buf_bar-code.unit-cli:RESIZABLE            in browse browse-1  = true .
if logical ( buf-price-list-type.have-rs-qnty-group ) = true  or
             buf-price-list-type.have-rs-sum-group    = true  or
  logical  ( buf-price-list-type.have-rs-turn-group ) = true  then do:
     enable browse-2 with frame Dialog-Frame .
     if buf-price-list-type.under-hand-corr = 0 then
        tt_price-doc-forming-gds-xxx.price-sale-doc:read-only in browse browse-2 = true .
       if           buf-price-list-type.have-rs-sum-group    = true then
          tt_price-doc-forming-gds-xxx.ggr-qnty:LABEL in browse browse-2 = "Суммы" .
       if logical  ( buf-price-list-type.have-rs-turn-group ) = true then
          tt_price-doc-forming-gds-xxx.ggr-qnty:LABEL in browse browse-2 = "Обороты" .
     browse-1:HEIGHT-CHARS in frame Dialog-Frame  = 7.75.
   end.
   else do:
     browse-1:HEIGHT-CHARS in frame Dialog-Frame  = 12.5.
     hide browse-2 in frame Dialog-Frame .
   end.
END PROCEDURE.
PROCEDURE new-price-sub :
define input  parameter p-plt-db-num as integer   no-undo .
define input  parameter p-plt-id     as integer   no-undo .
define input  parameter p-pdf-db     as integer   no-undo .
define input  parameter p-pdf-id     as integer   no-undo .
define input  parameter p-b-code     as integer   no-undo .
define input  parameter p-artic      as character no-undo .
define input  parameter p-prod-type  as character no-undo .
define input  parameter p-prod-code  as integer   no-undo .
define buffer buf2_price-doc-forming-gds for ub.price-doc-forming-gds  .
for each buf2_price-doc-forming-gds no-lock where
        buf2_price-doc-forming-gds.plt-db-num  =  p-plt-db-num and
        buf2_price-doc-forming-gds.plt-id      =  p-plt-id     and
        buf2_price-doc-forming-gds.pdf-db      =  p-pdf-db     and
        buf2_price-doc-forming-gds.pdf-id      =  p-pdf-id     and
        buf2_price-doc-forming-gds.artic       =  p-artic      and
        buf2_price-doc-forming-gds.prod-type   =  p-prod-type  and
        buf2_price-doc-forming-gds.prod-code   =  p-prod-code  :
  find first buf_price-doc-forming-gds no-lock  where
             buf_price-doc-forming-gds.plt-db-num  =  p-plt-db-num and
             buf_price-doc-forming-gds.plt-id      =  p-plt-id     and
             buf_price-doc-forming-gds.pdf-db      =  p-pdf-db     and
             buf_price-doc-forming-gds.pdf-id      =  p-pdf-id     and
             buf_price-doc-forming-gds.b-code      =  buf2_price-doc-forming-gds.b-code
             no-error .
    run make-xxx-line in this-procedure .
end.
END PROCEDURE.
PROCEDURE open1 :
 OPEN QUERY browse-1 FOR EACH buf_price-doc-forming-gds OF buf_price-doc-forming NO-LOCK,
             EACH buf_goods OF buf_price-doc-forming-gds NO-LOCK,
             EACH buf_bar-code OF buf_price-doc-forming-gds no-lock
             by buf_price-doc-forming-gds.artic
             by buf_bar-code.node-code
             by buf_price-doc-forming-gds.line-num.
run vc-pdf in this-procedure .
END PROCEDURE.
PROCEDURE OpenBr :
define input  parameter p-open-query     as logical   no-undo .
define input  parameter p-find-next      as logical   no-undo .
define input  parameter p-find-condition as character no-undo .
define variable l-query-was-opened as logical no-undo .
define variable title0 as character no-undo.
define variable sort-column-phrase as character no-undo .
case sort-column-name :
  when "" then do:
    assign
      sort-column-phrase = ""
    .
  end.
  when "v-name" then do:
    assign
      sort-column-phrase = 'by Buf_goods.gds-name' .
    .
  end.
  otherwise do:
    assign
      sort-column-phrase = "by " + sort-column-name
    .
  end.
end case.
define variable l-open-query as logical   no-undo .
case R-mode-code :
when 1 then do:
define variable vss-include-info137 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-138  as logical   no-undo .
define variable  l-filter-open-138    as logical   .
define variable  flt-rec-138       as recid     no-undo .
define variable  filter-name-138      as character no-undo .
define variable  where-phrase-138     as character no-undo .
define variable  sort-phrase-138      as character no-undo .
define variable  where-phrase-rus-138 as character no-undo .
define variable  sort-phrase-rus-138  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-138
  ,output filter-name-138
  ,output where-phrase-138
  ,output sort-phrase-138
  ,output where-phrase-rus-138
  ,output sort-phrase-rus-138
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-138
      ) no-error .
  assign
    l-filter-open-138 = false
  .
  if flt-rec-138 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-138 as character no-undo .
    define variable  parameter-3-138 as character no-undo .
    define variable  parameter-4-138 as character no-undo .
    define variable  parameter-5-138 as character no-undo .
    define variable  parameter-6-138 as character no-undo .
    define variable  parameter-7-138 as character no-undo .
      assign
      parameter-3-138 =
                              "FOR EACH buf_price-doc-forming-gds"
      parameter-4-138 =
        (
          if (" buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id     and                      buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and                     buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id     and                     buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db " + " " + where-phrase-138) <> ""
          then  substitute ( '                     buf_price-doc-forming-gds.plt-id     = &1 and                     buf_price-doc-forming-gds.plt-db-num = &2 and                     buf_price-doc-forming-gds.pdf-id     = &3 and                     buf_price-doc-forming-gds.pdf-db     = &4 ' ,                     buf_price-doc-forming.plt-id ,                     buf_price-doc-forming.plt-db-num ,                     buf_price-doc-forming.pdf-id ,                     buf_price-doc-forming.pdf-db )  + " " + where-phrase-138
          else "true"
        )
      parameter-5-138 = (" " + "" + " " + ", EACH buf_goods OF buf_price-doc-forming-gds NO-LOCK,                                    EACH buf_bar-code OF buf_price-doc-forming-gds NO-LOCK")
      parameter-6-138 = if sort-phrase-138 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " by buf_price-doc-forming-gds.line-num  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-138
        )
      parameter-7-138 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-138 =
          (" buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id     and                      buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and                     buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id     and                     buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db " + " " + where-phrase-138 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query BROWSE-1:handle
                          ,input parameter-3-138
                          ,input parameter-4-138
                          ,input parameter-5-138
                          ,input parameter-6-138
                          ,input parameter-7-138
                          )
      .
      assign
        l-filter-open-138 = true
      .
    end.
    if l-filter-open-138 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-138 = false then do:
    OPEN QUERY BROWSE-1 FOR EACH buf_price-doc-forming-gds no-lock
      where  buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id     and                      buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and                     buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id     and                     buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db
    , EACH buf_goods OF buf_price-doc-forming-gds NO-LOCK,                                    EACH buf_bar-code OF buf_price-doc-forming-gds NO-LOCK
       by buf_price-doc-forming-gds.line-num
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_price-doc-forming-gds )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query BROWSE-1:handle:get-buffer-handle(1) = (buffer buf_price-doc-forming-gds:handle) then do:
      assign
      parameter-2-138 = (if p-find-next then "true":u else "false":u )
      parameter-4-138 =
        "where ":u +  substitute ( '                     buf_price-doc-forming-gds.plt-id     = &1 and                     buf_price-doc-forming-gds.plt-db-num = &2 and                     buf_price-doc-forming-gds.pdf-id     = &3 and                     buf_price-doc-forming-gds.pdf-db     = &4 ' ,                     buf_price-doc-forming.plt-id ,                     buf_price-doc-forming.plt-db-num ,                     buf_price-doc-forming.pdf-id ,                     buf_price-doc-forming.pdf-db )  + " ":u + where-phrase-138 + " ":u + p-find-condition + " " + ""
      parameter-5-138 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-1:handle
                          ,input rowid(buf_price-doc-forming-gds)
                          ,input logical(parameter-2-138)
                          ,input no-lock
                          ,input (buffer buf_price-doc-forming-gds:handle)
                          ,input parameter-4-138
                          ,input parameter-5-138
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-138 = (if p-find-next then "true":u else "false":u )
      parameter-3-138 =  "FOR EACH buf_price-doc-forming-gds"
      parameter-4-138 =
        (
          if (" buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id     and                      buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and                     buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id     and                     buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db " + " " + where-phrase-138) <> ""
          then  substitute ( '                     buf_price-doc-forming-gds.plt-id     = &1 and                     buf_price-doc-forming-gds.plt-db-num = &2 and                     buf_price-doc-forming-gds.pdf-id     = &3 and                     buf_price-doc-forming-gds.pdf-db     = &4 ' ,                     buf_price-doc-forming.plt-id ,                     buf_price-doc-forming.plt-db-num ,                     buf_price-doc-forming.pdf-id ,                     buf_price-doc-forming.pdf-db )  + " " + where-phrase-138
          else "true"
        )
      parameter-5-138 = (" " + "" + " " + ", EACH buf_goods OF buf_price-doc-forming-gds NO-LOCK,                                    EACH buf_bar-code OF buf_price-doc-forming-gds NO-LOCK" + " " + p-find-condition)
      parameter-6-138 = if sort-phrase-138 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " by buf_price-doc-forming-gds.line-num  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-138
        )
      parameter-7-138 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-1:handle
                          ,input logical(parameter-2-138)
                          ,input no-lock
                          ,input parameter-3-138
                          ,input parameter-4-138
                          ,input parameter-5-138
                          ,input parameter-6-138
                          ,input parameter-7-138
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
end.
when 2 then do:
define variable vss-include-info139 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable  l-disable-where-140  as logical   no-undo .
define variable  l-filter-open-140    as logical   .
define variable  flt-rec-140       as recid     no-undo .
define variable  filter-name-140      as character no-undo .
define variable  where-phrase-140     as character no-undo .
define variable  sort-phrase-140      as character no-undo .
define variable  where-phrase-rus-140 as character no-undo .
define variable  sort-phrase-rus-140  as character no-undo .
  run waitfram-show in this-procedure
    (input "ЖДИТЕ ..."
    ).
run gbl/flt-get.p
  (input filter-point
  ,output flt-rec-140
  ,output filter-name-140
  ,output where-phrase-140
  ,output sort-phrase-140
  ,output where-phrase-rus-140
  ,output sort-phrase-rus-140
  ).
if p-open-query then do:
    run set-filter-name in this-procedure
      (INPUT filter-name-140
      ) no-error .
  assign
    l-filter-open-140 = false
  .
  if flt-rec-140 <> ?
    or sort-column-phrase > ""
  then do:
    define variable  parameter-2-140 as character no-undo .
    define variable  parameter-3-140 as character no-undo .
    define variable  parameter-4-140 as character no-undo .
    define variable  parameter-5-140 as character no-undo .
    define variable  parameter-6-140 as character no-undo .
    define variable  parameter-7-140 as character no-undo .
      assign
      parameter-3-140 =
                              "FOR EACH buf_price-doc-forming-gds"
      parameter-4-140 =
        (
          if (" buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id     and                      buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and                     buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id     and                     buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db " + " " + where-phrase-140) <> ""
          then  substitute ( '                     buf_price-doc-forming-gds.plt-id     = &1 and                     buf_price-doc-forming-gds.plt-db-num = &2 and                     buf_price-doc-forming-gds.pdf-id     = &3 and                     buf_price-doc-forming-gds.pdf-db     = &4 ' ,                     buf_price-doc-forming.plt-id ,                     buf_price-doc-forming.plt-db-num ,                     buf_price-doc-forming.pdf-id ,                     buf_price-doc-forming.pdf-db )  + " " + where-phrase-140
          else "true"
        )
      parameter-5-140 = (" " + "" + " " + ", EACH buf_goods OF buf_price-doc-forming-gds NO-LOCK,                                    EACH buf_bar-code OF buf_price-doc-forming-gds NO-LOCK                                    where buf_goods.unit-base = buf_bar-code.unit-cli")
      parameter-6-140 = if sort-phrase-140 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " by buf_price-doc-forming-gds.line-num  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-140
        )
      parameter-7-140 =
        "   "
    .
    do
    on stop undo, leave
    on error undo, leave
    :
      assign
        l-disable-where-140 =
          (" buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id     and                      buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and                     buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id     and                     buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db " + " " + where-phrase-140 = "")
      .
      run fltopend_fltopend in this-procedure  ( input this-procedure:handle
                          ,input query BROWSE-1:handle
                          ,input parameter-3-140
                          ,input parameter-4-140
                          ,input parameter-5-140
                          ,input parameter-6-140
                          ,input parameter-7-140
                          )
      .
      assign
        l-filter-open-140 = true
      .
    end.
    if l-filter-open-140 = false then do:
      message
        "Ошибка при фильтрации / сортировке" skip
        "Будут показаны записи без учета фильтра" skip
        view-as alert-box .
    end.
    else do:
        assign
          l-query-was-opened = true
        .
    end.
  end.
  if l-filter-open-140 = false then do:
    OPEN QUERY BROWSE-1 FOR EACH buf_price-doc-forming-gds no-lock
      where  buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id     and                      buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and                     buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id     and                     buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db
    , EACH buf_goods OF buf_price-doc-forming-gds NO-LOCK,                                    EACH buf_bar-code OF buf_price-doc-forming-gds NO-LOCK                                    where buf_goods.unit-base = buf_bar-code.unit-cli
       by buf_price-doc-forming-gds.line-num
  .
      assign
        l-query-was-opened = true
      .
  end.
end.
else do:
  assign
    doc-rec = recid( buf_price-doc-forming-gds )
  .
  do
  on stop undo, leave
  on error undo, leave
  :
    if query BROWSE-1:handle:get-buffer-handle(1) = (buffer buf_price-doc-forming-gds:handle) then do:
      assign
      parameter-2-140 = (if p-find-next then "true":u else "false":u )
      parameter-4-140 =
        "where ":u +  substitute ( '                     buf_price-doc-forming-gds.plt-id     = &1 and                     buf_price-doc-forming-gds.plt-db-num = &2 and                     buf_price-doc-forming-gds.pdf-id     = &3 and                     buf_price-doc-forming-gds.pdf-db     = &4 ' ,                     buf_price-doc-forming.plt-id ,                     buf_price-doc-forming.plt-db-num ,                     buf_price-doc-forming.pdf-id ,                     buf_price-doc-forming.pdf-db )  + " ":u + where-phrase-140 + " ":u + p-find-condition + " " + ""
      parameter-5-140 = " "
    .
      run fltopend_fltfindd in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-1:handle
                          ,input rowid(buf_price-doc-forming-gds)
                          ,input logical(parameter-2-140)
                          ,input no-lock
                          ,input (buffer buf_price-doc-forming-gds:handle)
                          ,input parameter-4-140
                          ,input parameter-5-140
                          ) no-error.
      .
      assign
        doc-rec = integer(return-value)
        v-fltopend-rowid[1] = ?
      .
    end.
    else do:
      assign
      parameter-2-140 = (if p-find-next then "true":u else "false":u )
      parameter-3-140 =  "FOR EACH buf_price-doc-forming-gds"
      parameter-4-140 =
        (
          if (" buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id     and                      buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and                     buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id     and                     buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db " + " " + where-phrase-140) <> ""
          then  substitute ( '                     buf_price-doc-forming-gds.plt-id     = &1 and                     buf_price-doc-forming-gds.plt-db-num = &2 and                     buf_price-doc-forming-gds.pdf-id     = &3 and                     buf_price-doc-forming-gds.pdf-db     = &4 ' ,                     buf_price-doc-forming.plt-id ,                     buf_price-doc-forming.plt-db-num ,                     buf_price-doc-forming.pdf-id ,                     buf_price-doc-forming.pdf-db )  + " " + where-phrase-140
          else "true"
        )
      parameter-5-140 = (" " + "" + " " + ", EACH buf_goods OF buf_price-doc-forming-gds NO-LOCK,                                    EACH buf_bar-code OF buf_price-doc-forming-gds NO-LOCK                                    where buf_goods.unit-base = buf_bar-code.unit-cli" + " " + p-find-condition)
      parameter-6-140 = if sort-phrase-140 = ''
                           then
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + " by buf_price-doc-forming-gds.line-num  "
        )
                           else
        (
        " " + " " +
          " " + sort-column-phrase +
        " " + sort-phrase-140
        )
      parameter-7-140 =
        "   "
    .
      run fltopend_fltfindq in this-procedure  (
                          input this-procedure:handle
                          ,input query BROWSE-1:handle
                          ,input logical(parameter-2-140)
                          ,input no-lock
                          ,input parameter-3-140
                          ,input parameter-4-140
                          ,input parameter-5-140
                          ,input parameter-6-140
                          ,input parameter-7-140
                          ,output v-fltopend-rowid
                          ) no-error.
      .
      doc-rec = ?.
    end.
    assign
      l-query-was-opened = true
    .
  end.
end.
  run waitfram-hide in this-procedure .
end.
end case.
run vc-pdf in this-procedure .
if not p-open-query then
reposition browse-1 to recid doc-rec no-error.
if not p-open-query and v-fltopend-rowid[1] <> ? then
query browse-1:handle:reposition-to-rowid(v-fltopend-rowid) No-ERROR.
if logical(buf-price-list-type.have-rs-qnty-group) = true  or
           buf-price-list-type.have-rs-sum-group   = true  or
   logical(buf-price-list-type.have-rs-turn-group) = true then do:
  OPEN QUERY BROWSE-2 FOR EACH tt_price-doc-forming-gds-xxx OF                                  buf_price-doc-forming-gds NO-LOCK INDEXED-REPOSITION.
end.
END PROCEDURE.
PROCEDURE proc-add-gds :
define input  parameter p-mode   as integer   no-undo .
define input  parameter p-b-code as integer   no-undo .
define buffer buf_goods for ub.goods  .
define buffer buf_doc-line for ub.doc-line  .
define buffer buf_price-list for ub.price-list  .
define buffer buf_gds-obj for ub.gds-obj  .
assign  frame Dialog-Frame
  calc-method
  increase-pc
  round-method
  round-base
  doc-code
  copy-code
  copy-type
  common-price
  .
define buffer buf1_price-list-type-gds-grp for ub.price-list-type-gds-grp  .
define buffer buf2_price-doc-forming-gds   for ub.price-doc-forming-gds  .
define buffer bufo_price-doc-forming-gds   for ub.price-doc-forming-gds.
define buffer bufo_price-doc-forming       for ub.price-doc-forming  .
define variable varschartic as character no-undo .
define variable ref-list    as character no-undo .
define variable stp-cycl as logical   no-undo .
if p-mode = 4 then do:
    if par-is-pharm = "yes" then do:
    for each buf_doc-line no-lock where buf_doc-line.doc-code = doc-code :
        find first buf_goods no-lock where
                   buf_goods.artic     = buf_doc-line.artic and
                   buf_goods.prod-type = buf_doc-line.prod-type and
                   buf_goods.prod-code = buf_doc-line.prod-code no-error .
        find first buf_gds-obj no-lock where
                   buf_gds-obj.obj-type = v-cntxt-obj-type and
                   buf_gds-obj.obj-code = v-cntxt-obj-code and
                   buf_gds-obj.gds-code = buf_goods.gds-code  and
                   buf_gds-obj.fact-qnty <> 0
                   no-error .
        if not available buf_gds-obj then  next.
        find first tt-gds-list where tt-gds-list.gds-code = buf_goods.gds-code no-error .
        if not available tt-gds-list then do:
            create tt-gds-list.
            buffer-copy buf_goods to tt-gds-list .
        end.
    end.
    end.
end.
else do:
  if not ( calc-method = 'Накладная':U or
           calc-method = 'Накл-безНДС':U or
           calc-method = 'НсП+накл':U or
           calc-method = 'Переоценка':U or
           calc-method = 'ДокФормЦены':U
           )
  then do:
    if p-mode = 1 then do:
            run str/chsgdsls.w
            (   input parParentProc ,
                input "price-list" ,
                input "Строка документа"  ,
                input ? ,
                input ? ,
                input v-cntxt-host-code-obj ,
                input-output varschartic,
                output ref-list,
                output table tt-gds-list,
                input false
                ) no-error.
        if error-status :error then message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          ""
          view-as alert-box error
        .
    end.
  end.
  else do:
      if p-mode <> 2 then do:
      case calc-method :
        when 'ДокФормЦены':U then do:
        find first bufo_price-doc-forming no-lock where
                   bufo_price-doc-forming.pdf-id = integer(entry( 1 , doc-code , "|" )) and
                   bufo_price-doc-forming.pdf-db = integer(entry( 2 , doc-code , "|" )) no-error .
          if available bufo_price-doc-forming then do:
          for each bufo_price-doc-forming-gds no-lock where
                   bufo_price-doc-forming-gds.pdf-id = bufo_price-doc-forming.pdf-id and
                   bufo_price-doc-forming-gds.pdf-db = bufo_price-doc-forming.pdf-db and
                   bufo_price-doc-forming-gds.plt-id = bufo_price-doc-forming.plt-id and
                   bufo_price-doc-forming-gds.plt-db-num = bufo_price-doc-forming.plt-db-num
                  :
              find first buf_goods no-lock where
                         buf_goods.artic     = bufo_price-doc-forming-gds.artic     and
                         buf_goods.prod-type = bufo_price-doc-forming-gds.prod-type and
                         buf_goods.prod-code = bufo_price-doc-forming-gds.prod-code
                         no-error .
              find first tt-gds-list where
                         tt-gds-list.gds-code = buf_goods.gds-code
                         no-error .
              if not available tt-gds-list then do:
                create tt-gds-list.
                buffer-copy buf_goods to tt-gds-list .
              end.
          end.
          end.
        end.
        when 'Переоценка':U then do:
          for each buf_price-list no-lock where buf_price-list.doc-num = doc-code :
              find first buf_goods no-lock where
                        buf_goods.artic     = buf_price-list.artic and
                        buf_goods.prod-type = buf_price-list.prod-type and
                        buf_goods.prod-code = buf_price-list.prod-code no-error .
              find first tt-gds-list where tt-gds-list.gds-code = buf_goods.gds-code no-error .
              if not available tt-gds-list then do:
                  create tt-gds-list.
                  buffer-copy buf_goods to tt-gds-list .
              end.
          end.
        end.
        when 'Накладная':U or
        when 'Накл-безНДС':U then do:
          for each buf_doc-line no-lock where buf_doc-line.doc-code = doc-code by buf_doc-line.line-num :
              find first buf_goods no-lock where
                        buf_goods.artic     = buf_doc-line.artic and
                        buf_goods.prod-type = buf_doc-line.prod-type and
                        buf_goods.prod-code = buf_doc-line.prod-code no-error .
              find first tt-gds-list where tt-gds-list.gds-code = buf_goods.gds-code no-error .
              if not available tt-gds-list then do:
                  create tt-gds-list.
                  buffer-copy buf_goods to tt-gds-list .
              end.
          end.
        end.
       otherwise do:
       end.
       end case.
    end.
  end.
end.
if  logical(buf-price-list-type.use-gds-group) = true then do:
    for each tt-gds-list :
        find first tt-table2 no-lock where  ( tt-gds-list.grp-name begins tt-table2.f2 ) no-error .
        if not available tt-table2 then do:
           delete tt-gds-list .
        end.
    end.
end.
if p-mode = 1 or p-mode = 4 then do:
    run ver-pr-conf no-error .
    if error-status :error then return error return-value .
    run last-num in this-procedure (
        input recid(buf_price-doc-forming) ,
        output v-line-num )
        .
end.
define variable v-type-goods as integer   no-undo .
define variable i as integer   no-undo .
define variable is-petrolium as logical   no-undo .
define variable is-pieces    as logical   no-undo .
define variable v-next as logical   no-undo .
if par-pr-goods = "" or num-entries (par-pr-goods,".") <> 2 then v-type-goods = integer('1':U) .
repeat i = 1 to 8 :
  if par-pr-goods begins string(i) + "."  then  do:
     v-type-goods = i .
     leave.
  end.
end.
define variable v-errr as logical   no-undo .
define variable v-errstr as character no-undo .
v-errr = false .
v-errstr = "" .
define buffer buf1_bar-code for ub.bar-code  .
define buffer gg_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer buf1_goods for ub.goods  .
for each tt-gds-list ,
    first buf1_bar-code no-lock where
          buf1_bar-code.gds-code   = tt-gds-list.gds-code   and
          buf1_bar-code.in-code    = ""                     and
          buf1_bar-code.part-code  = ""                     and
          buf1_bar-code.unit-cli   = tt-gds-list.unit-base  and
          ( p-mode <> 3 or buf1_bar-code.b-code = p-b-code )
          :
  find buf1_goods   where buf1_goods.gds-code       = tt-gds-list.gds-code no-lock .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:   run str/lib-trn.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn) <> true) then do:     message       "Error starting lib-trn.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn_is-petrl in g#lib-trn
  (
     input buf1_goods.artic
  ,  input buf1_goods.prod-type
  ,  input buf1_goods.prod-code
  , output is-petrolium
  , output is-pieces
  ) .
  run ver-pr-nogds ( input  buf1_goods.gds-code , input par-pr-nogds, output v-next , output v-errstr ) .
  if not v-next then do:
  case string(v-type-goods) :
    when '8':U       then do:
      v-errr = true .
      v-errstr = "Запрет на  включение в переоценку товаров, услуг и топлива" .
      leave .
    end.
    when '1':U    then do:
    end.
    when '2':U     then do:
        if buf1_goods.gds-type = 'т':U  and is-petrolium = false  then do:
           v-errr = true .
           v-errstr = substitute("Запрет на добавление товаров в переоценку " , buf1_goods.artic, buf1_goods.gds-name, buf1_goods.gds-type ) .
           next .
        end.
    end.
    when '3':U    then do:
        if is-petrolium then do:
           v-errr = true .
           v-errstr = substitute("Запрет на добавление топлива в переоценку " , buf1_goods.artic, buf1_goods.gds-name ) .
           next .
        end.
    end.
    when '4':U      then do:
        if buf1_goods.gds-type = 'у':U then do:
           v-errr = true .
           v-errstr = substitute("Запрет на добавление услуг в переоценку " , buf1_goods.artic, buf1_goods.gds-name, buf1_goods.gds-type ) .
           next .
        end.
    end.
    when '5':U  then do:
        if buf1_goods.gds-type = 'т':U and is-petrolium = false  then do:
           v-errr = true .
           v-errstr = substitute("Запрет на добавление товаров и услуг в переоценку " , buf1_goods.artic, buf1_goods.gds-name, buf1_goods.gds-type , buf1_goods.unit-base ) .
           next .
        end.
        if buf1_goods.gds-type = 'у':U then do:
           v-errr = true .
           v-errstr = substitute("Запрет на добавление товаров и услуг в переоценку " , buf1_goods.artic, buf1_goods.gds-name, buf1_goods.gds-type ) .
           next .
        end.
    end.
    when '6':U  then do:
        if buf1_goods.gds-type <> 'у':U  then do:
            v-errr = true .
            v-errstr = substitute("Запрет на добавление топлива и товара в переоценку " , buf1_goods.artic, buf1_goods.gds-name, buf1_goods.gds-type, buf1_goods.unit-base ) .
           next .
        end.
    end.
    when '7':U then do:
        if buf1_goods.gds-type = 'т':U and is-petrolium = true   then do:
           v-errr = true .
           v-errstr = substitute("Запрет на добавление услуг и топлива в переоценку " , buf1_goods.artic, buf1_goods.gds-name, buf1_goods.unit-base ) .
           next .
        end.
        if buf1_goods.gds-type = 'у':U then do:
           v-errr = true .
           v-errstr = substitute("Запрет на добавление услуг и топлива в переоценку " , buf1_goods.artic, buf1_goods.gds-name, buf1_goods.gds-type ) .
           next .
        end.
    end.
  end case.
  end.
  else do:
  end.
   run create-calc-bc in this-procedure
       ( input  recid( buf_price-doc-forming )
        ,input  calc-method
        ,input  increase-pc
        ,input  round-method
        ,input  round-base
        ,input  buf1_bar-code.b-code
        ,input  tt-gds-list.gds-code
        ,input  tt-gds-list.artic
        ,input  tt-gds-list.prod-type
        ,input  tt-gds-list.prod-code
        ,input  v-base-rate
        ,input  v-base-scale
        ,input  v-exch-scale
        ,input  v-exch-rate
        ,input  doc-code
        ,input  common-price
        ,input  copy-type
        ,input  copy-code
        ,input-output v-line-num
        ,input-output v-sec
      ) no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "create-calc-bc"
        view-as alert-box error
      .
define buffer buf-gds-prt  for ub.gds-prt   .
define buffer buf-bar-code for ub.bar-code  .
define buffer buf-goods    for ub.goods     .
define buffer buf_parts for ub.parts  .
define variable cur-recid as recid    no-undo .
define variable cur-pr    as decimal  no-undo .
define variable cur-rt    as decimal  no-undo .
define variable cur-ex    as decimal  no-undo .
define variable new-num   as recid    no-undo .
define variable new-rec   as recid    no-undo .
  find  buf-bar-code no-lock where
        buf-bar-code.b-code = buf1_bar-code.b-code.
  find  buf-goods no-lock where
        buf-goods.gds-code = buf-bar-code.gds-code.
  find  buf-gds-prt no-lock where
        buf-gds-prt.node-code = buf-bar-code.node-code.
  find first buf_parts no-lock where
      ( buf_parts.out-code   = 'free-zone':U  or
        buf_parts.out-code   = buf-bar-code.in-code)  and
        buf_parts.status_    = false   and
        buf_parts.in-code    = buf-bar-code.in-code  and
        buf_parts.part-code  = buf-bar-code.part-code  and
        buf_parts.artic      = buf-goods.artic  and
        buf_parts.prod-type  = buf-goods.prod-type  and
        buf_parts.prod-code  = buf-goods.prod-code no-error .
    if  ( buf-gds-prt.upper-code = buf-goods.prt-root and
          buf-bar-code.in-code   = "" and
          buf-bar-code.part-code = "" and
          buf-bar-code.unit-cli  = buf-goods.unit-base  )
          or
            available buf_parts
          then do:
define variable vss-include-info141 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library2) <> true) then do:   run gbl/library2.p persistent no-error .   if error-status :error or (valid-handle(g#library2) <> true) then do:     message       "Error starting library2.p" skip       g#library2 skip       g#library2 :type skip       g#library2 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bc-mpl in g#library2
  (input  buf-price-list-type.gop-id
  ,input  buf-price-list-type.gop-db-num
  ,input  buf1_bar-code.b-code
  ,input  0
  ,input  0
  ,output cur-recid
  ,output cur-pr
  ,output cur-rt
  ,output cur-ex
  ) no-error .
        if error-status :error then
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "от bc-mpl"
          view-as alert-box error
        .
      if cur-pr <> ? then do:
        run expose-prt in this-procedure
            ( input calc-method ,
              input increase-pc ,
              input buf1_bar-code.b-code,
              input cur-recid    ,
              input recid( buf_price-doc-forming ),
              input round-method ,
              input round-base   ,
              input doc-code     ,
              input common-price ,
              input copy-type    ,
              input copy-code    ,
              input-output v-line-num  ,
              input-output v-sec   ,
              output new-rec) no-error.
              if error-status :error then do:
                message
                  "Ошибка вызова процедуры разворота специальных и неосновных цен."
                  view-as alert-box error.
                undo , return error.
              end.
      end.
        find first gg_price-doc-forming-gds exclusive-lock where
                   gg_price-doc-forming-gds.b-code     = buf1_bar-code.b-code and
                   gg_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
                   gg_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
                   gg_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
                   gg_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db
                   no-error .
          if available gg_price-doc-forming-gds and (
              ( calc-method = 'Отсутствует':U
                or
              ( calc-method <> 'Отсутствует':U
                and gg_price-doc-forming-gds.price-sale-doc = ?
                and calc-method <> 'Не-считать':U  )))
                and
                ( p-mode = 1 or gg_price-doc-forming-gds.price-sale-doc = ? )
              then do:
                  run str/mplform.w (
                    input  parParentProc ,
                    input  "ЦИКЛ":U    ,
                    input recid (buf_price-doc-forming)    ,
                    input recid (gg_price-doc-forming-gds) ,
                    input increase-pc ,
                    input round-method,
                    input round-base,
                    input calc-method,
                    input v-exch-rate,
                    input v-exch-scale,
                    input v-base-rate ,
                    input v-base-scale,
                    output stp-cycl )
                    no-error .
                    if error-status :error then
                       message error-status :error
                               error-status :get-message(1)
                               "Ошибка mplform"
                               .
                      if return-value = "error" then do:
                          delete gg_price-doc-forming-gds .
                          next.
                      end.
                   if stp-cycl = true then leave.
              end.
        run recalc-neos (
            gg_price-doc-forming-gds.b-code,
            gg_price-doc-forming-gds.artic,
            gg_price-doc-forming-gds.prod-type,
            gg_price-doc-forming-gds.prod-code
            ) no-error .
            if error-status :error then do:
              message
                vss-workfile vss-revision vss-description skip
                error-status :get-message(1) skip
                return-value skip
                "ошибка пересчета"
                view-as alert-box error
              .
            end.
    end.
    else do:
      if buf-bar-code.unit-cli <> buf-goods.unit-base then do:
      end.
    end.
  find first buf_price-doc-forming-gds no-lock  where
             buf_price-doc-forming-gds.plt-db-num  =  buf_price-doc-forming.plt-db-num and
             buf_price-doc-forming-gds.plt-id      =  buf_price-doc-forming.plt-id     and
             buf_price-doc-forming-gds.pdf-db      =  buf_price-doc-forming.pdf-db     and
             buf_price-doc-forming-gds.pdf-id      =  buf_price-doc-forming.pdf-id     and
             buf_price-doc-forming-gds.b-code      =  buf1_bar-code.b-code
             no-error .
             if error-status :error
             then
             message
               vss-workfile vss-revision vss-description skip
               error-status :get-message(1) skip
               return-value skip
               "123"  skip
               buf_price-doc-forming.plt-db-num   skip
               buf_price-doc-forming.plt-id       skip
               buf_price-doc-forming.pdf-db       skip
               buf_price-doc-forming.pdf-id       skip
               buf1_bar-code.b-code               skip
               view-as alert-box error
             .
        run make-xxx-line in this-procedure no-error .
        if error-status :error then
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "make-xxx-line"
          view-as alert-box error
        .
        run calc-price-sub in this-procedure
           (input  buf1_bar-code.b-code ,
            input  recid(buf_price-doc-forming) ,
            input  calc-method,
            input  increase-pc,
            input  round-method,
            input  round-base,
            input  doc-code,
            input  common-price,
            input  copy-type,
            input  copy-code,
            output calc-rec)
            no-error.
            if error-status :error then message
              vss-workfile vss-revision vss-description skip
              error-status :get-message(1) skip
              return-value skip
              "calc-price-sub"
              view-as alert-box error
            .
    run new-price-sub in this-procedure  (
         buf_price-doc-forming.plt-db-num
       , buf_price-doc-forming.plt-id
       , buf_price-doc-forming.pdf-db
       , buf_price-doc-forming.pdf-id
       , buf1_bar-code.b-code
       , buf-goods.artic
       , buf-goods.prod-type
       , buf-goods.prod-code
    ) no-error .
      if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "new-price-sub"
        view-as alert-box error
      .
end.
if v-errr = true then
    message
      "Не все выбранные товары были добавлены в переоценку" skip
      v-errstr
      view-as alert-box information .
run OpenBr in this-procedure (yes, no, '':U).
  find first buf_price-doc-forming-gds no-lock  where
             buf_price-doc-forming-gds.plt-db-num  =  buf_price-doc-forming.plt-db-num and
             buf_price-doc-forming-gds.plt-id      =  buf_price-doc-forming.plt-id     and
             buf_price-doc-forming-gds.pdf-db      =  buf_price-doc-forming.pdf-db     and
             buf_price-doc-forming-gds.pdf-id      =  buf_price-doc-forming.pdf-id     and
             buf_price-doc-forming-gds.line-num    =  v-line-num no-error .
reposition browse-1 to rowid rowid(buf_price-doc-forming-gds) no-error .
apply "value-changed" to browse-1 in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE proc-b-mark :
define variable varlog as logical   no-undo .
  if not available buf_price-doc-forming-gds then return.
  run local-mark in this-procedure.
  assign varlog = BROWSE-1 :select-next-row( ) in frame Dialog-Frame.
  apply "ENTRY":U to BROWSE-1 in frame Dialog-Frame.
  BROWSE-1:refresh() in frame Dialog-Frame .
  run vc-pdf in this-procedure .
END PROCEDURE.
PROCEDURE proc-b-move :
define input parameter par-action as character no-undo.
define variable  loc#log as logical no-undo .
  assign
  p-doc-rec = recid( buf_price-doc-forming )
  .
  case par-action:
    when "b-next":u then do:
      if valid-handle (p-br-handle) then do:
          loc#log = p-br-handle:select-next-row().
      end.
    end.
    when "b-prev":u then do:
      if valid-handle (p-br-handle) then do:
          loc#log = p-br-handle:select-prev-row().
      end.
    end.
  end case.
  assign p-doc-rec = p-buffer-handle:recid .
  if not loc#log then do:
    message
      "Это" ( if par-action = "b-next":u then "последний" else "первый" )
      "документ в списке!"
    view-as alert-box information.
    return no-apply.
  end.
END PROCEDURE.
PROCEDURE proc-end-o :
   hide FILL-IN_end-shift-date in frame Dialog-Frame
        FILL-IN_end-shift-num
        FILL-IN_end-date
        FILL-IN_end-sys-date
        l-loc-hour-2
        l-loc-min-2
        in frame Dialog-Frame .
if buf-price-list-type.main = true then do:
   hide FILL-IN_have-end-period in frame Dialog-Frame .
   return .
end.
if FILL-IN_have-end-period   =  true then do:
   case buf-price-list-type.work-date:
   when integer( '1':U ) then do:
      if p-mode <> 'ПРОСМОТР':U
      then enable FILL-IN_end-date with frame Dialog-Frame .
      display FILL-IN_end-date with frame Dialog-Frame .
   end.
   when integer( '2':U ) then do:
      display FILL-IN_end-shift-date FILL-IN_end-shift-num  with frame Dialog-Frame .
      if p-mode <> 'ПРОСМОТР':U then enable FILL-IN_end-shift-date FILL-IN_end-shift-num  with frame Dialog-Frame .
   end.
   when integer( '3':U ) then do:
      display FILL-IN_end-sys-date l-loc-hour-2 l-loc-min-2 with frame Dialog-Frame .
      if p-mode <> 'ПРОСМОТР':U then enable FILL-IN_end-sys-date l-loc-hour-2 l-loc-min-2  with frame Dialog-Frame .
   end.
   end case.
end.
END PROCEDURE.
PROCEDURE proc-start-o :
   hide FILL-IN_start-shift-date in frame Dialog-Frame
        FILL-IN_start-shift-num
        FILL-IN_start-date
        FILL-IN_start-sys-date
        l-loc-hour
        l-loc-min
        in frame Dialog-Frame .
if buf-price-list-type.main = true then do:
   hide FILL-IN_have-start-period in frame Dialog-Frame .
   return .
end.
if FILL-IN_have-start-period  =  true then do:
   case buf-price-list-type.work-date:
   when integer ( '1':U ) then do:
      display FILL-IN_start-date with frame Dialog-Frame .
      if p-mode <> 'ПРОСМОТР':U then enable FILL-IN_start-date with frame Dialog-Frame .
   end.
   when integer ( '2':U ) then do:
      display FILL-IN_start-shift-date FILL-IN_start-shift-num with frame Dialog-Frame .
      if p-mode <> 'ПРОСМОТР':U then enable FILL-IN_start-shift-date FILL-IN_start-shift-num  with frame Dialog-Frame .
   end.
   when integer ( '3':U ) then do:
      display FILL-IN_start-sys-date l-loc-hour l-loc-min with frame Dialog-Frame .
      if p-mode <> 'ПРОСМОТР':U then enable FILL-IN_start-sys-date l-loc-hour l-loc-min with frame Dialog-Frame .
   end.
   end case.
end.
END PROCEDURE.
PROCEDURE proc-value-1 :
  case calc-method :
    when 'Объект':U then do:
      enable copy-type copy-code r-copy with frame Dialog-Frame.
      display copy-type copy-code with frame Dialog-Frame.
    end.
    when 'Накладная':U or
    when 'Накл-безНДС':U or
    when 'НсП+накл':U or
    when 'Переоценка':U or
    when 'ДокФормЦены':U
    then do:
      enable doc-code r-copy with frame Dialog-Frame.
      display doc-code with frame Dialog-Frame.
    end.
    when 'Единая':U then do:
      enable common-price with frame Dialog-Frame.
      display common-price with frame Dialog-Frame.
    end.
  end case.
if (calc-method = 'Накладная':U or
    calc-method = 'Накл-безНДС':U or
    calc-method = 'НсП+накл':U or
    calc-method = 'Переоценка':U or
    calc-method = 'ДокФормЦены':U
    ) and
   doc-code = "" then
  apply "entry" to doc-code in frame Dialog-Frame.
else do:
   if (calc-method = 'Единая':U ) then apply "entry" to common-price in frame Dialog-Frame.
   else
   apply "entry" to browse-1 in frame Dialog-Frame.
end.
  if par-is-pharm = "yes" then do:
      display
        doc-code
      with frame Dialog-Frame no-error .
      enable doc-code r-copy with frame Dialog-Frame .
   end.
END PROCEDURE.
PROCEDURE proc-value-2 :
if  lookup( input frame Dialog-Frame round-method, 'Произвольно,Вверх,Коэффициент,9-99окончание':U ) > 0 then do:
    enable round-base with frame Dialog-Frame.
end.
ELSE do:
    hide round-base in frame Dialog-Frame.
end.
END PROCEDURE.
PROCEDURE recalc-neos :
define input  parameter p-b-code    as integer   no-undo .
define input  parameter p-artic     as character no-undo .
define input  parameter p-prod-type as character no-undo .
define input  parameter p-prod-code as integer   no-undo .
define buffer buf_price-doc-forming-gds for ub.price-doc-forming-gds  .
for each buf_price-doc-forming-gds exclusive-lock where
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.artic = p-artic and
             buf_price-doc-forming-gds.prod-type = p-prod-type and
             buf_price-doc-forming-gds.prod-code = p-prod-code and
             buf_price-doc-forming-gds.b-code    <>  p-b-code
             :
  run calc-price-alt in this-procedure
      (input  buf_price-doc-forming-gds.b-code
      ,input  recid ( buf_price-doc-forming )
      ,input  buf_price-doc-forming-gds.d-pcnt
      ,input  round-method
      ,input  round-base
      ,output buf_price-doc-forming-gds.price-sale-base
      ,output buf_price-doc-forming-gds.price-sale-doc
      ,output buf_price-doc-forming-gds.price-sale-rubl
      ).
end.
END PROCEDURE.
PROCEDURE save-header :
do
  on error undo, return error return-value
  :
  define variable v-param-sp as character no-undo .
  if calc-method  = ? then calc-method  = ''.
  if increase-pc  = ? then     increase-pc  = 0 .
  if round-method = ? then     round-method = ''.
  if round-base   = ? then     round-base   =  0.
  if doc-code     = ? then     doc-code     = '' .
  if common-price = ? then     common-price =   0 .
  if copy-type    = ? then     copy-type    = ''  .
  if copy-code    = ? then     copy-code    =    0 .
v-param-sp =                       calc-method + chr(4)      .
v-param-sp = v-param-sp + string(  increase-pc   ) + chr(4).
v-param-sp = v-param-sp +          round-method    + chr(4).
v-param-sp = v-param-sp +  string( round-base   ) + chr(4).
v-param-sp = v-param-sp +          doc-code        + chr(4).
v-param-sp = v-param-sp +  string( common-price ) + chr(4).
v-param-sp = v-param-sp +          copy-type                  .
v-param-sp = v-param-sp +  string( copy-code    ) .
run pdf-write (
    buf_price-doc-forming.pdf-id  ,
    buf_price-doc-forming.pdf-db  ,
    buf_price-doc-forming.plt-id  ,
    buf_price-doc-forming.plt-db-num ,
    'pricedocI' ,
    v-param-sp
    ) no-error .
if error-status :error then message
  vss-workfile vss-revision vss-description skip
  error-status :get-message(1) skip
  return-value skip
  ""
  view-as alert-box error
.
  end.
end procedure.
PROCEDURE save-proc :
   run metod-gop-obj in this-procedure ( v-cntxt-db-num,  buf-price-list-type.gop-id , buf-price-list-type.gop-db-num) .
   run metod-delobj-usr (
    buf_price-doc-forming.pdf-id  ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id    ,
    buf_price-doc-forming.plt-db-num
   ).
    if return-value = "nullobj"  then
   do:
    message
      "Внимание !!! Нет ни одного объекта для ДНЦ !!!"
      view-as alert-box error
      .
     return error "Внимание !!! Нет ни одного объекта для ДНЦ !!!" .
   end.
find current buf_price-doc-forming exclusive-lock no-error .
if error-status :error then return error "запись захвачена" .
 assign frame Dialog-Frame
    FILL-IN_base-rate
    FILL-IN_base-scale
    FILL-IN_exch-rate
    FILL-IN_exch-scale
    FILL-IN_name
    FILL-IN_have-start-period
    FILL-IN_start-sys-date
    FILL-IN_start-shift-num
    FILL-IN_start-date
    FILL-IN_start-shift-date
    FILL-IN_have-end-period
    FILL-IN_end-sys-date
    FILL-IN_end-shift-num
    FILL-IN_end-date
    FILL-IN_end-shift-date
    l-loc-hour
    l-loc-min
    l-loc-hour-2
    l-loc-min-2
    calc-method
    common-price
    copy-code
    copy-type
    doc-code
    increase-pc
    round-base
    round-method
     .
    if FILL-IN_base-rate = 0  or  FILL-IN_base-rate  < 0 or FILL-IN_base-rate  = ? or
       FILL-IN_base-scale = 0 or  FILL-IN_base-scale < 0 or FILL-IN_base-scale = ? then  do:
define variable vss-include-info142 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  v-base-code
  ,input  TODAY
  ,output FILL-IN_base-rate
  ,output FILL-IN_base-scale
  ,output v-curr-abbr-bv
  )  .
    end.
    if FILL-IN_exch-rate = 0  or  FILL-IN_exch-rate  < 0 or FILL-IN_exch-rate  = ? or
       FILL-IN_exch-scale = 0 or  FILL-IN_exch-scale < 0 or FILL-IN_exch-scale = ? then  do:
define variable vss-include-info143 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run exchrate in g#library
  (input  buf-price-list-type.curr-code
  ,input  TODAY
  ,output FILL-IN_exch-rate
  ,output FILL-IN_exch-scale
  ,output v-curr-abbr-vd
  )  .
   end.
    if FILL-IN_base-rate = 0  or  FILL-IN_base-rate  < 0 or FILL-IN_base-rate  = ? then  return error SUBSTITUTE("Неверно установлено значение базовой валюты"  ) .
    if FILL-IN_exch-rate = 0  or  FILL-IN_exch-rate  < 0 or FILL-IN_exch-rate  = ? then  return error SUBSTITUTE("Неверно установлено значение курса валюты"    ) .
    if FILL-IN_base-scale = 0 or  FILL-IN_base-scale < 0 or FILL-IN_base-scale = ? then  return error SUBSTITUTE("Неверно установлено значение м-ба базовой валюты"  ) .
    if FILL-IN_exch-scale = 0 or  FILL-IN_exch-scale < 0 or FILL-IN_exch-scale = ? then  return error SUBSTITUTE("Неверно установлено значение м-ба валюты"      ) .
 assign
    buf_price-doc-forming.name              = FILL-IN_name
    buf_price-doc-forming.have-start-period = int(FILL-IN_have-start-period )
    buf_price-doc-forming.start-sys-date    = FILL-IN_start-sys-date
    buf_price-doc-forming.start-sys-time    = ( l-loc-hour * 60 * 60 )  + ( l-loc-min * 60 )
    buf_price-doc-forming.start-shift-num   = FILL-IN_start-shift-num
    buf_price-doc-forming.start-date        = FILL-IN_start-date
    buf_price-doc-forming.start-shift-date  = FILL-IN_start-shift-date
    buf_price-doc-forming.have-end-period   = int(FILL-IN_have-end-period )
    buf_price-doc-forming.end-sys-date      = FILL-IN_end-sys-date
    buf_price-doc-forming.end-sys-time    = ( l-loc-hour-2 * 60 * 60 )  + ( l-loc-min-2 * 60 )
    buf_price-doc-forming.end-shift-num     = FILL-IN_end-shift-num
    buf_price-doc-forming.end-date          = FILL-IN_end-date
    buf_price-doc-forming.end-shift-date    = FILL-IN_end-shift-date
    buf_price-doc-forming.base-rate         = FILL-IN_base-rate
    buf_price-doc-forming.base-scale        = FILL-IN_base-scale
    buf_price-doc-forming.db-num-chg        = v-cntxt-db-num
    buf_price-doc-forming.exch-rate         = FILL-IN_exch-rate
    buf_price-doc-forming.exch-scale        = FILL-IN_exch-scale
    buf_price-doc-forming.stts              = integer('0':U)
    buf_price-doc-forming.sys-date          = today
    buf_price-doc-forming.sys-time          = time
    buf_price-doc-forming.sys-time-chr      = string ( buf_price-doc-forming.sys-time , "hh:mm" )
       .
    run save-tt-line in this-procedure .
    if can-find (first buf_price-doc-forming-gds where
                       buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
                       buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
                       buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
                       buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
                       buf_price-doc-forming-gds.price-sale = ? no-lock)
                   then do:
      g#log = no.
      message "В документе есть нерассчитанные строки. Удалить их ?"
      view-as alert-box question buttons yes-no update g#log.
          if g#log then do:
              for each buf_price-doc-forming-gds no-lock where
                        buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
                        buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
                        buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
                        buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
                        buf_price-doc-forming-gds.price-sale = ? :
                      run del-doc-line ( input recid (buf_price-doc-forming-gds)) no-error  .
                      if error-status :error then do:
                          message  vss-workfile vss-revision vss-description skip
                          " Нельзя удалить " buf_price-doc-forming-gds.b-code skip
                          error-status :get-message(1) .
                      end.
                end.
          end.
  end.
    run ver-dfc-mpl-lib3 in this-procedure ( recid (buf_price-doc-forming) ) no-error  .
    if error-status :error and return-value <> "no-records":U then do:
       message
       return-value
       skip
       "Документ нельзя записать в БД, удалить его ? "  view-as alert-box question
       buttons yes-no
       update v-ok1 as logical
       .
       error-status :error = false .
       if v-ok1 = true then  do:
          delete buf_price-doc-forming .
       end.
    end.
    if return-value = "no-records":U then do:
       message "В документе нет ни одной строки , удалить ?" view-as alert-box question
       buttons yes-no
       update v-ok as logical
       .
       if v-ok = true then  do:
          delete buf_price-doc-forming .
       end.
    end.
    else do:
       if error-status :error then return error SUBSTITUTE("- &1  &2" , return-value , error-status :get-message(1)) .
    end.
  define variable p-err as logical   no-undo .
  if available buf_price-doc-forming then do:
    if doc-code <> "" and par-pr-discm = 'sale-' then do:
      buf_price-doc-forming.out-code = doc-code .
    end.
    run save-header.
      run ver-pr-discnS in this-procedure (
        input buf_price-doc-forming.plt-id   ,
        input buf_price-doc-forming.plt-db-num ,
        input buf_price-doc-forming.pdf-id ,
        input buf_price-doc-forming.pdf-db ,
        input "",
        input buf_price-doc-forming.out-code ,
        output p-err )
          no-error .
          if error-status :error then do:
              message "Ошибка при проверке процента наценки!" skip
              "Остаться в документе для исправления строки ?" skip
              view-as alert-box question
              buttons yes-no
              Title "Внимание !!!"
              update v-qqq as logical
                .
          if v-qqq then p-err = true .
          else p-err = false .
        if p-err then return error return-value .
     end.
  end.
END PROCEDURE.
PROCEDURE save-tt-line :
define buffer buf_price-doc-forming-gds-qnty for ub.price-doc-forming-gds-qnty  .
for each tt_price-doc-forming-gds-xxx :
   if logical(buf-price-list-type.have-rs-qnty-group) = true then do:
   find first buf_price-doc-forming-gds-qnty exclusive-lock where
              buf_price-doc-forming-gds-qnty.plt-id       = tt_price-doc-forming-gds-xxx.plt-id     and
              buf_price-doc-forming-gds-qnty.plt-db-num   = tt_price-doc-forming-gds-xxx.plt-db-num and
              buf_price-doc-forming-gds-qnty.pdf-id       = tt_price-doc-forming-gds-xxx.pdf-id     and
              buf_price-doc-forming-gds-qnty.pdf-db       = tt_price-doc-forming-gds-xxx.pdf-db     and
              buf_price-doc-forming-gds-qnty.b-code       = tt_price-doc-forming-gds-xxx.b-code     and
              buf_price-doc-forming-gds-qnty.qgr-id       = tt_price-doc-forming-gds-xxx.qgr-id     and
              buf_price-doc-forming-gds-qnty.qgr-db-num   = tt_price-doc-forming-gds-xxx.qgr-db-num and
              buf_price-doc-forming-gds-qnty.ggr-qnty     = tt_price-doc-forming-gds-xxx.ggr-qnty
              no-error .
              if not available buf_price-doc-forming-gds-qnty then do:
                create buf_price-doc-forming-gds-qnty.
                assign
                  buf_price-doc-forming-gds-qnty.plt-id       = tt_price-doc-forming-gds-xxx.plt-id
                  buf_price-doc-forming-gds-qnty.plt-db-num   = tt_price-doc-forming-gds-xxx.plt-db-num
                  buf_price-doc-forming-gds-qnty.pdf-id       = tt_price-doc-forming-gds-xxx.pdf-id
                  buf_price-doc-forming-gds-qnty.pdf-db       = tt_price-doc-forming-gds-xxx.pdf-db
                  buf_price-doc-forming-gds-qnty.b-code       = tt_price-doc-forming-gds-xxx.b-code
                  buf_price-doc-forming-gds-qnty.qgr-id       = tt_price-doc-forming-gds-xxx.qgr-id
                  buf_price-doc-forming-gds-qnty.qgr-db-num   = tt_price-doc-forming-gds-xxx.qgr-db-num
                  buf_price-doc-forming-gds-qnty.ggr-qnty     = tt_price-doc-forming-gds-xxx.ggr-qnty
                .
              end.
              buffer-copy tt_price-doc-forming-gds-xxx to buf_price-doc-forming-gds-qnty .
    end.
end.
define buffer buf_price-doc-forming-gds-sum for ub.price-doc-forming-gds-sum  .
for each tt_price-doc-forming-gds-xxx :
   if buf-price-list-type.have-rs-sum-group = true then do:
   find first buf_price-doc-forming-gds-sum exclusive-lock where
              buf_price-doc-forming-gds-sum.plt-id       = tt_price-doc-forming-gds-xxx.plt-id     and
              buf_price-doc-forming-gds-sum.plt-db-num   = tt_price-doc-forming-gds-xxx.plt-db-num and
              buf_price-doc-forming-gds-sum.pdf-id       = tt_price-doc-forming-gds-xxx.pdf-id     and
              buf_price-doc-forming-gds-sum.pdf-db       = tt_price-doc-forming-gds-xxx.pdf-db     and
              buf_price-doc-forming-gds-sum.b-code       = tt_price-doc-forming-gds-xxx.b-code     and
              buf_price-doc-forming-gds-sum.sgr-id       = tt_price-doc-forming-gds-xxx.qgr-id     and
              buf_price-doc-forming-gds-sum.sgr-db-num   = tt_price-doc-forming-gds-xxx.qgr-db-num and
              buf_price-doc-forming-gds-sum.ssg-summa    = tt_price-doc-forming-gds-xxx.ggr-qnty
              no-error .
              if not available buf_price-doc-forming-gds-sum then do:
                create buf_price-doc-forming-gds-sum.
                assign
                  buf_price-doc-forming-gds-sum.plt-id       = tt_price-doc-forming-gds-xxx.plt-id
                  buf_price-doc-forming-gds-sum.plt-db-num   = tt_price-doc-forming-gds-xxx.plt-db-num
                  buf_price-doc-forming-gds-sum.pdf-id       = tt_price-doc-forming-gds-xxx.pdf-id
                  buf_price-doc-forming-gds-sum.pdf-db       = tt_price-doc-forming-gds-xxx.pdf-db
                  buf_price-doc-forming-gds-sum.b-code       = tt_price-doc-forming-gds-xxx.b-code
                  buf_price-doc-forming-gds-sum.sgr-id       = tt_price-doc-forming-gds-xxx.qgr-id
                  buf_price-doc-forming-gds-sum.sgr-db-num   = tt_price-doc-forming-gds-xxx.qgr-db-num
                  buf_price-doc-forming-gds-sum.ssg-summa    = tt_price-doc-forming-gds-xxx.ggr-qnty
                .
              end.
              buffer-copy tt_price-doc-forming-gds-xxx to buf_price-doc-forming-gds-sum
              assign
                  buf_price-doc-forming-gds-sum.sgr-id       = tt_price-doc-forming-gds-xxx.qgr-id
                  buf_price-doc-forming-gds-sum.sgr-db-num   = tt_price-doc-forming-gds-xxx.qgr-db-num
                  buf_price-doc-forming-gds-sum.ssg-summa    = tt_price-doc-forming-gds-xxx.ggr-qnty
              .
    end.
end.
define buffer buf_price-doc-forming-gds-tnv for ub.price-doc-forming-gds-tnv  .
for each tt_price-doc-forming-gds-xxx :
   if logical(buf-price-list-type.have-rs-turn-group) = true then do:
   find first buf_price-doc-forming-gds-tnv exclusive-lock where
              buf_price-doc-forming-gds-tnv.plt-id       = tt_price-doc-forming-gds-xxx.plt-id     and
              buf_price-doc-forming-gds-tnv.plt-db-num   = tt_price-doc-forming-gds-xxx.plt-db-num and
              buf_price-doc-forming-gds-tnv.pdf-id       = tt_price-doc-forming-gds-xxx.pdf-id     and
              buf_price-doc-forming-gds-tnv.pdf-db       = tt_price-doc-forming-gds-xxx.pdf-db     and
              buf_price-doc-forming-gds-tnv.b-code       = tt_price-doc-forming-gds-xxx.b-code     and
              buf_price-doc-forming-gds-tnv.tog-id       = tt_price-doc-forming-gds-xxx.qgr-id     and
              buf_price-doc-forming-gds-tnv.tog-db-num   = tt_price-doc-forming-gds-xxx.qgr-db-num and
              buf_price-doc-forming-gds-tnv.ttg-summa    = tt_price-doc-forming-gds-xxx.ggr-qnty
              no-error .
              if not available buf_price-doc-forming-gds-tnv then do:
                create buf_price-doc-forming-gds-tnv.
                assign
                  buf_price-doc-forming-gds-tnv.plt-id       = tt_price-doc-forming-gds-xxx.plt-id
                  buf_price-doc-forming-gds-tnv.plt-db-num   = tt_price-doc-forming-gds-xxx.plt-db-num
                  buf_price-doc-forming-gds-tnv.pdf-id       = tt_price-doc-forming-gds-xxx.pdf-id
                  buf_price-doc-forming-gds-tnv.pdf-db       = tt_price-doc-forming-gds-xxx.pdf-db
                  buf_price-doc-forming-gds-tnv.b-code       = tt_price-doc-forming-gds-xxx.b-code
                  buf_price-doc-forming-gds-tnv.tog-id       = tt_price-doc-forming-gds-xxx.qgr-id
                  buf_price-doc-forming-gds-tnv.tog-db-num   = tt_price-doc-forming-gds-xxx.qgr-db-num
                  buf_price-doc-forming-gds-tnv.ttg-summa    = tt_price-doc-forming-gds-xxx.ggr-qnty
                .
              end.
              buffer-copy tt_price-doc-forming-gds-xxx to buf_price-doc-forming-gds-tnv
              assign
                  buf_price-doc-forming-gds-tnv.tog-id       = tt_price-doc-forming-gds-xxx.qgr-id
                  buf_price-doc-forming-gds-tnv.tog-db-num   = tt_price-doc-forming-gds-xxx.qgr-db-num
                  buf_price-doc-forming-gds-tnv.ttg-summa    = tt_price-doc-forming-gds-xxx.ggr-qnty
              .
    end.
end.
END PROCEDURE.
PROCEDURE seach-artic :
define input  parameter p-artic as character no-undo .
define input  parameter p-next as logical   no-undo .
if p-next = true then do:
   find next buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.artic begins loc-art and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
              if not available buf_price-doc-forming-gds then do:
                message "Еще запись не найдена ! " view-as alert-box information .
                return .
              end.
end.
else do:
  find first buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.artic begins loc-art and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
              if not available buf_price-doc-forming-gds then do:
                message "Запись не найдена !" view-as alert-box information .
                return .
              end.
end.
reposition BROWSE-1 to rowid rowid(buf_price-doc-forming-gds) no-error .
apply "value-changed" to BROWSE-1 in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE seach-code :
define input  parameter p-b-code as integer   no-undo .
define input  parameter p-next as logical   no-undo .
if p-next = true then do:
   find next buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.b-code = p-b-code and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
              if not available buf_price-doc-forming-gds then do:
                message "Еще запись не найдена ! " view-as alert-box information .
                return .
              end.
end.
else do:
  find first buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.b-code = p-b-code and
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num no-error .
              if not available buf_price-doc-forming-gds then do:
                message "Запись не найдена !" view-as alert-box information .
                return .
              end.
end.
reposition BROWSE-1 to rowid rowid(buf_price-doc-forming-gds) no-error .
apply "value-changed" to BROWSE-1 in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE seach-name :
define input  parameter p-name as character no-undo .
define input  parameter p-next as logical   no-undo .
if p-next = true then do:
   find next buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
             can-find ( ub.goods where ub.goods.prod-type = buf_price-doc-forming-gds.prod-type and
                                       ub.goods.prod-code = buf_price-doc-forming-gds.prod-code and
                                       ub.goods.artic     = buf_price-doc-forming-gds.artic and
                                       ub.goods.gds-name begins p-name         )             no-error .
              if not available buf_price-doc-forming-gds then do:
                message "Еще запись не найдена ! " view-as alert-box information .
                return .
              end.
end.
else do:
  find first buf_price-doc-forming-gds no-lock where
             buf_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id and
             buf_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db and
             buf_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id and
             buf_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
             can-find ( ub.goods where ub.goods.prod-type = buf_price-doc-forming-gds.prod-type and
                                       ub.goods.prod-code = buf_price-doc-forming-gds.prod-code and
                                       ub.goods.artic     = buf_price-doc-forming-gds.artic and
                                       ub.goods.gds-name begins p-name         )             no-error .
              if not available buf_price-doc-forming-gds then do:
                message "Запись не найдена !" view-as alert-box information .
                return .
              end.
end.
reposition BROWSE-1 to rowid rowid(buf_price-doc-forming-gds) no-error .
apply "value-changed" to BROWSE-1 in frame Dialog-Frame.
END PROCEDURE.
PROCEDURE select-header :
do
  on error undo, return error return-value
  :
define variable v-exist as logical   no-undo .
define variable v-param-sp as character no-undo .
define variable p-type as character no-undo .
run pdf-exist (
      buf_price-doc-forming.pdf-id  ,
      buf_price-doc-forming.pdf-db  ,
      buf_price-doc-forming.plt-id  ,
      buf_price-doc-forming.plt-db-num ,
      'pricedocI' ,
      output v-exist ).
if v-exist then  do:
   run pdf-value (
      buf_price-doc-forming.pdf-id  ,
      buf_price-doc-forming.pdf-db  ,
      buf_price-doc-forming.plt-id  ,
      buf_price-doc-forming.plt-db-num ,
      'pricedocI',
      output v-param-sp
      ) .
   if num-entries(v-param-sp,chr(4)) >= 3 then
      assign
        calc-method  = entry (1,v-param-sp,chr(4))
        increase-pc  = decimal (entry(2,v-param-sp,chr(4)))
        round-method = entry (3,v-param-sp,chr(4))
        round-base   = decimal (entry(4,v-param-sp,chr(4)))
        doc-code     = entry (5,v-param-sp,chr(4))
        common-price = decimal(entry (6,v-param-sp,chr(4)))
        copy-type    = substring(entry (7,v-param-sp,chr(4)),1,3)
        copy-code    = integer(substring(entry (7,v-param-sp,chr(4)),4,15))
        .
   calc-method:screen-value in frame Dialog-Frame  = calc-method  .
   doc-code:screen-value in frame Dialog-Frame     = doc-code     .
   increase-pc:screen-value in frame Dialog-Frame  = string(increase-pc)  .
   round-method:screen-value in frame Dialog-Frame = round-method .
   round-base:screen-value in frame Dialog-Frame   = string(round-base )  .
   common-price:screen-value in frame Dialog-Frame = string(common-price) .
   copy-type:screen-value in frame Dialog-Frame    = copy-type    .
   copy-code:screen-value in frame Dialog-Frame    = string(copy-code)    .
   run proc-value-1 in this-procedure .
   run proc-value-2 in this-procedure .
end.
end.
end procedure.
PROCEDURE select-xxx-line :
    if logical(buf-price-list-type.have-rs-qnty-group) = true then do:
        define buffer buf_price-doc-forming-gds-qnty for ub.price-doc-forming-gds-qnty  .
        for each buf_price-doc-forming-gds-qnty no-lock where
                buf_price-doc-forming-gds-qnty.pdf-db     = buf_price-doc-forming.pdf-db    and
                buf_price-doc-forming-gds-qnty.pdf-id     = buf_price-doc-forming.pdf-id    and
                buf_price-doc-forming-gds-qnty.plt-db-num = buf_price-doc-forming.plt-db-num and
                buf_price-doc-forming-gds-qnty.plt-id     = buf_price-doc-forming.plt-id     :
            create tt_price-doc-forming-gds-xxx.
            buffer-copy buf_price-doc-forming-gds-qnty to tt_price-doc-forming-gds-xxx.
        end.
    end.
    if buf-price-list-type.have-rs-sum-group = true then do:
        define buffer buf_price-doc-forming-gds-sum  for ub.price-doc-forming-gds-sum   .
        for each buf_price-doc-forming-gds-sum no-lock where
                buf_price-doc-forming-gds-sum.pdf-db     = buf_price-doc-forming.pdf-db    and
                buf_price-doc-forming-gds-sum.pdf-id     = buf_price-doc-forming.pdf-id    and
                buf_price-doc-forming-gds-sum.plt-db-num = buf_price-doc-forming.plt-db-num and
                buf_price-doc-forming-gds-sum.plt-id     = buf_price-doc-forming.plt-id     :
            create tt_price-doc-forming-gds-xxx.
            buffer-copy buf_price-doc-forming-gds-sum to tt_price-doc-forming-gds-xxx
            assign
                tt_price-doc-forming-gds-xxx.ggr-qnty    = buf_price-doc-forming-gds-sum.ssg-summa
                tt_price-doc-forming-gds-xxx.qgr-db-num  = buf_price-doc-forming-gds-sum.sgr-db-num
                tt_price-doc-forming-gds-xxx.qgr-id      = buf_price-doc-forming-gds-sum.sgr-id
                .
        end.
    end.
    if logical(buf-price-list-type.have-rs-turn-group) = true then do:
        define buffer buf_price-doc-forming-gds-tnv  for ub.price-doc-forming-gds-tnv   .
        for each buf_price-doc-forming-gds-tnv no-lock where
                buf_price-doc-forming-gds-tnv.pdf-db     = buf_price-doc-forming.pdf-db    and
                buf_price-doc-forming-gds-tnv.pdf-id     = buf_price-doc-forming.pdf-id    and
                buf_price-doc-forming-gds-tnv.plt-db-num = buf_price-doc-forming.plt-db-num and
                buf_price-doc-forming-gds-tnv.plt-id     = buf_price-doc-forming.plt-id     :
            create tt_price-doc-forming-gds-xxx.
            buffer-copy buf_price-doc-forming-gds-tnv to tt_price-doc-forming-gds-xxx
            assign
                tt_price-doc-forming-gds-xxx.ggr-qnty    = buf_price-doc-forming-gds-tnv.ttg-summa
                tt_price-doc-forming-gds-xxx.qgr-db-num  = buf_price-doc-forming-gds-tnv.tog-db-num
                tt_price-doc-forming-gds-xxx.qgr-id      = buf_price-doc-forming-gds-tnv.tog-id
                .
        end.
    end.
END PROCEDURE.
PROCEDURE upd-br-field :
define variable v-recid as recid no-undo .
v-recid = recid (buf_price-doc-forming-gds) .
define buffer loc_price-doc-forming-gds for ub.price-doc-forming-gds  .
find first loc_price-doc-forming-gds no-lock where recid(loc_price-doc-forming-gds ) = v-recid no-error .
run ref/h-pdfgds.p
  ( buffer loc_price-doc-forming-gds ,
     input buf_price-doc-forming-gds.price-sale-doc :screen-value in browse browse-1 ,
     input-output v-sec
     ) no-error .
     if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          error-status :get-message(1) skip
          return-value skip
          "h-pdfgds.p"
          view-as alert-box error
        .
     end.
END PROCEDURE.
PROCEDURE vc-pdf :
v-in-doc-qnty = ? .
if not available buf_price-doc-forming-gds then return.
define variable v1-recid as recid no-undo .
define buffer bf_goods for ub.goods   .
define variable p-avrg1  as decimal   no-undo .
define variable p-qnty1  as decimal   no-undo .
assign
  p-avrg1 = 0
  p-qnty1 = 0
  obj-in-date = 01/01/1990
  obj-in-code = ""
  p-last = 0
  v-free-qnty = 0
  v-fact-qnty = 0
  v-in-doc-qnty = ?
.
find first bf_goods no-lock where
           bf_goods.artic = buf_price-doc-forming-gds.artic and
           bf_goods.prod-type = buf_price-doc-forming-gds.prod-type and
           bf_goods.prod-code = buf_price-doc-forming-gds.prod-code no-error .
run metod-delobj-usr (
    buf_price-doc-forming.pdf-id  ,
    buf_price-doc-forming.pdf-db ,
    buf_price-doc-forming.plt-id    ,
    buf_price-doc-forming.plt-db-num
   ).
for each x_obj-group :
    find ub.gds-obj no-lock where
        ub.gds-obj.artic     = buf_price-doc-forming-gds.artic     and
        ub.gds-obj.prod-type = buf_price-doc-forming-gds.prod-type and
        ub.gds-obj.prod-code = buf_price-doc-forming-gds.prod-code and
        ub.gds-obj.obj-type  = x_obj-group.obj-type and
        ub.gds-obj.obj-code  = x_obj-group.obj-code no-error.
        if available ub.gds-obj and ub.gds-obj.avrg-rubl <> ? then do:
           assign
            p-avrg1 = p-avrg1 + (if var-pr-r-b = "rubl" then  ub.gds-obj.avrg-rubl else ub.gds-obj.avrg-base) * ub.gds-obj.avrg-qnty
            p-qnty1 = p-qnty1 + ub.gds-obj.avrg-qnty
           .
        end.
        if available ub.gds-obj and ub.gds-obj.in-date <> ? then do:
            if obj-in-date < ub.gds-obj.in-date then do:
                assign
                  obj-in-date = ub.gds-obj.in-date
                  obj-in-code = ub.gds-obj.in-code
                  p-last = if var-pr-r-b = "rubl" then  ub.gds-obj.last-rubl else ub.gds-obj.last-base
                  v-free-qnty = ub.gds-obj.free-qnty
                  v-fact-qnty = ub.gds-obj.fact-qnty
                .
            end.
        end.
end.
if obj-in-code <> ? and obj-in-code > "" and available bf_goods
then do:
  find first buf_doc-line no-lock where buf_doc-line.doc-code  = obj-in-code
                                   and buf_doc-line.artic     = bf_goods.artic
                                   and buf_doc-line.prod-type = bf_goods.prod-type
                                   and buf_doc-line.prod-code = bf_goods.prod-code no-error .
  if available buf_doc-line
  then do:
    v-in-doc-qnty = buf_doc-line.fact-qnty .
  end.
  else do:
    v-in-doc-qnty = ? .
  end.
end.
if obj-in-date = 01/01/1990  then obj-in-date = ?.
if p-qnty1 = 0 or p-qnty1 = ? then p-avrg = ? .
                              else p-avrg = p-avrg1 / p-qnty1.
define variable v-cur-dn as character no-undo .
define variable v-cur-pr as decimal   no-undo .
define variable v-cur-rt as decimal   no-undo .
define variable v-cur-ex as decimal   no-undo .
find first x_obj-group no-error .
if error-status :error then return .
define variable vss-include-info144 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run bcodeprc in g#library
  (input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,input  buf_price-doc-forming-gds.b-code
  ,input  0
  ,input  0
  ,output v-cur-dn
  ,output v-cur-pr
  ,output v-cur-rt
  ,output v-cur-ex
  )  .
if par-is-pharm = "yes"  then do:
define variable vss-include-info145 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run proprice in g#library
(  input  buf_price-doc-forming-gds.b-code
 , input  x_obj-group.obj-type
 , input  x_obj-group.obj-code
 , output v-prod-price
 , output v-priceprodwithvat-2
 , output v-prod-vat
 , output v-str1
 , output v-str1
        )  .
  v-ost  = f-ost-part ( buf_price-doc-forming-gds.b-code,x_obj-group.obj-type , x_obj-group.obj-code ) .
  var-vat-pc = 0 .
define variable vss-include-info146 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run pftxvalg in g#library
  (input  bf_goods.gds-code
  ,input  '1':U
  ,input  ?
  ,input  v-cntxt-host-code-obj
  ,input  x_obj-group.obj-type
  ,input  x_obj-group.obj-code
  ,output var-vat-pc
  ) no-error .
end.
assign
  p-pr-doc-old = v-cur-pr
  prev-price_doc-num =  v-cur-dn
  p-old = buf_price-doc-forming-gds.price-prev-doc
  p-new = buf_price-doc-forming-gds.price-sale-doc
  p-pc-prev = (p-new / p-old  - 1) * 100
  p-op-avrg = (p-old / p-avrg - 1) * 100
  p-pc-avrg = (p-new / p-avrg - 1) * 100
  p-op-pr-doc-old = (p-old / p-pr-doc-old - 1) * 100
  p-pc-pr-doc-old = (p-new / p-pr-doc-old - 1) * 100
  p-op-last = (p-old / p-last - 1) * 100
  p-pc-last = (p-new / p-last - 1) * 100
  p-pc-op-pr-doc-old = p-pc-pr-doc-old - p-op-pr-doc-old
  p-pc-op-avrg = p-pc-avrg - p-op-avrg
  p-pc-op-last = p-pc-last - p-op-last
  p-calc-metod = buf_price-doc-forming-gds.calc-method
  v-new-price-vat  = p-new - ( p-new * var-vat-pc / (100 + var-vat-pc))
  v-prod-price-prc   = ( p-new  / v-prod-price - 1 ) * 100
  v-prod-price-prc-2 = ( v-new-price-vat / v-priceprodwithvat-2 - 1 ) * 100
  v-prod-price-prc-3 = ( p-new / v-priceprodwithvat-2 - 1 ) * 100
  .
  if num-entries(buf_price-doc-forming-gds.calc-method,chr(4)) >= 2 then do:
     p-calc-metod          = entry(1,buf_price-doc-forming-gds.calc-method,chr(4)) .
     p-calc-metod:tooltip in frame Dialog-Frame  = entry(2,buf_price-doc-forming-gds.calc-method,chr(4)) .
  end.
  else do:
   p-calc-metod:tooltip in frame Dialog-Frame  = "" .
  end.
  if p-pc-prev > 9999 then
    p-pc-prev = ?.
  if p-pc-avrg > 9999 then
    p-pc-avrg = ?.
  if p-op-avrg > 9999 then
    p-op-avrg = ?.
  if p-pc-pr-doc-old > 9999 then
    p-pc-pr-doc-old = ?.
  if p-op-pr-doc-old > 9999 then
    p-op-pr-doc-old = ?.
  if p-pc-last > 9999 then
    p-pc-last = ?.
  if p-op-last > 9999 then
    p-op-last = ?.
  if   p-pc-op-avrg > 9999 then
    p-pc-op-avrg = ?.
  if   p-pc-op-pr-doc-old > 9999 then
    p-pc-op-pr-doc-old = ?.
  if p-pc-op-last > 9999 then
    p-pc-op-last = ?.
  if v-prod-price-prc > 9999 then
     v-prod-price-prc = ?.
display
     p-new p-old  prev-price_doc-num
     p-last obj-in-code obj-in-date    p-pc-op-last p-calc-metod
     p-pc-prev   p-op-last p-pc-last
     p-avrg
     p-op-avrg
     p-pc-avrg
     p-pc-op-avrg
     p-pr-doc-old
     p-op-pr-doc-old
     p-pc-pr-doc-old
     p-pc-op-pr-doc-old
     with frame Dialog-Frame no-error .
  if par-is-pharm = "yes" then do:
      display
        v-ost
        v-prod-price
        v-new-price-vat
        v-prod-price-prc
        v-priceprodwithvat-2
        v-prod-price-prc-2
        v-prod-price-prc-3
        doc-code
      with frame Dialog-Frame no-error .
      enable doc-code with frame Dialog-Frame .
  end.
  else do :
    hide
        v-ost
        v-prod-price
        v-new-price-vat
        v-prod-price-prc
        v-priceprodwithvat-2
        v-prod-price-prc-2
        v-prod-price-prc-3
      in frame Dialog-Frame  .
    display
      v-free-qnty
      v-fact-qnty
      v-in-doc-qnty
    with frame Dialog-Frame no-error .
  end.
if p-mode = 'ПРОСМОТР':U then  disable doc-code with frame Dialog-Frame .
END PROCEDURE.
PROCEDURE ver-bar-code-prt :
define input  parameter p-b-code as integer   no-undo .
define output parameter p-is-prt as logical   no-undo .
define buffer main_bar-code for ub.bar-code  .
define buffer buf1_bar-code for ub.bar-code  .
define buffer buf1_goods    for ub.goods  .
define variable main-b-code as integer   no-undo .
find first buf1_bar-code no-lock where
           buf1_bar-code.b-code = p-b-code no-error .
find first buf1_goods no-lock where
           buf1_goods.gds-code = buf1_bar-code.gds-code no-error .
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  buf1_goods.gds-code
  ,input  ?
  ,output main-b-code
  )  .
 p-is-prt = false  .
 if main-b-code <> p-b-code and buf1_goods.unit-base = buf1_bar-code.unit-cli then p-is-prt = true .
END PROCEDURE.
PROCEDURE ver-pr-conf :
define buffer buf-bar-code  for ub.bar-code.
define buffer buf-goods     for ub.goods.
define buffer buf-gds-prt   for ub.gds-prt.
define buffer curr_price-doc-forming-gds for ub.price-doc-forming-gds  .
define buffer f_price-doc   for ub.price-doc  .
define variable v-ex1               as logical   no-undo .
define variable v-ex1-doc-num       as character no-undo .
define variable v-ex1-doc-status    as character no-undo .
define variable v-ex1-doc-obj-type  as character no-undo .
define variable v-ex1-doc-obj-code  as integer   no-undo .
define variable v-ret               as logical   no-undo .
define variable bc-main             as integer   no-undo .
define variable g#log               as logical   no-undo .
for each  x_obj-group :
for each tt-gds-list :
    find  buf-goods no-lock where
          buf-goods.gds-code = tt-gds-list.gds-code.
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run gdsbcode in g#library
  (input  tt-gds-list.gds-code
  ,input  ?
  ,output bc-main
  )  .
    run ver-modificator-price-is-null (
        input  tt-gds-list.artic ,
        input  tt-gds-list.prod-type ,
        input  tt-gds-list.prod-code ,
        input  v-cntxt-obj-type ,
        input  v-cntxt-obj-code ,
        output v-ret ).
        if v-ret = false then do:
            message
              "На модификатор : " skip
              "Артикул : " buf-goods.artic skip
                buf-goods.gds-name skip
              "не должно быть цены! "
              view-as alert-box information .
              delete tt-gds-list .
              next.
        end.
      if par-pr-dpl-q = "yes" then do:
          assign
            v-ex1 = false
            v-ex1-doc-num =    ""
            v-ex1-doc-status   = ""
            v-ex1-doc-obj-type = ""
            v-ex1-doc-obj-code = 0
          .
                for each  ub.price-list no-lock where
                          ub.price-list.b-code   = bc-main and
                          ub.price-list.obj-type = x_obj-group.obj-type and
                          ub.price-list.obj-code = x_obj-group.obj-code and
                          ub.price-list.price-type = "" and
                          ub.price-list.fact-order = 0 ,
                          first f_price-doc no-lock where
                                f_price-doc.doc-num = ub.price-list.doc-num and
                              ( f_price-doc.status_ = 'приказ':U or  f_price-doc.status_ = 'разрешен':U )
                          :
                          assign
                            v-ex1 = true
                            v-ex1-doc-num =     ub.price-list.doc-num
                            v-ex1-doc-status   = f_price-doc.status_
                            v-ex1-doc-obj-type = f_price-doc.obj-type
                            v-ex1-doc-obj-code = f_price-doc.obj-code
                            .
                          leave.
                end.
        if v-ex1 = true  then do:
          g#log = yes.
          message "Строка :" buf-goods.artic buf-goods.gds-name
                  "ЕСТЬ в ПЕРЕОЦЕНКЕ №" v-ex1-doc-num  "статус:" v-ex1-doc-status
                  "для" v-ex1-doc-obj-type v-ex1-doc-obj-code skip
                  "Продолжать?"
                  view-as alert-box question buttons ok-cancel update g#log.
          if not g#log then do:
            delete tt-gds-list .
            next.
          end.
        end.
      end.
    if par-pr-clt-q = "yes" then do:
    find first curr_price-doc-forming-gds no-lock where
              curr_price-doc-forming-gds.pdf-db     = buf_price-doc-forming.pdf-db     and
              curr_price-doc-forming-gds.pdf-id     = buf_price-doc-forming.pdf-id     and
              curr_price-doc-forming-gds.plt-db-num = buf_price-doc-forming.plt-db-num and
              curr_price-doc-forming-gds.plt-id     = buf_price-doc-forming.plt-id     and
              curr_price-doc-forming-gds.artic      = buf-goods.artic                  and
              curr_price-doc-forming-gds.prod-type  = buf-goods.prod-type              and
              curr_price-doc-forming-gds.prod-code  = buf-goods.prod-code  no-error .
      if available curr_price-doc-forming-gds then do:
          g#log = yes.
          message "Строка :" buf-goods.artic buf-goods.gds-name
                  "уже ЕСТЬ в заполняемом ДНЦ, цена =" curr_price-doc-forming-gds.price-sale-doc skip
                  "Продолжать?"
                  view-as alert-box question buttons ok-cancel update g#log.
          if not g#log then  do:
            delete tt-gds-list .
            next.
          end.
      end.
    end.
end.
end.
END PROCEDURE.
FUNCTION fnc-color RETURNS integer
  ( buffer b-goods for ub.goods , buffer b-bar-code for ub.bar-code ) :
define buffer b-gds-prt for ub.gds-prt.
find first b-gds-prt no-lock where b-gds-prt.node-code = b-bar-code.node-code no-error .
if available b-gds-prt then do:
   if b-gds-prt.upper-code = b-goods.prt-root then do:
      if b-goods.unit-base = b-bar-code.unit-cli then return ?.
                                                 else return dark_gray_color .
   end.
  else do:
    if b-goods.unit-base = b-bar-code.unit-cli then return dark_green_color .
                                               else return blue_color .
  end.
end.
END FUNCTION.
FUNCTION fnc-gds-name RETURNS CHARACTER
( input p-rec1 as recid , input p-rec2 as recid ) :
define buffer b-goods    for ub.goods  .
define buffer b-bar-code for ub.bar-code  .
define buffer b-gds-prt  for ub.gds-prt.
define buffer buf_parts  for ub.parts  .
define variable v-name as character no-undo .
find first b-goods    no-lock where recid(b-goods) = p-rec1 no-error .
     if error-status :error then return '' .
find first b-bar-code no-lock where recid(b-bar-code)  = p-rec2 no-error .
find first b-gds-prt no-lock where b-gds-prt.node-code = b-bar-code.node-code no-error .
find first buf_parts no-lock where
           buf_parts.part-code  = b-bar-code.part-code and
           buf_parts.in-code    = b-bar-code.in-code and
           buf_parts.out-code   = b-bar-code.in-code and
           buf_parts.artic      = b-goods.artic      and
           buf_parts.prod-type  = b-goods.prod-type      and
           buf_parts.prod-code  = b-goods.prod-code    no-error .
 v-name = if b-gds-prt.upper-code = b-goods.prt-root
         then
         if b-bar-code.in-code = ''
            then  b-goods.gds-name
            else  substitute("  &1  ПН &2 до &3" , b-bar-code.part-code, b-bar-code.in-code , if available buf_parts then  string(buf_parts.last-date , "99/99/9999") else "" )
      else        substitute("    &1" , b-gds-prt.f-name)
      .
      return v-name.
END FUNCTION.
