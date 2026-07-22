block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: cre-sale.p $
$Archive: str/cre-sale.p $

Создание продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/31/05
Author: Bakhtadze Natalya
Creation date: 10/31/05

*/

define input parameter parparentproc   as widget-handle no-undo .
define input parameter p-curr-obj-type like ub.clients.obj-type no-undo .
define input parameter p-curr-obj-code like ub.clients.obj-code no-undo .
define input parameter p-mode          as character no-undo .
define input parameter v-silent        as character no-undo .
define input parameter p-shift-mode    as character no-undo .
define input-output parameter p-inkas-code    like ub.inkas.inkas-code no-undo .
define input parameter p-create-status like ub.trn-doc.status_ no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: cre-sale.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/cre-sale.p $":U .
define variable vss-description as character no-undo init "Создание продажи".
{ cmp/vssrevis.i }

{ cmp/trg-def.i }
{ str/lib-trn.i }
{ str/doc-code.i }
{ gbl/waitfram.i }
{ str/trdcalib.i }
{ str/cre-sale.i }

DEFINE new SHARED BUFFER    ink-doc FOR ub.inkas.
DEFINE new SHARED BUFFER    X_trn-doc FOR ub.trn-doc.
DEFINE new SHARED QUERY     br-docs FOR ink-doc SCROLLING.
define variable v-doc-rec  as recid no-undo .
define variable v-host-code   like ub.sysconf.host-code no-undo .
define variable glog as logical no-undo .
define variable v-mes as character no-undo .
DEFINE VARiable v-handle as handle no-undo.
define variable next-prev as character no-undo .
define variable v-rid-list as character no-undo .
define buffer buf_shift-obj for ub.shift-obj.

