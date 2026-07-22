block-level on error undo, throw.

define variable vss-revision    as character no-undo initial "$Revision: abddb85eb294, 1634, rls $":U .
define variable vss-author      as character no-undo initial "$Author: EShklyar $":U .
define variable vss-date        as character no-undo initial "$Date: Mon Nov 19 15:15:34 2018 +0300 $":U .
define variable vss-workfile    as character no-undo initial "$Workfile: rvs-close.p $":U .
define variable vss-archive     as character no-undo initial "$Archive: str/rvs-close.p $":U .
define variable vss-description as character no-undo initial "Список документов сверки":U .
{ cmp/vssrevis.i }
define input  parameter mutil    as class ibs.th.utl.method-for-draw-utility no-undo.
define input  parameter iRvsCode as character no-undo.
 
define variable parparentproc as handle no-undo.
parparentproc = mutil:parparentproc.
{cmp/str-glbl.i}
{ ref/gds-attr.i }
{ cmp/library.i  }

{ str/is-gas.i }
{ str/placelib.i } 
{ cmp/gds-list.i gds-list def }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get }
{ str/lib-rvs.i  }

define buffer r-doc for ub.rvs-doc.
define buffer buf-inv_trn-doc for ub.trn-doc .
define buffer buf-spi_trn-doc for ub.trn-doc .
define variable varlog as logical no-undo.
define variable varstr as character no-undo.
define variable v-value as character no-undo.
define variable v-ok as logical no-undo.
define variable is-vir as logical no-undo.
define buffer open-shift         for ub.shift-obj .
find first r-doc where r-doc.rvs-code eq iRvsCode 
no-lock no-error.
if available r-doc
then do:
        define variable varchg-inv as logical   no-undo.
        define variable v-inv-doc  as character no-undo .

        {&no-rvs}
  if r-doc.status_ = {&fact}
    or r-doc.status_ = {&rvs-froze}
  then do:
        message
            "Данный документ сверки закрыт по факту или не может быть обработан в этом списке."
            view-as alert-box.
        return no-apply.
    end.
if r-doc.status_ = {&g___new} then 
do:
    assign
        varlog = no
        .
   /* message
        "Вы хотите завершить редактирование документа сверки?"
        view-as alert-box question buttons yes-no update varlog .
    if varlog <> yes then 
    do:
        return no-apply.
    end.*/
    tr:
    do transaction
        on error   undo tr, leave
        on end-key undo tr, leave
        on stop    undo tr, leave
        :
       /* find last open-shift where
            open-shift.obj-type = v-cntxt-obj-type and
            open-shift.obj-code = v-cntxt-obj-code and
            open-shift.status_ = {&sht-current}
            use-index pi no-error.
        open-shift.close-time = time.*/      
        { str/rvsclose.i
        parparentproc
        recid(r-doc)
        yes
        no-error
      }
   
      if error-status :error then do:
       
        message
          "Ошибка при закрытии документа сверки." skip
          error-status:get-message(1) skip
          return-value
          view-as alert-box error.
        //run userlogrvs(58, return-value + error-status:get-message(1) ) .
        undo tr, leave.
      end.
    end.
