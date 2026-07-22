 
 /*------------------------------------------------------------------------
    File        : is_PM
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : SSlivenko
    Created     : Wed Nov 18 18:16:51 AST 2020
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.

class ibs.th.bge.is_PM.is_PM: 
  
  { cmp/str-glbl.i class }
  { str/lib-trn.i class }
  { str/trdcalib.i class }
  
  define temp-table tt-result no-undo
    field gds-code            as integer
    field gds-name            as character
    field wght-fact-start     as decimal
    field wght-fact-end       as decimal
    field wght-doc-start      as decimal
    field wght-doc-end        as decimal
    field delivery            as decimal
    field delivery-own-pnpo   as decimal
    field delivery-other-pnpo as decimal
    field delivery-other      as decimal
    field direct-delivery     as decimal
    field fuel-in-transit     as decimal
    field wght-sale           as decimal
    field wght-wholesale      as decimal
    field loss-own-needs      as decimal
    field Delivery-ned-izl    as decimal
    field wght-other          as decimal
    field othermoves          as decimal
    field change-place        as logical
  index pi as primary gds-code
  .
  
  define temp-table tt-gds no-undo
    field gds-code    as integer
  index pi as primary gds-code
  .
  
  define temp-table tt-place no-undo
    field pl-code             as integer
    field pl-name             as character
    field gds-code            as integer
    field is-meas             as logical
    field is-calc             as logical
    field rvd-level           as logical
    field is-income           as logical
    field income-date         as date
    field income-time         as integer
    field need-new-rvs        as logical
    field use-old-rvs         as logical
    field rvs-doc-code        as character
    field rvs-doc-num         as integer
    field end-rvs-fact-qnty   as decimal
    field end-chk-fact-qnty   as decimal
    field end-trn-fact-qnty   as decimal
    field start-rvs-fact-qnty as decimal
    field start-chk-fact-qnty as decimal
    field start-trn-fact-qnty as decimal
    field end-rvs-doc-qnty    as decimal
    field end-chk-doc-qnty    as decimal
    field end-trn-doc-qnty    as decimal
    field start-rvs-doc-qnty  as decimal
    field start-chk-doc-qnty  as decimal
    field start-trn-doc-qnty  as decimal
  index pi as primary pl-code gds-code
  .
  
  define property timezone-diff as integer no-undo init ?
    get.
    private set.
    
  define property rvs-doc-exist-diff as integer no-undo init ?
    get.
    private set.
    
  define property rvs-doc-create-diff as integer no-undo init ?
    get.
    private set.
    
  define property db-num  as integer no-undo init ?
    get.
    private set.
    
  define property obj-code as integer no-undo init ?
    get.
    private set.
    
  define property obj-type as character no-undo init ""
    get.
    private set.
    
  define property last-exp-date  as date no-undo init ?
    get.
    private set.
    
  define property date-start  as date no-undo init ?
    get.
    private set.
    
  define property time-start  as integer no-undo init ?
    get.
    private set.
    
  define property date-end  as date no-undo init ?
    get.
    private set.
    
  define property time-end  as integer no-undo init ?
    get.
    private set.
    
  define property is-full as logical no-undo init false
    get.
    private set.
    
  define property is-full-backdate as logical no-undo init false
    get.
    private set.
    
  define property checks-recieved as logical no-undo init false
    get.
    private set.
    
  define property parparentproc as widget-handle no-undo
    get.
    private set.
    
  define property p-parent-handle as widget-handle no-undo
    get.
    private set.
    
  define property Data  as memptr no-undo
    get.
    private set.
    
  define property toDate  as date no-undo initial ?
    get.
    private set.
    
  define property otherOneDate as logical no-undo initial false
    get.
    private set.
    
  define property rep-file-name as character no-undo
    get.
    private set.
    
  define property oneMoreTime as logical no-undo initial false
    get.
    set.
    
  define buffer buf_clients for ub.clients .
  define buffer buf_clients-attr for ub.clients-attr .
  define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle . 
  
  define variable v-density       as decimal   no-undo .
  define variable v-pl-code       as integer   no-undo .

  define variable vMoscowDate     as date      no-undo .
  define variable vMoscowTime     as integer   no-undo .
  define variable vMoscowTimeEnd  as integer   no-undo .
  define variable cTime           as character no-undo .
  define variable vHour           as integer   no-undo .
  define variable cMoscowTime     as character no-undo .
  define variable vMoscowHour     as integer   no-undo .
  define variable vIsOtherMoves   as character no-undo .
  define variable vType           as character no-undo .
  
  define variable v-Reconc-tank-attr as character no-undo .
  
  define stream OutStr-html .
  
  constructor public is_PM
  (
  input pDbNum  as integer,
  input pObjCode as integer,
  input paramList as character,
  input pParentProc as widget-handle,
  input pParHandle as widget-handle
  ) :

    db-num = pDbNum .
    obj-code = pObjCode .
    obj-type = {&shop} .
    parparentproc = pParentProc .
    p-parent-handle = pParHandle .
    
    find first buf_clients no-lock where buf_clients.obj-code = obj-code
                                     and buf_clients.obj-type = obj-type
                                     .
    
    timezone-diff = integer(entry(1,paramList)) * 60 .
    rvs-doc-exist-diff = integer(entry(2,paramList)) .
    rvs-doc-create-diff = integer(entry(3,paramList)) .
    
    toDate = ? .
    otherOneDate = false .
    
    if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn3)
    then run str/lib-trn3.p persistent no-error .
    if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn)
    then run str/lib-trn.p persistent no-error .
    if not valid-handle (ibs.th.gbl.gbl-hndllib:g#trdcalib)
    then run str/trdcalib.p persistent no-error .
  end constructor .
  
  constructor public is_PM
  (
  input pDbNum  as integer,
  input pObjCode as integer,
  input paramList as character,
  input pParentProc as widget-handle,
  input pParHandle as widget-handle,
  input pToDate as date
  ) :
    
    db-num = pDbNum .
    obj-code = pObjCode .
    obj-type = {&shop} .
    parparentproc = pParentProc .
    p-parent-handle = pParHandle .
    
    find first buf_clients no-lock where buf_clients.obj-code = obj-code
                                     and buf_clients.obj-type = obj-type
                                     .
    
    timezone-diff = integer(entry(1,paramList)) * 60 .
    rvs-doc-exist-diff = integer(entry(2,paramList)) .
    rvs-doc-create-diff = integer(entry(3,paramList)) .
    
    toDate = pToDate .
    otherOneDate = true .
    
    if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn3)
    then run str/lib-trn3.p persistent no-error .
    if not valid-handle (ibs.th.gbl.gbl-hndllib:g#lib-trn)
    then run str/lib-trn.p persistent no-error .
    if not valid-handle (ibs.th.gbl.gbl-hndllib:g#trdcalib)
    then run str/trdcalib.p persistent no-error .
  end constructor .
  
  method public void exec_1c () :
    if session:debug-alert then output stream OutStr-html to PM_wght_lc.txt append convert target 'UTF-8'. 
    stage1() .
    stage2() .
    stage3() .
    stage4() .
    stage5() .
    create-esys-data() .
    if session:debug-alert then output stream OutStr-html close .    
  end method .
  
  method public void exec_rep () :

    if session:debug-alert then output stream OutStr-html to PM_wght_rep.txt append convert target 'UTF-8'. 
    stage1() .
    stage2() .
    stage3() .
    stage4() .
    stage5() .
    if session:debug-alert then output stream OutStr-html close .
    make-rep() .

  end method .
  
  method private void stage1 () :
    define buffer buf_place  for ub.place .
    define buffer buf_place-attr  for ub.place-attr .
    define buffer buf_c-pl-gds for ub.c-pl-gds .
    define buffer buf2_c-pl-gds for ub.c-pl-gds .
    define buffer buf_goods for ub.goods .
    define buffer buf_goods-attr for ub.goods-attr .
    
    empty temp-table tt-gds .
    empty temp-table tt-place .
    empty temp-table tt-result .
  
    run write-to-log in p-parent-handle (" START PRESTAGE UTC " + utc-time() ) .
    
    /* START Определение периода и приведение к московскому времени */
    is-full = false .
    is-full-backdate = false .
    
    if not otherOneDate
    or (otherOneDate and toDate = today)
    then do :
      cTime = string(time, "HH:MM:SS") .
      vHour = integer(substring(cTime, 1, 2)) .
      
      vMoscowTime = time - (timezone-diff * 60) .
      if vMoscowTime < 0
      then do :
        vMoscowTime = vMoscowTime + 86400 .
      end .
      cMoscowTime = string(vMoscowTime, "HH:MM:SS") .
      vMoscowHour = integer(substring(cMoscowTime, 1, 2)) .
      if vMoscowHour = 0
      then do :
        is-full = true .
        vMoscowTimeEnd = 86399 .
      end .
      else do :
        vMoscowTimeEnd = (vMoscowHour - 1) * 3600 + (59 * 60) + 59 .
      end .
      
      vMoscowDate = date(now - (timezone-diff * 60 * 1000)) .
      
      last-exp-date = today - 1 .
      for first buf_clients-attr no-lock where buf_clients-attr.obj-type = buf_clients.obj-type
                                           and buf_clients-attr.obj-code = buf_clients.obj-code
                                           and buf_clients-attr.attr-code = {&attr-exp-isPM-last-date}
                                           :
        last-exp-date = date(buf_clients-attr.attr-value) .    
      end .
      
      if last-exp-date = (vMoscowDate - 1)
      then do :
        date-start = vMoscowDate - if is-full then 1 else 0.
        time-start = timezone-diff * 60 .
        if time-start < 0
        then do :
          date-start = vMoscowDate - 1 .
          time-start = time-start + 86400 .
        end .
        date-end   = today .
        time-end   = (vHour - 1) * 3600 + (59 * 60) + 60 .
        if time-end <= 0
        then do :
          date-end   = today - 1 .
          time-end   = time-end + 86400 . 
        end .
      end .
      else do :
        run write-to-log in p-parent-handle (("Последняя выгруженная дата по московскому времени - " + string(last-exp-date, "99/99/9999"))) .
        is-full-backdate = true .
        if vMoscowHour > 0 then oneMoreTime = true .
        
        vMoscowDate = vMoscowDate - 1 .
        vMoscowTimeEnd = 86399 .
        
        date-start = vMoscowDate .
        time-start = timezone-diff * 60 .
        if time-start < 0
        then do :
          date-start = vMoscowDate - 2 .
          time-start = time-start + 86400 .
        end .
        date-end   = vMoscowDate + 1 .
        time-end   = timezone-diff * 60 . 
        if time-end <= 0
        then do :
          date-end   = vMoscowDate .
          time-end   = time-end + 86400 . 
        end .
      end .
    end .
    else do :
      is-full = true .
      vMoscowDate = toDate .
      vMoscowTimeEnd = 86399 .
      
      date-start = toDate .
      time-start = timezone-diff * 60 .
      if time-start < 0
      then do :
        date-start = toDate - 1 .
        time-start = time-start + 86400 .
      end .
      date-end   = toDate + 1 .
      time-end   = timezone-diff * 60 . 
      if time-end <= 0
      then do :
        date-end   = toDate .
        time-end   = time-end + 86400 . 
      end .
    end .
    /* END Определение периода */
    
    /* START Определяем список топлив и список резервуаров */
    place_ :
    for each buf_place  no-lock
      where buf_place.obj-type = obj-type
        and buf_place.obj-code = obj-code
    on error undo, return error return-value
    :
      
      for first buf_place-attr no-lock where buf_place-attr.obj-type = buf_place.obj-type
                                         and buf_place-attr.obj-code = buf_place.obj-code
                                         and buf_place-attr.pl-code  = buf_place.pl-code
                                         and buf_place-attr.attr-code = "place-virtual"
                                         :
        if lookup(buf_place-attr.attr-value, 'true,yes':u) > 0 then next place_ .                                   
      end .
      
      c-pl-gds_ :
      for each buf_c-pl-gds no-lock
          where buf_c-pl-gds.obj-type = buf_place.obj-type
            and buf_c-pl-gds.obj-code = buf_place.obj-code
            and buf_c-pl-gds.pl-code  = buf_place.pl-code
            and (buf_c-pl-gds.corr-date < date-end
             or (buf_c-pl-gds.corr-date = date-end and buf_c-pl-gds.corr-time <= time-end) )
             by buf_c-pl-gds.chip-num desc
      on error undo, return error return-value
      :
        for first buf2_c-pl-gds no-lock where buf2_c-pl-gds.obj-type = buf_c-pl-gds.obj-type
                                          and buf2_c-pl-gds.obj-code = buf_c-pl-gds.obj-code
                                          and buf2_c-pl-gds.pl-code  = buf_c-pl-gds.pl-code
                                          and buf2_c-pl-gds.gds-code <> buf_c-pl-gds.gds-code
                                          and buf2_c-pl-gds.corr-date = buf_c-pl-gds.corr-date
                                          and buf2_c-pl-gds.corr-date >= date-start
                                          :
          for first buf_goods-attr no-lock where buf_goods-attr.gds-code = buf2_c-pl-gds.gds-code
                                             and buf_goods-attr.attr-code = {&attr-ptrl-without-rvs}
                                             :
            if lookup(buf_goods-attr.attr-value, 'true,yes':u) > 0 then next c-pl-gds_ .                                   
          end .
    
          
          find first tt-gds where tt-gds.gds-code = buf2_c-pl-gds.gds-code no-error .
          if not available tt-gds
          then do :
            create tt-gds .
            assign
              tt-gds.gds-code = buf2_c-pl-gds.gds-code
            .
          end .
          
          find first tt-result where tt-result.gds-code = buf2_c-pl-gds.gds-code no-error .
          if not available tt-result
          then do :
            create tt-result .
            assign
              tt-result.gds-code = buf2_c-pl-gds.gds-code
              tt-result.change-place = yes
            .
          end .
          
          find first tt-place where tt-place.pl-code  = buf_place.pl-code
                                and tt-place.gds-code = buf2_c-pl-gds.gds-code
                                no-error .
          if not available tt-place
          then do :
            create tt-place .
            assign
              tt-place.pl-code  = buf_place.pl-code
              tt-place.pl-name  = buf_place.pl-name
              tt-place.gds-code = buf2_c-pl-gds.gds-code
              tt-place.is-meas  = buf_place.is-meas
              tt-place.is-calc  = no
            .
            for first buf_place-attr no-lock where buf_place-attr.obj-type = buf_place.obj-type
                                               and buf_place-attr.obj-code = buf_place.obj-code
                                               and buf_place-attr.pl-code  = buf_place.pl-code
                                               and buf_place-attr.attr-code = "place-rvd-lvl"
                                               :
              if lookup(buf_place-attr.attr-value, 'true,yes':u) > 0 then tt-place.rvd-level = yes .                                   
            end .
          end .                                  
        end .
        for first buf_goods-attr no-lock where buf_goods-attr.gds-code = buf_c-pl-gds.gds-code
                                           and buf_goods-attr.attr-code = {&attr-ptrl-without-rvs}
                                           :
          if lookup(buf_goods-attr.attr-value, 'true,yes':u) > 0 then next c-pl-gds_ .                                   
        end .
  
        
        find first tt-gds where tt-gds.gds-code = buf_c-pl-gds.gds-code no-error .
        if not available tt-gds
        then do :
          create tt-gds .
          assign
            tt-gds.gds-code = buf_c-pl-gds.gds-code
          .
        end .
        
        find first tt-result where tt-result.gds-code = buf_c-pl-gds.gds-code no-error .
        if not available tt-result
        then do :
          create tt-result .
          assign
            tt-result.gds-code = buf_c-pl-gds.gds-code
            tt-result.change-place = no
          .
        end .
        
        find first tt-place where tt-place.pl-code  = buf_place.pl-code
                              and tt-place.gds-code = buf_c-pl-gds.gds-code
                              no-error .
        if not available tt-place
        then do :
          create tt-place .
          assign
            tt-place.pl-code  = buf_place.pl-code
            tt-place.pl-name  = buf_place.pl-name
            tt-place.gds-code = buf_c-pl-gds.gds-code
            tt-place.is-meas  = buf_place.is-meas
            tt-place.is-calc  = no
          .
          for first buf_place-attr no-lock where buf_place-attr.obj-type = buf_place.obj-type
                                             and buf_place-attr.obj-code = buf_place.obj-code
                                             and buf_place-attr.pl-code  = buf_place.pl-code
                                             and buf_place-attr.attr-code = "place-rvd-lvl"
                                             :
            if lookup(buf_place-attr.attr-value, 'true,yes':u) > 0 then tt-place.rvd-level = yes .                                   
          end .
        end .
        
        leave c-pl-gds_ .
      end . /* for each bf_c-pl-gds */
    end . /* for each bf_place */
    /* END Определяем список топлив и список резервуаров */
    
    for each tt-gds,
    first buf_goods no-lock where buf_goods.gds-code = tt-gds.gds-code
    :
      run write-to-log in p-parent-handle (buf_goods.artic + ": " + buf_goods.gds-name) .
    end .
    
    run write-to-log in p-parent-handle (if is-full-backdate then "Суточная за прошедшие сутки" else  (if is-full then "Суточная" else "Промежуточная")) .
    run write-to-log in p-parent-handle (string(date-start) + " " + string(time-start, "HH:MM:SS") + " - " + string(date-end) + " " + (if time-end = 86400 then "23:59:59" else string(time-end, "HH:MM:SS"))) .
    run write-to-log in p-parent-handle (string(vMoscowDate) + " " + string(0, "HH:MM:SS") + " - " + string(vMoscowDate) + " " + string(vMoscowTimeEnd, "HH:MM:SS")) .
    
    run write-to-log in p-parent-handle (" END PRESTAGE UTC " + utc-time() ) .
    
  end method . /* stage1 */
  
  method private void stage2 () :
    define buffer buf_trn-doc for ub.trn-doc .
    define buffer buf_c-trn-doc for ub.c-trn-doc .
    define buffer buf_doc-line for ub.doc-line .
    define buffer buf_doc-pl for ub.doc-pl .
    define buffer end_rvs-doc for ub.rvs-doc .
    define buffer end_rvs-line for ub.rvs-line .
    define buffer new_rvs-doc for ub.rvs-doc .
    define buffer new_rvs-line for ub.rvs-line .
    define buffer buf_chk-doc for ub.chk-doc .
    define buffer buf_chk-gds for ub.chk-gds .
    define buffer buf_bar-code for ub.bar-code .
    define buffer buf_goods for ub.goods .
    define buffer buf_clients-attr for ub.clients-attr .
    define buffer before_rvs-doc for ub.rvs-doc .
    define buffer buf_shift-obj for ub.shift-obj .
    
    define variable v-found-income as logical no-undo .
    define variable v-income-doc-code as character no-undo .
    
    run write-to-log in p-parent-handle (" START FACT-END UTC " + utc-time() ) .
    
    /* START Определяем, по каким резервуарам идёт приёмка */
    run write-to-log in p-parent-handle ( "Поиск открытых на конец периода приемок" ) .
    v-found-income = false .
    v-income-doc-code = "" .
    trn_ :
    for each buf_trn-doc no-lock where buf_trn-doc.obj-type = obj-type
                                   and buf_trn-doc.obj-code = obj-code
                                   and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
                                   and buf_trn-doc.status_ <> {&fact}
                                   and buf_trn-doc.sys-date >= date-start
                                   and buf_trn-doc.sys-date <= date-end 
                                   :
      find first buf_c-trn-doc no-lock where buf_c-trn-doc.doc-code = buf_trn-doc.doc-code no-error .
      if available buf_c-trn-doc 
      then do :
        if buf_c-trn-doc.real-date-create = date-start  
        and buf_c-trn-doc.real-time-create < time-start
        then next trn_ . 
        
        if buf_c-trn-doc.real-date-create = date-end  
        and buf_c-trn-doc.real-time-create > time-end
        then next trn_ .   
        
        place_ :     
        for each tt-place,
        first buf_doc-pl no-lock where buf_doc-pl.obj-type = buf_trn-doc.obj-type
                                   and buf_doc-pl.obj-code = buf_trn-doc.obj-code
                                   and buf_doc-pl.pl-code  = tt-place.pl-code
                                   and buf_doc-pl.out-code = buf_trn-doc.doc-code
                                   and buf_doc-pl.gds-code = tt-place.gds-code
                                   :
          assign
            tt-place.is-income = true
            tt-place.income-date = buf_c-trn-doc.real-date-create
            tt-place.income-time = buf_c-trn-doc.real-time-create
            v-found-income = true .
          .
          if v-income-doc-code <> buf_trn-doc.doc-code
          then do :
            v-income-doc-code = buf_trn-doc.doc-code .
            run write-to-log in p-parent-handle ( "Найдена приемка по ПН №" + v-income-doc-code ) .
          end .
          tt-place.rvs-doc-num = 2000000000 .
          for first before_rvs-doc no-lock where before_rvs-doc.out-code = buf_trn-doc.doc-code
                                             and before_rvs-doc.rvs-type = {&rvs-before-doc}    
                                             :
            tt-place.rvs-doc-num = integer(entry(1, before_rvs-doc.rvs-code, "-")) no-error .
            if before_rvs-doc.fact-date <> ?
            then do :
              assign
                tt-place.income-date = before_rvs-doc.fact-date
                tt-place.income-time = before_rvs-doc.fact-time
              .
            end .                                 
          end .
        end . 
      end .
      else do :                             
        if buf_trn-doc.sys-date = date-start  
        and buf_trn-doc.sys-time-int < time-start
        then next trn_ . 
        if buf_trn-doc.sys-date = date-end  
        and buf_trn-doc.sys-time-int > time-end
        then next trn_ .   
        
        place_ :     
        for each tt-place,
        first buf_doc-pl no-lock where buf_doc-pl.obj-type = buf_trn-doc.obj-type
                                   and buf_doc-pl.obj-code = buf_trn-doc.obj-code
                                   and buf_doc-pl.pl-code  = tt-place.pl-code
                                   and buf_doc-pl.out-code = buf_trn-doc.doc-code
                                   and buf_doc-pl.gds-code = tt-place.gds-code
                                   :
          assign
            tt-place.is-income = true
            tt-place.income-date = buf_trn-doc.sys-date
            tt-place.income-time = buf_trn-doc.sys-time-int
            v-found-income = true .
          .
          if v-income-doc-code <> buf_trn-doc.doc-code
          then do :
            v-income-doc-code = buf_trn-doc.doc-code .
            run write-to-log in p-parent-handle ( "Найдена приемка по ПН №" + v-income-doc-code ) .
          end .
          tt-place.rvs-doc-num = 2000000000 .
          for first before_rvs-doc no-lock where before_rvs-doc.out-code = buf_trn-doc.doc-code
                                             and before_rvs-doc.rvs-type = {&rvs-before-doc}    
                                             :
            tt-place.rvs-doc-num = integer(entry(1, before_rvs-doc.rvs-code, "-")) no-error .
            if before_rvs-doc.fact-date <> ?
            then do :
              assign
                tt-place.income-date = before_rvs-doc.fact-date
                tt-place.income-time = before_rvs-doc.fact-time
              .
            end .                                 
          end . 
        end . 
      end .  
    end .
    if not v-found-income
    then do :
      run write-to-log in p-parent-handle ( "Приемки не найдены" ) .
    end .
    /* END Определяем, по каким резервуарам идёт приёмка */
    
    /* START Прием чеков */
    if not otherOneDate
    then
    for first tt-place where tt-place.need-new-rvs
                          or tt-place.is-income
                          :
      run write-to-log in p-parent-handle ( "Прием чеков" ) .                      
      checks-recieved = get-check() .
    end .
    
    /* END Прием чеков */
 
    /* START Поиск контрольных сверок на конец периода по резервуарам, которые не учавствуют в приёмке */
    define variable rvs-time-diff as integer no-undo .
    define variable exec-time-diff as integer no-undo .
     
    for each tt-place where not tt-place.is-income :
      if not otherOneDate
      then
      run write-to-log in p-parent-handle ( "Проверка необходимости создания сверки по резервуару " + string(tt-place.pl-code) + " . Товар " + string(tt-place.gds-code) ) .
      
      end_rvs-doc_ :
      for each end_rvs-doc no-lock where end_rvs-doc.obj-type = obj-type
                                     and end_rvs-doc.obj-code = obj-code
                                     and end_rvs-doc.rvs-type = {&rvs-control}
                                     and end_rvs-doc.status_  = {&fact}
                                     and ((end_rvs-doc.fact-date < date-end)
                                       or (end_rvs-doc.fact-date = date-end and end_rvs-doc.fact-time <= time-end))
                                     ,
      first end_rvs-line no-lock where end_rvs-line.obj-type  = end_rvs-doc.obj-type
                                   and end_rvs-line.obj-code  = end_rvs-doc.obj-code
                                   and end_rvs-line.rvs-code  = end_rvs-doc.rvs-code
                                   and end_rvs-line.pl-code   = tt-place.pl-code
                                   and end_rvs-line.gds-code  = tt-place.gds-code
                                   by end_rvs-doc.fact-order desc
                                   :
        rvs-time-diff = time-end - end_rvs-doc.fact-time + ((date-end - end_rvs-doc.fact-date) * 86400) .
        if rvs-time-diff < 0
        then do :
          rvs-time-diff = 86400 - end_rvs-doc.fact-time + time-end .
        end .
        
        exec-time-diff = time - time-end .
        if exec-time-diff < 0
        then do :
          exec-time-diff = 86400 - time-end + time .
        end .
        
        if rvs-time-diff > (rvs-doc-exist-diff * 60)
        and exec-time-diff < (rvs-doc-create-diff * 60)
        and not otherOneDate
        then do :
          if is-full
          and tt-place.is-meas
          and not tt-place.rvd-level
          and rvs-time-diff > exec-time-diff
          then do :
            run write-to-log in p-parent-handle ( "Требуется создание сверки" ) .
            tt-place.need-new-rvs = true .
          end .
          else do :
            run write-to-log in p-parent-handle (if is-full-backdate then "Выгрузка за прошедшие сутки, сверка не создается" else "Выгрузка промежуточная, сверка не создается" ) .
            tt-place.use-old-rvs = true .
          end .
        end .
        else do :
          if rvs-time-diff > (rvs-doc-exist-diff * 60)
          then do :
            tt-place.use-old-rvs = true .
            run write-to-log in p-parent-handle ( "Cоздание сверки не требуется" ) .
          end .
          else do :
            if not otherOneDate
            then
            run write-to-log in p-parent-handle ( "Есть актуальная сверка, создание сверки не требуется" ) .
            
            tt-place.end-rvs-fact-qnty = end_rvs-line.state-measure-cli-qnty + (end_rvs-line.state-add-qnty * end_rvs-line.state-density) .
            tt-place.rvs-doc-code = end_rvs-doc.rvs-code .
            tt-place.is-calc = false .
            for first tt-result where tt-result.gds-code = tt-place.gds-code :
              tt-result.wght-fact-end = tt-result.wght-fact-end + tt-place.end-rvs-fact-qnty .
              if abs(tt-result.wght-fact-end) < 0.001 then tt-result.wght-fact-end = 0 .
              if session:debug-alert
              then do:
                put stream OutStr-html unformatted
                  "wght-fact-end Поиск контрольных сверок на конец периода" skip
                  "Резервуар " + string(tt-place.gds-code) + " " +  string(tt-place.pl-code) + " " +  string(tt-place.pl-name) skip
                  string(tt-place.end-rvs-fact-qnty) skip
                  string (tt-result.wght-fact-end) skip
                .
              end.   
            end .
          end .
        end .
        leave end_rvs-doc_ .
      end . /* for last end_rvs-doc */
    end . /* for each tt-place */
    /* END Поиск контрольных сверок на конец периода */
    
    /* START Создание новой полной контрольной сверки */
    define variable new-rvs-doc-code as character no-undo init "" .
    
    if not otherOneDate
    then
    for first tt-place where tt-place.need-new-rvs :
      run write-to-log in p-parent-handle ( "Создание контрольной сверки" ) .
      new-rvs-doc-code = make-rvs-doc() .
      if new-rvs-doc-code = "error"
      then do :
        run write-to-log in p-parent-handle ( "Ошибка при создании контрольной сверки" ) .
      end .
      else do :
        run write-to-log in p-parent-handle ( "Создана сверка №" + new-rvs-doc-code ) .
      end .
    end .
    
    if new-rvs-doc-code = "error"
    then do :
      for each tt-place where tt-place.need-new-rvs :
        assign
          tt-place.need-new-rvs = false
          tt-place.use-old-rvs = true
        .
      end .
    end .
    /* END Создание новой полной контрольной сверки */
    
    
    /* START Рассчет фактического остатка на конец периода по формулам 1 и 2 */
    for each tt-place where tt-place.need-new-rvs,
    first buf_goods no-lock where buf_goods.gds-code = tt-place.gds-code,
    first gds-prt no-lock where gds-prt.upper-code = buf_goods.prt-root,
    first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code
                                 and buf_bar-code.node-code = gds-prt.node-code
                                 and buf_bar-code.in-code = ""
                                 and buf_bar-code.part-code = ""
                                 and buf_bar-code.unit-cli = buf_goods.unit-base
    :
      for first new_rvs-doc where new_rvs-doc.rvs-code = new-rvs-doc-code :
        tt-place.is-calc = true .
        tt-place.rvs-doc-code = new_rvs-doc.rvs-code .
        
        for first new_rvs-line no-lock where new_rvs-line.obj-type  = new_rvs-doc.obj-type
                                         and new_rvs-line.obj-code  = new_rvs-doc.obj-code
                                         and new_rvs-line.rvs-code  = new_rvs-doc.rvs-code
                                         and new_rvs-line.pl-code   = tt-place.pl-code
                                         and new_rvs-line.gds-code  = tt-place.gds-code
                                         :
          tt-place.end-rvs-fact-qnty = new_rvs-line.state-measure-cli-qnty + (new_rvs-line.state-add-qnty * new_rvs-line.state-density) . 
        end .
        
        chk-doc_ :
        for each buf_chk-doc no-lock where buf_chk-doc.obj-type = obj-type
                                       and buf_chk-doc.obj-code = obj-code
                                       and buf_chk-doc.chk-date = new_rvs-doc.fact-date
                                       and buf_chk-doc.chk-time >= (if time-end = 86399 then 0 else time-end) 
                                       and buf_chk-doc.chk-time <= new_rvs-doc.fact-time
                                       :
          if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next chk-doc_ .
          
          chk-gds_ :
          for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                                         and buf_chk-gds.b-code   = buf_bar-code.b-code
