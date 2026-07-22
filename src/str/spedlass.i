/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление в ассортиментной матрице товара , который больше нет в спецификации

Автор: Чернова Светлана Александровна
Дата создания: 10/23/08
Author: Svetlana Chernova
Creation date: 10/23/08

*/
&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure spedlass-proc :

define input  parameter parParentProc   as handle no-undo .
define input  parameter p-gds-code      as integer   no-undo .
define input  parameter p-contract-code as integer   no-undo .
define input  parameter p-host-code     as integer   no-undo .
define input  parameter p-ask           as logical   no-undo .
define input-output     parameter v-list-mat as character no-undo .
define input-output     parameter v-err-ext  as logical   no-undo .
define input-output     parameter v-longchar as longchar no-undo .



define buffer buf_contract-specif for ub.contract-specif  .
define buffer buf_contract        for ub.contract  .
define variable v-log as logical   no-undo .
  do
  on error undo, return error return-value
  :
/* Проверим право */

  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr-gds_deletion':U
    {&cntxt-global}
    0
    '':U
    0
    0
    0
    0
    false
    v-log
  }
 if not v-log then return  .

/* Найдем сначала все спецификации */
    for each buf_contract-specif  no-lock where
             buf_contract-specif.gds-code = p-gds-code  and not
           ( buf_contract-specif.contract-num  = p-contract-code and
             buf_contract-specif.host-code     = p-host-code ) ,
            first buf_contract no-lock where
                  buf_contract.contract-code = buf_contract.contract-code and
                  buf_contract.host-code     = buf_contract.host-code    and
                  buf_contract.status_       =  {&current-contr}
                    :
                    return .
    end.

/* MATRIX */
define variable v-ass-m as logical   no-undo init false .

if can-find ( first ub.assortment-matrix no-lock where
                    ub.assortment-matrix.asmt-status = integer ({&current-status-int}))
                    then v-ass-m = true.


if p-ask then do:
    if v-ass-m = true then do:
      message "Удалить товары спецификации из Ассортиментных матриц ?"
              "Если ДА , укажите в каких."
              view-as alert-box question
                      buttons yes-no
                      update v-okk as logical
                      .
      if v-okk then do:
          run ref/assmatr.w (
                input parParentProc
                ,input "b-sel,b-mark"
                ,input v-cntxt-obj-type
                ,input v-cntxt-obj-code
                ,input ?
                ,input ?
                ,input-output v-list-mat
                ) no-error  .
          if error-status :error then message
            vss-workfile vss-revision vss-description skip
            error-status :get-message(1) skip
            return-value skip
            ""
            view-as alert-box error
          .
      end.
    end.
end.

if num-entries(v-list-mat) = 0 then return .

/* перевод ИЖТ на пусто и удаление из АссМатр */
define buffer buf_gds-obj-prop          for ub.gds-obj-prop  .
define buffer buf_assortment-matrix     for ub.assortment-matrix  .
define buffer buf_assortment-matrix-goods for ub.assortment-matrix-goods  .
define variable i as integer   no-undo .
define variable v-sts as integer   no-undo .


repeat i = 1 to num-entries(v-list-mat) :
  find first buf_assortment-matrix no-lock where
             recid(buf_assortment-matrix) = int(entry(i,v-list-mat)) no-error .

  for each buf_assortment-matrix-goods no-lock where
           buf_assortment-matrix-goods.asmt-id  = buf_assortment-matrix.asmt-id and
           buf_assortment-matrix-goods.db-num   = buf_assortment-matrix.db-num  and
           buf_assortment-matrix-goods.gds-code = p-gds-code
           :
    for each buf_gds-obj-prop exclusive-lock where
            buf_gds-obj-prop.obj-type = buf_assortment-matrix.obj-type and
            buf_gds-obj-prop.obj-code = buf_assortment-matrix.obj-code and
            buf_gds-obj-prop.gds-code = buf_assortment-matrix-goods.gds-code
            :
            if not (buf_gds-obj-prop.gdop-igt = {&ass-izd-empty} or
                    buf_gds-obj-prop.gdop-igt = {&ass-izd-del} ) then do:

              v-err-ext = true .
              v-longchar = v-longchar +
              substitute("Принудительная смена ИЖТ &1 на ПУСТО у товара &2 на объекте &3 &4&5" ,
                buf_gds-obj-prop.gdop-igt ,
                buf_gds-obj-prop.gds-code ,
                buf_assortment-matrix.obj-type ,
                buf_assortment-matrix.obj-code , {&new-line} )   .

            assign
              buf_gds-obj-prop.gdop-igt = {&ass-izd-empty}
              .


            end.
    end.

    release buf_gds-obj-prop .
    if buf_assortment-matrix-goods.asmg-status = int({&current-status-int}) then do:
        v-sts = int({&deleted-status-int}) .
         { ref/gds-mat2.i
           this-procedure
           recid(buf_assortment-matrix-goods)
           v-sts
           no
           no-error  }
           if error-status :error then message
              error-status :get-message(1)
              return-value
              "Ошибка изменения статуса товара в ассортиментной матрице" skip
              buf_assortment-matrix-goods.asmg-status  v-sts
              .
    end.
  end.
end.
end.

end procedure. /* spedlass-proc */