block-level on error undo, throw.
class Ibs.Th.Rul.route-data_
   inherits   ibs.th.gbl.sys.objth:
    define override public property vss-revision    as character no-undo init "$Revision:$":U get .
    define override public property vss-author      as character no-undo init "$Author:$":U get.
    define override public property vss-date        as character no-undo init "$Date:$":U get.
    define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
    define override public property vss-archive     as character no-undo init "$Archive:$":U get.
    define override public property vss-description as character no-undo init "Класс  Данные для экспорта/импорта" get.
    define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile: route-data_.cls $ $Revision: 84dd6171ad45, 3327, rls $".
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable tempcxml_v-num_ as integer no-undo .
define  temp-table temp-xml-tables no-undo
field order as integer
field tbl-name as character
field tbl-handle_ as handle
field table-handle_ as handle
field uniq-gate-rec as character
field gate-name as character
field gate-handle_ as handle
field is-parent as logical
index pi is unique primary
uniq-gate-rec
tbl-name
index iorder
order
index gr
uniq-gate-rec
index gh
gate-handle_
index iparent
is-parent
.
define  temp-table temp-xml-records no-undo
field tbl-name as character
field uniq-key-rec as character
index pi is unique primary
tbl-name
uniq-key-rec
.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define temp-table temp-rel-handle no-undo
field dh as handle
field ii as integer
field active_ as logical
field child-buffer_ as character
field parent-buffer_ as character
field child-buffer-handle as handle
field parent-buffer-handle as handle
field name_ as character
field nested_ as logical
field relation-fields_ as character
field reposition_ as logical
field type_ as character
field query_ as handle
field where-string_ as character
field tbl-handle_ as handle
index pi is unique primary
ii
index iparentname parent-buffer_ child-buffer_
index iparenthandle parent-buffer-handle child-buffer-handle
.
method public void tmpreldf_get-relations ( input p-dataseth as handle ):
define variable v-ii as integer no-undo .
define buffer buf_temp-rel-handle for temp-rel-handle.
do
on error undo, return error
:
  if not valid-handle(p-dataseth)
  or p-dataseth:type <> "DATASET"
  then do:
    return error substitute("Не определен dataset с handle &1", p-dataseth).
  end.
  for each buf_temp-rel-handle where
          buf_temp-rel-handle.dh = p-dataseth:
    delete buf_temp-rel-handle.
  end.
  do v-ii = 1 to p-dataseth:num-relations:
    create buf_temp-rel-handle.
    assign
    buf_temp-rel-handle.ii = v-ii
    buf_temp-rel-handle.dh = p-dataseth
    buf_temp-rel-handle.active_ = p-dataseth:get-relation(v-ii):active
    buf_temp-rel-handle.child-buffer_ = p-dataseth:get-relation(v-ii):child-buffer:name
    buf_temp-rel-handle.parent-buffer_ = p-dataseth:get-relation(v-ii):parent-buffer:name
    buf_temp-rel-handle.child-buffer-handle = p-dataseth:get-relation(v-ii):child-buffer
    buf_temp-rel-handle.tbl-handle_ = buf_temp-rel-handle.child-buffer-handle
    buf_temp-rel-handle.parent-buffer-handle = p-dataseth:get-relation(v-ii):parent-buffer
    buf_temp-rel-handle.name_ = p-dataseth:get-relation(v-ii):name
    buf_temp-rel-handle.nested_ = p-dataseth:get-relation(v-ii):nested
    buf_temp-rel-handle.relation-fields_ = p-dataseth:get-relation(v-ii):relation-fields
    buf_temp-rel-handle.reposition_ = p-dataseth:get-relation(v-ii):reposition
    buf_temp-rel-handle.type_ = p-dataseth:get-relation(v-ii):type
    buf_temp-rel-handle.query_ = p-dataseth:get-relation(v-ii):query
    buf_temp-rel-handle.where-string_ = p-dataseth:get-relation(v-ii):where-string
    .
  end.
end.
end method.
method public void tmpreldf_set-relations ( input p-srcdataseth as handle
                                          , input p-trgdataseth as handle ):
define variable gh as handle no-undo .
define buffer buf_temp-rel-handle for temp-rel-handle.
do
on error undo, return error
:
  if not valid-handle(p-srcdataseth)
  or p-srcdataseth:type <> "DATASET"
  then do:
    return error substitute("Не определен dataset-источник с handle &1", p-srcdataseth).
  end.
  if not valid-handle(p-trgdataseth)
  or p-trgdataseth:type <> "DATASET"
  then do:
    return error substitute("Не определен dataset-приемник с handle &1", p-trgdataseth).
  end.
  for each buf_temp-rel-handle no-lock where
          buf_temp-rel-handle.dh = p-srcdataseth
  on error  undo , return error substitute( "&1. &2&3&4", vss-workfile, return-value, chr(10), error-status :get-message (1))
  on stop   undo , return error substitute( "&1. stop", vss-workfile )
  on endkey undo , return error substitute( "&1. endkey", vss-workfile )
  :
    gh = p-trgdataseth:ADD-RELATION ( buf_temp-rel-handle.parent-buffer-handle
                                      , buf_temp-rel-handle.child-buffer-handle
                                      , buf_temp-rel-handle.relation-fields_
                                      , buf_temp-rel-handle.reposition_
                                      , buf_temp-rel-handle.nested_).
   if error-status:error
   or not valid-handle(gh) then do:
     undo, return error substitute("Ошибка при добавлении relation &1 в dataset &2", buf_temp-rel-handle.name, p-trgdataseth:name).
   end.
  end.
