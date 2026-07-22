block-level on error undo, throw.
define variable vss-revision    as character no-undo init "$Revision: bbf1530230d5, 2753, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Сб фев 20 15:59:21 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: in-imp-cashier.p $":U .
define variable vss-archive     as character no-undo init "$Archive: utl/in-imp-cashier.p $":U .
define variable vss-description as character no-undo init "импорт клиентов из excel".
  
{ cmp/library.i }
{ gbl/cur-time.i }  
{ cmp/str-glbl.i }
  
define input parameter parparentproc     as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .


define variable my-seek1 as integer.
define variable my-seek2 as integer.
define variable my-mess as char.
  define stream InStream.
define stream logstream .
DEFINE VARIABLE chExcelApplication AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorkbook         AS COM-HANDLE no-undo .
DEFINE VARIABLE chWorksheet        AS COM-HANDLE no-undo . 
define variable ss                 as character  no-undo.
define variable cod-fiz            as integer    no-undo.
define variable num-BD             as integer    no-undo.
define variable code-cashier       as integer    no-undo.
define variable password           as character  no-undo.
define buffer buf_staff for staff.  
define variable v-date-start   as date      no-undo.
define variable v-date-end     as date      no-undo.
define variable p-rid          as recid     no-undo.
define variable v-work-place   as character no-undo.
define variable v-time         as integer   no-undo.

define variable v-today        as date      no-undo.  
define variable v-level        as character no-undo.
define variable v-host-code    as integer   no-undo.
define variable v-obj-type     as character no-undo.
define variable v-obj-code     as integer   no-undo.
define variable num-rec        as integer   no-undo.
define variable num-rec-ok     as integer   no-undo.
define variable file-name as character no-undo.
define variable ff             as character no-undo.
define variable var-name-sheet as character no-undo .
chworkbook = chexcelapplication:activeworkbook no-error.
define variable log-file-name                as character      no-undo init "imp-cashier.txt".
define variable v-view-log                   as logical        no-undo .

define variable v-full-path        as character no-undo .
define variable v-path             as character no-undo .
define variable v-file-name        as character no-undo .
define variable v-file-name-no-ext as character no-undo .
define variable v-file-name-ext    as character no-undo .


file-name   =  p-parameter no-error.


if error-status:error then 
do:
    run write-log-and-file in p-log-handle (
        input 1
        , input log-file-name
        , input 1
        , input substitute("Ошибка входных параметров &1:&2&3&4"
        , p-parameter
        , {&new-line}
        , error-status:get-message(1)
        , return-value
        )).
    assign
        v-view-log = yes.
    {&view-log}.
end.



run gbl/filename.p (
                 input  file-name
                ,output v-full-path
                ,output v-path
                ,output v-file-name
                ,output v-file-name-no-ext
                ,output v-file-name-ext
                ) no-error .



    chworkbook = chexcelapplication:activeworkbook no-error.
    run ex-file in this-procedure   (v-full-path, false) .
    
    
    chworkbook   = chexcelapplication:activeworkbook no-error.
    chworksheet  = chexcelapplication:sheets:item(1):select  no-error.
    chworksheet  = chexcelapplication:sheets:item(1) no-error.
    
    
run import-proc in this-procedure  no-error .
if error-status :error then message
        vss-workfile vss-revision vss-description skip
        error-status :get-message(1) skip
        return-value skip
        "import-proc"
        view-as alert-box error
        .
RELEASE OBJECT chWorksheet NO-ERROR.
RELEASE OBJECT chWorkbook NO-ERROR.
chExcelApplication :QUIT().
RELEASE OBJECT  chExcelApplication  NO-ERROR.



