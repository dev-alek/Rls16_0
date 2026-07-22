using Progress.Lang.*.
using ibs.th.bge.mercury.*.
block-level on error undo, throw.
class ibs.th.bge.mercury.Journal :
  define public variable tth_journal-merc as handle no-undo.
  define public variable bh_journal-merc as handle no-undo.
  define buffer buf_esys-all-attr for ub.esys-all-attr.
  define variable        v-subject        as character no-undo.
  define variable        v-status         as character no-undo.
  define variable        v-db-num         as integer   no-undo.
  define variable        v-user           as character no-undo.
  define temp-table tt_journal-merc no-undo
    field jou-who     as character LABEL "Кто отправил"       format "X(30)"
    field jou-time    as datetime  LABEL "Во сколько"         FORMAT "99.99.99 HH:MM"
    field jou-subject as character LABEL "Какой запрос"       format "X(25)"
    field jou-status  as character LABEL "Состояние запроса"  format "X(20)"
    field jou-param   as character LABEL "UUID ВСД"           format "X(38)"
    field jou-code    as character LABEL "Код запроса"        format "X(38)"
    field piIndex     as character
    index tt_journal-egais is primary jou-code ascending.
  method public handle GetHndlTable(input date1 as datetime, input date2 as datetime):
  empty temp-table tt_journal-merc .
  for each buf_esys-all-attr where buf_esys-all-attr.table-name = "esys-pck-sent"
                               and buf_esys-all-attr.attr-code  = "mercury"
                               and datetime (buf_esys-all-attr.key4) >= date1
                               and datetime (buf_esys-all-attr.key4) <= date2 no-lock:
    create tt_journal-merc.
    v-subject = "Some".
    if buf_esys-all-attr.key2 = 1 then do:
      v-subject = "Запрос ВСД по UUID".
    end.
    if buf_esys-all-attr.key2 = 2 then do:
      v-subject = "Запрос на гашение ВСД".
    end.
    if buf_esys-all-attr.key8 <> "" then do:
      find first ub.user-account where ub.user-account.user-id = buf_esys-all-attr.key8 no-error.
      v-user = ub.user-account.last-name + ' ' + ub.user-account.first-name + ' ' + ub.user-account.second-name .
    end.
    assign
      tt_journal-merc.jou-who = v-user
      tt_journal-merc.jou-code = buf_esys-all-attr.key7
      tt_journal-merc.jou-time = datetime (buf_esys-all-attr.key4)
      tt_journal-merc.jou-subject = v-subject
      tt_journal-merc.jou-status = buf_esys-all-attr.key3
      tt_journal-merc.jou-param = replace(buf_esys-all-attr.attr-value,chr(4),'|')
      tt_journal-merc.piIndex = table-name + string (key1) + string (key2) + string (key3) + string (key4) + string (key5) + string (key6) +
      string (key7) + string (key8) + attr-code.
    .
  end.
  return buffer tt_journal-merc:handle.
  end.
end class.
