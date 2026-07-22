/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Возвращает запрашиваемый тип цены в  р у б  или б.в. и количество в кг (весовой учет топлива)

Автор: Булгаков Андрей Николаевич
Дата создания: 03/23/05
Author: Andrew Bulgakoff
Creation date: 03/23/05

*/

&glob prefix                   invlnsum_
&glob invlnsum_function-number 12
&glob invlnsum_function-list   acc-rubl,acc-base,acc-price,sale-rubl,sale-base,sale-price,weight-rubl,weight-base,weight-price,cli-qnty,after-qnty,weight-qnty

&if     '{1}' = 'def' &then

  &if defined( invlnsum_already-defined ) = 0 &then

    { str/lib-trn.i }

    {&check_lib-trn3}

    &glob invlnsum_already-defined yes
    &scop invlnsum_function-used   {&invlnsum_function-list}
    &scop invlnsum_func_not_used

    &if defined( invlnsum_defined-list ) = 0 &then
        &if     trim( '{2}' ) = ''  &then
    &scop invlnsum_defined-list '{&invlnsum_function-used},{&invlnsum_func_not_used}'
        &elseif       '{2}'   = '?' &then
    &scop invlnsum_defined-list '{&invlnsum_function-used},{&invlnsum_func_not_used}'
        &elseif       '{2}'   = '*' &then
    &scop invlnsum_defined-list '{&invlnsum_function-used}'
        &else
    &scop invlnsum_defined-list '{2}'
        &endif
    &endif

    &scop SELF-NAME acc-rubl
    &if lookup( '^{&SELF-NAME}', {&invlnsum_defined-list} ) = 0 and
        lookup(  '{&SELF-NAME}', {&invlnsum_defined-list} ) > 0 or
        lookup( '^acc',          {&invlnsum_defined-list} ) = 0 and
        lookup(  'acc',          {&invlnsum_defined-list} ) > 0 or
        lookup( '^price',        {&invlnsum_defined-list} ) = 0 and
        lookup(  'price',        {&invlnsum_defined-list} ) > 0 &then
      function {&prefix}{&SELF-NAME} returns decimal ( input p-doc-code  as character,
                                                       input p-artic     as character,
                                                       input p-prod-type as character,
                                                       input p-prod-code as integer    ) :
        define variable d_out-kg-acc-rubl  as decimal no-undo initial ?.

        if valid-handle( g#lib-trn3 ) = yes then do on error undo, return error :
          run lib-trn3_invlnprc in g#lib-trn3 (
                                                 input p-doc-code         /* doc-code              */
                                              ,  input p-artic            /* artic                 */
                                              ,  input p-prod-type        /* prod-type             */
                                              ,  input p-prod-code        /* prod-code             */
                                              ,  input "acc"              /* price-type (acc,sale) */
                                              ,  input yes                /* print-rubl (yes,no)   */
                                              , output d_out-kg-acc-rubl  /* price (kg)            */
                                              ) {3}.
          return ( if error-status :error then ? else d_out-kg-acc-rubl  ).
        end. /* valid-handle */
      end function. /* invlnsum_acc-rubl */
    &endif

    &scop SELF-NAME acc-base
    &if lookup( '^{&SELF-NAME}', {&invlnsum_defined-list} ) = 0 and
        lookup(  '{&SELF-NAME}', {&invlnsum_defined-list} ) > 0 or
        lookup( '^acc',          {&invlnsum_defined-list} ) = 0 and
        lookup(  'acc',          {&invlnsum_defined-list} ) > 0 or
        lookup( '^price',        {&invlnsum_defined-list} ) = 0 and
        lookup(  'price',        {&invlnsum_defined-list} ) > 0 &then
      function {&prefix}{&SELF-NAME} returns decimal ( input p-doc-code  as character,
                                                       input p-artic     as character,
                                                       input p-prod-type as character,
                                                       input p-prod-code as integer    ) :
        define variable d_out-kg-acc-base  as decimal no-undo initial ?.

        if valid-handle( g#lib-trn3 ) = yes then do on error undo, return error :
          run lib-trn3_invlnprc in g#lib-trn3 (
                                                 input p-doc-code         /* doc-code              */
                                              ,  input p-artic            /* artic                 */
                                              ,  input p-prod-type        /* prod-type             */
                                              ,  input p-prod-code        /* prod-code             */
                                              ,  input "acc"              /* price-type (acc,sale) */
                                              ,  input no                 /* print-rubl (yes,no)   */
                                              , output d_out-kg-acc-base  /* price (kg)            */
                                              ) {3}.
          return ( if error-status :error then ? else d_out-kg-acc-base  ).
        end. /* valid-handle */
      end function. /* invlnsum_acc-base */
    &endif

    &scop SELF-NAME acc-price
    &if lookup( '^{&SELF-NAME}', {&invlnsum_defined-list} ) = 0 and
        lookup(  '{&SELF-NAME}', {&invlnsum_defined-list} ) > 0 or
        lookup( '^acc',          {&invlnsum_defined-list} ) = 0 and
        lookup(  'acc',          {&invlnsum_defined-list} ) > 0 or
        lookup( '^price',        {&invlnsum_defined-list} ) = 0 and
        lookup(  'price',        {&invlnsum_defined-list} ) > 0 &then
      function {&prefix}{&SELF-NAME} returns decimal ( input p-doc-code   as character,
                                                       input p-artic      as character,
                                                       input p-prod-type  as character,
                                                       input p-prod-code  as integer,
                                                       input p-print-rubl as logical    ) :
        define variable d_out-kg-acc-price as decimal no-undo initial ?.

        if valid-handle( g#lib-trn3 ) = yes then do on error undo, return error :
          run lib-trn3_invlnprc in g#lib-trn3 (
                                                 input p-doc-code         /* doc-code              */
                                              ,  input p-artic            /* artic                 */
                                              ,  input p-prod-type        /* prod-type             */
                                              ,  input p-prod-code        /* prod-code             */
                                              ,  input "acc"              /* price-type (acc,sale) */
                                              ,  input p-print-rubl       /* print-rubl (yes,no)   */
                                              , output d_out-kg-acc-price /* price (kg)            */
                                              ) {3}.
          return ( if error-status :error then ? else d_out-kg-acc-price ).
        end. /* valid-handle */
      end function. /* invlnsum_acc-price */
    &endif

    &scop SELF-NAME sale-rubl
    &if lookup( '^{&SELF-NAME}', {&invlnsum_defined-list} ) = 0 and
        lookup(  '{&SELF-NAME}', {&invlnsum_defined-list} ) > 0 or
        lookup( '^sale',         {&invlnsum_defined-list} ) = 0 and
        lookup(  'sale',         {&invlnsum_defined-list} ) > 0 or
        lookup( '^price',        {&invlnsum_defined-list} ) = 0 and
        lookup(  'price',        {&invlnsum_defined-list} ) > 0 &then
      function {&prefix}{&SELF-NAME} returns decimal ( input p-doc-code  as character,
                                                       input p-artic     as character,
                                                       input p-prod-type as character,
                                                       input p-prod-code as integer    ) :
        define variable d_out-kg-sale-rubl as decimal no-undo initial ?.

        if valid-handle( g#lib-trn3 ) = yes then do on error undo, return error :
          run lib-trn3_invlnprc in g#lib-trn3 (
                                                 input p-doc-code         /* doc-code              */
                                              ,  input p-artic            /* artic                 */
                                              ,  input p-prod-type        /* prod-type             */
                                              ,  input p-prod-code        /* prod-code             */
                                              ,  input "sale"             /* price-type (acc,sale) */
                                              ,  input yes                /* print-rubl (yes,no)   */
                                              , output d_out-kg-sale-rubl /* price (kg)            */
                                              ) {3}.
          return ( if error-status :error then ? else d_out-kg-sale-rubl ).
        end. /* valid-handle */
      end function. /* invlnsum_sale-rubl */
    &endif

    &scop SELF-NAME sale-base
    &if lookup( '^{&SELF-NAME}', {&invlnsum_defined-list} ) = 0 and
        lookup(  '{&SELF-NAME}', {&invlnsum_defined-list} ) > 0 or
        lookup( '^sale',         {&invlnsum_defined-list} ) = 0 and
        lookup(  'sale',         {&invlnsum_defined-list} ) > 0 or
        lookup( '^price',        {&invlnsum_defined-list} ) = 0 and
        lookup(  'price',        {&invlnsum_defined-list} ) > 0 &then
      function {&prefix}{&SELF-NAME} returns decimal ( input p-doc-code  as character,
                                                       input p-artic     as character,
                                                       input p-prod-type as character,
                                                       input p-prod-code as integer    ) :
        define variable d_out-kg-sale-base as decimal no-undo initial ?.

        if valid-handle( g#lib-trn3 ) = yes then do on error undo, return error :
          run lib-trn3_invlnprc in g#lib-trn3 (
                                                 input p-doc-code         /* doc-code              */
                                              ,  input p-artic            /* artic                 */
                                              ,  input p-prod-type        /* prod-type             */
                                              ,  input p-prod-code        /* prod-code             */
                                              ,  input "sale"             /* price-type (acc,sale) */
                                              ,  input no                 /* print-rubl (yes,no)   */
                                              , output d_out-kg-sale-base /* price (kg)            */
                                              ) {3}.
          return ( if error-status :error then ? else d_out-kg-sale-base ).
        end. /* valid-handle */
      end function. /* invlnsum_sale-base */
    &endif

    &scop SELF-NAME sale-price
    &if lookup( '^{&SELF-NAME}', {&invlnsum_defined-list} ) = 0 and
        lookup(  '{&SELF-NAME}', {&invlnsum_defined-list} ) > 0 or
        lookup( '^sale',         {&invlnsum_defined-list} ) = 0 and
        lookup(  'sale',         {&invlnsum_defined-list} ) > 0 or
        lookup( '^price',        {&invlnsum_defined-list} ) = 0 and
        lookup(  'price',        {&invlnsum_defined-list} ) > 0 &then
      function {&prefix}{&SELF-NAME} returns decimal ( input p-doc-code   as character,
                                                       input p-artic      as character,
                                                       input p-prod-type  as character,
                                                       input p-prod-code  as integer,
                                                       input p-print-rubl as logical    ) :
        define variable d_out-kg-sale-price as decimal no-undo initial ?.

        if valid-handle( g#lib-trn3 ) = yes then do on error undo, return error :
          run lib-trn3_invlnprc in g#lib-trn3 (
                                                 input p-doc-code          /* doc-code              */
                                              ,  input p-artic             /* artic                 */
                                              ,  input p-prod-type         /* prod-type             */
                                              ,  input p-prod-code         /* prod-code             */
                                              ,  input "sale"              /* price-type (acc,sale) */
                                              ,  input p-print-rubl        /* print-rubl (yes,no)   */
                                              , output d_out-kg-sale-price /* price (kg)            */
                                              ) {3}.
          return ( if error-status :error then ? else d_out-kg-sale-price ).
        end. /* valid-handle */
      end function. /* invlnsum_sale-price */
    &endif

    &scop SELF-NAME weight-rubl
    &if lookup( '^{&SELF-NAME}', {&invlnsum_defined-list} ) = 0 and
        lookup(  '{&SELF-NAME}', {&invlnsum_defined-list} ) > 0 or
        lookup( '^price',        {&invlnsum_defined-list} ) = 0 and
        lookup(  'price',        {&invlnsum_defined-list} ) > 0 &then
      function {&prefix}{&SELF-NAME} returns decimal ( input p-doc-code   as character,
                                                       input p-artic      as character,
                                                       input p-prod-type  as character,
                                                       input p-prod-code  as integer,
                                                       input p-price-type as character  ) :
        define variable d_out-kg-weight-rubl as decimal no-undo initial ?.

        if valid-handle( g#lib-trn3 ) = yes then do on error undo, return error :
          run lib-trn3_invlnprc in g#lib-trn3 (
                                                 input p-doc-code           /* doc-code              */
                                              ,  input p-artic              /* artic                 */
                                              ,  input p-prod-type          /* prod-type             */
                                              ,  input p-prod-code          /* prod-code             */
                                              ,  input p-price-type         /* price-type (acc,sale) */
                                              ,  input yes                  /* print-rubl (yes,no)   */
                                              , output d_out-kg-weight-rubl /* price (kg)            */
                                              ) {3}.
          return ( if error-status :error then ? else d_out-kg-weight-rubl ).
        end. /* valid-handle */
      end function. /* invlnsum_weight-rubl */
    &endif

    &scop SELF-NAME weight-base
    &if lookup( '^{&SELF-NAME}', {&invlnsum_defined-list} ) = 0 and
        lookup(  '{&SELF-NAME}', {&invlnsum_defined-list} ) > 0 or
        lookup( '^price',        {&invlnsum_defined-list} ) = 0 and
        lookup(  'price',        {&invlnsum_defined-list} ) > 0 &then
      function {&prefix}{&SELF-NAME} returns decimal ( input p-doc-code   as character,
                                                       input p-artic      as character,
                                                       input p-prod-type  as character,
                                                       input p-prod-code  as integer,
                                                       input p-price-type as character  ) :
        define variable d_out-kg-weight-base as decimal no-undo initial ?.

        if valid-handle( g#lib-trn3 ) = yes then do on error undo, return error :
          run lib-trn3_invlnprc in g#lib-trn3 (
                                                 input p-doc-code           /* doc-code              */
                                              ,  input p-artic              /* artic                 */
                                              ,  input p-prod-type          /* prod-type             */
                                              ,  input p-prod-code          /* prod-code             */
                                              ,  input p-price-type         /* price-type (acc,sale) */
                                              ,  input no                   /* print-rubl (yes,no)   */
                                              , output d_out-kg-weight-base /* price (kg)            */
                                              ) {3}.
          return ( if error-status :error then ? else d_out-kg-weight-base ).
        end. /* valid-handle */
      end function. /* invlnsum_weight-base */
    &endif

    &scop SELF-NAME weight-price
    &if lookup( '^{&SELF-NAME}', {&invlnsum_defined-list} ) = 0 and
        lookup(  '{&SELF-NAME}', {&invlnsum_defined-list} ) > 0 or
        lookup( '^price',        {&invlnsum_defined-list} ) = 0 and
        lookup(  'price',        {&invlnsum_defined-list} ) > 0 &then
      function {&prefix}{&SELF-NAME} returns decimal ( input p-doc-code   as character,
                                                       input p-artic      as character,
                                                       input p-prod-type  as character,
                                                       input p-prod-code  as integer,
                                                       input p-price-type as character,
                                                       input p-print-rubl as logical    ) :
        define variable d_out-kg-weight-price as decimal no-undo initial ?.

        if valid-handle( g#lib-trn3 ) = yes then do on error undo, return error :
          run lib-trn3_invlnprc in g#lib-trn3 (
                                                 input p-doc-code            /* doc-code              */
                                              ,  input p-artic               /* artic                 */
                                              ,  input p-prod-type           /* prod-type             */
                                              ,  input p-prod-code           /* prod-code             */
                                              ,  input p-price-type          /* price-type (acc,sale) */
                                              ,  input p-print-rubl          /* print-rubl (yes,no)   */
                                              , output d_out-kg-weight-price /* price (kg)            */
                                              ) {3}.
          return ( if error-status :error then ? else d_out-kg-weight-price ).
        end. /* valid-handle */
      end function. /* invlnsum_weight-price */
    &endif

    &scop SELF-NAME cli-qnty
    &if lookup( '^{&SELF-NAME}', {&invlnsum_defined-list} ) = 0 and
        lookup(  '{&SELF-NAME}', {&invlnsum_defined-list} ) > 0 or
        lookup( '^qnty',         {&invlnsum_defined-list} ) = 0 and
        lookup(  'qnty',         {&invlnsum_defined-list} ) > 0 &then
      function {&prefix}{&SELF-NAME} returns decimal ( input p-doc-code  as character,
                                                       input p-artic     as character,
                                                       input p-prod-type as character,
                                                       input p-prod-code as integer     ) :
        define variable d_out-qnty-kg as decimal no-undo initial ?.

        &scop  proc-name lib-trn3_invlnqty
        if valid-handle( g#lib-trn3 ) = yes then do on error undo, return error :
          run lib-trn3_invlnqty in g#lib-trn3 (
                                                 input p-doc-code    /* doc-code           */
                                              ,  input p-artic       /* artic              */
                                              ,  input p-prod-type   /* prod-type          */
                                              ,  input p-prod-code   /* prod-code          */
                                              ,  input no            /* qnty-type (yes,no) */
                                              , output d_out-qnty-kg /* qnty (kg)          */
        ) {3}.
          return ( if error-status :error then ? else d_out-qnty-kg ).
        end. /* valid-handle */
      end function. /* invlnsum_cli-qnty */
    &endif

    &scop SELF-NAME after-qnty
    &if lookup( '^{&SELF-NAME}', {&invlnsum_defined-list} ) = 0 and
        lookup(  '{&SELF-NAME}', {&invlnsum_defined-list} ) > 0 or
        lookup( '^qnty',         {&invlnsum_defined-list} ) = 0 and
        lookup(  'qnty',         {&invlnsum_defined-list} ) > 0 &then
      function {&prefix}{&SELF-NAME} returns decimal ( input p-doc-code  as character,
                                                       input p-artic     as character,
                                                       input p-prod-type as character,
                                                       input p-prod-code as integer     ) :
        define variable d_out-qnty-kg as decimal no-undo initial ?.

        if valid-handle( g#lib-trn3 ) = yes then do on error undo, return error :
          run lib-trn3_invlnqty in g#lib-trn3 (
                                                 input p-doc-code    /* doc-code           */
                                              ,  input p-artic       /* artic              */
                                              ,  input p-prod-type   /* prod-type          */
                                              ,  input p-prod-code   /* prod-code          */
                                              ,  input yes           /* qnty-type (yes,no) */
                                              , output d_out-qnty-kg /* qnty (kg)          */
                                              ) {3}.
          return ( if error-status :error then ? else d_out-qnty-kg ).
        end. /* valid-handle */
      end function. /* invlnsum_after-qnty */
    &endif

    &scop SELF-NAME weight-qnty
    &if lookup( '^{&SELF-NAME}', {&invlnsum_defined-list} ) = 0 and
        lookup(  '{&SELF-NAME}', {&invlnsum_defined-list} ) > 0 or
        lookup( '^qnty',         {&invlnsum_defined-list} ) = 0 and
        lookup(  'qnty',         {&invlnsum_defined-list} ) > 0 &then
      function {&prefix}{&SELF-NAME} returns decimal ( input p-doc-code  as character,
                                                       input p-artic     as character,
                                                       input p-prod-type as character,
                                                       input p-prod-code as integer,
                                                       input p-is-arch   as   logical                ) :
        define variable d_out-qnty-kg as decimal no-undo initial ?.

        if valid-handle( g#lib-trn3 ) = yes then do on error undo, return error :
          run lib-trn3_invlnqty in g#lib-trn3 (
                                                 input p-doc-code    /* doc-code           */
                                              ,  input p-artic       /* artic              */
                                              ,  input p-prod-type   /* prod-type          */
                                              ,  input p-prod-code   /* prod-code          */
                                              ,  input p-is-arch     /* qnty-type (yes,no) */
                                              , output d_out-qnty-kg /* qnty (kg)          */
                                              ) {3}.
          return ( if error-status :error then ? else d_out-qnty-kg ).
        end. /* valid-handle */
      end function. /* invlnsum_weight-qnty */
    &endif

  &endif

&elseif '{1}' = 'exe' &then

  &if lookup( '{2}', '{&invlnsum_function-list}' ) > 0 &then

    {&prefix}{2} (
      &if trim( '{3}' ) <> '' &then
                   {3}
        &if trim( '{4}' ) <> '' &then
                 , {4}
          &if trim( '{5}' ) <> '' &then
                 , {5}
            &if trim( '{6}' ) <> '' &then
                 , {6}
              &if trim( '{7}' ) <> '' &then
                 , {7}
                &if trim( '{8}' ) <> '' &then
                 , {8}
                  &if trim( '{9}' ) <> '' &then
                 , {9}
                  &endif
                &endif
              &endif
            &endif
          &endif
        &endif
      &endif
                 )
  &endif

&endif

/* $Workfile$   E n d */
