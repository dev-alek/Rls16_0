define variable mForExtsys as character no-undo.
define variable mHiddenMode as logical no-undo.
define variable mForDb as longchar no-undo.
define variable mForProc as character no-undo.

define variable mSessionBegin as logical no-undo init yes.
define variable mListDb       as character no-undo.
define variable mListDbAll    as character no-undo.
define variable mListKey      as character no-undo.
define variable mListKeyAll   as character no-undo.

define temp-table tt-db no-undo
   field db-num as integer
   index pi is unique primary
    db-num ascending
.
define temp-table tt-extsys no-undo
   field extsys_id as integer
   index pi is unique primary
      extsys_id ascending
.
{ adm/ttbatch.i }

{ cmp/str-glbl.i }
{ utl/search.i }
procedure initProcMode:
   define input  parameter iAutoTypeList as character no-undo.
   define input  parameter iMode as character no-undo.
   
   define variable v-ind as integer no-undo.
   
   if lookup( "H":U, iMode, "+":U ) = 0 
   then do:
      mHiddenMode = false.
      run myenable in this-procedure
         ( input iAutoTypeList
         ) .
   end.
   else do:
      mHiddenMode = true.
   end.

   assign
      mForDb      = "":U
      mForExtsys  = "":U
   .
   block_db-list:
   do v-ind = 1 to num-entries( iMode, "+":U )
   :
      if entry( 1, entry( v-ind, imode, "+":U), ":":U ) = "DB":U 
      then do:
         mForDb = entry( 2, entry( v-ind, imode, "+":U), ":":U ).
         for each tt-db
         :
           delete tt-db .
         end.
         run gbl/prcs-lst.p
            ( input mForDb
            , input 0
            , input 99999  /* (максимальное значение db.db-num) */
            , input false
            , input (buffer tt-db:handle)
            , input "db-num":U
            ) no-error .
         mForDb = "".
         for each tt-db
         :
            mForDb = mForDb + ",":U + string( tt-db.db-num ).
            delete tt-db .
         end.
         mForDb = substring( mForDb, 2 ).
         leave block_db-list .
      end.
    
      if entry( 1, entry( v-ind, iMode, "+":U), ":":U ) = "ExtSys":U 
      then do:
         mForExtsys = entry( 2, entry( v-ind, iMode, "+":U), ":":U ).
         for each tt-extsys
         :
            delete tt-extsys .
         end.
         run gbl/prcs-lst.p
            ( input mForExtsys
            , input 0
            , input 99999  /* (максимальное значение db.db-num) */
            , input false
            , input (buffer tt-extsys:handle)
            , input "extsys_id":U
            ) no-error .
         mForExtsys = "".
         for each tt-extsys
         :
            mForExtsys = mForExtsys + ";":U + string( tt-extsys.extsys_id ).
            delete tt-extsys .
         end.
         mForExtsys = substring( mForExtsys, 2 ).

         leave block_db-list .
      end.
    
      if entry( 1, entry( v-ind, iMode, "+":U), ":":U ) = "ProcName":U 
      then do:
         mForProc = entry( 2, entry( v-ind, iMode, "+":U), ":":U ).
         leave block_db-list .
      end.
   end.
