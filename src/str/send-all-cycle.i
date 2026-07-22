/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

отсылка схемы интеграции ККТ - цикл по всем кассам одного типа

Автор: Шкляр Елена 
Дата создания: 02/14/14
Author: Elena Shklyar
Creation date: 02/14/14

*/

&scoped-define vssseq {&sequence}
define variable vss-include-info{&vssseq} as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".

procedure   for-cash-cycle:
   define variable v-cash-types as character no-undo init {&cd-type-ibm-xml}.
   define variable V-root-teg   as character no-undo init "data".
   define variable v-xml-encoding as character no-undo init "windows-1251".
   define variable v-tag-from   as character no-undo.
   define variable v-tag-to     as character no-undo.
/*   define variable v-cash-type  as character no-undo.*/
   define variable v-work-handle as handle no-undo .
   if     search("str/send-all-work-" + i-type + ".p") eq ?
      and search("str/send-all-work-" + i-type + ".r") eq ?
   then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Не найдена str/send-all-work-&1.r"
                                ,i-type
                                
                            )
                                            ).
      v-view-log = yes.
      return.
   end.
   run value ( "str/send-all-work-" + i-type + ".p") persistent set v-work-handle no-error .
   if error-status:error then do:
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!Ошибка при выполнение процедуры str/send-all&1.r (&2) : &3 &4"
                                ,i-type
                                ,search("str/send-all" + i-type + ".p")
                                ,return-value
                                ,error-status:get-message (1)
                            )
                                            ).
      v-view-log = yes.
      return.
   end.
   if lookup("get-xml-encoding", v-work-handle:internal-entries) >  0
   then do:
      run get-xml-encoding  in v-work-handle (output v-xml-encoding) no-error.
      if error-status:error then do:
         run write-log-and-file in p-log-handle (
               input 1
             , input log-file-name
             , input 1
             , input substitute( "!!!Ошибка при выполнение процедуры &1 (str/send-all&4.r) : &2 &3"
                                   ,"get-xml-encoding"
                                   ,return-value
                                   ,error-status:get-message (1)
                                   , i-type
                                   
                               )
                                               ).
         v-view-log = yes.
         return.
      end.
   end.
   if lookup("get-tag-from", v-work-handle:internal-entries) >  0
   then do:
      run get-tag-from in v-work-handle (output v-tag-from) no-error.
      if error-status:error then do:
         run write-log-and-file in p-log-handle (
               input 1
             , input log-file-name
             , input 1
             , input substitute( "!!!Ошибка при выполнение процедуры &1 (str/send-all&4.r) : &2 &3"
                                   ,"get-teg-from"
                                   ,return-value
                                   ,error-status:get-message (1)
                                   , i-type
                                   
                               )
                                               ).
         v-view-log = yes.
         return.
      end.
   end.
   if lookup("get-tag-to", v-work-handle:internal-entries) >  0
   then do:
      run get-tag-to in v-work-handle (output v-tag-to) no-error.
      if error-status:error then do:
         run write-log-and-file in p-log-handle (
               input 1
             , input log-file-name
             , input 1
             , input substitute( "!!!Ошибка при выполнение процедуры &1 (str/send-all&4.r) : &2 &3"
                                   ,"get-teg-to"
                                   ,return-value
                                   ,error-status:get-message (1)
                                   , i-type
                                   
                               )
                                               ).
         v-view-log = yes.
         return.
      end.
   end.

   if lookup("get-cash-types", v-work-handle:internal-entries) >  0
   then do:
      run get-cash-types  in v-work-handle (output v-cash-types) no-error.
      if error-status:error then do:
         run write-log-and-file in p-log-handle (
               input 1
             , input log-file-name
             , input 1
             , input substitute( "!!!Ошибка при выполнение процедуры &1 (str/send-all&4.r) : &2 &3"
                                   ,"get-cash-types"
                                   ,return-value
                                   ,error-status:get-message (1)
                                   , i-type
                                   
                               )
                                               ).
         v-view-log = yes.
         return.
      end.
   end.
   if lookup(ub.cash-desk.pos-type,v-cash-types) ne 0
   then do:
      if lookup("get-root-teg", v-work-handle:internal-entries) >  0
      then do:
         run get-root-teg in v-work-handle (output V-root-teg) no-error.
         if error-status:error then do:
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Ошибка при выполнение процедуры &1 (str/send-all&4.r) : &2 &3"
                                      ,"get-roor-teg"
                                      ,return-value
                                      ,error-status:get-message (1)
                                      ,i-type
                                      
                                  )
                                                  ).
            v-view-log = yes.
            return.
         end.
      end.
      define variable vProcInfo as character no-undo.
      if lookup("set-context", v-work-handle:internal-entries) >  0
      then do:
         run set-context in v-work-handle (parparentproc,
                                           p-log-handle,
                                           log-file-name,
                                           output vProcInfo) no-error.
         if error-status:error then do:
            run write-log-and-file in p-log-handle (
                  input 1
                , input log-file-name
                , input 1
                , input substitute( "!!!Ошибка при выполнение процедуры &1 (str/send-all&4.r) : &2 &3"
                                      ,"set-context"
                                      ,return-value
                                      ,error-status:get-message (1)
                                      ,i-type
                                      
                                  )
                                                  ).
            v-view-log = yes.
            return.
         end.
      end.
      run write-log-and-file in p-log-handle (
                        input 1
                      , input log-file-name
                      , input 1
                      , input substitute( 'Обработка запроса &1 на кассы магазина &2 начата'
                                            ,if vProcInfo ne "" then '"' + vProcInfo + '"' else ""
                                            ,i-obj-code
                                           
                                        )
                                                        ). 
      define buffer for-cash-desk for ub.cash-desk.
