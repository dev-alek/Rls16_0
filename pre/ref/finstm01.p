block-level on error undo, throw.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define input parameter p-mode as character no-undo .
define input parameter p-close-mode as character no-undo .
define input parameter p-host-code           like ub.fin-statement.host-code            no-undo . define input parameter p-sttm-code           like ub.fin-statement.sttm-code            no-undo . define input parameter p-curr-code           like ub.fin-statement.curr-code            no-undo . define input parameter p-doc-date            like ub.fin-statement.doc-date             no-undo . define input parameter p-bank-date           like ub.fin-statement.doc-date             no-undo . define input parameter p-fact-date           like ub.fin-statement.fact-date            no-undo . define input parameter p-fins-doc-type       like ub.fin-statement.fins-doc-type        no-undo . define input parameter p-fins-ext-doc-type   like ub.fin-statement.fins-ext-doc-type    no-undo . define input parameter p-code-bank           like ub.fin-statement.code-bank            no-undo . define input parameter p-bank-name           like ub.fin-statement.bank-name            no-undo . define input parameter p-bank-city           like ub.fin-statement.bank-city            no-undo . define input parameter p-bik                 like ub.fin-statement.bik                  no-undo . define input parameter p-code-schet          like ub.fin-statement.code-schet           no-undo . define input parameter p-r-schet             like ub.fin-statement.r-schet              no-undo . define input parameter p-c-schet             like ub.fin-statement.c-schet              no-undo . define input parameter p-cli-name            like ub.fin-statement.cli-name             no-undo . define input parameter p-prn-doc-code        like ub.fin-statement.prn-doc-code         no-undo . define input parameter p-PS                  like ub.fin-statement.PS                   no-undo . define input parameter p-sum-doc             like ub.fin-statement.sum-doc              no-undo . define input parameter p-start-sum-doc-th    like ub.fin-statement.start-sum-doc-th     no-undo . define input parameter p-start-sum-doc       like ub.fin-statement.start-sum-doc        no-undo . define input parameter p-in-sum-doc          like ub.fin-statement.in-sum-doc           no-undo . define input parameter p-out-sum-doc         like ub.fin-statement.out-sum-doc          no-undo . define input parameter p-end-sum-doc         like ub.fin-statement.end-sum-doc          no-undo . define input parameter p-num-docs            like ub.fin-statement.num-docs             no-undo . define input parameter p-start-date          like ub.fin-statement.start-date           no-undo . define input parameter p-end-date            like ub.fin-statement.end-date             no-undo .
define input parameter p-status_ like ub.fin-statement.status_ no-undo .
define input parameter p-status-date like ub.fin-statement.doc-date no-undo .
define output parameter p-correct as logical no-undo .
define output parameter p-err-mess as character no-undo .
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: finstm01.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/finstm01.p $":U .
define variable vss-description as character no-undo init "Проверка выписки типа standard-sttm".
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
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable v-dopi as integer no-undo .
define variable v-reason as character no-undo .
define variable v-author as character no-undo .
define buffer buf_fin-statement for ub.fin-statement.
define buffer buf_sysconf for ub.sysconf.
procedure standard-sttm-gen :
define input parameter p-close-mode as character no-undo .
define output parameter p-correct as logical no-undo .
define variable accum-in-rubl as decimal no-undo .
define variable accum-in-base as decimal no-undo .
define variable accum-in-doc as decimal no-undo .
define variable accum-out-rubl as decimal no-undo .
define variable accum-out-base as decimal no-undo .
define variable accum-out-doc as decimal no-undo .
define buffer buf_fin-statement-line for ub.fin-statement-line.
do
on error undo, return error
:
  find first buf_sysconf no-lock where
            buf_sysconf.host-code = p-host-code .
  if p-status_ = 'факт':U then do:
    if p-prn-doc-code = "":U then do:
      assign
      p-err-mess = "Не заполнен номер выписки"
      .
      return "prn-doc-code":U.
    end.
  end.
  if v-author = 'cl-bank':U
  then do:
    if p-bik = "":U then do:
      assign
      p-err-mess = "Не заполнен БИК БАНКА"
      .
          message p-err-mess skip
              "Закрывать выписку ? "
              view-as alert-box question
              buttons yes-no
              title "ВНИМАНИЕ !!!"
              update v-ok3 as logical.
          if not v-ok3 then do:
             return "bik":U.
          end.
    end.
    if p-r-schet = "":U then do:
      assign
      p-err-mess = "Не заполнен р/с БАНКА"
      .
      return "r-schet":U.
    end.
    if p-bank-name = "":U then do:
      assign
      p-err-mess = "Не заполнен банк"
      .
      return "bank-name":U.
    end.
  end.
  if p-close-mode = '<закрытие документа>':U
  then do:
    if (p-fact-date <> ? and p-doc-date > p-fact-date)
    or (p-status-date <> ? and p-doc-date > p-status-date and (p-status_ = 'факт':U))
      then do:
      assign
      p-err-mess = "Дата факт не может быть меньше даты составления выписки".
      return "fact-date":U.
    end.
    if (p-fact-date <> ? and p-bank-date > p-fact-date)
    or (p-status-date <> ? and p-bank-date > p-status-date and (p-status_ = 'факт':U))
      then do:
      assign
      p-err-mess = "Дата факт не может быть меньше даты прохождения выписки в банке".
      return "fact-date":U.
    end.
    if p-bank-date <> ? and (p-end-date > p-bank-date)
    or (p-status-date <> ? and p-end-date > p-status-date and (p-status_ = 'факт':U))
    then do:
      assign
      p-err-mess = "Дата прохождения выписка в банке не может быть меньше даты конца выписки".
      return "bank-date":U.
    end.
    if p-fact-date <> ? and (p-end-date > p-fact-date)
    or (p-status-date <> ? and p-end-date > p-status-date and (p-status_ = 'факт':U))
    then do:
      assign
      p-err-mess = "Дата факт не может быть меньше даты конца выписки".
      return "fact-date":U.
    end.
  end.
  assign
  p-correct = yes
  .
  for each buf_fin-statement-line no-lock where
          buf_fin-statement-line.host-code = p-host-code
      AND buf_fin-statement-line.sttm-code = p-sttm-code
      AND buf_fin-statement-line.fin-doc-code > 0
      :
    assign
    accum-in-doc  = accum-in-doc    + (if buf_fin-statement-line.fin-ext-doc-type = 'ппп':U
                                      then buf_fin-statement-line.sum-doc
                                      else 0)
    accum-out-doc  = accum-out-doc  + (if buf_fin-statement-line.fin-ext-doc-type = 'рпп':U
                                      then buf_fin-statement-line.sum-doc
                                      else 0)
    .
  end.
  if accum-in-doc > p-in-sum-doc
  then do:
    assign
    p-err-mess = "Сумма по приходным документам выписки в TH больше суммы приходов в выписке по данным банка".
    return "in-sum-doc":U.
  end.
  if accum-out-doc > p-out-sum-doc
  then do:
    p-err-mess = "Сумма по расходным документам выписки в TH больше суммы расходов в выписке по данным банка".
    return "out-sum-doc":U .
  end.
  if p-in-sum-doc - p-out-sum-doc <> p-sum-doc then do:
    p-err-mess = "Суммы приходных и расходных оборотов не равны общей сумме обротов по данным банка".
    return  "":U .
  end.
  if p-start-sum-doc  + p-in-sum-doc - p-out-sum-doc <> p-end-sum-doc then do:
    p-err-mess = "Суммы приходных и расходных оборотов, сложенных с суммой входящего остатка не равны исходящему остатку в выписке по данным банка".
    return "":U .
  end.
end.
end procedure.
do
on error undo, return error
:
  assign
  v-author = (if num-entries(p-mode, chr(4)) > 1
            then entry(2, p-mode, chr(4))
            else '':U)
  p-mode = entry(1, p-mode, chr(4))
  .
  run standard-sttm-gen in this-procedure ( input p-close-mode, output p-correct) no-error .
  if error-status:error then do:
    return "Ошибка в процедуре проверки валидности выписки".
  end.
  else do:
    if p-correct = no then return return-value.
  end.
  assign
  p-correct = yes
  .
end.
