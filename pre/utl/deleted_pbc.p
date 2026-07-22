block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: bf04b0e5cfa2, 2256, rls $":U .
define variable vss-author      as character no-undo init "$Author: druban $":U .
define variable vss-date        as character no-undo init "$Date: Wed Dec 25 15:24:01 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: deleted_pbc.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/deleted_pbc.p $":U .
define variable vss-description as character no-undo init "Удаление незакрытых накладных с просроч. платежами и связаными с ними ФО".
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
define variable v-file-name as character no-undo.
define variable v-file-line-str as character initial "" no-undo.
define variable v-lst-del-pbc   as character initial "" no-undo.
define variable v-cnt-line as integer no-undo.
define variable v-num-entry as integer no-undo.
define variable v-i as integer initial 0 no-undo.
define variable v-i1 as integer initial 0 no-undo.
define variable v-i2 as integer initial 0 no-undo.
define variable v-i3 as integer initial 0 no-undo.
define temp-table tt-deleted-pbc no-undo
    field b-str like ub.prod-bc.b-str
    index pi as primary unique b-str
.
procedure proc-mes-err-file-empty:
    message "Внимание!" skip
    "Файл соответствий не содержит значимых данных!" skip(2)
    "Обязательно проверьте:" skip
    "- доп.Бар-коды отделены друг от друга запятыми" skip
    "(кроме запятых не используйте в качестве разделителей кавычки и др. символы!);" skip
    "- доп.Бар-коды не содержат пустых значений или не состоят из одних пробелов;"
    "- под списком доп.Баркодов должна стоять пустая строка!" skip
    "- список соответствий заполняется в файле: deleted_pbc.txt"
    view-as alert-box error.
end procedure.
do:
    v-file-name = "deleted_pbc.txt".
    if search(v-file-name) = ? then
        do:
            message "Внимание!" skip
            "Не найден файл соответствия - deleted_pbc.txt" skip(2)
            "Создайте файл deleted_pbc.txt в рабочей директории и заполните его доп.Баркодами, которые Вы хотите удалить." view-as alert-box error.
            return.
        end.
        input from value(v-file-name).
            repeat:
                import unformatted v-file-line-str.
                v-lst-del-pbc = v-lst-del-pbc + trim(v-file-line-str).
                v-file-line-str = "".
                v-cnt-line = v-cnt-line + 1.
            end.
        input close.
        if v-cnt-line = 0 then
            do:
                run proc-mes-err-file-empty.
                return.
            end.
        v-num-entry = num-entries(v-lst-del-pbc).
        if v-num-entry > 0 then
            do:
                do v-i = 1 to v-num-entry:
                    if trim(entry(v-i, v-lst-del-pbc, ",")) <> "" then
                        do:
                            if not can-find(first tt-deleted-pbc where tt-deleted-pbc.b-str = trim(entry(v-i, v-lst-del-pbc, ","))) then
                                do:
                                    create tt-deleted-pbc.
                                    tt-deleted-pbc.b-str = trim(entry(v-i, v-lst-del-pbc, ",")).
                                    v-i1 = v-i1 + 1.
                                end.
                            else
                                do:
                                    v-i3 = v-i3 + 1.
                                end.
                        end.
                end.
            end.
        else
            do:
                run proc-mes-err-file-empty.
                return.
            end.
    for each tt-deleted-pbc no-lock:
        find first ub.prod-bc where
        ub.prod-bc.b-str = tt-deleted-pbc.b-str exclusive-lock no-error.
        if available ub.prod-bc then
            do:
                v-i2 = v-i2 + 1.
                 delete ub.prod-bc.
            end.
    end.
    if v-i2 = 0 and v-i1 = 0 then
    do:
        run proc-mes-err-file-empty.
        return.
    end.
    if v-i2 = 0 then
        do:
            message "Внмание!" skip
            "Процесс удаления доп.Бар-кодов завершён." skip
            "Из запланированных к удалению - " v-i1 + v-i3 " позиц., " skip
            "удалено - " v-i2 " позиций доп.Бар-кодов." skip(2)
            "Запланированные к удалению поз. доп.Бар-кодов отсутствуют в ТН, возможно они удалены ранее!" view-as alert-box error.
        end.
    if v-i2 <> 0 and v-i1 <> v-i2 then
        do:
            message "Удаление доп.Бар-кодов произведено успешно!" skip
            "Из запланированных к удалению - " v-i1 + v-i3 " позиц., " skip
            if v-i3 = 0 then "" else "исключено повторов - " string(v-i3) "," skip
            "удалено - " v-i2 " позиц. доп. Бар-кодов." skip
            "Не удалось удалить - " (v-i1 - v-i2) " позиц.  доп.Бар-кода,  котор. отсутств. в ТН." skip
            view-as alert-box information.
        end.
    if v-i1 <> 0 and v-i1 = v-i2 then
        do:
            message "Удаление дополнительных Бар-кодов произведено успешно!" skip
            "Из запланированных к удалению - " v-i1 + v-i3 " позиц.," (if v-i3 = 0 then "" else " исключено повторов - " + string(v-i3) + ",") " удалено - " v-i2 " позиц. доп.Бар-кодов." view-as alert-box information.
        end.
end.