end.
define variable mAsyncProcRun as logical no-undo.
procedure startproc:
   define input  parameter iAutoType as character no-undo.
   define input  parameter iListDb as character no-undo.
   define input  parameter iListKey as character no-undo.
   define input  parameter iStart as datetime-tz no-undo.
   mStartTime = iStart.
 define variable v-db-num as integer no-undo.
 define variable v-ind as integer no-undo.
 define variable v-num-entries-db-list as integer no-undo.
 v-num-entries-db-list = num-entries(iListDb, {&comma-char})
            .
   case iAutoType :
      when {&btpr-type-autonws}
      then do:
         define variable mreadini as character no-undo.
         define variable msesnws as integer no-undo.
         get-key-value section "THAutoSessions" key "NumAsyncSessionsNWS" value mreadini.
         
         assign
            msesnws = 1
            msesnws = integer (mreadini)
         no-error.
         if    mAsyncProcRun 
            or msesnws > 1
         then do:
            mAsyncHelper:maxproc = msesnws.     
            run bge/auto-nws.p
               (input iAutoType 
               ,input this-procedure
               ,input iListDb
            ) no-error.
            
         end.
         else do:
            run nws/exch-nws.p
                  (input this-procedure
                  ,input g#auto-user-id
                  ,input g#auto-user-password
                  ,input iListDb
                  ) no-error.
         end.
          if error-status :error
            then do:
               run write-to-log in this-procedure
                  (input vss-workfile + {&space-char}
                    + "Ошибка при запуске новостей" + {&new-line}
                    + error-status :get-message(error-status :num-messages) + {&new-line}
                    + return-value
               ) .
            end.
      end.
      when {&btpr-type-mercury}
      then do:
         run bge/auto-merc-asunc.p
            (input iAutoType 
            ,input this-procedure
            ,input iListDb
         ) no-error.
      end.
      when {&btpr-type-is_motp}
      then do:
         if mAsyncProcRun
         then
            run addtask (iAutoType,"utl\proc-anyproc.p",substitute ("&2&1&3&1&4&1&5&1&6",
                                                {&delim-par},
                                                "bge/auto-motp.p",
                                                g#auto-user-id,
                                                g#auto-user-password,
                                                iListDb,
                                                no)).
         else
            run bge/auto-motp.p
               (input g#auto-user-id
               ,input g#auto-user-password
               ,input iListDb
               ,input no
            ) no-error.
      end.
      when {&btpr-type-is_diadoc}
      then do:
         run bge/auto-diadoc.p
            (input iAutoType 
            ,input this-procedure
/*                     ,input g#auto-user-password*/
            , input iListDb
            ) no-error.
      end.
      when {&btpr-type-hddtest}
      then do:
         define variable Vdbinfo as char no-undo.
         run adm/db-info.p ( output v-db-num, output Vdbinfo ) no-error.
         if mAsyncProcRun
         then
            run addtask (iAutoType,"utl\proc-anyproc.p",substitute ("&2&1&3&1&4&1&5",
                                                {&delim-par},
                                                "bge/auto-hddtest.p",
                                                g#auto-user-id,
                                                g#auto-user-password,
                                                v-db-num)).
         else
            run bge/auto-hddtest.p
               (input g#auto-user-id
               ,input g#auto-user-password
               ,input v-db-num
            ) no-error.
      end.
      when {&btpr-type-autoarh}
      then do:
         do v-ind = 1 to v-num-entries-db-list
         :
            define variable v-rec-key as character no-undo.
            define variable v-cre-db-num as integer no-undo.
            define variable v-task-type as character no-undo.
            define variable v-task-num as integer no-undo.
            assign
               v-db-num     = integer( entry( v-ind, iListDb, {&comma-char} ) )
               v-rec-key    =          entry( v-ind, iListKey, {&delim-nws} )
               v-cre-db-num = integer( entry( 1, v-rec-key, {&delim-key} ) )
               v-task-type  =          entry( 2, v-rec-key, {&delim-key} )
               v-task-num   = integer( entry( 3, v-rec-key, {&delim-key} ) )
            .
             if mAsyncProcRun
             then
                run addtask (iAutoType,"utl\proc-anyproc.p",substitute ("&2&1&3&1&4&1&5&1&6",
                                                   {&delim-par},
                                                   "adm/calc-arc.p",
                                                   v-db-num,
                                                   v-cre-db-num,
                                                   v-task-type,
                                                   v-task-num)).
             else do:
               run adm/calc-arc.p
                  (input v-db-num
                  ,input v-cre-db-num
                  ,input v-task-type
                  ,input v-task-num
               ) no-error.
               if error-status :error
               then do:
               run write-to-log in this-procedure
                  (input vss-workfile + {&space-char}
                       + "Ошибка при расчете архива" + {&new-line}
                       + error-status :get-message(error-status :num-messages) + {&new-line}
                       + return-value
                  ) .
               end.
            end.
         end.
      end.
      when {&btpr-type-autoexp}
      then do:
         do v-ind = 1 to v-num-entries-db-list :
            assign
               v-db-num     = integer( entry( v-ind, iListDb, {&comma-char} ) )
               v-rec-key    =          entry( v-ind, iListKey, {&delim-nws} )
               v-cre-db-num = integer( entry( 1, v-rec-key, {&delim-key} ) )
               v-task-type  =          entry( 2, v-rec-key, {&delim-key} )
               v-task-num   = integer( entry( 3, v-rec-key, {&delim-key} ) )
            .
            if mAsyncProcRun
             then
                run addtask (iAutoType,"utl\proc-anyproc.p",substitute ("&2&1&3&1&4&1&5&1&6",
                                                   {&delim-par},
                                                   "bge/bge-shd.p",
                                                   v-cre-db-num,
                                                   v-task-type,
                                                   v-task-num,
                                                   v-db-num)).
             else do:
               run bge/bge-shd.p
                  (input v-cre-db-num
                  ,input v-task-type
                  ,input v-task-num
                  ,input v-db-num
               ) no-error.
            end.
         end. /* do v-ind = 1... */
      end.
      when {&btpr-type-autooxml}
      then do:
         do v-ind = 1 to v-num-entries-db-list :
            assign
               v-db-num     = integer( entry( v-ind, iListDb, {&comma-char} ) )
               v-rec-key    =          entry( v-ind, iListKey, {&delim-nws} )
               v-cre-db-num = integer( entry( 1, v-rec-key, {&delim-key} ) )
               v-task-type  =          entry( 2, v-rec-key, {&delim-key} )
               v-task-num   = integer( entry( 3, v-rec-key, {&delim-key} ) )
            .
            run bge/oxmlshd.p
            (input this-procedure:handle
            ,input v-cre-db-num
            ,input v-task-type
            ,input v-task-num
            ,input v-db-num
            ,input mForExtsys
            ) no-error.
         end. /* do v-ind = 1... */
      end.
      when {&btpr-type-autogetcd}
      then do:
         do v-ind = 1 to v-num-entries-db-list :
            assign
               v-db-num     = integer( entry( v-ind, iListDb, {&comma-char} ) )
               v-rec-key    =          entry( v-ind, iListKey, {&delim-nws} )
               v-cre-db-num = integer( entry( 1, v-rec-key, {&delim-key} ) )
               v-task-type  =          entry( 2, v-rec-key, {&delim-key} )
               v-task-num   = integer( entry( 3, v-rec-key, {&delim-key} ) )
            .
            run str/gcd-shd.p
               (input this-procedure:handle
               ,input v-cre-db-num
               ,input v-task-type
               ,input v-task-num
               ,input v-db-num
               ) no-error.
         end. /* do v-ind = 1... */
      end.
      when {&btpr-type-autosuz}
      then do:
         do v-ind = 1 to v-num-entries-db-list
         :
            assign
               v-db-num     = integer( entry( v-ind, iListDb, {&comma-char} ) )
               v-rec-key    =          entry( v-ind, iListKey, {&delim-nws} )
               v-cre-db-num = integer( entry( 1, v-rec-key, {&delim-key} ) )
               v-task-type  =          entry( 2, v-rec-key, {&delim-key} )
               v-task-num   = integer( entry( 3, v-rec-key, {&delim-key} ) )
            .
            run str/suz-shd.p
               (
               input this-procedure:handle
               ,input v-cre-db-num
               ,input v-task-type
               ,input v-task-num
               ,input v-db-num
            ) no-error.
            if error-status :error
            then do:
               run write-to-log in this-procedure
                  (input vss-workfile + {&space-char}
                    + "Ошибка при запуске отчета" + {&new-line}
                    + error-status :get-message(error-status :num-messages) + {&new-line}
                    + return-value
               ) .
            end.
         end.
      end.
      when {&btpr-type-autosale}
      then do:
         do v-ind = 1 to v-num-entries-db-list :
            assign
               v-db-num     = integer( entry( v-ind, iListDb, {&comma-char} ) )
               v-rec-key    =          entry( v-ind, iListKey, {&delim-nws} )
               v-cre-db-num = integer( entry( 1, v-rec-key, {&delim-key} ) )
               v-task-type  =          entry( 2, v-rec-key, {&delim-key} )
               v-task-num   = integer( entry( 3, v-rec-key, {&delim-key} ) )
            .
            run str/sal-shd.p
               (input this-procedure:handle
               ,input v-cre-db-num
               ,input v-task-type
               ,input v-task-num
               ,input v-db-num
               ) no-error.
         end. /* do v-ind = 1... */
      end.
      when {&btpr-type-autocbnk}
      then do:
         do v-ind = 1 to v-num-entries-db-list :
            assign
               v-db-num     = integer( entry( v-ind, iListDb, {&comma-char} ) )
               v-rec-key    =          entry( v-ind, iListKey, {&delim-nws} )
               v-cre-db-num = integer( entry( 1, v-rec-key, {&delim-key} ) )
               v-task-type  =          entry( 2, v-rec-key, {&delim-key} )
               v-task-num   = integer( entry( 3, v-rec-key, {&delim-key} ) )
            .
            run bge/clb-shd.p
               (input this-procedure:handle
               ,input v-cre-db-num
               ,input v-task-type
               ,input v-task-num
               ,input v-db-num
            ) no-error.
         end. /* do v-ind = 1... */
      end.
      when {&btpr-type-autofree}
      then do:
         do v-ind = 1 to v-num-entries-db-list :
            assign
               v-db-num     = integer( entry( v-ind, iListDb, {&comma-char} ) )
               v-rec-key    =          entry( v-ind, iListKey, {&delim-nws} )
               v-cre-db-num = integer( entry( 1, v-rec-key, {&delim-key} ) )
               v-task-type  =          entry( 2, v-rec-key, {&delim-key} )
               v-task-num   = integer( entry( 3, v-rec-key, {&delim-key} ) )
            .
            run adm/freeshdr.p
               (input this-procedure:handle
               ,input v-cre-db-num
               ,input v-task-type
               ,input v-task-num
               ,input v-db-num
            ) no-error.
         end. /* do v-ind = 1... */
      end.
      when {&btpr-type-is_PM}
      then do:
         do v-ind = 1 to v-num-entries-db-list :
            assign
               v-db-num     = integer( entry( v-ind, iListDb, {&comma-char} ) )
               v-rec-key    =          entry( v-ind, iListKey, {&delim-nws} )
               v-cre-db-num = integer( entry( 1, v-rec-key, {&delim-key} ) )
               v-task-type  =          entry( 2, v-rec-key, {&delim-key} )
               v-task-num   = integer( entry( 3, v-rec-key, {&delim-key} ) )
            .
            run bge/auto-exp-is_PM.p
                       (input this-procedure:handle
                        ,input v-db-num
                        ,input v-cre-db-num
                        ,input v-task-type
                        ,input v-task-num
                        ) no-error.
         end. /* do v-ind = 1... */
      end.
   end case.
   
