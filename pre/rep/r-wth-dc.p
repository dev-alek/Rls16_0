block-level on error undo, throw.
define input parameter parparentproc as widget-handle no-undo .
define input parameter p-tog-object  as logical       no-undo .
define input parameter p-tog-total   as logical       no-undo .
define variable vss-revision    as character no-undo initial "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo initial "$Author: expertek $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-wth-dc.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-wth-dc.p $":U .
define variable vss-description as character no-undo initial "Отчет о движении материальных ценностей":U .
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
define  shared variable gdsgrp_recids      as character no-undo.
define  shared variable fin-schet-recid    as character no-undo.
define  shared variable v-d-report-handle  as handle    no-undo .
define  shared temp-table g#customer no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define  shared temp-table g#cli no-undo
    field obj-type like ub.clients.obj-type
    field obj-code like ub.clients.obj-code
    field obj-name like ub.clients.obj-name
    index pi is unique primary obj-type obj-code.
define  shared temp-table tmp#grp no-undo
    field node-code like ub.gds-grp.node-code
    field grp-name like ub.gds-grp.node-name
    field lvl-num  like ub.gds-grp.lvl-num
    field is-term  like ub.gds-grp.is-term
    index pi is unique primary grp-name node-code
    index i-node-code    node-code
    index level-num   lvl-num  grp-name
    index is-term is-term  grp-name
    .
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared temp-table gds-list no-undo like ub.goods
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
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   shared  temp-table gds-list-hist no-undo
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
define variable vss-include-info4 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
def
 shared
temp-table  obj-list no-undo
  field obj-type like ub.clients.obj-type
  field obj-code like ub.clients.obj-code
  field obj-name like ub.clients.obj-name
  field obj-id   as integer
  field db-num   as integer
  index pi is primary unique obj-id
  index ie1 obj-type obj-code
  index ie2 obj-name
.
procedure create_obj-list :
   define input parameter p-obj-type like ub.clients.obj-type no-undo .
   define input parameter p-obj-code like ub.clients.obj-code no-undo .
   do
   on error undo, return error return-value
   :
      define buffer cli-obj for ub.clients .
      define variable p-var as integer no-undo .
      define buffer buf_obj-list for obj-list .
      find last buf_obj-list  use-index pi no-error .
      if available buf_obj-list
      then
         p-var = buf_obj-list.obj-id + 1.
      else
         p-var = 1.
      find first cli-obj where
                cli-obj.obj-type = p-obj-type
            and cli-obj.obj-code = p-obj-code
      no-lock no-error.
      if available cli-obj
      then do:
         create buf_obj-list.
         assign
            buf_obj-list.obj-id   = p-var
            buf_obj-list.obj-code = cli-obj.obj-code
            buf_obj-list.obj-type = cli-obj.obj-type
            buf_obj-list.obj-name = cli-obj.obj-name
            buf_obj-list.db-num   = cli-obj.db-num
         .
      end.
   end.
end.
define  shared temp-table X-init_obj-list no-undo
field obj-type like ub.clients.obj-type
field obj-code like ub.clients.obj-code
index pi is unique primary obj-type obj-code.
define variable p1 like ub.gds-obj.prod-type no-undo.
define variable p2 like ub.gds-obj.prod-code no-undo.
define variable p3 like ub.gds-obj.artic     no-undo.
define variable vss-include-info5 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info6 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable to-day       as date no-undo .
define   shared variable str1   as character  no-undo.
define   shared variable str2   as character  no-undo.
define   shared variable str3   as character  no-undo.
define   shared variable str4   as character  no-undo.
define   shared variable ReportNAme   as character  no-undo.
define   shared variable ReportProc   as character  no-undo.
define   shared variable ReportHeader as character  no-undo.
define   shared variable ReportPageWidth  as integer no-undo.
define   shared variable ReportPageHeight as integer no-undo.
define   shared variable ReportFontNum    as integer no-undo.
define   shared variable my-request as logical  init false no-undo.
define   shared variable v-delim as character no-undo .
define   shared variable v-sdate as character no-undo initial "/":U.
define   shared variable v-shortdate as character no-undo initial "dd/mm/yyyy":U .
define   shared variable my-handle  as handle no-undo .
define   shared variable parent-handle  as handle no-undo .
define   shared variable v-show-all-goods as logical  no-undo .
define   shared variable params-only      as logical   no-undo .
define   shared variable params-only-mode as character no-undo .
define   shared variable place-call       as character no-undo .
define   shared variable x-Goods-Editor   as character  no-undo .
define   shared variable x-Date-Alone     as date format "99/99/9999":u   no-undo .
define   shared variable x-Date-End       as date format "99/99/9999":u   no-undo .
define   shared variable x-Date-Start     as date format "99/99/9999":u   no-undo .
define   shared variable x-Shift-Alone    as integer format ">9":u         no-undo .
define   shared variable x-Shift-End      as integer format ">9":u         no-undo .
define   shared variable x-Shift-Start    as integer format ">9":u         no-undo .
define   shared variable x-SelectGood     as integer                      no-undo .
define   shared variable x-SelectObject   as character                          no-undo .
define   shared variable x-SET_PAY_TYPE   as integer  no-undo .
define   shared variable x-SET_val_TYPE   as integer  no-undo .
define   shared variable x-TOG-Shift      as logical  no-undo .
define   shared variable x-Radio-Task     as integer  no-undo .
define   shared variable x-TOG-Excel      as logical  no-undo .
define   shared variable x-TOG-list-hist  as logical  no-undo .
define   shared variable x-text-1 as character  no-undo .
define   shared variable x-text-2 as character  no-undo .
define   shared variable x-text-3 as character  no-undo .
define   shared variable x-text-4 as character  no-undo .
define   shared variable init-date-start  like x-date-start  no-undo .
define   shared variable init-date-end    like x-date-end    no-undo .
define   shared variable init-date-alone  like x-date-alone  no-undo .
define   shared variable init-shift-alone like x-shift-alone no-undo .
define   shared variable init-shift-start like x-shift-start no-undo .
define   shared variable init-shift-end   like x-shift-end   no-undo .
define   shared variable init-set_pay_type like x-set_pay_type   no-undo .
define   shared variable init-set_val_type like x-set_val_type   no-undo .
define   shared variable ref_date-start    as character   no-undo .
define   shared variable ref_date-end      as character   no-undo .
define   shared variable ref_date-alone    as character   no-undo .
define   shared work-table TDEDT  no-undo
  field id as char
  field name as character  format "x(40)"
  field n as character
  .
define variable tempstr as character  no-undo.
define variable b1-name as character  no-undo.
define variable b2-name as character  no-undo.
define variable source-str   as character no-undo .
define variable I#           as integer    no-undo.
define variable p-price-med  as decimal init 0 no-undo .
define   shared variable str-obj-type as character  no-undo.
define   shared variable str-obj-code as character  no-undo.
define   shared variable str-obj-name as character  no-undo.
define   shared variable str-obj      as character  no-undo.
define   shared variable link#        as logical  no-undo init false.
define   shared variable  Verify-Arc-ot      as logical  no-undo init false.
define   shared variable  Verify-Arc-stk     as logical  no-undo init false.
define   shared variable  Verify-Arc-supp    as logical  no-undo init false.
define   shared variable  Verify-Arc-hold    as logical  no-undo init false.
define   shared variable  Verify-Arc-aht     as logical  no-undo init false.
define   shared variable  Verify-send-check  as logical  no-undo init false.
define   shared variable  Verify-Arc-fin     as logical  no-undo init false.
define   shared variable  Verify-Arc-strong  as logical  no-undo init false.
define   shared variable  Show-Crsa         as logical  no-undo init false.
define   shared variable  Show-Cost         as logical  no-undo init false.
define   shared variable  Show-Sale         as logical  no-undo init false.
define   shared variable  Name-Sale-price   as character no-undo .
define   shared variable  Format-Folder     as logical no-undo .
define   shared variable  Print-List-Hist   as logical no-undo init false.
define   shared variable Make-Excel     as logical  no-undo init false.
define   shared variable Make-Excel-com as logical  no-undo init false.
define   shared stream ForExcel.
define   shared variable Use-column   as logical extent 256 no-undo .
define   shared variable right-column as logical extent 256 no-undo .
define shared  temp-table Sheetf no-undo
field Excel-Column-Lable as character
field Excel-Row-Heder    as integer
field Excel-Row-Title    as integer
field Sizes              as character
field Make-correct       as character
field Rights-column      as character
field MergeCellsH        as character
field MergeCellsV        as character
field sheet-num          as integer
field ColFormat          as character
field Bas-FIle           as character
field Bas-Params         as character
field Bas-Param-Add      as logical
field File-name          as character
field Silent-save        as logical
index pi as primary unique
      sheet-num
.
find first sheetf where sheet-num = 1 no-error.
define variable l-stroka as character no-undo .
define   shared  variable ch#ExcelApplication as com-handle no-undo .
define   shared  variable ch#Workbook         as com-handle no-undo .
define   shared  variable ch#Worksheet        as com-handle no-undo .
define   shared  variable Num#Str#            as integer no-undo.
define   shared  variable Number-List         as integer no-undo init 1.
define   shared  variable v-excel-file        as character no-undo .
define variable Col-name as character  extent 256.
define variable Col-format as character  extent 256.
define variable Col-Post-format as character  extent 256.
run proc-page0-assign in this-procedure .
procedure proc-page0-assign :
 do
 on error undo, return error return-value
 :
