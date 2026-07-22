block-level on error undo, throw.
define input  parameter p-parent-handle     as handle no-undo .
define input  parameter p-fins-doc-type      like ub.fin-statement.fins-doc-type     no-undo .
define input  parameter p-fins-ext-doc-type  like ub.fin-statement.fins-ext-doc-type no-undo .
define input  parameter p-status-current     like ub.fin-statement.status_          no-undo .
define input  parameter p-mode               as   character                   no-undo .
define input  parameter p-author             as   character                   no-undo .
define input  parameter p-status-date        like ub.fin-statement.fact-date        no-undo .
define output parameter p-status_            like ub.fin-statement.status_          no-undo .
define output parameter p-ask-date           as logical                       no-undo .
define output parameter p-ask-message        as character                     no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Стандартный граф переходов выписок по параметрам".
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
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do on error undo, return error return-value :
  CASE p-fins-doc-type:
    when 'стд':U then do:
      CASE P-status-current:
        when 'новый':U then do:
           run standard-sttm-new          .
        end.
        when 'банк':U then do:
           run standard-sttm-bank       .
        end.
        otherwise do:
           return error substitute ("Недопустимый тип-статус &1-&2.", p-fins-doc-type, p-status-current).
        end.
      END CASE.
    end.
    otherwise do:
        return error substitute ("Недопустимый тип-статус &1-&2.", p-fins-doc-type, p-status-current).
    end.
  END CASE.
end.
procedure standard-sttm-new :
case p-mode:
  when '<открытие документа>':U then do:
    return error substitute ('Выписка открыта.').
  end.
  when '<закрытие документа>':U then do:
     assign
     p-status_ = 'банк':U
     p-ask-message = "Закрыть выписку(и)" + chr(10) +
                     "(закончить редактирование ВЫПИСКИ и перевести в статус БАНК)?"
     p-ask-date = yes
     .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для выписки с атрибутами тип-статус &2-&3.', p-mode, p-fins-doc-type, p-status-current).
  end.
end case.
end procedure.
procedure standard-sttm-bank:
case p-mode:
  when '<открытие документа>':U then do:
    assign
    p-status_ = 'новый':U
    p-ask-message = "Открыть выписку(и)" + chr(10) +
                    "(снять отметку о поступления выписки из банка)?"
    .
  end.
  when '<закрытие документа>':U then do:
    run check-cl-bank in p-parent-handle no-error .
    if error-status:error then do:
      return error return-value .
    end.
    assign
    p-status_ = 'факт':U
    p-ask-message = "Закрыть выписку(и)" + chr(10) +
                    "(подтвердить факт поступления выписки из банка - дальнейшее редактирование выписки будет невозможно)?"
    p-ask-date = yes
    .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для выписки с атрибутами тип-статус &2-&3.', p-mode, p-fins-doc-type, p-status-current).
  end.
end case.
end procedure.
