block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Блокировка МЦ по документу

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

Блокируются все МЦ, используемые в накладной
выполняется перед началом закрытия накладной, (еще до получения fact-num)

*/
define input parameter v-wth-doc-doc-code like ub.wth-doc.doc-code no-undo .
define input parameter p-check-inv        as logical no-undo .
/* если true - то проверяем что МЦ не входят в открытые инвентаризации
   инв разр
 */

define input parameter p-document-fact-order like ub.wth-doc.fact-order no-undo .
/* если 0 - то никакие дополнительные проверки не выполняются.
   если задан номер, то проверяется что по каждому товару отсутствуют документы
     инвентаризации и переоценки с датой более поздней, чем указанная.
 */

define input parameter p-fact-close       as logical no-undo .
define input parameter p-is-news          as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "Блокировка МЦ по документу".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i }


define temp-table temp-wth-pl no-undo
  field w-p-code like ub.wth-place.w-p-code

  index xpk is primary w-p-code
.

define buffer buf_wth-doc  for ub.wth-doc .
define buffer buf_wth-line for ub.wth-line .
define buffer buf_wth-obj  for ub.wth-obj .
define buffer buf_wealth   for ub.wealth .
define buffer inv_wth-line for ub.wth-line .
define buffer inv_wth-doc  for ub.wth-doc .

define variable l-reserv-pl-code         as logical no-undo .

define variable num_rec       as integer   no-undo initial 0 .
define variable start_time    as integer   no-undo .
define variable curr_time     as integer   no-undo .

