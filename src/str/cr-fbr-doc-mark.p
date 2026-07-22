
/*------------------------------------------------------------------------
    File        : cr-fbr-doc-mark.p
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : SlivenkoSA
    Created     : Thu Sep 19 12:05:13 MSK 2024
    Notes       :
  ----------------------------------------------------------------------*/

/* ***************************  Definitions  ************************** */

block-level on error undo, throw.

{ str/temp_upd.i }
{ str/tt-fbr-line.i }
define input parameter parparentproc    as widget-handle    no-undo .
define input parameter p-fbrhist-handle as widget-handle    no-undo .
define input parameter table for tt-fbr-line .
define input parameter table for tt-marking-lines .
{ gbl/objsrv.i }

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Производство блюд при продаже":U .

{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/cur-time.i }
{ str/doc-code.i }
{ trg/partslib.i }
{ str/writelog.i def "'fbr-mark.log'" no-create }
{ gbl/getcntxt.i def }
{ str/fbrrest.i  }
{ str/fbrlib.i   }
{ str/fbrpln.i   }
{ str/fbradd.i   }
{ str/fbrhist.i  }
{ str/trdcalib.i }
{ str/fbrattr.i  }
{ ref/gds-attr.i }
{ ref/gdsoattr.i }
{ gbl/ggoattr.i  }

define buffer buf_goods for ub.goods .
define buffer buf_fbr-doc for ub.fbr-doc .
define buffer buf_fbr-line for ub.fbr-line .
define buffer buf_marking-lines for ub.marking-lines .
define buffer buf_marking for ub.marking .

define variable v-fbr-doc-code            as character no-undo .
define variable v-fbr-doc-recid           as recid no-undo .
define variable v-same-good               as logical   no-undo.
define variable v-same-good-old-qnty      as decimal   no-undo.
define variable v-reserved                as logical   no-undo.
/* ********************  Preprocessor Definitions  ******************** */


/* ***************************  Main Block  *************************** */
do :
  { gbl/getcntxt.i get}

  run fbrlib_create-fbr-doc ( input v-cntxt-obj-type
                             ,input v-cntxt-obj-code
                             ,input v-cntxt-userid
                             ,output v-fbr-doc-code
                             ,output v-fbr-doc-recid)
  no-error.
  if error-status:error then 
  do:
    undo, return error substitute("Ошибка при создании нового документа производства:&1&2&1&3"
        , {&new-line}
        , error-status:get-message(1)
        , return-value ).
  end.
  
  for each tt-fbr-line,
  first buf_goods no-lock where buf_goods.gds-code = tt-fbr-line.ingr-gds-code
  :
    run create-initial-temp-goods in this-procedure (
        input v-fbr-doc-code
      , input buf_goods.artic
      , input buf_goods.prod-type
      , input buf_goods.prod-code
      , input {&income}
      , input tt-fbr-line.recipe-type
      , input tt-fbr-line.recipe-code
      , input tt-fbr-line.qnty
      , output v-same-good
      , output v-same-good-old-qnty
    ).
    run calc-not-calculated-goods in this-procedure (
        input parparentproc
      , input p-fbrhist-handle
      , input v-fbr-doc-code
      , input v-same-good
      , input v-same-good-old-qnty
      , input no                          /* p-always-select-recipe */
      , input no                          /* p-add-childs           */
      , input v-cntxt-obj-type   /* p-price-sale-obj-type  */
      , input v-cntxt-obj-code   /* p-price-sale-obj-code  */
      , input yes                         /* p-autofbr              */
      , input yes
    ).
  end .
  
  find first buf_fbr-doc no-lock where recid(buf_fbr-doc) = v-fbr-doc-recid .
  
  for each buf_fbr-line no-lock where buf_fbr-line.doc-code = buf_fbr-doc.doc-code
                                  and not buf_fbr-line.is-comp,
  first buf_goods no-lock where buf_goods.artic     = buf_fbr-line.artic
                            and buf_goods.prod-type = buf_fbr-line.prod-type
                            and buf_goods.prod-code = buf_fbr-line.prod-code
  :
    for each tt-marking-lines where tt-marking-lines.gds-code = buf_goods.gds-code :
      create buf_marking-lines .
      assign 
        buf_marking-lines.mark      = tt-marking-lines.mark
        buf_marking-lines.obj-type  = tt-marking-lines.obj-type
        buf_marking-lines.obj-code  = tt-marking-lines.obj-code
        buf_marking-lines.gds-code  = tt-marking-lines.gds-code
        buf_marking-lines.doc-level = tt-marking-lines.doc-level
        buf_marking-lines.in-code   = "manufacturing"
        buf_marking-lines.out-code  = buf_fbr-doc.doc-code
        buf_marking-lines.part-code = buf_fbr-line.recipe-code
        buf_marking-lines.prt-code  = 0
      .
    end .
  end .
  
  run str/fbr-rsrv.p (
       input parparentproc
     , input ?
     , input v-fbr-doc-recid
     , input yes /* p-silent */
     , input yes /* autofbr */
     , input yes
     , input no
     , output v-reserved
     ) no-error.            
  if error-status :error
  or v-reserved = no
  then do:
    message "Ошибка при резервировании товаров для производства. Документ не закрыт!" view-as alert-box .
    return .
  end .
  
  run str/fbr-fact.p ( input parparentproc
                     , input v-fbr-doc-recid
                     , input no                   /* p-silent */
                     ) no-error.
  if error-status :error
  then do:
    message "Не удалось закрыть документ производства!" view-as alert-box .
    return .
  end .

end .