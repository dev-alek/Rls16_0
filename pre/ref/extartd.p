block-level on error undo, throw.
define input  parameter p-cli-type like ub.ext-artic.cli-type no-undo .
define input  parameter p-cli-code like ub.ext-artic.cli-code no-undo .
define input  parameter p-gds-code like ub.ext-artic.gds-code no-undo .
define input  parameter p-status_  like ub.ext-artic.status_  no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: extartd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/extartd.p $":U .
define variable vss-description as character no-undo init "Изменение статуса внешнего артикула".
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
define buffer buf_ext-artic       for ub.ext-artic.
define buffer ex_ext-artic        for ub.ext-artic.
define buffer buf_goods           for ub.goods.
define buffer buf_ext-artic-attr  for ub.ext-artic-attr.
do on error undo, return error return-value :
  if     p-status_ <> 'тек':U
    and  p-status_ <> 'удал':U then do:
    return error "Неверное значение параметра p-status_".
  end.
  find first buf_ext-artic exclusive-lock
    where buf_ext-artic.cli-type = p-cli-type
      and buf_ext-artic.cli-code = p-cli-code
      and buf_ext-artic.gds-code = p-gds-code
  no-wait no-error .
  if not available buf_ext-artic then do:
    if locked buf_ext-artic then do:
      return error "Запись заблокирована".
    end.
    else do:
      return error "Запись не найдена".
    end.
  end.
  if p-status_ = 'тек':U then do:
    find first ex_ext-artic no-lock
      where ex_ext-artic.cli-type  = p-cli-type
        and ex_ext-artic.cli-code  = p-cli-code
        and ex_ext-artic.gds-code <> p-gds-code
        and ex_ext-artic.ext-artic = buf_ext-artic.ext-artic
        and ex_ext-artic.status_   = 'тек':U
    use-index ea-stts
    no-error .
    if available ex_ext-artic then do :
      find first buf_goods no-lock
        where buf_goods.gds-code = ex_ext-artic.gds-code
      no-error .
      return error substitute( "У '&1 &2' уже есть товар &3 с внешним артикулом &4"
                            , p-cli-type
                            , p-cli-code
                            , if available buf_goods then substitute( "'&1 &2'" , buf_goods.artic , buf_goods.gds-name ) else ''
                            , buf_ext-artic.ext-artic
                            ).
    end.
  end.
  if p-status_ = 'удал':U then do :
    for each buf_ext-artic-attr exclusive-lock
          where buf_ext-artic-attr.cli-type = buf_ext-artic.cli-type
            and buf_ext-artic-attr.cli-code = buf_ext-artic.cli-code
            and buf_ext-artic-attr.gds-code = buf_ext-artic.gds-code
    :
      delete buf_ext-artic-attr.
    end.
  end.
  assign
    buf_ext-artic.status_ = p-status_
  .
end.
