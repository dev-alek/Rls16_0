block-level on error undo, throw.

/*------------------------------------------------------------------------
    File        : imp-promotion-1C-RN.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SSlivenko
    Created     : Wed Dec 06 12:05:31 AST 2017
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */
using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.

/* не используется с 24/VI-2018;
   заменена на классы сущностей, работающие по таблицам PromotionSeries
{ cmp/trg-def.i }
{ cmp/str-glbl.i }
{ gbl/getcntxa.i }

define input parameter p-PromotionObj           as class promotion .
define input parameter p-profile                as integer no-undo .

define variable v-shedule                       as class subjects .
define variable v-thresholds                    as class subjects .
define variable v-gds                           as class subjects .
define variable v-shedule-line                  as class promotion_shedule-line .
define variable v-threshold                     as class promotion_threshold .
define variable v-gd                            as class promotion_gd .

define variable v-mode              as character    no-undo .
define variable v-rec-dis-time      as recid        no-undo .
define variable v-rec-dis-rule      as recid        no-undo .

define variable ii as integer no-undo .
define variable jj as integer no-undo .
define variable tmp-rule-num as integer no-undo .

define variable v-discnt-value  as decimal no-undo .
define variable v-sts           as integer no-undo .
define variable v-can           as logical no-undo .

define variable v-strt-date     as date    no-undo .
define variable v-end-date      as date    no-undo .

define buffer buf_dis-rule          for ub.dis-rule .
define buffer buf2_dis-rule         for ub.dis-rule .
define buffer loc_dis-rule          for ub.dis-rule .
define buffer root_dis-rule         for ub.dis-rule .
define buffer buf_dis-time-rule     for ub.dis-time-rule .
define buffer root_dis-time-rule    for ub.dis-time-rule .
define buffer buf_dis-gds-rule      for ub.dis-gds-rule .

define buffer buf_dis-cp-rule       for ub.dis-cp-rule .

DEFINE TEMP-TABLE tt0-term_dis-time-rule NO-UNDO LIKE ub.dis-time-rule.
DEFINE TEMP-TABLE tt0-term_dis-rule NO-UNDO LIKE ub.dis-rule.
DEFINE TEMP-TABLE tt0-dis-gds-rule NO-UNDO LIKE ub.dis-gds-rule.

function f-int-time returns integer (input v-time as character) :
  def var v-int-time as integer .
  def var v-hour as integer .
  def var v-minute as integer .
  def var v-sec as integer .
  
  v-hour = integer(entry(1, v-time, ":")) .
  v-minute = integer(entry(2, v-time, ":")) .
  v-sec = integer(entry(3, v-time, ":")) .
  
  v-int-time = v-hour * 60 * 60 + v-minute * 60 + v-sec .
  return  v-int-time .
end.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */

v-shedule = p-PromotionObj:shedule .
v-thresholds = p-PromotionObj:thresholds .
v-gds = p-PromotionObj:gds .

empty temp-table tt0-term_dis-time-rule .
empty temp-table tt0-term_dis-rule .
empty temp-table tt0-dis-gds-rule .
tmp-rule-num = 0 .
v-rec-dis-rule = ? .

v-strt-date = date(integer(entry(2, p-PromotionObj:strt-date, '-')), integer(entry(3, p-PromotionObj:strt-date, '-')), integer(entry(1, p-PromotionObj:strt-date, '-'))) .
v-end-date  = date(integer(entry(2, p-PromotionObj:end-date , '-')), integer(entry(3, p-PromotionObj:end-date , '-')), integer(entry(1, p-PromotionObj:end-date , '-'))) .

find first ub.clients no-lock where ub.clients.db-num = g#db-num
                                  and ub.clients.obj-type = {&shop}
                                  and ub.clients.stts = 0 .

find first buf_dis-rule no-lock where buf_dis-rule.promo-id = p-PromotionObj:code_ no-error.
if available buf_dis-rule
then do :
  
  if (buf_dis-rule.sts = integer({&used-status-int}) and
      p-PromotionObj:del-l = 1)
  or p-PromotionObj:del-f = 1 
  then do :
    
    for each buf_dis-rule no-lock where buf_dis-rule.promo-id = p-PromotionObj:code_ :
      
      for each buf_dis-gds-rule exclusive-lock where buf_dis-gds-rule.rule-num = buf_dis-rule.rule-num :
        delete buf_dis-gds-rule .
      end.
      for each buf_dis-cp-rule exclusive-lock where buf_dis-cp-rule.rule-num = buf_dis-rule.rule-num :
        delete buf_dis-cp-rule .
      end.
      
      for each buf2_dis-rule no-lock where buf2_dis-rule.upper-rule-num = buf_dis-rule.rule-num
                                       and buf2_dis-rule.lvl-num > 1 :
        for each buf_dis-gds-rule exclusive-lock where buf_dis-gds-rule.rule-num = buf2_dis-rule.rule-num :
          delete buf_dis-gds-rule .
        end.
        for each buf_dis-cp-rule exclusive-lock where buf_dis-cp-rule.rule-num = buf2_dis-rule.rule-num :
          delete buf_dis-cp-rule .
        end.                                 
      end.
      
      if p-PromotionObj:del-l = 1
      then do :
        find first loc_dis-rule exclusive-lock where
              recid(loc_Dis-rule) = recid(buf_Dis-rule) no-error .
        v-sts = ? .
        run ref/dis-rul2.p (
                      buffer loc_dis-rule
                    , input yes /*p-silent*/
                    , input ? /*p-pos-type*/
                    , input-output v-sts
                    ) no-error.
        if error-status:error then do:
          undo, return error return-value .
        end.
      end.
      
      if p-PromotionObj:del-f = 1
      then do :
        find first loc_dis-rule exclusive-lock where
              recid(loc_Dis-rule) = recid(buf_Dis-rule) no-error .
        run ref/dis-rul3.p (
                         buffer loc_dis-rule
                        ,input no /*p-sts-mode удаление а не проверка*/
                        ,input yes /*p-silent*/
                        ,output v-can
                        ) no-error .
        if error-status:error then do:
          undo, return error return-value .
        end.     
      end.
    end.
    
    return .
    
  end .
  else do :
    for each buf_dis-rule no-lock where buf_dis-rule.promo-id = p-PromotionObj:code_ :
      
      for each buf_dis-gds-rule exclusive-lock where buf_dis-gds-rule.rule-num = buf_dis-rule.rule-num :
        delete buf_dis-gds-rule .
      end.
      for each buf_dis-cp-rule exclusive-lock where buf_dis-cp-rule.rule-num = buf_dis-rule.rule-num :
        delete buf_dis-cp-rule .
      end.
      
      for each buf2_dis-rule no-lock where buf2_dis-rule.upper-rule-num = buf_dis-rule.rule-num
                                       and buf2_dis-rule.lvl-num > 1 :
        for each buf_dis-gds-rule exclusive-lock where buf_dis-gds-rule.rule-num = buf2_dis-rule.rule-num :
          delete buf_dis-gds-rule .
        end.
        for each buf_dis-cp-rule exclusive-lock where buf_dis-cp-rule.rule-num = buf2_dis-rule.rule-num :
          delete buf_dis-cp-rule .
        end.                                 
      end.
      
      find first loc_dis-rule exclusive-lock where
            recid(loc_Dis-rule) = recid(buf_Dis-rule) no-error .
      run ref/dis-rul3.p (
                         buffer loc_dis-rule
                        ,input no /*p-sts-mode удаление а не проверка*/
                        ,input yes /*p-silent*/
                        ,output v-can
                        ) no-error . 
      if error-status:error then do:
        undo, return error return-value .
      end.  
    end.
  end.
