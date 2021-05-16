# defmodule Proxy.ReportView do
#   use ProxyWeb, :view

#   alias Elixlsx.{Workbook, Sheet}

#   @headers [["Reference", bg_color: "#FFD966", bold: true],	["RRCode", bg_color: "#FFD966", bold: true],	["Orig.Acc", bg_color: "#FFD966", bold: true],	["Value Dt", bg_color: "#FFD966", bold: true],	["Dest. Acc", bg_color: "#FFD966", bold: true],	["Narration", bg_color: "#FFD966", bold: true],	["Beneficiary", bg_color: "#FFD966", bold: true],	["Amt.", bg_color: "#FFD966", bold: true]]

#   def render("report.xlsx", %{entries: entries}) do
#     report_generator(entries)
#     |> Elixlsx.write_to_memory("report.xlsx")
#     |> elem(1)
#     |> elem(1)
#   end

#   def report_generator(entries) do
#     rows =
#       entries
#       |> Enum.group_by(&(&1.bank_code))
#       |> Map.values
#       |> Enum.map(fn entries ->
#         set_bank_name(entries)
#         |> Enum.concat(Enum.map(entries, &Enum.map(row(&1), fn item -> if(is_nil(item), do: "", else: item) end)))
#         |> Enum.concat(set_bank_total(entries))
#       end)
#       |> List.foldl([], &(&1 ++ &2))
#     %Workbook{sheets: [%Sheet{name: "Banklink", rows: [@headers] ++ rows} |> set_col_width()]}
#   end

#   defp set_col_width(sheet) do
#     sheet
#     |> Sheet.set_col_width("A", 33.44)
#     |> Sheet.set_col_width("B", 6.78)
#     |> Sheet.set_col_width("C", 14.33)
#     |> Sheet.set_col_width("D", 9.44)
#     |> Sheet.set_col_width("E", 14.33)
#     |> Sheet.set_col_width("F", 70.33)
#     |> Sheet.set_col_width("G", 30.33)
#     |> Sheet.set_col_width("H", 21.44)
#   end

#   def row(entry) do
#     [
#       [entry.cbs_ref_no || "", border: [bottom: [style: :double, color: "#000000"], top: [style: :double, color: "#000000"], right: [style: :double, color: "#000000"], left: [style: :double, color: "#000000"]]],
#       [entry.return_code || "", border: [bottom: [style: :double, color: "#000000"], top: [style: :double, color: "#000000"], right: [style: :double, color: "#000000"], left: [style: :double, color: "#000000"]]],
#       [entry.src_acc_no || "", border: [bottom: [style: :double, color: "#000000"], top: [style: :double, color: "#000000"], right: [style: :double, color: "#000000"], left: [style: :double, color: "#000000"]]],
#       [entry.value_date || "", border: [bottom: [style: :double, color: "#000000"], top: [style: :double, color: "#000000"], right: [style: :double, color: "#000000"], left: [style: :double, color: "#000000"]]],
#       [entry.destin_acc_no || "", border: [bottom: [style: :double, color: "#000000"], top: [style: :double, color: "#000000"], right: [style: :double, color: "#000000"], left: [style: :double, color: "#000000"]]],
#       [entry.narration || "", border: [bottom: [style: :double, color: "#000000"], top: [style: :double, color: "#000000"], right: [style: :double, color: "#000000"], left: [style: :double, color: "#000000"]]],
#       [entry.destin_acc_name || entry.src_acc_name || "", border: [bottom: [style: :double, color: "#000000"], top: [style: :double, color: "#000000"], right: [style: :double, color: "#000000"], left: [style: :double, color: "#000000"]]],
#       [to_string(entry.amount), align_horizontal: :right, bg_color: "#DDEBF7", border: [bottom: [style: :double, color: "#000000"], top: [style: :double, color: "#000000"], right: [style: :double, color: "#000000"], left: [style: :double, color: "#000000"]]]
#     ]
#   end

#   defp set_bank_total([entry| _rest]) do
#     [List.duplicate(["", border: [bottom: [style: :double, color: "#000000"], top: [style: :double, color: "#000000"], right: [style: :double, color: "#000000"], left: [style: :double, color: "#000000"]]], 7) ++ [[entry.bank_total, bg_color: "#20E0C0", bold: true, align_horizontal: :right]]]
#   end
#   defp set_bank_total(_), do: [[]]

#   defp set_bank_name([entry| _rest]) do
#     [[[entry.bank_name, bg_color: "#C6E0B4", bold: true, border: [bottom: [style: :double, color: "#000000"], top: [style: :double, color: "#000000"], right: [style: :double, color: "#000000"], left: [style: :double, color: "#000000"]]]] ++ List.duplicate(["", border: [bottom: [style: :double, color: "#000000"], top: [style: :double, color: "#000000"], right: [style: :double, color: "#000000"], left: [style: :double, color: "#000000"]]], 7)]
#   end
#   defp set_bank_name(_), do: [[]]
# end
