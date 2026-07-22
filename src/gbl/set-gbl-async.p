block-level on error undo, throw.
/*

$Revision: b30922a289ff, 3175, rls $
$Author: EShklyar $
$Date: 2022/12/27 12:54:24 $
$Workfile: set-gbl-async.p $
$Archive: gbl/set-gbl-async.p $

»нициализаци€ глобальных переменных

јвтор: ѕерваков ћихаил —ергеевич
ƒата создани€: 04/18/06
Author: Mikhail Pervakov
Creation date: 04/18/06

*/

define input  parameter p-auto-value  as logical   no-undo .
define input  parameter p-user-id     as character no-undo .
define input  parameter p-user-passwd as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: b30922a289ff, 3175, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: 2022/12/27 12:54:24 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: set-gbl-async.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/set-gbl-async.p $":U .
define variable vss-description as character no-undo init "»нициализаци€ глобальных переменных".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }


do
on error undo, return error return-value
:

  define variable v-msg as character no-undo .
  define variable conf-par as character no-undo .
  define variable par-type as character no-undo .

  define buffer buf_sys-ctrl       for ub.sys-ctrl .
  define buffer buf_other-sys-ctrl for ub.sys-ctrl .

  /* текуща€ дата всегда с сервера */
  assign
    session :time-source = "ub"
  .

  find first buf_sys-ctrl no-lock
    no-error .
/*  if not available buf_sys-ctrl
  then do:
    message
      "Ќевозможно определить номер базы данных" skip
      "Ќе найдена запись sys-ctrl" skip
      "Ќевозможно продолжить работу системы" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  /* провер€ем, что запись sys-ctrl единственна€ */
  find first buf_other-sys-ctrl no-lock
    where rowid(buf_other-sys-ctrl) <> rowid(buf_sys-ctrl)
    no-error .
  if available buf_other-sys-ctrl
  then do:
    message
      "Ќевозможно определить номер базы данных" skip
      "Ќайдено более одной записи sys-ctrl" skip
      "Ќевозможно продолжить работу системы" skip
      view-as alert-box error .
    undo, return error return-value .
  end.
  */
  assign
    g#auto           = p-auto-value
    g#news           = false
    g#news-source-db = -1
    g#userid         = p-user-id
    g#passwd         = p-user-passwd
    g#db-num         = buf_sys-ctrl.db-num
    no-error 
 .

  /* считываем параметр: €зык €дра системы */
  /* сравниваем его с €зыком, использованием дл€ создани€ *.r кодов */
  define new global shared var g#language as character no-undo .

  assign
    g#language = entry(1, buf_sys-ctrl.language, {&delim-par} ) no-error
  .
  release buf_sys-ctrl.
  if not p-user-passwd begins "nocrypt:"
  then do:
    { gbl/conf-rd.i
        "'oxmlthon':u"
        "'':u"
        "'':u"
        0
        "'':u"
        "'':u"
        "'':u"
        no
        conf-par
        par-type
        no-error
    }
    if error-status :error
    then do:
        assign
            g#oxml = no
        .
    end.
    else do:
        if par-type = {&type-log}
        and conf-par = 'yes':u
        then do:
            assign
                g#oxml = yes
            .
        end.
        else do:
            assign
                g#oxml = no
            .
        end.
    end.
end.
end.