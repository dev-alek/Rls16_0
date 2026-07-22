block-level on error undo, throw.
/*
$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: abcanal1.p $
$Archive: ref/abcanal1.p $

Сохранение изменений в карточке Заголовка АМ

Автор: Чернова Светлана Александровна
Дата создания: 03/23/05
Author: Svetlana Chernova
Creation date: 03/23/05

*/
DEFINE TEMP-TABLE x-abc-analysis      no-undo  LIKE ub.abc-analysis.
DEFINE TEMP-TABLE x-abc-analysis-doc  no-undo  LIKE ub.abc-analysis-doc.
DEFINE TEMP-TABLE x-abc-analysis-obj  no-undo LIKE  ub.abc-analysis-obj.
DEFINE TEMP-TABLE x-abc-analysis-period  no-undo LIKE ub.abc-analysis-period.

define input-output parameter p-doc-rec  as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter table for  x-abc-analysis.
define input parameter table for  x-abc-analysis-doc.
define input parameter table for  x-abc-analysis-obj.
define input parameter table for  x-abc-analysis-period.

define variable  v-list-obj          like ub.abc-analysis.abc-hash-string-obj          no-undo .
define variable  v-list-period       like ub.abc-analysis.abc-hash-string-period       no-undo .
define variable  v-list-doc          like ub.abc-analysis.abc-hash-string-doc          no-undo .

define variable  v-abc-hash-string-obj          like ub.abc-analysis.abc-hash-string-obj          no-undo .
define variable  v-abc-hash-string-period       like ub.abc-analysis.abc-hash-string-period       no-undo .
define variable  v-abc-hash-string-doc          like ub.abc-analysis.abc-hash-string-doc          no-undo .

define variable  v-abc-possb-keep-string-obj    like ub.abc-analysis.abc-possb-keep-string-obj    no-undo .
define variable  v-abc-possb-keep-string-period like ub.abc-analysis.abc-possb-keep-string-period no-undo .
define variable  v-abc-possb-keep-string-doc    like ub.abc-analysis.abc-possb-keep-string-doc    no-undo .

define variable  v-abc-string-obj               like ub.abc-analysis.abc-string-obj               no-undo .
define variable  v-abc-string-period            like ub.abc-analysis.abc-string-period            no-undo .
define variable  v-abc-string-doc               like ub.abc-analysis.abc-string-doc               no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: abcanal1.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/abcanal1.p $":U .
define variable vss-description as character no-undo init "Сохранение изменений в карточке Заголовка АМ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ ref/def-hash.i }
{ gbl/thbjattr.i }

define variable v-db-num like ub.db.db-num no-undo .
define variable v-db-num-obj like ub.db.db-num no-undo .
define variable v-host-code as integer   no-undo .
define variable v-base-code as integer   no-undo .
define variable v-first-base-code as integer   no-undo .

define stream LogStream.

if p-mode <> {&add-def} AND p-mode <> {&update} then do:
  message
  vss-workfile vss-revision vss-description skip
  "Неверный параметр p-mode" p-mode
  view-as alert-box error .
  return error '':u.
end.

{ gbl/curdbnum.i v-db-num }
find first x-abc-analysis no-error .
if error-status :error then do:
          run err-mess ("Не найдена x-abc-analysis ").
          return error "err":U.

end.

IF x-abc-analysis.abc-a  >= 100 or
   x-abc-analysis.abc-b >= 100  or
   x-abc-analysis.abc-a <= 0    or
   x-abc-analysis.abc-b <= 0    then do:
          run err-mess ("Не верно установлено соотношение ранжировани ").
          return error "abc-rang":U.

END.


define variable par-type as character no-undo .
define variable par-abc-type as character no-undo .
define variable  v-value-date    as date   no-undo .
define variable  v-value-decimal as decimal   no-undo .
define variable  v-value-integer as integer   no-undo .
define variable  v-value-logical as logical   no-undo .
define variable v-found as logical   no-undo .
run thbjattr_value in this-procedure  (
  input   "",
  input   0 ,
  input   {&attr-abc-global} ,
  input   'abc-type'  ,
  output  par-abc-type ,
  output  v-value-date      ,
  output  v-value-decimal   ,
  output  v-value-integer   ,
  output  v-value-logical   ,
  output  par-type            ,
  output  v-found
  ) no-error
  .
  if error-status :error or v-found = false then do:
      message "Нет настроек Ассортиментной политики !!!." view-as alert-box information .
      return error return-value .
  end.

