block-level on error undo, throw.
/*

$Revision: 8f5f559ebdb3, 2359, rls $
$Author: EShklyar $
$Date: Ср июн 10 21:13:34 2020 +0300 $
$Workfile: r-help-road.p $
$Archive: rep/r-help-road.p $

Выгрузка реализации банковских продуктов

Автор: Белоусов Илья Александрович
Дата создания: 04/13/09
Author: Ilia Belousov
Creation date: 04/13/09

*/
{ rep/exp-help-road.i   }

define input parameter p-date          as integer          no-undo.
define input parameter p-folder        as character        no-undo.
define input parameter p-name          as character        no-undo.
define input parameter p-date-from     as date             no-undo.
define input parameter p-date-to       as date             no-undo.
define input parameter p-ftp-path      as character        no-undo.
define input parameter p-ftp-target-dir as character        no-undo.
define input parameter p-log-handle    as handle no-undo .
define input parameter table   FOR tt-obj.
define input parameter table   FOR tt-oss-ref.
define input parameter table   FOR tt-gds-list.

define variable vss-revision    as character no-undo init "$Revision: 8f5f559ebdb3, 2359, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$Date: Ср июн 10 21:13:34 2020 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-help-road.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-help-road.p $":U .
define variable vss-description as character no-undo init "Выгрузка реализации банковских продуктов".

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
/*{ adm/auto-def.i }*/
{ cmp/library.i  }
{ cmp/showinf.i  }
{ trg/factord.i  }
{ gbl/ftp-df.i }

define variable log-file-name     as character no-undo initial ? .
define stream out-stream.
define stream lst-out.
define stream StreamLog.

define variable v-rrn as character no-undo .

define buffer buf_chk-doc       for ub.chk-doc.
define buffer buf_chk-gds       for ub.chk-gds.
define buffer buf_bar-code      for ub.bar-code.
define buffer buf_goods         for ub.goods.
define buffer buf_goods-attr    for ub.goods-attr.
define buffer buf_producer      for ub.clients.
define buffer buf_prod-bc       for ub.prod-bc.
define buffer buf_chk-pay       for ub.chk-pay.
define buffer buf_cash-pay-attr for ub.cash-pay-attr .
define buffer buf_chk-gds-attr  for ub.chk-gds-attr .
define buffer buf_chk-pay-attr  for ub.chk-pay-attr .
define buffer bf_chk-pay-attr   for ub.chk-pay-attr .

