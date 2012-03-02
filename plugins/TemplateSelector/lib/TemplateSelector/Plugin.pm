# Copyright 2011 Rick Bychowski http://hiranyaloka.com
# This program is free software; you can redistribute it and/or modify it
# under the terms of either: the GNU General Public License as published
# by the Free Software Foundation; or the Artistic License.
# See http://dev.perl.org/licenses/ for more information.

package TemplateSelector::Plugin;
use strict;

# EDIT ENTRY/PAGE CALLBACK - insert template/widget selection menu for TemplateSelector tag config
# some code lifted from Endevver's Supr plugin and Byrne Reese's PageLayout plugin
sub edit_entry_param {
  my ($cb, $app, $param, $tmpl) = @_;
  my $blog = $app->blog;
  my $blog_id = $blog->id;
  my ($entry, $template_selector, $widget_selector, $widgetset_selector);
  # retrieve if previous template/widget selector values
  if ($param->{id}) {
    my $type = $param->{object_type};
    my $class = $app->model($type);
    if (!$class) {
	    MT->log({ blog_id => $blog->id, message => "Invalid type " . $type });
	    return 1; # fail gracefully
    }
    $entry = $class->load($param->{id})  or return 1;
    $template_selector = $entry->template_selector || '';
    $widget_selector = $entry->widget_selector || '';
     $widgetset_selector = $entry->widgetset_selector || '';
 }
  #fall back to defaults if empty 
  my $blog_id = $blog->id;
  my $plugin = MT->component("TemplateSelector");
  my $ts_show_menu = $plugin->get_config_value( 'ts_show_menu',
    'blog:' . $blog_id );
  my $ws_show_menu = $plugin->get_config_value( 'ws_show_menu',
    'blog:' . $blog_id );
  my $wss_show_menu = $plugin->get_config_value( 'wss_show_menu',
    'blog:' . $blog_id );
  $template_selector = $template_selector || $plugin->get_config_value( 'template_selector_default',
    'blog:' . $blog_id );
  $widget_selector = $widget_selector || $plugin->get_config_value( 'widget_selector_default',
    'blog:' . $blog_id );
  $widgetset_selector = $widgetset_selector || $plugin->get_config_value( 'widgetset_selector_default',
    'blog:' . $blog_id );
  # retrieve stored template selector menu
  my ($ts_menu_string, $ws_menu_string, $wss_menu_string);
  $ts_menu_string = $blog->ts_menu_string;  
  $ws_menu_string = $blog->ws_menu_string;  
  $wss_menu_string = $blog->wss_menu_string;  
  my @ts_options = split( /\s*\|\s*/, $ts_menu_string );
  push @ts_options, '';
  my @ws_options = split( /\s*\|\s*/, $ws_menu_string );
  push @ws_options, '';
  my @wss_options = split( /\s*\|\s*/, $wss_menu_string );
  push @wss_options, '';
  # generate template/widget selector menu
  my $ts_opts;
  foreach (@ts_options) {
    my $ts_selected = ($template_selector eq $_);
    $ts_opts .= '<option value="'.$_.'"'.($ts_selected ? ' selected' : $template_selector)
      .'>'.$_."</option>\n";
  }
 my $ws_opts;
  foreach (@ws_options) {
    my $ws_selected = ($widget_selector eq $_);
    $ws_opts .= '<option value="'.$_.'"'.($ws_selected ? ' selected' : $widget_selector)
      .'>'.$_."</option>\n";
  }
 my $wss_opts;
  foreach (@wss_options) {
    my $wss_selected = ($widgetset_selector eq $_);
    $wss_opts .= '<option value="'.$_.'"'.($wss_selected ? ' selected' : $widgetset_selector)
      .'>'.$_."</option>\n";
  }
  my $ts_setting = $tmpl->createElement('app:setting', { 
    id => 'template_selector', label => "Template Selector", shown => $ts_show_menu });
  $ts_setting->innerHTML('<select name="template_selector">'.$ts_opts.'</select>');
  $tmpl->insertAfter($ts_setting,$tmpl->getElementById('authored_on'));    

  my $ws_setting = $tmpl->createElement('app:setting', { 
    id => 'widget_selector', label => "Widget Selector", shown => $ws_show_menu });
  $ws_setting->innerHTML('<select name="widget_selector">'.$ws_opts.'</select>');
  $tmpl->insertAfter($ws_setting,$tmpl->getElementById('authored_on'));    

  my $wss_setting = $tmpl->createElement('app:setting', { 
    id => 'widgetset_selector', label => "Widget Set Selector", shown => $wss_show_menu });
  $wss_setting->innerHTML('<select name="widgetset_selector">'.$wss_opts.'</select>');
  $tmpl->insertAfter($wss_setting,$tmpl->getElementById('authored_on'));    

  $param;
}

