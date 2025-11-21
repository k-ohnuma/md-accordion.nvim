local M = {}

local PLUGIN_NAME = "MdAccordion"

local function warn(msg)
  vim.notify(PLUGIN_NAME .. ": " .. msg, vim.log.levels.WARN)
end

local function is_markdown_buffer()
  local ft = vim.bo.filetype
  return ft == "markdown" or ft == "md"
end

local function strip_blank_lines(lines)
  local start_i = nil
  local end_i = nil

  for i, l in ipairs(lines) do
    if vim.trim(l) ~= "" then
      start_i = i
      break
    end
  end

  if not start_i then
    return {}
  end

  for i = #lines, 1, -1 do
    if vim.trim(lines[i]) ~= "" then
      end_i = i
      break
    end
  end

  local result = {}
  for i = start_i, end_i do
    table.insert(result, lines[i])
  end

  return result
end

local function get_lines(bufnr, line1, line2)
  return vim.api.nvim_buf_get_lines(bufnr, line1 - 1, line2, false)
end

local function first_nonblank_index(lines)
  for i, l in ipairs(lines) do
    if vim.trim(l) ~= "" then
      return i
    end
  end
  return nil
end

local function is_details_block(lines)
  local idx = first_nonblank_index(lines)
  if not idx then
    return false
  end
  local trimmed = vim.trim(lines[idx])
  return trimmed:match("^<details") ~= nil
end

local function unwrap_details_block(lines)
  local unwrapped = {}

  for _, l in ipairs(lines) do
    local trimmed = vim.trim(l)
    local skip = false

    if trimmed:match("^<details") or trimmed == "</details>" then
      skip = true
    else
      local inner = trimmed:match("^<summary>(.*)</summary>$")
      if inner then
        local indent = l:match("^(%s*)") or ""
        table.insert(unwrapped, indent .. inner)
        skip = true
      end
    end

    if not skip then
      table.insert(unwrapped, l)
    end
  end
  return strip_blank_lines(unwrapped)
end

function M.run(line1, line2, open)
  if not is_markdown_buffer() then
    warn("This command only works in Markdown buffers")
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local lines = get_lines(bufnr, line1, line2)

  if is_details_block(lines) then
    local unwrapped = unwrap_details_block(lines)

    if #unwrapped == 0 then
      vim.api.nvim_buf_set_lines(bufnr, line1 - 1, line2, false, {})
    else
      vim.api.nvim_buf_set_lines(bufnr, line1 - 1, line2, false, unwrapped)
    end
    return
  end

  local filtered = strip_blank_lines(lines)

  if #filtered == 0 then
    warn("Selection contains only blank lines")
    return
  end

  local summary = vim.trim(filtered[1])
  table.remove(filtered, 1)

  filtered = strip_blank_lines(filtered)
  local new_lines = {}

  if open then
    table.insert(new_lines, "<details open>")
  else
    table.insert(new_lines, "<details>")
  end
  table.insert(new_lines, "")
  table.insert(new_lines, "<summary>" .. summary .. "</summary>")
  table.insert(new_lines, "")

  if #filtered > 0 then
    for i = 1, #filtered do
      table.insert(new_lines, filtered[i])
    end
  end

  table.insert(new_lines, "")
  table.insert(new_lines, "</details>")

  vim.api.nvim_buf_set_lines(bufnr, line1 - 1, line2, false, new_lines)
end

function M.setup()
  vim.api.nvim_create_user_command("MdAccordion", function(opts)
    local arg = opts.fargs[1]
    local open = arg and arg:lower() == "open" or false
    M.run(opts.line1, opts.line2, open)
  end, {
    range = true,
    nargs = "?",
  })
end

return M
