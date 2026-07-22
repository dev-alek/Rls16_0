block-level on error undo, throw.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define input parameter parfile     as character no-undo.
define input parameter parobj-type as character no-undo.
define input parameter parobj-code as integer   no-undo.
define variable varstring as character no-undo.
define variable varcode   as integer   no-undo.
define variable varlevel  as integer   no-undo.
define variable varvolume as integer   no-undo.
define variable varprev-level  as integer   no-undo.
define variable varprev-volume as integer   no-undo.
define variable varkoeff  as decimal   no-undo.
define variable varerror  as logical initial no no-undo.
define variable varid as character no-undo.
define temp-table tt-rsrv no-undo
field code as integer
index pi is unique primary code.
define temp-table tt-tarir
field code    as   integer
field pl-code like ub.place.pl-code
field level   as   integer
field volume  as   integer
field koeff   as   decimal
index pi is unique primary code level.
define buffer bf_clients  for ub.clients.
define buffer bf_place    for ub.place.
define buffer bf_pl-level for ub.pl-level.
do on error undo, return error return-value :
if search(parfile) = ? then do:
  message "Не найден файл " parfile view-as alert-box error.
  return error.
end.
if parobj-type <> 'маг':U  and
   parobj-type <> 'скл':U then do:
  message "Указан тип объекта " parobj-type " должен быть указан склад или магазин." view-as alert-box error.
  return error.
end.
find first bf_clients where bf_clients.obj-type = parobj-type and
                            bf_clients.obj-code = parobj-code no-lock no-error.
if not available bf_clients then do:
  message "Указан неправильный объект " parobj-type " " parobj-code " ." view-as alert-box error.
  return error.
end.
define stream str-in.
input stream str-in from value(search(parfile)).
repeat :
  import stream str-in unformatted varstring.
  assign
    varcode   = integer(entry (1, varstring, chr(9)))
    varlevel  = integer(entry (2, varstring, chr(9)))
    varvolume = integer(entry (3, varstring, chr(9)))
  no-error.
  if error-status:error = no then do:
    assign
      varkoeff = ?.
    assign
      varkoeff = decimal(entry (4, varstring, chr(9))) no-error.
    find first tt-rsrv where tt-rsrv.code = varcode no-error.
    if not available tt-rsrv then do:
      create tt-rsrv.
      assign
        tt-rsrv.code = varcode.
    end.
    create tt-tarir.
    assign
      tt-tarir.code   = varcode
      tt-tarir.level  = varlevel
      tt-tarir.volume = varvolume
      tt-tarir.koeff  = varkoeff.
  end.
end.
for each tt-rsrv,
   each tt-tarir where tt-tarir.code = tt-rsrv.code break by tt-tarir.code :
  if first-of (tt-tarir.code) then do:
    if tt-tarir.level <> 0 then do:
      message "По резервуару " tt-tarir.code " первый уровень не 0." view-as alert-box error.
      assign
        varerror = yes.
    end.
  end.
  else do:
    if tt-tarir.level <> varprev-level + 1 then do:
      message "Неверно указаны тарировочные таблицы по резервуару " tt-tarir.code " уровень " tt-tarir.level " идет после уровня " varprev-level " ."
      view-as alert-box error.
      assign
        varerror = yes.
    end.
    if tt-tarir.volume <= varprev-level then do:
      message "Неверно указаны тарировочные таблицы по резервуару " tt-tarir.code " уровень " tt-tarir.level " объем " tt-tarir.volume " идет после уровня " varprev-level " с объемом " varprev-volume " ."
      view-as alert-box error.
      assign
        varerror = yes.
    end.
  end.
  assign
    varprev-level  = tt-tarir.level
    varprev-volume = tt-tarir.volume.
end.
if varerror then do:
  message "Во время загрузки тарировочных таблиц были ошибки. Таблицы не загружены." view-as alert-box error.
  return error.
end.
for each tt-rsrv on error undo, return error return-value :
  find first bf_place where bf_place.obj-type = parobj-type  and
                            bf_place.obj-code = parobj-code  and
                            bf_place.loc1     = string(tt-rsrv.code) no-lock no-error.
  if not available bf_place then do:
    message "Получены данные по резервуару с кодом " bf_place.loc1 ", но данного резервуара нет в справочнике." view-as alert-box error.
    return error.
  end.
  for each bf_pl-level where bf_pl-level.obj-type = bf_place.obj-type and
                             bf_pl-level.obj-code = bf_place.obj-code and
                             bf_pl-level.pl-code  = bf_place.pl-code  on error undo, return error return-value :
    delete bf_pl-level.
  end.
end.
for each tt-rsrv :
  find first bf_place where bf_place.obj-type = parobj-type     and
                            bf_place.obj-code = parobj-code     and
                            bf_place.loc1     = string(tt-rsrv.code) no-lock.
  for each tt-tarir where tt-tarir.code = tt-rsrv.code :
    create bf_pl-level.
    assign
      bf_pl-level.obj-type = bf_place.obj-type
      bf_pl-level.obj-code = bf_place.obj-code
      bf_pl-level.pl-code  = bf_place.pl-code
      bf_pl-level.pl-level = tt-tarir.level
      bf_pl-level.pl-qnty  = tt-tarir.volume.
  end.
end.
end.
message "Импорт завершен успешно." view-as alert-box.