end.
else 
do:
    find first buf-inv_trn-doc no-lock
        where buf-inv_trn-doc.out-code = r-doc.rvs-code
        no-error.
    if ambiguous buf-inv_trn-doc then 
    do:
        message
            "Найдено более одного складского документа связанного со сверкой."
            view-as alert-box error.
        return no-apply.
    end.
    if available buf-inv_trn-doc then 
    do:
        if buf-inv_trn-doc.doc-type <> {&inventory} then 
        do:
            message
                "Документ связанный с документом сверки не яв-ся инвентаризацией."
                view-as alert-box error.
            return no-apply.
        end.
        if buf-inv_trn-doc.status_ <> {&doc-froze}
            or buf-inv_trn-doc.flag_ <> yes
            then 
        do:
            message
                substitute( "Ошибка в документе инвентаризации &1 по сверке.", buf-inv_trn-doc.doc-code ) skip
                substitute( "Связанный со сверкой документ инвентаризации не находится в статусе &1", {&doc-froze} )
                view-as alert-box error.
            return no-apply.
        end.
        assign
            varstr    = " документ инвентаризации"
            v-inv-doc = buf-inv_trn-doc.doc-code
            .
    end.
    assign
        varlog = no
        .
   /* message
        substitute( "Вы хотите закрыть документ сверки &1?", (if varstr <> "" then "и" else "") + varstr )
        view-as alert-box question buttons yes-no update varlog.
    if varlog <> yes then 
    do:
        return no-apply.
    end.
*/
    find first ub.rvs-line no-lock
        where ub.rvs-line.rvs-code           = r-doc.rvs-code
        and ub.rvs-line.state-measure-qnty = ?
        no-error.
    if available ub.rvs-line then 
    do:
        find first ub.goods no-lock
            where ub.goods.gds-code = ub.rvs-line.gds-code.
      
        run placelib_get-attr(input {&place-virtual}
            ,input rvs-line.obj-code
            ,input rvs-line.obj-type
            ,input rvs-line.pl-code
            ,output v-value
            ,output v-ok) no-error.

        is-vir = if (v-ok and logical(v-value)) then true else false.
  
        if not is-gas(ub.rvs-line.gds-code) and not is-vir then 
        do:
            message
                substitute( "Не заданы фактические остатки по товару &1 (&2)", ub.goods.gds-code, ub.goods.gds-name )
                view-as alert-box error.
            return no-apply.
        end.
    end.
    tr:
    do transaction
        on error   undo tr, leave
        on end-key undo tr, leave
        on stop    undo tr, leave
        :
        find last open-shift where
            open-shift.obj-type = v-cntxt-obj-type and
            open-shift.obj-code = v-cntxt-obj-code and
            open-shift.status_ = {&sht-current}
            use-index pi no-error.
        open-shift.close-time = time.  
        { str/rvsclose.i
        parparentproc
        recid(r-doc)
        no
        no-error
      }
        if error-status :error then 
        do:
            mutil:put-log( return-value + error-status:get-message(1) ) .
            message
                "Ошибка при закрытии документа сверки." skip
                error-status:get-message(1) skip
                return-value
                view-as alert-box error.
            undo tr, leave.
        end.

        release r-doc no-error .
        if error-status :error then 
        do:
            message
                "Ошибка при закрытии документа сверки." skip
                error-status:get-message(1) skip
                return-value
                view-as alert-box error.
            undo tr, leave.
        end.

        /* Закрытие инвентаризации */
        find first buf-inv_trn-doc exclusive-lock
            where buf-inv_trn-doc.doc-code = v-inv-doc
            no-error.
        if available buf-inv_trn-doc then 
        do:
            assign
                buf-inv_trn-doc.status_ = {&permitted}
                buf-inv_trn-doc.flag_   = yes
                .
            run str/trn-stat.p
                ( input parparentproc
                , input this-procedure
                , input {&close-doc}
                , input v-inv-doc
                , input ?
                , input v-cntxt-db-num
                , input ?
                , input ?
                , input ?
                , input ?
                , input yes
                , output varchg-inv
                , output table gds-list
                ) no-error.
            if error-status :error then 
            do:
                message
                    "Не удалось закрыть инвентаризацию." skip
                    return-value                         skip
                    error-status :get-message(1)         skip
                    view-as alert-box error.
                undo tr, leave.
            end.
            release buf-inv_trn-doc no-error .
            if error-status :error then 
            do:
                message
                    "Ошибка при закрытии документа интвентаризации." skip
                    error-status:get-message(1) skip
                    return-value
                    view-as alert-box error.
                undo tr, leave.
            end.

            find first buf-spi_trn-doc exclusive-lock
                where buf-spi_trn-doc.out-code = v-inv-doc
                and buf-spi_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}
                no-error .
            /* Закрытие списания */
            if available buf-spi_trn-doc then 
            do:
                assign
                    buf-spi_trn-doc.status_ = {&permitted}
                    buf-spi_trn-doc.flag_   = yes
                    .
                run str/trn-stat.p
                    ( input parparentproc
                    , input this-procedure
                    , input {&close-doc}
                    , input buf-spi_trn-doc.doc-code
                    , input ?
                    , input v-cntxt-db-num
                    , input ?
                    , input ?
                    , input ?
                    , input ?
                    , input yes
                    , output varchg-inv
                    , output table gds-list
                    ) no-error.
                if error-status :error then 
                do:
                    message
                        "Не удалось закрыть документ списания." skip
                        return-value                            skip
                        error-status:get-message(1)             skip
                        view-as alert-box error.
                    undo tr, leave.
                end.
                release buf-spi_trn-doc no-error .
                if error-status :error then 
                do:
                    message
                        "Ошибка при закрытии документа списания." skip
                        error-status:get-message(1) skip
                        return-value
                        view-as alert-box error.
                    undo tr, leave.
                end.
            end.
        end.
    end.
end.
    
end.


 