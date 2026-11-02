-- fletcher diagrams. The import's version is the one pinned in
-- writing/default.nix, so it always resolves offline.
local version = vim.g.fletcher_version

return {
  s(
    { trig = "fimport", desc = "Import fletcher" },
    t('#import "@preview/fletcher:' .. version .. '" as fletcher: diagram, node, edge')
  ),

  s(
    { trig = "diag", desc = "fletcher diagram" },
    fmta(
      [[
        #diagram(
          node-stroke: 1pt,
          node((0, 0), [<>]),
          edge("<>"),
          node((1, 0), [<>]),
        )
      ]],
      { i(1, "A"), i(2, "->"), i(3, "B") },
      { dedent = true }
    )
  ),

  s({ trig = "node", desc = "fletcher node" }, fmta("node((<>, <>), [<>]),", { i(1, "0"), i(2, "0"), i(3) })),

  s(
    { trig = "edge", desc = "fletcher edge" },
    fmta('edge((<>), (<>), "<>"),', { i(1, "0, 0"), i(2, "1, 0"), i(3, "->") })
  ),
}
