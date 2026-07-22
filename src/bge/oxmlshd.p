block-level on error undo, throw.
/*

$Revision: 82f568d3f6c1, 3551, rls $
$Author: ARostovtsev $
$Date: 2023/11/27 08:31:18 $
$Workfile: oxmlshd.p $
$Archive: bge/oxmlshd.p $

Обмен OpenXML по расписанию.

Автор: Хныкин Павел Андреевич
Дата создания: 04/12/06
Author: Pavel Khnykin
Creation date: 04/12/06

Input:

Output:

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-cre-db-num as integer   no-undo .
define input parameter p-task-type  as character no-undo .
define input parameter p-task-num   as integer   no-undo .
define input parameter p-db-num     as integer   no-undo .
define input parameter p-extsys     as char   no-undo .

define variable vss-revision    as character no-undo init "$Revision: 82f568d3f6c1, 3551, rls $":U .
define variable vss-author      as character no-undo init "$Author: ARostovtsev $":U .
define variable vss-date        as character no-undo init "$Date: 2023/11/27 08:31:18 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: oxmlshd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/oxmlshd.p $":U .
define variable vss-description as character no-undo init "Обмен OpenXML по расписанию.".
{ cmp/vssrevis.i    }
{ cmp/trg-def.i     }
&global-define tab-shift 2
{ bge/oxml-def.i    }
{ str/auto2dia.i    }

define variable v-err-code as integer no-undo .
define variable v-message as character no-undo .
define variable v-ind as int no-undo .

define buffer buf_BatchProcess      for ub.BatchProcess.

do
on error undo, return error
:

    assign
    g#esys                = true
    .
    run gbl/set-gbl.p
      (input  true
      ,input  g#auto-user-id
      ,input  g#auto-user-password
      ) no-error.
    if error-status :error
    then do:
        run write-to-log( vss-workfile + {&space-char}
                        + "!!!Ошибка при инициализации переменных g#..." + {&new-line}
                        + error-status:get-message(error-status:num-messages)
                        + return-value
                        ) .
        return error.
    end.
    assign
    g#esys                = true
    .
    /*сначала примем потому что процесс приема может породит новые руты*/
    run bge/oxmlinx.p (
          input parparentproc
        , input this-procedure
        , input this-procedure
        , input substitute("&1,&2,&3,&4"
                          , "take+analys"
                          , p-db-num
                          , p-extsys
                          , 0)   /*Т.к. внешние системы заводятся сейчас только в ГБД, то номер БД у них всегде 0. Если ситуация изменится, то надо будет переделать насттройку сессий оxml тоже*/
    ) no-error.
    if error-status :error
    then do:
        run write-to-log in this-procedure ( substitute( "&2&1Ошибка загрузки OpenXML&1&3&1&4"
                                        , {&new-line}
                                        , vss-workfile
                                        , return-value
                                        , error-status :get-message( error-status :num-messages )
                                    )
                        ) .
    end.



    run write-to-log ( substitute( "Подготовка новых пакетов." ) ).

    run bge/cnewxpck.p (
                      input p-extsys
                    , output v-err-code
    ) no-error .
    if error-status:error
    then do:
      run write-to-log( substitute( "&1. ERROR!!! Ошибка при подготовке пакетов OpenXML &2&3&4"
                                    ,vss-workfile
                                    ,error-status:get-message(error-status:num-messages)
                                    ,{&new-line}
                                    ,return-value
                                  )
                      ) .
    end.
    else do:
      assign
        v-message = return-value
      .
      if v-message <> "":U then do:
        run write-to-log ( substitute( "&1", v-message ) ).
      end.
      run write-to-log ( substitute( "Завершена подготовка новых пакетов." ) ).
    end.
    if p-extsys > "" then do v-ind = 1 to num-entries(p-extsys,';'):
      run bge/oxmloutx.p (
            input parparentproc
          , input this-procedure
          , input this-procedure
          , input substitute("one-esys,&1,&2,&3", p-db-num,entry(v-ind,p-extsys,';'),0 )
      ) no-error.
      if error-status :error
      then do:
          run write-to-log in this-procedure ( substitute( "&2&1Ошибка выгрузки OpenXML&1&3&1&4"
                                          , {&new-line}
                                          , vss-workfile
                                          , return-value
                                          , error-status :get-message( error-status :num-messages )
                                      )
                          ) .
      end.
    end.
    else do:
      run bge/oxmloutx.p (
            input parparentproc
          , input this-procedure
          , input this-procedure
          , input substitute("all,&1", p-db-num )
      ) no-error.
      if error-status :error
      then do:
          run write-to-log in this-procedure ( substitute( "&2&1Ошибка выгрузки OpenXML&1&3&1&4"
                                          , {&new-line}
                                          , vss-workfile
                                          , return-value
                                          , error-status :get-message( error-status :num-messages )
                                      )
                          ) .
      end.
    end.
    
        /* удаление старых марок  */
  run nws/mark-clean.p no-error.
  if error-status:error then do:
    run write-to-log( substitute( "&1. ERROR!!! Ошибка при удалении марок &2&3&4&5"
                                  ,vss-workfile
                                  ,{&new-line}
                                  ,error-status:get-message(error-status:num-messages)
                                  ,{&new-line}
                                  ,return-value
                                )
                    ) .
  end.
end.