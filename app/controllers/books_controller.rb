require 'mechanize'

class BooksController < ApplicationController


  def show
    scrape_amazon
    render text: "OK"
  end

  private

  def scrape_amazon

    agent = Mechanize.new
    agent.user_agent_alias = 'Mac Safari'
    page = agent.get('https://www.amazon.com')
    search_form = page.form('site-search')
    search_form['field-keywords'] = 'picture books for children 3-5'
    page = agent.submit(search_form)

    #arrive at first book listings page

    # #region
    # region_text = page.parser.xpath("//div[@id='header_global_container']//li[@id='userGroups']/a[@id='userGroups_List_open']").text
    # region_string = region_text.split(" ").join(" ")
    # result = Region.find_by name: region_string
    # if (!result.nil?)
    #   regionid = result.id
    # end
    #
    # while (page.parser.xpath("//div[@class='forum_footer']/ul[@class='pagination']/li/a[@class='next']").text == 'Next') do #while there is a 'next' link at bottom of page
    #   scrape_page(page, agent, regionid)
    #   page = page.link_with(:text => 'Next').click
    # end
    #
    # scrape_page(page, agent, regionid) #scrape the last page
    # agent.shutdown #avoids the "too many connection reset" error

  end

    # def scrape_page(page, agent, regionid)
    #   all_links = page.parser.xpath("//table[@class='forums_index']//tr[@class='forum_message']//a[starts-with(@href, '/group/forum/message/')]/@href")
    #   all_links.each do |link|
    #     post_page = agent.get("http://www.bigtent.com" + link.value)
    #
    #     #topicid
    #     topic_info = post_page.parser.xpath("//div[@class='flag_container']/@id").first.value
    #     # topic_info = post_page.parser.xpath("//ul[@class='message_list']/li[@class='comments']/div[@class='flag_container']/@id").first.value
    #     topicid = topic_info[15..topic_info.length]
    #
    #     comments = post_page.parser.xpath("//ul[@class='message_list']/li[@class='comments']/ul[@class='comments_list']/li")
    #     comments.each do |comment|
    #       #userid
    #       userid = nil
    #       if (comment.xpath("div[@class='message_id']/p[@class='username']/a/@href").present?) #user still has active account
    #         username_href = comment.xpath("div[@class='message_id']/p[@class='username']/a/@href").first.value
    #         username_temp = username_href.chomp("?trackback")
    #         userid = username_temp[9..username_temp.length]
    #       end
    #
    #       #date
    #       date_str = comment.xpath("div[@class='message_id']/p[@class='date']").text
    #       dt = format_date(date_str)
    #
    #       #didn't find a way to traverse cleanly because no root node is available. have to iterate over until node is nil
    #       #skip over first <p> because it's always empty
    #       message_node = comment.xpath("div[@class='message']/p").first.next
    #       combined_msg = ""
    #
    #       while (message_node != nil)
    #         combined_msg += message_node.text + " "
    #         message_node = message_node.next
    #       end
    #       matches = find_dr_name_matches(combined_msg)
    #
    #       #dr name
    #       matches.each do |match|
    #         if (match != nil && match[0] != "dren's") # throw out "children's" string
    #           if match[1].in?(@@extra_words) && match[2].in?(@@extra_words)
    #             #do nothing. don't insert random preposition words into DB
    #           elsif match[2].in?(@@extra_words) # includes a "throw away" word (first AND last name)
    #             dr_name = match[1]
    #             do_insert(userid, dt, dr_name, topicid, regionid)
    #           else
    #             dr_name = match[1] + " " + match[2]
    #             do_insert(userid, dt, dr_name, topicid, regionid)
    #           end
    #         end
    #       end
    #     end
    #   end
    # end

end