# EDIT ENTRY CALLBACK - Save selected template name to db
sub cms_post_save_entry {
  my ( $cb, $entry, $entry_orig ) = @_;
  my ($ts_selection, $ws_selection, $wss_selection);
  my $entry_id = $entry->id;
  my $app = MT->app;
  return unless $app->isa('MT::App');
  $ts_selection = $app->param('template_selector') || '';
  $ws_selection = $app->param('widget_selector') || '';
  $wss_selection = $app->param('widgetset_selector') || '';

  $entry->template_selector($ts_selection) if $ts_selection;
  $entry->widget_selector($ws_selection) if $ws_selection;
  $entry->widgetset_selector($wss_selection) if $wss_selection;
  $entry->save if ($ts_selection || $ws_selection || $wss_selection );
  return 1;
}

# EDIT PAGE CALLBACK - Save selected template name to db
sub cms_post_save_page {
  my ( $cb, $page, $page_orig ) = @_;
  my ($ts_selection, $ws_selection, $wss_selection);
  my $app = MT->app;
  return unless $app->isa('MT::App');
  $ts_selection = $app->param('template_selector') || '';
  $ws_selection = $app->param('widget_selector') || '';
  $wss_selection = $app->param('widgetset_selector') || '';

  $page->template_selector($ts_selection) if $ts_selection;
  $page->widget_selector($ws_selection) if $ws_selection;
  $page->widgetset_selector($wss_selection) if $wss_selection;
  $page->save if ($ts_selection || $ws_selection || $wss_selection);
  return 1;
}

# TAG - returns the template name
sub _hdlr_template_selector {
  my ( $ctx, $args ) = @_;
  my $blog = $ctx->stash('blog');
  my $blog_id = $blog->id;
  my $plugin = MT->component("TemplateSelector");
  my $template_selector_default = $plugin->get_config_value( 'template_selector_default',
    'blog:' . $blog_id );
  my $entry = $ctx->stash('entry');
  return '' if !$entry;
  return $entry->template_selector || $template_selector_default || '';
}

# TAG - returns the widget name
sub _hdlr_widget_selector {
  my ( $ctx, $args ) = @_;
  my $blog = $ctx->stash('blog');
  my $blog_id = $blog->id;
  my $plugin = MT->component("TemplateSelector");
  my $widget_selector_default = $plugin->get_config_value( 'widget_selector_default',
    'blog:' . $blog_id );
  my $entry = $ctx->stash('entry');
  return '' if !$entry;
  return $entry->widget_selector || $widget_selector_default || '';
}

# TAG - returns the widget set name
sub _hdlr_widgetset_selector {
  my ( $ctx, $args ) = @_;
  my $blog = $ctx->stash('blog');
  my $blog_id = $blog->id;
  my $plugin = MT->component("TemplateSelector");
  my $widgetset_selector_default = $plugin->get_config_value( 'widgetset_selector_default',
    'blog:' . $blog_id );
  my $entry = $ctx->stash('entry');
  return '' if !$entry;
  return $entry->widgetset_selector || $widgetset_selector_default || '';
}

