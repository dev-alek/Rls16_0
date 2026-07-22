block-level on error undo, throw.
define input parameter p-obj-type          like ub.wth-pobj.obj-type no-undo .
define input parameter p-obj-code          like ub.wth-pobj.obj-code no-undo .
define input parameter p-wth-code          like ub.wth-pobj.wth-code  no-undo .
define input parameter p-w-p-code          like ub.wth-pobj.w-p-code  no-undo .
define input parameter p-action            as character no-undo .
define input parameter p-no-check-doc-code as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Блокировка и разблокировка МЦ на МХ".
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
define buffer buf_wth-obj  for ub.wth-obj .
define buffer buf_wth-doc  for ub.wth-doc .
define buffer buf_wth-line for ub.wth-line .
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  if lookup( p-action
    , "assign-doc-on=true"  + ","
    + "assign-doc-on=false" + ","
    + "check-doc-on=true"   + ","
    + "check-doc-on=false" ) = 0
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Неизвестное значение p-action" skip
      "p-action" p-action skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  find first ub.wealth no-lock
    where ub.wealth.wth-code = p-wth-code
    no-error .
  if not available ub.wealth then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Код МЦ" p-wth-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run wthpobjc in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  ub.wealth.wth-code
  ,input p-w-p-code
  ,buffer ub.wth-pobj
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при поиске МЦ на МХ объекта" skip
      "obj-type"  p-obj-type skip
      "obj-code"  p-obj-code skip
      "wth-code"  p-wth-code skip
      "w-p-code"  p-w-p-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run wthobjcr in g#library
  (input  p-obj-type
  ,input  p-obj-code
  ,input  ub.wealth.wth-code
  ,buffer buf_wth-obj
  ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при поиске МЦ на объекте" skip
      "obj-type"  p-obj-type skip
      "obj-code"  p-obj-code skip
      "wth-code"  p-wth-code skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  find current buf_wth-obj exclusive-lock .
  release buf_wth-obj .
  find current ub.wth-pobj exclusive-lock .
  if ub.wth-pobj.doc-on = ? then do:
    message
      vss-workfile vss-revision vss-description skip
      "МЦ на МХ имеет неопределенный статус" skip
      "Объект" p-obj-type p-obj-code skip
      "МХ" p-w-p-code skip
      "Код МЦ" ub.wealth.wth-code skip
      "ub.wth-pobj.doc-on" ub.wth-pobj.doc-on skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  case p-action :
    when "assign-doc-on=true" then do:
      if ub.wth-pobj.doc-on = false then do:
        do
        on error undo main-block, return error
        :
          assign
            ub.wth-pobj.doc-on = true
          .
        end.
      end.
      else do:
        for each buf_wth-doc no-lock
          where buf_wth-doc.obj-type = ub.wth-pobj.obj-type
            and buf_wth-doc.obj-code = ub.wth-pobj.obj-code
            and buf_wth-doc.status_  = 'разрешен':U
        on error undo main-block, return error
        :
          for each buf_wth-line no-lock
            where buf_wth-line.doc-code = buf_wth-doc.doc-code
              and buf_wth-line.obj-type = ub.wth-pobj.obj-type
              and buf_wth-line.obj-code = ub.wth-pobj.obj-code
              and buf_wth-line.w-p-code  = ub.wth-pobj.w-p-code
              and buf_wth-line.wth-code = ub.wth-pobj.wth-code
          on error undo main-block, return error
          :
            message
              "Невозможно заблокировать МЦ на МХ" skip
              "МЦ уже является заблокированной" skip
              "Объект" p-obj-type p-obj-code skip
              "МХ" p-w-p-code skip
              "Код МЦ" ub.wealth.wth-code skip
              "Существует документ МЦ" buf_wth-doc.doc-code skip
              "Статус документа" buf_wth-doc.status_ skip
              view-as alert-box information .
            undo main-block, return error .
          end.
        end.
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно заблокировать МЦ на МХ" skip
          "МЦ уже является заблокированной" skip
          "Объект" p-obj-type p-obj-code skip
          "МХ" p-w-p-code skip
          "Код МЦ" ub.wealth.wth-code skip
          view-as alert-box error .
        undo main-block, return error .
      end.
    end.
    when "assign-doc-on=false" then do:
      if ub.wth-pobj.doc-on = true then do:
        for each buf_wth-doc no-lock
          where buf_wth-doc.obj-type = ub.wth-pobj.obj-type
            and buf_wth-doc.obj-code = ub.wth-pobj.obj-code
            and ( buf_wth-doc.status_  = 'разрешен':U
                )
            and buf_wth-doc.doc-code <> p-no-check-doc-code
        on error undo main-block, return error
        :
          for each buf_wth-line no-lock
            where buf_wth-line.doc-code = buf_wth-doc.doc-code
              and buf_wth-line.obj-type = ub.wth-pobj.obj-type
              and buf_wth-line.obj-code = ub.wth-pobj.obj-code
              and buf_wth-line.w-p-code  = ub.wth-pobj.w-p-code
              and buf_wth-line.wth-code = ub.wth-pobj.wth-code
          on error undo main-block, return error
          :
            message
              vss-workfile vss-revision vss-description skip
              "Невозможно снять блокировку на МЦ на МХ" skip
              "Объект" p-obj-type p-obj-code skip
              "МХ" p-w-p-code skip
              "Код МЦ" ub.wealth.wth-code skip
              "Существует документ МЦ" buf_wth-doc.doc-code skip
              "Статус документа" buf_wth-doc.status_ skip
              view-as alert-box information .
            undo main-block, return error .
          end.
        end.
        do
        on error undo main-block, return error
        :
          assign
            ub.wth-pobj.doc-on = false
          .
        end.
      end.
      else do:
        message
          vss-workfile vss-revision vss-description skip
          "Невозможно разблокировать МЦ на МХ" skip
          "МЦ не является заблокированной" skip
          "Объект" p-obj-type p-obj-code skip
          "МХ" p-w-p-code skip
          "Код МЦ" ub.wealth.wth-code skip
          view-as alert-box error .
        undo main-block, return error .
      end.
    end.
    when "check-doc-on=true" then do:
      if ub.wth-pobj.doc-on <> true then do:
        message
          vss-workfile vss-revision vss-description skip
          "МЦ на МХ не является заблокированной" skip
          "Объект" p-obj-type p-obj-code skip
          "Место хранения" p-w-p-code skip
          "Код МЦ" ub.wealth.wth-code skip
          view-as alert-box information .
        undo main-block, return error .
      end.
    end.
    when "check-doc-on=false" then do:
      if ub.wth-pobj.doc-on <> false then do:
        message
          vss-workfile vss-revision vss-description skip
          "МЦ на МХ является заблокированной" skip
          "Объект" p-obj-type p-obj-code skip
          "МХ" p-w-p-code skip
          "Код МЦ" ub.wealth.wth-code skip
          view-as alert-box information .
        undo main-block, return error .
      end.
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Внутрення ошибка" skip
        "Неизвестное значение p-action" skip
        "p-action" p-action skip
        view-as alert-box error .
      undo main-block, return error .
    end.
  end case .
end.
