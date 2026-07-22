/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Обёртка для использования процедур из str/fbrlib.i в классах 

Автор: Молотков Сергей Михайлович
Дата создания: 25/10/17
Author: Molotkov Sergey
Creation date: 25/10/17

*/

using Progress.Lang.*.

block-level on error undo, throw.


class ibs.th.str.fbrlib: 

  { cmp/str-glbl.i class } /* {&add-def},{&update} */ 
  
  define property ReturnMsg as character no-undo
    get.
    private set.

  define variable hndl-proc-key-rec as handle.
 
  constructor public fbrlib ():
    run str/fbrlib.p persistent set hndl-proc-key-rec .
  end constructor.

  destructor public fbrlib ():
    /* к моменту захода в деструктор библиотека hndl-proc-key-rec уже, как правило, удалена */
    if valid-handle(hndl-proc-key-rec) then delete object hndl-proc-key-rec .
  end destructor.

  /*
     Вызовы процедур из fbrlib.i и fbrcode.i реализуются по мере потребности.
     Пожалуйста добавляйте сюда новые вызовы, если их ещё не реализовали.
     Кто реализует последний вызов - сотрите этот комментарий.
     Перечень процедур frbcode.i:
       * fbrcode-gen-recipe-code
       fbrcode-is-from-object
       fbrcode-trn-doc
       fbrcode-fill-fbr-by-sale-or-pln
       fbrcode-get-final-doc
     Перечень процедур fbrlib.i:
       fbrlib_create-fbr-doc
       fbrlib_get-default-pay-code
       fbrlib-fill-and-check-temp_fbrlib_recipe
       fbrlib-fill-sum-fbr-doc
       fbrlib-calc-prices
       fbrlib-put-in-order-recipe
       fbrlib-add-recipe-in-tmp-order
       fbrlib-get-trn-type
       fbrlib-check-temp-tables
       fbrlib-s-coeff-value
       fbrlib_create-fbr-recipe-gds
       * fbrlib-set-default-recipe
       fbrlib-get-obj-recipe
       * fbrlib-create-or-update-recipe-gds
       * fbrlib-create-or-update-recipe
       * !create-new-recipe - новая, скопирована из машины правил из rul/000002086.p
       fbrlib-delete-fact-fbr-doc
       fbrlib-del-trn-doc
       fbrlib-delete-fact-trn-doc
       fbrlib-print-del-error-message
       fbrlib-calc-brutto
       fbrlib-check-brutto
       fbrlib-check-fbr-recipe
       fbrlib-get-recipe-type
       calc-comp-from-ingr
       get-temp_dressing-ingr-used-qnty
       fbrlib_adjust-recipe
       fbrlib_adjust-doc-lines
       fbrlib_check-before-close
  */
  
  /* ========================================================================== */
  /* Генерация кода нового рецепта для заданного объекта */
  method public void fbrcode-gen-recipe-code (  
    input p-obj-type        as character, /* объект */
    input p-obj-code        as integer,
   output p-new-recipe-code as character
  ):
    
    run fbrcode-gen-recipe-code in hndl-proc-key-rec
      (input p-obj-type
      ,input p-obj-code
     ,output p-new-recipe-code
      ) .

  end method. /* end_of fbrcode-gen-recipe-code */
  /* ========================================================================== */
  /* Назначить рецепт по умолчанию */
  method public void fbrlib-set-default-recipe (
    input p-obj-type        as character, /* объект */
    input p-obj-code        as integer,
    input p-gds-code        as integer
  ):
    
    run fbrlib-set-default-recipe in hndl-proc-key-rec
      (input p-obj-type
      ,input p-obj-code
      ,input p-gds-code
      ) .

  end method. /* end_of fbrlib-set-default-recipe */
  /* ========================================================================== */
  /* Добавление товаров в рецепт и изменение товаров в рецепте */
  method public void fbrlib-create-or-update-recipe-gds (
    input p-recipe-code as character,
    input p-gds-code    as integer,
    input p-is-waste    as logical,
    input p-qnty        as decimal,
    input p-proc-number as integer,
    input p-nws-self    as logical
  ):
      
    /* ! во входных параметрах отсутствует код рецепта для полуфабриката.
       ! во входных параметрах отсутствуют количество брутто и коэффициэнт потерь. 
       Использование не желательно.
    */    
    run fbrlib-create-or-update-recipe-gds in hndl-proc-key-rec
      (input p-recipe-code
      ,input p-gds-code
      ,input p-is-waste
      ,input p-qnty
      ,input p-proc-number
      ,input p-nws-self
      ) .
  end method. /* end_of fbrlib-create-or-update-recipe-gds */
    
  /* найти максимальный свободный намер в рецепте proc-number (int) - порядковый номер при обработке, нужен для альтернативного рецепта */
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
  end method. /* end_of find-next-proc-number */

  /* скопмоновано из fbrlib-create-or-update-recipe-gds() и триггера на b-change ("Изменить") в ref/recipe.w */
  method public rowid create-new-recipe-gds (
    input p-recipe-code as character,
    input p-gds-code    as integer,
    input p-qnty-net    as decimal, /* recipe-gds.qnty */
    input p-qnty-gross  as decimal, /* recipe-gds.brutto-qnty */
    input p-lf          as decimal, /* recipe-gds.coeff-waste */
    input p-gds-recipe-code as character, /* код рецепта самого ингредиента, если он полуфабрикат */
    input p-wst         as integer
  ):
  define variable v-rowid        as rowid no-undo . /* возвратное значение */
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
  
    /* товары в рецепте:
       а) если товара не было - создать его
       б) если товар был - обновить его
    */
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
      /* только для update */
    end .
    else do:
      /* только для add */
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
        
        /* "Отправлять запись по новостям не в составе куста рецепта" */
        buf_recipe-gds.nws-self    = no /* посылка товаров отдельно от рецептов отсутствует в протоколе обмена с 1С */
      .
    end .
    
    /* для add и для update */
    assign
      /* нетто есть брутто, очищенный от коэффициента потерь lf */  
      buf_recipe-gds.qnty        = p-qnty-net
      buf_recipe-gds.brutto-qnty = p-qnty-gross
      buf_recipe-gds.coeff-waste = p-lf when p-lf <> ?
      
      /* "отметка, что это отходы" */
      buf_recipe-gds.is-waste    = if p-wst = 1 then yes else no
      
      buf_recipe-gds.gds-recipe-code = p-gds-recipe-code when p-gds-recipe-code <> ?
    .
    v-rowid = rowid(buf_recipe-gds) .
    
    return v-rowid .
  end method. /* end_of create-new-recipe-gds */
  /* ========================================================================== */
  /* Создание и изменение рецепта */
  method public void fbrlib-create-or-update-recipe (
    input p-mode            as character, /* {&add-def} или {&update} */
    input p-obj-type        as character, /* объект */
    input p-obj-code        as integer,
    input p-recipe-code     as character, /* код рецепта. Если "", то создается новый */
    input p-recipe-type     as character, /* тип рецепта. Обязателен для нового рецепта */
    input p-gds-code        as integer,   /* код товара. Обязателен для нового рецепта */
    input p-name            as character, /* имя рецепта. Для нового рецепта, если "", то будет взято имя товара */
    input p-design          as character, /* способ оформления блюда */
    input p-order           as integer,   /* порядковый номер при обработке */
    input p-quality         as character, /* Показатели качества готовой продукции */
    input p-ref-num         as character, /* Номер рецепта по справочнику рецептур */
    input p-technique       as character, /* Описание технологии приготовления блюда по рецепту */
    input p-template        as character, /* Ссылка на справочник рецептур или технологическую карту */
    input p-qnty            as decimal,   /* Количество товара */  
    input p-portion-qnty    as integer,   /* Количество порций товара */
    input p-portion-weight  as decimal,   /* Вес порции для рецепта производства со штучными ингредиентами */
   output p-new-recipe-code as character
  ):

    /* ! внутри ошибки. Использование не желательно.
       По тексту процедура работает так:
       1) если p-recipe-code = "" - то делает create buf_recipe
       2) далее независимо от значения p-recipe-code делает assign_buf_recip
       Т.к. buf_recipe определён внутри процедуры, то при обновлении записи она вообще не должна сработать.
       На создание она будет работать только если пустой recip-code,
       но т.к. значение recip-code при импорте мы берём из файла импорта - то создание в импорте тоже не сработает.  
    */    
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

  end method. /* end_of fbrlib-create-or-update-recipe */
  /* скопировано с машины правил rul/000002086.p */
  method public void create-new-recipe (
    input p-mode            as character, /* {&add-def} или {&update} */
    input p-recipe-code     as character, /* код рецепта. Если "", то создается новый */
    input p-recipe-type     as character, /* тип рецепта. Обязателен для нового рецепта */
    input p-recipe-name     as character, /* имя рецепта. если "", то будет взято наименование товара */
    input p-recipe-num      as character, /* Номер рецепта по справочнику рецептур */
    input p-gds-code        as integer,   /* код товара */
    input p-qnty-netto      as decimal,   /* Количество товара */  
    input p-portion-qnty    as integer,   /* Количество порций товара */
    input p-portion-weight  as decimal,   /* Вес порции */
    input p-stts            as integer    /* Статус */
  ):
  define buffer buf_recipe for ub.recipe .
  define buffer buf_goods  for ub.goods .

    /* даже если нам не понадобится наименование товара - сам товар по-любому должен существовать в целевой БД */
    find first buf_goods no-lock where buf_goods.gds-code = p-gds-code no-error.
    if not available buf_goods then do:
    undo, throw new Progress.Lang.AppError(
      substitute("Код товара [&1] отсутствует в справочнике товаров.", p-gds-code)
    ) .
    end.
    
    case p-mode:
      when {&add-def} then do:
        if p-recipe-code > "":U then . else undo, throw new Progress.Lang.AppError("Не задан ид. рецепта при создании") .
        create buf_recipe .
        assign
          buf_recipe.recipe-code      = p-recipe-code
          buf_recipe.recipe-type      = p-recipe-type
          /* чтобы при обновлении не затирать поля, которые не приходят из 1с, присваиваем их только здесь: */
          buf_recipe.recipe-design    = ""
          buf_recipe.recipe-order     = 0
          buf_recipe.recipe-quality   = ""
          buf_recipe.recipe-technique = ""
          buf_recipe.recipe-template  = ""
        .
      end.
      when {&update} then do:
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
          /* возвращаемые коды типов рецепта необходимо будет преобразовать к значениям enum-recipe-type */
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
  
      /* делать рецепт глобальным? - да, все импортируемые из 1с рецепты глобальные */
      buf_recipe.host-code     = 0
      buf_recipe.obj-type      = "":U 
      buf_recipe.obj-code      = 0
  
      buf_recipe.qnty           = p-qnty-netto
      buf_recipe.portion-qnty   = p-portion-qnty
      buf_recipe.portion-weight = p-portion-weight
      
      buf_recipe.stts           = p-stts
  
      /* остались незаполненными:
      whole-send-news
      brutto-qnty
      sale-gactor
      is-defult
      */
    .

  end method. /* end_of create-new-recipe */
  /* ========================================================================== */
 
  
end class.
