/*

$Revision: f077abec0847, 3643, rls $
$Author: ARostovtsev $
$Date: 2024/01/31 10:15:43 $
$Workfile: inv-gd-doc.cls $
$Archive: ibs/th/bge/1crn/subjects/inv-gd-doc.cls $

Экспорт сообщения с накладаной в 1С ERPRN inv-gd-doc

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.str.*.
using ibs.th.str.ptrl.* from propath.

block-level on error undo, throw.

class ibs.th.bge.1crn.subjects.inv-gd-doc implements iexpsubject:
  
  { cmp/str-glbl.i class }
  { str/lib-trn.i  class }
  { gbl/attr-lib.i class}
  { str/trdcalib.i class }
  { cmp/library.i  class }
  { gbl/thbj-def.i       }
  { gbl/objsrv.i def }
  { utl/gtin.i class      }
  
  define temp-table buf_trn-doc like ub.trn-doc.
  
  define buffer buf_inv-line for ub.inv-line.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_doc-line-attr for ub.doc-line-attr.
  define buffer bf_doc-line-sum for ub.doc-line-sum.
  define buffer buf_doc-pl for ub.doc-pl.
  define buffer buf_gds for ub.goods.
  define buffer buf_doc-attr for ub.doc-attr.
  define buffer buf_units for ub.units.
  define buffer bf_rvs-line for ub.rvs-line.
  define buffer bf_rvs-doc for ub.rvs-doc.
  define buffer bf_gen-attr for ub.gen-attr.
  
  
  define property Msg as character no-undo
    get:
      return trim (Msg, {&new-line}).
    end.
    private set (inArg as char):
      Msg = Msg + {&new-line} + inArg.
    end.
    
  define property InitSecTag as character no-undo
    get.
    private set.
    
  define property BufTableHndlNew as handle no-undo
    get.
    set.

  define property BufTableHndlOld as handle no-undo
    get.
    set.
  
  define public property sendTableName as character no-undo init "trn-doc"
    get.
   
  define public property sendOldRowid as rowid  no-undo
    get.
    set.

  define public property sendNewRowid as rowid  no-undo
    get.
    set.

  define variable rvsinvObj        as class rvsinvsub no-undo .
  
  define variable sw               as handle    no-undo.
  define variable v-is-petrol-trn  as logical   no-undo.
  define variable v-is-pieces      as logical   no-undo.
  define variable isDel            as logical   no-undo.
  define variable varinvclcwt      as logical   no-undo.
  define variable varinvclcas      as logical   no-undo.
  define variable varinvclcex      as logical   no-undo.
  define variable varinvclcms      as logical   no-undo.
  define variable varinvclcbef     as logical   no-undo.
  define variable prtvalue         as character no-undo.
  define variable varinvclcspvalue as character no-undo.
  define variable varr-b           as character no-undo.
  define variable is-cdinv         as character no-undo .
  define variable v-bufhnd         as handle    no-undo.
  define variable v-doc-num        as character no-undo .
  define variable dprice-sale      as decimal   no-undo .
  define variable droad-tax        as decimal   no-undo .
  define variable dexcise          as decimal   no-undo .
  define variable v-qnty-type      as character no-undo .
  define variable dcurr-price      as decimal   no-undo .
  define variable prc-density      as decimal   no-undo .
  define variable dLoss-qnty       as decimal   no-undo .
  define variable dLoss-sum        as decimal   no-undo .
  define temp-table tt-marks no-undo
    field mark as character.
    
  constructor public inv-gd-doc():
    if not valid-handle (ibs.th.gbl.gbl-hndllib:g#trdcalib) then
      run str/trdcalib.p persistent no-error .
  end constructor.
  
  method public void CrContentToSW (insw as handle):
    { gbl/objsrv.i}
    define variable p-value      as character no-undo.
    define variable p-type       as character no-undo.
    
    sw = insw.
    
    create buf_trn-doc.
    
    v-bufhnd = buffer buf_trn-doc:handle.
    
    if valid-handle (BufTableHndlNew)
    then do:
      sendNewRowid  = BufTableHndlNew:rowid.
      v-bufhnd:buffer-copy (BufTableHndlNew) no-error.
      if error-status:error
      then do:
        Msg = "Ошибка выгрузки inv-gd-doc, неверный буфер BufTableHndlNew".
        undo, return error Msg.
      end.
      isDel = false.
    end.
    else do:
      if not valid-handle (BufTableHndlOld)
      then do:
        Msg = "Ошибка выгрузки inv-gd-doc, неопеределен ни старый ни новый буфер".
        undo, return error Msg.
      end.
      sendOldRowid  = BufTableHndlOld:rowid.
      v-bufhnd:buffer-copy (BufTableHndlOld) no-error.
      if error-status:error
      then do:
        Msg = "Ошибка выгрузки inv-gd-doc, неверный буфер BufTableHndlOld".
        undo, return error Msg.
      end.
      isDel = true.
    end.
    
    for each buf_inv-line no-lock where buf_inv-line.doc-code = buf_trn-doc.doc-code:
      { str/is-petrl.i
          buf_inv-line.artic
          buf_inv-line.prod-type
          buf_inv-line.prod-code
          v-is-petrol-trn
          v-is-pieces
      }
      if v-is-petrol-trn
        then leave.
    end.

    { str/tdat-val.i buf_trn-doc.doc-code
                 {&trdcattr-addsum}
                 p-value
                 p-type             }
    assign
      varinvclcbef = no
      varinvclcas  = no
      varinvclcex  = no
      varinvclcms  = no
      varinvclcwt  = no
    .
    if lookup( {&sum-before-doc}, p-value ) <> 0 then do:
      assign
        varinvclcbef = yes
      .
    end.
    if lookup( {&sum-general-doc}, p-value ) <> 0 then do:
      assign
        varinvclcas = yes
      .
    end.
    if lookup( {&sum-extra-doc}, p-value ) <> 0 then do:
      assign
        varinvclcex = yes
      .
    end.
    if lookup( {&sum-miss-doc}, p-value ) <> 0 then do:
      assign
        varinvclcms = yes
      .
    end.
    if lookup( {&sum-wastage-doc}, p-value ) <> 0 then do:
      assign
        varinvclcwt = yes
      .
    end.
    
    run str/invdcfrd.p (  input buf_trn-doc.doc-code,
                     output varinvclcspvalue,
                     output prtvalue,
                     output varr-b ,
                     output is-cdinv
                     ) no-error.
    
    if v-is-petrol-trn
    then do:
      StartDocInvFuel().
      GdsLineFuel().
      EndDocInvFuel().
    end.
    else do: 
      StartDocInv().
      GdsLine().
      EndDocInv().
    end.
    
  end.


  method private void GdsLine ():
    define variable vGT as integer no-undo .
    define variable vGtin as character no-undo .
    define variable vGtinQnty as integer no-undo .
    
    sw:start-element ("gds").
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code:
      find first buf_gds where
            buf_gds.artic = buf_doc-line.artic 
        and buf_gds.prod-code = buf_doc-line.prod-code
        and buf_gds.prod-type = buf_doc-line.prod-type.
      find first buf_doc-line-attr no-lock where buf_doc-line-attr.doc-code = buf_doc-line.doc-code
                                             and buf_doc-line-attr.gds-code = buf_gds.gds-code
                                             and buf_doc-line-attr.attr-code = "GTIN-qnty"
                                             no-error .
      sw:start-element ("gd").
        write-data-element ("gd-code", string-mth (buf_gds.gds-code)).
        write-data-element ("qnty-b", string-mth (round (buf_doc-line.doc-qnty - buf_doc-line.fact-qnty, 3))).
        write-data-element ("qnty-a", string-mth (round (buf_doc-line.doc-qnty, 3))).
        write-data-element ("qnty-df", string-mth (round (buf_doc-line.fact-qnty, 3))).
        write-data-element ("qnty-izl", string-mth (round (fncextra-qnty( buffer buf_doc-line ), 3))).
        write-data-element ("qnty-ned", string-mth (round (fncmiss-qnty( buffer buf_doc-line ), 3))).
        write-data-element ("qnty-eu", string-mth (round (0.0, 3))).
        write-data-element ("sum-b", string-mth (round (fncbefore-rubl( buffer buf_doc-line, buffer buf_gds ), 2))).
        write-data-element ("sum-a", string-mth (round (fncafter-rubl( buffer buf_doc-line, buffer buf_gds ), 2))).
        write-data-element ("sum-izl", string-mth (round (fncextra-rubl( buffer buf_doc-line, buffer buf_gds ), 2))).
        write-data-element ("sum-ned", string-mth (round (fncmiss-rubl( buffer buf_doc-line, buffer buf_gds ), 2))).
        write-data-element ("sum-eu", string-mth (round ( fncwastage( buffer buf_doc-line, buffer buf_gds ), 2))).
        write-data-element ("sum-b-s", string-mth (round (fncbefore-rubl( buffer buf_doc-line, buffer buf_gds ), 2))).
        write-data-element ("sum-a-s", string-mth (round (fncafter-rubl( buffer buf_doc-line, buffer buf_gds ), 2))).
        define variable vqnty as decimal no-undo.
        run str/getost.p (buf_doc-line.obj-type,buf_doc-line.obj-code,buf_gds.gds-code, buf_doc-line.doc-code, output vqnty ).
        write-data-element ("qnty-delta",string(round (buf_doc-line.doc-qnty - buf_doc-line.fact-qnty - vqnty, 3))). 
        if can-find (first bf_gen-attr no-lock where bf_gen-attr.table-name = "inv-doc-mark" and bf_gen-attr.attr-code = buf_trn-doc.doc-code
          and bf_gen-attr.attr-value = string(buf_gds.gds-code) and not bf_gen-attr.p-key begins {&tech-mark-prefix})
        then do:
          sw:start-element ("marks").
          for each bf_gen-attr no-lock where bf_gen-attr.table-name = "inv-doc-mark" and bf_gen-attr.attr-code = buf_trn-doc.doc-code
            and bf_gen-attr.attr-value = string(buf_gds.gds-code) and not bf_gen-attr.p-key begins {&tech-mark-prefix}:
            sw:start-element ("mark").
    /*        write-data-element ("gd-line-num", bf_gen-attr.attr-value).*/
            write-data-element ("mark-code", repSpecSimbforXlm( addBracketForCode(bf_gen-attr.p-key))).
            sw:end-element ("mark").
          end.
          sw:end-element ("marks").

        end.
        else
        if available buf_doc-line-attr
        and buf_doc-line-attr.attr-value > ""
        then do :
          sw:start-element ("marks").
          GT_ :
          do vGT = 1 to num-entries(buf_doc-line-attr.attr-value, ";") :
            assign
              vGtin = entry(1, entry(vGT, buf_doc-line-attr.attr-value, ";"), "=")
              vGtinQnty = integer(entry(2, entry(vGT, buf_doc-line-attr.attr-value, ";"), "="))
            no-error .
            if error-status:error
            then next GT_ .
            
            sw:start-element ("mark").
