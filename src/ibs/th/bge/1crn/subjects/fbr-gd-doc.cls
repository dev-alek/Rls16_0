/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Экспорт сообщения с накладаной в 1С ERPRN trn-gd-doc

Автор: Александр Морозов
Дата создания: 26/09/17
Author: Morozov Alexandr
Creation date: 26/09/17

*/

using Progress.Lang.*.
using ibs.th.bge.1crn.subjects.*.
using ibs.th.str.*.
using ibs.th.gbl.storage.*.

block-level on error undo, throw.

class ibs.th.bge.1crn.subjects.fbr-gd-doc inherits ibs.th.gbl.sys.objth implements iexpsubject:
  define override public property vss-revision    as character no-undo init "$Revision:$":U get .
  define override public property vss-author      as character no-undo init "$Author:$":U get.
  define override public property vss-date        as character no-undo init "$Date:$":U get.
  define override public property vss-workfile    as character no-undo init "$Workfile:$":U get.
  define override public property vss-archive     as character no-undo init "$Archive:$":U get.
  define override public property vss-description as character no-undo init "Выгрузка документов производства в 1С" get.

  { cmp/str-glbl.i class }
  { cmp/library.i  class }
  { str/utd-typemark.i class }
  
  define temp-table buf_fbr-doc like ub.fbr-doc.
  
  define buffer buf_fbr-line for ub.fbr-line.
  define buffer buf_trn-doc for ub.trn-doc.
  define buffer buf_doc-line for ub.doc-line.
  define buffer buf_doc-line-attr for ub.doc-line-attr.
  define buffer buf_gds-dtl for ub.gds-dtl.
  define buffer buf_doc-pl for ub.doc-pl.
  define buffer buf_gds for ub.goods.
  define buffer buf_doc-attr for ub.doc-attr.
  define buffer buf_parts for ub.parts.
  define buffer buf_recipe for ub.recipe.
  define buffer buf_fbr-recipe-gds for ub.fbr-recipe-gds.
  define buffer buf_marking-lines for ub.marking-lines .
  
  define property Msg as character no-undo
    get:
      return trim (Msg, {&new-line}).
    end.
    private set (inArg as char):
      Msg = Msg + {&new-line} + inArg.
    end.

  define property DocCode as character no-undo
    get.
    set.

  define property BufTableHndl as handle no-undo
    get.
    set.

  define temp-table tt-gds no-undo
    field line-num as integer
    field gds-code as integer
  .

  define property InitSecTag as character no-undo init "trn-gd-docs"
    get.

  define property BufTableHndlNew as handle no-undo
    get.
    set.

  define property BufTableHndlOld as handle no-undo
    get.
    set.

  define public property sendTableName as character no-undo init "fbr-doc"
    get.
   
  define public property sendOldRowid as rowid  no-undo
    get.
    set.

  define public property sendNewRowid as rowid  no-undo
    get.
    set.

  define variable sw               as handle    no-undo.
  define variable v-doc-type-ERPRN as character no-undo.
  define variable v-is-petrol-trn  as logical   no-undo.
  define variable v-is-pieces      as logical   no-undo.
  define variable isDel            as logical   no-undo.
  define variable v-bufhnd         as handle    no-undo.
  define variable v-user-name      as character no-undo.

  method public void CrContentToSW (insw as handle):
    
    sw = insw.
    
    create buf_fbr-doc.
    
    v-bufhnd = buffer buf_fbr-doc:handle.
    
    if valid-handle (BufTableHndlNew)
    then do:
      sendNewRowid  = BufTableHndlNew:rowid.
      v-bufhnd:buffer-copy (BufTableHndlNew) no-error.
      if error-status:error
      then do:
        Msg = "Ошибка выгрузки fbr-gd-doc, неверный буфер BufTableHndlNew".
        undo, return error Msg.
      end.
      isDel = false.
    end.
    else do:
      if not valid-handle (BufTableHndlOld)
      then do:
        Msg = "Ошибка выгрузки fbr-gd-doc, неопеределен ни старый ни новый буфер".
        undo, return error Msg.
      end.
      sendOldRowid  = BufTableHndlOld:rowid.
      v-bufhnd:buffer-copy (BufTableHndlOld) no-error.
      if error-status:error
      then do:
        Msg = "Ошибка выгрузки fbr-gd-doc, неверный буфер BufTableHndlOld".
        undo, return error Msg.
      end.
      isDel = true.
    end.
    
    case buf_fbr-doc.doc-type:
      when {&manufacturing} then do:
        v-doc-type-ERPRN = "6".
          StartDocFbr().
          FbrLine().
          EndDocFbr().
      end. 
      otherwise do:
        return.
      end.
    end.
    
  end.


  method private void FbrLine ():
    
    find first buf_fbr-line no-lock where buf_fbr-line.doc-code = buf_fbr-doc.doc-code no-error.
    if not available (buf_fbr-line)
      then return.
    
    /*for each buf_fbr-line no-lock where buf_fbr-line.doc-code = buf_fbr-doc.doc-code:
    
    
    sw:start-element ("gds").
    for each buf_fbr-line no-lock where buf_fbr-line.doc-code = buf_fbr-doc.doc-code:
      
      find first buf_gds where
            buf_gds.artic = buf_fbr-line.artic 
        and buf_gds.prod-code = buf_fbr-line.prod-code
        and buf_gds.prod-type = buf_fbr-line.prod-type.
      
      ii = ii + 1.
      
      create tt-gds.
      assign
        tt-gds.gds-code = buf_gds.gds-code
        tt-gds.line-num = ii
      .
      
      sw:start-element ("gd").
        write-data-element ("line-num", string-mth (tt-gds.line-num)).
        write-data-element ("gd-code", string-mth (buf_gds.gds-code)).
        write-data-element ("unit-code", string (buf_gds.unit-base)).
        write-data-element ("qnty-ttn", string-mth (round (buf_fbr-line.fact-qnty, 3))).
        write-data-element ("qnty-fact", string-mth (round (buf_fbr-line.fact-qnty, 3))).
        write-data-element ("sum", string-mth (round (buf_fbr-line.price-rubl * buf_fbr-line.fact-qnty, 2))).
        write-data-element ("sum-nds", string-mth (round ((buf_fbr-line.price-sum-vat-rubl) , 2))).
      sw:end-element ("gd").
      
    end.
    sw:end-element ("gds").*/
    FBR ().
    
  end.

  method private void FBR ():

    define variable ii as integer no-undo.
    define variable vGT as integer no-undo .
    define variable vGtin as character no-undo .
    define variable vQnty as integer no-undo .
    
    define variable v-value as character no-undo .
    define variable v-type as character no-undo .
    define variable isVarWeight as logical no-undo init no .

    sw:start-element ("dishs").    
    for each buf_fbr-line no-lock where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
      and buf_fbr-line.is-comp:
      
      find first buf_gds where
            buf_gds.artic = buf_fbr-line.artic 
        and buf_gds.prod-code = buf_fbr-line.prod-code
        and buf_gds.prod-type = buf_fbr-line.prod-type.
      
      ii = ii + 1.
      
      isVarWeight = WghProdVariable(buf_fbr-doc.obj-type, buf_fbr-doc.obj-code, buf_gds.gds-code).
      
      &scop proc-name gds-attr-value
      {&run_proc_attr-lib}
        ( input buf_gds.gds-code
         ,input {&attr-mark-type} 
         ,output v-value
         ,output v-type
        )        no-error .
      if error-status :error
      then do:
        undo, return error return-value .
      end.
      
      find first tt-gds where tt-gds.gds-code = buf_gds.gds-code no-error.

      sw:start-element ("dish").
        write-data-element ("line-num", string-mth (ii)).
        write-data-element ("gd-code", string-mth (buf_gds.gds-code)).
        write-data-element ("oper-type", (if buf_fbr-line.trn-type = {&write-off}
          then "2" else "1") ).
        write-data-element ("qnty", string-mth (round ((buf_fbr-line.fact-qnty) , 3))).
        write-data-element ("u-price", string-mth (round ((buf_fbr-line.price-rubl) , 2))).
        write-data-element ("p-price", string-mth (round ((buf_fbr-line.price-sale) , 2))).
        write-data-element ("u-price-s", string-mth (round (buf_fbr-line.price-sum-rubl , 2))).
        write-data-element ("rcp-code", buf_fbr-line.recipe-code).
        
        if (ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_fbr-doc.obj-type, buf_fbr-doc.obj-code):GetIsEDOForType(v-value) or isVarWeight) and
           can-find(first buf_marking-lines where 
                          buf_marking-lines.gds-code = buf_gds.gds-code
                      and buf_marking-lines.obj-type = buf_fbr-doc.obj-type
                      and buf_marking-lines.obj-code = buf_fbr-doc.obj-code
                      and buf_marking-lines.in-code  = "manufacturing"
                      and buf_marking-lines.out-code = buf_fbr-line.doc-code
                      and buf_marking-lines.part-code = buf_fbr-line.recipe-code
                      and buf_marking-lines.prt-code = 0
                      and buf_marking-lines.doc-level = 1)
        then do :
          sw:start-element ("marks").
          for each buf_marking-lines no-lock where buf_marking-lines.gds-code = buf_gds.gds-code
                                               and buf_marking-lines.obj-type = buf_fbr-doc.obj-type
                                               and buf_marking-lines.obj-code = buf_fbr-doc.obj-code
                                               and buf_marking-lines.in-code  = "manufacturing"
                                               and buf_marking-lines.out-code = buf_fbr-line.doc-code
                                               and buf_marking-lines.part-code = buf_fbr-line.recipe-code
                                               and buf_marking-lines.prt-code = 0
                                               and buf_marking-lines.doc-level = 1
          :
            sw:start-element ("mark").
            write-data-element ("mark-code", repTegforDm( addBracketForCode(buf_marking-lines.mark))).
            sw:end-element ("mark").
          end .
          sw:end-element ("marks").
        end . 
        
      sw:end-element ("dish").

    end.
    sw:end-element ("dishs").

    sw:start-element ("ingrs").
    for each buf_fbr-line no-lock where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
      and not buf_fbr-line.is-comp:    

      find first buf_gds no-lock where
            buf_gds.artic = buf_fbr-line.artic 
        and buf_gds.prod-code = buf_fbr-line.prod-code
        and buf_gds.prod-type = buf_fbr-line.prod-type.
      
      isVarWeight = WghProdVariable(buf_fbr-doc.obj-type, buf_fbr-doc.obj-code, buf_gds.gds-code).

      find first buf_recipe no-lock where
            buf_recipe.recipe-code = buf_fbr-line.recipe-code no-error.
            
      find first fbr-recipe no-lock where fbr-recipe.doc-code = buf_fbr-line.doc-code
                                      and fbr-recipe.recipe-code = buf_fbr-line.recipe-code no-error.

