local M = {}
local fn = vim.fn
local colors = vim.g.interestingwords_colors or { "#8CCBEA", "#A4E57E", "#FFDB72", "#FF7272", "#FFB3FF", "#9999FF" }
local highlight_prefix = "Interestingwords_"
-- save matchadd id words_group, its item struct is {word, id}

-- init highlight
for index, value in ipairs(colors) do
  vim.api.nvim_set_hl(0, highlight_prefix .. index, { bg = value, fg = "Black" })
end

-- return: found, index
-- If found the word, then return {true, index}
-- If found an empty index, then return the {false, index}
-- Otherwise return {false, #words_group + 1}
local function get_word_index(word)
  local index = 1
  local min_nil_index = 0
  local words = vim.w.words_array

  if not words then
    return false, -1
  end

  for i = 1, #words do
    if words[i] ~= nil and #words[i] ~= 0 then
      if words[i][1] == word then
        return true, i
      end
    elseif min_nil_index == 0 then
      min_nil_index = i
    end
    index = index + 1
  end

  if min_nil_index ~= 0 then
    index = min_nil_index
  end

  return false, index
end

local function color_word(index, word)
  local words = vim.w.words_array
  if index > #colors then
    print("Number of highlight-word is greater than " .. #colors)
    return
  end

  local hi = highlight_prefix .. index
  local id = fn.matchadd(hi, string.format([[\V\<%s\>]], word), 11)
  words[index] = { word, id }
  vim.w.words_array = words
end

local function uncolor_word(index)
  local words = vim.w.words_array
  fn.matchdelete(words[index][2])
  words[index] = {}
  vim.w.words_array = words
end

function M.toggle(word)
  if vim.w.words_array == nil then
    vim.w.words_array = {}
  end

  local found, index = get_word_index(word)
  if found then
    uncolor_word(index)
  else
    color_word(index, word)
  end
end

function M.uncolor_all()
  local words = vim.w.words_array
  if words == nil then
    return
  end
  for key, value in pairs(words) do
    pcall(fn.matchdelete, value[2])
    words[key] = nil
  end
  vim.w.words_array = words
end

function M.navigate(word, direction)
  local search_native = function(word, direction)
    local direct = 'N'
    if not direction then
      direct = 'n'
    end

    local key = vim.api.nvim_replace_termcodes(direct, true, false, true)
    vim.api.nvim_feedkeys(key, "n", true)
  end


  local search = fn.search

  local found, _ = get_word_index(word)
  if not found then
    search = search_native
  end

  word = string.format('\\V\\<%s\\>', word)
  if direction == nil then
    search(word)
  else
    search(word, direction)
  end
end

return M
