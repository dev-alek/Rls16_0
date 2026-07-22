block-level on error undo, throw.
/*
$Revision: eaa8cb55810d, 3483, rls $
$Author: EShklyar $
$Date: 2023/10/16 15:13:35 $
$Workfile: r-closeShift.p $
$Archive: rep/r-closeShift.p $

отправка сменного отчета

Автор: Шкляр Елена
Дата создания: 08/06/07
Author: Shklyar Elena
Creation date: 08/06/07

*/
define input parameter parparentproc            as widget-handle           no-undo .
define input parameter p-rdbh                   as handle                  no-undo . /*destination*/
define input parameter p-report-id              as character               no-undo .
define input parameter custom-par               as character     no-undo . 
define input parameter p-obj-code               like ub.clients.obj-code   no-undo .
define input parameter p-obj-type               like ub.clients.obj-type   no-undo .
define input parameter p-curr-abbr              like ub.currency.curr-abbr no-undo .
define input parameter p-base-code              like ub.currency.curr-code no-undo .
define input parameter tog-1                    as   logical               no-undo .
define input parameter tog-2                    as   logical               no-undo .
define input parameter tog-3                    as   logical               no-undo .
define input parameter tog-4                    as   logical               no-undo .
define input parameter tog-5                    as   logical               no-undo .
define input parameter tog-5-1                  as   logical               no-undo .
define input parameter tog-6                    as   logical               no-undo .
define input parameter tog-7                    as   logical               no-undo .
define input parameter tog-81                   as   logical               no-undo .
define input parameter tog-82                   as   logical               no-undo .
define input parameter tog-9                    as   logical               no-undo .
define input parameter tog-10                   as   logical               no-undo .
define input parameter tog-1-pump-one           as   logical               no-undo .
define input parameter tog-1-whole-gds          as   logical               no-undo .
define input parameter tog-1-out-pump-with-icnt as   logical               no-undo .
define input parameter tog-2-cp-grp             as   logical               no-undo .
define output parameter v-report-name-html      as   character             no-undo .
define output parameter v-report-json           as   character             no-undo .

{ rul/tempcxml.i }

define variable vss-revision    as character no-undo initial "$Revision: eaa8cb55810d, 3483, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: 2023/10/16 15:13:35 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: r-closeshift.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: rep/r-closeshift.p $":U .
define variable vss-description as character no-undo initial "сменный отчет":U .

define variable  p-parent-handle          as handle                  no-undo .
define variable  p-log-handle             as handle                  no-undo .
define variable  p-cont-handle            as handle                  no-undo .
define variable  p-rebh                   as handle                  no-undo . /*для ошибок*/
p-parent-handle = this-procedure:handle .
p-log-handle = this-procedure:handle .
p-cont-handle = this-procedure:handle .
p-rebh = this-procedure:handle .

/* Parameters Definitions ---                                           */
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ cmp/trg-def.i     }
{ cmp/r-page1.i new }
    { cmp/r-pril.i   }
    { gbl/prn-lib.i "new shared" }
    { rep/r-sym.i    }
    { rep/r-gl.i     }
    { cmp/breakstr.i }
    { gbl/cur-time.i }
{ gbl/getcntxt.i def }
{ gbl/getsect.i  def }
/*данные по реализации*/
{ rep/real-2df.i "NEW SHARED" treal-2 }
{ rep/real-3df.i "NEW SHARED" treal-3 }
{ rep/real-4df.i "NEW SHARED" treal-4 }
{ rep/real-8df.i "NEW SHARED" treal-8 }
/*таблица нужных групп для листа 3*/
{ rep/icm-3df.i  "NEW SHARED"}
{ gbl/waitfram.i }
{ rep/rshiftd1.i t "new shared"}
{ gbl/gate-clb.i }
{ rep/fmtcli.i     }

define variable v-nn3 as integer no-undo .
define variable Jv    as integer no-undo .

v-nn3 = NUM-ENTRIES(custom-par).
REPEAT Jv = 1 to v-nn3:
    if CAPS(trim(Entry(Jv,custom-par))) begins "X-DATE-START"      then  X-DATE-START  = date(Entry(2,Entry(Jv,custom-par ),"="))  .
    if CAPS(trim(Entry(Jv,custom-par))) begins "X-DATE-END"        then  X-DATE-END    = date(Entry(2,Entry(Jv,custom-par ),"=")) .
    if CAPS(trim(Entry(Jv,custom-par))) begins "X-SHIFT-START"     then  X-Shift-Start = int(Entry(2,Entry(Jv,custom-par ),"=")) .
    if CAPS(trim(Entry(Jv,custom-par))) begins "X-SHIFT-END"       then  X-Shift-End   = int(Entry(2,Entry(Jv,custom-par ),"=")) .
End.

define            variable line                      as character no-undo .
define            variable rep-shift-store-name      as character no-undo. /*наименование организации*/
define            variable rep-shift-for-mng         as character no-undo format "X(30)":U .
define            variable rep-shift-for-mng1        as character no-undo format "X(30)":U .
define            variable rep-shift-for-mng2        as character no-undo format "X(30)":U .
define            variable rep-shift-for-mng-next    as character no-undo format "X(30)":U .
define            variable rep-shift-for-mng-end     as character no-undo format "X(30)":U .
define            variable rep-shift-rol-mng-end     as character no-undo format "X(30)":U .
define            variable rep-shift-for-opers       as character no-undo.
define            variable rep-shift-for-opers1      as character no-undo format "X(44)":U .
define            variable rep-shift-for-opers2      as character no-undo format "X(44)":U .
define            variable rep-shift-first-oper      as logical   no-undo initial yes.
define            variable rep-shift-first-mngr      as logical   no-undo initial yes.
define            variable sheets                    as integer   no-undo.
define            variable v-previous-shift-date     as date      no-undo .
define            variable v-current-shift-date      as date      no-undo .
define            variable v-archive-ok              as logical   no-undo .
define            variable v-comment                 as character no-undo .
define            variable v-can-print               as logical   no-undo .
define            variable v-run-2-3-4               as logical   no-undo initial yes.
define            variable v-host-code               like ub.sysconf.host-code no-undo .
define            variable v-host-name               like ub.clients.obj-name no-undo . /*наименование фирмы*/
define            variable p-z-number-list           as character no-undo.
define            variable p-z-number-item           as character no-undo.
define            variable v-param_prt-z-no          as character no-undo.
define            variable v-param_shft-qty          as character no-undo.
define            variable v-param_data-type         as character no-undo.
define new shared variable v-rep-shift-open-date     like ub.shift-obj.open-date no-undo. /*дата открытия смены*/
define new shared variable v-rep-shift-open-time     like ub.shift-obj.open-time no-undo. /*время открытия смены*/
define new shared variable v-rep-shift-close-date    like ub.shift-obj.close-date no-undo. /*дата закрытия смены*/
define new shared variable v-rep-shift-close-time    like ub.shift-obj.close-time no-undo. /*время закрытия смены*/
define new shared variable v-rep-shift-close         like ub.shift-obj.close-time no-undo. /*время закрытия смены*/
define            variable v-count                   as integer   initial 0 no-undo .
define            variable v-ii                      as integer   no-undo .
define            variable v-str2                    as character no-undo .
define            variable v-write-xml-error         as logical   no-undo .
define            variable v-obj-address             as character no-undo .
define            variable v-obj-phone               as character no-undo .
define            variable v-report-name-html-list   as character no-undo .
define            variable v-report-name-html-result as character no-undo .
define            variable v-report-result           as logical   no-undo . 
define            variable rep-shift-rol-mng         as character no-undo .
define            variable rep-shift-rol-oper        as character no-undo .
define            variable rep-shift-rol-mng2        as character no-undo .
define            variable rep-shift-rol-oper2       as character no-undo .
define            variable rep-shift-rol-mng-next    as character no-undo .
define            variable v-param-code              as integer   no-undo .
define            variable tog-list                  as character no-undo .
define            variable tog-last                  as character no-undo .
define            VARIABLE v-param                   as LOGICAL   no-undo .
define            VARIABLE v-one-shift               as LOGICAL   no-undo .
define buffer next-shift-obj     for ub.shift-obj.
define buffer previous-shift-obj for ub.shift-obj.
define buffer buf_goods          for ub.goods.
define buffer buf_shift          for shiftt.


define stream Out-Stream.
define stream OutStr-html.

/*определение какого формата будет печататься сменный отчет*/
define variable v-sort-list  as character no-undo .
define variable v-param-type as character no-undo .
define variable v-tth        as handle    no-undo .

run adm/shattri.p (
    input "get":U
    ,input  '' /*p-obj-type*/
    ,input  0 /*p-obj-code*/
    ,input  {&attr-report-glob}
    ,input  {&attr-report-glob_rep-shift-format} /*p-param-code*/
    ,output v-sort-list
    ,output v-value-date
    ,output v-value-decimal
    ,output v-param-code
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
    ) no-error .

if error-status:error then
do:
    delete object v-tth.
    message
        "Не найден или незаполнен параметр - Формат печати сменного отчета"
        view-as alert-box error .
    return .
end.

/*создание листа помеченных листов для печати*/
x-tog-shift = true .
find first ub.clients no-lock where ub.clients.obj-code = p-obj-code and
    ub.clients.obj-type = p-obj-type no-error .
if available (ub.clients) then 
do:
    CREATE obj-list.
    Buffer-copy ub.clients TO obj-list.
end.

if tog-1 = true then 
do:
    tog-list = "tog-1".
end.
if tog-2 = true then 
do:
    tog-list = tog-list + ',' + "tog-2".
end.
if tog-3 = true then 
do:
    tog-list = tog-list + ',' + "tog-3".
end.
if tog-4 = true then 
do:
    tog-list = tog-list + ',' + "tog-4".
end.  
if tog-5 = true then 
do:
    tog-list = tog-list + ',' + "tog-5".
end.  
if tog-5-1 = true then 
do:
    tog-list = tog-list + ',' + "tog-5-1".
end.  
if tog-7 = true then 
do:
    tog-list = tog-list + ',' + "tog-7".
end.
if tog-81 = true then 
do:
    tog-list = tog-list + ',' + "tog-81".
end.
if tog-9 = true then 
do:
    tog-list = tog-list + ',' + "tog-9".
end.
if tog-10 = true then 
do:
    tog-list = tog-list + ',' + "tog-10".
end.  

if tog-list <> "" then 
do:
    tog-last = entry(num-entries(tog-list),tog-list).
end.

{ gbl/getcntxt.i get }

FIND FIRST ub.clients No-LOCK
    WHERE ub.clients.obj-type = p-obj-type
    AND ub.clients.obj-code = p-obj-code
    No-ERROR.
assign
    rep-shift-store-name = if available ub.clients
             then ub.clients.obj-name
             else (p-obj-type + string(p-obj-code))
    .
{ gbl/hostname.i p-obj-type p-obj-code v-host-code v-host-name}
{ gbl/getsect.i run p-obj-type p-obj-code {&attr-report-obj} }
for each thbjattr_thbj-attr :
/*    if thbjattr_thbj-attr.prop-code = 'shft-qty'  then v-param_shft-qty = thbjattr_thbj-attr.property-value-character .*/
    if thbjattr_thbj-attr.prop-code = 'prt-z-no'  then v-param_prt-z-no = string(thbjattr_thbj-attr.property-value-logical) .
end.
v-param_shft-qty = "state" .
define temp-table temp-shift-obj no-undo like ub.shift-obj
    FIELD num as integer
    INDEX ii IS UNIQUE num
    .

RUN fmtcli-get-client IN THIS-PROCEDURE ( INPUT  p-obj-type
    , INPUT  p-obj-code
    ) .
