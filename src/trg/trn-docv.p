block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Дополнительные проверки по документу перед отсылкой по новостям

Автор: Чернова Светлана Александровна
Дата создания: 10/03/07
Author: Svetlana Chernova
Creation date: 10/03/07

*/
using ibs.th.str.alcohol.*.
using ibs.th.gbl.sys.*.

define input  parameter p-doc-code  like ub.trn-doc.doc-code no-undo .
define output parameter p-err       as logical   no-undo .
define output parameter p-mess      as character no-undo .

define variable chg-qnty      as   decimal no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Дополнительные проверки по документу перед отсылкой по новостям".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ str/lib-trn.i  }
{ trg/trndocrs.i }
{ trg/partrqst.i }
{ str/hvrdtax.i  }
{ gbl/key-rec.i  }
{ trg/partcopy.i }
{ trg/partrsrv.i }
{ ref/gds-attr.i }
p-err = false .
p-mess = "" .

define buffer buf_trn-doc  for ub.trn-doc .
define buffer buf_doc-line for ub.doc-line .
define buffer buf_parts    for ub.parts .
define buffer buf_gds-dtl  for ub.gds-dtl .

define variable v-place-rsrv        as logical   no-undo .
define variable v-need-rsrv         as logical   no-undo .
define variable v-root-node         as integer   no-undo .
define variable v-goods-serial      as logical   no-undo .
define variable v-goods-twounit     as logical   no-undo .
define variable v-parts-rsrv-qnty   as decimal   no-undo .
define variable v-total-rsrv-qnty   as decimal   no-undo .
define variable v-gds-dtl-rsrv-qnty as decimal   no-undo .
define variable v-real-chg-qnty     as decimal   no-undo .
define variable v-parts-recid       as integer   no-undo .
define variable v-is-hold           as integer   no-undo .
define variable v-gds-attr-value-old as character no-undo .
define variable v-gds-attr-type      as character no-undo .
    
define variable v-doc-qnty as decimal   no-undo .
define variable v-fact-qnty as decimal   no-undo .
{ gbl/objsrv.i }

define variable v-fact-qnty-p as decimal   no-undo .
define variable v-doc-qnty-p as decimal   no-undo .
do
on error undo, return error return-value
:
  find first buf_trn-doc exclusive-lock
    where buf_trn-doc.doc-code = p-doc-code
    no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" p-doc-code skip
      view-as alert-box error .
    undo, return error .
  end.

  if buf_trn-doc.status_ = {&inquiry}
  or buf_trn-doc.status_ = {&ready}
  or buf_trn-doc.status_ = {&rejected}
    then do:
    /* для запросов не нужно производить резервирование */
    return .
  end.

  if buf_trn-doc.doc-type = {&inventory}  then return  .

  { gbl/hold-doc.i
    buf_trn-doc.doc-code
    v-is-hold
  }


  for each buf_doc-line exclusive-lock
    where buf_doc-line.doc-code = buf_trn-doc.doc-code
  on error undo, return error
  :

  /* статусы строк должны быть как у шапки */
   if buf_doc-line.status_ <> buf_trn-doc.status_ then do:
      buf_doc-line.status_   = buf_trn-doc.status_  .
   end.

    { gbl/rootnode.i
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      v-root-node
      no-error
    }
    if error-status :error then do:
        p-mess = substitute("&1 &2 &3 &4 &5 &6 &7 &8 &9",
       "Ошибка при определении корневого признака товара Документ" ,
        buf_doc-line.doc-code ,
        buf_trn-doc.ext-doc-type,
        "Артикул"               ,
        buf_doc-line.artic      ,
        buf_doc-line.prod-type  ,
        buf_doc-line.prod-code  ,
        error-status :get-message(1) ,
        return-value  ) .
        p-err = true .
        return .
    end.

    define buffer buf_gds-obj for ub.gds-obj .
    define buffer buf_prt-obj for ub.prt-obj .

    { gbl/gdscheck.i
      buf_doc-line.obj-type
      buf_doc-line.obj-code
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      v-root-node
      "''"
      no-error
    }
    if error-status :error then do:
        p-mess = substitute("&1 &2 &3 &4 &5 &6 &7 &8",
        "Ошибка при проверке целостности товара" ,
        buf_doc-line.obj-type ,
        buf_doc-line.obj-code       ,
        buf_doc-line.artic ,
        buf_doc-line.prod-type ,
        buf_doc-line.prod-code ,
        error-status :get-message(1) ,
        return-value ).
        p-err = true .
        return.
    end.

    { gbl/gdsat.i
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      'serial=request':u
      v-goods-serial
      no-error
    }
    if error-status :error then do:
        p-mess =
        "Ошибка при определении атрибута товара Товар серийный" +
        error-status :get-message(1) +
        return-value .

        p-err = true .
        return.
    end.

    { gbl/gdsat.i
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      'twounit=request':u
      v-goods-twounit
      no-error
    }
    if error-status :error then do:
        p-mess = "Ошибка при определении атрибута товара Двойная единица измерения" +
        error-status :get-message(1) +
        return-value .
        p-err = true .
        return.
    end.

    { gbl/gdsobjat.i
      buf_doc-line.obj-type
      buf_doc-line.obj-code
      buf_doc-line.artic
      buf_doc-line.prod-type
      buf_doc-line.prod-code
      "'place-rsrv=request'"
      v-place-rsrv
      no-error
    }

    if error-status :error then do:
        p-mess = "Ошибка при определении атрибута на объекта" +
        error-status :get-message(1) +
        return-value .
        p-err = true .
        return.
    end.
    /* Проверки по партиям */
    v-fact-qnty-p = 0 .
    v-doc-qnty-p = 0 .
    for each buf_parts no-lock
      where buf_parts.obj-type  = buf_doc-line.obj-type
        and buf_parts.obj-code  = buf_doc-line.obj-code
        and buf_parts.artic     = buf_doc-line.artic
        and buf_parts.prod-type = buf_doc-line.prod-type
        and buf_parts.prod-code = buf_doc-line.prod-code
        and buf_parts.out-code  = buf_doc-line.doc-code :
        v-doc-qnty-p  = v-doc-qnty-p + buf_parts.qnty .
        v-fact-qnty-p = v-fact-qnty-p + buf_parts.fact-qnty .
    end.
    v-fact-qnty = 0 .
    v-doc-qnty = 0 .

    for each buf_gds-dtl no-lock
      where buf_gds-dtl.artic     = buf_doc-line.artic
        and buf_gds-dtl.prod-type = buf_doc-line.prod-type
        and buf_gds-dtl.prod-code = buf_doc-line.prod-code
        and buf_gds-dtl.doc-code  = buf_doc-line.doc-code :
        v-fact-qnty = v-fact-qnty + buf_gds-dtl.fact-qnty .
        v-doc-qnty  = v-doc-qnty + buf_gds-dtl.doc-qnty .
    end.

    find first ub.goods no-lock where ub.goods.artic = buf_doc-line.artic and ub.goods.prod-code = buf_doc-line.prod-code and ub.goods.prod-type = buf_doc-line.prod-type no-error .
    if available (ub.goods) then do:
        run gds-attr-value (
                        INPUT ub.goods.gds-code,
                        INPUT {&attr-mark-type},
                        OUTPUT v-gds-attr-value-old,
                        OUTPUT v-gds-attr-type
                        ).
    end.
    find first goods no-lock where goods.artic = buf_doc-line.artic
                               and goods.prod-type = buf_doc-line.prod-type
                               and goods.prod-code = buf_doc-line.prod-code
                               .

    find first doc-fbr-gds no-lock where (doc-fbr-gds.out-code = buf_doc-line.doc-code or
                                          doc-fbr-gds.out-code = replace(buf_doc-line.doc-code, "=", "-") ) 
                                     and doc-fbr-gds.gds-code = goods.gds-code
                                     no-error .
    if available doc-fbr-gds
    then do :
