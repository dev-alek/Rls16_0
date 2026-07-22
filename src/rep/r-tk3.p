/*

$Revision: 58482062ad09, 1751, rls $
$Author: SMMolotkov $
$Date: Thu Feb 07 16:49:55 2019 +0300 $
$Workfile: r-tk3.p $
$Archive: rep/r-tk3.p $

Документ Технологическая карта - 3

Автор: Харитонов Владимир Александрович
Дата создания: 02/09/13
Author: KHaritonov Vladimir
Creation date: 02/09/13


*/

using Progress.Lang.*.
using Ibs.Th.Gbl.Rep-Out.
block-level on error undo, throw.

define variable vss-revision    as character no-undo init "$Revision: 58482062ad09, 1751, rls $":U .
define variable vss-author      as character no-undo init "$Author: SMMolotkov $":U .
define variable vss-date        as character no-undo init "$Date: Thu Feb 07 16:49:55 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: r-tk3.p $":U .
define variable vss-archive     as character no-undo init "$Archive: rep/r-tk3.p $":U .
define variable vss-description as character no-undo init "Документ Технологическая - 3 ".

define input parameter parparentproc as handle no-undo .
define input parameter p-recid  as recid     no-undo.
define input parameter p-type as character no-undo .

define variable v-num as character no-undo. /* рецептура № */
define variable v-orgname as character no-undo . /* огранизация */
define variable v-name as character no-undo. /* название */
define variable v-weight as character no-undo. /* выход */
define variable v-ps as character no-undo. /* технология приготовления */
define variable v-ps1 as character no-undo. /* примечание */

/* на 100 г для товара рецепта */
define variable v-calories as decimal no-undo. /* Энергетическая! ценность, ккал */
define variable v-protein as decimal no-undo. /* Белки, г */
define variable v-carbohydrate as decimal no-undo. /* Углеводы, г */
define variable v-fat as decimal no-undo.  /* Жиры, г */
define variable v-show-t2 as logical no-undo. /* показывать таблицу с белками, жирами и тд... */

{ cmp/vssrevis.i     }
{ cmp/str-glbl.i     }
{ cmp/r-pril.i       }
{ cmp/r-page1.i  new }
{ rep/hva-rep-etc.i  }
{ str/fbrlib.i       }
{ ref/gds-attr.i     }
{ ref/gdsoattr.i     }
{ gbl/nutro.i        }
{ gbl/getcntxt.i def }
{ gbl/getcntxt.i get " " parparentproc }

&glob format-num "->>>,>>>,>>9.999"
&glob format-pc "->>9.99"
&glob format-pc3 "->>9.999"

define temp-table tt-line no-undo
    field gds-name as character /** название */
    field gds-unit as character /** ед. измерения */
    field brutto as decimal /** вес брутто */
    field waste-pc as decimal /** % потерь */
    field netto as decimal /** вес нетто */
    field netto-1 as decimal /* нетто на 1 ед. */
    field final-weight as decimal /* вес готового продукта */
.

run main no-error.
if error-status:error then
    message return-value
    view-as alert-box.

procedure main:
    define variable v-file-name as character no-undo.
    
    run prepare-info {&check-no-error}
    run create-rep(output v-file-name) {&check-no-error}
    
    if v-file-name = ? then
        return error "файл созданного отчёта не найден".
    else
        run open-ie(v-file-name) {&check-no-error}
end.

procedure prepare-info:   
    define variable v-type as character no-undo.
    define variable v-val as character no-undo.
    define variable v-host-code as integer no-undo .

    find first ub.recipe no-lock where recid(ub.recipe) = p-recid.