assign
    v-obj-address = ( if v-fmtcli-index <> '':U then ( v-fmtcli-index ) else '':U )
                            + ( if v-fmtcli-full-addres <> '':U then ( v-fmtcli-full-addres ) else '':U )
    v-obj-phone   = ( if v-fmtcli-phone <> '':U then v-fmtcli-phone else '':U )
    .

for each ub.shift-obj  no-lock
    where ub.shift-obj.obj-code   =  p-obj-code
    and ub.shift-obj.obj-type   =  p-obj-type
    and ub.shift-obj.shift-date >= X-date-Start
    and ub.shift-obj.shift-date <= X-date-End
    :
    if ub.shift-obj.shift-date = X-date-Start and ub.shift-obj.shift-num < X-Shift-Start then next .
    if ub.shift-obj.shift-date = X-date-End   and ub.shift-obj.shift-num > X-Shift-End then next .

    create temp-shift-obj .
    assign 
        v-count = v-count + 1 .
    assign 
        temp-shift-obj.num = v-count .
    buffer-copy ub.shift-obj to temp-shift-obj .
    find first buf_shift where
        buf_shift.obj-type = p-obj-type
        and buf_shift.obj-code = p-obj-code
        and buf_shift.shift-date = x-date-end
        and buf_shift.shift-num = x-shift-end no-error.
    if not available buf_shift then 
    do:
        create buf_shift.
        assign
            buf_shift.obj-type    = p-obj-type
            buf_shift.obj-code    = p-obj-code
            buf_shift.shift-date  = ub.shift-obj.shift-date
            buf_shift.shift-num   = ub.shift-obj.shift-num
            buf_shift.db-num      = ub.clients.db-num
            buf_shift.obj-name    = ub.clients.obj-name
            buf_shift.obj-address = v-obj-address
            buf_shift.obj-phone   = v-obj-phone
            buf_shift.db-num      = ub.clients.db-num
            buf_shift.shift-name  = ub.shift-obj.shift-name
            buf_shift.base-code   = p-base-code
            buf_shift.curr-abbr   = p-curr-abbr
            .
        release buf_shift.
    end.
    /* персонал */
    FOR EACH ub.shift-staff No-LOCK WHERE
        ub.shift-staff.obj-type   = p-obj-type AND
        ub.shift-staff.obj-code   = p-obj-code AND
        ub.shift-staff.shift-date = ub.shift-obj.shift-date AND
        ub.shift-staff.shift-num  = ub.shift-obj.shift-num AND
        ub.shift-staff.next-shift = no AND
        ub.shift-staff.staff-role = no and
        ub.shift-staff.psn-num    >= 0 :
        if lookup( {&space-char} + ub.shift-staff.name, rep-shift-for-opers ) = 0 then 
        do:
            assign
                rep-shift-for-opers = rep-shift-for-opers + (if rep-shift-for-opers > '' then {&comma-char} else "")  + ub.shift-staff.name
                .
        end.
    end.

    if rep-shift-for-opers > '' then
        assign
            rep-shift-for-opers1 = entry (1, rep-shift-for-opers, {&comma-char})
            rep-shift-rol-oper   = "Оператор"
              no-error.


    if num-entries (rep-shift-for-opers, {&comma-char}) >= 2 then
        assign
            rep-shift-for-opers2 = entry (2, rep-shift-for-opers, {&comma-char})
            rep-shift-rol-oper2  = "Оператор"
              no-error.


    FOR EACH ub.shift-staff No-LOCK WHERE
        ub.shift-staff.obj-type = p-obj-type AND
        ub.shift-staff.obj-code = p-obj-code AND
        ub.shift-staff.shift-date = temp-shift-obj.shift-date AND
        ub.shift-staff.shift-num  = temp-shift-obj.shift-num AND
        ub.shift-staff.next-shift = no AND
        ub.shift-staff.staff-role = yes and
        ub.shift-staff.psn-num    >= 0 :
        if lookup( {&space-char} + ub.shift-staff.name, rep-shift-for-mng ) = 0 then 
        do:
            assign
                rep-shift-for-mng = rep-shift-for-mng + (if rep-shift-for-mng > '' then {&comma-char} else "")  + ub.shift-staff.name
                .
        end.
    end.

    if rep-shift-for-mng > '' then
        assign
            rep-shift-for-mng1 = entry (1, rep-shift-for-mng, {&comma-char})
            rep-shift-rol-mng  = "Старший оператор"
              no-error.


    if num-entries (rep-shift-for-mng, {&comma-char}) >= 2 then
        assign
            rep-shift-for-mng2 = entry (2, rep-shift-for-mng, {&comma-char})
            rep-shift-rol-mng2 = "Старший оператор"
              no-error.

/*    end.*/
end.
rep-shift-for-opers =  breakstr(rep-shift-for-opers, 44, input-output rep-shift-for-opers1, input-output rep-shift-for-opers2).

/* корректируем первую смену  */
find first temp-shift-obj where temp-shift-obj.num = 1 no-error .
if not available temp-shift-obj Then 
DO:
    &scop my-message substitute("На объекте &1 нет смены &2 с датой начала &3&4" + ~
                                "Исправьте запрашиваемые данные!" ~
                                , rep-shift-store-name ~
                                , X-shift-start ~
                                ,string(X-date-start,"99/99/9999") ~
                                , ~{&new-line~} )
    RETURN.
End.
assign
    x-date-Start          = temp-shift-obj.shift-date
    X-Shift-Start         = temp-shift-obj.shift-num
    v-rep-shift-open-date = temp-shift-obj.open-date
    v-rep-shift-open-time = temp-shift-obj.open-time
    .
  
/* корректируем последнюю смену  */
find first temp-shift-obj  where temp-shift-obj.num = v-count no-error .
if available temp-shift-obj then 
do:
    assign
        x-date-End             = temp-shift-obj.shift-date
        X-Shift-End            = temp-shift-obj.shift-num
        v-rep-shift-close-date = temp-shift-obj.close-date
        v-rep-shift-close-time = temp-shift-obj.open-time
        v-rep-shift-close      = temp-shift-obj.close-time
        .
end.

if x-shift-start = x-shift-end and x-date-start = x-date-end then v-one-shift = true . 
else v-one-shift = false .

/* ищем следующюю смену и ее персонал */
FIND first next-shift-obj NO-LOCK
    WHERE next-shift-obj.obj-type   = temp-shift-obj.obj-type
    and next-shift-obj.obj-code   = temp-shift-obj.obj-code
    and next-shift-obj.shift-date = temp-shift-obj.shift-date
    and next-shift-obj.shift-num  = temp-shift-obj.shift-num
    no-error .
FIND NEXT  next-shift-obj SHARE-LOCK WHERE next-shift-obj.obj-type = p-obj-type AND next-shift-obj.obj-code = p-obj-code use-index pi NO-ERROR.
FIND FIRST ub.shift-staff No-LOCK WHERE
    ub.shift-staff.obj-type   = p-obj-type AND
    ub.shift-staff.obj-code   = p-obj-code AND
    ub.shift-staff.shift-date = (if available next-shift-obj then next-shift-obj.shift-date else temp-shift-obj.shift-date) AND
    ub.shift-staff.shift-num  = (if available next-shift-obj then next-shift-obj.shift-num  else temp-shift-obj.shift-num) AND
    ub.shift-staff.next-shift = (if available next-shift-obj then no else yes) AND
    ub.shift-staff.staff-role = yes and
    ub.shift-staff.psn-num    >= 0 No-ERROR.
assign 
    rep-shift-for-mng-next = if available ub.shift-staff then string(ub.shift-staff.name, "X(30)") else "".
rep-shift-rol-mng-next = "Старший оператор"  
    .
/*создание */

run get-report-num in parParentProc (
    output p-report-id
    ).
v-report-name-html = session:temp-directory + {&DF_Name} + string(p-report-id) + string(time) + ".html". /*формирование имя файла для часть1*/        

if v-param-code = 3 then v-param = yes.
else v-param = no .

if tog-1 = true then 
do:
    /*Вызов процедуры напечатывания шапки для часть1*/
    run first-line-tog1-html in this-procedure (
        input v-report-name-html
        ).  
    /*вызов первого листа*/    
    if v-param-code = 2 then
    do:
        run rep/r-new-shift1-2.p
            ( input parparentproc
            , input p-parent-handle
            , input p-log-handle
            , input p-cont-handle
            , input p-rebh
            , input v-report-name-html
            , input ""
            , input ""
            , input 0
            , input 0
            , input 0
            , input yes
            , input v-param_shft-qty
            , input p-obj-type
            , input p-obj-code
            , input p-z-number-list
            , input tog-1-pump-one
            , input tog-1-whole-gds
            , input tog-1-out-pump-with-icnt
            ) no-error.
    end.
    else
    do:
        if v-param-code = 3 then
        do:
            run rep/r-new-shift1-3.p
                ( input parparentproc
                , input p-parent-handle
                , input p-log-handle
                , input p-cont-handle
                , input p-rebh
                , input v-report-name-html
                , input ""
                , input ""
                , input 0
                , input 0
                , input 0
                , input yes
                , input v-param_shft-qty
                , input p-obj-type
                , input p-obj-code
                , input p-z-number-list
                , input tog-1-pump-one
                , input tog-1-whole-gds
                , input tog-1-out-pump-with-icnt
                ) .
        end.
        else
        do:
            run rep/r-new-shift1.p
                ( input parparentproc
                , input p-parent-handle
                , input p-log-handle
                , input p-cont-handle
                , input p-rebh
                , input v-report-name-html
                , input ""
                , input ""
                , input 0
                , input 0
                , input 0
                , input yes
                , input v-param_shft-qty
                , input p-obj-type
                , input p-obj-code
                , input p-z-number-list
                , input tog-1-pump-one
                , input tog-1-whole-gds
                , input tog-1-out-pump-with-icnt
                ) no-error.
        end.
    end.
    if tog-last <> "tog-1" then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted                                                                     
            substitute (
            '
        </table>
        '                                                                                      
            , chr(123), chr(125)                                                                                                 
            ).                                                                                                    
        output stream OutStr-html close.
    end.
    else
        run last-line-tog-html in this-procedure (
            input v-report-name-html
            ).
end.

