#
# Copyright 2010 Red Hat, Inc.
#
# This is free software; you can redistribute it and/or modify it
# under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation; either version 3 of
# the License, or (at your option) any later version.
#
# This software is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this software; if not, write to the Free
# Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA, or see the FSF site: http://www.fsf.org.


# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def dom_class_for_body
    %(#{params[:controller]}_controller #{params[:action]}_action)
  end

  def content_for_superuser(text = nil, &block)
    raise ArgumentError.new("Don't supply both text and a block") if text and block_given?
    concat(text || capture(&block)) if current_user.superuser?
  end

  def style_display_none
    { :style => 'display: none;' }
  end

  def remove_link_unless_new_record(fields, link_title = 'remove')
    out = ''
    out << fields.hidden_field(:_destroy)  unless fields.object.new_record?
    out << link_to(link_title, "##{fields.object.class.name.underscore}", :class => 'remove')
    out
  end

  def generate_html(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f

    form_builder.fields_for(method, options[:object], :child_index => 'NEW_RECORD') do |f|
      render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })
    end
  end

  def generate_template(form_builder, method, options = {})
    escape_javascript generate_html(form_builder, method, options)
  end

  def back_or_default(default)
    request.env["HTTP_REFERER"] ? :back : default
  end

  def sort_link(text, column)
    column = column.to_s
    direction = (params[:sort_by] == column && params[:sort_dir] == 'ASC' ? 'DESC' : 'ASC')
    link_to text, "?sort_by=#{column}&sort_dir=#{direction}", :class => (params[:sort_by] == column ? 'sort_column' : '')
  end

  def timeago(time, options = {})
    options[:class] ||= "timeago"
    content_tag(:abbr, time.to_s(:standard), options.merge(:title => time.getutc.iso8601)) if time
  end
end
