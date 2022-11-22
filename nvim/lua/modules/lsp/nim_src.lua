local null_ls = require("null-ls")

local CompletionItemKind = vim.lsp.protocol.CompletionItemKind
local kinds = {
  d = CompletionItemKind.Keyword,
  f = CompletionItemKind.Function,
  t = CompletionItemKind.Struct,
  v = CompletionItemKind.Variable,
}

return {
  method = null_ls.methods.COMPLETION,
  filetypes = { "nim" },
  generator = {
    async = true,
    fn = function(params, done)
      vim.fn["nim#suggest#sug#GetAllCandidates"](function(start, candidates)
        local items = vim.tbl_map(function(candidate)
          return {
            kind = kinds[candidate.kind] or CompletionItemKind.Text,
            label = candidate.word,
            documentation = candidate.info,
          }
        end, candidates)
        done({ { items = items } })
      end)
    end,
  },
}
