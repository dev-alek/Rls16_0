block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: delbtpr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/delbtpr.p $":U .
define variable vss-description as character no-undo init "Удаление зависшей записи Batchprocess для системы архивов".
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
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
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
    if buf_c-trn-doc.status_ <> 'факт':U
    then do:
      message
        substitute("Удаленный документ имеет статус &1 отличный от &2"
                  ,buf_c-trn-doc.status_
                  ,'факт':U
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
      when 'arh':U
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
      when 'ahsp':U
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
      when 'aht':U
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