case par-abc-type:
    when "ABC":U
    then do:
      if x-abc-analysis.abc-a = 0 then do:
          run err-mess ("Нe задан уровень А!").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-b = 0 then do:
          run err-mess ("Нe задан уровень  B !").
          return error "abc-rang":U.
      end.

      if x-abc-analysis.abc-c = 0 then do:
        assign
          x-abc-analysis.abc-c = 100
          x-abc-analysis.abc-d = 0
          x-abc-analysis.abc-e = 0
          x-abc-analysis.abc-f = 0
        .
      end.
      if  x-abc-analysis.abc-a = x-abc-analysis.abc-b then do:
          run err-mess ("Уровни ранжирования должны быть различны !").
          return error "abc-rang":U.
      end.
      if not (x-abc-analysis.abc-a < x-abc-analysis.abc-b  and
            x-abc-analysis.abc-b < x-abc-analysis.abc-c  )
           then do:
              run err-mess ("Уровни ранжирования должны идти по возрастанию !").
              return error "abc-rang":U.

           end.


    end.

    when "ABCD":U
    then do:
      if x-abc-analysis.abc-a = 0 then do:
          run err-mess ("Нe задан уровень А!").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-b = 0 then do:
          run err-mess ("Нe задан уровень  B !").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-c = 0 then do:
          run err-mess ("Нe задан уровень  C !").
          return error "abc-rang":U.
      end.


      if x-abc-analysis.abc-d = 0 then do:
        assign
          x-abc-analysis.abc-d = 100
          x-abc-analysis.abc-e = 0
          x-abc-analysis.abc-f = 0
        .
      end.
      if   (x-abc-analysis.abc-a = x-abc-analysis.abc-b)  or
           (x-abc-analysis.abc-b = x-abc-analysis.abc-c)   or
           (x-abc-analysis.abc-a = x-abc-analysis.abc-c)
        then do:
          run err-mess ("Уровни ранжирования должны быть различны !").
          return error "abc-rang":U.
      end.
      if not (x-abc-analysis.abc-a < x-abc-analysis.abc-b  and
            x-abc-analysis.abc-b < x-abc-analysis.abc-c  and
            x-abc-analysis.abc-c < x-abc-analysis.abc-d )
           then do:
              run err-mess ("Уровни ранжирования должны идти по возрастанию !").
              return error "abc-rang":U.

           end.

    end.

    when "ABCDE":U
    then do:
      if x-abc-analysis.abc-a = 0 then do:
          run err-mess ("Нe задан уровень А!").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-b = 0 then do:
          run err-mess ("Нe задан уровень  B !").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-c = 0 then do:
          run err-mess ("Нe задан уровень  C !").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-d = 0 then do:
          run err-mess ("Нe задан уровень  D !").
          return error "abc-rang":U.
      end.


      if x-abc-analysis.abc-e = 0 then do:
        assign
          x-abc-analysis.abc-e = 100
          x-abc-analysis.abc-f = 0
        .
      end.
      if   (x-abc-analysis.abc-a = x-abc-analysis.abc-b)  or
           (x-abc-analysis.abc-a = x-abc-analysis.abc-c)  or
           (x-abc-analysis.abc-a = x-abc-analysis.abc-d)  or
           (x-abc-analysis.abc-b = x-abc-analysis.abc-c)  or
           (x-abc-analysis.abc-b = x-abc-analysis.abc-d)
        then do:
          run err-mess ("Уровни ранжирования должны быть различны !").
          return error "abc-rang":U.
      end.
      if not (x-abc-analysis.abc-a < x-abc-analysis.abc-b  and
            x-abc-analysis.abc-b < x-abc-analysis.abc-c  and
            x-abc-analysis.abc-c < x-abc-analysis.abc-d  and
            x-abc-analysis.abc-d < x-abc-analysis.abc-e  )
           then do:
              run err-mess ("Уровни ранжирования должны идти по возрастанию !").
              return error "abc-rang":U.

           end.

    end.

    when "ABCDEF":U
    then do:
      if x-abc-analysis.abc-a = 0 then do:
          run err-mess ("Нe задан уровень А!").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-b = 0 then do:
          run err-mess ("Нe задан уровень  B !").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-c = 0 then do:
          run err-mess ("Нe задан уровень  C !").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-d = 0 then do:
          run err-mess ("Нe задан уровень  D !").
          return error "abc-rang":U.
      end.
      if x-abc-analysis.abc-f = 0 then do:
          run err-mess ("Нe задан уровень  F !").
          return error "abc-rang":U.
      end.


      if x-abc-analysis.abc-f = 0 then do:
        assign
          x-abc-analysis.abc-f = 100
        .
      end.
      if   (x-abc-analysis.abc-a = x-abc-analysis.abc-b)  or
           (x-abc-analysis.abc-a = x-abc-analysis.abc-c)  or
           (x-abc-analysis.abc-a = x-abc-analysis.abc-d)  or
           (x-abc-analysis.abc-a = x-abc-analysis.abc-e)  or
           (x-abc-analysis.abc-b = x-abc-analysis.abc-c)  or
           (x-abc-analysis.abc-b = x-abc-analysis.abc-d)  or
           (x-abc-analysis.abc-b = x-abc-analysis.abc-e)  or
           (x-abc-analysis.abc-c = x-abc-analysis.abc-d)  or
           (x-abc-analysis.abc-c = x-abc-analysis.abc-e)

        then do:
          run err-mess ("Уровни ранжирования должны быть различны !").
          return error "abc-rang":U.
      end.

      if not (x-abc-analysis.abc-a < x-abc-analysis.abc-b  and
            x-abc-analysis.abc-b < x-abc-analysis.abc-c  and
            x-abc-analysis.abc-c < x-abc-analysis.abc-d  and
            x-abc-analysis.abc-d < x-abc-analysis.abc-e  and
            x-abc-analysis.abc-e < x-abc-analysis.abc-f)
           then do:
              run err-mess ("Уровни ранжирования должны идти по возрастанию !").
              return error "abc-rang":U.

           end.


    end.


