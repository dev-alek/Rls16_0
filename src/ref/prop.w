/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Редактирование шкалы признаков

Автор: Перваков Михаил Сергеевич
Дата создания: 04/13/06
Author: Mikhail Pervakov
Creation date: 04/13/06

*/

def input  param mode as char no-undo.
def input  param n-c  like ub.gds-prt.node-code no-undo.
def output param rid  as recid init ? no-undo.

define variable vss-revision    as character no-undo initial "$Revision$":U .
define variable vss-author      as character no-undo initial "$Author$":U .
define variable vss-date        as character no-undo initial "$Date$":U .
define variable vss-workfile    as character no-undo initial "$Workfile$":U .
define variable vss-archive     as character no-undo initial "$Archive$":U .
define variable vss-description as character no-undo initial "Редактирование шкалы признаков".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ cmp/showinf.i  }
{ gbl/color.i    }
{ gbl/waitfram.i }

&scop frame-name td

def var sc-name like ub.gds-prt.node-name format "x(40)" label "Название шкалы" no-undo.
def var ld-n     as int no-undo.
def var prt_root as int no-undo.

def var v-ind    as integer no-undo .

define variable v-ok as logical   no-undo .

&scop open-ld open query ld for each ld.
&scop open-nd open query nd for each nd where nd.num = ld.num.
&scop open-sel-nd {&open-nd} ~
      if available nd then do:~
        assign ~
          v-ok = nd:select-focused-row () ~
        . ~
      end.

/* уровень шкалы */
def temp-table ld no-undo
    field num  as integer                     /* Номер уровня */
    field ord  as integer                     /* Число признаков */
    field name like ub.gds-prt.node-name         /* Название уровня */
    index num is primary unique num .

/* узел шкалы */
def temp-table nd no-undo
    field num  as integer                     /* Номер уровня */
    field ord  as integer                     /* Номер признака */
    field name format "x(16)" like ub.gds-prt.node-name         /* Название признака */
    field new_ as logical init yes            /* Отметка, что признак только создан */
    index num  is primary unique num ord.

/*def temp-table prt like ub.gds-prt.*/

def query ld for ld .
def browse ld query ld
       disp ld.name
       with size 13 by 10 no-labels title "Уровни" separators .

def query nd for nd .
def browse nd query nd
       disp nd.name
       with size 19 by 10 no-labels title "Признаки" separators .

def button b-ok auto-go default
     LABEL "&Ввод"
     SIZE 10 BY 1.
def button b-cancel  auto-endkey
    label "&Отмена"
     SIZE 10 BY 1.
def button b-help
    label "Помо&щь"
     SIZE 10 BY 1.
def button b-add-ld
    label "Добав"
     SIZE 8 BY 1.
def button b-upd-ld
    label "Изм"
     SIZE 8 BY 1.
def button b-del-ld
    label "Удал"
     SIZE 8 BY 1.
def button b-ld-up
    label "Перест"
     SIZE 8 BY 1.
def button b-add-nd
    label "Добав"
     SIZE 8 BY 1.
def button b-upd-nd
    label "Изм"
     SIZE 8 BY 1.
def button b-del-nd
    label "Удал"
     SIZE 8 BY 1.
def button b-nd-up
    label "Перест"
     SIZE 8 BY 1.

def frame {&frame-name}
b-ok at row 1 col 1
b-cancel at row 1 col 11
b-help at row 1 col 21
sc-name at row 2.5 col 5
ld at row 4 col 11
nd at row 4 col 47
b-add-ld at row 14.5 col 2
b-upd-ld at row 14.5 col 10
b-del-ld at row 14.5 col 18
b-ld-up at row 14.5 col 26
b-add-nd at row 14.5 col 38
b-upd-nd at row 14.5 col 46
b-del-nd at row 14.5 col 54
b-nd-up at row 14.5 col 62
with view-as dialog-box scrollable side-labels three-d default-button b-ok
title "".

/* --------------- TRIGGERS --------------------- */
on row-display of nd do:
  if available nd
  and nd.new_ then do:
    assign
      name :fgcolor in browse nd = RED_COLOR .
    .
  end.
  else do:
    assign
      name :fgcolor in browse nd = BLACK_COLOR .
    .
  end.
end.


