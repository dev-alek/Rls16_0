DEFINE BUFFER locked_cash-desk FOR cash-desk.
DEFINE TEMP-TABLE tt-cash-desk NO-UNDO LIKE cash-desk.
DEFINE BUFFER X_cash-desk FOR cash-desk.
define input        parameter parparentproc AS HANDLE no-undo.
define input        parameter p-mode as character  no-undo.
define input        parameter p-db-num like ub.cash-desk.db-num  no-undo.
define input        parameter p-obj-code like ub.cash-desk.obj-code  no-undo.
define input        parameter p-pos-type like ub.cash-desk.pos-type no-undo .
define input        parameter p-cash-num like ub.cash-desk.cash-num  no-undo.
define input-output parameter p-rid  as recid no-undo.
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Редактирование параметров кассы".
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
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
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
procedure wth-lib_cur-stock-place:
define input  parameter parobj-type like ub.clients.obj-type   no-undo.
define input  parameter parobj-code like ub.clients.obj-code   no-undo.
define input  parameter parw-p-code like ub.wth-pobj.w-p-code  no-undo.
define input  parameter parwth-code like ub.wth-pobj.wth-code  no-undo.
define output parameter parstock    like ub.wth-pobj.income-pl no-undo.
define buffer bf_wth-pobj for ub.wth-pobj.
find first bf_wth-pobj where bf_wth-pobj.obj-type = parobj-type and
                             bf_wth-pobj.obj-code = parobj-code and
                             bf_wth-pobj.w-p-code = parw-p-code and
                             bf_wth-pobj.wth-code = parwth-code no-lock no-error.
if available bf_wth-pobj then assign parstock = bf_wth-pobj.income-pl - bf_wth-pobj.incass-pl.
                         else assign parstock = 0.
end procedure.
procedure wth-lib_cur-stock-obj:
define input  parameter parobj-type like ub.clients.obj-type   no-undo.
define input  parameter parobj-code like ub.clients.obj-code   no-undo.
define input  parameter parwth-code like ub.wth-obj.wth-code   no-undo.
define output parameter parstock    like ub.wth-obj.income     no-undo.
define buffer bf_wth-obj for ub.wth-obj.
find first bf_wth-obj where bf_wth-obj.obj-type = parobj-type and
                            bf_wth-obj.obj-code = parobj-code and
                            bf_wth-obj.wth-code = parwth-code no-lock no-error.
if available bf_wth-obj then assign parstock = bf_wth-obj.income - bf_wth-obj.incass.
                        else assign parstock = 0.
end.
FUNCTION wth-lib_cur-stock-obj-func RETURNS DECIMAL (INPUT parobj-type AS CHARACTER,
                                                     INPUT parobj-code AS INTEGER,
                                                     INPUT parwth-code AS INTEGER):
define buffer bf_wth-obj for ub.wth-obj.
find first bf_wth-obj where bf_wth-obj.obj-type = parobj-type and
                            bf_wth-obj.obj-code = parobj-code and
                            bf_wth-obj.wth-code = parwth-code no-lock no-error.
if available bf_wth-obj then return (bf_wth-obj.income - bf_wth-obj.incass).
                        else return 0.00.
end function.
FUNCTION wth-lib_cur-stock-host-func RETURNS DECIMAL (INPUT parhost-code AS INTEGER,
                                                      INPUT parwth-code  AS INTEGER):
define buffer bf_wth-obj for ub.wth-obj.
define variable v-stock like ub.wth-obj.income no-undo.
for each bf_wth-obj no-lock where bf_wth-obj.host-code = parhost-code and
                                  bf_wth-obj.wth-code = parwth-code :
  v-stock = v-stock +  bf_wth-obj.income - bf_wth-obj.incass.
