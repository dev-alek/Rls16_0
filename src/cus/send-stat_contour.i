
/*------------------------------------------------------------------------
    File        : send-stat_contour.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SSlivenko
    Created     : Wed Jul 29 16:11:11 MSK 2015
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */


define variable ExpData1 as class Route-data_ no-undo .
&scop constructor_1 ( input parparentproc, input p-parent-handle, input p-log-handle, input this-procedure:handle)
ExpData1 = new Route-data_{&constructor_1} .

define variable v-DATA as memptr no-undo.

/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
define variable v-esys-cmd-proc-handle as handle no-undo .
define variable v-esys-cmd-code as integer no-undo .


 { rul/context_f.i  begin-esys-command }
 { rul/context_f.i  send-esys-command-ext }
 { rul/context_f.i  set-custom-esys-pck-name }
 { rul/context_f.i  delete-command }


procedure send-stat_contour :
    
  define input parameter p-doc-type as character no-undo .
  define input parameter p-state as character no-undo .
  define input parameter p-stage as character no-undo .
  define input parameter p-description as character no-undo .
  define input parameter p-messID as character no-undo .

  define variable v-ii as integer no-undo .
  define variable v-uniq-key-rec as character no-undo .
  define variable v-cli-uniq-key-rec as character no-undo .
  define variable v-err as logical no-undo .
  define variable v-custom-pack-name as character no-undo .
  define variable v-success as logical   no-undo .
  DEFINE VARIABLE v-today as date no-undo .
  DEFINE VARIABLE v-time as integer no-undo .
  define variable v-ord-int1 as integer no-undo .
  define variable v-obj-gln as character no-undo .
  define variable v-cli-gln as character no-undo .
  define variable v-gln-net as character no-undo .
  define variable v-type as character no-undo .
  define variable v-mess as character no-undo .
  define variable v-b-code as integer no-undo .
  define variable v-b-str as character no-undo .
  define variable v-jj as integer   no-undo .
  define variable v-cli-base-rate as decimal no-undo .
  define variable v-dump-ord-int64 as int64 no-undo .
  define variable v-rcv-code as character no-undo .
  define variable v-cli-rcv-code as character no-undo .
  define variable v-EDIINTERCHANGEID as character no-undo .
  define variable v-edist-mess as character no-undo .
  define variable v-date-status as character no-undo .
  define variable v-time-status as integer no-undo .
  define variable v-error as character no-undo .
  define variable v-stringdate as character no-undo .
  define variable v-documentNumber as character no-undo .
  define variable v-documentDate as character no-undo .
  define variable sw as handle no-undo .

  define buffer buf_ext-system for ub.ext-system.
  define buffer buf_ord-doc for ub.ord-doc.
  define buffer buf_ord-line for ub.ord-line.
  define buffer buf_object for ub.clients.
  define buffer buf_clients for ub.clients.
  define buffer buf_ext-classif for ub.ext-classif.
  define buffer esys_ext-classif for ub.ext-classif.
  define buffer buf_goods for ub.goods.
  define buffer buf_ord-doc-rcv for ub.ord-doc-rcv.
  define buffer buf_currency for ub.currency.
  define buffer buf_ord-line-attr for ub.ord-line-attr.
  define buffer buf_edi-status for ub.edi-status.