# CUSTOM CONFIG_TYPE - Blog-level template selector menu
sub _hdlr_ts_menu {
  my $app = shift;
  my ($field_id, $field, $value) = @_;
  my $blog = $app->blog;
  my $ts_menu_string = $blog->ts_menu_string;
  
  my $plugin = MT->component("TemplateSelector");
  my $template_selector_default = $plugin->get_config_value( 'template_selector_default',
    'blog:' . $app->blog->id );
  my @ts_options = split( /\|/, $ts_menu_string );
  push @ts_options, '';
  my $options;
  foreach my $opt (@ts_options) {
    my $selected = ($template_selector_default eq $opt);
    $options .= '<option value="'.$opt.'"'.($selected ? ' selected' : '').'>'.$opt."</option>\n";
    }
  return '<select name="template_selector_default" class="ts_menu">' . $options . '</select>' ;
}

# CUSTOM CONFIG_TYPE - Blog-level widget selector menu
sub _hdlr_ws_menu {
  my $app = shift;
  my ($field_id, $field, $value) = @_;
  my $blog = $app->blog;
  my $ws_menu_string = $blog->ws_menu_string;
  
  my $plugin = MT->component("TemplateSelector");
  my $widget_selector_default = $plugin->get_config_value( 'widget_selector_default',
    'blog:' . $app->blog->id );
  my @ws_options = split( /\|/, $ws_menu_string );
  push @ws_options, '';
  my $options;
  foreach my $opt (@ws_options) {
    my $selected = ($widget_selector_default eq $opt);
    $options .= '<option value="'.$opt.'"'.($selected ? ' selected' : '').'>'.$opt."</option>\n";
    }
  return '<select name="widget_selector_default" class="ws_menu">' . $options . '</select>' ;
}

# CUSTOM CONFIG_TYPE - Blog-level widget selector menu
sub _hdlr_wss_menu {
  my $app = shift;
  my ($field_id, $field, $value) = @_;
  my $blog = $app->blog;
  my $wss_menu_string = $blog->wss_menu_string;
  
  my $plugin = MT->component("TemplateSelector");
  my $widgetset_selector_default = $plugin->get_config_value( 'widgetset_selector_default',
    'blog:' . $app->blog->id );
  my @wss_options = split( /\|/, $wss_menu_string );
  push @wss_options, '';
  my $options;
  foreach my $opt (@wss_options) {
    my $selected = ($widgetset_selector_default eq $opt);
    $options .= '<option value="'.$opt.'"'.($selected ? ' selected' : '').'>'.$opt."</option>\n";
    }
  return '<select name="widgetset_selector_default" class="wss_menu">' . $options . '</select>' ;
}

