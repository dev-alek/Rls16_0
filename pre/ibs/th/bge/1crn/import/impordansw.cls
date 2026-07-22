using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.bge.1crn.import.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impordansw implements ibs.th.bge.1crn.import.iimpsubject:
  define private variable parparentproc   as handle no-undo .
  define variable orderStatus  as class ibs.th.str.order.sts.order no-undo .
  define variable DbNum        as integer no-undo .
  define property Msg as character no-undo
    get.
    set.
  define property Notification as character no-undo
    get.
    set.
  constructor public impordansw():
    find first sys-ctrl no-lock .
    DbNum = sys-ctrl.db-num.
  end constructor.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable vResult    as logical   no-undo.
    define variable vMsg       as character no-undo.
    define variable vNewSts    as integer   no-undo.
    define variable vOrdansw    as class ordansw no-undo.
    define buffer sys-ctrl       for ub.sys-ctrl .
    define buffer buf_order-doc  for ub.order-doc .
    define buffer buf_order-line for ub.order-line .
    orderStatus =  new ibs.th.str.order.sts.order().
    vOrdansw     = cast (subjectObj, ordansw).
    find first buf_order-doc exclusive-lock where
               buf_order-doc.db-num   = DbNum
           and buf_order-doc.doc-code = vOrdansw:order-item no-error no-wait.
    if not avail buf_order-doc then
    do:
      Msg = if locked(buf_order-doc)
            then substitute("Заказ &1 занят другим пользователем.", vOrdansw:order-item)
            else substitute("Заказ &1 не найден.", vOrdansw:order-item).
      return error.
    end.
    assign
      buf_order-doc.order-item = if vOrdansw:order-item-ext <> ?
                                 then vOrdansw:order-item-ext
                                 else buf_order-doc.order-item
      buf_order-doc.info       = if vOrdansw:mess <> "" then vOrdansw:mess else buf_order-doc.info
    .
    vNewSts = statusMapping(vOrdansw:sts).
    if ( vNewSts = orderStatus:Corrected:KeyIntDB and buf_order-doc.sts <> orderStatus:Corrected:KeyIntDB )
    or ( vNewSts = orderStatus:Cancelled:KeyIntDB and buf_order-doc.sts <> orderStatus:Cancelled:KeyIntDB ) then
    do:
      Notification = substitute("&1Заказ № &2 &3 - &4.&5", Notification,
                                if buf_order-doc.order-item <> "" then buf_order-doc.order-item else (string(buf_order-doc.doc-code) + " в TH"),
                                buf_order-doc.cli-name, orderStatus:GetLabel(vNewSts),
                                "~n").
    end.
    buf_order-doc.sts        = if vOrdansw:sts <> 6 then statusMapping(vOrdansw:sts) else buf_order-doc.sts.
    if buf_order-doc.sts = orderStatus:Cancelled:KeyIntDB then
    do:
      for each buf_order-line exclusive-lock where
               buf_order-line.db-num   = buf_order-doc.db-num
           and buf_order-line.doc-code = buf_order-doc.doc-code
      :
          buf_order-line.fact-qnty = 0.
      end.
    end.
    vResult = true.
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = Msg + "; " + exAppErrors:ReturnValue .
      if Msg = "" then Msg = exAppErrors:GetMessage(1) .
      vResult = false.
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      Msg = exProErrors:GetMessage(1) .
      vResult = false.
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error occurred..." .
      vResult = false.
    end catch .
    finally:
      if valid-object(orderStatus) then
        delete object orderStatus no-error.
      return vResult.
    end.
  end method.
  method public void sendNotification():
    define buffer buf_db-attr for ub.db-attr.
    if Notification <> "" then
    do:
      Notification = "ВНИМАНИЕ!~n" + Notification.
      find first buf_db-attr no-lock where
                 buf_db-attr.db-num = DbNum
             and buf_db-attr.attr-code = "orderStatusNitif" no-error.
      if not available (buf_db-attr) or logical(buf_db-attr.attr-value) then
        run utl\proc-msg.p (trim(Notification,"~n")) no-error.
    end.
  end method.
  method private integer statusMapping (iAnswer as integer):
    case iAnswer:
      when 0 then return orderStatus:Shipment:KeyIntDB.
      when 1 then return orderStatus:Corrected:KeyIntDB.
      when 2 then return orderStatus:Cancelled:KeyIntDB.
      when 3 then return orderStatus:DeliveryWaiting:KeyIntDB.
      when 4 then return orderStatus:DeliveryCompleted:KeyIntDB.
      when 5 then return orderStatus:ReceivedProvider:KeyIntDB.
    end case.
    return ?.
  end method.
end class.