/*            write-data-element ("mark-code", "02" + vGtin + "37" + string-mth(vGtinQnty)) .*/
            write-data-element ("gtin", vGtin) .
            write-data-element ("gtin-qnt", string-mth(vGtinQnty)) .
            sw:end-element ("mark").
          end .
          sw:end-element ("marks").
        end .
      sw:end-element ("gd").
    end.
    sw:end-element ("gds").
    
  end.

  
  method private void GdsLineFuel ():
    define variable dAddCliQnty       as decimal   no-undo .
    define variable dAddQnty          as decimal   no-undo .
    define variable v-sum-b           as decimal   no-undo .
    define variable v-sum-a           as decimal   no-undo .
    define variable v-sum-b-s         as decimal   no-undo .
    define variable v-sum-a-s         as decimal   no-undo .
    define variable v-sum-df          as decimal   no-undo .


          
    find first bf_rvs-doc no-lock where
             bf_rvs-doc.rvs-code = buf_trn-doc.out-code no-error .
    
    sw:start-element ("gds").
    for each buf_doc-line no-lock where buf_doc-line.doc-code = buf_trn-doc.doc-code:
      find first buf_gds where
            buf_gds.artic = buf_doc-line.artic 
        and buf_gds.prod-code = buf_doc-line.prod-code
        and buf_gds.prod-type = buf_doc-line.prod-type.
      for each buf_doc-pl no-lock where buf_doc-pl.obj-type = buf_doc-line.obj-type and buf_doc-pl.obj-code = buf_doc-line.obj-code
        and buf_doc-pl.out-code = buf_doc-line.doc-code and buf_doc-pl.gds-code = buf_gds.gds-code:
        
        assign
          dAddCliQnty = 0.0
          dAddQnty = 0.0
        .
        
        find first bf_rvs-line no-lock where
          available (bf_rvs-doc) and
          bf_rvs-line.rvs-code = buf_trn-doc.out-code and
          bf_rvs-line.obj-type = buf_doc-line.obj-type and
          bf_rvs-line.obj-code = buf_doc-line.obj-code and
          bf_rvs-line.gds-code = buf_doc-pl.gds-code and
          bf_rvs-line.pl-code = buf_doc-pl.pl-code no-error.
          
        if available (bf_rvs-line)
        then
          assign
            dAddCliQnty   = bf_rvs-line.state-add-qnty * bf_rvs-line.state-density
            dAddQnty  = bf_rvs-line.state-add-qnty.
    
        assign
          v-sum-b-s = fncbefore-rubl( buffer buf_doc-line, buffer buf_gds)
          v-sum-a-s = fncafter-rubl( buffer buf_doc-line, buffer buf_gds)
          v-sum-b = v-sum-b-s / (buf_doc-line.doc-qnty - buf_doc-line.fact-qnty) * buf_doc-pl.rest-bf-qnty
          v-sum-a = v-sum-a-s / buf_doc-line.doc-qnty * buf_doc-pl.rest-af-qnty
          v-sum-df = v-sum-a - v-sum-b
        .

        find first buf_units where buf_units.unit-name = buf_gds.unit-base.
        sw:start-element ("gd").
          write-data-element ("tank-num", string-mth (buf_doc-pl.pl-code)).
          write-data-element ("gd-code", string-mth (buf_gds.gds-code)).
          write-data-element ("cap-b", string-mth (round (buf_doc-pl.rest-bf-qnty, 3))).
          write-data-element ("cap-a", string-mth (round (buf_doc-pl.rest-af-qnty, 3))).
          write-data-element ("cap-df", string-mth (round (buf_doc-pl.rest-af-qnty - buf_doc-pl.rest-bf-qnty, 3))).
          write-data-element ("wght-b", string-mth (round (buf_doc-pl.cli-rest-bf-qnty, 3))).
          write-data-element ("wght-a", string-mth (round ( buf_doc-pl.cli-rest-af-qnty , 3))).
          write-data-element ("wght-df", string-mth (round (buf_doc-pl.cli-fact-qnty, 3))).
          write-data-element ("sum-b", string-mth (round 
                (
                  v-sum-b
                , 2))).
          
          write-data-element ("sum-a", string-mth (round 
                (
                  v-sum-a
                , 2))).
                
          write-data-element ("sum-df", string-mth (round 
                (
                  v-sum-df
                , 2))).
                
          write-data-element ("wght-izl", string-mth (round ((if buf_doc-pl.cli-fact-qnty > 0 then buf_doc-pl.cli-fact-qnty else 0.0), 3))).
          write-data-element ("wght-ned", string-mth (round ((if buf_doc-pl.cli-fact-qnty < 0 then absolute (buf_doc-pl.cli-fact-qnty) else 0.0), 3))).
          write-data-element ("sum-izl", string-mth (round ((if v-sum-df > 0 then v-sum-df else 0.0), 2))).
          write-data-element ("sum-ned", string-mth (round ((if v-sum-df < 0 then absolute (v-sum-df) else 0), 2))).

          { gbl/bcodeprc.i
              buf_trn-doc.obj-type
              buf_trn-doc.obj-code
              buf_gds.gds-code
              0
              buf_trn-doc.fact-order
              v-doc-num
              dprice-sale
              droad-tax
              dexcise
              no-error
          }
          if error-status :error
          then do:
            Msg = 'Не могу определить текущие продажные цены.'.
            undo, return error Msg.
          end.
          
          assign
            v-qnty-type = "cli":U
          .
          assign
            dcurr-price = dprice-sale
          .
          
          assign
            dLoss-qnty = 0.0
          .
          find first bf_doc-line-sum no-lock
            where bf_doc-line-sum.doc-code  = buf_trn-doc.doc-code
              and bf_doc-line-sum.gds-code  = buf_gds.gds-code
              and bf_doc-line-sum.sum-type  = substitute( "&1&2&3&2&4", {&sum-wastage-doc}, {&delim-par}, 'base', buf_doc-pl.pl-code )
            no-error .
          if available bf_doc-line-sum then do:
            assign
              dLoss-qnty = bf_doc-line-sum.fact-qnty
            .
          end.
          assign
            dLoss-sum  = dLoss-qnty  * dcurr-price
          .


          assign
            dLoss-qnty = 0.0
          .
          find first bf_doc-line-sum no-lock
            where bf_doc-line-sum.doc-code  = buf_trn-doc.doc-code
              and bf_doc-line-sum.gds-code  = buf_gds.gds-code
              and bf_doc-line-sum.sum-type  = substitute( "&1&2&3&2&4", {&sum-wastage-doc}, {&delim-par}, 'cli', buf_doc-pl.pl-code )
            no-error .
          if available bf_doc-line-sum then do:
            assign
              dLoss-qnty = bf_doc-line-sum.fact-qnty
            .
          end.
          
          write-data-element ("wght-eu", string-mth (round (dLoss-qnty, 2))).
          write-data-element ("sum-eu", string-mth (round ( dLoss-sum, 2))).
          
          write-data-element ("pipeline-cap", string-mth (round (dAddQnty, 2))).
          write-data-element ("pipeline-wght", string-mth (round (dAddCliQnty, 2))).
          
          rvsinvObj = new rvsinvsub ().
          if available (bf_rvs-line)
          then do:
          assign
            rvsinvObj:RvsCode = bf_rvs-line.rvs-code
            rvsinvObj:ObjCode = buf_trn-doc.obj-code
            rvsinvObj:ObjType = buf_trn-doc.obj-type
            rvsinvObj:PlCode = bf_rvs-line.pl-code
            rvsinvObj:GdsCode =  buf_gds.gds-code
          .
          end.
          
          if rvsinvObj:RvsInvStrObj:FillSub(rvsinvObj)
          then do:
            write-data-element ("wght-tp-N", string-mth (round (rvsinvObj:TPNormal, 3))).
            write-data-element ("wght-tp-F", string-mth (round (rvsinvObj:TPWast, 3))).
          end.
          else do:
            write-data-element ("wght-tp-N", string-mth (round (0.0, 3))).
            write-data-element ("wght-tp-F", string-mth (round (0.0, 3))).            
          end.
          
        sw:end-element ("gd").
      end.
    end.
    sw:end-element ("gds").
    
  end.
  
  
  method private void StartDocInv ():
      InitSecTag =  "inv-gd-docs".
      sw:start-element ("inv-gd-doc") .
        write-data-element ("doc-code", buf_trn-doc.doc-code).
        write-data-element ("doc-num", buf_trn-doc.doc-code).
        write-data-element ("del-f", string (isDel, "1/0") ).
        write-data-element ("doc-date", if buf_trn-doc.doc-date = ? then "" else iso-date (datetime (buf_trn-doc.doc-date, buf_trn-doc.real-time-create * 1000))).
        write-data-element ("fact-date", if buf_trn-doc.fact-date = ? then "" else iso-date (datetime (buf_trn-doc.fact-date, buf_trn-doc.fact-time * 1000))).
        write-data-element ("shift-date", if buf_trn-doc.shift-date = ? then "" else iso-date (date (buf_trn-doc.shift-date))).
        write-data-element ("shift-num", if buf_trn-doc.shift-num = ? then "0" else string-mth (buf_trn-doc.shift-num)).
    sw:start-element ("atr") .
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = "invTech" and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code no-error .
    if available (ub.inv-doc-attr) then 
    do:
      if ub.inv-doc-attr.attr-value = string(true) then write-data-element ("techop", "1").
      else write-data-element ("techop", "0").
    end.
    else 
    do:
      write-data-element ("techop", "0").
    end.
        
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-prikaz-number} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("ordernum", ub.inv-doc-attr.attr-value).
    end.

    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-prikaz-date} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("orderdate", iso-date (date (ub.inv-doc-attr.attr-value))).
    end.      
        
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-inv-date} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code no-error .
    if available (ub.inv-doc-attr) then 
    do:
      if ub.inv-doc-attr.attr-value <> "" then write-data-element ("invbegin", iso-date (date (ub.inv-doc-attr.attr-value))).
      else write-data-element ("invbegin", if buf_trn-doc.doc-date = ? then "" else iso-date (date (buf_trn-doc.doc-date))).
    end.
    else 
    do:
      write-data-element ("invbegin", if buf_trn-doc.doc-date = ? then "" else iso-date (date (buf_trn-doc.doc-date))).
    end. 
        
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-fio-agent} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("chairmen1", ub.inv-doc-attr.attr-value).
    end.

    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-fio-player1} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("chairmen2", ub.inv-doc-attr.attr-value).
    end.

    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-fio-player2} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("chairmen3", ub.inv-doc-attr.attr-value).
    end.
        
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-fio-player3} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("chairmen4", ub.inv-doc-attr.attr-value).
    end.
                 
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-pos-agent} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("jobtitle1", ub.inv-doc-attr.attr-value).
    end.

    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-pos-player1} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("jobtitle2", ub.inv-doc-attr.attr-value).
    end.  
              
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-pos-player2} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("jobtitle3", ub.inv-doc-attr.attr-value).
    end.    
         
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-pos-player3} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("jobtitle4", ub.inv-doc-attr.attr-value).
    end.  
        
    find first ub.user-account no-lock where ub.user-account.user-id = buf_trn-doc.user-name no-error .  
    if available (ub.user-account) then 
      write-data-element ("invclose", string(ub.user-account.last-name + " " + ub.user-account.first-name + " " + ub.user-account.second-name) ).              
    else write-data-element ("invclose", "").        
    sw:end-element ("atr") .    
  end.

  method private void EndDocInv ():
    
    sw:end-element ("inv-gd-doc") .
