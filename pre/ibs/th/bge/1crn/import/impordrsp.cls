using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.bge.1crn.import.*.
block-level on error undo, throw.
class ibs.th.bge.1crn.import.impordrsp implements ibs.th.bge.1crn.import.iimpsubject:
method private void getAttrLib ():
   define variable g#attr-lib  as handle no-undo .
   run gbl/getgattrlib.p (output g#attr-lib).
end.
  define buffer buf_db for ub.db.
  define buffer buf_clients for ub.clients.
  define variable orderStatus  as class ibs.th.str.order.sts.order no-undo .
  define property Msg as character no-undo
    get.
    set.
  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable vResult    as logical   no-undo.
    define variable vCount     as integer   no-undo.
    define variable vOrdrsp    as class ordrsp no-undo.
    define variable vOrderGood as class order-good no-undo.
    define variable vOrderGoods as class subjects no-undo.
    define buffer sys-ctrl       for ub.sys-ctrl .
    define buffer buf_order-doc  for ub.order-doc .
    define buffer buf_order-line for ub.order-line .
    define buffer buf_goods      for ub.goods .
    orderStatus =  new ibs.th.str.order.sts.order().
    vOrdrsp     = cast (subjectObj, ordrsp).
    vOrderGoods = vOrdrsp:order-good.
    find first sys-ctrl no-lock .
    find first buf_order-doc exclusive-lock where
               buf_order-doc.db-num   = sys-ctrl.db-num
           and buf_order-doc.doc-code = int(vOrdrsp:order-item) no-error no-wait.
    if not avail buf_order-doc then
    do:
      Msg = if locked(buf_order-doc)
            then substitute("Заказ &1 занят другим пользователем.", vOrdrsp:order-item)
            else substitute("Заказ &1 не найден.", vOrdrsp:order-item).
      return error.
    end.
    do vCount = 1 to vOrderGoods:Get(vCount):
        vOrderGood = cast(vOrderGoods:SubjectObjCurr, order-good) .
        find first buf_order-line exclusive-lock where
                   buf_order-line.db-num   = buf_order-doc.db-num
               and buf_order-line.doc-code = buf_order-doc.doc-code
               and buf_order-line.gds-code = vOrderGood:gd-code no-error.
        if not avail buf_order-line then
        do:
          find first buf_goods where
                     buf_goods.gds-code = vOrderGood:gd-code no-lock no-error.
          if not avail buf_goods then
          do:
            Msg = substitute("Товар &1 не может быть добавлен в заказ. Товар с таким кодом не найден.",
                             vOrderGood:gd-code).
            return error.
          end.
          create buf_order-line.
          assign
            buf_order-line.db-num    = buf_order-doc.db-num
            buf_order-line.doc-code  = buf_order-doc.doc-code
            buf_order-line.gds-code  = vOrderGood:gd-code
            buf_order-line.artic     = buf_goods.artic
            buf_order-line.prod-type = buf_goods.prod-type
            buf_order-line.prod-code = buf_goods.prod-code
          .
        end.
        assign
          buf_order-line.fact-qnty = vOrderGood:amount
        .
    end.
    assign
      buf_order-doc.order-date = vOrdrsp:order-date
    .
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
      return vResult.
    end.
  end method.
end class.
