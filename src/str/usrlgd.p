block-level on error undo, throw.
/*

$Revision: 2facc70d13d4, 1596, rls $
$Author: SPalagin $
$Date: Tue Nov 06 04:41:37 2018 +0300 $
$Workfile: usrlgd.p $
$Archive: str/usrlgd.p $

Вызов истории по документу из истории пользовател

Автор: Гюнтнер Виктор Арнольдович
Дата создания: 05/08/08
Author: Victor Guntner
Creation date: 05/08/08

Input:

Output:

*/
define input parameter parparentproc    as handle           no-undo.
define input parameter p-table-name     as character        no-undo.
define input parameter p-unique-key-rec as character        no-undo.

define variable vss-revision    as character no-undo init "$Revision: 2facc70d13d4, 1596, rls $":U .
define variable vss-author      as character no-undo init "$Author: SPalagin $":U .
define variable vss-date        as character no-undo init "$Date: Tue Nov 06 04:41:37 2018 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: usrlgd.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/usrlgd.p $":U .
define variable vss-description as character no-undo init "Вызов истории по документу из истории пользователя".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ gbl/key-rec.i  }
{ adm/cnf-inc.i &new="new"}
define variable v-list             as character no-undo.
define variable v-field-list       as character no-undo.
define variable v-field-value-list as character no-undo.
do
    on error undo, return error
    :
    run gen-key-fv in this-procedure (
        input p-unique-key-rec
        , output v-field-list
        , output v-field-value-list
        ).
        
    case p-table-name
        :
        when "c-fbr-doc":U or when "fbr-doc"
        then 
            do:
                run str/fbrdocsh.w (
                    input parparentproc
                    , input entry( 1, v-field-value-list, {&delim-key} )
                    ) no-error .
            end.        /* when "fbr-doc":U */
        when "c-sht-hist":U
        then 
            do:
                DEFINE VARIABLE v-rid-list AS CHARACTER NO-UNDO.    
                run ref/cshthist.w (
                    INPUT parParentProc
                    ,input ''
                    ,input ?
                    ,input '':U /* bttns  */
                    ,input 'one':U /*p-mode  */
                    ,INPUT entry( 1, v-field-value-list, {&delim-key} )
                    ,INPUT entry( 2, v-field-value-list, {&delim-key} )
                    ,INPUT entry( 3, v-field-value-list, {&delim-key} )
                    ,INPUT entry( 4, v-field-value-list, {&delim-key} )
                    ,INPUT '':U /*p-subject*/
                    ,INPUT-OUTPUT v-list) NO-ERROR.
            end.
        when "c-trn-doc" then 
            do:
                define variable doc-rec as recid no-undo .
                find first ub.c-trn-doc where ub.c-trn-doc.doc-code = entry( 1, v-field-value-list, {&delim-key} ) no-error.
                if AVAILABLE (ub.c-trn-doc) then 
                do:
                    doc-rec = recid(ub.c-trn-doc) .
                    run str/calldocs.w
                        (input parparentproc
                        ,input "doc" /*parlist-mode*/
                        ,input "" /*parstat*/
                        ,input "" /*partype*/
                        ,input ? /*parflag*/
                        ,input no /*parinternal*/
                        ,input '':U /*bttns*/
                        ,input ub.c-trn-doc.doc-code /*parext-doc-type*/
                        ,input ? /*paris-hold*/
                        ,input doc-rec
                        ,input ub.c-trn-doc.obj-type
                        ,input ub.c-trn-doc.obj-code
                        ,output v-list
                        ) no-error .

                end.
            end.
        when "trn-doc" or when "c-trn-doc" then 
            do:
                find first ub.trn-doc where ub.trn-doc.doc-code = entry( 1, v-field-value-list, {&delim-key} ) no-error.
                if AVAILABLE (ub.trn-doc) then 
                do:
                    doc-rec = recid(ub.trn-doc) .
                    run str/calldocs.w
                        (input parparentproc
                        ,input "doc" /*parlist-mode*/
                        ,input "" /*parstat*/
                        ,input "" /*partype*/
                        ,input ? /*parflag*/
                        ,input no /*parinternal*/
                        ,input '':U /*bttns*/
                        ,input ub.trn-doc.doc-code /*parext-doc-type*/
                        ,input ? /*paris-hold*/
                        ,input doc-rec
                        ,input ub.trn-doc.obj-type
                        ,input ub.trn-doc.obj-code
                        ,output v-list
                        ) no-error .

                end.
            end.   
        when "rvs-doc" or when "c-rvs-doc" then 
            do:
                    run str/rvscdocs.w 
                    (   input        parparentproc,
                        input        "":U,
                        input        "one":U,
                        input        entry( 1, v-field-value-list, {&delim-key} ),
                        input-output v-list                  ) 
                        no-error .
        end.       
        when "c-inkas" then 
            do:
                find first ub.c-inkas where ub.c-inkas.inkas-code = entry( 1, v-field-value-list, {&delim-key} ) no-error.
                if AVAILABLE (ub.c-inkas) then 
                do:
                    run str/salclist.w (
                        input parparentproc
                        ,input '':U /*bttns  */
                        ,input 'one':U
                        ,input ub.c-inkas.inkas-code
                        ,input ub.c-inkas.host-code
                        ,input ub.c-inkas.obj-type
                        ,input ub.c-inkas.obj-code
                        ,input-output v-list    ) no-error .
                end.
            end.          
        when "c-price-doc" then 
            do:
                find first ub.c-price-doc where ub.c-price-doc.doc-num = entry( 1, v-field-value-list, {&delim-key} ) no-error.
                if AVAILABLE (ub.c-price-doc) then 
                do:
                    run str/pr-cdoc.w ( parParentProc, ub.c-price-doc.host-code, ub.c-price-doc.doc-num ) no-error.
                end.
            end.
        when "price-doc" then 
            do:
                find first ub.price-doc where ub.price-doc.doc-num = entry( 1, v-field-value-list, {&delim-key} ) no-error.
                if AVAILABLE (ub.price-doc) then 
                do:
                    run str/pr-cdoc.w ( parParentProc, ub.price-doc.host-code, ub.price-doc.doc-num ) no-error.
                end.
            end.    
        when "c-chk-doc" then 
            do:
                find first ub.c-chk-doc where ub.c-chk-doc.doc-code = entry( 1, v-field-value-list, {&delim-key} ) no-error.
                if AVAILABLE (ub.c-chk-doc) then 
                do:
                    run str/cchkdocs.w (
                        input parparentproc
                        , "":U /*bttns*/
                        , "one":U
                        , ub.c-chk-doc.doc-code
                        , ub.c-chk-doc.obj-type
                        , ub.c-chk-doc.obj-code
                        , input-output v-list
                        ) no-error.
        
                end.
            end.  
        when "chk-doc" then 
            do:
                find first ub.chk-doc where ub.chk-doc.doc-code = entry( 1, v-field-value-list, {&delim-key} ) no-error.
                if AVAILABLE (ub.chk-doc) then 
                do:
                    run str/cchkdocs.w (
                        input parparentproc
                        , "":U /*bttns*/
                        , "one":U
                        , ub.chk-doc.doc-code
                        , ub.chk-doc.obj-type
                        , ub.chk-doc.obj-code
                        , input-output v-list
                        ) no-error.
        
                end.
                else 
                do:
                    find first ub.c-chk-doc where ub.c-chk-doc.doc-code = entry( 1, v-field-value-list, {&delim-key} ) no-error.
                    if AVAILABLE (ub.c-chk-doc) then 
                    do:
                        run str/cchkdocs.w (
                            input parparentproc
                            , "":U /*bttns*/
                            , "one":U
                            , ub.c-chk-doc.doc-code
                            , ub.c-chk-doc.obj-type
                            , ub.c-chk-doc.obj-code
                            , input-output v-list
                            ) no-error.
        
                    end.
                end.    
            end.
        when "price-doc-forming" or 
        when "c-price-doc-forming" then 
            do:
                run ref/cpr-form.w
                    ( parParentProc 
                    ,entry( 1, v-field-value-list, {&delim-key} )
                    ,entry( 2, v-field-value-list, {&delim-key} )
                    ,entry( 3, v-field-value-list, {&delim-key} )
                    ,entry( 4, v-field-value-list, {&delim-key} )

                    ) no-error.
  
            end.
        when "cash-pay" then 
            do:
                run ref/ccashpay.w (
                    input parparentproc
                    , INPUT "":U /*bttns*/
                    , INPUT "one":U /*parref-mode*/
                    , OUTPUT  v-list
                    , INPUT integer(entry( 1, v-field-value-list, {&delim-key} ))
                    , INPUT integer(entry( 2, v-field-value-list, {&delim-key} ))
                    , input "":U /*p-subject*/
                    ) no-error .
            end.
        when "goods" then 
            do:
                run ref/cgdshisth.w (
                    input parparentproc
                    , input "":U /*bttns*/
                    , input "one":U /*p-mode*/
                    , input integer(entry(1, v-field-value-list, {&delim-key}))
                    , input ? /*p-host-code*/
                    , input ? /*p-obj-type*/
                    , input ? /*p-obj-code*/
                    , input ? /* p-corr-user-db-num  */
                    , input "":U /* p-corr-user-name  */
                    , input "":U /* p-subject  */
                    , input-output v-list  ) no-error .
            end.
        when "place" then 
            do:
        
                run ref/cplchist.w
                    ( input parparentproc
                    , input entry(1, v-field-value-list, {&delim-key})
                    , input integer(entry(2, v-field-value-list, {&delim-key}))
                    , input "":u /*bttns  */
                    , input "one":u /*p-mode*/
                    , input entry(1, v-field-value-list, {&delim-key})
                    , input integer(entry(2, v-field-value-list, {&delim-key}))
                    , input integer(entry(3, v-field-value-list, {&delim-key}))
                    , input 0 /*p-gds-code*/
                    , input 0 /*p-pump-code*/
                    , input 0 /*p-nozzle-code*/
                    , input '':u /*p-subject*/
                    , input-output v-list
                    ) no-error .
        
            end.  
        when "cli-grp" then 
            do:
                run ref/ccgrphis.w (
                    input parparentproc
                    ,INPUT "":U /* bttns */
                    ,INPUT "cli-grp":U /*parref-mode */
                    ,INPUT integer(entry(1, v-field-value-list, {&delim-key}))
                    ,INPUT yes /*p-is-del*/
                    ,OUTPUT v-list
                    ) .
            end.  
        when "clients" then 
            do:
                run ref/cclihisth.w (
                    input parparentproc
                    , input 0 /*p-curr-host-code*/
                    , input "":U  /*p-curr-obj-type*/
                    , input 0  /*p-curr-obj-code*/
                    , input "":U /*bttns*/
                    , "one":U /*p-mode*/
                    , input entry(1, v-field-value-list, {&delim-key}) /*p-obj-type*/
                    , input integer(entry(2, v-field-value-list, {&delim-key})) /*p-obj-code*/
                    , input ? /*p-host-code*/
                    , input ? /* p-corr-user-db-num  */
                    , input "":U /* p-corr-user-name  */
                    , input "":U /* p-subject  */
                    , input-output v-list  ) no-error .
            end.  
        when "units" then 
            do:
                run ref/c-units.w (
                    INPUT parparentproc
                    ,INPUT '':U /*bttns*/
                    ,INPUT 'one':U
                    ,INPUT entry(1, v-field-value-list, {&delim-key})
                    ,INPUT-OUTPUT v-list) NO-ERROR.
            end.  
        when "dis-card-type" then 
            do:
                run ref/dcctypes.w (
                    input parparentproc
                    ,input '':U
                    ,input  ?
                    ,input  integer(entry(1, v-field-value-list, {&delim-key}))
                    ,input  integer(entry(3, v-field-value-list, {&delim-key}))
                    ,input  entry(4, v-field-value-list, {&delim-key})
                    ,input  integer(entry(5, v-field-value-list, {&delim-key}))
                    ,input  entry(2, v-field-value-list, {&delim-key})
                    ,input "one":U
                    ,input '':U /*subject*/
                    ,output v-list ) no-error.
            end.  
        when "dis-card" then 
            do:
                find first ub.dis-card where ub.dis-card.d-card = entry(1, v-field-value-list, {&delim-key}) no-error .
                if AVAILABLE (ub.dis-card) then 
                do:
                    run ref/cdchisth.w (
                        INPUT parparentproc
                        ,input "":U
                        ,input "one":U
                        ,input ub.dis-card.d-card
                        ,input ub.dis-card.card-num
                        ,input ? /*p-corr-user-db-num */
                        ,input "":U /*p-corr-user-name */
                        ,input "":U /*p-subject*/
                        ,input ? /*p-db-num */
                        /*записи в выборке*/
                        ,input-output v-list
                        ) no-error .
                end.
            end.  
        when "cash-desk" then 
            do:
                run ref/ccshlist.w (
                    input parparentproc
                    , INPUT "":U /*bttns*/
                    , INPUT {&all} /*parref-mode*/
                    , OUTPUT  v-list
                    , INPUT integer(entry(1, v-field-value-list, {&delim-key}))
                    , INPUT {&shop}
                    , INPUT integer(entry(2, v-field-value-list, {&delim-key}))
                    , input entry(3, v-field-value-list, {&delim-key})
                    , input integer(entry(4, v-field-value-list, {&delim-key}))
                    , input "":U /*p-subject*/
                    ) no-error.
            end. 
        when "gds-grp" then 
            do:
                find first ub.gds-grp no-lock where ub.gds-grp.node-code = integer(entry(1, v-field-value-list, {&delim-key})) no-error .
                if AVAILABLE (ub.gds-grp) then 
                do:
                    run ref/cggrphis.w (
                        input parparentproc
                        ,INPUT "":U /* bttns */
                        ,INPUT "gds-grp":U /*parref-mode */
                        ,INPUT integer(entry(1, v-field-value-list, {&delim-key}))
                        , "":U /*p-attr-code*/
                        , INPUT 0
                        , INPUT "":U /*p-obj-type*/
                        , INPUT 0 /*p-obj-code*/
                        , INPUT 0 /*p-tax-code*/
                        , INPUT NO
                        ,input "":U /*p-subject*/
                        ,OUTPUT v-list
                        ) .
                end.
                else 
                do:
                    run ref/cggrphis.w (
                        input parparentproc
                        ,INPUT "":U /* bttns */
                        ,INPUT "gds-grp":U /*parref-mode */
                        ,INPUT integer(entry(1, v-field-value-list, {&delim-key}))
                        , "":U /*p-attr-code*/
                        , INPUT 0
                        , INPUT "":U /*p-obj-type*/
                        , INPUT 0 /*p-obj-code*/
                        , INPUT 0 /*p-tax-code*/
                        , INPUT yes
                        ,input "":U /*p-subject*/
                        ,OUTPUT v-list
                        ) .
                end.    
            end.
        when "thbj-attr" then 
            do:
                run ref/cthbjatrh.w (
                    input parparentproc
                    ,input '' /*bttns*/
                    ,input "section" /*p-mode*/
                    ,input entry(1, v-field-value-list, {&delim-key})
                    ,input integer(entry(2, v-field-value-list, {&delim-key}))
                    ,input entry(3, v-field-value-list, {&delim-key})
                    ,input entry(4, v-field-value-list, {&delim-key})
                    ,input ? /* p-corr-user-db-num  */
                    ,input "":U /* p-corr-user-name  */
                    ,input "":U /* p-subject  */
                    ,input-output v-rid-list  ) no-error .
            end.   
        when "pl-gds" then 
            do:

                run ref/cplchisth.w (
                    INPUT parParentProc
                    , input "":U /*bttns  */
                    , input "subject":U /*p-mode*/
                    , input entry(1, v-field-value-list, {&delim-key})
                    , input INTEGER (entry(2, v-field-value-list, {&delim-key}))
                    , input INTEGER (entry(3, v-field-value-list, {&delim-key}))
                    , input INTEGER (entry(4, v-field-value-list, {&delim-key})) /*p-gds-code*/
                    , input 0 /*p-pump-code*/
                    , input 0 /*p-nozzle-code*/
                    , input {&table_pl-gds} /*p-subject*/
                    , input-output v-list
                    ) no-error .
            end.  
        when "pl-gds-pump" then
            do:
                run ref/cplchisth.w (
                    INPUT parParentProc
                    , input "":U /*bttns  */
                    , input "subject":U /*p-mode*/
                    , input entry(1, v-field-value-list, {&delim-key})
                    , input INTEGER (entry(2, v-field-value-list, {&delim-key}))
                    , input INTEGER (entry(5, v-field-value-list, {&delim-key}))
                    , input INTEGER (entry(3, v-field-value-list, {&delim-key})) /*p-gds-code*/
                    , input INTEGER (entry(4, v-field-value-list, {&delim-key})) /*p-pump-code*/
                    , input 0 /*p-nozzle-code*/
                    , input {&table_pl-gds-pump} /*p-subject*/
                    , input-output v-list
                    ) no-error .
            end.
        when "staff" then 
            do:
                run ref/cstaffsh.w (
                    input parparentproc
                    , input "":U /*bttns*/
                    , "one":U /*p-mode*/
                    , input entry(1, v-field-value-list, {&delim-key})
                    , input entry(2, v-field-value-list, {&delim-key})
                    , input entry(3, v-field-value-list, {&delim-key})
                    , input integer(entry(4, v-field-value-list, {&delim-key}))
                    , input date(entry(5, v-field-value-list, {&delim-key}))
                    , input-output v-list  ) no-error .
            end.    
        when "fin-bank" then 
            do:
                run ref/fincbnksh.w
                    (
                    input parParentProc
                    ,input "":U /*bttns*/
                    ,input "one":U
                    ,input integer(entry(1, v-field-value-list, {&delim-key}))
                    ,input integer(entry(2, v-field-value-list, {&delim-key}))
                    ,input-output v-list
                    ) no-error .
            end.    
        when "ord-doc" then 
            do:
                run cus/ordcdoch.w
                    (
                    parParentProc,
                    entry(1, v-field-value-list, {&delim-key}),
                    "" ) .
            end.           
        when "auto-tank" then 
            do:
                run str/c-auto-tn.w (
                    INPUT parParentProc
                    ,input '':U /*bttns*/
                    ,input 'one':U /*p-mode*/
                    ,INPUT entry(1, v-field-value-list, {&delim-key})
                    ,INPUT-OUTPUT v-rid-list) NO-ERROR.
            end.                   
        when "config" then 
            do:
                find first ub.config where ub.config.param-code = entry(1, v-field-value-list, {&delim-key}) no-error .
                if AVAILABLE (ub.config) then 
                do:
                    create cnf .
                    buffer-copy ub.config to cnf .
                    assign
                        cnf.param-name = entry(1, v-field-value-list, {&delim-key})
                        cnf.host-code  = integer(entry(2, v-field-value-list, {&delim-key}))
                        cnf.obj-type   = entry(3, v-field-value-list, {&delim-key})
                        cnf.obj-code   = integer(entry(4, v-field-value-list, {&delim-key}))
                        cnf.beg-date   = date(entry(5, v-field-value-list, {&delim-key}))
                        cnf.end-date   = date(entry(6, v-field-value-list, {&delim-key}))
                        cnf.db-num     = integer(entry(7, v-field-value-list, {&delim-key}))
                        .
                end.
                run adm/cfg-hist.w
                    ( input parparentproc
                    ,buffer cnf
                    ) no-error .
            end.    
        when "action-role" or 
        when "action-role-item" then 
            do:
                run ref/cactnrole.w (
                    INPUT parparentproc
                    , INPUT "":U /*bttns*/
                    , INPUT "one":U /*parref-mode*/
                    , OUTPUT  v-list
                    , INPUT INTEGER (entry(1, v-field-value-list, {&delim-key}))
                    , INPUT INTEGER (entry(2, v-field-value-list, {&delim-key}))
                    , INPUT INTEGER (entry(3, v-field-value-list, {&delim-key}))
                    , input "":U /*p-subject*/
                    ).
            end. 
        when "c-plc-hist" then 
            do:
                
                if entry(6, v-field-value-list, {&delim-key}) = "pl-gds-pump" then 
                do:
                    find first ub.c-pl-gds-pump no-lock where ub.c-pl-gds-pump.chip-num = INTEGER (entry(5, v-field-value-list, {&delim-key})) no-error .
                    if AVAILABLE (ub.c-pl-gds-pump) then 
                    do:
                        run ref/cplchisth.w (
                            INPUT parParentProc
                            , input "":U /*bttns  */
                            , input "subject":U /*p-mode*/
                            , input ub.c-pl-gds-pump.obj-type
                            , input ub.c-pl-gds-pump.obj-code
                            , input ub.c-pl-gds-pump.pl-code
                            , input ub.c-pl-gds-pump.gds-code /*p-gds-code*/
                            , input ub.c-pl-gds-pump.pump-code /*p-pump-code*/
                            , input 0 /*p-nozzle-code*/
                            , input {&table_pl-gds-pump} /*p-subject*/
                            , input-output v-list
                            ) no-error .
                    end.    
                end.    
            end.    
        when "tech-prol-pwd" then 
            do:
               
               def var vEntity as utl.tech-prol-pwd no-undo.
               def var vRepo   as utl.repoPwd no-undo.
               def var vFrm    as utl.gpwdfrm no-undo.
               
               assign 
                  vEntity = new utl.tech-prol-pwd()
                  vEntity:id = int64(v-field-value-list)
                  vRepo = new utl.repoPwd(vEntity)
               .
               
               vRepo:Refresh().
               
               vFrm = utl.gpwdfrm:GetObject("view",vEntity).
               
               wait-for vFrm:ShowDialog().
      
            end.    

    end case.       /* case p-table-name */
  
end.