/*    sw:end-element ("inv-gd-docs") .*/
    
  end.

  method private void StartDocInvFuel ():
      define buffer buf_doc-attr for ub.doc-attr .
      InitSecTag =  "inv-fuel-docs".
      sw:start-element ("inv-fuel-doc") .
        write-data-element ("doc-code", buf_trn-doc.doc-code).
        write-data-element ("doc-num", buf_trn-doc.doc-code).
        write-data-element ("del-f", string (isDel, "1/0") ).
        write-data-element ("doc-date", if buf_trn-doc.doc-date = ? then "" else iso-date (datetime (buf_trn-doc.doc-date, buf_trn-doc.real-time-create * 1000))).
        write-data-element ("fact-date", if buf_trn-doc.fact-date = ? then "" else iso-date (datetime (buf_trn-doc.fact-date, buf_trn-doc.fact-time * 1000))).
        write-data-element ("shift-date", if buf_trn-doc.shift-date = ? then "" else iso-date (date (buf_trn-doc.shift-date))).
        write-data-element ("shift-num", if buf_trn-doc.shift-num = ? then "0" else string-mth (buf_trn-doc.shift-num)).
        if can-find(first bf_rvs-doc no-lock where
             bf_rvs-doc.rvs-code = buf_trn-doc.out-code) 
          then write-data-element ("check-fuel-doc", buf_trn-doc.out-code).
        find first buf_doc-attr no-lock where buf_doc-attr.doc-code = buf_trn-doc.doc-code
                                          and buf_doc-attr.attr-code = {&trdcattr-othermoves}
                                          no-error .
        if available buf_doc-attr
        and logical(buf_doc-attr.attr-value)  
        then do :
          write-data-element ("othermoves", "1") .
        end . 
        else do :
          write-data-element ("othermoves", "0") .
        end .
           
    sw:start-element ("atr") .
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = "invTech" and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code no-error .
    if available (ub.inv-doc-attr) then 
    do:
      if ub.inv-doc-attr.attr-value = string(true) then write-data-element ("techop", "1").
      else write-data-element ("techop", "0").
    end.
    else 
    do:
      write-data-element ("techop", "0").
    end.
        
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-prikaz-number} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("ordernum", ub.inv-doc-attr.attr-value).
    end.

    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-prikaz-date} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("orderdate", iso-date (date (ub.inv-doc-attr.attr-value))).
    end.      
        
    find first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-inv-date} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code no-error .
    if available (ub.inv-doc-attr) then 
    do:
      if ub.inv-doc-attr.attr-value <> "" then write-data-element ("invbegin", iso-date (date (ub.inv-doc-attr.attr-value))).
      else write-data-element ("invbegin", if buf_trn-doc.doc-date = ? then "" else iso-date (date (buf_trn-doc.doc-date))).
    end.
    else 
    do:
      write-data-element ("invbegin", if buf_trn-doc.doc-date = ? then "" else iso-date (date (buf_trn-doc.doc-date))).
    end. 
        
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-fio-agent} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("chairmen1", ub.inv-doc-attr.attr-value).
    end.

    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-fio-player1} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("chairmen2", ub.inv-doc-attr.attr-value).
    end.

    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-fio-player2} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("chairmen3", ub.inv-doc-attr.attr-value).
    end.
        
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-fio-player3} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("chairmen4", ub.inv-doc-attr.attr-value).
    end.
                 
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-pos-agent} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("jobtitle1", ub.inv-doc-attr.attr-value).
    end.

    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-pos-player1} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("jobtitle2", ub.inv-doc-attr.attr-value).
    end.  
              
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-pos-player2} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("jobtitle3", ub.inv-doc-attr.attr-value).
    end.    
         
    for first ub.inv-doc-attr no-lock where ub.inv-doc-attr.attr-code = {&trdcattr-pos-player3} and
      ub.inv-doc-attr.doc-code = buf_trn-doc.doc-code and
      ub.inv-doc-attr.attr-value <> "":
      write-data-element ("jobtitle4", ub.inv-doc-attr.attr-value).
    end.  
        
    find first ub.user-account no-lock where ub.user-account.user-id = buf_trn-doc.user-name no-error .  
    if available (ub.user-account) then 
      write-data-element ("invclose", string(ub.user-account.last-name + " " + ub.user-account.first-name + " " + ub.user-account.second-name) ).              
    else write-data-element ("invclose", "").        
    sw:end-element ("atr") .            
                                  
  end.

  method private void EndDocInvFuel ():
    
    sw:end-element ("inv-fuel-doc") .
