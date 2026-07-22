
/*

    Процедуры создания, изменения и удаления путевых листов.

 */

{ cmp/str-glbl.i }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }

procedure update-or-create-travel-sheet:
    def input-output param p-rec-id      as recid    no-undo. /* номер ПЛ, 0 - для создания, тогда возвратит для созданного */
    def input param p-ts-num      as char     no-undo. /* № путевого листа */
    def input param p-ts-date     as date     no-undo. /* дата ПЛ */
    def input param p-pf          as decimal  no-undo. /* разрешенный налив */
    def input param p-fuel-code   as int      no-undo. /* код топлива */
    def input param p-card-code   as char     no-undo. /* код карты */
    def input param p-stat        as logical  no-undo. /* статус */

    def buffer buf_cd-doc   for ub.cd-doc.
    def buffer buf_goods    for ub.goods.
    def buffer buf_dis-card for ub.dis-card.

    if p-fuel-code = 0 then
        return error "Топлево не указано".

    if trim(p-card-code) = "" then
        return error "Дисконтная карта не указана".

    if p-pf = 0 then
        return error "Разрешенный налив должен быть больше 0".

    if trim(p-ts-num) = "" then
        return error "Номер ПЛ не должен быть пустым".

    for each buf_cd-doc no-lock
        where buf_cd-doc.CharKey_One = p-ts-num
        and buf_cd-doc.doc-type = {&travel-sheet}
        and buf_cd-doc.obj-code = v-cntxt-obj-code
        and buf_cd-doc.obj-type = v-cntxt-obj-type
        and recid(buf_cd-doc) <> p-rec-id:

            return error "уже есть ПЛ с номером " + p-ts-num.
    end.

    find first buf_goods no-lock
        where buf_goods.gds-code = p-fuel-code
        no-error.
    if not avail buf_goods then
        return error "не удалось найти топливо по gds коду = " + string(p-fuel-code).

    find first buf_dis-card no-lock
        where buf_dis-card.d-card = p-card-code
        no-error.
    if not avail buf_dis-card then
        return error "не удалось найти дисконтную карту".

    if p-rec-id = 0 then do:
        create buf_cd-doc.
        assign
            buf_cd-doc.Key#_One = 0
        .
    end.
    else do:
        find first buf_cd-doc
            where recid(buf_cd-doc) = p-rec-id
            no-error.

        if not avail buf_cd-doc then /* если не найдена */
            return error "Не найдена запись с recid = " + string(p-rec-id).

        if buf_cd-doc.doc-type <> {&travel-sheet} then /* не путевой лист */
            return error "Запись с recid = " + string(p-rec-id) + " не является ПЛ".

        if buf_cd-doc.Key#_One = 1 then /* закрытый документ */
            return error "Документ с recid = " + string(p-rec-id) + " переведен в статус Закрыт, изменение не возможно".

    end.

    assign
        buf_cd-doc.obj-type     = v-cntxt-obj-type      when p-rec-id = 0
        buf_cd-doc.obj-code     = v-cntxt-obj-code      when p-rec-id = 0
        buf_cd-doc.pos-type     = ""                    when p-rec-id = 0
        buf_cd-doc.doc-type     = {&travel-sheet}       when p-rec-id = 0
        buf_cd-doc.doc-code     = string(next-value(s-file-num-2)) when p-rec-id = 0

        buf_cd-doc.datekey_one  = p-ts-date       when p-ts-date <> ?
        buf_cd-doc.CharKey_One  = p-ts-num        when p-ts-num <> ?
        buf_cd-doc.CharKey_Two  = p-card-code     when p-card-code <> ?
        buf_cd-doc.Key#_Two     = p-fuel-code     when p-fuel-code <> ?
        buf_cd-doc.DecKey_One   = p-pf            when p-pf <> ?
        buf_cd-doc.Key#_One     = integer(p-stat) when p-stat <> ?
    .

    p-rec-id = recid(buf_cd-doc).
end.


procedure delete-travel-sheet:
    def input param p-rid as recid no-undo.

    def buffer buf_cd-doc for       ub.cd-doc.
    def buffer buf_cd-doc-line for  ub.cd-doc-line.

    find first buf_cd-doc share-lock
        where recid(buf_cd-doc) = p-rid
        no-error.

    if not avail buf_cd-doc then
        return error "Запись для удаления не найдена, recid = " + string(p-rid).

    for each buf_cd-doc-line no-lock
        where buf_cd-doc-line.doc-type = {&travel-sheet}
        and buf_cd-doc-line.doc-code = buf_cd-doc.doc-code
        and buf_cd-doc-line.obj-code = buf_cd-doc.obj-code
        and buf_cd-doc-line.obj-type = buf_cd-doc.obj-type
        :
            return error "Нельзя удалять путевые листы, для которых есть данные о заправках".
    end.

    delete buf_cd-doc.
end.