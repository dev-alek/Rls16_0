block-level on error undo, throw.
define input parameter        p-mode as character no-undo .
define input parameter        p-silent as logical no-undo .
define input-output parameter p-rec  as recid     no-undo .
define input parameter p-wth-code as integer no-undo .
define input parameter p-par-code as integer no-undo .
define input parameter p-par-val  as integer no-undo .
define input parameter p-par-feat as character no-undo .
define input parameter p-par-rate as decimal no-undo .
define input parameter p-par-unit as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: wth-par1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/wth-par1.p $":U .
define variable vss-description as character no-undo init "Сохранение номинала МЦ".
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
define variable v-mess as character no-undo .
define buffer buf_wealth for ub.wealth.
define buffer buf_wth-par for ub.wth-par.
if p-mode <> 'ДОБАВЛЕНИЕ':U
AND p-mode <> 'ИЗМЕНЕНИЕ':U then do:
  message vss-workfile vss-revision vss-description skip
          "Неверный параметр p-mode - " p-mode
  view-as alert-box error .
  return error '':u.
end.
if g#db-num <> 0 then do:
  message vss-workfile vss-revision vss-description skip
          "Запрещено вызывать процедуру в УБД"
  view-as alert-box error .
  return error '':u.
end.
main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:
  find first buf_wealth no-lock where
          buf_wealth.wth-code = p-wth-code no-error .
  if not available buf_wealth then do:
    v-mess = substitute("Не найдена МЦ").
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'wth-code':U).
  end.
  if p-par-val = ?
  or p-par-val = 0 then do:
    v-mess = "Не определено значение номинала" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'par-val':U).
  end.
  if p-par-rate = ?
  or p-par-rate = 0 then do:
    v-mess = "Не определен коэффициент" .
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'par-rate':U).
  end.
  if (p-par-feat = "" or p-par-feat = ? )
  and buf_wealth.is-money then do:
    v-mess = substitute("Для материальных ценностей - денежных средств или имеющих денежный эквивалент&1" +
                        "необходимо указать дополнительный признак"
                        , chr(10)).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else 'par-feat':U).
  end.
  if buf_wealth.is-money = no then do:
    if p-par-unit = ? or p-par-unit = "" then do:
      v-mess = substitute("Укажите ед. изм. номинала или выберите ее из справочника единиц измерения").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'par-unit':U).
    end.
    if (p-par-rate <> p-par-val)
    AND p-par-unit = buf_wealth.unit-base
    then do:
      v-mess = substitute("Ед. изм. номинала совпадает с базовой ед.изм. МЦ, а коэффициент не равен значению номинала").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'par-unit':U).
    end.
  end.
  else do:
    if p-par-unit = ? or p-par-unit = "" then do:
      v-mess = substitute("Не задана ед. изм. номинала").
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else 'par-unit':U).
    end.
  end.
  if p-mode = 'ДОБАВЛЕНИЕ':U then do:
    create buf_wth-par.
    assign
    buf_wth-par.par-code = next-value(s-par-code, ub)
    buf_wth-par.wth-code = p-wth-code
    .
  end.
  if p-mode = 'ИЗМЕНЕНИЕ':U then do:
    find first buf_wth-par exclusive-lock where
              recid(buf_wth-par) = p-rec .
    if buf_wth-par.par-code <> p-par-code
    or buf_wth-par.wth-code <> p-wth-code then do:
      v-mess = substitute("Для уже имеющейся записи Номинала МЦ нельзя изменить код МЦ или код Номинала&1" +
                           "старый код МЦ - &2, старый код номинала &3"
                           ,chr(10)
                           , buf_wth-par.wth-code
                           , buf_wth-par.par-code).
      run err-mess in this-procedure ( input-output v-mess).
      return error (if p-silent = yes then v-mess else '':U).
    end.
  end.
  assign
  buf_wth-par.par-val = p-par-val
  buf_wth-par.par-unit = p-par-unit
  buf_wth-par.par-feat = p-par-feat
  buf_wth-par.par-rate = p-par-rate
  p-rec = recid(buf_wth-par)
  .
  release buf_wth-par no-error .
  if error-status:error then do:
    v-mess = substitute("Ошибка при сохранения записи номинала МЦ:&1&2&3"
                         , error-status:get-message(1)
                         , chr(10)
                         , return-value
                         ).
    run err-mess in this-procedure ( input-output v-mess).
    return error (if p-silent = yes then v-mess else '':U).
  end.
end.
PROCEDURE err-mess:
  DEFINE INPUT-OUTPUT PARAMETER p-mess as character No-UNDO.
  CASE p-silent:
    when yes then do:
      assign
      p-mess = substitute("Номинал МЦ: код МЦ &1 код номинала &2&3&4"
                         , p-wth-code
                         , p-par-code
                         , chr(10)
                         , p-mess)
      .
    end.
    when no then do:
      message
      p-mess
      view-as alert-box error .
    end.
  end.
END PROCEDURE.
