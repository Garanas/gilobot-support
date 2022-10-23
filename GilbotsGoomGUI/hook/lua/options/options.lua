do
	table.insert(options.ui.items, 
				{
					title = "GUI: Bigger Strategic Build Icons",
					key = 'gui_bigger_strat_build_icons',
					type = 'toggle',
					default = 1,
	                custom = {
						states = {
							{text = "<LOC _Off>", key = 0 },
							{text = "<LOC _On>", key = 1 },
						},
					},
				})
	table.insert(options.ui.items, 
				{
					title = "GUI: Template Rotation",
					key = 'gui_template_rotator',
					type = 'toggle',
					default = 1,
	                custom = {
						states = {
							{text = "<LOC _Off>", key = 0 },
							{text = "<LOC _On>", key = 1 },
						},
					},
				})
	table.insert(options.ui.items, 
				{
					title = "GUI: SCU Manager",
					key = 'gui_scu_manager',
					type = 'toggle',
					default = 1,
	                custom = {
						states = {
							{text = "<LOC _Off>", key = 0 },
							{text = "<LOC _On>", key = 1 },
						},
					},
				})
	table.insert(options.ui.items, 
				{
					title = "GUI: Draggable Build Queue",
					key = 'gui_draggable_queue',
					type = 'toggle',
					default = 1,
	                custom = {
						states = {
							{text = "<LOC _Off>", key = 0 },
							{text = "<LOC _On>", key = 1 },
						},
					},
				})
	table.insert(options.ui.items, 
				{
					title = "GUI: Middle Click Avatars",
					key = 'gui_idle_engineer_avatars',
					type = 'toggle',
					default = 1,
	                custom = {
						states = {
							{text = "<LOC _Off>", key = 0 },
							{text = "<LOC _On>", key = 1 },
						},
					},
				})
	table.insert(options.ui.items, 
				{
					title = "GUI: All Race Templates",
					key = 'gui_all_race_templates',
					type = 'toggle',
					default = 1,
	                custom = {
						states = {
							{text = "<LOC _Off>", key = 0 },
							{text = "<LOC _On>", key = 1 },
						},
					},
				})
	table.insert(options.ui.items, 
				{
					title = "GUI: Single Unit Selected Info",
					key = 'gui_enhanced_unitview',
					type = 'toggle',
					default = 1,
	                custom = {
						states = {
							{text = "<LOC _Off>", key = 0 },
							{text = "<LOC _On>", key = 1 },
						},
					},
				})
	table.insert(options.ui.items, 
				{
					title = "GUI: Single Unit Selected Rings",
					key = 'gui_enhanced_unitrings',
					type = 'toggle',
					default = 1,
	                custom = {
						states = {
							{text = "<LOC _Off>", key = 0 },
							{text = "<LOC _On>", key = 1 },
						},
					},
				})
    table.insert(options.ui.items,
                 {
                    title = "GUI: Zoom Pop Distance",
                    key = 'gui_zoom_pop_distance',
                    type = 'slider',
                    default = 80,
                    custom = {
                       min = 1,
                       max = 160,
                       inc = 1,
                    },
                 })
end