/*если нужна хоть какая разброска платежей по чекам то сделаем*/                                                                                                                                                    
if tog-2 or tog-3 or tog-4 /*or tog-8 */ then 
do:                                                                                                                                                                        
    assign                                                                                                                                                                                                            
        sheets = if tog-2 then 1000 else 0                                                                                                                                                                                
        sheets = sheets + if tog-3 then 100 else 0                                                                                                                                                                        
        sheets = sheets + if tog-4 then 10 else 0                                                                                                                                                                         
        .
                                                                                                                                                                                                              
    if tog-3 then 
    do:                                                                                                                                                                                                 
        /*группы хотелось бы знать заранее*/                                                                                                                                                                                
        run rep/r-shftgr.p                                                                                                                                                                                              
            ( input p-obj-type                                                                                                                                                                                            
            ,input p-obj-code                                                                                                                                                                                            
            ,input X-date-Start                                                                                                                                                                                          
            ,input X-Shift-Start                                                                                                                                                                                         
            ,input "no-classify"                                                                                                                                                                                             
            ,input ""                                                                                                                                                                                             
            ,input no                                                                                                                                                                                            
            ,input 1                                                                                                                                                                                            
            ) no-error.                                                                                                                                                                                                   
                                                                                                                                                                                                                    
    end.                                                                                                                                                                                                              
  
                                                                                                                                                                                                   
    run rep/r-shftc2.p (                                                                                                                                                                                              
        INPUT p-obj-type                                                                                                                                                                                  
        ,INPUT p-obj-code                                                                                                                                                                                  
        ,INPUT X-date-start                                                                                                                                                                                
        ,INPUT X-Shift-Start                                                                                                                                                                               
        ,INPUT X-date-end                                                                                                                                                                                  
        ,INPUT X-Shift-end                                                                                                                                                                                 
        ,INPUT SHEETS                                                                                                                                                                                      
        ,INPUT tog-2                                                                                                                                                                                       
        ,INPUT tog-3                                                                                                                                                                                       
        ,INPUT tog-4                                                                                                                                                                                       
        ,INPUT tog-81                                                                                                                                                                                       
        ,INPUT no                                                                                                                                                                   
        ,INPUT no                                                                                                                                                                   
        ,INPUT 0
        ,INPUT v-param)                                                                                                                                                                                    
        no-error.             
    if error-status:error then                                                    
    do:                                                                           
        message error-status:error error-status:get-message(1)  view-as alert-box.
    /*после этого появляются записи в таблицах treal-2 treal-3 treal-4 */         
    end.     
    define variable v-batch as integer no-undo init 0.                                                                    
    FIND LAST  previous-shift-obj SHARE-LOCK WHERE                                                                                                                                                                    
        previous-shift-obj.obj-type = p-obj-type AND                                                                                                                                                          
        previous-shift-obj.obj-code = p-obj-code AND                                                                                                                                                          
        ((previous-shift-obj.shift-date = X-date-start AND                                                                                                                                                    
        previous-shift-obj.shift-num < X-shift-start) OR                                                                                                                                                      
        previous-shift-obj.shift-date < X-date-start)                                                                                                                                                         
        use-index pi NO-ERROR.                                                                                                                                                                                
    if available previous-shift-obj then 
    do:                                                                                                                                                                          
        assign                                                                                                                                                                                                          
            v-previous-shift-date = previous-shift-obj.shift-date                                                                                                                                                           
            v-current-shift-date  = X-date-start                                                                                                                                                                             
            .                                                                                                                                                                                                               
        run rep/chk-ahz.p (                                                                                                                                                                                             
            input        p-obj-type                                                                                                                                                                           
            ,input        p-obj-code                                                                                                                                                                          
            ,input        yes            /* p-verify-detail     */                                                                                                                                            
            ,input        yes            /* p-verify-arh        */                                                                                                                                            
            ,input        no             /* p-verify-ahsp       */                                                                                                                                            
            ,input        no             /* p-verify-aht        */                                                                                                                                            
            ,input        (v-batch = integer({&repcalc-type-operator}))            /* p-check-act         */                                                                                                  
            ,input        v-cntxt-db-num /* p-check-act-db-num  */                                                                                                                                            
            ,input        v-cntxt-userid /* p-check-act-user-id */                                                                                                                                            
            ,input-output v-previous-shift-date                                                                                                                                                               
            ,input-output v-current-shift-date                                                                                                                                                                
            ,output       v-archive-ok                                                                                                                                                                        
            ,output       v-comment                                                                                                                                                                           
            ,output       v-can-print                                                                                                                                                                         
            ) no-error .                                                                                                                                                                                        
        if error-status:error then 
        do:                                                                                                                                                                                  
      &scop my-message substitute("&1 &2 &3&4Ошибка при вызове программы chk-ahz.p&4&5&4&6"  ~
                                  ,vss-workfile  ~
                                  ,vss-revision  ~
                                  ,vss-description  ~
                                  ,~{&new-line~} ~
                                  ,error-status :get-message(1)  ~
                                  ,return-value )
            {&display-message}.                                                                                                                                                                                      
            if v-write-xml-error then 
            do:                                                                                                                                                                                 
                run cb_write-report-error in p-parent-handle ( input p-rebh                                                                                                                                                 
                    ,input p-report-id                                                                                                                                            
                    ,input ?                                                                                                                                                      
                    ,input {&severity-high}                                                                                                                                       
                    ,input {&my-message}).                                                                                                                                        
            end.                                                                                                                                                                                                          
            return error .                                                                                                                                                                                                
        end. /*if error-status:error then do:*/                                                                                                                                                                         
        if X-date-start < v-previous-shift-date                                                                                                                                                                         
            or X-date-start > v-current-shift-date  then 
        do:                                                                                                                                                                
      &scop my-message substitute("Объект &1&2 Печать 2, 3 и 4 листа сменного отчета за выбранную дату невозможна&3"  + ~
                                  "Отсутствуют подробные складские архивы&3"  + ~
                                  "Возможные даты отчета: &4-&5&3&6&3" ~
                                  ,p-obj-type  ~
                                  ,p-obj-code  ~
                                  , ~{&new-line~} ~
                                  ,string(v-previous-shift-date, '99/99/9999':u) ~
                                  ,string(v-current-shift-date, '99/99/9999':u)  ~
                                  ,v-comment)
            {&display-message}.                                                                                                                                                                                       
            if v-write-xml-error then 
            do:                                                                                                                                                                                 
                run cb_write-report-error in p-parent-handle ( input p-rebh                                                                                                                                                 
                    ,input p-report-id                                                                                                                                            
                    ,input ?                                                                                                                                                      
                    ,input {&severity-high}                                                                                                                                       
                    ,input {&my-message}).                                                                                                                                        
            end.                                                                                                                                                                                                          
            assign                                                                                                                                                                                                        
                v-run-2-3-4 = no                                                                                                                                                                                              
                .                                                                                                                                                                                                             
        end. /*if X-date-start < v-previous-shift-date*/                                                                                                                                                                
    end. /* if available previous-shift-obj */                                                                                                                                                                        
end. /* if tog-2 = yes or tog-3 = yes or tog-4 = yes */                                                                                                                                                             

if tog-2 = true then 
do:

    /*Вызов процедуры напечатывания шапки для часть2*/

    run first-line-tog2-html in this-procedure (
        input v-report-name-html
        ).  
    if v-param-code = 3 then 
    do: 
        run rep/r-new-shift2_3.p                                                                                                                                                                                                
            ( input parparentproc                                                                                                                                                                                           
            ,input p-parent-handle                                                                                                                                                                                         
            ,input p-log-handle                                                                                                                                                                                            
            ,input p-cont-handle                                                                                                                                                                                           
            ,input p-rebh                                                                                                                                                                                                  
            ,input v-report-name-html                                                                                                                                                                                             
            ,input ""                                                                                                                                                                                              
            ,input ""                                                                                                                                                                                         
            ,input 0                                                                                                                                                                                                
            ,input 0                                                                                                                                                                                              
            ,input 0                                                                                                                                                                                            
            ,input p-obj-type                                                                                                                                                                                              
            ,input p-obj-code                                                                                                                                                                                              
            ,input p-z-number-list                                                                                                                                                                                         
            ,input v-previous-shift-date                                                                                                                                                                                   
            ,input tog-2-cp-grp
                                                                                                                                                                                      
            ) no-error.                                                                                                                                                                                                     
        if error-status:error then 
        do:                                                                                                                                                                                    
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
            {&display-message}.                                                                                                                                                                                          
        end.  
    end. 
    else 
    do: 
        run rep/r-new-shift2.p                                                                                                                                                                                                
            ( input parparentproc                                                                                                                                                                                           
            ,input p-parent-handle                                                                                                                                                                                         
            ,input p-log-handle                                                                                                                                                                                            
            ,input p-cont-handle                                                                                                                                                                                           
            ,input p-rebh                                                                                                                                                                                                  
            ,input v-report-name-html                                                                                                                                                                                             
            ,input ""                                                                                                                                                                                              
            ,input ""                                                                                                                                                                                         
            ,input 0                                                                                                                                                                                                 
            ,input 0                                                                                                                                                                                             
            ,input 0                                                                                                                                                                                            
            ,input p-obj-type                                                                                                                                                                                              
            ,input p-obj-code                                                                                                                                                                                              
            ,input p-z-number-list                                                                                                                                                                                         
            ,input v-previous-shift-date                                                                                                                                                                                   
            ,input tog-2-cp-grp
                                                                                                                                                                                      
            ) no-error.                                                                                                                                                                                                     
        if error-status:error then 
        do:                                                                                                                                                                                    
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
            {&display-message}.                                                                                                                                                                                          
        end.  
    end. 
    if tog-last <> "tog-2" then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted                                                                     
            substitute (
            '
        </table>
        '                                                                                      
            , chr(123), chr(125)                                                                                                 
            ).                                                                                                    
        output stream OutStr-html close.
    end.
    else
        run last-line-tog-html in this-procedure (
            input v-report-name-html
            ).
end.                                                                                                                                                                                                           
                  


if tog-3 = yes and v-run-2-3-4 = yes then 
do:

    /*Вызов процедуры напечатывания шапки для часть3*/
    run first-line-tog3-html in this-procedure (
        input v-report-name-html
        ).  
    if v-param-code = 3 then 
    do:
        run rep/r-new-shift3_3.p (
            input parparentproc
            ,input p-parent-handle
            ,input p-log-handle
            ,input p-cont-handle
            ,input p-rebh
            ,input v-report-name-html
            ,input ""
            ,input ""
            ,input 0
            ,input 0
            ,input 0
            ,input p-obj-type
            ,input p-obj-code
            ,input p-z-number-list
            ,input "no-classify"
            ,input ""
            ,input no
            ,input 1
            ,input v-previous-shift-date
            ,input v-param
            ) no-error.
        if error-status:error then 
        do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
            {&display-message}.
        end.
    end.
    else 
    do:    
        run rep/r-new-shift3.p (
            input parparentproc
            ,input p-parent-handle
            ,input p-log-handle
            ,input p-cont-handle
            ,input p-rebh
            ,input v-report-name-html
            ,input ""
            ,input ""
            ,input 0
            ,input 0
            ,input 0
            ,input p-obj-type
            ,input p-obj-code
            ,input p-z-number-list
            ,input "no-classify"
            ,input ""
            ,input no
            ,input 1
            ,input v-previous-shift-date
            ) no-error.
        if error-status:error then 
        do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
            {&display-message}.
        end.
    end.
    if tog-last <> "tog-3" then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted                                                                     
            substitute (
            '
        </table>
        '                                                                                      
            , chr(123), chr(125)                                                                                                 
            ).                                                                                                    
        output stream OutStr-html close.
    end.
    else
        run last-line-tog-html in this-procedure (
            input v-report-name-html
            ).
end.
                                                                                                                                                                                            
if tog-4 = true then 
do:

    run first-line-tog4-html in this-procedure (
        input v-report-name-html
        ).
    if v-param-code = 3 then 
    do:
        run rep/r-new-shift4_3.p (
            input parparentproc
            ,input p-parent-handle
            ,input p-log-handle
            ,input p-cont-handle
            ,input p-rebh
            ,input v-report-name-html
            ,input ""
            ,input ""
            ,input 0
            ,input 0
            ,input 0
            ,input p-obj-type
            ,input p-obj-code
            ,input p-z-number-list
            ,input v-previous-shift-date 
            ,input v-param) no-error.
        if error-status:error then 
        do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
            {&display-message}.
        end.
            
    end.
    else 
    do:                  
        run rep/r-new-shift4.p (
            input parparentproc
            ,input p-parent-handle
            ,input p-log-handle
            ,input p-cont-handle
            ,input p-rebh
            ,input v-report-name-html
            ,input ""
            ,input ""
            ,input 0
            ,input 0
            ,input 0
            ,input p-obj-type
            ,input p-obj-code
            ,input p-z-number-list
            ,input v-previous-shift-date 
            ,input v-param) no-error.
        if error-status:error then 
        do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
            {&display-message}.
        end.
    end.
    if tog-last <> "tog-4" then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted                                                                     
            substitute (
            '
        </table>
        '                                                                                      
            , chr(123), chr(125)                                                                                                 
            ).                                                                                                    
        output stream OutStr-html close.
    end.
    else
        run last-line-tog-html in this-procedure (
            input v-report-name-html
            ).