Assign
  Col-name[1] = 'A':U
  Col-name[2] = 'B':U
  Col-name[3] = 'C':U
  Col-name[4] = 'D':U
  Col-name[5] = 'E':U
  Col-name[6] = 'F':U
  Col-name[7] = 'G':U
  Col-name[8] = 'H':U
  Col-name[9] = 'I':U
  Col-name[10]= 'J':U
  Col-name[11]= 'K':U
  Col-name[12]= 'L':U
  Col-name[13]= 'M':U
  Col-name[14]= 'N':U
  Col-name[15]= 'O':U
  Col-name[16]= 'P':U
  Col-name[17]= 'Q':U
  Col-name[18]= 'R':U
  Col-name[19]= 'S':U
  Col-name[20]= 'T':U
  Col-name[21]= 'U':U
  Col-name[22]= 'V':U
  Col-name[23]= 'W':U
  Col-name[24]= 'X':U
  Col-name[25]= 'Y':U
  Col-name[26]= 'Z':U
  Col-name[27]= 'AA':U
  Col-name[28]= 'AB':U
  Col-name[29]= 'AC':U
  Col-name[30]= 'AD':U
  Col-name[31]= 'AE':U
  Col-name[32]= 'AF':U
  Col-name[33]= 'AG':U
  Col-name[34]= 'AH':U
  Col-name[35]= 'AI':U
  Col-name[36]= 'AJ':U
  Col-name[37]= 'AK':U
  Col-name[38]= 'AL':U
  Col-name[39]= 'AM':U
  Col-name[40]= 'AN':U
  Col-name[41]= 'AO':U
  Col-name[42]= 'AP':U
  Col-name[43]= 'AQ':U
  Col-name[44]= 'AR':U
  Col-name[45]= 'AS':U
  Col-name[46]= 'AT':U
  Col-name[47]= 'AU':U
  Col-name[48]= 'AV':U
  Col-name[49]= 'AW':U
  Col-name[50]= 'AX':U
  Col-name[51]= 'AY':U
  Col-name[52]= 'AZ':U
  Col-name[53]= 'BA':U
  Col-name[54]= 'BB':U
  Col-name[55]= 'BC':U
  Col-name[56]= 'BD':U
  Col-name[57]= 'BE':U
  Col-name[58]= 'BF':U
  Col-name[59]= 'BG':U
  Col-name[60]= 'BH':U
  Col-name[61]= 'BI':U
  Col-name[62]= 'BJ':U
  Col-name[63]= 'BK':U
  Col-name[64]= 'BL':U
  Col-name[65]= 'BM':U
  Col-name[66]= 'BN':U
  Col-name[67]= 'BO':U
  Col-name[68]= 'BP':U
  Col-name[69]= 'BQ':U
  Col-name[70]= 'BR':U
  Col-name[71]= 'BS':U
  Col-name[72]= 'BT':U
  Col-name[73]= 'BU':U
  Col-name[74]= 'BV':U
  Col-name[75]= 'BW':U
  Col-name[76]= 'BX':U
  Col-name[77]= 'BY':U
  Col-name[78]= 'BZ':U
  Col-name[79]= 'CA':U
  Col-name[80]= 'CB':U
  Col-name[81]= 'CC':U
  Col-name[82]= 'CD':U
  Col-name[83]= 'CE':U
  Col-name[84]= 'CF':U
  Col-name[85]= 'CG':U
  Col-name[86]= 'CH':U
  Col-name[87]= 'CI':U
  Col-name[88]= 'CJ':U
  Col-name[89]= 'CK':U
  Col-name[90]= 'CL':U
  Col-name[91]= 'CM':U
  Col-name[92]= 'CN':U
  Col-name[93]= 'CO':U
  Col-name[94]= 'CP':U
  Col-name[95]= 'CQ':U
  Col-name[96]= 'CR':U
  Col-name[97]= 'CS':U
  Col-name[98]= 'CT':U
  Col-name[99]= 'CU':U
  Col-name[100]= 'CV':U
Col-name[101]= 'CW':U
Col-name[102]= 'CX':U
Col-name[103]= 'CY':U
Col-name[104]= 'CZ':U
Col-name[105]= 'DA':U
Col-name[106]= 'DB':U
Col-name[107]= 'DC':U
Col-name[108]= 'DD':U
Col-name[109]= 'DE':U
Col-name[110]= 'DF':U
Col-name[111]= 'DG':U
Col-name[112]= 'DH':U
Col-name[113]= 'DI':U
Col-name[114]= 'DJ':U
Col-name[115]= 'DK':U
Col-name[116]= 'DL':U
Col-name[117]= 'DM':U
Col-name[118]= 'DN':U
Col-name[119]= 'DO':U
Col-name[120]= 'DP':U
Col-name[121]= 'DQ':U
Col-name[122]= 'DR':U
Col-name[123]= 'DS':U
Col-name[124]= 'DT':U
Col-name[125]= 'DU':U
Col-name[126]= 'DV':U
Col-name[127]= 'DW':U
Col-name[128]= 'DX':U
Col-name[129]= 'DY':U
Col-name[130]= 'DZ':U
Col-name[131]= 'EA':U
Col-name[132]= 'EB':U
Col-name[133]= 'EC':U
Col-name[134]= 'ED':U
Col-name[135]= 'EE':U
Col-name[136]= 'EF':U
Col-name[137]= 'EG':U
Col-name[138]= 'EH':U
Col-name[139]= 'EI':U
Col-name[140]= 'EJ':U
Col-name[141]= 'EK':U
Col-name[142]= 'EL':U
Col-name[143]= 'EM':U
Col-name[144]= 'EN':U
Col-name[145]= 'EO':U
Col-name[146]= 'EP':U
Col-name[147]= 'EQ':U
Col-name[148]= 'ER':U
Col-name[149]= 'ES':U
Col-name[150]= 'ET':U
Col-name[151]= 'EU':U
Col-name[152]= 'EV':U
Col-name[153]= 'EW':U
Col-name[154]= 'EX':U
Col-name[155]= 'EY':U
Col-name[156]= 'EZ':U
Col-name[157]= 'FA':U
.
assign
  Col-name[158]= 'FB':U
  Col-name[159]= 'FC':U
  Col-name[160]= 'FD':U
  Col-name[161]= 'FE':U
  Col-name[162]= 'FF':U
  Col-name[163]= 'FG':U
  Col-name[164]= 'FH':U
  Col-name[165]= 'FI':U
  Col-name[166]= 'FJ':U
  Col-name[167]= 'FK':U
  Col-name[168]= 'FL':U
  Col-name[169]= 'FM':U
  Col-name[170]= 'FN':U
  Col-name[171]= 'FO':U
  Col-name[172]= 'FP':U
  Col-name[173]= 'FQ':U
  Col-name[174]= 'FR':U
  Col-name[175]= 'FS':U
  Col-name[176]= 'FT':U
  Col-name[177]= 'FU':U
  Col-name[178]= 'FV':U
  Col-name[179]= 'FW':U
  Col-name[180]= 'FX':U
  Col-name[181]= 'FY':U
  Col-name[182]= 'FZ':U
  Col-name[183]= 'GA':U
  Col-name[184]= 'GB':U
  Col-name[185]= 'GC':U
  Col-name[186]= 'GD':U
  Col-name[187]= 'GE':U
  Col-name[188]= 'GF':U
  Col-name[189]= 'GG':U
  Col-name[190]= 'GH':U
  Col-name[191]= 'GI':U
  Col-name[192]= 'GJ':U
  Col-name[193]= 'GK':U
  Col-name[194]= 'GL':U
  Col-name[195]= 'GM':U
  Col-name[196]= 'GN':U
  Col-name[197]= 'GO':U
  Col-name[198]= 'GP':U
  Col-name[199]= 'GQ':U
  Col-name[200]=   'GR':U
  Col-name[201]=   'GS':U
  Col-name[202]=   'GT':U
  Col-name[203]=   'GU':U
  Col-name[204]=   'GV':U
  Col-name[205]=   'GW':U
  Col-name[206]=   'GX':U
  Col-name[207]=   'GY':U
  Col-name[208]=   'GZ':U
  Col-name[209]=   'HA':U
  Col-name[210]=   'HB':U
  Col-name[211]=   'HC':U
  Col-name[212]=   'HD':U
  Col-name[213]=   'HE':U
  Col-name[214]=   'HF':U
  Col-name[215]=   'HG':U
  Col-name[216]=   'HH':U
  Col-name[217]=   'HI':U
  Col-name[218]=   'HJ':U
  Col-name[219]=   'HK':U
  Col-name[220]=   'HL':U
  Col-name[221]=   'HM':U
  Col-name[222]=   'HN':U
  Col-name[223]=   'HO':U
  Col-name[224]=   'HP':U
  Col-name[225]=   'HQ':U
  Col-name[226]=   'HR':U
  Col-name[227]=   'HS':U
  Col-name[228]=   'HT':U
  Col-name[229]=   'HU':U
  Col-name[230]=   'HV':U
  Col-name[231]=   'HW':U
  Col-name[232]=   'HX':U
  Col-name[233]=   'HY':U
  Col-name[234]=   'HZ':U
  Col-name[235]=   'IA':U
  Col-name[236]=   'IB':U
  Col-name[237]=   'IC':U
  Col-name[238]=   'ID':U
  Col-name[239]=   'IE':U
  Col-name[240]=   'IF':U
  Col-name[241]=   'IG':U
  Col-name[242]=   'IH':U
  Col-name[243]=   'II':U
  Col-name[244]=   'IJ':U
  Col-name[245]=   'IK':U
  Col-name[246]=   'IL':U
  Col-name[247]=   'IM':U
  Col-name[248]=   'IN':U
  Col-name[249]=   'IO':U
  Col-name[250]=   'IP':U
  Col-name[251]=   'IQ':U
  Col-name[252]=   'IR':U
  Col-name[253]=   'IS':U
  Col-name[254]=   'IT':U
  Col-name[255]=   'IU':U
  Col-name[256]=   'IV':U
  .
 end.