/*    sw:end-element ("inv-fuel-docs") .*/
    
  end.

  method private void write-data-element (inTag as char, inValue as char):
    
    if inValue = ?
    then do:
      Msg = substitute ('Предупреждение отладки: тег &1 иммет неопределнное значение. Работа будет продолжена...', inTag).
    end.

    if inTag = ?
    then do:
      Msg = substitute ('Предупреждение отладки: Имя тега не может быть пустым...').
      return.
    end.

    if inTag = "acc-ship"
    then do:
      if string (inValue) begins "."
        then inValue = "0" + inValue.
    end.

    inTag = lc (InTag).

    if inValue = ?
      then sw:write-empty-element (inTag).
      else sw:write-data-element (inTag, inValue).
  
  end.

  method private character string-mth (inValue as integer):
    
    def var v-str as character no-undo.
    
    if inValue = ?
      then v-str = "0".
      else v-str = string (inValue). 
    
    return v-str.
    
  end.

  method private character string-mth (inValue as decimal):
    
    def var v-str as character no-undo.
    
    if inValue = ?
      then v-str = "0".
    
    if string (inValue) begins "."
      then v-str = "0" + string (inValue).
      else v-str = string (inValue).
    return v-str.
    
  end.

  method private decimal fncwastage ( buffer local-doc-line for ub.doc-line,
                                        buffer local-goods for ub.goods ) :
    define buffer bf_doc-line-sum      for ub.doc-line-sum.
    define buffer bf-wst_doc-line-sum  for ub.doc-line-sum.

    if varinvclcas = yes and
       varinvclcwt = yes then do:
      find first bf_doc-line-sum no-lock where
                 bf_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf_doc-line-sum.gds-code = local-goods.gds-code and
                 bf_doc-line-sum.sum-type = {&sum-general-doc}.
      find first bf-wst_doc-line-sum no-lock where
                 bf-wst_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf-wst_doc-line-sum.gds-code = local-goods.gds-code and
                 bf-wst_doc-line-sum.sum-type = {&sum-wastage-doc}.
      if bf_doc-line-sum.sale-sum-base < 0 then do:
        if varr-b = "base" then do:
          if bf-wst_doc-line-sum.sale-sum-base > - bf_doc-line-sum.sale-sum-base then do:
            return - bf_doc-line-sum.sale-sum-base.
          end.
          else do:
            return bf-wst_doc-line-sum.sale-sum-base.
          end.
        end.
        else do:
          if bf-wst_doc-line-sum.sale-sum-rubl > - bf_doc-line-sum.sale-sum-rubl then do:
            return - bf_doc-line-sum.sale-sum-rubl.
          end.
          else do:
            return bf-wst_doc-line-sum.sale-sum-rubl.
          end.
        end.
      end.
      else do:
        return 0.00.
      end.
    end.
    return 0.00.
    
  end. /* fncwastage */

  method private decimal fncextra-qnty ( buffer local-doc-line for ub.doc-line ) :
    if local-doc-line.fact-qnty > 0 then do:
      return local-doc-line.fact-qnty.
    end.
    else do:
      return 0.00.
    end.
  end.

  method private decimal fncmiss-qnty ( buffer local-doc-line for ub.doc-line ) :
    if local-doc-line.fact-qnty < 0 then do:
      return - local-doc-line.fact-qnty.
    end.
    else do:
      return 0.00.
    end.
  end.
  
  method private decimal fncextra-qntykg ( buffer local-doc-line for ub.doc-line ) :
    if fncdiffqntykg( buffer buf_doc-line ) > 0 then do:
      return local-doc-line.fact-qnty.
    end.
    else do:
      return 0.00.
    end.
  end.

  method private decimal fncmiss-qntykg ( buffer local-doc-line for ub.doc-line ) :
    if fncdiffqntykg( buffer buf_doc-line ) < 0 then do:
      return - local-doc-line.fact-qnty.
    end.
    else do:
      return 0.00.
    end.
  end.

  method private decimal fncbefore-sale-rubl ( buffer local-doc-line for ub.doc-line ,
                                          buffer local-goods for ub.goods) :
    define variable varreturn as decimal no-undo.
  
    define buffer bf_doc-line-sum for ub.doc-line-sum.
  
    if varinvclcbef = yes then do:
      find first bf_doc-line-sum no-lock where
                 bf_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf_doc-line-sum.gds-code = local-goods.gds-code and
                 bf_doc-line-sum.sum-type = {&sum-before-doc}.
      assign
        varreturn = bf_doc-line-sum.sale-sum-rubl
      .
    end.
    else do:
      assign
        varreturn = 0.00
      .
    end.
    return varreturn.
  end.

  method private decimal fncafter-sale-rubl ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
    define buffer bf_doc-line-sum for ub.doc-line-sum.
  
    if varinvclcas = yes then do:
      find first bf_doc-line-sum no-lock where
                 bf_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf_doc-line-sum.gds-code = local-goods.gds-code and
                 bf_doc-line-sum.sum-type = {&sum-after-doc}.
      return bf_doc-line-sum.sale-sum-rubl.
    end.
    else do:
      return 0.00.
    end.
  end.

  method private decimal fncbefore-rubl ( buffer local-doc-line for ub.doc-line ,
                                          buffer local-goods for ub.goods) :
    define variable varreturn as decimal no-undo.
  
    define buffer bf_doc-line-sum for ub.doc-line-sum.
  
    if varinvclcbef = yes then do:
      find first bf_doc-line-sum no-lock where
                 bf_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf_doc-line-sum.gds-code = local-goods.gds-code and
                 bf_doc-line-sum.sum-type = {&sum-before-doc}.
      assign
        varreturn = bf_doc-line-sum.cost-sum-rubl - bf_doc-line-sum.cost-VAT-rubl
      .
    end.
    else do:
      assign
        varreturn = 0.00
      .
    end.
    return varreturn.
  end.

  method private decimal fncafter-rubl ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
    define buffer bf_doc-line-sum for ub.doc-line-sum.
  
    if varinvclcas = yes then do:
      find first bf_doc-line-sum no-lock where
                 bf_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf_doc-line-sum.gds-code = local-goods.gds-code and
                 bf_doc-line-sum.sum-type = {&sum-after-doc}.
      return bf_doc-line-sum.cost-sum-rubl - bf_doc-line-sum.cost-VAT-rubl.
    end.
    else do:
      return 0.00.
    end.
  end.
  
  method private decimal fncextra-rubl ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
    define buffer bf_doc-line-sum for ub.doc-line-sum.
  
    if varinvclcas = yes then do:
      find first bf_doc-line-sum no-lock where
                 bf_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf_doc-line-sum.gds-code = local-goods.gds-code and
                 bf_doc-line-sum.sum-type = {&sum-general-doc}.
      if bf_doc-line-sum.cost-sum-rubl > 0 then do:
        return bf_doc-line-sum.sale-sum-rubl.
      end.
      else do:
        return 0.00.
      end.
    end.
    else do:
      return 0.00.
    end.
  end.
  
  method private decimal fncmiss-rubl ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
                                           
    define buffer bf_doc-line-sum for ub.doc-line-sum.
  
    if varinvclcas = yes then do:
      find first bf_doc-line-sum no-lock where
                 bf_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf_doc-line-sum.gds-code = local-goods.gds-code and
                 bf_doc-line-sum.sum-type = {&sum-general-doc}.
      if bf_doc-line-sum.cost-sum-rubl < 0 then do:
        return - bf_doc-line-sum.sale-sum-rubl.
      end.
      else do:
        return 0.00.
      end.
    end.
    else do:
      return 0.00.
    end.

  end.
  
  method private decimal fncdiff-rubl ( buffer local-doc-line for ub.doc-line,
                                         buffer local-goods for ub.goods ) :
                                           
    define buffer bf_doc-line-sum for ub.doc-line-sum.
  
    if varinvclcas = yes then do:
      find first bf_doc-line-sum no-lock where
                 bf_doc-line-sum.doc-code = local-doc-line.doc-code and
                 bf_doc-line-sum.gds-code = local-goods.gds-code and
                 bf_doc-line-sum.sum-type = {&sum-general-doc}.
      return bf_doc-line-sum.cost-sum-rubl.
    end.
    else do:
      return 0.00.
    end.

  end.

  method private decimal fncwasqntykg ( buffer local-doc-line for ub.doc-line ) :
    define variable d_out-qnty-kg as decimal no-undo.
  
    inv-line_qnty( input recid( local-doc-line ), input "was",  output d_out-qnty-kg ) no-error.
    return ( if error-status :error then 0 else d_out-qnty-kg ).
  end.
  
  method private decimal fncareqntykg ( buffer local-doc-line for ub.doc-line ) :
    define variable d_out-qnty-kg as decimal no-undo.
  
    inv-line_qnty( input recid( local-doc-line ), input "are",  output d_out-qnty-kg ) no-error.
    return ( if error-status :error then 0 else d_out-qnty-kg ).

  end.

  method private decimal fncdiffqntykg ( buffer local-doc-line for ub.doc-line ) :
  define variable d_out-qnty-kg as decimal no-undo.

  inv-line_qnty( input recid( local-doc-line ), input "diff", output d_out-qnty-kg ) no-error.
    return ( if error-status :error then 0 else d_out-qnty-kg ).
  end.

  method private void inv-line_qnty ( p-doc-line-rec as recid,
                                         p-mode as character, 
                                         output p-qnty-kg as decimal ) :

    define buffer buf_doc-line for ub.doc-line.
    define buffer buf_inv-line for ub.inv-line.
  
    do on error undo, return error return-value :
      find first buf_doc-line no-lock where
          recid( buf_doc-line ) = p-doc-line-rec no-error.
      if not available buf_doc-line then do:
        assign
          p-qnty-kg = 0.0
        .
        return.
      end.
  
      find first buf_inv-line no-lock where
                 buf_inv-line.doc-code  = buf_doc-line.doc-code  and
                 buf_inv-line.artic     = buf_doc-line.artic     and
                 buf_inv-line.prod-type = buf_doc-line.prod-type and
                 buf_inv-line.prod-code = buf_doc-line.prod-code no-error.
      if not available buf_inv-line then do:
        assign
          p-qnty-kg = 0.0
        .
        return.
      end.
  
      case p-mode :
        when "was"  then do:
          assign
            p-qnty-kg = buf_inv-line.before-cli-qnty
          .
        end.
        when "are"  then do:
          assign
            p-qnty-kg = buf_inv-line.wast-cli-qnty
          .
        end.
        when "diff" then do:
          assign
            p-qnty-kg = buf_doc-line.cli-qnty
          .
        end.
      end case. /* p-mode */
    end. /* on error */

  end.

end class.
