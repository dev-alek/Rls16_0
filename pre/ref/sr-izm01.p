block-level on error undo, throw.
define input parameter p-node-code                   as integer   no-undo .
define input parameter p-sr-type-izm                 as integer   no-undo .
define input parameter p-sr-model                    as character no-undo .
define input parameter p-sr-level                    as integer   no-undo .
define input parameter p-sr-temperature              as integer   no-undo .
define input parameter p-sr-density                  as integer   no-undo .
define input parameter p-sr-Weight                   as integer   no-undo .
define input parameter p-sr-type-level-measuring     as integer   no-undo .
define input parameter p-sr-type-id                  as integer   no-undo .
define input parameter p-sr-abs-err-neft-water       as decimal   no-undo .
define input parameter p-sr-relative-err-neft-water  as decimal   no-undo .
define input parameter p-sr-abs-err-water            as decimal   no-undo .
define input parameter p-sr-relative-err-water       as decimal   no-undo .
define input parameter p-sr-abs-err-dens             as decimal   no-undo .
define input parameter p-sr-abs-err-temp-vol         as decimal   no-undo .
define input parameter p-sr-abs-err-temp-dens        as decimal   no-undo .
define input parameter p-sr-relative-err-dens        as decimal   no-undo .
define input parameter p-sr-abs-err-dens-lgas-liquid as decimal   no-undo .
define input parameter p-sr-relative-err-dens-lgas-liquid as decimal   no-undo .
define input parameter p-sr-abs-err-dens-lgas-vapor  as decimal   no-undo .
define input parameter p-sr-otnos                    as decimal   no-undo .
define input parameter p-sr-temp-line                as decimal   no-undo .
define input parameter p-sr-not-used                 as integer   no-undo .
define variable vss-revision    as character no-undo init "$Revision: c93c7157b47d, 2925, rls $":U .
define variable vss-author      as character no-undo init "$Author: VRukavishnikov $":U .
define variable vss-date        as character no-undo init "$Date: ѕн но€ 22 19:49:14 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sr-izm01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/sr-izm01.p $":U .
define variable vss-description as character no-undo init "—охранение изменений в карточке средства измерени€ (прибора)".
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
define buffer buf_sr-izmerenia for ub.sr-izmerenia .
  if p-sr-model > "" then .
  else do:
    undo, throw new Progress.Lang.AppError(
      substitute("&1 &2 &3&4ѕожалуйста заполните наименование модели средства измерени€",
                 vss-workfile, vss-revision, vss-description, chr(10))
    ) .
  end .
  if can-find (first buf_sr-izmerenia
  where buf_sr-izmerenia.sr-model                    = p-sr-model
    AND buf_sr-izmerenia.sr-level                    = (p-sr-level > 0)
    AND buf_sr-izmerenia.sr-temperature              = (p-sr-temperature > 0)
    AND buf_sr-izmerenia.sr-density                  = (p-sr-density > 0)
    AND buf_sr-izmerenia.sr-Weight                   = (p-sr-Weight > 0)
    AND buf_sr-izmerenia.sr-type-id                  = p-sr-type-id
    AND buf_sr-izmerenia.sr-abs-err-neft-water       = p-sr-abs-err-neft-water
    AND buf_sr-izmerenia.sr-abs-err-water            = p-sr-abs-err-water
    AND buf_sr-izmerenia.sr-abs-err-dens             = p-sr-abs-err-dens
    AND buf_sr-izmerenia.sr-abs-err-temp-vol         = p-sr-abs-err-temp-vol
    AND buf_sr-izmerenia.sr-abs-err-temp-dens        = p-sr-abs-err-temp-dens
    AND buf_sr-izmerenia.sr-otnos                    = p-sr-otnos
    AND buf_sr-izmerenia.sr-temp-line                = p-sr-temp-line
    AND buf_sr-izmerenia.sr-type-izm                 = p-sr-type-izm
    AND buf_sr-izmerenia.sr-type-level-measuring     = p-sr-type-level-measuring
    AND buf_sr-izmerenia.sr-relative-err-neft-water  = p-sr-relative-err-neft-water
    AND buf_sr-izmerenia.sr-relative-err-water       = p-sr-relative-err-water
    AND buf_sr-izmerenia.sr-relative-err-dens        = p-sr-relative-err-dens
    AND buf_sr-izmerenia.sr-abs-err-dens-lgas-liquid = p-sr-abs-err-dens-lgas-liquid
    AND buf_sr-izmerenia.sr-relative-err-dens-lgas-liquid = p-sr-relative-err-dens-lgas-liquid
    AND buf_sr-izmerenia.sr-abs-err-dens-lgas-vapor       = p-sr-abs-err-dens-lgas-vapor
    AND buf_sr-izmerenia.node-code                       <> p-node-code
  ) then do:
    undo, throw new Progress.Lang.AppError(
      substitute("&1 &2 &3&4”же существует запись с совпадающими характеристиками, код которой отличаетс€ от [&5]",
                 vss-workfile, vss-revision, vss-description, chr(10),
                 p-node-code)
    ) .
  end .
  find first buf_sr-izmerenia exclusive-lock
       where buf_sr-izmerenia.node-code = p-node-code no-error no-wait .
  if locked(buf_sr-izmerenia) then do:
    undo, throw new Progress.Lang.AppError(
      substitute("&1 &2 &3&4«апись о средстве измерени€ с ид. [&5] зан€та другим пользователем",
                 vss-workfile, vss-revision, vss-description, chr(10),
                 p-node-code )
      ) .
  end .
  if available buf_sr-izmerenia then do:
  end .
  else do :
    create buf_sr-izmerenia .
    assign
      buf_sr-izmerenia.node-code = p-node-code
    .
  end .
  assign
    buf_sr-izmerenia.sr-model                    = p-sr-model
    buf_sr-izmerenia.sr-level                    = (p-sr-level > 0)
    buf_sr-izmerenia.sr-temperature              = (p-sr-temperature > 0)
    buf_sr-izmerenia.sr-density                  = (p-sr-density > 0)
    buf_sr-izmerenia.sr-Weight                   = (p-sr-Weight > 0)
    buf_sr-izmerenia.sr-type-id                  = p-sr-type-id
    buf_sr-izmerenia.sr-abs-err-neft-water       = p-sr-abs-err-neft-water
    buf_sr-izmerenia.sr-abs-err-water            = p-sr-abs-err-water
    buf_sr-izmerenia.sr-abs-err-dens             = p-sr-abs-err-dens
    buf_sr-izmerenia.sr-abs-err-temp-vol         = p-sr-abs-err-temp-vol
    buf_sr-izmerenia.sr-abs-err-temp-dens        = p-sr-abs-err-temp-dens
    buf_sr-izmerenia.sr-otnos                    = p-sr-otnos
    buf_sr-izmerenia.sr-temp-line                = p-sr-temp-line
    buf_sr-izmerenia.sr-type-izm                 = p-sr-type-izm
    buf_sr-izmerenia.sr-type-level-measuring     = p-sr-type-level-measuring
    buf_sr-izmerenia.sr-relative-err-neft-water  = p-sr-relative-err-neft-water
    buf_sr-izmerenia.sr-relative-err-water       = p-sr-relative-err-water
    buf_sr-izmerenia.sr-relative-err-dens        = p-sr-relative-err-dens
    buf_sr-izmerenia.sr-abs-err-dens-lgas-liquid = p-sr-abs-err-dens-lgas-liquid
    buf_sr-izmerenia.sr-relative-err-dens-lgas-liquid = p-sr-relative-err-dens-lgas-liquid
    buf_sr-izmerenia.sr-abs-err-dens-lgas-vapor  = p-sr-abs-err-dens-lgas-vapor
    buf_sr-izmerenia.sr-not-used                 = (p-sr-not-used > 0)
  .
  validate buf_sr-izmerenia .
