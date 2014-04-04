xm.item do
  if item.is_a?(Note)
    xm.title item.body
  else
    xm.title item.title
  end
  content_html =
    if item.password_protected?
      "<p>This article is password protected. Please <a href='#{item.permalink_url}'>fill in your password</a> to read it</p>"
    elsif this_blog.hide_extended_on_rss
      html(item, :body)
    else
      html(item, :all)
    end
  xm.description content_html + item.get_rss_description
  xm.pubDate item.published_at.rfc822
  xm.guid "urn:uuid:#{item.guid}", "isPermaLink" => "false"
  if item.link_to_author?
    xm.author "#{item.user.email} (#{item.user.name})"
  end

  if item.is_a?(Article)
    xm.comments(item.permalink_url("comments"))
    for category in item.categories
      xm.category category.name
    end
    for tag in item.tags
      xm.category tag.display_name
    end
    # RSS 2.0 only allows a single enclosure per item, so only include the first one here.
    if not item.resources.empty?
      resource = item.resources.first
      xm.enclosure(
        :url => item.blog.file_url(resource.upload_url),
        :length => resource.size,
        :type => resource.mime)
      end
    end

  if item.allow_pings?
    xm.trackback :ping, item.trackback_url
  end
  xm.link item.permalink_url
end