on choose of b-ld-up do:
    def var h1 as int no-undo.
    def var h2 as int no-undo.
    def var r as recid no-undo.

    if not available ld then do:
      return no-apply.
    end.
    assign
      r = recid(ld)
      h1 = ld.num
    .
    get prev  ld.
    if not available ld then do:
      return no-apply.
    end.

    assign
      h2 = ld.num
      ld.num = -2
    .

    find ld where recid( ld ) = r.
    assign
      ld.num  = h2
    .
    find ld where ld.num = -2 .
    assign
      ld.num  = h1
    .
    for each nd
      where nd.num = h2
    :
      assign
        nd.num = -2
      .
    end.

    for each nd
    where nd.num = h1
    :
      assign
        nd.num = h2
      .
    end.

    for each nd
      where nd.num = - 2
    :
      assign
        nd.num = h1
      .
    end.
    {&open-ld}
    reposition ld to recid r.
    define variable v-ok as logical   no-undo .
    assign
      v-ok = ld:select-focused-row( )
    .
    apply "value-changed":U to ld.
end.

on choose of b-nd-up do:

  def var r1    as recid     no-undo .
  def var h1    as integer   no-undo .
  def var name1 as character no-undo .
  def var r2    as recid     no-undo .
  def var h2    as integer   no-undo .
  def var name2 as character no-undo .

  if not available nd then do:
    return no-apply .
  end.
  if nd.new_ <> true then do:
    message
      "Нельзя менять порядок уже созданных признаков" skip
      view-as alert-box information .
    return no-apply .
  end.

  assign
    r1    = recid(nd)
    h1    = nd.ord
    name1 = nd.name
  .

  get prev  nd.
  if not available nd then do:
    return no-apply.
  end.
  if nd.new_ <> true then do:
    message
      "Нельзя менять порядок уже созданных признаков" skip
      "Нельзя поменять местами признаки" name1 "и" nd.name skip
      view-as alert-box information .
    find nd where recid( nd ) = r1.
    return no-apply .
  end.

  assign
    r2    = recid(nd)
    h2    = nd.ord
    name2 = nd.name
  .

  find nd where recid( nd ) = r1.
  assign
    nd.ord = ?
  .

  find nd where recid( nd ) = r2.
  assign
    nd.ord = h1
  .

  find nd where recid( nd ) = r1.
  assign
    nd.ord = h2
  .

  {&open-nd}
  reposition nd to recid r1.

  define variable v-ok as logical   no-undo .
  assign
    v-ok = nd :select-focused-row( )
  .
end.

on go of frame {&frame-name} do:

  def var ind  as integer no-undo init 0 .
  def var max_ as integer no-undo init 0 .
  def var j    as integer no-undo .

  if sc-name :screen-value = "" then do:
    message
      "Введите название шкалы."
      view-as alert-box error.
    apply "ENTRY":U to sc-name.
    return no-apply.
  end.
  if can-find (ub.gds-prt where
              ub.gds-prt.root = yes AND
              ub.gds-prt.node-name = sc-name:screen-value no-lock) and
    (mode = {&add-def} or
      mode = {&add-copy}) then do:
    message
      "Шкала с таким названием уже есть."
      view-as alert-box error.
    apply "ENTRY":U to sc-name.
    return no-apply.
  end.

  for each ld
  :
    accumulate ld (count).
    if not can-find (first nd where nd.num = ld.num) then do:
      message
        "На уровне" ld.name skip
        "нет признаков."
        view-as alert-box error.
      return no-apply.
    end.
  end.
  if (accum count ld) = 0 then do:
    message
      "В шкале не задан ни один из уровней." skip
      "В системе может быть только одна пустая шкала." skip
      view-as alert-box error.
    return no-apply.
  end.

  /* перенумерация уровней */
  for each ld
  :
    for each nd
      where nd.num = ld.num
    :
      assign
        nd.num = ind
      .
    end.
    assign
      ld.num = ind
      ind    = ind + 1
    .
  end.

  if mode = {&update} then do:
    find ub.gds-prt
      where ub.gds-prt.node-code = n-c
      .
    for each ld
    :
      find last nd
        where nd.num = ld.num
        use-index num .
      assign
        max_ = nd.ord
        j = 0
      .
      for each nd
        where nd.num = ld.num
          and nd.ord <= max_
        by nd.ord
      :
        assign
          j = j + 1
          nd.ord = max_ + j
        .
      end.
    end.
  end.

  run create-scale no-error.
  if error-status :error then do:
    return no-apply.
  end.