end. 

define variable volddate as date no-undo init ?.
define stream sOutCash.
define variable mFileCashParLog as character no-undo.
procedure AddCashParam:
   define input  parameter p-auto-type-list as character no-undo.
   define input  parameter iToday as date no-undo.
   define input  parameter iTime as integer no-undo.
   
   if mFileCashParLog eq ""
   then do:
      mFileCashParLog = searchfile("cashparam.log").
      if mFileCashParLog eq ?
      then do:
         output stream sOutCash to "cashparam.log" append.
         output stream sOutCash close.
         mFileCashParLog = searchfile("cashparam.log").
         if mFileCashParLog eq ?
         then
            mFileCashParLog = "". 
      end.
   end.
   if (   /* lookup ({&btpr-type-autonws}   ,p-auto-type-list) > 0 
        or */ lookup ({&btpr-type-autooxml}  ,p-auto-type-list) > 0
      )
      and voldDate ne iToday
   then do:
      mAsyncHelper:setTimeOutTask("cashParam",600).
      voldDate = iToday.
      if iTime < 7200 /* 2 * 60 * 60 */
      then
         run addTaskTime in this-procedure ("cashParam","utl/proc-send-all.p" , mFileCashParLog, datetime-tz (month (iToday),day (iToday), year (iToday),2,0 )).
      if iTime < 50400 /* 14 * 60 * 60 */
      then
         run addTaskTime in this-procedure("cashParam","utl/proc-send-all.p" , mFileCashParLog, datetime-tz (month (iToday),day (iToday), year (iToday),14,0 )).
   end.
   