/* в рецепте оба значения не определены;
   для взятия наименования своей организкции будем использовать текущие obj-type и obj-code из контекста
      ub.recipe.obj-type
      ub.recipe.obj-code
*/      
    { gbl/hostname.i
      v-cntxt-obj-type
      v-cntxt-obj-code
      v-host-code
      v-orgname
    }    
    find first ub.goods no-lock
        where ub.goods.artic = ub.recipe.artic
        and ub.goods.prod-type = ub.recipe.prod-type
        and ub.goods.prod-code = ub.recipe.prod-code.
    
    assign
        v-ps1 = ub.recipe.recipe-quality
        v-ps = ub.recipe.recipe-technique
        v-num = ub.recipe.recipe-ref-num
        v-name = ub.recipe.recipe-name
        v-weight = string(ub.recipe.portion-weight, {&format-num}) + " кг"
    .

    run gds-attr-value(
        ub.goods.gds-code,
        {&attr-calories},
        output v-val,
        output v-type
    ).
    
    v-calories = decimal(v-val).
    
    run gds-attr-value(
        ub.goods.gds-code,
        {&attr-fat},
        output v-val,
        output v-type
    ).
    
    v-fat = decimal(v-val).
    
    run gds-attr-value(
        ub.goods.gds-code,
        {&attr-carbohydrate},
        output v-val,
        output v-type
    ).
    
    v-carbohydrate = decimal(v-val).
    
    run gds-attr-value(
        ub.goods.gds-code,
        {&attr-protein},
        output v-val,
        output v-type
    ).
    
    v-protein = decimal(v-val).
    
    /* проверка таблицы на видимость */
    v-show-t2 = (if
        (v-calories = 0 OR v-calories = ?) AND
        (v-fat = 0 OR v-fat = ?) AND
        (v-carbohydrate = 0 OR v-carbohydrate = ?) AND
        (v-protein = 0 OR v-protein = ?)
            then false else true 
        ).
    
    for each ub.recipe-gds no-lock
        where ub.recipe-gds.recipe-code = ub.recipe.recipe-code,
    first ub.goods no-lock
        where ub.goods.gds-code = ub.recipe-gds.gds-code:
        
        create tt-line.
        assign
            tt-line.gds-name = ub.goods.gds-name /* название ингридиента */
            tt-line.gds-unit = ub.goods.unit-base /* ед измерения */
            tt-line.brutto = ub.recipe-gds.brutto-qnty /* брутто */
            tt-line.netto = ub.recipe-gds.qnty /* нетто */
            tt-line.final-weight = tt-line.netto /* вес готового продукта */
            tt-line.waste-pc = ub.recipe-gds.coeff-waste /* % потерь */
            tt-line.netto-1 = tt-line.netto / ub.recipe.portion-qnty
        .
    end.        
end.

procedure create-rep:
    define output parameter p-filename as character no-undo.
        
    define variable v-rls-file as character no-undo.
    define variable v-data-file as character no-undo.
    define variable v-xsl-file as character no-undo.
    define variable v-tmp-file as character no-undo.
    define variable hw as handle no-undo.
    define variable rep-out as class Rep-Out no-undo.
    
    assign
        v-xsl-file = search("exe/tk3.xsl.html")
        v-data-file = session:temp-directory + string(time) + ".xml"
        v-tmp-file = session:temp-directory + string(time) + ".html".
    .
    
    create sax-writer hw.
    hw:formatted = true.
    hw:set-output-destination ("file", v-data-file).
    
    run write-data(hw) {&check-no-error}

    rep-out = new rep-out().
    v-rls-file = rep-out:xsl-transform(v-data-file, v-xsl-file).    
    os-delete value(v-tmp-file).
    os-copy value(v-rls-file) value(v-tmp-file).  
    os-delete value(v-rls-file).
    delete object rep-out.
    
    p-filename = v-tmp-file.
end.

procedure write-data:
    define input parameter hw as handle no-undo.
    
    hw:start-document ().
    hw:start-element ("rep").
    hw:start-element ("card").
    
    hw:insert-attribute ("name", v-name).
    hw:insert-attribute ("num", v-num).
    hw:insert-attribute ("org", v-orgname).
    hw:insert-attribute ("ps", v-ps).
    hw:insert-attribute ("ps1", v-ps1).
    hw:insert-attribute ("weight", v-weight).
    
    hw:insert-attribute ("show-t2", string(v-show-t2)).
    hw:insert-attribute ("fat", string(if v-fat = ? then 0 else v-fat, {&format-num})).
    hw:insert-attribute ("protein", string(if v-protein = ? then 0 else v-protein, {&format-num})).
    hw:insert-attribute ("carbohydrate", string(if v-carbohydrate = ? then 0 else v-carbohydrate, {&format-num})).
    hw:insert-attribute ("calories", string(if v-calories = ? then 0 else v-calories, {&format-num})).
    
    for each tt-line no-lock:
        hw:start-element ("line").
        hw:insert-attribute ("name", tt-line.gds-name).
        hw:insert-attribute ("unit", tt-line.gds-unit).
        hw:insert-attribute ("brutto", string(tt-line.brutto, {&format-num})).
        hw:insert-attribute ("netto", string(tt-line.netto, {&format-num})).
        hw:insert-attribute ("netto-1",  if tt-line.netto-1 = ? then "" else string(tt-line.netto-1, {&format-num}) ).
        hw:insert-attribute ("waste-pc", string(tt-line.waste-pc, {&format-pc3})).
        hw:insert-attribute ("final-weight", string(tt-line.final-weight, {&format-num})).
        hw:end-element ("line").
    end.    
    
    hw:end-element ("card").
    hw:end-element ("rep").
    hw:end-document ().

end.

procedure open-ie:
    define input parameter p-filename as character no-undo.
    
    define variable o-IE as com-handle no-undo.
    
    create "InternetExplorer.Application" o-IE.
    /* o-IE:menubar = false. */
    o-IE:addressbar = false.
    o-IE:Navigate(p-filename).
    o-IE:visible = true.
    release object o-IE.

end.