end case.

if x-abc-analysis.abc-name = "":U then do:
  run err-mess ("Название ABC анализа не может быть пустым").
  return error "abc-name":U.
end.


if x-abc-analysis.cral-id = 0 then do:
  run err-mess ("Не выбран КРИТЕРИЙ АНАЛИЗА").
  return error "cral-id":U.
end.

if not can-find ( first x-abc-analysis-doc) then do: run err-mess ("Не заданы типы документов для анализа"). return error "doc":U. end.
if not can-find ( first x-abc-analysis-obj) then do: run err-mess ("Не заданы объекты для анализа"). return error "obj":U. end.
if not can-find ( first x-abc-analysis-period) then do: run err-mess ("Не заданы периоды для анализа"). return error "period":U. end.

find first ub.criterion-analysis no-lock where ub.criterion-analysis.cral-id = x-abc-analysis.cral-id no-error .
if not available ub.criterion-analysis then do: run err-mess ("Не верно задан критерий анализа.Ошибка поиска"). return error "cral-id":U. end.
if available ub.criterion-analysis and ub.criterion-analysis.cral-status <> 0  then do: run err-mess ("Критерий анализа не активный"). return error "cral-id":U. end.
define variable fl as logical   no-undo init false .

/* проверим одновалютность фирм для валютного критерия */
if lookup(string(criterion-analysis.cral-id) ,"5,7,9,11,13,15") > 0 then do:
    for each x-abc-analysis-obj break by x-abc-analysis-obj.obj-type by x-abc-analysis-obj.obj-code :
      { gbl/hostcode.i x-abc-analysis-obj.obj-type  x-abc-analysis-obj.obj-code v-host-code }
      { gbl/basecode.i v-host-code v-base-code }
      if fl = false then
          assign
            v-first-base-code = v-base-code
            fl = true
          .
      if v-first-base-code <> v-base-code then do:
          run err-mess ("При выбранном валютном критерии анализа , выбранные объекты принадлежат к разным валютным фирмам. Анализ не возможен !!!").
          return error "obj":U.
      end.
    end.
end.

_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:

define variable v-date as date no-undo .
define variable v-time as integer no-undo .


run cur-time in this-procedure(output v-date, output v-time).

  if p-mode = {&add-def} then do:


    create ub.abc-analysis.
    assign
    ub.abc-analysis.abc-id = next-value(s-asmt, {&db-name_schema})
    ub.abc-analysis.abc-date-create    = v-date
    ub.abc-analysis.abc-time-create    = v-time
    ub.abc-analysis.abc-db-num-create  = g#db-num
    ub.abc-analysis.abc-who-create     = g#userid
    ub.abc-analysis.db-num             = g#db-num