end.

procedure AddUtil:
   define input  parameter p-auto-type-list as character no-undo.
   
   define variable vRun as logical no-undo. 

   if mFileCashParLog eq ""
   then do:
      mFileCashParLog = searchfile("utils.log").
      if mFileCashParLog eq ?
      then do:
         output stream sOutCash to "utils.log" append.
         output stream sOutCash close.
         mFileCashParLog = searchfile("utils.log").
         if mFileCashParLog eq ?
         then
            mFileCashParLog = "".
      end.
   end.
   if (   /* lookup ({&btpr-type-autonws}   ,p-auto-type-list) > 0
        or */ lookup ({&btpr-type-autooxml}  ,p-auto-type-list) > 0
      )
   then do:
      mAsyncHelper:setTimeOutTask("Utils",600).
      
      run utl/chknds22.p (output vRun). 
      if vRun then
      do:
        run addTaskTime in this-procedure("Смена кода ставки НДС с 1 на 11.","utl/run_nds22.p" , mFileCashParLog, datetime-tz (1,1,2026,0,0 )).
      end.
   end.
   
end.


define variable mPrintNextMes as logical no-undo init yes.
procedure checkConect:
   define input  parameter iTitle  as character no-undo.
   define input  parameter iAutoType as character no-undo.
   define output parameter oDbNum  as integer   no-undo.
   define output parameter oDBInfo as character no-undo.
   define variable v-log as logical no-undo.
   run adm/chk-db.p no-error .
   if error-status :error then do:
      run write-to-log (  substitute( "&1. Проверка возможности работы сессии.&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ).
      run gbl/dbdiscon.p no-error.
      if error-status :error then do:
         run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ).
      end.
      return error.
   end.
   if v-socket = false
   then do:
      if iAutoType = {&btpr-type-autonws}
      then do:
         message
            vss-workfile vss-revision vss-description skip
            substitute( 'В параметрах соединения с БД отсутствуют параметры "-S" и "-1".' ) skip
            substitute( 'Работа СПН возможна только в ручном режиме.' ) skip
            substitute( 'Продолжить работу в ручном режиме?' ) skip
            view-as alert-box question buttons yes-no update v-log
         .
         if v-log = true
         then do:
            run gbl/dbdiscon.p no-error.
            if error-status :error then do:
               run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ).
            end.
            return error "HandMode".
            
         end.
      end.
      else do:
         message
            vss-workfile vss-revision vss-description skip
            substitute( 'В параметрах соединения с БД отсутствуют параметры "-S" и "-1".' ) skip
            substitute( '&1 работать не может.', ititle ) skip
            view-as alert-box error
         .
      end.
      return error.
   end.

   run adm/db-info.p ( output oDbNum, output oDBInfo ) no-error.
   if error-status :error
   then do:
      if mPrintNextMes = true then do:
         run write-to-log( vss-workfile + {&space-char}
                         + "Ошибка при считывании информации о текущей БД." + {&new-line}
                         + error-status :get-message(error-status :num-messages) + {&new-line}
                         + return-value
                         ) .
         mPrintNextMes = false.
      end.
      return error "WaitOK".
   end.
   else do:
      mPrintNextMes = true.
   end.