end. 

if tog-5 = yes then 
do:

    run first-line-tog5-html in this-procedure (
        input v-report-name-html
        ).

    run rep/r-new-shift5.p (
        input parparentproc
        ,input p-parent-handle
        ,input p-log-handle
        ,input p-cont-handle
        ,input p-rebh
        ,input v-report-name-html
        ,input ""
        ,input ""
        ,input 0
        ,input 0
        ,input 0
        ,input p-obj-type
        ,input p-obj-code
        ) no-error.
    if error-status:error then 
    do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
        {&display-message}.
    end.
    if tog-last <> "tog-5" then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute (
            '
        </table>
        '
            , chr(123), chr(125)
            ).
        output stream OutStr-html close.
    end.
    else
        run last-line-tog-html in this-procedure (
            input v-report-name-html
            ).
End.

if tog-5-1 = yes then 
do:
                 
    run first-line-tog5-1-html in this-procedure (
        input v-report-name-html
        ).
    run rep/r-new-shift5-2.p (
        input parparentproc
        ,input p-parent-handle
        ,input p-log-handle
        ,input p-cont-handle
        ,input p-rebh
        ,input p-rdbh
        ,input v-report-name-html
        ,input ""
        ,input 0
        ,input 0
        ,input 0
        ,input p-obj-type
        ,input p-obj-code
        ,input p-report-id
        ,output v-report-json
        ) no-error.
    if error-status:error then 
    do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
        {&display-message}.
    end.
    if tog-last <> "tog-5-1" then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted                                                                     
            substitute (
            '
        </table>
        '                                                                                      
            , chr(123), chr(125)                                                                                                 
            ).                                                                                                    
        output stream OutStr-html close.
    end.
    else
        run last-line-tog-html5-1 in this-procedure (
            input v-report-name-html
            ).
End.

                                                                                                                                                                                                        
if tog-7 = yes then 
DO:
 
    run first-line-tog7-html in this-procedure (
        input v-report-name-html
        ).
                  
    run rep/r-new-shift7.p
        ( input parparentproc
        ,input p-parent-handle
        ,input p-log-handle
        ,input p-cont-handle
        ,input p-rebh
        ,input v-report-name-html
        ,input ""
        ,input ""
        ,input 0
        ,input 0
        ,input 0
        ,input p-obj-type
        ,input p-obj-code
        ,input v-previous-shift-date
        ) no-error.
    if error-status:error then 
    do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
        {&display-message}.
    end.
    if tog-last <> "tog-7" then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute (
            '
            </table>
            '
            , chr(123), chr(125)
            ).
        output stream OutStr-html close.
    end.
    else
        run last-line-tog-html in this-procedure (
            input v-report-name-html
            ).
End.


if tog-81 then 
DO:
    run first-line-tog8-html in this-procedure (
        input v-report-name-html
        ).
                  
    run rep/r-new-shift8.p
        (
        input parparentproc
        ,INPUT p-obj-type
        ,INPUT p-obj-code
        ,INPUT tog-82
        ,v-report-name-html 
        ,v-report-result
        ) no-error .
        
    if tog-last <> "tog-81" then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute (
            '
<tbody><thead>
<tr><td colspan="7">«Частичный возврат» - это: </td></tr>
<tr><td colspan="7">«Частичный возврат» - возврат, который был проведен на недолитое топливо по транзакции на АРМ Кассира</td></tr>
<tr><td colspan="7">«Остальные возвраты» - это:</td></tr>
<tr><td colspan="7">«Полный по номеру чека» - полный возврат, который был проведен по номеру чека на АРМ Кассира</td></tr>
<tr><td colspan="7">«Частичный по номеру чека» - частичный возврат, который был проведен по номеру чека на АРМ Кассира</td></tr>
<tr><td colspan="7">«Полный по транзакции» - полный возврат, который был проведен по транзакции на АРМ Кассира</td></tr>
<tr><td colspan="7">«Сухой чек, созданный в ППО Trade House» - сухой возврат, который был проведен на АРМ Кассира</td></tr>
<tr><td colspan="7">«Сухой чек, проведенный на АРМ Кассира» - сухой возврат, который был проведен на АРМ Кассира</td></tr>
</thead>
</tbody>
</table>'
            , chr(123), chr(125)
            ).
        output stream OutStr-html close.
    end.
    else

        run last-line-tog-html81 in this-procedure (
            input v-report-name-html
            ).
    v-report-result = YES.
        
END.


if tog-9 then 
DO:
 
    run first-line-tog9-html in this-procedure (
        input v-report-name-html
        ).

    run rep/r-new-shift9.p   (
        input parparentproc
        ,input p-parent-handle
        ,input p-log-handle
        ,input p-cont-handle
        ,input p-rebh
        ,input v-report-name-html
        ,input ""
        ,input ""
        ,input 0
        ,input 0
        ,input 0
        ,INPUT p-obj-type
        ,INPUT p-obj-code
        ,INPUT x-date-Start
        ,INPUT x-Shift-Start
        ,INPUT x-date-End
        ,INPUT x-Shift-End
        ,input tog-1-out-pump-with-icnt
        ) no-error .
    if error-status:error then 
    do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
        {&display-message}.
    end.
    if tog-last <> "tog-9" then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted                                                                     
            substitute (
            '
               </table>
        '                                                                                      
            , chr(123), chr(125)                                                                                                 
            ).                                                                                                    
        output stream OutStr-html close.
    end.
    else
        run last-line-tog-html in this-procedure (
            input v-report-name-html
            ).
End. /* tog-9 */



if tog-10 then 
DO:
 
    run first-line-tog10-html in this-procedure (
        input v-report-name-html
        ).

    run rep/r-new-shift10.p   (
        input parparentproc
        ,input p-parent-handle
        ,input p-log-handle
        ,input p-cont-handle
        ,input p-rebh
        ,input v-report-name-html
        ,input ""
        ,input ""
        ,input 0
        ,input 0
        ,input 0
        ,INPUT p-obj-type
        ,INPUT p-obj-code
        ,INPUT x-date-Start
        ,INPUT x-Shift-Start
        ,INPUT x-date-End
        ,INPUT x-Shift-End
        ) no-error .
    if error-status:error then 
    do:
    &scop my-message substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6" ~
                          ,vss-workfile ~
                          ,vss-revision ~
                          ,vss-description ~
                          ,~{&new-line~} ~
                          , error-status:get-message(1) ~
                          , return-value )
        {&display-message}.
    end.
    run last-line-tog-html in this-procedure (
        input v-report-name-html
        ).
End. /* tog-10 */

procedure first-line-tog1-html :
    define input parameter v-report-name-html     as character no-undo .
    define buffer bf_shift-obj     for ub.shift-obj .
    define buffer buf_usser-account for ub.user-account .
    if v-param-code = 3 then 
    do:
        find first bf_shift-obj no-lock where bf_shift-obj.shift-date = X-Date-Start and bf_shift-obj.Shift-num = X-Shift-Start no-error .
        if not available (bf_shift-obj) then return error.
    
        find first buf_usser-account no-lock where buf_usser-account.user-id = bf_shift-obj.close-id no-error .
        if not available (buf_usser-account) then return error .
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px; 
                   ~}
                   .class1 ~{
                       border-collapse: collapse;
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист1" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:50px"></td>
                        <td style="width:30px"></td>
                        <td style="width:30px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:60px"></td>
                        <td style="width:50px"></td>
                        <td style="width:60px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:65px"></td>
                        <td style="width:65px"></td>
                        <td style="width:65px"></td>
                        <td style="width:65px"></td>
                        <td style="width:65px"></td>
                        <td style="width:80px"></td>
                        <td style="width:60px"></td>
                      </tr>
                    <tr>
                      <td colspan="22"></td>
                    </tr>
                    <tr>
                      <td colspan="22" >&2</td>
                    </tr>
                    <tr>
                      <td colspan="20" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      <td colspan="4" style="text-align: center; color:#7030a0; border-top: thick double #7030a0; border-left: thick double #7030a0; border-right: thick double #7030a0;">АЗК № &3</td>
                    </tr> 
                    </tr>
                    <tr>
                      <td colspan="20" style="font-size:16px;font-weight:bold; text-align: center;">Часть №1 Движение нефтепродуктов по количеству</td>
                      <td colspan="4" style="text-align: center; color:#7030a0; border-left: thick double #7030a0; border-right: thick double #7030a0;">Документ подписан ID - &4</td>
                    </tr>' 
            ,
            v-host-name,
            rep-shift-store-name,
            string(bf_shift-obj.obj-code),
            entry(2,buf_usser-account.user-id,"-")
            ).
            
        if v-one-shift then 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="20">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td>' skip
                '<td colspan="4" style="text-align: center; color:#7030a0; border-left: thick double #7030a0; border-right: thick double #7030a0;"></td>' skip
                '</tr>' skip
                .
        end.
        else 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="20">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td>' skip
                '<td colspan="4" style="text-align: center; color:#7030a0; border-left: thick double #7030a0; border-right: thick double #7030a0;"></td>' skip
                '</tr>' skip
                .
        end.      

        put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="20"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
            '<td colspan="4" style="text-align: center; border-right: thick double #7030a0; border-left: thick double #7030a0; color:#7030a0;"> ' + buf_usser-account.last-name + '</td>'
            '</tr>' skip
            '<tr>' skip
            '<td colspan="20"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
            '<td colspan="4" style="text-align: center; border-right: thick double #7030a0; border-left: thick double #7030a0; color:#7030a0;">' + buf_usser-account.first-name + '</td>'
            '</tr>' skip
            '<tr>' skip
            '<td colspan="20"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
            '<td colspan="4" style="text-align: center; border-bottom: thick double #7030a0; border-right: thick double #7030a0; border-left: thick double #7030a0; color:#7030a0;">' + buf_usser-account.second-name + '</td>'
            '</tr>' skip
            '<tr>' skip
            '<td colspan="22"></td>' skip
            '</tr>' skip
            '<tr>'skip
            '<td colspan="22"></td>' skip
            '</tr>' skip         
            '</thead>' skip
            .
        output stream OutStr-html close.   
    end.
    else 
    do:
        if v-param-code = 2 then 
        do:  
            output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
            put stream OutStr-html unformatted
                substitute(
                '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px; 
                   ~}
                   .class1 ~{
                       border-collapse: collapse;
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист1" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:170px"></td>
                        <td style="width:30px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:30px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                      </tr>
                    <tr>
                      <td colspan="20"></td>
                    </tr>
                    <tr>  
                      <td colspan="5" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="15"></td>
                    </tr>
                    <tr>
                      <td colspan="5" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="15"></td>
                    </tr>
                    <tr>
                      <td colspan="20" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="20" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="20"> Смены  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="20"> </td>
                    </tr>'
                ,
                v-host-name,
                string(ub.clients.obj-name),
                string(v-rep-shift-close-date,"99.99.9999"),
                string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
                string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
                ).

         
            put stream OutStr-html unformatted
                substitute (
                '<tr> 
            <td colspan="3" style="height:30px;"> Состав смены:</td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&2</td>
            <td></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td colspan="3"></td>
            <td colspan="4" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
            <td></td>
            <td colspan="4" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr> 
            <td colspan="3" style="height:30px;"></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&5</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&6</td>
            <td></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&7</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&8</td>
          </tr>
          <tr> 
            <td colspan="3"></td>
            <td colspan="4" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
            <td></td>
            <td colspan="4" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="20" style="height:30px;"></td>
          </tr>
          </thead>'
                ,
                rep-shift-rol-mng,
                rep-shift-for-mng1,
                rep-shift-rol-mng2,
                rep-shift-for-mng2,
                rep-shift-rol-oper,
                rep-shift-for-opers1,
                rep-shift-rol-oper2,
                rep-shift-for-opers2

                ).
            output stream OutStr-html close.
        end.  
        else 
        do:
            output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
            put stream OutStr-html unformatted
                substitute(
                '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px; 
                   ~}
                   .class1 ~{
                       border-collapse: collapse;
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист1" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                      <tr class="set_columns">
                        <td style="width:170px"></td>
                        <td style="width:30px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:30px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                      </tr>
                    <tr>
                      <td colspan="21"></td>
                    </tr>
                    <tr>
                      <td colspan="21" >&2</td>
                    </tr>
                    <tr>
                      <td colspan="21" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                    </tr>
                    <tr>
                      <td colspan="21" style="font-size:16px;font-weight:bold; text-align: center;">Часть №1 Движение нефтепродуктов по количеству</td>
                    </tr>
                    <tr>
                      <td colspan="21"> Смены  с &3  по &4 </td>
                    </tr>
                    <tr>
                      <td colspan="21"> Закрыта &5 </td>
                    </tr>
                    <tr>
                      <td colspan="21"> Старший смены: &6 </td>
                    </tr>
                    <tr>
                      <td colspan="21"> Операторы: &7 </td>
                    </tr>
                    <tr>
                      <td colspan="21"></td>
                    </tr>
                    </thead>'
                ,
                v-host-name,
                rep-shift-store-name,
                string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
                string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm"),
                string(v-rep-shift-close-date,"99.99.9999"),
                rep-shift-for-mng1,
                rep-shift-for-opers1
                ).
            output stream OutStr-html close.        
        end.
    end.
    assign 
        v-report-result = yes. 
  