end.

on choose of b-add-ld do:
    def var rr as recid no-undo.

    run add-ld( output rr ).
    if rr <> ? then do:
       {&open-ld}
       reposition ld to recid rr.
       apply "value-changed":U to ld.
       define variable v-ok as logical   no-undo .
       assign
         v-ok = ld :select-focused-row( )
       .
    end.
end.

on choose of b-add-nd do:
    def var rr as recid no-undo.

    if not available ld THEN return no-apply.
    run add-nd( output rr ).
    if rr <> ? then do:
       {&open-sel-nd}
    end.
end.

on choose of b-ok do:
    message "Закончить ввод шкалы?" view-as alert-box question buttons yes-no
                     set OK as log .
    if not OK THEN return no-apply.
end.

on choose of b-del-nd do:
    def var  r as recid no-undo.
    def var  rr as recid no-undo.

    if not available nd THEN return.

    if nd.new_ <> true then do:
      message
        "Нельзя удалять уже созданный признак" skip
        view-as alert-box information .
      return .
    end.

     message "Удалить признак?" view-as alert-box question buttons yes-no
                      set OK as log .
     if not OK THEN return no-apply.
     r = recid( nd ).
     get prev nd.
     rr = recid( nd ).
     find nd where recid( nd )  = r.
     delete nd .
     {&open-nd}
     reposition nd to recid rr no-error.

     define variable v-ok as logical   no-undo .
     if available nd then do:
       assign
         v-ok = nd :select-focused-row() .
       .
     end.
end.

on choose of b-del-ld do:
     def var  r as recid no-undo.
     def var  rr as recid no-undo.

     if not available ld THEN return no-apply.
     message "Удалить признак?" view-as alert-box question buttons yes-no
                      set OK as log .
     if not OK THEN return no-apply.
     r = recid( ld ).
     get prev ld.
     rr = recid( ld ).
     find ld where recid( ld )  = r.
     for each nd where nd.num = ld.num:
         delete nd.
     end.
     delete ld .
     {&open-ld}
     reposition ld to recid rr no-error.
     define variable v-ok as logical   no-undo .
     if available ld then do:
       assign
         v-ok = ld:select-focused-row()
       .
     end.
     apply "value-changed":U to ld.
end.

on choose of b-upd-ld do:
    run upd-ld.
end.

on choose of b-upd-nd do:
    if not available nd THEN return.
    run upd-nd.
end.

ON WINDOW-CLOSE OF FRAME {&FRAME-NAME} APPLY "END-ERROR":U TO SELF.

on value-changed of ld in frame {&frame-name} do:
     {&open-sel-nd}
end.

/* ------------------- MAIN ------------------------ */

{ gbl/app_help.i }

frame {&frame-name} :title = "Шкала.                              " + mode.
if mode = {&add-copy} or
   mode = {&update} then do:
  /* изменение, копия */
  find gds-prt where gds-prt.node-code = n-c.
  if gds-prt.node-name = {&empty-scale} then do:
    message "Изменение пустой шкалы невозможно."
            view-as alert-box error.
    return.
  end.
  assign
    sc-name = gds-prt.node-name
    prt_root = gds-prt.upper-code
    .
  for each ub.lvl-name where ub.lvl-name.upper-code = ub.gds-prt.upper-code:
    create ld.
    assign
      ld.num = lvl-name.level
      ld.name = lvl-name.lvl-name
      .
  end.
  run prt-tree (n-c).
  disp sc-name with frame {&frame-name}.
end.
if mode = {&add-copy} or
   mode = {&add-def} then
  /* добавление, копия */
  enable b-add-ld b-del-ld b-upd-ld b-ld-up with frame {&frame-name}.

{&open-ld}

ld :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .
nd :SET-REPOSITIONED-ROW(5, "CONDITIONAL") .


enable sc-name ld nd b-ok b-cancel b-help
       b-add-nd b-del-nd b-upd-nd b-nd-up
       with frame {&frame-name}.
if available ld then do:
    v-ok = ld :select-focused-row() .
    apply "value-changed":U to ld.
end.
wait-for go of frame {&frame-name}.