/*      define variable vi as integer no-undo.*/
   
/*   do vi = 1 to num-entries(v-cash-types): */
/*      v-cash-type = entry(vi,v-cash-types).*/
      define variable mQuery as handle    no-undo.
      define variable vqry   as character no-undo.
      create query mQuery.
      mQuery:set-buffers(buffer for-cash-desk:HANDLE).
      vqry = substitute("for each for-cash-desk no-lock where
                                  for-cash-desk.db-num   eq &1 
                              and for-cash-desk.pos-type eq '&2'      
                              and for-cash-desk.obj-code eq &3 " 
                           ,  g#db-num, ub.cash-desk.pos-type,i-obj-code).
      if mCashNum ne ?
      then
         vqry = vqry + substitute(" and for-cash-desk.cash-num eq &1", mCashNum).
      else
         vqry = vqry + " and for-cash-desk.is-del   ne  true
                         and for-cash-desk.autonomy ne {&bef-cd-slave}". 
      if not mSendAll 
      then
         vqry = vqry + " and for-cash-desk.cash-on  eq yes".
         
      vqry = vqry + "   
 by for-cash-desk.db-num
 by for-cash-desk.obj-code
 by for-cash-desk.pos-type
 by for-cash-desk.cash-on ". 
      mQuery:query-prepare(vqry).
      mQuery:query-open ().
      mQuery:get-first ().
                                                                         
      do while not mQuery:query-off-end:
        if lookup("set-cash-info", v-work-handle:internal-entries) >  0
        then do:
            run set-cash-info in v-work-handle (for-cash-desk.db-num,
                                                {&shop},
                                                for-cash-desk.obj-code,
                                                for-cash-desk.pos-type,
                                                for-cash-desk.cash-num) no-error.
            if error-status:error then do:
               run write-log-and-file in p-log-handle (
                     input 1
                   , input log-file-name
                   , input 1
                   , input substitute( "!!!Ошибка при выполнение процедуры &1 (str/send-all&4.r) : &2 &3"
                                         ,"set-cash-info"
                                         ,return-value
                                         ,error-status:get-message (1)
                                         ,i-type
                                     )
                                                     ).
              v-view-log = yes.
              return.
           end.
        end. 
        run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "Пересылка - касса &1", for-cash-desk.cash-num 
                              )
                                              ).
        
        { str/send-all-genoutc.i
        &out-title = i-Title 
        }
        /*сформируем вывод для кассы определенного типа*/
        define variable vOk as logical no-undo.
        run putc in v-work-handle
                     ( input hSAXWriter
                      ,i-action
                      ,input i-value
                      ,output vOk
                      ) no-error.
        if error-status:error then do:
               run write-log-and-file in p-log-handle (
                     input 1
                   , input log-file-name
                   , input 1
                   , input substitute( "!!!Ошибка при выполнение процедуры &1 (str/send-all&4.r) : &2 &3"
                                         ,"putc"
                                         ,return-value
                                         ,error-status:get-message (1)
                                         ,i-type
                                     )
                                                     ).
              v-view-log = yes.
              return.
        end.
        if not vOk
        then
           run write-log-and-file in p-log-handle (
              input 1
            , input log-file-name
            , input 1
            , input substitute( "Запрос данных с кассы не требуется - касса &1", for-cash-desk.cash-num
                              )
                                              ).
        { str/send-all-gencloc.i
        &out-title= i-Title
        }
      
      
         mQuery:get-next ().
      end . /*for each for-cash-desk*/
      delete object mQuery.
   end.
   run write-log-and-file in p-log-handle (
                     input 1
                   , input log-file-name
                   , input 1
                   , input substitute( 'Обработка запроса &1 на кассы магазина &2 завершена'
                                         ,'"' + vProcInfo + '"'
                                         ,i-obj-code
                                        
                                     )
                                                     ). 
   if valid-handle(v-work-handle) then do:
      delete procedure v-work-handle  .
    end.
end procedure.

/* $Workfile$ e n d */