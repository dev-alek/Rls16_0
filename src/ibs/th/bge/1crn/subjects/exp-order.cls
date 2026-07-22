/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт сообщения с заказами в 1С ERPRN order

Автор: Ростовцев Александр Михайлович
Дата создания: 31/03/25
Author: Rostovtsev Aleksandr
Creation date: 31/03/25

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.bge.1crn.export.send1cerpsub.
block-level on error undo, throw.


class ibs.th.bge.1crn.subjects.exp-order inherits send1cerpsub:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Выгрузка Заказов в 1С" get.

  { cmp/str-glbl.i class }

  &scop tag-interface 'orders':U
  define override public property InitSecTag as character no-undo init {&tag-interface}
  get.

  define override public property sendTableName as character no-undo init "order-doc"
    get.
   
   method override public void CheckParam(  ):
    define buffer buf_order-doc  for ub.order-doc .
    define buffer buf_order-line for ub.order-line .

    if not valid-handle(oldbh) then 
    do:
      Msg = "Не передана ссылка на заказ.".
      return error.
    end.

    if oldbh:keys ne "db-num,doc-code" then 
    do: /* проверяем по keys, т.к. имя таблицы может быть любым */
      Msg = "Передан не Заказ.".
      return error.
    end.
    find first buf_order-doc no-lock where 
               buf_order-doc.db-num   = int(oldbh:buffer-field( "db-num":U  ):buffer-value )
           and buf_order-doc.doc-code = int(oldbh:buffer-field( "doc-code":U  ):buffer-value ) no-error .
    if not avail buf_order-doc then 
    do:
      Msg = substitute("Заказ &1 не найден.", oldbh:buffer-field( "doc-code":U  ):buffer-value).
      return error.
    end.

    if can-find(first buf_order-line where 
                      buf_order-line.db-num     = buf_order-doc.db-num
                  and buf_order-line.doc-code   = buf_order-doc.doc-code
                  and buf_order-line.order-qnty <= 0) then
    do:
      Msg = substitute("В заказе &1 не должно быть строк с количеством <= 0.", oldbh:buffer-field( "doc-code":U  ):buffer-value).
      return error.
    end.

    return.

   end method.

  &scop tag-message   'order':U
  &scop tag-section1  'order-goods':U
  &scop tag-item1     'order-good':U
  /*------------------------------------------------------------------------------
   Purpose: выгружает состав сущности в контекст контейнера SAX-writer
   Notes:   обязательный метод
   Param:   insw = create sax-writer
  ------------------------------------------------------------------------------*/
  method override public void CrContentToSW (insw as handle):
    define buffer buf_order-doc  for ub.order-doc .
    define buffer buf_order-line for ub.order-line .
    define buffer buf_user-account for ub.user-account .

    find first buf_order-doc no-lock where 
               buf_order-doc.db-num   = int(oldbh:buffer-field( "db-num":U  ):buffer-value )
           and buf_order-doc.doc-code = int(oldbh:buffer-field( "doc-code":U  ):buffer-value ) no-error .

    sendOldRowid = rowid(buf_order-doc) .
    insw:start-element ({&tag-message}) .
    
    insw:write-data-element (  "order-item":U,  string(buf_order-doc.doc-code)  ).
    insw:write-data-element (  "sup-code":U,    string(buf_order-doc.cli-code)  ).
    insw:write-data-element (  "cont-code":U,   string(buf_order-doc.contract-code)  ).
    insw:write-data-element (  "doc-datetime":U, formatDateTime(buf_order-doc.doc-date)  ).
    insw:write-data-element (  "order-date":U,   formatDate(buf_order-doc.order-date)  ).
    insw:write-data-element (  "creator-order":U,getCreatorOrder(buf_order-doc.user-id)  ).
    
    insw:start-element ({&tag-section1}) .
    for each buf_order-line no-lock where 
             buf_order-line.db-num   = buf_order-doc.db-num
         and buf_order-line.doc-code = buf_order-doc.doc-code:
      insw:start-element ({&tag-item1}) .
      insw:write-data-element (  "gd-code":U,   string(buf_order-line.gds-code)  ).
      insw:write-data-element (  "amount":U,    string(buf_order-line.order-qnty)  ).
      insw:end-element ({&tag-item1}) .
    end .

    insw:end-element ({&tag-section1}) .
    insw:end-element ({&tag-message}) .
    finally:
        if Msg <> "" then
          return error Msg.
    end finally.
  end method . /* end CrContentToSW */
  
  method private character formatDateTime (iDateTime as datetime) :
    define variable vDateTime as character no-undo . /* возвратное значение */
    
    if (iDateTime = ?) then vDateTime = "" .
    else
       vDateTime =  entry(1,iso-date(iDateTime),".")
    .
    
    return vDateTime .
  end method .
  
  method private character formatDate (iDate as date) :
    return if (iDate = ?) then "" else iso-date(iDate) .
  end method .

  method private character getCreatorOrder (iUserId as character) :
    
    define variable vUserName as character no-undo. 
    define buffer buf_user-account for ub.user-account .
    
    if iUserId <> '' then
    do: 
      find first buf_user-account no-lock where 
                 buf_user-account.user-id = iUserId no-error .
      if available (buf_user-account) then 
        vUserName = trim(buf_user-account.last-name + " " + buf_user-account.first-name + " " + buf_user-account.second-name) .
    end.  

    return vUserName.
  end method .


end class.