.

    p-doc-rec = recid(ub.abc-analysis)
    .
  end.
  else do:
    FIND FIRST ub.abc-analysis where
              recid(ub.abc-analysis) = p-doc-rec No-ERROR.
    if not available ub.abc-analysis then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
  end.
  assign
    ub.abc-analysis.cral-id     =  x-abc-analysis.cral-id
    ub.abc-analysis.abc-name    =  x-abc-analysis.abc-name
    ub.abc-analysis.abc-des     =  x-abc-analysis.abc-des
    ub.abc-analysis.raad-a      =  x-abc-analysis.raad-a
    ub.abc-analysis.raad-b      =  x-abc-analysis.raad-b
    ub.abc-analysis.raad-c      =  x-abc-analysis.raad-c
    ub.abc-analysis.raad-d      =  x-abc-analysis.raad-d
    ub.abc-analysis.raad-e      =  x-abc-analysis.raad-e
    ub.abc-analysis.raad-f      =  x-abc-analysis.raad-f
    ub.abc-analysis.abc-a       =  x-abc-analysis.abc-a
    ub.abc-analysis.abc-b       =  x-abc-analysis.abc-b
    ub.abc-analysis.abc-c       =  x-abc-analysis.abc-c
    ub.abc-analysis.abc-d       =  x-abc-analysis.abc-d
    ub.abc-analysis.abc-e       =  x-abc-analysis.abc-e
    ub.abc-analysis.abc-f       =  x-abc-analysis.abc-f
    ub.abc-analysis.abc-a-prc-qnty  =  x-abc-analysis.abc-a-prc-qnty
    ub.abc-analysis.abc-a-qnty      =  x-abc-analysis.abc-a-qnty
    ub.abc-analysis.abc-a-sum-prc   =  x-abc-analysis.abc-a-sum-prc
    ub.abc-analysis.abc-a-sum       =  x-abc-analysis.abc-a-sum
    ub.abc-analysis.abc-b-prc-qnty  =  x-abc-analysis.abc-b-prc-qnty
    ub.abc-analysis.abc-b-qnty      =  x-abc-analysis.abc-b-qnty
    ub.abc-analysis.abc-b-sum-prc   =  x-abc-analysis.abc-b-sum-prc
    ub.abc-analysis.abc-b-sum       =  x-abc-analysis.abc-b-sum
    ub.abc-analysis.abc-c-prc-qnty  =  x-abc-analysis.abc-c-prc-qnty
    ub.abc-analysis.abc-c-qnty      =  x-abc-analysis.abc-c-qnty
    ub.abc-analysis.abc-c-sum-prc   =  x-abc-analysis.abc-c-sum-prc
    ub.abc-analysis.abc-c-sum       =  x-abc-analysis.abc-c-sum
    ub.abc-analysis.abc-d-prc-qnty  =  x-abc-analysis.abc-d-prc-qnty
    ub.abc-analysis.abc-d-qnty      =  x-abc-analysis.abc-d-qnty
    ub.abc-analysis.abc-d-sum-prc   =  x-abc-analysis.abc-d-sum-prc
    ub.abc-analysis.abc-d-sum       =  x-abc-analysis.abc-d-sum
    ub.abc-analysis.abc-e-prc-qnty  =  x-abc-analysis.abc-e-prc-qnty
    ub.abc-analysis.abc-e-qnty      =  x-abc-analysis.abc-e-qnty
    ub.abc-analysis.abc-e-sum-prc   =  x-abc-analysis.abc-e-sum-prc
    ub.abc-analysis.abc-e-sum       =  x-abc-analysis.abc-e-sum
    ub.abc-analysis.abc-f-prc-qnty  =  x-abc-analysis.abc-f-prc-qnty
    ub.abc-analysis.abc-f-qnty      =  x-abc-analysis.abc-f-qnty
    ub.abc-analysis.abc-f-sum-prc   =  x-abc-analysis.abc-f-sum-prc
    ub.abc-analysis.abc-f-sum       =  x-abc-analysis.abc-f-sum
    ub.abc-analysis.R-GOODS         =  x-abc-analysis.r-goods
    ub.abc-analysis.double-line-proc          =  x-abc-analysis.double-line-proc
    ub.abc-analysis.le-proc         =  x-abc-analysis.le-proc
    ub.abc-analysis.abc-type        =  x-abc-analysis.abc-type
  .