# OPTIONS CALLBACK - template options
# also creates concatenated template name list and saves to db
sub ts_options {
  my ($cb, $app, $option_hash, $old_value, $new_value) = @_;
 
  unless ($old_value eq $new_value) {
 
    my $blog = $app->blog;
    my $blog_id = $blog->id;
    my $scope = "blog:" . $blog_id;
    my $option = $option_hash->{basename};
    $app->log({
      message => "Changing " . $option
      . " from '" . $old_value 
      . "' to '" . $new_value . "'."
    });

    # get the option values
    my $plugin = MT->component("TemplateSelector");
    my $ts_trim = ($option eq 'ts_trim') ? $new_value : $plugin->get_config_value( 'ts_trim', $scope );
    my $ts_type_string = ($option eq 'ts_type') ? $new_value : $plugin->get_config_value( 'ts_type', $scope );
    my $ts_outfile_string = ($option eq 'ts_outfile') ? $new_value : $plugin->get_config_value( 'ts_outfile', $scope );
    my $ts_name_string = ($option eq 'ts_name') ? $new_value : $plugin->get_config_value( 'ts_name', $scope );

    # untaint the outfile option 
    {
      $ts_outfile_string =~ /^([\w\s\.\-\/%]+)$/;
      $ts_outfile_string = $1;
    }
    # untaint the name option
    {
      $ts_name_string =~ /^([\w\s\.\-\/%]+)$/;
      $ts_name_string = $1;
    }

    # trim leading/trailing whitespace if ts_trim option is set
    if ($ts_trim) {
      $ts_outfile_string = trim_whitespace($ts_outfile_string);
      $ts_name_string = trim_whitespace($ts_name_string);
    }
 
    $app->log({
      message => "ts_type_string: '" . $ts_type_string
        . "' ts_outfile_string: '" . $ts_outfile_string
        . "' ts_name_string: '" . $ts_name_string . "'"
    });
 
    my @maps;
    # my @maps = MT::Template->load({ $ts_name_string, $ts_type_string, $ts_outfile_string, blog_id => $blog->id, });
    if ($ts_type_string and (! $ts_outfile_string) and (! $ts_name_string)) {
      mt_log($app, 'Only type selected');
      @maps = MT::Template->load({ type => "$ts_type_string", blog_id => $blog->id, });
    } elsif ($ts_outfile_string and (! $ts_name_string)) {
      mt_log($app, 'Only type and outfile selected');
      @maps = MT::Template->load({ type => "$ts_type_string", outfile => {like => "$ts_outfile_string" },
        blog_id => $blog->id, });
    } elsif ((! $ts_type_string) and $ts_name_string) {
      mt_log($app, 'Only name selected');
      @maps = MT::Template->load({ name => {like => "$ts_name_string" }, blog_id => $blog->id, });
    } elsif ($ts_type_string and (! $ts_outfile_string) and $ts_name_string) {
      mt_log($app, 'Only type and name selected');
      @maps = MT::Template->load({ type => "$ts_type_string", name => {like => "$ts_name_string" },
        blog_id => $blog->id, });
    } elsif ($ts_outfile_string and $ts_name_string) {
      mt_log($app, 'Type outfile and name selected');
      @maps = MT::Template->load({ type => "$ts_type_string", outfile => {like => "$ts_outfile_string" },
        name => {like => "$ts_name_string" }, blog_id => $blog->id, });
    } elsif ((! $ts_type_string) and (! $ts_name_string)) {
      @maps = MT::Template->load();
    } else {
      return 1;
    }

    # extract the template names.
    my @names = map {$_->name} @maps;
    # filter out backup templates.
    my @names = grep {(! /Backup \d{4}\-\d{2}\-d{2}/)} @names;
    my $ts_menu_string = join ('|', @names);
    # retrieve ts_menu_string from db and save if changed
    my $ts_menu_string_db = $blog->ts_menu_string;
    unless ($ts_menu_string eq $ts_menu_string_db) {
      $app->log({
        message => "Saving ts_menu_string '"
          . $ts_menu_string . "' to database."
      });
  
      $blog->meta('ts_menu_string', $ts_menu_string);
      $blog->save;
    }
  }   
  return 1;
}

