/* @NOTE логических полей избегать, иначе при импорте пустого значения ';;;' будет ошибка:
         логическое поле может быть только yes/no */
define temp-table tt-imp-parts no-undo // скопировано из utl/imp-doc4.p
  /* 01 */ field artic         as character
           field f02           as character
  /* 03 */ field part-code     as character
  /* 04 */ field in-code       like ub.parts.in-code
  /* 05 */ field gds-code      as int64
  /* 06 */ field price-rubl    like ub.parts.price-rubl
  /* 07 */ field fact-qnty     like ub.parts.fact-qnty
           field f08           as character
           field f09           as character
           field f10           as character
  /* 11 */ field vat-tax-value as decimal
           field f12           as character
           field f13           as character
  /* 14 */ field name-gtd      as character
           field f15           as character
           field f16           as character
  /* 17 */ field srok-god      as character
           field f18           as character
           field f19           as character
  /* 20 */ field supp-code     as integer
  /* 21 */ field supp-type     as character
  /* 22 */ field cont-prn-code like ub.contract.contract-prn-code
           field imp-row       as character // исходая строка из файла импорта
.