block-level on error undo, throw.
define input  parameter p-mode               as character                         no-undo .
define input  parameter p-cli-type           like ub.ext-artic.cli-type           no-undo .
define input  parameter p-cli-code           like ub.ext-artic.cli-code           no-undo .
define input  parameter p-gds-code           like ub.goods.gds-code               no-undo .
define input  parameter p-ext-artic          like ub.ext-artic.ext-artic          no-undo .
define input  parameter p-ps                 like ub.ext-artic.ps                 no-undo .
define input  parameter p-unit-cli           like ub.ext-artic.unit-cli           no-undo .
define input  parameter p-cli-base-rate      like ub.ext-artic.cli-base-rate      no-undo .
define input  parameter p-unit-cli-ord       like ub.ext-artic.unit-cli-ord       no-undo .
define input  parameter p-cli-base-rate-ord  like ub.ext-artic.cli-base-rate-ord  no-undo .
define input  parameter p-unit-cli-rcv       like ub.ext-artic.unit-cli-rcv       no-undo .
define input  parameter p-cli-base-rate-rcv  like ub.ext-artic.cli-base-rate-rcv  no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extarts.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/extarts.p $":U .
define variable vss-description as character no-undo init "Сохранение внешнего артикула".
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
define buffer buf_ext-artic for ub.ext-artic.
define buffer ex_ext-artic  for ub.ext-artic.
define buffer buf_goods     for ub.goods.
define buffer ex_goods      for ub.goods.
define buffer buf_clients   for ub.clients.
do on error undo, return error return-value :
  find first buf_clients no-lock
    where buf_clients.obj-type = p-cli-type
      and buf_clients.obj-code = p-cli-code
  no-error .
  if not available buf_clients then do :
    return error substitute( "Не найден контрагент&1cli-type=&2, cli-code=&3"
                           , chr(10)
                           , p-cli-type
                           , p-cli-code
                           ).
  end.
  find first buf_goods no-lock
    where buf_goods.gds-code = p-gds-code
  no-error .
  if not available buf_goods then do :
    return error substitute ( "Не найден товар с кодом &1 " , p-gds-code ).
  end.
  find first ex_ext-artic no-lock
    where ex_ext-artic.cli-type   = p-cli-type
      and ex_ext-artic.cli-code   = p-cli-code
      and ex_ext-artic.gds-code  <> p-gds-code
      and ex_ext-artic.ext-artic  = p-ext-artic
      and ex_ext-artic.status_    = 'тек':U
  no-error .
  if available ex_ext-artic then do :
    find first ex_goods no-lock
      where ex_goods.gds-code = ex_ext-artic.gds-code
    no-error .
    return error substitute( "У '&1 &2' уже есть товар &3 с внешним артикулом &4"
                           , p-cli-type
                           , p-cli-code
                           , if available ex_goods then substitute( "'&1 &2'" , ex_goods.artic , ex_goods.gds-name ) else ''
                           , p-ext-artic
                           ).
  end.
  case p-mode :
    when 'ДОБАВЛЕНИЕ':U then do:
      find first ex_ext-artic no-lock
        where ex_ext-artic.cli-type = p-cli-type
          and ex_ext-artic.cli-code = p-cli-code
          and ex_ext-artic.gds-code = p-gds-code
      no-error .
      if not available ex_ext-artic then do :
        create buf_ext-artic.
      end.
      else do :
        if ex_ext-artic.status_ = 'тек':U then do:
          return error substitute ( "Ошибка при добавлении внешнего артикула к товару '&1 &2'&3Для данного товара уже есть внешний артикул поставщика &4 &5."
                                  , buf_goods.artic
                                  , buf_goods.gds-name
                                  , chr(10)
                                  , ex_ext-artic.cli-type
                                  , ex_ext-artic.cli-code
                                  ).
        end.
        else do :
          find first buf_ext-artic exclusive-lock
            where recid(buf_ext-artic) = recid(ex_ext-artic)
          no-wait no-error .
          if locked buf_ext-artic then do:
            return error substitute("Запись заблокирована, редактирование невозможно.").
          end.
        end.
      end.
    end.
    when 'ИЗМЕНЕНИЕ':U then do:
      find first buf_ext-artic exclusive-lock
        where buf_ext-artic.cli-type = p-cli-type
          and buf_ext-artic.cli-code = p-cli-code
          and buf_ext-artic.gds-code = p-gds-code
      no-wait no-error .
      if not available buf_ext-artic then do:
        if locked buf_ext-artic then do:
          return error substitute("Запись заблокирована, редактирование невозможно.").
        end.
        else do:
          return error substitute( "Не найдена запись для редактирования с ключом '&1:&2:&3'"
                                 , p-cli-type
                                 , p-cli-code
                                 , p-gds-code
                                 ) .
        end.
      end.
    end.
  end case.
  assign
    buf_ext-artic.cli-type  = p-cli-type
    buf_ext-artic.cli-code  = p-cli-code
    buf_ext-artic.gds-code  = p-gds-code
    buf_ext-artic.ext-artic = p-ext-artic
    buf_ext-artic.ps        = p-ps
    buf_ext-artic.unit-cli           = p-unit-cli
    buf_ext-artic.cli-base-rate      = p-cli-base-rate
    buf_ext-artic.unit-cli-ord       = p-unit-cli-ord
    buf_ext-artic.cli-base-rate-ord  = p-cli-base-rate-ord
    buf_ext-artic.unit-cli-rcv       = p-unit-cli-rcv
    buf_ext-artic.cli-base-rate-rcv  = p-cli-base-rate-rcv
  .
  if p-mode = 'ДОБАВЛЕНИЕ':U then do :
    assign
      buf_ext-artic.status_ = 'тек':U
    .
  end.
end.