# OPTIONS CALLBACK - widget options
# also creates concatenated widget name list and saves to db
sub ws_options {
  my ($cb, $app, $option_hash, $old_value, $new_value) = @_;
 
  unless ($old_value eq $new_value) {
 
    my $blog = $app->blog;
    my $blog_id = $blog->id;
    my $scope = "blog:" . $blog_id;
    my $option = $option_hash->{basename};
    $app->log({
      message => "Changing " . $option
      . " from '" . $old_value 
      . "' to '" . $new_value . "'."
    });

    # get the option values
    my $plugin = MT->component("TemplateSelector");
    my $ts_trim = ($option eq 'ts_trim') ? $new_value : $plugin->get_config_value( 'ts_trim', $scope );
    my $ws_name_string = ($option eq 'ws_name') ? $new_value : $plugin->get_config_value( 'ws_name', $scope );

    # untaint the name option
    {
      $ws_name_string =~ /^([\w\s\.\-\/%]+)$/;
      $ws_name_string = $1;
    }

    # trim leading/trailing whitespace if ts_trim option is set
    if ($ts_trim) {
      $ws_name_string = trim_whitespace($ws_name_string);
    }
 
    $app->log({
      message => " ws_name_string: '" . $ws_name_string . "'"
    });
 
    my @maps;
    if ($ws_name_string) {
      mt_log($app, 'Name selected');
      @maps = MT::Template->load({ type => 'widget', name => {like => "$ws_name_string" },
        blog_id => $blog->id, });
    } elsif (! $ws_name_string) {
      @maps = MT::Template->load();
    } else {
      return 1;
    }

    # extract the template names.
    my @names = map {$_->name} @maps;
    # filter out backup templates.
    my @names = grep {(! /Backup \d{4}\-\d{2}\-d{2}/)} @names;
    my $ws_menu_string = join ('|', @names);
    # retrieve ts_menu_string from db and save if changed
    my $ws_menu_string_db = $blog->ws_menu_string;
    unless ($ws_menu_string eq $ws_menu_string_db) {
      $app->log({
        message => "Saving ws_menu_string '"
          . $ws_menu_string . "' to database."
      });
  
      $blog->meta('ws_menu_string', $ws_menu_string);
      $blog->save;
    }
  }   
  return 1;
}

# OPTIONS CALLBACK - widget set options
# also creates concatenated widget name list and saves to db
sub wss_options {
  my ($cb, $app, $option_hash, $old_value, $new_value) = @_;
 
  unless ($old_value eq $new_value) {
 
    my $blog = $app->blog;
    my $blog_id = $blog->id;
    my $scope = "blog:" . $blog_id;
    my $option = $option_hash->{basename};
    $app->log({
      message => "Changing " . $option
      . " from '" . $old_value 
      . "' to '" . $new_value . "'."
    });

    # get the option values
    my $plugin = MT->component("TemplateSelector");
    my $ts_trim = ($option eq 'ts_trim') ? $new_value : $plugin->get_config_value( 'ts_trim', $scope );
    my $wss_name_string = ($option eq 'wss_name') ? $new_value : $plugin->get_config_value( 'wss_name', $scope );

    # untaint the name option
    {
      $wss_name_string =~ /^([\w\s\.\-\/%]+)$/;
      $wss_name_string = $1;
    }

    # trim leading/trailing whitespace if ts_trim option is set
    if ($ts_trim) {
      $wss_name_string = trim_whitespace($wss_name_string);
    }
 
    $app->log({
      message => " wss_name_string: '" . $wss_name_string . "'"
    });
 
    my @maps;
    if ($wss_name_string) {
      mt_log($app, 'Name selected');
      @maps = MT::Template->load({ type => 'widgetset', name => {like => "$wss_name_string" },
        blog_id => $blog->id, });
    } elsif (! $wss_name_string) {
      @maps = MT::Template->load();
    } else {
      return 1;
    }

    # extract the template names.
    my @names = map {$_->name} @maps;
    # filter out backup templates.
    my @names = grep {(! /Backup \d{4}\-\d{2}\-d{2}/)} @names;
    my $wss_menu_string = join ('|', @names);
    # retrieve ts_menu_string from db and save if changed
    my $wss_menu_string_db = $blog->wss_menu_string;
    unless ($wss_menu_string eq $wss_menu_string_db) {
      $app->log({
        message => "Saving ws_menu_string '"
          . $wss_menu_string . "' to database."
      });
  
      $blog->meta('wss_menu_string', $wss_menu_string);
      $blog->save;
    }
  }   
  return 1;
}

# HELPER SUBROUTINES

sub mt_log {
   my ($app, $msg) = @_;
   $app->log({
    message => $msg
  });
}

sub trim_whitespace {
  my $string = shift;
  if ($string) {
    $string =~ s/^\s+//;
    $string =~ s/\s+$//;
  }
  return $string || '';
}

1;
