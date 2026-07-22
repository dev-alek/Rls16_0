block-level on error undo, throw.
/*
$Revision: c5e125f9f735, 902, rls $
$Author: EShklyar $
$Date: Tue Dec 06 17:15:45 2016 +0300 $
$Workfile: xyzanal1.p $
$Archive: ref/xyzanal1.p $

Сохранение изменений в карточке XYZ

Автор: Чернова Светлана Александровна
Дата создания: 03/03/06
Author: Svetlana Chernova
Creation date: 03/03/06

Дата создания: 03/23/05
*/
DEFINE TEMP-TABLE x-XYZ-analysis-doc  no-undo  LIKE ub.xyz-analysis-doc.
DEFINE TEMP-TABLE x-XYZ-analysis-obj  no-undo LIKE ub.xyz-analysis-obj.
DEFINE TEMP-TABLE x-XYZ-analysis-period  no-undo LIKE ub.xyz-analysis-period.

define input-output parameter p-doc-rec  as recid no-undo.
define input parameter p-mode            as character no-undo .
define input parameter p-XYZ-id                       like ub.XYZ-analysis.XYZ-id                       no-undo .
define input parameter p-db-num                       like ub.XYZ-analysis.db-num                       no-undo .
define input parameter p-cral-id                      like ub.XYZ-analysis.cral-id                      no-undo .
define input parameter p-XYZ-name                     like ub.XYZ-analysis.XYZ-name                     no-undo .
define input parameter p-XYZ-des                      like ub.XYZ-analysis.XYZ-des                      no-undo .
define input parameter p-raxd-x                       like ub.XYZ-analysis.raxd-x                       no-undo .
define input parameter p-raxd-y                       like ub.XYZ-analysis.raxd-y                       no-undo .
define input parameter p-raxd-z                       like ub.XYZ-analysis.raxd-z                       no-undo .
define input parameter p-XYZ-x                        like ub.XYZ-analysis.XYZ-x                        no-undo .
define input parameter p-XYZ-y                        like ub.XYZ-analysis.XYZ-y                        no-undo .
define input parameter p-XYZ-z                        like ub.XYZ-analysis.XYZ-z                        no-undo .
define input parameter p-xyz-x-prc-qnty           like ub.XYZ-analysis.xyz-x-prc-qnty                   no-undo .
define input parameter p-xyz-x-qnty               like ub.XYZ-analysis.xyz-x-qnty                       no-undo .
define input parameter p-xyz-x-sum-prc            like ub.XYZ-analysis.xyz-x-sum-prc                    no-undo .
define input parameter p-xyz-x-sum                like ub.XYZ-analysis.xyz-x-sum                        no-undo .
define input parameter p-xyz-y-prc-qnty           like ub.XYZ-analysis.xyz-y-prc-qnty                   no-undo .
define input parameter p-xyz-y-qnty               like ub.XYZ-analysis.xyz-y-qnty                       no-undo .
define input parameter p-xyz-y-sum-prc            like ub.XYZ-analysis.xyz-y-sum-prc                    no-undo .
define input parameter p-xyz-y-sum                like ub.XYZ-analysis.xyz-y-sum                        no-undo .
define input parameter p-xyz-z-prc-qnty           like ub.XYZ-analysis.xyz-z-prc-qnty                   no-undo .
define input parameter p-xyz-z-qnty               like ub.XYZ-analysis.xyz-z-qnty                       no-undo .
define input parameter p-xyz-z-sum-prc            like ub.XYZ-analysis.xyz-z-sum-prc                    no-undo .
define input parameter p-xyz-z-sum                like ub.XYZ-analysis.xyz-z-sum                        no-undo .
define input parameter p-xyz-r-good               like ub.xyz-analysis-attr.xyza-attr-value             no-undo .

define input PARAMETER TABLE FOR    x-XYZ-analysis-doc.
define input PARAMETER TABLE FOR    x-XYZ-analysis-obj.
define input PARAMETER TABLE FOR    x-XYZ-analysis-period.

define variable  v-list-obj          like ub.XYZ-analysis.XYZ-hash-string-obj          no-undo .
define variable  v-list-period       like ub.XYZ-analysis.XYZ-hash-string-period       no-undo .
define variable  v-list-doc          like ub.XYZ-analysis.XYZ-hash-string-doc          no-undo .

