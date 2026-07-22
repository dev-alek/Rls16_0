block-level on error undo, throw.
/*

$Revision: e41006018ff7, 3417, rls $
$Author: DRuban $
$Date: 2023/10/16 15:13:30 $
$Workfile: file2clb.p $
$Archive: gbl/file2clb.p $

Копирование файла в CLOB

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/27/07
Author: Bakhtadze Natalya
Creation date: 12/27/07

*/

define input parameter p-mode as character no-undo .
/*
{&lookup} - возвращает поля первичного ключа clob-data

{&add-def} - если поля первичного ключа clob-data заполнены то дописывает новый clob-bind а clob-data не трогает

{&update}
p-clob-mode = override
для имеющегося clob-bind ищет clob-data и проверяет нет ли у него связи с другим владельцем (другой clob-bind)
если другой владелец есть
или (resource-type = lob-res-gate или resource-type= lob-res-upgrade ) и файл измменилс
то создает свой clob-data

p-clob-mode = add-new
для имеющегося clob-bind ищет clob-data и проверяет изменился ли crc
если да то сохраняет clob-data
если нет - не сохраняет

{&deletion}
p-clob-mode = "leave"
ищет clob-bind и удаляет его clob-data не трогает рекомендуется использовать только для resource-type = {&lob-gate} или {&lob-upgrade}

p-clob-mode = "delete"
ищет clob-bind и соответствующий clob-data удаляет clob-bind и clob-data


*/

define input parameter p-clob-mode as character no-undo .
define input parameter p-bh as handle no-undo.
define input parameter p-uniq-key-rec as character no-undo .
define input parameter p-field as character no-undo .
define input parameter p-descr as character no-undo .
define input-output parameter p-part-num as integer no-undo .
define input parameter p-resource-type as character no-undo .

/*если создается новый кусок данных то передавать можно ?  */
define input-output parameter p-clob-db-num as integer no-undo .

/*если создается новый кусок данных то передавать можно 0  */
define input-output parameter p-int64-id as int64 no-undo .


define input parameter p-file as character no-undo .
define input parameter p-encoding as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: e41006018ff7, 3417, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/10/16 15:13:30 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: file2clb.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/file2clb.p $":U .
define variable vss-description as character no-undo init "Копирование файла в CLOB".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/key-rec.i }

define variable v-path             as character no-undo .
DEFINE VARIABLE v-full-path        as character no-undo .
DEFINE VARIABLE v-file-name        as character no-undo .
DEFINE VARIABLE v-file-name-no-ext as character no-undo .
DEFINE VARIABLE v-file-name-ext    as character no-undo .
define variable v-uniq-key-rec     as character no-undo .
define variable v-md5-signature    as character no-undo .
define variable v-part-num         as integer   no-undo .
define variable glog               as logical   no-undo .
define variable v-int64-id         as int64     no-undo .
define variable v-clob-db-num      as integer   no-undo .
define variable v-longchar1        as longchar  no-undo .
define variable v-longchar2        as longchar  no-undo .
define variable v-file-size        as integer   no-undo .
define variable v-save-clob        as logical   no-undo .
define variable v-send-nws         as logical   no-undo .
define buffer buf_clob-data   for ub.clob-data.
define buffer other_clob-data for ub.clob-data.
define buffer other_clob-bind for ub.clob-bind.
define buffer self_clob-bind  for ub.clob-bind.

FUNCTION is-abs-path returns logical ( input p-path-string as character):
    if index(p-path-string, ":") > 0
        or p-path-string begins ({&slash-char} + {&slash-char})
        or p-path-string begins ({&back-slash-char} + {&back-slash-char})
        or (index(p-path-string, {&slash-char}) = 0
        and index(p-path-string, {&back-slash-char}) = 0) then return yes.
    return no.
end function.


