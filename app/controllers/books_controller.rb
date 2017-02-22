require 'mechanize'
require 'open-uri'

class BooksController < ApplicationController

  @@local_img_path = '/Users/mkam/books/app/assets/images/'
  @@agent = Mechanize.new

  def show
    scrape_bn
    render text: "OK"
  end

  private

  def scrape_bn
    @@agent.user_agent_alias = random_user_agent
    debugger
    #main index of all picture books
    page = @@agent.get('http://www.barnesandnoble.com/b/picture-books/books/kids/_/N-8Z2eg0Z29Z8q8Ztu1')
    # random_delay
    doc = Nokogiri::HTML(page.content)
    results = doc.css("div.resultsListContainer li.clearer")
    results.each do |listing|
      debugger
      scrape_bn_book(book_block)
    end
  end


  def scrape_bn_book(book)
    hash = {}
    image_path = "http://" + doc.css('div.resultsListContainer li.clearer ul li a img')[0]['src']
    hash = hash.merge({"image_path" => image_path})
  end


  #rand returns random double between 0 and 10
  def random_delay
    sleep(rand * 10)
  end

  def scrape_amazon
    #page 1
    @@agent.user_agent_alias = random_user_agent
    page = @@agent.get('https://www.amazon.com/b/ref=s9_acss_bw_cg_CHP8P_2b1_w?node=2578999011')
    random_delay
    doc = Nokogiri::HTML(page.content)
    results = doc.css('div#search-results div#mainResults ul li')
    results.each do |book_block|
      scrape_amazon_book(book_block)
    end

    #PAGES 2-20
    for i in 2..20
      @@agent.user_agent_alias = random_user_agent
      page = @@agent.get('https://www.amazon.com/s/ref=sr_pg_' + i.to_s + '?rh=n%3A283155%2Cn%3A%211000%2Cn%3A4%2Cp_n_feature_five_browse-bin%3A2578999011&page=' + i.to_s)
      random_delay
      doc = Nokogiri::HTML(page.content)
      results = doc.css('div#resultsCol div#atfResults ul li')
      results.each do |book_block|
        scrape_amazon_book(book_block)
      end
    end
  end

  def scrape_amazon_book(book)
    item_type = book.css("div.a-col-right div.a-spacing-none a h3").text
    acceptable_types = ["Hardcover", "Board book", "Paperback"]
    if acceptable_types.include?(item_type)
      hash = {}
      title = book.css("a.s-access-detail-page h2").text
      hash = hash.merge({"title" => title})

      author = book.css("div.a-col-right span.a-size-small a").text
      hash = hash.merge({"author" => author})
      Rails.logger.debug "+++++++++++++++ " + title + "+++++++++++++++++\n\n"

      formatted_title = title.split(" ").join("_")
      file_name = formatted_title.gsub(/[\/\;\,\!\:\'\(\)]/, '') #remove special characters when creating a file name
      file_name_final = file_name.slice(0,75)

      image_url = book.css('div.a-col-left img')[0]["src"]
      download = open(image_url)

      open(@@local_img_path + file_name_final + ".jpg", 'w')

      IO.copy_stream(download, @@local_img_path + file_name_final + ".jpg")

      hash = hash.merge({"image_path" => file_name_final+".jpg"})

      details_url = book.css('div.a-col-right div.a-spacing-small a.s-access-detail-page')[0]["href"]
      @@agent.user_agent_alias = random_user_agent
      details_page = @@agent.get(details_url)
      doc2 = Nokogiri::HTML(details_page.content)

      price = doc2.css("div#formats ul li span.a-color-price").text.strip
      hash = hash.merge({"price" => price})
      description = doc2.css("div#bookDescription_feature_div noscript").text.strip
      hash = hash.merge({"description" => description})

      product_bullets = doc2.css("div#detail-bullets div.content > ul > li")

      product_bullets.each do |item|
        pair = item.text.split(":")
        key = pair[0].strip
        if !key.include?("Customer Review") && !key.include?("Language") && !key.include?("ASIN") #throw away these items
          if key.include?("Best Sellers")
            list_items = item.css("ul.zg_hrsr li")
            categories = get_tags_array(list_items)
            hash_elt = {"tags" => categories}
          elsif pair[1] != nil
            val = pair[1].strip
            hash_elt = format_product_detail_value(key, val)
          else
            debugger
            Rails.logger.debug "++++++++++++++ error in product bullet key. item = " + item
            hash_elt = format_product_detail_value(key, "none")
          end
          if (hash_elt.present?)
            hash = hash.merge(hash_elt)
          end
        end
      end
      random_delay
      do_insert(hash)
    end

  end

  #params is a hash of key, value pairs
  def do_insert(params)
    Book.create(params)
  end

  def get_tags_array(list_items)
    categories = []
    list_items.each do |item|
      links = item.css("span.zg_hrsr_ladder a")
      num_levels = links.length
      for i in 2..num_levels-1
        categories << links[i].text
      end
    end
    return categories
  end

  def handle_blank_value(value)
    if (value == "none")
      result = "none"
    else
      result = value.split(" ")[1]
    end
  end

  def format_product_detail_value(key, value)
    case key
      when "Age Range"
        elts = value.split(" ")
        val = elts[0] + elts[1] + elts[2]
        {"age" => val}
      when "Grade Level"
        elts = value.split(" ")
        val = elts[0] + elts[1] + elts[2]
        {"grade" => val}
      when "Hardcover"
        result = handle_blank_value(value)
        {"cover_type" => "hard", "pages" => result}
      when "Paperback"
        result = handle_blank_value(value)
        {"cover_type" => "paper", "pages" => result}
      when "Series"
        {"series" => value}
      when "Board book"
        result = handle_blank_value(value)
        {"cover_type" => "board", "pages" => result}
      when "Publisher"
        sections = value.split("(")
        val = sections[0].strip
        date = sections[1].slice(0, sections[1].length-1)
        {"publisher" => val, "publish_date" => date}
      when "Lexile Measure"
        val = value.split(" ")[0]
        {"lexile" => val}
      when "ISBN-10"
        {"ISBN10" => value}
      when "ISBN-13"
        {"ISBN13" => value}
      when "Product Dimensions"
        {"dimensions" => value}
      when "Shipping Weight"
        elts = value.split(" ")
        unit = elts[1]
        units = ""
        if (unit == "ounces" || unit == "ounce")
          units = "oz"
        elsif (unit == "pounds" || unit == "pound")
          units = "lbs"
        else
          puts "error parsing shipping weight"
        end
        result = elts[0] + " " + units
        {"weight" => result}
      when "Amazon Best Sellers Rank"
      else
        debugger
        print('Case is key: ' + key + ' and value: ' + value + ' It is not a recognized label for Product Details')
     end
  end

  def books_params
    params.require(:book).permit(:title, :author, :publish_date)
  end

  def random_user_agent
    agent_array =
    [
      "Linux Firefox",
      "Linux Konqueror",
      "Linux Mozilla",
      "Mac Firefox",
      "Mac Mozilla",
      "Mac Safari 4",
      "Mac Safari",
      "Windows Chrome",
      "Windows IE 6",
      "Windows IE 7",
      "Windows IE 8",
      "Windows IE 9",
      "Windows IE 10",
      "Windows IE 11",
      "Windows Edge",
      "Windows Mozilla",
      "Windows Firefox"
      # "iPhone",
      # "iPad",
      # "Android"
    ]
    num_agents = agent_array.length
    index = rand(0..num_agents-1)
    return agent_array[index]
  end
end