End procedure. /*procedure first-line-tog1-html*/

procedure first-line-tog2-html :
  
    define input parameter v-report-name-html     as character no-undo .

    if v-param-code = 1 and v-report-result = no then 
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист2" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:70px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>
                        <td style="width:80px"></td>
                        <td style="width:70px"></td>
                        <td style="width:90px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:30px"></td>
                        <td style="width:80px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:80px"></td>
                                             
                      </tr>
                    <tr>
                      <td colspan="16" >&2</td>
                    </tr>
                    <tr>
                      <td colspan="16" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                    </tr>
                    <tr>
                      <td colspan="16" style="font-size:16px;font-weight:bold; text-align: center;">Часть №2 Движение нефтепродуктов по количеству и суммам</td>
                    </tr>
                    </tr>' 
            ,
            v-host-name,
            rep-shift-store-name
            ).
            
        if v-one-shift then 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="16">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
                .
        end.
        else 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="16">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
                .
        end.      
        put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="16"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="16"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="16"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="16"></td>' skip
            '</tr>' skip
            '</thead>' skip
            .
        output stream OutStr-html close.                                                
    end.
    if v-param-code = 2 and v-report-result = no then 
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист2" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:70px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>
                        <td style="width:80px"></td>
                        <td style="width:70px"></td>
                        <td style="width:90px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:30px"></td>
                        <td style="width:80px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:80px"></td>
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>   
                    <tr>
                      <td colspan="18"></td>
                    </tr>
                    <tr>  
                      <td colspan="5" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="13"></td>
                    </tr>
                    <tr>
                      <td colspan="5" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="13"></td>
                    </tr>
                    <tr>
                      <td colspan="18" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="18" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="18"> Смены  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="18"> </td>
                    </tr>'
            ,
            rep-shift-store-name,
            string(ub.clients.obj-name),
            string(v-rep-shift-close-date,"99.99.9999"),
            string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
            string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
            ).

         
        put stream OutStr-html unformatted
            substitute (
            '<tr> 
            <td colspan="3" style="height:30px;"> Состав смены:</td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&2</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td colspan="3"></td>
            <td colspan="3" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr> 
            <td colspan="3" style="height:30px;"></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&5</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&6</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&7</td>
            <td></td>
            <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&8</td>
          </tr>
          <tr> 
            <td colspan="3"></td>
            <td colspan="3" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="3" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="18" style="height:30px;"></td>
          </tr>
          </thead>'
            ,
            rep-shift-rol-mng,
            rep-shift-for-mng1,
            rep-shift-rol-mng2,
            rep-shift-for-mng2,
            rep-shift-rol-oper,
            rep-shift-for-opers1,
            rep-shift-rol-oper2,
            rep-shift-for-opers2

            ).
        output stream OutStr-html close.    
    end.
    
    if v-param-code = 3 then 
    do:
        if v-report-result = no then 
        do:
        
            output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
            put stream OutStr-html unformatted
                substitute(
                '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист2" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:70px"></td>
                        <td style="width:50px"></td>
                        <td style="width:60px"></td>
                        <td style="width:110px"></td>
                        <td style="width:90px"></td>
                        <td style="width:80px"></td>
                        <td style="width:60px"></td>
                        <td style="width:40px"></td>
                        <td style="width:60px"></td>
                        <td style="width:110px"></td>
                        <td style="width:60px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:70px"></td>
                        <td style="width:60px"></td>
                        <td style="width:70px"></td>                        
                        <td style="width:60px"></td>
                      </tr>
                    <tr>
                      <td colspan="17" > &2 </td>
                    </tr>
                    <tr>
                      <td colspan="17" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                    </tr>
                    <tr>
                      <td colspan="17" style="font-size:16px;font-weight:bold; text-align: center;">Часть №2 Движение нефтепродуктов по количеству и суммам</td>
                    </tr>'
                ,v-host-name,
                rep-shift-store-name) .
                    
            if v-one-shift then 
            do:
                put stream OutStr-html unformatted
                    '<tr><td colspan="16">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
                    .
            end.
            else 
            do:
                put stream OutStr-html unformatted
                    '<tr><td colspan="16">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
                    .
            end.  
       
            put stream OutStr-html unformatted
                substitute('
                    <tr>
                      <td colspan="17"> Закрыта &5 </td>
                    </tr>
                    <tr>
                      <td colspan="17"> Старший смены: &6 </td>
                    </tr>
                    <tr>
                      <td colspan="17"> Операторы: &7 </td>
                    </tr>
                    <tr>
                    <td colspan="17" style="height:30px;"></td>
                    </tr>                    
                    </thead>'
                ,
                v-host-name,
                rep-shift-store-name,
                string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
                string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm"),
                string(v-rep-shift-close-date,"99.99.9999"),
                rep-shift-for-mng1,
                rep-shift-for-opers1
                ).
            output stream OutStr-html close.
        end. 
        else 
        do:
            output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
            put stream OutStr-html unformatted
                substitute(
                '       <table orientation="landscape" name="лист2" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:70px"></td>
                        <td style="width:50px"></td>
                        <td style="width:60px"></td>
                        <td style="width:110px"></td>
                        <td style="width:90px"></td>
                        <td style="width:80px"></td>
                        <td style="width:60px"></td>
                        <td style="width:40px"></td>
                        <td style="width:60px"></td>
                        <td style="width:110px"></td>
                        <td style="width:60px"></td>
                        <td style="width:80px"></td>
                        <td style="width:80px"></td>
                        <td style="width:70px"></td>
                        <td style="width:60px"></td>
                        <td style="width:70px"></td>                        
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>
                      </tr>
                    <tr>
                      <td colspan="17" style="height:30px;"></td>
                    </tr>
                    <tr>
                      <td colspan="17" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                    </tr>
                    <tr>
                      <td colspan="17" style="font-size:16px;font-weight:bold; text-align: center;">Часть №2 Движение нефтепродуктов по количеству и суммам</td>
                    </tr>
                    <tr>
                      <td colspan="17" style="height:30px;"></td>
                    </tr>
                    </thead>'
                ,chr(123), chr(125)
                ).
            output stream OutStr-html close.
        end.
                                                     
    end.
    if v-report-result = yes and v-param-code <> 3 then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '       <table orientation="landscape" name="лист2" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:70px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:60px"></td>
                        <td style="width:60px"></td>
                        <td style="width:80px"></td>
                        <td style="width:70px"></td>
                        <td style="width:90px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:30px"></td>
                        <td style="width:80px"></td>
                        <td style="width:50px"></td>
                        <td style="width:50px"></td>
                        <td style="width:80px"></td>
                        <td style="width:60px"></td>
                 
                      </tr>
                    <tr>
                      <td colspan="17" style="height:30px;"></td>
                    </tr>
                    <tr>
                      <td colspan="17" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                    </tr>
                    <tr>
                      <td colspan="17" style="font-size:16px;font-weight:bold; text-align: center;">Часть №2 Движение нефтепродуктов по количеству и суммам</td>
                    </tr>
                    <tr>
                      <td colspan="17" style="height:30px;"></td>
                    </tr>                    
                    </thead>'
            ,chr(123), chr(125)
            ).
        output stream OutStr-html close.           
    end.
    assign 
        v-report-result = yes. 
  
End procedure. /*procedure first-line-tog2-html*/

procedure first-line-tog3-html :
  
    define input parameter v-report-name-html     as character no-undo .

    if v-param-code = 1 and v-report-result = no then 
    do: 
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px;
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист3" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:100px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                      </tr>
                      <tr>  
                        <td colspan="13" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="13" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="13" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="13" style="font-size:16px;font-weight:bold; text-align: center;">Часть №3 Движение ТНП по количеству и суммам</td>
                      </tr>
                    </tr>' 
            ,
            v-host-name,
            rep-shift-store-name
            ).
            
        if v-one-shift then 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="13">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
                .
        end.
        else 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="13">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
                .
        end.      
        put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="13"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="13"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="13"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="13"></td>' skip
            '</tr>' skip
            '</thead>' skip
            .
        output stream OutStr-html close.  
    end.
    if v-param-code = 2 and v-report-result = no then 
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист3" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:100px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                      </tr>
                    <tr>
                      <td colspan="13"></td>
                    </tr>
                    <tr>  
                      <td colspan="5" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="8"></td>
                    </tr>
                    <tr>
                      <td colspan="5" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="8"></td>
                    </tr>
                    <tr>
                      <td colspan="13" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="13" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="13"> Смены  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="13"> </td>
                    </tr>'
            ,
            rep-shift-store-name,
            string(ub.clients.obj-name),
            string(v-rep-shift-close-date,"99.99.9999"),
            string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
            string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
            ).

         
        put stream OutStr-html unformatted
            substitute (
            '<tr> 
            <td colspan="4" style="height:30px;"> Состав смены:</td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&2</td>
          </tr>
          <tr> 
            <td colspan="4"></td>
            <td colspan="4" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="4" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          <tr> 
            <td colspan="4" style="height:30px;"></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td colspan="4"></td>
            <td colspan="4" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="4" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="13" style="height:30px;"></td>
          </tr>      
          </thead>'
            ,
            rep-shift-rol-mng,
            rep-shift-for-mng1,
            rep-shift-rol-oper,
            rep-shift-for-opers1
            ).
        output stream OutStr-html close.          
    end.
    if v-param-code = 3 then 
    do: 
        if v-report-result = no then 
        do:
            output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
            put stream OutStr-html unformatted
                substitute(
                '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1400px;
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист3" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:120px"></td>
                        <td style="width:50px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                      </tr>
                      <tr>  
                        <td colspan="15" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="15" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="15" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="15" style="font-size:16px;font-weight:bold; text-align: center;">Часть №3 Движение ТНП по количеству и суммам</td>
                      </tr>
                      <tr>
                        <td colspan="15"> Смены  с &3  по &4 </td>
                      </tr>
                      <tr>
                        <td colspan="15"> Закрыта &5 </td>
                      </tr>
                      <tr>
                        <td colspan="15"> Старший смены: &6 </td>
                      </tr>
                      <tr>
                        <td colspan="15"> Операторы: &7 </td>
                      </tr>
                      <tr>
                        <td colspan="15" style="height:30px;"></td>
                      </tr>      
                      </thead>'
                ,
                v-host-name,
                rep-shift-store-name,
                string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
                string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm"),
                string(v-rep-shift-close-date,"99.99.9999"),
                rep-shift-for-mng1,
                rep-shift-for-opers1                    
                ).
            output stream OutStr-html close.  
        end.
        else 
        do:
            output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
            put stream OutStr-html unformatted
                substitute(
                '<table orientation="landscape" name="лист3" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                      </tr>
                      <tr>
                        <td colspan="15" style="height:30px;"></td>
                      </tr>       
                      <tr>
                        <td colspan="15" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="15" style="font-size:16px;font-weight:bold; text-align: center;">Часть №3 Движение ТНП по количеству и суммам</td>
                      </tr>
                      <tr>
                        <td colspan="15" style="height:30px;"></td>
                      </tr>       
                      </thead>'
                ,chr(123), chr(125)             
                ).        
            output stream OutStr-html close.
        end.
    
    end.
    if v-report-result = yes and v-param-code <> 3 then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<table orientation="landscape" name="лист3" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:120px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                        <td style="width:70px"></td>
                      </tr>
                      <tr>
                        <td colspan="16" style="height:30px;"></td>
                      </tr>       
                      <tr>
                        <td colspan="16" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="16" style="font-size:16px;font-weight:bold; text-align: center;">Часть №3 Движение ТНП по количеству и суммам</td>
                      </tr>
                      <tr>
                        <td colspan="16" style="height:30px;"></td>
                      </tr>       
                      </thead>'
            ,chr(123), chr(125)             
            ).        
        output stream OutStr-html close.
    end.
      
    assign 
        v-report-result = yes. 
 
