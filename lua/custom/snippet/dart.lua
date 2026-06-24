local ls = require("luasnip")

local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("pt", {
    t("debugPrint(' koking \\n' + '"),
    i(1),
    t("');"),
  }),

  s("spc", {
    t({
      "/// koking",
      "color: Colors.red,",
      "padding: const EdgeInsets.all(5),",
      "margin: const EdgeInsets.all(5),",
    }),
  }),

  s("sz", {
    t({
      "child: const SizedBox(",
      "  /// koking",
      "  height: 30,",
      "  width: 30,",
      "),",
    }),
  }),
}