block-level on error undo, throw.
/*

$Revision: eb694e4e9475, 2831, rls $
$Author: EShklyar $
$Date: Пн ноя 22 19:48:51 2021 +0300 $
$Workfile: bgecheck-new.p $
$Archive: bge/bgecheck-new.p $

Экспорт чеков

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 04/12/06
Author: Victor Guntner
Creation date: 04/12/06

Input:

Output:

*/
using ibs.th.gbl.gbl-var.

define input parameter  p-log-handle       as handle               no-undo.
define input parameter v-ftp-adress        as character            no-undo.
define input parameter v-place             as integer              no-undo.
define input parameter v-login             as character            no-undo.
define input parameter v-password          as character            no-undo.
define input parameter p-pack-lim          as int64                no-undo. /* после 90Mb закрываем пакет и делаем новый; на входе целое число мегабайт */
define input parameter v-date-from         as date      INIT ?     no-undo.
define input parameter v-date-to           as date      INIT ?     no-undo.
define input parameter v-range             as integer              no-undo.
define input parameter v-host-code         as integer              no-undo.
define input parameter v-obj-list          as character            no-undo.
define input parameter v-pay-type-list     as character            no-undo . /* список recid'ов выбранных записей cash-pay */
define input parameter v-gds-type          as character init 'all' no-undo.  /* тип товара all/fuel/other */
define input parameter v-void-character    as character            no-undo.
define input parameter v-dc-num-full       as character            no-undo.
define input parameter v-per               as integer              no-undo.
define input parameter v-inf-bonus         as logical              no-undo.    
define input parameter p-code_pool         as character            no-undo.
define input parameter p-chk-type as character no-undo.
define variable vss-revision    as character no-undo init "$Revision: eb694e4e9475, 2831, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Пн ноя 22 19:48:51 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: bgecheck-new.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/bgecheck-new.p $":U .
define variable vss-description as character no-undo init "Экспорт чеков".
{ cmp/vssrevis.i        }
{ cmp/trg-def.i         }
{ gbl/temphost.i        }
{ bge/bge-xml.i         }
{ gbl/getcntxt.i def    }
{ str/lib-trn.i         }
{ gbl/ftp-df.i }
{ cmp/r-pril.i new  } 

&scoped-define version-string "12.3 " + replace( vss-revision + vss-date, "$", " " )
&scop discnt-type-code string(buf_chk-discnt.discnt-type)
&scop discnt-target-code string(buf_chk-discnt.line-type)
&scop discnt-v-code string(buf_chk-discnt.value-type)
define variable   log-file-name  as char no-undo.
define VARIABLE   bonus-relation as char no-undo .

DEFINE TEMP-TABLE tt-cash-pay NO-UNDO
    FIELD pay-code  LIKE cash-pay.cdpay-code
    FIELD curr-code LIKE cash-pay.curr-code
    INDEX pu AS PRIMARY UNIQUE
    pay-code
    curr-code
    .


do on error undo, return error :
    define variable v-xml-file-name    as character no-undo.
    define variable v-log-file-name    as character no-undo.
    define variable v-locked           as logical   no-undo.

    define variable v-obj-counter      as integer   no-undo.
    define variable v-rrn              as character no-undo.
    DEFINE VARIABLE v-pay-type-counter AS INTEGER   NO-UNDO.
    DEFINE VARIABLE v-need-pay-type    AS LOGICAL   NO-UNDO.

    DEFINE VARIABLE v-db-num-char      AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-task-type        AS CHARACTER NO-UNDO.
    DEFINE VARIABLE v-task-num         AS INTEGER   NO-UNDO.
    DEFINE VARIABLE v-action           AS CHARACTER NO-UNDO.
    define variable v-cash-pay-recid   as integer no-undo .
    
    define variable v-corr-type as character no-undo .
    
    DEFINE BUFFER buf_cash-pay      FOR cash-pay.
    define buffer buf_dis-card      for ub.dis-card.



    IF v-pay-type-list <> "" THEN
    DO v-pay-type-counter = 1 TO NUM-ENTRIES( v-pay-type-list ):
      v-cash-pay-recid = INTEGER(  ENTRY( v-pay-type-counter, v-pay-type-list )  ) .
        FIND FIRST buf_cash-pay NO-LOCK
            WHERE RECID(buf_cash-pay) = v-cash-pay-recid NO-ERROR.
        IF NOT AVAILABLE buf_cash-pay then next .
        if CAN-FIND(FIRST tt-cash-pay
                    WHERE tt-cash-pay.pay-code  = buf_cash-pay.cdpay-code
                      AND tt-cash-pay.curr-code = buf_cash-pay.curr-code)   THEN NEXT.
        CREATE tt-cash-pay.
        ASSIGN
            tt-cash-pay.pay-code  = buf_cash-pay.cdpay-code
            tt-cash-pay.curr-code = buf_cash-pay.curr-code
            .
        release tt-cash-pay.     
    END.
    v-need-pay-type = CAN-FIND (FIRST tt-cash-pay no-lock) .

        { gbl/working.i }

if v-place = 2 then do:
        log-file-name = "check.log"
        .
 &scop display-message    run write-log-and-file in p-log-handle (  ~
         input 1                                                      ~
         , input log-file-name                                          ~
         , input 1                                                      ~
         , input ~{&my-message~})
end.
else if v-place = 1 then do:
  /* вызывается только ради имени лог-файла; имя xml-файла берётся напрямую через genfname.p */
    run xml-bge-filename in this-procedure (
        input "D":U
        , input "":U
        , input no
        , output v-xml-file-name
        , output v-log-file-name
        , output v-locked
        ) no-error.
