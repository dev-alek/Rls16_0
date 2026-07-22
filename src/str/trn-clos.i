/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: trn-clos.i $
$Archive: str/trn-clos.i $

Триггеры на b-open и b-close в списке документов a l l - d o c s . w

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile: trn-clos.i $ $Revision: aea5316774be, 0, rls $".
on choose of b-open in frame {&frame-name} /* Откр */
  do:
    define buffer bf_inv-doc-attr for ub.inv-doc-attr .
    define buffer buf_doc-line-attr for doc-line-attr.
    DEFINE buffer curr_inv-doc-attr for ub.inv-doc-attr .
    {&net-proc}
    assign
      pardoc-rec = recid (t-doc)
      .
    if t-doc.status_ = {&permitted} then 
    do:
      find first ub.inv-doc-attr no-lock where (ub.inv-doc-attr.attr-code = "ItogInv" or ub.inv-doc-attr.attr-code = "ItogInvManual")and
        ub.inv-doc-attr.doc-code = t-doc.doc-code no-error .
      if available (ub.inv-doc-attr) then 
      do:
        message "Этот документ запрещено открывать!" skip
          "Номер документа" t-doc.doc-code
          view-as alert-box information .
        return .
      end.
      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
      ub.inv-doc-attr.attr-code = 'invMultDevice' no-error .
      if available (ub.inv-doc-attr) then 
      do:
        message "Этот документ запрещено открывать!" skip
          "Номер документа" t-doc.doc-code
          view-as alert-box information .
        return .
      end.
    end.
    { gbl/int-open.i
    parparentproc
    t-doc.doc-code
    gds-list
    no-error
  }
    if error-status :error
      then 
    do:
      find t-doc no-lock
        where recid( t-doc) = pardoc-rec
        .
      return no-apply.
    end.
    find t-doc no-lock
      where recid( t-doc) = pardoc-rec
      .
   
    if t-doc.status_ = {&wayb} then 
    do:  
      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
        ub.inv-doc-attr.attr-code = 'ItogInvManual' no-error .
      if available(ub.inv-doc-attr) then 
      do:
        for each bf_inv-doc-attr exclusive-lock where bf_inv-doc-attr.attr-value = t-doc.doc-code and
          bf_inv-doc-attr.attr-code = 'ManualTSD':
          delete bf_inv-doc-attr .
        end.
      end.
      for each buf_doc-line-attr exclusive-lock where buf_doc-line-attr.doc-code = t-doc.doc-code and
          buf_doc-line-attr.attr-code = 'tsd-qnty':
          delete buf_doc-line-attr .
        end.
    end.    
    run UI-on in this-procedure ( input "open" ).
    return no-apply.
  END.

&Scop if-not-clos if not varlog then do: find t-doc where recid( t-doc ) = pardoc-rec. return error. end.

