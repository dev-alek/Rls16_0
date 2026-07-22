block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00055000.p $
$Archive: cut/00055000.p $

Файл пирога обрезания. Относится к категории 55.

Автор: Чернова Светлана Александровна
Дата создания: 08/05/09
Author: Svetlana Chernova
Creation date: 08/05/09

Обработка таблиц:
fbr-doc
fbr-line

doc-fbr-gds-attr

*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00055000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00055000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 10.".
{ cmp/str-glbl.i }
{ utl/tt-objs.i  }

    define buffer buf_new_clients       for dst.clients.
    define buffer buf_old_fbr-doc       for src.fbr-doc.
    define buffer buf_old_fbr-pln       for src.fbr-pln.
    define buffer buf_old_fbr-gds-obj           for src.fbr-gds-obj.
    define buffer buf_new_fbr-gds-obj           for dst.fbr-gds-obj.
    define buffer buf_old_c-fbr-gds-obj         for src.c-fbr-gds-obj.
    define buffer buf_new_c-fbr-gds-obj         for dst.c-fbr-gds-obj.
    define buffer buf_old_fbr-gds-obj-attr           for src.fbr-gds-obj-attr.
    define buffer buf_new_fbr-gds-obj-attr           for dst.fbr-gds-obj-attr.
    define buffer buf_old_c-fbr-gds-obj-attr         for src.c-fbr-gds-obj-attr.
    define buffer buf_new_c-fbr-gds-obj-attr         for dst.c-fbr-gds-obj-attr.
    define buffer new-doc-fbr-gds for dst.doc-fbr-gds.
define buffer old-doc-fbr-gds-attr for src.doc-fbr-gds-attr.
define buffer new-doc-fbr-gds-attr for dst.doc-fbr-gds-attr.


    define buffer buf_new_goods     for dst.goods.
do
for buf_new_clients
  , buf_old_fbr-doc
  , buf_old_fbr-pln
  , buf_old_fbr-gds-obj
  , buf_new_fbr-gds-obj
  , buf_old_c-fbr-gds-obj
  , buf_new_c-fbr-gds-obj
  , buf_old_fbr-gds-obj-attr
  , buf_new_fbr-gds-obj-attr
  , buf_old_c-fbr-gds-obj-attr
  , buf_new_c-fbr-gds-obj-attr
  , buf_new_goods
on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
:
{ utl/00000001.i }