do
on error undo, return error return-value
:
  if p-mode = {&lookup} then do:
    FIND FIRST ink-doc WHERE ink-doc.inkas-code = p-inkas-code  NO-LOCK NO-ERROR.
    if not available ink-doc then do:
      v-mes = substitute("Для &1&2 НЕТ незакрытого отчета о продаже &3"
                         ,p-curr-obj-type
                         ,p-curr-obj-code
                         ,p-inkas-code).
      return v-mes.
    end.
    v-doc-rec = recid (ink-doc).
  end.
  else
      do on stop undo, return error
          on end-key undo, return error :
        if p-mode = {&add-def} then do:
          FIND FIRST ink-doc WHERE
                      ink-doc.status_ = {&g___new}
                  and ink-doc.obj-type = p-curr-obj-type
                  and ink-doc.obj-code = p-curr-obj-code no-lock NO-ERROR.
          if available ink-doc then do:
            if v-silent <> "silent":U then do:
              glog = no.
              message
              substitute("Уже есть один незакрытый отчет на объекте &1&2&3" +
                        "дата &4 дата факт.(ожидается)&5,&3Вы уверены что хотите создать еще один?"
                        , p-curr-obj-type
                        , p-curr-obj-code
                        , {&new-line}
                        , string(ink-doc.doc-date, "99/99/9999")
                        , string(ink-doc.fact-date, "99/99/9999")
                        )
              view-as alert-box QUESTION buttons yes-no update glog.
              if not glog then undo, return error "cancell".
            end.
          end.
          if p-shift-mode = {&select}
          and v-silent = '':U
          and p-mode = {&add-def}
          then do:
            { gbl/hostcode.i p-curr-obj-type p-curr-obj-code v-host-code }
            { gbl/chk-actg.i
              g#db-num
              g#userid
              {&action-head-code-main}
              'actn_sale_create-back-shift':U
              {&cntxt-object}
              v-host-code
              p-curr-obj-type
              p-curr-obj-code
              0
              0
              0
              true
              glog
            }
            if not glog then do:
              return error "cancell".
            end.
            run str/sht-all.w (
                          input parparentproc
                        , INPUT p-curr-obj-type /*p-curr-obj-type*/
                        , input p-curr-obj-code /*p-curr-obj-code*/
                        , input 'b-sel'
                        , input 'obj'
                        , INPUT p-curr-obj-type /*p-obj-type*/
                        , input p-curr-obj-code  /*p-obj-code*/
                        , input '':u
                        , input-output v-rid-list) no-error.
             if v-rid-list = '':U then do:
                return error "cancell".
             end.
             find first buf_shift-obj no-lock where
                      recid(buf_shift-obj) = integer(v-rid-list) .
             if not (buf_shift-obj.obj-type = p-curr-obj-type
                     and
                     buf_shift-obj.obj-code = p-curr-obj-code
                     )
             or not (buf_shift-obj.status_ = {&sht-closed}) then do:
               message
               substitute("Вы должны Выбрать ЗАКРЫТУЮ смену по &1&2"
                          , p-curr-obj-type
                          , p-curr-obj-code)
               view-as alert-box error .
               return error "cancell".
             end.
          end.
          run waitfram-show in this-procedure ("Создание нового отчета о продаже ...").
          RUN cre-docs in this-procedure  (
                                          input (if v-silent = "silent" then 4 else 0) /*p-auto*/
                                        , input p-curr-obj-type
                                        , input p-curr-obj-code
                                        , input (if available buf_shift-obj
                                                 then buf_shift-obj.shift-date
                                                 else ?) /*p-shift-date*/
                                        , input (if available buf_shift-obj
                                                 then buf_shift-obj.shift-num
                                                 else ?)  /*p-shift-num*/
                                        , input "":U /*p-filter-name*/
                                        , input "":U /*p-filter*/
                                        , input "":U /*p-filter-rus*/
                                        , input p-create-status
                                        , output v-doc-rec
                                        ) NO-ERROR.
          if error-status:error then do:
            run waitfram-hide in this-procedure .
            undo, return error return-value .
          end.
          run waitfram-hide in this-procedure .
        end. /*if add-def*/
        else do:
          if p-inkas-code = "":U then do:
            find ink-doc where
                ink-doc.obj-type = p-curr-obj-type
            AND ink-doc.obj-code = p-curr-obj-code
            AND ink-doc.status_ = {&g___new} no-error .
            if AMBIGUOUS ink-doc then do:
              if v-silent <> "silent":U then do:
                message
                substitute("На объекте &1&2 несколько открытых продаж&3" +
                          "воспользуйтесь меню ПРОДАЖА-Список незакрытых продаж"
                          , p-curr-obj-type
                          , p-curr-obj-code
                          , {&new-line})
                view-as alert-box .
                return.
              end.
            end.
            if available ink-doc then do:
              p-inkas-code = ink-doc.inkas-code.
            end.
          end. /*if p-inkas-code = "":U then do:*/
          FIND FIRST ink-doc WHERE
                      ink-doc.inkas-code = p-inkas-code NO-ERROR.
          if not available ink-doc then do:
            v-mes = substitute("Не найден незакрытый отчет на объекте &1&2 с номером &3"
                       , p-curr-obj-type
                       , p-curr-obj-code
                       , p-inkas-code).
            return error v-mes.
          end.
          v-doc-rec = recid (ink-doc).
        end. /*не add-def*/
        DO TRANSACTION:
          FIND FIRST ink-doc WHERE
                      recid(ink-doc) = v-doc-rec EXCLUSIVE-LOCK.
          if p-inkas-code = ?
          or p-inkas-code = '' then do:
            p-inkas-code = ink-doc.inkas-code.
          end.
          if ink-doc.status_ = {&fact} then do:
            v-mes = substitute("Продажа с номером &1 закрыта -изменения невозможны"
                       , p-inkas-code).
            undo, return error v-mes.
          end.
          if ink-doc.status_ = {&inquiry}
          then do:
            v-mes = substitute("Продажа-запрос с номером &1 закрыта -изменения невозможны"
                       , p-inkas-code).
            undo, return error v-mes.
          end.
        END.
      end.

  /*
  в режиме РАСЧЕТ вызывается при закрытии переоценки в магазине
  if list-mode <> "РАСЧЕТ" then
      do:
  */
  if v-silent = "silent" then return ''.
  if p-mode = {&lookup} then do:
    p-mode = {&lookup}.
  end.
  else do:
    p-mode = {&update}.
  end.
  assign
  v-handle = ?
  next-prev = ?.
  run str/sale.w (
                input parparentproc
              , input p-mode
              , input-output v-doc-rec
              , input-output v-handle
              , input-output next-prev
              , buffer ink-doc
              )  NO-ERROR .
end. /*doe*/