/*      find first buf_recipe-gds no-lock where                    */
/*            buf_recipe-gds.recipe-code = buf_fbr-line.recipe-code*/
/*        and buf_recipe-gds.gds-code = buf_gds.gds-code           */
/*        no-error.                                                */
      
      find first buf_fbr-recipe-gds no-lock where buf_fbr-recipe-gds.doc-code = buf_fbr-line.doc-code
                                              and buf_fbr-recipe-gds.recipe-code = buf_fbr-line.recipe-code
                                              and buf_fbr-recipe-gds.prod-type = buf_fbr-line.prod-type
                                              and buf_fbr-recipe-gds.prod-code = buf_fbr-line.prod-code
                                              and buf_fbr-recipe-gds.artic = buf_fbr-line.artic
                                              no-error .
      
      find first buf_doc-line-attr no-lock where buf_doc-line-attr.doc-code = buf_fbr-line.doc-code
                                             and buf_doc-line-attr.gds-code = buf_gds.gds-code
                                             and buf_doc-line-attr.attr-code = "GTIN-qnty"
                                             no-error .
      
      &scop proc-name gds-attr-value
      {&run_proc_attr-lib}
        ( input buf_gds.gds-code
         ,input {&attr-mark-type} 
         ,output v-value
         ,output v-type
        )        no-error .
      if error-status :error
      then do:
        undo, return error return-value .
      end.
      
      define variable brutto as decimal no-undo.
      define variable netto as decimal no-undo.    
      assign
        brutto = buf_fbr-line.fact-qnty
        netto = (buf_fbr-line.fact-qnty / buf_fbr-recipe-gds.recipe-brutto-qnty) * buf_fbr-recipe-gds.recipe-qnty
      .   
      
      sw:start-element ("ingr").
        write-data-element ("dish-code", string-mth (buf_recipe.gds-code)).
        write-data-element ("rcp-code", buf_recipe.recipe-code).
        write-data-element ("ingr-code", string-mth (buf_gds.gds-code)).
        write-data-element ("qnty-b", string-mth (round (brutto, 3))).
        write-data-element ("qnty-n", string-mth (round (netto, 3))).
        write-data-element ("qnty-p", string-mth (round ((brutto - netto), 3))).
        write-data-element ("perc-p", string-mth (round ((buf_fbr-line.coeff-value), 2))).
        write-data-element ("u-price",string-mth (round ((buf_fbr-line.price-rubl), 2))).
        write-data-element ("u-price-s", string-mth (round (buf_fbr-line.price-sum-rubl , 2))).
        if available buf_doc-line-attr
        and buf_doc-line-attr.attr-value > ""
        and not isVarWeight
        then do :
          sw:start-element ("marks").
          GT_ :
          do vGT = 1 to num-entries(buf_doc-line-attr.attr-value, ";") :
            assign
              vGtin = entry(1, entry(vGT, buf_doc-line-attr.attr-value, ";"), "=")
              vQnty = integer(entry(2, entry(vGT, buf_doc-line-attr.attr-value, ";"), "="))
            no-error .
            if error-status:error
            then next GT_ .
            
            sw:start-element ("mark").