on WRITE of dst.fbr-doc  override do: end.
on WRITE of dst.fbr-line override do: end.
on WRITE of dst.fbr-pln override do: end.
on WRITE of dst.fbr-gds-obj override do: end.
on WRITE of dst.c-fbr-gds-obj override do: end.
on WRITE of dst.fbr-gds-obj-attr override do: end.
on WRITE of dst.c-fbr-gds-obj-attr override do: end.
on WRITE of dst.doc-fbr-gds-attr override DO: END.
on WRITE of dst.c-gds-hist override DO: END.



    for each buf_new_clients no-lock
       where buf_new_clients.db-num <> ?
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
        if vartype-cut = 1
        then do:
            find first tt-objs
                 where tt-objs.obj-type = buf_new_clients.obj-type
                   and tt-objs.obj-code = buf_new_clients.obj-code
            no-error.
        end.
        if vartype-cut = 0
        or ( vartype-cut = 1 and available tt-objs )
        then do:        /* старое обрезание или объект есть в списке */
            for each buf_old_fbr-gds-obj no-lock
               where buf_old_fbr-gds-obj.obj-type = buf_new_clients.obj-type
                 and buf_old_fbr-gds-obj.obj-code = buf_new_clients.obj-code
            on error undo, return error
            :
                find first buf_new_goods no-lock
                     where buf_new_goods.gds-code = buf_old_fbr-gds-obj.gds-code
                no-error.
                if available buf_new_goods
                then do:
                    create buf_new_fbr-gds-obj.
                    buffer-copy buf_old_fbr-gds-obj to buf_new_fbr-gds-obj.
                    if varstay-history then do:
                      for each buf_old_c-fbr-gds-obj no-lock
                        where buf_old_c-fbr-gds-obj.obj-type = buf_old_fbr-gds-obj.obj-type
                          and buf_old_c-fbr-gds-obj.obj-code = buf_old_fbr-gds-obj.obj-code
                          and buf_old_c-fbr-gds-obj.gds-code = buf_old_fbr-gds-obj.gds-code
                      on error undo, return error
                      :
                          create buf_new_c-fbr-gds-obj.
                          buffer-copy buf_old_c-fbr-gds-obj to buf_new_c-fbr-gds-obj.
                      end.        /* for each buf_old_c-fbr-gds-obj */
                      for each buf_old_c-fbr-gds-obj-attr no-lock
                        where buf_old_c-fbr-gds-obj-attr.obj-type = buf_old_fbr-gds-obj-attr.obj-type
                          and buf_old_c-fbr-gds-obj-attr.obj-code = buf_old_fbr-gds-obj-attr.obj-code
                          and buf_old_c-fbr-gds-obj-attr.gds-code = buf_old_fbr-gds-obj-attr.gds-code
                      on error undo, return error
                      :
                          create buf_new_c-fbr-gds-obj-attr.
                          buffer-copy buf_old_c-fbr-gds-obj-attr to buf_new_c-fbr-gds-obj-attr.
                      end.        /* for each buf_old_c-fbr-gds-obj-attr */
                    end.
                    for each buf_old_fbr-gds-obj-attr no-lock
                       where buf_old_fbr-gds-obj-attr.obj-type = buf_old_fbr-gds-obj.obj-type
                         and buf_old_fbr-gds-obj-attr.obj-code = buf_old_fbr-gds-obj.obj-code
                         and buf_old_fbr-gds-obj-attr.gds-code = buf_old_fbr-gds-obj.gds-code
                    on error undo, return error
                    :
                        create buf_new_fbr-gds-obj-attr.
                        buffer-copy buf_old_fbr-gds-obj-attr to buf_new_fbr-gds-obj-attr.
                    end.        /* for each buf_old_fbr-gds-obj-attr */
                end.
            end.        /* for each buf_old_fbr-gds-obj */
            if vardate-actual-docs <> ?
            then do:
                for each buf_old_fbr-doc no-lock
                   where buf_old_fbr-doc.obj-type = buf_new_clients.obj-type
                     and buf_old_fbr-doc.obj-code = buf_new_clients.obj-code
                     and buf_old_fbr-doc.fact-date >= vardate-actual-docs
                on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
                :
                    run copy-records-to-new in this-procedure (
                        input rowid( buf_old_fbr-doc )
                    ).
                end.
                for each buf_old_fbr-pln no-lock
                   where buf_old_fbr-pln.obj-type = buf_new_clients.obj-type
                     and buf_old_fbr-pln.obj-code = buf_new_clients.obj-code
                     and buf_old_fbr-pln.fact-date >= vardate-actual-docs
                on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
                :
                    run copy-fbr-pln-to-new in this-procedure (
                        input rowid( buf_old_fbr-pln )
                    ).
                end.        /* for each buf_old_fbr-pln */
            end.
        end.
        else do:        /* объекта нет в списке - переносим все записи */
            for each buf_old_fbr-doc no-lock
               where buf_old_fbr-doc.obj-type = buf_new_clients.obj-type
                 and buf_old_fbr-doc.obj-code = buf_new_clients.obj-code
            on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
            :
                run copy-records-to-new in this-procedure (
                    input rowid( buf_old_fbr-doc )
                ).
            end.
            for each buf_old_fbr-pln no-lock
               where buf_old_fbr-pln.obj-type = buf_new_clients.obj-type
                 and buf_old_fbr-pln.obj-code = buf_new_clients.obj-code
            on error undo, return error substitute("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
            :
                run copy-fbr-pln-to-new in this-procedure (
                    input rowid( buf_old_fbr-pln )
                ).
            end.        /* for each buf_old_fbr-pln */
        end.
    end.

    for each old-doc-fbr-gds-attr
        no-lock
        :

       FIND first new-doc-fbr-gds
            where new-doc-fbr-gds.obj-type     = old-doc-fbr-gds-attr.obj-type
            and new-doc-fbr-gds.obj-code     = old-doc-fbr-gds-attr.obj-code
            and new-doc-fbr-gds.fbr-obj-type = old-doc-fbr-gds-attr.fbr-obj-type
            and new-doc-fbr-gds.fbr-obj-code = old-doc-fbr-gds-attr.fbr-obj-code
            and new-doc-fbr-gds.out-code     = old-doc-fbr-gds-attr.out-code
            no-lock
            no-error
            .

       IF AVAILABLE new-doc-fbr-gds
       THEN DO:
         create new-doc-fbr-gds-attr.
         BUFFER-COPY old-doc-fbr-gds-attr to new-doc-fbr-gds-attr.
       END.
    end.
    output stream str-gen close.
    return "Произведен экспорт таблиц: fbr-doc fbr-line recipe-develop fbr-pln fbr-pln-line fbr-history doc-fbr-gds-attr.".
end.

/*==========================================================================*/
procedure copy-fbr-pln-to-new :
define input parameter p-old-fbr-pln-rowid  as rowid            no-undo.

    define variable v-need-copy-fbr-line          as logical      no-undo.

    define buffer buf_old_fbr-pln               for src.fbr-pln.
    define buffer buf_new_fbr-pln               for dst.fbr-pln.
    define buffer buf_old_c-fbr-pln               for src.c-fbr-pln.
    define buffer buf_new_c-fbr-pln               for dst.c-fbr-pln.
    define buffer buf_old_fbr-pln-line          for src.fbr-pln-line.
    define buffer buf_new_fbr-pln-line          for dst.fbr-pln-line.
    define buffer buf_old_c-fbr-pln-line          for src.c-fbr-pln-line.
    define buffer buf_new_c-fbr-pln-line          for dst.c-fbr-pln-line.
    define buffer buf_old_fbr-history           for src.fbr-history.
    define buffer buf_new_fbr-history           for dst.fbr-history.
    define buffer buf_new_test_fbr-history      for dst.fbr-history.
    define buffer buf_old_c-doc-fbr-gds         for src.c-doc-fbr-gds.
    define buffer buf_new_c-doc-fbr-gds         for dst.c-doc-fbr-gds.
    define buffer buf_new_test_c-doc-fbr-gds    for dst.c-doc-fbr-gds.
    define buffer buf_new_goods                 for dst.goods.
do
for buf_old_fbr-pln
  , buf_new_fbr-pln
  , buf_old_c-fbr-pln
  , buf_new_c-fbr-pln
  , buf_old_fbr-pln-line
  , buf_new_fbr-pln-line
  , buf_old_c-fbr-pln-line
  , buf_new_c-fbr-pln-line
  , buf_old_fbr-history
  , buf_new_fbr-history
  , buf_new_test_fbr-history
  , buf_old_c-doc-fbr-gds
  , buf_new_c-doc-fbr-gds
  , buf_new_test_c-doc-fbr-gds
  , buf_new_goods
on error undo, return error
:
    find first buf_old_fbr-pln no-lock
         where rowid( buf_old_fbr-pln ) = p-old-fbr-pln-rowid
    .
           for each buf_old_c-fbr-pln no-lock
              where buf_old_c-fbr-pln.doc-code  = buf_old_fbr-pln.doc-code
            on error undo, return error
            :
              create buf_new_c-fbr-pln.
              buffer-copy buf_old_c-fbr-pln to buf_new_c-fbr-pln.
            end.

    create buf_new_fbr-pln.
    buffer-copy buf_old_fbr-pln to buf_new_fbr-pln.
    assign
        v-need-copy-fbr-line = yes
    .
    for each buf_old_fbr-pln-line no-lock
       where buf_old_fbr-pln-line.doc-code = buf_old_fbr-pln.doc-code
    on error undo, return error
    :
        find first buf_new_goods no-lock
             where buf_new_goods.gds-code = buf_old_fbr-pln-line.gds-code
        no-error.
        if not available buf_new_goods
        then do:
            assign
                v-need-copy-fbr-line = no
            .
        end.
    end.        /* for each buf_old_fbr-pln-line */
    if v-need-copy-fbr-line = yes
    then do:
        for each buf_old_fbr-pln-line no-lock
           where buf_old_fbr-pln-line.doc-code = buf_old_fbr-pln.doc-code
        on error undo, return error
        :

            for each buf_old_c-fbr-pln-line no-lock
              where buf_old_c-fbr-pln-line.doc-code = buf_old_fbr-pln.doc-code and
                    buf_old_c-fbr-pln-line.fbr-obj-type = buf_old_fbr-pln-line.fbr-obj-type  and
                    buf_old_c-fbr-pln-line.fbr-obj-code = buf_old_fbr-pln-line.fbr-obj-code  and
                    buf_old_c-fbr-pln-line.gds-code     = buf_old_fbr-pln-line.gds-code      and
                    buf_old_c-fbr-pln-line.recipe-code  = buf_old_fbr-pln-line.recipe-code
            on error undo, return error
            :
              create buf_new_c-fbr-pln-line.
              buffer-copy buf_old_c-fbr-pln-line to buf_new_c-fbr-pln-line.
            end.
            create buf_new_fbr-pln-line.
            buffer-copy buf_old_fbr-pln-line to buf_new_fbr-pln-line.

            for each buf_old_c-doc-fbr-gds no-lock
               where buf_old_c-doc-fbr-gds.obj-type = buf_old_fbr-pln.obj-type
                 and buf_old_c-doc-fbr-gds.obj-code = buf_old_fbr-pln.obj-code
                 and buf_old_c-doc-fbr-gds.gds-code = buf_old_fbr-pln-line.gds-code
            on error undo, return error
            :
                find first buf_new_test_c-doc-fbr-gds no-lock
                     where buf_new_test_c-doc-fbr-gds.obj-type     = buf_old_c-doc-fbr-gds.obj-type
                       and buf_new_test_c-doc-fbr-gds.obj-code     = buf_old_c-doc-fbr-gds.obj-code
                       and buf_new_test_c-doc-fbr-gds.fbr-obj-type = buf_old_c-doc-fbr-gds.fbr-obj-type
                       and buf_new_test_c-doc-fbr-gds.fbr-obj-code = buf_old_c-doc-fbr-gds.fbr-obj-code
                       and buf_new_test_c-doc-fbr-gds.out-code     = buf_old_c-doc-fbr-gds.out-code
                       and buf_new_test_c-doc-fbr-gds.chip-num     = buf_old_c-doc-fbr-gds.chip-num
                       and buf_new_test_c-doc-fbr-gds.gds-code     = buf_old_c-doc-fbr-gds.gds-code
                no-error.
                if not available buf_new_test_c-doc-fbr-gds
                then do:
                    create buf_new_c-doc-fbr-gds.
                    buffer-copy buf_old_c-doc-fbr-gds to buf_new_c-doc-fbr-gds.
                end.
            end.        /* for each buf_old_c-doc-fbr-gds */
        end.        /* for each buf_old_fbr-pln-line */
    end.
    for each buf_old_fbr-history no-lock
       where buf_old_fbr-history.obj-type = buf_old_fbr-pln.obj-type
         and buf_old_fbr-history.obj-code = buf_old_fbr-pln.obj-code
         and buf_old_fbr-history.doc-code = buf_old_fbr-pln.doc-code
    on error undo, return error
    :
        find first buf_new_test_fbr-history no-lock
             where buf_new_test_fbr-history.obj-type = buf_old_fbr-pln.obj-type
               and buf_new_test_fbr-history.obj-code = buf_old_fbr-pln.obj-code
               and buf_new_test_fbr-history.hst-code = buf_old_fbr-history.hst-code
        no-error.
        if not available buf_new_test_fbr-history
        then do:
            create buf_new_fbr-history.
            buffer-copy buf_old_fbr-history to buf_new_fbr-history.
        end.
    end.        /* for each buf_old_fbr-history */
end.
end procedure. /* copy-fbr-pln-to-new */

/*==========================================================================*/
procedure copy-records-to-new :
define input parameter p-old-fbr-doc-rowid  as rowid            no-undo.

    define variable v-need-copy-fbr-line          as logical      no-undo.
    define variable v-need-copy-recipe-develop    as logical      no-undo.

    define buffer buf_old_fbr-doc               for src.fbr-doc.
    define buffer buf_new_fbr-doc               for dst.fbr-doc.
    define buffer buf_old_fbr-line              for src.fbr-line.
    define buffer buf_new_fbr-line              for dst.fbr-line.
    define buffer buf_old_fbr-recipe            for src.fbr-recipe.
    define buffer buf_new_fbr-recipe            for dst.fbr-recipe.
    define buffer buf_old_fbr-recipe-gds        for src.fbr-recipe-gds.
    define buffer buf_new_fbr-recipe-gds        for dst.fbr-recipe-gds.
    define buffer buf_old_recipe-develop        for src.recipe-develop.
    define buffer buf_new_recipe-develop        for dst.recipe-develop.
    define buffer buf_old_fbr-history           for src.fbr-history.
    define buffer buf_new_fbr-history           for dst.fbr-history.
    define buffer buf_new_test_fbr-history      for dst.fbr-history.
    define buffer buf_old_c-doc-fbr-gds         for src.c-doc-fbr-gds.
    define buffer buf_new_c-doc-fbr-gds         for dst.c-doc-fbr-gds.
    define buffer buf_new_test_c-doc-fbr-gds    for dst.c-doc-fbr-gds.

    define buffer buf_new_goods     for dst.goods.
do
for buf_old_fbr-doc
  , buf_new_fbr-doc
  , buf_old_fbr-line
  , buf_new_fbr-line
  , buf_old_fbr-recipe
  , buf_new_fbr-recipe
  , buf_old_fbr-recipe-gds
  , buf_new_fbr-recipe-gds
  , buf_old_recipe-develop
  , buf_new_recipe-develop
  , buf_old_fbr-history
  , buf_new_fbr-history
  , buf_new_test_fbr-history
  , buf_old_c-doc-fbr-gds
  , buf_new_c-doc-fbr-gds
  , buf_new_test_c-doc-fbr-gds
  , buf_new_goods
on error undo, return error
:
    find first buf_old_fbr-doc no-lock
         where rowid( buf_old_fbr-doc ) = p-old-fbr-doc-rowid
    .
    create buf_new_fbr-doc.
    buffer-copy buf_old_fbr-doc to buf_new_fbr-doc.

    assign
        v-need-copy-fbr-line    = yes
    .
    for each buf_old_fbr-line no-lock
       where buf_old_fbr-line.doc-code = buf_old_fbr-doc.doc-code
    :
        find first buf_new_goods no-lock
             where buf_new_goods.artic     = buf_old_fbr-line.artic
               and buf_new_goods.prod-type = buf_old_fbr-line.prod-type
               and buf_new_goods.prod-code = buf_old_fbr-line.prod-code
        no-error.
        if not available buf_new_goods
        then do:
            assign
                v-need-copy-fbr-line    = no
            .
        end.
    end.
    if v-need-copy-fbr-line    = yes
    then do:
        for each buf_old_fbr-line no-lock
        where buf_old_fbr-line.doc-code = buf_old_fbr-doc.doc-code
        :
            create buf_new_fbr-line.
            buffer-copy buf_old_fbr-line to buf_new_fbr-line.
            find first buf_new_goods no-lock
                 where buf_new_goods.artic     = buf_old_fbr-line.artic
                   and buf_new_goods.prod-type = buf_old_fbr-line.prod-type
                   and buf_new_goods.prod-code = buf_old_fbr-line.prod-code
            .
            for each buf_old_c-doc-fbr-gds no-lock
               where buf_old_c-doc-fbr-gds.obj-type = buf_old_fbr-doc.obj-type
                 and buf_old_c-doc-fbr-gds.obj-code = buf_old_fbr-doc.obj-code
                 and buf_old_c-doc-fbr-gds.gds-code = buf_new_goods.gds-code
            on error undo, return error
            :
                find first buf_new_test_c-doc-fbr-gds no-lock
                     where buf_new_test_c-doc-fbr-gds.obj-type     = buf_old_c-doc-fbr-gds.obj-type
                       and buf_new_test_c-doc-fbr-gds.obj-code     = buf_old_c-doc-fbr-gds.obj-code
                       and buf_new_test_c-doc-fbr-gds.fbr-obj-type = buf_old_c-doc-fbr-gds.fbr-obj-type
                       and buf_new_test_c-doc-fbr-gds.fbr-obj-code = buf_old_c-doc-fbr-gds.fbr-obj-code
                       and buf_new_test_c-doc-fbr-gds.out-code     = buf_old_c-doc-fbr-gds.out-code
                       and buf_new_test_c-doc-fbr-gds.chip-num     = buf_old_c-doc-fbr-gds.chip-num
                       and buf_new_test_c-doc-fbr-gds.gds-code     = buf_old_c-doc-fbr-gds.gds-code
                no-error.
                if not available buf_new_test_c-doc-fbr-gds
                then do:
                    create buf_new_c-doc-fbr-gds.
                    buffer-copy buf_old_c-doc-fbr-gds to buf_new_c-doc-fbr-gds.
                end.
            end.        /* for each buf_old_c-doc-fbr-gds */
            if buf_old_fbr-line.recipe-code <> ?
            and buf_old_fbr-line.recipe-code <> "":U
            then do:
                if buf_old_fbr-line.is-comp = yes
                then do:
                    assign
                        v-need-copy-recipe-develop = yes
                    .
                    for each buf_old_recipe-develop no-lock
                       where buf_old_recipe-develop.recipe-code = buf_old_fbr-line.recipe-code
                         and buf_old_recipe-develop.doc-code    = buf_old_fbr-line.doc-code
                    on error undo, return error
                    :
                        find first buf_new_goods no-lock
                             where buf_new_goods.gds-code = buf_old_recipe-develop.gds-code
                        no-error.
                        if not available buf_new_goods
                        then do:
                            assign
                                v-need-copy-recipe-develop = no
                            .
                        end.
                    end.        /* for each buf_old_recipe-develop */
                    if v-need-copy-recipe-develop = yes
                    then do:
                        for each buf_old_recipe-develop no-lock
                           where buf_old_recipe-develop.recipe-code = buf_old_fbr-line.recipe-code
                             and buf_old_recipe-develop.doc-code    = buf_old_fbr-line.doc-code
                        on error undo, return error
                        :
                            create buf_new_recipe-develop.
                            buffer-copy buf_old_recipe-develop to buf_new_recipe-develop.
                        end.        /* for each buf_old_recipe-develop */
                    end.
                end.
                find first buf_new_fbr-recipe no-lock
                     where buf_new_fbr-recipe.doc-code      = buf_old_fbr-line.doc-code
                       and buf_new_fbr-recipe.recipe-code   = buf_old_fbr-line.recipe-code
                no-error.
                if not available buf_new_fbr-recipe
                then do:
                    for each buf_old_fbr-recipe no-lock
                    where buf_old_fbr-recipe.doc-code    = buf_old_fbr-line.doc-code
                        and buf_old_fbr-recipe.recipe-code = buf_old_fbr-line.recipe-code
                    :
                        create buf_new_fbr-recipe.
                        buffer-copy buf_old_fbr-recipe to buf_new_fbr-recipe.
                        for each buf_old_fbr-recipe-gds no-lock
                           where buf_old_fbr-recipe-gds.doc-code    = buf_old_fbr-recipe.doc-code
                             and buf_old_fbr-recipe-gds.recipe-code = buf_old_fbr-recipe.recipe-code
                        on error undo, return error
                        :
                            create buf_new_fbr-recipe-gds.
                            buffer-copy buf_old_fbr-recipe-gds to buf_new_fbr-recipe-gds.
                        end.        /* for each buf_old_fbr-recipe-gds */
                    end.
                end.
            end.
        end.
    end.        /* v-need-copy-fbr-line    = yes */
    for each buf_old_fbr-history no-lock
       where buf_old_fbr-history.obj-type = buf_old_fbr-doc.obj-type
         and buf_old_fbr-history.obj-code = buf_old_fbr-doc.obj-code
         and buf_old_fbr-history.doc-code = buf_old_fbr-doc.doc-code
    on error undo, return error
    :
        find first buf_new_test_fbr-history no-lock
             where buf_new_test_fbr-history.obj-type = buf_old_fbr-doc.obj-type
               and buf_new_test_fbr-history.obj-code = buf_old_fbr-doc.obj-code
               and buf_new_test_fbr-history.hst-code = buf_old_fbr-history.hst-code
        no-error.
        if not available buf_new_test_fbr-history
        then do:
            create buf_new_fbr-history.
            buffer-copy buf_old_fbr-history to buf_new_fbr-history.
        end.
    end.        /* for each buf_old_fbr-history */
end.
end procedure. /* copy-records-to-new */