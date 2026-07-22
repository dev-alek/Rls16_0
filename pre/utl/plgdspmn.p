block-level on error undo, throw.
define buffer bf_pl-gds-pump for ub.pl-gds-pump.
do on error undo, return error return-value :
for each bf_pl-gds-pump no-lock on error undo, return error return-value :
  run str/callnews.p
    (input "pl-gds-pump"
    ,input (buffer bf_pl-gds-pump:handle)
    ) .
end.
message "Вся таблица складское-место_товар_ТРК отправлена по новостям." view-as alert-box.
end.
