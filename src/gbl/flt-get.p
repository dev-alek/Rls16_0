block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: flt-get.p $
$Archive: gbl/flt-get.p $

Получение текущего значение фильтра

Автор: Хныкин Павел Андреевич
Дата создания: 07/09/07
Author: Pavel Khnykin
Creation date: 07/09/07

Автор1: Перваков Михаил Сергеевич
Дата создания: 10/01/00

*/

define input  parameter c-p              as character no-undo.
define output parameter flt-rec          as recid     no-undo .
define output parameter filter-name      as character no-undo .
define output parameter where-phrase     as character no-undo .
define output parameter sort-phrase      as character no-undo .
define output parameter where-phrase-rus as character no-undo .
define output parameter sort-phrase-rus  as character no-undo .


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: flt-get.p $":U .
define variable vss-archive     as character no-undo init "$Archive: gbl/flt-get.p $":U .
define variable vss-description as character no-undo init "Получение текущего значение фильтра".
{ cmp/vssrevis.i "substitute('&1',c-p)" }
{ cmp/str-glbl.i }
{ cmp/trg-def.i  }

define variable c-p-name                 as character no-undo .
define variable v-enable-sorting         as logical   no-undo init yes.

function octal-to-char returns character
  ( p-string as character ) :

  define variable v-asc     as integer no-undo .
  define variable v-new-asc as integer no-undo .
  define variable ind       as integer no-undo .

  if length(p-string) <> 3 then do:
    return ? .
  end.

  assign
    v-asc = 0
  .
  do ind = 1 to length(p-string)
  :
    assign
      v-new-asc = asc(substring(p-string, ind, 1)) - asc('0')
    .
    if v-new-asc < 0 or v-new-asc >= 8 then do:
      return ? .
    end.
    assign
      v-asc = v-asc * 8 + v-new-asc
    .
  end.

  return chr(v-asc) .
end function .


assign
  flt-rec = ?
.
if c-p = '':U then do:
  assign
    flt-rec      = ?
    filter-name  = ""
    where-phrase = ""
    sort-phrase  = ""
  .
end.

if num-entries(c-p, {&delim-par}) > 2 then do:
  assign
  v-enable-sorting = logical(entry(3, c-p, {&delim-par}))
  no-error
  .
end.
if num-entries(c-p, {&delim-par}) > 1 then do:
  assign
  c-p-name = entry(2, c-p, {&delim-par})
  c-p      = entry(1, c-p, {&delim-par})
  .
end.
find ubflt.usr-flt no-lock
  where ubflt.usr-flt.user-name  = g#userid
    and ubflt.usr-flt.call-point = c-p
  no-error.
find ubflt.filter no-lock
  where ubflt.filter.call-point = ubflt.usr-flt.call-point
    and ubflt.filter.naim       = ubflt.usr-flt.naim
  no-error.
if available ubflt.filter then do:
  assign
    flt-rec          = recid (ubflt.filter)
    filter-name      = ubflt.usr-flt.naim
    where-phrase     = ""
    sort-phrase      = ""
    where-phrase-rus = ""
    sort-phrase-rus  = ""

  .

  if num-entries(ubflt.filter.where-ysl) > 0 then do:
    assign
      where-phrase = where-phrase
                   + ' and ('
    .

    define variable ind as integer no-undo.
    do ind = 1 to num-entries(ubflt.filter.where-ysl):
      assign
        where-phrase = where-phrase
                    + " " + entry(ind, ubflt.filter.where-ysl)
      .
    end.

    assign
      where-phrase = where-phrase
                   + ')'
    .
  end.

  if num-entries(where-phrase, "{&delim-flt-tilda}") > 1 then do:
    define variable v-new-where-phrase as character no-undo .
    assign
      v-new-where-phrase = entry(1, where-phrase, "{&delim-flt-tilda}")
    .
    do ind = 2 to num-entries(where-phrase, "{&delim-flt-tilda}")
    :
      define variable v-sub-phrase as character no-undo .
      assign
        v-sub-phrase = entry(ind, where-phrase, "{&delim-flt-tilda}")
      .

      if octal-to-char(substring(v-sub-phrase, 1, 3)) <> ? then do:
        assign
          v-new-where-phrase = v-new-where-phrase
                            + octal-to-char(substring(v-sub-phrase, 1, 3))
                            + substring(v-sub-phrase, 4)
        .
      end.
      else do:
        assign
          v-new-where-phrase = v-new-where-phrase
                            + "{&delim-flt-tilda}"
                            + v-sub-phrase
        .
      end.
    end.
    assign
      where-phrase = v-new-where-phrase
    .
  end.

  if v-enable-sorting then do:
    do ind = 1 to num-entries(ubflt.filter.fields-sort)
    :
      if entry(ind, ubflt.filter.fields-sort) <> "" then do:
        define variable num-sort as integer no-undo.
        do num-sort = 1 to num-entries( entry(ind, ubflt.filter.fields-sort), "{&delim-flt}")
        :
          assign
            sort-phrase = sort-phrase
                        + " by "
                        + entry( num-sort , entry(ind, ubflt.filter.fields-sort), "{&delim-flt}")
          .
          if entry(ind, ubflt.filter.lst-cend) = '1' then do:
            assign
              sort-phrase = sort-phrase
                          + " descending"
            .
          end.
        end.
      end.
    end.
  end.
  assign
  where-phrase-rus = ubflt.filter.where-ysl-rus
  sort-phrase-rus  = (if v-enable-sorting then ubflt.filter.fields-sort-rus else "":U)
  .
end.
else do:
  assign
    flt-rec      = ?
    filter-name  = ""
    where-phrase = ""
    sort-phrase  = ""
  .
end.