/* --------------- PROCEDURES ------------------ */

procedure prt-tree:
/* -------------------------------------------------------------------
рекурсия без транзакции
заполнение временной таблицы узлов
- при копировании коды узлов не заполняются - будут генериться новые
------------------------------------------------------------------- */
def input param uc like ub.gds-prt.upper-code no-undo. /* код вышестоящего узла */
def buffer b-g-p for ub.gds-prt.
def var nc         as int no-undo.                  /* код текущего узла */
def var next-level as log no-undo.                  /* наличие вышестоящего узла */

/* ищем любой узел текущего уровня и заполняем инфо об уровне */
/* шкала точно не пустая, так что при первом вызове не отвалится */
find first b-g-p where b-g-p.upper-code = uc.
find ld where ld.num = b-g-p.lvl-num.
assign
  ld.ord = 0
  nc = b-g-p.node-code
  .
/* проверяем, есть ли следующий уровень */
if can-find (first b-g-p where b-g-p.upper-code = nc) then
  next-level = yes.
else
  next-level = no.
/* заполняем таблицу для всех узлов уровня */
for each b-g-p where b-g-p.upper-code = uc:
  if b-g-p.prt-num > ld.ord then
    ld.ord = b-g-p.prt-num.
  create nd.
  assign
    nd.num  = b-g-p.lvl-num
    nd.ord  = b-g-p.prt-num
    nd.name = b-g-p.node-name
    .
  if mode = {&update} then
    nd.new_ = no.
end.
/* обрабатываем следующий уровень, если он есть */
if next-level then
  run prt-tree (nc).
end procedure.

PROCEDURE create-nodes :
  /*

  процедура создания узлов шкалы одного уровн
  - корневой признак не создается,
  - при изменении создаются только новые признаки
  - при добавлении, копировании - все узлы шкалы (кроме корневого)

  */

  define input parameter p-curr-level     like nd.num              no-undo . /* номер обрабатываемого уровня */
  define input parameter p-upper-code     like ub.gds-prt.upper-code  no-undo . /* код родительского узла, к которому привязывается уровень */
  define input parameter p-prt-root       like ub.gds-prt.prt-root no-undo . /* указатель на корень шкалы */
  define input parameter p-parent-f-name  like ub.gds-prt.f-name      no-undo . /* полное имя родительского узла */
  define input parameter p-max-level      as integer  no-undo .  /* количество уровней шкалы */
  define input parameter p-subtree-create as logical  no-undo .  /* необходимо ли создавать все поддерево признаков */

  define buffer buf_gds-prt  for ub.gds-prt .
  define buffer buf_goods    for ub.goods .
  define buffer buf_bar-code for ub.bar-code .
  define buffer cur-node     for nd .          /* текущий узел (врем. табл.) */

  def var v-curr-f-name  as character no-undo. /* полное имя текущего узла */

  def var v-b-code like ub.bar-code.b-code no-undo .

  do
  on error undo, return error
  :

    for each cur-node
      where cur-node.num = p-curr-level
    on error undo, return error
    :
      /* вычисляем полное имя текущего узла */
      if p-parent-f-name = "" then do:
        assign
          v-curr-f-name = cur-node.name
        .
      end.
      else do:
        assign
          v-curr-f-name = p-parent-f-name + "/" + cur-node.name
        .
      end.

      if cur-node.new_
      or p-subtree-create then do:
        /* создаем узел шкалы в БД */
        assign
          v-ind = v-ind + 1
        .
        if p-curr-level = p-max-level
        and (v-ind mod 10 = 0)
        then do:
          run waitfram-show in this-procedure
            (input "Создаем узел шкалы: " + v-curr-f-name
            ).
        end.

        do transaction
        on error undo, return error
        :
          create buf_gds-prt.
          assign
            buf_gds-prt.lvl-num    = p-curr-level
            buf_gds-prt.upper-code = p-upper-code
            buf_gds-prt.node-code  = next-value (s-gds-prt, {&db-name_schema})
            buf_gds-prt.node-name  = cur-node.name
            buf_gds-prt.f-name     = v-curr-f-name
            buf_gds-prt.prt-num    = cur-node.ord
            buf_gds-prt.root       = false
            buf_gds-prt.prt-root   = p-prt-root
            buf_gds-prt.is-term    = (p-curr-level = p-max-level )
          .
        end.
      end.
      else do:
        /* если мы рассматриваем не терминальный признак */
        /* то находим узел шкалы в БД */
        if p-curr-level < p-max-level  then do:
          find first buf_gds-prt no-lock
            where buf_gds-prt.upper-code = p-upper-code
              and buf_gds-prt.node-name  = cur-node.name
            .
        end.
      end.

      if p-curr-level < p-max-level then do:
        run create-nodes in this-procedure
          (input cur-node.num + 1                   /* p-curr-level     */
          ,input buf_gds-prt.node-code              /* p-upper-code     */
          ,input p-prt-root                         /* p-prt-root       */
          ,input v-curr-f-name                      /* p-parent-f-name  */
          ,input p-max-level                        /* p-max-level      */
          ,input cur-node.new_ or p-subtree-create  /* p-subtree-create */
          ) no-error.
        if error-status :error then do:
          undo, return error.
        end.
      end.
    end.
  end.
