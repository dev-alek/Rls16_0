block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: 00145000.p $
$Archive: cut/00145000.p $

Файл пирога обрезания. Относится к категории 145.

Автор: Чернова Светлана Александровна
Дата создания: 08/05/09
Author: Svetlana Chernova
Creation date: 08/05/09

Обработка таблиц:
recipe
recipe-gds
s-coeff
c-s-coeff
s-coeff-attr
fbr-gds-grp
c-fbr-gds-grp
fbr-gds-grp-attr
c-fbr-gds-grp-attr
c-fbr-gds-grp-hist
dish-grp
dish-grp-attr
fbr-prn
c-fbr-prn
fbr-prn-attr
fbr-prn-attr
fbr-prn-gds
c-fbr-prn-gds
fbr-prn-gds-attr
fbr-prn-grp
c-fbr-prn-grp
fbr-prn-grp-attr
recipe-develop
c-recipe
c-recipe-develop
c-recipe-gds
c-recipe-hist


*/

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: 00145000.p $":U .
define variable vss-archive     as character no-undo init "$Archive: cut/00145000.p $".
define variable vss-description as character no-undo init "Файл пирога обрезания. Относится к категории 145.".
{ cmp/str-glbl.i }

    define variable v-moved-recipe as logical no-undo.

    define buffer old-recipe            for src.recipe    .
    define buffer new-recipe            for dst.recipe    .
    define buffer old-recipe-gds        for src.recipe-gds.
    define buffer new-recipe-gds        for dst.recipe-gds.
    define buffer old-s-coeff           for src.s-coeff.
    define buffer new-s-coeff           for dst.s-coeff.
    define buffer old-c-s-coeff         for src.c-s-coeff.
    define buffer new-c-s-coeff         for dst.c-s-coeff.
    define buffer old-s-coeff-attr      for src.s-coeff-attr.
    define buffer new-s-coeff-attr      for dst.s-coeff-attr.
    define buffer old-fbr-gds-grp       for src.fbr-gds-grp.
    define buffer new-fbr-gds-grp       for dst.fbr-gds-grp.
    define buffer old-c-fbr-gds-grp     for src.c-fbr-gds-grp.
    define buffer new-c-fbr-gds-grp     for dst.c-fbr-gds-grp.
    define buffer old-fbr-gds-grp-attr  for src.fbr-gds-grp-attr.
    define buffer new-fbr-gds-grp-attr  for dst.fbr-gds-grp-attr.
    define buffer old-c-fbr-gds-grp-attr for src.c-fbr-gds-grp-attr.
    define buffer new-c-fbr-gds-grp-attr for dst.c-fbr-gds-grp-attr.
    define buffer old-c-fbr-gds-grp-hist for src.c-fbr-gds-grp-hist.
    define buffer new-c-fbr-gds-grp-hist for dst.c-fbr-gds-grp-hist.
    define buffer old-dish-grp          for src.dish-grp.
    define buffer new-dish-grp          for dst.dish-grp.
    define buffer old-dish-grp-attr     for src.dish-grp-attr.
    define buffer new-dish-grp-attr     for dst.dish-grp-attr.
    define buffer old-fbr-prn           for src.fbr-prn.
    define buffer new-fbr-prn           for dst.fbr-prn.
    define buffer old-c-fbr-prn         for src.c-fbr-prn.
    define buffer new-c-fbr-prn         for dst.c-fbr-prn.
    define buffer old-fbr-prn-attr      for src.fbr-prn-attr.
    define buffer new-fbr-prn-attr      for dst.fbr-prn-attr.
    define buffer old-fbr-prn-gds       for src.fbr-prn-gds.
    define buffer new-fbr-prn-gds       for dst.fbr-prn-gds.
    define buffer old-c-fbr-prn-gds     for src.c-fbr-prn-gds.
    define buffer new-c-fbr-prn-gds     for dst.c-fbr-prn-gds.
    define buffer old-fbr-prn-gds-attr  for src.fbr-prn-gds-attr.
    define buffer new-fbr-prn-gds-attr  for dst.fbr-prn-gds-attr.
    define buffer old-fbr-prn-grp       for src.fbr-prn-grp.
    define buffer new-fbr-prn-grp       for dst.fbr-prn-grp.
    define buffer old-c-fbr-prn-grp     for src.c-fbr-prn-grp.
    define buffer new-c-fbr-prn-grp     for dst.c-fbr-prn-grp.
    define buffer old-fbr-prn-grp-attr  for src.fbr-prn-grp-attr.
    define buffer new-fbr-prn-grp-attr  for dst.fbr-prn-grp-attr.
    define buffer new-goods             for dst.goods.
    define buffer new-rcp_goods         for dst.goods.
    define buffer old-recipe-develop    for src.recipe-develop.
    define buffer new-recipe-develop    for dst.recipe-develop.

    define buffer old-c-recipe         for src.c-recipe        .
    define buffer old-c-recipe-develop for src.c-recipe-develop.
    define buffer old-c-recipe-gds     for src.c-recipe-gds    .
    define buffer old-c-recipe-hist    for src.c-recipe-hist   .

    define buffer new-c-recipe         for dst.c-recipe        .
    define buffer new-c-recipe-develop for dst.c-recipe-develop.
    define buffer new-c-recipe-gds     for dst.c-recipe-gds    .
    define buffer new-c-recipe-hist    for dst.c-recipe-hist   .

