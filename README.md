TemplateSelector extends entries and pages with a new "TemplateSelector" custom field. The "TemplateSelector" tag can output the name of any template in your blog.

# USAGE
Within entry or page context of a template, use the tag to include a template by name:

    <mt:Include name="<mt:TemplateSelector>">

Or perhaps use the tag to set a variable:

    <mt:If tag="TemplateSelector"><mt:TemplateSelector setvar="my_template_name"></mt:If>

Then later in that template set a custom stylesheet:

    <link id="my_custom_layout" rel="stylesheet" href="<mt:Link template="$my_template_name">" type="text/css" media="screen" />

## Setting The Tag Value

Simply select a template name from a pull-down menu within the "edit entry/page" form.

# TEMPLATE SELECTOR MENU BUILDER

TemplateSelector can automatically search and present your entire list of templates. You probably don't want to present your entire list of templates in the selection menu, so the Preferences::Plugin Settings::TemplateSelector form presents three options to narrow down the list. The resulting list is the result of an intersection of the three options (e.g. List = Type AND Outfile AND Name).

The resulting template list is then used to build the Template Selector Default Form (on plugin options page) and the Template Selector form on each "edit entry/page" form.

## Template Type (optional)

Select from a single template type, or choose blank to return all types (blank is default).

* index - an Index Template
* archive - an Archive Template
* category - also an Archive Template
* individual - also an Archive Template
* custom - a Template Module.
* comments -  a Comment Listing Template
* comment_preview - a Comment Preview Template
* comment_error - a Comment Error Template
* popup_image - an Uploaded Image Popup Template
* BLANK - returns all types (default).

## Index Template Outfile (optional - requires Index type selection)
When the Index type is active, this text field matches against the Index Template Outfile path/name (precisely as shown in the "Design::Themes" panel of your blog's dashboard). Allows only certain characters (see below). Supports any combination of percent '%' and '_' wildcards. For example:

* '%.css' matches index style sheets.
* 'archives/%' matches any index templates with outfiles written to your blog root archives directory.

## Template Name (optional)
A simple text field matching the template name(s). Practically useful only when used with the wildcard characters (otherwise you can only possibly match a single template).

* Entry% - matches 'Entry', 'Entry Monthly', and 'Entry Listing'.
* Foo_Ba% - matches 'FoodBar', 'FootBall', 'Foo_Bar', etc.

## Allowed Characters for Outfile and Name fields
* Word characters - alphanumeric plus underscore.
* Whitespace - allowed (optionally trim trailing/leading whitespace).
* Symbols (outfile) - Hyphen '-', period '.', and forward slash '/'.
* Symbols (name) - Hyphen '-' and period '.' .
* Wildcard - Percent '%' matches any characters, underscore "_" matches a single character.

## Trim Leading/Trailing Whitespace checkbox
When checked, leading/trailing whitespace will be trimmed from the Outfile and Name fields. Default is checked.

## Blank Selection (Type, Outfile, and Name)
The default selection is blank. Leaving all three fields blank will (theoretically) return all templates on your system. However, the template list size limit is twenty (see BUGS section below).

# TEMPLATE SELECTOR DEFAULT VALUE
After saving the three menu builder options, the "Set Default Template" menu will update the list of templates available in the "Set Default Template" field in the plugin options page. So it doesn't make sense to attempt to change the "Menu Builder" and "Default Template" values at the same time (although in fact they are saved in the same form, see TO DO section).

# ENTRY/PAGE TEMPLATE SELECTOR
Template Selector surfaces a dropdown list populated with the templates derived from the plugin options. New entries/pages will be provided the default selection option from the plugin options page.

# INSTALLATION
To install this plugin follow the instructions found here:

http://tinyurl.com/easy-plugin-install

# DEPENDENCIES
Melody or Movable Type 4 with __ConfigAssistant 2.1.33 or above__. (ConfigAssistant 2.1.33 [added the options basename to the option_hash for callbacks](https://github.com/openmelody/mt-plugin-configassistant/commit/2e80e4edf7de4fbe6a05df2c11b0f55729d9e974)).

# Support, Feedback, Bugs, Feature Requests, ToDo

I would like to hear about your experience with TemplateSelector. Leave a comment on the [Hiranyaloka TemplateSelector  support page](http://hiranyaloka.com/website_design_encinitas/software/templateselector-plugin-for-melody-and-mt4.html) or email me at [rick@hiranyaloka.com](mailto:rick@hiranyaloka.com).

## Known Bugs
* My testing has revealed that only the first 20 templates are exposed in the selection form, regardless of how many template names are fed to the Template Selector default value form. I'm open to suggestions to fix that.

* Initial setting of the template “Type” field to “Index” at the same time as setting the Template “Outfile” option (in plugin settings) returns no templates to the list. The fix is to set the Template “Type” option by itself and subsequently add the Template “Outfile” option.

## Road Map
* Changes to the menu builder and default template options are submitted at the same time (with a single "Save Changes" button). Because the former affects the latter, it makes more sense to submit them separately (i.e. separate "Submit" buttons).

* Show error message when unsupported characters are entered in the Template Outfile or Template Name text field options.

* Allow for multiple values: &lt;TemplateSelector name="foo"&gt; .

* Extend other Melody objects: &ltTemplateSelector object='Category' name="bar"&gt; .

# THANKS
Thanks to Byrne Reese for guidance, support, and code examples in his PageLayout plugin for Melody.

Thanks also to the Melody team for ConfigAssistant and code examples from the Supr plugin.

# COPYRIGHT AND LICENSE

The software is released under the Artistic License. The
terms of the Artistic License are described at
http://www.perl.com/language/misc/Artistic.html .

Except where otherwise noted, TemplateSelector is Copyright 2011,
Rick Bychowski, rick@hiranyaloka.com for Hiranyaloka. All
rights reserved.
