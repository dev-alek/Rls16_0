find {1} buf_parts
  where buf_parts.obj-type  = buf_doc-line.obj-type
    and buf_parts.obj-code  = buf_doc-line.obj-code
    and buf_parts.artic     = buf_doc-line.artic
    and buf_parts.prod-type = buf_doc-line.prod-type
    and buf_parts.prod-code = buf_doc-line.prod-code
    and buf_parts.out-code  = v-rsrv-code
    and buf_parts.status_   = no
    /* для поэкзеплярного учета и если была просканирована марка  и */
    /* при внутреннем расходе и списании ищем свободную партию с достаточным кол-вом ед. товара */
    and (buf_parts.fact-qnty >= if v-mark-tobacco and (vIsExemplarGoods or v-isweighed) and (buf_trn-doc.ext-doc-type = {&TDEDT_Ras_Perem} or buf_trn-doc.ext-doc-type = {&TDEDT_Spi_Vnesh}) 
                                then p-chg-qnty else 0)
    {2}
  use-index FIFO
  no-error.