End procedure.

procedure first-line-tog4-html :
  
    define input parameter v-report-name-html     as character no-undo .

    if v-param-code <> 2 and v-report-result = no then 
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист4" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:180px"></td>
                        <td style="width:140px"></td>
                        <td style="width:180px"></td>
                        <td style="width:180px"></td>
                        <td style="width:140px"></td>
                        <td style="width:180px"></td>
                      </tr>
                       <tr>  
                        <td colspan="6" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="6" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="6" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="6" style="font-size:16px;font-weight:bold; text-align: center;">Часть №4 Реализация услуг</td>
                    </tr>' 
            ,
            v-host-name,
            rep-shift-store-name
            ).
            
        if v-one-shift then 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="6">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
                .
        end.
        else 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="6">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
                .
        end.      
        put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="6"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="6"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="6"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="6"></td>' skip
            '</tr>' skip
            '</thead>' skip
            .
        output stream OutStr-html close.   
    end.
    if v-param-code = 2 and v-report-result = no then 
    do:
        if v-param-code = 2 and v-report-result = no then 
        do:
            output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
            put stream OutStr-html unformatted
                substitute(
                '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       width: 1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист4" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:180px"></td>
                        <td style="width:140px"></td>
                        <td style="width:180px"></td>
                        <td style="width:180px"></td>
                        <td style="width:140px"></td>
                        <td style="width:180px"></td>
                      </tr>
                    <tr>
                      <td colspan="6"></td>
                    </tr>
                    <tr>  
                      <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="3"></td>
                    </tr>
                    <tr>
                      <td colspan="3" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="3"></td>
                    </tr>
                    <tr>
                      <td colspan="6" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="6" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="6"> Смены  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="6"> </td>
                    </tr>'
                ,
                rep-shift-store-name,
                string(ub.clients.obj-name),
                string(v-rep-shift-close-date,"99.99.9999"),
                string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
                string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
                ).

         
            put stream OutStr-html unformatted
                substitute (
                '<tr> 
            <td style="height:30px;"> Состав смены:</td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&2</td>
          </tr>
          <tr> 
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          <tr> 
            <td style="height:30px;"></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="6" style="height:30px;"></td>
          </tr>       
          </thead>'
                ,
                rep-shift-rol-mng,
                rep-shift-for-mng1,
                rep-shift-rol-oper,
                rep-shift-for-opers1
                ).
            output stream OutStr-html close.          
        end.
    end.
    if v-report-result = yes then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '        <table orientation="landscape" name="лист4" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:180px"></td>
                        <td style="width:140px"></td>
                        <td style="width:180px"></td>
                        <td style="width:180px"></td>
                        <td style="width:140px"></td>
                        <td style="width:180px"></td>
                      </tr>
                      <tr>
                        <td colspan="6" style="height:30px;"></td>
                      </tr>                          
                      <tr>
                        <td colspan="6" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="6" style="font-size:16px;font-weight:bold; text-align: center;">Часть №4 Реализация услуг</td>
                      </tr>
                      <tr>
                        <td colspan="6" style="height:30px;"></td>
                      </tr>       
                      </thead>'
            ,chr(123), chr(125)                   
            ).
        output stream OutStr-html close.  
    end.
 
    assign 
        v-report-result = yes. 
  
End procedure. /*procedure first-line-tog4-html*/

procedure first-line-tog5-html :
  
    define input parameter v-report-name-html     as character no-undo .

    if v-param-code <> 2 and v-report-result = no then 
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width: 1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист5" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:160px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                      </tr>
                       <tr>  
                        <td colspan="7" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="7" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">Часть №5 Движение материальных ценностей</td>
                      </tr>
                    </tr>' 
            ,
            v-host-name,
            rep-shift-store-name
            ).
            
        if v-one-shift then 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="7">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
                .
        end.
        else 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="7">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
                .
        end.      
        put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="7"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="7"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="7"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="7"></td>' skip
            '</tr>' skip
            '</thead>' skip
            .
        output stream OutStr-html close.  
    end.
    if v-param-code = 2 and v-report-result = no then 
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width: 1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист5" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:160px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                      </tr>
                    <tr>
                      <td colspan="7"></td>
                    </tr>
                    <tr>  
                      <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="4"></td>
                    </tr>
                    <tr>
                      <td colspan="3" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="4"></td>
                    </tr>
                    <tr>
                      <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="7" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="7"> Смены  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="7"> </td>
                    </tr>'
            ,
            rep-shift-store-name,
            string(ub.clients.obj-name),
            string(v-rep-shift-close-date,"99.99.9999"),
            string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
            string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
            ).

         
        put stream OutStr-html unformatted
            substitute (
            '<tr> 
            <td colspan="2" style="height:30px;"> Состав смены:</td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&2</td>
          </tr>
          <tr> 
            <td colspan="2"></td>
            <td colspan="2" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          <tr> 
            <td colspan="2" style="height:30px;"></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td colspan="2"></td>
            <td colspan="2" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="7" style="height:30px;"></td>
          </tr>       
          </thead>'
            ,
            rep-shift-rol-mng,
            rep-shift-for-mng1,
            rep-shift-rol-oper,
            rep-shift-for-opers1
            ).
        output stream OutStr-html close.          
    end.
    if v-report-result = yes then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '       <table orientation="landscape" name="лист5" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:160px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                        <td style="width:140px"></td>
                      </tr>
                      <tr>
                        <td colspan="7" style="height:30px;"></td>
                      </tr>                             
                      <tr>
                        <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">Часть №5 Движение материальных ценностей</td>
                      </tr>
                      <tr>
                        <td colspan="7" style="height:30px;"></td>
                      </tr>       
                      </thead>'
            ,       chr(123), chr(125)                  
            ).
        output stream OutStr-html close.  
    end.

    assign 
        v-report-result = yes. 
End procedure.

procedure first-line-tog5-1-html :
  
    define input parameter v-report-name-html     as character no-undo .

    if v-param-code <> 2 and v-report-result = no then 
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width: 1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист5" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                      </tr>
                       <tr>  
                        <td colspan="7" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="7" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">Часть №5 Движение денежных средств</td>
                      </tr>
                      <tr>
                       <td colspan="7" style="height:30px;"></td>
                      </tr>       
                      </thead>'
            ,
            v-host-name,
            rep-shift-store-name
            ).
            
        if v-one-shift then 
        do:
            put stream OutStr-html unformatted
                '<thead><tr><td colspan="7">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
                .
        end.
        else 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="7">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr></thead>' skip
                .
        end.      
        put stream OutStr-html unformatted
            '<thead>' skip
            '<tr>' skip
            '<td colspan="7"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="7"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="7"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="7"></td>' skip
            '</tr>' skip
            '</thead>' skip
            .
        output stream OutStr-html close.   
    end.
    if v-param-code = 2 and v-report-result = no then 
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width: 1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист5" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                      </tr>
                    <tr>
                      <td colspan="7"></td>
                    </tr>
                    <tr>  
                      <td colspan="3" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="4"></td>
                    </tr>
                    <tr>
                      <td colspan="3" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="4"></td>
                    </tr>
                    <tr>
                      <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="7" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="7"> Смена  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="7"> </td>
                    </tr>'
            ,
            rep-shift-store-name,
            string(ub.clients.obj-name),
            string(v-rep-shift-close-date,"99.99.9999"),
            string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
            string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
            ).

         
        put stream OutStr-html unformatted
            substitute (
            '<tr> 
            <td colspan="2" style="height:30px;"> Состав смены:</td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&2</td>
          </tr>
          <tr> 
            <td colspan="2"></td>
            <td colspan="2" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          <tr> 
            <td colspan="2" style="height:30px;"></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td colspan="2"></td>
            <td colspan="2" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="7" style="height:30px;"></td>
          </tr>       
          </thead>'
            ,
            rep-shift-rol-mng,
            rep-shift-for-mng1,
            rep-shift-rol-oper,
            rep-shift-for-opers1
            ).
        output stream OutStr-html close.          
    end.
    if v-report-result = yes then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '       <table orientation="landscape" name="лист5" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                        <td style="width:150px"></td>
                      </tr>
                      <tr>
                        <td colspan="7" style="height:30px;"></td>
                      </tr>                             
                      <tr>
                        <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="7" style="font-size:16px;font-weight:bold; text-align: center;">Часть №5 Движение денежных средств</td>
                      </tr>
                      <tr>
                        <td colspan="7" style="height:30px;"></td>
                      </tr>       
                      </thead>'
            ,       chr(123), chr(125)                  
            ).
        output stream OutStr-html close.  
    end.

    assign 
        v-report-result = yes. 
End procedure.