end procedure.
define variable var-report-r-b as character no-undo .
define variable vss-include-info7 as character format "x(65)" no-undo initial "@(#)$Workfile$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curr-r-b in g#library
  (output var-report-r-b
  )  .
define variable vss-include-info8 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define  shared variable PrintCopiesCounter as integer   no-undo initial 1 .
define  shared variable RepPathName        as character no-undo .
define  shared variable PrintRubl          as logical   no-undo .
define variable vss-include-info9 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info10 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure cur-time :
   define output parameter p-today as date      no-undo .
   define output parameter p-time  as integer   no-undo .
  do
  on error undo, return error
  :
    define variable v-date1 as date      no-undo .
    define variable v-date2 as date      no-undo .
    define variable v-time  as integer   no-undo .
    assign
      v-date1 = today
      v-time  = time
      v-date2 = today
    .
    if v-date1 <> v-date2
    then do:
      assign
        v-date1 = today
        v-time  = v-time
      .
    end.
    assign
      p-today = v-date1
      p-time  = v-time
    .
  end.
end.
function cur-time-date returns character
:
  return string(today, '99/99/9999':U) .
end.
function cur-time-mjd returns decimal
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return integer(v-date) - 2400002 + (v-time / 86400) .
end.
function cur-time-get-ending-index returns integer
(input p-number as integer
)
:
  if p-number < 0
  or p-number = ?
  then do:
    return 1 .
  end.
  define variable v-rest as integer   no-undo .
  assign
    p-number = p-number modulo 100
  .
  if p-number < 20
  then do:
    assign
      v-rest = p-number
    .
  end.
  else do:
    assign
      v-rest = p-number modulo 10
    .
  end.
  case v-rest :
    when 1
    then do:
      return 2 .
    end.
    when 2 or
    when 3 or
    when 4
    then do:
      return 3 .
    end.
    otherwise do:
      return 1 .
    end.
  end case .
end.
procedure cur-time-mjd-to-date :
   define input  parameter i-mjd-diff as decimal no-undo.
   define output parameter o-Date     as date    no-undo.
   define output parameter o-Time     as integer no-undo.
   define variable v-day-number as integer   no-undo .
   if    i-mjd-diff < 0
      or i-mjd-diff = ?
   then do:
      return "?" .
   end.
   assign
      v-day-number = truncate(i-mjd-diff,0).
      o-Date = date(v-day-number + 2400002).
      o-Time = truncate((i-mjd-diff - v-day-number) * 86400, 0)
  .
