block-level on error undo, throw.
/*

$Revision: bb5787071046, 1352, rls $
$Author: SSlivenko $
$Date: Fri May 18 13:28:25 2018 +0300 $
$Workfile: chk-back.p $
$Archive: str/chk-back.p $

Проверка даты документа при закрытии его задним числом

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 12/05/03

*/

define input  parameter p-doc-code  as character no-undo .
define input  parameter p-fact-date as date      no-undo .

define variable vss-revision    as character no-undo initial "$Revision: bb5787071046, 1352, rls $":U .
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo initial "$Date: Fri May 18 13:28:25 2018 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: chk-back.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/chk-back.p $":U .
define variable vss-description as character no-undo initial "Проверка даты документа при закрытии его задним числом".
{ cmp/vssrevis.i "substitute('&1|&2':u,p-doc-code,p-fact-date)" }
{ cmp/trg-def.i  }
{ gbl/clntattr.i }
{ gbl/thbjattr.i }

define buffer buf_trn-doc for ub.trn-doc .

define variable v-cur-date          as date      no-undo .
define variable v-value-character   as character no-undo .
define variable v-date-close-period as date      no-undo .
define variable v-value-decimal     as decimal   no-undo .
define variable v-value-integer     as integer   no-undo .
define variable v-value-logical     as logical   no-undo .
define variable v-value-type        as character no-undo .