/* ------------------------- &end-hn-option& -----------------------------------*/
_main:
do
on error undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
on stop undo, return error substitute( "&1&2&3&2&4", return-value, {&new-line}, error-status :get-message (1), v-last-error-message)
:

  if retry then do:
    &scop my-message substitute("Ошибка при отправке статуса по заказу &1:&2&3" ~
                                   , v-current-doc-code  ~
                                   , ~{&new-line~}, v-mess)
    {&display-message}.
    undo _main, return error.
  end.
  else do:
    assign
    v-mess = ''
    .
    /*найдем сам заказ*/
    find first buf_ord-doc exclusive-lock where
              buf_ord-doc.doc-code = v-current-doc-code no-error .
    if not available buf_ord-doc then do:
      v-mess = substitute("Не найден заказ для поставки").
      v-err = yes.
      undo _main, retry _main.
    end.
    if p-doc-type = "DESADV" then do :
        find first buf_ord-doc-rcv no-lock where buf_ord-doc-rcv.doc-code = v-current-doc-code no-error .
        if available buf_ord-doc-rcv then assign v-rcv-code = buf_ord-doc-rcv.rcv-code .
    end.    
    /* ------------------------- &start-rule& -----------------------------------*/
    
    find first buf_clients no-lock where
              buf_clients.obj-type = buf_ord-doc.cli-type
          and buf_clients.obj-code = buf_ord-doc.cli-code no-error.
    if not available buf_clients then do:
      v-mess =  substitute("Не найден контрагент &1&2", buf_ord-doc.cli-type, buf_ord-doc.cli-code).
      v-err = yes.
      undo _main, retry _main.
    end.

    
    run gen-key-rec in this-procedure ( input {&table_clients}
                                      ,input (buffer buf_clients:handle)
                                      ,output v-cli-uniq-key-rec) no-error .
    if error-status:error then do:
      v-mess = substitute("gen-key-rec: &1&2&3&2(&4&5)"
                                , error-status:get-message(1)
                                , return-value
                                , {&new-line}
                                , buf_ord-doc.cli-type
                                , buf_ord-doc.cli-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    find first esys_ext-classif no-lock where
        esys_ext-classif.classif-name = {&extclass_clients_exite-edi}
    and esys_ext-classif.classif-subject = {&table_clients}
    and esys_ext-classif.db-num = -1
    and esys_Ext-classif.uniq-key-rec = v-cli-uniq-key-rec no-error .
    if not available esys_ext-classif then do:
      v-mess = substitute("Поставщик &1&2 заказа НЕ РАБОТАЕТ ПО СИСТЕМЕ EDI", buf_ord-doc.cli-type, buf_ord-doc.cli-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    find first buf_object no-lock where
              buf_object.obj-type = v-current-obj-type
          and buf_object.obj-code = v-current-obj-code no-error.
    if not available buf_object then do:
      v-mess =  substitute("Не найден объект &1&2", v-current-obj-type, v-current-obj-code).
      v-err = yes.
      undo _main, retry _main.
    end.
/*    if buf_object.db-num <> g#db-num then do:                                                          */
/*      v-mess = substitute("Объект &1&2 принадлежит другой БД", v-current-obj-type, v-current-obj-code).*/
/*      v-err = yes.                                                                                     */
/*      undo _main, retry _main.                                                                         */
/*    end.                                                                                               */
    run gen-key-rec in this-procedure ( input {&table_clients}
                                      ,input (buffer buf_object:handle)
                                      ,output v-uniq-key-rec) no-error .
    if error-status:error then do:
      v-mess =  substitute("gen-key-rec: &1&2&3&2(&4&5)"
                                , error-status:get-message(1)
                                , return-value
                                , {&new-line}
                                , buf_object.obj-type
                                , buf_object.obj-code).
      v-err = yes.
      undo _main, retry _main.
    end.
    assign
    v-obj-gln = get-gln( input buf_object.obj-type
                    ,input buf_object.obj-code) no-error.
    if error-status:error
    or v-obj-gln = {&question-mark}
    or v-obj-gln = '' then do:
      v-mess =  substitute("Не определен GLN для &1&2"
                                , buf_object.obj-type
                                , buf_object.obj-code) .
      v-err = yes.
      undo _main, retry _main.
    end.
    v-cli-gln = get-gln( input buf_ord-doc.cli-type
                        ,input buf_ord-doc.cli-code) no-error.
    if error-status:error
    or v-cli-gln = {&question-mark}
    or v-cli-gln = '' then do:
      v-mess =  substitute("Не определен GLN для &1&2"
                                , buf_object.obj-type
                                , buf_object.obj-code) .
      v-err = yes.
      undo _main, retry _main.
    end.
      /*найдем првязку к EDI*/
    for each esys_ext-classif no-lock where
        esys_ext-classif.classif-name = {&extclass_clients_exite-edi}
    and esys_ext-classif.classif-subject = {&table_clients}
    and esys_ext-classif.db-num = -1
    and esys_Ext-classif.uniq-key-rec = v-cli-uniq-key-rec,
      first buf_ext-system no-lock where
                buf_ext-system.esys-id = esys_ext-classif.key#_one
            and buf_ext-system.db-num = 0
/*            and buf_ext-system.esys-db-num-exp = g#db-num*/
            and buf_ext-system.esys-have-export = yes,
      first buf_ext-classif no-lock where
        buf_ext-classif.classif-name = {&extclass_clients_exite-edi}
    and buf_ext-classif.classif-subject = {&table_clients}
    and buf_ext-classif.db-num = -1
    and buf_Ext-classif.uniq-key-rec = v-uniq-key-rec
    and buf_Ext-classif.key#_one = esys_ext-classif.key#_one:
      leave.
    end.
    if not available buf_ext-system then do:
      v-mess = substitute("Для поставщика &1&2 не найдена ВС, у которой есть экспорт в текущей БД").
      v-err = yes.
      undo _main, retry _main.
    end.
    
    run ext-system-attr-value in this-procedure ( input buf_ext-system.esys-id
                                                 ,input buf_ext-system.db-num
                                                 ,input {&attr-esys-gln-net}
                                                 ,output v-gln-net
                                                 ,output v-type) no-error.

    IF  context_begin-esys-command( input string(buf_ext-system.esys-id), input-output v-esys-cmd-proc-handle, output v-esys-cmd-code) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
/*    run cur-time in this-procedure(output v-today, output v-time) no-error.*/
    v-stringdate = substring(string(NOW), 7, 4) + substring(string(NOW), 4, 2) + substring(string(NOW), 1, 2)
                 + substring(string(NOW), 12, 2) + substring(string(NOW), 15, 2) + substring(string(NOW), 18, 2).
    /*создадим имя custom имя файла*/
    v-custom-pack-name = p-state + "_" + v-stringdate + "_" + p-doc-type + "_" + buf_ord-doc.doc-code + "_&pack-num.xml".
    /*надо найти номер транзакции EXITE и запомнить ошибки - из edi-status*/
    if p-doc-type = "ORDRSP" then do :
        if p-stage = "Read" then
        assign
            v-documentNumber = entry(1, v-cli-out-doc, {&delim-par})
            v-documentDate = entry(2, v-cli-out-doc, {&delim-par})
        .
        else
        assign
            v-documentNumber = entry(1, buf_ord-doc.cli-out-doc, {&delim-par})
            v-documentDate = entry(2, buf_ord-doc.cli-out-doc, {&delim-par})
        .    
        for each buf_edi-status no-lock where
                buf_edi-status.tbl-name = {&table_ord-doc}
           and buf_edi-status.doc-code = v-current-doc-code
           and (buf_edi-status.state = {&edi-orders} or buf_edi-status.state = {&edi-orders-deliv} or buf_edi-status.state = {&edi-ordrsp-sts} or buf_edi-status.state = {&edi-ordrsp})
           and buf_edi-status.err-code < 3 :
          assign
            v-EDIINTERCHANGEID = cr-edist_get-mess-key-value(buf_edi-status.mess, {&edist_ediinterchangeid})
          .
          if v-EDIINTERCHANGEID <> ? and trim(v-EDIINTERCHANGEID) <> "" then leave .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = {&table_ord-doc}
           and temp-edi-status.doc-code begins v-current-doc-code :
          assign
            v-error = v-error + 
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             + 
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = {&table_ord-line}
           and temp-edi-status.doc-code begins v-current-doc-code :
          assign
            v-error = v-error + 
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             + 
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
    end.    
    if p-doc-type = "DESADV" then do :
        assign
            v-documentNumber = v-desadv-DELIVERYNOTENUMBER
            v-documentDate = iso-date(v-desadv-DELIVERYNOTEDATE)
        .
        for each buf_edi-status no-lock where
                buf_edi-status.tbl-name = {&table_ord-doc-rcv}
           and buf_edi-status.doc-code = v-rcv-code
           and buf_edi-status.state = {&edi-desadv-sts}
           and buf_edi-status.err-code < 3 :
          assign
          v-EDIINTERCHANGEID = cr-edist_get-mess-key-value(buf_edi-status.mess, {&edist_ediinterchangeid}).
          if v-EDIINTERCHANGEID <> ? and trim(v-EDIINTERCHANGEID) <> "" then leave .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = {&table_ord-doc}
           and temp-edi-status.doc-code begins v-current-doc-code :
          assign
            v-error = v-error + 
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             + 
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = {&table_ord-line}
           and temp-edi-status.doc-code begins v-current-doc-code :
          assign
            v-error = v-error + 
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             + 
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = {&table_ord-doc-rcv}
           and temp-edi-status.doc-code begins v-rcv-code :
          assign
            v-error = v-error + 
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             + 
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
        for each temp-edi-status no-lock where
                temp-edi-status.tbl-name = {&table_ord-line-rcv}
           and temp-edi-status.doc-code begins v-rcv-code :
          assign
            v-error = v-error + 
                           (if v-error = '' then ''
                            else if trim(cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Арт." then chr(30)
                            else if r-index(v-error, ";") = length(v-error) then ''
                            else ';')
                             + 
                            if (cr-edist_get-error-mean(input temp-edi-status.des-err) ) begins "Инф:" then ""
                            else cr-edist_get-error-mean(input temp-edi-status.des-err)
          .
        end.
    end.    
    
    if v-EDIINTERCHANGEID <> ? and v-EDIINTERCHANGEID <> "" and p-messID = ? then p-messID = v-EDIINTERCHANGEID .
    if p-messID = ? then p-messID = "" .
    
    create sax-writer sw .
    sw:formatted = true.
    sw:set-output-destination ("memptr", v-DATA).
    sw:encoding = "UTF-8".
    sw:start-document () .
    sw:start-element ("statusReport") .
        sw:write-data-element ("reportDateTime", substring(iso-date(NOW), 1, 23) + "Z") .
        sw:write-data-element ("reportRecipient", v-cli-gln) .
        sw:start-element ("reportItem") .
            sw:write-data-element ("messageId", p-messID) .
            sw:write-data-element ("documentId", p-messID) .
            sw:write-data-element ("messageSender", v-cli-gln) .
            sw:write-data-element ("messageRecepient", v-gln-net) .
            sw:write-data-element ("documentType", p-doc-type) .
            sw:write-data-element ("documentNumber", v-documentNumber) .
            sw:write-data-element ("documentDate", v-documentDate) no-error .
            sw:start-element ("statusItem") .
                sw:write-data-element ("dateTime", substring(iso-date(NOW), 1, 23) + "Z") .
                sw:write-data-element ("stage", p-stage) .
                sw:write-data-element ("state", p-state) .
                sw:write-data-element ("description", p-description) .
                if p-stage = "Checking" and p-state = "Ok" and p-description = "Сообщение отклонено на стороне получателя" then
                do :
                    sw:write-data-element ("error", "Заказ УЖЕ в статусе Подтвержден или ПодтвержденОК") .
                end. 
                else if p-stage = "Checking" and p-state = "Fail" and p-doc-type = "DESADV" and p-description = "Сообщение отклонено на стороне получателя в УБД" then
                do :
                    sw:write-data-element ("error", "Поставка уже в работе в УБД") .
                end.     
                else if p-state = "Fail" then
                do :
                    v-error = replace(v-error, {&delim-par}, " ") .
                    v-error = replace(v-error, ";", "; ") .
                    if trim(v-error) <> "" then 
                    do v-ii = 1 to num-entries(v-error, chr(30) ):                            
                        if trim(entry(v-ii, v-error, chr(30) )) <> "" then                    
                        sw:write-data-element ("error", trim(entry(v-ii, v-error, chr(30)))) .
                    end.                   
/*                    sw:write-data-element ("error", v-error) .*/
                end.    
/*                do v-ii = 1 to num-entries(v-error, {&delim-par} ):                            */
/*                    if trim(entry(v-ii, v-error, {&delim-par} )) <> "" then                    */
/*                    sw:write-data-element ("error", trim(entry(v-ii, v-error, {&delim-par}))) .*/
/*                end.                                                                           */
                else do :
                end.      
            sw:end-element ("statusItem") .
        sw:end-element ("reportItem") . 
    sw:end-element ("statusReport") .  
    sw:end-document () .
    delete object sw.     
                                                                                                                        
    IF ExpData1:esys-add-dump-data ( INPUT v-DATA, INPUT v-esys-cmd-proc-handle, INPUT v-esys-cmd-code, '+update') = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    
    IF  context_set-custom-esys-pck-name(  input v-esys-cmd-proc-handle, input v-esys-cmd-code, input v-custom-pack-name) = false  THEN do:
      undo _main, return error v-last-error-message .
    end.
    v-dump-ord-int64 = context_send-esys-command( input string(buf_ext-system.esys-id), input v-esys-cmd-proc-handle, input v-esys-cmd-code, input g#userid).
    if v-dump-ord-int64 = 0 THEN do:
      undo _main, return error v-last-error-message .
    end.
    v-edist-mess = ''.
    v-edist-mess = cr-edist_add-edist-mess( v-edist-mess, {&edist_route}, string(v-dump-ord-int64)).
    v-date-status = ?.
    run create-edi-state in this-procedure (
                                            input {&table_ord-doc-rcv}                /* p-tbl-name */
                                          , input v-rcv-code                          /* p-doc-code */
                                          , input buf_ord-doc.cli-type                /* p-cli-type */
                                          , input buf_ord-doc.cli-code                /* p-cli-code */
                                          , input {&update}                           /* p-act      */
                                          , input buf_ord-doc.ord-int1                   /* p-state    */
                                          , input integer({&severity-no-error})        /* p-err      */
                                          , input buf_ord-doc.PS                      /* p-des      */
                                          , input v-edist-mess                         /* p-mess     */
                                          , input integer({&doc-dm-edi})
                                          , input-output v-date-status
                                          , input-output v-time-status
                                          ).


    /* ------------------------- &end-rule& -------------------------------------*/

    /* ------------------------- &start-release-obj& -----------------------------------*/


    /* ------------------------- &end-release-obj& -------------------------------------*/
    &scop release_1 clear-data ( )
    ExpData1:Route-data_{&release_1} .
  end. /*else if retry*/
  
end. /*doe _main*/
end procedure. /* proc-main */



/*не удалять!!!!*/