end.
return v-stock.
end function.
procedure wth-lib_full-inf-shift:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date and                        cur_wth-line.shift-num  = parshift-num  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-inter:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo.                        define input  parameter parshift-date1  like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num1   like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        ((cur_wth-line.shift-date = parshift-date1 and                           cur_wth-line.shift-num  <= parshift-num1)  or                            cur_wth-line.shift-date < parshift-date1 ) and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-period-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parw-p-code     like ub.wth-pobj.w-p-code  no-undo.                        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num    like ub.shift-obj.shift-num   no-undo.                        define input  parameter parshift-date1  like ub.shift-obj.shift-date  no-undo.                        define input  parameter parshift-num1   like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        ((cur_wth-line.shift-date = parshift-date1 and                           cur_wth-line.shift-num  <= parshift-num1)  or                            cur_wth-line.shift-date < parshift-date1 ) and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input parameter parw-p-code   like ub.wth-line.w-p-code     no-undo.                        define input parameter parshift-date like ub.shift-obj.shift-date  no-undo.                        define input parameter parshift-num  like ub.shift-obj.shift-num   no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code   = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date and                        cur_wth-line.shift-num  = parshift-num  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sdn-pl no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                (start_wth-line.shift-date = parshift-date and                           start_wth-line.shift-num  < parshift-num  or                            start_wth-line.shift-date < parshift-date ) and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sdn-pl no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-date:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parshift-date   like ub.shift-obj.shift-date  no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date   and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sd no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.shift-date < parshift-date and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sd no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-shift-date-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input parameter parw-p-code   like ub.wth-line.w-p-code     no-undo.                        define input parameter parshift-date like ub.shift-obj.shift-date  no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code   = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.shift-date = parshift-date   and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-sd-pl no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.shift-date < parshift-date and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-sd-pl no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-calend-date:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input  parameter parfact-date    like ub.wth-line.fact-date    no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                                                                                       cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.fact-date  = parfact-date  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-cld no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.fact-date  < parfact-date   and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-cld no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income - cur_wth-line.incass              parincome        = cur_wth-line.income                     parincome-cassa  = cur_wth-line.income-cassa               parincome-other  = cur_wth-line.income-other               parincass        = cur_wth-line.incass                     parincass-bank   = cur_wth-line.incass-bank                parincass-other  = cur_wth-line.incass-other.              parincass-cassa  = cur_wth-line.incass-cassa.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income     - start_wth-line.incass               parstock-end     = cur_wth-line.income       - cur_wth-line.incass                 parincome        = cur_wth-line.income       - start_wth-line.income               parincome-cassa  = cur_wth-line.income-cassa - start_wth-line.income-cassa         parincome-other  = cur_wth-line.income-other - start_wth-line.income-other         parincass        = cur_wth-line.incass       - start_wth-line.incass               parincass-bank   = cur_wth-line.incass-bank  - start_wth-line.incass-bank          parincass-other  = cur_wth-line.incass-other - start_wth-line.incass-other.        parincass-cassa  = cur_wth-line.incass-cassa - start_wth-line.incass-cassa.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income - start_wth-line.incass                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
procedure wth-lib_full-inf-calend-date-place:
define input  parameter parobj-type     like ub.clients.obj-type      no-undo.        define input  parameter parobj-code     like ub.clients.obj-code      no-undo.        define input  parameter parwth-code     like ub.wth-line.wth-code     no-undo.        define input parameter parw-p-code  like ub.wth-line.w-p-code  no-undo.                        define input parameter parfact-date like ub.wth-line.fact-date no-undo.                                                              define output parameter parstock-start  like ub.wth-line.income       no-undo.        define output parameter parstock-end    like ub.wth-line.income       no-undo.        define output parameter parincome       like ub.wth-line.income       no-undo.        define output parameter parincome-cassa like ub.wth-line.income-cassa no-undo.        define output parameter parincome-other like ub.wth-line.income-other no-undo.        define output parameter parincass       like ub.wth-line.incass       no-undo.        define output parameter parincass-bank  like ub.wth-line.incass-bank  no-undo.        define output parameter parincass-other like ub.wth-line.incass-other no-undo.        define output parameter parincass-cassa like ub.wth-line.incass-cassa no-undo.        define buffer cur_wth-line   for ub.wth-line.                                         define buffer start_wth-line for ub.wth-line.                                         find last cur_wth-line where cur_wth-line.obj-type   = parobj-type   and                                        cur_wth-line.obj-code   = parobj-code   and                                        cur_wth-line.w-p-code   = parw-p-code and                                                               cur_wth-line.wth-code   = parwth-code   and                                        cur_wth-line.fact-date  = parfact-date  and                                                                     cur_wth-line.status_    = 'факт':U       use-index                                  stat-cld-pl no-lock no-error.                     find last start_wth-line where start_wth-line.obj-type   = parobj-type         and                                start_wth-line.obj-code   = parobj-code         and                                start_wth-line.w-p-code = parw-p-code and                                                             start_wth-line.wth-code   = parwth-code         and                                start_wth-line.fact-date  < parfact-date   and                                                                   start_wth-line.status_ = 'факт':U                                                   use-index stat-cld-pl no-lock no-error.         if not available start_wth-line then do:                                              if not available cur_wth-line then do:                                                 assign                                                                                parstock-start   = 0                                                                  parstock-end     = 0                                                                  parincome        = 0                                                                  parincome-cassa  = 0                                                                  parincome-other  = 0                                                                  parincass        = 0                                                                  parincass-bank   = 0                                                                  parincass-other  = 0.                                                                 parincass-cassa  = 0.                                                              end.                                                                               else do:                                                                              assign parstock-start   = 0               parstock-end     = cur_wth-line.income-pl - cur_wth-line.incass-pl              parincome        = cur_wth-line.income-pl                     parincome-cassa  = cur_wth-line.income-cassa-pl               parincome-other  = cur_wth-line.income-other-pl               parincass        = cur_wth-line.incass-pl                     parincass-bank   = cur_wth-line.incass-bank-pl                parincass-other  = cur_wth-line.incass-other-pl.              parincass-cassa  = cur_wth-line.incass-cassa-pl.                                                                                       end.                                                                            end.                                                                               else do:                                                                              if available cur_wth-line then do:                                                    assign                                                                             parstock-start   = start_wth-line.income-pl     - start_wth-line.incass-pl               parstock-end     = cur_wth-line.income-pl       - cur_wth-line.incass-pl                 parincome        = cur_wth-line.income-pl       - start_wth-line.income-pl               parincome-cassa  = cur_wth-line.income-cassa-pl - start_wth-line.income-cassa-pl         parincome-other  = cur_wth-line.income-other-pl - start_wth-line.income-other-pl         parincass        = cur_wth-line.incass-pl       - start_wth-line.incass-pl               parincass-bank   = cur_wth-line.incass-bank-pl  - start_wth-line.incass-bank-pl          parincass-other  = cur_wth-line.incass-other-pl - start_wth-line.incass-other-pl.        parincass-cassa  = cur_wth-line.incass-cassa-pl - start_wth-line.incass-cassa-pl.     end.                                                                               else do:                                                                              assign                                                                             parstock-start   = start_wth-line.income-pl - start_wth-line.incass-pl                   parstock-end     = parstock-start                                                  parincome        = 0                                                               parincome-cassa  = 0                                                               parincome-other  = 0                                                               parincass        = 0                                                               parincass-bank   = 0                                                               parincass-other  = 0.                                                              parincass-cassa  = 0.                                                           end.                                                                            end.
end procedure.
FUNCTION get-curr RETURNS CHARACTER
  (buffer loc-wealth for ub.wealth ) :
define buffer buf_currency for ub.currency.
if loc-wealth.curr-code = ? or loc-wealth.is-money = no then
return loc-wealth.unit-base.
FIND FIRST buf_currency no-lock where
          buf_currency.curr-code = loc-wealth.curr-code No-ERROR.
if avail buf_currency then
  RETURN buf_currency.curr-abbr.