end.

find first root_dis-rule no-lock where root_dis-rule.rule-num = p-profile no-error.
if not available root_dis-rule
then do :
    undo, return error ("Не найдено корневое правило скидки с номером " + string(p-profile) ) .
end.
v-mode = {&ADD-DEF} .    
case root_dis-rule.rule-num :
  when 5
  then do :
    find first root_dis-time-rule no-lock where
          root_dis-time-rule.time-rule-num = 50003 no-error .  
    
    find first buf_dis-time-rule no-lock
         where buf_dis-time-rule.upper-time-rule-num = root_dis-time-rule.time-rule-num
           and buf_dis-time-rule.date-from = v-strt-date
           and buf_dis-time-rule.date-to = v-end-date 
           no-error.
    if not available buf_dis-time-rule
    then do :      
      
      run ref/dis-tim1.p (
       input ? /* (IF p-mode = {&ADD-DEF} THEN ? ELSE tt-dis-time-rule.time-rule-num )  p-rule-num */
      ,input root_dis-time-rule.time-rule-num
      ,input root_dis-time-rule.time-rule-num
      ,input "ПЕРИОД ДАТ"
      ,input v-strt-date
      ,input v-end-date
      ,input -1
      ,input -1
      ,input -1
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input root_dis-time-rule.time-rule-num
      ,input root_dis-time-rule.value-type
      ,input table tt0-term_dis-time-rule
      ,input-output v-rec-dis-time
      ,input v-mode
      ,input yes /*p-silent */
      ) NO-ERROR.
      if error-status:error then do:
        undo, return error return-value.
      end.  
      
      find first buf_dis-time-rule no-lock where recid(buf_dis-time-rule) = v-rec-dis-time .
    
    end.
    
    if valid-object (v-thresholds)
    then do :
      do ii = 1 to v-thresholds:Get(ii):  
        v-threshold = cast (v-thresholds:SubjectObjCurr, promotion_threshold).  
          
        create tt0-term_dis-rule .
        BUFFER-COPY root_dis-rule TO tt0-term_dis-rule
        ASSIGN
          tt0-term_dis-rule.rule-num                = ii
          tt0-term_dis-rule.host-code               = ub.clients.host-code
          tt0-term_dis-rule.obj-type                = ub.clients.obj-type
          tt0-term_dis-rule.obj-code                = ub.clients.obj-code
          tt0-term_dis-rule.dis-kat                 = 0
          tt0-term_dis-rule.doc-qnty                = v-threshold:value_
          tt0-term_dis-rule.discnt-value            = v-threshold:dscnt
          tt0-term_dis-rule.time-rule-num           = buf_dis-time-rule.time-rule-num
          tt0-term_dis-rule.time-templ-rl-root      = root_dis-time-rule.time-rule-num
          tt0-term_dis-rule.sts                     = INTEGER({&non-root-status-int})
          tt0-term_dis-rule.tot-sum                 = 0
          tt0-term_dis-rule.upper-rule-num          = root_dis-rule.rule-num
          tt0-term_dis-rule.root                    = no
          tt0-term_dis-rule.des                     = ("На кол-во товара от " + string(v-threshold:value_) )
          tt0-term_dis-rule.lvl-num                 = 2
          tt0-term_dis-rule.key#_one                = 0
          tt0-term_dis-rule.key#_two                = 0
          tt0-term_dis-rule.key#_three              = 0
          tt0-term_dis-rule.charkey_one             = "":U
          tt0-term_dis-rule.charkey_two             = "":U
          tt0-term_dis-rule.charkey_three           = "":U
          tt0-term_dis-rule.deckey_one              = 0
          tt0-term_dis-rule.deckey_two              = 0
          tt0-term_dis-rule.deckey_three            = 0
        .
      end .
      
    end. /* thresholds */
      
    run ref/dis-rul1.p (
     input  ? /* (IF v-mode = {&ADD-DEF} THEN ? ELSE tt-dis-rule.rule-num ) p-rule-num */
    ,input "IBM-XML"
    ,input root_dis-rule.rule-num
    ,input root_dis-rule.rule-num
    ,input p-PromotionObj:name_
    ,input -1
    ,input {&discnt-t-qnty}
    ,input 0
    ,input -1
    ,input ""
    ,input ""
    ,input ""
    ,input ?
    ,input ?
    ,input ?
    ,input ?
    ,input ?
    ,input ?
    ,input INTEGER({&discnt-gds})
    ,input root_dis-time-rule.time-rule-num
    ,input buf_dis-time-rule.time-rule-num
    ,input root_dis-rule.rule-num
    ,input integer({&discnt-v-pcnt})
    ,input ub.clients.host-code
    ,INPUT ub.clients.obj-type
    ,INPUT ub.clients.obj-code
    ,INPUT 0
    ,input table tt0-term_dis-rule
    ,input-output v-rec-dis-rule
    ,input v-mode
    ,input yes /*p-silent */
    ) NO-ERROR.
    if error-status:error then do:
      undo, return error return-value.
    end.
    
    find first buf_dis-rule exclusive-lock where recid(buf_dis-rule) = v-rec-dis-rule .
    buf_dis-rule.promo-id = p-PromotionObj:code_ .
    
    if p-PromotionObj:status_ = 1
    then do :
      find first loc_dis-rule exclusive-lock where
            recid(loc_Dis-rule) = recid(buf_Dis-rule) no-error .
      v-sts = ? .
      run ref/dis-rul2.p (
                    buffer loc_dis-rule
                  , input yes /*p-silent*/
                  , input ? /*p-pos-type*/
                  , input-output v-sts
                  ) no-error.
      if error-status:error then do:
        undo, return error return-value .
      end.
      
      return .
    end.
    
    if valid-object (v-gds)
    then do :
      do ii = 1 to v-gds:Get(ii) :
        v-gd = cast (v-gds:SubjectObjCurr, promotion_gd). 
        
        empty temp-table tt0-dis-gds-rule .
        
        create tt0-dis-gds-rule .
        assign
          tt0-dis-gds-rule.obj-type           = ub.clients.obj-type
          tt0-dis-gds-rule.obj-code           = ub.clients.obj-code
          tt0-dis-gds-rule.gds-code           = integer(v-gd:gd-code)
          tt0-dis-gds-rule.rule-num           = buf_dis-rule.rule-num
          tt0-dis-gds-rule.pos-type           = "IBM-XML"
          tt0-dis-gds-rule.templ-rl-root      = root_dis-rule.rule-num
          tt0-dis-gds-rule.whole-send-news    = 0
          tt0-dis-gds-rule.discnt-role        = {&dgr-pcnt-qnty}
          tt0-dis-gds-rule.time-templ-rl-root = root_dis-time-rule.time-rule-num
          tt0-dis-gds-rule.nonunique          = ""
          tt0-dis-gds-rule.rl-root            = buf_dis-rule.rule-num
        .
        
        for each buf_dis-gds-rule no-lock where buf_dis-gds-rule.obj-type           = ub.clients.obj-type
                                            and buf_dis-gds-rule.obj-code           = ub.clients.obj-code
                                            and buf_dis-gds-rule.gds-code           = integer(v-gd:gd-code)
                                            and buf_dis-gds-rule.pos-type           = "IBM-XML" :
          create tt0-dis-gds-rule .
          buffer-copy buf_dis-gds-rule to tt0-dis-gds-rule no-error.
          if error-status:error then delete tt0-dis-gds-rule no-error.
        end.
        
        run ref/disgdsr1.p (
                 input {&update}
                ,input integer(v-gd:gd-code)
                ,input ub.clients.obj-type
                ,input ub.clients.obj-code
                ,INPUT table tt0-dis-gds-rule
                ) no-error .
      end.
      
    end. /* gds */
  end . /* 5 */
  when 74
  then do :
    find first root_dis-time-rule no-lock where
          root_dis-time-rule.time-rule-num = 50003 no-error .  
      
    find first buf_dis-time-rule no-lock
         where buf_dis-time-rule.upper-time-rule-num = root_dis-time-rule.time-rule-num
           and buf_dis-time-rule.date-from = v-strt-date
           and buf_dis-time-rule.date-to = v-end-date 
           no-error.
    if not available buf_dis-time-rule
    then do :      
      
      run ref/dis-tim1.p (
       input ? /* (IF p-mode = {&ADD-DEF} THEN ? ELSE tt-dis-time-rule.time-rule-num )  p-rule-num */
      ,input root_dis-time-rule.time-rule-num
      ,input root_dis-time-rule.time-rule-num
      ,input "ПЕРИОД ДАТ"
      ,input v-strt-date
      ,input v-end-date
      ,input -1
      ,input -1
      ,input -1
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input root_dis-time-rule.time-rule-num
      ,input root_dis-time-rule.value-type
      ,input table tt0-term_dis-time-rule
      ,input-output v-rec-dis-time
      ,input v-mode
      ,input yes /*p-silent */
      ) NO-ERROR.
      if error-status:error then do:
        undo, return error return-value.
      end.  
      
      find first buf_dis-time-rule no-lock where recid(buf_dis-time-rule) = v-rec-dis-time .
    
    end.
    
    if valid-object (v-thresholds)
    then do :
      do ii = 1 to v-thresholds:Get(ii):  
        v-threshold = cast (v-thresholds:SubjectObjCurr, promotion_threshold).  
        
        do jj = 1 to num-entries(p-PromotionObj:pmnt-types) :
          find first ub.cash-pay no-lock where ub.cash-pay.cdpay-code = integer(entry(jj, p-PromotionObj:pmnt-types)) no-error .
          if not available ub.cash-pay
          then do :
            undo, return error ("Нет типа кассового платежа с кодом " + entry(jj, p-PromotionObj:pmnt-types) ) .
          end.
          tmp-rule-num = tmp-rule-num + 1 .
          create tt0-term_dis-rule .
          BUFFER-COPY root_dis-rule TO tt0-term_dis-rule
          ASSIGN
            tt0-term_dis-rule.rule-num                = tmp-rule-num
            tt0-term_dis-rule.host-code               = ub.clients.host-code
            tt0-term_dis-rule.obj-type                = ub.clients.obj-type
            tt0-term_dis-rule.obj-code                = ub.clients.obj-code
            tt0-term_dis-rule.dis-kat                 = 0
            tt0-term_dis-rule.doc-qnty                = v-threshold:value_
            tt0-term_dis-rule.discnt-value            = v-threshold:dscnt
            tt0-term_dis-rule.time-rule-num           = buf_dis-time-rule.time-rule-num
            tt0-term_dis-rule.time-templ-rl-root      = root_dis-time-rule.time-rule-num
            tt0-term_dis-rule.sts                     = INTEGER({&non-root-status-int})
            tt0-term_dis-rule.tot-sum                 = 0
            tt0-term_dis-rule.upper-rule-num          = root_dis-rule.rule-num
            tt0-term_dis-rule.root                    = no
            tt0-term_dis-rule.des                     = ("На кол-во товара от " + string(v-threshold:value_) )
            tt0-term_dis-rule.lvl-num                 = 2
            tt0-term_dis-rule.key#_one                = ub.cash-pay.cdpay-code
            tt0-term_dis-rule.key#_two                = ub.cash-pay.curr-code
            tt0-term_dis-rule.key#_three              = 0
            tt0-term_dis-rule.charkey_one             = "":U
            tt0-term_dis-rule.charkey_two             = "":U
            tt0-term_dis-rule.charkey_three           = "":U
            tt0-term_dis-rule.deckey_one              = 0
            tt0-term_dis-rule.deckey_two              = 0
            tt0-term_dis-rule.deckey_three            = 0
          .
        end.
      end.
    end.
      
    run ref/dis-rul1.p (
     input  ? /* (IF v-mode = {&ADD-DEF} THEN ? ELSE tt-dis-rule.rule-num ) p-rule-num */
    ,input "IBM-XML"
    ,input root_dis-rule.rule-num
    ,input root_dis-rule.rule-num
    ,input p-PromotionObj:name_
    ,input -1
    ,input {&discnt-t-qnty}
    ,input 0
    ,input -1
    ,input ""
    ,input ""
    ,input ""
    ,input ?
    ,input ?
    ,input ?
    ,input 0
    ,input 0
    ,input ?
    ,input INTEGER({&discnt-gds}) /* dis-rule.subject-type */
    ,input root_dis-time-rule.time-rule-num
    ,input buf_dis-time-rule.time-rule-num
    ,input root_dis-rule.rule-num
    ,input integer({&discnt-v-abs}) /* dis-rule.value-type */
    ,input ub.clients.host-code
    ,INPUT ub.clients.obj-type
    ,INPUT ub.clients.obj-code
    ,INPUT 0
    ,input table tt0-term_dis-rule
    ,input-output v-rec-dis-rule
    ,input v-mode
    ,input yes /*p-silent */
    ) NO-ERROR.
    if error-status:error then do:
      undo, return error return-value.
    end.
    
    find first buf_dis-rule exclusive-lock where recid(buf_dis-rule) = v-rec-dis-rule .
    buf_dis-rule.promo-id = p-PromotionObj:code_ .
  
    if p-PromotionObj:status_ = 1
    then do :
      for each buf_dis-cp-rule exclusive-lock where buf_dis-cp-rule.rule-num = buf_dis-rule.rule-num :
        delete buf_dis-cp-rule .
      end.
      
      find first loc_dis-rule exclusive-lock where
            recid(loc_Dis-rule) = recid(buf_Dis-rule) no-error .
      v-sts = ? .
      run ref/dis-rul2.p (
                    buffer loc_dis-rule
                  , input yes /*p-silent*/
                  , input ? /*p-pos-type*/
                  , input-output v-sts
                  ) no-error.
      if error-status:error then do:
        undo, return error return-value .
      end.
      
      return .
    end.
    
    if valid-object (v-gds)
    then do :
      do ii = 1 to v-gds:Get(ii) :
        v-gd = cast (v-gds:SubjectObjCurr, promotion_gd). 
        
        empty temp-table tt0-dis-gds-rule .
        
        create tt0-dis-gds-rule .
        assign
          tt0-dis-gds-rule.obj-type           = ub.clients.obj-type
          tt0-dis-gds-rule.obj-code           = ub.clients.obj-code
          tt0-dis-gds-rule.gds-code           = integer(v-gd:gd-code)
          tt0-dis-gds-rule.rule-num           = buf_dis-rule.rule-num
          tt0-dis-gds-rule.pos-type           = "IBM-XML"
          tt0-dis-gds-rule.templ-rl-root      = root_dis-rule.rule-num
          tt0-dis-gds-rule.whole-send-news    = 0
          tt0-dis-gds-rule.discnt-role        = {&dgr-pcnt-qnty}
          tt0-dis-gds-rule.time-templ-rl-root = root_dis-time-rule.time-rule-num
          tt0-dis-gds-rule.nonunique          = ""
          tt0-dis-gds-rule.rl-root            = buf_dis-rule.rule-num
        .
        
        for each buf_dis-gds-rule no-lock where buf_dis-gds-rule.obj-type           = ub.clients.obj-type
                                            and buf_dis-gds-rule.obj-code           = ub.clients.obj-code
                                            and buf_dis-gds-rule.gds-code           = integer(v-gd:gd-code)
                                            and buf_dis-gds-rule.pos-type           = "IBM-XML" :
          create tt0-dis-gds-rule .
          buffer-copy buf_dis-gds-rule to tt0-dis-gds-rule no-error.
          if error-status:error then delete tt0-dis-gds-rule no-error.
        end.
        
        run ref/disgdsr1.p (
                 input {&update}
                ,input integer(v-gd:gd-code)
                ,input ub.clients.obj-type
                ,input ub.clients.obj-code
                ,INPUT table tt0-dis-gds-rule
                ) no-error .
      end.
      
    end.
  end . /* 74 */
  when 73
  then do :
    find first root_dis-time-rule no-lock where
          root_dis-time-rule.time-rule-num = 50003 no-error .  
      
    find first buf_dis-time-rule no-lock
         where buf_dis-time-rule.upper-time-rule-num = root_dis-time-rule.time-rule-num
           and buf_dis-time-rule.date-from = v-strt-date
           and buf_dis-time-rule.date-to = v-end-date 
           no-error.
    if not available buf_dis-time-rule
    then do :      
      
      run ref/dis-tim1.p (
       input ? /* (IF p-mode = {&ADD-DEF} THEN ? ELSE tt-dis-time-rule.time-rule-num )  p-rule-num */
      ,input root_dis-time-rule.time-rule-num
      ,input root_dis-time-rule.time-rule-num
      ,input "ПЕРИОД ДАТ"
      ,input v-strt-date
      ,input v-end-date
      ,input -1
      ,input -1
      ,input -1
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input root_dis-time-rule.time-rule-num
      ,input root_dis-time-rule.value-type
      ,input table tt0-term_dis-time-rule
      ,input-output v-rec-dis-time
      ,input v-mode
      ,input yes /*p-silent */
      ) NO-ERROR.
      if error-status:error then do:
        undo, return error return-value.
      end.  
      
      find first buf_dis-time-rule no-lock where recid(buf_dis-time-rule) = v-rec-dis-time .
    
    end.
    
    if valid-object (v-thresholds)
    then do :
      do ii = 1 to v-thresholds:Get(ii):  
        v-threshold = cast (v-thresholds:SubjectObjCurr, promotion_threshold).  
        
        do jj = 1 to num-entries(p-PromotionObj:pmnt-types) :
          find first ub.cash-pay no-lock where ub.cash-pay.cdpay-code = integer(entry(jj, p-PromotionObj:pmnt-types)) no-error .
          if not available ub.cash-pay
          then do :
            undo, return error ("Нет типа кассового платежа с кодом " + entry(jj, p-PromotionObj:pmnt-types) ) .
          end.
          tmp-rule-num = tmp-rule-num + 1 .
          create tt0-term_dis-rule .
          BUFFER-COPY root_dis-rule TO tt0-term_dis-rule
          ASSIGN
            tt0-term_dis-rule.rule-num                = tmp-rule-num
            tt0-term_dis-rule.host-code               = ub.clients.host-code
            tt0-term_dis-rule.obj-type                = ub.clients.obj-type
            tt0-term_dis-rule.obj-code                = ub.clients.obj-code
            tt0-term_dis-rule.dis-kat                 = 0
            tt0-term_dis-rule.doc-qnty                = v-threshold:value_
            tt0-term_dis-rule.discnt-value            = v-threshold:dscnt
            tt0-term_dis-rule.time-rule-num           = buf_dis-time-rule.time-rule-num
            tt0-term_dis-rule.time-templ-rl-root      = root_dis-time-rule.time-rule-num
            tt0-term_dis-rule.sts                     = INTEGER({&non-root-status-int})
            tt0-term_dis-rule.tot-sum                 = 0
            tt0-term_dis-rule.upper-rule-num          = root_dis-rule.rule-num
            tt0-term_dis-rule.root                    = no
            tt0-term_dis-rule.des                     = ("На кол-во товара от " + string(v-threshold:value_) )
            tt0-term_dis-rule.lvl-num                 = 2
            tt0-term_dis-rule.key#_one                = ub.cash-pay.cdpay-code
            tt0-term_dis-rule.key#_two                = ub.cash-pay.curr-code
            tt0-term_dis-rule.key#_three              = 0
            tt0-term_dis-rule.charkey_one             = "":U
            tt0-term_dis-rule.charkey_two             = "":U
            tt0-term_dis-rule.charkey_three           = "":U
            tt0-term_dis-rule.deckey_one              = 0
            tt0-term_dis-rule.deckey_two              = 0
            tt0-term_dis-rule.deckey_three            = 0
          .
        end.
      end.
    end.
      
    run ref/dis-rul1.p (
     input  ? /* (IF v-mode = {&ADD-DEF} THEN ? ELSE tt-dis-rule.rule-num ) p-rule-num */
    ,input "IBM-XML"
    ,input root_dis-rule.rule-num
    ,input root_dis-rule.rule-num
    ,input p-PromotionObj:name_
    ,input -1
    ,input {&discnt-t-qnty}
    ,input 0
    ,input -1
    ,input ""
    ,input ""
    ,input ""
    ,input ?
    ,input ?
    ,input ?
    ,input 0
    ,input 0
    ,input ?
    ,input INTEGER({&discnt-gds}) /* dis-rule.subject-type */
    ,input root_dis-time-rule.time-rule-num
    ,input buf_dis-time-rule.time-rule-num
    ,input root_dis-rule.rule-num
    ,input integer({&discnt-v-pcnt}) /* dis-rule.value-type */
    ,input ub.clients.host-code
    ,INPUT ub.clients.obj-type
    ,INPUT ub.clients.obj-code
    ,INPUT 0
    ,input table tt0-term_dis-rule
    ,input-output v-rec-dis-rule
    ,input v-mode
    ,input yes /*p-silent */
    ) NO-ERROR.
    if error-status:error then do:
      undo, return error return-value.
    end.
    
    find first buf_dis-rule exclusive-lock where recid(buf_dis-rule) = v-rec-dis-rule .
    buf_dis-rule.promo-id = p-PromotionObj:code_ .
    
    if p-PromotionObj:status_ = 1
    then do :
      for each buf_dis-cp-rule exclusive-lock where buf_dis-cp-rule.rule-num = buf_dis-rule.rule-num :
        delete buf_dis-cp-rule .
      end.
    
      find first loc_dis-rule exclusive-lock where
            recid(loc_Dis-rule) = recid(buf_Dis-rule) no-error .
      v-sts = ? .
      run ref/dis-rul2.p (
                    buffer loc_dis-rule
                  , input yes /*p-silent*/
                  , input ? /*p-pos-type*/
                  , input-output v-sts
                  ) no-error.
      if error-status:error then do:
        undo, return error return-value .
      end.
      
      return .
    end.
    
    if valid-object (v-gds)
    then do :
      do ii = 1 to v-gds:Get(ii) :
        v-gd = cast (v-gds:SubjectObjCurr, promotion_gd). 
        
        empty temp-table tt0-dis-gds-rule .
        
        create tt0-dis-gds-rule .
        assign
          tt0-dis-gds-rule.obj-type           = ub.clients.obj-type
          tt0-dis-gds-rule.obj-code           = ub.clients.obj-code
          tt0-dis-gds-rule.gds-code           = integer(v-gd:gd-code)
          tt0-dis-gds-rule.rule-num           = buf_dis-rule.rule-num
          tt0-dis-gds-rule.pos-type           = "IBM-XML"
          tt0-dis-gds-rule.templ-rl-root      = root_dis-rule.rule-num
          tt0-dis-gds-rule.whole-send-news    = 0
          tt0-dis-gds-rule.discnt-role        = {&dgr-pcnt-qnty}
          tt0-dis-gds-rule.time-templ-rl-root = root_dis-time-rule.time-rule-num
          tt0-dis-gds-rule.nonunique          = ""
          tt0-dis-gds-rule.rl-root            = buf_dis-rule.rule-num
        .
        
        for each buf_dis-gds-rule no-lock where buf_dis-gds-rule.obj-type           = ub.clients.obj-type
                                            and buf_dis-gds-rule.obj-code           = ub.clients.obj-code
                                            and buf_dis-gds-rule.gds-code           = integer(v-gd:gd-code)
                                            and buf_dis-gds-rule.pos-type           = "IBM-XML" :
          create tt0-dis-gds-rule .
          buffer-copy buf_dis-gds-rule to tt0-dis-gds-rule no-error.
          if error-status:error then delete tt0-dis-gds-rule no-error.
        end.
        
        run ref/disgdsr1.p (
                 input {&update}
                ,input integer(v-gd:gd-code)
                ,input ub.clients.obj-type
                ,input ub.clients.obj-code
                ,INPUT table tt0-dis-gds-rule
                ) no-error .
      end.
      
    end.
  end . /* 73 */
  when 43
  then do :
    find first root_dis-time-rule no-lock where
          root_dis-time-rule.time-rule-num = 50003 no-error .  
      
    find first buf_dis-time-rule no-lock
         where buf_dis-time-rule.upper-time-rule-num = root_dis-time-rule.time-rule-num
           and buf_dis-time-rule.date-from = v-strt-date
           and buf_dis-time-rule.date-to = v-end-date 
           no-error.
    if not available buf_dis-time-rule
    then do :      
      
      run ref/dis-tim1.p (
       input ? /* (IF p-mode = {&ADD-DEF} THEN ? ELSE tt-dis-time-rule.time-rule-num )  p-rule-num */
      ,input root_dis-time-rule.time-rule-num
      ,input root_dis-time-rule.time-rule-num
      ,input "ПЕРИОД ДАТ"
      ,input v-strt-date
      ,input v-end-date
      ,input -1
      ,input -1
      ,input -1
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input root_dis-time-rule.time-rule-num
      ,input root_dis-time-rule.value-type
      ,input table tt0-term_dis-time-rule
      ,input-output v-rec-dis-time
      ,input v-mode
      ,input yes /*p-silent */
      ) NO-ERROR.
      if error-status:error then do:
        undo, return error return-value.
      end.  
      
      find first buf_dis-time-rule no-lock where recid(buf_dis-time-rule) = v-rec-dis-time .
    
    end.
    
    if valid-object (v-thresholds)
    then do :
      do ii = 1 to v-thresholds:Get(ii):  
        v-threshold = cast (v-thresholds:SubjectObjCurr, promotion_threshold).  
        
        run ref/dis-rul1.p (
         input  ? /* (IF v-mode = {&ADD-DEF} THEN ? ELSE tt-dis-rule.rule-num ) p-rule-num */
        ,input "IBM-XML"
        ,input root_dis-rule.rule-num
        ,input root_dis-rule.rule-num
        ,input p-PromotionObj:name_
        ,input -1
        ,input {&discnt-t-d-card}
        ,input 0
        ,input -1
        ,input ""
        ,input ""
        ,input ""
        ,input ?
        ,input ?
        ,input ?
        ,input ?
        ,input ?
        ,input ?
        ,input INTEGER({&discnt-payment}) /* dis-rule.subject-type */
        ,input root_dis-time-rule.time-rule-num
        ,input buf_dis-time-rule.time-rule-num
        ,input root_dis-rule.rule-num
        ,input integer({&discnt-v-abs}) /* dis-rule.value-type */
        ,input ub.clients.host-code
        ,INPUT ub.clients.obj-type
        ,INPUT ub.clients.obj-code
        ,INPUT v-threshold:dscnt
        ,input table tt0-term_dis-rule
        ,input-output v-rec-dis-rule
        ,input v-mode
        ,input yes /*p-silent */
        ) NO-ERROR.
        if error-status:error then do:
          undo, return error return-value.
        end.
        
        find first buf_dis-rule exclusive-lock where recid(buf_dis-rule) = v-rec-dis-rule .
        buf_dis-rule.promo-id = p-PromotionObj:code_ .
        
        if p-PromotionObj:status_ = 1
        then do :
        
          find first loc_dis-rule exclusive-lock where
                recid(loc_Dis-rule) = recid(buf_Dis-rule) no-error .
          v-sts = ? .
          run ref/dis-rul2.p (
                        buffer loc_dis-rule
                      , input yes /*p-silent*/
                      , input ? /*p-pos-type*/
                      , input-output v-sts
                      ) no-error.
          if error-status:error then do:
            undo, return error return-value .
          end.
          
          next .
        end.
        
        do jj = 1 to num-entries(p-PromotionObj:pmnt-types) :
          find first ub.cash-pay no-lock where ub.cash-pay.cdpay-code = integer(entry(jj, p-PromotionObj:pmnt-types)) no-error .
          if not available ub.cash-pay
          then do :
            undo, return error ("Нет типа кассового платежа с кодом " + entry(jj, p-PromotionObj:pmnt-types) ) .
          end.
          
          find first buf_dis-cp-rule exclusive-lock where
                     buf_dis-cp-rule.cdpay-code  = ub.cash-pay.cdpay-code
                 AND buf_dis-cp-rule.curr-code  = ub.cash-pay.curr-code
                 AND buf_dis-cp-rule.obj-type  = ub.clients.obj-type
                 AND buf_dis-cp-rule.host-code = ub.clients.host-code
                 AND buf_dis-cp-rule.obj-code  = ub.clients.obj-code
                 AND buf_dis-cp-rule.pos-type  = "IBM-XML"
                 AND buf_dis-cp-rule.discnt-role = {&dcpr-simple-pay}
                 and buf_dis-cp-rule.nonunique = ""
                 no-error .
          if not available buf_dis-cp-rule then do:
            create buf_dis-cp-rule .
            assign
            buf_dis-cp-rule.cdpay-code  = ub.cash-pay.cdpay-code
            buf_dis-cp-rule.curr-code  = ub.cash-pay.curr-code
            buf_dis-cp-rule.host-code  = ub.clients.host-code
            buf_dis-cp-rule.obj-type  = ub.clients.obj-type
            buf_dis-cp-rule.obj-code  = ub.clients.obj-code
            buf_dis-cp-rule.pos-type = "IBM-XML"
            buf_dis-cp-rule.discnt-role = {&dcpr-simple-pay}
            buf_dis-cp-rule.rule-num = buf_dis-rule.rule-num
            buf_dis-cp-rule.nonunique = ""
            no-error
            .
          end.
          ASSIGN
          buf_dis-cp-rule.rule-num = buf_dis-rule.rule-num
          buf_dis-cp-rule.rl-root = buf_dis-rule.rl-root
          buf_dis-cp-rule.templ-rl-root = root_dis-rule.rl-root
          buf_dis-cp-rule.time-templ-rl-root = 0
          buf_dis-cp-rule.nonunique = ""
          no-error.

        end.
      end.
    end.
      
  end . /* 43 */
  when 42
  then do :
    find first root_dis-time-rule no-lock where
          root_dis-time-rule.time-rule-num = 50003 no-error .  
      
    find first buf_dis-time-rule no-lock
         where buf_dis-time-rule.upper-time-rule-num = root_dis-time-rule.time-rule-num
           and buf_dis-time-rule.date-from = v-strt-date
           and buf_dis-time-rule.date-to = v-end-date 
           no-error.
    if not available buf_dis-time-rule
    then do :      
      
      run ref/dis-tim1.p (
       input ? /* (IF p-mode = {&ADD-DEF} THEN ? ELSE tt-dis-time-rule.time-rule-num )  p-rule-num */
      ,input root_dis-time-rule.time-rule-num
      ,input root_dis-time-rule.time-rule-num
      ,input "ПЕРИОД ДАТ"
      ,input v-strt-date
      ,input v-end-date
      ,input -1
      ,input -1
      ,input -1
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input root_dis-time-rule.time-rule-num
      ,input root_dis-time-rule.value-type
      ,input table tt0-term_dis-time-rule
      ,input-output v-rec-dis-time
      ,input v-mode
      ,input yes /*p-silent */
      ) NO-ERROR.
      if error-status:error then do:
        undo, return error return-value.
      end.  
      
      find first buf_dis-time-rule no-lock where recid(buf_dis-time-rule) = v-rec-dis-time .
    
    end.
    
    if valid-object (v-thresholds)
    then do :
      do ii = 1 to v-thresholds:Get(ii):  
        v-threshold = cast (v-thresholds:SubjectObjCurr, promotion_threshold).  
        
        run ref/dis-rul1.p (
         input  ? /* (IF v-mode = {&ADD-DEF} THEN ? ELSE tt-dis-rule.rule-num ) p-rule-num */
        ,input "IBM-XML"
        ,input root_dis-rule.rule-num
        ,input root_dis-rule.rule-num
        ,input p-PromotionObj:name_
        ,input -1
        ,input {&discnt-t-another}
        ,input 0
        ,input -1
        ,input ""
        ,input ""
        ,input ""
        ,input ?
        ,input ?
        ,input ?
        ,input 0
        ,input 0
        ,input ?
        ,input INTEGER({&discnt-payment}) /* dis-rule.subject-type */
        ,input root_dis-time-rule.time-rule-num
        ,input buf_dis-time-rule.time-rule-num
        ,input root_dis-rule.rule-num
        ,input integer({&discnt-v-pcnt}) /* dis-rule.value-type */
        ,input ub.clients.host-code
        ,INPUT ub.clients.obj-type
        ,INPUT ub.clients.obj-code
        ,INPUT v-threshold:dscnt
        ,input table tt0-term_dis-rule
        ,input-output v-rec-dis-rule
        ,input v-mode
        ,input yes /*p-silent */
        ) NO-ERROR.
        if error-status:error then do:
          undo, return error return-value.
        end.
        
        find first buf_dis-rule exclusive-lock where recid(buf_dis-rule) = v-rec-dis-rule .
        buf_dis-rule.promo-id = p-PromotionObj:code_ .
        
        if p-PromotionObj:status_ = 1
        then do :
        
          find first loc_dis-rule exclusive-lock where
                recid(loc_Dis-rule) = recid(buf_Dis-rule) no-error .
          v-sts = ? .
          run ref/dis-rul2.p (
                        buffer loc_dis-rule
                      , input yes /*p-silent*/
                      , input ? /*p-pos-type*/
                      , input-output v-sts
                      ) no-error.
          if error-status:error then do:
            undo, return error return-value .
          end.
          
          next .
        end.
        
        do jj = 1 to num-entries(p-PromotionObj:pmnt-types) :
          find first ub.cash-pay no-lock where ub.cash-pay.cdpay-code = integer(entry(jj, p-PromotionObj:pmnt-types)) no-error .
          if not available ub.cash-pay
          then do :
            undo, return error ("Нет типа кассового платежа с кодом " + entry(jj, p-PromotionObj:pmnt-types) ) .
          end.
          
          find first buf_dis-cp-rule exclusive-lock where
                     buf_dis-cp-rule.cdpay-code  = ub.cash-pay.cdpay-code
                 AND buf_dis-cp-rule.curr-code  = ub.cash-pay.curr-code
                 AND buf_dis-cp-rule.obj-type  = ub.clients.obj-type
                 AND buf_dis-cp-rule.host-code = ub.clients.host-code
                 AND buf_dis-cp-rule.obj-code  = ub.clients.obj-code
                 AND buf_dis-cp-rule.pos-type  = "IBM-XML"
                 AND buf_dis-cp-rule.discnt-role = {&dcpr-simple-pay}
                 and buf_dis-cp-rule.nonunique = ""
                 no-error .
          if not available buf_dis-cp-rule then do:
            create buf_dis-cp-rule .
            assign
            buf_dis-cp-rule.cdpay-code  = ub.cash-pay.cdpay-code
            buf_dis-cp-rule.curr-code  = ub.cash-pay.curr-code
            buf_dis-cp-rule.host-code  = ub.clients.host-code
            buf_dis-cp-rule.obj-type  = ub.clients.obj-type
            buf_dis-cp-rule.obj-code  = ub.clients.obj-code
            buf_dis-cp-rule.pos-type = "IBM-XML"
            buf_dis-cp-rule.discnt-role = {&dcpr-simple-pay}
            buf_dis-cp-rule.rule-num = buf_dis-rule.rule-num
            buf_dis-cp-rule.nonunique = ""
            no-error
            .
          end.
          ASSIGN
          buf_dis-cp-rule.rule-num = buf_dis-rule.rule-num
          buf_dis-cp-rule.rl-root = buf_dis-rule.rl-root
          buf_dis-cp-rule.templ-rl-root = root_dis-rule.rl-root
          buf_dis-cp-rule.time-templ-rl-root = 0
          buf_dis-cp-rule.nonunique = ""
          no-error.

        end.
      end.  
    end.
      
  end . /* 42 */
  when 28
  then do :
    if valid-object (v-thresholds)
    then do :
      do ii = 1 to v-thresholds:Get(ii):
        v-threshold = cast (v-thresholds:SubjectObjCurr, promotion_threshold).
        v-discnt-value = v-threshold:dscnt .
        if v-discnt-value <> ?
        and v-discnt-value <> 0
        then do :
          leave .
        end.
      end.
    end.
    
    find first root_dis-time-rule no-lock where
          root_dis-time-rule.time-rule-num = 50008 no-error . 
    
    if valid-object (v-shedule)
    then do :
      do ii = 1 to v-shedule:Get(ii):
        v-shedule-line = cast (v-shedule:SubjectObjCurr, promotion_shedule-line).
        run ref/dis-tim1.p (
         input ? /* (IF p-mode = {&ADD-DEF} THEN ? ELSE tt-dis-time-rule.time-rule-num )  p-rule-num */
        ,input root_dis-time-rule.time-rule-num
        ,input root_dis-time-rule.time-rule-num
        ,input "ПЕРИОД ДАТ с расписанием и днями недели"
        ,input v-strt-date
        ,input v-end-date
        ,input f-int-time(v-shedule-line:strt-time)
        ,input f-int-time(v-shedule-line:end-time)
        ,input -1
        ,input if integer(v-shedule-line:day_) = 0 then yes else no
        ,input if integer(v-shedule-line:day_) = 1 then yes else no
        ,input if integer(v-shedule-line:day_) = 2 then yes else no
        ,input if integer(v-shedule-line:day_) = 3 then yes else no
        ,input if integer(v-shedule-line:day_) = 4 then yes else no
        ,input if integer(v-shedule-line:day_) = 5 then yes else no
        ,input if integer(v-shedule-line:day_) = 6 then yes else no
        ,input if integer(v-shedule-line:day_) = 7 then yes else no
        ,input root_dis-time-rule.time-rule-num
        ,input root_dis-time-rule.value-type
        ,input table tt0-term_dis-time-rule
        ,input-output v-rec-dis-time
        ,input v-mode
        ,input yes /*p-silent */
        ) NO-ERROR.
        if error-status:error then do:
          undo, return error return-value.
        end.  
        
        find first buf_dis-time-rule no-lock where recid(buf_dis-time-rule) = v-rec-dis-time .
        
        create tt0-term_dis-rule .
        BUFFER-COPY root_dis-rule TO tt0-term_dis-rule
        ASSIGN
          tt0-term_dis-rule.rule-num                = ii
          tt0-term_dis-rule.host-code               = ub.clients.host-code
          tt0-term_dis-rule.obj-type                = ub.clients.obj-type
          tt0-term_dis-rule.obj-code                = ub.clients.obj-code
          tt0-term_dis-rule.dis-kat                 = 0
          tt0-term_dis-rule.doc-qnty                = 0
          tt0-term_dis-rule.discnt-value            = v-discnt-value
          tt0-term_dis-rule.time-rule-num           = buf_dis-time-rule.time-rule-num
          tt0-term_dis-rule.time-templ-rl-root      = root_dis-time-rule.time-rule-num
          tt0-term_dis-rule.sts                     = INTEGER({&non-root-status-int})
          tt0-term_dis-rule.tot-sum                 = 0
          tt0-term_dis-rule.upper-rule-num          = root_dis-rule.rule-num
          tt0-term_dis-rule.root                    = no
          tt0-term_dis-rule.des                     = ("На день недели " + v-shedule-line:day_ )
          tt0-term_dis-rule.lvl-num                 = 2
          tt0-term_dis-rule.key#_one                = 0
          tt0-term_dis-rule.key#_two                = 0
          tt0-term_dis-rule.key#_three              = 0
          tt0-term_dis-rule.charkey_one             = "":U
          tt0-term_dis-rule.charkey_two             = "":U
          tt0-term_dis-rule.charkey_three           = "":U
          tt0-term_dis-rule.deckey_one              = 0
          tt0-term_dis-rule.deckey_two              = 0
          tt0-term_dis-rule.deckey_three            = 0
        .
        
      end.
    end. /* schedule */
    
    run ref/dis-rul1.p (
     input  ? /* (IF v-mode = {&ADD-DEF} THEN ? ELSE tt-dis-rule.rule-num ) p-rule-num */
    ,input "IBM-XML"
    ,input root_dis-rule.rule-num
    ,input root_dis-rule.rule-num
    ,input p-PromotionObj:name_
    ,input -1
    ,input {&discnt-t-time}
    ,input -1
    ,input -1
    ,input ""
    ,input ""
    ,input ""
    ,input ?
    ,input ?
    ,input ?
    ,input ?
    ,input ?
    ,input ?
    ,input INTEGER({&discnt-gds})
    ,input root_dis-time-rule.time-rule-num
    ,input buf_dis-time-rule.time-rule-num
    ,input root_dis-rule.rule-num
    ,input integer({&discnt-v-pcnt})
    ,input ub.clients.host-code
    ,INPUT ub.clients.obj-type
    ,INPUT ub.clients.obj-code
    ,INPUT 0
    ,input table tt0-term_dis-rule
    ,input-output v-rec-dis-rule
    ,input v-mode
    ,input yes /*p-silent */
    ) NO-ERROR.
    if error-status:error then do:
      undo, return error return-value.
    end.
    
    find first buf_dis-rule exclusive-lock where recid(buf_dis-rule) = v-rec-dis-rule .
    buf_dis-rule.promo-id = p-PromotionObj:code_ .
    
    if p-PromotionObj:status_ = 1
    then do :
      find first loc_dis-rule exclusive-lock where
            recid(loc_Dis-rule) = recid(buf_Dis-rule) no-error .
      v-sts = ? .
      run ref/dis-rul2.p (
                    buffer loc_dis-rule
                  , input yes /*p-silent*/
                  , input ? /*p-pos-type*/
                  , input-output v-sts
                  ) no-error.
      if error-status:error then do:
        undo, return error return-value .
      end.
      
      return .
    end.
    
    if valid-object (v-gds)
    then do :
      do ii = 1 to v-gds:Get(ii) :
        v-gd = cast (v-gds:SubjectObjCurr, promotion_gd). 
        
        empty temp-table tt0-dis-gds-rule .
        
        create tt0-dis-gds-rule .
        assign
          tt0-dis-gds-rule.obj-type           = ub.clients.obj-type
          tt0-dis-gds-rule.obj-code           = ub.clients.obj-code
          tt0-dis-gds-rule.gds-code           = integer(v-gd:gd-code)
          tt0-dis-gds-rule.rule-num           = buf_dis-rule.rule-num
          tt0-dis-gds-rule.pos-type           = "IBM-XML"
          tt0-dis-gds-rule.templ-rl-root      = root_dis-rule.rule-num
          tt0-dis-gds-rule.whole-send-news    = 0
          tt0-dis-gds-rule.discnt-role        = {&dgr-temp-disc}
          tt0-dis-gds-rule.time-templ-rl-root = root_dis-time-rule.time-rule-num
          tt0-dis-gds-rule.nonunique          = ""
          tt0-dis-gds-rule.rl-root            = buf_dis-rule.rule-num
        .
        
        for each buf_dis-gds-rule no-lock where buf_dis-gds-rule.obj-type           = ub.clients.obj-type
                                            and buf_dis-gds-rule.obj-code           = ub.clients.obj-code
                                            and buf_dis-gds-rule.gds-code           = integer(v-gd:gd-code)
                                            and buf_dis-gds-rule.pos-type           = "IBM-XML" :
          create tt0-dis-gds-rule .
          buffer-copy buf_dis-gds-rule to tt0-dis-gds-rule no-error.
          if error-status:error then delete tt0-dis-gds-rule no-error.
        end.                                      
        
        run ref/disgdsr1.p (
                 input {&update}
                ,input integer(v-gd:gd-code)
                ,input ub.clients.obj-type
                ,input ub.clients.obj-code
                ,INPUT table tt0-dis-gds-rule
                ) no-error .
      end.
      
    end. /* gds */
    
  end. /* 28 */
  when 20
  then do :
    find first root_dis-time-rule no-lock where
          root_dis-time-rule.time-rule-num = 50003 no-error .  
      
    find first buf_dis-time-rule no-lock
         where buf_dis-time-rule.upper-time-rule-num = root_dis-time-rule.time-rule-num
           and buf_dis-time-rule.date-from = v-strt-date
           and buf_dis-time-rule.date-to = v-end-date 
           no-error.
    if not available buf_dis-time-rule
    then do :      
      
      run ref/dis-tim1.p (
       input ? /* (IF p-mode = {&ADD-DEF} THEN ? ELSE tt-dis-time-rule.time-rule-num )  p-rule-num */
      ,input root_dis-time-rule.time-rule-num
      ,input root_dis-time-rule.time-rule-num
      ,input "ПЕРИОД ДАТ"
      ,input v-strt-date
      ,input v-end-date
      ,input -1
      ,input -1
      ,input -1
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input ?
      ,input root_dis-time-rule.time-rule-num
      ,input root_dis-time-rule.value-type
      ,input table tt0-term_dis-time-rule
      ,input-output v-rec-dis-time
      ,input v-mode
      ,input yes /*p-silent */
      ) NO-ERROR.
      if error-status:error then do:
        undo, return error return-value.
      end.  
      
      find first buf_dis-time-rule no-lock where recid(buf_dis-time-rule) = v-rec-dis-time .
    
    end.
    
    if valid-object (v-thresholds)
    then do :
      do ii = 1 to v-thresholds:Get(ii):  
        v-threshold = cast (v-thresholds:SubjectObjCurr, promotion_threshold).  
          
        create tt0-term_dis-rule .
        BUFFER-COPY root_dis-rule TO tt0-term_dis-rule
        ASSIGN
          tt0-term_dis-rule.rule-num                = ii
          tt0-term_dis-rule.host-code               = ub.clients.host-code
          tt0-term_dis-rule.obj-type                = ub.clients.obj-type
          tt0-term_dis-rule.obj-code                = ub.clients.obj-code
          tt0-term_dis-rule.dis-kat                 = 0
          tt0-term_dis-rule.doc-qnty                = 0
          tt0-term_dis-rule.discnt-value            = v-threshold:dscnt
          tt0-term_dis-rule.time-rule-num           = buf_dis-time-rule.time-rule-num
          tt0-term_dis-rule.time-templ-rl-root      = root_dis-time-rule.time-rule-num
          tt0-term_dis-rule.sts                     = INTEGER({&non-root-status-int})
          tt0-term_dis-rule.tot-sum                 = v-threshold:value_
          tt0-term_dis-rule.upper-rule-num          = root_dis-rule.rule-num
          tt0-term_dis-rule.root                    = no
          tt0-term_dis-rule.des                     = ("На сумму от " + string(v-threshold:value_) )
          tt0-term_dis-rule.lvl-num                 = 2
          tt0-term_dis-rule.key#_one                = 0
          tt0-term_dis-rule.key#_two                = 0
          tt0-term_dis-rule.key#_three              = 0
          tt0-term_dis-rule.charkey_one             = "":U
          tt0-term_dis-rule.charkey_two             = "":U
          tt0-term_dis-rule.charkey_three           = "":U
          tt0-term_dis-rule.deckey_one              = 0
          tt0-term_dis-rule.deckey_two              = 0
          tt0-term_dis-rule.deckey_three            = 0
        .
      end .
      
    end. /* thresholds */
      
    run ref/dis-rul1.p (
     input  ? /* (IF v-mode = {&ADD-DEF} THEN ? ELSE tt-dis-rule.rule-num ) p-rule-num */
    ,input "IBM-XML"
    ,input root_dis-rule.rule-num
    ,input root_dis-rule.rule-num
    ,input p-PromotionObj:name_
    ,input -1
    ,input {&discnt-t-std}
    ,input -1
    ,input 0
    ,input ""
    ,input ""
    ,input ""
    ,input ?
    ,input ?
    ,input ?
    ,input ?
    ,input ?
    ,input ?
    ,input INTEGER({&discnt-total})
    ,input root_dis-time-rule.time-rule-num
    ,input buf_dis-time-rule.time-rule-num
    ,input root_dis-rule.rule-num
    ,input integer({&discnt-v-pcnt})
    ,input ub.clients.host-code
    ,INPUT ub.clients.obj-type
    ,INPUT ub.clients.obj-code
    ,INPUT 0
    ,input table tt0-term_dis-rule
    ,input-output v-rec-dis-rule
    ,input v-mode
    ,input yes /*p-silent */
    ) NO-ERROR.
    if error-status:error then do:
      undo, return error return-value.
    end.
    
    find first buf_dis-rule exclusive-lock where recid(buf_dis-rule) = v-rec-dis-rule .
    buf_dis-rule.promo-id = p-PromotionObj:code_ .
    
    if p-PromotionObj:status_ = 1
    then do :
      find first loc_dis-rule exclusive-lock where
            recid(loc_Dis-rule) = recid(buf_Dis-rule) no-error .
      v-sts = ? .
      run ref/dis-rul2.p (
                    buffer loc_dis-rule
                  , input yes /*p-silent*/
                  , input ? /*p-pos-type*/
                  , input-output v-sts
                  ) no-error.
      if error-status:error then do:
        undo, return error return-value .
      end.
      
      return .
    end.
    
  end. /* 20 */
