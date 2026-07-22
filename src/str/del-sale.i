/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Действия специфические при удалении продажи

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/18/05
Author: Bakhtadze Natalya
Creation date: 10/18/05

1 - inkas-code
2 - obj-type
3 - obj-code
4 - счетчик чеков
5 - del удаление на факт
6 - ставить is-del в буфере {6}
7 - inv - документ инвентраизации иначе параметр hstc-inkas
8 - если 7 = штм метка undo иначе параметр hstc-inkas
9   параметр hstc-inkas
10  параметр hstc-inkas
11  параметр hstc-inkas
12  параметр hstc-inkas

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

&scop my-message "Отвязывание чеков от документа -        "
{&display-message}.
FOR EACH ub.chk-doc WHERE
          ub.chk-doc.obj-type = {2} AND
          ub.chk-doc.obj-code = {3} AND
          ub.chk-doc.out-code = {1}
on error undo _main, return error substitute("Ошибка при удалении/отвязывании чеков при удалении документа &1", {1})
          :

    FOR EACH ub.chk-gds WHERE
              ub.chk-gds.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.chk-gds.
      end.
      else do:
        ub.chk-gds.out-code = ? .
        for each ub.marking-chk where ub.marking-chk.doc-code = ub.chk-gds.doc-code
                                  and ub.marking-chk.line-num = ub.chk-gds.line-num :
          ub.marking-chk.sts = 0 .                       
        end .
      end.
    END .
    FOR EACH ub.chk-pay WHERE
              ub.chk-pay.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.chk-pay.
      end.
      else do:
        ub.chk-pay.out-code = ? .
      end.
    END .
    FOR EACH ub.chk-discnt WHERE
              ub.chk-discnt.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.chk-discnt.
      end.
      else do:
        ub.chk-discnt.out-code = ? .
      end.
    END .
    FOR EACH ub.chk-doc-attr WHERE
              ub.chk-doc-attr.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.chk-doc-attr.
      end.
      else do:
         ub.chk-doc-attr.out-code = ?.
      end.
    END .
    
    
    FOR EACH ub.chk-gds-pay WHERE
             ub.chk-gds-pay.doc-code = ub.chk-doc.doc-code :
      delete ub.chk-gds-pay.
    END .
    
    FOR EACH ub.c-chk-gds WHERE
              ub.c-chk-gds.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-gds.
      end.
      else do:
        ub.c-chk-gds.out-code = ? .
      end.
    END .
    FOR EACH ub.c-chk-pay WHERE
              ub.c-chk-pay.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-pay.
      end.
      else do:
        ub.c-chk-pay.out-code = ? .
      end.
    END .
    FOR EACH ub.c-chk-discnt WHERE
              ub.c-chk-discnt.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-discnt.
      end.
      else do:
        ub.c-chk-discnt.out-code = ? .
      end.
    END .
    FOR EACH ub.c-chk-doc-attr WHERE
              ub.c-chk-doc-attr.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-doc-attr.
      end.
    END .
    FOR EACH ub.c-chk-doc WHERE
              ub.c-chk-doc.doc-code = ub.chk-doc.doc-code :
      if g#news then do:
        delete ub.c-chk-doc.
      end.
      else do:
        ub.c-chk-doc.out-code = ? .
      end.
    END .
&if "{7}" <> "inv" &then
&if "{5}" = "del" &then
    if ub.chk-doc.d-card <> "":u
    and lookup(string(ub.chk-doc.chk-type), {&no-d-card-receipt-codes}) = 0
    then do:
      run str/trnsupds.p (
                      input ub.chk-doc.doc-code
                      ,input false) no-error .
      if error-status:error then do:
        assign
        v-err-mes = substitute("Ошибка при пересчете товарного архива по покупателю: чек &1", chk-doc.doc-code)
        .
        undo _main, return error v-err-mes.
      end.
    end.
&endif
&endif
    if g#news then do:
      delete ub.chk-doc.
    end.
    else do:
      assign
      ub.chk-doc.out-code = ?
      {4} = {4} + 1
      .
    end.
    &scop my-count-message substitute("Отвязывание чеков от документа -       &1", string({4}, "99999"))
    {&display-count-message}.
END .
&if "{7}" <> "inv" &then
&scop my-message "Удаление записей о выручке ..."
{&display-message}.
&if "{5}" = "del" &then
      {6}.is-del = yes.
      if not g#news then do:
        run hstc-inkas in this-procedure (
                                             input {7}
                                            ,input {8}
                                            ,input {9}
                                            ,input {10}
                                            ,input {11}
                                            ,input {12}
                                            ,output {13}
                                            )
                                            {14} .
        if error-status:error then do:
&scop my-message substitute("Ошибка при копировании удаляемой шапки продажи &1:&2&3 &4"   ~
                       , ~{1~}                                                       ~
                       , ~{&new-line~}                                               ~
                       , error-status:get-message(1)                                 ~
                       , return-value )
{&display-message-laud}.
           {&view-log}.
          undo _main, return error.
        end.
     end.
&endif
FOR EACH ub.inkas-pay WHERE
          ub.inkas-pay.inkas-code = {1} :
    delete ub.inkas-pay.
END .
FOR EACH ub.inkas-pay-desk WHERE
          ub.inkas-pay-desk.inkas-code = {1} :
    delete ub.inkas-pay-desk.
END .
FOR EACH ub.inkas-pay-wth WHERE
          ub.inkas-pay-wth.inkas-code = {1} :
    delete ub.inkas-pay-wth.
END .

/*если не inv*/
&endif

/* $Workfile$ e n d */