for each ub.abc-analysis-doc exclusive-lock where
         ub.abc-analysis-doc.abc-id = ub.abc-analysis.abc-id and
         ub.abc-analysis-doc.db-num = ub.abc-analysis.db-num   :
    delete ub.abc-analysis-doc .
end.
v-list-doc = "".
for each x-abc-analysis-doc :
     create ub.abc-analysis-doc.
     BUFFER-COPY x-abc-analysis-doc  TO ub.abc-analysis-doc
         assign
           ub.abc-analysis-doc.abc-id = ub.abc-analysis.abc-id
           ub.abc-analysis-doc.db-num = ub.abc-analysis.db-num
         .
          v-list-doc = v-list-doc +  x-abc-analysis-doc.abcd-ext-doc-type + "," .
end.

for each ub.abc-analysis-obj exclusive-lock where
         ub.abc-analysis-obj.abc-id = ub.abc-analysis.abc-id and
         ub.abc-analysis-obj.db-num = ub.abc-analysis.db-num   :
    delete ub.abc-analysis-obj .
end.
 v-list-obj = "".
for each x-abc-analysis-obj :
     create ub.abc-analysis-obj.
     BUFFER-COPY x-abc-analysis-obj  TO ub.abc-analysis-obj
         assign
           ub.abc-analysis-obj.abc-id = ub.abc-analysis.abc-id
           ub.abc-analysis-obj.db-num = ub.abc-analysis.db-num
         .
     v-list-obj = v-list-obj + x-abc-analysis-obj.obj-type + string(x-abc-analysis-obj.obj-code) + "," .
end.

for each ub.abc-analysis-period exclusive-lock where
         ub.abc-analysis-period.abc-id = ub.abc-analysis.abc-id and
         ub.abc-analysis-period.db-num = ub.abc-analysis.db-num   :
    delete ub.abc-analysis-period .
end.
v-list-period = "".
for each x-abc-analysis-period :
     create ub.abc-analysis-period.
     BUFFER-COPY x-abc-analysis-period TO ub.abc-analysis-period
         assign
           ub.abc-analysis-period.abc-id = ub.abc-analysis.abc-id
           ub.abc-analysis-period.db-num = ub.abc-analysis.db-num
         .
         v-list-period = v-list-period + string ( x-abc-analysis-period.abcp-start,"99/99/9999") + "-"
                                       + string ( x-abc-analysis-period.abcp-end,"99/99/9999")    + "," .
end.

  run def-hash ( input   v-list-obj ,
                 output  v-abc-possb-keep-string-obj,
                 output  v-abc-string-obj ,
                 output  v-abc-hash-string-obj       )
                 .
  run def-hash ( input   v-list-period ,
                 output  v-abc-possb-keep-string-period,
                 output  v-abc-string-period ,
                 output  v-abc-hash-string-period       )
                 .

  run def-hash ( input   v-list-doc ,
                 output  v-abc-possb-keep-string-doc,
                 output  v-abc-string-doc ,
                 output  v-abc-hash-string-doc       )
                 .

  assign
    ub.abc-analysis.abc-hash-string-obj          =  v-abc-hash-string-obj
    ub.abc-analysis.abc-hash-string-period       =  v-abc-hash-string-period
    ub.abc-analysis.abc-hash-string-doc          =  v-abc-hash-string-doc
    ub.abc-analysis.abc-possb-keep-string-obj    =  v-abc-possb-keep-string-obj
    ub.abc-analysis.abc-possb-keep-string-period =  v-abc-possb-keep-string-period
    ub.abc-analysis.abc-possb-keep-string-doc    =  v-abc-possb-keep-string-doc
    ub.abc-analysis.abc-string-obj               =  v-abc-string-obj
    ub.abc-analysis.abc-string-period            =  v-abc-string-period
    ub.abc-analysis.abc-string-doc               =  v-abc-string-doc
  .



/*   release ub.abc-analysis no-error.
  if error-status:error then do:
     run err-mess ( substitute("Ошибка при сохранении записи УСЛОВИЙ ХРАНЕНИЯ с кодом &1: &2: &3"
                             , x-abc-analysis.asmt-id
                             , ERROR-STATUS:GET-message(1)
                             , return-value
                             )).
    undo, return error "":U.

 end.
  */
end. /*doe*/



PROCEDURE err-mess:
  DEFINE INPUT PARAMETER p-mess as character No-UNDO.
      message
      p-mess
      view-as alert-box error .
END PROCEDURE.