else return "".
END FUNCTION.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define new global shared variable g#attr-lib  as handle no-undo .
define variable v-attr-lib-variable as handle no-undo .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message (1)).
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
    undo, return error substitute( "&1. &2&3&4", vss-include-info1, return-value, chr(10), error-status :get-message (1)).
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cd-attr-code :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-type           as character no-undo .
  define output parameter p-format         as character no-undo .
  define output parameter p-label          as character no-undo .
  define output parameter p-user-can-edit  as logical   no-undo .
  define output parameter p-output-display as logical   no-undo .
  define output parameter p-other          as character no-undo .
  define output parameter p-prop-list      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-code in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-type
      ,output p-format
      ,output p-label
      ,output p-user-can-edit
      ,output p-output-display
      ,output p-other
      ,output p-prop-list
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-tooltip :
  define input  parameter p-ucode   as character no-undo .
  define input  parameter p-code    as character no-undo .
  define output parameter p-tooltip as character no-undo .
  define output parameter p-label   as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-tooltip in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-tooltip
      ,output p-label
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-value :
  define input  parameter p-db-num    like ub.cash-desk-attr.db-num        no-undo .
  define input  parameter p-obj-code  like ub.cash-desk-attr.obj-code      no-undo .
  define input  parameter p-pos-type  like ub.cash-desk-attr.pos-type      no-undo .
  define input  parameter p-cash-num  like ub.cash-desk-attr.cash-num      no-undo .
  define input  parameter p-ucode     like ub.cash-desk-attr.upper-attr-code      no-undo .
  define input  parameter p-code      like ub.cash-desk-attr.attr-code      no-undo .
  define output parameter p-character like ub.cash-desk-attr.attr-value-character    no-undo .
  define output parameter p-date      like ub.cash-desk-attr.attr-value-date         no-undo .
  define output parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal      no-undo .
  define output parameter p-integer   like ub.cash-desk-attr.attr-value-integer      no-undo .
  define output parameter p-logical   like ub.cash-desk-attr.attr-value-logical      no-undo .
  define output parameter p-type      as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-value in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-character
      ,output p-date
      ,output p-decimal
      ,output p-integer
      ,output p-logical
      ,output p-type
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-write :
  define input parameter p-db-num    like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code  like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type  like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num  like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code      like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-character like ub.cash-desk-attr.attr-value-character no-undo .
  define input parameter p-date      like ub.cash-desk-attr.attr-value-date      no-undo .
  define input parameter p-decimal   like ub.cash-desk-attr.attr-value-decimal   no-undo .
  define input parameter p-integer   like ub.cash-desk-attr.attr-value-integer   no-undo .
  define input parameter p-logical   like ub.cash-desk-attr.attr-value-logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-write in g#attr-lib
      (input p-db-num
      ,input p-obj-code
      ,input p-pos-type
      ,input p-cash-num
      ,input p-ucode
      ,input p-code
      ,input p-character
      ,input p-date
      ,input p-decimal
      ,input p-integer
      ,input p-logical
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-exist :
  define input  parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input  parameter p-ucode    like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input  parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-exist    as logical  no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-exist in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-exist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-delete :
  define input parameter  p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter  p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter  p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter  p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter  p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter  p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define output parameter p-deleted  as logical no-undo.
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-delete in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
      ,input  p-code
      ,output p-deleted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-news :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-news           as logical   no-undo .
  define output parameter p-from-gbd       as logical   no-undo .
  define output parameter p-from-ubd       as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-news in g#attr-lib
      (
       input  p-ucode
      ,input  p-code
      ,output p-news
      ,output p-from-gbd
      ,output p-from-ubd
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-hist :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-hist           as logical   no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-hist in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-hist
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-parse-date-time returns date
(input  p-string as character
,output p-time   as integer
):
  define variable v-return-value as date      no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-parse-date-time-proc in g#attr-lib
    (input  p-string
    ,output p-time
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run last-check-date-time in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr-cd-datetostring returns character
(input  p-date as date
):
  define variable v-return-value as character no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-cd-datetostring-proc in g#attr-lib
    (input  p-date
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr-last-report-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-report-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-params :
  define input parameter parparentproc as widget-handle no-undo .
  define input parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-params in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-last-check-date-time :
  define input parameter parparentproc as widget-handle no-undo .
  define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
  define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
  define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
  define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
  define input-output parameter p-character as character no-undo .
  define input-output parameter p-date      as date      no-undo .
  define input-output parameter p-decimal   as decimal   no-undo .
  define input-output parameter p-integer   as integer   no-undo .
  define input-output parameter p-logical   as logical   no-undo .
  define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-last-check-maria in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-character
      ,input-output p-date
      ,input-output p-decimal
      ,input-output p-integer
      ,input-output p-logical
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-periodic-tasks :
define input  parameter p-db-num like ub.cash-desk-attr.db-num no-undo .
define input  parameter p-obj-code like ub.cash-desk-attr.obj-code no-undo .
define input  parameter p-pos-type like ub.cash-desk-attr.pos-type no-undo .
define input  parameter p-cash-num like ub.cash-desk-attr.cash-num no-undo .
define input-output parameter p-value as character no-undo .
define output parameter p-setted as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-periodic-tasks in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input-output p-value
      ,output p-setted
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
function cd-attr_get-attr-int returns integer
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as integer   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-int-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-int-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
function cd-attr_get-attr-log returns logical
(buffer buf_cash-desk for ub.cash-desk
,input p-upper-attr-code as character
,input p-attr-code as character
,output p-mes as character
):
  define variable v-return-value as logical   no-undo .
    if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_get-attr-log-proc in g#attr-lib
    (buffer buf_cash-desk
    ,input  p-upper-attr-code
    ,input  p-attr-code
    ,output p-mes
    ,output v-return-value
    ) no-error .
  if error-status :error
  then do:
    assign
      p-mes = substitute("Неизвестная ошибка при вызове процедуры cd-attr_get-attr-log-proc &1 &2"
                        ,error-status :get-message(1)
                        ,return-value
                        )
    .
    return ? .
  end.
  return v-return-value .
end function.
procedure cd-attr_check-marketer :
  define input parameter p-db-num   like ub.cash-desk-attr.db-num     no-undo .
  define input parameter p-obj-code like ub.cash-desk-attr.obj-code   no-undo .
  define input parameter p-pos-type like ub.cash-desk-attr.pos-type   no-undo .
  define input parameter p-cash-num like ub.cash-desk-attr.cash-num   no-undo .
  define input parameter p-ucode     like ub.cash-desk-attr.upper-attr-code  no-undo .
  define input parameter p-code     like ub.cash-desk-attr.attr-code  no-undo .
  define input parameter p-value as character no-undo .
  define input parameter p-mode  as character no-undo .
  define output parameter p-correct     as logical no-undo .
  define output parameter p-error-code  as character no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr_check-marketer in g#attr-lib
      (input  p-db-num
      ,input  p-obj-code
      ,input  p-pos-type
      ,input  p-cash-num
      ,input  p-ucode
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
procedure cd-attr-manual-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-manual-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-batch-edit :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-section-num    as integer no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-batch-edit in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-section-num
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
procedure cd-attr-send-param :
  define input  parameter p-ucode          as character no-undo .
  define input  parameter p-code           as character no-undo .
  define output parameter p-send-param     as logical no-undo .
  do
  on error undo, return error return-value
  :
        if (valid-handle(g#attr-lib) <> true) then do:   run gbl/attr-lib.p persistent no-error .   if error-status :error or (valid-handle(g#attr-lib) <> true) then do:     message       "Error starting attr-lib.p" skip       g#attr-lib skip       g#attr-lib :type skip       g#attr-lib :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run cd-attr-send-param in g#attr-lib
      (input  p-ucode
      ,input  p-code
      ,output p-send-param
      ) no-error .
    if error-status :error
    then do:
      undo, return error return-value .
    end.
  end.
end procedure.
define variable v-db-num like ub.db.db-num no-undo.
define variable tcode as integer no-undo.
define variable dflt-cd as character no-undo init 'IBM':U.
define variable conf-attr as character no-undo.
define variable conf-par as character no-undo.
define variable par-type as character no-undo.
define variable v-host-code like ub.sysconf.host-code no-undo .
DEFINE VARIABLE v-fr-type-list-items-full AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-fr-type-list-items AS CHARACTER NO-UNDO.
define variable l-shift-on as logical no-undo .
define buffer buf_cash-desk for ub.cash-desk.
define variable mCashDevice      as ibs.th.str.cash.CashDevice no-undo.
DEFINE BUTTON B-attr
     LABEL "&Оп.данные"
     SIZE 10 BY 1.
DEFINE BUTTON B-attr-2
     LABEL "&Настройки"
     SIZE 10 BY 1 TOOLTIP "Параметры данной кассы".
DEFINE BUTTON B-cli-attr
     LABEL "&Пар-тры типа кассы"
     SIZE 20 BY 1.
DEFINE BUTTON B-exit AUTO-GO
     LABEL "&Ввод"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-Help
     LABEL "Помо&щь"
     SIZE 3 BY 1
     BGCOLOR 8 .
DEFINE BUTTON B-hist
     LABEL "Ис&тория"
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-GO
     LABEL "&Отмена"
     SIZE 10 BY 1
     BGCOLOR 8 .
DEFINE VARIABLE cb-device-kind AS INTEGER FORMAT ">9":U
     LABEL "Признак исполнения кассы"
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEM-PAIRS "Стандартное",0,
                     "ТСО Элекснет",1,
                     "ТСО Auto GC",2,
                     "Мобильное приложение",3
     DROP-DOWN-LIST
     SIZE 25 BY 1.
DEFINE VARIABLE CB-fr-type AS CHARACTER FORMAT "x(15)"
     LABEL "Тип ФР"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEM-PAIRS "Item 1","Item 1",
                     "Item 1","Item 1"
     DROP-DOWN-LIST
     SIZE 30 BY 1 TOOLTIP "Модель (класс, тип, марка) ККМ, Тип ФР".
DEFINE VARIABLE COMBO-protocol AS CHARACTER FORMAT "X(256)":U
     LABEL "Протокол"
     VIEW-AS COMBO-BOX INNER-LINES 5
     LIST-ITEMS "","ftp","http","samba","SMTP"
     DROP-DOWN-LIST
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE COMBO-protocol-maria AS CHARACTER FORMAT "X(256)":U
     LABEL "Протокол"
     VIEW-AS COMBO-BOX INNER-LINES 4
     LIST-ITEMS "","local","remote","ftp","shared"
     DROP-DOWN-LIST
     SIZE 10 BY 1 NO-UNDO.
DEFINE VARIABLE f-cash-num-char AS CHARACTER FORMAT "X(256)":U
     LABEL "Зав.#"
     VIEW-AS FILL-IN
     SIZE 27 BY 1 NO-UNDO.
DEFINE VARIABLE f-fr-type AS CHARACTER FORMAT "X(256)":U
     LABEL "Модель ККМ"
     VIEW-AS FILL-IN
     SIZE 30 BY 1 TOOLTIP "Модель (класс, тип, марка) ККМ, Тип ФР" NO-UNDO.
DEFINE VARIABLE f-obj-name AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 40.8 BY .95 NO-UNDO.
DEFINE VARIABLE f-pswd AS CHARACTER FORMAT "X(256)":U
     LABEL "Пароль"
     VIEW-AS FILL-IN
     SIZE 27 BY 1 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 1 GRAPHIC-EDGE  NO-FILL
     SIZE 77 BY 2.14.
DEFINE VARIABLE T-remote AS LOGICAL INITIAL no
     LABEL "Удаленная"
     VIEW-AS TOGGLE-BOX
     SIZE 29 BY 1 NO-UNDO.
DEFINE QUERY Dialog-Frame FOR
      tt-cash-desk,
      cash-desk SCROLLING.
DEFINE FRAME Dialog-Frame
     B-exit AT ROW 1 COL 1
     b-quit AT ROW 1 COL 11
     B-attr AT ROW 1 COL 31
     B-attr-2 AT ROW 1 COL 41 WIDGET-ID 6
     B-cli-attr AT ROW 1 COL 51
     B-hist AT ROW 1 COL 77
     B-Help AT ROW 1 COL 81
     tt-cash-desk.cash-num AT ROW 2.52 COL 11.4 COLON-ALIGNED
          LABEL "Номер"
          VIEW-AS FILL-IN
          SIZE 6 BY 1
     tt-cash-desk.db-num AT ROW 2.5 COL 32.63 COLON-ALIGNED
          LABEL "Номер БД"
          VIEW-AS FILL-IN
          SIZE 5.63 BY 1
     tt-cash-desk.obj-code AT ROW 3.75 COL 11.63 COLON-ALIGNED
          LABEL "Магазин"
          VIEW-AS FILL-IN
          SIZE 6.38 BY 1
          BGCOLOR 15 FGCOLOR 0
     f-obj-name AT ROW 3.75 COL 22.75 COLON-ALIGNED NO-LABEL
     f-cash-num-char AT ROW 5 COL 11.63 COLON-ALIGNED
     f-pswd AT ROW 5 COL 50 COLON-ALIGNED
     tt-cash-desk.addr-path AT ROW 7.5 COL 27 COLON-ALIGNED
          LABEL "Адрес/путь"
          VIEW-AS FILL-IN
          SIZE 25 BY 1
          BGCOLOR 15 FGCOLOR 0
     COMBO-protocol-maria AT ROW 7.5 COL 64 COLON-ALIGNED
     COMBO-protocol AT ROW 7.5 COL 64 COLON-ALIGNED
     cb-device-kind  AT ROW 6.29 COL 27 COLON-ALIGNED WIDGET-ID 14
     tt-cash-desk.cash-os AT ROW 6.29 COL 64 COLON-ALIGNED
          LABEL "Тип ОС"
          VIEW-AS COMBO-BOX INNER-LINES 4
          LIST-ITEMS "","DOS","LINUX","WINDOWS"
          DROP-DOWN-LIST
          SIZE 10 BY 1
          BGCOLOR 15 FGCOLOR 0
     tt-cash-desk.autonomy AT ROW 9.75 COL 13.63 NO-LABEL
          VIEW-AS RADIO-SET HORIZONTAL
          RADIO-BUTTONS
                    "Item 1", 1,
"Item 2", 2,
"Item 3", 3
          SIZE 66 BY 1
     tt-cash-desk.pos-type AT ROW 11.29 COL 60.2 COLON-ALIGNED
          LABEL "Тип POS"
          VIEW-AS COMBO-BOX INNER-LINES 11
          LIST-ITEM-PAIRS "1","1",
                     "2","2",
                     "3","3",
                     "4","4",
                     "5","5",
                     "6","6",
                     "7","7"
          DROP-DOWN-LIST
          SIZE 24 BY 1
          BGCOLOR 15 FGCOLOR 0
     CB-fr-type AT ROW 13.67 COL 11.2 COLON-ALIGNED WIDGET-ID 4
     tt-cash-desk.version AT ROW 13.67 COL 60.2 COLON-ALIGNED
          LABEL "Версия протокола"
          VIEW-AS FILL-IN
          SIZE 24 BY 1
     f-fr-type AT ROW 14.81 COL 49.6 COLON-ALIGNED WIDGET-ID 8
     T-remote AT ROW 14.95 COL 13
     tt-cash-desk.registration-code AT ROW 16.14 COL 11.8 COLON-ALIGNED
          LABEL "Регистр. №"
          VIEW-AS FILL-IN
          SIZE 30 BY 1
     tt-cash-desk.serial-code AT ROW 16.14 COL 51.6 COLON-ALIGNED
          LABEL "Сер. №"
          VIEW-AS FILL-IN
          SIZE 30 BY 1
     RECT-1 AT ROW 9.14 COL 3 WIDGET-ID 10
     SPACE(3.99) SKIP(7.76)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Касса"
         DEFAULT-BUTTON B-exit.
ASSIGN
       FRAME Dialog-Frame:SCROLLABLE       = FALSE
       FRAME Dialog-Frame:HIDDEN           = TRUE.
ASSIGN
       COMBO-protocol:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ASSIGN
       COMBO-protocol-maria:HIDDEN IN FRAME Dialog-Frame           = TRUE.
ON WINDOW-CLOSE OF FRAME Dialog-Frame
DO:
  APPLY "END-ERROR":U TO SELF.
END.
ON VALUE-CHANGED OF cb-device-kind IN FRAME Dialog-Frame
DO:
  if p-mode = 'ПРОСМОТР':U then return no-apply.
  ASSIGN
  cb-device-kind.
  tt-cash-desk.pos-type = if    cb-device-kind eq mCashDevice:Tanker:keyint
                             or cb-device-kind eq mCashDevice:TankerIntegr:keyint
                          then 'Autotank':U
                          else 'IBM-XML':U.
  DISPLAY
     tt-cash-desk.pos-type
  WITH FRAME Dialog-Frame.
END.
ON VALUE-CHANGED OF tt-cash-desk.autonomy IN FRAME Dialog-Frame
DO:
  if p-mode = 'ПРОСМОТР':U then return no-apply.
  ASSIGN
  tt-cash-desk.autonomy.
  CASE tt-cash-desk.autonomy:
      WHEN INTEGER('2':U) THEN DO:
          ASSIGN
          tt-cash-desk.cash-num = 0
          .
          DISPLAY
          tt-cash-desk.cash-num
          cb-device-kind
          WITH FRAME Dialog-Frame.
          DISABLE
          tt-cash-desk.cash-num
          WITH FRAME Dialog-Frame.
      END.
      OTHERWISE DO:
          ASSIGN
          tt-cash-desk.cash-num = tcode.
          DISPLAY
          tt-cash-desk.cash-num
          cb-device-kind
          WITH FRAME Dialog-Frame.
          ENABLE
          tt-cash-desk.cash-num when p-mode = 'ДОБАВЛЕНИЕ':U
          cb-device-kind
          WITH FRAME Dialog-Frame.
      END.
  END CASE.
END.
ON CHOOSE OF B-attr IN FRAME Dialog-Frame
DO:
define variable v-rid-list as character no-undo .
  v-rid-list = string(recid(locked_cash-desk)).
  if tt-cash-desk.pos-type = 'IBS-TH':U then do:
    if p-mode <> 'ПРОСМОТР':U then do:
      message
      "Для данного типа кассы режим ИЗМЕНЕНИЕ для оперативных данных недоступен" skip
      "предалагаем Оперативные данные в режиме ПРОСМОТР" skip
      view-as alert-box .
    end.
    run ref/cda-cc.w ( input parparentproc
                      ,input tt-cash-desk.db-num
                      ,input 'маг':U
                      ,input tt-cash-desk.obj-code
                      ,input tt-cash-desk.pos-type
                      ,input tt-cash-desk.cash-num
                      ,input ''
                      ,input-output v-rid-list) no-error.
  end.
  else do:
    run ref/cd-atti.w (   input parparentproc
                    ,input 'ПРОСМОТР':U
                    ,input "oper"
                    ,input tt-cash-desk.db-num
                    ,input tt-cash-desk.obj-code
                    ,input tt-cash-desk.pos-type
                    ,input tt-cash-desk.cash-num
                                        ,input no
                  ).
  end.
END.
ON CHOOSE OF B-attr-2 IN FRAME Dialog-Frame
DO:
define variable v-setted as logical no-undo .
  case tt-cash-desk.pos-type:
    when 'IBS-TH':U then do:
        run ref/cda-29.w ( input parparentproc
                          ,input 'ПРОСМОТР':U
                          ,input tt-cash-desk.db-num
                          ,input tt-cash-desk.obj-code
                          ,input tt-cash-desk.pos-type
                          ,input tt-cash-desk.cash-num
                          ,input ""
                          ,input ''
                          ,output v-setted) no-error.
    end.
    when 'IBS-TH-MOB':U then do:
        run ref/cda-31.w ( input parparentproc
                          ,input 'ПРОСМОТР':U
                          ,input tt-cash-desk.db-num
                          ,input tt-cash-desk.obj-code
                          ,input tt-cash-desk.pos-type
                          ,input tt-cash-desk.cash-num
                          ,input ""
                          ,input ''
                          ,output v-setted) no-error.
    end.
    otherwise do:
      run ref/cd-atti.w (   input parparentproc
                      ,input 'ПРОСМОТР':U
                      ,input "ref"
                      ,input tt-cash-desk.db-num
                      ,input tt-cash-desk.obj-code
                      ,input tt-cash-desk.pos-type
                      ,input tt-cash-desk.cash-num
                                          ,input no
                    ).
    end.
  end case.
END.
ON CHOOSE OF B-cli-attr IN FRAME Dialog-Frame
DO:
define variable attr-type as character no-undo .
define variable attr-format as character no-undo .
define variable attr-label as character no-undo .
define variable attr-user-can-edit as logical no-undo .
define variable attr-output-display as logical no-undo .
define variable attr-other as char no-undo .
define variable attr-value as char no-undo .
define variable attr-prop-list      as character no-undo .
define variable attr-prop-type-list as character no-undo .
define variable attr-prop-label-list as character no-undo .
define variable attr-global          as logical no-undo .
define variable attr-host           as logical no-undo .
define variable attr-shop           as logical no-undo .
define variable attr-store          as logical no-undo .
define variable attr-db             as logical no-undo .
define variable v-spr as character no-undo .
define variable ii as integer no-undo .
  run  thbjattr_code in this-procedure (
                                         input   "cd-type-":U + locked_cash-desk.pos-type
                                         ,input ''
                                         ,output attr-label
                                         ,output attr-user-can-edit
                                         ,output attr-output-display
                                         ,output attr-other
                                         ,output attr-prop-list
                                         ,output attr-prop-type-list
                                         ,output attr-prop-label-list
                                         ,output attr-global
                                         ,output attr-host
                                         ,output attr-shop
                                         ,output attr-store
                                         ,output attr-db ).
  do ii = 1 to num-entries(attr-other, chr(47)):
    if entry(ii, attr-other, chr(47)) begins "spr-ext=":U then do:
      assign
      v-spr = entry(2, entry(ii, attr-other, chr(47)), "=").
    end.
  end.
    run value(v-spr)(
                  input parparentproc
                ,'ПРОСМОТР':U
                ,'маг':U
                ,locked_cash-desk.obj-code
                ).
END.
ON CHOOSE OF B-exit IN FRAME Dialog-Frame
DO:
  assign
    frame Dialog-Frame
    tt-cash-desk.pos-type
  .
  if tt-cash-desk.pos-type = 'r-keeper':U then do :
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run conf-rd in g#library
  (input  'is-rkeep':U
  ,input  '':U
  ,input  '':U
  ,input  0
  ,input  '':U
  ,input  '':U
  ,input  '':U
  ,input  no
  ,output conf-par
  ,output par-type
  ) no-error .
    if error-status :error
    or conf-par <> 'yes'
    then do:
      message
        "В системе запрещена работа с кассами R-Keeper либо отсутсвует конфигурационный параметр is-rkeep" skip
        "Обратитесь к администратору" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      return no-apply.
    end.
  end.
  run proc-save in this-procedure no-error.
  if error-status:error then return no-apply.
END.
ON CHOOSE OF B-hist IN FRAME Dialog-Frame
DO:
define variable rid-list as character no-undo.
      run ref/ccshlist.w (
                         INPUT parparentproc
                       , INPUT "":U
                       , INPUT "one":U
                       , OUTPUT  rid-list
                       , INPUT tt-cash-desk.db-num
                       , INPUT 'маг':U
                       , INPUT tt-cash-desk.obj-code
                       , input tt-cash-desk.pos-type
                       , input tt-cash-desk.cash-num
                       , input "":U
                        ).
END.
ON LEAVE OF tt-cash-desk.cash-num IN FRAME Dialog-Frame
DO:
  assign tt-cash-desk.cash-num .
  assign tcode = tt-cash-desk.cash-num .
END.
ON LEAVE OF tt-cash-desk.obj-code IN FRAME Dialog-Frame
DO:
   define buffer buf_shop for ub.shop.
  define buffer buf_clients for ub.clients.
  find first buf_shop no-lock where
                buf_shop.obj-code = input frame Dialog-Frame tt-cash-desk.obj-code no-error.
  if available buf_shop then do:
    find first buf_clients no-lock where
                buf_clients.obj-type = 'маг':U
           AND buf_clients.obj-code = buf_shop.obj-code .
    assign
    tt-cash-desk.obj-code
    f-obj-name = buf_clients.obj-name.
    display
   tt-cash-desk.obj-code
   f-obj-name
    with frame Dialog-Frame.
  end.
  else do:
      assign
        tt-cash-desk.obj-code = 0
        f-obj-name = "":U.
      return no-apply.
  end.
END.
ON VALUE-CHANGED OF tt-cash-desk.pos-type IN FRAME Dialog-Frame
DO:
  if p-mode = 'ПРОСМОТР':U then return no-apply.
  assign
  tt-cash-desk.pos-type.
  if lookup(tt-cash-desk.pos-type,
            ('IBM':U + chr(44) +
             'IBM-XML':U + chr(44) +
             'MARIA':U)) = 0 then do:
      disable
      t-remote
      with frame Dialog-Frame.
  end.
  else do:
      enable
      t-remote when (p-mode <> 'ПРОСМОТР':U and not l-shift-on)
      with frame Dialog-Frame.
  end.
  if lookup(tt-cash-desk.pos-type
            , ('IBM-XML':U + chr(44) +
               'Autotank':U)) > 0
      then do:
      if p-mode <> 'ПРОСМОТР':U then do:
        view
        combo-protocol
        in frame Dialog-Frame.
      end.
      enable
      combo-protocol when (p-mode <> 'ПРОСМОТР':U and not l-shift-on)
      with frame Dialog-Frame.
  end.
  else do:
      disable
      combo-protocol
      with frame Dialog-Frame.
      HIDE
      combo-protocol
      in frame Dialog-Frame.
  end.
  if lookup('MARIA':U, tt-cash-desk.pos-type) > 0
      then do:
      if p-mode <> 'ПРОСМОТР':U then do:
        view
        combo-protocol-maria
        in frame Dialog-Frame.
      end.
      enable
      combo-protocol-maria when (p-mode <> 'ПРОСМОТР':U and not l-shift-on)
      with frame Dialog-Frame.
  end.
  else do:
      disable
      combo-protocol-maria
      with frame Dialog-Frame.
      HIDE
      combo-protocol-maria
      in frame Dialog-Frame.
  end.
  if lookup('MARIA':U, tt-cash-desk.pos-type) > 0
      then do:
      enable
      f-cash-num-char when (p-mode <> 'ПРОСМОТР':U and not l-shift-on)
      with frame Dialog-Frame.
  end.
  else do:
      disable
      f-cash-num-char
      with frame Dialog-Frame.
      HIDE
      f-cash-num-char
      in frame Dialog-Frame.
  end.
  if lookup('MARIA':U, tt-cash-desk.pos-type) > 0
      then do:
      enable
      f-pswd when (p-mode <> 'ПРОСМОТР':U and not l-shift-on)
      with frame Dialog-Frame.
  end.
  else do:
      disable
      f-pswd
      with frame Dialog-Frame.
      HIDE
      f-pswd
      in frame Dialog-Frame.
  end.
  if lookup(tt-cash-desk.pos-type,
           ('IBM-XML':U + chr(44) +
            'NCR-GM':U + chr(44) +
            'MAGIA-XML':U + chr(44) +
            'NCR-AS@R':U + chr(44) +
            'Autotank':U
            )) > 0 then do:
      enable
      tt-cash-desk.autonomy when (p-mode <> 'ПРОСМОТР':U and not l-shift-on)
      with frame Dialog-Frame.
  end.
  else do:
      ASSIGN
      tt-cash-desk.autonomy = 0.
      DISPLAY
      tt-cash-desk.autonomy
      with frame Dialog-Frame.
      disable
      tt-cash-desk.autonomy
      with frame Dialog-Frame.
  end.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME Dialog-Frame:PARENT eq ?
THEN FRAME Dialog-Frame:PARENT = ACTIVE-WINDOW.
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
 if num-entries(p-mode, chr(4)) > 1 then do:
   assign
   l-shift-on = logical(entry(2, p-mode, chr(4)))
   p-mode = entry(1, p-mode, chr(4))
   .
 end.
 if p-mode  <> 'ДОБАВЛЕНИЕ':U
 and p-mode <> 'ИЗМЕНЕНИЕ':U
 and p-mode <> 'ПРОСМОТР':U
 then do:
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error.
 end.
 v-db-num = ibs.th.gbl.gbl-var:g#db-num .
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run hostcode in g#library
  (input  'маг':U
  ,input  p-obj-code
  ,output v-host-code
  )  .
  empty temp-table tt-cash-desk .
  case p-mode :
    when 'ИЗМЕНЕНИЕ':U then do:
      find first locked_cash-desk EXclusive-lock
           where recid(locked_cash-desk) = p-rid no-wait no-error.
      if locked locked_cash-desk then do:
        message
        vss-workfile vss-revision vss-description skip
         "Запись КАССЫ занята"
        view-as alert-box error .
        undo, return error.
      end.
      if not available locked_cash-desk then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись КАССА"
      view-as alert-box error .
      undo, return error.
      end.
      if locked_cash-desk.db-num <> v-db-num then do:
            message
            vss-workfile vss-revision vss-description skip
            "Нельзя изменять кассу чужой БД"
            view-as alert-box error .
            undo, return error.
      end.
      IF LOCKED_cash-desk.is-del THEN DO:
        message
        vss-workfile vss-revision vss-description skip
        "Нельзя изменять кассу? которая логически удалена"
        view-as alert-box error .
        undo, return error.
      END.
      create tt-cash-desk.
      buffer-copy locked_cash-desk to tt-cash-desk .
      tcode = tt-cash-desk.cash-num .
    end.
    when 'ПРОСМОТР':U then do :
      find first locked_cash-desk no-lock
           where recid(locked_cash-desk) = p-rid no-error .
      if not available locked_cash-desk then do:
        find first locked_cash-desk no-lock
             where locked_cash-desk.db-num   = p-db-num
               AND Locked_Cash-desk.obj-code = p-obj-code
               AND locked_cash-desk.cash-num = p-cash-num
               AND locked_cash-desk.pos-type = p-pos-type    no-error.
        if not available locked_cash-desk then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись КАССА"
      view-as alert-box error .
      undo, return error.
        end.
      end.
      create tt-cash-desk.
      buffer-copy locked_cash-desk to tt-cash-desk .
      tcode = tt-cash-desk.cash-num .
    end .
    when 'ДОБАВЛЕНИЕ':U then do:
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-param-type7 as character no-undo .
define variable v-value-date7 as date no-undo .
define variable v-value-decimal7 as decimal no-undo .
define variable v-value-integer7 as INTEGER no-undo .
define variable v-value-logical7 AS LOGICAL no-undo .
define variable v-tth7 as handle no-undo .
run adm/shattri.p (
    input "get":U
    ,input  'маг':U
    ,input  p-obj-code
    ,input  'cd-sending':U
    ,input  'dflt-cd':U
    ,output dflt-cd
    ,output v-value-date7
    ,output v-value-decimal7
    ,output v-value-integer7
    ,output v-value-logical7
    ,output v-param-type7
    ,INPUT-OUTPUT table-handle v-tth7
    )  .
delete object v-tth7 no-error.
      for each buf_cash-desk NO-LOCK
         where buf_cash-desk.db-num = v-db-num
             BY buf_cash-desk.cash-num :
        tcode = buf_cash-desk.cash-num.
      end.
      tcode = tcode + 1.
      create tt-cash-desk.
      assign
    tt-cash-desk.db-num    = v-db-num
    tt-cash-desk.obj-code  = p-obj-code
    tt-cash-desk.cash-num  = tcode
    tt-cash-desk.pos-type  = dflt-cd
    tt-cash-desk.addr-path = (if dflt-cd = 'IBM':U or dflt-cd = 'OMRON':U then "192.1.1.1":U else "":U)
    tt-cash-desk.cash-os   = "OS/2"
    tt-cash-desk.cash-on   = no
      .
    end.
    otherwise do :
    message
    vss-workfile vss-revision vss-description skip
    "Неверное значение параметров вызова p-mode"  p-mode
    view-as alert-box ERROR.
    undo, return error .
    end .
  end case .
  RUN MyENable in this-procedure .
  WAIT-FOR GO OF FRAME Dialog-Frame.
END.
delete object mCashDevice.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE enable_UI :
  OPEN QUERY Dialog-Frame FOR EACH tt-cash-desk SHARE-LOCK,       EACH cash-desk WHERE TRUE  SHARE-LOCK.
  GET FIRST Dialog-Frame.
  DISPLAY f-obj-name f-cash-num-char f-pswd COMBO-protocol-maria COMBO-protocol
          cb-device-kind CB-fr-type f-fr-type T-remote
      WITH FRAME Dialog-Frame.
  IF AVAILABLE tt-cash-desk THEN
    DISPLAY tt-cash-desk.cash-num tt-cash-desk.db-num tt-cash-desk.obj-code
          tt-cash-desk.addr-path tt-cash-desk.pos-type tt-cash-desk.cash-os
          tt-cash-desk.autonomy tt-cash-desk.version
          tt-cash-desk.registration-code tt-cash-desk.serial-code
      WITH FRAME Dialog-Frame.
  ENABLE B-exit RECT-1 b-quit B-attr B-attr-2 B-cli-attr B-hist B-Help
         tt-cash-desk.obj-code f-obj-name tt-cash-desk.addr-path
         COMBO-protocol-maria COMBO-protocol tt-cash-desk.pos-type
         tt-cash-desk.cash-os tt-cash-desk.autonomy cb-device-kind CB-fr-type
         tt-cash-desk.version f-fr-type T-remote tt-cash-desk.registration-code
         tt-cash-desk.serial-code
      WITH FRAME Dialog-Frame.
  VIEW FRAME Dialog-Frame.
END PROCEDURE.
PROCEDURE MyEnable :
DEFINE VARIABLE v-list-items AS CHARACTER NO-UNDO.
DEFINE VARIABLE v-ii         AS INTEGER   NO-UNDO.
 define variable objType    as ibs.th.gbl.propmap no-undo.
   mCashDevice      = new ibs.th.str.cash.CashDevice().
   do v-ii = 1 to mCashDevice:mapType:GetItem(v-ii):
      objType = mCashDevice:CurrProp.
      v-list-items = v-list-items + chr(44) + objType:Label_ + chr(44) + string(objType:KeyIntDB) .
   end.
   cb-device-kind:LIST-ITEM-PAIRS  in frame Dialog-Frame = trim(v-list-items,chr(44)) .
v-list-items = "".
DO v-ii = 1 TO NUM-ENTRIES('IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA':U):
    ASSIGN
    v-list-items = v-list-items + (IF v-ii > 1 THEN  chr(44) ELSE "":U) +
                   ENTRY(v-ii, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,R-KEEPER,InfoKiosk,Прайс-чекер Servis+,Emulator-NKT-IBM,MARIA':U) + chr(44) +
                   ENTRY(v-ii, 'IBM-XML,Autotank,IBM,IPC-Servis+,OMRON-NEW,OMRON,NCR-GM,MAGIA-XML,NCR-AS@R,IBS-TH,IBS-TH-MOB,r-keeper,InfoKiosk,pricecheck-Servis+,Emulator-NKT-IBM,MARIA':U).
END.
tt-cash-desk.pos-type:list-item-pairs in frame Dialog-Frame = v-list-items .
define variable v-fr-type-list-item-pairs as character no-undo .
DO v-ii = 1 TO NUM-ENTRIES('shtrih-fr-k-01,prim08tk':U):
    ASSIGN
    v-fr-type-list-item-pairs = v-fr-type-list-item-pairs + (IF v-ii > 1 THEN  chr(44) ELSE "":U) +
                                      ENTRY(v-ii, 'Штрих-ФР-К 01,ПРИМ08ТК':U) +
                                      chr(44) +
                                      ENTRY(v-ii, 'shtrih-fr-k-01,prim08tk':U)
    v-fr-type-list-items-full = v-fr-type-list-items-full + (IF v-ii > 1 THEN  chr(44) ELSE "":U) +
                                      ENTRY(v-ii, 'Штрих-ФР-К 01,ПРИМ08ТК':U)
    v-fr-type-list-items = v-fr-type-list-items + (IF v-ii > 1 THEN  chr(44) ELSE "":U) +
                                      ENTRY(v-ii, 'shtrih-fr-k-01,prim08tk':U)
    .
END.
assign
cb-fr-type:LIST-ITEM-pairs IN FRAME Dialog-Frame = trim(v-fr-type-list-item-pairs, chr(44))
cb-fr-type = tt-cash-desk.fr-type
f-fr-type = tt-cash-desk.fr-type
f-fr-type:column = cb-fr-type:column
f-fr-type:row = cb-fr-type:row
f-fr-type:side-label-handle:row = f-fr-type:row
f-fr-type:side-label-handle:column = f-fr-type:column
.
  cb-device-kind = tt-cash-desk.device-kind .
assign
t-remote = (tt-cash-desk.remote = 1)
tt-cash-desk.autonomy:radio-buttons = "&Автономная касса"  + chr(44) + '0':U +  chr(44) +
                                      "&Подчиненная касса" + chr(44) + '1':U + chr(44) +
                                      "&Касс.менеджер"     + chr(44) + '2':U
.
DISPLAY
f-obj-name
cb-device-kind
T-remote
WITH FRAME Dialog-Frame .
IF AVAILABLE tt-cash-desk THEN DO:
 combo-protocol:SCREEN-VALUE = (IF num-entries(tt-cash-desk.addr-path, chr(4)) > 1
                                and (tt-cash-desk.pos-type = 'IBM-XML':U
                                     or tt-cash-desk.pos-type = 'Autotank':U)
                                THEN ENTRY(1, tt-cash-desk.addr-path, chr(4))
                                ELSE chr(32)) .
 combo-protocol-maria:SCREEN-VALUE = (IF num-entries(tt-cash-desk.addr-path, chr(4)) > 1
                                      and tt-cash-desk.pos-type = 'MARIA':U
                                      THEN ENTRY(1, tt-cash-desk.addr-path, chr(4))
                                      ELSE chr(32)) .
DISPLAY
f-fr-type
tt-cash-desk.cash-num
tt-cash-desk.db-num
tt-cash-desk.obj-code
(IF num-entries(tt-cash-desk.addr-path, chr(4)) > 1
THEN ENTRY(2, tt-cash-desk.addr-path, chr(4))
ELSE tt-cash-desk.addr-path) @ tt-cash-desk.addr-path
tt-cash-desk.pos-type
tt-cash-desk.cash-os
tt-cash-desk.version
tt-cash-desk.autonomy
tt-cash-desk.registration-code
tt-cash-desk.serial-code
WITH FRAME Dialog-Frame .
IF NUM-ENTRIES(tt-cash-desk.addr-path, chr(4)) > 2
AND tt-cash-desk.pos-type = 'MARIA':U
    THEN DO:
    DISPLAY
    ENTRY(3, tt-cash-desk.addr-path, chr(4)) @ f-cash-num-char
    WITH FRAME Dialog-Frame.
END.
IF NUM-ENTRIES(tt-cash-desk.addr-path, chr(4)) > 3
AND tt-cash-desk.pos-type = 'MARIA':U
    THEN DO:
    DISPLAY
    ENTRY(4, tt-cash-desk.addr-path, chr(4)) @ f-pswd
    WITH FRAME Dialog-Frame.
END.
END.
ENABLE
b-quit
B-exit
b-attr when (p-mode <> 'ДОБАВЛЕНИЕ':U and not l-shift-on)
b-attr-2 when (p-mode <> 'ДОБАВЛЕНИЕ':U and not l-shift-on)
b-cli-attr when (p-mode <> 'ДОБАВЛЕНИЕ':U and not l-shift-on)
b-hist when p-mode <> 'ДОБАВЛЕНИЕ':U
B-Help
tt-cash-desk.cash-num when (p-mode = 'ДОБАВЛЕНИЕ':U and not l-shift-on)
tt-cash-desk.obj-code  when (p-mode = 'ДОБАВЛЕНИЕ':U and not l-shift-on)
tt-cash-desk.addr-path when (p-mode <> 'ПРОСМОТР':U)
tt-cash-desk.pos-type  when (p-mode = 'ДОБАВЛЕНИЕ':U and not l-shift-on)
tt-cash-desk.cash-os when (p-mode <> 'ПРОСМОТР':U and not l-shift-on)
tt-cash-desk.version when p-mode <> 'ПРОСМОТР':U
tt-cash-desk.registration-code when p-mode <> 'ПРОСМОТР':U
tt-cash-desk.serial-code when p-mode <> 'ПРОСМОТР':U
T-remote when (p-mode <> 'ПРОСМОТР':U and not l-shift-on)
tt-cash-desk.autonomy when (p-mode <> 'ПРОСМОТР':U and not l-shift-on)
cb-device-kind when (p-mode <> 'ПРОСМОТР':U)
WITH FRAME Dialog-Frame.
if p-mode = 'ПРОСМОТР':U then do:
    assign
    b-quit:label = "&Выход"
    .
    hide
    b-exit
    in frame Dialog-Frame.
end.
APPLY "VALUE-CHANGED" to tt-cash-desk.pos-type.
enable tt-cash-desk.pos-type WITH FRAME Dialog-Frame.
APPLY "VALUE-CHANGED" to tt-cash-desk.autonomy.
VIEW FRAME Dialog-Frame .
END PROCEDURE.
PROCEDURE proc-save :
IF COMBO-protocol:visible in FRAME Dialog-Frame THEN
ASSIGN
COMBO-protocol
.
ELSE
combo-protocol = "":U.
IF COMBO-protocol-maria:visible in FRAME Dialog-Frame THEN
ASSIGN
COMBO-protocol-maria
.
ELSE
combo-protocol-maria = "":U.
IF f-cash-num-char:visible in FRAME Dialog-Frame THEN
ASSIGN
f-cash-num-char
.
ELSE
f-cash-num-char = "":U.
IF f-pswd:visible in FRAME Dialog-Frame THEN
ASSIGN
f-pswd
.
ELSE
f-pswd = "":U.
IF cb-FR-TYPE:SENSITIVE in FRAME Dialog-Frame THEN do:
  ASSIGN
  cb-FR-TYPE
  tt-cash-desk.fr-type = cb-FR-TYPE
  .
end.
ELSE do:
  cb-FR-TYPE = "":U.
end.
IF f-FR-TYPE:SENSITIVE in FRAME Dialog-Frame THEN do:
  ASSIGN
  f-FR-TYPE
  tt-cash-desk.fr-type = f-FR-TYPE
  .
end.
ELSE do:
  f-FR-TYPE = "":U.
end.
if cb-device-kind:sensitive in frame Dialog-Frame
  then assign cb-device-kind .
  else cb-device-kind = 0 .
assign
frame Dialog-Frame tt-cash-desk.addr-path
tt-cash-desk.addr-path = (IF combo-protocol <> "":U
                          THEN (combo-protocol + chr(4))
                          ELSE '':U) +
                          tt-cash-desk.addr-path
tt-cash-desk.addr-path =   (IF combo-protocol-maria <> "":U
                          THEN (combo-protocol-maria + chr(4))
                          ELSE '':U) +
                          tt-cash-desk.addr-path
tt-cash-desk.addr-path = tt-cash-desk.addr-path +
                        (IF f-cash-num-char <> "":U
                        THEN (chr(4) + f-cash-num-char )
                        ELSE '':U)
tt-cash-desk.addr-path = tt-cash-desk.addr-path +
                        (IF f-pswd <> "":U
                        THEN (chr(4) + f-pswd )
                        ELSE '':U)
tt-cash-desk.cash-num
tt-cash-desk.cash-os
tt-cash-desk.obj-code
tt-cash-desk.pos-type
tt-cash-desk.version
T-remote
tt-cash-desk.remote = (if T-remote and T-remote:sensitive then 1 else 0)
tt-cash-desk.autonomy
tt-cash-desk.serial-code
tt-cash-desk.registration-code
.
run ref/cashdsk1.p (
 input-output p-rid
,input p-mode
,input tt-cash-desk.db-num
,input tt-cash-desk.obj-code
,input tt-cash-desk.pos-type
,input tt-cash-desk.cash-num
,input tt-cash-desk.autonomy
,input tt-cash-desk.addr-path
,input tt-cash-desk.cash-on
,input tt-cash-desk.cash-os
,input tt-cash-desk.is-del
,input tt-cash-desk.remote
,input tt-cash-desk.version
,input tt-cash-desk.registration-code
,input tt-cash-desk.serial-code
,input tt-cash-desk.fr-type
,input cb-device-kind
) no-error .
if error-status:error then do:
  if num-entries(return-value, " ") > 1 then message
    substitute("&1&2&3", error-status:get-message(1) , chr(10), return-value)
  view-as alert-box error .
  else if return-value > "" then do:
  end .
  undo, return error.
end.
END PROCEDURE.
