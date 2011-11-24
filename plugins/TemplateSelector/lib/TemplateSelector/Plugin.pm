# Copyright 2011 Rick Bychowski http://hiranyaloka.com
# This program is free software; you can redistribute it and/or modify it
# under the terms of either: the GNU General Public License as published
# by the Free Software Foundation; or the Artistic License.
# See http://dev.perl.org/licenses/ for more information.

package TemplateSelector::Plugin;
use strict;

# EDIT ENTRY/PAGE CALLBACK - insert template selection menu for TemplateSelector tag config
# some code lifted from Endevver's Supr plugin and Byrne Reese's PageLayout plugin
sub edit_entry_param {
  my ($cb, $app, $param, $tmpl) = @_;
  my $blog = $app->blog;
  my ($entry, $template_selector);
  # retrieve if previous template selector value
  if ($param->{id}) {
    my $type = $param->{object_type};
    my $class = $app->model($type);
    $entry = $class->load($param->{id});
    $template_selector = $entry->template_selector() || '';
  }
  #fall back to default if empty 
  my $blog_id = $blog->id;
  my $plugin = MT->component("TemplateSelector");
  $template_selector = $template_selector || $plugin->get_config_value( 'template_selector_default',
    'blog:' . $app->blog->id );
  # retrieve stored template selector menu
  my $ts_menu_string;
  $ts_menu_string = $blog->ts_menu_string;  
  my @ts_options = split( /\s*\|\s*/, $ts_menu_string );
  push @ts_options, '';
  # generate template selector menu
  my $opts;
  foreach (@ts_options) {
    my $selected = ($template_selector eq $_);
    $opts .= '<option value="'.$_.'"'.($selected ? ' selected' : $template_selector)
      .'>'.$_."</option>\n";
  }
  my $setting = $tmpl->createElement('app:setting', { 
    id => 'template_selector', label => "Template Selector" });
  $setting->innerHTML('<select name="template_selector">'.$opts.'</select>');
  $tmpl->insertAfter($setting,$tmpl->getElementById('authored_on'));    

  $param;
}

# EDIT ENTRY CALLBACK - Save selected template name to db
sub cms_post_save_entry {
  my ( $cb, $entry, $entry_orig ) = @_;
  my $ts_selection;
  my $entry_id = $entry->id;
  my $app = MT->app;
  return unless $app->isa('MT::App');
  my $q = $app->can('query') ? $app->query : $app->param;
  if ( $app->can('param') ) {
    $ts_selection = $q->param('template_selector');
  }
  if ($ts_selection) {
    $entry->template_selector($ts_selection);
    $entry->save;

    $app->log({
      message => "Entry #" . $entry_id . " selected template '"
      . $ts_selection . "'."
    });
  }
  return 1;
}

# EDIT PAGE CALLBACK - Save selected template name to db
sub cms_post_save_page {
  my ( $cb, $page, $page_orig ) = @_;
  my $ts_selection;
  my $app = MT->app;
  return unless $app->isa('MT::App');
  my $q = $app->can('query') ? $app->query : $app->param;
  if ( $app->can('param') ) {
    $ts_selection = $q->param('template_selector');
  }
  if ($ts_selection) {
    $page->template_selector($ts_selection);
    $page->save;
  }
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
      $ts_outfile_string = ts_trim_whitespace($ts_outfile_string);
      $ts_name_string = ts_trim_whitespace($ts_name_string);
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

# HELPER SUBROUTINES

sub mt_log {
   my ($app, $msg) = @_;
   $app->log({
    message => $msg
  });
}

sub ts_trim_whitespace {
my $string = shift;
	$string =~ s/^\s+//;
	$string =~ s/\s+$//;
	return $string;
}

1;
