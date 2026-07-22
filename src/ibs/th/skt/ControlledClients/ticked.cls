/*

$Revision: 51d0b788d6e0, 3546, rls $
$Author: DRuban $
$Date: 2023/11/27 08:31:17 $
$Workfile: Ticked.cls $
$Archive: ibs/th/skt/ControlledClients/Ticked.cls $



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/

using Progress.Lang.*.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.


class ibs.th.skt.ControlledClients.Ticked: 

  { cmp/str-glbl.i class}
  { str/defc-gds.i }

  define public property SomeStr as char no-undo
    get.
    set.

  define temp-table in-ItemHowMany no-undo
    field ItemCode   as char
    field IHMObject  as char
    field IHMObjCode as integer
    field IHMFact    as decimal
    field IHMFree    as decimal
    index idx-code ItemCode
    .
  define temp-table Out-ItemHowMany no-undo
    field ItemCode   as char
    field IHMObject  as char
    field IHMObjCode as integer
    field IHMFact    as decimal
    field IHMFree    as decimal
    index idx-code ItemCode
    .
  define variable hDoc-out    as handle no-undo.
  define variable hDoc          as handle  no-undo.
  define variable hRow-out      as handle  no-undo.
  define variable hRow          as handle  no-undo.
  define variable hRoot         as handle  no-undo.
  define variable hRoot-out     as handle  no-undo.
  define variable hText-out     as handle  no-undo.
  define variable req-type      as char    no-undo.
  define variable req-id        as int     no-undo.
  define variable req-from      as char    no-undo.
  define variable req-to        as char    no-undo.
  define variable req-tstamp    as int     no-undo.
  define variable i             as int     no-undo.
  define variable req-encod     as char    init 'koi8-r' no-undo.
  define variable logWrite      as class   LogWrite no-undo.
  define variable mbuffer-out   as memptr  no-undo.
  define variable v-cont-length as integer no-undo.
  
&scop CRLF chr(13) + chr(10)
&scop HdEnd chr(13) + chr(10) + chr(13) + chr(10)


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
		
  constructor Ticked (  ):
		

    create x-noderef hRow-out.
    create x-noderef hText-out.
		

		
  end constructor.


  method private character get-error (p-str as char, p-code as int, p-severity as int, p-hparentout as handle ):



    hDoc-Out:create-node(hRow-out,'Error','ELEMENT':U).
    p-hParentOut:append-child(hRow-out).
    hDoc-Out:create-node(hText-out,'','TEXT':U).
    hRow-out:append-child(hText-out).
    hText-out:node-value = string(p-code).

    hDoc-Out:create-node(hRow-out,'ErrorMessage','ELEMENT':U).
    p-hParentOut:append-child(hRow-out).
    hDoc-Out:create-node(hText-out,'','TEXT':U).
    hRow-out:append-child(hText-out).
    hText-out:node-value = p-str.

    hDoc-Out:create-node(hRow-out,'ErrorSeverity','ELEMENT':U).
    p-hParentOut:append-child(hRow-out).
    hDoc-Out:create-node(hText-out,'','TEXT':U).
    hRow-out:append-child(hText-out).
    hText-out:node-value = string(p-severity).

    return "ERROR: " + p-str.

  end method.


  method public void ParsHowMany (p-hNode as handle, p-ctrl as char, p-code  as char, p-hParentOut as handle):
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:       Остаток товара
    ------------------------------------------------------------------------------*/
  
    define variable hField     as handle no-undo.
    define variable hBuf       as handle no-undo.
    define variable hDBFld     as handle no-undo.
    define variable hText      as handle no-undo.
    define variable hBuf-out   as handle no-undo.
    define variable hDBFld-out as handle no-undo.
    define variable hField-out as handle no-undo.
    define variable hText-out  as handle no-undo.
    /*DEFINE VARIABLE hRow-out  AS HANDLE NO-UNDO.   */
  
    def    var      v-ctrl     as char   no-undo.
    def    var      v-code     as char   no-undo.
    def    var      i          as int    no-undo.
    def    var      j          as int    no-undo.
    hBuf     = buffer in-ItemHowMany:handle.
    hBuf-out = buffer out-ItemHowMany:handle.
  
    v-ctrl = p-hNode:get-attribute("ctrl":U).
    if v-ctrl > ''  then. /* если действие не указано в конкретном тэге, используем ctrl родителя */
    else v-ctrl = p-ctrl.
    v-code = p-hNode:get-attribute("code":U).
    if v-code > '' then.
    else v-code = p-code.
  
    create in-ItemHowMany.
    assign 
      in-ItemHowMany.ItemCode = v-code.
  
    create x-noderef  hField.
    create x-noderef  hText.
    create x-noderef  hField-out.
    create x-noderef  hText-out.
    create x-noderef  hRow-out.
  
  
    do i = 1 to p-hNode:num-children:
      p-hNode:get-child(hField,i).
      if hField:name = '#text' then next.
      hDBFld = hBuf:buffer-field(hField:name) no-error.
      if valid-handle(hDBFld) then 
      do:
        hField:get-child(hText,1).
        hDbFld:buffer-value = hText:node-value.
      end.
    end.
  
  
    if v-ctrl = 'read' then 
    do:
      empty temp-table out-ItemHowMany.
      empty temp-table cash-gds.
      /*     FOR EACH in-ItemHowMany NO-LOCK WHERE in-ItemHowMany.ItemCode = v-code: */
      if in-ItemHowMany.ItemCode = '*' then 
      do: /*По всем товарам*/
        create out-ItemHowMany.
        assign 
          out-ItemHowMany.ItemCode   = '105107'
          out-ItemHowMany.IHMObject  = 'маг'
          out-ItemHowMany.IHMObjCode = 20
          out-ItemHowMany.IHMFact    = 10
          out-ItemHowMany.IHMFree    = 10.
        create out-ItemHowMany.
        assign 
          out-ItemHowMany.ItemCode   = '27'
          out-ItemHowMany.IHMObject  = 'маг'
          out-ItemHowMany.IHMObjCode = 20
          out-ItemHowMany.IHMFact    = 20
          out-ItemHowMany.IHMFree    = 20.
      end.
      else 
      do:
        run str/sendirst.p (input substitute('&1&3&2',in-ItemHowMany.ItemCode,in-ItemHowMany.IHMObjCode,{&delim-par}),
          output table cash-gds) no-error.
        if error-status:error then 
        do:
          hDoc-Out:create-node(hRow-out,'ItemHowMany','ELEMENT').
          p-hParentOut:append-child(hRow-out).
          hRow-out:set-attribute("code",string(in-ItemHowMany.ItemCode)).
          hRow-out:set-attribute("ctrl", "READ":U).
          write-error (return-value
            ,1
            ,2
            ,hRow-out:handle).
          logWrite:LogStr = (return-value).
        end.
      end.
      /*     END. */
      for each cash-gds no-lock
        where cash-gds.fact-qnty <> 0 and cash-gds.free-qnty <> 0 :
        hDoc-Out:create-node(hRow-out,'ItemHowMany','ELEMENT').
        p-hParentOut:append-child(hRow-out).
        hRow-out:set-attribute("code",string(cash-gds.b-code)).
        hRow-out:set-attribute("ctrl", "ADD":U).
        out-tag-put (hRow-out:handle, hField-out:handle, hText-out:handle, 'IHMObject' , cash-gds.obj-type ).
        out-tag-put (hRow-out:handle, hField-out:handle, hText-out:handle, 'IHMObjCode' , string(cash-gds.obj-code) ).
        out-tag-put (hRow-out:handle, hField-out:handle, hText-out:handle, 'IHMFact' , string(cash-gds.fact-qnty) ).
        out-tag-put (hRow-out:handle, hField-out:handle, hText-out:handle, 'IHMFree' , string(cash-gds.free-qnty) ).
      end.
  
    /*    FOR EACH out-ItemHowMany:
            hDoc-Out:CREATE-NODE(hRow-out,'ItemHowMany','ELEMENT').
            p-hParentOut:APPEND-CHILD(hRow-out).
            hRow-out:SET-ATTRIBUTE("code",out-ItemHowMany.ItemCode).
            hRow-out:SET-ATTRIBUTE("ctrl", "ADD":U).
            REPEAT j = 1 TO hBuf-out:NUM-FIELDS:
                hDBFld-out = hBuf-out:BUFFER-FIELD(j).
                IF hDBFld-out:NAME = 'ItemCode':U THEN NEXT.
                hDoc-Out:CREATE-NODE(hField-out,hDBFld-out:NAME,'ELEMENT').
                hRow-out:APPEND-CHILD(hField-out).
                hDoc-Out:CREATE-NODE(hText-out,"",'TEXT').
                hField-out:APPEND-CHILD(hText-out).
                hText-out:NODE-VALUE = STRING(hDBFld-out:BUFFER-VALUE).
            END.
        END. */
  
    end.
  
    delete object hField.
    delete object hText.
    delete object hField-out.
    delete object hText-out.
  /*DELETE OBJECT hRow-out.   */
  
  end method.


  method public void ParsPayMeans (p-hNode as handle, p-hParentOut as handle):
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/


    define variable hRow-out      as handle  no-undo.
    define variable hField-out    as handle  no-undo.
    define variable hText-out     as handle  no-undo.
    /*DEFINE VARIABLE hBuf   AS HANDLE NO-UNDO.
    DEFINE VARIABLE hDBFld AS HANDLE NO-UNDO. */

    define variable hRowField-out as handle  no-undo.
    define variable v-ser-code    as integer no-undo.
    define variable v-db-num      as integer no-undo.
    define variable v-stts        as integer no-undo.
    define variable v-wth-code    as integer no-undo.
    define variable v-gds-code    as integer no-undo.
    define variable v-par-code    as integer no-undo.
    define variable v-FromDate    as date    no-undo.
    define variable v-ToDate      as date    no-undo.
    define variable v-zone        as char    no-undo.
    define variable v-rangeNum    as integer no-undo.
    define variable v-prod-bc     as char    no-undo.
    define buffer buf_wth-par  for ub.wth-par.
    define buffer buf_wth-ser  for ub.wth-ser.
    define buffer buf_wealth   for ub.wealth.
    define buffer buf_cash-pay for ub.cash-pay.


    def var v-ctrl as char no-undo.
    def var v-code as char no-undo.
    def var i      as int  no-undo.
    def var j      as int  no-undo.

    v-ctrl = p-hNode:get-attribute("ctrl":U).
    v-code = p-hNode:get-attribute("code":U).

    create x-noderef  hField-out.
    create x-noderef  hRow-out.
    create x-noderef  hRowField-out.
    create x-noderef  hText-out.

    if v-ctrl = 'read' then 
    ReadBlock: do:
      hDoc-Out:create-node(hRow-out,'PayMeans','ELEMENT').
      p-hParentOut:append-child(hRow-out).
      hRow-out:set-attribute("code",v-code).
      hRow-out:set-attribute("ctrl", "READ":U).

      run str/wthidnt.p ( input v-code /*"КОД ТАЛОНА"*/
        ,output v-ser-code
        ,output v-db-num
        ,output v-stts
        ,output v-wth-code
        ,output v-gds-code
        ,output v-par-code
        ,output v-zone
        ,output v-FromDate
        ,output v-ToDate
        ,output v-rangeNum
        ) no-error.
      if error-status:error then 
      do:
        write-error (return-value
          ,1
          ,2
          ,hRow-out:handle).
        return .
      end.
      logWrite:LogStr = (substitute('Идентифицирована маска: серия &1-&2, МЦ &3, зона &4, номер &5!',v-ser-code,v-db-num,v-wth-code,v-zone, v-rangeNum)).

      /*Находим буфферы для заполнения всей информ. по талону. При этом пользователю эти ошибки возвращаются как ошибки
      идентификации.  Более подробно ошибки вывводятся в лог.*/
      find first buf_wth-ser no-lock where
        buf_wth-ser.ser-code = v-ser-code
        and buf_wth-ser.db-num = v-db-num no-error.
      if not available buf_wth-ser then 
      do:
        write-error('Ошибка идентификации талона.'
          ,2
          ,2
          ,hRow-out:handle).
        logWrite:LogStr = (substitute('ERROR: Не найдена маска с кодом &1-&2!',v-ser-code,v-db-num)).
        leave ReadBlock.
      end.
      find first buf_wealth no-lock where
        buf_wealth.wth-code = v-wth-code no-error.
      if not available buf_wealth then 
      do:
        write-error ('Ошибка идентификации талона.'
          ,2
          ,2
          ,hRow-out:handle).
        logWrite:LogStr = (substitute('ERROR: Не найдена МЦ с кодом &1!',v-wth-code)).
        leave ReadBlock.
      end.
      find first buf_wth-par no-lock where
        buf_wth-par.par-code = v-par-code no-error.
      if not available buf_wth-par then 
      do:
        write-error ('Ошибка идентификации талона.'
          ,2
          ,2
          ,hRow-out:handle).
        logWrite:LogStr = (substitute('ERROR: Не найден номинал с кодом &1!',v-par-code)).
        leave ReadBlock.
      end.

      find first buf_cash-pay no-lock where
        buf_cash-pay.wth-code = v-wth-code no-error.
      if not available buf_cash-pay then 
      do:
        write-error ('Ошибка идентификации талона.'
          ,2
          ,2
          ,hRow-out:handle).
        logWrite:LogStr = (substitute('ERROR: Не найден тип платежа с кодом МЦ &1!',v-wth-code)).
        leave ReadBlock.
      end.
      v-prod-bc = pet-code(v-gds-code).
      if v-prod-bc > '' then.
      else 
      do:
        write-error ('Ошибка идентификации талона.'
          ,2
          ,2
          ,hRow-out:handle).
        logWrite:LogStr = (substitute('ERROR: Не определен короткий код для кода товара  &1!',v-gds-code)).
        leave ReadBlock.
      end.
      if v-zone <> {&cli-zone} then 
      do:
        if v-zone = {&put-zone} then write-error(substitute('Талон с номером &1 уже погашен.',v-code)
            ,4
            ,2
            ,hRow-out:handle).
        else write-error (substitute('Нет информации о наличии у клиента талона с номером &1.',v-code)
            ,5
            ,2
            ,hRow-out:handle).
        leave ReadBlock.
      end.
      /*    IF v-ToDate <> ? AND TODAY < v-ToDate THEN DO:
              RUN write-error (substitute('Истек срок действия талона (&1).',v-Todate)
                              ,3
                              ,1
                     ,hRow-out:HANDLE).
              LEAVE ReadBlock.
          END.
          IF v-FromDate <> ? AND TODAY > v-FromDate THEN DO:
              RUN write-error (substitute('Cрок действия талона (&1) еще не наступил.',v-FromDate)
                              ,3
                              ,1
                     ,hRow-out:HANDLE).
              LEAVE ReadBlock.
          END.    */
      hRow-out:set-attribute("ctrl", "ADD":U).
      out-tag-put (hRow-out:handle, hField-out:handle, hText-out:handle, 'PMName' , buf_wealth.wth-name ).
      out-tag-put (hRow-out:handle, hField-out:handle, hText-out:handle, 'PMProperty' , string(buf_wth-ser.authr) ).
      out-tag-put (hRow-out:handle, hRowField-out:handle, hText-out:handle, 'PMMark' , '':U ).
      out-tag-put (hRowField-out:handle, hField-out:handle, hText-out:handle, 'PMMCode' , v-prod-bc ).
      out-tag-put (hRow-out:handle, hField-out:handle, hText-out:handle, 'PMCoupType' , '0' ).
      out-tag-put (hRow-out:handle, hField-out:handle, hText-out:handle, 'PMValue' , string(buf_wth-par.par-val) ).
      out-tag-put (hRow-out:handle, hField-out:handle, hText-out:handle, 'PMPayCode' , string(buf_cash-pay.cdpay-code) ).
      out-tag-put (hRow-out:handle, hField-out:handle, hText-out:handle, 'PMDateSrartYY' , substring(string(year(v-fromDate)),3,2)).
      out-tag-put (hRow-out:handle, hField-out:handle, hText-out:handle, 'PMDateStartMM' , string(month(v-fromDate)) ).
      out-tag-put (hRow-out:handle, hField-out:handle, hText-out:handle, 'PMDateStartDD' , string(day(v-fromDate)) ).
      out-tag-put (hRow-out:handle, hField-out:handle, hText-out:handle, 'PMDateEndYY' , substring(string(year(v-ToDate)),3,2) ).
      out-tag-put (hRow-out:handle, hField-out:handle, hText-out:handle, 'PMDateEndMM' , string(month(v-ToDate)) ).
      out-tag-put (hRow-out:handle, hField-out:handle, hText-out:handle, 'PMDateEndDD' , string(day(v-ToDate)) ).
      out-tag-put (hRow-out:handle, hField-out:handle, hText-out:handle, 'PMLock' , string(if buf_wth-ser.stts = 0 then 0 else 1) ).
    /*     hDoc-Out:CREATE-NODE(hField-out,'PMMark','Element'). */
    /*     hRow-out:APPEND-CHILD(hField-out).                   */
    end.

    delete object  hField-out.
    delete object  hRow-out.
    delete object  hRowField-out.
    delete object  hText-out.

  end method.


  method private void out-tag-put (p-hrow as handle, p-hfield as handle, p-htext  as handle, p-name as char, p-value as char):
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/


    hDoc-Out:create-node(p-hField,p-name,'Element').
    p-hRow:append-child(p-hField).
    if p-value > '' then 
    do:
      hDoc-Out:create-node(p-hText,'','TEXT':U).
      p-hField:append-child(p-hText).
      p-hText:node-value = p-value.
    end.

  end method.

  method private character pet-code 
    ( input p-gds-code as integer ) :
    define variable main-b-code      like ub.bar-code.b-code no-undo.
    define variable l-is-petrol-code as logical no-undo.
    define buffer buf_prod-bc for ub.prod-bc.
    if p-gds-code = 0 then return "":U.

    run ibs/th/skt/Adapters/AdapteeProcGdsbcode.p
      (input p-gds-code, input ?, output main-b-code) 
    no-error.
    if error-status:error then return "":U.
    for each buf_prod-bc no-lock where
      buf_prod-bc.b-code = main-b-code:
      run ibs/th/skt/Adapters/AdapteeProcProdbcat.p
        (buffer buf_prod-bc, output l-is-petrol-code) 
      no-error.
      if l-is-petrol-code then return buf_prod-bc.b-str.
    end.

    return "".

  end method.

  method public void xml-router ( p-hNode as handle, p-ctrl as char, p-code as char, p-hParentOut as handle ):
    /*------------------------------------------------------------------------------
      Purpose:
      Parameters:  <none>
      Notes:
    ------------------------------------------------------------------------------*/


    case p-hNode:name:
      when 'Item' then 
        do:

        end.
      when 'PayMeans' then 
        do:
          ParsPayMeans(p-hNode,
            p-hParentOut) no-error.
        end.
      when 'ItemHowMany' then 
        do:
          ParsHowMany (p-hNode
            ,p-ctrl
            ,p-code
            ,p-hParentOut
            ) no-error.
        end.
    end case.
    if error-status:error then 
    do:
      logWrite:LogStr = (return-value).
    end.

  end method.
  
  method private void write-error 
    (p-str  as char, p-code   as int, p-severity   as int, p-hParentOut as handle):
  /*------------------------------------------------------------------------------
    Purpose:
    Parameters:  <none>
    Notes:
  ------------------------------------------------------------------------------*/
  
    define variable hRow-out  as handle no-undo.
    define variable hText-out  as handle no-undo.
    create x-noderef hRow-out.
    create x-noderef hText-out.
    
    hDoc-Out:create-node(hRow-out,'Error','ELEMENT':U).
    p-hParentOut:append-child(hRow-out).
    hDoc-Out:create-node(hText-out,'','TEXT':U).
    hRow-out:append-child(hText-out).
    hText-out:node-value = string(p-code).
    
    hDoc-Out:create-node(hRow-out,'ErrorMessage','ELEMENT':U).
    p-hParentOut:append-child(hRow-out).
    hDoc-Out:create-node(hText-out,'','TEXT':U).
    hRow-out:append-child(hText-out).
    hText-out:node-value = p-str.
    
    hDoc-Out:create-node(hRow-out,'ErrorSeverity','ELEMENT':U).
    p-hParentOut:append-child(hRow-out).
    hDoc-Out:create-node(hText-out,'','TEXT':U).
    hRow-out:append-child(hText-out).
    hText-out:node-value = string(p-severity).
    
    logWrite:LogStr = ("ERROR: " + p-str).
  
  end method.

  method public character AuthorizationTicked (req as class ibs.th.skt.Commands.IRequest):
    
    define variable str as character no-undo.
    
    
    logWrite = new LogWrite().
    
    create x-document hdoc.
    create x-noderef  hroot.
    create x-noderef  hrow.


    hDoc:load("longchar",cast(req, ibs.th.skt.Commands.SimpleRequest):Content,no).

    hdoc:get-document-element(hRoot).

    req-type   = hroot:get-attribute("type").
    req-id     = int(hroot:get-attribute("id")).
    req-from   = hroot:get-attribute("from").
    req-to     = hroot:get-attribute("to").
    req-tstamp = int(hroot:get-attribute("tstamp")).
    req-encod  = hdoc:encoding.

    /* Общий тэг xml-ответа */
    create x-document hdoc-out.
    create x-noderef hroot-out.

    hdoc-out:encoding = req-encod.
    hdoc-out:create-node(hroot-out,'data','element').
    hdoc-out:append-child(hroot-out).
    if req-id <> 0 and req-id <> ? then   hroot-out:set-attribute('id',string(req-id)).
    if req-to > '':U then                 hroot-out:set-attribute('from',req-to).
    if req-from > '':U then               hroot-out:set-attribute('to',req-from).
    if req-tstamp <> 0 and req-tstamp <> ? then hroot-out:set-attribute('tstamp',string(req-tstamp)).
    hroot-out:set-attribute('type','replay').

    do i = 1 to hRoot:num-children:
      hRoot:get-child(hRow,i).
      xml-router(hRow:handle
        ,'':U
        ,'':U
        ,hRoot-out:handle ) no-error.
    end. /* i */

    set-size(mbuffer-out) = 0.
    /*SET-SIZE(mbuffer-out) = 2000.  */
    hdoc-out:save('memptr',mbuffer-out).

    str = get-string(mbuffer-out,1).
    /*RUN write-to-log(s).*/
    v-cont-length = length(str,"RAW":U).

    delete object hdoc.
    delete object hroot.
    delete object hrow.
    delete object hdoc-out.
    delete object hroot-out.

    SomeStr = substitute("HTTP/1.0 200 OK&1Server: 4GL&1Content-Type: text/xml&1Content-Length: &3&2&4",{&CRLF},{&HdEnd},string(v-cont-length),get-string(mbuffer-out,1)).
    
  end method.

end class.