procedure first-line-tog7-html :
  
    define input parameter v-report-name-html     as character no-undo .
  
    if v-param-code <> 2 and v-report-result = no then 
    do:  
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width:1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист7" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:150px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                      </tr>
                       <tr>  
                        <td colspan="5" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="5" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="5" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="5" style="font-size:16px;font-weight:bold; text-align: center;">Часть №7 Погрешности объемомеров ТРК</td>
                    </tr>' 
            ,
            v-host-name,
            rep-shift-store-name
            ).
            
        if v-one-shift then 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="5">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
                .
        end.
        else 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="5">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
                .
        end.      
        put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="5"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="5"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="5"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="5"></td>' skip
            '</tr>' skip
            '</thead>' skip
            .
        output stream OutStr-html close.  
    end.
    if v-param-code = 2 and v-report-result = no then 
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width:1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист7" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:150px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                      </tr>
                    <tr>
                      <td colspan="5"></td>
                    </tr>
                    <tr>  
                      <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="3"></td>
                    </tr>
                    <tr>
                      <td colspan="2" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="3"></td>
                    </tr>
                    <tr>
                      <td colspan="5" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="5" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="5"> Смены  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="5"> </td>
                    </tr>'
            ,
            rep-shift-store-name,
            string(ub.clients.obj-name),
            string(v-rep-shift-close-date,"99.99.9999"),
            string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
            string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
            ).

        put stream OutStr-html unformatted
            substitute (
            '<tr> 
            <td colspan="2" style="height:30px;"> Состав смены:</td>
            <td style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td style="border-bottom: 1px solid black; text-align: center;">&2</td>
          </tr>
          <tr> 
            <td colspan="2"></td>
            <td style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          <tr> 
            <td colspan="2" style="height:30px;"></td>
            <td style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td colspan="2"></td>
            <td style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="5" style="height:30px;"></td>
          </tr>       
          </thead>'
            ,
            rep-shift-rol-mng,
            rep-shift-for-mng1,
            rep-shift-rol-oper,
            rep-shift-for-opers1
            ).
        output stream OutStr-html close.          
    end.
    if v-report-result = yes then 
    do:    
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '       <table orientation="landscape" name="лист7" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:150px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                      </tr>
                      <tr>
                        <td colspan="5" style="height:30px;"></td>
                      </tr>                          
                      <tr>
                        <td colspan="5" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="5" style="font-size:16px;font-weight:bold; text-align: center;">Часть №7 Погрешности объемомеров ТРК</td>
                      </tr>
                      <tr>
                        <td colspan="5" style="height:30px;"></td>
                      </tr>       
                      </thead>'
            , chr(123), chr(125)
                
            ).
        output stream OutStr-html close. 
    end.    
    assign 
        v-report-result = yes. 
  
End procedure.

procedure first-line-tog8-html :
  
    define input parameter v-report-name-html     as character no-undo .
    if v-report-result = no then 
    do:  
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист8" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
      <tr class="set_columns">
      <td style="width:250px"></td>
      <td style="width:150px"></td>
      <td style="width:50px"></td>
      <td style="width:100px"></td>
      <td style="width:150px"></td>
      <td style="width:50px"></td>
      <td style="width:100px"></td>
      <td style="width:100px"></td>
      <td style="width:100px"></td>
      <td style="width:100px"></td>
      <td style="width:100px"></td>
      </tr>
                       <tr>  
                        <td colspan="11" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="11" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="11" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="11" style="font-size:16px;font-weight:bold; text-align: center;">Часть №8. Возвраты по сопутствующим товарам и топливу</td>
                    </tr>' 
            ,
            v-host-name,
            rep-shift-store-name
            ).
            
        if v-one-shift then 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="11">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
                .
        end.
        else 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="11">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
                .
        end.      
        put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="11"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="11"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="11"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="11"></td>' skip
            '</tr>' skip
            '</thead>' skip
            .
        output stream OutStr-html close.  
    end.
    else 
    do:    
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '       <table orientation="landscape" name="лист8" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
      <tr class="set_columns">
      <td style="width:250px"></td>
      <td style="width:150px"></td>
      <td style="width:50px"></td>
      <td style="width:100px"></td>
      <td style="width:150px"></td>
      <td style="width:50px"></td>
      <td style="width:100px"></td>
      <td style="width:100px"></td>
      <td style="width:100px"></td>
      <td style="width:100px"></td>
      <td style="width:100px"></td>
      </tr>
                      <tr>
                        <td colspan="10" style="height:30px;"></td>
                      </tr>                          
                      <tr>
                        <td colspan="10" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="10" style="font-size:16px;font-weight:bold; text-align: center;">Часть №8. Возвраты по сопутствующим товарам и топливу</td>
                      </tr>
                      <tr>
                        <td colspan="10" style="height:30px;"></td>
                      </tr>       
                      </thead>'
            , chr(123), chr(125)
                
            ).
        output stream OutStr-html close. 
    end.    
    assign 
        v-report-result = yes. 
  
End procedure.



procedure first-line-tog9-html :
  
    define input parameter v-report-name-html     as character no-undo .
  
    if v-param-code <> 2 and v-report-result = no then 
    do: 
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width: 1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист9" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:40px"></td>
                        <td style="width:40px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                      </tr>
                       <tr>  
                        <td colspan="13" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="13" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="13" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="13" style="font-size:16px;font-weight:bold; text-align: center;">Часть №9 Сбросы, переливы и переводы транзакций</td>
                      </tr>' 
            ,
            v-host-name,
            rep-shift-store-name
            ).
            
        if v-one-shift then 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="13">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
                .
        end.
        else 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="13">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
                .
        end.      
        put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="13"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="13"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="13"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="13"></td>' skip
            '</tr>' skip
            '</thead>' skip
            .
        output stream OutStr-html close.  
    end.
    if v-param-code = 2 and v-report-result = no then 
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width:1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист9" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:40px"></td>
                        <td style="width:40px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                      </tr>
                    <tr>
                      <td colspan="13"></td>
                    </tr>
                    <tr>  
                      <td colspan="5" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="8"></td>
                    </tr>
                    <tr>
                      <td colspan="5" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="8"></td>
                    </tr>
                    <tr>
                      <td colspan="13" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="13" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="13"> Смены  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="13"> </td>
                    </tr>'
            ,
            rep-shift-store-name,
            string(ub.clients.obj-name),
            string(v-rep-shift-close-date,"99.99.9999"),
            string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
            string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
            ).

         
        put stream OutStr-html unformatted
            substitute (
            '<tr> 
            <td colspan="4" style="height:30px;"> Состав смены:</td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&2</td>
          </tr>
          <tr> 
            <td colspan="4"></td>
            <td colspan="4" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="4" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          <tr> 
            <td colspan="4" style="height:30px;"></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td colspan="4"></td>
            <td colspan="4" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="4" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="13" style="height:30px;"></td>
          </tr>       
          </thead>'
            ,
            rep-shift-rol-mng,
            rep-shift-for-mng1,
            rep-shift-rol-oper,
            rep-shift-for-opers1
            ).
        output stream OutStr-html close.          
    end.
    if v-report-result = yes then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '       <table orientation="landscape" name="лист9" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:40px"></td>
                        <td style="width:40px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                        <td style="width:90px"></td>
                      </tr>
                      <tr>
                        <td colspan="13" style="height:30px;"></td>
                      </tr>                            
                      <tr>
                        <td colspan="13" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="13" style="font-size:16px;font-weight:bold; text-align: center;">Часть №9 Сбросы, переливы и переводы транзакций</td>
                      </tr>
                      <tr>
                        <td colspan="13" style="height:30px;"></td>
                      </tr>       
                      </thead>'
            ,   chr(123), chr(125)                  
            ).
        output stream OutStr-html close. 
    end. 

    assign 
        v-report-result = yes. 
End procedure.
  
procedure first-line-tog10-html :
  
    define input parameter v-report-name-html     as character no-undo .

    if v-report-result = no then 
    do:   
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width:1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист10" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                      </tr>
                       <tr>  
                        <td colspan="8" >&1</td>
                      </tr>
                      <tr>
                        <td colspan="8" >&2</td>
                      </tr>
                      <tr>
                        <td colspan="8" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="8" style="font-size:16px;font-weight:bold; text-align: center;">Часть №10 Топливо по типам платежей</td>
                    </tr>' 
            ,
            v-host-name,
            rep-shift-store-name
            ).
            
        if v-one-shift then 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="8">Смена: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + '</td></tr>' skip
                .
        end.
        else 
        do:
            put stream OutStr-html unformatted
                '<tr><td colspan="8">Смены с: ' + string(X-Shift-Start) + ' от ' +  String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm") + ' по ' + string(X-Shift-End) + ' от ' + String(x-date-end , "99.99.9999") + ' ' + String( v-rep-shift-close-time,"hh:mm") + '</td></tr>' skip
                .
        end.      
        put stream OutStr-html unformatted
            '<tr>' skip
            '<td colspan="8"> Закрыта ' + string(v-rep-shift-close-date,"99.99.9999") + " " + string(v-rep-shift-close,"hh:mm") + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="8"> Старший смены: ' + rep-shift-for-mng1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="8"> Операторы: ' + rep-shift-for-opers1 + '</td>' skip
            '</tr>' skip
            '<tr>' skip
            '<td colspan="8"></td>' skip
            '</tr>' skip
            '</thead>' skip
            .
        output stream OutStr-html close.  
    end.
    if v-param-code = 2 and v-report-result = no then 
    do:
        output stream OutStr-html to value(v-report-name-html) convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '<!doctype html>
            <html>
              <head>
              <meta charset="UTF-8">
                  <!-- Стили документа -->
              <style>
                   table ~{
                       border-collapse: collapse;
                       table-layout: fixed;
                       width:1200px; 
                   ~}
                   tbody td, th ~{
                       border: 1px solid black;
                       border-collapse: collapse;
                 height: 14px;
                   ~}
          
              </style>
              </head>
                <body>
                  <table orientation="landscape" name="лист10" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                      </tr>
                    <tr>
                      <td colspan="8"></td>
                    </tr>
                    <tr>  
                      <td colspan="4" style="border-bottom: 1px solid black; text-align: center;">&1</td>
                      <td colspan="4"></td>
                    </tr>
                    <tr>
                      <td colspan="4" style="font-size:10px; text-align: center;">наименование организации</td>
                      <td colspan="4"></td>
                    </tr>
                    <tr>
                      <td colspan="8" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ &2</td>
                    </tr>
                    <tr>
                      <td colspan="8" style="text-align: center;"> от &3 </td>
                    </tr>
                    <tr>
                      <td colspan="8"> Смены  с &4  по &5 </td>
                    </tr>
                    <tr>
                      <td colspan="8"> </td>
                    </tr>'
            ,
            rep-shift-store-name,
            string(ub.clients.obj-name),
            string(v-rep-shift-close-date,"99.99.9999"),
            string(X-Shift-Start) + ' от ' + String(v-rep-shift-open-date , "99.99.9999") + ' ' + String ( v-rep-shift-open-time,"hh:mm"),
            string(X-Shift-End) + ' от ' + String(v-rep-shift-close-date , "99.99.9999") + ' ' + String ( v-rep-shift-close-time,"hh:mm")
            ).

         
        put stream OutStr-html unformatted
            substitute (
            '<tr> 
            <td colspan="3" style="height:30px;"> Состав смены:</td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&1</td>
            <td></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&2</td>
          </tr>
          <tr> 
            <td colspan="3"></td>
            <td colspan="2" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          <tr> 
            <td colspan="3" style="height:30px;"></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&3</td>
            <td></td>
            <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&4</td>
          </tr>
          <tr> 
            <td colspan="3"></td>
            <td colspan="2" style="font-size:10px; text-align: center;">должность</td>
            <td></td>
            <td colspan="2" style="font-size:10px; text-align: center;">инициалы, фамилия</td>
          </tr>
          <tr>
            <td colspan="8" style="height:30px;"></td>
          </tr>       
          </thead>'
            ,
            rep-shift-rol-mng,
            rep-shift-for-mng1,
            rep-shift-rol-oper,
            rep-shift-for-opers1
            ).
        output stream OutStr-html close.          
    end.
    if v-report-result = yes then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted
            substitute(
            '       <table orientation="landscape" name="лист10" fit_to_page="true">  <!-- таблица, в которой содержится весь отчет -->
                    <thead>  <!-- Шапка отчета -->
                    <!-- Обязательно создаётся строка таблицы, в которой находятся размеры колонок в px-->
                      <tr class="set_columns">
                        <td style="width:150px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                        <td style="width:100px"></td>
                      </tr>
                      <tr>
                      <td colspan="8" style="height:30px;"></td>
                      </tr>       
                      <tr>
                        <td colspan="8" style="font-size:16px;font-weight:bold; text-align: center;">СМЕННЫЙ ОТЧЕТ</td>
                      </tr>
                      <tr>
                        <td colspan="8" style="font-size:16px;font-weight:bold; text-align: center;">Часть №10 Топливо по типам платежей</td>
                      </tr>
                      <tr>
                      <td colspan="8" style="height:30px;"></td>
                      </tr>       
                      </thead>'
            ,       chr(123), chr(125)             
            ).
        output stream OutStr-html close. 
    end.  
    assign 
        v-report-result = yes. 
