block-level on error undo, throw.
define input parameter p-obj-type           as character        no-undo.
define input parameter p-obj-code           as integer          no-undo.
define input parameter p-shift-date         as date             no-undo.
define input parameter p-shift-num          as integer          no-undo.
define output parameter p-fact-order-from   as decimal          no-undo.
define output parameter p-fact-order-to     as decimal          no-undo.
define output parameter p-docs-exists       as logical          no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: getfosht.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/getfosht.p $":U .
define variable vss-description as character no-undo init "Определение диапазона fact-order по диапазону дат или смен".
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
    define variable v-shift-on    as logical      no-undo.
    define buffer buf_stk-tot for ub.stk-tot.
do
for buf_stk-tot
on error undo, return error
:
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run objat in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  'shift-on=request'
  ,output v-shift-on
  ) no-error .
    if error-status :error
    then do:
        message
                    vss-workfile vss-revision vss-description
            skip(1)
            skip "Невозможно определить тип сменный/не сменный"
            skip "для заданного объекта."
            skip "Объект:" p-obj-type p-obj-code
            skip return-value
            skip trim(error-status :get-message(1))
                    trim(error-status :get-message(2))
                    trim(error-status :get-message(3))
        view-as alert-box error.
        undo, return error .
    end.
    if v-shift-on = no
    then do:
        message
            "Неверно задан тип объекта" p-obj-type p-obj-code
            skip "Объект не сменный."
        view-as alert-box information.
    end.
    assign
        p-docs-exists = no
    .
    find last buf_stk-tot no-lock
        where buf_stk-tot.obj-type   = p-obj-type
          and buf_stk-tot.obj-code   = p-obj-code
          and buf_stk-tot.shift-date = p-shift-date
          and buf_stk-tot.shift-num  = p-shift-num
    use-index shift-num
    no-error.
    if not available buf_stk-tot
    then do:
        assign
            p-docs-exists = no
        .
    end.
    else do:
        assign
            p-fact-order-to = buf_stk-tot.fact-order
            p-docs-exists   = yes
        .
        find last buf_stk-tot no-lock
            where buf_stk-tot.obj-type   = p-obj-type
              and buf_stk-tot.obj-code   = p-obj-code
              and buf_stk-tot.shift-date = p-shift-date
              and buf_stk-tot.shift-num  < p-shift-num
        use-index shift-num
        no-error.
        if not available buf_stk-tot
        then do:
            find last buf_stk-tot no-lock
                where buf_stk-tot.obj-type   = p-obj-type
                  and buf_stk-tot.obj-code   = p-obj-code
                  and buf_stk-tot.shift-date < p-shift-date
            use-index shift-num
            no-error.
            if not available buf_stk-tot
            then do:
                assign
                    p-docs-exists       = yes
                    p-fact-order-from   = 0
                .
            end.
        end.
        if available buf_stk-tot
        then do:
            if buf_stk-tot.fact-order >= p-fact-order-to
            then do:
                assign
                    p-docs-exists = no
                .
            end.
            else do:
                assign
                    p-docs-exists       = yes
                    p-fact-order-from   = buf_stk-tot.fact-order
                .
            end.
        end.
    end.
end.