/* --------------------------------------------- начало триггера b-close ------------------------------------------- */
ON CHOOSE OF b-close IN FRAME {&frame-name} /* Закр */
  DO:
    define buffer bf_inv-doc-attr for ub.inv-doc-attr .
    define buffer curr_inv-doc-attr for ub.inv-doc-attr .
    define buffer del_inv-doc-attr for ub.inv-doc-attr .
    define variable p-ok as logical no-undo .
    define variable ii      as integer   no-undo .
    define variable docCode as character no-undo .
    
    {&net-proc}
    assign
      pardoc-rec = recid (t-doc)
      .

    if t-doc.doc-type = {&inventory} and t-doc.status_ = {&permitted} then 
    do:
    
      /* Проверка на заполнение атрибутов */
      define variable is-pos   as logical   no-undo .
      define variable is-date  as logical   no-undo .
      define variable is-fio   as logical   no-undo .
      define variable is-check as logical   no-undo .
      define variable is-mes   as character no-undo .

      define buffer fio_inv-doc-attr    for ub.inv-doc-attr .
      define buffer pos_inv-doc-attr    for ub.inv-doc-attr .
      define buffer prikaz_inv-doc-attr for ub.inv-doc-attr .
  
      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
        ub.inv-doc-attr.attr-code = "invTech" and
        ub.inv-doc-attr.attr-value = string(true) no-error .
      if not available (ub.inv-doc-attr) then 
      do:
        if not can-find (first prikaz_inv-doc-attr no-lock where prikaz_inv-doc-attr.doc-code = t-doc.doc-code and
          prikaz_inv-doc-attr.attr-code = {&trdcattr-prikaz-date} and
          prikaz_inv-doc-attr.attr-value <> "") then 
        do:
          is-date = true .
          is-check = true .
        end.
        if not can-find (first fio_inv-doc-attr no-lock where fio_inv-doc-attr.doc-code = t-doc.doc-code and
          (fio_inv-doc-attr.attr-code = {&trdcattr-fio-agent} or
          fio_inv-doc-attr.attr-code = {&trdcattr-fio-player1} or
          fio_inv-doc-attr.attr-code = {&trdcattr-fio-player2} or
          fio_inv-doc-attr.attr-code = {&trdcattr-fio-player3}) and
          fio_inv-doc-attr.attr-value <> "") then 
        do:
          is-fio = true .
          is-check = true .
        end.
        if not can-find (first fio_inv-doc-attr no-lock where fio_inv-doc-attr.doc-code = t-doc.doc-code and
          (fio_inv-doc-attr.attr-code = {&trdcattr-pos-agent} or
          fio_inv-doc-attr.attr-code = {&trdcattr-pos-player1} or
          fio_inv-doc-attr.attr-code = {&trdcattr-pos-player2} or
          fio_inv-doc-attr.attr-code = {&trdcattr-pos-player3}) and
          fio_inv-doc-attr.attr-value <> "")then 
        do:
          is-pos = true .
          is-check = true .
        end.
      
        if is-check then 
        do:

          is-mes = "Ошибка при закрытии документа инвентаризации." .

          if is-date then 
          do:
            is-mes = is-mes + {&new-line} + "Не указана дата приказа." .
          end.
          if is-fio then 
          do:
            is-mes = is-mes + {&new-line} + "Не указано ФИО." .
          end.
          if is-pos then 
          do:
            is-mes = is-mes + {&new-line} + "Не указана должность." .
          end.
      
        end.
        /* Проверка на заполнение по парам ФИО и должность */
      
        find first fio_inv-doc-attr no-lock where 
          fio_inv-doc-attr.doc-code = t-doc.doc-code and
          fio_inv-doc-attr.attr-code = {&trdcattr-fio-agent} and 
          fio_inv-doc-attr.attr-value <> "" no-error .
        if not available (fio_inv-doc-attr) then 
        do:
          find first pos_inv-doc-attr no-lock where 
            pos_inv-doc-attr.doc-code = t-doc.doc-code and
            pos_inv-doc-attr.attr-code = {&trdcattr-pos-agent} and 
            pos_inv-doc-attr.attr-value <> "" no-error . 
          if available (pos_inv-doc-attr) then 
          do:
            if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." .  
            is-mes = is-mes + "Не заполнена ФИО председателя комиссии." + {&new-line}. 
          end.         
        end. 
        else 
        do:
          find first pos_inv-doc-attr no-lock where 
            pos_inv-doc-attr.doc-code = t-doc.doc-code and
            pos_inv-doc-attr.attr-code = {&trdcattr-pos-agent} and 
            pos_inv-doc-attr.attr-value <> "" no-error . 
          if not available (pos_inv-doc-attr) then 
          do:
            if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." . 
            is-mes = is-mes + "Не заполнена должность председателя комиссии." + {&new-line}.                
          end. 
        end.
        
        find first fio_inv-doc-attr no-lock where 
          fio_inv-doc-attr.doc-code = t-doc.doc-code and
          fio_inv-doc-attr.attr-code = {&trdcattr-fio-player1} and 
          fio_inv-doc-attr.attr-value <> "" no-error .
        if not available (fio_inv-doc-attr) then 
        do:
          find first pos_inv-doc-attr no-lock where 
            pos_inv-doc-attr.doc-code = t-doc.doc-code and
            pos_inv-doc-attr.attr-code = {&trdcattr-pos-player1} and 
            pos_inv-doc-attr.attr-value <> "" no-error . 
          if available (pos_inv-doc-attr) then 
          do:
            if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." . 
            is-mes = is-mes + "Не заполнена ФИО первого участника комиссии." + {&new-line}.          
          end. 
        end.
        else 
        do:
          find first pos_inv-doc-attr no-lock where 
            pos_inv-doc-attr.doc-code = t-doc.doc-code and
            pos_inv-doc-attr.attr-code = {&trdcattr-pos-player1} and 
            pos_inv-doc-attr.attr-value <> "" no-error . 
          if not available (pos_inv-doc-attr) then 
          do:
            if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." . 
            is-mes = is-mes + "Не заполнена должность первого участника комиссии." + {&new-line}.                
          end.           
        end.

        find first fio_inv-doc-attr no-lock where 
          fio_inv-doc-attr.doc-code = t-doc.doc-code and
          fio_inv-doc-attr.attr-code = {&trdcattr-fio-player2} and 
          fio_inv-doc-attr.attr-value <> "" no-error .
        if not available (fio_inv-doc-attr) then 
        do:
          find first pos_inv-doc-attr no-lock where 
            pos_inv-doc-attr.doc-code = t-doc.doc-code and
            pos_inv-doc-attr.attr-code = {&trdcattr-pos-player2} and 
            pos_inv-doc-attr.attr-value <> "" no-error . 
          if available (pos_inv-doc-attr) then 
          do:
            if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." . 
            is-mes = is-mes + "Не заполнена ФИО второго участника комиссии." + {&new-line}.          
          end.
        end. 
        else 
        do:
          find first pos_inv-doc-attr no-lock where 
            pos_inv-doc-attr.doc-code = t-doc.doc-code and
            pos_inv-doc-attr.attr-code = {&trdcattr-pos-player2} and 
            pos_inv-doc-attr.attr-value <> "" no-error . 
          if not available (pos_inv-doc-attr) then 
          do:
            if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." . 
            is-mes = is-mes + "Не заполнена должность второго участника комиссии." + {&new-line}.  
          end.              
        end.   

        find first fio_inv-doc-attr no-lock where 
          fio_inv-doc-attr.doc-code = t-doc.doc-code and
          fio_inv-doc-attr.attr-code = {&trdcattr-fio-player3} and 
          fio_inv-doc-attr.attr-value <> "" no-error .
        if not available (fio_inv-doc-attr) then 
        do:
          find first pos_inv-doc-attr no-lock where 
            pos_inv-doc-attr.doc-code = t-doc.doc-code and
            pos_inv-doc-attr.attr-code = {&trdcattr-pos-player3} and 
            pos_inv-doc-attr.attr-value <> "" no-error . 
          if available (pos_inv-doc-attr) then 
          do:
            if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." . 
            is-mes = is-mes + "Не заполнена ФИО третьего участника комиссии." + {&new-line}.          
          end. 
        end.
        else 
        do:
          find first pos_inv-doc-attr no-lock where 
            pos_inv-doc-attr.doc-code = t-doc.doc-code and
            pos_inv-doc-attr.attr-code = {&trdcattr-pos-player3} and 
            pos_inv-doc-attr.attr-value <> "" no-error . 
          if not available (pos_inv-doc-attr) then 
          do:
            if is-mes = "" then is-mes = "Ошибка при закрытии документа инвентаризации." . 
            is-mes = is-mes + "Не заполнена должность третьего участника комиссии." + {&new-line}.                
          end.   
        end.
        if is-mes <> "" then 
        do:
          message
            is-mes
            view-as alert-box .
          return no-apply.
        end.
      end.
    if t-doc.status_ = {&permitted} then do:
        run proc-close-inv (output p-ok).      
        if not p-ok then return no-apply .  
     
    end.
    end .

    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
      ub.inv-doc-attr.attr-code = 'invMultDevice' and 
      ub.inv-doc-attr.attr-value = string(true) no-error .
    if available (ub.inv-doc-attr) and t-doc.status_ = {&permitted} then return no-apply .

  
    { gbl/int-clos.i
    parparentproc
    t-doc.doc-code
    gds-list
    no-error
  }
    if error-status :error
      then 
    do:
      find t-doc no-lock
        where recid( t-doc) = pardoc-rec
        .
      return no-apply.
    end.
    find t-doc
      no-lock where recid( t-doc ) = pardoc-rec.
    if t-doc.status_ = {&fact} then 
    do:  

      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
        ub.inv-doc-attr.attr-code = 'ItogInv' no-error .
      if available(ub.inv-doc-attr) then 
      do:
        for each ub.trn-doc exclusive-lock where ub.trn-doc.doc-code begins ub.inv-doc-attr.attr-value:
          if entry(2,ub.trn-doc.doc-code,"/") = "и" then next .
          delete ub.trn-doc .
        end.
        
      for each del_inv-doc-attr exclusive-lock where del_inv-doc-attr.attr-value = t-doc.doc-code and
      del_inv-doc-attr.attr-code = "MultiTSD":
       find first ub.trn-doc exclusive-lock where ub.trn-doc.doc-code = del_inv-doc-attr.doc-code no-error .
       if available (ub.trn-doc) then delete ub.trn-doc .
      end.
      end.
      
      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
        ub.inv-doc-attr.attr-code = 'ItogInvManual' no-error .
      if available(ub.inv-doc-attr) then 
      do:
        for each bf_inv-doc-attr no-LOCK where bf_inv-doc-attr.attr-value = t-doc.doc-code and
          bf_inv-doc-attr.attr-code = 'ManualTSD':
          for each ub.trn-doc exclusive-lock where ub.trn-doc.doc-code = bf_inv-doc-attr.doc-code:
            if docCode = "" then docCode = ub.trn-doc.doc-code .
            else docCode = docCode + ";" + ub.trn-doc.doc-code .
            delete ub.trn-doc .
            for first curr_inv-doc-attr EXCLUSIVE-LOCK where curr_inv-doc-attr.attr-code = bf_inv-doc-attr.attr-code and
            curr_inv-doc-attr.doc-code = bf_inv-doc-attr.doc-code:
            delete bf_inv-doc-attr .
            end.
          end.
        end.
        define variable dd as integer no-undo .
        do dd = 1 to num-entries(docCode,";"):
              for first bf_inv-doc-attr no-lock where bf_inv-doc-attr.attr-code = 'isManualError' and
                  bf_inv-doc-attr.doc-code = entry(dd,docCode,";") + "-M" :
                  message "В системе есть ошибочные накладные инвентаризации." skip
                      "Удалить их?"  view-as alert-box question buttons yes-no update v-ok as logical .
                  if v-ok then 
                  do:
                      for each ub.trn-doc exclusive-lock where ub.trn-doc.doc-code = bf_inv-doc-attr.doc-code:
                          delete ub.trn-doc .
                      end.
                  end.
              end. 
          end.    
      end.
    end.
    if t-doc.status_ = {&permitted} then 
    do:  
      find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.doc-code = t-doc.doc-code and
        ub.inv-doc-attr.attr-code = 'ItogInvManual' no-error .
      if available(ub.inv-doc-attr) then 
      do:
        do ii = 1 to num-entries(ub.inv-doc-attr.attr-value):
          create bf_inv-doc-attr .
          assign
            bf_inv-doc-attr.attr-code  = 'ManualTSD'
            bf_inv-doc-attr.doc-code   = entry(ii,ub.inv-doc-attr.attr-value)
            bf_inv-doc-attr.attr-value = t-doc.doc-code
            .
        end.
      end.
    end.    
    run UI-on in this-procedure ( input "open" ) .
    reposition {&browse-name} to recid pardoc-rec no-error.

  END.

/* --------------------------------------------- конец триггера b-close ------------------------------------------- */

{ str/plgdsfnd.i }

/* $Workfile: trn-clos.i $   E n d */