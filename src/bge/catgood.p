block-level on error undo, throw.
/*

$Revision: 2d6430604525, 1301, rls $
$Author: EShklyar $
$Date: Tue Apr 10 12:04:11 2018 +0300 $
$Workfile: catgood.p $
$Archive: bge/catgood.p $

Экспорт справочника товаров

Автор: Хныкин Павел Андреевич
Дата создания: 04/05/06
Author: Pavel Khnykin
Creation date: 04/05/06

Input:
    p-mode          - режим экспорта (список):
                        "good-ext" - расширенный экспорт, весь справочник
                        "list"     - экспорт товаров с кодами из временной таблицы temp_bgelib_goods
    temp_bgelib_goods - список кодов товаров для режима "list"
*/

define variable vss-revision    as character no-undo init "$Revision: 2d6430604525, 1301, rls $":U .
define variable vss-author      as character no-undo init "$Author: EShklyar $":U .
define variable vss-date        as character no-undo init "$date: 12.08.03 16:43 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: catgood.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/catgood.p $":U .
define variable vss-description as character no-undo init "Экспорт справочника товаров".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/library.i  }
{ bge/bgelib.i   }
{ trg/factord.i  }
{ str/fbrlib.i   }

define input parameter p-mode       as character    no-undo.
define input parameter table for temp_bgelib_goods .

&scoped-define version-string "15.0 " + replace( vss-revision + vss-date, "$", " " )
&scoped-define parameters-amount 4

    define variable v-counter               as integer      no-undo.
    define variable v-xml-file-name         as character    no-undo.
    define variable v-log-file-name         as character    no-undo.
    define variable v-list-file-name        as character    no-undo.
    define variable v-xml-file-number       as integer      no-undo.
    define variable v-cancel                as logical      no-undo.
    define variable v-parameter-list        as character    no-undo.

    define buffer buf_goods     for ub.goods.
