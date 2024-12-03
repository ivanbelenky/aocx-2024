defmodule RedNoseReports do
  @spec is_safe([String.t()]) :: boolean()
  def is_safe(report) do
    idx_value = Enum.with_index(report)
    n = length(idx_value)
    diffs = Enum.map(idx_value, fn {value, idx} ->
        String.to_integer(Enum.at(report, idx+1, value)) - String.to_integer(value)
    end) |> Enum.slice(0..n-2)
    Enum.all?(diffs, &(abs(&1)<=3)) and (Enum.all?(diffs, &(&1>0)) or Enum.all?(diffs, &(&1<0)))
  end

  def is_safe_remove(report) do
    idx_value = Enum.with_index(report)
    all_reports = Enum.map(idx_value, fn {_, idx} ->
      {_, new_report} = List.pop_at(report, idx)
      new_report
    end)
    Enum.any?(all_reports, &is_safe(&1))
  end

  @spec safe_reports(Path.t() | String.t(), boolean()) :: [[String.t()]]
  def safe_reports(file_path, unsafe \\ false) do
    stream = File.stream!(file_path, [encoding: :utf8])
    stream |>
      Enum.map(&String.split(String.trim(&1), " ")) |>
      Enum.filter(fn report ->
        safe_flag = is_safe(report)
        if unsafe do
          !safe_flag
        else
          safe_flag
        end
      end)
  end

  @spec safe_reports_remove(Path.t() | String.t()) :: [[integer()]]
  def safe_reports_remove(file_path) do
    unsafe_reports = safe_reports(file_path, true)
    unsafe_reports |> Enum.filter( fn report -> is_safe_remove(report) end)

  end

end