/*            write-data-element ("mark-code", "02" + vGtin + "37" + string-mth(vQnty)) .*/
            write-data-element ("gtin", vGtin) .
            write-data-element ("gtin-qnt", string-mth(vQnty)) .
            sw:end-element ("mark").
          end .
          sw:end-element ("marks").
        end .
        if (ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_fbr-doc.obj-type, buf_fbr-doc.obj-code):GetIsEDOForType(v-value) or isVarWeight) and
           can-find(first buf_marking-lines where 
                          buf_marking-lines.gds-code = buf_gds.gds-code
                      and buf_marking-lines.obj-type = buf_fbr-doc.obj-type
                      and buf_marking-lines.obj-code = buf_fbr-doc.obj-code
                      and buf_marking-lines.in-code  = "manufacturing"
                      and buf_marking-lines.out-code = buf_fbr-line.doc-code
                      and buf_marking-lines.part-code = buf_fbr-line.recipe-code
                      and buf_marking-lines.prt-code = 0
                      and buf_marking-lines.doc-level = 1)
        then do :
          sw:start-element ("marks").
          for each buf_marking-lines no-lock where buf_marking-lines.gds-code = buf_gds.gds-code
                                               and buf_marking-lines.obj-type = buf_fbr-doc.obj-type
                                               and buf_marking-lines.obj-code = buf_fbr-doc.obj-code
                                               and buf_marking-lines.in-code  = "manufacturing"
                                               and buf_marking-lines.out-code = buf_fbr-line.doc-code
                                               and buf_marking-lines.part-code = buf_fbr-line.recipe-code
                                               and buf_marking-lines.prt-code = 0
                                               and buf_marking-lines.doc-level = 1
          :
            sw:start-element ("mark").
            write-data-element ("mark-code", repTegforDm( addBracketForCode(buf_marking-lines.mark))).
            sw:end-element ("mark").
          end .
          sw:end-element ("marks").
        end . 
      sw:end-element ("ingr").
          
    end.
    
    sw:end-element ("ingrs").
    
  end.
  
  method private void StartDocFbr ():
      sw:start-element ("trn-gd-doc") .
    { gbl/usrfulnm.i
      buf_fbr-doc.creid
      v-user-name }
      
        write-data-element ("doc-code", buf_fbr-doc.doc-code).
        write-data-element ("doc-num", buf_fbr-doc.doc-code).
        write-data-element ("del-f", string (isDel, "1/0") ).
        write-data-element ("doc-date", if buf_fbr-doc.doc-date = ? then "" else substitute("&1T&2",iso-date(date(buf_fbr-doc.doc-date)), string(buf_fbr-doc.sys-time))).
        write-data-element ("fact-date", if buf_fbr-doc.fact-date = ? then "" else iso-date (date (buf_fbr-doc.fact-date))).
        write-data-element ("doc-type", v-doc-type-ERPRN).
        write-data-element ("operator", v-user-name ).        
        write-data-element ("shift-date", if buf_fbr-doc.shift-date = ? then "" else iso-date (date (buf_fbr-doc.shift-date))).
        write-data-element ("shift-num", if buf_fbr-doc.shift-num = ? then "0" else string-mth (buf_fbr-doc.shift-num)).

  end.

  method private void EndDocFbr ():
    
    sw:end-element ("trn-gd-doc") .
    
  end.

  
  method private void write-data-element (inTag as char, inValue as char):
    
    if inValue = ?
    then do:
      Msg = substitute ('Предупреждение отладки: тег &1 иммет не определнное значение. Работа будет продолжена...', inTag).
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
    then do:
        v-str = "0".
        return v-str.
    end.
    if string (inValue) begins "."
      then v-str = "0" + string (inValue).
      else v-str = string (inValue).
    return v-str.
    
  end.

end class.