define variable  v-XYZ-hash-string-obj          like ub.XYZ-analysis.XYZ-hash-string-obj          no-undo .
define variable  v-XYZ-hash-string-period       like ub.XYZ-analysis.XYZ-hash-string-period       no-undo .
define variable  v-XYZ-hash-string-doc          like ub.XYZ-analysis.XYZ-hash-string-doc          no-undo .
define variable  v-XYZ-possb-keep-string-obj    like ub.XYZ-analysis.XYZ-possb-keep-string-obj    no-undo .
define variable  v-XYZ-possb-keep-string-period like ub.XYZ-analysis.XYZ-possb-keep-string-period no-undo .
define variable  v-XYZ-possb-keep-string-doc    like ub.XYZ-analysis.XYZ-possb-keep-string-doc    no-undo .
define variable  v-XYZ-string-obj               like ub.XYZ-analysis.XYZ-string-obj               no-undo .
define variable  v-XYZ-string-period            like ub.XYZ-analysis.XYZ-string-period            no-undo .
define variable  v-XYZ-string-doc               like ub.XYZ-analysis.XYZ-string-doc               no-undo .


def var vss-revision    as character no-undo init "$Revision: c5e125f9f735, 902, rls $":U .
def var vss-author      as character no-undo init "$Author: EShklyar $":U .
def var vss-date        as character no-undo init "$Date: Tue Dec 06 17:15:45 2016 +0300 $":U .
def var vss-workfile    as character no-undo init "$Workfile: xyzanal1.p $":U .
def var vss-archive     as character no-undo init "$Archive: ref/xyzanal1.p $":U .
def var vss-description as character no-undo init "Сохранение изменений в карточке Заголовка АМ".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ gbl/cur-time.i }
{ ref/def-hash.i }
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


if p-XYZ-name = "":U then do:
  run err-mess ("Название XYZ анализа не может быть пустым").
  return error "XYZ-name":U.
end.


if p-cral-id = 0 then do:
  run err-mess ("Не выбран КРИТЕРИЙ АНАЛИЗА").
  return error "cral-id":U.
end.

if not can-find ( first x-XYZ-analysis-doc) then do: run err-mess ("Не заданы типы документов для анализа"). return error "doc":U. end.
if not can-find ( first x-XYZ-analysis-obj) then do: run err-mess ("Не заданы объекты для анализа"). return error "obj":U. end.
if not can-find ( first x-XYZ-analysis-period) then do: run err-mess ("Не заданы периоды для анализа"). return error "period":U. end.

find first ub.criterion-analysis no-lock where ub.criterion-analysis.cral-id = p-cral-id no-error .
if not available ub.criterion-analysis then do: run err-mess ("Не верно задан критерий анализа.Ошибка поиска"). return error "cral-id":U. end.
define variable fl as logical   no-undo init false .

/* проверим одновалютность фирм для валютного критерия */
if lookup(string(criterion-analysis.cral-id) ,"5,7,9,11,13,15") > 0 then do:
    for each x-XYZ-analysis-obj break by x-XYZ-analysis-obj.obj-type by x-XYZ-analysis-obj.obj-code :
      { gbl/hostcode.i x-XYZ-analysis-obj.obj-type  x-XYZ-analysis-obj.obj-code v-host-code }
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

  /* проверка на пересечение интервалов */
  define buffer b_date for x-XYZ-analysis-period .
  for each x-XYZ-analysis-period :
    find first b_date where
            ( b_date.xyzp-start >= x-XYZ-analysis-period.xyzp-start and
              b_date.xyzp-start <= x-XYZ-analysis-period.xyzp-end ) or
            ( b_date.xyzp-end   >= x-XYZ-analysis-period.xyzp-start and
              b_date.xyzp-end   <= x-XYZ-analysis-period.xyzp-end )
              no-error .

     if available b_date and
         not  (   b_date.xyzp-start = x-XYZ-analysis-period.xyzp-start    and
                  b_date.xyzp-end = x-XYZ-analysis-period.xyzp-end  ) then do:
          run err-mess ( "Интервалы пересекаются ! "      +
                    string( x-XYZ-analysis-period.xyzp-start ) + "-" +
                    string( x-XYZ-analysis-period.xyzp-end ) + " " +
                    string( b_date.xyzp-start  ) + "-" +
                    string( b_date.xyzp-end  ) ).
          return error "date":U .
     end.

  end.


_MAIN:
DO ON ERROR UNDO, RETURN ERROR
ON STOP UNDO, RETURN ERROR:

define variable v-date as date no-undo .
define variable v-time as integer no-undo .


run cur-time in this-procedure(output v-date, output v-time).

  if p-mode = {&add-def} then do:


    create ub.XYZ-analysis.
    assign
    ub.XYZ-analysis.XYZ-id = next-value(s-asmt, {&db-name_schema})
    ub.XYZ-analysis.XYZ-date-create    = v-date
    ub.XYZ-analysis.XYZ-time-create    = v-time
    ub.XYZ-analysis.XYZ-db-num-create  = g#db-num
    ub.XYZ-analysis.XYZ-who-create     = g#userid
    ub.XYZ-analysis.db-num             = g#db-num
.

    p-doc-rec = recid(ub.XYZ-analysis)
    .
  end.
  else do:
    FIND FIRST ub.XYZ-analysis where
              recid(ub.XYZ-analysis) = p-doc-rec No-ERROR.
    if not available ub.XYZ-analysis then do:
      message
      vss-workfile vss-revision vss-description skip
      "Не найдена запись - p-doc-rec" p-doc-rec
      view-as alert-box error .
      undo, return error '':u.
    end.
    if ub.XYZ-analysis.XYZ-id <> p-XYZ-id
    then do:
      message
      vss-workfile vss-revision vss-description skip
      "Для уже имеющейся записи нельзя изменить"
      "внутренний код" skip
      view-as alert-box ERROR.
      undo, return error '':U.
    end.
  end.
  assign
    ub.XYZ-analysis.cral-id     =  p-cral-id
    ub.XYZ-analysis.XYZ-name    =  p-XYZ-name
    ub.XYZ-analysis.XYZ-des     =  p-XYZ-des
    ub.XYZ-analysis.raxd-x      =  p-raxd-x
    ub.XYZ-analysis.raxd-y      =  p-raxd-y
    ub.XYZ-analysis.raxd-z      =  p-raxd-z
    ub.XYZ-analysis.XYZ-x       =  p-XYZ-x
    ub.XYZ-analysis.XYZ-y       =  p-XYZ-y
    ub.XYZ-analysis.XYZ-z       =  p-XYZ-z
    ub.XYZ-analysis.xyz-x-prc-qnty          = p-xyz-x-prc-qnty
    ub.XYZ-analysis.xyz-x-qnty              = p-xyz-x-qnty
    ub.XYZ-analysis.xyz-x-sum-prc           = p-xyz-x-sum-prc
    ub.XYZ-analysis.xyz-x-sum               = p-xyz-x-sum
    ub.XYZ-analysis.xyz-y-prc-qnty          = p-xyz-y-prc-qnty
    ub.XYZ-analysis.xyz-y-qnty              = p-xyz-y-qnty
    ub.XYZ-analysis.xyz-y-sum-prc           = p-xyz-y-sum-prc
    ub.XYZ-analysis.xyz-y-sum               = p-xyz-y-sum
    ub.XYZ-analysis.xyz-z-prc-qnty          = p-xyz-z-prc-qnty
    ub.XYZ-analysis.xyz-z-qnty              = p-xyz-z-qnty
    ub.XYZ-analysis.xyz-z-sum-prc           = p-xyz-z-sum-prc
    ub.XYZ-analysis.xyz-z-sum               = p-xyz-z-sum
  .
  find first ub.xyz-analysis-attr where ub.xyz-analysis-attr.db-num = ub.xyz-analysis.db-num
                                    and ub.xyz-analysis-attr.xyz-id = ub.xyz-analysis.xyz-id
                                    and ub.xyz-analysis-attr.xyza-attr-code = "r-goods" exclusive-lock no-error .
    if not available ub.xyz-analysis-attr then do:
      create ub.xyz-analysis-attr .
      assign
        ub.xyz-analysis-attr.db-num = ub.xyz-analysis.db-num
        ub.xyz-analysis-attr.xyz-id = ub.xyz-analysis.xyz-id
        ub.xyz-analysis-attr.xyza-attr-code = "r-goods"
      .
    end.                                           
    assign
      ub.xyz-analysis-attr.xyza-attr-value = p-xyz-r-good
    .
for each ub.XYZ-analysis-doc exclusive-lock where
         ub.XYZ-analysis-doc.XYZ-id = ub.XYZ-analysis.XYZ-id and
         ub.XYZ-analysis-doc.db-num = ub.XYZ-analysis.db-num   :
    delete ub.XYZ-analysis-doc .