end.
function cur-time-mjd-to-string returns character
(input p-mjd-diff as decimal
)
:
  define variable v-day-number as integer   no-undo .
  define variable v-seconds    as integer   no-undo .
  define variable v-hour       as integer   no-undo .
  define variable v-min        as integer   no-undo .
  define variable v-day-name    as character no-undo extent 3 initial [   "дней",    "день",     "дня" ] .
  define variable v-hour-name   as character no-undo extent 3 initial [  "часов",     "час",    "часа" ] .
  define variable v-min-name    as character no-undo extent 3 initial [  "минут",  "минута",  "минуты" ] .
  define variable v-second-name as character no-undo extent 3 initial [ "секунд", "секунда", "секунды" ] .
  if p-mjd-diff < 0
  or p-mjd-diff = ?
  then do:
    return "?" .
  end.
  assign
    v-day-number = integer(truncate(p-mjd-diff,0))
    v-seconds    = truncate((p-mjd-diff - v-day-number) * 86400, 0)
  .
  if v-seconds > 86400
  then do:
    assign
      v-seconds = 86400 - 1
    .
  end.
  if v-seconds < 0
  then do:
    assign
      v-seconds = 0
    .
  end.
  assign
    v-hour = truncate(v-seconds / 3600, 0)
  .
  assign
    v-seconds = v-seconds modulo 3600
  .
  assign
    v-min = truncate(v-seconds / 60, 0)
  .
  assign
    v-seconds = v-seconds modulo 60
  .
  return
      (if v-day-number <> 0
        then string(v-day-number) + " " + v-day-name[cur-time-get-ending-index(v-day-number)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0
        then string(v-hour) + " " + v-hour-name[cur-time-get-ending-index(v-hour)] + " "
        else ""
      )
    + (if v-day-number <> 0 or v-hour <> 0 or v-min <> 0
        then string(v-min) + " " + v-min-name[cur-time-get-ending-index(v-min)] + " "
        else ""
      )
    + string(v-seconds) + " " + v-second-name[cur-time-get-ending-index(v-seconds)]
    .
end.
function cur-time-string returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM':U) .
end.
function cur-time-string-sec returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return string(v-date, '99/99/9999':U) + ' ':u + string(v-time, 'HH:MM:SS':U) .
end.
function cur-time-custom  returns character
(input p-prefix as character
,input p-date-format as character
,input p-delimiter as character
,input p-time-format as character
,input p-suffix as character
)
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return
    p-prefix
    + string(v-date, p-date-format)
    + p-delimiter
    + string(v-time, p-time-format)
    + p-suffix
    .
end.
function cur-time-print  returns character
:
  define variable v-date as date      no-undo .
  define variable v-time as integer   no-undo .
  run cur-time in this-procedure
    (output v-date
    ,output v-time
    ) .
  return "Дата печати : " + string(v-date, '99.99.9999':U) + ' , ':U + string(v-time, 'HH:MM':U) .
end.
function cur-time-datetime returns datetime
:
  define variable v-char as character no-undo .
  define variable v-datetime as datetime no-undo .
  v-char = cur-time-string().
  v-datetime = datetime(v-char).
  return  v-datetime.
end.
function cur-time-string-msec returns character
:
  define variable v-date as datetime  no-undo .
  v-date = now.
  return string(v-date) .
end.
FUNCTION Sparse RETURNS CHARACTER ( INPUT p-instring AS CHARACTER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.
  RUN get-sparsed-string IN THIS-PROCEDURE ( INPUT p-instring, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN p-instring ELSE v-outstring ).
END FUNCTION.
PROCEDURE get-sparsed-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.
  DEFINE VARIABLE jj AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    DO jj = 1 TO LENGTH( p-instring ) :
      ASSIGN p-outstring = p-outstring + ( IF p-outstring = "":U THEN "":U ELSE " ":U ) + SUBSTRING( p-instring, jj, 1 ).
    END.
    ASSIGN p-outstring = CAPS( TRIM( p-outstring ) ).
  END.
END PROCEDURE.
FUNCTION Centering RETURNS CHARACTER ( INPUT i-string AS CHARACTER, INPUT i-length AS INTEGER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.
  RUN get-centre-string IN THIS-PROCEDURE ( INPUT i-string, INPUT i-length, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-string ELSE v-outstring ).
END FUNCTION.
PROCEDURE get-centre-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-length    AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.
  DEFINE VARIABLE j-format AS INTEGER NO-UNDO.
  DEFINE VARIABLE j-left   AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-instring = TRIM(   p-instring )
           j-format   = LENGTH( p-instring ).
    IF           j-format > p-length THEN DO:
      ASSIGN p-outstring = SUBSTRING( p-instring, 1, p-length ).
    END. ELSE IF j-format < p-length THEN DO:
      ASSIGN j-left      = INTEGER( ( p-length - ( j-format + 1 ) ) * 0.5 )
             p-outstring = FILL( " ":U, j-left ) + p-instring + FILL( " ":U, p-length - ( j-left + j-format ) ).
    END.                             ELSE DO:
      ASSIGN p-outstring = p-instring.
    END.
  END.
END PROCEDURE.
FUNCTION ShiftRight RETURNS CHARACTER ( INPUT i-string AS CHARACTER, INPUT i-length AS INTEGER ) :
  DEFINE VARIABLE v-outstring AS CHARACTER NO-UNDO.
  RUN get-right-string IN THIS-PROCEDURE ( INPUT i-string, INPUT i-length, OUTPUT v-outstring ) NO-ERROR.
  RETURN ( IF ERROR-STATUS :ERROR THEN i-string ELSE v-outstring ).
END FUNCTION.
PROCEDURE get-right-string :
  DEFINE  INPUT PARAMETER p-instring  AS CHARACTER NO-UNDO.
  DEFINE  INPUT PARAMETER p-length    AS INTEGER   NO-UNDO.
  DEFINE OUTPUT PARAMETER p-outstring AS CHARACTER NO-UNDO INITIAL "":U.
  DEFINE VARIABLE j-format AS INTEGER NO-UNDO.
  DO ON ERROR UNDO, RETURN ERROR :
    ASSIGN p-instring = TRIM(   p-instring )
           j-format   = LENGTH( p-instring ).
    IF           j-format > p-length THEN DO:
      ASSIGN p-outstring = SUBSTRING( p-instring, 1, p-length ).
    END. ELSE IF j-format < p-length THEN DO:
      ASSIGN p-outstring = FILL( " ":U, p-length - j-format ) + p-instring.
    END.                             ELSE DO:
      ASSIGN p-outstring = p-instring.
    END.
  END.
END PROCEDURE.
define variable vss-include-info11 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define buffer bf_wth-doc  for ub.wth-doc  .
define buffer bf_wth-line for ub.wth-line .
define buffer bf_clients  for ub.clients  .
define buffer bf_object   for ub.clients  .
define buffer bf_sysconf  for ub.sysconf  .
define variable v-own-name as character no-undo .
define variable v-obj-name as character no-undo .
define variable v-temp     as character no-undo .
define variable Under_Line as character no-undo .
define variable t_today    as date      no-undo .
define variable j_time     as integer   no-undo .
define variable j_order    as integer   no-undo initial 0 .
define variable v-del-0    as character no-undo .
define variable v-del-1    as character no-undo .
define variable v-del-2    as character no-undo .
define variable r-rec-line as recid     no-undo .
define variable v-firm-name      as character no-undo .
define variable v-object-name    as character no-undo .
define variable v-object-type    as character no-undo .
define variable v-object-code    as integer   no-undo .
define variable fact-order_from  as decimal   no-undo .
define variable fact-order_till  as decimal   no-undo .
define variable j_line-counter   as integer   no-undo .
define variable j_order-max      as integer   no-undo .
define variable v-short-date     as character no-undo .
define variable XLS-page-num     as integer   no-undo .
define variable v-temp-string    as character no-undo .
define variable v_temp-param     as character no-undo .
define variable v_data-type      as character no-undo .
define variable XL-delim         as character no-undo .
define variable v-report-name    as character no-undo .
define variable v-report-subname as character no-undo .
define variable v-stored-name    as character no-undo .
define variable d_rest-from  like ub.wth-line.income no-undo .
define variable d_rest-till  like ub.wth-line.income no-undo .
define variable d_cash-sum   like ub.wth-line.income no-undo .
define variable d_incass-sum like ub.wth-line.incass no-undo .
define variable g#report-num  as integer no-undo .
define variable g#quest-print as logical no-undo initial yes .
define variable g#host-code   as integer no-undo .
define temp-table tt_line no-undo
  field order      as integer
  field obj-type   as character
  field obj-code   as integer
  field obj-name   as character
  field own-type   as character
  field own-code   as integer
  field own-name   as character
  field shift-date as date
  field shift-num  as integer
  field shift-name as character
  field shift-out  as character
  field rest-from  as decimal   decimals 2 format "->,>>>,>>>,>>>,>>9.99":U
  field rest-till  as decimal   decimals 2 format "->,>>>,>>>,>>>,>>9.99":U
  field cash-sum   as decimal   decimals 2 format "->,>>>,>>>,>>>,>>9.99":U
  field incass-sum as decimal   decimals 2 format "->,>>>,>>>,>>>,>>9.99":U
  field is-total   as logical
  index tt-pui     is primary   unique order
  index tt-ui1     is           unique obj-type   obj-code   shift-date shift-num
  index tt-ui2     is           unique shift-date shift-num  obj-type   obj-code
  index i1                             is-total   obj-type   obj-code   shift-date shift-num order
  index i2                             is-total   shift-date shift-num  obj-type   obj-code  order
.
define buffer bf_line for tt_line .
define stream text_out .
define variable vss-include-info12 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define   stream text_out.
procedure prn-lib-prn-file :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-DIsabledoptions as integer no-undo .
  define variable v-report-name as character no-undo .
  define variable v-user-action as character no-undo .
  define variable v-printed     as logical   no-undo .
  define variable v-exist       as logical   no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
define variable vss-include-info13 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run filenmln in g#library
  (input  v-report-name
  ,input  2
  ,output v-exist
  )  .
    if NOT v-exist then
    DO:
      Message
        "Нет заданий на печать ! "
        view-as alert-box .
      Return  .
    End.
    run gbl/prnfilen.w
      (input  ""
      ,input  p-DisabledOptions
      ,input  string(v-report-name )
      ,input  7
      ,output v-user-action
      ,output v-printed
      ) .
    if v-printed then
    do:
      return "YES" .
    end.
    else
    do:
      return "NO" .
    end.
  end.
end procedure.
procedure prn-lib-open-stream :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-page-size    as integer no-undo .
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-append       as logical no-undo .
  define variable v-report-name as character no-undo .
  do
    on error undo, return error
    :
    run prn-lib-get-report-name  in this-procedure (
      input parParentProc
      ,output v-report-name
      ).
    if p-is-stream then
    do:
      if p-append then
      do:
        output stream text_out to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output stream text_out to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
    if not p-is-stream then
    do:
      if p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) append .
      end.
      if not p-append then
      do:
        output to value( v-report-name )
          page-size value(p-page-size) .
      end.
    end.
  end.
end procedure.
procedure prn-lib-open-exp :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-is-stream    as logical no-undo .
  define input parameter p-is-append    as logical no-undo .
  define output parameter p-ReportFileName as char init "report" no-undo.
  define output parameter p-process as logical no-undo .
  define variable glog as logical no-undo .
  do
    on error undo, return error
    :
    SYSTEM-DIALOG GET-FILE p-ReportFileName
      TITLE      "Укажите путь"
      FILTERS "Текстовый файл (*.txt)"   "*.txt"
      ASK-OVERWRITE
      CREATE-TEST-FILE
      SAVE-AS
      USE-FILENAME
      DEFAULT-EXTENSION "txt"
      UPDATE glog
      .
    if not glog then  return.
    p-ReportFileName = trim( string( p-ReportFileName ) ) .
    if p-is-stream then
    do:
      if p-is-append then
      do:
        OUTPUT stream text_out TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT stream text_out TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    else
    do:
      if p-is-append then
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0 append.
      end.
      else
      do:
        OUTPUT TO value ( p-ReportFileName ) PAGE-SIZE 0.
      end.
    end.
    p-process = yes.
  end.
end procedure.
procedure prn-lib-get-report-name :
  define input parameter parParentProc  as widget-handle no-undo.
  define output parameter p-report-name as character no-undo .
  p-report-name = ibs.th.gbl.gbl-inipar:prn-lib-get-report-name("rpt").
end procedure.
procedure prn-lib-reportviewer-report-name :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer-report-name(p-report-name-html) no-error.
end procedure.
procedure prn-lib-reportviewer :
  define input parameter parParentProc  AS WIDGET-HANDLE NO-UNDO.
  define input parameter p-report-name-html as character no-undo .
  define input parameter p-param        as character no-undo .
  define variable v-excel           as character no-undo init 'TRUE' .
  define variable v-value-character as character no-undo .
  define variable v-value-integer   as character no-undo .
  define variable v-value-date      as date      no-undo .
  define variable v-value-decimal   as decimal   no-undo .
  define variable rep-excel         as logical   no-undo .
  define variable excel-string      as character no-undo .
  define variable v-param-type      as character no-undo .
  define variable v-tth             as handle    no-undo .
  run adm/shattri.p (
    input "get":U
    ,input  ""
    ,input  0
    ,input  'report-glob':U
    ,input  'rep-excel':U
    ,output v-value-character
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output rep-excel
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    )  .
  if rep-excel then v-excel = "TRUE" .
  else v-excel = "FALSE" .
  if p-param eq ""
  then
     p-param = "EXCEL:" + v-excel.
  else
     p-param = p-param + chr(4) + "EXCEL:" + v-excel .
  ibs.th.gbl.gbl-inipar:prn-lib-reportviewer(p-report-name-html, p-param).
end procedure.
form header
  v-report-name                                                             format "x(136)":U at 1
  v-report-subname                                                          format "x(136)":U at 1
  v-firm-name                                                               format "x(136)":U at 1 skip( 0 )
  substitute( '&1 &2 "&3".'
            , v-object-type
            , v-object-code
            , v-object-name
            )                                                              format "x(136)":U at 1 skip( 1 )
  ShiftRight( substitute( "Дата печати: &1, время: &2.   Страница: &3."
                        , string( t_today,                 "99.99.9999":U )
                        , string( j_time,                  "HH:MM:SS":U   )
                        , string( page-number( text_out ), ">>9":U        )
                        )                                , 113 ) format "x(136)":U at 1 skip( 0 )
  "-----------------------------------------------------------------------------------------------------------------" skip( 0 )                                                                                                       skip( 0 )                                                         "|                       :  Остаток на начало  :                     : Инкассировано в банк:   Остаток на конец  |" skip( 0 )                     "|     № и дата смены    :   периода (на АЗК)  :   Выручка за смену  :      (за смену)     :   периода (на АЗК)  |" skip( 0 )                     "|-----------------------:---------------------:---------------------:---------------------:---------------------|" skip( 0 )                                                                                                    skip( 0 )
with frame Top_Page width 136 page-top no-labels no-box use-text stream-io no-underline .
form header                                    skip( 1 )
  Under_Line format "x(136)":U at  1 skip( 0 )
  "Продолжение на следующей странице"    at 30 skip( 0 )
with frame Bottom_Page width 136 page-bottom no-labels no-box use-text stream-io no-underline .
do
on error undo, return error return-value
:
  run WaitFram-Show   in this-procedure
    ( input 'Подождите ...'
    ) .
  run get-report-num  in parparentproc
    (
      output g#report-num
    ) .
  run get-quest-print in parparentproc
    (
      output g#quest-print
    ) .
define variable vss-include-info14 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
  assign
    g#host-code = v-cntxt-host-code-obj
  .
define variable vss-include-info15 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable vss-include-info16 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table thbjattr_thbj-attr no-undo like ub.thbj-attr.
define variable par-type          as character no-undo.
define variable v-value-character as character no-undo .
define variable v-value-date      as date      no-undo .
define variable v-value-decimal   as decimal   no-undo .
define variable v-value-integer   as integer   no-undo .
define variable v-value-logical   as logical   no-undo .
define variable vss-include-info17 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
empty temp-table thbjattr_thbj-attr.
run adm/shattri.p (
   input "get":U
  ,input v-cntxt-obj-type
  ,input v-cntxt-obj-code
  ,input 'report-firm':U
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
      if thbjattr_thbj-attr.prop-code = 'XL-delim'  then v_temp-param   = thbjattr_thbj-attr.property-value-character.
  end.
  IF v_temp-param = "" then XL-delim = ";".
  else XL-delim = v_temp-param.
  run gbl/getlocal.p
    ( output v-del-0
    , output v-del-1
    , output v-del-2
    , output v-short-date
    ) no-error .
  if error-status :error
  then do:
    assign
      v-del-1 = " ":U
    .
  end.
  case x-radio-task :
    when 1
    then do:
      assign
        v-temp = "период с " + string( x-date-start ) + " по " + string( x-date-end )
      .
    end.
    when 2
    then do:
      assign
        v-temp = "сменные сутки c " + string( x-date-start ) + " по " + string( x-date-end )
      .
    end.
    when 3
    then do:
      assign
        v-temp = "сменные сутки и порядок смен с "
                + string( x-shift-start ) + " ":U + string( x-date-start ) + " по "
                + string( x-shift-end   ) + " ":U + string( x-date-end   )
      .
    end.
    when 4
    then do:
      assign
        v-temp = "смену " + string( x-shift-alone ) + " с "
                          + string( x-date-start  ) + " по " + string( x-date-end )
      .
    end.
  end case.
  run cur-time in this-procedure
    ( output t_today
    , output j_time
    ) .
  assign
    Under_Line = fill( '-', 113 )
  .
  for each obj-list no-lock
  :
    find first bf_object no-lock where
               bf_object.obj-type = obj-list.obj-type and
               bf_object.obj-code = obj-list.obj-code .
    find first bf_clients no-lock where
               bf_clients.obj-type = 'орг':U              and
               bf_clients.obj-code = bf_object.host-code .
    find first bf_sysconf no-lock where
               bf_sysconf.host-code = bf_clients.obj-code .
    if lookup( bf_object.obj-name, v-obj-name, chr(44) ) = 0
    then do:
      assign
        v-obj-name = v-obj-name
                   + ( if v-obj-name = "":U then "":U else chr(44) )
                   + bf_object.obj-name
      .
    end.
    if lookup( bf_clients.obj-name, v-own-name, chr(44) ) = 0
    then do:
      assign
        v-own-name = v-own-name
                   + ( if v-own-name = "":U then "":U else chr(44) )
                   + bf_clients.obj-name
      .
    end.
    case x-radio-task :
      when 1
      then do:
        for each bf_wth-doc no-lock where
                 bf_wth-doc.obj-type   = obj-list.obj-type and
                 bf_wth-doc.obj-code   = obj-list.obj-code and
                 bf_wth-doc.fact-date >= x-date-start      and
                 bf_wth-doc.fact-date <= x-date-end        and
                 bf_wth-doc.status_    = 'факт':U           and
                 bf_wth-doc.borned     = no
          , each bf_wth-line no-lock where
                 bf_wth-line.doc-code  = bf_wth-doc.doc-code
        break by bf_wth-doc.shift-date
              by bf_wth-doc.shift-num
              by bf_wth-line.wth-code
        :
if first-of( bf_wth-line.wth-code )
then do:
  assign
    fact-order_from = bf_wth-doc.fact-order
  .
  find first tt_line where
             tt_line.obj-type   = bf_object.obj-type    and
             tt_line.obj-code   = bf_object.obj-code    and
             tt_line.shift-date = bf_wth-doc.shift-date and
             tt_line.shift-num  = bf_wth-doc.shift-num  no-error .
  if not available tt_line
  then do:
    run create-tt_line in this-procedure
      (  input bf_object.obj-type
      ,  input bf_object.obj-code
      ,  input bf_object.obj-name
      ,  input bf_clients.obj-type
      ,  input bf_clients.obj-code
      ,  input bf_clients.obj-name
      ,  input bf_wth-doc.shift-date
      ,  input bf_wth-doc.shift-num
      , output r-rec-line
      ) no-error .
    if error-status :error or
       r-rec-line = ?
    then do:
      undo, return error return-value .
    end.
    find first tt_line where
        recid( tt_line ) = r-rec-line .
  end.
end.
if bf_wth-doc.cli-type = bf_sysconf.sale-type and
   bf_wth-doc.cli-code = bf_sysconf.sale-code and
 ( bf_wth-doc.doc-type = 'при':U            or
   bf_wth-doc.doc-type = 'рас':U         ) and
   bf_wth-doc.inter_   = no
then do:
  find first tt_line where
             tt_line.obj-type   = bf_object.obj-type    and
             tt_line.obj-code   = bf_object.obj-code    and
             tt_line.shift-date = bf_wth-doc.shift-date and
             tt_line.shift-num  = bf_wth-doc.shift-num  no-error .
  if not available tt_line
  then do:
    run create-tt_line in this-procedure
      (  input bf_object.obj-type
      ,  input bf_object.obj-code
      ,  input bf_object.obj-name
      ,  input bf_clients.obj-type
      ,  input bf_clients.obj-code
      ,  input bf_clients.obj-name
      ,  input bf_wth-doc.shift-date
      ,  input bf_wth-doc.shift-num
      , output r-rec-line
      ) no-error .
    if error-status :error or
       r-rec-line = ?
    then do:
      undo, return error return-value .
    end.
    find first tt_line where
        recid( tt_line ) = r-rec-line .
  end.
  case bf_wth-doc.doc-type :
    when 'при':U
    then do:
      assign
        tt_line.cash-sum = tt_line.cash-sum + bf_wth-line.fact-sum
      .
    end.
    when 'рас':U
    then do:
      assign
        tt_line.cash-sum = tt_line.cash-sum - bf_wth-line.fact-sum
      .
    end.
  end case.
end.
if last-of( bf_wth-line.wth-code )
then do:
  assign
    fact-order_till = bf_wth-doc.fact-order
  .
  find first tt_line where
             tt_line.obj-type   = bf_object.obj-type    and
             tt_line.obj-code   = bf_object.obj-code    and
             tt_line.shift-date = bf_wth-doc.shift-date and
             tt_line.shift-num  = bf_wth-doc.shift-num  no-error .
  if not available tt_line
  then do:
    run create-tt_line in this-procedure
      (  input bf_object.obj-type
      ,  input bf_object.obj-code
      ,  input bf_object.obj-name
      ,  input bf_clients.obj-type
      ,  input bf_clients.obj-code
      ,  input bf_clients.obj-name
      ,  input bf_wth-doc.shift-date
      ,  input bf_wth-doc.shift-num
      , output r-rec-line
      ) no-error .
    if error-status :error or
       r-rec-line = ?
    then do:
      undo, return error return-value .
    end.
    find first tt_line where
        recid( tt_line ) = r-rec-line .
  end.
  assign
    fact-order_from = 0.00
    fact-order_till = 0.00
  .
end.
        end.
      end.
      when 2
      then do:
        for each bf_wth-doc no-lock where
                 bf_wth-doc.obj-type    = obj-list.obj-type and
                 bf_wth-doc.obj-code    = obj-list.obj-code and
                 bf_wth-doc.shift-date >= x-date-start      and
                 bf_wth-doc.shift-date <= x-date-end        and
                 bf_wth-doc.status_     = 'факт':U           and
                 bf_wth-doc.borned      = no
          , each bf_wth-line no-lock where
                 bf_wth-line.doc-code   = bf_wth-doc.doc-code
        break by bf_wth-doc.shift-date
              by bf_wth-doc.shift-num
              by bf_wth-line.wth-code
        :
if first-of( bf_wth-line.wth-code )
then do:
  assign
    fact-order_from = bf_wth-doc.fact-order
  .
  find first tt_line where
             tt_line.obj-type   = bf_object.obj-type    and
             tt_line.obj-code   = bf_object.obj-code    and
             tt_line.shift-date = bf_wth-doc.shift-date and
             tt_line.shift-num  = bf_wth-doc.shift-num  no-error .
  if not available tt_line
  then do:
    run create-tt_line in this-procedure
      (  input bf_object.obj-type
      ,  input bf_object.obj-code
      ,  input bf_object.obj-name
      ,  input bf_clients.obj-type
      ,  input bf_clients.obj-code
      ,  input bf_clients.obj-name
      ,  input bf_wth-doc.shift-date
      ,  input bf_wth-doc.shift-num
      , output r-rec-line
      ) no-error .
    if error-status :error or
       r-rec-line = ?
    then do:
      undo, return error return-value .
    end.
    find first tt_line where
        recid( tt_line ) = r-rec-line .
  end.
end.
if bf_wth-doc.cli-type = bf_sysconf.sale-type and
   bf_wth-doc.cli-code = bf_sysconf.sale-code and
 ( bf_wth-doc.doc-type = 'при':U            or
   bf_wth-doc.doc-type = 'рас':U         ) and
   bf_wth-doc.inter_   = no
then do:
  find first tt_line where
             tt_line.obj-type   = bf_object.obj-type    and
             tt_line.obj-code   = bf_object.obj-code    and
             tt_line.shift-date = bf_wth-doc.shift-date and
             tt_line.shift-num  = bf_wth-doc.shift-num  no-error .
  if not available tt_line
  then do:
    run create-tt_line in this-procedure
      (  input bf_object.obj-type
      ,  input bf_object.obj-code
      ,  input bf_object.obj-name
      ,  input bf_clients.obj-type
      ,  input bf_clients.obj-code
      ,  input bf_clients.obj-name
      ,  input bf_wth-doc.shift-date
      ,  input bf_wth-doc.shift-num
      , output r-rec-line
      ) no-error .
    if error-status :error or
       r-rec-line = ?
    then do:
      undo, return error return-value .
    end.
    find first tt_line where
        recid( tt_line ) = r-rec-line .
  end.
  case bf_wth-doc.doc-type :
    when 'при':U
    then do:
      assign
        tt_line.cash-sum = tt_line.cash-sum + bf_wth-line.fact-sum
      .
    end.
    when 'рас':U
    then do:
      assign
        tt_line.cash-sum = tt_line.cash-sum - bf_wth-line.fact-sum
      .
    end.
  end case.
end.
if last-of( bf_wth-line.wth-code )
then do:
  assign
    fact-order_till = bf_wth-doc.fact-order
  .
  find first tt_line where
             tt_line.obj-type   = bf_object.obj-type    and
             tt_line.obj-code   = bf_object.obj-code    and
             tt_line.shift-date = bf_wth-doc.shift-date and
             tt_line.shift-num  = bf_wth-doc.shift-num  no-error .
  if not available tt_line
  then do:
    run create-tt_line in this-procedure
      (  input bf_object.obj-type
      ,  input bf_object.obj-code
      ,  input bf_object.obj-name
      ,  input bf_clients.obj-type
      ,  input bf_clients.obj-code
      ,  input bf_clients.obj-name
      ,  input bf_wth-doc.shift-date
      ,  input bf_wth-doc.shift-num
      , output r-rec-line
      ) no-error .
    if error-status :error or
       r-rec-line = ?
    then do:
      undo, return error return-value .
    end.
    find first tt_line where
        recid( tt_line ) = r-rec-line .
  end.
  assign
    fact-order_from = 0.00
    fact-order_till = 0.00
  .
end.
        end.
      end.
      when 3
      then do:
        for each bf_wth-doc no-lock where
                 bf_wth-doc.obj-type    = obj-list.obj-type and
                 bf_wth-doc.obj-code    = obj-list.obj-code and
               ( bf_wth-doc.shift-date >  x-date-start      or
               ( bf_wth-doc.shift-date  = x-date-start      and
                 bf_wth-doc.shift-num  >= x-shift-start ) ) and
               ( bf_wth-doc.shift-date <  x-date-end        or
               ( bf_wth-doc.shift-date  = x-date-end        and
                 bf_wth-doc.shift-num  <= x-shift-end   ) ) and
                 bf_wth-doc.status_     = 'факт':U           and
                 bf_wth-doc.borned      = no
          , each bf_wth-line no-lock where
                 bf_wth-line.doc-code   = bf_wth-doc.doc-code
        break by bf_wth-doc.shift-date
              by bf_wth-doc.shift-num
              by bf_wth-line.wth-code
        :
if first-of( bf_wth-line.wth-code )
then do:
  assign
    fact-order_from = bf_wth-doc.fact-order
  .
  find first tt_line where
             tt_line.obj-type   = bf_object.obj-type    and
             tt_line.obj-code   = bf_object.obj-code    and
             tt_line.shift-date = bf_wth-doc.shift-date and
             tt_line.shift-num  = bf_wth-doc.shift-num  no-error .
  if not available tt_line
  then do:
    run create-tt_line in this-procedure
      (  input bf_object.obj-type
      ,  input bf_object.obj-code
      ,  input bf_object.obj-name
      ,  input bf_clients.obj-type
      ,  input bf_clients.obj-code
      ,  input bf_clients.obj-name
      ,  input bf_wth-doc.shift-date
      ,  input bf_wth-doc.shift-num
      , output r-rec-line
      ) no-error .
    if error-status :error or
       r-rec-line = ?
    then do:
      undo, return error return-value .
    end.
    find first tt_line where
        recid( tt_line ) = r-rec-line .
  end.
end.
if bf_wth-doc.cli-type = bf_sysconf.sale-type and
   bf_wth-doc.cli-code = bf_sysconf.sale-code and
 ( bf_wth-doc.doc-type = 'при':U            or
   bf_wth-doc.doc-type = 'рас':U         ) and
   bf_wth-doc.inter_   = no
then do:
  find first tt_line where
             tt_line.obj-type   = bf_object.obj-type    and
             tt_line.obj-code   = bf_object.obj-code    and
             tt_line.shift-date = bf_wth-doc.shift-date and
             tt_line.shift-num  = bf_wth-doc.shift-num  no-error .
  if not available tt_line
  then do:
    run create-tt_line in this-procedure
      (  input bf_object.obj-type
      ,  input bf_object.obj-code
      ,  input bf_object.obj-name
      ,  input bf_clients.obj-type
      ,  input bf_clients.obj-code
      ,  input bf_clients.obj-name
      ,  input bf_wth-doc.shift-date
      ,  input bf_wth-doc.shift-num
      , output r-rec-line
      ) no-error .
    if error-status :error or
       r-rec-line = ?
    then do:
      undo, return error return-value .
    end.
    find first tt_line where
        recid( tt_line ) = r-rec-line .
  end.
  case bf_wth-doc.doc-type :
    when 'при':U
    then do:
      assign
        tt_line.cash-sum = tt_line.cash-sum + bf_wth-line.fact-sum
      .
    end.
    when 'рас':U
    then do:
      assign
        tt_line.cash-sum = tt_line.cash-sum - bf_wth-line.fact-sum
      .
    end.
  end case.
end.
if last-of( bf_wth-line.wth-code )
then do:
  assign
    fact-order_till = bf_wth-doc.fact-order
  .
  find first tt_line where
             tt_line.obj-type   = bf_object.obj-type    and
             tt_line.obj-code   = bf_object.obj-code    and
             tt_line.shift-date = bf_wth-doc.shift-date and
             tt_line.shift-num  = bf_wth-doc.shift-num  no-error .
  if not available tt_line
  then do:
    run create-tt_line in this-procedure
      (  input bf_object.obj-type
      ,  input bf_object.obj-code
      ,  input bf_object.obj-name
      ,  input bf_clients.obj-type
      ,  input bf_clients.obj-code
      ,  input bf_clients.obj-name
      ,  input bf_wth-doc.shift-date
      ,  input bf_wth-doc.shift-num
      , output r-rec-line
      ) no-error .
    if error-status :error or
       r-rec-line = ?
    then do:
      undo, return error return-value .
    end.
    find first tt_line where
        recid( tt_line ) = r-rec-line .
  end.
  assign
    fact-order_from = 0.00
    fact-order_till = 0.00
  .
end.
        end.
      end.
      when 4
      then do:
        for each bf_wth-doc no-lock where
                 bf_wth-doc.obj-type    = obj-list.obj-type and
                 bf_wth-doc.obj-code    = obj-list.obj-code and
                 bf_wth-doc.shift-date >= x-date-start      and
                 bf_wth-doc.shift-date <= x-date-end        and
                 bf_wth-doc.shift-num   = x-shift-alone     and
                 bf_wth-doc.status_     = 'факт':U           and
                 bf_wth-doc.borned      = no
          , each bf_wth-line no-lock where
                 bf_wth-line.doc-code   = bf_wth-doc.doc-code
        break by bf_wth-doc.shift-date
              by bf_wth-doc.shift-num
              by bf_wth-line.wth-code
        :
if first-of( bf_wth-line.wth-code )
then do:
  assign
    fact-order_from = bf_wth-doc.fact-order
  .
  find first tt_line where
             tt_line.obj-type   = bf_object.obj-type    and
             tt_line.obj-code   = bf_object.obj-code    and
             tt_line.shift-date = bf_wth-doc.shift-date and
             tt_line.shift-num  = bf_wth-doc.shift-num  no-error .
  if not available tt_line
  then do:
    run create-tt_line in this-procedure
      (  input bf_object.obj-type
      ,  input bf_object.obj-code
      ,  input bf_object.obj-name
      ,  input bf_clients.obj-type
      ,  input bf_clients.obj-code
      ,  input bf_clients.obj-name
      ,  input bf_wth-doc.shift-date
      ,  input bf_wth-doc.shift-num
      , output r-rec-line
      ) no-error .
    if error-status :error or
       r-rec-line = ?
    then do:
      undo, return error return-value .
    end.
    find first tt_line where
        recid( tt_line ) = r-rec-line .
  end.
end.
if bf_wth-doc.cli-type = bf_sysconf.sale-type and
   bf_wth-doc.cli-code = bf_sysconf.sale-code and
 ( bf_wth-doc.doc-type = 'при':U            or
   bf_wth-doc.doc-type = 'рас':U         ) and
   bf_wth-doc.inter_   = no
then do:
  find first tt_line where
             tt_line.obj-type   = bf_object.obj-type    and
             tt_line.obj-code   = bf_object.obj-code    and
             tt_line.shift-date = bf_wth-doc.shift-date and
             tt_line.shift-num  = bf_wth-doc.shift-num  no-error .
  if not available tt_line
  then do:
    run create-tt_line in this-procedure
      (  input bf_object.obj-type
      ,  input bf_object.obj-code
      ,  input bf_object.obj-name
      ,  input bf_clients.obj-type
      ,  input bf_clients.obj-code
      ,  input bf_clients.obj-name
      ,  input bf_wth-doc.shift-date
      ,  input bf_wth-doc.shift-num
      , output r-rec-line
      ) no-error .
    if error-status :error or
       r-rec-line = ?
    then do:
      undo, return error return-value .
    end.
    find first tt_line where
        recid( tt_line ) = r-rec-line .
  end.
  case bf_wth-doc.doc-type :
    when 'при':U
    then do:
      assign
        tt_line.cash-sum = tt_line.cash-sum + bf_wth-line.fact-sum
      .
    end.
    when 'рас':U
    then do:
      assign
        tt_line.cash-sum = tt_line.cash-sum - bf_wth-line.fact-sum
      .
    end.
  end case.
end.
if last-of( bf_wth-line.wth-code )
then do:
  assign
    fact-order_till = bf_wth-doc.fact-order
  .
  find first tt_line where
             tt_line.obj-type   = bf_object.obj-type    and
             tt_line.obj-code   = bf_object.obj-code    and
             tt_line.shift-date = bf_wth-doc.shift-date and
             tt_line.shift-num  = bf_wth-doc.shift-num  no-error .
  if not available tt_line
  then do:
    run create-tt_line in this-procedure
      (  input bf_object.obj-type
      ,  input bf_object.obj-code
      ,  input bf_object.obj-name
      ,  input bf_clients.obj-type
      ,  input bf_clients.obj-code
      ,  input bf_clients.obj-name
      ,  input bf_wth-doc.shift-date
      ,  input bf_wth-doc.shift-num
      , output r-rec-line
      ) no-error .
    if error-status :error or
       r-rec-line = ?
    then do:
      undo, return error return-value .
    end.
    find first tt_line where
        recid( tt_line ) = r-rec-line .
  end.
  assign
    fact-order_from = 0.00
    fact-order_till = 0.00
  .
end.
        end.
      end.
    end case.
  end.
  for each tt_line
  :
    assign
      tt_line.incass-sum = tt_line.incass-sum - tt_line.cash-sum
    .
  end.
  assign
    d_rest-from  = 0.00
    d_rest-till  = 0.00
    d_cash-sum   = 0.00
    d_incass-sum = 0.00
  .
  for each bf_line no-lock where
           bf_line.is-total = no
  break by bf_line.obj-type
        by bf_line.obj-code
  :
    if first-of( bf_line.obj-code )
    then do:
      assign
        d_rest-from  = bf_line.rest-from
        d_rest-till  = 0.00
        d_cash-sum   = 0.00
        d_incass-sum = 0.00
      .
    end.
    assign
      d_cash-sum   = d_cash-sum   + bf_line.cash-sum
      d_incass-sum = d_incass-sum + bf_line.incass-sum
    .
    if last-of( bf_line.obj-code )
    then do:
      assign
        j_order = j_order + 10
      .
      create tt_line .
      assign
        tt_line.order      = j_order + 2
        tt_line.obj-type   = bf_line.obj-type
        tt_line.obj-code   = bf_line.obj-code
        tt_line.obj-name   = bf_line.obj-name
        tt_line.own-type   = bf_line.own-type
        tt_line.own-code   = bf_line.own-code
        tt_line.own-name   = bf_line.own-name
        tt_line.shift-date = t_today
        tt_line.shift-num  = j_time
        tt_line.shift-name = "":U
        tt_line.shift-out  = "":U
        tt_line.rest-from  = d_rest-from
        tt_line.rest-till  = bf_line.rest-till
        tt_line.cash-sum   = d_cash-sum
        tt_line.incass-sum = d_incass-sum
        tt_line.is-total   = yes
      .
      assign
        tt_line.shift-out  = Centering( "Итого по объекту:" , 23 )
      .
    end.
  end.
  for each bf_line no-lock where
           bf_line.is-total = no
  break by bf_line.shift-date
        by bf_line.shift-num
  :
    if first-of( bf_line.shift-num )
    then do:
      assign
        d_rest-from  = bf_line.rest-from
        d_rest-till  = 0.00
        d_cash-sum   = 0.00
        d_incass-sum = 0.00
      .
    end.
    assign
      d_cash-sum   = d_cash-sum   + bf_line.cash-sum
      d_incass-sum = d_incass-sum + bf_line.incass-sum
    .
    if last-of( bf_line.shift-num )
    then do:
      assign
        j_order = j_order + 10
      .
      create tt_line .
      assign
        tt_line.order      = j_order + 4
        tt_line.obj-type   = "---"
        tt_line.obj-code   = -1
        tt_line.obj-name   = v-obj-name
        tt_line.own-type   = "":U
        tt_line.own-code   = 0
        tt_line.own-name   = v-own-name
        tt_line.shift-date = bf_line.shift-date
        tt_line.shift-num  = bf_line.shift-num
        tt_line.shift-name = bf_line.shift-name
        tt_line.shift-out  = "":U
        tt_line.rest-from  = d_rest-from
        tt_line.rest-till  = bf_line.rest-till
        tt_line.cash-sum   = d_cash-sum
        tt_line.incass-sum = d_incass-sum
        tt_line.is-total   = yes
      .
      assign
        tt_line.shift-out  = Centering( "Итого за смену:" , 23 )
      .
    end.
  end.
  assign
    d_rest-from  = 0.00
    d_rest-till  = 0.00
    d_cash-sum   = 0.00
    d_incass-sum = 0.00
  .
  for each bf_line no-lock where
           bf_line.is-total = yes
  :
    if bf_line.obj-type   = "---" or
       bf_line.obj-code   = -1 or
       bf_line.shift-date = ?                 or
       bf_line.shift-num  = 0
    then do:
      next .
    end.
    assign
      d_rest-from  = d_rest-from  + bf_line.rest-from
      d_rest-till  = d_rest-till  + bf_line.rest-till
      d_cash-sum   = d_cash-sum   + bf_line.cash-sum
      d_incass-sum = d_incass-sum + bf_line.incass-sum
    .
  end.
  assign
    j_order = j_order + 10
  .
  create tt_line .
  assign
    tt_line.order      = j_order + 8
    tt_line.obj-type   = "---"
    tt_line.obj-code   = -1
    tt_line.obj-name   = v-obj-name
    tt_line.own-type   = "":U
    tt_line.own-code   = 0
    tt_line.own-name   = v-own-name
    tt_line.shift-date = ?
    tt_line.shift-num  = 0
    tt_line.shift-name = "":U
    tt_line.shift-out  = "":U
    tt_line.rest-from  = d_rest-from
    tt_line.rest-till  = d_rest-till
    tt_line.cash-sum   = d_cash-sum
    tt_line.incass-sum = d_incass-sum
    tt_line.is-total   = yes
  .
  assign
    tt_line.shift-out  = Centering( "Итого:" , 23 )
  .
  assign
    d_rest-from  = 0.00
    d_rest-till  = 0.00
    d_cash-sum   = 0.00
    d_incass-sum = 0.00
  .
  assign
    j_order-max = tt_line.order
  .
  run prn-lib-open-stream in this-procedure
    ( input parparentproc
    , input 62
    , input yes
    , input no
    ) .
  assign
    v-report-name    = Centering( Sparse( "Отчет о движении материальных ценностей" ), 113 )
    v-report-subname = Centering( Sparse( "за " + v-temp                            ), 113 )
                     + chr(10)
                     + chr(10)
  .
  if p-tog-object = yes
  then do:
    assign
      j_line-counter = 0
    .
    for each tt_line no-lock where
             tt_line.is-total = p-tog-total
    break by tt_line.obj-type
          by tt_line.obj-code
          by tt_line.shift-date
          by tt_line.shift-num
    :
      if p-tog-total        =  yes               and
         tt_line.obj-type   =  "---" and
         tt_line.obj-code   =  -1 and
         tt_line.shift-date <> t_today           and
         tt_line.shift-num  <> j_time
      then do:
        next .
      end.
      if first-of( tt_line.obj-code )
      then do:
        assign
          v-firm-name   = tt_line.own-name
          v-object-type = tt_line.obj-type
          v-object-code = tt_line.obj-code
          v-object-name = tt_line.obj-name
        .
        if v-firm-name = v-stored-name
        then do:
          assign
            v-firm-name = "":U
          .
        end.
        view stream text_out frame    Top_Page .
        view stream text_out frame Bottom_Page .
        if not first( tt_line.obj-code )
        then do:
          assign
            v-report-name    = "":U
            v-report-subname = "":U
          .
          if page-size( text_out ) > line-counter( text_out ) + 6 and
             j_line-counter        > 0
          then do:
            put stream text_out unformatted
              v-firm-name               format "x(136)":U at 1                                                              skip( 0 )
              substitute( '&1 &2 "&3".'
                        , v-object-type
                        , v-object-code
                        , v-object-name
                        )               format "x(136)":U at 1                                                              skip( 0 )
              "-----------------------------------------------------------------------------------------------------------------" skip( 0 )                                                                                                       skip( 0 )                                                         "|                       :  Остаток на начало  :                     : Инкассировано в банк:   Остаток на конец  |" skip( 0 )                     "|     № и дата смены    :   периода (на АЗК)  :   Выручка за смену  :      (за смену)     :   периода (на АЗК)  |" skip( 0 )                     "|-----------------------:---------------------:---------------------:---------------------:---------------------|" skip( 0 )                                                                                                    skip( 0 )
            .
          end.
          else do:
            page stream text_out .
          end.
        end.
        assign
          v-firm-name   = tt_line.own-name
          v-stored-name = tt_line.own-name
        .
      end.
      put stream text_out unformatted
        "|" string(         tt_line.shift-out                              , "x(23)":U )
        ":" string( string( tt_line.rest-from,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
        ":" string( string( tt_line.cash-sum,   "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
        ":" string( string( tt_line.incass-sum, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
        ":" string( string( tt_line.rest-till,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
        "|" skip
      .
      if last-of( tt_line.obj-code )
      then do:
        if p-tog-total = no
        then do:
          find first bf_line no-lock where
                     bf_line.is-total = yes              and
                     bf_line.obj-type = tt_line.obj-type and
                     bf_line.obj-code = tt_line.obj-code .
          put stream text_out unformatted
            "|-----------------------:---------------------:---------------------:---------------------:---------------------|" skip( 0 )
          .
          put stream text_out unformatted
            "|" string(         bf_line.shift-out                              , "x(23)":U )
            ":" string( string( bf_line.rest-from,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
            ":" string( string( bf_line.cash-sum,   "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
            ":" string( string( bf_line.incass-sum, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
            ":" string( string( bf_line.rest-till,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
            "|" skip
          .
        end.
        if last( tt_line.obj-code )
        then do:
          put stream text_out unformatted
            string( Under_Line, "x(113)":U ) skip( 0 )
          .
          hide stream text_out frame Bottom_Page .
        end.
        else do:
          put stream text_out unformatted
            string( Under_Line, "x(113)":U ) skip( 1 )
          .
        end.
      end.
      if last( tt_line.obj-code )
      then do:
        hide stream text_out frame Bottom_Page .
      end.
      assign
        j_line-counter = j_line-counter + 1
      .
    end.
  end.
  else do:
    assign
      v-firm-name   = v-own-name
      v-object-type = "":U
      v-object-code = num-entries( v-obj-name )
      v-object-name = v-obj-name
    .
    view stream text_out frame    Top_Page .
    view stream text_out frame Bottom_Page .
    assign
      v-report-name    = "":U
      v-report-subname = "":U
    .
    if p-tog-total = yes
    then do:
      assign
        j_line-counter = 1
      .
    end.
    else do:
      assign
        j_line-counter = 0
      .
      for each tt_line no-lock where
               tt_line.is-total = p-tog-total
      break by tt_line.shift-date
            by tt_line.shift-num
            by tt_line.obj-type
            by tt_line.obj-code
      :
        if p-tog-total        =  yes               and
           tt_line.obj-type   <> "---" and
           tt_line.obj-code   <> -1 and
           tt_line.shift-date =  t_today           and
           tt_line.shift-num  =  j_time
        then do:
          next .
        end.
        if tt_line.order      = j_order-max or
           tt_line.shift-date = ?           or
           tt_line.shift-num  = 0
        then do:
          next .
        end.
        if p-tog-total = yes
        then do:
          assign
            v-temp-string = ShiftRight( substitute( '№ &1&3 от &2'
                                      , tt_line.shift-name
                                      , string( tt_line.shift-date, "99/99/9999":U )
                                      , ( if tt_line.shift-name = string( tt_line.shift-num ) then "":U else
                                        ( substitute( '(&1)'
                                                    , tt_line.shift-num
                                                    )
                                        )
                                        )
                                      )
                                      , 22 ) + " ":U
          .
          put stream text_out unformatted
            "|" string( v-temp-string, "x(23)":U )
          .
        end.
        else do:
          put stream text_out unformatted
            "|" string(         tt_line.shift-out                              , "x(23)":U )
          .
        end.
        put stream text_out unformatted
          ":" string( string( tt_line.rest-from,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
          ":" string( string( tt_line.cash-sum,   "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
          ":" string( string( tt_line.incass-sum, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
          ":" string( string( tt_line.rest-till,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
          "|" skip
        .
        if last( tt_line.shift-num )
        then do:
          hide stream text_out frame Bottom_Page .
        end.
        assign
          j_line-counter = j_line-counter + 1
        .
      end.
      put stream text_out unformatted
        string( Under_Line, "x(113)":U ) skip
      .
    end.
  end.
  if j_line-counter > 0
  then do:
    find first bf_line no-lock where
               bf_line.order = j_order-max .
    put stream text_out unformatted
      "|" string(         bf_line.shift-out                              , "x(23)":U )
      ":" string( string( bf_line.rest-from,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
      ":" string( string( bf_line.cash-sum,   "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
      ":" string( string( bf_line.incass-sum, "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
      ":" string( string( bf_line.rest-till,  "->,>>>,>>>,>>>,>>9.99":U ), "x(21)":U )
      "|" skip
    .
    put stream text_out unformatted
      string( Under_Line, "x(113)":U ) skip
    .
  end.
  hide stream text_out frame    Top_Page .
  hide stream text_out frame Bottom_Page .
  output stream text_out close .
  run WaitFram-Hide in this-procedure .
  run prn-lib-prn-file in this-procedure
    ( input parparentproc
    , input 0
    ) .
end.
procedure wealth-rest :
  define  input parameter p-obj-type    as character no-undo .
  define  input parameter p-obj-code    as integer   no-undo .
  define  input parameter p-shift-date  as date      no-undo .
  define  input parameter p-shift-num   as integer   no-undo .
  define output parameter p-rest-from   as decimal   no-undo initial 0.00 .
  define output parameter p-rest-till   as decimal   no-undo initial 0.00 .
  define output parameter p-incass-bank as decimal   no-undo initial 0.00 .
  define variable d_stock-start  like ub.wth-line.income       no-undo .
  define variable d_stock-end    like ub.wth-line.income       no-undo .
  define variable d_income       like ub.wth-line.income       no-undo .
  define variable d_income-cassa like ub.wth-line.income-cassa no-undo .
  define variable d_income-other like ub.wth-line.income-other no-undo .
  define variable d_incass       like ub.wth-line.incass       no-undo .
  define variable d_incass-bank  like ub.wth-line.incass-bank  no-undo .
  define variable d_incass-other like ub.wth-line.incass-other no-undo .
  define variable d_incass-cassa like ub.wth-line.incass-cassa no-undo .
  define buffer bf_wth-obj for ub.wth-obj .
  do
  on error undo, return error return-value
  :
    for each bf_wth-obj no-lock where
             bf_wth-obj.obj-type = p-obj-type and
             bf_wth-obj.obj-code = p-obj-code
          by bf_wth-obj.wth-code
    :
      run wth-lib_full-inf-shift in this-procedure
        (  input p-obj-type
        ,  input p-obj-code
        ,  input bf_wth-obj.wth-code
        ,  input p-shift-date
        ,  input p-shift-num
        , output d_stock-start
        , output d_stock-end
        , output d_income
        , output d_income-cassa
        , output d_income-other
        , output d_incass
        , output d_incass-bank
        , output d_incass-other
        , output d_incass-cassa
        ) no-error .
      if error-status :error
      then do:
        undo, return error return-value .
      end.
      assign
        p-rest-from   = p-rest-from   + d_stock-start
        p-rest-till   = p-rest-till   + d_stock-end
        p-incass-bank = p-incass-bank + d_income      - d_incass
      .
    end.
  end.
end procedure.
procedure create-tt_line :
  define  input parameter p-obj-type   as character no-undo .
  define  input parameter p-obj-code   as integer   no-undo .
  define  input parameter p-obj-name   as character no-undo .
  define  input parameter p-cli-type   as character no-undo .
  define  input parameter p-cli-code   as integer   no-undo .
  define  input parameter p-cli-name   as character no-undo .
  define  input parameter p-shift-date as date      no-undo .
  define  input parameter p-shift-num  as integer   no-undo .
  define output parameter p-rec-id     as recid     no-undo .
  define variable v-shift-name     as character no-undo .
  define variable v-shift-name-num as character no-undo .
  do
  on error undo, return error return-value
  :
    find first tt_line where
               tt_line.obj-type   = p-obj-type   and
               tt_line.obj-code   = p-obj-code   and
               tt_line.shift-date = p-shift-date and
               tt_line.shift-num  = p-shift-num  no-error .
    if not available tt_line
    then do:
      assign
        j_order = j_order + 10
      .
if (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:   run str/lib-trn3.p persistent no-error .   if error-status :error or (valid-handle(ibs.th.gbl.gbl-hndllib:g#lib-trn3) <> true) then do:     message       "Error starting lib-trn3.p" skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :type skip       ibs.th.gbl.gbl-hndllib:g#lib-trn3 :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run lib-trn3_shiftnam in g#lib-trn3
  (
     input p-obj-type
  ,  input p-obj-code
  ,  input p-shift-date
  ,  input p-shift-num
  , output v-shift-name
  , output v-shift-name-num
  )        no-error .
      if error-status :error
      then do:
        undo, return error return-value .
      end.
      create tt_line .
      assign
        tt_line.order      = j_order
        tt_line.obj-type   = p-obj-type
        tt_line.obj-code   = p-obj-code
        tt_line.obj-name   = p-obj-name
        tt_line.own-type   = p-cli-type
        tt_line.own-code   = p-cli-code
        tt_line.own-name   = p-cli-name
        tt_line.shift-date = p-shift-date
        tt_line.shift-num  = p-shift-num
        tt_line.shift-name = v-shift-name
        tt_line.shift-out  = "":U
        tt_line.rest-from  = 0.00
        tt_line.rest-till  = 0.00
        tt_line.cash-sum   = 0.00
        tt_line.incass-sum = 0.00
        tt_line.is-total   = no
      .
      assign
        tt_line.shift-out  = ShiftRight( substitute( '№ &1 от &2'
                                                   , v-shift-name-num
                                                   , string( p-shift-date, "99/99/9999":U )
                                                   )
                                                   , 22 ) + " ":U
      .
      run wealth-rest in this-procedure
        (  input p-obj-type
        ,  input p-obj-code
        ,  input p-shift-date
        ,  input p-shift-num
        , output tt_line.rest-from
        , output tt_line.rest-till
        , output tt_line.incass-sum
        ) no-error .
      if error-status :error
      then do:
        undo, return error return-value .
      end.
    end.
    assign
      p-rec-id = recid( tt_line )
    .
  end.
end procedure.