procedure import-proc: 
    define variable ii           as integer   no-undo.
    define variable t            as char      no-undo.
    define variable type-clients as char      no-undo.
    define variable code-clients as char      no-undo.
    define variable name-clients as char      no-undo.
    define variable n-entry      as char      no-undo extent 40.
    define variable alf          as character no-undo.
    define variable nen          as integer   no-undo .
    
    run cur-time in this-procedure ( output v-today, output v-time).

    ii = 1 .
    
    _stroka:
    REPEAT ON ERROR UNDO, leave:
       
       ss = "".
        ii = ii  + 1.
        T = string(ii) .
    
        if chWorkSheet:Range ('A' + T):Value  = ? then leave _stroka.
        num-rec = num-rec + 1.
    
        nen = 1 .
        alf = "a,b,c,d,e".
   
        mass: do nen = 1 to 5:

            n-entry[nen] = chWorkSheet:Range ( entry(nen, alf, ",") + T) :value.

            if  n-entry[nen] = ? then   n-entry[nen]  = "" .
         
            ss = ss +   n-entry[nen] + ";".
        end.

        cod-fiz     = integer( entry(1, ss , ";")) no-error.
        num-BD    = integer(entry(2, ss ,";")) no-error.
        code-cashier = integer(entry(3, ss ,";")) no-error.
        password = entry(4 , ss ,";") no-error.
        if LENGTH(string(code-cashier)) > 3 then do:
            my-mess =     substitute("Код кассира превышает 3 символа"
                , {&role-cashier}
                , {&new-line}
                , error-status:get-message(1)
                , return-value ) . 
            /*              run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).*/
            run err-write in this-procedure ( input-output my-mess , v-obj-code , v-obj-type  ).
            .
            next  _stroka.

        end.    

        find first clients where clients.obj-code = cod-fiz and clients.obj-type = {&prs} no-lock no-error.
    
        v-work-place = string(num-BD , '99999').
        assign
            v-level      = {&role-level-db}
            v-host-code  = 0
            v-obj-type   = '':U
            v-obj-code   = 0
            v-date-start = v-today + 1
            v-date-end   = {&end-of-age}
            .
        
        run ref/staff01.p (
            input-output p-rid
            ,input {&add-def}
            ,input no /*p-silent*/
            ,input {&role-cashier}
            ,input code-cashier
            ,input clients.obj-code
            ,input v-level
            ,input v-date-start
            ,input v-date-end
            ,input num-BD
            ,input v-host-code
            ,input v-obj-type
            ,input v-obj-code
            ,input v-work-place
            ,input password) no-error .
        if error-status:error then 
        do:
            my-mess =     substitute("Ошибка при сохранении записи &1&2&3&2&4"
                , {&role-cashier}
                , {&new-line}
                , error-status:get-message(1)
                , return-value ) . 
            /*              run display-intelli-log in this-procedure ( input substitute("&1&2,&3,false,&4", my-obj-type, my-obj-code, my-parus-2-code, my-mess)).*/
            run err-write in this-procedure ( input-output my-mess , v-obj-code , v-obj-type  ).
            .
        end.
        else 
        do: 
            num-rec-ok = num-rec-ok + 1 .            
        end.
        next  _stroka.
    end.

  
end procedure.
 
 
 
run write-log-and-file in p-log-handle (
    input 1
    , input log-file-name
    , input 1
    , input substitute("Импорт кассиров из файла &1 завершен: из &2 записей успешно закачано &3&4&5"
    , file-name
    , num-rec
    , num-rec-ok
    , {&new-line} )
    ).
{&view-log}.
input stream InStream close.
 
 
  
  
PROCEDURE ex-file :
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/
    define input parameter ff as character no-undo .
    define input parameter ex as logical no-undo .
    if ex = false then 
    do:
        create "excel.application" chexcelapplication connect no-error.
        if error-status:error then 
        do:  
            create "excel.application" chexcelapplication no-error.
           if error-status :error then 
           do:
              message
                 "Ошибка при запуске Excel" skip
                 error-status :get-message(1) skip
                 view-as alert-box error .
              undo, return error .
           end. 
        end.
        if ff = ""  then 
        do:
            chworkbook   = chexcelapplication:workbooks:add( ).
        end.
        else 
        do:
            chworkbook   = chexcelapplication:workbooks:open( ff ).
        end.
    end.
    {&excel-invisable}
    chworksheet  = chexcelapplication:sheets:item (1).

END PROCEDURE.
  

PROCEDURE err-write:
    DEFINE INPUT-OUTPUT PARAMETER mess as char No-UNDO.
    define input parameter p-obj-code as integer no-undo.
    define input parameter p-obj-type as char no-undo.
  
    seek STREAM Instream to my-seek1.
    import stream InStream .
    /*  ss.*/
    run write-log-and-file in p-log-handle (
        input 1
        , input log-file-name
        , input 1
        , input mess + {&new-line} + p-obj-type + "   " + string(p-obj-code)  ).
    assign
        v-view-log = yes.
    mess = "".
    seek STREAM Instream to my-seek2.
END PROCEDURE.


 