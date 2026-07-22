block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: gds-mat1.p $
$Archive: ref/gds-mat1.p $

Общая процедура для изменений и добавлений товара в Ассортиментную матрицу

Автор: Чернова Светлана Александровна
Дата создания: 03/23/05
Author: Svetlana Chernova
Creation date: 03/23/05

	Last change:  NIA  18 Mar 2011    2:42 pm
*/
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: gds-mat1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/gds-mat1.p $":U .
define variable vss-description as character no-undo init "Общая процедура для изменений и добавлений товара в Ассортиментную матрицу".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ gbl/cur-time.i }
{ cmp/gds-list.i gds-list def "new shared"  }
{ cmp/obj-list.i new }
{ ref/gds-ind1.i }
{ ref/assgrpmt.i }
{ ref/gds-matl.i }
{ cmp/library.i  }
{ str/asstroth.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable v-db-num-obj like ub.db.db-num no-undo .
define variable p-ask as logical   no-undo .
/*  */
/* Включен ли модуль Взаиморасчеты  */
DEFINE VARIABLE l_Is-Fin_This-Procedure            as LOGICAL    NO-UNDO INITIAL FALSE.
/* Есть ли право "добавление товаров в матрицу без договора "  */
DEFINE VARIABLE l_Is-Add-no-gds_This-Procedure     as LOGICAL    NO-UNDO INITIAL FALSE.
DEFINE VARIABLE c_Error_This-Procedure             as CHARACTER  NO-UNDO INITIAL "".


define stream LogStream.


if valid-handle (g#lib-Matrix)
and g#lib-Matrix <> this-procedure :handle
and g#lib-Matrix :get-signature('lib-Matrix_testproc':u) <> ""
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Попытка повторной загрузки библиотеки" skip
    g#lib-Matrix skip
    g#lib-Matrix :type skip
    g#lib-Matrix :file-name skip
    valid-handle(g#lib-Matrix) skip
    this-procedure :handle skip
    this-procedure :type skip
    this-procedure :file-name skip
    valid-handle(this-procedure) skip
    view-as alert-box error .
  undo, return error return-value .
end.
else do:
  assign
    g#lib-Matrix = this-procedure :handle
  .
end.

if this-procedure :persistent <> true
then do:
  message
    vss-workfile vss-revision vss-description skip
    "Ошибка запуска библиотеки" program-name(1) skip
    "Попытка запустить ее как обычную процедуру" skip
    view-as alert-box error .
end.

/* Устанавливаем значения переменных  */
RUN Set_Variable_This-Procedure IN THIS-PROCEDURE.


on delete of this-procedure do:
  assign
    g#lib-Matrix = ?
  .
end.

procedure lib-Matrix_testproc :

end.

/***********
            Проверка наличия товара в какой нибудь спецификации Contract-specif
            Пока проверяем так !!!
***********/
FUNCTION Is-Goods-in-Cont-Spec RETURN LOGICAL(
         INPUT p-iGds-Code as INTEGER
         ):
   DEFINE BUFFER Spec FOR ub.Contract-Specif.
   RETURN (CAN-FIND (FIRST Spec WHERE Spec.Gds-code = p-iGds-Code NO-LOCK)).
END FUNCTION.


/***********
            Процедура установки значений переменных
            l_Is-Fin_This-Procedure
            l_Is-Add-no-gds_This-Procedure
            c_Error_This-Procedure
**********/
PROCEDURE Set_Variable_This-Procedure:
   DEFINE VARIABLE is-finvalue   as CHARACTER NO-UNDO INITIAL "".
   DEFINE VARIABLE is-fintype    as CHARACTER NO-UNDO INITIAL "".
   DEFINE VARIABLE v-Db-Num      as INTEGER   NO-UNDO INITIAL 0.

   /* Первоначальный сброс на всякий случай !!!  */
   ASSIGN
      l_Is-Fin_This-Procedure         = FALSE
      l_Is-Add-no-gds_This-Procedure  = FALSE
      c_Error_This-Procedure          = ""
      .
   /*  */
   /* Снимаем настройки is-fin  */
   { gbl/conf-rd.i
          "'is-fin'"
          "''"
          "''"
          0
          "''"
          "''"
          "''"
          no
          is-finvalue
          is-fintype
          no-error
   }
   /*  */
   ASSIGN
      l_Is-Fin_This-Procedure =  LOGICAL(is-finvalue)
      NO-ERROR.
   /* Пока ошибку не обрабатываем ?! */
   if ERROR-STATUS:ERROR THEN DO:
   END.

   /* Если включен модуль взаиморасчеты -
      Проверка права на добавление товара в матрицу без договора !!!
      "actn_assort-matr_add-no-gds"
   */
   if l_Is-Fin_This-Procedure THEN DO:
      /* Текущий номер базы  */
      { gbl/curdbnum.i v-db-num }
      /* Установка переменной права пользователя  */
      { gbl/chk-actg.i
            v-db-num
            g#userid
            {&action-head-code-main}
            'actn_assort-matr_add-no-gds':U
            {&cntxt-global}
            0
            '':U
            0
            0
            0
            0
            false
            l_Is-Add-no-gds_This-Procedure
      }
      /* Сохраняем значение сообщения о проверке прав  */
      if NOT l_Is-Add-no-gds_This-Procedure  THEN DO:
         ASSIGN
            c_Error_This-Procedure = RETURN-VALUE.
      END.
      /*  */
   END.
   /*  */
   RETURN.
END PROCEDURE.


procedure main_gds-mat1 :

define input  parameter p-handle as handle no-undo .
define input-output parameter p-doc-rec   as recid no-undo.
define input parameter p-mode             as character no-undo .
define input parameter p-id               like ub.assortment-matrix.asmt-id   no-undo .
define input parameter p-db-num           like ub.assortment-matrix.db-num    no-undo .
define input parameter p-gds-code         like ub.assortment-matrix-goods.gds-code  no-undo .
define input parameter p-des              like ub.assortment-matrix-goods.asmg-des  no-undo .

  do
  on error undo, return error return-value
  :

if p-mode <> {&add-def} AND p-mode <> {&update}  then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.

{ gbl/curdbnum.i v-db-num }

define variable v-date as date no-undo .
define variable v-time as integer no-undo .
define buffer buf_assortment-matrix for ub.assortment-matrix .
define buffer new_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer old_assortment-matrix-goods for ub.assortment-matrix-goods  .
define buffer buf_goods for ub.goods  .
define variable v-flaf as logical   no-undo .
v-flaf = false .


find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .

find first buf_assortment-matrix no-lock where
           buf_assortment-matrix.asmt-id =  p-id       and
           buf_assortment-matrix.db-num  =  p-db-num no-error .
           if error-status :error then return error error-status :get-message(1)  .


run cur-time in this-procedure(output v-date, output v-time).

  if p-mode = {&add-def} then do:
     /* При добавлении товара в матрицу - делаем все проверки */
     if l_Is-Fin_This-Procedure                          /* Включен модуль взаиморасчеты  */
        AND (NOT Is-Goods-in-Cont-Spec(p-gds-code))      /* товара нет ни в одной из спецификаций  */
        AND (l_Is-Add-no-gds_This-Procedure <> TRUE )    /* и нет права у пользователя на добавление такого товара  */
        THEN DO:
        /*  */
        RETURN ERROR c_Error_This-Procedure + {&new-line} + "Код товара (gds-code)=" + STRING(p-gds-code).
     END.
  /*  */
  find first new_assortment-matrix-goods exclusive-lock where
             new_assortment-matrix-goods.gds-code           = p-gds-code and
             new_assortment-matrix-goods.asmt-id            = p-id       and
             new_assortment-matrix-goods.db-num             = p-db-num
             no-error .

        if available new_assortment-matrix-goods then do:
            if new_assortment-matrix-goods.asmg-status  = 0 then p-mode = {&update} .
            else do:
                run ass-grp-gds-code-yes (
                    input  p-gds-code   ,
                    input  buf_goods.grp-code ,
                    input  p-id         ,
                    input  p-db-num     ,
                    output p-ask        ) no-error .
                    if error-status :error  or p-ask = false  then do:
                        /* message substitute ( "Нельзя добавлять товар &1 &2 в Ассортиментную матрицу &3(&4) из-за ограничения по ассортименту в группе" ,buf_goods.gds-code  , buf_goods.gds-name, p-id ,p-db-num   ) skip
                        return-value skip
                        error-status :get-message(1)
                        view-as alert-box information .
                        */
                        return error substitute ( "Нельзя добавлять товар &1 &2 в Ассортиментную матрицу &3(&4) из-за ограничения по ассортименту в группе &5 &6 " ,buf_goods.gds-code  , buf_goods.gds-name , p-id ,p-db-num , return-value , {&new-line} ).
                    end.
            end.
            assign
              new_assortment-matrix-goods.asmg-date-update   = v-date
              new_assortment-matrix-goods.asmg-db-num-update = g#db-num
              new_assortment-matrix-goods.asmg-status        = 0
              new_assortment-matrix-goods.asmg-time-update   = v-time
              new_assortment-matrix-goods.asmg-who-update    = g#userid
              new_assortment-matrix-goods.asmt-id            = p-id
              .
        end.
        else do:
            run  ass-grp-gds-code-yes (
                input  p-gds-code   ,
                input  buf_goods.grp-code ,
                input  p-id         ,
                input  p-db-num     ,
                output p-ask        ) no-error .
                if error-status :error  or p-ask = false  then do:
                  /*message substitute("Нельзя добавлять товар &1 &2 в Ассортиментную матрицу &3(&4) из-за ограничения по ассортименту в группе", buf_goods.gds-code  ,buf_goods.gds-name  , p-id ,p-db-num ) skip
                    return-value skip error-status :get-message(1)
                    view-as alert-box information .
                    */
                    return error substitute (
                    "Нельзя добавлять товар &1 &2 в Ассортиментную матрицу &3(&4) из-за ограничения по ассортименту в группе &5&6", buf_goods.gds-code  ,buf_goods.gds-name  , p-id ,p-db-num , return-value , {&new-line}  ).
                end.

            create ub.assortment-matrix-goods.
            assign
              ub.assortment-matrix-goods.asmg-date-create   = v-date
              ub.assortment-matrix-goods.asmg-date-update   = v-date
              ub.assortment-matrix-goods.asmg-db-num-create = g#db-num
              ub.assortment-matrix-goods.asmg-db-num-update = g#db-num
              ub.assortment-matrix-goods.asmg-status        = 0
              ub.assortment-matrix-goods.asmg-time-create   = v-time
              ub.assortment-matrix-goods.asmg-time-update   = v-time
              ub.assortment-matrix-goods.asmg-who-create    = g#userid
              ub.assortment-matrix-goods.asmg-who-update    = g#userid
              ub.assortment-matrix-goods.asmt-id            = p-id
              ub.assortment-matrix-goods.db-num             = p-db-num
              ub.assortment-matrix-goods.gds-code           = p-gds-code
              ub.assortment-matrix-goods.asmg-des           = p-des
              .
              FIND FIRST  new_assortment-matrix-goods exclusive-lock  where
                  new_assortment-matrix-goods.asmt-id  = p-id and
                  new_assortment-matrix-goods.db-num   = p-db-num   no-error .
        end.
        p-doc-rec = recid(new_assortment-matrix-goods)   .
  end.
  /* Изменение товара в матрице  */
  else do:
    FIND FIRST  new_assortment-matrix-goods exclusive-lock where
         recid (new_assortment-matrix-goods) = p-doc-rec No-ERROR.
    if not available new_assortment-matrix-goods then do:
       message
        vss-workfile vss-revision vss-description skip
        "Не найдена запись - p-doc-rec" p-doc-rec
        view-as alert-box error .
        undo, return error '':u.
    end.
    if new_assortment-matrix-goods.asmt-id <> p-id
    then do:
      message
        vss-workfile vss-revision vss-description skip
        "Для уже имеющейся записи нельзя изменить"
        "внутренний код" skip
        view-as alert-box ERROR.
        undo, return error '':U.
    end.
    if new_assortment-matrix-goods.asmg-status <> 0 then v-flaf = true .
  end.

  assign
    new_assortment-matrix-goods.asmg-des    = p-des
    new_assortment-matrix-goods.asmg-status = 0
  .

  if v-flaf or p-mode = {&add-def} then do:
      /*
      run recalc-gds-assgrp
        (  /* пересчет после удаления или внесения товара в матрицу */
          input  '+'  ,
          input  buf_goods.gds-code  ,
          input  buf_goods.grp-code  ,
          input  p-id      ,
          input  p-db-num  ) no-error .
          */
  end.

end. /*doe*/


if p-mode = {&add-def} then do:
    run chg-izt-proc
    ( p-gds-code,
      buffer buf_assortment-matrix )
      no-error .
      if error-status :error then do:
      /*
      message
        vss-workfile vss-revision vss-description skip
        return-value
        error-status :get-message(1)  skip
        "Ошибка при изменении ИЖТ товара "
        view-as alert-box error .
        */
      end.
end.

  define variable v-econom as logical   no-undo .
  v-econom = false .
  run econom-mode in p-handle  (output v-econom ) no-error .
  if not v-econom  then do: /* Запускаем Трансляцию */
     run translate-to-other-gds (
          p-id       ,
          p-db-num   ,
          p-gds-code ,
          0 ) .
       if v-longchar-asstro <> "" then do:
         run correct-message in p-handle  (input v-longchar-asstro ) no-error .
         v-longchar-asstro =  "".
       end.
  end.

end procedure. /* main_gds-mat1 */


procedure chg-izt-proc :
/* смена ИЖТ */
define input     parameter p-gds-code                   as integer   no-undo .
define parameter buffer buf_assortment-matrix for ub.assortment-matrix .

define buffer buf_goods for ub.goods.
define variable v-gds-prop-recid as recid no-undo .

  do
  on error undo, return error return-value
  :

  if buf_assortment-matrix.obj-type <> "" and buf_assortment-matrix.obj-type <> ? then do:
        run gds-ind1
            ( input-output v-gds-prop-recid
            ,  p-gds-code
            ,  buf_assortment-matrix.obj-type
            ,  buf_assortment-matrix.obj-code
            , {&ass-izd-new}
            , ?
            , ?
            , ?
            , ?
            , ?
            )  no-error .
            if error-status :error then do:
                message vss-workfile vss-revision vss-description skip
                  error-status :get-message(1) skip
                  return-value
                  skip "Ошибка внутр. процедуры gds-ind1"
                  view-as alert-box error .
            end.
  end.
  end.
end procedure. /* chg-izt-proc */


procedure main_gds-mat2 :
/* Изменение статуса строки(товара) ассортиментной матрицы */
  define input parameter p-handle as handle no-undo .
  define input parameter p-recid  as recid  no-undo.
  define input-output parameter p-asmg-status like ub.assortment-matrix-goods.asmg-status no-undo .
  define input parameter p-mess as logical   no-undo . /* задавать вопросы */

  do
  on error undo, return error return-value
  :
define buffer bf-assortment-matrix-goods for ub.assortment-matrix-goods.

define variable loc#log as logical no-undo .
define variable choice as logical no-undo .
define variable v-old-asmg-status like ub.assortment-matrix-goods.asmg-status no-undo .
define variable v-db-num as integer   no-undo .

{ gbl/curdbnum.i v-db-num }
define buffer buf_goods for ub.goods  .
define variable v-gds-code as integer   no-undo .
define variable v-id       as integer   no-undo .
define variable v-db-num1  as integer   no-undo .

find first bf-assortment-matrix-goods exclusive-lock where
           recid(bf-assortment-matrix-goods) = p-recid.

  v-id       = bf-assortment-matrix-goods.asmt-id .
  v-db-num1   = bf-assortment-matrix-goods.db-num  .

find first buf_goods no-lock where buf_goods.gds-code = bf-assortment-matrix-goods.gds-code no-error .
 v-gds-code  = buf_goods.gds-code .
 choice = true .

define buffer buf_assortment-matrix for ub.assortment-matrix .
find first buf_assortment-matrix no-lock where
           buf_assortment-matrix.asmt-id =  bf-assortment-matrix-goods.asmt-id and
           buf_assortment-matrix.db-num  =  bf-assortment-matrix-goods.db-num
           no-error .
           if error-status :error then return error error-status :get-message(1)  .

v-old-asmg-status = bf-assortment-matrix-goods.asmg-status.
if p-asmg-status = ? then do:
  CASE v-old-asmg-status:
    when integer({&current-status-int}) then do:
      assign
      p-asmg-status = integer({&deleted-status-int}).
    end.
    when integer({&deleted-status-int}) then do:
      assign
      p-asmg-status = integer({&current-status-int}).
    end.
  END CASE.
end.

CASE p-asmg-status:
  WHEN integer({&current-status-int}) then do:
    if integer({&current-status-int}) = bf-assortment-matrix-goods.asmg-status  then do:
      if p-mess then message "Запись уже имеет статус ТЕКУЩИЙ!"
                              view-as alert-box ERROR.
      p-asmg-status = ?.
      return error.
    end.
    else do:
      if p-mess then do:
          message  "Запись уже удалена - восстановить?"
                   view-as alert-box QUestion buttons YEs-no update choice.
       end.
    end.
  end.
  WHEN integer({&deleted-status-int}) then do:
    if integer({&deleted-status-int}) = bf-assortment-matrix-goods.asmg-status  then do:
      if p-mess then message "Запись уже имеет статус УДАЛЕН!"
                              view-as alert-box ERROR.
      p-asmg-status = ?.
      return error.
    end.
    else do:
      if p-mess then  do:
          message  "Удалить строку в  Ассортиментной матрице?"
                   view-as alert-box QUestion buttons yes-no update choice.

       end.
    end.
  end.
END CASE.


if p-asmg-status  = 0 then do:
    define variable p-ask as logical   no-undo .
    run ass-grp-gds-code-yes (
        input  buf_goods.gds-code ,
        input  buf_goods.grp-code ,
        input  v-id          ,
        input  v-db-num1     ,
        output p-ask        ) no-error .
        if error-status :error  or p-ask = false  then do:
          message substitute("Нельзя добавлять товар &1 &2 в Ассортиментную матрицу  &4(&5) из-за ограничения по ассортименту в группе &3", buf_goods.gds-code  ,buf_goods.gds-name , return-value ,
            v-id ,  v-db-num1 ) skip
            return-value skip error-status :get-message(1)
            view-as alert-box information .
            undo , return error substitute("Нельзя добавлять товар &1 &2 в Ассортиментную матрицу  &4(&5) из-за ограничения по ассортименту в группе &3 &6", buf_goods.gds-code  ,buf_goods.gds-name , return-value ,
                                          v-id ,  v-db-num1 , {&new-line} ) .
        end.
end.

define variable p-ok as logical no-undo .
 define variable v-err-str as character no-undo .
 v-err-str = "" .
if choice then do:
   if integer({&deleted-status-int}) = p-asmg-status  then do:    /* сменим статус ИЖТ */
      run chg-izt-proc2 (
          buffer buf_assortment-matrix ,
          buffer bf-assortment-matrix-goods ,
          output p-ok ) .

      if p-ok =  false then do:
          assign
            bf-assortment-matrix-goods.asmg-status = p-asmg-status
            v-err-str = ""
          .
      end.
      else do:
         v-err-str =  substitute("НЕ УДАЛИЛИ из матрицы, так как сработало правило в событие <УДАЛЕНИЕ товара из матрицы>  &1" , "" ) .
      end.
   end.
   else do:
      assign
        bf-assortment-matrix-goods.asmg-status = p-asmg-status
      .
    end.
end.

  release bf-assortment-matrix-goods no-error .

  if error-status:error then do:
    p-asmg-status = ?.
    message
    "Ошибка при сохранении записи Ассортиментной Матрицы" skip
    error-status:get-message(1) skip
    return-value
    view-as alert-box error .
    undo , return error .
  end.

  define variable v-econom as logical   no-undo .
  v-econom = false .
  run econom-mode in p-handle  (output v-econom ) no-error .
  if not v-econom  then do: /* Запускаем Трансляцию */
     run translate-to-other-gds (
          v-id       ,
          v-db-num   ,
          v-gds-code ,
          p-asmg-status ) no-error .
       if v-longchar-asstro <> "" or v-err-str <> "" then do:
           run correct-message in p-handle  (input v-longchar-asstro + " " + v-err-str) no-error .
       end.
  end.
return v-err-str .
end.
end procedure.

procedure chg-izt-proc2 :

define parameter buffer buf_assortment-matrix for ub.assortment-matrix .
define parameter buffer bf-assortment-matrix-goods for ub.assortment-matrix-goods .
define output parameter choice2 as logical   no-undo  .

/* смена ИЖТ */
  do
  on error undo, return error return-value
  :
define buffer buf_goods for ub.goods.
define buffer buf_gds-obj for ub.gds-obj  .
define buffer buf_gds-obj-prop for ub.gds-obj-prop  .

define variable v-amin  as logical   no-undo .
define variable v-izt   as character no-undo .
define variable v-gdop-min-stock                as decimal   no-undo .
define variable v-grop-max-stock                as decimal   no-undo .
define variable v-grop-level-always-presence    as decimal   no-undo .
define variable v-grop-min-order                as decimal   no-undo .
define variable p-old  as character no-undo .
define variable p-new  as character no-undo .
define variable v-gds-prop-recid as recid no-undo .

define variable v-event-code as character no-undo .
define variable v-izt-new    as logical   no-undo .
define variable v-izt-com    as logical   no-undo .
define variable v-izt-del    as logical   no-undo .
define variable v-izt-spec   as logical   no-undo .
define variable v-izt-empty  as logical   no-undo .


choice2 = false .
  if buf_assortment-matrix.obj-type <> "" and buf_assortment-matrix.obj-type <> ? then do:
    { gbl/gdsobjpr.i
      buf_assortment-matrix.obj-type
      buf_assortment-matrix.obj-code
      ?
      ?
      ?
      bf-assortment-matrix-goods.gds-code
      v-amin
      v-izt
      v-gdop-min-stock
      v-grop-max-stock
      v-grop-level-always-presence
      v-grop-min-order
      }

      find first buf_goods no-lock where
                 buf_goods.gds-code = bf-assortment-matrix-goods.gds-code no-error .
                 if not available buf_goods then return error error-status :get-message(1) .
      find first buf_gds-obj no-lock where
                 buf_gds-obj.gds-code = bf-assortment-matrix-goods.gds-code and
                 buf_gds-obj.obj-type = buf_assortment-matrix.obj-type and
                 buf_gds-obj.obj-code = buf_assortment-matrix.obj-code
                 no-error .
         if available buf_gds-obj and buf_gds-obj.fact-qnty <> 0 then do:
             v-event-code = {&izt-event-delete-matr-rest} .
         end.
         else do:
            v-event-code = {&izt-event-delete-matr-norest} .
         end.
        { gbl/iztrul.i
          v-event-code
          v-izt-new
          v-izt-com
          v-izt-del
          v-izt-spec
          v-izt-empty
          }
      case v-izt :
      when {&ass-izd-del}
      then do:
        choice2 = true .
        if v-izt-del = false then  choice2 = true  .
                             else  choice2 = false .
        if choice2 = true  then do:
        if v-amin = true then do:
            message "У товара " buf_goods.artic  buf_goods.gds-name skip
                      "ИЖТ = " v-izt skip
            substitute ("Остаток товара на  &1 &2 = &3" , buf_gds-obj.obj-type , buf_gds-obj.obj-code , buf_gds-obj.fact-qnty )
            skip
            if v-amin = true then "входит в Ассортиментный минимум" else ""
            skip
            "Оставляем его в Ассортиментной матрице ? "
            view-as alert-box question buttons yes-no update choice2 .
        end.
        end.
      end.
      when "" or when ? or when {&ass-izd-empty}
      then do:
        if v-izt-empty = false then   choice2 = true .
                               else   choice2 = false .
      end.
      otherwise do:
          message "Удалить можно только тоавары с ИЖТ" {&ass-izd-del} skip
            buf_goods.artic buf_goods.gds-name "пропускаем"
            view-as alert-box information .
            choice2 = true.
      end.
      end case.

      if choice2 = false then do:
          p-old = {&ass-izd-del}    .
          p-new = {&ass-izd-empty}  .

        find first buf_gds-obj-prop no-lock  where
                   buf_gds-obj-prop.gds-code = buf_goods.gds-code and
                   buf_gds-obj-prop.obj-code = buf_assortment-matrix.obj-code and
                   buf_gds-obj-prop.obj-type = buf_assortment-matrix.obj-type no-error .
           if not available buf_gds-obj-prop then
           do:
               run gds-ind1
                ( input-output v-gds-prop-recid
                , bf-assortment-matrix-goods.gds-code
                , buf_assortment-matrix.obj-type
                , buf_assortment-matrix.obj-code
                , p-new
                , ?
                , ?
                , ?
                , ?
                , ?
                )   .
              end.
              else do:
                  if buf_gds-obj-prop.gdop-igt = p-old then do:
                      run gds-ind1
                          (input-output v-gds-prop-recid
                          ,buf_gds-obj-prop.gds-code
                          ,buf_gds-obj-prop.obj-type
                          ,buf_gds-obj-prop.obj-code
                          ,p-new
                          ,?
                          ,?
                          ,?
                          ,?
                          ,?
                          )  .
                  end.
              end.
      end.
  end.

  end.
end procedure. /* chg-izt-proc2 */

procedure clear-longmess :

  do
  on error undo, return error return-value
  :
    v-longchar-asstro = "".
  end.

end procedure. /* clear-longmess */