end.
v-list-doc = "".
for each x-XYZ-analysis-doc :
     create ub.XYZ-analysis-doc.
     BUFFER-COPY x-XYZ-analysis-doc  TO ub.XYZ-analysis-doc
         assign
           ub.XYZ-analysis-doc.XYZ-id = ub.XYZ-analysis.XYZ-id
           ub.XYZ-analysis-doc.db-num = ub.XYZ-analysis.db-num
         .
          v-list-doc = v-list-doc +  x-XYZ-analysis-doc.XYZd-ext-doc-type + "," .
end.

for each ub.XYZ-analysis-obj exclusive-lock where
         ub.XYZ-analysis-obj.XYZ-id = ub.XYZ-analysis.XYZ-id and
         ub.XYZ-analysis-obj.db-num = ub.XYZ-analysis.db-num   :
    delete ub.XYZ-analysis-obj .
end.
 v-list-obj = "".
for each x-XYZ-analysis-obj :
     create ub.XYZ-analysis-obj.
     BUFFER-COPY x-XYZ-analysis-obj  TO ub.XYZ-analysis-obj
         assign
           ub.XYZ-analysis-obj.XYZ-id = ub.XYZ-analysis.XYZ-id
           ub.XYZ-analysis-obj.db-num = ub.XYZ-analysis.db-num
         .
     v-list-obj = v-list-obj + x-XYZ-analysis-obj.obj-type + string(x-XYZ-analysis-obj.obj-code) + "," .
end.

for each ub.XYZ-analysis-period exclusive-lock where
         ub.XYZ-analysis-period.XYZ-id = ub.XYZ-analysis.XYZ-id and
         ub.XYZ-analysis-period.db-num = ub.XYZ-analysis.db-num   :
    delete ub.XYZ-analysis-period .
end.
v-list-period = "".
for each x-XYZ-analysis-period :
     create ub.XYZ-analysis-period.
     BUFFER-COPY x-XYZ-analysis-period TO ub.XYZ-analysis-period
         assign
           ub.XYZ-analysis-period.XYZ-id = ub.XYZ-analysis.XYZ-id
           ub.XYZ-analysis-period.db-num = ub.XYZ-analysis.db-num
         .
         v-list-period = v-list-period + string ( x-XYZ-analysis-period.XYZp-start,"99/99/9999") + "-"
                                       + string ( x-XYZ-analysis-period.XYZp-end,"99/99/9999")    + "," .
end.

  run def-hash ( input   v-list-obj ,
                 output  v-XYZ-possb-keep-string-obj,
                 output  v-XYZ-string-obj ,
                 output  v-XYZ-hash-string-obj       )
                 .
  run def-hash ( input   v-list-period ,
                 output  v-XYZ-possb-keep-string-period,
                 output  v-XYZ-string-period ,
                 output  v-XYZ-hash-string-period       )
                 .

  run def-hash ( input   v-list-doc ,
                 output  v-XYZ-possb-keep-string-doc,
                 output  v-XYZ-string-doc ,
                 output  v-XYZ-hash-string-doc       )
                 .

  assign
    ub.XYZ-analysis.XYZ-hash-string-obj          =  v-XYZ-hash-string-obj
    ub.XYZ-analysis.XYZ-hash-string-period       =  v-XYZ-hash-string-period
    ub.XYZ-analysis.XYZ-hash-string-doc          =  v-XYZ-hash-string-doc
    ub.XYZ-analysis.XYZ-possb-keep-string-obj    =  v-XYZ-possb-keep-string-obj
    ub.XYZ-analysis.XYZ-possb-keep-string-period =  v-XYZ-possb-keep-string-period
    ub.XYZ-analysis.XYZ-possb-keep-string-doc    =  v-XYZ-possb-keep-string-doc
    ub.XYZ-analysis.XYZ-string-obj               =  v-XYZ-string-obj
    ub.XYZ-analysis.XYZ-string-period            =  v-XYZ-string-period
    ub.XYZ-analysis.XYZ-string-doc               =  v-XYZ-string-doc
  .



/*   release ub.XYZ-analysis no-error.
  if error-status:error then do:
     run err-mess ( substitute("Ошибка при сохранении записи УСЛОВИЙ ХРАНЕНИЯ с кодом &1: &2: &3"
                             , p-asmt-id
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