do
for buf_goods
on error undo, return error
:
    run bgelib-filename in this-procedure (
          input "gds"
        , output v-xml-file-name
        , output v-log-file-name
        , output v-list-file-name
    ).
    run gbl/waitfrsp.w (
          input substring( v-xml-file-name, 1, 1 )
        , input {&bgelib_minimum-free-mbytes}
        , output v-cancel
    ) .
    if v-cancel = yes
    then do:
        undo, return error .
    end.
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input "&DLine"
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Начало выгрузки справочника товаров в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + {&bgelib-temp-extension}
                          )
    ).
    assign
        v-parameter-list         =  substitute( "&1,&2,&3,&4,&5,&6,&7,&8,&9"
                                               , {&parameters-amount}
                                               , "docName"          , "goods":U
                                               , "version"          , replace({&version-string},',','')
                                               , "exportDate"       , string( today,          "99/99/9999" )
                                               , "exportTime"       , string( time,           "HH:MM:SS"   )
                                              )
    .
    run bgelib-write-header in this-procedure (
          input yes
        , input v-xml-file-name
        , input v-list-file-name
        , input 1                                           /* p-file-number   */
        , input no                                          /* p-have-prev     */
        , input ""                                          /* p-prev-filename */
        , input ""
        , input ""
        , input v-parameter-list
    ).
    if lookup( "list":U, p-mode ) = 0
    then do:
        for each buf_goods no-lock
        on error undo, return error
        :       /* и удаленные товары тоже */
            run export-good in this-procedure (
                  input buf_goods.gds-code
                , input v-parameter-list
                , input v-xml-file-name
                , input v-log-file-name
                , input v-list-file-name
                , input v-xml-file-number
                , output v-xml-file-name
                , output v-xml-file-number
            ).
        end.
    end.        /* if lookup( "list":U, p-mode ) <> 0 */
    else do:
        for each temp_bgelib_goods
        on error undo, return error
        :
            run export-good in this-procedure (
                  input temp_bgelib_goods.gds-code
                , input v-parameter-list
                , input v-xml-file-name
                , input v-log-file-name
                , input v-list-file-name
                , input v-xml-file-number
                , output v-xml-file-name
                , output v-xml-file-number
            ).
        end.        /* for each temp_bgelib_goods */
    end.        /* NOT( if lookup( "list":U, p-mode ) <> 0 ) */
    run bgelib-write-footer in this-procedure (
          input yes
        , input v-xml-file-name
        , input v-list-file-name
        , input no
        , input ""
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input substitute( "Данные выгружены в файл &1"
                                , replace( v-xml-file-name, "/", "\" ) + "xml"
                          )
    ).
    run bgelib-write-log in this-procedure (
          input v-log-file-name
        , input 1
        , input "&DLine"
    ).
end.

/*========================================================================*/
procedure export-good:
do
on error undo, return error
:
define input parameter p-gds-code as integer no-undo.
define input parameter p-parameter-list         as character    no-undo.
define input parameter p-xml-file-name          as character    no-undo.
define input parameter p-log-file-name          as character    no-undo.
define input parameter p-list-file-name         as character    no-undo.
define input parameter p-xml-file-number        as integer      no-undo.
define output parameter p-last-xml-file-name    as character    no-undo.
define output parameter p-last-xml-file-number  as integer      no-undo.


    define variable v-barcode       like ub.bar-code.b-code no-undo.
    define variable v-vat-pc        as decimal      no-undo.
    define variable v-slt-pc        as decimal      no-undo.
    define variable v-need-new-file as logical      no-undo.
    define variable v-void-string   as character    no-undo.
    define variable v-prev-filename as character    no-undo.
    define variable v-rate-code     as integer      no-undo.

    define buffer buf_goods     for ub.goods.
    define buffer buf_units     for ub.units.
    define buffer buf_prod-bc   for ub.prod-bc.

    assign
        p-last-xml-file-name   = p-xml-file-name
        p-last-xml-file-number = p-xml-file-number
    .
    run bgelib-check-file-size in this-procedure (
          input p-xml-file-name + {&bgelib-temp-extension}
        , output v-need-new-file
    ).
    if v-need-new-file = yes
    then do:
        assign
            v-prev-filename = p-xml-file-name
        .
        run bgelib-filename in this-procedure (
              input "gds"
            , output p-xml-file-name
            , output v-void-string
            , output v-void-string
        ).
        run bgelib-write-footer in this-procedure (
              input no
            , input v-prev-filename
            , input p-list-file-name
            , input yes
            , input p-xml-file-name + "xml":U
        ).
        run bgelib-write-log in this-procedure (
              input p-log-file-name
            , input 1
            , input substitute( "Данные выгружены в файл &1"
                                    , replace( p-xml-file-name, "/", "\" ) + "xml"
                            )
        ).
        assign
            p-last-xml-file-number   = p-xml-file-number + 1
            p-last-xml-file-name     = p-xml-file-name
        .
        run bgelib-write-header in this-procedure (
              input no
            , input p-last-xml-file-name
            , input p-list-file-name
            , input p-last-xml-file-number
            , input yes
            , input v-prev-filename + "xml":U
            , input ""
            , input ""
            , input p-parameter-list
        ).
        assign
            v-need-new-file = no
        .
    end.        /* if v-need-new-file = yes */
    output stream stmxmlout to value( p-xml-file-name + {&bgelib-temp-extension} ) convert target "1251" append.
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    { gbl/pgtxvalg.i buf_goods.gds-code {&vat-tax-code} ? v-vat-pc no-error}
    { gbl/pgtxvalg.i buf_goods.gds-code {&slt-tax-code} ? v-slt-pc no-error}
    run get-tax-rate-code in this-procedure (
          input buf_goods.gds-code
        , input integer( {&vat-tax-code} )
        , input ?
        , output v-rate-code
    ).

    { gbl/gdsbcode.i buf_goods.gds-code ? v-barcode no-error}.
    if error-status :error
    then do:
        run bgelib-write-log in this-procedure (
            input p-log-file-name,
            input 2,
            input substitute( "*** ERR *** Не найден бар-код товара: &1"
                                , p-gds-code  )
        ).
    end.
    run bgelib-tag-open in this-procedure ( input 0, input "gds", input "" ).
    run bgelib-tag-put in this-procedure ( input 1, input "goodID"  , input string( buf_goods.gds-code ), input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "articul" , input buf_goods.artic             , input 0 ).
    if buf_goods.stts <> 0
    then do:
        run bgelib-tag-put in this-procedure ( input 1, input "deleted", input "yes", input 0).
    end.
        run bgelib-tag-put in this-procedure ( input 1, input "prodtype", input buf_goods.prod-type, input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "prodcode", input buf_goods.prod-code, input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "units"     , input buf_goods.unit-base           , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "type"      , input buf_goods.gds-type            , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "minstock"  , input string(buf_goods.min-stock)   , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "okdp"      , input buf_goods.okdp                , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "name"      , input buf_goods.gds-name            , input 0 ).
    if lookup( "good-ext":U, p-mode ) <> 0
    then do:
        define variable v-have-recipe          as logical      no-undo.
        define variable v-is-ingredient        as logical      no-undo.
        define variable v-can-be-income        as logical      no-undo.
        define variable v-can-be-write-off     as logical      no-undo.
        run get-fbr-trn-type in this-procedure (
              input buf_goods.gds-code
            , output v-have-recipe
            , output v-is-ingredient
            , output v-can-be-income
            , output v-can-be-write-off
        ).
        run bgelib-tag-put in this-procedure ( input 1, input trim( "labelname    " ), input string( buf_goods.label-name    ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input trim( "destin       " ), input string( buf_goods.destin        ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input trim( "attrib       " ), input string( buf_goods.attrib        ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input trim( "userRule     " ), input string( buf_goods.user-rule     ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input trim( "sert         " ), input string( buf_goods.sert          ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input trim( "struct       " ), input string( buf_goods.struct        ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input trim( "deadline     " ), input string( buf_goods.deadline      ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input trim( "sort         " ), input string( buf_goods.sort          ), input 0 ).
/*        run bgelib-tag-put in this-procedure ( input 1, input trim( "tnved        " ), input string( buf_goods.tnved         ), input 0 ).*/
        run bgelib-tag-put in this-procedure ( input 1, input trim( "unitCST      " ), input string( buf_goods.unit-cst      ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input trim( "CSTBaseRate  " ), input string( buf_goods.cst-base-rate ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input trim( "nationality  " ), input string( buf_goods.nationality   ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input trim( "normalWastage" ), input string( buf_goods.normal-wastage), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input trim( "normalWaste  " ), input string( buf_goods.normal-waste  ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input trim( "haveRecipe   " ), input string( v-have-recipe           ), input 3 ).
        run bgelib-tag-put in this-procedure ( input 1, input trim( "isIngredient " ), input string( v-is-ingredient         ), input 3 ).
        run bgelib-tag-put in this-procedure ( input 1, input trim( "canBeIncome  " ), input string( v-can-be-income         ), input 3 ).
        run bgelib-tag-put in this-procedure ( input 1, input trim( "canBeWriteOff" ), input string( v-can-be-write-off      ), input 3 ).
    end.
    run bgelib-tag-put in this-procedure ( input 1, "Vat"           , input string( v-vat-pc )              , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, "VATRateCode"   , input string( v-rate-code )           , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, "SLT"           , input string( v-slt-pc )              , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, "country"       , input buf_goods.alpha1                , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, "margin"        , input string( buf_goods.increase-pc ) , input 0 ).
    find first buf_units no-lock
         where buf_units.unit-name = buf_goods.unit-base
    no-error.
    if available buf_units
    then do:
        run bgelib-tag-put in this-procedure ( input 1, input "unitType", input buf_units.type, input 0 ).
    end.        /* available buf_units */
    else do:
        run bgelib-tag-put in this-procedure ( input 1, input "unitType", input "", input 0 ).
        run bgelib-write-log in this-procedure (
            input p-log-file-name,
            input 2,
            input substitute( "*** ERR *** Не найден тип: &1 для товара: &2"
                                , buf_goods.unit-base
                                , p-gds-code  )
        ).
    end.        /* not ( available buf_units ) */
    run bgelib-tag-put in this-procedure ( input 1, input "barcode"     , input string( v-barcode )             , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "groupcode"   , input string(buf_goods.grp-code)      , input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "condKeepCode", input string(buf_goods.cond-keep-code), input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "unitCli"     , input string( buf_goods.unit-cli        ), input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "cliBaseRate" , input string( buf_goods.cli-base-rate   ), input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "msCart"      , input string( buf_goods.ms-cart         ), input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "wtCart"      , input string( buf_goods.wt-cart         ), input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "qntyCart"    , input string( buf_goods.qnty-cart       ), input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "msBase"      , input string( buf_goods.ms-base         ), input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "wtBase"      , input string( buf_goods.wt-base         ), input 0 ).
    run bgelib-tag-put in this-procedure ( input 1, input "comment"   , input buf_goods.PS              , input 0 ).
    /*run bgelib-tag-put in this-procedure ( input 3, "group", buf_goods.grp-code, 0).*/
    run bgelib-tag-close in this-procedure ( input 0, input "gds").

    for each buf_prod-bc no-lock
       where buf_prod-bc.b-code = v-barcode
    on error undo, return error
    :
        run bgelib-tag-open in this-procedure ( input 0, input "gdsBcode", input "" ).
        run bgelib-tag-put in this-procedure ( input 1, input "goodID"    , input string( buf_goods.gds-code  ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "bcodeStr"  , input string( buf_prod-bc.b-str   ), input 0 ).
        run bgelib-tag-put in this-procedure ( input 1, input "bcodeOn"   , input string( buf_prod-bc.bc-on   ), input 0 ).
        run bgelib-tag-close in this-procedure ( input 0, input "gdsBcode").
    end.        /* for each buf_prod-bc */

    output stream stmxmlout close.
end.
end procedure.

/*==========================================================================*/
procedure get-tax-rate-code :
define input parameter p-gds-code   as integer          no-undo.
define input parameter p-tax-code   as integer          no-undo.
define input parameter p-date       as date             no-undo.
define output parameter p-rate-code as integer          no-undo.

    define variable v-today             as date         no-undo.
    define variable v-time              as integer      no-undo.
    define variable v-fact-order        as integer      no-undo.

    define buffer buf_tax-rate-gds      for ub.tax-rate-gds.
do
for buf_tax-rate-gds
on error undo, return error
:
    run cur-time in this-procedure (
          output v-today
        , output v-time
    ).
    if p-date = ?
    then do:
        assign
            p-date = v-today
        .
    end.
    run factord-end-day in this-procedure (
          input p-date
        , output v-fact-order
    ).
    find last buf_tax-rate-gds no-lock
        where buf_tax-rate-gds.gds-code   = p-gds-code
          and buf_tax-rate-gds.tax-code   = p-tax-code
          and buf_tax-rate-gds.host-code  = 0
          and buf_tax-rate-gds.obj-type   = ""
          and buf_tax-rate-gds.obj-code   = 0
          and buf_tax-rate-gds.fact-order <= v-fact-order
    no-error .
    if not available buf_tax-rate-gds
    then do:
        assign
            p-rate-code = 0
        .
    end.
    else do:
        assign
            p-rate-code = buf_tax-rate-gds.rate-code
        .
    end.

end.
end procedure. /* get-tax-rate-code */

/*==========================================================================*/
procedure get-fbr-trn-type :
define input parameter p-gds-code           as integer          no-undo.
define output parameter p-have-recipe       as logical          no-undo.
define output parameter p-is-ingredient     as logical          no-undo.
define output parameter p-can-be-income     as logical          no-undo.
define output parameter p-can-be-write-off  as logical          no-undo.

    define variable v-is-comp       as logical      no-undo.
    define variable v-trn-type      as character    no-undo.
    define variable v-recipe-type   as character    no-undo.

    define buffer buf_goods         for ub.goods.
    define buffer buf_recipe        for ub.recipe.
    define buffer buf_recipe-gds    for ub.recipe-gds.
do
for buf_goods
  , buf_recipe
  , buf_recipe-gds
on error undo, return error
:
    find first buf_goods no-lock
         where buf_goods.gds-code = p-gds-code
    .
    assign
        p-have-recipe       = no
        p-is-ingredient     = no
        p-can-be-income     = no
        p-can-be-write-off  = no
    .
    find first buf_recipe no-lock
         where buf_recipe.artic       = buf_goods.artic
           and buf_recipe.prod-type   = buf_goods.prod-type
           and buf_recipe.prod-code   = buf_goods.prod-code
    no-error.
    if available buf_recipe
    then do:
        assign
            p-have-recipe = yes
        .
    end.
    find first buf_recipe-gds no-lock
         where buf_recipe-gds.artic       = buf_goods.artic
           and buf_recipe-gds.prod-type   = buf_goods.prod-type
           and buf_recipe-gds.prod-code   = buf_goods.prod-code
    no-error.
    if available buf_recipe-gds
    then do:
        assign
            p-is-ingredient = yes
        .
    end.
    if p-have-recipe = yes
    then do:
        find first buf_recipe no-lock
             where buf_recipe.artic       = buf_goods.artic
               and buf_recipe.prod-type   = buf_goods.prod-type
               and buf_recipe.prod-code   = buf_goods.prod-code
               and buf_recipe.recipe-type = {&gathering}
        no-error.
        if available buf_recipe
        then do:
            assign
                p-can-be-income    = yes
                p-can-be-write-off = yes
            .
            return .
        end.
        else do:
            calc-trn-type-by-recipe:
            for each buf_recipe no-lock
               where buf_recipe.artic       = buf_goods.artic
                 and buf_recipe.prod-type   = buf_goods.prod-type
                 and buf_recipe.prod-code   = buf_goods.prod-code
            on error undo, return error
            :
                run fbrlib-get-trn-type in this-procedure (
                      input buf_recipe.recipe-code
                    , input recid( buf_goods )
                    , input yes
                    , output v-is-comp
                    , output v-trn-type
                ).
                if v-trn-type = {&income}
                then do:
                    assign
                        p-can-be-income    = yes
                    .
                end.
                if v-trn-type = {&write-off}
                then do:
                    assign
                        p-can-be-write-off = yes
                    .
                end.
            end.        /* for each buf_recipe */
        end.
    end.
    if p-is-ingredient = yes
    then do:
        calc-trn-type-by-recipe-gds:
        for each buf_recipe-gds no-lock
           where buf_recipe-gds.artic       = buf_goods.artic
             and buf_recipe-gds.prod-type   = buf_goods.prod-type
             and buf_recipe-gds.prod-code   = buf_goods.prod-code
        on error undo, return error
        :
            run fbrlib-get-recipe-type in this-procedure (
                  input "":U
                , input buf_recipe-gds.recipe-code
                , output v-recipe-type
            ).
            if v-recipe-type = {&gathering}
            then do:
                assign
                    p-can-be-income    = yes
                    p-can-be-write-off = yes
                .
                return .
            end.
            run fbrlib-get-trn-type in this-procedure (
                  input buf_recipe-gds.recipe-code
                , input recid( buf_goods )
                , input yes
                , output v-is-comp
                , output v-trn-type
            ).
            if v-trn-type = {&income}
            then do:
                assign
                    p-can-be-income    = yes
                .
            end.
            if v-trn-type = {&write-off}
            then do:
                assign
                    p-can-be-write-off = yes
                .
            end.
        end.        /* for each buf_recipe-gds */
    end.
end.
end procedure. /* get-fbr-trn-type */