do
  on error undo, return error
  :
  define variable v-begin-date            as date      no-undo .
  define variable v-end-date              as date      no-undo .
  define variable v-begin-date0           as date      no-undo .
  define variable v-end-date0             as date      no-undo .
  define variable v-par-val               as character no-undo .
  define variable v-par-type              as character no-undo .
  /*   define variable v-message           as character   no-undo .*/
  define variable v-file-name             as character no-undo . /* Путь к отчету */
  define variable v-file-name-mapping     as character no-undo .
  define variable v-file-name-mapping-new as character no-undo .  
  define variable v-fmt                   as character no-undo .
  define variable v-weekday-today         as integer   no-undo .
  define variable v-b-code                as integer   no-undo .
  define variable v-bar                   as character no-undo .
  define variable v-prod-name             as character no-undo .
  define variable v-gds-code              as integer   no-undo .   
  define variable v-fact-order-start      as decimal   no-undo .
  define variable v-fact-order-end        as decimal   no-undo .
  define variable v-empty-1               as decimal   no-undo .
  define variable v-empty-2               as decimal   no-undo .
  define variable v-gds-name              as character no-undo .
  define variable v-grp-code              as integer   no-undo .
  define variable v-counter               as integer   no-undo .
  define variable v-label                 as character no-undo .
  define variable v-archive-ok            as logical   no-undo.
  define variable v-can-print             as logical   no-undo.
  define variable v-comment               as character no-undo.
  define variable v-grp-name              as character no-undo. 
  define variable v-cli-base-rate         as decimal   no-undo.
   
   &scop display-message    run write-log-and-file in p-log-handle (  ~
         input 1                                                      ~
         , input log-file-name                                          ~
         , input 1                                                      ~
         , input ~{&my-message~})
         
  define frame info
    v-label        label "Этап" format "x(16)" skip
    v-counter      label "Записей" format ">>>,>>>,>>9" skip
    with view-as dialog-box side-labels 1 columns three-d title "Формирование отчета"
    .
  assign
    log-file-name = "Rep_BPA.log"
    .

  IF p-date <> ? 
    THEN 
  DO:
    assign
      v-begin-date    = TODAY - p-date
      v-end-date      = TODAY
      v-begin-date0   = v-begin-date
      v-end-date0     = v-end-date
      .
  END.
  ELSE 
  DO:
    assign
      /*         v-weekday-today = WEEKDAY(p-date)*/
      /*         v-begin-date    = p-date - v-weekday-today - 5*/
      /*         v-end-date      = p-date - v-weekday-today + 1*/
      v-end-date0   = p-date-to
      v-begin-date0 = p-date-from
      .
  END.
  
  if p-folder <> "" then 
  do:
    v-file-name = p-folder + "\" + p-name .
  end.
  else 
  do:
    v-file-name = p-name .
  end.    
  output stream out-stream to value(v-file-name + ".csv") .

  for each tt-obj no-lock:
    for each buf_chk-doc no-lock                                                         /* Фильтруем чеки по объектам, датам и типам чеков */
      where buf_chk-doc.obj-type = tt-obj.obj-type 
      and buf_chk-doc.obj-code = tt-obj.obj-code
      and buf_chk-doc.chk-date <= v-end-date0
      and buf_chk-doc.chk-date >= v-begin-date0
      and buf_chk-doc.out-code > "":
      if lookup(string(buf_chk-doc.chk-type), {&no-sale-receipt-codes}) > 0 then next .
      for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code,
        first buf_bar-code no-lock where buf_bar-code.b-code = buf_chk-gds.b-code,
        first buf_goods-attr no-lock where buf_goods-attr.gds-code = buf_bar-code.gds-code
        and buf_goods-attr.attr-code = {&attr-oper-serv-id} :
          
        find first tt-oss-ref where tt-oss-ref.id = integer(buf_goods-attr.attr-value) no-error .
        if available (tt-oss-ref) then do:
        find first tt-gds-list no-lock where tt-gds-list.gds-code = buf_goods-attr.gds-code no-error .   /* Смотрим линии выбранного чека */
        if available (tt-gds-list) then do:
        find first buf_chk-pay no-lock where buf_chk-pay.doc-code = buf_chk-gds.doc-code and buf_chk-pay.line-num = buf_chk-gds.line-num no-error .
        find first buf_chk-gds-attr no-lock where buf_chk-gds-attr.attr-code = "agent-gd-code" and buf_chk-gds-attr.doc-code = buf_chk-gds.doc-code no-error .
        
        put stream out-stream unformatted
          tt-obj.obj-name ";"
          tt-gds-list.gds-name ";".
          
        if available (buf_chk-gds-attr) then 
        do:
          put stream out-stream unformatted
            buf_chk-gds-attr.attr-value ";".
        end.
        else 
        do:
          put stream out-stream unformatted 
            "" ";".
        end.
          
        if available (buf_chk-pay) then 
        do: 
          put stream out-stream unformatted
            string(buf_chk-pay.chk-date) ";" string(buf_chk-doc.chk-time,"HH:MM:SS") ";" 
            string(buf_chk-pay.tot-sum) ";"
            .
          find first buf_cash-pay-attr where buf_cash-pay-attr.cdpay-code = buf_chk-pay.pay-code
            and buf_cash-pay-attr.curr-code = buf_chk-pay.curr-code
            and buf_cash-pay-attr.attr-code = "cash-prop" no-error .
          v-rrn = "" .                       
          if AVAILABLE buf_cash-pay-attr then 
          do:
            if buf_cash-pay-attr.attr-value <> "1" then 
            do:
              put stream out-stream unformatted
                "Электронные" ";".
                
              for first buf_chk-pay-attr no-lock
                where  buf_chk-pay-attr.doc-code = buf_chk-pay.doc-code 
                and buf_chk-pay-attr.attr-code = "RRN" 
                and buf_chk-pay-attr.line-num = buf_chk-pay.line-num  :
                v-rrn = buf_chk-pay-attr.attr-value.
              end.       
              if v-rrn = '' then 
                for first bf_chk-pay-attr no-lock
                  where bf_chk-pay-attr.doc-code = buf_chk-pay.doc-code 
                  and bf_chk-pay-attr.attr-code = "cpdoc"
                  and bf_chk-pay-attr.line-num = buf_chk-pay.line-num:
                  v-rrn = bf_chk-pay-attr.attr-value.
                end.
              put stream out-stream unformatted
                v-rrn .
            end.
            else  
            do:
              put stream out-stream unformatted
                "Наличные" ";".
              put stream out-stream unformatted
                v-rrn .  
            end.
          end.
        end.   
        else 
        do:
          put stream out-stream unformatted
            ";"
            ";"
            .     
        end.
        put stream out-stream unformatted
          "" {&new-line}.
      end. /*for each buf_chk-gds no-lock where buf_chk-gds.doc-code = buf_chk-doc.doc-code*/
    end. /*for each buf_chk-doc no-lock */
  end. /*for each tt-obj no-lock:*/
end.
end.
end.
    