do
    on error undo, return error
    :
    if p-mode <> {&deletion} then 
    do:
        run gbl/filename.p (
            input p-file
            ,output v-full-path
            ,output v-path
            ,output v-file-name
            ,output v-file-name-no-ext
            ,output v-file-name-ext
            ) no-error .
        if error-status:error then 
        do:
            return error substitute("Не удается найти файл &1", p-file).
        end.
    end.
    if p-resource-type = {&lob-res-data}
        or ((p-resource-type = {&lob-res-report}
        or p-resource-type = {&lob-res-report-xml})
        and p-bh <> ? )
        then 
    do:
        if p-resource-type = {&lob-res-data} then 
        do:
            run gen-key-rec in this-procedure ( input p-bh:table
                ,input p-bh
                ,output v-uniq-key-rec) no-error .

            if error-status:error then 
            do:
                return error return-value .
            end.
        end.
        else 
        do:
            v-uniq-key-rec = p-uniq-key-rec.
        end.
        if p-bh <> ? then 
        do:
            glog = p-bh:find-current( exclusive-lock) no-error.
            if error-status:error
                or not glog
                then 
            do:
                undo, return error substitute("Не удалось заблокировать &1 для записи файла &2  в CLOB&3&4&3&5"
                    ,v-uniq-key-rec
                    ,p-file
                    ,{&new-line}
                    , error-status:get-message(1)
                    , return-value ).
            end.
        end.
    end.
    else 
    do:
        v-uniq-key-rec = p-uniq-key-rec.
    end.
    if num-entries(p-clob-mode) > 1 then 
    do:
        v-send-nws = logical(entry(2, p-clob-mode)).
        p-clob-mode = entry(1, p-clob-mode).
    end.
    else 
    do:
        v-send-nws = yes.
    end.

    case p-mode :
        when {&lookup} then 
            do:
                find first self_clob-bind  no-lock where
                    self_clob-bind.uniq-key-rec = v-uniq-key-rec
                    and self_clob-bind.field-name = p-field
                    and self_clob-bind.part-num = p-part-num
                    no-error.
                if not available self_clob-bind then 
                do:
                    undo, return error substitute("Не найдена ссылка на CLOB для &1 &2 номер части &3"
                        ,v-uniq-key-rec
                        ,p-field
                        ,p-part-num).
                end.
                find first buf_clob-data  no-lock where
                    buf_clob-data.db-num = self_clob-bind.db-num
                    and buf_clob-data.int64-id = self_clob-bind.int64-id no-error.
                if not available buf_clob-data then 
                do:
                    undo, return error substitute("Не найден CLOB БД &1 id &2 для &3 &4 номер части &5"
                        ,self_clob-bind.db-num
                        ,self_clob-bind.int64-id
                        ,v-uniq-key-rec
                        ,p-field
                        ,p-part-num).
                end.
                assign
                    p-clob-db-num = self_clob-bind.db-num
                    p-int64-id    = self_clob-bind.int64-id
                    .
                return '':U.
            end.
        when {&add-def} then 
            do:
                run gbl/md5.p (
                    input  v-full-path    /* p-file-name     */
                    ,output v-md5-signature /* p-md5-signature */
                    ) no-error .
                if error-status:error then 
                do:
                    undo, return error substitute("&1 &2 &3&4&5&4&6"
                        ,vss-workfile
                        ,vss-revision
                        ,vss-description
                        ,{&new-line}
                        , error-status:get-message(1)
                        , return-value ).

                end.
                assign
                    file-info:file-name = v-full-path.
                v-file-size = file-info:file-size.
                if v-file-size > 100000000 then 
                do:
                    undo, return error substitute("Слишком большой файл &1 (> 100000000Б)", v-full-path).
                end.
                if not (p-clob-db-num = ?
                    and
                    p-int64-id = 0) then 
                do:
                    find first buf_clob-data  share-lock where
                        buf_clob-data.db-num = p-clob-db-num
                        and buf_clob-data.int64-id = p-int64-id no-error.
                    if not available buf_clob-data then 
                    do:
                        undo, return error substitute("Не найден CLOB БД &1 id &2"
                            ,p-clob-db-num
                            ,p-int64-id).
                    end.
                end.
                find last self_clob-bind  no-lock where
                    self_clob-bind.uniq-key-rec = v-uniq-key-rec
                    and self_clob-bind.field-name = p-field no-error.
                if available self_clob-bind
                    and (self_clob-bind.resource-type = {&lob-res-data}
                    or
                    self_clob-bind.resource-type = {&lob-res-report}
                    or
                    self_clob-bind.resource-type = {&lob-res-report-xml}
                    or
                    self_clob-bind.resource-type = {&lob-res-list}
                    or
                    self_clob-bind.resource-type = {&lob-res-list-macro}
                    )
                    then 
                do:
                    assign
                        v-part-num = self_clob-bind.part-num + 1.
                end.
                else 
                do:
                    v-part-num = 1.
                end.
                if not available buf_clob-data then 
                do:
                    create buf_clob-data.
                    assign
                        buf_clob-data.int64-id      = next-value( s-clob-int64, {&db-name_schema})
                        buf_clob-data.db-num        = g#db-num
                        buf_clob-data.crc-field     = v-md5-signature
                        buf_clob-data.file-size     = v-file-size
                        buf_clob-data.encoding      = (if p-encoding <> ?
                               and p-encoding <> ""
                               then p-encoding
                               else "")
                        buf_clob-data.is-cs         = v-send-nws
                        buf_clob-data.resource-type = p-resource-type
                        .
                    buf_clob-data.file-name_ = (if is-abs-path(p-file) then v-file-name else p-file).
                    if p-encoding <> ?
                        and p-encoding <> '':U
                        and p-encoding <> "1251" then 
                    do:
                        COPY-LOB
                            FROM  FILE v-full-path
                            TO  OBJECT v-longchar1
                            no-convert
                            NO-ERROR .
                        if error-status :error then 
                        do:
                            v-longchar1 = '':U.
                            v-longchar2 = '':U.
                            undo, return error substitute("Ошибка при перекодировке файла &1:&2&3"
                                , v-full-path
                                , {&new-line}
                                , error-status:get-message(1) ).
                        end.
                        assign
                            v-longchar2 = codepage-convert(v-longchar1, p-encoding, "1251")
                            .
                        /*        COPY-LOB                      */
                        /*        FROM  object v-longchar2      */
                        /*        TO  OBJECT buf_clob-data.cdata*/
                        /*        No-convert                    */
                        /*        NO-ERROR .                    */
                        buf_clob-data.cdata = v-longchar2 .
                        v-longchar1 = '':U.
                        v-longchar2 = '':U.
                    end.
                    else 
                    do:
                        /*        COPY-LOB                      */
                        /*        FROM  FILE v-full-path        */
                        /*        TO  OBJECT buf_clob-data.cdata*/
                        /*        No-convert                    */
                        /*        NO-ERROR .                    */
                        COPY-LOB
                            FROM  FILE v-full-path
                            TO  OBJECT v-longchar1
                            No-convert
                            NO-ERROR .
                        buf_clob-data.cdata = v-longchar1 .
                    end.
                    if error-status:error then 
                    do:
                        if error-status :error then 
                        do:
                            v-longchar1 = '':U.
                            v-longchar2 = '':U.
                            undo, return error substitute("Ошибка при записи файла в БД&1:&2&3"
                                , v-full-path
                                , {&new-line}
                                , error-status:get-message(1) ).
                        end.
                    end.
                end. /*if not available buf_clob-data then do:*/
                create self_clob-bind.
                assign
                    self_clob-bind.uniq-key-rec  = v-uniq-key-rec
                    self_clob-bind.field-name    = (if p-resource-type = {&lob-res-list}
                                 or p-resource-type = {&lob-res-list-macro}
                                 then substitute("&1-&2", buf_clob-data.db-num, buf_clob-data.int64-id)
                                 else p-field)
                    self_clob-bind.part-num      = v-part-num
                    self_clob-bind.resource-type = p-resource-type
                    self_clob-bind.db-num        = buf_clob-data.db-num
                    self_clob-bind.int64-id      = buf_clob-data.int64-id
                    self_clob-bind.descr         = p-descr
                    p-part-num                   = self_clob-bind.part-num
                    p-clob-db-num                = self_clob-bind.db-num
                    p-int64-id                   = self_clob-bind.int64-id
                    buf_clob-data.file-name_     = (if p-resource-type = {&lob-res-list}
                                or p-resource-type = {&lob-res-list-macro}
                                then  p-resource-type
                                else buf_clob-data.file-name_)
                    .
                run trg/userlog.p (
                    input {&nwsdochs_action_create}
                    , input {&table_clob-bind}
                    , input ( buffer self_clob-bind :handle )
                    , input ?
                    , input ""
                    ) no-error.
                if error-status :error
                    then 
                do:
                    undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                        , {&new-line}
                        , vss-workfile
                        , return-value
                        , error-status :get-message ( 1 ) ).
                end.
                release self_clob-bind no-error.
                if error-status:error then 
                do:
                    undo, return error substitute("&1 &2 &3Ошибки при сохранении связи clob с записью-владельцем &4 &5 &6&7&6&8"
                        ,vss-workfile
                        ,vss-revision
                        ,vss-description
                        ,v-uniq-key-rec
                        ,p-field
                        ,{&new-line}
                        , error-status:get-message(1)
                        , return-value ).

                end.
                release buf_clob-data no-error.
                if error-status:error then 
                do:
                    undo, return error substitute("&1 &2 &3Ошибки при сохранении clob для &6&7&6&8"
                        ,vss-workfile
                        ,vss-revision
                        ,vss-description
                        ,v-uniq-key-rec
                        ,p-field
                        ,{&new-line}
                        , error-status:get-message(1)
                        , return-value ).

                end.
            end.
        when {&update} then 
            do:
                if p-clob-mode <> "override"
                    and p-clob-mode <> "add-new"
                    and p-clob-mode <> "add-new-old-delete"
                    then 
                do:
                    undo, return error  substitute("Неверное значение параметра p-clob-mode = &1", p-clob-mode).
                end.
                v-save-clob = yes.
                run gbl/md5.p (
                    input  v-full-path    /* p-file-name     */
                    ,output v-md5-signature /* p-md5-signature */
                    ) no-error .
                if error-status:error then 
                do:
                    undo, return error substitute("&1 &2 &3&4&5&4&6"
                        ,vss-workfile
                        ,vss-revision
                        ,vss-description
                        ,{&new-line}
                        , error-status:get-message(1)
                        , return-value ).

                end.
                assign
                    file-info:file-name = v-full-path.
                v-file-size = file-info:file-size.
                if v-file-size > 100000000 then 
                do:
                    undo, return error substitute("Слишком большой файл &1 (> 100000000Б)", v-full-path).
                end.
                find first self_clob-bind  exclusive-lock where
                    self_clob-bind.uniq-key-rec = v-uniq-key-rec
                    and self_clob-bind.field-name = p-field
                    and self_clob-bind.part-num = p-part-num
                    no-error.
                if not available self_clob-bind then 
                do:
                    undo, return error substitute("Не найдена ссылка на CLOB для &1 &2 номер части &3"
                        ,v-uniq-key-rec
                        ,p-field
                        ,p-part-num).
                end.
                find first buf_clob-data  share-lock where
                    buf_clob-data.db-num = self_clob-bind.db-num
                    and buf_clob-data.int64-id = self_clob-bind.int64-id no-error.
                if not available buf_clob-data then 
                do:
                    undo, return error substitute("Не найден CLOB БД &1 id &2 для &3 &4 номер части &5"
                        ,self_clob-bind.db-num
                        ,self_clob-bind.int64-id
                        ,v-uniq-key-rec
                        ,p-field
                        ,p-part-num).
                end.
                v-send-nws = buf_clob-data.is-cs.
                if p-clob-mode = "override" then 
                do:
                    for each other_clob-bind no-lock where
                        other_clob-bind.db-num = self_clob-bind.db-num
                        and other_clob-bind.int64-id = self_clob-bind.int64-id :
                        if not (other_clob-bind.uniq-key-rec = self_clob-bind.uniq-key-rec
                            and
                            other_clob-bind.field-name = self_clob-bind.field-name
                            and
                            other_clob-bind.part-num = self_clob-bind.part-num
                            ) then leave.
                    end.
                end.
                if available other_clob-bind
                    or (p-resource-type = {&lob-res-gate}
                    and not (v-md5-signature = buf_clob-data.crc-field
                    and
                    p-file = buf_clob-data.file-name_)
                    )
                    or (p-resource-type = {&lob-res-upgrade}
                    and not (v-md5-signature = buf_clob-data.crc-field
                    and
                    p-file = buf_clob-data.file-name_)
                    )
                    or p-clob-mode = "add-new"
                    or p-clob-mode = "add-new-old-delete"
                    then 
                do:
                    /*уже связан с другим владельцем или вообще менять нельзя нужно создать свой*/
                    create buf_clob-data.
                    assign
                        buf_clob-data.int64-id      = next-value( s-clob-int64, {&db-name_schema})
                        buf_clob-data.db-num        = g#db-num
                        buf_clob-data.crc-field     = v-md5-signature
                        buf_clob-data.file-size     = v-file-size
                        buf_clob-data.encoding      = (if p-encoding <> ?
                              and p-encoding <> ""
                              then p-encoding
                              else "")
                        buf_clob-data.resource-type = p-resource-type
                        v-save-clob                 = yes
                        buf_clob-data.is-cs         = v-send-nws
                        .
                    buf_clob-data.file-name_ = (if is-abs-path(p-file) then v-file-name else p-file).
                end.
                else 
                do:
                    if buf_clob-data.crc-field = v-md5-signature
                        and buf_clob-data.file-name_ = (if is-abs-path(p-file) then v-file-name 
                    else p-file) then 
                    do:
                        v-save-clob = no.
                    end.
                    if v-save-clob then 
                    do:
                        assign
                            buf_clob-data.crc-field  = v-md5-signature
                            buf_clob-data.file-size  = v-file-size
                            buf_clob-data.file-name_ = (if is-abs-path(p-file) then v-file-name else p-file)
                            .
                    end.
                end.
                if v-save-clob then 
                do:
                    if p-encoding <> ?
                        and p-encoding <> '':U
                        and p-encoding <> "1251" then 
                    do:
                        COPY-LOB
                            FROM  FILE v-full-path
                            TO  OBJECT v-longchar1
                            no-convert
                            NO-ERROR .
                        if error-status :error then 
                        do:
                            v-longchar1 = '':U.
                            v-longchar2 = '':U.
                            undo, return error substitute("Ошибка при перекодировке файла &1:&2&3"
                                , v-full-path
                                , {&new-line}
                                , error-status:get-message(1) ).
                        end.
                        assign
                            v-longchar2 = codepage-convert(v-longchar1, p-encoding, "1251")
                            .
                        /*        COPY-LOB                      */
                        /*        FROM  object v-longchar2      */
                        /*        TO  OBJECT buf_clob-data.cdata*/
                        /*        No-convert                    */
                        /*        NO-ERROR .                    */
                        buf_clob-data.cdata = v-longchar2 .
                        v-longchar1 = '':U.
                        v-longchar2 = '':U.
                    end.
                    else 
                    do:
                        /*        COPY-LOB                      */
                        /*        FROM  FILE v-full-path        */
                        /*        TO  OBJECT buf_clob-data.cdata*/
                        /*        No-convert                    */
                        /*        NO-ERROR .                    */
                        COPY-LOB
                            FROM  FILE v-full-path
                            TO  OBJECT v-longchar1
                            No-convert
                            NO-ERROR .
                        buf_clob-data.cdata = v-longchar1 .
                    end.
                    if error-status :error then 
                    do:
                        undo, return error substitute("Ошибка при записи файла в БД&1:&2&3"
                            , v-full-path
                            , {&new-line}
                            , error-status:get-message(1) ).
                    end.
                    assign
                        self_clob-bind.resource-type = p-resource-type
                        self_clob-bind.db-num        = buf_clob-data.db-num
                        self_clob-bind.int64-id      = buf_clob-data.int64-id
                        self_clob-bind.descr         = p-descr
                        p-part-num                   = self_clob-bind.part-num
                        p-clob-db-num                = self_clob-bind.db-num
                        p-int64-id                   = self_clob-bind.int64-id
                        .
                end.
                assign
                    buf_clob-data.file-name_ = (if p-resource-type = {&lob-res-list}
                                or p-resource-type = {&lob-res-list-macro}
                                then  p-resource-type
                                else buf_clob-data.file-name_)
                    .
                release self_clob-bind no-error.
                if error-status:error then 
                do:
                    undo, return error substitute("&1 &2 &3Ошибки при сохранении связи clob с записью-владельцем &4 &5 &6&7&6&8"
                        ,vss-workfile
                        ,vss-revision
                        ,vss-description
                        ,v-uniq-key-rec
                        ,p-field
                        ,{&new-line}
                        , error-status:get-message(1)
                        , return-value ).

                end.
                release buf_clob-data no-error.
                if error-status:error then 
                do:
                    undo, return error substitute("&1 &2 &3Ошибки при сохранении clob для &6&7&6&8"
                        ,vss-workfile
                        ,vss-revision
                        ,vss-description
                        ,v-uniq-key-rec
                        ,p-field
                        ,{&new-line}
                        , error-status:get-message(1)
                        , return-value ).

                end.
                if p-clob-mode = "add-new-old-delete" then 
                do:
                    delete self_clob-bind no-error.
                    if error-status:error then 
                    do:
                        undo, return error substitute("&1 &2 &3Ошибки при удалении связи старого clob с записью-владельцем &4 &5 &6&7&6&8"
                            ,vss-workfile
                            ,vss-revision
                            ,vss-description
                            ,v-uniq-key-rec
                            ,p-field
                            ,{&new-line}
                            , error-status:get-message(1)
                            , return-value ).

                    end.
                end.
            end.
        when {&deletion} then 
            do:
                if p-clob-mode <> "delete"
                    and p-clob-mode <> "leave" then 
                do:
                    undo, return error  substitute("Неверное значение параметра p-clob-mode = &1", p-clob-mode).
                end.
                find first self_clob-bind  exclusive-lock where
                    self_clob-bind.uniq-key-rec = v-uniq-key-rec
                    and self_clob-bind.field-name = p-field
                    and self_clob-bind.part-num = p-part-num
                    no-error.
                if not available self_clob-bind then 
                do:
                    undo, return error substitute("Не найдена ссылка на CLOB для &1 &2 номер части &3"
                        ,v-uniq-key-rec
                        ,p-field
                        ,p-part-num).
                end.
                if self_clob-bind.db-num <> g#db-num
                    and not (p-resource-type = {&lob-res-data}
                    or p-resource-type = {&lob-res-report}
                    or p-resource-type = {&lob-res-report-xml})
                    then 
                do:
                    undo, return error substitute("Нельзя удалить файл, созданный в другой БД").

                end.

                assign
                    v-clob-db-num = self_clob-bind.db-num
                    v-int64-id    = self_clob-bind.int64-id
                    .
                run trg/userlog.p (
                        input {&nwsdochs_action_delete}
                        , input {&table_clob-bind}
                        , input ( buffer self_clob-bind :handle )
                        , input ?
                        , input ""
                        ) no-error.
                if error-status :error
                then 
                do:
                   undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
                            , {&new-line}
                            , vss-workfile
                            , return-value
                            , error-status :get-message ( 1 ) ).
                end.
                delete self_clob-bind no-error .
                if error-status:error then 
                do:
                    undo, return error substitute("&1 &2 &3Ошибки при удалении связи clob с записью-владельцем &4 &5 &6&7&6&8"
                        ,vss-workfile
                        ,vss-revision
                        ,vss-description
                        ,v-uniq-key-rec
                        ,p-field
                        ,{&new-line}
                        , error-status:get-message(1)
                        , return-value ).
                end.
                    
                
                if p-clob-mode  = "delete" then 
                do:
                    find first buf_clob-data exclusive-lock where
                        buf_clob-data.db-num = v-clob-db-num
                        and  buf_clob-data.int64-id  = v-int64-id.
                    delete buf_clob-data no-error. /*no-error потому что должны проверить что нет других ссылко на clob-data*/
                    if error-status:error then 
                    do:
                        undo, return error substitute("&1 &2 &3Ошибки при удалении clob для &6&7&6&8"
                            ,vss-workfile
                            ,vss-revision
                            ,vss-description
                            ,v-uniq-key-rec
                            ,p-field
                            ,{&new-line}
                            , error-status:get-message(1)
                            , return-value ).
                    end.

                end.
                assign
                    p-part-num    = ?
                    p-clob-db-num = ?
                    p-int64-id    = 0
                    .
            end.
        otherwise 
        do:
            undo, return error  substitute("Неверное значение параметра p-mode = &1", p-mode).

        end.
    end case.

end. /*doe*/


procedure cb_set-send-nws :
    define output  parameter p-send-nws as logical   no-undo .

    do
        on error undo, return error return-value
        :
        p-send-nws = v-send-nws.
    end.

end procedure. /* cb_set-send-nws */