if buf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Perem} and not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_doc-line.obj-type, buf_doc-line.obj-code):GetIsMarkingForType(v-gds-attr-value-old) then do:
      if v-fact-qnty-p <> v-doc-qnty  and v-fact-qnty-p <> 0 then do:
          p-mess = "В документе не соответствует количество по партиям и признакам для производства (fact) !!!"   .
          p-err = true .
          return.
      end.
end.
      if v-doc-qnty-p <> v-doc-qnty and v-doc-qnty-p <> 0 then do:
          p-mess = "В документе не соответствует количество по партиям и признакам для производства (doc) !!!" .
          p-err = true .
          return.
  
      end.
if buf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Perem} and not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_doc-line.obj-type, buf_doc-line.obj-code):GetIsMarkingForType(v-gds-attr-value-old) then do:

      if v-fact-qnty <> buf_doc-line.fact-qnty and v-fact-qnty-p <> 0 then do:
          p-mess = "В документе не соответствует количество по партиям и строкам для производства (fact)!!!" .
          p-err = true .
          return.
  
      end.
end.
      if v-doc-qnty <> buf_doc-line.doc-qnty and v-doc-qnty-p <> 0 then do:
          p-mess = "В документе не соответствует количество по признакам и строкам для производства (doc)!!!" .
          p-err = true .
          return.
      end.
    end.                                         
    else do :
      if buf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Perem} and not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_doc-line.obj-type, buf_doc-line.obj-code):GetIsMarkingForType(v-gds-attr-value-old) then do:

      if v-fact-qnty-p <> v-fact-qnty  and v-fact-qnty-p <> 0 then do:
          p-mess = "В документе не соответствует количество по партиям и признакам (fact) !!!"   .
          p-err = true .
          return.
      end.
     end. 
      if v-doc-qnty-p <> v-doc-qnty and v-doc-qnty-p <> 0 then do:
          p-mess = "В документе не соответствует количество по партиям и признакам (doc) !!!" .
          p-err = true .
          return.
  
      end.
if buf_trn-doc.ext-doc-type <> {&TDEDT_Pri_Perem} and not ObjSrv:Env:ParametrsOfSection:GetSectionEDO(buf_doc-line.obj-type, buf_doc-line.obj-code):GetIsMarkingForType(v-gds-attr-value-old) then do:

      if v-fact-qnty <> buf_doc-line.fact-qnty and v-fact-qnty-p <> 0 then do:
          p-mess = "В документе не соответствует количество по партиям и строкам (fact)!!!" .
          p-err = true .
          return.
  
      end.
end.
      if v-doc-qnty <> buf_doc-line.doc-qnty and v-doc-qnty-p <> 0 then do:
          p-mess = "В документе не соответствует количество по признакам и строкам (doc)!!!" .
          p-err = true .
          return.
      end.
    end.
  end.
end.