/*                                         and buf_chk-gds.pl-code  = tt-place.pl-code*/
                                         :
            if buf_chk-doc.out-code = ?
            then do :
              v-pl-code = findtank (buf_chk-doc.obj-type,
                                    buf_chk-doc.obj-code,
                                    buf_chk-gds.pump,
                                    buf_chk-gds.nozzle-code,
                                    buf_chk-gds.pl-code,
                                    buf_bar-code.gds-code) .
              if v-pl-code = ?
              or v-pl-code = 0
              then do :
                v-pl-code = findblockedtank (buf_chk-doc.obj-type,
                                             buf_chk-doc.obj-code,
                                             buf_chk-gds.pump,
                                             buf_chk-gds.nozzle-code,
                                             buf_chk-gds.pl-code,
                                             buf_bar-code.gds-code) .
              end .
            end .
            else do :
              v-pl-code = buf_chk-gds.pl-code .
            end .                        
            if v-pl-code <> tt-place.pl-code then next chk-gds_ .
                                           
            if not valid-density (buf_chk-gds.density, (buf_goods.unit-base = buf_goods.unit-cli))
            then do :   
              v-density = 0 .
              if lookup({&shift-err}, buf_chk-doc.office) > 0
              then do :        
                { str/avrgdens.i
                  tt-place.gds-code
                  buf_chk-doc.obj-type
                  buf_chk-doc.obj-code
                  tt-place.pl-code
                  new_rvs-doc.shift-date
                  new_rvs-doc.shift-num
                  buf_chk-doc.chk-date
                  buf_chk-doc.chk-time
                  v-density
                  v-Reconc-tank-attr
                  no-error
                }
              end .
              else do :
                { str/avrgdens.i
                  tt-place.gds-code
                  buf_chk-doc.obj-type
                  buf_chk-doc.obj-code
                  tt-place.pl-code
                  buf_chk-doc.shift-date
                  buf_chk-doc.shift-num
                  buf_chk-doc.chk-date
                  buf_chk-doc.chk-time
                  v-density
                  v-Reconc-tank-attr
                  no-error
                }
              end .
              tt-place.end-chk-fact-qnty = tt-place.end-chk-fact-qnty + (buf_chk-gds.doc-qnty * v-density) .
            end .
            else do :                     
              tt-place.end-chk-fact-qnty = tt-place.end-chk-fact-qnty + (buf_chk-gds.doc-qnty * buf_chk-gds.density) .   
            end .                            
          end .
        end .
        
        income-doc-line_ :
        for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                        and buf_doc-line.obj-code  = obj-code
                                        and buf_doc-line.artic     = buf_goods.artic
                                        and buf_doc-line.prod-type = buf_goods.prod-type
                                        and buf_doc-line.prod-code = buf_goods.prod-code
                                        and buf_doc-line.status_   = {&fact}
                                        ,
        first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                    and (buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Inv})
                                    and buf_trn-doc.fact-date = new_rvs-doc.fact-date
                                    and buf_trn-doc.fact-time >= (if time-end = 86399 then 0 else time-end)
                                    and buf_trn-doc.fact-time <= new_rvs-doc.fact-time
                                    :
          { str/tdat-val.i
              buf_trn-doc.doc-code
              {&trdcattr-othermoves}
              vIsOtherMoves
              vType                 }
          if vIsOtherMoves > ""
          and logical(vIsOtherMoves)
          then next income-doc-line_ .
                
          if buf_trn-doc.ext-doc-type <> {&TDEDT_Inv}
          then
          for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                               and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                               and buf_clients-attr.attr-code = {&attr-shftrep2}
                                               :
            /* ТехПролив */
            if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next income-doc-line_ .
          end .
          for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                        and buf_doc-pl.obj-code = obj-code
                                        and buf_doc-pl.pl-code  = tt-place.pl-code
                                        and buf_doc-pl.out-code = buf_doc-line.doc-code
                                        and buf_doc-pl.gds-code = tt-place.gds-code
                                        :
            tt-place.end-trn-fact-qnty = tt-place.end-trn-fact-qnty + buf_doc-pl.cli-fact-qnty .                              
          end .
        end . /* for each income buf_doc-line */
        
        expense-doc-line_ :
        for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                        and buf_doc-line.obj-code  = obj-code
                                        and buf_doc-line.artic     = buf_goods.artic
                                        and buf_doc-line.prod-type = buf_goods.prod-type
                                        and buf_doc-line.prod-code = buf_goods.prod-code
                                        and buf_doc-line.status_   = {&fact}
                                        ,
        first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                    and (buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh})
                                    and buf_trn-doc.fact-date = new_rvs-doc.fact-date
                                    and buf_trn-doc.fact-time >= (if time-end = 86399 then 0 else time-end)
                                    and buf_trn-doc.fact-time <= new_rvs-doc.fact-time
                                    :
          { str/tdat-val.i
              buf_trn-doc.doc-code
              {&trdcattr-othermoves}
              vIsOtherMoves
              vType                 }
          if vIsOtherMoves > ""
          and logical(vIsOtherMoves)
          then next expense-doc-line_ .
          for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                               and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                               and buf_clients-attr.attr-code = {&attr-shftrep2}
                                               :
            /* ТехПролив */
            if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next expense-doc-line_ .
          end .
          for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                        and buf_doc-pl.obj-code = obj-code
                                        and buf_doc-pl.pl-code  = tt-place.pl-code
                                        and buf_doc-pl.out-code = buf_doc-line.doc-code
                                        and buf_doc-pl.gds-code = tt-place.gds-code
                                        :
            tt-place.end-trn-fact-qnty = tt-place.end-trn-fact-qnty - buf_doc-pl.cli-fact-qnty .                              
          end .
        end . /* for each expense buf_doc-line */
      end . /* for first new_rvs-doc */
      for first tt-result where tt-result.gds-code = tt-place.gds-code :
        /* Формула 2 */
        tt-result.wght-fact-end = tt-result.wght-fact-end + (tt-place.end-rvs-fact-qnty + tt-place.end-chk-fact-qnty - tt-place.end-trn-fact-qnty) .
        if abs(tt-result.wght-fact-end) < 0.001 then tt-result.wght-fact-end = 0 .
        if session:debug-alert 
        then do:
          put stream OutStr-html unformatted
            "wght-fact-end Формула 2" skip
            "Резервуар: " + string(tt-place.gds-code) + " " +  string(tt-place.pl-code) + " " +  string(tt-place.pl-name) skip
            string(tt-place.end-rvs-fact-qnty) + " + " +  string (tt-place.end-chk-fact-qnty) +  " - " + string(tt-place.end-trn-fact-qnty) skip
            string(tt-result.wght-fact-end) skip
          .
        end.  
      end .
    end .
    
    for each tt-place where tt-place.use-old-rvs,
    first buf_goods no-lock where buf_goods.gds-code = tt-place.gds-code,
    first gds-prt no-lock where gds-prt.upper-code = buf_goods.prt-root,
    first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code
                                 and buf_bar-code.node-code = gds-prt.node-code
                                 and buf_bar-code.in-code = ""
                                 and buf_bar-code.part-code = ""
                                 and buf_bar-code.unit-cli = buf_goods.unit-base
    :
      end_rvs-doc_ :
      for each end_rvs-doc no-lock where end_rvs-doc.obj-type = obj-type
                                     and end_rvs-doc.obj-code = obj-code
                                     and end_rvs-doc.rvs-type = {&rvs-control}
                                     and end_rvs-doc.status_  = {&fact}
                                     and ((end_rvs-doc.fact-date < date-end)
                                       or (end_rvs-doc.fact-date = date-end and end_rvs-doc.fact-time <= time-end))
                                     by end_rvs-doc.fact-order desc
                                     :
        tt-place.is-calc = true .
        
        if end_rvs-doc.fact-date < date-start - 1
        then do :
          chk-doc_ :
          for each buf_chk-doc no-lock where buf_chk-doc.obj-type = obj-type
                                         and buf_chk-doc.obj-code = obj-code
                                         and buf_chk-doc.chk-date >= date-start
                                         and buf_chk-doc.chk-date <= date-end
                                         :
            if buf_chk-doc.chk-date = date-start
            and buf_chk-doc.chk-time <= time-start
            then next chk-doc_ .
            
            if buf_chk-doc.chk-date = date-end
            and buf_chk-doc.chk-time > time-end
            then next chk-doc_ .  
                                         
            if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next chk-doc_ .
            
            chk-gds_ :
            for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                                           and buf_chk-gds.b-code   = buf_bar-code.b-code
  /*                                         and buf_chk-gds.pl-code  = tt-place.pl-code*/
                                           :
              if buf_chk-doc.out-code = ?
              then do :
                v-pl-code = findtank (buf_chk-doc.obj-type,
                                      buf_chk-doc.obj-code,
                                      buf_chk-gds.pump,
                                      buf_chk-gds.nozzle-code,
                                      buf_chk-gds.pl-code,
                                      buf_bar-code.gds-code) .
                if v-pl-code = ?
                or v-pl-code = 0
                then do :
                  v-pl-code = findblockedtank (buf_chk-doc.obj-type,
                                               buf_chk-doc.obj-code,
                                               buf_chk-gds.pump,
                                               buf_chk-gds.nozzle-code,
                                               buf_chk-gds.pl-code,
                                               buf_bar-code.gds-code) .
                end .
              end .
              else do :
                v-pl-code = buf_chk-gds.pl-code .
              end .
              if v-pl-code <> tt-place.pl-code then next chk-gds_ .
                                             
              if not valid-density (buf_chk-gds.density, (buf_goods.unit-base = buf_goods.unit-cli))
              then do :   
                v-density = 0 .   
                if lookup({&shift-err}, buf_chk-doc.office) > 0
                then do :    
                  find last buf_shift-obj no-lock where buf_shift-obj.obj-type = buf_chk-doc.obj-type
                                                    and buf_shift-obj.obj-code = buf_chk-doc.obj-code
                                                    and ((buf_shift-obj.open-date < buf_chk-doc.chk-date)
                                                      or (buf_shift-obj.open-date = buf_chk-doc.chk-date and buf_shift-obj.open-time < buf_chk-doc.chk-time))
                                                    no-error .
                  if available buf_shift-obj
                  then do :                                    
                    { str/avrgdens.i
                      tt-place.gds-code
                      buf_chk-doc.obj-type
                      buf_chk-doc.obj-code
                      tt-place.pl-code
                      buf_shift-obj.shift-date
                      buf_shift-obj.shift-num
                      buf_chk-doc.chk-date
                      buf_chk-doc.chk-time
                      v-density
                      v-Reconc-tank-attr
                      no-error
                    }
                  end .
                  else do :
                    { str/avrgdens.i
                      tt-place.gds-code
                      buf_chk-doc.obj-type
                      buf_chk-doc.obj-code
                      tt-place.pl-code
                      buf_chk-doc.chk-date
                      1
                      buf_chk-doc.chk-date
                      buf_chk-doc.chk-time
                      v-density
                      v-Reconc-tank-attr
                      no-error
                    }
                  end .
                end .
                else do :
                  { str/avrgdens.i
                    tt-place.gds-code
                    buf_chk-doc.obj-type
                    buf_chk-doc.obj-code
                    tt-place.pl-code
                    buf_chk-doc.shift-date
                    buf_chk-doc.shift-num
                    buf_chk-doc.chk-date
                    buf_chk-doc.chk-time
                    v-density
                    v-Reconc-tank-attr
                    no-error
                  }
                end .
                tt-place.end-chk-fact-qnty = tt-place.end-chk-fact-qnty + (buf_chk-gds.doc-qnty * v-density) .
              end .
              else do :                     
                tt-place.end-chk-fact-qnty = tt-place.end-chk-fact-qnty + (buf_chk-gds.doc-qnty * buf_chk-gds.density) .   
              end .                               
            end .
          end .
          
          income-doc-line_ :
          for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                          and buf_doc-line.obj-code  = obj-code
                                          and buf_doc-line.artic     = buf_goods.artic
                                          and buf_doc-line.prod-type = buf_goods.prod-type
                                          and buf_doc-line.prod-code = buf_goods.prod-code
                                          and buf_doc-line.status_   = {&fact}
                                          ,
          first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                      and (buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Inv})
                                      and ((buf_trn-doc.fact-date > date-start) or
                                           (buf_trn-doc.fact-date = date-start and buf_trn-doc.fact-time > time-start))
                                      and ((buf_trn-doc.fact-date < date-end) or
                                           (buf_trn-doc.fact-date = date-end and buf_trn-doc.fact-time <= time-end))
                                      :
            { str/tdat-val.i
                buf_trn-doc.doc-code
                {&trdcattr-othermoves}
                vIsOtherMoves
                vType                 }
            if vIsOtherMoves > ""
            and logical(vIsOtherMoves)
            then next income-doc-line_ .
            if buf_trn-doc.ext-doc-type <> {&TDEDT_Inv}
            then
            for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                                 and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                                 and buf_clients-attr.attr-code = {&attr-shftrep2}
                                                 :
              /* ТехПролив */
              if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next income-doc-line_ .
            end .
            for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                          and buf_doc-pl.obj-code = obj-code
                                          and buf_doc-pl.pl-code  = tt-place.pl-code
                                          and buf_doc-pl.out-code = buf_doc-line.doc-code
                                          and buf_doc-pl.gds-code = tt-place.gds-code
                                          :
              tt-place.end-trn-fact-qnty = tt-place.end-trn-fact-qnty + buf_doc-pl.cli-fact-qnty .                              
            end .
          end . /* for each income buf_doc-line */
          
          expense-doc-line_ :
          for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                          and buf_doc-line.obj-code  = obj-code
                                          and buf_doc-line.artic     = buf_goods.artic
                                          and buf_doc-line.prod-type = buf_goods.prod-type
                                          and buf_doc-line.prod-code = buf_goods.prod-code
                                          and buf_doc-line.status_   = {&fact}
                                          ,
          first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                      and (buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh})
                                      and ((buf_trn-doc.fact-date > date-start) or
                                           (buf_trn-doc.fact-date = date-start and buf_trn-doc.fact-time > time-start))
                                      and ((buf_trn-doc.fact-date < date-end) or
                                           (buf_trn-doc.fact-date = date-end and buf_trn-doc.fact-time <= time-end))
                                      :
            { str/tdat-val.i
                buf_trn-doc.doc-code
                {&trdcattr-othermoves}
                vIsOtherMoves
                vType                 }
            if vIsOtherMoves > ""
            and logical(vIsOtherMoves)
            then next expense-doc-line_ .
            for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                                 and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                                 and buf_clients-attr.attr-code = {&attr-shftrep2}
                                                 :
              /* ТехПролив */
              if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next expense-doc-line_ .
            end .
            for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                          and buf_doc-pl.obj-code = obj-code
                                          and buf_doc-pl.pl-code  = tt-place.pl-code
                                          and buf_doc-pl.out-code = buf_doc-line.doc-code
                                          and buf_doc-pl.gds-code = tt-place.gds-code
                                          :
              tt-place.end-trn-fact-qnty = tt-place.end-trn-fact-qnty - buf_doc-pl.cli-fact-qnty .                              
            end .
          end . /* for each expense buf_doc-line */
          leave end_rvs-doc_ .
        end .
        find first end_rvs-line no-lock where end_rvs-line.obj-type  = end_rvs-doc.obj-type
                                         and end_rvs-line.obj-code  = end_rvs-doc.obj-code
                                         and end_rvs-line.rvs-code  = end_rvs-doc.rvs-code
                                         and end_rvs-line.pl-code   = tt-place.pl-code
                                         and end_rvs-line.gds-code  = tt-place.gds-code
                                         no-error .
        if not available end_rvs-line                                
        then do :
          next end_rvs-doc_ .
        end .
        
        tt-place.rvs-doc-code = end_rvs-doc.rvs-code .                               
        
        tt-place.end-rvs-fact-qnty = end_rvs-line.state-measure-cli-qnty + (end_rvs-line.state-add-qnty * end_rvs-line.state-density) .
        
        chk-doc_ :
        for each buf_chk-doc no-lock where buf_chk-doc.obj-type = obj-type
                                       and buf_chk-doc.obj-code = obj-code
                                       and buf_chk-doc.chk-date >= end_rvs-doc.fact-date
                                       and buf_chk-doc.chk-date <= date-end
                                       :
          if buf_chk-doc.chk-date = end_rvs-doc.fact-date
          and buf_chk-doc.chk-time <= end_rvs-doc.fact-time
          then next chk-doc_ .
          
          if buf_chk-doc.chk-date = date-end
          and buf_chk-doc.chk-time > time-end
          then next chk-doc_ .  
                                       
          if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next chk-doc_ .
          
          chk-gds_ :
          for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                                         and buf_chk-gds.b-code   = buf_bar-code.b-code
