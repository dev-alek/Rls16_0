block-level on error undo, throw.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
define input parameter parfile    as character no-undo.
define input parameter p-obj-type as character no-undo.
define input parameter p-obj-code as integer   no-undo.
define input parameter p-pl-code  as integer   no-undo.
define variable v-filename       as character no-undo.
define variable varstring        as character no-undo.
define variable varcode          as integer   no-undo.
define variable varlevel         as integer   no-undo.
define variable varvolume        as DECIMAL   no-undo.
define variable varprev-level    as integer   no-undo.
define variable varprev-volume   as DECIMAL   no-undo.
define variable vardelta         as decimal   no-undo.
define variable vardeltaV        as decimal   no-undo.
define variable vError           as character no-undo.
define temp-table tt-tarir
   field level   as   integer
   field volume  as   DECIMAL
   field delta   as   decimal
   field deltaV  as   decimal
   index pi is unique primary
         level
.
define buffer buf_clients  for ub.clients .
define buffer buf_place    for ub.place .
define buffer buf_pl-level for ub.pl-level .
define buffer buf_pl-level-attr for ub.pl-level-attr .
define stream str-in.
do
on error undo, return error return-value :
   assign
      v-filename = search(parfile)
   .
   if v-filename = ? then do:
      message "Не найден файл " parfile
      skip "Таблицы не загружены."
      view-as alert-box error.
      return error.
   end.
   if  p-obj-type <> 'маг':U
   and p-obj-type <> 'скл':U
   then do:
      message "Указан тип объекта " p-obj-type " должен быть указан склад или магазин."
      skip "Таблицы не загружены."
      view-as alert-box error.
      return error.
   end.
   find first buf_clients
        where buf_clients.obj-type = p-obj-type
        and   buf_clients.obj-code = p-obj-code
        no-lock
        no-error.
   if not available buf_clients then do:
      message "Указан неправильный объект " p-obj-type " " p-obj-code " ."
      skip "Таблицы не загружены."
      view-as alert-box error.
      return error.
   end.
   find first buf_place
        where buf_place.obj-type = p-obj-type
        and   buf_place.obj-code = p-obj-code
        and   buf_place.pl-code  = p-pl-code
        no-lock
        no-error.
   if not available buf_place then do:
      message "Указан неправильный резервуар " p-obj-type " " p-obj-code " " p-pl-code "."
      skip "Таблицы не загружены."
      view-as alert-box error.
      return error.
   end.
   input stream str-in from VALUE(v-filename).
   repeat :
      import stream str-in unformatted varstring.
      if varstring = "" then next.
      assign
         varcode   = integer(entry (1, varstring, chr(9)))
         varlevel  = integer(entry (2, varstring, chr(9)))
         varvolume = DECIMAL(entry (3, varstring, chr(9)))
      no-error.
      if error-status:error then
      do:
        vError = "Неверный формат файла.".
        leave.
      end.
      if STRING(varcode) = buf_place.loc1
      then do:
        find first tt-tarir where
                   tt-tarir.level = varlevel
             no-lock no-error.
        if avail tt-tarir then
        do:
          vError = substitute("В файле указан повторно уровень &1.", varlevel).
          leave.
        end.
        create tt-tarir.
        assign
           tt-tarir.level  = varlevel
           tt-tarir.volume = varvolume
        .
        vardelta  = DECIMAL(entry (4, varstring, chr(9))) no-error .
        if vardelta = 0 or vardelta = ?
        then do :
          find first ub.place-attr no-lock where ub.place-attr.obj-type = buf_place.obj-type
                                             and ub.place-attr.obj-code = buf_place.obj-code
                                             and ub.place-attr.pl-code = buf_place.pl-code
                                             and ub.place-attr.attr-code = "place-type"
                                             no-error .
          if not available ub.place-attr
          or (available ub.place-attr and ub.place-attr.attr-value = "2")
          then do :
            vardelta = 0.25 .
          end .
          else do :
            vardelta = 0.2 .
          end .
        end .
        tt-tarir.delta  = vardelta .
        vardeltaV = DECIMAL(entry (5, varstring, chr(9))) no-error .
        vardeltaV = round(vardeltaV, 4) no-error .
        if vardeltaV > 0
        then do :
          if vardeltaV >= 10
          then do :
            vError = "Неверный формат значения коэффициента вместимости, неверное кол-во знаков до разделителя.".
            leave.
          end .
          tt-tarir.deltaV  = vardeltaV .
        end .
      end.
   end.
   if vError <> "" then
     return error substitute("&1~nТаблицы не загружены.", vError).
   IF NOT CAN-FIND (FIRST tt-tarir) THEN DO:
      message "В файле нет тарировочной таблицы для резервуара " p-obj-type " " p-obj-code " " p-pl-code " ("  buf_place.loc1 ")."
      skip "Таблицы не загружены."
      view-as alert-box error.
      return.
   END.
   for each tt-tarir
       break by tt-tarir.level
       :
      if first-of (tt-tarir.level) then do:
      end.
      else do:
         if tt-tarir.level <> varprev-level + 1 then do:
            message "Неверно указаны тарировочные таблицы по резервуару " p-pl-code " уровень " tt-tarir.level " идет после уровня " varprev-level " ."
            skip "Во время загрузки тарировочных таблиц были ошибки. Таблицы не загружены."
            view-as alert-box error.
            return error.
         end.
         if tt-tarir.volume <= varprev-level then do:
            message "Неверно указаны тарировочные таблицы по резервуару " p-pl-code " уровень " tt-tarir.level " объем " tt-tarir.volume " идет после уровня " varprev-level " с объемом " varprev-volume " ."
            skip "Во время загрузки тарировочных таблиц были ошибки. Таблицы не загружены."
            view-as alert-box error.
            return error.
         end.
      end.
      assign
         varprev-level  = tt-tarir.level
         varprev-volume = tt-tarir.volume
      .
   end.
   for each  buf_pl-level
       where buf_pl-level.obj-type = buf_place.obj-type
       and   buf_pl-level.obj-code = buf_place.obj-code
       and   buf_pl-level.pl-code  = buf_place.pl-code
       exclusive-lock
       on error undo, return error return-value
   :
     for first buf_pl-level-attr exclusive-lock where buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
                                                  and buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
                                                  and buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
                                                  and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                                  and buf_pl-level-attr.attr-code = "tarir-delta"
                                                  :
       delete buf_pl-level-attr .
     end .
     for first buf_pl-level-attr exclusive-lock where buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
                                                  and buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
                                                  and buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
                                                  and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                                  and buf_pl-level-attr.attr-code = "deltaV"
                                                  :
       delete buf_pl-level-attr .
     end .
     delete buf_pl-level.
   end.
   for each tt-tarir
   :
     create buf_pl-level.
     assign
       buf_pl-level.obj-type = buf_place.obj-type
       buf_pl-level.obj-code = buf_place.obj-code
       buf_pl-level.pl-code  = buf_place.pl-code
       buf_pl-level.pl-level = tt-tarir.level
       buf_pl-level.pl-qnty  = tt-tarir.volume
     .
     find first buf_pl-level-attr exclusive-lock where buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
                                                   and buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
                                                   and buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
                                                   and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                                   and buf_pl-level-attr.attr-code = "tarir-delta"
                                                   no-error .
     if not available buf_pl-level-attr
     then do :
     create buf_pl-level-attr .
       assign
         buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
         buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
         buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
         buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
         buf_pl-level-attr.attr-code = "tarir-delta"
       .
     end .
     assign buf_pl-level-attr.attr-value = string(tt-tarir.delta) .
     if tt-tarir.deltaV > 0
     then do :
       find first buf_pl-level-attr exclusive-lock where buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
                                                     and buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
                                                     and buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
                                                     and buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
                                                     and buf_pl-level-attr.attr-code = "deltaV"
                                                     no-error .
       if not available buf_pl-level-attr
       then do :
       create buf_pl-level-attr .
         assign
           buf_pl-level-attr.obj-type  = buf_pl-level.obj-type
           buf_pl-level-attr.obj-code  = buf_pl-level.obj-code
           buf_pl-level-attr.pl-code   = buf_pl-level.pl-code
           buf_pl-level-attr.pl-level  = buf_pl-level.pl-level
           buf_pl-level-attr.attr-code = "deltaV"
         .
       end .
       assign buf_pl-level-attr.attr-value = string(tt-tarir.deltaV) .
     end .
   end.
end.
message "Импорт завершен успешно."
view-as alert-box.
