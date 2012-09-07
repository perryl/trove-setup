-- mason-notify.post-receive.lua
--
-- Global post-receive hook which notifies Mason of any and all refs updates
-- (except refs/gitano/*) which happen.
--
-- It notifies Mason *before* passing the updates on to the project hook.
--
-- Copyright 2012 Codethink Limited
--
-- This is a part of Trove and re-use is limited to Baserock systems only.
--

local project_hook, repo, updates = ...

local masonhost = "##MASON_HOST##:##MASON_PORT##"
local basepath = "/1.0"
local urlbases = {
   "git://##TROVE_HOSTNAME##/",
   "ssh://git@##TROVE_HOSTNAME##/",
}

local notify_mason = false

for ref in pairs(updates) do
   if not ref:match("^refs/gitano/") then
      notify_mason = true
   end
end

if notify_mason and repo.name ~= "gitano-admin" then
   -- Build the report...
   local masoninfo, indent_level = {}, 0
   local function _(...)
      masoninfo[#masoninfo+1] = ("    "):rep(indent_level) .. table.concat({...})
   end
   local function indent()
      indent_level = indent_level + 1
   end
   local function dedent()
      indent_level = indent_level - 1
   end
   _ "{" indent()
   
   _ '"urls": [' indent()

   for i = 1, #urlbases do
      local comma = (i==#urlbases) and "" or ","
      _(("%q,"):format(urlbases[i] .. repo.name)
      _(("%q%s"):format(urlbases[i] .. repo.name .. ".git", comma))
   end

   dedent() _ "],"

   _ '"changes": [' indent()

   local toreport = {}
   for ref, info in pairs(updates) do
      if not ref:match("^refs/gitano") then
	 toreport[#toreport+1] = { 
	    ('"ref": %q,'):format(ref),
	    ('"old": %q,'):format(info.oldsha),
	    ('"new": %q'):format(info.newsha)
	 }
      end
   end
   for i = 1, #toreport do
      local comma = (i==#toreport) and "" or ","
      _ "{" indent()
      for __, ent in ipairs(toreport[i]) do
	 _(ent)
      end
      dedent() _("}", comma)
   end
   dedent() _ "]"

   dedent() _ "}"

   -- And finalise the JSON object
   _("")
   masoninfo = table.concat(masoninfo, "\n")
   log.state("Notifying Mason of changes...")

   local code, msg, headers, content =
      http.post(masonhost, basepath, "application/json", masoninfo)
   if code ~= "200" then
      log.state("Notification failed somehow")
   end
   for line in content:gmatch("([^\r\n]*)\r?\n") do
      log.state("Mason: " .. line)
   end
end

-- Finally, chain to the project hook
return project_hook(repo, updates)