/*                                         and buf_chk-gds.pl-code  = tt-place.pl-code*/
                                         :
            if buf_chk-doc.out-code = ?
            then do :
              v-pl-code = findtank (buf_chk-doc.obj-type,
                                    buf_chk-doc.obj-code,
                                    buf_chk-gds.pump,
                                    buf_chk-gds.nozzle-code,
                                    buf_chk-gds.pl-code,
                                    buf_bar-code.gds-code) .
              if v-pl-code = ?
              or v-pl-code = 0
              then do :
                v-pl-code = findblockedtank (buf_chk-doc.obj-type,
                                             buf_chk-doc.obj-code,
                                             buf_chk-gds.pump,
                                             buf_chk-gds.nozzle-code,
                                             buf_chk-gds.pl-code,
                                             buf_bar-code.gds-code) .
              end .
            end .
            else do :
              v-pl-code = buf_chk-gds.pl-code .
            end .
            if v-pl-code <> tt-place.pl-code then next chk-gds_ .
                                           
            if not valid-density (buf_chk-gds.density, (buf_goods.unit-base = buf_goods.unit-cli))
            then do :   
              v-density = 0 .    
              if lookup({&shift-err}, buf_chk-doc.office) > 0
              then do :   
                find last buf_shift-obj no-lock where buf_shift-obj.obj-type = buf_chk-doc.obj-type
                                                  and buf_shift-obj.obj-code = buf_chk-doc.obj-code
                                                  and ((buf_shift-obj.open-date < buf_chk-doc.chk-date)
                                                    or (buf_shift-obj.open-date = buf_chk-doc.chk-date and buf_shift-obj.open-time < buf_chk-doc.chk-time))
                                                  no-error .
                if available buf_shift-obj
                then do :                                    
                  { str/avrgdens.i
                    tt-place.gds-code
                    buf_chk-doc.obj-type
                    buf_chk-doc.obj-code
                    tt-place.pl-code
                    buf_shift-obj.shift-date
                    buf_shift-obj.shift-num
                    buf_chk-doc.chk-date
                    buf_chk-doc.chk-time
                    v-density
                    v-Reconc-tank-attr
                    no-error
                  }
                end .
                else do :
                  { str/avrgdens.i
                    tt-place.gds-code
                    buf_chk-doc.obj-type
                    buf_chk-doc.obj-code
                    tt-place.pl-code
                    buf_chk-doc.chk-date
                    1
                    buf_chk-doc.chk-date
                    buf_chk-doc.chk-time
                    v-density
                    v-Reconc-tank-attr
                    no-error
                  }
                end .
              end .
              else do :
                { str/avrgdens.i
                  tt-place.gds-code
                  buf_chk-doc.obj-type
                  buf_chk-doc.obj-code
                  tt-place.pl-code
                  buf_chk-doc.shift-date
                  buf_chk-doc.shift-num
                  buf_chk-doc.chk-date
                  buf_chk-doc.chk-time
                  v-density
                  v-Reconc-tank-attr
                  no-error
                }
              end .
              tt-place.end-chk-fact-qnty = tt-place.end-chk-fact-qnty + (buf_chk-gds.doc-qnty * v-density) .
            end .
            else do :                     
              tt-place.end-chk-fact-qnty = tt-place.end-chk-fact-qnty + (buf_chk-gds.doc-qnty * buf_chk-gds.density) .   
            end .                               
          end .
        end .
        
        income-doc-line_ :
        for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                        and buf_doc-line.obj-code  = obj-code
                                        and buf_doc-line.artic     = buf_goods.artic
                                        and buf_doc-line.prod-type = buf_goods.prod-type
                                        and buf_doc-line.prod-code = buf_goods.prod-code
                                        and buf_doc-line.status_   = {&fact}
                                        ,
        first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                    and (buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Inv})
                                    and ((buf_trn-doc.fact-date > end_rvs-doc.fact-date) or
                                         (buf_trn-doc.fact-date = end_rvs-doc.fact-date and buf_trn-doc.fact-time >  end_rvs-doc.fact-time))
                                    and ((buf_trn-doc.fact-date < date-end) or
                                         (buf_trn-doc.fact-date = date-end and buf_trn-doc.fact-time <= time-end))
                                    :
          { str/tdat-val.i
              buf_trn-doc.doc-code
              {&trdcattr-othermoves}
              vIsOtherMoves
              vType                 }
          if vIsOtherMoves > ""
          and logical(vIsOtherMoves)
          then next income-doc-line_ .
          if buf_trn-doc.ext-doc-type <> {&TDEDT_Inv}
          then
          for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                               and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                               and buf_clients-attr.attr-code = {&attr-shftrep2}
                                               :
            /* ТехПролив */
            if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next income-doc-line_ .
          end .
          for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                        and buf_doc-pl.obj-code = obj-code
                                        and buf_doc-pl.pl-code  = tt-place.pl-code
                                        and buf_doc-pl.out-code = buf_doc-line.doc-code
                                        and buf_doc-pl.gds-code = tt-place.gds-code
                                        :
            tt-place.end-trn-fact-qnty = tt-place.end-trn-fact-qnty + buf_doc-pl.cli-fact-qnty .                              
          end .
        end . /* for each income buf_doc-line */
        
        expense-doc-line_ :
        for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                        and buf_doc-line.obj-code  = obj-code
                                        and buf_doc-line.artic     = buf_goods.artic
                                        and buf_doc-line.prod-type = buf_goods.prod-type
                                        and buf_doc-line.prod-code = buf_goods.prod-code
                                        and buf_doc-line.status_   = {&fact}
                                        ,
        first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                    and (buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh})
                                    and ((buf_trn-doc.fact-date > end_rvs-doc.fact-date) or
                                         (buf_trn-doc.fact-date = end_rvs-doc.fact-date and buf_trn-doc.fact-time >  end_rvs-doc.fact-time))
                                    and ((buf_trn-doc.fact-date < date-end) or
                                         (buf_trn-doc.fact-date = date-end and buf_trn-doc.fact-time <= time-end))
                                    :
          { str/tdat-val.i
              buf_trn-doc.doc-code
              {&trdcattr-othermoves}
              vIsOtherMoves
              vType                 }
          if vIsOtherMoves > ""
          and logical(vIsOtherMoves)
          then next expense-doc-line_ .
          for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                               and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                               and buf_clients-attr.attr-code = {&attr-shftrep2}
                                               :
            /* ТехПролив */
            if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next expense-doc-line_ .
          end .
          for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                        and buf_doc-pl.obj-code = obj-code
                                        and buf_doc-pl.pl-code  = tt-place.pl-code
                                        and buf_doc-pl.out-code = buf_doc-line.doc-code
                                        and buf_doc-pl.gds-code = tt-place.gds-code
                                        :
            tt-place.end-trn-fact-qnty = tt-place.end-trn-fact-qnty - buf_doc-pl.cli-fact-qnty .                              
          end .
        end . /* for each expense buf_doc-line */
        leave end_rvs-doc_ .
      end . /* for each end_rvs-doc */ 
      for first tt-result where tt-result.gds-code = tt-place.gds-code :
        /* Формула 1 */
        tt-result.wght-fact-end = tt-result.wght-fact-end + (tt-place.end-rvs-fact-qnty - tt-place.end-chk-fact-qnty + tt-place.end-trn-fact-qnty) .
        if abs(tt-result.wght-fact-end) < 0.001 then tt-result.wght-fact-end = 0 .
        if session:debug-alert
        then do:
          put stream OutStr-html unformatted
            "wght-fact-end Формула 1" skip
            "Резервуар: " + string(tt-place.gds-code) + " " +  string(tt-place.pl-code) + " " +  string(tt-place.pl-name) skip
            string(tt-place.end-rvs-fact-qnty) + " - " +  string (tt-place.end-chk-fact-qnty) +  " + " + string(tt-place.end-trn-fact-qnty) skip
            string(tt-result.wght-fact-end) skip
          .
        end.  
      end .
    end .
    
    for each tt-place where tt-place.is-income,
    first buf_goods no-lock where buf_goods.gds-code = tt-place.gds-code,
    first gds-prt no-lock where gds-prt.upper-code = buf_goods.prt-root,
    first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code
                                 and buf_bar-code.node-code = gds-prt.node-code
                                 and buf_bar-code.in-code = ""
                                 and buf_bar-code.part-code = ""
                                 and buf_bar-code.unit-cli = buf_goods.unit-base
    :
      for last end_rvs-doc no-lock where end_rvs-doc.obj-type = obj-type
                                     and end_rvs-doc.obj-code = obj-code
                                     and end_rvs-doc.rvs-type = {&rvs-control}
                                     and end_rvs-doc.status_  = {&fact}
                                     and ((integer(entry(1, end_rvs-doc.rvs-code, "-")) < tt-place.rvs-doc-num)
                                       or (end_rvs-doc.fact-date = tt-place.income-date and end_rvs-doc.fact-time <= tt-place.income-time))
                                     by end_rvs-doc.fact-order
                                     :
        tt-place.is-calc = true .     
        tt-place.rvs-doc-code = end_rvs-doc.rvs-code .                          
        for first end_rvs-line no-lock where end_rvs-line.obj-type  = end_rvs-doc.obj-type
                                         and end_rvs-line.obj-code  = end_rvs-doc.obj-code
                                         and end_rvs-line.rvs-code  = end_rvs-doc.rvs-code
                                         and end_rvs-line.pl-code   = tt-place.pl-code
                                         and end_rvs-line.gds-code  = tt-place.gds-code
                                         :
          tt-place.end-rvs-fact-qnty = end_rvs-line.state-measure-cli-qnty + (end_rvs-line.state-add-qnty * end_rvs-line.state-density) .
        end .
        chk-doc_ :
        for each buf_chk-doc no-lock where buf_chk-doc.obj-type = obj-type
                                       and buf_chk-doc.obj-code = obj-code
                                       and buf_chk-doc.chk-date >= end_rvs-doc.fact-date
                                       and buf_chk-doc.chk-date <= date-end
                                       :
          if buf_chk-doc.chk-date = end_rvs-doc.fact-date
          and buf_chk-doc.chk-time <= end_rvs-doc.fact-time
          then next chk-doc_ .
          
          if buf_chk-doc.chk-date = date-end
          and buf_chk-doc.chk-time > time-end
          then next chk-doc_ .  
                                       
          if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next chk-doc_ .
          
          chk-gds_ :
          for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                                         and buf_chk-gds.b-code   = buf_bar-code.b-code
                                         :
            if buf_chk-doc.out-code = ?
            then do :
              v-pl-code = findtank (buf_chk-doc.obj-type,
                                    buf_chk-doc.obj-code,
                                    buf_chk-gds.pump,
                                    buf_chk-gds.nozzle-code,
                                    buf_chk-gds.pl-code,
                                    buf_bar-code.gds-code) .
              if v-pl-code = ?
              or v-pl-code = 0
              then do :
                v-pl-code = findblockedtank (buf_chk-doc.obj-type,
                                             buf_chk-doc.obj-code,
                                             buf_chk-gds.pump,
                                             buf_chk-gds.nozzle-code,
                                             buf_chk-gds.pl-code,
                                             buf_bar-code.gds-code) .
              end .                      
            end .
            else do :
              v-pl-code = buf_chk-gds.pl-code .
            end .
            if v-pl-code <> tt-place.pl-code then next chk-gds_ .
                                           
            if not valid-density (buf_chk-gds.density, (buf_goods.unit-base = buf_goods.unit-cli))
            then do :   
              v-density = 0 . 
              if lookup({&shift-err}, buf_chk-doc.office) > 0
              then do :      
                find last buf_shift-obj no-lock where buf_shift-obj.obj-type = buf_chk-doc.obj-type
                                                  and buf_shift-obj.obj-code = buf_chk-doc.obj-code
                                                  and ((buf_shift-obj.open-date < buf_chk-doc.chk-date)
                                                    or (buf_shift-obj.open-date = buf_chk-doc.chk-date and buf_shift-obj.open-time < buf_chk-doc.chk-time))
                                                  no-error .
                if available buf_shift-obj
                then do :                                    
                  { str/avrgdens.i
                    tt-place.gds-code
                    buf_chk-doc.obj-type
                    buf_chk-doc.obj-code
                    tt-place.pl-code
                    buf_shift-obj.shift-date
                    buf_shift-obj.shift-num
                    buf_chk-doc.chk-date
                    buf_chk-doc.chk-time
                    v-density
                    v-Reconc-tank-attr
                    no-error
                  }
                end .
                else do :
                  { str/avrgdens.i
                    tt-place.gds-code
                    buf_chk-doc.obj-type
                    buf_chk-doc.obj-code
                    tt-place.pl-code
                    buf_chk-doc.chk-date
                    1
                    buf_chk-doc.chk-date
                    buf_chk-doc.chk-time
                    v-density
                    v-Reconc-tank-attr
                    no-error
                  }
                end .
              end .
              else do :
                { str/avrgdens.i
                  tt-place.gds-code
                  buf_chk-doc.obj-type
                  buf_chk-doc.obj-code
                  tt-place.pl-code
                  buf_chk-doc.shift-date
                  buf_chk-doc.shift-num
                  buf_chk-doc.chk-date
                  buf_chk-doc.chk-time
                  v-density
                  v-Reconc-tank-attr
                  no-error
                }
              end .
              tt-place.end-chk-fact-qnty = tt-place.end-chk-fact-qnty + (buf_chk-gds.doc-qnty * v-density) .
            end .
            else do :                     
              tt-place.end-chk-fact-qnty = tt-place.end-chk-fact-qnty + (buf_chk-gds.doc-qnty * buf_chk-gds.density) .   
            end .                               
          end .
        end .
        income-doc-line_ :
        for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                        and buf_doc-line.obj-code  = obj-code
                                        and buf_doc-line.artic     = buf_goods.artic
                                        and buf_doc-line.prod-type = buf_goods.prod-type
                                        and buf_doc-line.prod-code = buf_goods.prod-code
                                        and buf_doc-line.status_   = {&fact}
                                        ,
        first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                    and (buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Inv})
                                    and ((buf_trn-doc.fact-date > end_rvs-doc.fact-date) or
                                         (buf_trn-doc.fact-date = end_rvs-doc.fact-date and buf_trn-doc.fact-time >  end_rvs-doc.fact-time))
                                    and ((buf_trn-doc.fact-date < date-end) or
                                         (buf_trn-doc.fact-date = date-end and buf_trn-doc.fact-time <= time-end))
                                    :
          { str/tdat-val.i
              buf_trn-doc.doc-code
              {&trdcattr-othermoves}
              vIsOtherMoves
              vType                 }
          if vIsOtherMoves > ""
          and logical(vIsOtherMoves)
          then next income-doc-line_ .
          if buf_trn-doc.ext-doc-type <> {&TDEDT_Inv}
          then
          for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                               and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                               and buf_clients-attr.attr-code = {&attr-shftrep2}
                                               :
            /* ТехПролив */
            if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next income-doc-line_ .
          end .
          for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                        and buf_doc-pl.obj-code = obj-code
                                        and buf_doc-pl.pl-code  = tt-place.pl-code
                                        and buf_doc-pl.out-code = buf_doc-line.doc-code
                                        and buf_doc-pl.gds-code = tt-place.gds-code
                                        :
            tt-place.end-trn-fact-qnty = tt-place.end-trn-fact-qnty + buf_doc-pl.cli-fact-qnty .                              
          end .
        end . /* for each income buf_doc-line */
        expense-doc-line_ :
        for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                        and buf_doc-line.obj-code  = obj-code
                                        and buf_doc-line.artic     = buf_goods.artic
                                        and buf_doc-line.prod-type = buf_goods.prod-type
                                        and buf_doc-line.prod-code = buf_goods.prod-code
                                        and buf_doc-line.status_   = {&fact}
                                        ,
        first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                    and (buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh})
                                    and ((buf_trn-doc.fact-date > end_rvs-doc.fact-date) or
                                         (buf_trn-doc.fact-date = end_rvs-doc.fact-date and buf_trn-doc.fact-time >  end_rvs-doc.fact-time))
                                    and ((buf_trn-doc.fact-date < date-end) or
                                         (buf_trn-doc.fact-date = date-end and buf_trn-doc.fact-time <= time-end))
                                    :
          { str/tdat-val.i
              buf_trn-doc.doc-code
              {&trdcattr-othermoves}
              vIsOtherMoves
              vType                 }
          if vIsOtherMoves > ""
          and logical(vIsOtherMoves)
          then next expense-doc-line_ .
          for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                               and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                               and buf_clients-attr.attr-code = {&attr-shftrep2}
                                               :
            /* ТехПролив */
            if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next expense-doc-line_ .
          end .
          for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                        and buf_doc-pl.obj-code = obj-code
                                        and buf_doc-pl.pl-code  = tt-place.pl-code
                                        and buf_doc-pl.out-code = buf_doc-line.doc-code
                                        and buf_doc-pl.gds-code = tt-place.gds-code
                                        :
            tt-place.end-trn-fact-qnty = tt-place.end-trn-fact-qnty - buf_doc-pl.cli-fact-qnty .                              
          end .
        end . /* for each expense buf_doc-line */
      end . /* for last end_rvs-doc */ 
      for first tt-result where tt-result.gds-code = tt-place.gds-code :
        /* Формула 1 */
        tt-result.wght-fact-end = tt-result.wght-fact-end + (tt-place.end-rvs-fact-qnty - tt-place.end-chk-fact-qnty + tt-place.end-trn-fact-qnty) .
        if abs(tt-result.wght-fact-end) < 0.001 then tt-result.wght-fact-end = 0 .
        if session:debug-alert 
        then do:
          put stream OutStr-html unformatted
            "wght-fact-end Формула 1" skip
            "Резервуар: " + string(tt-place.gds-code) + " " +  string(tt-place.pl-code) + " " +  string(tt-place.pl-name) skip
            string(tt-place.end-rvs-fact-qnty) + " - " +  string (tt-place.end-chk-fact-qnty) +  " + " + string(tt-place.end-trn-fact-qnty) skip
            string(tt-result.wght-fact-end) skip
          .
        end.          
      end .
    end .
    
    for each tt-place :
      run write-to-log in p-parent-handle ("place " + string(tt-place.pl-code) + ": " + tt-place.pl-name + "; " +
                                            string(tt-place.is-income) + "; " +
                                            tt-place.rvs-doc-code + "; " + 
                                            string(tt-place.is-calc) + 
                                            (if tt-place.is-calc
                                             then
                                              ("; " +
                                               string-mth(tt-place.end-rvs-fact-qnty) + ": " +
                                               string-mth(tt-place.end-chk-fact-qnty) + ": " +
                                               string-mth(tt-place.end-trn-fact-qnty) + "; "
                                              )
                                             else "; ") + 
                                            string-mth(tt-place.end-rvs-fact-qnty - tt-place.end-chk-fact-qnty + tt-place.end-trn-fact-qnty) 
                                            ) .
    end .
    
    
    for each tt-result,
    first buf_goods no-lock where buf_goods.gds-code = tt-result.gds-code
    :
      run write-to-log in p-parent-handle ("gds " + string(tt-result.gds-code) + ": " + buf_goods.gds-name + "; " +
                                           string-mth(tt-result.wght-fact-end)
                                           ) .
    end .
    
    /* END Рассчет фактического остатка на конец периода по формулам 1 и 2 */
    run write-to-log in p-parent-handle (" END FACT-END UTC " + utc-time() ) .
    
  end method . /* stage2 */
  
  method private void stage3 () :
    define buffer buf_trn-doc for ub.trn-doc .
    define buffer buf_doc-line for ub.doc-line .
    define buffer buf_doc-pl for ub.doc-pl .
    define buffer start_rvs-doc for ub.rvs-doc .
    define buffer start_rvs-line for ub.rvs-line .
    define buffer buf_chk-doc for ub.chk-doc .
    define buffer buf_chk-gds for ub.chk-gds .
    define buffer buf_bar-code for ub.bar-code .
    define buffer buf_goods for ub.goods .
    define buffer buf_clients-attr for ub.clients-attr .
    
    define variable rvs-time-diff as integer no-undo .
    define variable exec-time-diff as integer no-undo .
    
    run write-to-log in p-parent-handle (" START FACT-BOOK-START UTC " + utc-time() ) .
    
    for each tt-place,
    first buf_goods no-lock where buf_goods.gds-code = tt-place.gds-code,
    first gds-prt no-lock where gds-prt.upper-code = buf_goods.prt-root,
    first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code
                                 and buf_bar-code.node-code = gds-prt.node-code
                                 and buf_bar-code.in-code = ""
                                 and buf_bar-code.part-code = ""
                                 and buf_bar-code.unit-cli = buf_goods.unit-base
    :
      /* START Определение книжного остатка на начало периода */
      for last start_rvs-doc no-lock where start_rvs-doc.obj-type = obj-type
                                       and start_rvs-doc.obj-code = obj-code
                                       and start_rvs-doc.rvs-type = {&rvs-shift}
                                       and start_rvs-doc.status_  = {&fact}
                                       and ((start_rvs-doc.fact-date < date-start)
                                         or (start_rvs-doc.fact-date = date-start and start_rvs-doc.fact-time <= time-start))
                                       by start_rvs-doc.fact-order
                                       :
        for first start_rvs-line no-lock where start_rvs-line.obj-type  = start_rvs-doc.obj-type
                                           and start_rvs-line.obj-code  = start_rvs-doc.obj-code
                                           and start_rvs-line.rvs-code  = start_rvs-doc.rvs-code
                                           and start_rvs-line.pl-code   = tt-place.pl-code
                                           and start_rvs-line.gds-code  = tt-place.gds-code
                                           :
          tt-place.start-rvs-doc-qnty = start_rvs-line.system-cli-qnty . 
        end .
        chk-doc_ :
        for each buf_chk-doc no-lock where buf_chk-doc.obj-type = obj-type
                                       and buf_chk-doc.obj-code = obj-code
                                       and buf_chk-doc.chk-date >= start_rvs-doc.fact-date
                                       and buf_chk-doc.chk-date <= date-start
                                       :
          if lookup({&shift-err}, buf_chk-doc.office) > 0
          or (buf_chk-doc.src-shift-date > buf_chk-doc.shift-date and buf_chk-doc.chk-date > buf_chk-doc.shift-date) /* Созданные вручную чеки в другой смене */
          or buf_chk-doc.out-code = ?
          then do :
            if buf_chk-doc.chk-date = start_rvs-doc.fact-date
            and buf_chk-doc.chk-time <= start_rvs-doc.fact-time
            then next chk-doc_ .
          end .
          else do :
            if buf_chk-doc.shift-date < start_rvs-doc.shift-date
            then next chk-doc_ .
            
            if buf_chk-doc.shift-date = start_rvs-doc.shift-date
            and buf_chk-doc.shift-num <= start_rvs-doc.shift-num
            then next chk-doc_ .
          end .
          
          if buf_chk-doc.chk-date = date-start
          and buf_chk-doc.chk-time >= time-start
          then next chk-doc_ .  
                                       
          if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next chk-doc_ .
          
          chk-gds_ :
          for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                                         and buf_chk-gds.b-code   = buf_bar-code.b-code
