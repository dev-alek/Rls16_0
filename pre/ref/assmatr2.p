block-level on error undo, throw.
define input parameter p-recid as recid no-undo.
define input-output parameter p-asmt-status like ub.assortment-matrix.asmt-status no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: assmatr2.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/assmatr2.p $":U .
define variable vss-description as character no-undo init "Изменение статуса ассортиментной матрицы".
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
DEFINE VARIABLE loc#log as logical no-undo .
DEFINE BUFFER bf-assortment-matrix for ub.assortment-matrix.
DEFINE VARIABLE choice as logical no-undo .
DEFINE VARIABLE v-old-asmt-status like ub.assortment-matrix.asmt-status no-undo .
define variable v-db-num as integer   no-undo .
_main:
do
on error undo, return error
:
define buffer old_assortment-matrix for ub.assortment-matrix  .
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
if (valid-handle(g#library) <> true) then do:   run gbl/library.p persistent no-error .   if error-status :error or (valid-handle(g#library) <> true) then do:     message       "Error starting library.p" skip       g#library skip       g#library :type skip       g#library :file-name skip       error-status :get-message(1) skip       return-value skip       view-as alert-box error .     stop .   end. end. run curdbnum in g#library
  (output v-db-num
  )  .
FIND FIRST bf-assortment-matrix WHERE
           recid(bf-assortment-matrix) = p-recid.
    define buffer x_curr_clients for ub.clients.
      find first  x_curr_clients no-lock where
                x_curr_clients.obj-type = bf-assortment-matrix.obj-type and
                x_curr_clients.obj-code = bf-assortment-matrix.obj-code no-error.
      if available x_curr_clients then do:
          if v-db-num > 0 then do:
            if x_curr_clients.db-num <>  v-db-num then do:
                message
                "На УБД нельзя добавлять/корректировать Ассортиментные матрици по Объектам других БД" skip
                    x_curr_clients.obj-type x_curr_clients.obj-code skip
                    "БД : " x_curr_clients.db-num
                    view-as alert-box error.
                undo, return error .
            end.
          end.
      end.
v-old-asmt-status = bf-assortment-matrix.asmt-status.
if p-asmt-status = ? then do:
  CASE v-old-asmt-status:
    when integer('0':U) then do:
      assign
      p-asmt-status = integer('1':U).
    end.
    when integer('1':U) then do:
      if bf-assortment-matrix.obj-type <> "" then do:
          find first old_assortment-matrix no-lock where
                      old_assortment-matrix.asmt-status = integer('0':U) and
                      old_assortment-matrix.obj-type    = bf-assortment-matrix.obj-type and
                      old_assortment-matrix.obj-code    = bf-assortment-matrix.obj-code and
                     not ( old_assortment-matrix.asmt-id   = bf-assortment-matrix.asmt-id and
                           old_assortment-matrix.db-num     = bf-assortment-matrix.db-num ) no-error .
          if not available old_assortment-matrix then
          assign
          p-asmt-status = integer('0':U).
          else do:
              message "Уже есть матрица в статусе ТЕКУЩИЙ по объекту !"
              bf-assortment-matrix.obj-type
              bf-assortment-matrix.obj-code
              view-as alert-box ERROR.
              p-asmt-status = ?.
              return error.
          end.
      end.
      else do:
          assign
          p-asmt-status = integer('0':U).
      end.
    end.
  END CASE.
end.
CASE p-asmt-status:
  WHEN integer('0':U) then do:
    if integer('0':U) = bf-assortment-matrix.asmt-status  then do:
      message "Запись уже имеет статус ТЕКУЩИЙ!"
      view-as alert-box ERROR.
      p-asmt-status = ?.
      return error.
    end.
    else do:
      if v-db-num <> 0 then do:
          message
          "Восстановить матрицу можно только в ГБД"
          view-as alert-box information .
          choice = false .
      end.
      else do:
        message
        "Матрица уже удалена - восстановить?"
        view-as alert-box QUestion buttons YEs-no update choice.
      end.
    end.
  end.
  WHEN integer('1':U) then do:
    if integer('1':U) = bf-assortment-matrix.asmt-status  then do:
      message "Запись уже имеет статус УДАЛЕН!"
      view-as alert-box ERROR.
      p-asmt-status = ?.
      return error.
    end.
    else do:
      message
      "Удалить Ассортиментную матрицу?"
      view-as alert-box QUestion buttons yes-no update choice.
    end.
  end.
END CASE.
if choice = false  then do:
   release bf-assortment-matrix no-error .
   return .
end.
if choice then
assign
bf-assortment-matrix.asmt-status = p-asmt-status.
release bf-assortment-matrix no-error .
if error-status:error then do:
  message
  "Ошибка при сохранении записи Ассортиментной Матрицы" skip
  error-status:get-message(1) skip
  return-value
  view-as alert-box error .
  undo _main, return error .
end.
define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer buf_gds-obj-prop for ub.gds-obj-prop  .
FIND FIRST bf-assortment-matrix no-lock WHERE
          recid(bf-assortment-matrix) = p-recid.
if p-asmt-status = integer('1':U) and
   bf-assortment-matrix.asmt-type = 'Объект':U then do:
   choice = false .
   message
   "Изменить ИЖТ всех товаров удаленной Ассортиментной матрицы на ПУСТО ?"
   view-as alert-box QUestion buttons yes-no update choice.
   if choice then do:
      FIND FIRST bf-assortment-matrix exclusive-lock WHERE
                recid(bf-assortment-matrix) = p-recid.
      for each buf_assortment-matrix-goods exclusive-lock where
               buf_assortment-matrix-goods.asmt-id = bf-assortment-matrix.asmt-id and
               buf_assortment-matrix-goods.db-num  = bf-assortment-matrix.db-num
               :
               for each buf_gds-obj-prop exclusive-lock where
                        buf_gds-obj-prop.gds-code = buf_assortment-matrix-goods.gds-code and
                        buf_gds-obj-prop.obj-type = bf-assortment-matrix.obj-type and
                        buf_gds-obj-prop.obj-code = bf-assortment-matrix.obj-code :
                        buf_gds-obj-prop.gdop-igt = 'Пусто':U .
               end.
      end.
   end.
end.
p-asmt-status = ?.
end.
