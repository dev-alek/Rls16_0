block-level on error undo, throw.
define input-output parameter p-rec                 as recid no-undo .
define input parameter        p-mode                as character no-undo .
define input parameter        p-db-num              like ub.db.db-num no-undo .
define input parameter        p-db-name             like ub.db.db-name no-undo .
define input parameter        p-add-clients         like ub.db.add-clients no-undo .
define input parameter        p-send-check          like ub.db.send-check no-undo .
define input parameter        p-add-goods           like ub.db.add-goods no-undo .
define input parameter        p-save-packs          like ub.db.save-packs no-undo .
define variable vss-revision    as character no-undo init "$Revision: 8c1a0fd433e1, 1120, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Dec 14 02:13:53 2017 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: db01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: adm/db01.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке магазина".
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
define buffer buf_db for ub.db .
do on error undo, throw:
  if lookup(p-mode, "ДОБАВЛЕНИЕ,ИЗМЕНЕНИЕ") = 0 then do:
    undo, throw new Progress.Lang.AppError(
      substitute("&1 &2 &3&4Неверный параметр p-mode. Не предусмотрена операция [&5]",
                 vss-workfile, vss-revision, vss-description, chr(10),
                 p-mode )
    ) .
  end .
  if p-db-name > "" then .
  else do:
    undo, throw new Progress.Lang.AppError(
      substitute("&1 &2 &3&4Имя БД отсутствует",
                 vss-workfile, vss-revision, vss-description, chr(10))
    ) .
  end .
  if p-save-packs < 10 then do:
    undo, throw new Progress.Lang.AppError(
      substitute("&1 &2 &3&4Минимальный период хранения пакетов 10 дней.&4Удалять пакеты через [&5] дней нельзя.",
                 vss-workfile, vss-revision, vss-description, chr(10),
                 p-save-packs )
    ) .
  end.
  case p-mode:
    when 'ДОБАВЛЕНИЕ':U then do:
      if p-db-num = ? then do:
        undo, throw new Progress.Lang.AppError(
          substitute("&1 &2 &3&4Номер БД отсутствует",
                     vss-workfile, vss-revision, vss-description, chr(10))
        ) .
      end .
      if can-find (first buf_db where buf_db.db-num = p-db-num) then do:
        undo, throw new Progress.Lang.AppError(
          substitute("&1 &2 &3&4БД с номером [&5] уже существует",
                     vss-workfile, vss-revision, vss-description, chr(10),
                     p-db-num )
        ) .
      end .
      create buf_db .
      assign
        buf_db.db-num       = p-db-num
        buf_db.db-key       = "":U
        buf_db.db-key-enc   = "":U
        buf_db.remote-stock = false
        buf_db.on-line-rest = false
        buf_db.max-p-size   = 10000
        buf_db.max-p-queue  = 10
        buf_db.max-p-time   = 0
        buf_db.unload-arch  = true
        buf_db.unload-aht   = true
      .
    end.
    when 'ИЗМЕНЕНИЕ':U then do:
      find first buf_db exclusive-lock where recid(buf_db) = p-rec no-error no-wait .
      if locked(buf_db) then do:
        undo, throw new Progress.Lang.AppError(
          substitute("&1 &2 &3&4Запись о БД с ид. [&5] занята другим пользователем",
                     vss-workfile, vss-revision, vss-description, chr(10),
                     p-rec )
        ) .
      end .
      if not available buf_db then do:
        undo, throw new Progress.Lang.AppError(
          substitute("&1 &2 &3&4Запись о БД с ид. [&5] отсутствует",
                     vss-workfile, vss-revision, vss-description, chr(10),
                     p-rec )
        ) .
      end .
    end .
    otherwise .
  end case .
  assign
    buf_db.db-name     = p-db-name
    buf_db.add-clients = p-add-clients
    buf_db.send-check  = p-send-check
    buf_db.add-goods   = p-add-goods
    buf_db.save-packs  = p-save-packs
  .
  validate buf_db .
end.