/*                                         and buf_chk-gds.pl-code  = tt-place.pl-code*/
                                         :
            if buf_chk-doc.out-code = ?
            then do :
              v-pl-code = findtank (buf_chk-doc.obj-type,
                                    buf_chk-doc.obj-code,
                                    buf_chk-gds.pump,
                                    buf_chk-gds.nozzle-code,
                                    buf_chk-gds.pl-code,
                                    buf_bar-code.gds-code) .
              if v-pl-code = ?
              or v-pl-code = 0
              then do :
                v-pl-code = findblockedtank (buf_chk-doc.obj-type,
                                             buf_chk-doc.obj-code,
                                             buf_chk-gds.pump,
                                             buf_chk-gds.nozzle-code,
                                             buf_chk-gds.pl-code,
                                             buf_bar-code.gds-code) .
              end .
            end .
            else do :
              v-pl-code = buf_chk-gds.pl-code .
            end .
            if v-pl-code <> tt-place.pl-code then next chk-gds_ .
            
            if not valid-density (buf_chk-gds.density, (buf_goods.unit-base = buf_goods.unit-cli))
            then do :   
              v-density = 0 .  
              if lookup({&shift-err}, buf_chk-doc.office) > 0
              then do :     
                { str/avrgdens.i
                  tt-place.gds-code
                  buf_chk-doc.obj-type
                  buf_chk-doc.obj-code
                  tt-place.pl-code
                  start_rvs-doc.shift-date
                  start_rvs-doc.shift-num
                  buf_chk-doc.chk-date
                  buf_chk-doc.chk-time
                  v-density
                  v-Reconc-tank-attr
                  no-error
                }
              end .
              else do :
                { str/avrgdens.i
                  tt-place.gds-code
                  buf_chk-doc.obj-type
                  buf_chk-doc.obj-code
                  tt-place.pl-code
                  buf_chk-doc.shift-date
                  buf_chk-doc.shift-num
                  buf_chk-doc.chk-date
                  buf_chk-doc.chk-time
                  v-density
                  v-Reconc-tank-attr
                  no-error
                }
              end .
              tt-place.start-chk-doc-qnty = tt-place.start-chk-doc-qnty + (buf_chk-gds.doc-qnty * v-density) .
              if session:debug-alert 
              then do:
                put stream OutStr-html unformatted
                  "tt-place.start-chk-doc-qnty Определение книжного остатка на начало периода" skip
                  "чек: " + buf_chk-gds.doc-code + " не валидная плотность в чеке"   skip
                  string(buf_chk-gds.doc-qnty) + " * " +  string (v-density)  skip
                  string(tt-place.start-chk-doc-qnty) skip
                .
              end.
            end .
            else do :
              tt-place.start-chk-doc-qnty = tt-place.start-chk-doc-qnty + (buf_chk-gds.doc-qnty * buf_chk-gds.density) .   
              if session:debug-alert 
              then do:
                put stream OutStr-html unformatted
                  "tt-place.start-chk-doc-qnty Определение книжного остатка на начало периода" skip
                  "чек: " + buf_chk-gds.doc-code + "    валидная плотность в чеке"  skip
                  string(buf_chk-gds.doc-qnty) + " * " +  string (buf_chk-gds.density)  skip
                  string(tt-place.start-chk-doc-qnty) skip
                .
              end.
            end .                            
          end .
        end .
        income-doc-line_ :
        for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                        and buf_doc-line.obj-code  = obj-code
                                        and buf_doc-line.artic     = buf_goods.artic
                                        and buf_doc-line.prod-type = buf_goods.prod-type
                                        and buf_doc-line.prod-code = buf_goods.prod-code
                                        and buf_doc-line.status_   = {&fact}
                                        ,
        first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                    and (buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Inv})
                                    and ((buf_trn-doc.fact-date < date-start) or
                                         (buf_trn-doc.fact-date = date-start and buf_trn-doc.fact-time <= time-start))
                                    and ((buf_trn-doc.shift-date > start_rvs-doc.shift-date) or
                                         (buf_trn-doc.shift-date = start_rvs-doc.shift-date and buf_trn-doc.shift-num > start_rvs-doc.shift-num))
        :
          if buf_trn-doc.ext-doc-type <> {&TDEDT_Inv}
          then
          for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                               and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                               and buf_clients-attr.attr-code = {&attr-shftrep2}
                                               :
            /* ТехПролив */
            if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next income-doc-line_ .
          end .
          for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                        and buf_doc-pl.obj-code = obj-code
                                        and buf_doc-pl.pl-code  = tt-place.pl-code
                                        and buf_doc-pl.out-code = buf_doc-line.doc-code
                                        and buf_doc-pl.gds-code = tt-place.gds-code
                                        :
            tt-place.start-trn-doc-qnty = tt-place.start-trn-doc-qnty + buf_doc-pl.cli-fact-qnty .                              
          end .
        end . /* for each income buf_doc-line */
        expense-doc-line_ :
        for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                        and buf_doc-line.obj-code  = obj-code
                                        and buf_doc-line.artic     = buf_goods.artic
                                        and buf_doc-line.prod-type = buf_goods.prod-type
                                        and buf_doc-line.prod-code = buf_goods.prod-code
                                        and buf_doc-line.status_   = {&fact}
                                        ,
        first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                    and (buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh})
                                    and ((buf_trn-doc.fact-date < date-start) or
                                         (buf_trn-doc.fact-date = date-start and buf_trn-doc.fact-time <= time-start))
                                    and ((buf_trn-doc.shift-date > start_rvs-doc.shift-date) or
                                         (buf_trn-doc.shift-date = start_rvs-doc.shift-date and buf_trn-doc.shift-num > start_rvs-doc.shift-num))
        :
          for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                               and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                               and buf_clients-attr.attr-code = {&attr-shftrep2}
                                               :
            /* ТехПролив */
            if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next expense-doc-line_ .
          end .
          for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                        and buf_doc-pl.obj-code = obj-code
                                        and buf_doc-pl.pl-code  = tt-place.pl-code
                                        and buf_doc-pl.out-code = buf_doc-line.doc-code
                                        and buf_doc-pl.gds-code = tt-place.gds-code
                                        :
            tt-place.start-trn-doc-qnty = tt-place.start-trn-doc-qnty - buf_doc-pl.cli-fact-qnty .                              
          end .
        end . /* for each expense buf_doc-line */
      end . /* for last start_rvs-doc */
      for first tt-result where tt-result.gds-code = tt-place.gds-code :
        /* Формула 3 */
        tt-result.wght-doc-start = tt-result.wght-doc-start + (tt-place.start-rvs-doc-qnty - tt-place.start-chk-doc-qnty + tt-place.start-trn-doc-qnty) .
        if session:debug-alert 
        then do:
          put stream OutStr-html unformatted
            "wght-doc-start Определение книжного остатка на начало периода" skip
            "Резервуар: " + string(tt-place.gds-code) + " " +  string(tt-place.pl-code) + " " +  string(tt-place.pl-name) skip
            string(tt-place.start-rvs-doc-qnty) + " - " +  string (tt-place.start-chk-doc-qnty) +  " + " + string(tt-place.end-trn-doc-qnty) skip
            string(tt-result.wght-doc-start) skip
          .
        end.          
      end .
      /* END Определение книжного остатка на начало периода */
  
      /* START Определение фактического остатка на начало периода */
      start_rvs-doc_ :
      for each start_rvs-doc no-lock where start_rvs-doc.obj-type = obj-type
                                       and start_rvs-doc.obj-code = obj-code
                                       and start_rvs-doc.rvs-type = {&rvs-control}
                                       and start_rvs-doc.status_  = {&fact}
                                       and ((start_rvs-doc.fact-date < date-start)
                                         or (start_rvs-doc.fact-date = date-start and start_rvs-doc.fact-time <= time-start))
                                       ,
      first start_rvs-line no-lock where start_rvs-line.obj-type  = start_rvs-doc.obj-type
                                     and start_rvs-line.obj-code  = start_rvs-doc.obj-code
                                     and start_rvs-line.rvs-code  = start_rvs-doc.rvs-code
                                     and start_rvs-line.pl-code   = tt-place.pl-code
                                     and start_rvs-line.gds-code  = tt-place.gds-code
                                     by start_rvs-doc.fact-order desc
      :
        if start_rvs-doc.fact-date < date-start - 2
        then do :
          leave start_rvs-doc_ .
        end .
        
        tt-place.rvs-doc-code = start_rvs-doc.rvs-code . 
        rvs-time-diff = time-start - start_rvs-doc.fact-time .
        if rvs-time-diff < 0
        then do :
          rvs-time-diff = 86400 - start_rvs-doc.fact-time + time-start .
        end .
        
        if rvs-time-diff > (rvs-doc-exist-diff * 60)
        then do :
          tt-place.start-rvs-fact-qnty = start_rvs-line.state-measure-cli-qnty + (start_rvs-line.state-add-qnty * start_rvs-line.state-density) .
          tt-place.is-calc = true .
          chk-doc_ :
          for each buf_chk-doc no-lock where buf_chk-doc.obj-type = obj-type
                                         and buf_chk-doc.obj-code = obj-code
                                         and buf_chk-doc.chk-date >= start_rvs-doc.fact-date
                                         and buf_chk-doc.chk-date <= date-start
                                         :
            if buf_chk-doc.chk-date = start_rvs-doc.fact-date
            and buf_chk-doc.chk-time <= start_rvs-doc.fact-time
            then next chk-doc_ .
            
            if buf_chk-doc.shift-date < start_rvs-doc.shift-date
            then next chk-doc_ .

            if buf_chk-doc.shift-date = start_rvs-doc.shift-date
            and buf_chk-doc.shift-num < start_rvs-doc.shift-num
            then next chk-doc_ .
            
            if buf_chk-doc.chk-date = date-start
            and buf_chk-doc.chk-time >= time-start
            then next chk-doc_ .  
                                         
            if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next chk-doc_ .
            
            chk-gds_ :
            for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                                           and buf_chk-gds.b-code   = buf_bar-code.b-code
                                           :
              if buf_chk-doc.out-code = ?
              then do :
                v-pl-code = findtank (buf_chk-doc.obj-type,
                                      buf_chk-doc.obj-code,
                                      buf_chk-gds.pump,
                                      buf_chk-gds.nozzle-code,
                                      buf_chk-gds.pl-code,
                                      buf_bar-code.gds-code) .
                if v-pl-code = ?
                or v-pl-code = 0
                then do :
                  v-pl-code = findblockedtank (buf_chk-doc.obj-type,
                                               buf_chk-doc.obj-code,
                                               buf_chk-gds.pump,
                                               buf_chk-gds.nozzle-code,
                                               buf_chk-gds.pl-code,
                                               buf_bar-code.gds-code) .
                end .
              end .
              else do :
                v-pl-code = buf_chk-gds.pl-code .
              end .
              if v-pl-code <> tt-place.pl-code then next chk-gds_ .
            
              if not valid-density (buf_chk-gds.density, (buf_goods.unit-base = buf_goods.unit-cli))
              then do :   
                v-density = 0 .  
                if lookup({&shift-err}, buf_chk-doc.office) > 0
                then do :     
                  { str/avrgdens.i
                    tt-place.gds-code
                    buf_chk-doc.obj-type
                    buf_chk-doc.obj-code
                    tt-place.pl-code
                    start_rvs-doc.shift-date
                    start_rvs-doc.shift-num
                    buf_chk-doc.chk-date
                    buf_chk-doc.chk-time
                    v-density
                    v-Reconc-tank-attr
                    no-error
                  }
                end .
                else do :
                  { str/avrgdens.i
                    tt-place.gds-code
                    buf_chk-doc.obj-type
                    buf_chk-doc.obj-code
                    tt-place.pl-code
                    buf_chk-doc.shift-date
                    buf_chk-doc.shift-num
                    buf_chk-doc.chk-date
                    buf_chk-doc.chk-time
                    v-density
                    v-Reconc-tank-attr
                    no-error
                  }
                end .
                tt-place.start-chk-fact-qnty = tt-place.start-chk-fact-qnty + (buf_chk-gds.doc-qnty * v-density) .
              end .
              else do :
                tt-place.start-chk-fact-qnty = tt-place.start-chk-fact-qnty + (buf_chk-gds.doc-qnty * buf_chk-gds.density) .   
              end . 
            end .
          end .
          income-doc-line_ :
          for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                          and buf_doc-line.obj-code  = obj-code
                                          and buf_doc-line.artic     = buf_goods.artic
                                          and buf_doc-line.prod-type = buf_goods.prod-type
                                          and buf_doc-line.prod-code = buf_goods.prod-code
                                          and buf_doc-line.status_   = {&fact}
                                          ,
          first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                      and (buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Inv})
                                      and ((buf_trn-doc.fact-date > start_rvs-doc.fact-date) or
                                           (buf_trn-doc.fact-date = start_rvs-doc.fact-date and buf_trn-doc.fact-time > start_rvs-doc.fact-time))
                                      and ((buf_trn-doc.fact-date < date-start) or
                                           (buf_trn-doc.fact-date = date-start and buf_trn-doc.fact-time <= time-start))
                                      :
            { str/tdat-val.i
                buf_trn-doc.doc-code
                {&trdcattr-othermoves}
                vIsOtherMoves
                vType                 }
            if vIsOtherMoves > ""
            and logical(vIsOtherMoves)
            then next income-doc-line_ .
            if buf_trn-doc.ext-doc-type <> {&TDEDT_Inv}
            then
            for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                                 and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                                 and buf_clients-attr.attr-code = {&attr-shftrep2}
                                                 :
              /* ТехПролив */
              if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next income-doc-line_ .
            end .
            for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                          and buf_doc-pl.obj-code = obj-code
                                          and buf_doc-pl.pl-code  = tt-place.pl-code
                                          and buf_doc-pl.out-code = buf_doc-line.doc-code
                                          and buf_doc-pl.gds-code = tt-place.gds-code
                                          :
              tt-place.start-trn-fact-qnty = tt-place.start-trn-fact-qnty + buf_doc-pl.cli-fact-qnty .                              
            end .
          end . /* for each income buf_doc-line */
          expense-doc-line_ :
          for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                          and buf_doc-line.obj-code  = obj-code
                                          and buf_doc-line.artic     = buf_goods.artic
                                          and buf_doc-line.prod-type = buf_goods.prod-type
                                          and buf_doc-line.prod-code = buf_goods.prod-code
                                          and buf_doc-line.status_   = {&fact}
                                          ,
          first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                      and (buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh})
                                      and ((buf_trn-doc.fact-date > start_rvs-doc.fact-date) or
                                           (buf_trn-doc.fact-date = start_rvs-doc.fact-date and buf_trn-doc.fact-time > start_rvs-doc.fact-time))
                                      and ((buf_trn-doc.fact-date < date-start) or
                                           (buf_trn-doc.fact-date = date-start and buf_trn-doc.fact-time <= time-start))
                                      :
            { str/tdat-val.i
                buf_trn-doc.doc-code
                {&trdcattr-othermoves}
                vIsOtherMoves
                vType                 }
            if vIsOtherMoves > ""
            and logical(vIsOtherMoves)
            then next expense-doc-line_ .
            for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                                 and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                                 and buf_clients-attr.attr-code = {&attr-shftrep2}
                                                 :
              /* ТехПролив */
              if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next expense-doc-line_ .
            end .
            for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                          and buf_doc-pl.obj-code = obj-code
                                          and buf_doc-pl.pl-code  = tt-place.pl-code
                                          and buf_doc-pl.out-code = buf_doc-line.doc-code
                                          and buf_doc-pl.gds-code = tt-place.gds-code
                                          :
              tt-place.start-trn-fact-qnty = tt-place.start-trn-fact-qnty - buf_doc-pl.cli-fact-qnty .                              
            end .
          end . /* for each expense buf_doc-line */
          for first tt-result where tt-result.gds-code = tt-place.gds-code :
            /* Формула 4 */
            tt-result.wght-fact-start = tt-result.wght-fact-start + (tt-place.start-rvs-fact-qnty - tt-place.start-chk-fact-qnty + tt-place.start-trn-fact-qnty) .
            if abs(tt-result.wght-fact-start) < 0.001 then tt-result.wght-fact-start = 0 .
            if session:debug-alert 
            then do:
              put stream OutStr-html unformatted
                "wght-fact-start Формула 4 Определение фактического остатка на начало периода is-calc = true" skip
                "Резервуар: " + string(tt-place.gds-code) + " " +  string(tt-place.pl-code) + " " +  string(tt-place.pl-name) skip
                string(tt-place.start-rvs-fact-qnty) + " - " +  string (tt-place.start-chk-fact-qnty) +  " + " + string(tt-place.start-trn-fact-qnty) skip
                string(tt-result.wght-fact-start) skip
              .
            end.          
          end .
        end .
        else do :
          tt-place.is-calc = false .
          for first tt-result where tt-result.gds-code = tt-place.gds-code :
            tt-result.wght-fact-start = tt-result.wght-fact-start + start_rvs-line.state-measure-cli-qnty + (start_rvs-line.state-add-qnty * start_rvs-line.state-density) .
            if abs(tt-result.wght-fact-start) < 0.001 then tt-result.wght-fact-start = 0 .
            if session:debug-alert 
            then do:
              put stream OutStr-html unformatted
                "wght-fact-start Формула 4 Определение фактического остатка на начало периода is-calc = false" skip
                "Резервуар: " + string(tt-place.gds-code) + " " +  string(tt-place.pl-code) + " " +  string(tt-place.pl-name) skip
                string(start_rvs-line.state-measure-cli-qnty) + " + (" +  string (start_rvs-line.state-add-qnty) +  " * " + string(start_rvs-line.state-density) + ")" skip
                string(tt-result.wght-fact-start) skip
              .
            end.                  
          end .
        end .
        leave start_rvs-doc_ .
      end .
      /* END Определение фактического остатка на начало периода */
    end . /* for each tt-place */
    
    for each tt-place :
      run write-to-log in p-parent-handle ("fact_place " + string(tt-place.pl-code) + ": " + tt-place.pl-name + "; " +
                                            string(tt-place.is-income) + "; " +
                                            tt-place.rvs-doc-code + "; " + 
                                            string(tt-place.is-calc) + 
                                            (if tt-place.is-calc
                                             then
                                              ("; " +
                                               string-mth(tt-place.start-rvs-fact-qnty) + ": " +
                                               string-mth(tt-place.start-chk-fact-qnty) + ": " +
                                               string-mth(tt-place.start-trn-fact-qnty) + "; "
                                              )
                                             else "; ") + 
                                            string-mth(tt-place.start-rvs-fact-qnty - tt-place.start-chk-fact-qnty + tt-place.start-trn-fact-qnty) 
                                            ) .
    end .
    
    for each tt-result,
    first buf_goods no-lock where buf_goods.gds-code = tt-result.gds-code
    :
      run write-to-log in p-parent-handle ("fact_gds " + string(tt-result.gds-code) + ": " + buf_goods.gds-name + "; " +
                                           string-mth(tt-result.wght-fact-start)
                                           ) .
    end .
    
    for each tt-result,
    first buf_goods no-lock where buf_goods.gds-code = tt-result.gds-code
    :
      run write-to-log in p-parent-handle ("book_gds " + string(tt-result.gds-code) + ": " + buf_goods.gds-name + "; " +
                                           string-mth(tt-result.wght-doc-start)
                                           ) .
    end .
    
    run write-to-log in p-parent-handle (" END FACT-BOOK-START UTC " + utc-time() ) .
    
  end method . /* stage3 */
  
  method private void stage4 () :
    define buffer buf_trn-doc for ub.trn-doc .
    define buffer buf_doc-attr for ub.doc-attr .
    define buffer buf_doc-line for ub.doc-line .
    define buffer buf_doc-pl for ub.doc-pl .
    define buffer buf_chk-doc for ub.chk-doc .
    define buffer buf_chk-gds for ub.chk-gds .
    define buffer buf_bar-code for ub.bar-code .
    define buffer buf_goods for ub.goods .
    define buffer buf_clients-attr for ub.clients-attr .
    define buffer buf_inv-line for ub.inv-line .
    define buffer buf_shift-obj for ub.shift-obj .
    
    define variable v-is-npz    as logical no-undo .
    define variable v-is-own    as logical no-undo .
    define variable v-is-own-nb as logical no-undo .
    
    define variable v-nb-obj-type as character no-undo .
    define variable v-nb-obj-code as integer no-undo .
    
    run write-to-log in p-parent-handle (" START TURNOVER UTC " + utc-time() ) .
    
    /* START Прием чеков */
    if not checks-recieved
    and not otherOneDate
    then
      checks-recieved = get-check() .
    /* END Прием чеков */
    
    /* START Расчет реализации */
    chk-doc_ :
    for each buf_chk-doc no-lock where buf_chk-doc.obj-type = obj-type
                                   and buf_chk-doc.obj-code = obj-code
                                   and buf_chk-doc.chk-date >= date-start
                                   and buf_chk-doc.chk-date <= date-end
                                   :
      if buf_chk-doc.chk-date = date-start
      and buf_chk-doc.chk-time < time-start
      then next chk-doc_ .
      
      if buf_chk-doc.chk-date = date-end
      and buf_chk-doc.chk-time > time-end
      then next chk-doc_ .  
                                   
      if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next chk-doc_ .
      
      chk-gds_ :
      for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code,
      first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code,
      first tt-result where tt-result.gds-code = buf_bar-code.gds-code
      :
        if not valid-density (buf_chk-gds.density, false)
        then do :
          if buf_chk-doc.out-code = ?
          then do :
            v-pl-code = findtank (buf_chk-doc.obj-type,
                                  buf_chk-doc.obj-code,
                                  buf_chk-gds.pump,
                                  buf_chk-gds.nozzle-code,
                                  buf_chk-gds.pl-code,
                                  buf_bar-code.gds-code) .
            if v-pl-code = ?
            or v-pl-code = 0
            then do :
              v-pl-code = findblockedtank (buf_chk-doc.obj-type,
                                           buf_chk-doc.obj-code,
                                           buf_chk-gds.pump,
                                           buf_chk-gds.nozzle-code,
                                           buf_chk-gds.pl-code,
                                           buf_bar-code.gds-code) .
            end .
          end .
          else do :
            v-pl-code = buf_chk-gds.pl-code .
          end .
          v-density = 0 .  
          if lookup({&shift-err}, buf_chk-doc.office) > 0
          then do :     
            find last buf_shift-obj no-lock where buf_shift-obj.obj-type = buf_chk-doc.obj-type
                                              and buf_shift-obj.obj-code = buf_chk-doc.obj-code
                                              and ((buf_shift-obj.open-date < buf_chk-doc.chk-date)
                                                or (buf_shift-obj.open-date = buf_chk-doc.chk-date and buf_shift-obj.open-time < buf_chk-doc.chk-time))
                                              no-error .
            if available buf_shift-obj
            then do :                                    
              { str/avrgdens.i
                tt-result.gds-code
                buf_chk-doc.obj-type
                buf_chk-doc.obj-code
                v-pl-code
                buf_shift-obj.shift-date
                buf_shift-obj.shift-num
                buf_chk-doc.chk-date
                buf_chk-doc.chk-time
                v-density
                v-Reconc-tank-attr
                no-error
              }
            end .
            else do :
              { str/avrgdens.i
                tt-result.gds-code
                buf_chk-doc.obj-type
                buf_chk-doc.obj-code
                v-pl-code
                buf_chk-doc.chk-date
                1
                buf_chk-doc.chk-date
                buf_chk-doc.chk-time
                v-density
                v-Reconc-tank-attr
                no-error
              }
            end .
          end .
          else do :
            { str/avrgdens.i
              tt-result.gds-code
              buf_chk-doc.obj-type
              buf_chk-doc.obj-code
              v-pl-code
              buf_chk-doc.shift-date
              buf_chk-doc.shift-num
              buf_chk-doc.chk-date
              buf_chk-doc.chk-time
              v-density
              v-Reconc-tank-attr
              no-error
            }
          end .
          /* Формула 6 */
          tt-result.wght-sale = tt-result.wght-sale + (buf_chk-gds.doc-qnty * v-density) .
          if session:debug-alert
          then do:
            put stream OutStr-html unformatted
              "wght-sale Формула 6 Расчет реализации" skip
              "Чек: " + string(buf_chk-gds.doc-code) + " " +  string(buf_chk-doc.chk-type) + " " + string(buf_chk-gds.b-code) skip
              string(buf_chk-gds.doc-qnty) + " * " +  string (v-density) skip
              string(tt-result.wght-sale) skip
            .
          end.                
        end .
        else do :
          /* Формула 6 */
          tt-result.wght-sale = tt-result.wght-sale + (buf_chk-gds.doc-qnty * buf_chk-gds.density) .  
          if session:debug-alert 
          then do:
            put stream OutStr-html unformatted
              "wght-sale Формула 6 Расчет реализации" skip
              "Чек: " + string(buf_chk-gds.doc-code) + " " +  string(buf_chk-doc.chk-type) + " " + string(buf_chk-gds.b-code) skip
              string(buf_chk-gds.doc-qnty) + " * " +  string (buf_chk-gds.density) skip
              string(tt-result.wght-sale) skip
            .
          end.                
        end .                             
      end .
    end .
    /* END Расчет реализации */
    
    /* START Расчет поступлений */
    for each tt-result,
    first buf_goods no-lock where buf_goods.gds-code = tt-result.gds-code
    :
      income-doc-line_ :
      for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                      and buf_doc-line.obj-code  = obj-code
                                      and buf_doc-line.artic     = buf_goods.artic
                                      and buf_doc-line.prod-type = buf_goods.prod-type
                                      and buf_doc-line.prod-code = buf_goods.prod-code
                                      and buf_doc-line.status_   = {&fact}
                                      ,
      first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                  and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
                                  and ((buf_trn-doc.fact-date > date-start) or
                                       (buf_trn-doc.fact-date = date-start and buf_trn-doc.fact-time >= time-start))
                                  and ((buf_trn-doc.fact-date < date-end) or
                                       (buf_trn-doc.fact-date = date-end and buf_trn-doc.fact-time <= time-end))
                                  :
        { str/tdat-val.i
            buf_trn-doc.doc-code
            {&trdcattr-othermoves}
            vIsOtherMoves
            vType                 }
        if vIsOtherMoves > ""
        and logical(vIsOtherMoves)
        then next income-doc-line_ .
        for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                             and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                             and buf_clients-attr.attr-code = {&attr-shftrep2}
                                             :
          /* ТехПролив */
          if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next income-doc-line_ .
        end .
        assign
          v-is-npz = false
          v-is-own = false
          v-is-own-nb  = false
        .
