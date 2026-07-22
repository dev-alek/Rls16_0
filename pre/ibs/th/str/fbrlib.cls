using Progress.Lang.*.
block-level on error undo, throw.
class ibs.th.str.fbrlib:
  define property ReturnMsg as character no-undo
    get.
    private set.
  define variable hndl-proc-key-rec as handle.
  constructor public fbrlib ():
    run str/fbrlib.p persistent set hndl-proc-key-rec .
  end constructor.
  destructor public fbrlib ():
    if valid-handle(hndl-proc-key-rec) then delete object hndl-proc-key-rec .
  end destructor.
  method public void fbrcode-gen-recipe-code (
    input p-obj-type        as character,
    input p-obj-code        as integer,
   output p-new-recipe-code as character
  ):
    run fbrcode-gen-recipe-code in hndl-proc-key-rec
      (input p-obj-type
      ,input p-obj-code
     ,output p-new-recipe-code
      ) .
  end method.
  method public void fbrlib-set-default-recipe (
    input p-obj-type        as character,
    input p-obj-code        as integer,
    input p-gds-code        as integer
  ):
    run fbrlib-set-default-recipe in hndl-proc-key-rec
      (input p-obj-type
      ,input p-obj-code
      ,input p-gds-code
      ) .
  end method.
  method public void fbrlib-create-or-update-recipe-gds (
    input p-recipe-code as character,
    input p-gds-code    as integer,
    input p-is-waste    as logical,
    input p-qnty        as decimal,
    input p-proc-number as integer,
    input p-nws-self    as logical
  ):
    run fbrlib-create-or-update-recipe-gds in hndl-proc-key-rec
      (input p-recipe-code
      ,input p-gds-code
      ,input p-is-waste
      ,input p-qnty
      ,input p-proc-number
      ,input p-nws-self
      ) .
  end method.
  method private int find-next-proc-number (
    input p-recipe-code as character
  ):
  define variable v-max-proc-num as integer no-undo .
  define buffer buf_proc_recipe-gds for ub.recipe-gds .
    v-max-proc-num = 0 .
    for each buf_proc_recipe-gds no-lock
       where buf_proc_recipe-gds.recipe-code = p-recipe-code :
       assign
         v-max-proc-num = buf_proc_recipe-gds.proc-number when (v-max-proc-num < buf_proc_recipe-gds.proc-number)
       .
    end .
    return (v-max-proc-num + 1) .
  end method.
  method public rowid create-new-recipe-gds (
    input p-recipe-code as character,
    input p-gds-code    as integer,
    input p-qnty-net    as decimal,
    input p-qnty-gross  as decimal,
    input p-lf          as decimal,
    input p-gds-recipe-code as character,
    input p-wst         as integer
  ):
  define variable v-rowid        as rowid no-undo .
  define variable v-max-proc-num as integer no-undo .
  define buffer buf_goods      for ub.goods .
  define buffer buf_recipe-gds for ub.recipe-gds .
    v-rowid = ? .
    find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error .
    if not available buf_goods then do:
    undo, throw new Progress.Lang.AppError(
      substitute("Код товара [&1] из рецепта [&2] отсутствует в справочнике товаров.", p-gds-code, p-recipe-code)
    ) .
    end .
    find first buf_recipe-gds exclusive-lock
         where buf_recipe-gds.recipe-code = p-recipe-code
           and buf_recipe-gds.prod-type   = buf_goods.prod-type
           and buf_recipe-gds.prod-code   = buf_goods.prod-code
           and buf_recipe-gds.artic       = buf_goods.artic no-error no-wait .
    if locked(buf_recipe-gds) then do:
      undo, throw new Progress.Lang.AppError(
        substitute("Запись о товаре [&1] в рецепте с ид. [&2] занята другим пользователем", p-gds-code, p-recipe-code)
      ) .
    end .
    if available buf_recipe-gds then do:
    end .
    else do:
      v-max-proc-num = find-next-proc-number (p-recipe-code) .
      create buf_recipe-gds .
      assign
        buf_recipe-gds.recipe-code = p-recipe-code
        buf_recipe-gds.prod-type   = buf_goods.prod-type
        buf_recipe-gds.prod-code   = buf_goods.prod-code
        buf_recipe-gds.artic       = buf_goods.artic
        buf_recipe-gds.gds-code    = p-gds-code
        buf_recipe-gds.proc-number = v-max-proc-num
        buf_recipe-gds.coeff-waste = 0
        buf_recipe-gds.calc-method = 1
        buf_recipe-gds.nws-self    = no
      .
    end .
    assign
      buf_recipe-gds.qnty        = p-qnty-net
      buf_recipe-gds.brutto-qnty = p-qnty-gross
      buf_recipe-gds.coeff-waste = p-lf when p-lf <> ?
      buf_recipe-gds.is-waste    = if p-wst = 1 then yes else no
      buf_recipe-gds.gds-recipe-code = p-gds-recipe-code when p-gds-recipe-code <> ?
    .
    v-rowid = rowid(buf_recipe-gds) .
    return v-rowid .
  end method.
  method public void fbrlib-create-or-update-recipe (
    input p-mode            as character,
    input p-obj-type        as character,
    input p-obj-code        as integer,
    input p-recipe-code     as character,
    input p-recipe-type     as character,
    input p-gds-code        as integer,
    input p-name            as character,
    input p-design          as character,
    input p-order           as integer,
    input p-quality         as character,
    input p-ref-num         as character,
    input p-technique       as character,
    input p-template        as character,
    input p-qnty            as decimal,
    input p-portion-qnty    as integer,
    input p-portion-weight  as decimal,
   output p-new-recipe-code as character
  ):
    run fbrlib-create-or-update-recipe in hndl-proc-key-rec
      ( input p-mode
       ,input p-obj-type
       ,input p-obj-code
       ,input p-recipe-code
       ,input p-recipe-type
       ,input p-gds-code
       ,input p-name
       ,input p-design
       ,input p-order
       ,input p-quality
       ,input p-ref-num
       ,input p-technique
       ,input p-template
       ,input p-qnty
       ,input p-portion-qnty
       ,input p-portion-weight
       ,output p-new-recipe-code
      ) .
  end method.
  method public void create-new-recipe (
    input p-mode            as character,
    input p-recipe-code     as character,
    input p-recipe-type     as character,
    input p-recipe-name     as character,
    input p-recipe-num      as character,
    input p-gds-code        as integer,
    input p-qnty-netto      as decimal,
    input p-portion-qnty    as integer,
    input p-portion-weight  as decimal,
    input p-stts            as integer
  ):
  define buffer buf_recipe for ub.recipe .
  define buffer buf_goods  for ub.goods .
    find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error.
    if not available buf_goods then do:
    undo, throw new Progress.Lang.AppError(
      substitute("Код товара [&1] отсутствует в справочнике товаров.", p-gds-code)
    ) .
    end.
    case p-mode:
      when 'ДОБАВЛЕНИЕ':U then do:
        if p-recipe-code > "":U then . else undo, throw new Progress.Lang.AppError("Не задан ид. рецепта при создании") .
        create buf_recipe .
        assign
          buf_recipe.recipe-code      = p-recipe-code
          buf_recipe.recipe-type      = p-recipe-type
          buf_recipe.recipe-design    = ""
          buf_recipe.recipe-order     = 0
          buf_recipe.recipe-quality   = ""
          buf_recipe.recipe-technique = ""
          buf_recipe.recipe-template  = ""
        .
      end.
      when 'ИЗМЕНЕНИЕ':U then do:
        find first buf_recipe exclusive-lock where buf_recipe.recipe-code = p-recipe-code no-error no-wait .
        if locked(buf_recipe) then do:
          undo, throw new Progress.Lang.AppError(
            substitute("Запись о рецепте с ид. [&1] занята другим пользователем", p-recipe-code)
          ) .
        end .
        if not available buf_recipe then do:
          undo, throw new Progress.Lang.AppError(
            substitute("Запись о рецепте с ид. [&1] отсутствует", p-recipe-code)
          ) .
        end .
        if buf_recipe.recipe-type <> p-recipe-type then do:
          undo, throw new Progress.Lang.AppError(
            substitute("Ошибка в типе при изменении рецепта с ид. [&1]. Тип рецепта изменять нельзя. Новый тип [&3], текущий тип [&2]",
                       p-recipe-code, p-recipe-type, buf_recipe.recipe-type)
          ) .
        end .
      end.
      otherwise do:
        undo, throw new Progress.Lang.AppError(
          substitute("Ошибка задания типа операции для создания или измения рецепта. Задан тип операции: [&1]", p-mode)
        ) .
      end.
    end case.
    assign
      buf_recipe.recipe-name    = ( if p-recipe-name > "" then p-recipe-name else buf_goods.gds-name )
      buf_recipe.recipe-ref-num = p-recipe-num
      buf_recipe.gds-code      = p-gds-code
      buf_recipe.artic         = buf_goods.artic
      buf_recipe.prod-type     = buf_goods.prod-type
      buf_recipe.prod-code     = buf_goods.prod-code
      buf_recipe.host-code     = 0
      buf_recipe.obj-type      = "":U
      buf_recipe.obj-code      = 0
      buf_recipe.qnty           = p-qnty-netto
      buf_recipe.portion-qnty   = p-portion-qnty
      buf_recipe.portion-weight = p-portion-weight
      buf_recipe.stts           = p-stts
    .
  end method.
end class.