end .

    case v-range:
        when 1 then run init-temphost.
        when 2 then do: /* Экспорт по текущей фирме */
                run init-temphost.
                for each temp-obj where temp-obj.host-code <> v-host-code :
                    delete temp-obj.
                end.
        end.
        when 3 then do: /* Экспорт по списку объектов */
                for each temp-obj :
                    delete temp-obj.
                end.
                do v-obj-counter = 1 to num-entries ( v-obj-list ) / 2 :
                    create temp-obj.
                    assign
                        temp-obj.obj-type = entry( v-obj-counter * 2 - 1, v-obj-list )
                        temp-obj.obj-code = integer( entry( v-obj-counter * 2, v-obj-list ) )
                    no-error .
                    if error-status:error then do:
                        run wp-XMLWriteLog in this-procedure (
                            input v-log-file-name
                            , input 1
                            , input substitute( "*** Ошибка чтения списка объектов. &1. &2. &3. &4."
                            , return-value
                            , trim(error-status :get-message(1))
                            , trim(error-status :get-message(2))
                            , trim(error-status :get-message(3))
                            )
                            ).
                        undo, return error .
                    end.
                    { gbl/hostcode.i
                      temp-obj.obj-type
                      temp-obj.obj-code
                      temp-obj.host-code
                    no-error }
                    if error-status:error then do:
                        run wp-XMLWriteLog in this-procedure (
                            input v-log-file-name
                            , input 1
                            , input substitute( "*** Не найдена фирма для объекта &1 &2. &3. &4. &5. &6."
                            , temp-obj.obj-type
                            , temp-obj.obj-code
                            , return-value
                            , trim(error-status :get-message(1))
                            , trim(error-status :get-message(2))
                            , trim(error-status :get-message(3))
                            )
                            ).
                        undo, return error .
                    end.
                end.
        end.
    end case.

    define variable v-full-path as character no-undo .
         if v-place = 1 then v-full-path = v-ftp-adress .
    else if v-place = 2 then v-full-path = session:temp-directory .
    
    if v-per = 0 then . 
    else assign
      v-date-to   = today
      v-date-from = v-date-to - v-per
    .
    v-dc-num-full = right-trim(v-dc-num-full, ",").


    /* выгрузку чеков производить пакетами не более 100Mb, иначе Башнефть их вкачать не может */
    define variable v-trim-zero  as character no-undo.
    define variable v-par-type   as character no-undo.
    define variable v-must-open  as logical no-undo. /* true: требуется открыть выходной поток */
    define variable v-is-started as logical no-undo. /* true: файл был создан (т.е. были магазины и чеки для выгрузки) */ 
    DEFINE VARIABLE v-finded-pay-type AS LOGICAL   NO-UNDO.
    define variable v-is-ok      as logical no-undo .
    define variable v-d-card     as character no-undo.
    define variable v-manual-add as character no-undo .
    define buffer buf_chk-doc      for ub.chk-doc .
    define buffer buf_chk-doc-attr for ub.chk-doc-attr .
    define buffer buf_chk-pay      for ub.chk-pay .
    define buffer buf_tt-cash-pay  for tt-cash-pay .
    define buffer buf_c-chk-doc    for ub.c-chk-doc .
    define buffer buf_chk-discnt   for ub.chk-discnt .
    define variable v-discnt-t-round  as logical no-undo .
    
    if p-pack-lim > 0 then 
      p-pack-lim = p-pack-lim * 1024 * 1024 . /* 90 * 1024 * 1024 = 94371840 байт */

    v-must-open = true.
    v-is-started = false.
    for each temp-obj :
      do:
        run gbl/conf-rd.p (
            input "bgedcard":U
            , input temp-obj.host-code
            , input temp-obj.obj-type
            , input temp-obj.obj-code
            , input "":U
            , input "":U
            , input "":U
            , input no
            , output v-trim-zero
            , output v-par-type
        ) no-error.
        if error-status:error then v-trim-zero = "no":U . 
      end. /* end_of conf-rd.p */
      do:  
        run rep/rpychk0.p (input "r-shftc2"
            ,input temp-obj.obj-type
            ,input temp-obj.obj-code
            ,input ?                    /*p-date-from*/
            ,input ?                    /*p-date-to*/
            ,input v-date-from         /*p-shift-date-from*/
            ,input v-date-to           /*p-shift-date-to*/
            ,input 1                    /*p-shift-num-start*/
            ,input 99                   /*p-shift-num-end*/
            ,input ?                    /*p-inkas-code*/
        ) no-error.
        if error-status:error then do:
          run wp-XMLWriteLog in this-procedure (
                    input v-log-file-name
                    , input 1
                    , input substitute( "*** Ошибка выгрузки чеков по объекту &1 &2. &3. &4. &5."
                    , temp-obj.obj-type
                    , temp-obj.obj-code
                    , return-value
                    , error-status:get-message(1)
                    , error-status:get-message(2)
                    )
                    ).
        end.
      end. /* end_of rep/rpychk0.p */
      for each buf_chk-doc no-lock
          where buf_chk-doc.obj-type = temp-obj.obj-type
            and buf_chk-doc.obj-code = temp-obj.obj-code
            and buf_chk-doc.chk-date >= v-date-from
            and buf_chk-doc.chk-date <= v-date-to :
        do: /* фильтруем chk-doc */
          /* Пропускаем ошибочные чеки
             if replace(replace(replace(buf_chk-doc.office
                               , {&gds-goods}
                               , '':U)
                       , {&gds-office}
                       , '':U)
               , {&comma-char}
               , '':U) <> '':U
            then next.
          */
          if p-chk-type > "" then do: 
            if lookup(string(buf_chk-doc.chk-type),p-chk-type) = 0 then next.
          end.
          if v-dc-num-full > "" then do:
            if lookup( buf_chk-doc.d-card, v-dc-num-full ) = 0 then next.
          end.
          if v-need-pay-type then do :
            v-finded-pay-type = FALSE.
            for each buf_tt-cash-pay:
              if can-find (first buf_chk-pay
                           where buf_chk-pay.doc-code  = buf_chk-doc.doc-code
                             and buf_chk-pay.pay-code  = buf_tt-cash-pay.pay-code
                             and buf_chk-pay.curr-code = buf_tt-cash-pay.curr-code)
              then do : 
                v-finded-pay-type = TRUE .
                leave .
              end .
            end .
            if not v-finded-pay-type THEN NEXT.
          end .
          if not v-gds-type = "all" then do: 
            run check-gds-type in this-procedure
            (input v-gds-type
            ,input buf_chk-doc.doc-code
           ,output v-is-ok
            ) .
            if not v-is-ok then next .
          end .  
        end . /* end_of фильтруем chk-doc */   

        /* переоткрываем поток вывода (в начале, и через каждые 100Mb) */
        if v-must-open then do:
          run bge/genfname.p (
            input v-full-path
            , input "D"
            , input ""
            , input "."
            , input ""
            , output v-xml-file-name
          ).
          run wp-XMLWriteLog in this-procedure (
        input v-log-file-name
        , input 1
        , input "&DLine"
          ).
          run wp-XMLWriteLog in this-procedure (
        input v-log-file-name
        , input 1
        , input substitute( "Начало выгрузки чеков в файл &1xm1"
        , replace( v-xml-file-name, "/", "\" )
        )
          ).
          run wp-XMLWriteLog in this-procedure (
            input v-log-file-name
            , input 1
            , input substitute( "................с параметрами: Дата с: &1, дата по: &2"
            , v-date-from
            , v-date-to
            )
          ).
          run wp-XMLWriteLog in this-procedure (
        input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... список объектов: &1", v-obj-list )
          ).
          output stream stmXMLOut to value( v-xml-file-name + "xm1" ) convert target "1251" .
          v-is-started = true .
          run bge-xml-write-header-check in this-procedure
          (input "check"
        , input {&version-string}
        , input gbl-var:g#db-num
        , input v-date-from
        , input 0
        , input v-date-to
        , input 0
        , input v-obj-list
        , input p-code_pool
        , input v-dc-num-full
        , input v-inf-bonus
        , input "":U
        , input no
        , input no
        , input no
        , input no
        , input no
        , input no
        , input no
        , input no
          ) no-error.
          if error-status:error then do:
            run wp-XMLWriteLog in this-procedure (
            input v-log-file-name
            , input 1
            , input substitute( "*** Ошибка записи шапки файла. Процедура: &1 (v.&2 &3). &4. &5"
            , vss-workfile
            , vss-revision
            , vss-description
            , return-value
            , error-status:get-message(1)
            )
            ).
            undo, return error.
          end.
          v-must-open = false.
        end. /* end_of v-must-open */    

        find first buf_chk-discnt no-lock where buf_chk-discnt.doc-code = buf_chk-doc.doc-code
        and buf_chk-discnt.discnt-type = integer({&discnt-t-cashround}) no-error .
        if available (buf_chk-discnt) then v-discnt-t-round = yes .
        else v-discnt-t-round = no .
          
        /* заголовок чека */
        v-d-card = if v-trim-zero = "yes":U then left-trim(buf_chk-doc.d-card, "0":U) else buf_chk-doc.d-card .
        
        run wp-xmltagopen  in this-procedure ( input 1, input "check"     , input "" ).
        run wp-xmltagopen  in this-procedure ( input 2, input "checkHead" , input "" ).
        run wp-xmltagput   in this-procedure ( input 3, input "ID"        , input string( buf_chk-doc.doc-code ), input 0 ).
        run wp-xmltagput   in this-procedure ( input 3, input "objType"   , input string( buf_chk-doc.obj-type ), input 0 ).
        run wp-xmltagput   in this-procedure ( input 3, input "objCode"   , input string( buf_chk-doc.obj-code ), input 0 ).
        run wp-xmltagput   in this-procedure ( input 3, input "date"      , input string( buf_chk-doc.chk-date, "99/99/9999" ), input 0 ).
        run wp-xmltagput   in this-procedure ( input 3, input "time"      , input string( buf_chk-doc.chk-time, "HH:MM:SS" ), input 0 ).
        run wp-xmltagput   in this-procedure ( input 3, input "checkNum"  , input string( buf_chk-doc.chk-num  ), input 0 ).
        run wp-xmltagput   in this-procedure ( input 3, input "deskNum"   , input string( buf_chk-doc.pay-desk ), input 0 ).
        run wp-xmltagput   in this-procedure ( input 3, input "SrcCardNum"        , input buf_chk-doc.src-d-card , input 0 ).
        run wp-xmltagput   in this-procedure ( input 3, input "cardNum"       , input string( v-d-card         ), input 0 ).  
        run wp-xmltagput   in this-procedure ( input 3, input "checktype"     , input string( buf_chk-doc.chk-type   ), input 0 ).            
        run wp-xmltagput   in this-procedure ( input 3, input "chekShiftDate" , input string( buf_chk-doc.shift-date ), input 0 ).            
        run wp-xmltagput   in this-procedure ( input 3, input "chekShiftNum"  , input string( buf_chk-doc.shift-num  ), input 0 ).   
        run wp-xmltagput   in this-procedure ( input 3, input "checkTotDoc"   , input string( buf_chk-doc.netto      ), input 0 ). 
        run wp-xmltagput   in this-procedure ( input 3, input "checkBruttoDoc", input string( buf_chk-doc.tot-doc    ), input 0 ).
        if v-discnt-t-round then do:
          run wp-xmltagput   in this-procedure ( input 3, input "checkNettoSPL", input string( buf_chk-doc.tot-doc    ), input 0 ).
        end.
        else do:
          run wp-xmltagput   in this-procedure ( input 3, input "checkNettoSPL", input string( buf_chk-doc.netto    ), input 0 ).
        end.    
        if buf_chk-doc.chk-type <> integer({&income-corr})
        and buf_chk-doc.chk-type <> integer({&expense-corr})       
        then                            
        run wp-xmltagput   in this-procedure ( input 3, input "Reference-num" , input string( buf_chk-doc.doc-num2   ), input 1 ).
        run wp-xmltagput   in this-procedure ( input 3, input "Z-num"         , input string( buf_chk-doc.z-number   ), input 1 ).
        if buf_chk-doc.chk-type = integer({&income-corr})
        or buf_chk-doc.chk-type = integer({&expense-corr})
        then do :
          run wp-xmltagput   in this-procedure ( input 3, input "Reason" , input string( buf_chk-doc.doc-num   ), input 1 ).
          if num-entries(buf_chk-doc.doc-num2, ":") = 2
          then do :
            if entry(1, buf_chk-doc.doc-num2, ":") = "0"
            then v-corr-type = "самостоятельно" .
            else
            if entry(1, buf_chk-doc.doc-num2, ":") = "1"
            then v-corr-type = "по предписанию" .
            else
            v-corr-type = "неизвестн." .
          end.
          else
          v-corr-type = "неизвестн." .
          run wp-xmltagput   in this-procedure ( input 3, input "CorrType" , input string( v-corr-type  ), input 1 ).
        end.  
        /* 24/V-2018 В расширенную выгрузку чеков добавить тэг с признаком, что чек был создан вручную.
                     Определяется это по истории. Посмотреть как сделано в интерфейсе ручных чеков.
                     Название тэга - manual. значение 1\0
           @NOTE     Согласно str/superchk.p уникальный индекс по c-chk-doc строится по полям 
                     1 doc-code
                     2 corr-user-db-num
                     3 chip-num
                     при отображении в фильтр передаётся только doc-code;
                     поле chip-num заполняется нарастающими значениями.
        */
        /* 07/VI-2018 в выгрузке значение &#63 (символ "?"), т.е. записи в истории нет.
                      Эта ситуация в постановке задачи и в методах проверки задачи отсутствует.
                      Поэтому при отсутствии истории выгружаем "0", чтобы уменьшить заказчику
                      количество подозрительных чеков и количество головной боли на их перепроверку.
        */
        v-manual-add = "0" .
        for each buf_c-chk-doc no-lock
           where buf_c-chk-doc.doc-code = buf_chk-doc.doc-code
              by buf_c-chk-doc.chip-num :
          v-manual-add = if buf_c-chk-doc.is-add then "1" else "0" .
          leave .
        end .
        run wp-xmltagput   in this-procedure ( input 3, input "manual", v-manual-add, input 0 ). 
        
        for first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
          and buf_chk-doc-attr.attr-code  = "corr-osnov" :
          run wp-xmltagput   in this-procedure ( input 3, input "CorrOsnovName", buf_chk-doc-attr.attr-value , input 1 ).
        end.

        for first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
          and buf_chk-doc-attr.attr-code  = "corr-date" :
          run wp-xmltagput   in this-procedure ( input 3, input "CorrOsnovDate", buf_chk-doc-attr.attr-value, input 1 ).
        end.

        for first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
          and buf_chk-doc-attr.attr-code  = "corr-num" :
          run wp-xmltagput   in this-procedure ( input 3, input "CorrOsnovNum", buf_chk-doc-attr.attr-value, input 1 ).
        end.
        for first buf_chk-doc-attr exclusive-lock where buf_chk-doc-attr.doc-code = buf_chk-doc.doc-code
          and buf_chk-doc-attr.attr-code  = "corr-cause" :
          run wp-xmltagput   in this-procedure ( input 3, input "CorrOsnovCause", buf_chk-doc-attr.attr-value, input 1 ).
        end.
        find first buf_chk-doc-attr where buf_chk-doc-attr.doc-code  eq buf_chk-doc.doc-code
                                      and buf_chk-doc-attr.attr-code eq "CHNumberKKT"
             no-lock no-error.
        if avail buf_chk-doc-attr
        then
           run wp-xmltagput( input 3, input "CHNumberKKT", input buf_chk-doc-attr.attr-value, input 2 ).
        find first buf_chk-doc-attr where buf_chk-doc-attr.doc-code  eq buf_chk-doc.doc-code
                                      and buf_chk-doc-attr.attr-code eq "CHNumberFN"
             no-lock no-error.
        if avail buf_chk-doc-attr
        then
           run wp-xmltagput( input 3, input "CHNumberFN", input buf_chk-doc-attr.attr-value, input 2 ).
        run wp-xmltagclose in this-procedure ( input 2, input "checkHead").
        /* end_of заголовок чека */      
    
        /* товары, оплаты, скидки, и т.п. */
        run export-checks-by-object in this-procedure
        (input buf_chk-doc.doc-code
       , input v-log-file-name
       , input v-d-card
        ) no-error.
        if error-status:error then do:
          run wp-XMLWriteLog in this-procedure (
                    input v-log-file-name
                    , input 1
                    , input substitute( "*** Ошибка выгрузки чеков по объекту &1 &2. &3. &4. &5."
                    , temp-obj.obj-type
                    , temp-obj.obj-code
                    , return-value
                    , error-status:get-message(1)
                    , error-status:get-message(2)
                    )
                    ).
        end.
        run wp-xmltagclose in this-procedure ( input 1, input "check").

        /* как только свыше 90Mb - переоткрываем поток */
        if p-pack-lim > 0 then do:
          if seek(stmxmlout) > p-pack-lim then do:
            run close-xml-out in this-procedure.
            v-must-open = true.
          end .
        end .
      end . /* end_of for_each chk-doc */
    end.  /* for each temp-obj */
    
    if v-is-started then do:
    run close-xml-out in this-procedure.
        /*НАДО УБЕДИТЬСЯ ЧТО ВСЕ РАЗМАЗАНО!!*/
                 if  v-place  = 2 then
do:
   
        run ftp-send in this-procedure (input (v-xml-file-name)) no-error.
        if error-status:error
            then 
        do:
                  &scop my-message substitute("Ошибка отправки по FTP: &1", return-value)
            {&display-message}.
        end.
        else
        do:
            v-xml-file-name = replace( v-xml-file-name, "/", "\" ) + "xml".
            os-delete value( v-xml-file-name ).
        end.
   
end.

    end. /* end_of v-is-started */
    else do:
      run wp-XMLWriteLog in this-procedure (
        input v-log-file-name
        , input 1
        , input "&DLine"
      ).
      run wp-XMLWriteLog in this-procedure (
                    input v-log-file-name
                    , input 1
                    , input "*** Ошибка выгрузки чеков. Отсутствуют чеки, подлежащие выгрузке. Файл не был выгружен."
                    ).
          run wp-XMLWriteLog in this-procedure (
            input v-log-file-name
            , input 1
            , input substitute( "................с параметрами: Дата с: &1, дата по: &2"
            , v-date-from
            , v-date-to
            )
      ).
      run wp-XMLWriteLog in this-procedure (
        input v-log-file-name
        , input 1
        , input substitute( "................с параметрами: ... список объектов: &1", v-obj-list )
      ).
    end.
    

    { gbl/stopwork.i }
end.

/*==========================================================================*/
procedure close-xml-out private:
  output stream stmXMLOut close.
  
  run xml-bge-write-footer in this-procedure (
            input v-xml-file-name
          ) no-error .
  if error-status:error then do:
    run wp-XMLWriteLog in this-procedure (
                    input v-log-file-name
                    , input 1
                    , input substitute( "*** Ошибка выгрузки чеков. Ошибка при закрытии файла выгрузки. &1."
                    , return-value
                    )
                    ).
  end.
          run wp-XMLWriteLog in this-procedure (
        input v-log-file-name
        , input 1
        , input substitute( "Данные выгружены в файл &1xml"
        , replace( v-xml-file-name, "/", "\" )
        )
          ).
          run wp-XMLWriteLog in this-procedure (
        input v-log-file-name
        , input 1
        , input "&DLine"
          ).
end procedure. /* end_of close-xml-out */

procedure export-checks-by-object :
    do
        on error undo, return error
        :
define input parameter p-doc-code       as character    no-undo.
define input parameter p-log-file-name  as character    no-undo.
define input parameter p-d-card         as character    no-undo.
          
define variable v-gds-code        as integer   no-undo.
define variable v-artic           as character no-undo.
define variable v-prod-type       as character no-undo.
define variable v-prod-code       as integer   no-undo.
define variable v-gds-name        as character no-undo.
define VARIABLE   bonus-relation as char no-undo .
        define variable v-cpline          as integer   no-undo.
        define variable v-pay-code        as integer   no-undo.
        define variable v-eff-doc-qnty    as decimal   no-undo.
        define variable v-pay-card        as character no-undo.
        define variable v-price-base      as decimal   no-undo.
        define variable v-tot-r-b         as decimal   no-undo.
        define variable v-discnt          as decimal   no-undo.
        define variable v-pay-name        as character no-undo.
        define variable v-curr-abbr       as character no-undo.

define buffer buf_chk-gds      for ub.chk-gds .
define buffer buf_bar-code     for ub.bar-code .
define buffer buf_goods        for ub.goods .
define buffer buf_chk-gds-pay  for ub.chk-gds-pay .
define buffer buf_chk-pay      for ub.chk-pay .
define buffer buf_cash-pay     for ub.cash-pay .
define buffer buf_currency     for ub.currency .
define buffer buf_chk-pay-attr for chk-pay-attr.
DEFINE BUFFER buf_chk-discnt   for ub.chk-discnt .
          
  find first   buf_chk-doc no-lock where buf_chk-doc.doc-code = p-doc-code .
  if buf_chk-doc.chk-type = integer({&income-corr})
  or buf_chk-doc.chk-type = integer({&expense-corr}) 
  then do :
    for each buf_chk-gds no-lock
       where buf_chk-gds.doc-code = p-doc-code :
      run wp-xmltagopen in this-procedure ( input 2, input "checkBody", input "" ).
      run wp-xmltagput  in this-procedure ( input 3, input "ID"       , input string( buf_chk-gds.doc-code    ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 3, input "TaxCode"  , input string( buf_chk-gds.b-code      ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 3, input "Sum"      , input string( buf_chk-gds.src-sum     ), input 0 ).   
      run wp-xmltagput  in this-procedure ( input 3, input "CSTCode"  , input string( buf_chk-gds.depart-type, "X(4)" ), input 1 ).
      run wp-xmltagput  in this-procedure ( input 3, input "CSTValue" , input string( buf_chk-gds.road-tax    ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 3, input "VATRate"  , input string( buf_chk-gds.vat-pc      ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 3, input "VAT"      , input string( buf_chk-gds.vat-sum-rubl), input 0 ). 
      run wp-xmltagclose in this-procedure ( input 2, input "checkBody" ).
    end. 
    for each buf_chk-pay no-lock
       where buf_chk-pay.doc-code = p-doc-code :    
      run wp-xmltagopen in this-procedure ( input 2, input "checkPays", input "" ).
      run wp-xmltagput in this-procedure ( input 3, input "ID"        , input string( buf_chk-pay.doc-code    ), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "payCode"   , input string( buf_chk-pay.pay-code    ), input 0 ).
      run wp-xmltagput in this-procedure ( input 3, input "totSum"    , input string( buf_chk-pay.tot-sum     ), input 0 ).
      run wp-xmltagclose in this-procedure ( input 2, input "checkPays" ).   
    end.     
  end.
  else do :         
  for each buf_chk-gds no-lock
     where buf_chk-gds.doc-code = p-doc-code : 
    find first buf_bar-code no-lock
         where buf_bar-code.b-code = buf_chk-gds.b-code no-error .
    if available buf_bar-code then do :
      find first buf_goods no-lock
           where buf_goods.gds-code = buf_bar-code.gds-code no-error .
      if available buf_goods then do :
        assign
                                        v-gds-code  = buf_goods.gds-code
                                        v-artic     = buf_goods.artic
                                        v-prod-type = buf_goods.prod-type
                                        v-prod-code = buf_goods.prod-code
                                        v-gds-name  = buf_goods.gds-name
        .
      end.
      else do:
        run wp-XMLWriteLog in this-procedure (
                                        input p-log-file-name
                                        , input 1
                                        , input substitute( "*** Не найден товар для баркода по чеку &1. Объект &2 &3. Баркод &4. Код товара &5."
                                        , buf_chk-gds.doc-code
                                        , temp-obj.obj-type
                                        , temp-obj.obj-code
                                        , buf_chk-gds.b-code
                                        , buf_bar-code.gds-code
                                        )
        ).
      end.
    end.
    else do:
      run wp-XMLWriteLog in this-procedure (
                                    input p-log-file-name
                                    , input 1
                                    , input substitute( "*** Не найден баркод для чека &1. Объект &2 &3. Баркод &4."
                                    , buf_chk-gds.doc-code
                                    , temp-obj.obj-type
                                    , temp-obj.obj-code
                                    , buf_chk-gds.b-code
                                    )
      ).
    end.
    
    run wp-xmltagopen in this-procedure ( input 2, input "checkBody", input "" ).
    run wp-xmltagput  in this-procedure ( input 3, input "ID"       , input string( buf_chk-gds.doc-code   ), input 0 ).
    run wp-xmltagput  in this-procedure ( input 3, input "bcode"    , input string( buf_chk-gds.b-code     ), input 0 ).
    run wp-xmltagput  in this-procedure ( input 3, input "gdsCode"  , input string( v-gds-code             ), input 0 ).
    run wp-xmltagput  in this-procedure ( input 3, input "artic"    , input string( v-artic                ), input 0 ).
    run wp-xmltagput  in this-procedure ( input 3, input "prodType" , input string( v-prod-type            ), input 0 ).
    run wp-xmltagput  in this-procedure ( input 3, input "prodCode" , input string( v-prod-code            ), input 0 ).
    run wp-xmltagput  in this-procedure ( input 3, input "gdsName"  , input string( v-gds-name             ), input 0 ).
    run wp-xmltagput  in this-procedure ( input 3, input "price"    , input string( buf_chk-gds.price-base ), input 0 ).
    run wp-xmltagput  in this-procedure ( input 3, input "qnty"     , input string( buf_chk-gds.doc-qnty   ), input 0 ).
    run wp-xmltagput  in this-procedure ( input 3, input "sum"      , input string( buf_chk-gds.sum-base   ), input 0 ).
    run wp-xmltagput  in this-procedure ( input 3, input "discnt"   , input string( buf_chk-gds.discnt     ), input 0 ).
    run wp-xmltagput  in this-procedure ( input 3, input "density"  , input string( buf_chk-gds.density    ), input 0 ).
    
    for each buf_chk-gds-pay no-lock
       where buf_chk-gds-pay.doc-code = buf_chk-gds.doc-code
         and buf_chk-gds-pay.line-num = buf_chk-gds.line-num :
      assign
                                    v-cpline       = buf_chk-gds-pay.cpline-num
                                    v-pay-code     = buf_chk-gds-pay.pay-code
                                    v-eff-doc-qnty = buf_chk-gds-pay.eff-doc-qnty
                                    v-pay-card     = buf_chk-gds-pay.pay-card
                                    v-price-base   = buf_chk-gds-pay.price-base 
                                    v-tot-r-b      = buf_chk-gds-pay.tot-r-b
                                    v-discnt       = buf_chk-gds-pay.discnt 
      .
      run wp-xmltagopen in this-procedure ( input 3, input "checkBodyPay", input "" ).
      run wp-xmltagput  in this-procedure ( input 4, input "cpLine"      , input string( v-cpline       ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 4, input "payCode"     , input string( v-pay-code     ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 4, input "totrb"       , input string( v-tot-r-b      ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 4, input "pricebase"   , input string( v-price-base   ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 4, input "numpaycard"  , input string( v-pay-card     ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 4, input "discnt"      , input string( v-discnt       ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 4, input "effdocqnty"  , input string( v-eff-doc-qnty ), input 0 ).
      run wp-xmltagclose in this-procedure ( input 3, input "checkBodyPay" ).
    end.
    
    run wp-xmltagclose in this-procedure ( input 2, input "checkBody" ).
    end. /* for each buf_chk-gds */
    
    
    for each buf_chk-pay no-lock
       where buf_chk-pay.doc-code = p-doc-code :
      find first buf_cash-pay no-lock
           where buf_cash-pay.cdpay-code = buf_chk-pay.pay-code
             AND buf_cash-pay.curr-code  = buf_chk-pay.curr-code
                 no-error .
      if available buf_cash-pay then do :
        v-pay-name = buf_cash-pay.obj-name .
        find first buf_currency no-lock
             where buf_currency.curr-code = buf_chk-pay.curr-code
                   no-error .
        if available buf_currency then do:
          v-curr-abbr = buf_currency.curr-abbr .
        end.
        else do:
          run wp-XMLWriteLog in this-procedure (
                          input p-log-file-name
                          , input 1
                          , input substitute( "*** Не найдена валюта для платежа по чеку &1. Объект &2 &3. Платеж &4. Код валюты &5."
                          , buf_chk-pay.doc-code
                          , temp-obj.obj-type
                          , temp-obj.obj-code
                          , buf_chk-pay.pay-code
                          , buf_chk-pay.curr-code
                          )
          ).
        end.
      end.
      else do:
        run wp-XMLWriteLog in this-procedure (
                      input p-log-file-name
                      , input 1
                      , input substitute( "*** Не найден платеж для чека &1. Объект &2 &3. Платеж &4. Код валюты &5"
                      , buf_chk-pay.doc-code
                      , temp-obj.obj-type
                      , temp-obj.obj-code
                      , buf_chk-pay.pay-code
                      , buf_chk-pay.curr-code
                      )
        ).
      end.
                  v-rrn = "".   
              for first buf_chk-pay-attr no-lock
                 where  buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code 
                    and (buf_chk-pay-attr.attr-code = "RRN" or buf_chk-pay-attr.attr-code = "RRN-VBRR")
                    and buf_chk-pay.line-num =  buf_chk-pay-attr.line-num :
                  v-rrn = buf_chk-pay-attr.attr-value.
              end.       
              if v-rrn = '' then for first buf_chk-pay-attr no-lock
                 where buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code 
                    and buf_chk-pay-attr.attr-code = "cpdoc"
                    and buf_chk-pay.line-num =  buf_chk-pay-attr.line-num :
                  v-rrn = buf_chk-pay-attr.attr-value.
              end.
       
      run wp-xmltagopen in this-procedure ( input 2, input "checkPays", input "" ).
      run wp-xmltagput  in this-procedure ( input 3, input "ID"       , input string( buf_chk-pay.doc-code  ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 3, input "payCode"  , input string( buf_chk-pay.pay-code  ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 3, input "currCode" , input string( buf_chk-pay.curr-code ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 3, input "payName"  , input string( v-pay-name            ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 3, input "currAbbr" , input string( v-curr-abbr           ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 3, input "totSum"   , input string( buf_chk-pay.tot-sum   ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 3, input "totBase"  , input string( buf_chk-pay.tot-base  ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 3, input "totRubl"  , input string( buf_chk-pay.tot-rubl  ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 3, input "payCard"  , input string( buf_chk-pay.pay-card  ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 3, input "cashRate" , input string( buf_chk-pay.cash-rate ), input 0 ).
      run wp-xmltagput  in this-procedure ( input 3, input "OperationCode", input string( v-rrn             ), input 0 ).                           
      run wp-xmltagclose in this-procedure ( input 2, input "checkPays" ).
    end . /* end_of for_each buf_chk-pay */
  
      
    if v-inf-bonus then do: /* v-inf-bonus - входной параметр модуля */ 
      for each chk-discnt no-lock
         where chk-discnt.doc-code    = p-doc-code
           and chk-discnt.record-type = 4
           /*and chk-discnt.discnt-value-abs <> 0*/:
        bonus-relation = ''.
        for first chk-discnt-attr no-lock
            where chk-discnt-attr.attr-code = "RRN-bonus"
              and chk-discnt-attr.line-num  = chk-discnt.line-num
              and chk-discnt-attr.doc-code  = chk-discnt.doc-code
              and chk-discnt-attr.discnt-id = chk-discnt.discnt-id 
              and chk-discnt-attr.object-line-num = chk-discnt.object-line-num :
          bonus-relation = chk-discnt-attr.attr-value .
        end. 
          if chk-discnt.discnt-value-abs =  0  and bonus-relation = '' then next.            
        run wp-xmltagopen in this-procedure ( input 2, input "checkBonus", input "" ).
        run wp-xmltagput  in this-procedure ( input 3, input "ID"           , input p-doc-code, input 0 ).
        run wp-xmltagput  in this-procedure ( input 3, input "SrcCardNum"   , input chk-discnt.src-d-card , input 0 ).
        run wp-xmltagput  in this-procedure ( input 3, input "LineNum"      , input string(chk-discnt.line-num    ), input 0 ).
        run wp-xmltagput  in this-procedure ( input 3, input "BonusAmount"  , input string(chk-discnt.discnt-value-abs), input 0 ).
        run wp-xmltagput  in this-procedure ( input 3, input "BonusCardNum" , input p-d-card , input 0 ).
        run wp-xmltagput  in this-procedure ( input 3, input "BonusMode"    , input string(chk-discnt.line-type) , input 0 ).
        run wp-xmltagput  in this-procedure ( input 3, input "BonusOperationCode", input bonus-relation, input 1 ).
        run wp-xmltagclose in this-procedure ( input 2, input "checkBonus" ).            
      end. /* end_of for_each chk-discnt */
      for each buf_chk-discnt no-lock
         where buf_chk-discnt.doc-code = p-doc-code
           and buf_chk-discnt.record-type = 0 :
        run wp-xmltagopen in this-procedure ( input 2, input "checkDiscount"   , input "" ).
        run wp-xmltagput in this-procedure ( input 3, input "lineNum"          , input string( buf_chk-discnt.line-num )         , input 1 ).
        run wp-xmltagput in this-procedure ( input 3, input "discntVName"      , input {&discnt-v-name}                          , input 1 ).
        run wp-xmltagput in this-procedure ( input 3, input "objectLineNum"    , input string( buf_chk-discnt.object-line-num )  , input 1 ).
        run wp-xmltagput in this-procedure ( input 3, input "discntTargetName" , input {&discnt-target-name}                     , input 1 ).
        run wp-xmltagput in this-procedure ( input 3, input "discntTypeName"   , input {&discnt-type-name}                       , input 1 ).
        run wp-xmltagput in this-procedure ( input 3, input "discntValueAbs"   , input string( buf_chk-discnt.discnt-value-abs ) , input 1 ).
        run wp-xmltagput in this-procedure ( input 3, input "discntValuePcnt"  , input string( buf_chk-discnt.discnt-value-pcnt ), input 1 ).
        run wp-xmltagput in this-procedure ( input 3, input "srcDCard"         , input string( buf_chk-discnt.src-d-card )       , input 2 ).
        /* 11/XII-2017 buf_dis-card никогда не ищется, запись всегда будет невалидной */
        run wp-xmltagput in this-procedure ( input 3, input "discntKategory"   , input string(
           if buf_chk-discnt.src-d-card <> ''
          and buf_chk-discnt.src-d-card <> ?
          and available buf_dis-card
          and buf_dis-card.d-card = buf_chk-discnt.src-d-card
          and buf_chk-discnt.kateg = ?
           then buf_dis-card.category
           else buf_chk-discnt.kateg )        , input 2 ).
        run wp-xmltagput in this-procedure ( input 3, input "discntType", input string(buf_chk-discnt.discnt-type)  , input 1 ).
        run wp-xmltagclose in this-procedure ( input 2, input "checkDiscount" ).
      end. /* for each buf_chk-dicsnt no-lock  */
      /*Добавляем в выгрузку скидок еще и скидки, которыми выравниваются погрешности*/
      for each buf_chk-discnt no-lock
         where buf_chk-discnt.doc-code = p-doc-code
           and buf_chk-discnt.record-type = 2 :
        run wp-xmltagopen in this-procedure ( input 2, input "checkDiscount"   , input "" ).
        run wp-xmltagput in this-procedure ( input 3, input "lineNum"          , input string( buf_chk-discnt.line-num )         , input 1 ).
        run wp-xmltagput in this-procedure ( input 3, input "discntVName"      , input {&discnt-v-name}                          , input 1 ).
        run wp-xmltagput in this-procedure ( input 3, input "objectLineNum"    , input string( buf_chk-discnt.object-line-num )  , input 1 ).
        run wp-xmltagput in this-procedure ( input 3, input "discntTargetName" , input {&discnt-target-name}                     , input 1 ).
        run wp-xmltagput in this-procedure ( input 3, input "discntTypeName"   , input {&discnt-type-name}                       , input 1 ).
        run wp-xmltagput in this-procedure ( input 3, input "discntValueAbs"   , input string( buf_chk-discnt.discnt-value-abs ) , input 1 ).
        run wp-xmltagput in this-procedure ( input 3, input "discntValuePcnt"  , input string( buf_chk-discnt.discnt-value-pcnt ), input 1 ).
        run wp-xmltagput in this-procedure ( input 3, input "srcDCard"         , input string( buf_chk-discnt.src-d-card )       , input 2 ).
        run wp-xmltagput in this-procedure ( input 3, input "discntKategory"   , input string(
          if buf_chk-discnt.src-d-card <> ''
         and buf_chk-discnt.src-d-card <> ?
         and available buf_dis-card
         and buf_dis-card.d-card  = buf_chk-discnt.src-d-card
         and buf_chk-discnt.kateg = ?
            then buf_dis-card.category
            else buf_chk-discnt.kateg )        , input 2 ).
        run wp-xmltagput in this-procedure ( input 3, input "discntType"        , input string(buf_chk-discnt.discnt-type)  , input 1 ).          
        run wp-xmltagclose in this-procedure ( input 2, input "checkDiscount" ).
      end. /* for each buf_chk-dicsnt no-lock  */
    end. /* end_of if_v-inf-bonus */
  end.  
end.

end procedure. /* export-checks-by-object */


procedure check-gds-type private :
/* проверим тип товара */
define input  parameter p-gds-type as character no-undo .
define input  parameter p-doc-code as character no-undo .
define output parameter p-is-ok    as logical   no-undo .

define variable v-is-found        as logical   no-undo .
define variable v-is-petrol       as logical   no-undo.
define variable v-is-pieces       as logical   no-undo.
define buffer buf_chk-gds  for ub.chk-gds .
define buffer buf_bar-code for ub.bar-code .
define buffer buf_goods    for ub.goods .


  v-is-found = false .
  
  /*переберем переберем товары по чеку*/
  for each buf_chk-gds no-lock
     where buf_chk-gds.doc-code = p-doc-code :
    /*найдем код товара по баркоду*/
    find first buf_bar-code no-lock
         where buf_bar-code.b-code = buf_chk-gds.b-code no-error .
    if available buf_bar-code then do :
      /*найдем товар по коду*/
      find first buf_goods no-lock
           where buf_goods.gds-code = buf_bar-code.gds-code no-error .
      if available buf_goods then do:
        /*это топливо?*/
        { str/is-petrl.i buf_goods.artic buf_goods.prod-type buf_goods.prod-code v-is-petrol v-is-pieces no-error }
        if error-status:error then do:
          run wp-XMLWriteLog in this-procedure (
            input v-log-file-name
            , input 1
            , input substitute( "*** Ошибка проверки топливного признака. Процедура: &1 (v.&2 &3). Артикул товара &4, производитель &5 &6. Ошибка &7. &8"
            , vss-workfile
            , vss-revision
            , vss-description
            , buf_goods.artic
            , buf_goods.prod-type
            , buf_goods.prod-code            
            , return-value
            , error-status:get-message(1)
            )
          ) .
          next .
        end .
        /*если фильтр по топливу, а товар не топливо, то чек пропускаем*/
        if p-gds-type = "fuel"  and not v-is-petrol then next.
        /*если фильтр по НЕ топливу, а товар топливо, то чек пропускаем*/
        if p-gds-type = "other" and     v-is-petrol then next.
        
        v-is-found = true .
        leave .
      end .
    end .
  end . /*for each buf_chk-gds*/
 
  p-is-ok = v-is-found .          
end procedure . /* end_of check-gds-type */    


procedure ftp-send :
    define input parameter p-xml-file-name    as character no-undo.
    
    define variable v-parameter               as character no-undo.
    define variable p-directory               as char      no-undo.
    do
        on error undo, return error
        :
        p-xml-file-name =     replace(p-xml-file-name, "/", "\" ) + "xml".
        /* v-log-file-name =  replace(v-log-file-name, "/", "\" ) .*/
        /*Перед передачей параметра чистим ip-адрес от лишних символов*/
        p-directory = trim(trim(replace(v-ftp-adress,'ftp:',""),{&slash-char}),{&back-slash-char}).
        /*Передача параметров*/
        v-parameter = p-directory + {&delim-par} +
            v-login + {&delim-par} +
            v-password + {&delim-par} +
            string({&INTERNET_FLAG_PASSIVE}) + {&delim-par} + ''
            +
            p-xml-file-name  + {&delim-par} +
            /*p-ftp-target-dir + {&slash-char} +*/ p-xml-file-name + {&delim-par} +
            string(no) + {&delim-par} +  log-file-name .
        run gbl/ftp-put.p   ( input this-procedure:handle
            ,input this-procedure:handle
            , input p-log-handle
            , input v-parameter
            ) no-error.


    end. /* do on error */
end procedure. /* ftp-send */
        

procedure bge-xml-write-header-check:
do
on error undo, return error
:
define input parameter p-doc-name       as character        no-undo.
define input parameter p-version        as character        no-undo.
define input parameter p-db-num         as integer          no-undo.
define input parameter p-date-from      as date             no-undo.
define input parameter p-shift-num-from as integer          no-undo.
define input parameter p-date-to        as date             no-undo.
define input parameter p-shift-num-to   as integer          no-undo.
define input parameter p-obj-list       as character        no-undo.
define input parameter v-code_pool      as char             no-undo.
define input parameter p-dc-list        as char             no-undo.
define input parameter p-bonus          as logical          no-undo.
define input parameter p-doc-type-list  as character        no-undo.
define input parameter p-pay-code       as logical          no-undo.
define input parameter p-cst            as logical          no-undo.
define input parameter p-parts          as logical          no-undo.
define input parameter p-chk-pay-code   as logical          no-undo.
define input parameter p-pay-desk       as logical          no-undo.
define input parameter p-pay-desk-cards as logical          no-undo.
define input parameter p-deleted        as logical          no-undo.
define input parameter p-opened-docs    as logical          no-undo.

define variable v-out-string            as character        no-undo.

p-dc-list = right-trim (p-dc-list, ",").

assign
    v-out-string = substitute( "&1&2&3"
                        , "<?xml version='1.0' encoding='windows-1251'?>":U
                        , {&new-line}
                        , "<IBS_Trade_House>":U )
.
/*  {&new-line} + "<?xml-stylesheet type='text/xsl' href='{&OutFileName}.xsl'?>" */

put stream stmXMLOut unformatted
    v-out-string
.
run wp-XMLTagOpen(1, "header","").
if v-bge-xml-bgeflold = "oracle":u
then do:
  run wp-XMLTagOpen in this-procedure  ( 2, "delivery", "").
  run wp-XMLTagput in this-procedure ( 3, "message","", 1).
  run wp-XMLTagput in this-procedure ( 3, "from","IBS Trade House", 1).
  run wp-XMLTagput in this-procedure ( 3, "to","Oracle Retail", 1).
  run wp-XMLTagClose in this-procedure ( 2, "delivery"    ).
end.
run wp-XMLTagOpen( 2, "manifest", "").
run wp-XMLTagOpen( 3, "document", "").
run wp-XMLTagput( 4, "name", p-doc-name, 0).
run wp-XMLTagput( 4, "description", "", 0).
run wp-XMLTagput( 4, "version", p-version, 0).
run wp-XMLTagclose( 3, "document" ).
run wp-XMLTagclose( 2, "manifest" ).
run wp-XMLTagclose( 1, "header" ).
run wp-XMLTagOpen(1, "options","").
run wp-XMLTagput( 2, "exportDate",      string( today,              "99/99/9999" ), 1).
run wp-XMLTagput( 2, "exportDateXml",   bge-xml-date( today )                     , 1).
run wp-XMLTagput( 2, "exportTime",      string( time,               "HH:MM:SS"   ), 0).
run wp-XMLTagput( 2, "baseNum",         string( p-db-num                         ), 0).
run wp-XMLTagput( 2, "dateFrom",        string( p-date-from,        "99/99/9999" ), 1).
run wp-XMLTagput( 2, "dateFromXml",     bge-xml-date( p-date-from )               , 1).
run wp-XMLTagput( 2, "shiftNumFrom",    string( p-shift-num-from                 ), 2).
run wp-XMLTagput( 2, "dateTo",          string( p-date-to,          "99/99/9999" ), 0).
run wp-XMLTagput( 2, "dateToXml",       bge-xml-date( p-date-to )                 , 0).
run wp-XMLTagput( 2, "shiftNumTo",      string( p-shift-num-to                   ), 2).
run wp-XMLTagput( 2, "objList",                 p-obj-list                        , 0).
run wp-XMLTagput( 2, "DataSetName",                 v-code_pool                       , 0).
run wp-XMLTagput( 2, "DCList",                 p-dc-list                        , 0).
run wp-XMLTagput( 2, "chkBonus",              string(p-bonus)                        , 0).
run wp-XMLTagput( 2, "docTypeList",             p-doc-type-list                   , 0).
run wp-XMLTagput( 2, "payCode",         string( p-pay-code                       ), 0).
run wp-XMLTagput( 2, "cst",             string( p-cst                            ), 0).
run wp-XMLTagput( 2, "parts",           string( p-parts                          ), 0).
run wp-XMLTagput( 2, "chkPayCode",      string( p-chk-pay-code                   ), 0).
run wp-XMLTagput( 2, "chkPayDesk",      string( p-pay-desk                       ), 0).
run wp-XMLTagput( 2, "chkPayDeskCards", string( p-pay-desk-cards                 ), 0).
run wp-XMLTagput( 2, "deletedDocs",     string( p-deleted                        ), 0).
run wp-XMLTagput( 2, "openedDocs",      string( p-opened-docs                    ), 0).
run wp-XMLTagClose(1, "options").
run wp-XMLTagOpen( 1, "body", "" ).

end.
end procedure.