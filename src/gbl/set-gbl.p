block-level on error undo, throw.
/*

$Revision: 6eb2e10e43c1, 3410, rls $
$Author: DRuban $
$Date: 2023/08/17 10:18:56 $
$Workfile: set-gbl.p $
$Archive: gbl/set-gbl.p $

Инициализация глобальных переменных

Автор: Перваков Михаил Сергеевич
Дата создания: 04/18/06
Author: Mikhail Pervakov
Creation date: 04/18/06

*/

using ibs.th.gbl.*.

define input  parameter p-auto-value  as logical   no-undo .
define input  parameter p-user-id     as character no-undo .
define input  parameter p-user-passwd as character no-undo .

define variable vss-revision    as character no-undo init "$Revision: 6eb2e10e43c1, 3410, rls $":U .
define variable vss-author      as character no-undo init "$Author: DRuban $":U .
define variable vss-date        as character no-undo init "$Date: 2023/08/17 10:18:56 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: set-gbl.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/set-gbl.p $":U .
define variable vss-description as character no-undo init "Инициализация глобальных переменных".
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

  /* текущая дата всегда с сервера */
  assign
    session :time-source = "ub"
  .

  find first buf_sys-ctrl no-lock
    no-error .
  if not available buf_sys-ctrl
  then do:
    message
      "Невозможно определить номер базы данных" skip
      "Не найдена запись sys-ctrl" skip
      "Невозможно продолжить работу системы" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  /* проверяем, что запись sys-ctrl единственная */
  find first buf_other-sys-ctrl no-lock
    where rowid(buf_other-sys-ctrl) <> rowid(buf_sys-ctrl)
    no-error .
  if available buf_other-sys-ctrl
  then do:
    message
      "Невозможно определить номер базы данных" skip
      "Найдено более одной записи sys-ctrl" skip
      "Невозможно продолжить работу системы" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  assign
    g#auto           = p-auto-value
    g#news           = false
    g#news-source-db = -1
    g#db-num         = buf_sys-ctrl.db-num
    g#userid         = p-user-id
    g#passwd         = p-user-passwd
  .
  
  def var gblVarObj as class gbl-var.
  gblVarObj = new gbl-var().
  gblVarObj:InitObj (g#auto, g#news-source-db, g#db-num, g#userid, g#passwd, g#esys).
  delete object gblVarObj no-error.

  /* считываем параметр: язык ядра системы */
  /* сравниваем его с языком, использованием для создания *.r кодов */
  define new global shared var g#language as character no-undo .

  assign
    g#language = buf_sys-ctrl.language
  .
  release buf_sys-ctrl.
  if g#language <> 'eng':U
    and g#language <> 'rus':U
  then do:
    assign
      v-msg = substitute( "&1. Неправильное значение параметра &2&3Должно быть &4 или &5", vss-workfile, "language":U, {&new-line}, 'eng':U, 'rus':U )
    .
    
    if g#news <> true then do:
      message
        vss-workfile vss-revision vss-description skip
        v-msg skip
        view-as alert-box error .
    end.
    undo, return error v-msg .
  end.

  if g#language <> "{&language}"
  then do:
    assign
      v-msg = substitute( "&1. Incorrect version of str-glbl.i or incorrect value of &2 paramater&3Check str-glbl.i &2&3 Check language parameter &4":U, vss-workfile, "language":U, {&new-line}, g#language )
    .
    if g#news <> true then do:
      message
        vss-workfile vss-revision vss-description skip
        v-msg skip
        view-as alert-box error .
    end.
    undo, return error v-msg .
  end.
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