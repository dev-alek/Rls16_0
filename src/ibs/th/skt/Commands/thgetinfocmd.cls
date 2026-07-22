/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$



Автор: Морозов Александр Сергеевич
Дата создания: 01/30/15
Author: Alexandr Morozov
Creation date: 01/30/15

*/

using ibs.th.skt.*.
using ibs.th.skt.Commands.*.
using ibs.th.skt.ControlledClients.*.
using ibs.th.skt.Adapters.*.
block-level on error undo, throw.

class ibs.th.skt.Commands.THGetInfoCmd inherits ICommand: 
/*  { gbl/cls-sh-val-hdl.i }*/
  { cmp/str-glbl.i class } 

  /* --- для cmp/vssrevis.i --- */
    define override property vss-revision       as character no-undo init "$Revision$":U get.
    define override property  vss-author         as character no-undo init "$Author$":U get.
    define override property  vss-date           as character no-undo init "$Date$":U get.
    define override property  vss-workfile       as character no-undo init "$Workfile$":U get.
    define override property  vss-archive        as character no-undo init "$Archive$":U get.
    define override property  vss-description    as character no-undo init "Экранные триггеры промо-акций" get. 
  /* --- end_of для cmp/vssrevis.i --- */
  
  define public property ErrStatus as logical no-undo 
    get.
    private set.

  define public property LogMsg as character no-undo 
    get.
    private set.
    
  define public property SomeData as memptr no-undo 
    get.
    private set.
    
  define public property SomeStr as longchar no-undo
    get.
    private set.
    
  define temp-table tt-gds-prod
    field gds-code as integer
    field b-str as character
    field bc-on-type as character
    index pi as primary unique
      gds-code b-str
  .
  
  define temp-table tt-place-loc
    field pl-code as integer
    field loc1 as character
    index pi as primary unique
      pl-code
  .
  
  define temp-table tt-gds-price
    field gds-code as integer
    field price as decimal
    index pi as primary unique
      gds-code
  .

  define temp-table tt-version
    field version-name as character
  .

/* выгружаемая таблица скопирована из utl/exp-doc4.p */
define temp-table tt-rest no-undo
  field artic         like ub.parts.artic
  field part-code     as character
  field in-code       as character
  field gds-code      like ub.gds-obj.gds-code
  field prc_rubl      as decimal
  field sum_rubl      as decimal
  field fact-qnty     as decimal
  field vat-tax-value as decimal
  field name-gtd      as character
  field srok-god      as character
  field supp-code     as integer
  field supp-type     like ub.parts.supp-type
  field contract-code as integer
  index pi is primary in-code
  index i-supp supp-code contract-code
  index i-gds gds-code
.

define temp-table tt-rest-prtl no-undo
  field artic         like ub.parts.artic
  field part-code     as character
  field in-code       as character
  field gds-code      like ub.gds-obj.gds-code
  field prc_rubl      as decimal
  field sum_rubl      as decimal
  field fact-qnty     as decimal
  field vat-tax-value as decimal
  field name-gtd      as character
  field srok-god      as character
  field supp-code     as integer
  field supp-type     like ub.parts.supp-type
  field contract-code as integer
  field pl-loc1       as character
  field cli-qnty      as decimal
  index pi is primary in-code
  index i-supp supp-code contract-code
  index i-gds gds-code
.

define temp-table tt-imp-parts no-undo
  /* 01 */ field artic         as character
  /* 03 */ field part-code     as character
  /* 04 */ field in-code       like ub.parts.in-code
  /* 05 */ field gds-code      as integer
  /* 06 */ field price-rubl    like ub.parts.price-rubl
  /* 07 */ field fact-qnty     like ub.parts.fact-qnty
  /* 11 */ field vat-tax-value as decimal
  /* 14 */ field name-gtd      as character
  /* 17 */ field srok-god      as character
  /* 20 */ field supp-code     as integer
  /* 21 */ field supp-type     as character
  /* 22 */ field cont-prn-code like ub.contract.contract-prn-code
.

define temp-table tt-imp-parts-ptrl no-undo
  /* 01 */ field artic         as character
  /* 03 */ field part-code     as character
  /* 04 */ field in-code       like ub.parts.in-code
  /* 05 */ field gds-code      as integer
  /* 06 */ field price-rubl    like ub.parts.price-rubl
  /* 07 */ field fact-qnty     like ub.parts.fact-qnty
  /* 11 */ field vat-tax-value as decimal
  /* 14 */ field name-gtd      as character
  /* 17 */ field srok-god      as character
  /* 20 */ field supp-code     as integer
  /* 21 */ field supp-type     as character
  /* 22 */ field cont-prn-code like ub.contract.contract-prn-code
           field pl-loc1       as character
           field cli-qnty      as decimal
.
    define temp-table tt-user-login like ub.user-login .
    define temp-table tt-user-host  like ub.user-host .
    define temp-table tt-user-obj   like ub.user-obj .
    define temp-table tt-user-menu-group  like ub.user-menu-group .
    define temp-table tt-user-account  like ub.user-account .

define temp-table tt-cash-passwd
  field staff-code as integer   /* like staff.staff-code */
  field password   as character /* like staff.password */
.

define temp-table tt-rest-fin
  field obj-code as integer
  field obj-type as character
  field CashBookId like ub.CashBook.id
  field ostatok as decimal
  index pi is primary obj-code obj-type CashBookId
  .
  
  define private variable i           as integer   no-undo.
  define private variable userId_     as character no-undo.
  define private variable sn          as character no-undo.
  define private variable hndlSocket  as handle    no-undo.
  define private variable good        AS LOGICAL   NO-UNDO.
  define private variable line-num    as integer no-undo .
  define private variable v-type      as character no-undo .
  define private variable expJsonQry  as handle    no-undo.
  
  
  define private variable v-curr-obj-type as character no-undo .
  define private variable v-curr-obj-code as integer no-undo .
  
  constructor public THGetInfoCmd ():
    
    v-curr-obj-type = 'маг' .
    find first ub.clients no-lock where ub.clients.obj-type = v-curr-obj-type
                                    and ub.clients.stts = 0
                                    and ub.clients.db-num = ibs.th.gbl.gbl-var:g#db-num
                                    no-error.
    if available ub.clients
    then do :
    v-curr-obj-code = ub.clients.obj-code . 
    end.
    create query expJsonQry .
                 
  end constructor.
  destructor public THGetInfoCmd ( ):
    if valid-handle(expJsonQry) then delete object expJsonQry no-error .
  end destructor.



  method public override void Execute_( input req as IRequest, resp as class IResponse ):
  
  do transaction:

    &scop CRLF chr(13) + chr(10)
    &scop HdEnd chr(13) + chr(10) + chr(13) + chr(10)
    