end.
end method.
  define protected variable v_gc as handle no-undo.
  define protected variable v_ph as handle no-undo.
  define protected variable v_pp as widget-handle no-undo.
  define protected variable v_lh as widget-handle no-undo.
  define protected variable v_eh as widget-handle no-undo.
  define protected variable v_libg as handle no-undo .
  define private variable v_dataseth as handle no-undo.
  define private variable direction as integer no-undo .
  define private variable v-xmlh as handle no-undo .
  define private variable v-headerh as handle no-undo .
  define private variable v-gate-key-rec as character no-undo .
  define private variable v_qh as handle no-undo .
  define public variable name_ as character no-undo.
  define private variable v-esys-id as integer no-undo .
  define private variable v-esys-id-list as character no-undo .
  define private variable v-esys-name as character no-undo .
  define private variable v-tot-recs as integer no-undo .
  define private variable v-pack-num as integer no-undo .
  define variable objSetError as ibs.th.rul.route_date_error no-undo.
  CONSTRUCTOR PUBLIC route-data_(      input objError as ibs.th.rul.route_date_error
                                      ,input parparentproc as widget-handle
                                      ,input p-parent-handle as handle
                                      ,input p-log-handle as handle
                                      ):
     this-object(parparentproc,p-parent-handle,p-log-handle,?).
     objSetError = objError.
  end.
  CONSTRUCTOR PUBLIC route-data_(
                                       input parparentproc as widget-handle
                                      ,input p-parent-handle as handle
                                      ,input p-log-handle as handle
                                      ,input p-gc-handle as handle
                                      ):
    define variable glog as logical no-undo .
    define buffer buf_temp-xml-tables for temp-xml-tables.
    if valid-handle (p-gc-handle)
    then do:
       run garbcoll_create-gc-entry in p-gc-handle (input "route-data_",  input this-object) no-error.
       if error-status:error then do:
         message error-status:get-message(1) view-as alert-box .
         return error "Ошибка создания объекта ЭКСПОРТ ДАННЫХ".
       end.
    end.
    assign
    v_ph = p-parent-handle
    v_gc = p-gc-handle
    v_eh = v_gc
    v_libg = v_gc
    v_pp = parparentproc
    v_lh = p-log-handle
    name_ = '':U
    direction = 1
    .
  end constructor.
  CONSTRUCTOR PUBLIC route-data_(
                                       input parparentproc as widget-handle
                                      ,input p-parent-handle as handle
                                      ,input p-log-handle as handle
                                      ,input p-gc-handle as handle
                                      ,input p-libg-handle as handle
                                      ):
    define variable glog as logical no-undo .
    define buffer buf_temp-xml-tables for temp-xml-tables.
    run garbcoll_create-gc-entry in p-libg-handle (input "route-data_",  input this-object) no-error.
    if error-status:error then do:
      message error-status:get-message(1) view-as alert-box .
      return error "Ошибка создания объекта ЭКСПОРТ ДАННЫХ".
    end.
    assign
    v_ph = p-parent-handle
    v_gc = p-libg-handle
    v_eh = p-gc-handle
    v_pp = parparentproc
    v_lh = p-log-handle
    v_libg = p-libg-handle
    name_ = '':U
    direction = 1
    .
  end constructor.
  CONSTRUCTOR PUBLIC route-data_(
                                       input parparentproc as widget-handle
                                      ,input p-parent-handle as handle
                                      ,input p-log-handle as handle
                                      ,input p-gc-handle as handle
                                      ,input p-dataseth as handle
                                      ,input p-xmlh as handle
                                      ):
    define variable glog as logical no-undo .
    define buffer buf_temp-xml-tables for temp-xml-tables.
    run garbcoll_create-gc-entry in p-gc-handle (input "route-data_",  input this-object) no-error.
    if error-status:error then do:
      message error-status:get-message(1) view-as alert-box .
      return error "Ошибка создания объекта ИМПОРТ ДАННЫХ".
    end.
    assign
    v_ph = p-parent-handle
    v_gc = p-gc-handle
    v_eh = v_gc
    v_pp = parparentproc
    v_lh = p-log-handle
    v_libg = v_gc
    name_ = '':U
    direction = (if direction = 0 then -1 else direction)
    v_dataseth = p-dataseth
    v-gate-key-rec = (if num-entries(p-dataseth:private-data, chr(4)) > 1
                  then entry(2, p-dataseth:private-data, chr(4))
                  else '')
    v-xmlh = p-xmlh
    .
  end constructor.
  destructor public route-data_():
    define buffer buf_temp-xml-tables for temp-xml-tables.
    name_ = '':U.
    if direction = 1 then do:
      if valid-handle(v_libg) then do:
        run gate-clear in v_libg ( input v_dataseth, input buffer buf_temp-xml-tables:handle).
      end.
      else if valid-handle(v_gc) then do:
        run gate-clear in v_gc ( input v_dataseth, input buffer buf_temp-xml-tables:handle).
      end.
      else do :
      end.
    end.
  end destructor.
  method public void change-direction ( input p-direction as integer):
   direction = p-direction.
  end method.
  method public character current-tbl-name ():
    define variable v-character as character no-undo .
    if v-xmlh:available = yes then do:
      v-character = v-xmlh:buffer-field("tbl-name"):buffer-value.
    end.
    return v-character.
  end method.
  method public logical route-data_read-xmlschema ( input p-xsd-file as character):
   define variable glog as logical no-undo .
   define variable v-ii as integer no-undo .
   define variable v-longchar as longchar no-undo .
   define variable v-xmlh as handle no-undo .
   define buffer buf_clob-bind for ub.clob-bind.
   define buffer buf_clob-data for ub.clob-data.
   define buffer buf_temp-xml-tables for temp-xml-tables.
   if direction = -1 then do:
      undo, return error substitute("Нельзя получить XML-схему из файла в режиме импорта").
   end.
   if not valid-handle (v_dataseth) then do:
      v-xmlh = buffer buf_temp-xml-tables:handle.
      run get-gate-by-name in v_libg ( input  p-xsd-file
                                    ,output v-gate-key-rec
                                    ,output v_dataseth
                                    ,input-output v-xmlh) no-error.
      if error-status :error then do:
        setError ( input return-value ).
        return no.
      end.
      name_ = v_dataseth:name.
      return yes.
    end.
    else do:
      return yes.
    end.
  end method.
  method void route-data_init (
                                           input parparentproc as widget-handle
                                          ,input p-parent-handle as handle
                                          ,input p-log-handle as handle
                                          ,input p-gc-handle as handle
                                          ,input p-libg-handle as handle
                                          ):
    assign
    v_ph = p-parent-handle
    v_gc = p-gc-handle
    v_pp = parparentproc
    v_lh = p-log-handle
    v_libg = p-libg-handle
    .
    assign
    v_dataseth = ?
    direction = 1
    v-xmlh = ?
    v-headerh = ?
    v-gate-key-rec = ''
    name_ = ''
    v-esys-id-list = ''
    v-esys-id = 0
    v-esys-name = ''
    v-tot-recs = 0
    v-pack-num = 0
    .
  end.
  method public logical route-data_push-xmlschema ( input p-xsd-file as character
                                                   ):
   define variable v-xmlh as handle no-undo .
   define buffer buf_temp-xml-tables for temp-xml-tables.
   if direction = -1 then do:
      undo, return error substitute("Нельзя получить XML-схему из файла в режиме импорта").
   end.
   if not valid-handle (v_dataseth) then do:
      v-xmlh = buffer buf_temp-xml-tables:handle.
      run get-gate-by-name in v_libg ( input  p-xsd-file
                                    ,output v-gate-key-rec
                                    ,output v_dataseth
                                    ,input-output v-xmlh) no-error.
      if error-status :error then do:
        setError ( input return-value ).
        return no.
      end.
      name_ = v_dataseth:name.
      return yes.
    end.
    else do:
      return yes.
    end.
  end method.
  method public void route-data_clear-xmlschema ( ):
    define buffer buf_temp-xml-tables for temp-xml-tables.
    name_ = '':U.
   if direction = -1 then do:
      undo, return error substitute("Нельзя очищать структуру буфера маршрутизации в режиме импорта").
   end.
    run gate-clear in v_libg ( input v_dataseth, input buffer buf_temp-xml-tables:handle).
  end method.
  method public void route-data_clear-data ( ):
    define buffer buf_temp-xml-tables for temp-xml-tables.
    v-tot-recs = 0.
    v-esys-id-list = ''.
    v-esys-id = 0.
    v-pack-num = 0.
    v-esys-name = ''.
    for each buf_temp-xml-tables:
       buf_temp-xml-tables.tbl-handle_:empty-temp-table().
    end.
  end method.
  method public void route-data_dump ( ):
  end method.
  method public logical route-data_create-record ( input p-table-name as character ):
    define variable glog as logical no-undo .
    define buffer buf_temp-xml-tables for temp-xml-tables.
    if direction = -1 then do:
        undo, return error substitute("Нельзя создать запись в буфере маршрутизации в режиме импорта").
    end.
    find first buf_temp-xml-tables where
              buf_temp-xml-tables.tbl-name = p-table-name no-error.
    if not available buf_temp-xml-tables then do:
      return error substitute("Таблица &1 не найдена в dataset &2"
                             , p-table-name
                             , name_).
    end.
    do transaction :
      assign
      glog = buf_temp-xml-tables.tbl-handle_:buffer-create no-error.
      .
    end.
    if glog
    and buf_temp-xml-tables.is-parent
    then v-tot-recs = v-tot-recs + 1.
    return glog.
  end method.
  method public logical route-data_copy-field ( input p-table-name as character
                                                ,input p-field-name as character
                                                ,input p-src-fh as handle
                                             ):
    define variable glog as logical no-undo .
    define buffer buf_temp-xml-tables for temp-xml-tables.
    if direction = -1 then do:
        undo, return error substitute("Нельзя скопировать поле в буфер маршрутизации в режиме импорта").
    end.
    find first buf_temp-xml-tables where
              buf_temp-xml-tables.tbl-name = p-table-name no-error.
    if not available buf_temp-xml-tables then do:
      return error substitute("Таблица &1 не найдена в dataset &2"
                             , p-table-name
                             , name_).
    end.
    if buf_temp-xml-tables.tbl-handle_:available = no then do:
      glog = route-data_create-record( input p-table-name).
      if not glog then do:
        return no.
      end.
    end.
    assign
    buf_temp-xml-tables.tbl-handle_:buffer-field(p-field-name):buffer-value = p-src-fh:buffer-value
    no-error.
    .
    return not error-status:error .
  end method.
  method public logical route-data_copy-field-character ( input p-table-name as character
                                                ,input p-field-name as character
                                                ,input p-value-character as character
                                             ):
    define variable glog as logical no-undo .
    define buffer buf_temp-xml-tables for temp-xml-tables.
    if direction = -1 then do:
        undo, return error substitute("Нельзя скопировать поле в буфер маршрутизации в режиме импорта").
    end.
    find first buf_temp-xml-tables where
              buf_temp-xml-tables.tbl-name = p-table-name no-error.
    if not available buf_temp-xml-tables then do:
      return error substitute("Таблица &1 не найдена в dataset &2"
                             , p-table-name
                             , name_).
    end.
    if buf_temp-xml-tables.tbl-handle_:available = no then do:
      glog = route-data_create-record( input p-table-name).
      if not glog then do:
        return no.
      end.
    end.
    assign
    buf_temp-xml-tables.tbl-handle_:buffer-field(p-field-name):buffer-value = p-value-character
    no-error.
    .
    return not error-status:error .
  end method.
  method public logical route-data_copy-field-decimal ( input p-table-name as character
                                                ,input p-field-name as character
                                                ,input p-value-decimal as decimal
                                             ):
    define variable glog as logical no-undo .
    define buffer buf_temp-xml-tables for temp-xml-tables.
    if direction = -1 then do:
        undo, return error substitute("Нельзя скопировать поле в буфер маршрутизации в режиме импорта").
    end.
    find first buf_temp-xml-tables where
              buf_temp-xml-tables.tbl-name = p-table-name no-error.
    if not available buf_temp-xml-tables then do:
      return error substitute("Таблица &1 не найдена в dataset &2"
                             , p-table-name
                             , name_).
    end.
    if buf_temp-xml-tables.tbl-handle_:available = no then do:
      glog = route-data_create-record( input p-table-name).
      if not glog then do:
        return no.
      end.
    end.
    assign
    buf_temp-xml-tables.tbl-handle_:buffer-field(p-field-name):buffer-value = p-value-decimal
    no-error.
    .
    return not error-status:error .
  end method.
  method public logical route-data_copy-field-integer ( input p-table-name as character
                                                ,input p-field-name as character
                                                ,input p-value-integer as integer
                                             ):
    define variable glog as logical no-undo .
    define buffer buf_temp-xml-tables for temp-xml-tables.
    if direction = -1 then do:
        undo, return error substitute("Нельзя скопировать поле в буфер маршрутизации в режиме импорта").
    end.
    find first buf_temp-xml-tables where
              buf_temp-xml-tables.tbl-name = p-table-name no-error.
    if not available buf_temp-xml-tables then do:
      return error substitute("Таблица &1 не найдена в dataset &2"
                             , p-table-name
                             , name_).
    end.
    if buf_temp-xml-tables.tbl-handle_:available = no then do:
      glog = route-data_create-record( input p-table-name).
      if not glog then do:
        return no.
      end.
    end.
    assign
    buf_temp-xml-tables.tbl-handle_:buffer-field(p-field-name):buffer-value = p-value-integer
    no-error.
    .
    return not error-status:error .
  end method.
  method public logical route-data_copy-field-logical ( input p-table-name as character
                                                ,input p-field-name as character
                                                ,input p-value-logical as logical
                                             ):
    define variable glog as logical no-undo .
    define buffer buf_temp-xml-tables for temp-xml-tables.
    if direction = -1 then do:
        undo, return error substitute("Нельзя скопировать поле в буфер маршрутизации в режиме импорта").
    end.
    find first buf_temp-xml-tables where
              buf_temp-xml-tables.tbl-name = p-table-name no-error.
    if not available buf_temp-xml-tables then do:
      return error substitute("Таблица &1 не найдена в dataset &2"
                             , p-table-name
                             , name_).
    end.
    if buf_temp-xml-tables.tbl-handle_:available = no then do:
      glog = route-data_create-record( input p-table-name).
      if not glog then do:
        return no.
      end.
    end.
    assign
    buf_temp-xml-tables.tbl-handle_:buffer-field(p-field-name):buffer-value = p-value-logical
    no-error.
    .
    return not error-status:error .
  end method.
  method public logical route-data_copy-field-datetime-tz ( input p-table-name as character
                                                          , input p-field-name as character
                                                          , input p-value-datetime-tz as datetime-tz
                                                          ):
    define variable glog as logical no-undo .
    define buffer buf_temp-xml-tables for temp-xml-tables.
    if direction = -1 then do:
        undo, return error substitute("Нельзя скопировать поле в буфер маршрутизации в режиме импорта").
    end.
    find first buf_temp-xml-tables where
              buf_temp-xml-tables.tbl-name = p-table-name no-error.
    if not available buf_temp-xml-tables then do:
      return error substitute("Таблица &1 не найдена в dataset &2"
                             , p-table-name
                             , name_).
    end.
    if buf_temp-xml-tables.tbl-handle_:available = no then do:
      glog = route-data_create-record( input p-table-name).
      if not glog then do:
        return no.
      end.
    end.
    assign
    buf_temp-xml-tables.tbl-handle_:buffer-field(p-field-name):buffer-value = p-value-datetime-tz
    no-error.
    .
    return not error-status:error .
  end method.
  method public character route-data_get-field-character (
                                               input p-table-name as character
                                              ,input p-field-name as character
                                             ):
    define variable v-character as character no-undo .
    assign
    v-character = route-data_get-field-character ( input v-xmlh
                                    ,input p-table-name
                                    ,input p-field-name) no-error.
    if error-status:error then do:
       return error .
    end.
    return v-character.
  end method.
  method public character route-data_get-field-character (
                                               input p-xmlh as handle
                                              ,input p-table-name as character
                                              ,input p-field-name as character
                                             ):
    define variable glog as logical no-undo .
    define variable v-src-fh as handle no-undo .
    define variable v-character as character no-undo .
    if not valid-handle(p-xmlh) then do:
      undo, return error substitute("Неверное значение параметра p-xmlh, не указывает на буффер таблицы temp-xml-tables").
    end.
    if p-xmlh:available = no then do:
      undo, return error substitute("В настоящий момент в читаемом буфере &1 нет записи", p-xmlh:buffer-field("tbl-handle_"):buffer-value:name).
    end.
    if P-xmlh:buffer-field("tbl-handle_"):buffer-value:name <> p-table-name then do:
      undo, return error substitute("В настоящий момент в буфере маршрутизации запись &1, а не &2"
                                    ,p-xmlh:buffer-field("tbl-handle_"):buffer-value:name
                                    ,p-table-name).
    end.
    if P-xmlh:buffer-field("tbl-handle_"):buffer-value:available = no then do:
      undo, return error substitute("В настоящий момент в буфере маршрутизации нет записи").
    end.
    assign
    v-src-fh = p-xmlh:buffer-field("tbl-handle_"):buffer-value:buffer-field(p-field-name)
    v-character = v-src-fh:buffer-value
    no-error.
    .
    if not error-status :error then return v-character.
    else do:
      return error .
    end.
  end method.
  method public date route-data_get-field-date (
                                               input p-table-name as character
                                              ,input p-field-name as character
                                             ):
    define variable v-date as date no-undo .
    assign
    v-date = route-data_get-field-date ( input v-xmlh
                                    ,input p-table-name
                                    ,input p-field-name) no-error.
    if error-status:error then do:
       return error .
    end.
    return v-date.
  end.
  method public date route-data_get-field-date (
                                               input p-xmlh as handle
                                              ,input p-table-name as character
                                              ,input p-field-name as character
                                             ):
    define variable glog as logical no-undo .
    define variable v-src-fh as handle no-undo .
    define variable v-date as date no-undo .
    if not valid-handle(p-xmlh) then do:
      undo, return error substitute("Неверное значение параметра p-xmlh, не указывает на буффер таблицы temp-xml-tables").
    end.
    if p-xmlh:available = no then do:
      undo, return error substitute("В настоящий момент в читаемом буфере &1 нет записи", p-xmlh:buffer-field("tbl-handle_"):buffer-value:name ).
    end.
    if p-xmlh:buffer-field("tbl-handle_"):buffer-value:name <> p-table-name then do:
      undo, return error substitute("В настоящий момент в читаемом буфере запись &1, а не &2"
                                    ,p-xmlh:buffer-field("tbl-handle_"):buffer-value:name
                                    ,p-table-name).
    end.
    if p-xmlh:buffer-field("tbl-handle_"):buffer-value:available = no then do:
      undo, return error substitute("В настоящий момент в буфере маршрутизации нет записи").
    end.
    assign
    v-src-fh = p-xmlh:buffer-field("tbl-handle_"):buffer-value:buffer-field(p-field-name)
    v-date = v-src-fh:buffer-value
    no-error.
    .
    if not error-status :error then return v-date.
    else do:
      return error .
    end.
  end method.
  method public logical route-data_get-field-logical (
                                               input p-table-name as character
                                              ,input p-field-name as character
                                             ):
    define variable v-logical as logical no-undo .
    assign
    v-logical = route-data_get-field-logical ( input v-xmlh
                                    ,input p-table-name
                                    ,input p-field-name) no-error.
    if error-status:error then do:
       return error .
    end.
    return v-logical.
  end.
  method public logical route-data_get-field-logical (
                                               input p-xmlh as handle
                                              ,input p-table-name as character
                                              ,input p-field-name as character
                                             ):
    define variable glog as logical no-undo .
    define variable v-src-fh as handle no-undo .
    define variable v-logical as logical no-undo .
    if not valid-handle(p-xmlh) then do:
      undo, return error substitute("Неверное значение параметра p-xmlh, не указывает на буффер таблицы temp-xml-tables").
    end.
    if p-xmlh:available = no then do:
      undo, return error substitute("В настоящий момент в читаемом буфере &1 нет записи", p-xmlh:buffer-field("tbl-handle_"):buffer-value:name ).
    end.
    if p-xmlh:buffer-field("tbl-handle_"):buffer-value:name <> p-table-name then do:
      undo, return error substitute("В настоящий момент в читаемом буфере запись &1, а не &2"
                                    ,p-xmlh:buffer-field("tbl-handle_"):buffer-value:name
                                    ,p-table-name).
    end.
    if p-xmlh:buffer-field("tbl-handle_"):buffer-value:available = no then do:
      undo, return error substitute("В настоящий момент в буфере маршрутизации нет записи").
    end.
    assign
    v-src-fh = p-xmlh:buffer-field("tbl-handle_"):buffer-value:buffer-field(p-field-name)
    v-logical = v-src-fh:buffer-value
    no-error.
    .
    if not error-status :error then return v-logical.
    else do:
      return error .
    end.
  end method.
  method public integer route-data_get-field-integer (
                                               input p-table-name as character
                                              ,input p-field-name as character
                                             ):
    define variable v-integer as integer no-undo .
    assign
    v-integer = route-data_get-field-integer( input v-xmlh
                                    ,input p-table-name
                                    ,input p-field-name) no-error.
    if error-status:error then do:
       return error .
    end.
    return v-integer.
  end method.
  method public integer route-data_get-field-integer (
                                               input p-xmlh as handle
                                              ,input p-table-name as character
                                              ,input p-field-name as character
                                             ):
    define variable glog as logical no-undo .
    define variable v-src-fh as handle no-undo .
    define variable v-integer as integer   no-undo .
    if not valid-handle(p-xmlh) then do:
      undo, return error substitute("Неверное значение параметра p-xmlh, не указывает на буффер таблицы temp-xml-tables").
    end.
    if p-xmlh:available = no then do:
      undo, return error substitute("В настоящий момент в читаемом буфере &1 нет записи", p-xmlh:buffer-field("tbl-handle_"):buffer-value:name ).
    end.
    if p-xmlh:buffer-field("tbl-handle_"):buffer-value:name <> p-table-name then do:
      undo, return error substitute("В настоящий момент в читаемом буфере запись &1, а не &2"
                                    ,p-xmlh:buffer-field("tbl-handle_"):buffer-value:name
                                    ,p-table-name).
    end.
    if p-xmlh:buffer-field("tbl-handle_"):buffer-value:available = no then do:
      undo, return error substitute("В настоящий момент в буфере маршрутизации нет записи").
    end.
    assign
    v-src-fh = p-xmlh:buffer-field("tbl-handle_"):buffer-value:buffer-field(p-field-name)
    v-integer = v-src-fh:buffer-value
    no-error.
    .
    if not error-status :error then return v-integer.
    else do:
      return error .
    end.
  end method.
  method public decimal route-data_get-field-decimal (
                                               input p-table-name as character
                                              ,input p-field-name as character
                                             ):
    define variable v-decimal as decimal no-undo .
    assign
    v-decimal = route-data_get-field-decimal( input v-xmlh
                                    ,input p-table-name
                                    ,input p-field-name) no-error.
    if error-status:error then do:
       return error .
    end.
    return v-decimal.
  end method.
  method public decimal route-data_get-field-decimal (
                                               input p-xmlh as handle
                                              ,input p-table-name as character
                                              ,input p-field-name as character
                                             ):
    define variable glog as logical no-undo .
    define variable v-src-fh as handle no-undo .
    define variable v-decimal as decimal   no-undo .
    if not valid-handle(p-xmlh) then do:
      undo, return error substitute("Неверное значение параметра p-xmlh, не указывает на буффер таблицы temp-xml-tables").
    end.
    if p-xmlh:available = no then do:
      undo, return error substitute("В настоящий момент в читаемом буфере &1 нет записи", p-xmlh:buffer-field("tbl-handle_"):buffer-value:name ).
    end.
    if p-xmlh:buffer-field("tbl-handle_"):buffer-value:name <> p-table-name then do:
      undo, return error substitute("В настоящий момент в читаемом буфере запись &1, а не &2"
                                    ,p-xmlh:buffer-field("tbl-handle_"):buffer-value:name
                                    ,p-table-name).
    end.
    if p-xmlh:buffer-field("tbl-handle_"):buffer-value:available = no then do:
      undo, return error substitute("В настоящий момент в буфере маршрутизации нет записи").
    end.
    assign
    v-src-fh = p-xmlh:buffer-field("tbl-handle_"):buffer-value:buffer-field(p-field-name)
    v-decimal = v-src-fh:buffer-value
    no-error.
    .
    if not error-status :error then return v-decimal.
    else do:
      return error .
    end.
  end method.
  method public datetime-tz route-data_get-field-datetime-tz ( input p-table-name as character
                                                             , input p-field-name as character
                                                             ):
    define variable v-datetime-tz as datetime-tz no-undo .
    assign
    v-datetime-tz = route-data_get-field-datetime-tz( input v-xmlh
                                                    , input p-table-name
                                                    , input p-field-name
                                                    ) no-error.
    if error-status:error then do:
       return error .
    end.
    return v-datetime-tz.
  end method.
  method public datetime-tz route-data_get-field-datetime-tz ( input p-xmlh as handle
                                                             , input p-table-name as character
                                                             , input p-field-name as character
                                                             ):
    define variable glog as logical no-undo .
    define variable v-src-fh as handle no-undo .
    define variable v-datetime-tz as datetime-tz   no-undo .
    if not valid-handle(p-xmlh) then do:
      undo, return error substitute("Неверное значение параметра p-xmlh, не указывает на буффер таблицы temp-xml-tables").
    end.
    if p-xmlh:available = no then do:
      undo, return error substitute("В настоящий момент в читаемом буфере &1 нет записи", p-xmlh:buffer-field("tbl-handle_"):buffer-value:name ).
    end.
    if p-xmlh:buffer-field("tbl-handle_"):buffer-value:name <> p-table-name then do:
      undo, return error substitute("В настоящий момент в читаемом буфере запись &1, а не &2"
                                    ,p-xmlh:buffer-field("tbl-handle_"):buffer-value:name
                                    ,p-table-name).
    end.
    if p-xmlh:buffer-field("tbl-handle_"):buffer-value:available = no then do:
      undo, return error substitute("В настоящий момент в буфере маршрутизации нет записи").
    end.
    assign
    v-src-fh = p-xmlh:buffer-field("tbl-handle_"):buffer-value:buffer-field(p-field-name)
    v-datetime-tz = v-src-fh:buffer-value
    no-error.
    .
    if not error-status :error then return v-datetime-tz.
    else do:
      return error .
    end.
  end method.
  method public logical route-data_set-field (
                                               input p-table-name as character
                                              ,input p-field-name as character
                                              ,input p-trg-fh as handle
                                             ):
    define variable glog as logical no-undo .
    define variable v-src-fh as handle no-undo .
    if direction = 1 then do:
        undo, return error substitute("Нельзя скопировать поле из буфера маршрутизации в режиме экспорта").
    end.
    if v-xmlh:available = no then do:
      undo, return error substitute("В настоящий момент в буфере маршрутизации нет записи").
    end.
    if v-xmlh:buffer-field("tbl-handle_"):buffer-value:name <> p-table-name then do:
      undo, return error substitute("В настоящий момент в буфере маршрутизации запись &1, а не &2"
                                    ,v-xmlh:buffer-field("tbl-handle_"):buffer-value:name
                                    ,p-table-name).
    end.
    if v-xmlh:buffer-field("tbl-handle_"):buffer-value:available = no then do:
      undo, return error substitute("В настоящий момент в буфере маршрутизации нет записи").
    end.
    if p-trg-fh:buffer-handle:available = no then do:
      undo, return error substitute("В настоящий момент в буфере-приемнике &1 нет записи", p-trg-fh:buffer-handle:table ).
    end.
    assign
    v-src-fh = v-xmlh:buffer-field("tbl-handle_"):buffer-value:buffer-field(p-field-name)
    p-trg-fh:buffer-value = v-src-fh:buffer-value
    no-error.
    .
    return not error-status:error .
  end method.
  method public logical route-data_set-record (
                                               input p-table-name as character
                                              ,input p-trg-bh as handle
                                             ):
    define variable glog as logical no-undo .
    define variable v-src-bh as handle no-undo .
    if direction = 1 then do:
        undo, return error substitute("Нельзя скопировать поле из буфера маршрутизации в режиме экспорта").
    end.
    if v-xmlh:available = no then do:
      undo, return error substitute("В настоящий момент в буфере маршрутизации нет записи").
    end.
    if v-xmlh:buffer-field("tbl-handle_"):buffer-value:name <> p-table-name then do:
      undo, return error substitute("В настоящий момент в буфере маршрутизации запись &1, а не &2"
                                    ,v-xmlh::tbl-handle:name
                                    ,p-table-name).
    end.
    if v-xmlh:buffer-field("tbl-handle_"):buffer-value:available = no then do:
      undo, return error substitute("В настоящий момент в буфере маршрутизации нет записи").
    end.
    if p-trg-bh:available = no then do:
      undo, return error substitute("В настоящий момент в буфере-приемнике &1 нет записи", p-trg-bh:table ).
    end.
    do transaction :
      assign
      v-src-bh = v-xmlh:buffer-field("tbl-handle_"):buffer-value
      glog = p-trg-bh:buffer-copy( v-src-bh)
      no-error.
    end.
    .
    return glog .
  end method.
  method public logical route-data_is-empty():
    if not valid-handle(v_dataseth)
    and not valid-handle(v-xmlh) then return yes.
    else return no.
  end method.
  method public handle route-data_get-record ( input p-table-name as character ):
    return route-data_get-record ( input v-xmlh, input p-table-name  ).
  end.
  method public handle route-data_get-record ( input p-xmlbh as handle, input p-table-name as character ):
    define variable glog as logical no-undo .
    if p-xmlbh:available = no then do:
      undo, return error substitute("В настоящий момент в буфере маршрутизации нет записи").
    end.
    if p-xmlbh:buffer-field("tbl-handle_"):buffer-value:name <> p-table-name then do:
      undo, return error substitute("В настоящий момент в буфере маршрутизации запись &1, а не &2"
                                    ,p-xmlbh::tbl-handle:name
                                    ,p-table-name).
    end.
    if p-xmlbh:buffer-field("tbl-handle_"):buffer-value:available = no then do:
      undo, return error substitute("В настоящий момент в буфере маршрутизации нет записи").
    end.
    return p-xmlbh:buffer-field("tbl-handle_"):buffer-value.
  end method.
  method public logical route-data_copy-record ( input p-table-name as character
                                                ,input p-src-bh as handle
                                             ):
    define variable glog as logical no-undo .
    define buffer buf_temp-xml-tables for temp-xml-tables.
    if direction = -1 then do:
        undo, return error substitute("Нельзя скопировать запись в буфер маршрутизации в режиме импорта").
    end.
    find first buf_temp-xml-tables where
              buf_temp-xml-tables.tbl-name = p-table-name no-error.
    if not available buf_temp-xml-tables then do:
      return error substitute("Таблица &1 не найдена в dataset &2"
                             , p-table-name
                             , name_).
    end.
    if buf_temp-xml-tables.tbl-handle_:available = no then do:
      glog = route-data_create-record( input p-table-name).
      if not glog then do:
        return no.
      end.
    end.
    do transaction :
      assign
      glog = buf_temp-xml-tables.tbl-handle_:buffer-copy(p-src-bh)
      no-error.
    end.
    .
    return glog.
  end method.
  method public logical esys-add-dump (     input p-table-name as character
                                          , input p-esys-cmd-proc-handle as handle
                                          , input p-esys-cmd-code as integer
                                          , input p-action as character     ):
    define variable v-esys-rec-ord as integer no-undo .
    define variable v-local-xmlh as handle no-undo .
    define buffer buf_temp-xml-tables for temp-xml-tables.
    if valid-handle(v-xmlh) then do:
      v-local-xmlh = v-xmlh.
    end.
    else do:
      v-local-xmlh = buffer buf_temp-xml-tables:handle.
    end.
    if direction = -1 then do:
        undo, return error substitute("Нельзя маршрутизировать буфер маршрутизации в режиме импорта").
    end.
    v-local-xmlh:find-first( substitute(" where tbl-name = &1&2&1", chr(34), p-table-name)) no-error.
    if not v-local-xmlh:available then do:
      return error substitute("Таблица &1 не найдена в dataset &2"
                             , p-table-name
                             , name_).
    end.
    run add-dump in p-esys-cmd-proc-handle
      (input p-esys-cmd-code
      ,input p-table-name
      ,input p-action
      ,input v-local-xmlh::tbl-handle_
      ,input v-gate-key-rec
      ,output v-esys-rec-ord
      ) no-error .
    if error-status :error
    then do:
      if valid-handle (p-esys-cmd-proc-handle ) then do:
        delete procedure p-esys-cmd-proc-handle .
      end.
      setError (substitute("Ошибка при добавлении записи &2 в команду с кодом &3&1&4&1&5"
                                          ,chr(10)
                                          ,p-table-name
                                          ,p-esys-cmd-code
                                          ,error-status:get-message(1)
                                          ,return-value
                                          )) .
      return no.
    end.
    return yes.
  end method.
  method public logical set-esys ( input p-esys-id as integer, p-esys-name as character):
    assign
    v-esys-id-list = string(p-esys-id)
    v-esys-id = p-esys-id
    v-esys-name = p-esys-name
    .
    return yes.
  end.
  method public logical set-pack-num ( input p-pack-num as integer):
    assign
    v-pack-num = p-pack-num
    .
    return yes.
  end.
  method public logical set-field-hidden ( input p-table-name as character, input p-field-name as character ):
    define buffer buf_temp-xml-tables for temp-xml-tables.
    find first buf_temp-xml-tables where
              buf_temp-xml-tables.tbl-name = p-table-name.
    assign
    buf_temp-xml-tables.tbl-Handle_:buffer-field(p-field-name):xml-node-type = "hidden" no-error.
    if not error-status:error
    and buf_temp-xml-tables.tbl-Handle_:buffer-field(p-field-name):xml-node-type = "hidden"
    then return yes.
    return no.
  end method.
  method public logical write-xml ( input p-file-name as character, p-file-num as integer):
  define variable glog as logical no-undo .
    define variable v-header-schema-name as character no-undo .
    define variable v-header-name as character no-undo .
    define variable v-header-rec as character no-undo .
    define variable v-header-th as handle no-undo .
    define buffer buf_sys-ctrl  for ub.sys-ctrl.
    define buffer buf_temp-xml-tables for temp-xml-tables.
    find first buf_sys-ctrl no-lock.
    v-header-schema-name = "exe/ThHeader.xsd".
    v-header-name = "ThHeader".
    run get-gate-rec in v_libg ( input v-header-schema-name
                                        ,output v-header-rec) no-error.
    if error-status:error then do:
            .
      undo, return error ''.
    end.
    run get-header-by-rec in v_libg        ( input v-header-rec
                                          ,output v-header-th
                                          ) no-error.
    if error-status:error then do:
            .
      undo, return error '':U.
    end.
    v-headerh = v-header-th:default-buffer-handle.
    if v-headerh:available = no then do:
      do transaction :
        v-headerh:buffer-create().
      end.
      find first buf_temp-xml-tables where
              buf_temp-xml-tables.tbl-name = v-headerh:table no-error.
      if not available buf_temp-xml-tables then do:
        create buf_temp-xml-tables.
        assign
        buf_temp-xml-tables.tbl-name = v-headerh:table
        buf_temp-xml-tables.tbl-handle_ = v-headerh
        buf_temp-xml-tables.table-handle_ = v-headerh:table-handle
        buf_temp-xml-tables.uniq-gate-rec = v-gate-key-rec
        buf_temp-xml-tables.gate-name = v_dataseth:name
        buf_temp-xml-tables.gate-handle_ = v_dataseth
        buf_temp-xml-tables.order = -3
        .
        tmpreldf_get-relations  ( input v_dataseth).
        for each buf_temp-xml-tables
        break
        by buf_temp-xml-tables.order:
        if first(buf_temp-xml-tables.order) then do:
          glog = v_dataseth:set-buffers ( buf_temp-xml-tables.tbl-handle_) no-error.
        end.
        else do:
          glog = v_dataseth:add-buffer ( buf_temp-xml-tables.tbl-handle_) no-error.
        end.
        if error-status:error
        or not glog
        then do:
                        .
            run gate-clear in v_libg ( input v_dataseth, input v-xmlh).
            undo, return error '':U.
          end.
        end.
        tmpreldf_set-relations  ( input v_dataseth, input v_dataseth).
      end.
    end.
    do transaction :
      assign
      v-headerh::THfilename     = p-file-name
      v-headerh::THfilenumber   = p-file-num
      v-headerh::THformat_      = "IBS TH"
      v-headerh::THversion_     = trim( replace( substring( vss-archive, 15, 4 ), "$":U, "":U ) )
      v-headerh::THrevision     = trim( replace( substring( vss-revision, 12 ), "$":U, "":U ) )
      v-headerh::THcurrentDbNum = buf_sys-ctrl.db-num
      v-headerh::THschema-name  = substitute("exe/&1.xsd", v_dataseth:name)
      v-headerh::THesysname     = v-esys-name
      v-headerh::THpack-num     = v-pack-num
      v-headerh::THexport-esys-id  = (if direction = 1 then v-esys-id else 0)
      v-headerh::THimport-esys-id  = (if direction = -1 then v-esys-id else 0)
      v-headerh::THtotal-recs = v-tot-recs + 1
      .
    end.
    glog = v_dataseth:WRITE-XML("FILE"
                              ,p-file-name
                              ,yes
                              ,"windows-1251"
                              ,?
                              ,no
                              ,no
                              ) no-error.
    if error-status:error then do:
      setError ( substitute("Ошибка при записи XML файла данными через гейт &1:&2&3"
                                      , v_dataseth:name
                                      , chr(10), error-status:get-message(1))).
      return no.
    end.
    return yes.
  end method.
  method public logical esys-add-dump-data ( input p-data as memptr
                                          , input p-esys-cmd-proc-handle as handle
                                          , input p-esys-cmd-code as integer
                                          , input p-action as character     ):
    define variable v-esys-rec-ord as integer no-undo .
    define variable v-local-xmlh as handle no-undo .
    define variable v-dump-name as character no-undo .
    define buffer buf_temp-xml-tables for temp-xml-tables.
    v-dump-name = "" .
    if num-entries(p-action, chr(4)) >= 2
    then do :
        v-dump-name = entry(2, p-action, chr(4)) no-error.
        if num-entries(p-action, chr(4)) = 3
          then v-dump-name = substitute("&1&2&3", v-dump-name, chr(4), entry(3, p-action, chr(4))) no-error.
        p-action = entry(1, p-action, chr(4)) no-error.
    end.
    if direction = -1 then do:
        undo, return error substitute("Нельзя маршрутизировать буфер маршрутизации в режиме импорта").
    end.
    run add-dump-data in p-esys-cmd-proc-handle
      (input p-esys-cmd-code
      ,input if v-dump-name = "" then "xml data" else v-dump-name
      ,input p-action
      ,input p-data
      ,output v-esys-rec-ord
      ) no-error .
    if error-status :error
    then do:
      if valid-handle (p-esys-cmd-proc-handle ) then do:
        delete procedure p-esys-cmd-proc-handle .
      end.
      setError (substitute("Ошибка при добавлении записи &2 в команду с кодом &3&1&4&1&5"
                                          ,chr(10)
                                          ,"xml data"
                                          ,p-esys-cmd-code
                                          ,error-status:get-message(1)
                                          ,return-value
                                          )) .
      return no.
    end.
    return yes.
  end method.
  method private void setError (iTxt as char):
     if valid-handle (v_eh)
     then
        run set-error in v_eh (iTxt).
     if valid-object (objSetError)
     then
        objSetError:setError(iTxt).
   end.
end class.