END PROCEDURE.    /* create-nodes */


PROCEDURE create-scale :

  do
  on error undo, return error
  :
    /* определяем количество уровней */
    def var v-max-level as integer no-undo .

    assign
      v-max-level = 0
    .
    for each ld
    :
      assign
        v-max-level = v-max-level + 1
      .
    end.

    if mode = {&add-def}
    or mode = {&add-copy}
    then do:
      /* добавление, копирование */
      /* создаем корневой узел */
      create ub.gds-prt.
      assign
        ub.gds-prt.lvl-num    = 0
        ub.gds-prt.upper-code = next-value (s-gds-prt, {&db-name_schema})
        ub.gds-prt.node-code  = next-value (s-gds-prt, {&db-name_schema})
        ub.gds-prt.node-name  = input frame {&frame-name} sc-name
        ub.gds-prt.prt-num    = 0
        ub.gds-prt.root       = true
        ub.gds-prt.prt-root   = ub.gds-prt.upper-code
        ub.gds-prt.is-term    = (ub.gds-prt.lvl-num = v-max-level)

        rid                = recid (gds-prt)
        prt_root           = ub.gds-prt.upper-code
      .
      for each ld :
        create ub.lvl-name.
        assign
          ub.lvl-name.level      = ld.num
          ub.lvl-name.lvl-name   = ld.name
          ub.lvl-name.upper-code = ub.gds-prt.upper-code
          .
      end.
    end.
    assign
      rid = recid (gds-prt)
      ub.gds-prt.node-name = input frame {&frame-name} sc-name
    .

    /* создаем остальные узлы шкалы, или новые узлы, добавленные при изменении */
    run create-nodes
      (input 0                 /* p-curr-level     */
      ,input gds-prt.node-code /* p-upper-code     */
      ,input gds-prt.prt-root  /* p-prt-root       */
      ,input ""                /* p-parent-f-name  */
      ,input v-max-level - 1   /* p-max-level      */
      ,input false             /* p-subtree-create */
      ) no-error.
    if error-status :error then do:
      run waitfram-hide in this-procedure .
      undo, return error .
    end.
    run waitfram-hide in this-procedure .
  end.

END PROCEDURE.    /* create-scale */

PROCEDURE add-ld:  /*___________ add-ld _______________*/
   def output param ri as recid no-undo init ?.
   def button b-ok  auto-go default  size 10 by 1
       label "&Ввод ".
   def button b-cancel  auto-endkey  size 10 by 1
       label "&Отмена".
    form  b-ok   at 1 b-cancel at 11 skip
            ld.name  label "Название"
            space( 0.2 ) skip( 0.2 )
            space( 0.2 )
            with frame add-ld three-d side-labels  view-as dialog-box default-button b-ok
                     title "У Р О В Е Н Ь".

    on window-close of frame add-ld apply "end-error" to self.
    on go of frame add-ld do:
        if input ld.name = "" then do:
            message "Введите название" view-as alert-box.
            return no-apply.
        end.
        if can-find( first ld where ld.name = input frame add-ld  ld.name ) then do:
            message "Уровень" input ld.name "уже есть" view-as alert-box.
            return no-apply.
        end.
        create ld.
        assign ld-n = ld-n + 1
                    ld.num  = ld-n
                    ld.name
                    ri = recid( ld ).
    end.

    enable /*ld.num*/ ld.name b-ok b-cancel with frame add-ld.
    wait-for go of frame add-ld.
