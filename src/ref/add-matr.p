block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: add-matr.p $
$Archive: ref/add-matr.p $

Автоматическое добавление нового товара в ассортиментные матрицы

Автор: Чернова Светлана Александровна
Дата создания: 07/12/05
Author: Svetlana Chernova
Creation date: 07/12/05

*/
define input  parameter parParentProc  as widget-handle no-undo.
define input  parameter p-gds-code as integer   no-undo .

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: add-matr.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/add-matr.p $":U .
define variable vss-description as character no-undo init "Автоматическое добавление нового товара в ассортиментные матрицы".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ ref/gds-matl.i }
{ str/ascorrm.i  }
{ gbl/assmatat.i }   /* Библиотека для работы с атрибутами АМ */
{ gbl/thbj-def.i }
{ ref/ass-mat.i &DEF_PROC=YES}    /* Процедуры и функции для работы с АМ (по задаче "Процент отклонения матрицы от шаблона") */


define variable  p-obj-type    like ub.clients.obj-type no-undo .
define variable  p-obj-code    like ub.clients.obj-code no-undo .
define variable  p-mode        as character   no-undo .
define variable  p-sts         as integer   no-undo .
define variable  p-rid-list    as  character no-undo .
define variable v-db-num       as integer   no-undo .
define variable v-kol          as integer   no-undo .
define variable p-without-obj-host-code as integer   no-undo .
/*  */
DEFINE VARIABLE cError  as CHARACTER NO-UNDO INITIAL "".
DEFINE VARIABLE iDelta  as INTEGER   NO-UNDO INITIAL 0.

v-err-ext = false  .
v-longchar = "".

{ gbl/curdbnum.i v-db-num }
p-sts = integer ({&current-status-int}) .

if v-db-num <> 0 then do :
   if not can-find ( first assortment-matrix no-lock where  assortment-matrix.asmt-status = integer ({&current-status-int}) and
                                                            assortment-matrix.db-num = v-db-num )  then return .
end.
else do:
   if not can-find ( first assortment-matrix no-lock where  assortment-matrix.asmt-status = integer ({&current-status-int}))  then return .
end.
define variable v-log as logical   no-undo .
/* Проверка прав */
  { gbl/chk-actg.i
    v-cntxt-db-num
    v-cntxt-userid
    {&action-head-code-main}
    'actn_assort-matr-gds_add-def':U
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


 p-without-obj-host-code = v-cntxt-host-code-obj .
 p-obj-type              = v-cntxt-obj-type .
 p-obj-code              = v-cntxt-obj-code .


run ref/assmatr.w (
  input parParentProc
 ,input "b-sel,b-mark"
 ,input p-obj-type
 ,input p-obj-code
 ,input p-mode
 ,input p-sts
 ,input-output p-rid-list    ) no-error .
 if error-status :error then
 message
   vss-workfile vss-revision vss-description skip
   error-status :get-message(1) skip
   return-value skip
   "Список Ассортиментных матриц - assmatr.w"
   view-as alert-box error
 .

 v-kol = num-entries (p-rid-list).
if v-kol = 0  then do:
message "Не выбрана ни одна ассортиментная матрица !"
  "Внести товар в Ассортиментную матрицу можно в одноименном справочнике ."
  view-as alert-box information .
  return .
end.

define variable v-i as integer   no-undo .
define buffer buf_assortment-matrix for assortment-matrix.
define variable p-doc-rec  as recid no-undo .

repeat v-i = 1 to v-kol :
  find first  buf_assortment-matrix no-lock where recid(buf_assortment-matrix) = integer (entry(v-i,p-rid-list )) no-error .
  if available buf_assortment-matrix then do:
  if buf_assortment-matrix.asmt-status <> integer ({&current-status-int})   then do: message substitute("АМ &1 - удалена , в нее добавлять товар нельзя !" ,  buf_assortment-matrix.asmt-name , buf_assortment-matrix.db-num-obj ) view-as alert-box information . next. end.
  if v-db-num <> 0 and
     (( buf_assortment-matrix.asmt-type = {&type-assmatr-obj}     and buf_assortment-matrix.db-num-obj         <> v-db-num ) or
      ( buf_assortment-matrix.asmt-type = {&type-assmatr-shablon} and buf_assortment-matrix.asmt-db-num-create <> v-db-num ))
      then do:
        message substitute("АМ &1 чужой БД &2 , в нее добавлять товар нельзя !" ,  buf_assortment-matrix.asmt-name , buf_assortment-matrix.db-num-obj ) view-as alert-box information .
        next.
      end.
      /* Cюда добавляем проверку на % отклонения матрицы от шаблона !!!  */
      /* Проверку производимто только если товара нет в АМ  */
      IF NOT Is-Gds-In-AssMatr(p-gds-code,
                               buf_assortment-matrix.asmt-id,
                               buf_assortment-matrix.db-num) THEN DO:
         /* Снимаем параметры АМ   */
         RUN Get-Gl-Param-Proc-Otkl in THIS-PROCEDURE(
             buf_assortment-matrix.asmt-id,
             buf_assortment-matrix.db-num,
             OUTPUT cError
             ).
         if cError <> "" THEN DO:
             v-err-ext = true .
             v-longchar = v-longchar +
                          PROGRAM-NAME(1) + ":" + cError +
                          substitute("&1 &2 &3 " ,  buf_assortment-matrix.asmt-name , buf_assortment-matrix.db-num-obj, {&new-line})
                          .
             NEXT.
         END.
         /* Проверка допустимого % отклонения (Добавляется 1 товар )  */
         RUN Cntrl-AM-Add-1 IN THIS-PROCEDURE(
            1,
            OUTPUT cError
            ).
         /*  */
         if cError <> "" THEN DO:
             v-err-ext = true .
             v-longchar = v-longchar +
                          PROGRAM-NAME(1) + ":" + cError +
                          substitute("&1 &2 &3 " ,  buf_assortment-matrix.asmt-name , buf_assortment-matrix.db-num-obj, {&new-line})
                          .
             NEXT.
         END.
      END.

     { ref/gds-mat1.i
          this-procedure
          p-doc-rec
          {&add-def}
          buf_assortment-matrix.asmt-id
          buf_assortment-matrix.db-num
          p-gds-code
          "''"
          no-error }
          if error-status :error then do:
           v-err-ext = true .
           v-longchar = v-longchar + return-value + {&new-line} .
          end.
  end.
end.

if v-err-ext = true  then do:
define variable v-ok as logical   no-undo .
  run gbl/d-longchar.w (
        ?,
        'Editor_row=2\':u
      + 'title=При добавлении в Ассортиментные матрицы\':u
      + 'Editor_col=1\':u
      + 'Editor_width=96\':u
      + 'Editor_height=21\':u
      + 'readonly=yes\':u
    ,input-output v-longchar
    ,output v-ok ) no-error .
    v-longchar = "" .
    { ref/clearlm.i }

end.