/*        ЗИ 7700238152: ИЗМЕНЕНИЯ АЛГОРИТМА РАЗДЕЛЕНИЯ ПОСТАВОК ПМ                                                */
/*        for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type               */
/*                                             and buf_clients-attr.obj-code  = buf_trn-doc.cli-code               */
/*                                             and buf_clients-attr.attr-code = {&attr-NPZ}                        */
/*                                             :                                                                   */
/*          if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then v-is-npz = true . else v-is-npz = false .*/
/*        end .                                                                                                    */
        for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                             and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                             and buf_clients-attr.attr-code = {&attr-own-supp}
                                             :
          if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then v-is-own = true . else v-is-own = false .
        end .
        for first buf_doc-attr where buf_doc-attr.doc-code  = buf_trn-doc.doc-code
                                 and buf_doc-attr.attr-code = {&trdcattr-ptbobj}
                                 :
          assign
            v-nb-obj-type = entry(1, buf_doc-attr.attr-value, ";")
            v-nb-obj-code = integer(entry(2, buf_doc-attr.attr-value, ";"))
          no-error .                         
        end .
        for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = v-nb-obj-type
                                             and buf_clients-attr.obj-code  = v-nb-obj-code
                                             and buf_clients-attr.attr-code = {&attr-owner-code}
                                             :
          if (buf_clients-attr.attr-value = {&cmp} + string(buf_trn-doc.host-code)) then v-is-own-nb = true . else v-is-own-nb = false .
        end .
