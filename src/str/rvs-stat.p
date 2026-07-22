block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Переход по статусам в документах сверки

Автор: Уханов Дмитрий Юрьевич
Дата создания: 12/03/07
Author: Dmitry Ukhanov
Creation date: 12/03/07

Автор1: Суслов Алексей Юрьевич
Дата создания1: 03/27/06

*/

/* ***************************  Definitions  ************************** */
define input parameter parparentproc   as widget-handle no-undo.
define input parameter parrecid        as recid         no-undo.
define input parameter paraction       as character     no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Переход по статусам в документах сверки":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ str/lib-rvs.i  }
{ str/placelib.i }
{ str/autorvs.i  }
{ gbl/getsect.i def }
{ ref/gds-attr.i }
{ str/is-sug.i   }

tr:
do transaction
    on error  undo tr, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message ( error-status :num-messages ) )
    on stop   undo tr, return error substitute( "&1. stop", vss-workfile )
    on endkey undo tr, return error substitute( "&1. endkey", vss-workfile )
    :
    define variable vardata-type as character no-undo.
    define variable was_found    as logical   no-undo initial no.
    define variable v-auto       as logical   no-undo.
    define buffer buf_rvs-doc  for ub.rvs-doc .
    define buffer buf_rvs-line for ub.rvs-line .
    define buffer buf_doc-pl   for ub.doc-pl .
    define buffer buf_pl-gds   for ub.pl-gds .
    define buffer buf_place    for ub.place .
    define buffer last-rvs-doc for ub.rvs-doc . 
    define buffer last-rvs-line for ub.rvs-line .
    define buffer buf_doc-attr for ub.doc-attr .

    define variable v-cardif        as integer   no-undo .
    define variable v-abs-critdif   as decimal   no-undo .
    define variable v-dif-res-count as integer   no-undo .
    define variable v-dif-res       as character no-undo .
    define variable v-ok            as logical   no-undo .
    
    define variable v-first-volue      as decimal  no-undo .
    define variable v-first-density    as decimal  no-undo .
    define variable v-first-temp       as decimal  no-undo .
    define variable v-first-water      as decimal  no-undo .
    
    
    find first buf_rvs-doc exclusive-lock
        where recid(buf_rvs-doc) = parrecid
        .
  
    if autorvs(recid(buf_rvs-doc)) = "А"
    then do:
      v-auto = yes.
    end.
      
    { gbl/getsect.i run  buf_rvs-doc.obj-type  buf_rvs-doc.obj-code  {&attr-petrol} }
    
    for each thbjattr_thbj-attr :    
      if thbjattr_thbj-attr.prop-code = {&attr-petrol_CriticalDif} then assign v-cardif = integer( thbjattr_thbj-attr.property-value-character) .
    end.
                
    if buf_rvs-doc.rvs-type <> {&rvs-shift}
    and buf_rvs-doc.rvs-type <> {&rvs-control}
    and buf_rvs-doc.rvs-type <> {&rvs-before-doc}
    and buf_rvs-doc.rvs-type <> {&rvs-after-doc}
    and buf_rvs-doc.rvs-type <> {&test-asi}
    then do:
      undo tr, return error substitute("Смена статуса документа сверки. Неизвестный тип документа сверки &1.", buf_rvs-doc.rvs-type).
    end.
    
    if buf_rvs-doc.rvs-type = {&test-asi}
    then do :
      for each buf_rvs-line no-lock
          where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
          on error undo, return error return-value
      :
        find first rvs-line-attr no-lock
             where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
               and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
               and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
               and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
               and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
               and rvs-line-attr.attr-code = "test-asi-diff" no-error.
        if not available rvs-line-attr
        or (available rvs-line-attr and  (rvs-line-attr.attr-value = "" or decimal(rvs-line-attr.attr-value) = ?)) 
        then do :
          undo tr, return error substitute("Закрытие невозможно. Не выполнен расчёт проверки по резервуару &1.", buf_rvs-line.pl-code).
        end.
      end .
      assign
        buf_rvs-doc.status_ = {&fact}
      .
      return .
    end .

    /*Поиск последней сменной сверки*/
    for last last-rvs-doc no-lock
    where last-rvs-doc.obj-type   = buf_rvs-doc.obj-type
      and last-rvs-doc.obj-code   = buf_rvs-doc.obj-code
      and last-rvs-doc.status_    = {&fact}
      and last-rvs-doc.rvs-type   = {&rvs-shift},
      each last-rvs-line  exclusive-lock where last-rvs-line.rvs-code = last-rvs-doc.rvs-code
    :
    
    end.  

    case paraction:
      when "open":U
      then do:
        case buf_rvs-doc.status_:
          when {&permitted}
          then do:
            assign
              buf_rvs-doc.status_ = {&g___new}
            .
            /* убираем расчетно-книжные количества */
            for each buf_rvs-line exclusive-lock
                where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                on error undo, return error return-value
            :
              assign
                buf_rvs-line.system-qnty          = 0.0
                buf_rvs-line.system-cli-qnty      = 0.0
                buf_rvs-line.orig-system-qnty     = buf_rvs-line.system-qnty
                buf_rvs-line.orig-system-cli-qnty = buf_rvs-line.system-cli-qnty
              .
              find first rvs-line-attr exclusive-lock
                  where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                  and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                  and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                  and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                  and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                  and rvs-line-attr.attr-code = "CriticalDif" no-error.
              if available rvs-line-attr then 
              do :
                delete rvs-line-attr .
              end.
            end.
            release rvs-line-attr no-error .
          end.
          otherwise 
          do:
            undo tr, return error "Возможно открытие документа только в статусе: " + {&permitted} + " .".
          end.
        end case.
      end.
      when "close":U
      then do:
        case buf_rvs-doc.status_:
          when {&g___new}
          then do:
            if buf_rvs-doc.rvs-type <> {&rvs-after-doc}
            then do:
              /* в сверках по документу ставим бликировку на сверке "перед", а снимаем блокировку на сверке "после" */
              run trg/lock-rvs.p
                  ( input buf_rvs-doc.rvs-code
                  ,input "assign-rvs-on=true":U
                  ,input "":U
                  ,input false
                  ) no-error.
              if error-status :error then 
              do:
                undo tr, return error substitute( "Ошибка при блокировке по документу сверки &2&1&3&1&4", {&new-line}, buf_rvs-doc.rvs-code, error-status :get-message(1), return-value ) .
              end.
            end.
            /*устанавливаем расчетно-книжные количества*/
            for each buf_rvs-line exclusive-lock
                where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                on error undo, return error return-value
            :
              if  v-auto <> yes
              then do: 
                find first buf_pl-gds exclusive-lock
                    where buf_pl-gds.obj-type = buf_rvs-doc.obj-type
                    and buf_pl-gds.obj-code = buf_rvs-doc.obj-code
                    and buf_pl-gds.pl-code  = buf_rvs-line.pl-code
                    and buf_pl-gds.gds-code = buf_rvs-line.gds-code
                .
              end.
              else do: 
                find first buf_pl-gds no-lock
                    where buf_pl-gds.obj-type = buf_rvs-doc.obj-type
                    and buf_pl-gds.obj-code = buf_rvs-doc.obj-code
                    and buf_pl-gds.pl-code  = buf_rvs-line.pl-code
                    and buf_pl-gds.gds-code = buf_rvs-line.gds-code
                .
              end.
  
              find first buf_place no-lock
                  where buf_place.obj-type = buf_rvs-doc.obj-type
                  and buf_place.obj-code = buf_rvs-doc.obj-code
                  and buf_place.pl-code  = buf_rvs-line.pl-code
              .
              assign
                buf_rvs-line.tolerance            = buf_pl-gds.tolerance
                buf_rvs-line.add-qnty             = buf_place.add-qnty
                buf_rvs-line.state-add-qnty       = buf_place.add-qnty
                buf_rvs-line.system-qnty          = buf_pl-gds.fact-qnty
                buf_rvs-line.system-cli-qnty      = buf_pl-gds.cli-fact-qnty
                buf_rvs-line.orig-system-qnty     = buf_rvs-line.system-qnty
                buf_rvs-line.orig-system-cli-qnty = buf_rvs-line.system-cli-qnty
              .
 
              if  v-cardif > 0 and abs(  buf_rvs-line.system-cli-qnty - buf_rvs-line.state-measure-cli-qnty ) > ( buf_rvs-line.state-measure-cli-qnty * v-cardif / 100 )
              then do: 
                v-abs-critdif =  abs( buf_rvs-line.system-cli-qnty - buf_rvs-line.state-measure-cli-qnty ) -  ( buf_rvs-line.state-measure-cli-qnty * v-cardif / 100 ).
      
                if v-abs-critdif <> 0
                then do:               
                  find first rvs-line-attr exclusive-lock
                        where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                        and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                        and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                        and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                        and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                        and rvs-line-attr.attr-code = "CriticalDif" no-error.
                  if available rvs-line-attr then 
                  do :
                    rvs-line-attr.attr-value = ( string  (abs (  v-abs-critdif)) )  .
                  end.
                  else do :
                    create rvs-line-attr.
                    assign
                      rvs-line-attr.obj-code   = buf_rvs-line.obj-code
                      rvs-line-attr.obj-type   = buf_rvs-line.obj-type
                      rvs-line-attr.gds-code   = buf_rvs-line.gds-code
                      rvs-line-attr.pl-code    = buf_rvs-line.pl-code
                      rvs-line-attr.rvs-code   = buf_rvs-line.rvs-code
                      rvs-line-attr.attr-code  = "CriticalDif"
                      rvs-line-attr.attr-value = string ( v-abs-critdif )
                    .
                  end.
                  release rvs-line-attr no-error .
                end.
              end.  
            end.
            { str/rvsclchd.i
              recid(buf_rvs-doc)
              no
              no-error
            }
            if error-status :error then 
            do:
              undo tr, return error "Ошибка при пересчете документа.".
            end.
            assign
              buf_rvs-doc.status_ = {&permitted}
            .
          end.
          when {&permitted}
          then do:
            find first buf_doc-attr no-lock where buf_doc-attr.doc-code = buf_rvs-doc.rvs-code
                                              and buf_doc-attr.attr-code = "rvs-auto"
                                              and buf_doc-attr.attr-value = "Yes"
                                              no-error .
            if not available buf_doc-attr
            then do :
              for each buf_rvs-line no-lock
                  where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                  on error undo, return error return-value
              :
                if is-sug(buf_rvs-line.gds-code)
                then do :
                  if buf_rvs-line.state-temperature = ?
                  then do :
                    undo tr, return error substitute( "Не заполнено обязательное поле «Температура средняя». (СУГ &1, резервуар &2)", buf_rvs-line.gds-code, buf_rvs-line.pl-code).
                  end .
                end .
              end .
            end .
            case buf_rvs-doc.rvs-type :
              when {&rvs-shift}
              then do:
                { str/rvschtrn.i
                  buf_rvs-doc.obj-type
                  buf_rvs-doc.obj-code
                  buf_rvs-doc.shift-date
                  buf_rvs-doc.shift-num
                  buf_rvs-doc.rvs-code
                  no
                  no
                  was_found
                  no-error
                }
                if error-status :error then 
                do:
                  undo tr, return error "Ошибка поиска незакрытых документов (rvschtrn): " + return-value.
                end.
                if was_found = yes then 
                do:
                  undo tr, return error "Невозможно закрыть сверку. " + return-value.
                end.
                /* Проверка переполнения счетчика ТРК */
                run str/chkelcnt.p
                    ( input parparentproc
                    ,input rowid(buf_rvs-doc)
                    ,input no
                    ) no-error .
                if error-status :error then 
                do:
                  undo tr, return error "Невозможно закрыть сверку. " + return-value.
                end.
              end.
              when {&rvs-after-doc}
              then do:
                /*устанавливаем расчетно-книжные количества, т.к. после документа они меняются.*/
                for each buf_rvs-line exclusive-lock
                    where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                    on error undo, return error return-value
                :
                  find first buf_doc-pl exclusive-lock
                      where buf_doc-pl.obj-type = buf_rvs-doc.obj-type
                      and buf_doc-pl.obj-code = buf_rvs-doc.obj-code
                      and buf_doc-pl.pl-code  = buf_rvs-line.pl-code
                      and buf_doc-pl.out-code = buf_rvs-doc.out-code
                      and buf_doc-pl.gds-code = buf_rvs-line.gds-code
                  no-error .
                  if available buf_doc-pl
                  then do :
                  assign
                    buf_rvs-line.system-qnty          = buf_rvs-line.system-qnty          + buf_doc-pl.fact-qnty
                    buf_rvs-line.system-cli-qnty      = buf_rvs-line.system-cli-qnty      + buf_doc-pl.cli-fact-qnty
                    buf_rvs-line.orig-system-qnty     = buf_rvs-line.orig-system-qnty     + buf_doc-pl.fact-qnty
                    buf_rvs-line.orig-system-cli-qnty = buf_rvs-line.orig-system-cli-qnty + buf_doc-pl.cli-fact-qnty
                  .
                  end .
                end.
              end.
            end case.
            { str/rvsclchd.i
              recid(buf_rvs-doc)
              no
              no-error
            }
            if error-status :error then 
            do:
              undo tr, return error "Ошибка при пересчете документа.".
            end.
            assign
              buf_rvs-doc.status_ = {&fact}
            .
            /*Допустимые значения*/    
            run rep/r-otkl-total.p ( input buf_rvs-doc.rvs-code
              ,input buf_rvs-doc.rvs-type
              ,input buf_rvs-doc.obj-code
              ,input buf_rvs-doc.obj-type
              ,input buf_rvs-doc.shift-date
              ,input buf_rvs-doc.shift-num
              
              ) .
            if error-status:error then 
            do:
