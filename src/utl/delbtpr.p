block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: delbtpr.p $
$Archive: utl/delbtpr.p $

Удаление "зависшей" записи Batchprocess для системы архивов

Автор: Чернова Светлана Александровна
Дата создания: 07/23/08
Author: Svetlana Chernova
Creation date: 07/23/08

Автор1: Перваков Михаил Сергеевич
Дата создания: 05/04/06

*/


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: delbtpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/delbtpr.p $":U .
define variable vss-description as character no-undo init "Удаление зависшей записи Batchprocess для системы архивов".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

define variable v-doc-code  as character no-undo .
define variable v-obj-type  as character no-undo .
define variable v-obj-code  as integer   no-undo .
define variable v-fact-date as date      no-undo .
define variable v-ok        as logical   no-undo .

define buffer buf_batchprocess for ub.batchprocess .
define buffer buf_c-trn-doc    for ub.c-trn-doc .

define stream sout .

do
on error undo, return error return-value
:
  define variable v-bptr-recid as integer   no-undo .

  run gbl/d-prompt.w (
      'title=':u + "Введите номер записи BathProcess" + '\':u
    + 'text1=':u + "Введите номер записи BathProcess" + '\':u
    + 'format=>,>>>,>>>,>>9\':u
    + 'type=int\':u
    ,input-output v-bptr-recid
    ).
  if return-value = 'false':u
  then do:
    return .
  end.

  main_block:
  do transaction
  on error undo, return error return-value
  :
    find first buf_batchprocess exclusive-lock
      where recid(buf_batchprocess) = v-bptr-recid
      no-error .
    if not available buf_batchprocess
    then do:
      message
        substitute("Не найдена запись batchprocess с номером &1"
                  ,v-bptr-recid
                  ) skip
        view-as alert-box error .
      undo main_block, return error return-value .
    end.

    find first buf_c-trn-doc exclusive-lock
      where buf_c-trn-doc.doc-code = buf_batchprocess.charkey_one
      no-error .
    if not available buf_c-trn-doc
    then do:
      message
        "Не найден удаленный документ для записи batchprocess" skip
        "Возможно задан неправильный номер записи batchprocess" skip
        view-as alert-box error .
      undo main_block, return error return-value .
    end.

    if buf_c-trn-doc.status_ <> {&fact}
    then do:
      message
        substitute("Удаленный документ имеет статус &1 отличный от &2"
                  ,buf_c-trn-doc.status_
                  ,{&fact}
                  ) skip
        "Возможно задан неправильный номер записи batchprocess" skip
        view-as alert-box error .
      undo main_block, return error return-value .
    end.

    assign
      v-doc-code  = buf_c-trn-doc.doc-code
      v-obj-type  = buf_c-trn-doc.obj-type
      v-obj-code  = buf_c-trn-doc.obj-code
      v-fact-date = buf_c-trn-doc.fact-date
    .

    case buf_batchprocess.bp_type
    :
      when {&btpr-type-arh}
      then do:
        message
          substitute("Удалить запись batchprocess с номером &1"
                    ,v-bptr-recid
                    ) skip
          substitute("Номер документа &1"
                    ,v-doc-code
                    ) skip
          substitute("Складской архив по товарам будет помечен для перерасчета с даты &1"
                    , string(v-fact-date, '99/99/9999':U)
                    ) skip
          "Продолжить?"
          view-as alert-box question buttons yes-no update v-ok .
        if v-ok <> true
        then do:
          undo main_block, return error return-value .
        end.

        output stream sout to delbtpr.txt append .
        export stream sout string(today, '99/99/9999':U) "delete batchprocess" v-obj-type v-obj-code v-fact-date v-doc-code .
        export stream sout buf_batchprocess .
        output stream sout close .

        delete buf_batchprocess .

        run trg/markarh.p
          (input  v-obj-type
          ,input  v-obj-code
          ,input  v-fact-date
          ,input  v-doc-code
          ) .
      end.
      when {&btpr-type-ahsp}
      then do:
        message
          substitute("Удалить запись batchprocess с номером &1"
                    ,v-bptr-recid
                    ) skip
          substitute("Номер документа &1"
                    ,v-doc-code
                    ) skip
          substitute("Складской архив по поставщикам будет помечен для перерасчета с даты &1"
                    , string(v-fact-date, '99/99/9999':U)
                    ) skip
          "Продолжить?"
          view-as alert-box question buttons yes-no update v-ok .
        if v-ok <> true
        then do:
          undo main_block, return error return-value .
        end.

        output stream sout to delbtpr.txt append .
        export stream sout string(today, '99/99/9999':U) "delete batchprocess" v-obj-type v-obj-code v-fact-date v-doc-code .
        export stream sout buf_batchprocess .
        output stream sout close .

        delete buf_batchprocess .

        run trg/markahsp.p
          (input  v-obj-type
          ,input  v-obj-code
          ,input  v-fact-date
          ,input  v-doc-code
          ) .
      end.
      when {&btpr-type-aht}
      then do:
        message
          substitute("Удалить запись batchprocess с номером &1"
                    ,v-bptr-recid
                    ) skip
          substitute("Номер документа &1"
                    ,v-doc-code
                    ) skip
          substitute("Складской архив по типам приобретения будет помечен для перерасчета с даты &1"
                    , string(v-fact-date, '99/99/9999':U)
                    ) skip
          "Продолжить?"
          view-as alert-box question buttons yes-no update v-ok .
        if v-ok <> true
        then do:
          undo main_block, return error return-value .
        end.

        output stream sout to delbtpr.txt append .
        export stream sout string(today, '99/99/9999':U) "delete batchprocess" v-obj-type v-obj-code v-fact-date v-doc-code .
        export stream sout buf_batchprocess .
        output stream sout close .

        delete buf_batchprocess .

        run trg/markaht.p
          (input  v-obj-type
          ,input  v-obj-code
          ,input  v-fact-date
          ,input  v-doc-code
          ) .
      end.
      otherwise do:
        message
          substitute("Неизвестный тип записи batchprocess &1"
                    ,buf_batchprocess.bp_type
                    ) skip
          view-as alert-box error .
        undo main_block, return error return-value .
      end.

    end case .
  end.

  message
    "Запись batchprocess успешно удалена"
    view-as alert-box information .
end.