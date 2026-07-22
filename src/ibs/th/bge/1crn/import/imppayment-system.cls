/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Класс ипорта данных payment-agent (Информация по типам кассовых книг) из 1С

Автор: Молотков Сергей
Дата создания: 21/05/19
Author: Molotkov Sergey
Creation date: 21/05/19

*/
&scoped-define impclass payment-system
using ibs.th.bge.1crn.subjects.subjects.
using ibs.th.bge.1crn.subjects.{&impclass}.

block-level on error undo, throw.

class ibs.th.bge.1crn.import.imp{&impclass} implements ibs.th.bge.1crn.import.iimpsubject: 

/*
  { ibs/th/ref/ttCashBook.i }
  { ibs/th/ref/ttCashBookRule.i }
*/  
  { cmp/str-glbl.i class } /* &add-def, &update, &deletion, &shop, &attr-cash-book-id, &attr-oper-serv-id */

  define private temp-table tt-code no-undo
    field f-code as character 
  .
  
  
  define property Msg as character no-undo
    get. 
    set.

  method public logical Excute( subjectObj as class ibs.th.bge.1crn.subjects.isubject ):
    define variable objImp    as class {&impclass} no-undo.
    define variable v-retfl   as logical no-undo .
    define variable v-mode    as character no-undo. /* create/update */

    define variable v-payment-system as class ibs.th.bge.1crn.subjects.{&impclass} no-undo .
    define variable v-code      as character no-undo .
    define variable v-name      as character no-undo .
    
    define variable v-objlist   as class ibs.th.bge.1crn.subjects.subjects no-undo . // imp:kb-gds[]
    define variable v-i-counter as integer no-undo .
    define variable v-i-num     as integer no-undo .
    define variable v-stub      as integer no-undo .
    define variable v-bin-range as class ibs.th.bge.1crn.subjects.bin-range no-undo .
  //  define variable v-str-ossid as character no-undo .

    define buffer buf_code   for ub.code .
    define buffer buf_bin    for ub.code .
    
    Msg        = "":U .
    /* платёжный агент (до 21/V-2019):
      - ext-code платёжного агента совпадает с ext-code кассовой книги, к которой он относится в 1с;
      - новый платёжный агент добавляется, старый - обновляется;
      - при удалении Status_ у платёжного агента изменяется как Status_ у кассовой книги.
      Ид. платёжного агента далее используется вместе с ид.кассовой книги для привязки товара к кассовой книге.
    */
    objImp = cast (subjectObj, {&impclass}).
    v-payment-system = objImp .
    v-code = v-payment-system:code_ . /* обязательность 1-1 */
    v-name = v-payment-system:name_ . /* обязательность 0-1 */
    &glob codename "PlatSys"
    find first buf_code no-lock
         where buf_code.code = {&codename} no-error .
    if not available buf_code
    then do:
       create buf_code .
       assign
          buf_code.code       = {&codename}
          buf_code.codename   = "Платежные системы".
          buf_code.procview   = "ibs\th\ref\code\platsys.p".
       .
    end.
    
    find first buf_code exclusive-lock
         where buf_code.parent     = {&codename} 
           and buf_code.code = v-code no-error .
    if available buf_code then do :
      v-mode = {&update} .
    end .
    else do :
      create buf_code .
      assign
        v-mode = {&add-def}
        buf_code.code       = v-code
        buf_code.parent     = {&codename}
      .
    end .
    buf_code.codename       = v-name.
    
    
    empty temp-table tt-code .
    define variable mparent as character no-undo.
    mparent = buf_code.parent + {&delim-par} + buf_code.code.
    v-objlist = objImp:bin-ranges .
    if valid-object(v-objlist) then do :
      
      v-i-counter = v-objlist:iCounter .
      do v-i-num = 1 to v-i-counter :
        v-stub = v-objlist:Get(v-i-num) . // возвращает кол-во элементов и переключает currItem
        v-bin-range = cast(v-objlist:SubjectObjCurr, ibs.th.bge.1crn.subjects.bin-range) .
        create tt-code.
        tt-code.f-code = v-bin-range:range .
      end . // end_of_objImp:gds[]
      
      
      /* Отвязать от других платёжных. Скопировано из attr-lib:gds-attr-DELETE() */
      if v-mode = {&update} then do :
        for each buf_bin exclusive-lock
           where buf_bin.parent  = mparent
             :
          if not can-find (first tt-code where tt-code.f-code = buf_bin.code) then
            delete buf_bin.
        end .
      end .
      
      /* Перепривязать к пришедшему платёжному агенту. Скопировано из attr-lib:gds-attr-write() */
      for each tt-code :
        find first buf_bin exclusive-lock
               where buf_bin.parent  = mparent
                 and buf_bin.code    = tt-code.f-code  no-error .
        if not available buf_bin 
        then  do:
          create buf_bin .
          assign
            buf_bin.parent  = mparent
            buf_bin.code    = tt-code.f-code
            
          .
        end.
        buf_bin.CodeName = v-name.
      end .
      
    end. // end_of_gds


    v-retfl = true.
    
    define variable i as integer no-undo .
    catch exAppErrors as class Progress.Lang.AppError :
      Msg = exAppErrors:ReturnValue .
      if Msg > "" then . else do :
        do i = 1 to exAppErrors:NumMessages :
          Msg = Msg + {&new-line} + exAppErrors:GetMessage(i) .
        end .
        if Msg > "" then . else Msg = "AppError в платёжных агентах" .
      end .
      v-retfl = false .
      undo, throw exAppErrors .
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      do i = 1 to exProErrors:NumMessages :
        Msg = Msg + {&new-line} + exProErrors:GetMessage(i) .
      end .
      if Msg > "" then . else Msg = "ProError в платёжных агентах" .
      v-retfl = false.
      undo, throw exProErrors .
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      Msg = "Unexpected error в платёжных агентах" .
      v-retfl = false .
      undo, throw exAnyErrors .
    end catch .
    finally :
      return v-retfl .
    end finally .
  end method. /* end_of Excute */

end class.
