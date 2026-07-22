/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Удаление ДНЦ

Автор: Чернова Светлана Александровна
Дата создания: 12/19/05
Author: Svetlana Chernova
Creation date: 12/19/05

*/
{ gbl/thbj-def.i }

procedure price-doc-forming-DELETE :
define input  parameter p-plt-db-num       as integer   no-undo .
define input  parameter p-plt-id           as integer   no-undo .
define input  parameter p-pdf-db-num       as integer   no-undo .
define input  parameter p-pdf-id           as integer   no-undo .
define input  parameter p-db-num-usr       as integer   no-undo .
define input  parameter p-userid           as character no-undo .

define buffer buf_price-list-type for ub.price-list-type  .

define variable v-value-character as character no-undo .
define variable v-date-close-period as date      no-undo .
define variable v-value-decimal as decimal   no-undo .
define variable v-value-integer as integer   no-undo .
define variable v-value-logical as logical   no-undo .
define variable v-value-type as character no-undo .
define variable v-ask  as logical   no-undo init false .


  do
  on error undo, return error return-value
  :

if p-pdf-db-num <> p-db-num-usr then do:
   message "Нельзя удалять ДНЦ на чужой БД !" view-as alert-box error .
   return .
end.
find first ub.price-doc-forming no-lock  where
        ub.price-doc-forming.pdf-db       = p-pdf-db-num  and
        ub.price-doc-forming.pdf-id       = p-pdf-id      and
        ub.price-doc-forming.plt-db-num   = p-plt-db-num  and
        ub.price-doc-forming.plt-id       = p-plt-id
        no-error .
if  ub.price-doc-forming.STTS = integer({&pdf-delete}) then do:  /* удал */
   message "ДНЦ уже удален !" view-as alert-box error .
   return .
end.

if  ub.price-doc-forming.STTS = integer({&pdf-ready}) then do:  /* Готов */
   message "ДНЦ в статусе ГОТОВ удалять нельзя !" view-as alert-box error .
   return .
end.

if  ub.price-doc-forming.STTS = integer({&pdf-fact}) then do: /* факт */
find first ub.price-doc-forming exclusive-lock  where
        ub.price-doc-forming.pdf-db       = p-pdf-db-num  and
        ub.price-doc-forming.pdf-id       = p-pdf-id      and
        ub.price-doc-forming.plt-db-num   = p-plt-db-num  and
        ub.price-doc-forming.plt-id       = p-plt-id
        no-error .

 empty temp-table x_obj-group.
 find first buf_price-list-type no-lock where
            buf_price-list-type.plt-id    =  ub.price-doc-forming.plt-id and
            buf_price-list-type.plt-db-num = ub.price-doc-forming.plt-db-num no-error .
  run metod-gop-obj in this-procedure ( v-cntxt-db-num,  buf_price-list-type.gop-id , buf_price-list-type.gop-db-num) .

  run metod-delobj-usr (
    ub.price-doc-forming.pdf-id  ,
    ub.price-doc-forming.pdf-db ,
    ub.price-doc-forming.plt-id    ,
    ub.price-doc-forming.plt-db-num
    ).

 for each x_obj-group :
  run adm/shattri.p (
       input "get":U
      ,input x_obj-group.obj-type
      ,input x_obj-group.obj-code
      ,input {&attr-nakl_par}
      ,input  "date-close-period"
      ,output v-value-character
      ,output v-date-close-period
      ,output v-value-decimal
      ,output v-value-integer
      ,output v-value-logical
      ,output v-value-type
      ,INPUT-OUTPUT TABLE thbjattr_thbj-attr
      ) no-error .
  if error-status :error then v-date-close-period = date('').
      if v-date-close-period <> date('') then do:
          if ub.price-doc-forming.sys-date < v-date-close-period
          then do:
            message  substitute(
              "Дата закрытия ДНЦ &1 более ранняя, чем дата закрытия периода &2
              Дата закрытия документа  &3 &2
              Дата закрытия периода    &4 &2
              Объект &5 &6 "
              ,
              ub.price-doc-forming.pdf-id  ,
              {&new-line}  ,
              string ( ub.price-doc-forming.sys-date , "99/99/9999" ) ,
              string ( v-date-close-period,   "99/99/9999") ,
                        x_obj-group.obj-type ,
                        x_obj-group.obj-code  ) view-as alert-box information .
              return.
          end.
      end.
  end. /* по объектам ДНЦ */

    if available ub.price-doc-forming then do :
          ub.price-doc-forming.stts = integer({&pdf-delete}) .
          release ub.price-doc-forming.  /* !!!! */

       /* посылаем на кассу , если нужно , информацию о том что данные надо обновить */
          find first ub.price-doc-forming no-lock  where
                  ub.price-doc-forming.pdf-db       = p-pdf-db-num  and
                  ub.price-doc-forming.pdf-id       = p-pdf-id      and
                  ub.price-doc-forming.plt-db-num   = p-plt-db-num  and
                  ub.price-doc-forming.plt-id       = p-plt-id
                  no-error .
    /* Отправка на кассы , если нужно */
          { gbl/a-nwspdf.i
            ub.price-doc-forming.plt-id
            ub.price-doc-forming.plt-db-num
            ub.price-doc-forming.pdf-id
            ub.price-doc-forming.pdf-db
            v-ask
          }

          if v-ask then do: /* Нужно отправлять */
            run str/diallog.w
                    ( input parparentproc
                    , input this-procedure
                    , input 'str/sendpdfr.p':U
                    , input ("D":U + {&delim-par} +
                            string(ub.price-doc-forming.plt-id) + {&delim-par}  +
                            string(ub.price-doc-forming.plt-db-num) + {&delim-par} +
                            string(ub.price-doc-forming.pdf-id) + {&delim-par}  +
                            string(ub.price-doc-forming.pdf-db)
                            )
                    , input yes /*p-auto-go*/
                    , input '':U
                    , input '') no-error .
                    if error-status :error then do:
                    message
                      vss-workfile vss-revision vss-description skip
                      error-status :get-message(1) skip
                      return-value skip
                      "str/sendpdfr.p"
                      view-as alert-box error
                    .
                    end.
          end.
    end.
end.

if  ub.price-doc-forming.STTS = integer({&pdf-new}) then do:  /* новый        удаляем с концами  */
find first ub.price-doc-forming exclusive-lock  where
        ub.price-doc-forming.pdf-db       = p-pdf-db-num  and
        ub.price-doc-forming.pdf-id       = p-pdf-id      and
        ub.price-doc-forming.plt-db-num   = p-plt-db-num  and
        ub.price-doc-forming.plt-id       = p-plt-id
        no-error .
    if available ub.price-doc-forming then do :
       delete ub.price-doc-forming.
    end.
end.

  end.

end procedure. /* price-doc-forming-DELETE */