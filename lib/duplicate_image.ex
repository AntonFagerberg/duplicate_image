defmodule DuplicateImage do
  import Logger
  import File

  def main([base_path, duplicate_path, threshold]) do
    if (!dir?(base_path)), do: throw("Not valid folder: #{base_path}")
    if (!dir?(duplicate_path)), do: throw("Not valid folder: #{duplicate_path}")

    compare(File.ls!(base_path), base_path, duplicate_path, String.to_float(threshold))
  end

  defp file_error(file, reason, action) do
    Logger.warn("[#{action}] File error on '#{file}': #{:file.format_error(reason)}")
  end

  defp move(file, path, filename) do
    case File.cp(file, path <> "/" <> filename, fn(_, _) ->
      move(file, path, "duplicate_" <> filename)
      false
    end) do
      :ok ->
        case File.rm(file) do
          {:error, reason} ->
            file_error(file, reason, "remove")

          :ok ->
            Logger.info("File successfully moved!")
        end

      {:error, reason} -> file_error(file, reason, "copy")
    end
  end

  defp compare([], _base_path, _duplicate_path, threshold) do
    # done with folder
  end

  defp compare(files, base_path, duplicate_path, threshold) do
    [compare_file | remaining_files] = files
    compare_file_with_path = base_path <> "/" <> compare_file

    if (dir?(compare_file_with_path)) do
      case File.ls(compare_file_with_path) do
        {:ok, directory_files} ->
          compare(directory_files, compare_file_with_path, duplicate_path, threshold)

        {:error, reason} ->
          file_error(compare_file_with_path, reason, "list")
      end
    else
      remaining_files
      |> Enum.chunk(:erlang.system_info(:schedulers_online))
      |> Enum.each(fn(file_chunk) ->
        tasks =
          Enum.map(file_chunk, fn(file) ->
            Task.async(fn ->
              file_path = base_path <> "/" <> file

              if (regular?(file_path)) do
                case System.cmd("compare", ["-metric", "RMSE", compare_file_with_path, file_path, "null:"], stderr_to_stdout: true) do
                  {result, 0} ->
                    Logger.info("Found perfect duplicate: '#{compare_file_with_path}' & '#{file_path}'")
                    move(compare_file_with_path, duplicate_path, compare_file)

                  {result, 1} ->
                    comparison =
                      Regex.run(~r/\((\d+\.\d+)\)/, result)
                      |> Enum.at(1)
                      |> String.to_float

                    if (comparison < threshold) do
                      Logger.info("Found duplicate: '#{compare_file_with_path}' & '#{file_path}'")
                      move(compare_file_with_path, duplicate_path, compare_file)
                    end

                  _ -> # Unable to compare images
                end
              end
            end)
          end)

        Enum.map(tasks, &Task.await/1)
      end)

      compare(remaining_files, base_path, duplicate_path, threshold)
    end
  end
end