end procedure.

procedure initAsyncProc:
   define input  parameter iTitle as character no-undo.
   define input  parameter iAutoTypeList as character no-undo.
   define input  parameter iWorkType     as character no-undo.
   define input  parameter iNextPeriod as logical no-undo.
   define output parameter oDbInfo as character no-undo.
   
   define variable vi as integer no-undo.
   define variable vAutoType as character  no-undo.
   define variable vError as logical no-undo.
   define variable vConect as logical no-undo.
   define variable vDbNum as integer no-undo.
   do vi = 1 to num-entries (iAutoTypeList):
      vAutoType = entry(vi,iAutoTypeList).
      if lookup(vAutoType, iWorkType) eq 0
      then do:
         if not vConect
         then do:
            
            run adm/autoconn.p no-error.
            if error-status :error 
            then do:
               run write-to-log ( substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message(1) ) ).
               
            end.
            else do:
               vConect = yes.
               run checkConect (input  iTitle, 
                             input  i-auto-type,
                             output vDbNum, 
                             output oDbInfo) no-error.
               if error-status:error
               then do:
                  return error return-value.
               end.
            end.
         end. 
         if iNextPeriod
         then do:
            run adm/chk-sch.p
            ( input  vAutoType
            , input  mForDb
            , output mListDb
            , output mListDbAll
            , output mListKey
            , output mListKeyAll
            , input mForExtsys
            , input mForProc
            , output table tt-BatchProcess
            ) no-error.
         
            run adm/wr-n-bp.p
                ( input this-procedure:handle
                ,input mSessionBegin
                ,input vAutoType
                ,input mListDb
                ,input mForExtsys
                ,input mForProc
                ) no-error.
            if error-status :error
            then do:
               vError = yes.
               run write-to-log( vss-workfile + {&space-char}
                            + "Ошибка при анализе начала следующего сеанса" + {&new-line}
                            + error-status :get-message(error-status :num-messages) + {&new-line}
                            + return-value
                            ) no-error.
               if error-status:error
               then do:
                  run write-to-screen (return-value).
               end.
            end.
         end.
         run adm/chk-sch.p
            ( input  vAutoType
            , input  mForDb
            , output mListDb
            , output mListDbAll
            , output mListKey
            , output mListKeyAll
            , input mForExtsys
            , input mForProc
            , output table tt-BatchProcess
            ) no-error.
         if error-status :error
         then do:
            run write-to-log( vss-workfile + {&space-char}
                            + "Ошибка при чтении расписания." + {&new-line}
                            + error-status :get-message(error-status :num-messages) + {&new-line}
                            + return-value
                            ) .
            return error.
            
         
         end.
         for each tt-BatchProcess:
            run startproc(tt-BatchProcess.BP_Type, 
                          tt-BatchProcess.CharKey_One, 
                          tt-BatchProcess.CharKey_Three, 
                          datetime-tz (tt-BatchProcess.BP_ExecSysDate,tt-BatchProcess.BP_ExecSysTimeInt * 1000)). 
         end.
      end.
   end.
   if iNextPeriod and not vError
   then
      mSessionBegin = false.
   if vConect
   then do:
      run gbl/dbdiscon.p no-error.
      if error-status :error then do:
         run write-to-log (  substitute( "&1. Не удалось отсоединиться от БД&2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message(1) ) ) no-error.
         if error-status:error
         then do:
            run write-to-screen (return-value).
         end.
      end.
   end.
end procedure.
define stream VarStream.
procedure ReedFileContext:
   define variable v-varfile as character no-undo.
   define variable v-varstr as character no-undo.
   define variable mNewHiddenMode as logical no-undo.
   assign
      file-info:file-name = substitute( "./ATH&1.var", g#auto-pid )
      v-varfile           = file-info:full-pathname
   .

   if v-varfile <> ? 
   then do:
      v-varstr = "".
      input stream VarStream from value( v-varfile ) .
      block_read-var:
      repeat :
         import stream VarStream unformatted v-varstr no-error .
         leave block_read-var .
      end.
      input stream VarStream close.
      if lookup( "H":U, v-varstr, "+":U ) = 0 
      then do:
         mNewHiddenMode = false.
      end.
      else do:
         mNewHiddenMode = true.
      end.
      os-delete value( v-varfile ) .
      if mNewHiddenMode <> mHiddenMode 
      then do:
         mHiddenMode = mNewHiddenMode.
         run write-to-log ( substitute( "Смена статуса 'видимости' сессии. Теперь сессия &1видна.", (if mHiddenMode = true then "не":U else "") ) ) no-error.
         if error-status:error
         then do:
            run write-to-screen (return-value).
         end.
      end.
   end.
end.

procedure CheckUpdate:
  define variable CheckUpd      as class ibs.th.adm.upd.CheckUpd no-undo.
  CheckUpd = new ibs.th.adm.upd.CheckUpd ().

  if CheckUpd:isStopWork
  then do:
     run write-to-log ("Идет установка r-кодов. Попробуйте через несколько минут.") .
     delete object CheckUpd no-error.
     return error "Идет установка r-кодов. Попробуйте через несколько минут.".  
  end.
  
  if CheckUpd:isNeedUpd
  then do:
     run write-to-log ("Необходимо обновить базу. Запустите ТН") .
     delete object CheckUpd no-error.
     return error "Необходимо обновить базу. Запустите ТН".  
  end.
  delete object CheckUpd no-error.
end.