/*    define variable resp       as class     IResponse no-undo.*/
    define variable contLength as integer   no-undo.
    define variable strLog     as character no-undo.
    define variable str        as character no-undo.
    define variable reqtype    as character no-undo.
    define variable ANS as logical .
    
    reqtype = req:QueryPar.
    SomeStr = "" .
    
    case reqtype :
      when "GetVersion"  then GetVersion().
      when "GetCashDesk" then GetCashDesk() .
      when "GetSchem"    then GetSchem() .
      when "GetPumpDoc"  then GetPumpDoc() .
      when "GetPrice"    then GetPrice() .
      when "GetRest"     then GetRest() .
      when "VerifyRest"  then VerifyRest() .
      when "GetRvs"      then GetRvs() .
      when "GetRestPtrl" then GetRestPtrl() .
      when "GetUser"     then GetUser() . 
      when "GetCashp"    then GetCashPasswd () .
      when "GetFbrGds"   then GetFbrGds () .
      when "GetRestFin"  then GetRestFin() .
      otherwise do :
        
      end.
    end case.
      
    SomeStr = SomeStr + {&CRLF} .
    output to 123.txt.
    export SomeStr.
    
    hndlsocket = cast(req, ibs.th.skt.Commands.SimpleRequest):HndlSocket.
    SomeStr = substring(SomeStr, 3) .
    if ErrStatus then 
    do:
      writeSock("").
/*      if ErrStatus = true then undo.*/
    end.
    else do:
      writeSock(str).
/*      if ErrStatus = true then undo.*/
    end.
    
  end /*trans*/.
    
