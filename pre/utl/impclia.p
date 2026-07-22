block-level on error undo, throw.
define input  parameter parparentproc   as handle     no-undo .
define input  parameter p-filename      as character  no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: impclia.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/impclia.p $":U .
define variable vss-description as character no-undo init "Импорт артикулов поставщиков из файла".
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
define stream sinp .
define stream slog.
define buffer buf_ext-artic for ub.ext-artic.
define buffer buf_goods     for ub.goods.
define buffer buf_clients   for ub.clients.
define variable v-cli-type  like ub.cli-gds.cli-type   no-undo .
define variable v-cli-code  like ub.cli-gds.cli-code   no-undo .
define variable v-host-code like ub.cli-gds.host-code  no-undo .
define variable v-article   like ub.cli-gds.artic      no-undo .
define variable v-prod-type like ub.cli-gds.prod-type  no-undo .
define variable v-prod-code like ub.cli-gds.prod-code  no-undo .
define variable v-cli-art   like ub.cli-gds.cli-art    no-undo .
define variable vv-unit-cli           like ub.ext-artic.unit-cli           no-undo .
define variable vv-cli-base-rate      like ub.ext-artic.cli-base-rate      no-undo .
define variable vv-unit-cli-ord       like ub.ext-artic.unit-cli-ord       no-undo .
define variable vv-cli-base-rate-ord  like ub.ext-artic.cli-base-rate-ord  no-undo .
define variable vv-unit-cli-rcv       like ub.ext-artic.unit-cli-rcv       no-undo .
define variable vv-cli-base-rate-rcv  like ub.ext-artic.cli-base-rate-rcv  no-undo .
define variable v-log           as logical   no-undo .
define variable v-full-filename as character no-undo .
define variable v-i             as integer   no-undo .
define variable v-str           as character no-undo .
define variable v-num-entries   as integer   no-undo .
define variable v-cli-str       as character no-undo .
define variable v-mode          as character no-undo .
define variable v-err-cnt       as integer   no-undo .
define frame imp-frame
  v-i                 format ">>>>>>>>9"  label "Прочитано записей" skip
  v-cli-str           format "X(13)"      label "Поставщик"         skip
  v-cli-art           format "X(14)"      label "Артикул"
  with view-as dialog-box side-labels three-d
  title "Импорт артикулов поставщиков из файла"
  .
do
on error undo, return error return-value
:
  message
    "Импортировать из текстового файла артикулы поставщика ? "
  view-as alert-box question buttons yes-no UPDATE v-log.
  if not v-log
  then do:
    return .
  end.
  assign
    v-full-filename = search( p-filename )
  .
  if v-full-filename = ?
  then do:
    message
      "Не найден файл " p-filename
    view-as alert-box error.
    return .
  end.
  input stream sinp from value (p-filename) convert source "1251".
  _read:
  repeat transaction
    on error undo _read, return error return-value
  :
    import stream sinp unformatted v-str.
    assign
      v-str = trim(v-str)
    .
    if v-str <> ""
    then do:
      assign
        v-i           = v-i + 1
        v-num-entries = num-entries( v-str , ";":U )
      .
      if v-num-entries = 7
      then do:
        assign
          v-cli-type  = entry( 1 , v-str , ";":U )
          v-cli-code  = integer( entry( 2 , v-str , ";":U ) )
          v-host-code = integer( entry( 3 , v-str , ";":U ) )
          v-article   = entry( 4 , v-str , ";":U )
          v-prod-type = entry( 5 , v-str , ";":U )
          v-prod-code = integer( entry( 6 , v-str , ";":U ) )
          v-cli-art   = entry( 7 , v-str , ";":U )
        no-error .
        find first buf_goods no-lock
          where buf_goods.artic     = v-article
            and buf_goods.prod-type = v-prod-type
            and buf_goods.prod-code = v-prod-code
        no-error .
        find first buf_clients no-lock
          where buf_clients.obj-type  = v-cli-type
            and buf_clients.obj-code  = v-cli-code
        no-error .
        if  available buf_goods and
            available buf_clients
            then do:
          find first buf_ext-artic no-lock
            where buf_ext-artic.cli-type  = v-cli-type
              and buf_ext-artic.cli-code  = v-cli-code
              and buf_ext-artic.gds-code  = buf_goods.gds-code
          no-error .
          if available buf_ext-artic
          then do:
              assign
              v-mode = 'ИЗМЕНЕНИЕ':U
              .
            end.
          else do:
            assign
              v-mode = 'ДОБАВЛЕНИЕ':U
            .
          end.
          run ref/extarts.p ( input v-mode
                      , input v-cli-type
                      , input v-cli-code
                      , input buf_goods.gds-code
                      , input v-cli-art
                      , input "":U
                      , input vv-unit-cli
                      , input vv-cli-base-rate
                      , input vv-unit-cli-ord
                      , input vv-cli-base-rate-ord
                      , input vv-unit-cli-rcv
                      , input vv-cli-base-rate-rcv
                     ) no-error .
          if error-status :error
          then do:
            run write-log in this-procedure ( input substitute( "&1 &2 &3"
                                                              , trim(return-value)
                                                              , trim(error-status :get-message(1))
                                                              , trim(error-status :get-message(2))
                                                              )
                                            ).
            assign
              v-err-cnt = v-err-cnt + 1
            .
          end.
          assign
            v-cli-str = string(v-cli-code, "999999999")  +  " "  +  trim(v-cli-type)
          .
          display
            v-i
            v-cli-str
            v-cli-art
          with frame imp-frame.
          pause 0.
        end.
      end.
    end.
  end.
  input stream sinp close.
  if v-err-cnt > 0 then do:
    message
      substitute( "Ошибок при импорте: &1.&2Лог имопрта: &3"
                , v-err-cnt
                , chr(10)
                , "impclia.log":U
                )
    view-as alert-box information.
  end.
  message
    "Импорт завершен."
  view-as alert-box information.
end.
procedure write-log :
  define input parameter p-log-message as character no-undo.
do
on error undo, return error return-value
:
  output stream slog to value("impclia.log":U) append.
  put stream slog unformatted
    today chr(9)
    string(time, "hh:mm:ss") chr(9)
    p-log-message
    chr(10)
  .
  output stream slog close.
end.
end procedure.
