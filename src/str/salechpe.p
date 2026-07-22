block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: salechpe.p $
$Archive: str/salechpe.p $

Проверки при закрытии продажи если установлена опция close-day-period,

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/12/09
Author: Bakhtadze Natalya
Creation date: 10/12/09

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle     as handle no-undo .
define input parameter p-auto as integer no-undo .
define input parameter p-inkas-code as character no-undo .
define output parameter p-continue as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: salechpe.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/salechpe.p $":U .
define variable vss-description as character no-undo init "Проверки при закрытии продажи если установлена опция close-day-period,".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }

{ cmp/doc-list.i doc-list def " new shared " }

define variable v-host-code as integer no-undo .
define variable glog as logical no-undo .
define variable log-file-name as character no-undo .
define variable v-view-log  as logical no-undo .
define variable lns-cnt as integer no-undo .
define variable line-rec as recid no-undo .
define variable p-parent-handle as handle no-undo .
define buffer buf_trn-doc for ub.trn-doc.
define buffer buf_inkas for ub.inkas.
define buffer buf_fbr-doc for ub.fbr-doc.


&glob display-message  run write-log-and-file in p-log-handle ( ~
          input 1 ~
        , input log-file-name ~
        , input 1 ~
        , input ~{&my-message~} ~
                                      )


find first buf_inkas no-lock where
        buf_inkas.inkas-code = p-inkas-code no-error.
if not available buf_inkas then do:
  undo, return error substitute("Не найдена продажа &1", p-inkas-code).
end.


if p-auto = 0 then do:
  log-file-name = 'saleclos.log' .
end.
else do:
  log-file-name = 'ext-sale.log'.
end.

run get-doc-list in this-procedure no-error.


if can-find(first doc-list)  then do:
  case p-auto:
    when 0
    or
    when 1
    then do:
      message
      substitute("Согласно настройкам закрытие продажи ведет к закрытию периода до даты &1,&2" +
                 "Однако на Вашем объекте имеются еще незакрытые документы&2" +
                 "После закрытия продажи эти документы могут быть закрыты только следующим периодом&2&2" +
                 "Ознакомтесь со списком незакрытых документов"
                , (buf_inkas.doc-date +  1)
                , {&new-line}
                )
      view-as alert-box warning.
      { gbl/hostcode.i buf_inkas.obj-type buf_inkas.obj-code v-host-code }
      run str/doc-list.w (
                    input parparentproc
                    ,input v-host-code
                    ,input buf_inkas.obj-type
                    ,input buf_inkas.obj-code
                    ) no-error.
      if error-status:error then do:
        &scop my-message substitute("Ошибка при проверке наличия незакрытых документов")
        {&display-message}.
        return error.
      end.
      else do:
        message
        substitute("Продолжить закрытие продажи невзирая на открытые документы?")
        view-as alert-box question buttons yes-no update glog.
        if glog then do:
          run get-doc-list in this-procedure no-error.
          if can-find(first doc-list) then do:
            &scop my-message substitute("При закрытии продажи на объекте имелись незакрытые документы!")
            {&display-message}.
            p-continue = yes.
            return.
          end. /*if can-find(first doc-list) then do:*/
        end. /*if glog then do:*/
      end. /*if error-status:error then do*/
    end. /*when 0*/
    when 2 then do:
      &scop my-message  substitute("Согласно настройкам закрытие продажи ведет к закрытию периода до даты &1,&2" + ~
                 "Однако на объекте имеются еще незакрытые документы&2" + ~
                 "Закрытие продажи НЕВОЗМОЖНО!" ~
                , (buf_inkas.doc-date +  1) ~
                , ~{&new-line~} ~
                )
      {&display-message}.
    end. /*when 2 then do:*/
  end case.
  { str/cdviewlg.i
  "substitute('!!!В процессе закрытия продажи произошли ошибки!!!')"
  "'saleclos.log'" }
  return "error":U.
end. /*if can-find(first doc-list)  then do:*/
else do:
  p-continue = yes.
end.


procedure get-doc-list :
for each doc-list :
  delete doc-list.
end.

/*
Складские документы, кроме документов с типом «инвентаризация»,
в статусе «накл», «разр», «произв» и датой документа <= дате продажи
*/
for each buf_trn-doc no-lock where
        buf_trn-doc.obj-type = buf_inkas.obj-type
    and buf_trn-doc.obj-code = buf_inkas.obj-code
    and (buf_trn-doc.status_ = {&wayb}
    or
       buf_trn-doc.status_ = {&permitted}
    or buf_trn-doc.status_ = {&manufactured}
       )
    and buf_trn-doc.doc-date <= buf_inkas.doc-date
    :
  if buf_trn-doc.doc-code = p-inkas-code then next.
  if buf_trn-doc.out-code = p-inkas-code then next.
  if buf_trn-doc.doc-type = {&inventory} then do:
    next.
  end.
  { cmp/doc-list.i doc-list assign-trn buf_trn-doc  }
end.
/*
Документы инвентаризации с фактической датой <= дате продажи
в статусе накл и разр
*/
for each buf_trn-doc no-lock where
        buf_trn-doc.obj-type = buf_inkas.obj-type
    and buf_trn-doc.obj-code = buf_inkas.obj-code
    and buf_trn-doc.doc-type = {&inventory}
    and buf_inkas.fact-date <= buf_Inkas.doc-date
    and (buf_trn-doc.status_ = {&wayb}
        or  buf_trn-doc.status_ = {&permitted} ):

  { cmp/doc-list.i doc-list assign-trn buf_trn-doc  }
end.
/*
Документы производства в статусе «новый» и «разр» и датой документа <= дате продажи

*/
for each buf_fbr-doc no-lock where
        buf_fbr-doc.obj-type = buf_inkas.obj-type
    and buf_fbr-doc.obj-code = buf_inkas.obj-code
    and (buf_fbr-doc.status_ = {&permitted}
    or buf_fbr-doc.status_ = {&g___new})
    and buf_fbr-doc.doc-date <= buf_inkas.doc-date:

  { cmp/doc-list.i doc-list assign-fbr-doc buf_fbr-doc  }
end.

end procedure. /* get-doc-list */