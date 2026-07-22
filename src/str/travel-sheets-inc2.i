
/*

    Процедуры создания, изменения и удаления путевых листов.

 */

procedure create-travel-sheet-line:
    def input param p-travel-sheet-recid as recid no-undo. /* recid путевого листа */
    def input param p-vol as decimal no-undo. /* объем */
    def input param p-doc-code as char no-undo. /* код чека */
    def input param p-rfn as char no-undo. /* номер p-rfn */
    def input param p-stat as logical no-undo. /* статус, TRUE - фактический налив, FALSE - зарезервированный */
    def output param p-rec-id as recid no-undo. /* recid созданной линии */

    def buffer buf_chk-doc for ub.chk-doc.
    def buffer buf_cd-doc for ub.cd-doc.
    def buffer buf_cd-doc-line for ub.cd-doc-line.

    def var line-num as int no-undo init 0. /* для подсчета номера линии */
    def var head-fact as dec no-undo init 0. /* для подсчета фактич. налива в шапке */
    def var head-blocked as dec no-undo init 0. /* заблокированный объем для шапки */
    def var for-del as logical no-undo init false.

    p-rec-id = 0.

    if p-vol = 0 then
        return error "Объем не может быть равным 0".

    if p-doc-code = "" and p-stat then
        return error "Чек не указан".

  /*  if p-stat then do :
      find first buf_chk-doc no-lock
          where buf_chk-doc.doc-code = p-doc-code
          no-error.
      if not avail buf_chk-doc then
          return error "Не удалось найти чек по doc-code = " + p-doc-code.
    end.    */

    find first buf_cd-doc
        where recid(buf_cd-doc) = p-travel-sheet-recid
        no-error.
    if not avail buf_cd-doc then
        return error "Не удалось найти cd-doc по recid = " + string(p-travel-sheet-recid).

    if buf_cd-doc.Key#_One = 1 then
        return error "Путевой лист закрыт".

    if p-rfn = ? then p-rfn = "".

    for each buf_cd-doc-line
        where buf_cd-doc-line.obj-code = buf_cd-doc.obj-code
        and buf_cd-doc-line.obj-type = buf_cd-doc.obj-type
        and buf_cd-doc-line.doc-code = buf_cd-doc.doc-code
        and buf_cd-doc-line.doc-type = {&travel-sheet}:

            for-del = false.

            /* если РФН не пуст и указан в линии и линия заблокирована */
            if p-rfn <> "" and buf_cd-doc-line.CharKey_Two = p-rfn and buf_cd-doc-line.Key#_One = 0 then
                for-del = true.
            /* или линия заблокирована */
            else if buf_cd-doc-line.Key#_One = 0 then
                for-del = true.

            if for-del then
                delete buf_cd-doc-line.
            else do:
                /* счетаем заблокированный объем */
                if buf_cd-doc-line.DecKey_One = 0 then
                    head-blocked = head-blocked + buf_cd-doc-line.DecKey_One.
                /* счетаем фактический объем */
                else
                    head-fact = head-fact + buf_cd-doc-line.DecKey_One.

                /* находим максимальную линию документа */
                line-num = buf_cd-doc-line.line-num.
            end.
    end.

    line-num = line-num + 1.

    if p-stat then /* факт */
        head-fact = head-fact + p-vol.
    else /* заблокир. */
        head-blocked = head-blocked + p-vol.

    buf_cd-doc.DecKey_Two = head-fact.
    buf_cd-doc.DecKey_Three = head-blocked.

    /* если больше разрешенного объемаs получается по наливам, то закрываем ПЛ */
    if head-fact >= buf_cd-doc.DecKey_One then
        buf_cd-doc.Key#_One = 1.

    create buf_cd-doc-line.
    assign
        buf_cd-doc-line.doc-type = {&travel-sheet}
        buf_cd-doc-line.doc-code = buf_cd-doc.doc-code
        buf_cd-doc-line.obj-code = buf_cd-doc.obj-code
        buf_cd-doc-line.obj-type = buf_cd-doc.obj-type
        buf_cd-doc-line.pos-type = ""
        buf_cd-doc-line.line-num = line-num
        buf_cd-doc-line.DecKey_One = p-vol.
        buf_cd-doc-line.CharKey_Two = p-rfn.
        buf_cd-doc-line.CharKey_Three = p-doc-code.
        buf_cd-doc-line.Key#_One = integer(p-stat).
    .

    p-rec-id = recid(buf_cd-doc-line).
end.