end case .

run str/diallog.w (this-procedure, this-procedure, 'str/sendtotd.p':U, (string(ub.clients.obj-code) + {&delim-par} + 'U' + {&delim-par} + 'all':U), yes, '', 'Отправка информации по скидкам') .

procedure mainmenu_getcntxt :
  define output parameter v-cntxt-db-num        as integer   no-undo . /* текущая БД            */   
  define output parameter v-cntxt-userid        as character no-undo . /* текущий пользователь  */   
  define output parameter v-cntxt-level         as character no-undo . /* уровень контекста     */   
  define output parameter v-cntxt-host-code-obj as integer   no-undo . /* текущая фирма         */   
  define output parameter v-cntxt-obj-type      as character no-undo . /* тип текущего объекта  */   
  define output parameter v-cntxt-obj-code      as integer   no-undo . /* код текущего объекта  */   
  define output parameter v-cntxt-db-num-obj    as integer   no-undo . /* база текущего объекта */   
  define output parameter v-cntxt-is-admin      as logical   no-undo . /* база текущего объекта */  
  
  run  get-db-num (output v-cntxt-db-num ) no-error .
  v-cntxt-userid = g#userid .
  v-cntxt-level = ? .
  v-cntxt-host-code-obj = ub.clients.host-code .
  v-cntxt-obj-type = ub.clients.obj-type .
  v-cntxt-obj-code = ub.clients.obj-code .
  v-cntxt-db-num-obj = ub.clients.db-num .
  v-cntxt-is-admin =  ? .
end procedure .
*/
