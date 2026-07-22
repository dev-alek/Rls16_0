block-level on error undo, throw.
define input parameter p-doc-code as char no-undo.
define input parameter p-file-name-err as char no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: chkwthd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/chkwthd.p $":U .
define variable vss-description as character no-undo init "Проверка партий при удалении документов МЦ".
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
    assign
      p-vss-parameters = p-doc-code
    .
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
define variable v-flag-doc-err  as logical      no-undo.
define variable v-line-count    as integer      no-undo.
define buffer del_wth-parts   for wth-parts.
define buffer del_wth-doc     for wth-doc.
define buffer buf_wth-parts   for wth-parts.
define stream str-err .
mainBlock :
do on error undo, return error
:
  find first del_wth-doc where del_wth-doc.doc-code = p-doc-code
  exclusive-lock no-error.
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error return-value .
  end.
    assign
    v-flag-doc-err = no
  .
  if not g#news and search(p-file-name-err) <> ?
  then do:
    os-delete value(p-file-name-err).
  end.
  assign
    v-line-count = 0
  .
  for each buf_wth-parts where buf_wth-parts.doc-code = p-doc-code
  no-lock
  :
    if buf_wth-parts.out-code = p-doc-code then next.
    if lookup(buf_wth-parts.out-code,'free-zone,out-zone,cli-zone,фальшивый,put-zone':u) = 0 then do:
    v-flag-doc-err = yes.
      if not g#news
      then do:
        output stream str-err to value(p-file-name-err) append .
        put stream str-err unformatted
          substitute("Найден документ, в котором фигурируют партии удаляемого документа.chr(10)Код МЦ &1chr(10)Код серии &2chr(10)Номер документа &3chr(10)Диапазон &4 - &5 "
                    ,buf_wth-parts.wth-code
                    ,buf_wth-parts.ser-code
                    ,buf_wth-parts.out-code
                    ,buf_wth-parts.fact-rangeFrom
                    ,buf_wth-parts.fact-rangeTo
                    ,chr(10)
                    ) skip .
        output stream str-err close.
      end.
      else do:
        undo mainBlock, return error substitute("Найден документ, в котором фигурируют партии удаляемого документа.chr(10)Код МЦ &1chr(10)Код серии &2chr(10)Номер документа &3chr(10)Диапазон &4 - &5 "
                    ,buf_wth-parts.wth-code
                    ,buf_wth-parts.ser-code
                    ,buf_wth-parts.out-code
                    ,buf_wth-parts.fact-rangeFrom
                    ,buf_wth-parts.fact-rangeTo
                    ,chr(10)
                    ) .
      end.
    end.
  end.
  if v-flag-doc-err then return error 'Ошибка при удалении документа'.
end.