main-block:
do transaction
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:

  /* проверка входных параметров */
  find first buf_wth-doc no-lock
    where buf_wth-doc.doc-code = v-wth-doc-doc-code
    no-error .
  if not available buf_wth-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Не найден документ" skip
      "Документ" v-wth-doc-doc-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  if p-document-fact-order = ? then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка задания входных параметров" skip
      "Документ" v-wth-doc-doc-code skip
      "Логический номер закрываемого документа" p-document-fact-order skip
      view-as alert-box error .
    undo main-block, return error .
  end.

  def frame a
    "Блокировка МЦ на объекте." skip
    num_rec           format ">>>>>>>9"   label "Обработано МЦ" skip
    buf_wth-line.wth-code format ">>>>>>>>9"      label "Текущая МЦ" skip
    curr_time         format "->>>>>>>>9" label "Время" skip
    with view-as dialog-box side-labels three-d
    title "Документ " + v-wth-doc-doc-code .


  assign
    start_time = time
  .
  view frame a.

  for each buf_wth-line no-lock
    where buf_wth-line.doc-code = v-wth-doc-doc-code
    break by
    buf_wth-line.wth-code
  on error undo main-block, return error
  :

    find first buf_wealth no-lock
      where buf_wealth.wth-code = buf_wth-line.wth-code
      no-error .
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Не найдена МЦ" skip
        "Документ" buf_wth-line.doc-code skip
        "Код МЦ" buf_wealth.wth-code skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.

    /* обновить информацию о текущей закрываемой строке */
    assign
      num_rec   = num_rec + 1
    .
    if num_rec mod 10 = 0 then do:
      assign
        curr_time = time - start_time
      .
      display
        num_rec buf_wth-line.wth-code curr_time
        with frame a.
      process events .
    end.
     { gbl/wthobjcr.i
      buf_wth-line.obj-type
      buf_wth-line.obj-code
      buf_wth-line.wth-code
      buf_wth-obj
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Невозможно найти wth-obj" skip
        error-status :get-message(1) skip
        return-value skip
        view-as alert-box error .
      undo main-block, return error .
    end.
        DEFINE VARIABLE my-rec as recid no-undo .
    my-rec = recid(buf_wth-obj).
    find first buf_wth-obj exclusive-lock where
              recid(buf_wth-obj) = my-rec.
    /*
    find current buf_wth-obj exclusive-lock .*/
    release buf_wth-obj .
    /* проверяем целостность МЦ
        wth-obj  равно сумме wth-pobj
    */


    { gbl/wthcheck.i
      buf_wth-line.obj-type
      buf_wth-line.obj-code
      buf_wth-line.wth-code
      "''"
      no-error
    }
    if error-status :error then do:
      message
        vss-workfile vss-revision vss-description skip
        "Ошибка при проверке целостности товара" skip
        "Объект" buf_wth-line.obj-type buf_wth-line.obj-code skip
        "Код МЦ" buf_wth-line.wth-code skip
        error-status :get-message(1) skip
        view-as alert-box .
      undo main-block, return error .
    end.

  /*  блокировку на местах хранения не делаем для уничтожения из зоны клиента */
    if  p-fact-close = true
    and p-is-news    = false
    and buf_wth-doc.ext-doc-type <> {&WDEDT_Dst_Cli}
    then do:
      if first-of(buf_wth-line.wth-code) then do:
        /* очищаем таблицу складских мест */
        for each temp-wth-pl
        on error undo main-block, return error
        :
          delete temp-wth-pl .
        end.
      end.

      /* определяем список МХ */
        find first temp-wth-pl
          where temp-wth-pl.w-p-code = buf_wth-line.w-p-code
          no-error .
        if not available temp-wth-pl then do:
          create temp-wth-pl .
          assign
            temp-wth-pl.w-p-code = buf_wth-line.w-p-code
          .
        end.
        if buf_wth-doc.inter_ then do:
          find first temp-wth-pl
            where temp-wth-pl.w-p-code = buf_wth-line.out-code
            no-error .
          if not available temp-wth-pl then do:
            create temp-wth-pl .
            assign
              temp-wth-pl.w-p-code = buf_wth-line.out-code
            .
           end.
         end.


          if last-of(buf_wth-line.wth-code) then do:
            for each temp-wth-pl
            on error undo main-block, return error
            :
              run trg/lockplgw.p
                (input buf_wth-line.obj-type  /* p-obj-type          */
                ,input buf_wth-line.obj-code  /* p-obj-code          */
                ,input buf_wealth.wth-code    /* p-wth-code          */
                ,input temp-wth-pl.w-p-code   /* p-w-p-code          */
                ,input "check-doc-on=false"   /* p-action            */
                ,input ""                     /* p-no-check-rvs-code */
                ) no-error .
              if error-status :error then do:
                message
                  vss-workfile vss-revision vss-description skip
                  "МЦ заблокирована на МХ" skip
                  "Объект" buf_wth-line.obj-type buf_wth-line.obj-code skip
                  "МХ" temp-wth-pl.w-p-code skip
                  "Код МЦ" buf_wealth.wth-code skip
                  error-status :get-message(1) skip
                  return-value skip
                  view-as alert-box error .
                undo main-block, return error .
              end.
            end.
          end. /*last-of buf_wth-line.wth-code */
    end.
       /*
            if  p-fact-close = true
            and p-is-news    = false    */

    if p-check-inv then do:
      /* проверяем, нет ли инвентаризации "разр" по данной МЦ для данного объекта
      */
      define variable l-inv-on as logical no-undo .
      { gbl/wthobjat.i
        buf_wth-line.obj-type
        buf_wth-line.obj-code
        buf_wth-line.wth-code
        "'inv-on=request'"
        l-inv-on
        no-error
      }
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          "Ошибка получения признака МЦ на объекте" skip
          error-status :get-message(1) skip
          return-value skip
          view-as alert-box error .
        undo main-block, return no-apply .
      end.

      if l-inv-on then do:
        for each inv_wth-line no-lock
          where inv_wth-line.obj-type  = buf_wth-line.obj-type
            and inv_wth-line.obj-code  = buf_wth-line.obj-code
            and inv_wth-line.wth-code  = buf_wth-line.wth-code
            and inv_wth-line.status_   = {&permitted}
        ,first inv_wth-doc no-lock
          where inv_wth-doc.doc-code = inv_wth-line.doc-code
            and inv_wth-doc.doc-type = {&inventory}
            and inv_wth-doc.status_  = {&permitted}
        on error undo main-block, return error
        :
          message
            "МЦ :" buf_wealth.wth-code skip
            buf_wealth.wth-name skip
            "на объекте" inv_wth-line.obj-type inv_wth-line.obj-code skip
            "сейчас в инвентаризации (Документ №" inv_wth-line.doc-code ")." skip
            view-as alert-box information .
          undo main-block, return error .
        end.

        message
          "МЦ :" buf_wth-line.wth-code skip
          "на объекте" buf_wth-line.obj-type buf_wth-line.obj-code skip
          "Отмечен, как принадлежащий инвентризации" skip
          "Документ инвентаризации не найден" skip
          view-as alert-box information .
        undo main-block, return error .
      end.
    end.

    if false /* p-check-inv-rasr-minus */ then do:
      /* index fact-order */
      /*   obj-type   */
      /*   obj-code   */
      /*   prod-type  */
      /*   prod-code  */
      /*   artic      */
      /*   status_    */
      /*   fact-order */

      for each inv_wth-line no-lock
        where inv_wth-line.obj-type     = buf_wth-line.obj-type
          and inv_wth-line.obj-code     = buf_wth-line.obj-code
          and inv_wth-line.wth-code     = buf_wth-line.wth-code
          and inv_wth-line.ext-doc-type = {&WDEDT_Inv}
          and inv_wth-line.status_      = {&permitted}
          and inv_wth-line.doc-code     <> v-wth-doc-doc-code
      ,first ub.wth-doc no-lock
        where ub.wth-doc.doc-code       = inv_wth-line.doc-code
      on error undo main-block, return error
      :
        message
          "На объекте" inv_wth-line.obj-type inv_wth-line.obj-code skip
          "существует инвентаризация (Документ №" inv_wth-line.doc-code ") по МЦ" skip
          buf_wealth.wth-code skip
          buf_wealth.wth-name skip
          "Находящаяся в статусе '" STRING(ub.wth-doc.status_) "'." skip
          view-as alert-box information .
        undo main-block, return error .
      end.
    end.

    /* проверяем, что нет документов инвентаризации с датой
      более поздняя, чем указанная */
    if p-document-fact-order <> 0 then do:

      /* index fact-order */
      /*   obj-type   */
      /*   obj-code   */
      /*   prod-type  */
      /*   prod-code  */
      /*   artic      */
      /*   status_    */
      /*   fact-order */

      for each inv_wth-line no-lock
        where inv_wth-line.obj-type     = buf_wth-line.obj-type
          and inv_wth-line.obj-code     = buf_wth-line.obj-code
          and inv_wth-line.wth-code     = buf_wth-line.wth-code
          and inv_wth-line.ext-doc-type = {&WDEDT_Inv}
          and inv_wth-line.status_      = {&fact}
          and inv_wth-line.fact-order   > p-document-fact-order
      on error undo main-block, return error
      :
        message
          "На объекте" inv_wth-line.obj-type inv_wth-line.obj-code skip
          "существует инвентаризация (Документ №" inv_wth-line.doc-code ") по МЦ" skip
          buf_wealth.wth-code skip
          buf_wealth.wth-name skip
          "с большим логическим номером " inv_wth-line.fact-order "." skip
          "Невозможно закрыть документ с логическим номером" p-document-fact-order "." skip
          view-as alert-box information .
        undo main-block, return error .
      end.

    end.
  end.
end.