End procedure.



/*процедуры печати подвалов*/
  
procedure last-line-tog-html :
    define input parameter v-report-name-html     as character no-undo .

    find first temp-shift-obj  where temp-shift-obj.num = v-count no-error .
    if available temp-shift-obj then 
    do:
        assign
            x-date-End             = temp-shift-obj.shift-date
            X-Shift-End            = temp-shift-obj.shift-num
            v-rep-shift-close-date = temp-shift-obj.close-date
            v-rep-shift-close-time = temp-shift-obj.close-time
            .
    end.
  
  
    FIND FIRST ub.shift-staff No-LOCK WHERE
        ub.shift-staff.obj-type   = p-obj-type AND
        ub.shift-staff.obj-code   = p-obj-code AND
        ub.shift-staff.shift-date = x-date-End AND
        ub.shift-staff.shift-num  = X-Shift-End AND
        ub.shift-staff.staff-role = yes and
        ub.shift-staff.psn-num    >= 0 No-ERROR.
    assign 
        rep-shift-for-mng-end = if available ub.shift-staff then string(ub.shift-staff.name, "X(30)") else "".
    rep-shift-rol-mng-end = "Старший оператор"  
        .

    if v-param-code = 1 then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted                                                                     
            substitute (
            '
              <tfoot>
                  <tr> <!--Подвал-->
                    <td colspan="8" style="height:30px;"></td>
                  </tr>
                    <tr> 
                    <td colspan="8" style="height:30px;"> СМЕНУ СДАЛ:  &1  __________________</td>
                  </tr>
                  <tr> 
                    <td colspan="8"> СМЕНУ ПРИНЯЛ: </td>
                  </tr>
            </tfoot>
        </table>
        '                                                                                      
            ,
        
            rep-shift-for-mng-next                                                                                            
            ).                                                                                                    
        put stream OutStr-html unformatted                                                                     
            substitute (
            '
        </body>
        </html>
        '                                                                                      
            , chr(123), chr(125)                                                                                                 
            ).                                                                                                    
        output stream OutStr-html close.
    end.
    else 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.  
        put stream OutStr-html unformatted                                                                     
            substitute (
            '
              <tfoot>
                  <tr> <!--Подвал-->
                    <td colspan="8"></td>
                  </tr>
                    <tr> 
                    <td colspan="2" style="height:30px;"> Отчет составил и смену сдал:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&1</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&2</td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">подпись</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
                    <tr> 
                    <td colspan="2" style="height:30px;"> Смену принял:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&3</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&4</td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px;  text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px;  text-align: center;">подпись</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
                    <tr>
                    <td colspan="2" style="height:30px;"> Отчет проверил:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">подпись</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
        
            </tfoot>
        </table>
        '                                                                                      
            ,
            rep-shift-rol-mng-end,  
            rep-shift-for-mng-end, 
            rep-shift-rol-mng-next,  
            rep-shift-for-mng-next                                                                                            
            ).                                                                                                    
        output stream OutStr-html close.
 

    end.      
End procedure.


procedure last-line-tog-html81 :
    define input parameter v-report-name-html     as character no-undo .

    find first temp-shift-obj  where temp-shift-obj.num = v-count no-error .
    if available temp-shift-obj then 
    do:
        assign
            x-date-End             = temp-shift-obj.shift-date
            X-Shift-End            = temp-shift-obj.shift-num
            v-rep-shift-close-date = temp-shift-obj.close-date
            v-rep-shift-close-time = temp-shift-obj.close-time
            .
    end.
  
  
    FIND FIRST ub.shift-staff No-LOCK WHERE
        ub.shift-staff.obj-type   = p-obj-type AND
        ub.shift-staff.obj-code   = p-obj-code AND
        ub.shift-staff.shift-date = x-date-End AND
        ub.shift-staff.shift-num  = X-Shift-End AND
        ub.shift-staff.staff-role = yes and
        ub.shift-staff.psn-num    >= 0 No-ERROR.
    assign 
        rep-shift-for-mng-end = if available ub.shift-staff then string(ub.shift-staff.name, "X(30)") else "".
    rep-shift-rol-mng-end = "Старший оператор"  
        .

    if v-param-code = 1 then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted                                                                     
            substitute (
            '
              <tfoot>
                  <tr> <!--Подвал-->
                    <td colspan="8" style="height:30px;"></td>
                  </tr>
                    <tr> 
                    <td colspan="8" style="height:30px;"> СМЕНУ СДАЛ:  &1  __________________</td>
                  </tr>
                  <tr> 
                    <td colspan="8"> СМЕНУ ПРИНЯЛ: </td>
                  </tr>
            </tfoot>
            
        </table>
        '                                                                                      
            ,
        
            rep-shift-for-mng-next                                                                                            
            ).                                                                                                    
        put stream OutStr-html unformatted                                                                     
            substitute (
            '
        </body>
        </html>
        '                                                                                      
            , chr(123), chr(125)                                                                                                 
            ).                                                                                                    
        output stream OutStr-html close.
    end.
    else 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.  
        put stream OutStr-html unformatted                                                                     
            substitute (
            '
              <tfoot>
                  <tr> <!--Подвал-->
                    <td colspan="8"></td>
                  </tr>
                    <tr> 
                    <td colspan="2" style="height:30px;"> Отчет составил и смену сдал:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&1</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&2</td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">подпись</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
                    <tr> 
                    <td colspan="2" style="height:30px;"> Смену принял:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&3</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&4</td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px;  text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px;  text-align: center;">подпись</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
                    <tr>
                    <td colspan="2" style="height:30px;"> Отчет проверил:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">подпись</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
        <tr><td colspan="7">«Частичный возврат» - это: </td></tr>
<tr><td colspan="7">«Частичный возврат» - возврат, который был проведен на недолитое топливо по транзакции на АРМ Кассира</td></tr>
<tr><td colspan="7">«Остальные возвраты» - это:</td></tr>
<tr><td colspan="7">«Полный по номеру чека» - полный возврат, который был проведен по номеру чека на АРМ Кассира</td></tr>
<tr><td colspan="7">«Частичный по номеру чека» - частичный возврат, который был проведен по номеру чека на АРМ Кассира</td></tr>
<tr><td colspan="7">«Полный по транзакции» - полный возврат, который был проведен по транзакции на АРМ Кассира</td></tr>
<tr><td colspan="7">«Сухой чек, созданный в ППО Trade House» - сухой возврат, который был проведен на АРМ Кассира</td></tr>
<tr><td colspan="7">«Сухой чек, проведенный на АРМ Кассира» - сухой возврат, который был проведен на АРМ Кассира</td></tr>

        
            </tfoot>
            
            
        </table>
        '                                                                                      
            ,
            rep-shift-rol-mng-end,  
            rep-shift-for-mng-end, 
            rep-shift-rol-mng-next,  
            rep-shift-for-mng-next                                                                                            
            ).                                                                                                    
        output stream OutStr-html close.
 

    end.      
End procedure.

procedure last-line-tog-html5-1 :
    define input parameter v-report-name-html     as character no-undo .

    find first temp-shift-obj  where temp-shift-obj.num = v-count no-error .
    if available temp-shift-obj then 
    do:
        assign
            x-date-End             = temp-shift-obj.shift-date
            X-Shift-End            = temp-shift-obj.shift-num
            v-rep-shift-close-date = temp-shift-obj.close-date
            v-rep-shift-close-time = temp-shift-obj.close-time
            .
    end.
  
  
    /*  /* ищем следующюю смену и ее персонал */                                                                                                       */
    /*  FIND first next-shift-obj NO-LOCK                                                                                                              */
    /*    WHERE next-shift-obj.obj-type   = temp-shift-obj.obj-type                                                                                    */
    /*      and next-shift-obj.obj-code   = temp-shift-obj.obj-code                                                                                    */
    /*      and next-shift-obj.shift-date = temp-shift-obj.shift-date                                                                                  */
    /*      and next-shift-obj.shift-num  = temp-shift-obj.shift-num                                                                                   */
    /*  no-error .                                                                                                                                     */
    /*  FIND NEXT  next-shift-obj SHARE-LOCK WHERE next-shift-obj.obj-type = p-obj-type AND next-shift-obj.obj-code = p-obj-code use-index pi NO-ERROR.*/
    FIND FIRST ub.shift-staff No-LOCK WHERE
        ub.shift-staff.obj-type   = p-obj-type AND
        ub.shift-staff.obj-code   = p-obj-code AND
        ub.shift-staff.shift-date = x-date-End AND
        ub.shift-staff.shift-num  = X-Shift-End AND
        ub.shift-staff.staff-role = yes and
        ub.shift-staff.psn-num    >= 0 No-ERROR.
    assign 
        rep-shift-for-mng-end = if available ub.shift-staff then string(ub.shift-staff.name, "X(30)") else "".
    rep-shift-rol-mng-end = "Старший оператор"  
        .
    if v-param-code = 1 then 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.
        put stream OutStr-html unformatted                                                                     
            substitute (
            '
              
                  <tr> <!--Подвал-->
                    <td colspan="7" style="height:30px;"></td>
                  </tr>
                    <tr> 
                    <td colspan="7" style="height:30px;"> СМЕНУ СДАЛ:  &1  __________________</td>
                  </tr>
                  <tr> 
                    <td colspan="7"> СМЕНУ ПРИНЯЛ: </td>
                  </tr>
            </tfoot>
        </table>
        '                                                                                      
            ,
        
            rep-shift-for-mng-next                                                                                            
            ).                                                                                                    
        put stream OutStr-html unformatted                                                                     
            substitute (
            '
        </body>
        </html>
        '                                                                                      
            , chr(123), chr(125)                                                                                                 
            ).                                                                                                    
        output stream OutStr-html close.
    end.
    else 
    do:
        output stream OutStr-html to value(v-report-name-html) append convert target 'UTF-8' /*no-convert*/.  
        put stream OutStr-html unformatted                                                                     
            substitute (
            '
              
                  <tr> <!--Подвал-->
                    <td colspan="9"></td>
                  </tr>
                    <tr> 
                    <td colspan="2" style="height:30px;"> Отчет составил и смену сдал:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&1</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&2</td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">подпись</td>
                    <td></td>
                    <td colspan="2" style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
                    <tr> 
                    <td colspan="2" style="height:30px;"> Смену принял:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;">&3</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td colspan="2" style="border-bottom: 1px solid black; text-align: center;">&4</td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px;  text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px;  text-align: center;">подпись</td>
                    <td></td>
                    <td colspan="2" style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
                    <tr>
                    <td colspan="2" style="height:30px;"> Отчет проверил:</td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td style="border-bottom: 1px solid black; text-align: center;"></td>
                    <td></td>
                    <td colspan="2" style="border-bottom: 1px solid black; text-align: center;"></td>
                  </tr>
                  <tr> 
                    <td colspan="2"></td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">должность</td>
                    <td></td>
                    <td style="font-size:10px; text-align: center;">подпись</td>
                    <td></td>
                    <td colspan="2" style="font-size:10px; text-align: center;">расшифровка подписи</td>
                  </tr>
        
            </tfoot>
        </table>
        '                                                                                      
            ,
            rep-shift-rol-mng-end,  
            rep-shift-for-mng-end, 
            rep-shift-rol-mng-next,  
            rep-shift-for-mng-next                                                                                            
            ).                                                                                                    
        output stream OutStr-html close.
 

    end.      
End procedure.