END PROCEDURE.    /* add-ld */

PROCEDURE add-nd: /*___________ add-nd ___________________*/
   def output param ri as recid no-undo init ?.
   def button b-ok  auto-go default size 10 by 1
       label "&Ввод".
   def button b-cancel  auto-endkey size 10 by 1
       label "&Отмена".
    form b-ok  at 1 b-cancel at 11
            skip
            nd.name label "Название"
            space( 0.2 ) skip( 0.2 )
            space( 0.2 )

            with frame add-nd three-d side-labels  view-as dialog-box default-button b-ok
                   title "П Р И З Н А К".

    on window-close of frame add-nd apply "end-error" to self.
    on go of frame add-nd do:
        if input nd.name = "" then do:
            message "Введите название" view-as alert-box.
            return no-apply.
        end.
        if can-find( first nd where nd.num = ld.num
                                         AND nd.name = input frame add-nd  nd.name ) then do:
            message "Признак" input nd.name "уже есть" view-as alert-box.
            return no-apply.
        end.
        create nd.
        assign ld.ord = ld.ord + 1
                    nd.ord = ld.ord
                    nd.num  = ld.num
                    nd.name
                    ri = recid( nd ).
    end.

    enable /*nd.num*/ nd.name b-ok b-cancel with frame add-nd.
    wait-for go of frame add-nd.
END PROCEDURE.    /* add-nd */

PROCEDURE upd-ld: /*__________________ upd-ld ___________________*/
   def var ri as recid no-undo .
   def button b-ok  auto-go default
       label "&Ввод".
   def button b-cancel  auto-endkey
       label "&Отмена".
    form  b-ok   at 1 b-cancel at 11
            skip
            ld.name  label "Название"
            space( 0.2 ) skip( 0.2 )
            space( 0.2 )

            with frame add-ld three-d side-labels  view-as dialog-box default-button b-ok
                     title "У Р О В Е Н Ь -- изменение".

    on window-close of frame add-ld apply "end-error" to self.
    on go of frame add-ld do:
        if input ld.name = "" then do:
            message "Введите название" view-as alert-box.
            return no-apply.
        end.
        if can-find( first ld where ld.name = input frame add-ld  ld.name
                                        AND recid( ld ) <> ri ) then do:
            message "Уровень" input ld.name "уже есть" view-as alert-box.
            return no-apply.
        end.
        assign ld.name.
        disp ld.name with browse ld.
    end.

    if not available ld THEN return.
    ri = recid( ld ).
    disp ld.name with frame add-ld.
    enable  ld.name b-ok b-cancel with frame add-ld.
    wait-for go of frame add-ld.
END PROCEDURE.    /* upd-ld */

PROCEDURE upd-nd:  /*______________ upd-nd _______________*/
   def var ri as recid no-undo .

   if not available nd then do:
     return .
   end.

   if nd.new_ <> true then do:
     message
       "Нельзя менять название уже созданного признака" skip
       view-as alert-box information .
     return .
   end.

   def button b-ok  auto-go default
       label "&Ввод".
   def button b-cancel  auto-endkey
       label "&Отмена".
    form  b-ok at 1 b-cancel at 11
    skip
            nd.name label "Название"
            space( 0.2 ) skip( 0.2 )
            space( 0.2 )
            with frame add-nd three-d side-labels  view-as dialog-box default-button b-ok
                   title "П Р И З Н А К -- изменение".

    on window-close of frame add-nd apply "end-error" to self.
    on go of frame add-nd do:
        if input nd.name = "" then do:
            message "Введите название" view-as alert-box.
            return no-apply.
        end.
        if can-find( first nd where nd.num = ld.num
                                         AND nd.name = input frame add-nd  nd.name
                                         AND recid( nd ) <> ri ) then do:
            message "Признак" input nd.name "уже есть" view-as alert-box.
            apply "entry":U to nd.name.
            return no-apply.
        end.
        assign nd.name.
        disp nd.name with browse nd.
    end.

    if not available nd THEN return.
    ri = recid( nd ).
    disp nd.name with frame add-nd.
    enable nd.name b-ok b-cancel with frame add-nd.
    wait-for go of frame add-nd.
END PROCEDURE.    /* upd-nd */