/*        ЗИ 7700238152: ИЗМЕНЕНИЯ АЛГОРИТМА РАЗДЕЛЕНИЯ ПОСТАВОК ПМ*/
        for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = v-nb-obj-type
                                             and buf_clients-attr.obj-code  = v-nb-obj-code
                                             and buf_clients-attr.attr-code = {&attr-NPZ}
                                             :
          if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then v-is-npz = true . else v-is-npz = false .
        end .
        if ABS((buf_doc-line.fact-qnty * buf_doc-line.fact-density) - buf_doc-line.cli-qnty) < 0.002
        then do :
          /* Формула 7 */
          tt-result.delivery = tt-result.delivery + buf_doc-line.cli-qnty .
          if v-is-npz
          then do :
            tt-result.direct-delivery = tt-result.direct-delivery + buf_doc-line.cli-qnty .
          end .
          else
          if v-is-own
          then do :
            if v-is-own-nb
            then do :
              tt-result.delivery-own-pnpo = tt-result.delivery-own-pnpo + buf_doc-line.cli-qnty .
            end .
            else do :
              tt-result.delivery-other-pnpo = tt-result.delivery-other-pnpo + buf_doc-line.cli-qnty .
            end .
          end .
          else do :
            tt-result.delivery-other = tt-result.delivery-other + buf_doc-line.cli-qnty .
          end .
        end .
        else do :
          for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                        and buf_doc-pl.obj-code = obj-code
                                        and buf_doc-pl.out-code = buf_doc-line.doc-code
                                        and buf_doc-pl.gds-code = tt-result.gds-code
                                        :
            tt-result.delivery = tt-result.delivery + buf_doc-pl.cli-fact-qnty .
            if v-is-npz
            then do :
              tt-result.direct-delivery = tt-result.direct-delivery + buf_doc-pl.cli-fact-qnty .
            end .
            else
            if v-is-own
            then do :
              if v-is-own-nb
              then do :
                tt-result.delivery-own-pnpo = tt-result.delivery-own-pnpo + buf_doc-pl.cli-fact-qnty .
              end .
              else do :
                tt-result.delivery-other-pnpo = tt-result.delivery-other-pnpo + buf_doc-pl.cli-fact-qnty .
              end .
            end .
            else do :
              tt-result.delivery-other = tt-result.delivery-other + buf_doc-pl.cli-fact-qnty .
            end .
          end .
        end .
      end . /* for each income buf_doc-line */
    end .
    /* END Расчет поступлений */
    
    /* START Расчет прочих перемещений */
    for each tt-result,
    first buf_goods no-lock where buf_goods.gds-code = tt-result.gds-code
    :
      income-doc-line_ :
      for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                      and buf_doc-line.obj-code  = obj-code
                                      and buf_doc-line.artic     = buf_goods.artic
                                      and buf_doc-line.prod-type = buf_goods.prod-type
                                      and buf_doc-line.prod-code = buf_goods.prod-code
                                      and buf_doc-line.status_   = {&fact}
                                      ,
      first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                  and (buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Inv})
                                  and ((buf_trn-doc.fact-date > date-start) or
                                       (buf_trn-doc.fact-date = date-start and buf_trn-doc.fact-time >= time-start))
                                  and ((buf_trn-doc.fact-date < date-end) or
                                       (buf_trn-doc.fact-date = date-end and buf_trn-doc.fact-time <= time-end))
                                  :
        { str/tdat-val.i
            buf_trn-doc.doc-code
            {&trdcattr-othermoves}
            vIsOtherMoves
            vType                 }
        if vIsOtherMoves > ""
        and logical(vIsOtherMoves)
        then do :
          for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                        and buf_doc-pl.obj-code = obj-code
                                        and buf_doc-pl.out-code = buf_doc-line.doc-code
                                        and buf_doc-pl.gds-code = tt-result.gds-code
                                        :
            tt-result.othermoves = tt-result.othermoves + buf_doc-pl.cli-fact-qnty .                              
          end .
        end .
      end .
      
      expense-doc-line_ :
      for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                      and buf_doc-line.obj-code  = obj-code
                                      and buf_doc-line.artic     = buf_goods.artic
                                      and buf_doc-line.prod-type = buf_goods.prod-type
                                      and buf_doc-line.prod-code = buf_goods.prod-code
                                      and buf_doc-line.status_   = {&fact}
                                      ,
      first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                  and (buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh})
                                  and ((buf_trn-doc.fact-date > date-start) or
                                       (buf_trn-doc.fact-date = date-start and buf_trn-doc.fact-time >= time-start))
                                  and ((buf_trn-doc.fact-date < date-end) or
                                       (buf_trn-doc.fact-date = date-end and buf_trn-doc.fact-time <= time-end))
                                  :
        { str/tdat-val.i
            buf_trn-doc.doc-code
            {&trdcattr-othermoves}
            vIsOtherMoves
            vType                 }
        if vIsOtherMoves > ""
        and logical(vIsOtherMoves)
        then do :
          for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                        and buf_doc-pl.obj-code = obj-code
                                        and buf_doc-pl.out-code = buf_doc-line.doc-code
                                        and buf_doc-pl.gds-code = tt-result.gds-code
                                        :
            tt-result.othermoves = tt-result.othermoves - buf_doc-pl.cli-fact-qnty .                              
          end .
        end .
      end .
      
    end .
    /* END Расчет прочих перемещений */
    
    /* START Расчет излишек/недостач */
    for each tt-result,
    first buf_goods no-lock where buf_goods.gds-code = tt-result.gds-code
    :
      income-doc-line_ :
      for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                      and buf_doc-line.obj-code  = obj-code
                                      and buf_doc-line.artic     = buf_goods.artic
                                      and buf_doc-line.prod-type = buf_goods.prod-type
                                      and buf_doc-line.prod-code = buf_goods.prod-code
                                      and buf_doc-line.status_   = {&fact}
                                      ,
      first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                  and buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh}
                                  and ((buf_trn-doc.fact-date > date-start) or
                                       (buf_trn-doc.fact-date = date-start and buf_trn-doc.fact-time >= time-start))
                                  and ((buf_trn-doc.fact-date < date-end) or
                                       (buf_trn-doc.fact-date = date-end and buf_trn-doc.fact-time <= time-end))
                                  :
        { str/tdat-val.i
            buf_trn-doc.doc-code
            {&trdcattr-othermoves}
            vIsOtherMoves
            vType                 }
        if vIsOtherMoves > ""
        and logical(vIsOtherMoves)
        then next income-doc-line_ .
        for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                             and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                             and buf_clients-attr.attr-code = {&attr-shftrep2}
                                             :
          /* ТехПролив */
          if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next income-doc-line_ .
        end .
        /* Формула 8 */
        find first buf_inv-line no-lock where buf_inv-line.doc-code  = buf_doc-line.doc-code
                                          and buf_inv-line.artic     = buf_doc-line.artic    
                                          and buf_inv-line.prod-code = buf_doc-line.prod-code
                                          and buf_inv-line.prod-type = buf_doc-line.prod-type
                                          no-error .
        if available buf_inv-line
        then do :                                
          tt-result.Delivery-ned-izl = tt-result.Delivery-ned-izl + (buf_inv-line.wast-cli-qnty - buf_doc-line.cli-qnty) .
        end .       
        else do :
          tt-result.Delivery-ned-izl = tt-result.Delivery-ned-izl + ((buf_doc-line.fact-qnty * buf_doc-line.fact-density) - buf_doc-line.cli-qnty) .
        end .       
        if abs(tt-result.Delivery-ned-izl) < 0.002
        then do :
          tt-result.Delivery-ned-izl = 0 .
        end .                
      end . /* for each income buf_doc-line */
    end .
    /* END Расчет излишек/недостач */
    
    for each tt-result,
    first buf_goods no-lock where buf_goods.gds-code = tt-result.gds-code
    :
      run write-to-log in p-parent-handle ("gds " + string(tt-result.gds-code) + ": " + buf_goods.gds-name + "; " +
                                           string-mth(tt-result.delivery) + "; " +
                                           string-mth(tt-result.Delivery-ned-izl) + "; " +
                                           string-mth(tt-result.wght-sale)
                                           ) .
    end .
    
    run write-to-log in p-parent-handle (" END TURNOVER UTC " + utc-time() ) .
    
  end method . /* stage4 */
  
  method private void stage5 () :
    define buffer buf_trn-doc for ub.trn-doc .
    define buffer buf_doc-line for ub.doc-line .
    define buffer buf_doc-pl for ub.doc-pl .
    define buffer end_rvs-doc for ub.rvs-doc .
    define buffer end_rvs-line for ub.rvs-line .
    define buffer buf_chk-doc for ub.chk-doc .
    define buffer buf_chk-gds for ub.chk-gds .
    define buffer buf_bar-code for ub.bar-code .
    define buffer buf_goods for ub.goods .
    define buffer buf_clients-attr for ub.clients-attr .
    define buffer buf_shift-obj for ub.shift-obj .
    define buffer buf_goods-attr for ub.goods-attr .
    
    run write-to-log in p-parent-handle (" START BOOK-END UTC " + utc-time() ) .
      
    /* START Определение книжного остатка на конец периода */
    for each tt-place,
    first buf_goods no-lock where buf_goods.gds-code = tt-place.gds-code,
    first gds-prt no-lock where gds-prt.upper-code = buf_goods.prt-root,
    first buf_bar-code no-lock where buf_bar-code.gds-code = buf_goods.gds-code
                                 and buf_bar-code.node-code = gds-prt.node-code
                                 and buf_bar-code.in-code = ""
                                 and buf_bar-code.part-code = ""
                                 and buf_bar-code.unit-cli = buf_goods.unit-base
    :
      for last end_rvs-doc no-lock where end_rvs-doc.obj-type = obj-type
                                       and end_rvs-doc.obj-code = obj-code
                                       and end_rvs-doc.rvs-type = {&rvs-shift}
                                       and end_rvs-doc.status_  = {&fact}
                                       and ((end_rvs-doc.fact-date < date-end)
                                         or (end_rvs-doc.fact-date = date-end and end_rvs-doc.fact-time <= time-end))
                                       by end_rvs-doc.fact-order
                                       :
        for first end_rvs-line no-lock where end_rvs-line.obj-type  = end_rvs-doc.obj-type
                                           and end_rvs-line.obj-code  = end_rvs-doc.obj-code
                                           and end_rvs-line.rvs-code  = end_rvs-doc.rvs-code
                                           and end_rvs-line.pl-code   = tt-place.pl-code
                                           and end_rvs-line.gds-code  = tt-place.gds-code
                                           :
          tt-place.end-rvs-doc-qnty = end_rvs-line.system-cli-qnty . 
        end .
        chk-doc_ :
        for each buf_chk-doc no-lock where buf_chk-doc.obj-type = obj-type
                                       and buf_chk-doc.obj-code = obj-code
                                       and buf_chk-doc.chk-date >= end_rvs-doc.fact-date
                                       and buf_chk-doc.chk-date <= date-end
                                       :
          if lookup({&shift-err}, buf_chk-doc.office) > 0
          or (buf_chk-doc.src-shift-date > buf_chk-doc.shift-date and buf_chk-doc.chk-date > buf_chk-doc.shift-date) /* Созданные вручную чеки в другой смене */
          or buf_chk-doc.out-code = ?
          then do :                               
            if buf_chk-doc.chk-date = end_rvs-doc.fact-date
            and buf_chk-doc.chk-time <= end_rvs-doc.fact-time
            then next chk-doc_ .
          end .
          else do :
            if buf_chk-doc.shift-date < end_rvs-doc.shift-date
            then next chk-doc_ .
            
            if buf_chk-doc.shift-date = end_rvs-doc.shift-date
            and buf_chk-doc.shift-num <= end_rvs-doc.shift-num
            then next chk-doc_ .
          end .
          
          if buf_chk-doc.chk-date = date-end
          and buf_chk-doc.chk-time > time-end
          then next chk-doc_ .  
                                       
          if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next chk-doc_ .
          
          chk-gds_ :
          for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code
                                         and buf_chk-gds.b-code   = buf_bar-code.b-code
                                         :
            if buf_chk-doc.out-code = ?
            then do :
              v-pl-code = findtank (buf_chk-doc.obj-type,
                                    buf_chk-doc.obj-code,
                                    buf_chk-gds.pump,
                                    buf_chk-gds.nozzle-code,
                                    buf_chk-gds.pl-code,
                                    buf_bar-code.gds-code) .
              if v-pl-code = ?
              or v-pl-code = 0
              then do :
                v-pl-code = findblockedtank (buf_chk-doc.obj-type,
                                             buf_chk-doc.obj-code,
                                             buf_chk-gds.pump,
                                             buf_chk-gds.nozzle-code,
                                             buf_chk-gds.pl-code,
                                             buf_bar-code.gds-code) .
              end .
            end .
            else do :
              v-pl-code = buf_chk-gds.pl-code .
            end .
            if v-pl-code <> tt-place.pl-code then next chk-gds_ .
            
            if not valid-density (buf_chk-gds.density, (buf_goods.unit-base = buf_goods.unit-cli))
            then do :   
              v-density = 0 .    
              if lookup({&shift-err}, buf_chk-doc.office) > 0
              then do :   
                find last buf_shift-obj no-lock where buf_shift-obj.obj-type = buf_chk-doc.obj-type
                                                  and buf_shift-obj.obj-code = buf_chk-doc.obj-code
                                                  and ((buf_shift-obj.open-date < buf_chk-doc.chk-date)
                                                    or (buf_shift-obj.open-date = buf_chk-doc.chk-date and buf_shift-obj.open-time < buf_chk-doc.chk-time))
                                                  no-error .
                if available buf_shift-obj
                then do :                                    
                  { str/avrgdens.i
                    tt-place.gds-code
                    buf_chk-doc.obj-type
                    buf_chk-doc.obj-code
                    tt-place.pl-code
                    buf_shift-obj.shift-date
                    buf_shift-obj.shift-num
                    buf_chk-doc.chk-date
                    buf_chk-doc.chk-time
                    v-density
                    v-Reconc-tank-attr
                    no-error
                  }
                end .
                else do :
                  { str/avrgdens.i
                    tt-place.gds-code
                    buf_chk-doc.obj-type
                    buf_chk-doc.obj-code
                    tt-place.pl-code
                    buf_chk-doc.chk-date
                    1
                    buf_chk-doc.chk-date
                    buf_chk-doc.chk-time
                    v-density
                    v-Reconc-tank-attr
                    no-error
                  }
                end .
              end .
              else do :
                { str/avrgdens.i
                  tt-place.gds-code
                  buf_chk-doc.obj-type
                  buf_chk-doc.obj-code
                  tt-place.pl-code
                  buf_chk-doc.shift-date
                  buf_chk-doc.shift-num
                  buf_chk-doc.chk-date
                  buf_chk-doc.chk-time
                  v-density
                  v-Reconc-tank-attr
                  no-error
                }
              end .
              tt-place.end-chk-doc-qnty = tt-place.end-chk-doc-qnty + (buf_chk-gds.doc-qnty * v-density) .
            end .
            else do :                               
              tt-place.end-chk-doc-qnty = tt-place.end-chk-doc-qnty + (buf_chk-gds.doc-qnty * buf_chk-gds.density) . 
            end .                              
          end .
        end .
        income-doc-line_ :
        for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                        and buf_doc-line.obj-code  = obj-code
                                        and buf_doc-line.artic     = buf_goods.artic
                                        and buf_doc-line.prod-type = buf_goods.prod-type
                                        and buf_doc-line.prod-code = buf_goods.prod-code
                                        and buf_doc-line.status_   = {&fact}
                                        ,
        first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                    and (buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Vnesh} or buf_trn-doc.ext-doc-type = {&TDEDT_Pri_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Inv})
                                    and ((buf_trn-doc.fact-date < date-end) or
                                         (buf_trn-doc.fact-date = date-end and buf_trn-doc.fact-time <= time-end))
                                    and ((buf_trn-doc.shift-date > end_rvs-doc.shift-date) or
                                         (buf_trn-doc.shift-date = end_rvs-doc.shift-date and buf_trn-doc.shift-num > end_rvs-doc.shift-num))
        :
          if buf_trn-doc.ext-doc-type <> {&TDEDT_Inv}
          then                            
          for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                               and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                               and buf_clients-attr.attr-code = {&attr-shftrep2}
                                               :
            /* ТехПролив */
            if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next income-doc-line_ .
          end .
          for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                        and buf_doc-pl.obj-code = obj-code
                                        and buf_doc-pl.pl-code  = tt-place.pl-code
                                        and buf_doc-pl.out-code = buf_doc-line.doc-code
                                        and buf_doc-pl.gds-code = tt-place.gds-code
                                        :
            tt-place.end-trn-doc-qnty = tt-place.end-trn-doc-qnty + buf_doc-pl.cli-fact-qnty .                              
          end .
        end . /* for each income buf_doc-line */
        expense-doc-line_ :
        for each buf_doc-line no-lock where buf_doc-line.obj-type  = obj-type
                                        and buf_doc-line.obj-code  = obj-code
                                        and buf_doc-line.artic     = buf_goods.artic
                                        and buf_doc-line.prod-type = buf_goods.prod-type
                                        and buf_doc-line.prod-code = buf_goods.prod-code
                                        and buf_doc-line.status_   = {&fact}
                                        ,
        first buf_trn-doc no-lock where buf_trn-doc.doc-code = buf_doc-line.doc-code
                                    and (buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Vnesh_VP} or buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh})
                                    and ((buf_trn-doc.fact-date < date-end) or
                                         (buf_trn-doc.fact-date = date-end and buf_trn-doc.fact-time <= time-end))
                                    and ((buf_trn-doc.shift-date > end_rvs-doc.shift-date) or
                                         (buf_trn-doc.shift-date = end_rvs-doc.shift-date and buf_trn-doc.shift-num > end_rvs-doc.shift-num))
        :
          for first buf_clients-attr no-lock where buf_clients-attr.obj-type  = buf_trn-doc.cli-type
                                               and buf_clients-attr.obj-code  = buf_trn-doc.cli-code
                                               and buf_clients-attr.attr-code = {&attr-shftrep2}
                                               :
            /* ТехПролив */
            if lookup(buf_clients-attr.attr-value, 'true,yes':u) > 0 then next expense-doc-line_ .
          end .
          for each buf_doc-pl no-lock where buf_doc-pl.obj-type = obj-type
                                        and buf_doc-pl.obj-code = obj-code
                                        and buf_doc-pl.pl-code  = tt-place.pl-code
                                        and buf_doc-pl.out-code = buf_doc-line.doc-code
                                        and buf_doc-pl.gds-code = tt-place.gds-code
                                        :
            tt-place.end-trn-doc-qnty = tt-place.end-trn-doc-qnty - buf_doc-pl.cli-fact-qnty .                              
          end .
        end . /* for each expense buf_doc-line */
      end . /* for last end_rvs-doc */
      for first tt-result where tt-result.gds-code = tt-place.gds-code :
        /* Формула 9 */
        tt-result.wght-doc-end = tt-result.wght-doc-end + (tt-place.end-rvs-doc-qnty - tt-place.end-chk-doc-qnty + tt-place.end-trn-doc-qnty) .
        if session:debug-alert 
        then  do:
          put stream OutStr-html unformatted
            "wght-doc-end Формула 9 Определение книжного остатка на конец периода" skip
            "Резервуар: " + string(tt-place.gds-code) + " " +  string(tt-place.pl-code) + " " +  string(tt-place.pl-name) skip
            string(tt-place.end-rvs-doc-qnty) + " - " +  string (tt-place.end-chk-doc-qnty) +  " + " + string(tt-place.end-trn-doc-qnty) skip
            string(tt-result.wght-doc-end) skip
          .
        end.               
      end .
    end .
    /* END Определение книжного остатка на конец периода */
    
    for each tt-result where (tt-result.wght-doc-end = 0 or tt-result.wght-doc-end = ?)
                         and (tt-result.wght-doc-start = 0 or tt-result.wght-doc-start = ?)
                         and tt-result.change-place
                          :
      delete tt-result .    
    end .
    
    for each tt-result where tt-result.change-place :
      if tt-result.wght-doc-end = 0 then tt-result.wght-fact-end = 0 .
    end .
    
    /* START Расчет расхода на прочие нужды */
    for each tt-result :
      /* Формула 10 */
      tt-result.wght-other = tt-result.wght-doc-end - tt-result.wght-doc-start - tt-result.delivery + tt-result.wght-sale - tt-result.othermoves .
      if session:debug-alert 
      then do:
        put stream OutStr-html unformatted
          "wght-other Формула 10 Расчет расхода на прочие нужды" skip
          "Товар: " + string(tt-result.gds-code) + " " +  string(tt-result.gds-name) skip
          string(tt-result.wght-doc-end) + " - " +  string (tt-result.wght-doc-start) +  " - " + string(tt-result.delivery) + " + " + string (tt-result.wght-sale) skip
          string(tt-result.wght-other) skip
        .
      end.               
      tt-result.loss-own-needs = tt-result.wght-fact-end - tt-result.wght-doc-end .
    end .
    /* END Расчет расхода на прочие нужды */
    
    /* Метан (КПГ) BTS-1056 */
    for each tt-result,
    first buf_goods-attr no-lock where buf_goods-attr.gds-code = tt-result.gds-code
                                   and buf_goods-attr.attr-code = {&attr-fuel-type}
    :
      if buf_goods-attr.attr-value = {&attr-fuel-type_metan}
      then do :
        assign
          tt-result.wght-doc-start = 0
          tt-result.wght-fact-start = 0
          tt-result.wght-doc-end = 0
          tt-result.wght-fact-end = 0
          tt-result.Delivery-ned-izl = 0
        .
      end .
    end .
    
    for each tt-result,
    first buf_goods no-lock where buf_goods.gds-code = tt-result.gds-code
    :
      run write-to-log in p-parent-handle ("book_gds " + string(tt-result.gds-code) + ": " + buf_goods.gds-name + "; " +
                                           string-mth(tt-result.wght-doc-end) + "; " +
                                           string-mth(tt-result.wght-other)
                                           ) .
    end .
    
    if (is-full or is-full-backdate)
    and not otherOneDate
    then do :
      find first buf_clients-attr exclusive-lock where buf_clients-attr.obj-type = buf_clients.obj-type
                                                   and buf_clients-attr.obj-code = buf_clients.obj-code
                                                   and buf_clients-attr.attr-code = {&attr-exp-isPM-last-date}
                                                   no-error .
      if not available buf_clients-attr
      then do :
        create buf_clients-attr .
        assign
          buf_clients-attr.obj-type = buf_clients.obj-type       
          buf_clients-attr.obj-code = buf_clients.obj-code       
          buf_clients-attr.attr-code = {&attr-exp-isPM-last-date}
        .
      end .
      buf_clients-attr.attr-value = string(vMoscowDate) .
      last-exp-date = vMoscowDate .
    end .
    
    run write-to-log in p-parent-handle (" END BOOK-END UTC " + utc-time() ) .
    
  end method . /* stage5 */
  
  method private character make-rvs-doc () :
    define variable v-new-rvs-code as character no-undo init ? .
    run str/rvs-auto-is_PM.p (
                              input parparentproc,
                              input obj-type,
                              input obj-code,
                              output v-new-rvs-code)
    no-error .
    if error-status:error
    or v-new-rvs-code = ?
    then do :
      return "error" .
    end .
    
    return v-new-rvs-code .
    
  end method . /* make-rvs-doc */
  
  method private logical get-check () :
    define variable v-parameter as character no-undo .
    assign
      v-parameter =
                     obj-type         + {&delim-par} +
                     string(obj-code) + {&delim-par} +
                     string(0)        + {&delim-par} +
                     string(1)
    .
    run str/get-chkf.p (
                        input parparentproc, /*parparentproc a*/
                        input p-parent-handle, /*p-parent-handle*/
                        input parparentproc, /*p-log-handle*/
                        input v-parameter /*p-parameter*/)
    no-error .
    if error-status:error then do:
      return false .
    end .
    return true .
  end method . /* get-check */
  
  method private memptr create-esys-data () :
    define variable sw as handle no-undo.
    define variable ii as integer no-undo .
    define variable currMoscowTime as integer no-undo .
    define variable currMoscowDate as date no-undo .
    
    currMoscowTime = time - (timezone-diff * 60) .
    if currMoscowTime < 0
    then do :
      currMoscowTime = currMoscowTime + 86400 .
    end .
    
    currMoscowDate = date(now - (timezone-diff * 60 * 1000)) .
    
    create sax-writer sw.
    sw:set-output-destination ("memptr", Data).
    sw:encoding = "UTF-8".
    sw:fragment = true .
    sw:formatted = true .
    sw:start-document () .
      sw:start-element ("operating-balance") .
        sw:write-data-element ("org-unit-code", string(buf_clients.host-code)).
        sw:write-data-element ("azk-code", string(buf_clients.obj-code)). 
        sw:write-data-element ("doc-date", (iso-date(currMoscowDate) + "T" + string(currMoscowTime, "HH:MM:SS")) ).
        sw:write-data-element ("start-date", (iso-date(vMoscowDate) + "T" + string(0, "HH:MM:SS")) ).
        sw:write-data-element ("end-date", (iso-date(vMoscowDate) + "T" + string(vMoscowTimeEnd, "HH:MM:SS")) ).
        sw:start-element ("gds") .
        ii = 0 .
        for each tt-result by tt-result.gds-code :
          sw:start-element ("gd") .
            ii = ii + 1 .
            sw:write-data-element ("line-num",  string(ii)).
            sw:write-data-element ("gd-code",   string(tt-result.gds-code)).
            sw:write-data-element ("wght-fact-start",     string-mth(tt-result.wght-fact-start)).
            sw:write-data-element ("wght-fact-end",       string-mth(tt-result.wght-fact-end)).
            sw:write-data-element ("wght-doc-start",      string-mth(tt-result.wght-doc-start)).
            sw:write-data-element ("wght-doc-end",        string-mth(tt-result.wght-doc-end)).
            sw:write-data-element ("delivery",            string-mth(tt-result.delivery)).
            sw:write-data-element ("delivery-own-pnpo",   string-mth(tt-result.delivery-own-pnpo)).
            sw:write-data-element ("delivery-other-pnpo", string-mth(tt-result.delivery-other-pnpo)).
            sw:write-data-element ("delivery-other",      string-mth(tt-result.delivery-other)).
            sw:write-data-element ("direct-delivery",     string-mth(tt-result.direct-delivery)).
            sw:write-data-element ("fuel-in-transit",     string-mth(tt-result.fuel-in-transit)).
            sw:write-data-element ("wght-sale",           string-mth(tt-result.wght-sale)).
            sw:write-data-element ("wght-wholesale",      string-mth(tt-result.wght-wholesale)).
            sw:write-data-element ("loss-own-needs",      string-mth(tt-result.loss-own-needs)).
            sw:write-data-element ("Delivery-ned-izl",    string-mth(tt-result.Delivery-ned-izl)).
            sw:write-data-element ("wght-other",          string-mth(tt-result.wght-other)).
            sw:write-data-element ("othermoves",          string-mth(tt-result.othermoves)).
          sw:end-element ("gd") .
        end .          
        sw:end-element ("gds") .
      sw:end-element ("operating-balance") .
    sw:end-document () .
    
  end method . /* create-esys-data */
  
  method private void make-rep () :
    define variable v-now as datetime no-undo .
    define variable v-msk-dt as datetime no-undo .
    define variable v-host-code as integer no-undo .
    define variable v-host-name as character no-undo .
    
    define buffer host_clients for ub.clients .
    define buffer buf_goods for ub.goods .
    
    v-host-code = buf_clients.host-code .
    find first host_clients no-lock where host_clients.obj-code = buf_clients.host-code
                                      and host_clients.obj-type = {&cmp}
                                      no-error .
    if available host_clients
    then do :
      v-host-code = host_clients.obj-code .
      v-host-name = host_clients.obj-name .
    end .
    
    rep-file-name = "PM_" + replace(string(vMoscowDate, "99/99/9999"), "/", "") + "_" + replace(string(vMoscowTimeEnd, "HH:MM:SS"), ":", "") + ".html" .
    
    output stream OutStr-html to value(rep-file-name) convert target 'UTF-8' .
  
    /* Системная шапка HTML */
    put stream OutStr-html unformatted
      "<!DOCTYPE HTML>" skip
      ' <html>' skip
      '  <head>' skip
      '   <meta charset="utf-8">' skip
      '    <style type="text/css">' skip
      '      table ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
      '      .class1 ' + chr(123) + ' border-collapse: collapse; ' + chr(125) skip
      '      tbody, td, th ' + chr(123) + ' border-collapse: collapse; border: 1px solid black; height: 14px;' + chr(125) skip
      '   </style>' skip
      '  </head>' skip
    .
    
    put stream OutStr-html unformatted
      '<body>' skip
      '<table name="Лист1"  fit_to_page="true" orientation="landscape" CELLSPACING="0" BORDER="0">'skip
      '<thead>' skip
    .
    put stream OutStr-html unformatted
        '<tr class="set_columns">' skip
          '<td style="width: 100px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
          '<td style="width: 70px; border: none;"></td>' skip
        '</tr>' skip
    .
                        
    v-now = now .
    v-msk-dt = now - (timezone-diff * 60 * 1000) .
    put stream OutStr-html unformatted
        '<tr>' skip
          '<td colspan="24" style="text-align: center; font-weight:bold;">Ежедневный отчет по движению топлива за сутки на АЗС/АЗК </td>' skip
        '</tr>' skip   
        '<tr>' skip
          '<td colspan="12" style="text-align: left; font-weight:bold;">' + string(v-msk-dt, "99.99.9999 HH:MM:SS") + '</td>' skip
          '<td colspan="12" style="text-align: left; font-weight:bold;">' + string(v-now, "99.99.9999 HH:MM:SS") + '</td>' skip
        '</tr>' skip 
      '</thead>' skip
    .  
    
    put stream OutStr-html unformatted
      '     <tbody>' skip
      '       <tr>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver; height: 30px">Наименование организации</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Код организации</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Наименование АЗС/АЗК</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Код АЗС/АЗК</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Дата актуальности</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Время актуальности</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Название товара</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Код товара</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Книж. остатки на начало дня, кг</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Книж. остатки на конец дня, кг</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Факт. остатки на начало дня, кг</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Факт. остатки на конец дня, кг</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Поступления, кг</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Поступления от собственных нефтебаз ПНПО, кг</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Прямые поставки, кг</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Поступления от собственных нефтебаз других ПНПО, кг</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Поступления от сторонних поставщиков, кг</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Нефтепродукты в пути, кг</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">АЗС/АЗК, кг</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Мелкий опт, кг</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Потери и потребление на собственные нужды, кг</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Недостачи и излишки при приеме, кг</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Расход на прочие нужды, кг</th>' skip
      '         <th style="text-align: center; font-weight:bold; background-color: silver;">Прочие перемещения на АЗС, кг</th>' skip
      '       </tr>' skip
    . /* Точка для закрытия Put */
    
    for each tt-result,
    first buf_goods no-lock where buf_goods.gds-code = tt-result.gds-code
    by tt-result.gds-code
    :
      put stream OutStr-html unformatted
        '     <tbody>' skip
        '       <tr>' skip
        '         <th style="text-align: left; ">' + v-host-name + '</th>' skip
        '         <th style="text-align: right;">' + string(v-host-code) + '</th>' skip
        '         <th style="text-align: left; ">' + buf_clients.obj-name + '</th>' skip
        '         <th style="text-align: right;">' + string(buf_clients.obj-code) + '</th>' skip
        '         <th style="text-align: left; ">' + string(vMoscowDate, "99.99.9999") + '</th>' skip
        '         <th style="text-align: left; ">' + string(vMoscowTimeEnd, "HH:MM:SS") + '</th>' skip
        '         <th style="text-align: left; ">' + buf_goods.gds-name + '</th>' skip
        '         <th style="text-align: right;">' + string(buf_goods.gds-code) + '</th>' skip
        '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-result.wght-doc-start,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-result.wght-doc-start,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
        '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-result.wght-doc-end,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-result.wght-doc-end,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
        '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-result.wght-fact-start,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-result.wght-fact-start,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
        '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-result.wght-fact-end,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-result.wght-fact-end,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
        '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-result.delivery,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-result.delivery,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
        '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-result.delivery-own-pnpo,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-result.delivery-own-pnpo,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
        '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-result.direct-delivery,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-result.direct-delivery,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
        '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-result.delivery-other-pnpo,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-result.delivery-other-pnpo,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
        '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-result.delivery-other,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-result.delivery-other,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
        '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-result.fuel-in-transit,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-result.fuel-in-transit,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
        '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-result.wght-sale,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-result.wght-sale,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
        '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-result.wght-wholesale,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-result.wght-wholesale,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
        '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-result.loss-own-needs,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-result.loss-own-needs,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
        '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-result.Delivery-ned-izl,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-result.Delivery-ned-izl,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
        '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-result.wght-other,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-result.wght-other,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
        '         <th num="0.00" val="' + fnc-convert-dot-to-colon(tt-result.othermoves,"->>>>>>>>>>>>>9.99",2) + '" style="text-align: right;">' + fnc-convert-dot-to-colon(tt-result.othermoves,"->>>>>>>>>>>>>9.99",2) + '</th>' skip
        '       </tr>' skip
      . /* Точка для закрытия Put */
    end .
    
    put stream OutStr-html unformatted
      '     </tbody>' skip
      '   </table>' skip
      '  </body>' skip
      ' </html>' skip
    . /* Точка для закрытия Put */
    
    output stream OutStr-html close.
    
  end method . /* make-rep */
  
  method private character fnc-convert-dot-to-colon (input p-data as decimal,
                                                     input p-accur as character,
                                                     input p-num as integer)
  :
  /* Конвертация десятичной точки в запятую с передачей параметра форматирования числа (accuracy - точность) */
  define variable result       as character no-undo.
  define variable v-str-result as character no-undo.
  if p-data = ? then p-data = 0 .
  p-data = round(p-data, p-num). /* Чтобы не выйти случайно за рамки формата числа при выводе (несоотвесвие формата результата и формата отображения - приводит к ош) */
  v-str-result = trim(replace(string(p-data, p-accur), ".", ",")).
    
  return v-str-result.
    
  end method . /* fnc-convert-dot-to-colon */
  
  method private character string-mth (inValue as decimal):
    
    def var v-str as character no-undo.
    
    if inValue = ?
    then do :
      v-str = "0".
      return v-str.
    end .
    
    if string (inValue) begins "."
      then v-str = "0" + string (inValue).
      else v-str = string (inValue).
    
    return v-str.
    
  end method . /* string-mth */
  
  method private character utc-time () :
    define variable v-dt as datetime no-undo .
    v-dt = now - (timezone * 60 * 1000) .
    return string(v-dt) .
  end method . /* utc-time */
  
  method private logical valid-density
  (input p-density as decimal,
   input p-unit-base-cli-eq as logical
  ) :
    define variable v-answ as logical no-undo .
    if ( p-unit-base-cli-eq = true
         and p-density = 1.0
       )
      or ( p-unit-base-cli-eq = false
           and p-density <> ?
           and p-density > 0.0
           and p-density < 1.0
         )
    then do:
      assign
        v-answ = true
      .
    end.
    else do:
      assign
        v-answ = false
      .
    end.
    return v-answ.
  end method . /* valid-density */
  
  method private integer findtank
  (
    input p-obj-type     as character, 
    input p-obj-code     as integer,   
    input p-pump-code    as integer,   
    input p-nozzle-code  as integer,   
    input p-from-pl-code as integer,   
    input p-gds-code     as integer   
  ) :  
    define variable v-pl-code            like ub.place.pl-code no-undo .
    define variable p-pl-code            like ub.place.pl-code no-undo .
    define variable v-dopstr             as character no-undo .
  
    define buffer buf_place for ub.place.
    define buffer buf_pl-gds-pump for ub.pl-gds-pump.
    define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
    define buffer buf_pl-gds for ub.pl-gds.
  
    do
    on error undo, return error return-value
    :
  
      assign
        v-pl-code = 0
        p-pl-code = ?
      .
  
      if p-from-pl-code <> ?
        and p-from-pl-code <> 0
      then do:
        find first buf_pl-gds no-lock
          where buf_pl-gds.obj-type  = p-obj-type
            and buf_pl-gds.obj-code  = p-obj-code
            and buf_pl-gds.pl-code   = p-from-pl-code
            and buf_pl-gds.gds-code  = p-gds-code
          no-error.
        if available buf_pl-gds then do:
          assign
            v-pl-code = buf_pl-gds.pl-code
          .
        end.
      end.
  
      if v-pl-code <> 0
        and p-nozzle-code <> ?
        and p-nozzle-code <> 0
      then do:
        find first buf_pl-pump-nozzle no-lock
          where buf_pl-pump-nozzle.obj-type    = p-obj-type
            and buf_pl-pump-nozzle.obj-code    = p-obj-code
            and buf_pl-pump-nozzle.pl-code     = v-pl-code
            and buf_pl-pump-nozzle.pump-code   = p-pump-code
            and buf_pl-pump-nozzle.nozzle-code = p-nozzle-code
  /*          and buf_pl-pump-nozzle.status_     = {&current-status} поле не заполняется*/
          no-error .
        if not available buf_pl-pump-nozzle then do:
          return p-pl-code .
        end.
      end.
  
      if v-pl-code = 0 then do:
        if p-nozzle-code = 0 then do:
          find first buf_pl-gds-pump no-lock
            where buf_pl-gds-pump.obj-type  = p-obj-type
              and buf_pl-gds-pump.obj-code  = p-obj-code
              and buf_pl-gds-pump.pump-code = p-pump-code
              and buf_pl-gds-pump.gds-code  = p-gds-code
              and buf_pl-gds-pump.status_   = {&current-status}
            no-error.
          if available buf_pl-gds-pump then do:
            assign
              v-pl-code = buf_pl-gds-pump.pl-code
            .
          end.
        end.
        else do:
          _ppnz:
          for each buf_pl-pump-nozzle no-lock
            where buf_pl-pump-nozzle.obj-type = p-obj-type
              and buf_pl-pump-nozzle.obj-code = p-obj-code
              and buf_pl-pump-nozzle.pump-code = p-pump-code
              and buf_pl-pump-nozzle.nozzle-code = p-nozzle-code
  /*            and buf_pl-pump-nozzle.status_ = {&current-status} поле не заполняется*/
            ,first buf_pl-gds-pump no-lock
            where buf_pl-gds-pump.obj-type  = p-obj-type
              and buf_pl-gds-pump.obj-code  = p-obj-code
              and buf_pl-gds-pump.pump-code = p-pump-code
              and buf_pl-gds-pump.gds-code  = p-gds-code
              and buf_pl-gds-pump.status_   = {&current-status}
              and buf_pl-gds-pump.pl-code   = buf_pl-pump-nozzle.pl-code
          on error undo, return error return-value
          :
            assign
              v-pl-code = buf_pl-pump-nozzle.pl-code
            .
            leave _ppnz.
          end.
        end.
      end.
  
      if v-pl-code <> 0 then do:
        assign
          p-pl-code = v-pl-code
        .
      end .
      
      return p-pl-code .
  
    end . /*doe*/
  end method .
  
  method private integer findblockedtank
  (
    input p-obj-type     as character, 
    input p-obj-code     as integer,   
    input p-pump-code    as integer,   
    input p-nozzle-code  as integer,   
    input p-from-pl-code as integer,   
    input p-gds-code     as integer   
  ) :  
    define variable v-pl-code            like ub.place.pl-code no-undo .
    define variable p-pl-code            like ub.place.pl-code no-undo .
    define variable v-dopstr             as character no-undo .
  
    define buffer buf_place for ub.place.
    define buffer buf_pl-gds-pump for ub.pl-gds-pump.
    define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle.
    define buffer buf_pl-gds for ub.pl-gds.
  
    do
    on error undo, return error return-value
    :
  
      assign
        v-pl-code = 0
        p-pl-code = ?
      .
  
      if p-from-pl-code <> ?
        and p-from-pl-code <> 0
      then do:
        find first buf_pl-gds no-lock
          where buf_pl-gds.obj-type  = p-obj-type
            and buf_pl-gds.obj-code  = p-obj-code
            and buf_pl-gds.pl-code   = p-from-pl-code
            and buf_pl-gds.gds-code  = p-gds-code
          no-error.
        if available buf_pl-gds then do:
          assign
            v-pl-code = buf_pl-gds.pl-code
          .
        end.
      end.
  
      if v-pl-code <> 0
        and p-nozzle-code <> ?
        and p-nozzle-code <> 0
      then do:
        find first buf_pl-pump-nozzle no-lock
          where buf_pl-pump-nozzle.obj-type    = p-obj-type
            and buf_pl-pump-nozzle.obj-code    = p-obj-code
            and buf_pl-pump-nozzle.pl-code     = v-pl-code
            and buf_pl-pump-nozzle.pump-code   = p-pump-code
            and buf_pl-pump-nozzle.nozzle-code = p-nozzle-code
  /*          and buf_pl-pump-nozzle.status_     = {&current-status} поле не заполняется*/
          no-error .
        if not available buf_pl-pump-nozzle then do:
          return p-pl-code .
        end.
      end.
  
      if v-pl-code = 0 then do:
        if p-nozzle-code = 0 then do:
          find first buf_pl-gds-pump no-lock
            where buf_pl-gds-pump.obj-type  = p-obj-type
              and buf_pl-gds-pump.obj-code  = p-obj-code
              and buf_pl-gds-pump.pump-code = p-pump-code
              and buf_pl-gds-pump.gds-code  = p-gds-code