/*            return error substitute("!!!Ошибка при расчете&4&1 &2 &3&4&5&4&6"*/
/*              ,vss-workfile                                                  */
/*              ,vss-revision                                                  */
/*              ,vss-description                                               */
/*              ,{&new-line}                                                   */
/*              , error-status:get-message(1)                                  */
/*              , return-value ).                                              */
            end.
            for each buf_rvs-line exclusive-lock
                where buf_rvs-line.rvs-code = buf_rvs-doc.rvs-code
                on error undo, return error return-value
            :   
              if  v-cardif > 0 and abs( buf_rvs-line.system-cli-qnty  - buf_rvs-line.state-measure-cli-qnty ) > ( buf_rvs-line.state-measure-cli-qnty * v-cardif / 100 )
              then do: 
                v-abs-critdif = abs  (  buf_rvs-line.system-cli-qnty  - buf_rvs-line.state-measure-cli-qnty ) -  abs ( buf_rvs-line.state-measure-cli-qnty * v-cardif / 100 ).
      
                if v-abs-critdif <> 0
                then do:               
                  find first rvs-line-attr exclusive-lock
                      where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                      and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                      and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                      and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                      and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                      and rvs-line-attr.attr-code = "CriticalDif" no-error.
                  if available rvs-line-attr
                  then do :
                    rvs-line-attr.attr-value = ( string  (abs (  v-abs-critdif)) )  .
                  end.
                  else do :
                    create rvs-line-attr.
                    assign
                      rvs-line-attr.obj-code   = buf_rvs-line.obj-code
                      rvs-line-attr.obj-type   = buf_rvs-line.obj-type
                      rvs-line-attr.gds-code   = buf_rvs-line.gds-code
                      rvs-line-attr.pl-code    = buf_rvs-line.pl-code
                      rvs-line-attr.rvs-code   = buf_rvs-line.rvs-code
                      rvs-line-attr.attr-code  = "CriticalDif"
                      rvs-line-attr.attr-value = string ( v-abs-critdif )
                    .
                  end.
                  release rvs-line-attr no-error .
                end.
              end.  
              find first rvs-line-attr no-lock
                    where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                    and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                    and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                    and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                    and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                    and rvs-line-attr.attr-code = "hand-save" no-error.
              if available rvs-line-attr
              and logical(rvs-line-attr.attr-value) = yes
              then do :
                run placelib_write-attr  (input {&place-need-RVD-rvs}
                                          ,input buf_rvs-line.obj-code
                                          ,input buf_rvs-line.obj-type
                                          ,input buf_rvs-line.pl-code
                                          ,input string(no)
                                          ,output v-ok      ) no-error.
              end .
              release rvs-line-attr no-error .
              
              for first rvs-line-attr no-lock
                  where rvs-line-attr.obj-code  = buf_rvs-line.obj-code
                    and rvs-line-attr.obj-type  = buf_rvs-line.obj-type
                    and rvs-line-attr.gds-code  = buf_rvs-line.gds-code
                    and rvs-line-attr.pl-code   = buf_rvs-line.pl-code
                    and rvs-line-attr.rvs-code  = buf_rvs-line.rvs-code
                    and rvs-line-attr.attr-code = "rvd-reason"
              :
                run trg/userlog.p (
                      input 'rvd-reasons'
                    , input rvs-line-attr.attr-value
                    , input ?
                    , input ?
                    , input ""
                    ) no-error.
                if error-status :error
                then do:
                  message return-value + error-status:get-message(1) view-as alert-box title "Ошибка записи истории действий пользователя".
                end.
              end . 
            end.
            if buf_rvs-doc.rvs-type =  {&rvs-shift}
            then do: 
              v-dif-res-count = 0 .
              v-dif-res = "" .
              for each rvs-line-attr no-lock
                  where rvs-line-attr.obj-code  = buf_rvs-doc.obj-code
                  and rvs-line-attr.obj-type  = buf_rvs-doc.obj-type
                  and rvs-line-attr.rvs-code  = buf_rvs-doc.rvs-code
                  and rvs-line-attr.attr-code = "CriticalDif"
              : 
                v-dif-res-count = v-dif-res-count + 1 .
                v-dif-res = v-dif-res + (if v-dif-res <> "" then ", " else "") + string(rvs-line-attr.pl-code) .   
              end.
              if v-dif-res-count = 1
              then do :
                message "В сменной сверке есть расхождения массы в резервуаре"  v-dif-res  view-as alert-box.
              end.
              if v-dif-res-count > 1
              then do :
                message "В сменной сверке есть расхождения массы в резервуарах"  v-dif-res  view-as alert-box.
              end.
            end.
          end.
          when {&fact}
          then do:
             undo tr, return error "Невозможно закрыть документ. Документ в статусе " + {&fact} + " .".
          end.
          otherwise 
          do:
            undo tr, return error substitute( "Закрытие документа сверки. Неизвестный статус документа сверки &1", buf_rvs-doc.status_ ).
          end.
        end case.
        find first ub.user-account no-lock where ub.user-account.user-id = ibs.th.gbl.gbl-var:g#userid .
        if ub.user-account.psn-code <> 0 and ub.user-account.psn-code <> ?
        then do:
          if buf_rvs-doc.agnt = ?
          then do:
            buf_rvs-doc.agnt = ub.user-account.psn-code.
          end.
          if buf_rvs-doc.wrkr = ?
          then do:
            buf_rvs-doc.wrkr = ub.user-account.psn-code.
          end.
          buf_rvs-doc.boss = ub.user-account.psn-code.
        end.
        release ub.user-account no-error .
      end.
      when "froze":U
      then do:
        case buf_rvs-doc.status_:
          when {&permitted}
          then do:
            assign
              buf_rvs-doc.status_ = {&rvs-froze}
            .
          end.
          otherwise 
          do:
            undo tr, return error substitute( "Перевести в статус &1 возможно только из статуса &2", {&rvs-froze}, {&permitted}).
          end.
        end case.
      end.
      when "unfroze":U
      then do:
        case buf_rvs-doc.status_:
          when {&rvs-froze}
          then do:
            assign
              buf_rvs-doc.status_ = {&permitted}
            .
          end.
          otherwise 
          do:
            undo tr, return error substitute( "Перевести в статус &1 возможно только из статуса &2", {&permitted}, {&rvs-froze}).
          end.
        end case.
      end.
      otherwise 
      do:
        undo tr, return error "Неверный статус перехода документа сверки " + paraction + " .".
      end.
    end case.
  
    run trg/userlog.p (
        input {&nwsdochs_action_update}
        , input {&table_rvs-doc}
        , input ( buffer buf_rvs-doc :handle )
        , input ?
        , input ""
        ) no-error.
    if error-status :error
    then do:
      undo, return error substitute( "&2&1Ошибка при записи истории пользователя&1&3&1&4"
          , {&new-line}
          , vss-workfile
          , return-value
          , error-status :get-message ( 1 ) ).
    end.
end. /* transaction */