/*  return resp.*/
    
  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  define temp-table tt-rvs-line like rvs-line
    field loc1 as character 
  .
    define temp-table tt-rvs-line-attr like rvs-line-attr
        field loc1 as character 
        .
  define temp-table tt-rvs-line-pump like rvs-line-pump
    field loc1 as character 
  .
  define temp-table tt-rvs-line-pump-attr like rvs-line-pump-attr
    field loc1 as character 
  .    
  method private void GetRvs () :
    define variable v-str as longchar no-undo .
    define variable v-where-phrase as character no-undo .
    define buffer buf_rvs-doc            for ub.rvs-doc .
    define buffer buf_rvs-doc-exp        for ub.rvs-doc .
    define buffer buf_rvs-doc-attr       for ub.rvs-doc-attr .
    define buffer buf_rvs-line           for ub.rvs-line.
    define buffer buf_rvs-line-attr      for ub.rvs-line-attr.
    define buffer buf_rvs-pump           for ub.rvs-pump.
    define buffer buf_rvs-pump-attr      for ub.rvs-pump-attr.
    define buffer buf_rvs-line-pump      for ub.rvs-line-pump.
    define buffer buf_rvs-line-pump-attr for ub.rvs-line-pump-attr.
    define buffer place                  for place.
    
    block-rvs:
        for each buf_rvs-doc where buf_rvs-doc.obj-type  = v-curr-obj-type
                               and buf_rvs-doc.obj-code  = v-curr-obj-code
                               and buf_rvs-doc.status_   = {&fact}   
                               no-lock
                by buf_rvs-doc.obj-type desc
                by buf_rvs-doc.obj-code desc
                by buf_rvs-doc.status_    desc
                by buf_rvs-doc.fact-order desc
        :
           if buf_rvs-doc.rvs-type eq {&rvs-shift}
           then 
              leave block-rvs.         
        end.        
        if available  buf_rvs-doc
        then do:      
            v-where-phrase = substitute("FOR each buf_rvs-doc-exp no-lock where buf_rvs-doc-exp.rvs-code = '&1' ", buf_rvs-doc.rvs-code).
            v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"rvs-doc": ['       + ExpJson(buffer buf_rvs-doc-exp:handle  , v-where-phrase) + {&new-line} + "~],"  .
            
            v-where-phrase = substitute("FOR EACH buf_rvs-doc-attr no-lock where buf_rvs-doc-attr.rvs-code = '&1' ", buf_rvs-doc.rvs-code) .
            v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"rvs-doc-attr": ['  + ExpJson(buffer buf_rvs-doc-attr:handle  , v-where-phrase) + {&new-line} + "~],"  .
            &scop tttable rvs-line
            block-{&tttable}:
            FOR EACH buf_{&tttable} where buf_{&tttable}.rvs-code     = buf_rvs-doc.rvs-code 
            no-lock:
                find first place where place.pl-code eq buf_{&tttable}.pl-code
                                   and place.status_ ne {&deleted-status}
                no-lock no-error.
                if not avail place
                then 
                   next block-{&tttable}.
                create tt-{&tttable}.
                buffer-copy buf_{&tttable} to tt-{&tttable}.
                tt-{&tttable}.loc1 = place.loc1.
            end.
                              
            v-where-phrase = substitute("FOR EACH tt-{&tttable}     no-lock where tt-{&tttable}.rvs-code     = '&1'", buf_rvs-doc.rvs-code) .
            v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"{&tttable}": ['      + ExpJson(buffer tt-{&tttable}:handle      , v-where-phrase) + {&new-line} + "~],"  .
            
            &scop tttable rvs-line-attr
            block-{&tttable}:
            FOR EACH buf_{&tttable} where buf_{&tttable}.rvs-code     = buf_rvs-doc.rvs-code 
                no-lock:
                find first place where place.pl-code eq buf_{&tttable}.pl-code
                    and place.status_ ne {&deleted-status}
                    no-lock no-error.
                if not avail place
                    then 
                    next block-{&tttable}.
                create tt-{&tttable}.
                buffer-copy buf_{&tttable} to tt-{&tttable}.
                tt-{&tttable}.loc1 = place.loc1.
            end.
                              
            v-where-phrase = substitute("FOR EACH tt-{&tttable}     no-lock where tt-{&tttable}.rvs-code     = '&1'", buf_rvs-doc.rvs-code) .
            v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"{&tttable}": ['      + ExpJson(buffer tt-{&tttable}:handle      , v-where-phrase) + {&new-line} + "~],"  .
            
            v-where-phrase = substitute("FOR EACH buf_rvs-pump     no-lock where buf_rvs-pump.rvs-code     = '&1'", buf_rvs-doc.rvs-code) .
            v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"rvs-pump": [' + ExpJson(buffer buf_rvs-pump:handle , v-where-phrase) + {&new-line} + "~],"  .
            
            v-where-phrase = substitute("FOR EACH buf_rvs-pump-attr     no-lock where buf_rvs-pump-attr.rvs-code     = '&1'", buf_rvs-doc.rvs-code) .
            v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"rvs-pump-attr": [' + ExpJson(buffer buf_rvs-pump-attr:handle , v-where-phrase) + {&new-line} + "~],"  .
            
            &scop tttable rvs-line-pump
            block-{&tttable}:
            FOR EACH buf_{&tttable} where buf_{&tttable}.rvs-code     = buf_rvs-doc.rvs-code 
                no-lock:
                find first place where place.pl-code eq buf_{&tttable}.pl-code
                    and place.status_ ne {&deleted-status}
                    no-lock no-error.
                if not avail place
                    then 
                    next block-{&tttable}.
                create tt-{&tttable}.
                buffer-copy buf_{&tttable} to tt-{&tttable}.
                tt-{&tttable}.loc1 = place.loc1.
            end.
            v-where-phrase = substitute("FOR EACH tt-{&tttable}     no-lock where tt-{&tttable}.rvs-code     = '&1'", buf_rvs-doc.rvs-code) .
            v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"{&tttable}": ['      + ExpJson(buffer tt-{&tttable}:handle      , v-where-phrase) + {&new-line} + "~],"  .
                        

            &scop tttable rvs-line-pump-attr
            block-{&tttable}:
            FOR EACH buf_{&tttable} where buf_{&tttable}.rvs-code     = buf_rvs-doc.rvs-code 
                no-lock:
                find first place where place.pl-code eq buf_{&tttable}.pl-code
                    and place.status_ ne {&deleted-status}
                    no-lock no-error.
                if not avail place
                    then 
                    next block-{&tttable}.
                create tt-{&tttable}.
                buffer-copy buf_{&tttable} to tt-{&tttable}.
                tt-{&tttable}.loc1 = place.loc1.
            end.
            v-where-phrase = substitute("FOR EACH tt-{&tttable}     no-lock where tt-{&tttable}.rvs-code     = '&1'", buf_rvs-doc.rvs-code) .
            v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"{&tttable}": ['      + ExpJson(buffer tt-{&tttable}:handle      , v-where-phrase) + {&new-line} + "~]"  .
            
            SomeStr = "~{" + {&new-line} + "~{" + {&new-line} + v-str + {&new-line} + "~}" .
        end.    
    
     
  end method .
  
  method private void GetRestPtrl () :
    
    empty temp-table tt-rest-prtl.
    run utl/exp-doc4crptrl.p
    ( input v-curr-obj-code
    , input v-curr-obj-type
    , input "" /* список поставщиков, чьи партии выгружать */
    , input "" /* имя лог-файла подбора и выгрузки товаров */
    , output table tt-rest-prtl
    ) .
    empty temp-table tt-imp-parts-ptrl .
      
    /* скопировано из utl/exp-doc4.p */  
    define variable v-contn     as character no-undo .
    define buffer buf_tt-rest-prtl   for tt-rest-prtl .
    define buffer buf_contract  for ub.contract .
    
    for each buf_tt-rest-prtl break by buf_tt-rest-prtl.supp-code by buf_tt-rest-prtl.contract-code :
      if first-of (buf_tt-rest-prtl.contract-code) then do :
        if buf_tt-rest-prtl.contract-code > 0 then do :
          find first buf_contract no-lock
               where /* buf_contract.host-code     = buf_clients.host-code
                 and */ buf_contract.contract-code = buf_tt-rest-prtl.contract-code no-error .
          if available buf_contract then do:
               v-contn = buf_contract.contract-prn-code .
          end .
          else v-contn = "0" .
        end .
        else   v-contn = "0" .
      end .
      create tt-imp-parts-ptrl .
      assign
        tt-imp-parts-ptrl.artic         = substitute("PART: &1", buf_tt-rest-prtl.artic)
        tt-imp-parts-ptrl.part-code     = buf_tt-rest-prtl.part-code
        tt-imp-parts-ptrl.in-code       = buf_tt-rest-prtl.in-code
        tt-imp-parts-ptrl.gds-code      = buf_tt-rest-prtl.gds-code
        tt-imp-parts-ptrl.price-rubl    = buf_tt-rest-prtl.prc_rubl
        tt-imp-parts-ptrl.fact-qnty     = buf_tt-rest-prtl.fact-qnty
        tt-imp-parts-ptrl.vat-tax-value = buf_tt-rest-prtl.vat-tax-value
        tt-imp-parts-ptrl.name-gtd      = buf_tt-rest-prtl.name-gtd
        tt-imp-parts-ptrl.srok-god      = buf_tt-rest-prtl.srok-god
        tt-imp-parts-ptrl.supp-code     = buf_tt-rest-prtl.supp-code
        tt-imp-parts-ptrl.supp-type     = buf_tt-rest-prtl.supp-type
        tt-imp-parts-ptrl.cont-prn-code = v-contn
        tt-imp-parts-ptrl.pl-loc1       = buf_tt-rest-prtl.pl-loc1
        tt-imp-parts-ptrl.cli-qnty      = buf_tt-rest-prtl.cli-qnty
      .
    end . /* end_of for_each_tt-rest-prtl */
  
    if can-find (first tt-imp-parts-ptrl) then do :
      define variable v-where-phrase as character no-undo .
      define variable v-str as longchar no-undo .
  
      v-where-phrase = "FOR EACH tt-imp-parts-ptrl" .
      v-str = '"tt-imp-parts-ptrl": [' + ExpJson(temp-table tt-imp-parts-ptrl:default-buffer-handle, v-where-phrase) + {&new-line} + "~]" .
      SomeStr = "~{" + {&new-line} + "~{" + {&new-line} + v-str + {&new-line} + "~}" . 
    end .


  end method .

   /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method private void GetVersion () :
    define variable v-str as longchar no-undo .
    define variable v-where-phrase as character no-undo .

    define buffer buf_version for tt-version .
    create buf_version .
    buf_version.version-name = "15_0" .
    
    v-where-phrase = "FOR each tt-version" .
    v-str = '"tt-version": [' + ExpJson(temp-table tt-version:default-buffer-handle, v-where-phrase) + {&new-line} + "~]" .
      SomeStr = "~{" + {&new-line} + "~{" + {&new-line} + v-str + {&new-line} + "~}" .   end method .
    
   /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method private void GetCashDesk () :
    define variable v-str as longchar no-undo .
    define variable v-where-phrase as character no-undo .
    
    define buffer buf_cash-desk for ub.cash-desk .
    define buffer buf_cash-desk-attr for ub.cash-desk-attr .
    
    v-where-phrase = substitute("FOR EACH buf_cash-desk no-lock where buf_cash-desk.obj-code = &1 and not buf_cash-desk.is-del and buf_cash-desk.pos-type <> 'IBM' and buf_cash-desk.pos-type <> 'R-Keeper'", v-curr-obj-code) .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"cash-desk": [' + ExpJson(buffer buf_cash-desk:handle, v-where-phrase) + {&new-line} + "~],"  .
    
    v-where-phrase = substitute("FOR EACH buf_cash-desk-attr no-lock where buf_cash-desk-attr.obj-code = &1 and buf_cash-desk-attr.pos-type <> 'IBM' and buf_cash-desk-attr.pos-type <> 'R-Keeper'", v-curr-obj-code) .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"cash-desk-attr": [' + ExpJson(buffer buf_cash-desk-attr:handle, v-where-phrase) + {&new-line} + "~]"  .

    SomeStr = "~{" + {&new-line} + "~{" + {&new-line} + v-str + {&new-line} + "~}" . 
  end method .

   /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method private void GetFbrGds () :
    define variable v-str as longchar no-undo .
    define variable v-where-phrase as character no-undo .

    define buffer buf_fbr-gds-obj for ub.fbr-gds-obj .
    
    v-where-phrase = substitute("FOR EACH  buf_fbr-gds-obj no-lock where  buf_fbr-gds-obj.obj-code = &1", v-curr-obj-code) .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"fbr-gds-obj": [' + ExpJson(buffer buf_fbr-gds-obj:handle, v-where-phrase) + {&new-line} + "~]"  .

    SomeStr = "~{" + {&new-line} + "~{" + {&new-line} + v-str + {&new-line} + "~}" .    

  end method .    

   /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method private void GetRestFin () :
    define variable v-str as longchar no-undo .
    define variable v-where-phrase as character no-undo .

    define buffer bf_fin-doc for ub.fin-doc .
    define buffer buf_fin-doc for ub.fin-doc .
    define buffer bf_fin-doc-tax for ub.fin-doc-tax .
    define buffer buf_fin-doc-tax for ub.fin-doc-tax .
    define buffer bf_fin-doc-attr for ub.fin-doc-attr .
    define buffer buf_fin-doc-attr for ub.fin-doc-attr .
    define buffer bf_payment for ub.payment .
    define buffer buf_payment for ub.payment .
    define buffer buf_shift-obj for ub.shift-obj .
	define variable flag_rest as logical no-undo .
    empty temp-table tt-rest-fin .
    find last buf_shift-obj
          where buf_shift-obj.obj-type    = v-curr-obj-type 
            and buf_shift-obj.obj-code    = v-curr-obj-code
      no-error.
    for each ub.cashbook no-lock where ub.cashBook.Status_ = 0:
      find first tt-rest-fin where tt-rest-fin.obj-code = buf_shift-obj.obj-code and
      tt-rest-fin.obj-type = buf_shift-obj.obj-type and
      tt-rest-fin.CashBookId = ub.CashBook.id no-error .
      if not available (tt-rest-fin) then do:
        create tt-rest-fin .
        assign
        tt-rest-fin.obj-code = buf_shift-obj.obj-code
        tt-rest-fin.obj-type = buf_shift-obj.obj-type
        tt-rest-fin.CashBookId = ub.CashBook.id
        .
      end.   
      find last ub.arh-fin-doc-schet-nal-obj no-lock where
        ub.arh-fin-doc-schet-nal-obj.obj-type = buf_shift-obj.obj-type
        and ub.arh-fin-doc-schet-nal-obj.obj-code = buf_shift-obj.obj-code
        and ub.arh-fin-doc-schet-nal-obj.cli-code = buf_shift-obj.host-code
        and ub.arh-fin-doc-schet-nal-obj.cli-type = {&cmp}
        and ub.arh-fin-doc-schet-nal-obj.calc-curr-code = 0
        and ub.arh-fin-doc-schet-nal-obj.cashbookid = ub.CashBook.id
        and ub.arh-fin-doc-schet-nal-obj.curr-code = 0
        and ub.arh-fin-doc-schet-nal-obj.sum-type = "shift-obj" no-error . 
      if available (ub.arh-fin-doc-schet-nal-obj) then tt-rest-fin.ostatok = ub.arh-fin-doc-schet-nal-obj.income - ub.arh-fin-doc-schet-nal-obj.expense .
      
    end.

	for each tt-rest-fin:
	if tt-rest-fin.ostatok <> 0 then flag_rest = true .
	end.
	
	if not flag_rest then do:
	find first tt-rest-fin where tt-rest-fin.obj-code = buf_shift-obj.obj-code and
      tt-rest-fin.obj-type = buf_shift-obj.obj-type and
      tt-rest-fin.CashBookId = 0 no-error .
      if not available (tt-rest-fin) then do:
        create tt-rest-fin .
        assign
        tt-rest-fin.obj-code = buf_shift-obj.obj-code
        tt-rest-fin.obj-type = buf_shift-obj.obj-type
        tt-rest-fin.CashBookId = 0
        .
      end.   

find first ub.pay-type no-lock where ub.pay-type.obj-name begins "наличны" no-error .
if available(ub.pay-type) then do:
	for last wth-line no-lock where wth-line.obj-code = buf_shift-obj.obj-code and
	wth-line.obj-type = buf_shift-obj.obj-type and 
	wth-line.status_ = {&fact} and
	wth-line.shift-date = buf_shift-obj.shift-date and
	wth-line.shift-num = buf_shift-obj.shift-num and
	wth-line.wth-code = ub.pay-type.obj-code:
	tt-rest-fin.ostatok = wth-line.income - wth-line.incass .
	end. 
end.

	end.
	v-where-phrase = substitute("FOR EACH  tt-rest-fin no-lock ") .
        v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"tt-rest-fin": [' + ExpJson(buffer tt-rest-fin:handle, v-where-phrase) + {&new-line} + "~]"  .
     SomeStr = "~{" + {&new-line} + "~{" + {&new-line} + v-str + {&new-line} + "~}" .    

  end method .    
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method private void GetSchem () :
    define variable v-str as longchar no-undo .
    define variable v-where-phrase as character no-undo .
    
    define buffer buf_place for ub.place .
    define buffer buf_place-attr for ub.place-attr .
    define buffer buf_pump for ub.pump .
    define buffer buf_nozzle for ub.nozzle .
    define buffer buf_pl-pump for ub.pl-pump .
    define buffer buf_pump-nozzle for ub.pump-nozzle .
    define buffer buf_pl-pump-nozzle for ub.pl-pump-nozzle .
    define buffer buf_pl-level for ub.pl-level .
    define buffer buf_pl-gds for ub.pl-gds .
    define buffer buf_pl-gds-pump for ub.pl-gds-pump .
    define buffer buf_bar-code for ub.bar-code .
    define buffer buf_prod-bc for ub.prod-bc .

    for each buf_pl-gds no-lock where buf_pl-gds.obj-type = v-curr-obj-type and buf_pl-gds.obj-code = v-curr-obj-code,
    each buf_bar-code no-lock where buf_bar-code.gds-code = buf_pl-gds.gds-code:
    for each buf_prod-bc no-lock where buf_prod-bc.b-code = buf_bar-code.b-code and buf_prod-bc.bc-on:
      find first tt-gds-prod where tt-gds-prod.gds-code = buf_pl-gds.gds-code and tt-gds-prod.b-str = buf_prod-bc.b-str no-error.
      if not available tt-gds-prod
      then do :
        create tt-gds-prod .
        assign
          tt-gds-prod.gds-code = buf_pl-gds.gds-code
          tt-gds-prod.b-str    = buf_prod-bc.b-str
          tt-gds-prod.bc-on-type = buf_prod-bc.bc-on-type
        .
      end.    
    end.
    end.
    v-where-phrase = substitute("FOR EACH buf_place no-lock where buf_place.obj-type = '&1' and buf_place.obj-code = &2", v-curr-obj-type, v-curr-obj-code) .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"place": [' + ExpJson(buffer buf_place:handle, v-where-phrase) + {&new-line} + "~],"  .
    
    v-where-phrase = substitute("FOR EACH buf_place-attr no-lock where buf_place-attr.obj-type = '&1' and buf_place-attr.obj-code = &2 and not buf_place-attr.attr-code begins 'place-SI'", v-curr-obj-type, v-curr-obj-code) .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"place-attr": [' + ExpJson(buffer buf_place-attr:handle, v-where-phrase) + {&new-line} + "~],"  .
    
    v-where-phrase = substitute("FOR EACH buf_pump no-lock where buf_pump.obj-type = '&1' and buf_pump.obj-code = &2", v-curr-obj-type, v-curr-obj-code) .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"pump": [' + ExpJson(buffer buf_pump:handle, v-where-phrase) + {&new-line} + "~]," .
    
    v-where-phrase = substitute("FOR EACH buf_nozzle no-lock where buf_nozzle.obj-type = '&1' and buf_nozzle.obj-code = &2", v-curr-obj-type, v-curr-obj-code) .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"nozzle": [' + ExpJson(buffer buf_nozzle:handle, v-where-phrase) + {&new-line} + "~]," .
    
    v-where-phrase = substitute("FOR EACH buf_pl-pump no-lock where buf_pl-pump.obj-type = '&1' and buf_pl-pump.obj-code = &2", v-curr-obj-type, v-curr-obj-code) .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"pl-pump": [' + ExpJson(buffer buf_pl-pump:handle, v-where-phrase) + {&new-line} + "~]," .
    
    v-where-phrase = substitute("FOR EACH buf_pump-nozzle no-lock where buf_pump-nozzle.obj-type = '&1' and buf_pump-nozzle.obj-code = &2", v-curr-obj-type, v-curr-obj-code) .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"pump-nozzle": [' + ExpJson(buffer buf_pump-nozzle:handle, v-where-phrase) + {&new-line} + "~]," .
    
    v-where-phrase = substitute("FOR EACH buf_pl-pump-nozzle no-lock where buf_pl-pump-nozzle.obj-type = '&1' and buf_pl-pump-nozzle.obj-code = &2", v-curr-obj-type, v-curr-obj-code) .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"pl-pump-nozzle": [' + ExpJson(buffer buf_pl-pump-nozzle:handle, v-where-phrase) + {&new-line} + "~]," .
    
    v-where-phrase = substitute("FOR EACH buf_pl-level no-lock where buf_pl-level.obj-type = '&1' and buf_pl-level.obj-code = &2", v-curr-obj-type, v-curr-obj-code) .
    if can-find(first buf_pl-level no-lock where buf_pl-level.obj-type = v-curr-obj-type and buf_pl-level.obj-code = v-curr-obj-code)
    then
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"pl-level": [' + ExpJson(buffer buf_pl-level:handle, v-where-phrase) + {&new-line} + "~]," .
    
    v-where-phrase = substitute("FOR EACH buf_pl-gds no-lock where buf_pl-gds.obj-type = '&1' and buf_pl-gds.obj-code = &2", v-curr-obj-type, v-curr-obj-code) .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"pl-gds": [' + ExpJson(buffer buf_pl-gds:handle, v-where-phrase) + {&new-line} + "~]," .
    
    v-where-phrase = substitute("FOR EACH buf_pl-gds-pump no-lock where buf_pl-gds-pump.obj-type = '&1' and buf_pl-gds-pump.obj-code = &2", v-curr-obj-type, v-curr-obj-code) .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"pl-gds-pump": [' + ExpJson(buffer buf_pl-gds-pump:handle, v-where-phrase) + {&new-line} + "~]," .
    
    v-where-phrase = "FOR EACH tt-gds-prod" .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"tt-gds-prod": [' + ExpJson(temp-table tt-gds-prod:default-buffer-handle, v-where-phrase) + {&new-line} + "~]" .
    
    SomeStr = "~{" + {&new-line} + "~{" + {&new-line} + v-str + {&new-line} + "~}" . 
  end method .

  
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method private void GetPumpDoc () :
    define variable v-str as longchar no-undo .
    define variable v-where-phrase as character no-undo .
    
    define buffer buf_icnt-doc for ub.icnt-doc .
    define buffer buf_icnt-line for ub.icnt-line .
    define buffer buf_place for ub.place .
    define buffer buf_pl-gds for ub.pl-gds .
    define buffer buf_bar-code for ub.bar-code .
    define buffer buf_prod-bc for ub.prod-bc .
    
    for each buf_pl-gds no-lock where buf_pl-gds.obj-type = v-curr-obj-type and buf_pl-gds.obj-code = v-curr-obj-code,
    each buf_bar-code no-lock where buf_bar-code.gds-code = buf_pl-gds.gds-code,
    each buf_prod-bc no-lock where buf_prod-bc.b-code = buf_bar-code.b-code and buf_prod-bc.bc-on and length(trim(buf_prod-bc.b-str)) < 3 :
      find first tt-gds-prod where tt-gds-prod.gds-code = buf_pl-gds.gds-code no-error.
      if not available tt-gds-prod
      then do :
        create tt-gds-prod .
        assign
          tt-gds-prod.gds-code = buf_pl-gds.gds-code
          tt-gds-prod.b-str    = buf_prod-bc.b-str
          tt-gds-prod.bc-on-type = buf_prod-bc.bc-on-type
        .
      end.    
    end.
    
    for each buf_place no-lock where buf_place.obj-type = v-curr-obj-type and buf_place.obj-code = v-curr-obj-code :
      find first tt-place-loc where tt-place-loc.pl-code = buf_place.pl-code no-error.
      if not available tt-place-loc
      then do :
        create tt-place-loc .
        assign
          tt-place-loc.pl-code = buf_place.pl-code
          tt-place-loc.loc1    = buf_place.loc1
        .
      end. 
    end.
    
    find last icnt-doc no-lock where icnt-doc.obj-type = v-curr-obj-type and icnt-doc.obj-code = v-curr-obj-code and icnt-doc.doc-type = {&icnt-doc} use-index stat-fact no-error.
    if not available icnt-doc
    then do :
      
    end.
    
    v-where-phrase = substitute("FOR each buf_icnt-doc no-lock where buf_icnt-doc.obj-type = '&1' and buf_icnt-doc.obj-code = &2 and buf_icnt-doc.doc-code = '&3'", v-curr-obj-type, v-curr-obj-code, icnt-doc.doc-code) .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"icnt-doc": [' + ExpJson(buffer buf_icnt-doc:handle, v-where-phrase) + {&new-line} + "~],"  .
    
    v-where-phrase = substitute("FOR EACH buf_icnt-line no-lock where buf_icnt-line.obj-type = '&1' and buf_icnt-line.obj-code = &2 and buf_icnt-line.doc-code = '&3'", v-curr-obj-type, v-curr-obj-code, icnt-doc.doc-code) .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"icnt-line": [' + ExpJson(buffer buf_icnt-line:handle, v-where-phrase) + {&new-line} + "~],"  .
    
    v-where-phrase = "FOR EACH tt-gds-prod" .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"tt-gds-prod": [' + ExpJson(temp-table tt-gds-prod:default-buffer-handle, v-where-phrase) + {&new-line} + "~]," .
    
    v-where-phrase = "FOR EACH tt-place-loc" .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"tt-place-loc": [' + ExpJson(temp-table tt-place-loc:default-buffer-handle, v-where-phrase) + {&new-line} + "~]" .
    
    SomeStr = "~{" + {&new-line} + "~{" + {&new-line} + v-str + {&new-line} + "~}" . 
    
  end method .
  
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method private void GetPrice () :
    
    define variable v-str as longchar no-undo .
    define variable v-where-phrase as character no-undo .
    define variable v-price as decimal   no-undo .
    define variable v-cur-dn as character no-undo .
    define variable v-cur-rt as decimal   no-undo .
    define variable v-cur-ex as decimal   no-undo .
        
    define buffer buf_gds-obj   for ub.gds-obj.
    define buffer buf_bar-code  for ub.bar-code.
    define buffer buf_goods     for ub.goods .
    
    empty temp-table tt-gds-price .
    
    for each buf_gds-obj no-lock where
             buf_gds-obj.obj-type = v-curr-obj-type and
             buf_gds-obj.obj-code = v-curr-obj-code 
                 :
          if  buf_gds-obj.fact-qnty = 0 and buf_gds-obj.last-doc <= today - 200 then next.
          
          v-price =   buf_gds-obj.price-sale.  
          if v-price = 0 or v-price = ? then next.
        
        find first tt-gds-price where tt-gds-price.gds-code = buf_gds-obj.gds-code no-error.
        if not available tt-gds-price
        then do :
          create tt-gds-price .
          assign tt-gds-price.gds-code = buf_gds-obj.gds-code .
        end.
        assign tt-gds-price.price = v-price .

          /*
      for each buf_bar-code no-lock where
               buf_bar-code.gds-code = buf_gds-obj.gds-code and
               buf_bar-code.stts_ = 0 :

        run str/last-price.p (
          input buf_gds-obj.obj-type,
          input buf_gds-obj.obj-code,
          input buf_bar-code.b-code,
          output v-cur-dn,
          output v-price,
          output v-cur-rt,
          output v-cur-ex )
        no-error .
       
       
        if error-status :error then next.
        if v-price = 0 or v-price = ? then next.
        
        find first tt-gds-price where tt-gds-price.gds-code = buf_bar-code.gds-code no-error.
        if not available tt-gds-price
        then do :
          create tt-gds-price .
          assign tt-gds-price.gds-code = buf_bar-code.gds-code .
        end.
        assign tt-gds-price.price = v-price .
      end.
      */
    end.
      
    v-where-phrase = "FOR EACH tt-gds-price" .
    v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"tt-gds-price": [' + ExpJson(temp-table tt-gds-price:default-buffer-handle, v-where-phrase) + {&new-line} + "~]" .
    
    SomeStr = "~{" + {&new-line} + "~{" + {&new-line} + v-str + {&new-line} + "~}" . 
    
  end method .
  
    /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  /*Перенос пользователей*/
  method private void GetUser () :
    define variable v-str          as longchar  no-undo .
    define variable v-where-phrase as character no-undo .
    define buffer buf_user-account for ub.user-account .
    define buffer buf_user-login   for ub.user-login .
    define buffer buf_user-host    for ub.user-host .
    define buffer buf_user-obj     for ub.user-obj .
    define buffer buf_user-menu-group   for ub.user-menu-group .

    for each buf_user-login no-lock where buf_user-login.user-administrator <> yes and buf_user-login.db-num = ibs.th.gbl.gbl-var:g#db-num:
    for each buf_user-account no-lock where buf_user-account.status_ = {&bef-user-status-normal} and buf_user-login.user-id = buf_user-account.user-id
      :
        create tt-user-account.
        buffer-copy buf_user-account to tt-user-account .
        
        create tt-user-login .
        buffer-copy buf_user-login to tt-user-login .
        
        for each buf_user-host no-lock where buf_user-host.user-id = buf_user-account.user-id:
          create tt-user-host .
          buffer-copy buf_user-host to tt-user-host .
        end.                       
         
        for each buf_user-obj no-lock where buf_user-obj.user-id = buf_user-account.user-id:
          create tt-user-obj .
          buffer-copy buf_user-obj to tt-user-obj .
        end.                       
         
        for each buf_user-menu-group no-lock where buf_user-menu-group.user-id = buf_user-account.user-id:
          create tt-user-menu-group .
          buffer-copy buf_user-menu-group to tt-user-menu-group .
        end.
      end.
    end.
    
            v-where-phrase = "FOR EACH tt-user-account".
            v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"user-account": ['       + ExpJson(temp-table tt-user-account:default-buffer-handle  , v-where-phrase) + {&new-line} + "~],"  .

            v-where-phrase = "FOR EACH tt-user-login" .
            v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"user-login": ['  + ExpJson(temp-table tt-user-login:default-buffer-handle, v-where-phrase) + {&new-line} + "~],"  .

            v-where-phrase = "FOR EACH tt-user-host" .
            v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"user-host": ['  + ExpJson(temp-table tt-user-host:default-buffer-handle  , v-where-phrase) + {&new-line} + "~],"  .

            v-where-phrase = "FOR EACH tt-user-obj" .
            v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"user-obj": ['  + ExpJson(temp-table tt-user-obj:default-buffer-handle  , v-where-phrase) + {&new-line} + "~],"  .

            v-where-phrase = "FOR EACH tt-user-menu-group" .
            v-str = v-str + (if v-str = "" then "" else {&new-line}) + '"user-menu-group": ['  + ExpJson(temp-table tt-user-menu-group:default-buffer-handle  , v-where-phrase) + {&new-line} + "~]"  .
            
            SomeStr = "~{" + {&new-line} + "~{" + {&new-line} + v-str + {&new-line} + "~}" . 
  end method .
  
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method private void GetRest () :

    empty temp-table tt-rest.
    run utl/exp-doc4cr.p
    ( input v-curr-obj-code
    , input v-curr-obj-type
    , input "" /* список поставщиков, чьи партии выгружать */
    , input "" /* имя лог-файла подбора и выгрузки товаров */
    , output table tt-rest
    ) .
    empty temp-table tt-imp-parts .
      
  /* скопировано из utl/exp-doc4.p */  
  define variable v-contn     as character no-undo .
  define buffer buf_tt-rest   for tt-rest .
  define buffer buf_contract  for ub.contract .
  
  for each buf_tt-rest break by buf_tt-rest.supp-code by buf_tt-rest.contract-code :
    if first-of (buf_tt-rest.contract-code) then do :
      if buf_tt-rest.contract-code > 0 then do :
        find first buf_contract no-lock
             where /* buf_contract.host-code     = buf_clients.host-code
               and */ buf_contract.contract-code = buf_tt-rest.contract-code no-error .
        if available buf_contract then do:
             v-contn = buf_contract.contract-prn-code .
        end .
        else v-contn = "0" .
      end .
      else   v-contn = "0" .
    end .
    create tt-imp-parts .
    assign
      tt-imp-parts.artic         = substitute("PART: &1", buf_tt-rest.artic)
      tt-imp-parts.part-code     = buf_tt-rest.part-code
      tt-imp-parts.in-code       = buf_tt-rest.in-code
      tt-imp-parts.gds-code      = buf_tt-rest.gds-code
      tt-imp-parts.price-rubl    = buf_tt-rest.prc_rubl
      tt-imp-parts.fact-qnty     = buf_tt-rest.fact-qnty
      tt-imp-parts.vat-tax-value = buf_tt-rest.vat-tax-value
      tt-imp-parts.name-gtd      = buf_tt-rest.name-gtd
      tt-imp-parts.srok-god      = buf_tt-rest.srok-god
      tt-imp-parts.supp-code     = buf_tt-rest.supp-code
      tt-imp-parts.supp-type     = buf_tt-rest.supp-type
      tt-imp-parts.cont-prn-code = v-contn
    .
  end . /* end_of for_each_tt-rest */

  if can-find (first tt-imp-parts) then do :
    define variable v-where-phrase as character no-undo .
    define variable v-str as longchar no-undo .

    v-where-phrase = "FOR EACH tt-imp-parts" .
    v-str = '"tt-imp-parts": [' + ExpJson(temp-table tt-imp-parts:default-buffer-handle, v-where-phrase) + {&new-line} + "~]" .
    SomeStr = "~{" + {&new-line} + "~{" + {&new-line} + v-str + {&new-line} + "~}" . 
  end .
    
  end method . /* end_of GetRest() */

  method private void VerifyRest () :
  define variable th-stk-gd as handle no-undo .
  define variable th-stk-fu as handle no-undo .
  define variable tb-stk-gd as handle no-undo .
  define variable tb-stk-fu as handle no-undo .
  define variable v-contn   as character no-undo .
  define variable v-where-phrase as character no-undo .
  define variable v-str-gd       as longchar no-undo .
  define variable v-str-fu       as longchar no-undo .
  define variable v-exp-json     as longchar no-undo .
  define variable v-open-array   as character no-undo .
  define variable v-close-array  as character no-undo .
  
  
    run utl/exp-rest.p
    ( input v-curr-obj-code
    , input v-curr-obj-type
    , output table-handle th-stk-gd
    , output table-handle th-stk-fu
    ) .
    v-close-array = substitute('&1]', {&new-line}) .
      
    /* 29/I-2019 - при слиянии v-exp-json в v-str-gd через substitute падает сессия сокет-сервера.
                   Количество выгружаемых строк при падении - более 7000, объём выходного файла - более 1Мб.
    */ 
    if th-stk-gd:has-records then do :
      tb-stk-gd = th-stk-gd:default-buffer-handle .
      assign
        v-where-phrase = substitute("for each &1", tb-stk-gd:name)
        v-open-array   = substitute('"&1":['     , tb-stk-gd:name)
      .
      v-exp-json = ExpJson(tb-stk-gd, v-where-phrase) .
      v-str-gd   = v-open-array + v-exp-json + v-close-array .
    end .
    else v-str-gd = "" .
    if th-stk-fu:has-records then do :
      tb-stk-fu = th-stk-fu:default-buffer-handle .
      assign
        v-where-phrase = substitute("for each &1", tb-stk-fu:name)
        v-open-array   = substitute('"&1":['     , tb-stk-fu:name)
      .
      v-exp-json = ExpJson(tb-stk-fu, v-where-phrase) .
      v-str-fu   = v-open-array + v-exp-json + v-close-array .
    end .
    else v-str-fu = "" .
    
    SomeStr = "~{" + {&new-line} .
    SomeStr = SomeStr + "~{" + {&new-line} . /* при выгрузке первая скобка куда-то съедается, поэтому её надо дублировать */
    if v-str-gd <> "" then assign
      SomeStr = (SomeStr + v-str-gd) 
      SomeStr = (SomeStr + "," + {&new-line}) when (v-str-fu <> "")
    . 
    if v-str-fu <> "" then assign 
      SomeStr = (SomeStr + v-str-fu)
    .
    SomeStr = SomeStr + {&new-line} + "~}" .
     
  end method . /* end_of VerifyRest() */


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  method private void GetCashPasswd () :
    define buffer buf_staff for ub.staff .
    define variable v-str as longchar no-undo .
    define variable v-where-phrase as character no-undo .

    empty temp-table tt-cash-passwd .
    for each buf_staff no-lock where buf_staff.role = {&role-cashier} :
      create tt-cash-passwd .
      assign
        tt-cash-passwd.staff-code = buf_staff.staff-code
        tt-cash-passwd.password   = buf_staff.password
      .
    end .
    
    if can-find (first tt-cash-passwd) then do :
      v-where-phrase = "FOR EACH tt-cash-passwd" .
      v-str = '"tt-cash-passwd": [' + ExpJson(temp-table tt-cash-passwd:default-buffer-handle, v-where-phrase) + {&new-line} + "~]" .
      SomeStr = "~{" + {&new-line} + "~{" + {&new-line} + v-str + {&new-line} + "~}" . 
    end .

  end method .

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/

  method private longchar ExpJson(input hTab as handle, input where-phrase as character):
    define variable vI    as int64    no-undo.
    define variable vBuff as handle   no-undo.
    define variable vRes  as longchar no-undo.
    define variable v-field-value as character no-undo .
    define variable v-line-start  as character no-undo .
    define variable v-line-next   as character no-undo .
    define variable v-from as character extent 5 initial ['\' , '"' , 'здесь chr 10' , 'здесь chr 13', 'здесь tab' ] no-undo .
    define variable v-to   as character extent 5 initial ['\\', '\"', ''             , ''            , ''          ] no-undo .
    v-from[3]= chr(10).
    v-from[4]= chr(13).
    v-from[5]= {&tabulation}.

    define variable vJ    as int    no-undo.
    define variable v-is-first as logical no-undo .
      
    vRes = "" .
    vBuff = hTab.
    v-line-start = substitute("&1~{&1", {&new-line}) .
    v-line-next  = substitute(",&1",    {&new-line}) .
    v-is-first = true .
    
    expJsonQry:set-buffers(vBuff). 
    expJsonQry:query-prepare(where-phrase).
    expJsonQry:query-open.
  loop:
    repeat:
      expJsonQry:get-next().
      if expJsonQry:query-off-end then leave loop.
    
      if v-is-first then v-is-first = false .
                    else vRes = vRes + "," .
      vRes = vRes + v-line-start .
      do vI = 1 to vBuff:num-fields:
        if vBuff:buffer-field[vI]:buffer-value = ?
        then v-field-value = "" . 
        else do :
          v-field-value = replace( vBuff:buffer-field[vI]:buffer-value, v-from[1], v-to[1] ) .
          do vJ = 2 to extent(v-from) :
            v-field-value = replace( v-field-value, v-from[vJ], v-to[vJ] ) .
          end .
        end .
        vRes = vRes + quoter(vBuff:buffer-field[vI]:name) + ':"' + v-field-value + '"'.
        if vI < vBuff:num-fields then vRes = vRes + v-line-next.
      end.
      vRes = vRes + {&new-line} + "~}".
    end.
    
    expJsonQry:query-close().

    return vRes.
  end method.
  
  method private logical writeSock ( arg as character ):
    
    define variable mbuffer  as memptr   no-undo.
    define variable mbuffer1 as memptr   no-undo.
    define variable tempStr  as longchar no-undo.
    define variable glog     as logical  no-undo.
    set-size(mbuffer1) = 0.
    set-size(mbuffer1) = length (SomeStr, "RAW":U) + 1.
    put-string(mbuffer1,1) = SomeStr.        
    tempStr = substitute("HTTP/1.0 200 OK&1Server: 4GL&1Content-Type: text/csv&1Content-Length: &3&2",chr(13) + chr(10),chr(13) + chr(10) + chr(13) + chr(10),get-size(mbuffer1)).
    set-size(mbuffer) = 0.
    set-size(mbuffer) = length (tempStr, "RAW":U) + 1.
    put-string(mbuffer,1) = tempstr.
    assign
      glog = hndlsocket:write(mbuffer,1,length(tempStr,'RAW':U)) no-error.
    set-size(mbuffer) = 0.
    if not glog
    then do:
       LogWrite:LogStr = LogWrite:LogStr + " " + "Ошибка при отправке сообщения удаленному клиенту.".
    end.
    assign
      glog = hndlsocket:write(mbuffer1,1,get-size(mbuffer1)) no-error.
    if not glog
      then do:
        LogWrite:LogStr = LogWrite:LogStr + " " + "Ошибка при отправке сообщения удаленному клиенту.".
      end.
    set-size(mbuffer1) = 0.
    return true.
      
  end method.
  
  
end class.