/*              and buf_pl-gds-pump.status_   = {&current-status}*/
            no-error.
          if available buf_pl-gds-pump then do:
            assign
              v-pl-code = buf_pl-gds-pump.pl-code
            .
          end.
        end.
        else do:
          _ppnz:
          for each buf_pl-pump-nozzle no-lock
            where buf_pl-pump-nozzle.obj-type = p-obj-type
              and buf_pl-pump-nozzle.obj-code = p-obj-code
              and buf_pl-pump-nozzle.pump-code = p-pump-code
              and buf_pl-pump-nozzle.nozzle-code = p-nozzle-code
  /*            and buf_pl-pump-nozzle.status_ = {&current-status} поле не заполняется*/
            ,first buf_pl-gds-pump no-lock
            where buf_pl-gds-pump.obj-type  = p-obj-type
              and buf_pl-gds-pump.obj-code  = p-obj-code
              and buf_pl-gds-pump.pump-code = p-pump-code
              and buf_pl-gds-pump.gds-code  = p-gds-code
/*              and buf_pl-gds-pump.status_   = {&current-status}*/
              and buf_pl-gds-pump.pl-code   = buf_pl-pump-nozzle.pl-code
          on error undo, return error return-value
          :
            assign
              v-pl-code = buf_pl-pump-nozzle.pl-code
            .
            leave _ppnz.
          end.
        end.
      end.
  
      if v-pl-code <> 0 then do:
        assign
          p-pl-code = v-pl-code
        .
      end .
      
      return p-pl-code .
  
    end . /*doe*/
  end method .

end class .