do
on error undo, return error return-value
:
  find first buf_trn-doc exclusive-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if not available buf_trn-doc
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" p-doc-code skip
      "Дата" p-fact-date skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if p-fact-date = ?
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не указана дата закрытия документа"
      "Документ" p-doc-code skip
      "Дата" p-fact-date skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  /* проверяем дату закрытого периода */
  for each thbjattr_thbj-attr:
    delete thbjattr_thbj-attr.
  end.

  run adm/shattri.p (
      input "get":U
      ,input buf_trn-doc.obj-type
      ,input buf_trn-doc.obj-code
      ,input {&attr-nakl_par}
      ,input  "date-close-period"
      ,output v-value-character
      ,output v-date-close-period
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
      if error-status :error then v-date-close-period = date('').
      if v-date-close-period <> date('') then do:
          if  p-fact-date < v-date-close-period
          then do:
            return error substitute(
              "Дата закрытия документа &1 более ранняя, чем дата закрытия периода &2
              Дата закрытия документа &3 &2
              Дата закрытия периода &4
              Объект &5 &6     " ,
              buf_trn-doc.doc-code  ,
              {&new-line}  ,
              string ( p-fact-date        , "99/99/9999") ,
              string ( v-date-close-period, "99/99/9999") ,
              buf_trn-doc.obj-type ,
              buf_trn-doc.obj-code
              ) .
          end.
      end.
  /* для внутреннего перемещения */
  if buf_trn-doc.cli-type = {&shop} or buf_trn-doc.cli-type = {&stock}  then do:
      for each thbjattr_thbj-attr:
        delete thbjattr_thbj-attr.
      end.

      run adm/shattri.p (
          input "get":U
          ,input buf_trn-doc.cli-type
          ,input buf_trn-doc.cli-code
          ,input {&attr-nakl_par}
          ,input  "date-close-period"
          ,output v-value-character
          ,output v-date-close-period
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-value-type
          ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
          ) no-error .
          if error-status :error then v-date-close-period = date('').
          if v-date-close-period <> date('') then do:
              if  p-fact-date < v-date-close-period
              then do:
                return error substitute(
                  "Дата закрытия документа &1 более ранняя, чем дата закрытия периода &2
                  Дата закрытия документа &3 &2
                  Дата закрытия периода &4
                  Объект &5 &6     " ,
                  buf_trn-doc.doc-code  ,
                  {&new-line}  ,
                  string ( p-fact-date        , "99/99/9999") ,
                  string ( v-date-close-period, "99/99/9999") ,
                  buf_trn-doc.cli-type ,
                  buf_trn-doc.cli-code
                  ) .
              end.
          end.

  end.
  /* для межфирменного перемещения */
  if buf_trn-doc.hold-obj-type = {&shop} or buf_trn-doc.hold-obj-type = {&stock}  then do:
      for each thbjattr_thbj-attr:
        delete thbjattr_thbj-attr.
      end.

      run adm/shattri.p (
          input "get":U
          ,input buf_trn-doc.hold-obj-type
          ,input buf_trn-doc.hold-obj-code
          ,input {&attr-nakl_par}
          ,input  "date-close-period"
          ,output v-value-character
          ,output v-date-close-period
          ,output v-value-decimal
          ,output v-value-integer
          ,output v-value-logical
          ,output v-value-type
          ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
          ) no-error .
          if error-status :error then v-date-close-period = date('').
      if v-date-close-period <> date('') then do:
      if  p-fact-date < v-date-close-period
      then do:
        return error substitute(
          "Дата закрытия документа &1 более ранняя, чем дата закрытия периода &2
          Дата закрытия документа  &3 &2
          Дата закрытия периода    &4 &2
          Объект &5 &6 "
          ,
          buf_trn-doc.doc-code  ,
          {&new-line}  ,
          string ( p-fact-date, "99/99/9999") ,
          string ( v-date-close-period,   "99/99/9999") ,
                    buf_trn-doc.hold-obj-type ,
                    buf_trn-doc.hold-obj-code  ) .
      end.
  end.
  end.
  /*------*/

  { gbl/curobjdt.i
    buf_trn-doc.obj-type
    buf_trn-doc.obj-code
    v-cur-date
    no-error
  }
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при определении текущей даты на объекте" skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if p-fact-date > v-cur-date
  then do:
    message
      "Нельзя закрыть документ будующим числом" skip
      "Документ" p-doc-code  skip
      "Дата закрытия документа" p-fact-date skip
      "Сегодня" v-cur-date skip
      view-as alert-box error .
    undo, return error return-value .
  end.

  if p-fact-date = v-cur-date
  or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Object}
  then do:
    /* дата равна текущей */
    return .
  end.

  if  p-fact-date < v-cur-date
  and p-fact-date > v-cur-date - 15
  then do:
    define variable v-ok as logical   no-undo .
    message
      "Фактическая дата документа отличается от текущей даты на объекте" skip
      "Это может привести к перерасчету складских архивов за" v-cur-date - p-fact-date "дней" skip
      "Документ" p-doc-code  skip
      "Дата закрытия документа" p-fact-date skip
      "Сегодня" v-cur-date skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      undo, return error "Документ не был закрыт".
    end.
  end.

  if p-fact-date <= v-cur-date - 15
  then do:
    message
      "ВНИМАНИЕ!!!" skip
      "Фактическая дата документа отличается от текущей даты на объекте" skip
      "Количество дней, за которые будут перерассчитаны складские архивы" v-cur-date - p-fact-date skip
      "" skip
      "Такой перерасчет может занять много времени, в течение которого нельзя будет получить отчеты по объекту" skip
      "Документ" p-doc-code  skip
      "Дата закрытия документа" p-fact-date skip
      "Сегодня" v-cur-date skip
      "Продолжить?" skip
      view-as alert-box question buttons yes-no update v-ok .
    if v-ok <> true
    then do:
      undo, return error "Документ не был закрыт".
    end.

    define variable v-permit as logical   no-undo .

    run gbl/authoriz.p
      (input  "Разрешение на закрытие документа с датой более 15 дней назад"
      ,output v-permit
      ) .
    if v-permit <> true
    then do:
      undo, return error "Документ не был закрыт".
    end.
  end.


  define buffer calc-arh-lock_batchprocess for ub.batchprocess .

  run gbl/lock-prc.p
    (input {&lock-prc-calc-arh}
    ,input buf_trn-doc.obj-code
    ,input 0
    ,input 0
    ,input buf_trn-doc.obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Расчет складского архива по товарам"
    ,input true
    ,buffer calc-arh-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент рассчитывается складской архив по товарам" skip
      "Невозможно закрыть документ задним числом" skip
      "Документ" p-doc-code  skip
      "Дата закрытия документа" p-fact-date skip
      "Сегодня" v-cur-date skip
      view-as alert-box error .
    undo, return error "Документ не был закрыт" .
  end.

  define buffer calc-supp-arh-lock_batchprocess for ub.batchprocess .

  run gbl/lock-prc.p
    (input {&lock-prc-calc-supp-arh}
    ,input buf_trn-doc.obj-code
    ,input 0
    ,input 0
    ,input buf_trn-doc.obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Расчет складского архива по поставщикам"
    ,input true
    ,buffer calc-supp-arh-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент рассчитывается складской архив по поставщикам" skip
      "Невозможно закрыть документ задним числом" skip
      "Документ" p-doc-code  skip
      "Дата закрытия документа" p-fact-date skip
      "Сегодня" v-cur-date skip
      view-as alert-box error .
    undo, return error "Документ не был закрыт" .
  end.

  define buffer calc-aht-lock_batchprocess for ub.batchprocess .

  run gbl/lock-prc.p
    (input {&lock-prc-calc-aht}
    ,input buf_trn-doc.obj-code
    ,input 0
    ,input 0
    ,input buf_trn-doc.obj-type
    ,input ""
    ,input ""
    ,input "Объект,,, ,,,Расчет складского архива по типам приобретения"
    ,input true
    ,buffer calc-aht-lock_batchprocess
    ) no-error .
  if error-status :error
  then do:
    message
      vss-workfile vss-revision vss-description skip
      "В данный момент рассчитывается складской архив по типам приобретения" skip
      "Невозможно закрыть документ задним числом" skip
      "Документ" p-doc-code  skip
      "Дата закрытия документа" p-fact-date skip
      "Сегодня" v-cur-date skip
      view-as alert-box error .
    undo, return error "Документ не был закрыт" .
  end.

  define variable v-attr-value as character no-undo .
  define variable v-attr-type  as character no-undo .

  define variable v-ask-sysadm-passwd as logical   no-undo .

  assign
    v-ask-sysadm-passwd = false
  .

  /* проверяем дату начала подробного складского архива по товарам */
  define variable v-arh-detail-date as date      no-undo .

  run clntattr-value in this-procedure
    (input  buf_trn-doc.obj-type    /* p-obj-type */
    ,input  buf_trn-doc.obj-code    /* p-obj-code */
    ,input  {&attr-arh-detail-date} /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .

  if v-attr-type = {&type-date}
  then do:
    assign
      v-arh-detail-date = date(v-attr-value)
    .
  end.

  if  v-arh-detail-date <> ?
  and p-fact-date < v-arh-detail-date
  then do:
    message
      "Дата закрытия документа более ранняя, чем дата начала подробного складского архива по товарам" skip
      "Документ не может быть закрыт указанной датой" skip
      "Документ" p-doc-code  skip
      "Дата закрытия документа" p-fact-date skip
      "Сегодня" v-cur-date skip
      "Дата начала подробного складского архива по товарам" v-arh-detail-date skip
      view-as alert-box error .
    undo, return error "Документ не был закрыт" .
  end.


  /* проверяем дату начала подробного складского архива по поставщикам */
  define variable v-ahsp-detail-date as date      no-undo .

  run clntattr-value in this-procedure
    (input  buf_trn-doc.obj-type     /* p-obj-type */
    ,input  buf_trn-doc.obj-code     /* p-obj-code */
    ,input  {&attr-ahsp-detail-date} /* p-code     */
    ,output v-attr-value             /* p-value    */
    ,output v-attr-type              /* p-type     */
    ) .

  if v-attr-type = {&type-date}
  then do:
    assign
      v-ahsp-detail-date = date(v-attr-value)
    .
  end.

  if  v-ahsp-detail-date <> ?
  and p-fact-date < v-ahsp-detail-date
  then do:
    message
      "Дата закрытия документа более ранняя, чем дата начала подробного складского архива по поставщикам" skip
      "Документ не может быть закрыт указанной датой" skip
      "Документ" p-doc-code  skip
      "Дата закрытия документа" p-fact-date skip
      "Сегодня" v-cur-date skip
      "Дата начала подробного складского архива по поставщикам" v-ahsp-detail-date skip
      view-as alert-box error .
    undo, return error "Документ не был закрыт" .
  end.

  /* проверяем дату начала подробного складского архива по типам приобретения */
  define variable v-aht-detail-date as date      no-undo .

  run clntattr-value in this-procedure
    (input  buf_trn-doc.obj-type    /* p-obj-type */
    ,input  buf_trn-doc.obj-code    /* p-obj-code */
    ,input  {&attr-aht-detail-date} /* p-code     */
    ,output v-attr-value            /* p-value    */
    ,output v-attr-type             /* p-type     */
    ) .

  if v-attr-type = {&type-date}
  then do:
    assign
      v-aht-detail-date = date(v-attr-value)
    .
  end.

  if  v-aht-detail-date <> ?
  and p-fact-date < v-aht-detail-date
  then do:
    message
      "Дата закрытия документа более ранняя, чем дата начала подробного складского архива по типам приобретения" skip
      "Документ не может быть закрыт указанной датой" skip
      "Документ" p-doc-code  skip
      "Дата закрытия документа" p-fact-date skip
      "Сегодня" v-cur-date skip
      "Дата начала подробного складского архива по типам приобретения" v-aht-detail-date skip
      view-as alert-box error .
    undo, return error "Документ не был закрыт" .
  end.
end.