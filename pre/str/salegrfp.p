block-level on error undo, throw.
define input  parameter p-status-current    like ub.inkas.status_            no-undo .
define input  parameter p-flag-current      like ub.inkas.flag_              no-undo .
define input  parameter p-doc-status-current like ub.trn-doc.status_          no-undo .
define input  parameter p-mode              as   character                   no-undo .
define output parameter p-status_           like ub.inkas.status_            no-undo .
define output parameter p-flag_             like ub.inkas.flag_              no-undo .
define output parameter p-ask-message       as character                     no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: salegrfp.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/salegrfp.p $":U .
define variable vss-description as character no-undo init "Стандартный граф переходов продаж по параметрам".
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
do on error undo, return error return-value :
CASE P-status-current:
  when 'новый':U then do:
    CASE p-flag-current:
      when no then do:
        run new-minus.
      end.
      when yes then do:
        run new-plus.
      end.
    END CASE.
  end.
  when 'нередакт':U then do:
    run doc-froze.
  end.
  when 'факт':U then do:
      return error substitute ("Недопустимый статус &1", p-status-current).
  end.
  when 'запрос':U then do:
      return error substitute ("Недопустимый статус &1", p-status-current).
  end.
END CASE.
END.
procedure new-minus :
case p-mode:
  when '<открытие документа>':U then do:
    return error substitute ('Продажа открыта для закачки чеков.').
  end.
  when '<закрытие документа>':U then do:
     assign
     p-status_ = 'новый':U
     p-flag_   = yes
     p-ask-message = "Запрет на добавление чеков в продажу в режиме автом. работы с продажей по расписанию"
     .
  end.
  when '<закрытие документа на факт>':U then do:
     assign
     p-status_ = (if p-doc-status-current = 'запрос':U then 'запрос':U else 'факт':U)
     p-flag_   = no
     p-ask-message = if p-doc-status-current = 'запрос':U
                     then "Закрытие продажи до статуса <запрос>?"
                     else "Закрытие продажи на факт?"
     .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для продажи статус &2&3.', p-mode, p-status-current, p-flag-current).
  end.
end case.
end procedure.
procedure new-plus :
case p-mode:
  when '<открытие документа>':U then do:
    assign
    p-status_ = 'новый':U
    p-flag_   = no
    p-ask-message = "Разрешить добавление чеков в продажу в режиме автом. работы с продажей по расписанию"
    .
  end.
  when '<закрытие документа>':U then do:
    if p-doc-status-current = 'запрос':U then do:
       return error substitute ('Недопустима операция &1 для продажи статус &2&3.', p-mode, p-status-current, p-flag-current).
    end.
    else do:
     assign
     p-status_ = 'нередакт':U
     p-flag_   = no
     p-ask-message = "Запретить резервирование в режиме авто. работы с продажей по расписанию"
     .
    end.
  end.
  when '<закрытие документа на факт>':U then do:
     assign
     p-status_ = (if p-doc-status-current = 'запрос':U then 'запрос':U else 'факт':U)
     p-flag_   = no
     p-ask-message = if p-doc-status-current = 'запрос':U
                     then "Закрытие продажи до статуса <запрос>?"
                     else "Закрытие продажи на факт?"
     .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для продажи статус &2&3.', p-mode, p-status-current, p-flag-current).
  end.
end case.
end procedure.
procedure doc-froze :
case p-mode:
  when '<открытие документа>':U then do:
    if p-doc-status-current = 'запрос':U then do:
      return error substitute ('Недопустима операция &1 для продажи статус &2&3.', p-mode, p-status-current, p-flag-current).
    end.
    else do:
      assign
      p-status_ = 'новый':U
      p-flag_   = yes
      p-ask-message = "Разрешить резервирование в режиме автом. работы с продажей по расписанию"
      .
    end.
  end.
  when '<закрытие документа>':U then do:
     assign
     p-status_ = (if p-doc-status-current = 'запрос':U then 'запрос':U else 'факт':U)
     p-flag_   = no
     p-ask-message = if p-doc-status-current = 'запрос':U
                     then "Закрытие продажи до статуса <запрос>?"
                     else "Закрытие продажи на факт?"
     .
  end.
  when '<закрытие документа на факт>':U then do:
     assign
     p-status_ = (if p-doc-status-current = 'запрос':U then 'запрос':U else 'факт':U)
     p-flag_   = no
     p-ask-message = if p-doc-status-current = 'запрос':U
                     then "Закрытие продажи до статуса <запрос>?"
                     else "Закрытие продажи на факт?"
     .
  end.
  otherwise do:
    return error substitute ('Недопустима операция &1 для продажи статус &2&3.', p-mode, p-status-current, p-flag-current).
  end.
end case.
end procedure.
