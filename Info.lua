
-- Info.lua

-- Implements the g_PluginInfo standard plugin description





g_PluginInfo =
{
	Name = "Catastrophe",
	Version = 0,
	Description = "",
	
	Commands =
	{
		["/catastrophe"] =
		{
			Alias = {"/c", "/cat"},
			Permission = "catastrophe.create",
			HelpString = "Allows you to spawn catastrophes",
			Handler = HandleCatastropheCommand,
		},
	},
}