do
on error undo, return error SUBSTITUTE( "&1 &2 &3", return-value, error-status:get-message( 1 ), error-status:get-message( 2 ) )
:
{ utl/00000001.i }

on WRITE of dst.recipe               override do: end.
on WRITE of dst.recipe-gds           override do: end.
on WRITE of dst.s-coeff              override do: end.
on WRITE of dst.s-coeff-attr         override do: end.
on WRITE of dst.c-s-coeff            override do: end.
on WRITE of dst.fbr-gds-grp          override do: end.
on WRITE of dst.c-fbr-gds-grp        override do: end.
on WRITE of dst.fbr-gds-grp-attr     override do: end.
on WRITE of dst.c-fbr-gds-grp-attr   override do: end.
on WRITE of dst.c-fbr-gds-grp-hist    override do: end.
on WRITE of dst.dish-grp              override do: end.
on WRITE of dst.dish-grp-attr         override do: end.
on WRITE of dst.fbr-prn               override do: end.
on WRITE of dst.c-fbr-prn             override do: end.
on WRITE of dst.fbr-prn-attr          override do: end.
on WRITE of dst.fbr-prn-gds           override do: end.
on WRITE of dst.fbr-prn-gds-attr      override do: end.
on WRITE of dst.c-fbr-prn-gds         override do: end.
on WRITE of dst.fbr-prn-grp           override do: end.
on WRITE of dst.fbr-prn-grp-attr      override do: end.
on WRITE of dst.recipe-develop        override do: end.
on WRITE of dst.c-recipe              override do: end.
on WRITE of dst.c-recipe-develop      override do: end.
on WRITE of dst.c-recipe-gds          override do: end.
on WRITE of dst.c-recipe-hist         override do: end.

    { utl/00000002.i dish-grp   }
    { utl/00000002.i dish-grp-attr   }
    { utl/00000002.i recipe-develop   }

   if varstay-history then
    for each old-c-recipe no-lock
    on error undo, return error
    :

        find first new-goods
             where new-goods.artic     = old-c-recipe.artic
               and new-goods.prod-type = old-c-recipe.prod-type
               and new-goods.prod-code = old-c-recipe.prod-code
         no-lock
        no-error
        .
        if available new-goods
        then do:
          create new-c-recipe.
          buffer-copy old-c-recipe to new-c-recipe.
        end.
   end.
   if varstay-history then
    for each old-c-recipe-develop no-lock
    on error undo, return error
    :
        find first new-goods no-lock
             where new-goods.gds-code     = old-c-recipe-develop.gds-code
        no-error.
        if available new-goods
        then do:
          create new-c-recipe-develop.
          buffer-copy old-c-recipe-develop to new-c-recipe-develop.
        end.
   end.
   if varstay-history then
    for each old-c-recipe-gds no-lock
    on error undo, return error
    :
        find first new-goods no-lock
             where new-goods.gds-code     = old-c-recipe-gds.gds-code
        no-error.
        if available new-goods
        then do:
          create new-c-recipe-gds.
          buffer-copy old-c-recipe-gds to new-c-recipe-gds.
        end.
   end.
   if varstay-history then
    for each old-c-recipe-hist no-lock
    on error undo, return error
    :
        find first new-goods no-lock
             where new-goods.gds-code     = old-c-recipe-hist.gds-code
        no-error.
        if available new-goods
        then do:
          create new-c-recipe-hist.
          buffer-copy old-c-recipe-hist to new-c-recipe-hist.
        end.
   end.

    { utl/00000002.i fbr-prn    }
    if varstay-history then do:
      { utl/00000002.i c-fbr-prn    }
    end.
    { utl/00000002.i fbr-prn-grp    }
    if varstay-history then do:
      { utl/00000002.i c-fbr-prn-grp    }
    end.
    { utl/00000002.i fbr-gds-grp    }
    if varstay-history then do:
      { utl/00000002.i c-fbr-gds-grp    }
    end.
    { utl/00000002.i fbr-gds-grp-attr    }
    if varstay-history then do:
      { utl/00000002.i c-fbr-gds-grp-attr    }
      { utl/00000002.i c-fbr-gds-grp-hist    }
    end.
    for each old-fbr-prn-gds no-lock
    on error undo, return error
    :
        find first new-goods no-lock
             where new-goods.gds-code     = old-fbr-prn-gds.gds-code
        no-error.
        if available new-goods
        then do:
          create new-fbr-prn-gds.
          buffer-copy old-fbr-prn-gds to new-fbr-prn-gds.
        end.
    end.        /* for each old-fbr-prn-gds */
    if varstay-history then do:
      for each old-c-fbr-prn-gds no-lock
      on error undo, return error
      :
          find first new-goods no-lock
              where new-goods.gds-code     = old-c-fbr-prn-gds.gds-code
          no-error.
          if available new-goods
          then do:
            create new-c-fbr-prn-gds.
            buffer-copy old-c-fbr-prn-gds to new-c-fbr-prn-gds.
          end.
      end.        /* for each old-c-fbr-prn-gds */
    end.
    for each old-fbr-prn-gds-attr no-lock
    on error undo, return error
    :
        find first new-goods no-lock
             where new-goods.gds-code     = old-fbr-prn-gds-attr.gds-code
        no-error.
        if available new-goods
        then do:
          create new-fbr-prn-gds-attr.
          buffer-copy old-fbr-prn-gds-attr to new-fbr-prn-gds-attr.
        end.
    end.        /* for each old-fbr-prn-gds-attr */
    for each old-recipe no-lock
    on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
    :
        find first new-goods no-lock
             where new-goods.artic     = old-recipe.artic
               and new-goods.prod-type = old-recipe.prod-type
               and new-goods.prod-code = old-recipe.prod-code
        no-error.
        if available new-goods
        then do:
            assign
                v-moved-recipe = yes
            .
            for each old-recipe-gds no-lock
            where old-recipe-gds.recipe-code = old-recipe.recipe-code
            on error undo, return error SUBSTITUTE("&1 &2 &3", return-value, error-status:get-message(1), error-status:get-message(2))
            :
                find first new-rcp_goods no-lock
                     where new-rcp_goods.artic     = old-recipe-gds.artic
                       and new-rcp_goods.prod-type = old-recipe-gds.prod-type
                       and new-rcp_goods.prod-code = old-recipe-gds.prod-code
                no-error.
                if not available new-rcp_goods
                then do:
                    assign
                        v-moved-recipe = no
                    .
                    leave.
                end.
            end.
            if v-moved-recipe = yes
            then do:
                create new-recipe.
                buffer-copy old-recipe to new-recipe.
                for each old-recipe-gds no-lock
                   where old-recipe-gds.recipe-code = old-recipe.recipe-code
                :
                    create new-recipe-gds.
                    buffer-copy old-recipe-gds to new-recipe-gds.
                end.
            end.
        end.        /* if available new-goods */
    end.
    for each old-s-coeff no-lock
    on error undo, return error
    :
        find first new-goods no-lock
             where new-goods.gds-code     = old-s-coeff.gds-code
        no-error.
        if available new-goods
        then do:
            create new-s-coeff.
            buffer-copy old-s-coeff to new-s-coeff.
        end.
    end.        /* for each old-s-coeff */
    if varstay-history then do:
      for each old-c-s-coeff no-lock
      on error undo, return error
      :
          find first new-goods no-lock
              where new-goods.gds-code     = old-c-s-coeff.gds-code
          no-error.
          if available new-goods
          then do:
              create new-c-s-coeff.
              buffer-copy old-c-s-coeff to new-c-s-coeff.
          end.
      end.        /* for each old-c-s-coeff */
    end.
    for each old-s-coeff-attr no-lock
    on error undo, return error
    :
        find first new-goods no-lock
             where new-goods.gds-code     = old-s-coeff-attr.gds-code
        no-error.
        if available new-goods
        then do:
            create new-s-coeff-attr.
            buffer-copy old-s-coeff-attr to new-s-coeff-attr.
        end.
    end.        /* for each old-s-coeff-attr */
    output stream str-gen close.
    return "Произведен экспорт таблиц: ~
recipe recipe-gds s-coeff c-s-coeff s-coeff-attr ~
fbr-gds-grp c-fbr-gds-grp fbr-gds-grp-attr c-fbr-gds-grp-attr c-fbr-gds-grp-hist dish-grp dish-grp-attr recipe-develop ~
fbr-prn c-fbr-prn fbr-prn-attr fbr-prn-attr fbr-prn-gds c-fbr-prn-gds fbr-prn-gds-attr fbr-prn-grp c-fbr-prn-grp fbr-prn-grp-attr ~
c-recipe ~
c-recipe-develop ~
c-recipe-gds ~
c-recipe-hist ~
.".
end.